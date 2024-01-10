@echo off

pushd vwf_tool
python vwftool.py def.txt list.txt vwf_data.asm
move vwf_data* ..\sprite\sprites\vwf
popd
"Insert Sprite.bat"
pause