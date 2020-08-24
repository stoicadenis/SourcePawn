@Echo Off
:Start
If [%1==[ GoTo :EOF
PushD %~pd1
"C:\Program Files\7-Zip\7z.exe" u -tbzip2 -mpass=10 -mx=9 -mmt=3 %~nx1.bz2 %1
Shift
PopD
GoTo Start
