import 'dart:convert';
import 'dart:io';

import 'package:yamata_launcher/constants/torrents_constants.dart';
import 'package:yamata_launcher/models/aria2c.dart';
import 'package:yamata_launcher/utils/process_helper.dart';
import 'package:path/path.dart' as p;

enum DownloadUriType { magnet, torrent, direct }

class Aria2cUtils {
  static DownloadUriType detectUriType(String uri) {
    if (uri.contains('magnet:')) return DownloadUriType.magnet;
    if (uri.toLowerCase().endsWith('.torrent')) return DownloadUriType.torrent;
    return DownloadUriType.direct;
  }

  static List<String> getCommonArgs(String? certPath) {
    List<String> dhtSources = Platform.isAndroid
        ? [
            '--dht-entry-point=router.bittorrent.com:6881',
            '--dht-entry-point=dht.transmissionbt.com:6881',
            '--dht-entry-point=router.utorrent.com:6881',
          ]
        : [];
    List<String> params = [
      '--bt-tracker="${BT_TRACKERS.join(',')}"',
      "--auto-file-renaming=false",
      "--allow-overwrite=true",
      "--summary-interval=3",
      "--console-log-level=info",
    ];
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
        params.addAll(dhtSources);
        params.addAll(
            ["--async-dns=true", "--async-dns-server=1.1.1.1,8.8.8.8,8.8.4.4"]);
      }
    }
    return params;
  }

  static Future<String> handleRedirects(String url) async {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.isRedirect &&
        response.headers.value(HttpHeaders.locationHeader) != null) {
      final redirectedUrl = response.headers.value(HttpHeaders.locationHeader)!;
      return handleRedirects(redirectedUrl);
    } else {
      return url;
    }
  }

  static Future<Map<int, String>> showTorrentFiles({
    required String aria2cPath,
    required String torrentPath,
    String? certPath,
    String? cwd,
    void Function(String)? onLog,
    required void Function(Process) onSetRunning,
    required bool Function() isAborted,
  }) async {
    var commonArgs = getCommonArgs(certPath);
    final proc = await Process.start(
      aria2cPath,
      ['--show-files', torrentPath, ...commonArgs],
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

    return {
      for (final m in matches) int.parse(m.group(1)!): m.group(2)!.trim()
    };
  }

  static Future<void> downloadSelectedFileFromTorrent({
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
    var certArgs = getCommonArgs(certPath);
    final proc = await Process.start(
      aria2cPath,
      [
        ...(selectIndex == null
            ? []
            : [
                '--select-file=$selectIndex',
                '--bt-remove-unselected-file=true'
              ]),
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

  static Aria2Progress parseProgress(String line) {
    print("aria2c: $line");
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
}
