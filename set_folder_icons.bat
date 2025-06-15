@echo off
setlocal EnableDelayedExpansion

:: === Шаблон desktop.ini ===
set "TEMPLATE=[.ShellClassInfo]"
set "TEMPLATE2=IconResource="
set "TEMPLATE3=[ViewState]"
set "TEMPLATE4=Mode="
set "TEMPLATE5=Vid="
set "TEMPLATE6=FolderType=Generic"

:: === Список папок и иконок ===
set folders[0]=C:\MY_EGGFILES
set icons[0]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\user.ico

set folders[1]=C:\Program Files\ShareX\ShareX\Screenshots
set icons[1]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\quick access.ico

set folders[2]=C:\MY_EGGFILES\PROGRAMMING
set icons[2]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\control panel.ico

set folders[3]=C:\MY_EGGFILES\IMAGES
set icons[3]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\pictures.ico

set folders[4]=C:\MY_EGGFILES\FILES
set icons[4]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\libraries.ico

set folders[5]=C:\MY_EGGFILES\DOCUMENTS
set icons[5]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\docs.ico

set folders[6]=C:\MY_EGGFILES\Music
set icons[6]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\docs.ico

set folders[7]=C:\MY_EGGFILES\VIDEO
set icons[7]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\videos.ico

set folders[8]=C:\MY_EGGFILES\Programs
set icons[8]=C:\MY_EGGFILES\IMAGES\Icons\matte_Icons\pc.ico

:: === Обработка всех папок ===
for /L %%i in (0,1,8) do (
    set "folder=!folders[%%i]!"
    set "icon=!icons[%%i]!"

    echo Обработка: !folder!

    if exist "!folder!" (
        (
            echo !TEMPLATE!
            echo !TEMPLATE2!!icon!,0
            echo !TEMPLATE3!
            echo !TEMPLATE4!
            echo !TEMPLATE5!
            echo !TEMPLATE6!
        ) > "!folder!\desktop.ini"

        attrib +s "!folder!"
        attrib +h "!folder!\desktop.ini"
    ) else (
        echo ❌ Папка не найдена: !folder!
    )
)

:: === Перезапуск проводника для применения иконок ===
echo Перезапускаем проводник...
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
echo ✅ Готово.
pause
