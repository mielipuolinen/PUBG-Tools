@echo off

set path="C:\Program Files (x86)\Steam\steamapps\common\PUBG\TslGame\Content\Movies\"

IF EXIST %path%LicenseScreen.mp4 DEL /F %path%LicenseScreen.mp4
IF EXIST %path%LoadingScreen.mp4 DEL /F %path%LoadingScreen.mp4
