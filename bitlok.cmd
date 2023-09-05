@echo off
setlocal EnableDelayedExpansion

:loop
set "key="
set "digits=0123456789"

REM Generate a random 48-digit key with dashes
for /L %%N in (1,1,8) do (
    set "group="
    for /L %%M in (1,1,6) do (
        set /A "index=!random! %% 10"
        for /L %%K in (!index!,1,!index!) do set "group=!group!!digits:~%%K,1!"
    )
    set "key=!key!!group!-"
)

REM Remove the trailing dash
set "key=!key:~0,-1!"

REM Output the generated key
echo Trying key: !key!

REM Check if the "h" key is pressed to exit
>nul choice /C h /N

goto :eof
