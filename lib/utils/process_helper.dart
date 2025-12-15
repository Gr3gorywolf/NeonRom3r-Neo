import 'dart:convert';
import 'dart:io';

class ProcessHelper {
  static void pipeProcessOutput({
    Process process,
    void Function(String) onLog,
    void Function(String) onProgress,
  }) {
    void handle(String line) {
      if (onProgress != null && line.contains('[#')) {
        onProgress(line);
      }
      onLog(line);
    }

    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(handle);

    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(handle);
  }

  static Future<void> ensureExitOk(
    Process process,
    bool Function() isAborted,
    String errorMessage,
  ) async {
    final exitCode = await process.exitCode;
    if (isAborted()) throw StateError('Aborted');
    if (exitCode != 0) {
      throw StateError('$errorMessage (exitCode=$exitCode)');
    }
  }
}
