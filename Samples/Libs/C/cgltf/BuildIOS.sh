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

rm libcgltf_ios.a

clang -c -O3 -arch arm64 -isysroot $SDK_ROOT -DNDEBUG -xobjective-c++ -std=c++11 -miphoneos-version-min=11.0 cgltf.c

ar rcs libcgltf_ios.a *.o
ranlib libcgltf_ios.a
rm *.o
