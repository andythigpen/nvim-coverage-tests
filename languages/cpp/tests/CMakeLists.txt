cmake_minimum_required(VERSION 3.5)
Include(FetchContent)

FetchContent_Declare(
  Catch2
  GIT_SHALLOW    TRUE
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG        v3.3.1 # or a later release
)

FetchContent_MakeAvailable(Catch2)

list(APPEND CMAKE_MODULE_PATH ${catch2_SOURCE_DIR}/extras)
include(CTest)
include(Catch)
add_executable(exampleTests exampleTests.cpp)
target_include_directories(exampleTests PUBLIC ${catch2_SOURCE_DIR}/extras)
target_link_libraries(exampleTests PRIVATE Catch2::Catch2WithMain example)
add_test(exampleTests exampleTests)
