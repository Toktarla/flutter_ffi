#include <jni.h>
#include <string>
#include <opencv2/opencv.hpp>
#include <android/log.h>

#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, "ImageProcessing", __VA_ARGS__)

// Ensure C linkage for the functions
extern "C" {

// Function to apply Gaussian Blur
JNIEXPORT jstring JNICALL
Java_com_example_imagefilteringapp_ImageProcessing_nativeApplyGaussianBlur(
        JNIEnv* env,
        jobject /* this */,
        jstring inputPath,
        jstring outputPath,
        jint kernelSize) {

    if (inputPath == nullptr || outputPath == nullptr) {
        return env->NewStringUTF("Input or output path is null");
    }

    if (kernelSize < 3 || kernelSize % 2 == 0) {
        return env->NewStringUTF("Kernel size must be an odd number greater than or equal to 3");
    }

    const char *input_c = env->GetStringUTFChars(inputPath, nullptr);
    const char *output_c = env->GetStringUTFChars(outputPath, nullptr);

    if (input_c == nullptr || output_c == nullptr) {
        return env->NewStringUTF("Invalid input/output path");
    }

    cv::Mat image = cv::imread(input_c);
    if (image.empty()) {
        env->ReleaseStringUTFChars(inputPath, input_c);
        env->ReleaseStringUTFChars(outputPath, output_c);
        return env->NewStringUTF("Failed to load image");
    }

    cv::Mat output;
    cv::GaussianBlur(image, output, cv::Size(kernelSize, kernelSize), 0);

    if (!cv::imwrite(output_c, output)) {
        env->ReleaseStringUTFChars(inputPath, input_c);
        env->ReleaseStringUTFChars(outputPath, output_c);
        return env->NewStringUTF("Failed to save output image");
    }

    env->ReleaseStringUTFChars(inputPath, input_c);
    env->ReleaseStringUTFChars(outputPath, output_c);
    return env->NewStringUTF("Success");
}

// Function to apply Median Blur
JNIEXPORT jstring JNICALL
Java_com_example_imagefilteringapp_ImageProcessing_nativeApplyMedianBlur(
        JNIEnv* env,
        jobject /* this */,
        jstring inputPath,
        jstring outputPath,
        jint kernelSize) {

    if (inputPath == nullptr || outputPath == nullptr) {
        return env->NewStringUTF("Input or output path is null");
    }

    if (kernelSize < 3 || kernelSize % 2 == 0) {
        return env->NewStringUTF("Kernel size must be an odd number greater than or equal to 3");
    }

    const char *input_c = env->GetStringUTFChars(inputPath, nullptr);
    const char *output_c = env->GetStringUTFChars(outputPath, nullptr);

    // Check if the strings were successfully retrieved
    if (input_c == nullptr || output_c == nullptr) {
        if (input_c != nullptr) env->ReleaseStringUTFChars(inputPath, input_c);
        if (output_c != nullptr) env->ReleaseStringUTFChars(outputPath, output_c);
        return env->NewStringUTF("Failed to get string chars");
    }

    std::string inputStr(input_c);
    std::string outputStr(output_c);

    // Release the Java strings
    env->ReleaseStringUTFChars(inputPath, input_c);
    env->ReleaseStringUTFChars(outputPath, output_c);

    // Read the image
    cv::Mat image = cv::imread(inputStr);
    if (image.empty()) {
        return env->NewStringUTF("Failed to load image");
    }

    // Apply Median Blur
    cv::Mat blurred;
    cv::medianBlur(image, blurred, kernelSize);

    // Write the processed image
    bool success = cv::imwrite(outputStr, blurred);
    if (!success) {
        return env->NewStringUTF("Failed to save image");
    }

    LOGI("Loaded image size: %d x %d", image.cols, image.rows);

    return env->NewStringUTF("Success");
}

}
