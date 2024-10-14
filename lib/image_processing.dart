// lib/image_processing.dart

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

typedef NativeApplyGaussianBlur = Pointer<Utf8> Function(
    Pointer<Utf8> inputPath, Pointer<Utf8> outputPath, Int64 kernelSize);
typedef DartApplyGaussianBlur = Pointer<Utf8> Function(
    Pointer<Utf8> inputPath, Pointer<Utf8> outputPath, int kernelSize);

typedef NativeApplyMedianBlur = Pointer<Utf8> Function(
    Pointer<Utf8> inputPath, Pointer<Utf8> outputPath, Int64 kernelSize);
typedef DartApplyMedianBlur = Pointer<Utf8> Function(
    Pointer<Utf8> inputPath, Pointer<Utf8> outputPath, int kernelSize);

class ImageProcessing {
  late DynamicLibrary _lib;

  late DartApplyGaussianBlur _applyGaussianBlur;
  late DartApplyMedianBlur _applyMedianBlur;

  ImageProcessing() {
    // Load the native library
    _lib = _loadLibrary();

    // Bind the native functions
    _applyGaussianBlur = _lib
        .lookup<NativeFunction<NativeApplyGaussianBlur>>(
        'Java_com_example_imagefilteringapp_ImageProcessing_nativeApplyGaussianBlur')
        .asFunction();

    _applyMedianBlur = _lib
        .lookup<NativeFunction<NativeApplyMedianBlur>>(
        'Java_com_example_imagefilteringapp_ImageProcessing_nativeApplyMedianBlur')
        .asFunction();
  }

  // Function to load the appropriate library based on the platform
  DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libimage_processing.so');
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  // Wrapper for Gaussian Blur
  String applyGaussianBlur(
      String inputPath, String outputPath, int kernelSize) {
    final Pointer<Utf8> inputPtr = inputPath.toNativeUtf8();
    final Pointer<Utf8> outputPtr = outputPath.toNativeUtf8();

    final Pointer<Utf8> resultPtr =
    _applyGaussianBlur(inputPtr, outputPtr, kernelSize);

    final String result = resultPtr.toDartString();

    malloc.free(inputPtr);
    malloc.free(outputPtr);

    return result;
  }

  // Wrapper for Median Blur
  String applyMedianBlur(
      String inputPath, String outputPath, int kernelSize) {
    final Pointer<Utf8> inputPtr = inputPath.toNativeUtf8();
    final Pointer<Utf8> outputPtr = outputPath.toNativeUtf8();

    final Pointer<Utf8> resultPtr =
    _applyMedianBlur(inputPtr, outputPtr, kernelSize);

    final String result = resultPtr.toDartString();

    malloc.free(inputPtr);
    malloc.free(outputPtr);

    return result;
  }
}
