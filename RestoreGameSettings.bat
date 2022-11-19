::Retrieves PUBG settings from "cloud" after PUBG things happen
@echo off

IF EXIST "C:\temp\PUBG\backup" echo F|XCOPY /s/v/y "C:\temp\PUBG\backup\GameUserSettings.ini" "C:\Users\%username%\AppData\Local\TslGame\Saved\Config\WindowsNoEditor\GameUserSettings.ini"
