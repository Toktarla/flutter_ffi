// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'image_processing.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _originalImage;
  File? _processedImage;
  final ImageProcessing _imageProcessing = ImageProcessing();
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);

    if (pickedFile != null) {
      setState(() {
        _originalImage = File(pickedFile.path);
        _processedImage = null;
      });
    }
  }

  Future<void> _applyFilter(String filterType) async {
    if (_originalImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    final directory = await getApplicationDocumentsDirectory();
    final String outputPath = '${directory.path}/processed_image.jpg';

    String result;

    if (filterType == 'Gaussian Blur') {
      result = _imageProcessing.applyGaussianBlur(
          _originalImage!.path, outputPath, 15); // Kernel size = 15
    } else if (filterType == 'Median Blur') {
      result = _imageProcessing.applyMedianBlur(
          _originalImage!.path, outputPath, 15); // Kernel size = 15
    } else {
      result = "Unknown filter";
    }

    if (result == "Success") {
      setState(() {
        _processedImage = File(outputPath);
      });
    } else {
      // Handle errors
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result)));
    }

    setState(() {
      _isProcessing = false;
    });
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        _originalImage != null
            ? Image.file(_originalImage!)
            : const Text('No image selected.'),
        const SizedBox(height: 20),
        _processedImage != null
            ? Image.file(_processedImage!)
            : const Text('No processed image.'),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Select Image'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () => _applyFilter('Gaussian Blur'),
          child: const Text('Apply Gaussian Blur'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _isProcessing
              ? null
              : () => _applyFilter('Median Blur'),
          child: const Text('Apply Median Blur'),
        ),
        const SizedBox(height: 20),
        _isProcessing ? const CircularProgressIndicator() : Container(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Filtering App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('High-Performance Image Processing'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildImageSection(),
                const SizedBox(height: 20),
                _buildButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
