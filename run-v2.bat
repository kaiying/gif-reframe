@echo off
setlocal enabledelayedexpansion

rem 讀取設定檔
set "config_file=config.json"
set "target_frames=20"

if exist "%config_file%" (
    for /f "usebackq tokens=2 delims=: " %%a in (`findstr /i "frame" "%config_file%"`) do (
        set "temp=%%a"
        rem 移除逗號和空格
        set "temp=!temp:,=!"
        set "temp=!temp: =!"
        set "target_frames=!temp!"
    )
    echo 從 %config_file% 讀取設定: 目標幀數 = !target_frames!
) else (
    echo 找不到 %config_file%，使用預設值: !target_frames! 幀
)

echo.

if not exist out mkdir out

for %%f in (*.gif) do (
    echo Processing: %%f
    
    rem 取得時長
    for /f "usebackq delims=" %%d in (`ffprobe -v error -show_entries format^=duration -of default^=noprint_wrappers^=1:nokey^=1 "%%f"`) do (
        set "duration=%%d"
    )
    
    set "pal=out\palette_%%~nf.png"
    echo Duration: !duration! seconds, Target: !target_frames! frames
    
    rem 生成調色盤
    ffmpeg -v error -y -i "%%f" -vf "fps=!target_frames!/!duration!,palettegen=reserve_transparent=1" "!pal!"
    
    rem 套用調色盤輸出
    ffmpeg -v error -y -i "%%f" -i "!pal!" -lavfi "fps=!target_frames!/!duration! [x]; [x][1:v] paletteuse=dither=sierra2_4a" "out\%%~nf_!target_frames!f.gif"
    
    rem 刪除臨時調色盤
    if exist "!pal!" del "!pal!" >nul 2>&1
)

echo.
echo Done (HQ). 檔案已輸出到 out\ (每個 !target_frames! 幀)
pause