@echo off
set avi_file="%~f1"


set avi_file_out="%~d1%~p1%~n1_prel.avi"


avidemux_cli.exe --info  --load %avi_file% | grep -q -i "Decoder FCC: MJPG"
IF NOT .%ERRORLEVEL%. == .0. GOTO END

avidemux_cli.exe --info  --load %avi_file% | grep -q -i "dwWidth.*320"
IF NOT .%ERRORLEVEL%. == .0. GOTO ENCODE_1300kbs

::ECHO ERRORLEVEL %ERRORLEVEL%
::ECHO cbr_val %cbr_val%

:ENCODE_450kbs
echo.
echo IN  %~f1
echo OUT %avi_file_out%
::avidemux2_cli.exe --save-raw-audio --video-process --video-codec XVID --video-conf cbr=%cbr_val% --load %avi_file% --save %avi_file_out% 1>&0
avidemux_cli.exe --nogui --load %avi_file%  --run D:\Altii\eu\bat\proj_450k.py --save %avi_file_out% 1>&0 2>&0
echo.
GOTO RENAME


:ENCODE_1300kbs
echo.
echo IN  %~f1
echo OUT %avi_file_out%
::avidemux2_cli.exe --save-raw-audio --video-process --video-codec XVID --video-conf cbr=%cbr_val% --load %avi_file% --save %avi_file_out% 1>&0
avidemux_cli.exe --nogui --load %avi_file%  --run D:\Altii\eu\bat\proj_1300k.py --save %avi_file_out% 1>&0 2>&0
echo.
GOTO RENAME

:RENAME
rename  %avi_file%   "%~n1%~x1.avii"


:END