cd assimp_unzipped
cd assimp-4.1.0
cmake -Bbuild -H. -G "%GENERATOR%" -DASSIMP_BUILD_TESTS=OFF -DASSIMP_BUILD_ASSIMP_TOOLS=OFF -DASSIMP_NO_EXPORT=ON -DCMAKE_BUILD_TYPE=Release
IF %ERRORLEVEL% NEQ 0 (EXIT /B %ERRORLEVEL%)

cd build
echo ">>> start build"
nmake
IF %ERRORLEVEL% NEQ 0 (EXIT /B %ERRORLEVEL%)
nmake install
IF %ERRORLEVEL% NEQ 0 (EXIT /B %ERRORLEVEL%)
cd ..
REM in assimp-4.1.0
cd ..
REM in assimp_unzipped
cd ..
REM in project's root

%PYTHON% ci_scripts\\rename_lib.py
IF %ERRORLEVEL% NEQ 0 (EXIT /B %ERRORLEVEL%)
