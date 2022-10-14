LOCAL_PATH:= $(call my-dir)/..
include $(CLEAR_VARS)

LOCAL_MODULE     := sokol
LOCAL_C_INCLUDES := $(LOCAL_PATH)/sokol
LOCAL_CFLAGS     := -O3 -mfpu=neon -DNDEBUG
LOCAL_SRC_FILES  := sokol.c sokol/deps/cimgui.cpp sokol/deps/imgui/imgui.cpp sokol/deps/imgui/imgui_widgets.cpp sokol/deps/imgui/imgui_draw.cpp sokol/deps/imgui/imgui_tables.cpp sokol/deps/imgui/imgui_demo.cpp sokol/libs/basisu/sokol_basisu.cpp

include $(BUILD_STATIC_LIBRARY)