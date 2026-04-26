import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class ReceiptImageService {
  const ReceiptImageService();

  Future<File> compressAndPersist({
    required String sourcePath,
    int targetReductionFactor = 10,
    int maxEdge = 1600,
  }) async {
    final sourceFile = File(sourcePath);
    if (!sourceFile.existsSync()) return sourceFile;

    final originalBytes = await sourceFile.readAsBytes();
    if (originalBytes.isEmpty) return sourceFile;

    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) return sourceFile;

    final baked = img.bakeOrientation(decoded);
    final resized = _resizeIfNeeded(baked, maxEdge: maxEdge);

    final targetBytes = (originalBytes.length / targetReductionFactor).round();
    final encoded = _encodeJpgToTarget(resized, targetBytes: targetBytes);

    final appDataDir = await _appDataDir();
    final outDir = Directory(p.join(appDataDir, 'receipt_images'));
    await outDir.create(recursive: true);

    final outPath = p.join(
      outDir.path,
      'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final outFile = File(outPath);
    await outFile.writeAsBytes(encoded, flush: true);

    return outFile;
  }

  img.Image _resizeIfNeeded(img.Image image, {required int maxEdge}) {
    final width = image.width;
    final height = image.height;
    final longEdge = width > height ? width : height;
    if (longEdge <= maxEdge) return image;

    final scale = maxEdge / longEdge;
    final newWidth = (width * scale).round();
    final newHeight = (height * scale).round();

    return img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
      interpolation: img.Interpolation.average,
    );
  }

  Uint8List _encodeJpgToTarget(img.Image image, {required int targetBytes}) {
    // Start fairly high, then step down until we're <= target or we hit a floor.
    // This is approximate, but works well for "10x smaller" intent.
    var quality = 85;
    Uint8List best = Uint8List.fromList(img.encodeJpg(image, quality: quality));

    if (best.length <= targetBytes) return best;

    while (quality > 25) {
      quality -= 10;
      final attempt = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );
      best = attempt;
      if (attempt.length <= targetBytes) break;
    }

    return best;
  }

  Future<String> _appDataDir() async {
    final dbDir = await getDatabasesPath();
    return dbDir;
  }
}
