#include "example.hpp"

std::string fizzbuzz(int num) {
    if (num % 15 == 0) {
        return "fizzbuzz";
    }
    else if (num % 3 == 0) {
        return "fizz";
    }
    else if (num % 5 == 0) {
        return "buzz";
    }
    return std::to_string(num);
}
