import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

class ImageService {
  static const int _maxWidth = 1200;
  static const int _maxHeight = 1200;
  static const int _quality = 85;
  static const String _cacheDir = 'optimized_images';

  // Compress and optimize image
  Future<File?> optimizeImage(File imageFile) async {
    try {
      final dir = await _getCacheDirectory();
      final String fileName = await _generateFileName(imageFile);
      final String targetPath = '${dir.path}/$fileName';

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: _quality,
        maxWidth: _maxWidth,
        maxHeight: _maxHeight,
        rotate: 0,
      );

      return result;
    } catch (e) {
      print('Error optimizing image: $e');
      return null;
    }
  }

  // Compress image as Uint8List (for web support)
  Future<Uint8List?> optimizeImageBytes(Uint8List imageBytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: _quality,
        maxWidth: _maxWidth,
        maxHeight: _maxHeight,
        rotate: 0,
      );

      return result;
    } catch (e) {
      print('Error optimizing image bytes: $e');
      return null;
    }
  }

  // Generate a unique filename based on content hash
  Future<String> _generateFileName(File file) async {
    final bytes = await file.readAsBytes();
    final hash = sha256.convert(bytes);
    final extension = file.path.split('.').last;
    return '$hash.$extension';
  }

  // Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final cacheDir = await getTemporaryDirectory();
    final optimizedImagesDir = Directory('${cacheDir.path}/$_cacheDir');

    if (!await optimizedImagesDir.exists()) {
      await optimizedImagesDir.create(recursive: true);
    }

    return optimizedImagesDir;
  }

  // Clear image cache
  Future<void> clearImageCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      await CachedNetworkImage.evictFromCache();
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }

  // Get cached image if available
  Future<File?> getCachedImage(String url) async {
    try {
      final dir = await _getCacheDirectory();
      final fileName = _generateFileNameFromUrl(url);
      final file = File('${dir.path}/$fileName');

      if (await file.exists()) {
        return file;
      }

      return null;
    } catch (e) {
      print('Error getting cached image: $e');
      return null;
    }
  }

  // Cache network image
  Future<File?> cacheNetworkImage(String url) async {
    try {
      final response = await HttpClient().getUrl(Uri.parse(url));
      final HttpClientResponse data = await response.close();
      final bytes = await consolidateHttpClientResponseBytes(data);

      final optimizedBytes = await optimizeImageBytes(bytes);
      if (optimizedBytes == null) return null;

      final dir = await _getCacheDirectory();
      final fileName = _generateFileNameFromUrl(url);
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(optimizedBytes);
      return file;
    } catch (e) {
      print('Error caching network image: $e');
      return null;
    }
  }

  String _generateFileNameFromUrl(String url) {
    final hash = sha256.convert(utf8.encode(url));
    final extension = url.split('.').last.split('?').first;
    return '$hash.$extension';
  }

  // Get image dimensions
  Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final data = await decodeImageFromList(bytes);
      return {
        'width': data.width,
        'height': data.height,
      };
    } catch (e) {
      print('Error getting image dimensions: $e');
      return null;
    }
  }

  // Check if image needs optimization
  Future<bool> needsOptimization(File imageFile) async {
    try {
      final dimensions = await getImageDimensions(imageFile);
      if (dimensions == null) return false;

      final fileSize = await imageFile.length();
      final exceedsDimensions = dimensions['width']! > _maxWidth ||
          dimensions['height']! > _maxHeight;
      final exceedsSize = fileSize > 1024 * 1024; // 1MB

      return exceedsDimensions || exceedsSize;
    } catch (e) {
      print('Error checking if image needs optimization: $e');
      return false;
    }
  }

  // Get optimized image URL for web
  String getOptimizedImageUrl(
    String originalUrl, {
    int? width,
    int? height,
    int? quality,
  }) {
    // Implement your image CDN or resizing service URL generation here
    // Example using a hypothetical image CDN:
    final uri = Uri.parse(originalUrl);
    final params = {
      'w': (width ?? _maxWidth).toString(),
      'h': (height ?? _maxHeight).toString(),
      'q': (quality ?? _quality).toString(),
      'fit': 'cover',
    };
    return uri.replace(queryParameters: params).toString();
  }
}
