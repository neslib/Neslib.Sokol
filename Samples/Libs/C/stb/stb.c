#define STB_IMAGE_IMPLEMENTATION
#define STB_TRUETYPE_IMPLEMENTATION

#if defined(_WIN32)
#define STBIDEF __declspec(dllexport)
#define STBTT_DEF __declspec(dllexport)
#else
#define STBTT_DEF
#endif

#include "stb_image.h"
#include "stb_truetype.h"
