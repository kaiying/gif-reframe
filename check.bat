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
echo 檢查 out 資料夾中的 GIF 是否為 !target_frames! 幀...
echo.

set "total=0"
set "correct=0"
set "incorrect=0"

if not exist out (
    echo 錯誤: out 資料夾不存在！
    pause
    exit /b
)

for %%f in (out\*.gif) do (
    set /a total+=1
    
    rem 取得幀數
    for /f "usebackq delims=" %%c in (`ffprobe -v error -select_streams v:0 -count_frames -show_entries stream^=nb_read_frames -of default^=nokey^=1:noprint_wrappers^=1 "%%f"`) do (
        set "frames=%%c"
    )
    
    if "!frames!"=="!target_frames!" (
        set /a correct+=1
        echo [OK] %%~nxf - !frames! 幀
    ) else (
        set /a incorrect+=1
        echo [NG] %%~nxf - !frames! 幀 ^(應該是 !target_frames! 幀^)
    )
)

echo.
echo ======================================
echo 總共檢查: !total! 個檔案
echo 正確(!target_frames!幀): !correct! 個
echo 不正確: !incorrect! 個
echo ======================================
echo.

if !incorrect! gtr 0 (
    echo 警告: 有 !incorrect! 個檔案不是 !target_frames! 幀！
) else (
    if !total! gtr 0 (
        echo 所有檔案都是 !target_frames! 幀！
    ) else (
        echo out 資料夾中沒有 GIF 檔案。
    )
)

pause