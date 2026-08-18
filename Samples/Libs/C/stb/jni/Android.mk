LOCAL_PATH:= $(call my-dir)/..
include $(CLEAR_VARS)

LOCAL_MODULE     := stb
LOCAL_C_INCLUDES := $(LOCAL_PATH)

ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
  LOCAL_CFLAGS   := -O3 -DNDEBUG
else
  LOCAL_CFLAGS   := -O3 -mfpu=neon -DNDEBUG
endif

LOCAL_SRC_FILES  := stb.c

include $(BUILD_STATIC_LIBRARY)