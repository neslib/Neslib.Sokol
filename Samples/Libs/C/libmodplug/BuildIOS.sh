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

rm libmodplug_ios.a

clang -c -O3 -arch arm64 -isysroot $SDK_ROOT -DNDEBUG -DHAVE_SINF -Isrc/libmodplug -Wno-deprecated-register -xobjective-c++ -std=c++11 -miphoneos-version-min=11.0 src/fastmix.cpp src/load_669.cpp src/load_abc.cpp src/load_amf.cpp src/load_ams.cpp src/load_dbm.cpp src/load_dmf.cpp src/load_dsm.cpp src/load_far.cpp src/load_it.cpp src/load_j2b.cpp src/load_mdl.cpp src/load_med.cpp src/load_mid.cpp src/load_mod.cpp src/load_mt2.cpp src/load_mtm.cpp src/load_okt.cpp src/load_pat.cpp src/load_psm.cpp src/load_ptm.cpp src/load_s3m.cpp src/load_stm.cpp src/load_ult.cpp src/load_umx.cpp src/load_wav.cpp src/load_xm.cpp src/mmcmp.cpp src/modplug.cpp src/sndfile.cpp src/sndmix.cpp src/snd_dsp.cpp src/snd_flt.cpp src/snd_fx.cpp

ar rcs libmodplug_ios.a *.o
ranlib libmodplug_ios.a
rm *.o
