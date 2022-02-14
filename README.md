-- Getting Started --

Patch my_hack.bps (using Flips or an online patcher for example) to smw rom and make sure the output rom's name is my_hack.smc.
For more info on hacking Mario, check the readmes of the tools as well as Lunar Magic's help file for more details.

-- Custom Graphics --

For vanilla (tile and sprite) graphics click purple (middle) poison mushroom and choose appropiate tilesets.
For custom graphics click on the red poison mushroom (on the left) on the toolbar. Notice that the slots are already filled based on the chosen vanilla tilesets. Choose an appropiate slot (based on the graphics indices of the Map16 tiles you are using, some of the slots may be in the spreadsheet) and choose the appropiate graphics number (as indicated in the spreadsheet).

-- Custom Sprites (for now) --
With the Yoshi button pressed, press insert and choose a sprite to insert from the sprite folder's list.txt.
I will include jsons that allow to more easily place sprites in SMW so please rest assured.

-- ON/OFF Blocks & Animating Tiles --

Be sure that AN2 slot is filled with gfx file 81 (or other valid animation file). Then you can copy the animations from an another level that has them properly set up. Switch to than level then click on the SMB3 brick on the toolbar and either click "Copy All Slots" or click "Copy Slots" on a slot which are you interested in, then switch back to your level and click "Paste (All) Slots".


-- Migrating to a new ROM (automatic way - Lunar Monitor and Lunar Helper) --

Lunar Monitor let's you export resources automatically upon saving. It's useful so they can be quickly inserted with Lunar Helper.
To install Lunar Monitor, run lunar-monitor-injector.exe once. It should now be there everytime you open Lunar Magic, but you have to have lunar-monitor.dll in the same directory as Lunar Magic.
To migrate to a new ROM, grab your levels from "Levels" directory and your resources from "resource" directory and move them to the new folders.
Note that the all.map16 file may conflict, though that's being worked on. For a workaround, export and import your Map16 pages using the method outlined in the next section.

-- Migrating to a new ROM (manual way) --

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

-- Adding new assets --

To add new blocks, sprites, music or graphics, first make sure they are available in the spreadsheet:
https://docs.google.com/spreadsheets/d/1YrcuZg9DnHJWshEXCZL-O_vlvc7Sl_WYvWqbp_Cyxcw/edit#gid=0

If they are, add them to the list along with the hexadecimal slot you want them to fit under.

You can get new sprites, blocks, graphics, music and UberASM from SMWCentral (https://www.smwcentral.net/).
Simply browse ones from the pages on the side bar, and download them to their respective folder.

For everything but graphics, you must add them in their respective list.txt as well.

For example:

30 [title].txt
For a song.

4D [title].cfg
or 4D [title].json
For sprites.

And
[Map16 block number]:[Number of Page 0 and Page 1 block you wish to make it act like] [block].asm
For blocks.

Graphics files merely have to be named
ExGFX[hexadecimal number].bin

For UberASM simply add your level or sublevel ID and the asm file of the UberASM you want to use.
Please don't use overworld, or gamemode ASM.

They can all be inserted by simply building or packaging your hack in Lunar Helper.
