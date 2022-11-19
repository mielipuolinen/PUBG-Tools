:: ExecPubg.exe
:: TslGame.exe
:: TslGame_BE.exe
:: TslGame_UC.exe
:: zksvc.exe
@ECHO OFF
setlocal enabledelayedexpansion 
set proc[0]=ExecPubg.exe
set proc[1]=TslGame.exe
set proc[2]=TslGame_BE.exe
set proc[3]=TslGame_UC.exe
set proc[4]=zksvc.exe

echo "Killing PUBG processes"

for /l %%n in (0,1,4) do ( 
   taskkill /F /IM !proc[%%n]!
)
echo "Done"
