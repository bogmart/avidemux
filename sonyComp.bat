@echo off

::input params
:: %1  - file name with full path
:: %2  - prefix for encoded files (eg: _prel)

::quality 25 (best is 1)
set /a compress_quality_sw = 25

::nvidia hw compression
set /a compress_bitrate_hw = 4000
set /a bitrate_threshold   = 2500
set use_hw=0

set compress_remux_suffix=_remux

set file_input="%~f1"

::out_file = in_file + _prel
set file_output_extension=mp4
set file_output="%~n1%2.%file_output_extension%"
set file_output_with_path="%~d1%~p1%~n1%2.%file_output_extension%"
set file_output_tmp_same_path="%~d1%~p1%~n1_tmp.%file_output_extension%"
set file_output_tmp_temp_folder_HDD="%temp_folder%\%~n1_tmp.%file_output_extension%"

::pentru compresie direct pe USB/SD trebuie folosit temp_HDD
set file_output_tmp=%file_output_tmp_temp_folder_HDD%

set /a bitRate = 0
set resolution=0
set scanType=0

:: Bit rate format:
::   8 863 kb/s
::   11.8 Mb/s
for /f "tokens=1,2,3,4" %%a in (
	'%utils_path%\MediaInfo.exe %file_input% ^| %utils_path%\grep -m1 -E "Bit rate *:" ^| %utils_path%\sed "s/Bit rate *: //" ^| %utils_path%\sed "s/\([0-9]*\) \([0-9]*\)/\1\2/" ^| %utils_path%\sed "s/kb\/s/ 1/" ^| %utils_path%\sed "s/Mb\/s/ 1020/"  ^| %utils_path%\awk "{rez=$1 * $2}; END {print rez"}"'
	) do (
		set /a bitRate  = %%a
    )

::check if bit rate is below the configured threshold
if !bitRate! LSS !bitrate_threshold! (
   GOTO SKIP
)   


if %use_hw% == 1 (
    ::HW GPU compression
    set script_proj=proj_nvidia_h264_q%compress_bitrate_hw%_mp4.py
	GOTO ENCODE_h264
	
) else (
    :: SW compression
	for /f "tokens=1" %%e in (
	   '%utils_path%\MediaInfo.exe %file_input% ^| %utils_path%\grep -E "Width|Height" ^| %utils_path%\awk "(width==0 && height==0){width=$3$4}; {height=$3$4}; END {rez=width/height; print rez"}"'
	   ) do (
			  set resolution=%%e
			)

	for /f "tokens=1" %%f in (
	   '%utils_path%\MediaInfo.exe %file_input% ^| %utils_path%\grep -m 1 -E "Scan type" ^| %utils_path%\awk "{scan=$4}; END {print scan"}"'
	   ) do (
			  set scanType=%%f
			)

	if !resolution! == 1.33333 (
		if .!scanType!. == .Interlaced. (
			set script_proj=proj_h264_q%compress_quality_sw%_1x1_i_mp4.py 
		) else (
			set script_proj=proj_h264_q%compress_quality_sw%_1x1_mp4.py
		)
		GOTO ENCODE_h264
	)
	if !resolution! == 1.25 (
		if .!scanType!. == .Interlaced. (
			set script_proj=proj_h264_q%compress_quality_sw%_16x9_i_mp4.py
		) else (
			set script_proj=proj_h264_q%compress_quality_sw%_16x9_mp4.py
		)
		GOTO ENCODE_h264
	)
	if !resolution! == 1.77778 (
		if .!scanType!. == .Interlaced. (
			set script_proj=proj_h264_q%compress_quality_sw%_1x1_i_mp4.py 
		) else (
			set script_proj=proj_h264_q%compress_quality_sw%_1x1_mp4.py
		)
		GOTO ENCODE_h264
	)
)

GOTO ERROR


:ENCODE_h264
    echo.
    echo IN     %file_input%
    echo OUT    %file_output%
    echo script %script_proj%
    %aviDemux_path%\avidemux_cli.exe --nogui --load %file_input%  --run %scripts_path%\%script_proj% --save %file_output_tmp% 1>&0 2>&0
    echo.
    GOTO TEST_ERROR


:REMUX
    set file_input_remux="%~d1%~p1%~n1%compress_remux_suffix%%~x1"
    %utils_path%\TsRemux.exe %file_input% %file_input_remux%
    set file_input=%file_input_remux%
    GOTO ENCODE_h264


:TEST_ERROR
    IF %ERRORLEVEL% NEQ 0  (
        IF NOT .%file_input_remux%. == .. (
            GOTO  ERROR_AVIDEMUX
        )
        GOTO  REMUX
    )
    GOTO RENAME


:RENAME
    ::rename  %file_input%   "%~n1%~x1.avii"
    if  %file_output_tmp% == %file_output_tmp_same_path% (
        rename  %file_output_tmp%  %file_output%
    )
    if  %file_output_tmp% == %file_output_tmp_temp_folder_HDD% (
        move    %file_output_tmp%  %file_output_with_path%   1>&0 2>&0
    )
    GOTO DELETE_INTERMEDIATE_FILES


:DELETE_INTERMEDIATE_FILES
    if .%file_input_remux%.==.%file_input%. (
        del %file_input_remux%
        set file_input_remux=
    )

    IF EXIST %file_input%.idx2 (
        del  %file_input%.idx2
    )
    GOTO END


:SKIP
    echo skip: bitRate=!bitRate!
	echo.
    GOTO END

:ERROR
	echo.
	echo ERROR:  wrong resolution !resolution!
	GOTO END

:ERROR_AVIDEMUX
	echo.
	echo  ERROR: avi_demux
	echo.
	GOTO END


:END
