# A Third Mario Thing

## Getting Started

Patch my_hack.bps (using Flips or an online patcher for example) to smw rom and make sure the output rom's name is my_hack.smc.

## Custom Graphics

For vanilla (tile and sprite) graphics click purple (middle) poison mushroom and choose appropiate tilesets.
For custom graphics click on the red poison mushroom (on the left) on the toolbar. Notice that the slots are already filled based on the chosen vanilla tilesets. Choose an appropiate slot (based on the graphics indices of the Map16 tiles you are using, some of the slots may be in the spreadsheet) and choose the appropiate graphics number (as indicated in the spreadsheet).

## ON/OFF Blocks & Animating Tiles

Be sure that AN2 slot is filled with gfx file 81 (or other valid animation file). Then you can copy the animations from an another level that has them properly set up. Switch to than level then click on the SMB3 brick on the toolbar and either click "Copy All Slots" or click "Copy Slots" on a slot which are you interested in, then switch back to your level and click "Paste (All) Slots".

## Migrating to a new ROM (automatic way - Lunar Monitor and Lunar Helper)

Lunar Monitor let's you export resources automatically upon saving. It's useful so they can be quickly inserted with Lunar Helper.
To install Lunar Monitor, run lunar-monitor-injector.exe once. It should now be there everytime you open Lunar Magic, but you have to have lunar-monitor.dll in the same directory as Lunar Magic.

Make sure the paths to the ROM and Lunar Magic match the ones in config_project.txt in the Lunar Monitor folder.

To migrate to a new ROM, grab your levels from "Levels" directory and your resources from "resource" directory and move them to the new folders.

## Migrating to a new ROM (manual way)

(Not all steps may be needed)
1. First export all the resources:
- Save your level and your sublevels to files (File->Save Level to File) then drop the files to the new Levels directory
- Save your Map16 page(s) by selecting your page and clicking on a yellow question block with green arrow pointing to the right in the 16x16 Tile Map Editor dialog. Drop the file to the new resource directory.
- If you edited custom graphics using built-in Lunar Magic editor then click on the blue mushroom (Quick Extract ExGFX from ROM)
- Don't forget other resources like custom music and uberasm.

2. Then import them to the new ROM:
- Use File->Levels->Import Multiple Levels from Files...
- In Map16 dialog click on the yellow question block with red arrow pointing to the left.
- Click on the yellow mushroom (Quick Insert ExGFX to ROM)
- Insert other resources using appropriate tools.
