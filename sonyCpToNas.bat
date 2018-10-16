:: name_prel.mp4 -> name_prel.mp4.prel

@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

set dest_drive=Z:

set extension_photo_files=jpg
set extension_movie_files=m2ts mp4 mov vob


set file_output_suffix=_prel
set file_output_suffix_ext=.prel


IF     .%1. == .-h. GOTO HELP
IF     .%1. == .-H. GOTO HELP
IF     .%1. == ./?. GOTO HELP
IF NOT .%1. == ..   set  dest_drive=%1


IF NOT EXIST %dest_drive% (
	echo.
	echo Error: destination drive %dest_drive% is not mounted
	goto HELP
)


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
	
	set file_name_dst__full_path="%dest_drive%!file_path!!file_name!!file_extension!"
	
	IF NOT EXIST "%dest_drive%!file_path!" (
		call md "%dest_drive%!file_path!"
	)
	
	IF NOT EXIST !file_name_dst__full_path! (
		echo. !file_name! | findstr /C:"!file_output_suffix!" 1>nul
		if !errorlevel! EQU 0 (
			::file is prel: check if the original file is stored either remote or local
			rem ::replace substring  !file_output_suffix! with none
			set file_name__without_suffix=!file_name:%file_output_suffix%=!
			rem echo file_name__without_suffix=!file_name__without_suffix!

			set file_name_remote__without_suffix__no_extension=%dest_drive%!file_path!!file_name__without_suffix!
			set file_name_local__without_suffix__no_extension=!file_drive!!file_path!!file_name__without_suffix!
			rem echo !file_name_remote__without_suffix__no_extension!
			
			set file_original_found=
			for %%E in (
				!extension_all_files!
			) do (
				set iter_extension=%%E
				rem echo iter_extension=!iter_extension!
				for %%F in (
					"!file_name_remote__without_suffix__no_extension!.!iter_extension!"
					"!file_name_local__without_suffix__no_extension!.!iter_extension!"
				) do (
					rem echo test file %%F
					if exist %%F (
						rem echo file EXISTS %%F
						set file_original_found=1
					)
				)
			)
			
			if defined file_original_found (
				IF NOT EXIST !file_name_dst__full_path!!file_output_suffix_ext! (
					echo rename to !file_name_dst__full_path!!file_output_suffix_ext!
					cp -u --preserve=timestamps !file_name_src__full_path!  !file_name_dst__full_path!!file_output_suffix_ext!
				)
			) else (
				echo copy to   !file_name_dst__full_path!
				cp -u --preserve=timestamps !file_name_src__full_path!  !file_name_dst__full_path!
			)
		) else (
			:: file is original (it is NOT prel)
			echo copy to   !file_name_dst__full_path!
			cp -u --preserve=timestamps !file_name_src__full_path!  !file_name_dst__full_path!
		)
	)
)
goto END

:HELP
    echo.
    ECHO usage:  %0  [dest_drive]
    ECHO          ( default:      %dest_drive%  )
    GOTO END

:END
	ENDLOCAL
