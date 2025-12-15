import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:neonrom3r/models/aria2c.dart';
import 'package:neonrom3r/models/download_source_rom.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:neonrom3r/utils/process_helper.dart';
import 'package:neonrom3r/utils/string_helper.dart';
import 'package:path/path.dart' as p;

import 'files_system_helper.dart';

/// ============================================================================
/// Internal Classes
/// ============================================================================
class IsolateActiveJob {
  final String id;
  final Isolate isolate;
  final ReceivePort receivePort;
  final StreamSubscription sub;
  final StreamController<Aria2Event> controller;
  SendPort controlPort;

  IsolateActiveJob({
    this.id,
    this.isolate,
    this.receivePort,
    this.sub,
    this.controller,
  });
}

class IsolateArgs {
  final SendPort sendPort;
  final String aria2cPath;
  final String uri;
  final int fileIndex;
  final String downloadPath;

  IsolateArgs({
    this.sendPort,
    this.aria2cPath,
    this.uri,
    this.fileIndex,
    this.downloadPath,
  });
}

/// ============================================================================
/// Download Manager
/// ============================================================================

class Aria2DownloadManager {
  static final Map<String, IsolateActiveJob> _jobs = {};

  /// Starts a ROM download using:
  /// - [RomInfo]   → metadata / folder name
  /// - [DownloadSourceRom] → torrent source & file index
  static Future<Aria2DownloadHandle> startDownload({
    RomInfo rom,
    DownloadSourceRom source,
    String aria2cPath,
  }) async {
    final uri = source.uris.first;
    final id = StringHelper.hash20(uri + rom.title);

    if (_jobs.containsKey(id)) {
      throw StateError('Download already running for id=$id');
    }

    final receivePort = ReceivePort();
    final controller = StreamController<Aria2Event>.broadcast();
    final doneCompleter = Completer<Aria2DoneEvent>();

    final isolate = await Isolate.spawn<IsolateArgs>(
      _downloadIsolateMain,
      IsolateArgs(
        sendPort: receivePort.sendPort,
        aria2cPath: aria2cPath,
        uri: uri,
        fileIndex: source.fileIndex,
        downloadPath:
            p.join(FileSystemHelper.downloadsPath, rom.console, rom.title),
      ),
      debugName: 'aria2c-$id',
    );

    SendPort controlPort;

    final sub = receivePort.listen((msg) {
      if (msg is! Map) return;

      switch (msg['type']) {
        case 'controlPort':
          controlPort = msg['port'];
          _jobs[id]?.controlPort = controlPort;
          break;

        case 'log':
          controller.add(Aria2LogEvent(msg['line']));
          break;

        case 'progress':
          controller.add(
            Aria2ProgressEvent(_parseProgress(msg['line'])),
          );
          break;

        case 'error':
          controller.add(Aria2ErrorEvent(msg['message']));
          if (!doneCompleter.isCompleted) {
            doneCompleter.completeError(
              StateError(msg['message']),
            );
          }
          _cleanup(id);
          break;

        case 'done':
          final ev = Aria2DoneEvent(
            outputFilePath: msg['outputFilePath'],
            selectedIndex: msg['selectedIndex'],
            selectedTorrentPath: msg['selectedTorrentPath'],
          );
          controller.add(ev);
          if (!doneCompleter.isCompleted) {
            doneCompleter.complete(ev);
          }
          _cleanup(id);
          break;
      }
    });

    void abort() {
      final job = _jobs.remove(id);
      if (job == null) return;

      job.controlPort?.send({'cmd': 'abort'});
      Future.delayed(const Duration(milliseconds: 300), () {
        job.isolate.kill(priority: Isolate.immediate);
      });

      job.receivePort.close();
      job.sub.cancel();
      job.controller.close();
    }

    _jobs[id] = IsolateActiveJob(
      id: id,
      isolate: isolate,
      receivePort: receivePort,
      sub: sub,
      controller: controller,
    );

    return Aria2DownloadHandle(
      id: id,
      events: controller.stream,
      done: doneCompleter.future,
      abort: abort,
    );
  }

  static void _cleanup(String id) {
    final job = _jobs.remove(id);
    if (job == null) return;

    job.receivePort.close();
    job.sub.cancel();
    job.controller.close();
  }
}

/// ============================================================================
/// Isolate entry point
/// ============================================================================

Future<void> _downloadIsolateMain(IsolateArgs args) async {
  final main = args.sendPort;
  final control = ReceivePort();
  main.send({'type': 'controlPort', 'port': control.sendPort});

  bool aborted = false;
  Process running;

  control.listen((msg) {
    if (msg is Map && msg['cmd'] == 'abort') {
      aborted = true;
      running?.kill(ProcessSignal.sigterm);
    }
  });

  void log(String m) => main.send({'type': 'log', 'line': m});
  void progress(String l) => main.send({'type': 'progress', 'line': l});
  void fail(Object e) => main.send({'type': 'error', 'message': e.toString()});

  try {
    final torrentPath = await _resolveTorrent(
      aria2cPath: args.aria2cPath,
      uri: args.uri,
      onLog: log,
      onProgress: progress,
      onRunning: (p) => running = p,
      isAborted: () => aborted,
    );

    final files = await _showFiles(
      aria2cPath: args.aria2cPath,
      torrentPath: torrentPath,
      cwd: FileSystemHelper.torrentsCache,
      onLog: log,
      onSetRunning: (p) => running = p,
      isAborted: () => aborted,
    );

    final relPath = files[args.fileIndex] ??
        (throw StateError('File index not found in torrent'));

    final romDir = Directory(args.downloadPath)..createSync(recursive: true);

    await _downloadSelectedFile(
      aria2cPath: args.aria2cPath,
      torrentPath: torrentPath,
      selectIndex: args.fileIndex,
      cwd: args.downloadPath,
      onLog: log,
      onProgressLine: progress,
      onSetRunning: (p) => running = p,
      isAborted: () => aborted,
    );

    final src = File(p.join(args.downloadPath, relPath));
    final dst = File(p.join(romDir.path, p.basename(relPath)));

    await src.rename(dst.path);
    //delete anything that its not the dst file in case of residual data of the torrent
    final dir = Directory(args.downloadPath);
    await for (var entity in dir.list()) {
      if (entity.path != dst.path) {
        try {
          if (entity is File) {
            await entity.delete();
          } else if (entity is Directory) {
            await entity.delete(recursive: true);
          }
        } catch (e) {
          print("Error deleting extra file: " + e.toString());
        }
      }
    }
    main.send({
      'type': 'done',
      'outputFilePath': dst.path,
      'selectedIndex': args.fileIndex,
      'selectedTorrentPath': torrentPath,
    });
  } catch (e) {
    fail(e);
  } finally {
    running?.kill(ProcessSignal.sigkill);
    control.close();
  }
}

/// ============================================================================
/// Torrent helpers
/// ============================================================================

Future<String> _resolveTorrent({
  String aria2cPath,
  String uri,
  void Function(String) onLog,
  void Function(String) onProgress,
  void Function(Process) onRunning,
  bool Function() isAborted,
}) async {
  if (uri.endsWith('.torrent')) return uri;
  if (!uri.contains('magnet:')) {
    throw StateError('Invalid torrent URI');
  }

  final cache = Directory(FileSystemHelper.torrentsCache)
    ..createSync(recursive: true);

  final path = p.join(cache.path, '${StringHelper.hash20(uri)}.torrent');
  if (await File(path).exists()) return path;

  final proc = await Process.start(
    aria2cPath,
    [
      '--bt-metadata-only=true',
      '--bt-save-metadata=true',
      '--seed-time=0',
      uri
    ],
    workingDirectory: cache.path,
  );

  onRunning(proc);
  ProcessHelper.pipeProcessOutput(
    process: proc,
    onLog: onLog,
    onProgress: onProgress,
  );

  await ProcessHelper.ensureExitOk(proc, isAborted, 'Metadata download failed');

  final torrent = cache
      .listSync()
      .whereType<File>()
      .firstWhere((f) => f.path.endsWith('.torrent'));

  await torrent.rename(path);
  return path;
}

/// ============================================================================
/// aria2 helpers
/// ============================================================================

Future<Map<int, String>> _showFiles({
  String aria2cPath,
  String torrentPath,
  String cwd,
  void Function(String) onLog,
  void Function(Process) onSetRunning,
  bool Function() isAborted,
}) async {
  final proc = await Process.start(
    aria2cPath,
    ['--show-files', torrentPath],
    workingDirectory: cwd,
  );

  onSetRunning(proc);

  final buffer = StringBuffer();
  proc.stdout.transform(utf8.decoder).listen(buffer.write);
  proc.stderr.transform(utf8.decoder).listen(buffer.write);

  await ProcessHelper.ensureExitOk(proc, isAborted, '--show-files failed');

  final reg = RegExp(r'^\s*(\d+)\|\s*(.+)$', multiLine: true);
  final matches = reg.allMatches(buffer.toString());

  if (matches.isEmpty) {
    throw StateError('No files found in torrent');
  }

  return {for (final m in matches) int.parse(m.group(1)): m.group(2).trim()};
}

Future<void> _downloadSelectedFile({
  String aria2cPath,
  String torrentPath,
  int selectIndex,
  String cwd,
  void Function(String) onLog,
  void Function(String) onProgressLine,
  void Function(Process) onSetRunning,
  bool Function() isAborted,
}) async {
  final proc = await Process.start(
    aria2cPath,
    [
      '--select-file=$selectIndex',
      '--seed-time=0',
      '--file-allocation=none',
      torrentPath,
    ],
    workingDirectory: cwd,
  );

  onSetRunning(proc);
  ProcessHelper.pipeProcessOutput(
    process: proc,
    onLog: onLog,
    onProgress: onProgressLine,
  );

  await ProcessHelper.ensureExitOk(proc, isAborted, 'Download failed');
}

/// ============================================================================
/// Progress parser
/// ============================================================================

Aria2Progress _parseProgress(String line) {
  return Aria2Progress(
    rawLine: line,
    percent: RegExp(r'\((\d+%)\)').firstMatch(line)?.group(1),
    downloaded: RegExp(r'\[#\w+\s+([^\s/]+)').firstMatch(line)?.group(1),
    total: RegExp(r'/([^\s(]+)\(').firstMatch(line)?.group(1),
    dlSpeed: RegExp(r'\bDL:([^\s]+)').firstMatch(line)?.group(1),
    ulSpeed: RegExp(r'\bUL:([^\s]+)').firstMatch(line)?.group(1),
    seeds: RegExp(r'\bSD:(\d+)').firstMatch(line)?.group(1),
    eta: RegExp(r'\bETA:([^\s]+)').firstMatch(line)?.group(1),
  );
}
