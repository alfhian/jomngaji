cmake_minimum_required(VERSION 3.10.2)

project(whisper_flutter)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_C_STANDARD 11)

add_definitions(-DGGML_USE_K_QUANTS)
add_definitions(-DGGML_NO_METAL)

# ====== GGML FILES (new structure 1.5.x) ======
file(GLOB GGML_SRC
    "ggml/ggml.c"
    "ggml/ggml-alloc.c"
    "ggml/ggml-backend.c"
    "ggml/ggml-quants.c"
)

# Exclude GPU-specific files
# DO NOT COMPILE:
#   ggml-cuda.cu
#   ggml-metal.m
#   ggml-opencl.cpp

# ====== WHISPER FILES ======
set(WHISPER_SRC
    whisper.cpp
)

# ====== WRAPPER FILE ======
set(WRAPPER_SRC
    whisper_wrapper.cpp
)

# ====== BUILD SHARED LIBRARY ======
add_library(
    whisper_jni
    SHARED
    ${GGML_SRC}
    ${WHISPER_SRC}
    ${WRAPPER_SRC}
)

# ====== ANDROID LOG ======
find_library(log-lib log)

target_link_libraries(
    whisper_jni
    ${log-lib}
)

include_directories(${CMAKE_SOURCE_DIR})
include_directories(${CMAKE_SOURCE_DIR}/ggml)
