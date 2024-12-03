#include <vector>
#include <string>
#include <set>
#include <sstream>

#define WRAPPER_TRY() \
    try {

#define WRAPPER_CATCH_CONST_CHAR() \
    } catch (const std::exception &e) { \
        std::string error_message = std::string("Exception caught: ") + e.what(); \
        char* result = static_cast<char*>(malloc(error_message.size() + 1)); \
        if (result) { \
            std::strcpy(result, error_message.c_str()); \
        } \
        return result; \
    } catch (...) { \
        std::string error_message = "Unknown exception caught."; \
        char* result = static_cast<char*>(malloc(error_message.size() + 1)); \
        if (result) { \
            std::strcpy(result, error_message.c_str()); \
        } \
        return result; \
    }

#define WRAPPER_CATCH(default_value) \
    } catch (const std::exception &e) { \
        std::cerr << "Exception caught: " << e.what() << std::endl; \
        return default_value; \
    } catch (...) { \
        std::cerr << "Unknown exception caught." << std::endl; \
        return default_value; \
    }


#define WRAPPER_CATCH_VOID() \
    } catch (const std::exception &e) { \
        std::cerr << "Exception caught: " << e.what() << std::endl; \
        return; \
    } catch (...) { \
        std::cerr << "Unknown exception caught." << std::endl; \
        return; \
    }


const char* vectorToString(const std::vector<std::string>& vec, const std::string separator);
const char* vectorToString(const std::vector<uint32_t>& vec, const std::string separator);
const char* vectorToString(const std::vector<uint64_t>& vec, const std::string separator);
const char* vectorToString(const std::vector<std::set<uint32_t>>& vec, const std::string separator);
const char* vectorToString(const std::set<uint32_t>& intSet, const std::string separator);
std::set<std::string> splitString(const std::string& str, const std::string& delim);
std::vector<uint64_t> splitStringUint(const std::string& str, const std::string& delim);
std::vector<std::string> splitStringVector(const std::string& str, const std::string& delim);