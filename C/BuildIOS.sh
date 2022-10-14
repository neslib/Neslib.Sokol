PLATFORM="iPhoneOS"

DEVELOPER_DIR=`xcode-select -print-path`
if [ ! -d $DEVELOPER_DIR ]; then
  echo "Please set up Xcode correctly. '$DEVELOPER_DIR' is not a valid developer tools folder."
  exit 1
fi

SDK_ROOT=$DEVELOPER_DIR/Platforms/$PLATFORM.platform/Developer/SDKs/$PLATFORM.sdk
if [ ! -d $SDK_ROOT ]; then
  echo "The iOS SDK was not found in $SDK_ROOT."
  exit 1
fi

rm libsokol_ios.a

clang -c -O3 -arch arm64 -isysroot $SDK_ROOT -DNDEBUG -Isokol -xobjective-c++ -std=c++11 -miphoneos-version-min=11.0 sokol.c sokol/deps/cimgui.cpp sokol/deps/imgui/imgui.cpp sokol/deps/imgui/imgui_widgets.cpp sokol/deps/imgui/imgui_draw.cpp sokol/deps/imgui/imgui_tables.cpp sokol/deps/imgui/imgui_demo.cpp sokol/libs/basisu/sokol_basisu.cpp

ar rcs libsokol_ios.a *.o
ranlib libsokol_ios.a
rm *.o
