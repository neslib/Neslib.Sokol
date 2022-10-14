LOCAL_PATH:= $(call my-dir)/..
include $(CLEAR_VARS)

LOCAL_MODULE     := stb
LOCAL_C_INCLUDES := $(LOCAL_PATH)
LOCAL_CFLAGS     := -O3 -mfpu=neon -DNDEBUG
LOCAL_SRC_FILES  := stb.c

include $(BUILD_STATIC_LIBRARY)