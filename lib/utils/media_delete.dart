import 'dart:io';

class MediaDelete {
  static Future<void> deletePropertyMedia({
    required List<String> images,
    List<String>? videos,
  }) async {
    for (final path in images) {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    }

    if (videos != null) {
      for (final path in videos) {
        final file = File(path);

        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }
}