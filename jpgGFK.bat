@echo off
setlocal enabledelayedexpansion

rem    This script does:
rem        - it converts "png" and "gif" images to "jpg"
rem        - it renames "jpeg" to "jpg"
rem
rem    How to use:
rem        net use z: "\\bucw-fs04\i\online\!!PROJECTS GPS\2019\Consumer\034.521.00016.360_496_625_Roper Consumer Trends 2019\07 PAT\Procesate"
rem        cd /d z:
rem        cd India
rem        jpg.bat > ..\rename_India.txt

set temp_folder=C:\zzz_scripts
set listFiles=%temp_folder%\photosTemp.txt
set tempFile=tmpConv.jpg

set utils_path=C:\zzz_scripts\utils
set irfan="C:\Program Files\IrfanView\i_view64.exe"

::change the console encoding to UTF-8 (in order to support "strange" chars)
chcp 65001

dir /b /s /A-D * | sort > %listFiles%
::forfiles /s /m * /c "cmd /c if @isdir==FALSE echo @relpath" | sort > %listFiles%

for /f  "eol=; delims=;" %%i in (%listFiles%) do (
    set photoFormat=0
    set doConvert=0
    set doRename=0
    set file_full_current="%%i"
    for %%K in (!file_full_current!) do set file_extension=%%~xK
    for %%K in (!file_full_current!) do set file_name=%%~nK
    for %%K in (!file_full_current!) do set file_path=%%~pK
    for %%K in (!file_full_current!) do set file_drive=%%~dK

    pushd

    cd /d !file_drive!!file_path!

    for /f "tokens=1" %%a in (
        '%utils_path%\MediaInfo.exe "!file_name!!file_extension!" ^| %utils_path%\grep -m1 -E "Format *:" ^| %utils_path%\sed "s/Format *: //"'
    ) do (
        set photoFormat=%%a
    )

    rem echo !photoFormat!   "!file_drive!!file_path!!file_name!!file_extension!"
    if .!photoFormat!. == .PNG.  set doConvert=1
    if .!photoFormat!. == .GIF.  set doConvert=1
    
    if .!photoFormat!. == .JPEG. (
        if -!file_extension!- NEQ -.jpg- (
            set doRename=1
        )
    )

    if .!doConvert!. == .1. (
        echo !photoFormat!   !file_extension! to jpg   "!file_drive!!file_path!!file_name!!file_extension!"
        %irfan% "!file_name!!file_extension!"  /jpgq=95 /convert=!tempFile!
        if %ERRORLEVEL% equ 0 (
            del "!file_name!!file_extension!"
            move "!tempFile!"  "!file_name!.jpg"  1>&0 2>&0
        ) else (
            del "!tempFile!"
        )
    )

    if .!doRename!. == .1. (
        echo !photoFormat!   !file_extension! to jpg   "!file_drive!!file_path!!file_name!!file_extension!"
        move "!file_name!!file_extension!" "!file_name!.jpg"  1>&0 2>&0
    )
    popd
)

endlocal

