import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:crypto/crypto.dart';
import 'package:neonrom3r/models/aria2c.dart';
import 'package:neonrom3r/models/rom_info.dart';
import 'package:path/path.dart' as p;
import 'files_system_helper.dart';

class Aria2DownloadManager {
  static final Map<String, _ActiveJob> _jobs = {};

  /// Start a download in its own isolate.
  ///
  /// [uri] can be a magnet (string containing "magnet:") or a .torrent path/url.
  /// If [filePathInTorrent] is provided, we will find its index using `--show-files`.
  /// If [selectIndex] is provided, we skip `--show-files` and use that index directly.
  ///
  /// Returns a handle containing:
  /// - a stream of events (progress/log/error/done)
  /// - a `done` future
  /// - an `abort()` function
  static Future<Aria2DownloadHandle> startDownload({
    String romName,
    String aria2cPath,
    String uri,
    String filePathInTorrent,
    int selectIndex,
  }) async {
    final id = _hash20(uri + romName);
    if (_jobs.containsKey(id)) {
      throw StateError('A download with id=$id is already running.');
    }

    final receivePort = ReceivePort();
    final doneCompleter = Completer<Aria2DoneEvent>();
    final controller = StreamController<Aria2Event>.broadcast();

    final isolate = await Isolate.spawn<_IsolateArgs>(
      _downloadIsolateMain,
      _IsolateArgs(
        sendPort: receivePort.sendPort,
        aria2cPath: aria2cPath,
        uri: uri,
        torrentsCacheDir: FileSystemHelper.torrentsCache,
        filePathInTorrent: filePathInTorrent,
        selectIndex: selectIndex,
      ),
      debugName: 'aria2c-download-$id',
    );

    StreamSubscription sub = receivePort.listen((msg) {
      if (msg is Map) {
        final type = msg['type'];
        switch (type) {
          case 'progress':
            controller
                .add(Aria2ProgressEvent(_parseProgress(msg['line'] as String)));
            break;
          case 'log':
            controller.add(Aria2LogEvent(msg['line'] as String));
            break;
          case 'error':
            controller.add(Aria2ErrorEvent(msg['message'] as String));
            if (!doneCompleter.isCompleted) {
              doneCompleter.completeError(StateError(msg['message'] as String));
            }
            break;
          case 'done':
            final ev = Aria2DoneEvent(
              outputFilePath: msg['outputFilePath'] as String,
              selectedIndex: msg['selectedIndex'] as int,
              selectedTorrentPath: msg['selectedTorrentPath'] as String,
            );
            controller.add(ev);
            if (!doneCompleter.isCompleted) doneCompleter.complete(ev);
            break;
        }
      }
    });

    void abort() {
      final job = _jobs.remove(id);
      if (job == null) return;
      // Tell isolate to abort nicely; if it doesn't, kill it.
      job.controlPort?.send({'cmd': 'abort'});
      Future.delayed(const Duration(milliseconds: 300), () {
        job.isolate.kill(priority: Isolate.immediate);
      });
      job.receivePort.close();
      job.sub.cancel();
      job.controller.close();
    }

    final active = _ActiveJob(
      id: id,
      isolate: isolate,
      receivePort: receivePort,
      sub: sub,
      controller: controller,
    );
    _jobs[id] = active;

    // First message from isolate should contain a control SendPort.
    // We wait a short moment and capture it if it arrives.
    controller.stream.listen((event) {
      if (event is Aria2DoneEvent) {
        _cleanup(id);
      } else if (event is Aria2ErrorEvent) {
        _cleanup(id);
      }
    });

    return Aria2DownloadHandle(
      id: id,
      events: controller.stream,
      done: doneCompleter.future.whenComplete(() => _cleanup(id)),
      abort: abort,
    );
  }

  /// Abort a running download by id.
  static void abort(String id) {
    _jobs[id]?.controlPort?.send({'cmd': 'abort'});
    _jobs[id]?.isolate.kill(priority: Isolate.immediate);
    _cleanup(id);
  }

  static void _cleanup(String id) {
    final job = _jobs.remove(id);
    if (job == null) return;
    job.receivePort.close();
    job.sub.cancel();
    job.controller.close();
  }

  static String _hash20(String input) {
    final bytes = utf8.encode(input);
    final hex = sha1.convert(bytes).toString(); // 40 hex chars
    return hex.substring(0, 20);
  }
}

class _ActiveJob {
  final String id;
  final Isolate isolate;
  final ReceivePort receivePort;
  final StreamSubscription sub;
  final StreamController<Aria2Event> controller;
  SendPort controlPort;

  _ActiveJob({
    this.id,
    this.isolate,
    this.receivePort,
    this.sub,
    this.controller,
  });
}

class _IsolateArgs {
  final SendPort sendPort;
  final String aria2cPath;
  final String uri;
  final String torrentsCacheDir;
  final String filePathInTorrent;
  final int selectIndex;

  _IsolateArgs({
    this.sendPort,
    this.aria2cPath,
    this.uri,
    this.torrentsCacheDir,
    this.filePathInTorrent,
    this.selectIndex,
  });
}

/// Isolate entry point.
Future<void> _downloadIsolateMain(_IsolateArgs args) async {
  final mainSend = args.sendPort;
  final control = ReceivePort();
  mainSend.send({'type': 'controlPort', 'port': control.sendPort});

  bool aborted = false;
  Process running;

  control.listen((msg) {
    if (msg is Map && msg['cmd'] == 'abort') {
      aborted = true;
      try {
        running?.kill(ProcessSignal.sigterm);
      } catch (_) {}
    }
  });

  void log(String line) => mainSend.send({'type': 'log', 'line': line});
  void progress(String line) =>
      mainSend.send({'type': 'progress', 'line': line});
  void error(String message) =>
      mainSend.send({'type': 'error', 'message': message});

  try {
    final cacheDir = Directory(args.torrentsCacheDir);
    await cacheDir.create(recursive: true);

    final isMagnet = args.uri.contains('magnet:');
    final isTorrent = args.uri.toLowerCase().endsWith('.torrent');

    if (!isMagnet && !isTorrent) {
      throw StateError(
          'URI must be a magnet (contains "magnet:") or ends with ".torrent".');
    }

    final id = _hash20(args.uri);
    final cachedTorrentPath = p.join(cacheDir.path, '$id.torrent');

    String torrentPath;
    if (isMagnet) {
      torrentPath = await _ensureTorrentFromMagnet(
        aria2cPath: args.aria2cPath,
        magnet: args.uri,
        cacheDir: cacheDir,
        cachedTorrentPath: cachedTorrentPath,
        onLog: log,
        onProgressLine: progress,
        onSetRunning: (p) => running = p,
        isAborted: () => aborted,
      );
    } else {
      // If uri is a local path/url; for local paths we use directly.
      // If it is a URL, you can download it first; here we assume local path.
      torrentPath = args.uri;
    }

    if (aborted) throw StateError('Aborted');

    // Determine the selected file index + relative path from `--show-files`
    final showFiles = await _showFiles(
      aria2cPath: args.aria2cPath,
      torrentPath: torrentPath,
      cwd: cacheDir.path,
      onLog: log,
      onSetRunning: (p) => running = p,
      isAborted: () => aborted,
    );

    if (aborted) throw StateError('Aborted');

    int selectedIndex;
    String selectedRelPath;

    if (args.selectIndex != null) {
      selectedIndex = args.selectIndex;
      final match = showFiles.entries.firstWhere(
        (e) => e.key == selectedIndex,
        orElse: () => throw StateError(
            'selectIndex=$selectedIndex not found in torrent file list.'),
      );
      selectedRelPath = match.value;
    } else {
      final wanted = args.filePathInTorrent;
      if (wanted == null || wanted.trim().isEmpty) {
        throw StateError(
            'filePathInTorrent is required when selectIndex is not provided.');
      }

      // Match by exact end path or contains (more forgiving).
      final normalizedWanted = wanted.replaceAll('\\', '/');
      final entry = showFiles.entries.firstWhere(
        (e) {
          final rel = e.value.replaceAll('\\', '/');
          return rel.endsWith(normalizedWanted) ||
              rel.contains(normalizedWanted);
        },
        orElse: () =>
            throw StateError('File "$wanted" not found in torrent listing.'),
      );

      selectedIndex = entry.key;
      selectedRelPath = entry.value;
    }

    // Create ROM folder before download
    final romFileName = p.basename(selectedRelPath);
    final romName = p.basenameWithoutExtension(romFileName);
    final romFolder =
        Directory(p.join(FileSystemHelper.downloadsPath, romName));
    await romFolder.create(recursive: true);

    // Download selected file into cacheDir (aria2 will create nested folders)
    await _downloadSelectedFile(
      aria2cPath: args.aria2cPath,
      torrentPath: torrentPath,
      selectIndex: selectedIndex,
      cwd: FileSystemHelper.downloadsPath,
      onLog: log,
      onProgressLine: progress,
      onSetRunning: (p0) => running = p0,
      isAborted: () => aborted,
    );

    if (aborted) throw StateError('Aborted');

    // Move downloaded file into ROM folder as ROMName/ROMFile
    final downloadedFullPath =
        p.join(FileSystemHelper.downloadsPath, selectedRelPath);
    final targetPath = p.join(romFolder.path, romFileName);

    final src = File(downloadedFullPath);
    if (!await src.exists()) {
      // Sometimes aria2c writes without the leading "./"
      final alt = File(p.join(
          cacheDir.path, selectedRelPath.replaceFirst(RegExp(r'^\./'), '')));
      if (await alt.exists()) {
        await alt.rename(targetPath);
      } else {
        throw StateError('Downloaded file not found at "$downloadedFullPath".');
      }
    } else {
      await src.rename(targetPath);
    }

    mainSend.send({
      'type': 'done',
      'outputFilePath': targetPath,
      'selectedIndex': selectedIndex,
      'selectedTorrentPath': torrentPath,
    });
  } catch (e) {
    mainSend.send({'type': 'error', 'message': e.toString()});
  } finally {
    try {
      running?.kill(ProcessSignal.sigkill);
    } catch (_) {}
    control.close();
  }
}

String _hash20(String input) {
  final bytes = utf8.encode(input);
  final hex = sha1.convert(bytes).toString();
  return hex.substring(0, 20);
}

/// If cached torrent exists, use it. Otherwise run metadata-only and rename output to cachedTorrentPath.
Future<String> _ensureTorrentFromMagnet({
  String aria2cPath,
  String magnet,
  Directory cacheDir,
  String cachedTorrentPath,
  void Function(String) onLog,
  void Function(String) onProgressLine,
  void Function(Process) onSetRunning,
  bool Function() isAborted,
}) async {
  final cached = File(cachedTorrentPath);
  if (await cached.exists()) {
    onLog('Using cached torrent: $cachedTorrentPath');
    return cachedTorrentPath;
  }

  // Clean possible old torrents with same id file name
  await cacheDir.create(recursive: true);

  // Run aria2c to fetch metadata and save .torrent
  final args = <String>[
    '--bt-metadata-only=true',
    '--bt-save-metadata=true',
    '--seed-time=0',
    magnet,
  ];

  onLog('Generating torrent metadata via aria2c...');
  final proc = await Process.start(
    aria2cPath,
    args,
    workingDirectory: cacheDir.path,
    runInShell: false,
  );
  onSetRunning(proc);

  // aria2c writes progress-like lines to stdout (and sometimes stderr)
  proc.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.contains('[#')) onProgressLine(line);
    onLog(line);
  });
  proc.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.contains('[#')) onProgressLine(line);
    onLog(line);
  });

  final exit = await proc.exitCode;
  if (isAborted()) throw StateError('Aborted');
  if (exit != 0)
    throw StateError('aria2c failed to download metadata (exitCode=$exit)');

  // aria2c usually saves "<infohash>.torrent" in working dir; pick newest .torrent and rename
  final torrents = cacheDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.toLowerCase().endsWith('.torrent'))
      .toList()
    ..sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

  if (torrents.isEmpty) {
    throw StateError('Torrent file not found after metadata download.');
  }

  final newest = torrents.first;
  await newest.rename(cachedTorrentPath);
  onLog('Saved torrent to: $cachedTorrentPath');
  return cachedTorrentPath;
}

/// Runs `aria2c --show-files <torrent>` and returns a map of index -> relative path.
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
    runInShell: false,
  );
  onSetRunning(proc);

  final out = StringBuffer();
  proc.stdout.transform(utf8.decoder).listen(out.write);
  proc.stderr.transform(utf8.decoder).listen((s) {
    // aria2c sometimes prints extra info here; keep it for debugging
    out.write(s);
  });

  final exit = await proc.exitCode;
  if (isAborted()) throw StateError('Aborted');
  if (exit != 0)
    throw StateError('aria2c --show-files failed (exitCode=$exit)');

  final text = out.toString();
  onLog(text);

  // Parse lines like: 5891|./TopRoms Collection/.../file.iso
  final reg = RegExp(r'^\s*(\d+)\|\s*(.+)\s*$', multiLine: true);
  final matches = reg.allMatches(text);

  final map = <int, String>{};
  for (final m in matches) {
    final idx = int.parse(m.group(1));
    var path = m.group(2);

    // Keep as-is but normalize a bit (aria2 can prefix ./)
    path = path.trim();
    map[idx] = path;
  }

  if (map.isEmpty) {
    throw StateError('No files parsed from --show-files output.');
  }

  return map;
}

/// Download selected file index from torrent.
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
  final args = <String>[
    '--select-file=$selectIndex',
    '--seed-time=0',
    '--file-allocation=none',
    torrentPath,
  ];

  print(args);

  onLog('Downloading selectIndex=$selectIndex ...');
  final proc = await Process.start(
    aria2cPath,
    args,
    workingDirectory: cwd,
    runInShell: false,
  );
  onSetRunning(proc);

  proc.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.contains('[#')) onProgressLine(line);
    onLog(line);
  });
  proc.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    if (line.contains('[#')) onProgressLine(line);
    onLog(line);
  });

  final exit = await proc.exitCode;
  if (isAborted()) throw StateError('Aborted');
  if (exit != 0) throw StateError('aria2c download failed (exitCode=$exit)');
}

/// Parses progress lines like:
/// [#87b486 811MiB/823MiB(98%) CN:44 SD:6 DL:37MiB UL:4.6MiB(44MiB)]
/// Also tries to capture ETA if it appears.
Aria2Progress _parseProgress(String line) {
  // Percent is inside (...) right after done/total.
  final percent = RegExp(r'\((\d+%)\)').firstMatch(line)?.group(1);

  // done/total before (xx%)
  final dt =
      RegExp(r'\[#\w+\s+([0-9A-Za-z.]+)\/([0-9A-Za-z.]+)\(').firstMatch(line);
  final done = dt?.group(1);
  final total = dt?.group(2);

  // SD, DL, UL
  final seeds = RegExp(r'\bSD:(\d+)\b').firstMatch(line)?.group(1);
  final dl = RegExp(r'\bDL:([0-9A-Za-z.]+)\b').firstMatch(line)?.group(1);
  final ul = RegExp(r'\bUL:([0-9A-Za-z.]+)\b').firstMatch(line)?.group(1);

  // ETA patterns vary; try common ones
  final eta = RegExp(r'\bETA:([0-9A-Za-z:]+)\b').firstMatch(line)?.group(1);

  return Aria2Progress(
    rawLine: line,
    percent: percent,
    downloaded: done,
    total: total,
    dlSpeed: dl,
    ulSpeed: ul,
    seeds: seeds,
    eta: eta,
  );
}
