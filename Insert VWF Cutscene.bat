@echo off

pushd vwf_tool
python vwftool.py def.txt list.txt vwf_data.asm
python vwftool.py def.txt list2.txt vwf_data2.asm
move vwf_data* ..\sprite\sprites\vwf
popd
"Insert Sprite.bat"
pause