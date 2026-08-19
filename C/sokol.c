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
#define STBTT_DEF extern

// To enable Debug UI
#define SOKOL_TRACE_HOOKS

#include "sokol/sokol_app.h"
#include "sokol/sokol_args.h"
#include "sokol/sokol_audio.h"
#include "sokol/sokol_gfx.h"
#include "sokol/sokol_glue.h"
#include "sokol/sokol_log.h"
#include "sokol/sokol_time.h"
#include "sokol/util/sokol_color.h"
#include "sokol/util/sokol_debugtext.h"
#include "sokol/util/sokol_gl.h"
#include "sokol/util/sokol_framebuffer.h"
#include "sokol/util/sokol_letterbox.h"
#include "sokol/util/sokol_memtrack.h"
#include "sokol/deps/cimgui.h"

#if defined(__APPLE__)
#undef __cplusplus
extern "C" {
#endif
    
#include "sokol/deps/fontstash.h"
#include "sokol/util/sokol_fontstash.h"
#include "sokol/util/sokol_imgui.h"
#include "sokol/util/sokol_gfx_imgui.h"
#include "sokol/util/sokol_app_imgui.h"
#include "sokol/util/sokol_shape.h"
#include "sokol/spine/spine.h"
#include "sokol/util/sokol_spine.h"
    
#if defined(__APPLE__)
}
#endif

// Must be included *after* fontstash.h
#define STB_TRUETYPE_IMPLEMENTATION
#include "sokol/deps/imstb_truetype.h"
#undef STB_TRUETYPE_IMPLEMENTATION
