@echo off
SETLOCAL

set path=%~d0%~p0;%path%
set tempFile=c:\canonTemp.txt

dir /b /s *.avi | grep -e "[0-9]*\.AVI$" > %tempFile%


for /f "eol=; delims=;" %%i in (%tempFile%) do canonComp.bat "%%i"


del %tempFile%

ENDLOCAL
