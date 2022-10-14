LOCAL_PATH:= $(call my-dir)/..
include $(CLEAR_VARS)

LOCAL_MODULE     := pl_mpeg
LOCAL_C_INCLUDES := $(LOCAL_PATH)
LOCAL_CFLAGS     := -O3 -mfpu=neon -DNDEBUG
LOCAL_SRC_FILES  := pl_mpeg.c

include $(BUILD_STATIC_LIBRARY)