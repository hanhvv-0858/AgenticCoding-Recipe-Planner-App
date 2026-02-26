import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Image compression utility.
///
/// Resizes images to max 1024px width and < 1MB before upload.
/// Per constitution constraint on image sizes.
class ImageUtils {
  ImageUtils._();

  /// Maximum width for uploaded images.
  static const int maxWidth = 1024;

  /// Maximum height for uploaded images.
  static const int maxHeight = 1024;

  /// Maximum file size in bytes (1MB).
  static const int maxFileSize = 1024 * 1024;

  /// Initial compression quality.
  static const int initialQuality = 85;

  /// Minimum compression quality.
  static const int minQuality = 20;

  /// Compress an image file to be within size limits.
  ///
  /// Returns the compressed image bytes, or null if compression fails.
  static Future<Uint8List?> compressFile(File file) async {
    try {
      final fileSize = await file.length();

      // If already small enough, just resize
      if (fileSize <= maxFileSize) {
        final result = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: maxWidth,
          minHeight: maxHeight,
          quality: initialQuality,
          format: CompressFormat.jpeg,
        );
        return result;
      }

      // Iteratively reduce quality until under size limit
      int quality = initialQuality;
      Uint8List? result;

      while (quality >= minQuality) {
        result = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          minWidth: maxWidth,
          minHeight: maxHeight,
          quality: quality,
          format: CompressFormat.jpeg,
        );

        if (result != null && result.length <= maxFileSize) {
          return result;
        }

        quality -= 10;
      }

      return result;
    } catch (_) {
      return null;
    }
  }

  /// Compress image bytes to be within size limits.
  static Future<Uint8List?> compressBytes(Uint8List bytes) async {
    try {
      if (bytes.length <= maxFileSize) {
        final result = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: maxWidth,
          minHeight: maxHeight,
          quality: initialQuality,
          format: CompressFormat.jpeg,
        );
        return result;
      }

      int quality = initialQuality;
      Uint8List? result;

      while (quality >= minQuality) {
        result = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: maxWidth,
          minHeight: maxHeight,
          quality: quality,
          format: CompressFormat.jpeg,
        );

        if (result.length <= maxFileSize) {
          return result;
        }

        quality -= 10;
      }

      return result;
    } catch (_) {
      return null;
    }
  }
}
