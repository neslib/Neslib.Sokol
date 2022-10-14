LOCAL_PATH:= $(call my-dir)/..
include $(CLEAR_VARS)

LOCAL_MODULE     := ozzanim
LOCAL_C_INCLUDES := $(LOCAL_PATH)
LOCAL_CFLAGS     := -O3 -mfpu=neon -DNDEBUG -Iinclude
LOCAL_SRC_FILES  := ozzanim.cpp src/ozz_animation.cc src/ozz_base.cc src/mesh.cc

include $(BUILD_STATIC_LIBRARY)