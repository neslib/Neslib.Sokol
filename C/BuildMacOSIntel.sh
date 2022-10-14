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

rm libsokol_macos_intel.a

clang -c -fPIC -O3 -arch x86_64 -isysroot $SDK_ROOT -DNDEBUG -Isokol -Wno-address-of-temporary -xobjective-c++ -std=c++11 -mmacosx-version-min=10.13 sokol.c sokol/deps/cimgui.cpp sokol/deps/imgui/imgui.cpp sokol/deps/imgui/imgui_widgets.cpp sokol/deps/imgui/imgui_draw.cpp sokol/deps/imgui/imgui_tables.cpp sokol/deps/imgui/imgui_demo.cpp sokol/libs/basisu/sokol_basisu.cpp

ar rcs libsokol_macos_intel.a *.o
ranlib libsokol_macos_intel.a
rm *.o
