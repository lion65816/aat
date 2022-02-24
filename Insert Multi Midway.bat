@echo off

copy "my_hack.smc" "patch\"
cd patch

asar multi_midway_1.7.asm my_hack.smc
pause