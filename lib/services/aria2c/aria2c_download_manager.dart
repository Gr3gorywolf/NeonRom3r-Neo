import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:yamata_launcher/constants/files_constants.dart';
import 'package:yamata_launcher/constants/settings_constants.dart';
import 'package:yamata_launcher/constants/torrents_constants.dart';
import 'package:yamata_launcher/models/aria2c.dart';
import 'package:yamata_launcher/models/download_source_rom.dart';
import 'package:yamata_launcher/models/rom_info.dart';
import 'package:yamata_launcher/services/native/aria2c_android_interface.dart';
import 'package:yamata_launcher/services/settings_service.dart';
import 'package:yamata_launcher/utils/process_helper.dart';
import 'package:yamata_launcher/utils/string_helper.dart';
import 'package:path/path.dart' as p;

import '../files_system_service.dart';

/// ============================================================================
/// Internal Classes
/// ============================================================================
class IsolateActiveJob {
  final String? id;
  final Isolate? isolate;
  final ReceivePort? receivePort;
  final StreamSubscription? sub;
  final StreamController<Aria2Event>? controller;
  SendPort? controlPort;

  IsolateActiveJob({
    this.id,
    this.isolate,
    this.receivePort,
    this.sub,
    this.controller,
  });
}

class IsolateArgs {
  final SendPort? sendPort;
  final String? aria2cPath;
  final String? uri;
  final int? fileIndex;
  final String? filePath;
  final String? downloadPath;
  final String? torrentsPath;
  final String? certPath;

  IsolateArgs({
    this.sendPort,
    this.aria2cPath,
    this.uri,
    this.fileIndex,
    this.filePath,
    this.torrentsPath,
    this.downloadPath,
    this.certPath,
  });
}

List<String> DHT_SOURCES_PARAMS = Platform.isAndroid
    ? [
        '--dht-entry-point=router.bittorrent.com:6881',
        '--dht-entry-point=dht.transmissionbt.com:6881',
        '--dht-entry-point=router.utorrent.com:6881',
      ]
    : [];

enum _UriType { magnet, torrent, direct }

_UriType _detectUriType(String uri) {
  if (uri.contains('magnet:')) return _UriType.magnet;
  if (uri.toLowerCase().endsWith('.torrent')) return _UriType.torrent;
  return _UriType.direct;
}

List<String> _getTorrentAndCertParams(String? certPath) {
  List<String> params = ['--bt-tracker="${BT_TRACKERS.join(',')}"'];
  if (certPath != null) {
    params.add("--ca-certificate=${certPath}");
    var dhtPath = "${p.dirname(certPath!)}/dht.dat";
    if (Platform.isAndroid) {
      var dhtFile = File(dhtPath);
      if (!dhtFile.existsSync()) {
        dhtFile.createSync();
      }
      params.add("--bt-require-crypto=true");
      params.add("--disable-ipv6=true");
      params.add("--dht-file-path=${dhtPath}");
      params.add("--dht-file-path6=${p.dirname(certPath!)}/dht6.dat");
      params.addAll(DHT_SOURCES_PARAMS);
    }
  }
  print(certPath);
  print(params);
  return params;
}

Future<String> _handleRedirects(String url) async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(url));
  final response = await request.close();
  if (response.isRedirect &&
      response.headers.value(HttpHeaders.locationHeader) != null) {
    final redirectedUrl = response.headers.value(HttpHeaders.locationHeader)!;
    return _handleRedirects(redirectedUrl);
  } else {
    return url;
  }
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
    required RomInfo rom,
    required DownloadSourceRom source,
    String? aria2cPath,
  }) async {
    final uri = source.uris!.first;
    final id = StringHelper.hash20(rom.name! + rom.console!);

    if (_jobs.containsKey(id)) {
      throw StateError('Download already running for id=$id');
    }
    var includeConsolePrefix =
        await SettingsService().get<bool>(SettingsKeys.PREFIX_CONSOLE_SLUG);
    final receivePort = ReceivePort();
    final controller = StreamController<Aria2Event>.broadcast();
    final doneCompleter = Completer<Aria2DoneEvent>();
    final downloadPath = p.join(
        FileSystemService.downloadsPath,
        includeConsolePrefix ? rom.console.toUpperCase() : "",
        StringHelper.removeInvalidPathCharacters(rom.name!));
    if (!await Directory(downloadPath).exists()) {
      await Directory(downloadPath).create(recursive: true);
    }
    final isolate = await Isolate.spawn<IsolateArgs>(
      _downloadIsolateMain,
      IsolateArgs(
        sendPort: receivePort.sendPort,
        aria2cPath: aria2cPath,
        uri: Uri.decodeComponent(uri),
        fileIndex: source.fileIndex,
        certPath: Aria2cAndroidInterface.certPath.isEmpty
            ? null
            : Aria2cAndroidInterface.certPath,
        filePath: source.filePath != null
            ? Uri.decodeComponent(source.filePath!)
            : null,
        torrentsPath: FileSystemService.torrentsCachePath,
        downloadPath: downloadPath,
      ),
      debugName: 'aria2c-$id',
    );

    SendPort? controlPort;

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
      job.receivePort!.close();
      job.sub!.cancel();
      job.controller!.close();
      Future.delayed(const Duration(milliseconds: 300), () {
        try {
          final dir = Directory(downloadPath);
          if (dir.existsSync()) {
            dir.deleteSync(recursive: true);
          }
        } catch (e) {}
        job.isolate!.kill(priority: Isolate.immediate);
      });
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

    job.receivePort!.close();
    job.sub!.cancel();
    job.controller!.close();
  }
}

/// ============================================================================
/// Isolate entry point
/// ============================================================================

Future<void> _downloadIsolateMain(IsolateArgs args) async {
  final main = args.sendPort!;
  final control = ReceivePort();
  main.send({'type': 'controlPort', 'port': control.sendPort});

  bool aborted = false;
  Process? running;

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
    final uriType = _detectUriType(args.uri!);
    final romDir = Directory(args.downloadPath!)..createSync(recursive: true);

    // =======================================================================
    // DIRECT FILE DOWNLOAD (no torrent, no magnet)
    // =======================================================================

    if (uriType == _UriType.direct) {
      var certArgs = _getTorrentAndCertParams(args.certPath);
      var url = args.uri ?? "";
      if (url.contains("http")) {
        url = await _handleRedirects(url);
      }

      final proc = await Process.start(
        args.aria2cPath!,
        ["--file-allocation=none", ...certArgs, args.uri!],
        workingDirectory: romDir.path,
      );

      running = proc;
      ProcessHelper.pipeProcessOutput(
        process: proc,
        onLog: log,
        onProgress: progress,
      );

      await ProcessHelper.ensureExitOk(
          proc, () => aborted, 'Direct download failed');

      final fileName = p.basename(args.uri!);
      final outputPath = p.join(romDir.path, fileName);

      main.send({
        'type': 'done',
        'outputFilePath': outputPath,
        'selectedIndex': null,
        'selectedTorrentPath': null,
      });
      return;
    }

    // =======================================================================
    // TORRENT / MAGNET FLOW
    // =======================================================================
    final torrentPath = await _resolveTorrent(
      aria2cPath: args.aria2cPath,
      uri: args.uri!,
      onLog: log,
      certPath: args.certPath,
      torrentsPath: args.torrentsPath,
      onProgress: progress,
      onRunning: (p) => running = p,
      isAborted: () => aborted,
    );
    final files = await _showFiles(
      aria2cPath: args.aria2cPath!,
      torrentPath: torrentPath,
      certPath: args.certPath,
      cwd: args.torrentsPath,
      onLog: log,
      onSetRunning: (p) => running = p,
      isAborted: () => aborted,
    );
    var fileIndex = args.fileIndex;
    if (fileIndex == null && args.filePath != null) {
      fileIndex = files.entries
          .firstWhereOrNull(
            (e) => e.value == args.filePath,
          )
          ?.key;
    }
    final relPath = fileIndex != null ? files[args.fileIndex!] : null;

    await _downloadSelectedFile(
      aria2cPath: args.aria2cPath!,
      torrentPath: torrentPath,
      certPath: args.certPath,
      selectIndex: fileIndex,
      cwd: args.downloadPath,
      onLog: log,
      onProgressLine: progress,
      onSetRunning: (p) => running = p,
      isAborted: () => aborted,
    );
    String? outputPath = args.downloadPath;
    if (relPath != null) {
      outputPath = p.join(romDir.path, p.basename(relPath));
      final src = File(p.join(args.downloadPath!, relPath));
      final dst = File(outputPath);

      await src.rename(dst.path);

      // Cleanup residual torrent files
      final dir = Directory(args.downloadPath!);
      await for (var entity in dir.list()) {
        if (entity.path != dst.path) {
          try {
            if (entity is File) {
              await entity.delete();
            } else if (entity is Directory) {
              await entity.delete(recursive: true);
            }
          } catch (e) {
            print('Error deleting extra file: $e');
          }
        }
      }
    } else {
      var romOutputPath = Directory(outputPath!);
      if (romOutputPath.existsSync()) {
        var files = romOutputPath.listSync().whereType<File>().toList();
        if (files.isNotEmpty) {
          [
            ...VALID_COMPRESSED_ROM_EXTENSIONS,
            ...VALID_ROM_EXTENSIONS,
            ...VALID_COMPRESSED_EXTENSIONS
          ].forEach((ext) {
            var match = files.firstWhereOrNull(
                (f) => f.path.toLowerCase().endsWith('.' + ext));
            if (match != null) {
              outputPath = match.path;
            }
          });
        }
      }
    }

    main.send({
      'type': 'done',
      'outputFilePath': outputPath,
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
  String? aria2cPath,
  required String uri,
  String? torrentsPath,
  String? certPath,
  void Function(String)? onLog,
  void Function(String)? onProgress,
  void Function(Process)? onRunning,
  bool Function()? isAborted,
}) async {
  var uriHash = StringHelper.hash20(uri);
  final cache = Directory(torrentsPath ?? "" + "/${uriHash}")
    ..createSync(recursive: true);

  // CASE 1: Remote or local .torrent → download to cache
  if (uri.toLowerCase().endsWith('.torrent')) {
    final targetPath = p.join(cache.path, p.basename(uri));

    // Skip download if already cached
    if (await File(targetPath).exists()) {
      return targetPath;
    }

    onLog!('Downloading torrent via HTTP: $uri');

    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(uri));
    final response = await request.close();

    if (response.statusCode != HttpStatus.ok) {
      throw StateError(
        'Failed to download torrent (HTTP ${response.statusCode})',
      );
    }

    final file = File(targetPath);
    final sink = file.openWrite();

    try {
      await for (final chunk in response) {
        if (isAborted!()) {
          await sink.close();
          try {
            await file.delete();
          } catch (e) {}

          throw StateError('Aborted');
        }
        sink.add(chunk);
      }
    } finally {
      await sink.close();
      client.close();
    }

    onLog('Torrent saved to cache: $targetPath');
    return targetPath;
  }

  // CASE 2: Magnet → generate torrent
  if (!uri.contains('magnet:')) {
    throw StateError('Invalid torrent URI');
  }

  final path = p.join(cache.path, '${uriHash}.torrent');
  if (await File(path).exists()) return path;
  var certArgs = _getTorrentAndCertParams(certPath);
  final proc = await Process.start(
    aria2cPath!,
    [
      '--bt-metadata-only=true',
      '--bt-save-metadata=true',
      '--seed-time=0',
      ...certArgs,
      uri,
    ],
    workingDirectory: cache.path,
  );

  onRunning!(proc);
  ProcessHelper.pipeProcessOutput(
    process: proc,
    onLog: onLog,
    onProgress: onProgress,
  );

  await ProcessHelper.ensureExitOk(
      proc, isAborted!, 'Metadata download failed');

  final torrent = cache
      .listSync()
      .whereType<File>()
      .where((f) => f
          .statSync()
          .modified
          .isAfter(DateTime.now().subtract(Duration(minutes: 2))))
      .firstWhere((f) => f.path.endsWith('.torrent'));

  await torrent.rename(path);
  return path;
}

/// ============================================================================
/// aria2 helpers
/// ============================================================================

Future<Map<int, String>> _showFiles({
  required String aria2cPath,
  required String torrentPath,
  String? certPath,
  String? cwd,
  void Function(String)? onLog,
  required void Function(Process) onSetRunning,
  required bool Function() isAborted,
}) async {
  var certArgs = _getTorrentAndCertParams(certPath);
  final proc = await Process.start(
    aria2cPath,
    ['--show-files', torrentPath, ...certArgs],
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

  return {for (final m in matches) int.parse(m.group(1)!): m.group(2)!.trim()};
}

Future<void> _downloadSelectedFile({
  required String aria2cPath,
  required String torrentPath,
  int? selectIndex,
  String? cwd,
  String? certPath,
  void Function(String)? onLog,
  void Function(String)? onProgressLine,
  required void Function(Process) onSetRunning,
  required bool Function() isAborted,
}) async {
  var certArgs = _getTorrentAndCertParams(certPath);
  final proc = await Process.start(
    aria2cPath,
    [
      ...(selectIndex == null ? [] : ['--select-file=$selectIndex']),
      '--seed-time=0',
      '--file-allocation=none',
      ...certArgs,
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
  print("Parsing line: $line");
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
