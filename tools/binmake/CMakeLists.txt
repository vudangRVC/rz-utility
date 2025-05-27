cmake_minimum_required(VERSION 3.10)
project(binmake C)

# Set compiler flags
set(CMAKE_C_STANDARD 99)
set(CMAKE_C_COMPILER "gcc")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wextra -O2")

# Include directory for cJSON
include_directories(utils/cjson)

# Source files
set(SOURCES
    binmake.c
    cjson/cJSON.c
)

# Executable target
add_executable(binmake ${SOURCES})

# Custom clean rule for .bin files
set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "*.bin")
