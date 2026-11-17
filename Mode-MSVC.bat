@echo off
setlocal

if not defined SDL2_ROOT set "SDL2_ROOT=C:\SDL2"
if not defined SDL2_MIXER_ROOT set "SDL2_MIXER_ROOT=C:\SDL2_mixer"
if not defined MSVC_ARCH set "MSVC_ARCH=%VSCMD_ARG_TGT_ARCH%"
if not defined MSVC_ARCH set "MSVC_ARCH=x64"

if /I not "%MSVC_ARCH%"=="x64" if /I not "%MSVC_ARCH%"=="x86" (
	echo MSVC_ARCH must be x64 or x86.
	exit /b 1
)
where cl.exe >nul 2>nul
if errorlevel 1 (
	echo Run Mode-MSVC from a Visual Studio Developer Command Prompt.
	exit /b 1
)
if not exist "%SDL2_ROOT%\include\SDL.h" (
	echo SDL2 headers not found under "%SDL2_ROOT%".
	exit /b 1
)
if not exist "%SDL2_MIXER_ROOT%\include\SDL_mixer.h" (
	echo SDL2_mixer headers not found under "%SDL2_MIXER_ROOT%".
	exit /b 1
)
if not exist "%SDL2_ROOT%\lib\%MSVC_ARCH%\SDL2.lib" (
	echo SDL2 libraries not found for %MSVC_ARCH%.
	exit /b 1
)
if not exist "%SDL2_MIXER_ROOT%\lib\%MSVC_ARCH%\SDL2_mixer.lib" (
	echo SDL2_mixer libraries not found for %MSVC_ARCH%.
	exit /b 1
)

if not exist "%~dp0win-msvc" mkdir "%~dp0win-msvc"
pushd "%~dp0win-msvc"

cl.exe /nologo /O2 /W3 /std:c11 /D_CRT_SECURE_NO_WARNINGS /I"%SDL2_ROOT%\include" /I"%SDL2_MIXER_ROOT%\include" ..\sdl12main.c ..\celeste.c /Fe"ccleste.exe" /link /SUBSYSTEM:WINDOWS /LIBPATH:"%SDL2_ROOT%\lib\%MSVC_ARCH%" /LIBPATH:"%SDL2_MIXER_ROOT%\lib\%MSVC_ARCH%" SDL2main.lib SDL2_mixer.lib SDL2.lib Shell32.lib
if errorlevel 1 goto build_failed

copy /Y "%SDL2_ROOT%\lib\%MSVC_ARCH%\SDL2.dll" . >nul
if errorlevel 1 goto build_failed
copy /Y "%SDL2_MIXER_ROOT%\lib\%MSVC_ARCH%\SDL2_mixer.dll" . >nul
if errorlevel 1 goto build_failed
xcopy /E /I /Y "%~dp0data" data >nul
if errorlevel 1 goto build_failed
copy /Y "%~dp0gamecontrollerdb.txt" . >nul
if errorlevel 1 goto build_failed

echo MSVC builds are in "%CD%".
popd
exit /b 0

:build_failed
echo MSVC build or staging failed.
popd
exit /b 1
