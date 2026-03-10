#ifndef MONEROC_CHECKSUMS_WOWNERO
#define MONEROC_CHECKSUMS_WOWNERO
#ifdef __cplusplus
extern "C"
{
#endif

#ifdef __MINGW32__
    #define ADDAPI __declspec(dllexport)
#else
    #define ADDAPI __attribute__((__visibility__("default")))
#endif

extern ADDAPI const char * WOWNERO_wallet2_api_c_h_sha256;
extern ADDAPI const char * WOWNERO_wallet2_api_c_cpp_sha256;
extern ADDAPI const char * WOWNERO_wallet2_api_c_exp_sha256;

#ifdef __cplusplus
}
#endif
#endif
