#include <vector>
#include <string>
#include <set>
#include <sstream>

const char* vectorToString(const std::vector<std::string>& vec, const std::string separator);
const char* vectorToString(const std::vector<uint32_t>& vec, const std::string separator);
const char* vectorToString(const std::vector<uint64_t>& vec, const std::string separator);
const char* vectorToString(const std::vector<std::set<uint32_t>>& vec, const std::string separator);
const char* vectorToString(const std::set<uint32_t>& intSet, const std::string separator);
std::set<std::string> splitString(const std::string& str, const std::string& delim);
std::vector<uint64_t> splitStringUint(const std::string& str, const std::string& delim);