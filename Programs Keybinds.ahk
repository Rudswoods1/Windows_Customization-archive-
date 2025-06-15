DesktopCount := 4  ; 
CurrentDesktop := 1  ; 

#IfWinActive
^!n::  ; Ctrl+Alt+N - для следующего трека
Send {Media_Next}
return

; === 0. Открытие Task Manager (Win + T)
#t::Run cmd

; === 0. Открытие Task Manager (Ctrl + Win + Delete)
^#Delete:: Run taskmgr
return

; === 1. Открытие Chrome (Win + F)
#f::Run chrome.exe

; === 2. Открытие Spotify (Win + S)
#s::Run "C:\Users\nurbolik\AppData\Roaming\Spotify\Spotify.exe"

; === 3. Открытие Telegram (Win + G)
#g::Run "C:\Users\nurbolik\AppData\Roaming\Telegram Desktop\Telegram.exe"

; === 4. Виртуальные рабочие столы (Ctrl + Win + стрелки)
^#Right::Send ^#{Right}
^#Left::Send ^#{Left}

; === Создание нового рабочего стола (Win + Ctrl + D)
^#d::Send ^#d  ; Эмулируем нажатие Ctrl + Win + D для создания нового рабочего стола
return

^#F::
    Send ^#{F4} ; Стандартная комбинация для удаления текущего рабочего стола (Win+Ctrl+F4)
return

; === 5. Закрытие активного окна (Win + Q)
#q::WinClose, A

; === 6. Тёплый экран (Shift + F1)
+F1::Run ms-settings:nightlight  ; открывает настройки ночного режима
return

; === 7. Открытие VS Code (Win + V)
#v::Run "C:\Users\nurbolik\AppData\Local\Programs\Microsoft VS Code\Code.exe"

; === 8. Открытие блокнота (Win + N)
#n::Run notepad.exe



; === 9. Завершение работы (Ctrl + Alt + Insert)
^!Insert::
    MsgBox, 4,, Вы уверены, что хотите завершить работу?
    IfMsgBox Yes
    {
        Run, *RunAs shutdown.exe /s /t 0
    }
    ; If "No" — ничего не делаем
return

; === 10. Перезагрузка системы (Ctrl + Alt + PrintScreen) 
^!PrintScreen::  ; Ctrl + Alt + PrintScreen
    MsgBox, 4,, Вы действительно хотите перезагрузить компьютер?
    IfMsgBox, Yes
    {
        Run, *RunAs shutdown.exe /r /f /t 0
    }
    ; If "No" — ничего не делаем
return



; === 11. Перемещение окна через воркспейсы(Ctrl + Win + Alt + Left&Right)
^#!Right:: ; Ctrl + Win + Alt + Right
MoveWindowToDesktop("right")
return

^#!Left:: ; Ctrl + Win + Alt + Left
MoveWindowToDesktop("left")
return

MoveWindowToDesktop(direction) {
    ; Запускаем VirtualDesktopAccessor через DLL (нужна предварительно)
    ; Проверка на наличие dll
    dll := A_ScriptDir . "\VirtualDesktopAccessor.dll"
    if (!FileExist(dll)) {
        MsgBox, 48, Ошибка, Файл VirtualDesktopAccessor.dll не найден в папке скрипта.`nСкачай его отсюда:`nhttps://github.com/Ciantic/VirtualDesktopAccessor/releases
        return
    }

    ; Загружаем функции
    if (!hMod := DllCall("LoadLibrary", "Str", dll, "Ptr")) {
        MsgBox, 48, Ошибка, Не удалось загрузить VirtualDesktopAccessor.dll
        return
    }

    hwnd := WinExist("A")
    if (hwnd) {
        current := DllCall(dll . "\GetCurrentDesktopNumber", "Int")
        count := DllCall(dll . "\GetDesktopCount", "Int")
        
        target := (direction = "right") ? current + 1 : current - 1
        if (target < 0 || target >= count) {
            SoundBeep
            return
        }

        ; Переместить окно на нужный рабочий стол
        DllCall(dll . "\MoveWindowToDesktopNumber", "Ptr", hwnd, "Int", target)
        ; Переключиться на целевой рабочий стол
        DllCall(dll . "\GoToDesktopNumber", "Int", target)
    }
}


; === 12. Увеличение или уменьшение окна (Win + W)
#w::
    WinGet, windowState, MinMax, A  ; Получить состояние активного окна
    if (windowState = 1) {
        WinRestore, A  ; Если окно развернуто, восстановить
    } else {
        WinMaximize, A  ; Иначе — развернуть на весь экран
    }
return

#NoEnv  ; Рекомендация для производительности
SendMode Input
SetBatchLines -1
OnExit, Cleanup

; === Параметры сетки ===
columns := 3        ; число столбцов
rows    := 2        ; число строк
gapX    := 10       ; горизонтальный отступ между окнами
gapY    := 10       ; вертикальный отступ между окнами

; Индекс следующей зоны (0..columns*rows-1)
nextZone := 0

; Регистрация на события создания окон
DllCall("RegisterShellHookWindow", "Ptr", WinExist("A"))
msgID := DllCall("RegisterWindowMessage", "Str", "SHELLHOOK")
OnMessage(msgID := msgID+0, "ShellHookProc")

return

ShellHookProc(wParam, lParam) {
    static HSHELL_WINDOWCREATED := 1
    if (wParam = HSHELL_WINDOWCREATED) {
        TileWindow(lParam)
    }
}

TileWindow(hWnd) {
    global columns, rows, gapX, gapY, nextZone
    ; Игнорируем скрытые или невалидные окна
    WinGet, style, Style, ahk_id %hWnd%
    if (style & 0x10000000 = 0) ; WS_VISIBLE
        return

    ; Вычисляем размеры
    screenW := A_ScreenWidth // columns
    screenH := A_ScreenHeight // rows
    col := Mod(nextZone, columns)
    row := nextZone // columns

    x := col * screenW + gapX
    y := row * screenH + gapY
    w := screenW - 2*gapX
    h := screenH - 2*gapY

    WinMove, ahk_id %hWnd%, , x, y, w, h  ; Перемещение и ресайз :contentReference[oaicite:4]{index=4}
    nextZone := Mod(nextZone + 1, columns * rows)
}

Cleanup:
    ExitApp



; === 13. Увеличение или уменьшение размера окна (Win + X + left/right)
~x & Left::
    WinGetPos, X, Y, W, H, A
    W := W - 50
    WinMove, A, , X, Y, W, H
return

~x & Right::
    WinGetPos, X, Y, W, H, A
    W := W + 50
    WinMove, A, , X, Y, W, H
return

~x & Up::
    WinGetPos, X, Y, W, H, A
    H := H - 50
    WinMove, A, , X, Y, W, H
return

~x & Down::
    WinGetPos, X, Y, W, H, A
    H := H + 50
    WinMove, A, , X, Y, W, H
return



; === 14. Смена фокуса и курсора между окнами (Win + X + left/right)

#NoEnv
#SingleInstance Force
SetBatchLines -1

#+Left:: 
    direction = Left
    Gosub, MoveCursorToWindow
return

#+Right:: 
    direction = Right
    Gosub, MoveCursorToWindow
return

#+Up:: 
    direction = Up
    Gosub, MoveCursorToWindow
return

#+Down:: 
    direction = Down
    Gosub, MoveCursorToWindow
return

MoveCursorToWindow:
    WinGet, CurrentWindow, ID, A
    if not CurrentWindow
        return

    WinGetPos, currX, currY, currW, currH, ahk_id %CurrentWindow%
    if (currX = "" or currY = "" or currW = "" or currH = "")
        return

    currCenterX := currX + (currW // 2)
    currCenterY := currY + (currH // 2)

    closestWindow = 0
    minDistance = 999999
    targetX = targetY = targetW = targetH = 0

    WinGet, WindowList, List
    Loop, %WindowList% {
        WindowID := WindowList%A_Index%
        if (WindowID = CurrentWindow)
            continue

        WinGetTitle, title, ahk_id %WindowID%
        if (title = "")
            continue
            
        WinGet, style, Style, ahk_id %WindowID%
        if ((style & 0xC00000) = 0)
            continue
            
        if not DllCall("IsWindowVisible", "UInt", WindowID)
            continue
            
        if DllCall("IsIconic", "UInt", WindowID)
            continue

        WinGetPos, X, Y, W, H, ahk_id %WindowID%
        if (X = "" or Y = "" or W = "" or H = "")
            continue

        centerX := X + (W // 2)
        centerY := Y + (H // 2)

        ; Обновленные условия для направления Влево
        if (direction = "Left") {
            if (centerX >= currCenterX)
                continue
            deltaX := currCenterX - centerX
            deltaY := Abs(currCenterY - centerY)
            distance := deltaX + deltaY * 0.3
        }
        else if (direction = "Right") {
            if (centerX <= currCenterX)
                continue
            deltaX := centerX - currCenterX
            deltaY := Abs(currCenterY - centerY)
            distance := deltaX + deltaY * 0.3
        }
        else if (direction = "Up") {
            if (centerY >= currCenterY)
                continue
            deltaY := currCenterY - centerY
            deltaX := Abs(currCenterX - centerX)
            distance := deltaY + deltaX * 0.3
        }
        else if (direction = "Down") {
            if (centerY <= currCenterY)
                continue
            deltaY := centerY - currCenterY
            deltaX := Abs(currCenterX - centerX)
            distance := deltaY + deltaX * 0.3
        }

        if (distance < minDistance) {
            minDistance := distance
            closestWindow := WindowID
            targetX := X
            targetY := Y
            targetW := W
            targetH := H
        }
    }

    if closestWindow {
        MouseMove, % targetX + (targetW // 2), % targetY + (targetH // 2), 0
        WinActivate, ahk_id %closestWindow%
    }
return


; === 15. Перемещение через рабочие столы (Win + 1,2,3(etc))
