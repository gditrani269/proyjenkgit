echo off
setlocal EnableDelayedExpansion
set sal=0
for /f "tokens=*" %%i in (l.txt) do (

	set sTer=%%i
rem 	echo !sTer!
	for /f "tokens=1" %%j in ("!sTer!") do (
	
		if %%j == 5662 (
			set sal=1
		)
		
		if !sal! == 1 (
			echo %%i
			if %%j == ------------------------------------------------------------------------ (
				set sal=0
			)
		)
	)
)
	
goto :fin


:fin
