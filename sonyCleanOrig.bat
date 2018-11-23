:: name_prel.mp4 -> name_prel.mp4.prel

@echo off
SETLOCAL ENABLEDELAYEDEXPANSION


rem set extension_photo_files=jpg
set extension_movie_files=m2ts mp4 mov vob


set file_output_suffix=_prel
set file_output_extension=mp4


IF     .%1. == .-h. GOTO HELP
IF     .%1. == .-H. GOTO HELP
IF     .%1. == ./?. GOTO HELP


set extension_all_files=!extension_photo_files! !extension_movie_files!
set all_files=
for %%e in (!extension_all_files!) DO (
	set all_files=!all_files! *.%%e
)
::echo.!all_files!


for /f "tokens=*" %%f in ('dir /b /s !all_files!') DO  (
    set file_name_src__full_path="%%f"
	for %%K in (!file_name_src__full_path!) do set file_drive=%%~dK
	for %%K in (!file_name_src__full_path!) do set file_path=%%~pK
	for %%K in (!file_name_src__full_path!) do set file_name=%%~nK
	for %%K in (!file_name_src__full_path!) do set file_extension=%%~xK
	
	echo. !file_name! | findstr /C:"!file_output_suffix!" 1>nul
	if !errorlevel! NEQ 0 (
	    set file_name_prel__full_path="!file_drive!!file_path!!file_name!!file_output_suffix!.!file_output_extension!"
    	IF EXIST !file_name_prel__full_path! (
		    echo !file_name_src__full_path!
			rem rm !file_name_src__full_path!
	    )
	)
)

goto END

:HELP
    echo.
    ECHO usage:  %0 
    ECHO        Clean-up original files and preserve "_prel" ones.
	ECHO.
	ECHO        Please backup all files with "sonyCpToNas.bat [NAS]"
    GOTO END

:END
	ENDLOCAL