import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';

class ExtractionHelper {
  bool _isWithinOutputPath(String outputDir, String filePath) {
    return path.isWithin(
        path.canonicalize(outputDir), path.canonicalize(filePath));
  }

  bool _isValidSymLink(String outputPath, ArchiveFile file) {
    final filePath =
        path.dirname(path.join(outputPath, path.normalize(file.name)));
    final linkPath = path.normalize(file.symbolicLink ?? "");
    if (path.isAbsolute(linkPath)) {
      // Don't allow decoding of files outside of the output path.
      return false;
    }
    final absLinkPath = path.normalize(path.join(filePath, linkPath));
    if (!_isWithinOutputPath(outputPath, absLinkPath)) {
      // Don't allow decoding of files outside of the output path.
      return false;
    }
    return true;
  }

  Future<bool> extractArchiveToDiskWithProgress(
    Archive archive,
    String outputPath, {
    int? bufferSize,
    required void Function(double progress) onProgress,
  }) async {
    final outDir = Directory(outputPath);

    if (!outDir.existsSync()) {
      outDir.createSync(recursive: true);
    }

    // ---- calculate total bytes for progress ----
    final totalBytes = archive.files.fold<int>(
      0,
      (sum, f) => sum + (f.size ?? 0),
    );

    int written = 0;

    for (final entry in archive) {
      final filePath = path.normalize(path.join(outputPath, entry.name));

      if ((entry.isDirectory && !entry.isSymbolicLink) ||
          !_isWithinOutputPath(outputPath, filePath)) {
        continue;
      }

      // ---- symbolic link ----
      if (entry.isSymbolicLink) {
        if (!_isValidSymLink(outputPath, entry)) {
          continue;
        }

        final link = Link(filePath);
        await link.create(path.normalize(entry.symbolicLink ?? ""),
            recursive: true);
        continue;
      }

      // ---- directory ----
      if (entry.isDirectory) {
        await Directory(filePath).create(recursive: true);
        continue;
      }

      // ---- regular file ----
      ArchiveFile file = entry;

      bufferSize ??= OutputFileStream.kDefaultBufferSize;
      final fileSize = file.size;
      final fileBufferSize = fileSize < bufferSize ? fileSize : bufferSize;

      final output = OutputFileStream(filePath, bufferSize: fileBufferSize);

      try {
        final content = file.content as List<int>;

        const chunk = 32 * 1024;

        for (int i = 0; i < content.length; i += chunk) {
          final end = (i + chunk < content.length) ? i + chunk : content.length;

          output.writeBytes(content.sublist(i, end));

          written += (end - i);

          final progress =
              (written / totalBytes * 100).clamp(0, 100).toDouble();

          onProgress(progress);
        }
      } catch (e) {
        print("Extraction error on extraction helper: $e");
        onProgress(-2.0);
        return false;
      }

      await output.close();
    }

    // ensure final 100%
    onProgress(100.0);
    return true;
  }
}
