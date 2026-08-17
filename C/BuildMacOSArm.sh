# NOTE: ARM build currently not used until I am able to test it

PLATFORM="MacOSX"

DEVELOPER_DIR=`xcode-select -print-path`
if [ ! -d $DEVELOPER_DIR ]; then
  echo "Please set up Xcode correctly. '$DEVELOPER_DIR' is not a valid developer tools folder."
  exit 1
fi

SDK_ROOT=$DEVELOPER_DIR/Platforms/$PLATFORM.platform/Developer/SDKs/$PLATFORM.sdk
if [ ! -d $SDK_ROOT ]; then
  echo "The MacOSX SDK was not found in $SDK_ROOT."
  exit 1
fi

rm libsokol_macos_arm.a

clang -c -fPIC -O3 -arch arm64 -isysroot $SDK_ROOT -DNDEBUG -Isokol -Wno-address-of-temporary -Wno-return-mismatch -Wno-deprecated-builtins -Wno-deprecated-declarations -Wno-builtin-macro-redefined -Wno-macro-redefined -xobjective-c++ -std=c++11 -mmacosx-version-min=14.0 sokol.c sokol/deps/cimgui.cpp sokol/deps/cimgui_internal.cpp sokol/deps/imgui.cpp sokol/deps/imgui_widgets.cpp sokol/deps/imgui_draw.cpp sokol/deps/imgui_tables.cpp sokol/deps/imgui_demo.cpp sokol/libs/basisu/sokol_basisu.cpp sokol/spine/src/*.c

ar rcs libsokol_macos_arm.a *.o
ranlib libsokol_macos_arm.a
rm *.o
