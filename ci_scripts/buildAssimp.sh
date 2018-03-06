cd assimp_unzipped
cd assimp_-4.1.0
cmake -Bbuild -H. -G "%GENERATOR%" -DASSIMP_BUILD_TESTS=OFF -DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DASSIMP_NO_EXPORT=ON -DCMAKE_BUILD_TYPE=Release
cd build
make
make install
cd ..
cd ..
cd ..