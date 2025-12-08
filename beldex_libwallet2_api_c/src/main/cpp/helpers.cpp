#include <inttypes.h>
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <vector>
#include <string>
#include "helpers.hpp"
#include <set>
#include <sstream>
#include <cstring>
#include <thread>
#include <iostream>
#include <stdexcept>

#ifdef __ANDROID__
#include <android/log.h>

#define LOG_TAG "moneroc"
#define BUFFER_SIZE 1024*32

static int stdoutToLogcat(const char *buf, int size) {
    __android_log_write(ANDROID_LOG_INFO, LOG_TAG, buf);
    return size;
}

static int stderrToLogcat(const char *buf, int size) {
    __android_log_write(ANDROID_LOG_ERROR, LOG_TAG, buf);
    return size;
}

void redirectStdoutThread(int pipe_stdout[2]) {
    char bufferStdout[BUFFER_SIZE];
    while (true) {
        int read_size = read(pipe_stdout[0], bufferStdout, sizeof(bufferStdout) - 1);
        if (read_size > 0) {
            bufferStdout[read_size] = '\0';
            stdoutToLogcat(bufferStdout, read_size);
        }
    }
}

void redirectStderrThread(int pipe_stderr[2]) {
    char bufferStderr[BUFFER_SIZE];
    while (true) {
        int read_size = read(pipe_stderr[0], bufferStderr, sizeof(bufferStderr) - 1);
        if (read_size > 0) {
            bufferStderr[read_size] = '\0';
            stderrToLogcat(bufferStderr, read_size);
        }
    }
}

void setupAndroidLogging() {
    static int pfdStdout[2];
    static int pfdStderr[2];

    pipe(pfdStdout);
    pipe(pfdStderr);

    dup2(pfdStdout[1], STDOUT_FILENO);
    dup2(pfdStderr[1], STDERR_FILENO);

    std::thread stdoutThread(redirectStdoutThread, pfdStdout);
    std::thread stderrThread(redirectStderrThread, pfdStderr);

    stdoutThread.detach();
    stderrThread.detach();
}

#endif // __ANDROID__

__attribute__((constructor))
void library_init() {
#ifdef __ANDROID__
    setupAndroidLogging();  // This will now run automatically when the library is loaded
#endif
}

const char* vectorToString(const std::vector<std::string>& vec, const std::string separator) {
    // Check if the vector is empty
    if (vec.empty()) {
        return "";
    }

    // Concatenate all strings in the vector
    std::string result;
    for (size_t i = 0; i < vec.size() - 1; ++i) {
        result += vec[i];
        result += separator;
    }
    result += vec.back();  // Append the last string without the separator

    std::string str = result;
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}

const char* vectorToString(const std::vector<uint32_t>& vec, const std::string separator) {
    // Calculate the size needed for the result string
    size_t size = 0;
    for (size_t i = 0; i < vec.size(); ++i) {
        // Calculate the number of digits in each element
        size += snprintf(nullptr, 0, "%u", vec[i]);
        // Add comma and space for all elements except the last one
        if (i < vec.size() - 1) {
            size += separator.size(); // comma and space
        }
    }

    // Allocate memory for the result string
    char* result = static_cast<char*>(malloc(size + 1));
    if (result == nullptr) {
        // Handle memory allocation failure
        return nullptr;
    }

    // Fill in the result string
    char* current = result;
    for (size_t i = 0; i < vec.size(); ++i) {
        // Convert each element to string and copy to the result string
        int written = snprintf(current, size + 1, "%u", vec[i]);
        current += written;
        // Add comma and space for all elements except the last one
        if (i < vec.size() - 1) {
            strcpy(current, separator.c_str());
            current += separator.size();
        }
    }

    return result;
}

const char* vectorToString(const std::vector<uint64_t>& vec, const std::string separator) {
    // Calculate the size needed for the result string
    size_t size = 0;
    for (size_t i = 0; i < vec.size(); ++i) {
        // Calculate the number of digits in each element
        size += snprintf(nullptr, 0, "%llu", vec[i]);
        // Add comma and space for all elements except the last one
        if (i < vec.size() - 1) {
            size += separator.size(); // comma and space
        }
    }

    // Allocate memory for the result string
    char* result = static_cast<char*>(malloc(size + 1));
    if (result == nullptr) {
        // Handle memory allocation failure
        return nullptr;
    }

    // Fill in the result string
    char* current = result;
    for (size_t i = 0; i < vec.size(); ++i) {
        // Convert each element to string and copy to the result string
        int written = snprintf(current, size + 1, "%llu", vec[i]);
        current += written;
        // Add comma and space for all elements except the last one
        if (i < vec.size() - 1) {
            strcpy(current, separator.c_str());
            current += separator.size();
        }
    }

    return result;
}

const char* vectorToString(const std::vector<std::set<uint32_t>>& vec, const std::string separator) {
    // Check if the vector is empty
    if (vec.empty()) {
        return "";
    }

    // Use a stringstream to concatenate sets with commas and individual elements with spaces
    std::ostringstream oss;
    oss << "{";
    for (auto it = vec.begin(); it != vec.end(); ++it) {
        if (it != vec.begin()) {
            oss << separator;
        }

        oss << "{";
        for (auto setIt = it->begin(); setIt != it->end(); ++setIt) {
            if (setIt != it->begin()) {
                oss << separator;
            }
            oss << *setIt;
        }
        oss << "}";
    }
    oss << "}";
    std::string str = oss.str();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}

// Function to convert std::set<uint32_t> to a string
const char* vectorToString(const std::set<uint32_t>& intSet, const std::string separator) {
    // Check if the set is empty
    if (intSet.empty()) {
        return "";
    }

    // Use a stringstream to concatenate elements with commas
    std::ostringstream oss;
    auto it = intSet.begin();
    oss << *it;
    for (++it; it != intSet.end(); ++it) {
        oss << ", " << *it;
    }

    std::string str = oss.str();
    const std::string::size_type size = str.size();
    char *buffer = new char[size + 1];   //we need extra char for NUL
    memcpy(buffer, str.c_str(), size + 1);
    return buffer;
}

std::set<std::string> splitString(const std::string& str, const std::string& delim) {
    std::set<std::string> tokens;
    if (str.empty()) return tokens;
    size_t pos = 0;
    std::string token;
    std::string content = str;  // Copy of str so we can safely erase content
    while ((pos = content.find(delim)) != std::string::npos) {
        token = content.substr(0, pos);
        tokens.insert(token);
        content.erase(0, pos + delim.length());
    }
    tokens.insert(content);  // Inserting the last token
    return tokens;
}

std::vector<std::string> splitStringVector(const std::string& str, const std::string& delim) {
    std::vector<std::string> tokens;
    if (str.empty()) return tokens;
    size_t pos = 0;
    std::string content = str;  // Copy of str so we can safely erase content
    while ((pos = content.find(delim)) != std::string::npos) {
        tokens.push_back(content.substr(0, pos));
        content.erase(0, pos + delim.length());
    }
    tokens.push_back(content);  // Inserting the last token
    return tokens;
}

std::vector<uint64_t> splitStringUint(const std::string& str, const std::string& delim) {
    std::vector<uint64_t> tokens;
    if (str.empty()) return tokens;
    size_t pos = 0;
    std::string token;
    std::string content = str;  // Copy of str so we can safely erase content
    while ((pos = content.find(delim)) != std::string::npos) {
        token = content.substr(0, pos);
        tokens.push_back(std::stoull(token));  // Convert string to uint64_t and push to vector
        content.erase(0, pos + delim.length());
    }
    tokens.push_back(std::stoull(content));  // Inserting the last token
    return tokens;
}