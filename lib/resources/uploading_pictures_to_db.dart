// services/local_image_storage.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalImageStorage {
  static final LocalImageStorage _instance = LocalImageStorage._internal();
  factory LocalImageStorage() => _instance;
  LocalImageStorage._internal();

  final ImagePicker _picker = ImagePicker();
  bool get isWeb => kIsWeb;

  /// Save image to local storage and return path
  Future<String?> saveImageToLocal(
    XFile imageFile, {
    String? customFileName,
  }) async {
    try {
      return await _saveToFileSystem(imageFile, customFileName: customFileName);
    } catch (e) {
      return null;
    }
  }
  
  /// Pick image and save locally - returns path for Firebase
  Future<String?> pickAndSaveImage(
    ImageSource source, {
    String? customFileName,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return null;
      return await saveImageToLocal(pickedFile, customFileName: customFileName);
    } catch (e) {
      print('Error picking/saving image: $e');
      return null;
    }
  }


  /// Mobile: Save to file system and return file path
  Future<String> _saveToFileSystem(
    XFile imageFile, {
    String? customFileName,
  }) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String? fileName =
        customFileName;
    final String directoryPath = p.join(appDir.path, 'food_images');
    final String fullPath = p.join(directoryPath, fileName);

    // Create directory if it doesn't exist
    final Directory dir = Directory(directoryPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // FIXED: Copy the file instead of using saveTo()
    final File originalFile = File(imageFile.path);
    final File savedFile = await originalFile.copy(fullPath);

    return savedFile.path;
  }

  /// Get image from local storage using path from Firebase
  Future<Uint8List?> getImage(String imagePath) async {
    try {
      if (isWeb) return null;
      return await _getImageFromFileSystem(imagePath);
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  /// Mobile: Read image from file system
  Future<Uint8List?> _getImageFromFileSystem(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return await imageFile.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading image: $e');
      return null;
    }
  }

  /// Check if image exists
  Future<bool> imageExists(String imagePath) async {
    if (isWeb) return false;
    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      return false;
    }
  }
}
