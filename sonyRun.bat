@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set file_output_suffix=_prel

set temp_folder=D:\zzz_temp

::set scripts_path=%~d0%~p0avi_scripts
set scripts_path=D:\zzz_temp\avi_scripts

::set utils_path=%~d0%~p0utils
set utils_path=D:\zzz_temp\utils

::set aviDemux_path=D:\zzz_temp\avidemux.2.6
::set aviDemux_path=D:\zzz_temp\avidemux.2.6.7_x64
::set aviDemux_path=D:\zzz_temp\avidemux.2.6.8_x64
::set aviDemux_path=D:\zzz_temp\avidemux.2.6.14_x64
::set aviDemux_path=D:\zzz_temp\avidemux.2.6.18_x64
set aviDemux_path=D:\zzz_temp\avidemux.2.7.1_x64


set tempFile=%temp_folder%\sonyTemp.txt

::dir /b /s *.m2ts *.mp4 *.mov *.vob | grep -v "%file_output_suffix%" | sort > %tempFile%
dir /b /s *.m2ts *.mp4 *.mov *.vob | sort > %tempFile%

set file_name_old=
set file_full_old=
for /f  "eol=; delims=;" %%i in (%tempFile%) do (
    set file_full_current=%%i
    for %%K in (!file_full_current!) do set file_name_current=%%~nK
    if DEFINED  file_name_old  (
        ::exlude "_prel" files (note: remove first and last "  of file_name_old)
        if not .!file_name_current!. == .!file_name_old!!file_output_suffix!. (
		    ::exclude files already processed
            echo.!file_name_current! | findstr /C:"!file_name_old!" /C:"!file_output_suffix!" 1>nul
		    if !errorlevel! EQU 1 (
			    echo."!file_full_old!"
                call %scripts_path%\sonyComp.bat "!file_full_old!" %file_output_suffix%
		        set file_name_old=!file_name_current!
				set file_full_old=!file_full_current!
		    )
	    ) else (
	        set file_name_old=
			set file_full_old=
        )
	) else (
		echo.!file_name_current! | findstr /C:"!file_output_suffix!" 1>nul
		 if !errorlevel! EQU 1 (
			set file_name_old=!file_name_current!
			set file_full_old=!file_full_current!
		)
	)
)

::last file
echo.!file_name_current! | findstr /C:"!file_output_suffix!" 1>nul
if !errorlevel! EQU 1 (
    echo."!file_full_current!"
    call %scripts_path%\sonyComp.bat "!file_full_current!" %file_output_suffix%
)


del %tempFile%

ENDLOCAL
