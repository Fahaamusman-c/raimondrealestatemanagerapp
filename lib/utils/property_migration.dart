import 'package:hive_flutter/hive_flutter.dart';

import '../models/property_model.dart';
import 'media_storage.dart';

class PropertyMigration {
  static Future<void> migrateMedia() async {
    final box = Hive.box<Property>('properties');

    for (int i = 0; i < box.length; i++) {
      final property = box.getAt(i);

      if (property == null) continue;

      final fixedImages = <String>[];

      for (final image in property.images) {
        fixedImages.add(await MediaStorage.copyImageToApp(image));
      }

      final fixedVideos = <String>[];

      if (property.videos != null) {
        for (final video in property.videos!) {
          fixedVideos.add(await MediaStorage.copyVideoToApp(video));
        }
      }

      final updated = property.copyWith(
        images: fixedImages,
        videos: fixedVideos,
      );

      await box.putAt(i, updated);
    }
  }
}