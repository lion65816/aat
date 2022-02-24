@echo off

copy "my_hack.smc" "patch\"
cd patch

asar ExtendedLevelNames.asm my_hack.smc
pause