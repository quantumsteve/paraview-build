:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script for creating a ParaView kit on Windows
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Print some things for cross-checking
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set CMAKE_CMD="C:\Program Files (x86)\CMake 2.8\bin\cmake.exe"
%CMAKE_CMD% --version 

:: Set the system PATH for Qt and Python

set THIRD_PARTY=C:\Third_Party
set THIRD_PARTY_LIB=%THIRD_PARTY%\lib\win64
set PATH=%THIRD_PARTY_LIB%;%THIRD_PARTY_LIB%\Python27;%PATH%
:: Set Python paths since system has hard time figuring this out.
set PYTHON_LIB=%THIRD_PARTY_LIB%\Python27\libs\python27.lib
set PYTHON_INC=%THIRD_PARTY%\include\Python27\Include
set PYTHON_DEB=%THIRD_PARTY_LIB%\Python27\libs\python27_d.lib

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Setup ParaView versions for use below.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set PV_VERSION=v4.2.0
set PV_VERSION2=%PV_VERSION:v=%

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Building a ParaView kit on Windows requires things to be in top-level 
:: directories to avoid paths getting to long and choking the build.
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set BUILD_DIR=C:\PVSuper-%PV_VERSION2%
set SRC_DIR=C:\PVSuper-%PV_VERSION2%-source
if not exist %BUILD_DIR% (
    md %BUILD_DIR%
)
set HAVE_SRC_DIR=1
if not exist %SRC_DIR% (
    md %SRC_DIR%
	set HAVE_SRC_DIR=0
)

:: Checkout the Superbuild.
if 0 equ %HAVE_SRC_DIR% (
    "C:\Program Files (x86)\Git\bin\git.exe" clone -b %PV_VERSION% git://paraview.org/ParaViewSuperbuild.git %SRC_DIR%
)

:: Setup and build

cd %BUILD_DIR%

set BUILD_CONFIG=Release
set CMAKE_OPTS=-DBUILD_TESTING:BOOL=OFF -DCMAKE_BUILD_TYPE:STRING=%BUILD_CONFIG% -DCMAKE_INSTALL_PREFIX:PATH=%BUILD_DIR%/install 
set PV_OPTS=-DParaView_FROM_GIT=OFF
set PROJECTS=-DENABLE_matplotlib:BOOL=ON -DENABLE_paraview:BOOL=ON -DENABLE_python:BOOL=ON -DENABLE_qt:BOOL=ON
set USE_SYS=-DUSE_SYSTEM_matplotlib:BOOL=ON -DUSE_SYSTEM_python:BOOL=ON -DUSE_SYSTEM_qt:BOOL=ON
set PYTHON_SETUP=-DPYTHON_DEBUG_LIBRARY:FILEPATH=%PYTHON_DEB% -DPYTHON_INCLUDE_DIR:PATH=%PYTHON_INC% -DPYTHON_LIBRARY:FILEPATH=%PYTHON_LIB%
set EXTRAS=-DPV_EXTRA_CMAKE_ARGS:STRING=-DVTK_USE_SYSTEM_PYGMENTS:BOOL=ON

%CMAKE_CMD% -G "Visual Studio 11 Win64" %CMAKE_OPTS% %PV_OPTS% %PROJECTS% %USE_SYS% %PYTHON_SETUP% %EXTRAS% %SRC_DIR%
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

msbuild /nologo /m:%BUILD_THREADS% /nr:false /p:Configuration=%BUILD_CONFIG% ParaViewSuperBuild.sln
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

"C:\Program Files (x86)\CMake 2.8\bin\cpack.exe" -C %BUILD_CONFIG%
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

:: Need to copy the artifact back to the workspace otherwise the build will fail
if not %WORKSPACE%\build (
    md %WORKSPACE%\build
)

copy /Y *.exe %WORKSPACE%\build