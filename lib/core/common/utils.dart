import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void showsnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.only(bottom: 0),
    content: Text(text),
    duration: const Duration(seconds: 1),
  ));
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);

  return image;
}
