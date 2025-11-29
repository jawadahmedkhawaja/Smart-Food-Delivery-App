import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'dwxk85mdb';
  static const String uploadPreset = 'azpuabjj';

  static Future<String?> uploadFile() async {
    /// PICK FILE (Works on Web + Mobile)
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,  // needed for web
    );

    if (result == null) return null; // user cancelled

    final PlatformFile file = result.files.first;

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = uploadPreset;

    // FILE HANDLING FOR WEB
    if (kIsWeb) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes as Uint8List,
          filename: file.name,
        ),
      );
    } else {
      // FILE HANDLING FOR MOBILE
      request.files.add(
        await http.MultipartFile.fromPath('file', file.path!),
      );
    }

    final response = await request.send();
    final resBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final secureUrl = RegExp(r'"secure_url":"([^"]+)"')
          .firstMatch(resBody)!
          .group(1)!
          .replaceAll(r'\/', '/');

      return secureUrl;
    } else {
      debugPrint('Cloudinary Upload Failed: $resBody');
      return null;
    }
  }
}
