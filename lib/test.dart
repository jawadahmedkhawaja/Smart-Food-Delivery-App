
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'resources/uploading_pictures_to_db.dart';

class FileUp extends StatefulWidget {
  const FileUp({super.key});

  @override
  State<FileUp> createState() => _FileUpState();
}

class _FileUpState extends State<FileUp> {
  String? path;
  Future<void> pickImage() async {
    final pickedPath = await LocalImageStorage().pickAndSaveImage(
      ImageSource.gallery,
      customFileName: 'Hello',
    );

    setState(() {
      path = pickedPath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Slider(
        value: 23,
        onChanged: (value) {
          value++;
        },
      ),
    );
  }
}
