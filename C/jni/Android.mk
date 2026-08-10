LOCAL_PATH:= $(call my-dir)/..
include $(CLEAR_VARS)

LOCAL_MODULE     := sokol
LOCAL_C_INCLUDES := $(LOCAL_PATH)/sokol
ifeq ($(TARGET_ARCH_ABI),arm64-v8a)
  LOCAL_CFLAGS     := -O3 -DNDEBUG -Wno-deprecated-builtins -Wno-implicit-const-int-float-conversion
else
  LOCAL_CFLAGS     := -O3 -mfpu=neon -DNDEBUG -Wno-deprecated-builtins -Wno-implicit-const-int-float-conversion
endif

LOCAL_SRC_FILES  := sokol.c\
  sokol/deps/cimgui.cpp\
  sokol/deps/cimgui_internal.cpp\
  sokol/deps/imgui.cpp\
  sokol/deps/imgui_widgets.cpp\
  sokol/deps/imgui_draw.cpp\
  sokol/deps/imgui_tables.cpp\
  sokol/deps/imgui_demo.cpp\
  sokol/libs/basisu/sokol_basisu.cpp\
  sokol/spine/src/Animation.c\
  sokol/spine/src/AnimationState.c\
  sokol/spine/src/AnimationStateData.c\
  sokol/spine/src/Array.c\
  sokol/spine/src/Atlas.c\
  sokol/spine/src/AtlasAttachmentLoader.c\
  sokol/spine/src/Attachment.c\
  sokol/spine/src/AttachmentLoader.c\
  sokol/spine/src/Bone.c\
  sokol/spine/src/BoneData.c\
  sokol/spine/src/BoundingBoxAttachment.c\
  sokol/spine/src/ClippingAttachment.c\
  sokol/spine/src/Color.c\
  sokol/spine/src/Debug.c\
  sokol/spine/src/Event.c\
  sokol/spine/src/EventData.c\
  sokol/spine/src/extension.c\
  sokol/spine/src/IkConstraint.c\
  sokol/spine/src/IkConstraintData.c\
  sokol/spine/src/Json.c\
  sokol/spine/src/MeshAttachment.c\
  sokol/spine/src/PathAttachment.c\
  sokol/spine/src/PathConstraint.c\
  sokol/spine/src/PathConstraintData.c\
  sokol/spine/src/PhysicsConstraint.c\
  sokol/spine/src/PhysicsConstraintData.c\
  sokol/spine/src/PointAttachment.c\
  sokol/spine/src/RegionAttachment.c\
  sokol/spine/src/Sequence.c\
  sokol/spine/src/Skeleton.c\
  sokol/spine/src/SkeletonBinary.c\
  sokol/spine/src/SkeletonBounds.c\
  sokol/spine/src/SkeletonClipping.c\
  sokol/spine/src/SkeletonData.c\
  sokol/spine/src/SkeletonJson.c\
  sokol/spine/src/Skin.c\
  sokol/spine/src/Slot.c\
  sokol/spine/src/SlotData.c\
  sokol/spine/src/TransformConstraint.c\
  sokol/spine/src/TransformConstraintData.c\
  sokol/spine/src/Triangulator.c\
  sokol/spine/src/VertexAttachment.c

include $(BUILD_STATIC_LIBRARY)