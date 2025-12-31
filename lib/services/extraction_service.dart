import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:yamata_launcher/constants/settings_constants.dart';
import 'package:yamata_launcher/services/settings_service.dart';
import 'package:yamata_launcher/utils/extraction_helper.dart';

class _QueueItem {
  final String id;
  final File input;
  final Directory output;
  final Completer<void> completer;
  final StreamController<double> progressController;

  _QueueItem({
    required this.id,
    required this.input,
    required this.output,
    required this.completer,
    required this.progressController,
  });
}

class ExtractionService {
  static int maxConcurrent = 0;

  static List<_QueueItem> _queue = [];
  static Map<String, SendPort> _controlPorts = {};
  static int _running = 0;

  ExtractionService();

  static Future<(String id, Stream<double> progress)> enqueueExtraction(
      {required File input,
      required Directory output,
      String? extractionId}) async {
    final id = extractionId ?? DateTime.now().microsecondsSinceEpoch.toString();
    if (maxConcurrent == 0) {
      maxConcurrent = await SettingsService()
          .get<int>(SettingsKeys.MAX_CONCURRENT_EXTRACTIONS);
    }
    final completer = Completer<void>();
    final progressController = StreamController<double>.broadcast();

    final item = _QueueItem(
      id: id,
      input: input,
      output: output,
      completer: completer,
      progressController: progressController,
    );
    _queue.add(item);
    _tryRunNext();
    Future.delayed(Duration(milliseconds: 200), () {
      progressController.add(-1);
    });

    completer.future.then((_) => progressController.close());

    return (id, progressController.stream);
  }

  static Future<(Stream<double> progress, Function cancel)> extractOnce(
      {required File input, required Directory output}) async {
    final receivePort = ReceivePort();
    final progressController = StreamController<double>.broadcast();

    final id = DateTime.now().microsecondsSinceEpoch.toString();

    final controlPort = ReceivePort();
    progressController.add(0.0);
    controlPort.listen((message) {
      if (message is SendPort) {
        _controlPorts[id] = message;
      }
    });

    void cancel() async {
      final ctrl = _controlPorts[id];
      if (ctrl != null) {
        ctrl.send({"type": "cancel"});
      }
      await Future.delayed(Duration(milliseconds: 100));
      receivePort.close();
      _controlPorts.remove(id);
      progressController.close();
    }

    Isolate isolate = await Isolate.spawn(
      _isolateUncompress,
      {
        "events": receivePort.sendPort,
        "control": controlPort.sendPort,
        "id": id,
        "input": input.path,
        "output": output.path,
      },
    );
    Future.microtask(() async {
      progressController.add(-1);
      // Listen for control port from isolate
      await for (final message in receivePort) {
        if (message is double) {
          progressController.add(message);

          if (message >= 100) {
            receivePort.close();
            _controlPorts.remove(id);
            progressController.close();
          }
        }
      }
    });

    return (progressController.stream, cancel);
  }

  /// Cancel a running (or queued) task
  static Future<void> cancel(String id) async {
    // Remove from queue if not started yet
    final idx = _queue.indexWhere((q) => q.id == id);
    if (idx != -1) {
      final job = _queue.removeAt(idx);
      job.progressController.add(0);
      job.progressController.close();
      job.completer.complete();
      _tryRunNext();
      return;
    }

    // If running, notify isolate via control port
    final ctrl = _controlPorts[id];
    if (ctrl != null) {
      ctrl.send({"type": "cancel"});
    }
  }

  static void _tryRunNext() {
    print("Running: $_running, Queue length: ${_queue.length}");
    if (_running >= maxConcurrent) return;
    if (_queue.isEmpty) return;

    final job = _queue.removeAt(0);
    _running++;
    print("Running job ${job.id}");
    _runJob(job).whenComplete(() {
      _running--;
      _tryRunNext();
    });
  }

  static Future<void> _runJob(_QueueItem job) async {
    final receivePort = ReceivePort();
    final controlPort = ReceivePort();
    job.progressController.add(0.0);
    controlPort.listen((message) {
      if (message is SendPort) {
        _controlPorts[job.id] = message;
      }
    });
    await Isolate.spawn(
      _isolateUncompress,
      {
        "events": receivePort.sendPort,
        "control": controlPort.sendPort,
        "id": job.id,
        "input": job.input.path,
        "output": job.output.path,
      },
    );
    // Listen for control port from isolate
    await for (final message in receivePort) {
      if (message is double) {
        job.progressController.add(message);

        if (message >= 100) {
          job.completer.complete();
          receivePort.close();
          _controlPorts.remove(job.id);
        }
      }
    }
  }

  /// Runs inside isolate
  static Future<void> _isolateUncompress(Map data) async {
    final events = data["events"] as SendPort;
    final controlAnnounce = data["control"] as SendPort;

    final inputPath = data["input"] as String;
    final outputPath = data["output"] as String;

    bool cancelled = false;

    final controlReceiver = ReceivePort();
    final inputStream = InputFileStream(inputPath);
    controlAnnounce.send(controlReceiver.sendPort);
    events.send(0.0);
    final archive = ZipDecoder().decodeStream(inputStream);
    controlReceiver.listen((msg) {
      if (msg is Map && msg["type"] == "cancel") {
        cancelled = true;
        inputStream.closeSync();
      }
    });
    try {
      await ExtractionHelper().extractArchiveToDiskWithProgress(
          archive, outputPath, onProgress: (progress) {
        if (progress >= 100) return;
        if (progress % 2 != 0) return;
        events.send(progress);
      });
      await Future.delayed(Duration(milliseconds: 500), () {
        try {
          inputStream.closeSync();
        } catch (e) {}
        if (!cancelled) {
          events.send(100.0);
        } else {
          events.send(0.0);
        }
      });
    } finally {}
  }
}
