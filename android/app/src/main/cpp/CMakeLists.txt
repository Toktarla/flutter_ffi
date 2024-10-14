# android/app/src/main/cpp/CMakeLists.txt

cmake_minimum_required(VERSION 3.10.2)

project("image_filtering_app")

# Specify the OpenCV directory
set(OpenCV_DIR "C:/OpenCV-android-sdk/sdk/native/jni")

find_package(OpenCV REQUIRED)

add_library(
        image_processing
        SHARED
        image_processing.cpp
)

include_directories(${OpenCV_INCLUDE_DIRS})

target_link_libraries(
        image_processing
        ${OpenCV_LIBS}
        log
)
