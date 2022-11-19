::Saves PUBG settings to separate folder, "cloud", in case (when) PUBG things happen
@echo off

IF NOT EXIST "C:\temp\PUBG\backup\" MKDIR "C:\temp\PUBG\backup\"

echo F|XCOPY /s/v/y "C:\Users\%username%\AppData\Local\TslGame\Saved\Config\WindowsNoEditor\GameUserSettings.ini" "C:\temp\PUBG\backup\GameUserSettings.ini"
