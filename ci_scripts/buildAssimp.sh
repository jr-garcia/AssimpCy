#!/usr/bin/env bash
echo 'Building assimp...'
echo "$ASSIMPINCLUDES"
echo "$ASSIMPLIBS"
cd assimp-5.0.1 || exit
cmake -Bbuild -G "Unix Makefiles" -DASSIMP_BUILD_TESTS=OFF -DASSIMP_BUILD_SAMPLES=OFF -DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DBUILD_SHARED_LIBS=OFF -DASSIMP_NO_EXPORT=OFF -DASSIMP_BUILD_ZLIB=ON -DASSIMP_OPT_BUILD_PACKAGES=OFF -DCMAKE_BUILD_TYPE=Release -DASSIMP_INCLUDE_INSTALL_DIR="$ASSIMPINCLUDES" -DASSIMP_LIB_INSTALL_DIR="$ASSIMPLIBS"
rc=$?; if [[ ${rc} != 0 ]]; then exit ${rc}; fi
cd build || exit
make clean
make --quiet
rc=$?; if [[ ${rc} != 0 ]]; then exit ${rc}; fi
make install
rc=$?; if [[ ${rc} != 0 ]]; then exit ${rc}; fi