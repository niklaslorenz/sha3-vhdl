cmake_minimum_required(VERSION 3.10)

enable_testing()

add_executable(sha3Tests test_keccak_p.cpp)
target_link_libraries(sha3Tests PUBLIC GTest::gtest_main keccak)

include(GoogleTest)
gtest_discover_tests(sha3Tests)
