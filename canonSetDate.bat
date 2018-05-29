:: schimba "created date" a tuturor fisiereor *.avi
:: cu data continuta in cale D:\canon\2010_06_29 ....
:: Obs: obligatoriu dupa ziua continta in numele de folder trebuie sa fie unul dintre delimitatorii: \_( sau "spatiu"

::@echo off
SETLOCAL

::set path=%~d0%~p0;%path%
set tempFile=c:\canonTemp.txt

dir /b /s *.avi  > %tempFile%

:: calea parsata e de tipul
:: D:\canon\2010_06_29 (zambete - 5,2 kg)
for /f "eol=; delims=;" %%k in (%tempFile%) do (
  for /f "Tokens=3-5 delims=\_( " %%a in ("%%k") do (
    nircmdc.exe setfiletime "%%k" "%%c-%%b-%%a" "%%c-%%b-%%a"
	)
  )

del %tempFile%

ENDLOCAL
