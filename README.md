# And Another Thing

## Getting Started

Extract Lunar Magic from lm331.zip into lm331 directory (so it can be used with [Lunar Monitor](#export-resources-lunar-monitor) and [Lunar Helper](#import-resources-lunar-helper)).
**Type in the path to the main project directory in `lunar-helper\config_user.txt`** as follows `dir = C:\path\to\aat (see `example_config_user.txt`).
Run Lunar Helper and choose "Build". Alternatively, patch `my_hack_bps.bps` (using Flips or an online patcher for example) to a clean smw rom and make sure the output rom's name is `my_hack.smc` and is in the main project directory.
For more info on hacking SMW, check the readmes of the tools as well as Lunar Magic's help file for more details.

## Custom Graphics

For vanilla (tile and sprite) graphics click purple (middle) poison mushroom and choose appropiate tilesets.
For custom graphics click on the red poison mushroom (on the left) on the toolbar. Notice that the slots are already filled based on the chosen vanilla tilesets. Choose an appropiate slot (based on the graphics indices of the Map16 tiles you are using, some of the slots may be in the spreadsheet) and choose the appropiate graphics number (as indicated in the spreadsheet).

## Custom Sprites

The custom sprites should appear in sprite list (baby yoshi icon on the toolbar). Most of them are presented as an 'X' because making them display properly in Lunar Magic is a lot of work. Some sprites may use extra bit/extra bytes (refer to the top of appropiate sprite .asm file), alt-right click them to change those.

## Level Setup (Graphics & Palette)
- Choose any vanilla level (or sample level of custom graphics) as a base.
- Import the palette global.pal that comes with the baserom. Most vanilla sprites and blocks, including custom blocks on map16 page 2, will have correct palettes. Custom foreground and background graphics may use the first halves of palette rows 0-3. Using more palette space may make certain blocks have wrong palettes, so pay attention to that.
- Use ExGFX81 in the AN2 slot for working animations for the blocks on map16 page 2 like bricks, conveyors, etc. You can copy the ex-animation from level 105. Switch to that level then click on the SMB3 brick on the toolbar and either click "Copy All Slots" or click "Copy Slots" on a slot which are you interested in, then switch back to your level and click "Paste (All) Slots".
- Use ExGFX100 in the SP2 slot for working graphics of donut blocks.
- Vanilla big bushes can only be used with ExGFX.

## Updating to a new base ROM

The following steps assume you have downloaded the new base ROM in a separate directory and you are to copy your resources to it. If you want to use git, see section [Using git](#using-git) first.

### Automatic way (Lunar Monitor and Lunar Helper)

#### Export resources (Lunar Monitor)

Lunar Monitor lets you export resources automatically upon saving.
To inject Lunar Magic with Lunar Monitor, simply move Lunar Magic to the lm331 directory (where lunar-monitor.dll, lunar-monitor-injector.exe and usertoolbar.txt are located - they have to be in the same directory).

#### Import resources (Lunar Helper)

- Grab your levels from "Levels" directory and your resources from "resource" directory and copy them to the folders in the new root directory.
- Don't forget other resources like custom music and uberasm.
- Run Lunar Helper and select Build.

### Manual way

Note: not all steps may be needed.

#### Export resources

- Save your level and your sublevels to files (File->Save Level to File) then copy the files to the "Levels" directory in the new base ROM directory.
- Save your Map16 page(s) by selecting your page and clicking on a yellow question block with green arrow pointing to the right in the 16x16 Tile Map Editor dialog. Drop the file to the new "resource" directory.
- If you edited custom graphics using built-in Lunar Magic editor then click on the blue mushroom (Quick Extract ExGFX from ROM)
- Don't forget other resources like custom music and uberasm.

#### Import resources

- Use File->Levels->Import Multiple Levels from Files...
- In Map16 dialog click on the yellow question block with red arrow pointing to the left.
- Click on the yellow mushroom (Quick Insert ExGFX to ROM)
- Insert other resources using appropriate tools.

### Using git

Export your resources as outlined above, stage ("git add") and commit them ("git commit"). Then pull the newest resources ("git pull"). If there are conflicts you must resolve them before commiting them. Next, [import everything to the rom, preferably using Lunar Helper](#import-resources-lunar-helper).

## Adding new assets

To add new blocks, sprites, music or graphics, first make sure they are available in the spreadsheet:
https://docs.google.com/spreadsheets/d/1YrcuZg9DnHJWshEXCZL-O_vlvc7Sl_WYvWqbp_Cyxcw/edit#gid=0

If they are, add them to the list along with the hexadecimal slot you want them to fit under.

You can get new sprites, blocks, graphics, music and UberASM from SMWCentral (https://www.smwcentral.net/).
Simply browse ones from the pages on the side bar, and download them to their respective folder.

For everything but graphics, you must add them in their respective list.txt as well.

For example:

`30 [title].txt`
For a song.

`4D [title].cfg`
or `4D [title].json`
For sprites.

And
`[Map16 block number]:[Number of Page 0 and Page 1 block you wish to make it act like] [block].asm`
For blocks.

Graphics files merely have to be named
`ExGFX[hexadecimal number].bin`

For UberASM simply add your level or sublevel ID and the asm file of the UberASM you want to use.
Please don't use overworld, or gamemode ASM.

They can all be inserted by simply building or packaging your hack in Lunar Helper.
