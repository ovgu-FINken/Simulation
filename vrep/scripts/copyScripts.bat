cd /d %~dp0
@REM %~dp0
@REM %cd%

xcopy  "*.lua" "C:\Program Files (x86)\V-REP3\V-REP_PRO_EDU\lua\"

@REM mklink /H "C:\Program Files (x86)\V-REP3\V-REP_PRO_EDU\lua\finken.lua" "finken.lua"
@REM mklink /H "C:\Program Files (x86)\V-REP3\V-REP_PRO_EDU\lua\finkenPid.lua" "finkenPid.lua"
@REM mklink /H "C:\Program Files (x86)\V-REP3\V-REP_PRO_EDU\lua\finkenCore.lua" "finkenCore.lua"
@REM mklink /H "C:\Program Files (x86)\V-REP3\V-REP_PRO_EDU\lua\finkenMeta.lua" "finkenMeta.lua"
REM "your scripts were linked to $1"
