# And Another Thing

## Getting Started

Extract Lunar Magic from lm331.zip and move the .exe and .chm into the root project directory.
Patch my_hack.bps (using Flips or an online patcher for example) to smw rom and make sure the output rom's name is my_hack.smc.
For more info on hacking Mario, check the readmes of the tools as well as Lunar Magic's help file for more details.

## Custom Graphics

For vanilla (tile and sprite) graphics click purple (middle) poison mushroom and choose appropiate tilesets.
For custom graphics click on the red poison mushroom (on the left) on the toolbar. Notice that the slots are already filled based on the chosen vanilla tilesets. Choose an appropiate slot (based on the graphics indices of the Map16 tiles you are using, some of the slots may be in the spreadsheet) and choose the appropiate graphics number (as indicated in the spreadsheet).

## Custom Sprites (for now)

With the Yoshi button pressed, press insert and choose a sprite to insert from the sprite folder's list.txt.
I will include jsons that allow to more easily place sprites in SMW so please rest assured.

## ON/OFF Blocks & Animating Tiles

Be sure that AN2 slot is filled with gfx file 81 (or other valid animation file). Then you can copy the animations from an another level that has them properly set up. Switch to than level then click on the SMB3 brick on the toolbar and either click "Copy All Slots" or click "Copy Slots" on a slot which are you interested in, then switch back to your level and click "Paste (All) Slots".

<<<<<<< HEAD
-- Migrating to a new ROM (automatic way - Lunar Monitor and Lunar Helper) --

Lunar Monitor let's you export resources automatically upon saving. It's useful so they can be quickly inserted with Lunar Helper.
To inject Lunar Magic with Lunar Monitor, have lunar-monitor.dll, lunar-monitor-injector.exe and usertoolbar.txt in the same directory as Lunar Magic.
To migrate to a new ROM, grab your levels from "Levels" directory and your resources from "resource" directory and move them to the new folders.
Note that the all.map16 file may conflict, though that's being worked on. For a workaround, export and import your Map16 pages using the method outlined in the next section.
=======
## Updating to a new base ROM

The following steps assume you have downloaded the new base ROM in a separate directory and you are to copy your resources to it. If you want to use git, see section [Using git](#using-git) first.

### Automatic way (Lunar Monitor and Lunar Helper)

#### Export resources (Lunar Monitor)

Lunar Monitor lets you export resources automatically upon saving.
To inject Lunar Magic with Lunar Monitor, simply move Lunar Magic to the root directory (where there are lunar-monitor.dll, lunar-monitor-injector.exe and usertoolbar.txt - they have to be in the same directory).

#### Import resources (Lunar Helper)

- Grab your levels from "Levels" directory and your resources from "resource" directory and copy them to the folders in the new root directory. (Note that the all.map16 file may conflict, though that's being worked on. For a workaround, export and import your Map16 pages using the method outlined in [the next section](#export-resources).)
- Don't forget other resources like custom music and uberasm.
- Run Lunar Helper and select Build.
>>>>>>> 125b233d74017196b6832c47255f015d6df154cd

### Manual way

<<<<<<< HEAD
(Not all steps may be needed)
1. First export all the resources:
- Save your level and your sublevels to files (File->Save Level to File) then drop the files to the new Levels directory
- Save your Map16 page(s) by selecting your page and clicking on a yellow question block with green arrow pointing to the right in the 16x16 Tile Map Editor dialog. Drop the file to the new resource directory.
- If you edited custom graphics using built-in Lunar Magic editor then click on the blue mushroom (Quick Extract ExGFX from ROM)
- Don't forget other resources like custom music and uberasm.

2. Then import them to the new ROM:
=======
Note: not all steps may be needed.

#### Export resources

- Save your level and your sublevels to files (File->Save Level to File) then copy the files to the "Levels" directory in the new base ROM directory.
- Save your Map16 page(s) by selecting your page and clicking on a yellow question block with green arrow pointing to the right in the 16x16 Tile Map Editor dialog. Drop the file to the new "resource" directory.
- If you edited custom graphics using built-in Lunar Magic editor then click on the blue mushroom (Quick Extract ExGFX from ROM)
- Don't forget other resources like custom music and uberasm.

#### Import resources

>>>>>>> 125b233d74017196b6832c47255f015d6df154cd
- Use File->Levels->Import Multiple Levels from Files...
- In Map16 dialog click on the yellow question block with red arrow pointing to the left.
- Click on the yellow mushroom (Quick Insert ExGFX to ROM)
- Insert other resources using appropriate tools.

<<<<<<< HEAD
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
=======
### Using git

Export your resources as outlined above, stage ("git add") and commit them ("git commit"). Then pull the newest resources ("git pull"). If there are conflicts you must resolve them before commiting them. Next, [import everything to the rom, preferably using Lunar Helper](#import-resources-lunar-helper).
>>>>>>> 125b233d74017196b6832c47255f015d6df154cd
