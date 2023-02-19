#define CATCH_CONFIG_MAIN // This tells Catch to provide a main() - only do this
                          // in one cpp file
#include "../src/example.hpp"
#include "catch_amalgamated.hpp"
#include <cstdint>

TEST_CASE("fizzbuzz", "[fizzbuzzTest]") {
    REQUIRE(fizzbuzz(3) == "fizz");
    REQUIRE(fizzbuzz(5) == "buzz");
    REQUIRE(fizzbuzz(15) == "fizzbuzz");
}
