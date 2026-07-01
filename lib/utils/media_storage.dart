import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MediaStorage {
  static Future<String> copyImage(
    String originalPath,
    String propertyId,
    int index,
  ) async {
    final dir = await getApplicationDocumentsDirectory();

    final imageDir = Directory(
      "${dir.path}/properties/images",
    );

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final extension = p.extension(originalPath);

    final newPath =
        "${imageDir.path}/${propertyId}_$index$extension";

    return (await File(originalPath).copy(newPath)).path;
  }

  static Future<String> copyVideo(
    String originalPath,
    String propertyId,
    int index,
  ) async {
    final dir = await getApplicationDocumentsDirectory();

    final videoDir = Directory(
      "${dir.path}/properties/videos",
    );

    if (!await videoDir.exists()) {
      await videoDir.create(recursive: true);
    }

    final extension = p.extension(originalPath);

    final newPath =
        "${videoDir.path}/${propertyId}_video$index$extension";

    return (await File(originalPath).copy(newPath)).path;
  }
  static Future<String> copyImageToApp(String originalPath) async {
  final file = File(originalPath);

  if (!await file.exists()) {
    return originalPath;
  }

  final dir = await getApplicationDocumentsDirectory();
  final imageDir = Directory("${dir.path}/properties/images");

  if (!await imageDir.exists()) {
    await imageDir.create(recursive: true);
  }

  final newPath =
      "${imageDir.path}/${p.basename(originalPath)}";

  if (await File(newPath).exists()) {
    return newPath;
  }

  return (await file.copy(newPath)).path;
}

static Future<String> copyVideoToApp(String originalPath) async {
  final file = File(originalPath);

  if (!await file.exists()) {
    return originalPath;
  }

  final dir = await getApplicationDocumentsDirectory();
  final videoDir = Directory("${dir.path}/properties/videos");

  if (!await videoDir.exists()) {
    await videoDir.create(recursive: true);
  }

  final newPath =
      "${videoDir.path}/${p.basename(originalPath)}";

  if (await File(newPath).exists()) {
    return newPath;
  }

  return (await file.copy(newPath)).path;
}
}