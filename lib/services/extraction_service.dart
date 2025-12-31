import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/widgets.dart';
import 'package:yamata_launcher/constants/settings_constants.dart';
import 'package:yamata_launcher/services/settings_service.dart';
import 'package:yamata_launcher/utils/extraction_helper.dart';
import 'package:flutter_archive/flutter_archive.dart' as flutter_archive;

class _QueueItem {
  final String id;
  final File input;
  final Directory output;
  final Completer<void> completer;
  final StreamController<double> progressController;
  final void Function(Object error)? onError;

  _QueueItem({
    required this.id,
    required this.input,
    required this.output,
    required this.completer,
    required this.progressController,
    this.onError,
  });
}

class ExtractionService {
  static int maxConcurrent = 0;

  static List<_QueueItem> _queue = [];
  static Map<String, SendPort> _controlPorts = {};
  static int _running = 0;

  ExtractionService();

  static Future<(String id, Stream<double> progress)> enqueueExtraction({
    required File input,
    required Directory output,
    String? extractionId,
    void Function(Object error)? onError,
  }) async {
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
      onError: onError,
    );

    _queue.add(item);
    _tryRunNext();

    Future.delayed(const Duration(milliseconds: 200), () {
      progressController.add(-1);
    });

    completer.future.then((_) => progressController.close());

    return (id, progressController.stream);
  }

  static Future<(Stream<double> progress, Function cancel)> extractOnce({
    required File input,
    required Directory output,
    Function(Object error)? onError,
  }) async {
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

      await Future.delayed(const Duration(milliseconds: 100));
      receivePort.close();
      _controlPorts.remove(id);
      await progressController.close();
    }

    Isolate? isolate;

    final params = {
      "events": receivePort.sendPort,
      "control": controlPort.sendPort,
      "id": id,
      "input": input.path,
      "output": output.path,
    };

    if (Platform.isAndroid) {
      _isolateUncompress(params);
    } else {
      isolate = await Isolate.spawn(_isolateUncompress, params);
    }

    Future.microtask(() async {
      progressController.add(-1);

      await for (final message in receivePort) {
        if (message is double) {
          progressController.add(message);
          if (message == -2.0) {
            isolate?.kill(priority: Isolate.immediate);
            receivePort.close();
            _controlPorts.remove(id);
            progressController.addError('Extraction failed');
            await progressController.close();
            onError?.call('Extraction failed');
            return;
          }

          if (message >= 100) {
            receivePort.close();
            _controlPorts.remove(id);
            await progressController.close();
          }
        }
      }
    });

    return (progressController.stream, cancel);
  }

  static Future<void> cancel(String id) async {
    final idx = _queue.indexWhere((q) => q.id == id);

    if (idx != -1) {
      final job = _queue.removeAt(idx);

      job.progressController.add(0);
      job.progressController.close();
      job.completer.complete();

      job.onError?.call('Cancelled before start');

      _tryRunNext();
      return;
    }

    final ctrl = _controlPorts[id];
    if (ctrl != null) {
      ctrl.send({"type": "cancel"});
    }
  }

  static void _tryRunNext() {
    if (_running >= maxConcurrent) return;
    if (_queue.isEmpty) return;

    final job = _queue.removeAt(0);
    _running++;

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

    final params = {
      "events": receivePort.sendPort,
      "control": controlPort.sendPort,
      "id": job.id,
      "input": job.input.path,
      "output": job.output.path,
    };

    if (Platform.isAndroid) {
      _isolateUncompress(params);
    } else {
      await Isolate.spawn(_isolateUncompress, params);
    }

    await for (final message in receivePort) {
      if (message is double) {
        job.progressController.add(message);
        if (message == -2.0) {
          job.completer.completeError('Extraction failed');
          receivePort.close();
          _controlPorts.remove(job.id);
          job.onError?.call('Extraction failed');
          return;
        }

        if (message >= 100) {
          job.completer.complete();
          receivePort.close();
          _controlPorts.remove(job.id);
        }
      }
    }
  }

  static Future<void> _isolateUncompress(Map data) async {
    final events = data["events"] as SendPort;
    final controlAnnounce = data["control"] as SendPort;

    final inputPath = data["input"] as String;
    final outputPath = data["output"] as String;

    if (Platform.isAndroid) {
      final zipFile = File(inputPath);
      final destinationDir = Directory(outputPath);

      try {
        await flutter_archive.ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: destinationDir,
          onExtracting: (zipEntry, progress) {
            final progressInt = progress.floor();
            if (progressInt >= 100 || progressInt % 2 != 0) {
              return flutter_archive.ZipFileOperation.includeItem;
            }
            events.send(progressInt.toDouble());
            return flutter_archive.ZipFileOperation.includeItem;
          },
        );

        await Future.delayed(const Duration(milliseconds: 500));
        events.send(100.0);
      } catch (e) {
        print("Extraction error: $e");
        events.send(-2.0);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final controlReceiver = ReceivePort();
    final inputStream = InputFileStream(inputPath);

    try {
      controlAnnounce.send(controlReceiver.sendPort);
      events.send(0.0);

      controlReceiver.listen((msg) {
        if (msg is Map && msg["type"] == "cancel") {
          try {
            inputStream.closeSync();
          } catch (e) {
            print("Failed to close input stream: $e");
          }
        }
      });

      final archive = ZipDecoder().decodeStream(inputStream, verify: false);

      final result = await ExtractionHelper().extractArchiveToDiskWithProgress(
        archive,
        outputPath,
        onProgress: (progress) {
          final progressInt = progress.floor();
          if (progress >= 100) return;
          if (progressInt % 2 != 0) return;
          events.send(progressInt.toDouble());
        },
      );

      if (result == false) {
        events.send(-2.0);
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500), () {
        events.send(100.0);

        try {
          inputStream.closeSync();
        } catch (e) {
          print("Failed to close input stream: $e");
        }
      });
    } catch (e) {
      print("Extraction error: $e");
      events.send(-2.0);
    }
  }
}
