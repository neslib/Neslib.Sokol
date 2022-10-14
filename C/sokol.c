#if defined(_WIN32)
  #define SOKOL_D3D11
  #define SOKOL_NO_ENTRY
#elif defined(__APPLE__)
  #define SOKOL_METAL
  #define SOKOL_NO_ENTRY
#elif defined(__ANDROID__)
  #define SOKOL_GLES3
#else  
  #error("Unsupported platform")
#endif

#define SOKOL_DLL
#define SOKOL_IMPL
#define FONTSTASH_IMPLEMENTATION
#define CIMGUI_DEFINE_ENUMS_AND_STRUCTS

// To enable Debug UI
#define SOKOL_TRACE_HOOKS

/* TODO:
   Symbols from these files are not exported from the DLL:
   * stb_truetype.h
*/
#include "sokol/sokol_app.h"
#include "sokol/sokol_args.h"
#include "sokol/sokol_audio.h"
//#include "sokol/sokol_fetch.h"
#include "sokol/sokol_gfx.h"
#include "sokol/sokol_glue.h"
#include "sokol/sokol_time.h"
#include "sokol/util/sokol_color.h"
#include "sokol/util/sokol_debugtext.h"
#include "sokol/util/sokol_gl.h"
#include "sokol/deps/fontstash.h"
#include "sokol/util/sokol_fontstash.h"

/* On macOS, Sokol must be compiled in C++ mode (-xobjective-c++)
   because sokol_app.h includes Metal, which requires C++. 
   However, all other units must be compiled in C mode,
   so we undefine __cplusplus here, and make sure symbols
   exported. */  
#if defined(__APPLE__)
#undef __cplusplus
extern "C" {
#endif

#include "sokol/deps/cimgui.h"
#include "sokol/util/sokol_imgui.h"
#include "sokol/util/sokol_gfx_imgui.h"

#if defined(__APPLE__)
}
#define __cplusplus
#endif

#include "sokol/util/sokol_memtrack.h"
//#include "sokol/deps/nuklear.h"
//#include "sokol/util/sokol_nuklear.h"
#include "sokol/util/sokol_shape.h"