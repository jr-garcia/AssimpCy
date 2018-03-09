#!/usr/bin/env bash
if [ -z $1 ]
then
  path=cmake
else
  path=./cmake
fi
echo 'Building assimp...'
cd assimp_unzipped
cd assimp-4.1.0
${path} -Bbuild -H. -G 'Unix Makefiles' -DASSIMP_BUILD_TESTS=OFF -DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DASSIMP_NO_EXPORT=ON -DCMAKE_BUILD_TYPE=Release
rc=$?; if [[ ${rc} != 0 ]]; then exit ${rc}; fi
cd build
make
rc=$?; if [[ ${rc} != 0 ]]; then exit ${rc}; fi
make install
rc=$?; if [[ ${rc} != 0 ]]; then exit ${rc}; fi
cd ..
cd ..
cd ..