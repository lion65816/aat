### Lunar Helper v1.0.0-LMC + Lunar Monitor v0.3.1 Bundle ###

This zip archive is a bundle of two tools, Lunar Helper (originally created by 
Maddy Thorson, slightly altered by me (underway)) and Lunar Monitor (mostly 
written by me, logging functionality added by Atari2.0), which together allow 
you to very easily extract resources from your ROM while you edit it in Lunar 
Magic and to then rebuild your ROM from these extracted resources.

Each tool has its own directory in this archive, as well as its own included 
readme for its setup. 

I would recommend you start by setting up the included version of Lunar Helper, 
which is very slightly different from the standard version, and to then set up 
Lunar Monitor. Afterwards, please return to this readme for final instructions.

The source code for both tools is publicly available at links included in their 
respective readme files.

Feel free to now switch over to the readmes of the tools and to then come back!


## After Lunar Helper and Lunar Monitor Setup ## 

What you should do after setting the two tools up depends on whether you're 
moving an existing hack to this system or starting from scratch.


# Starting a new project

If you're starting a new project, place a clean ROM at the path you specified 
in Lunar Helper's "output" configuration variable. Place a lunar-monitor-config.txt
file in the same folder as this "output" ROM as described in Lunar Monitor's readme.
Now open this ROM in Lunar Magic (make sure it's the one you set Lunar Monitor up on!)
and:

- save a level once
- save map16 once
- save shared palettes once
- save the overworld, title screen or credits once
- export (Ex)GFX once
- manually export the title moves file using the overworld editor if you are 
  using Lunar Helper's title_moves configuration variable

(just make an insignificant change so you can save, i.e. move a tile somewhere and then
back, open the color dialog in the palette editor and click OK, etc.)

If Lunar Monitor is set up correctly, saving each of these once should export files to 
the specified locations. If there are no levels in your level_directory, no map16 file at 
your map16_path, no pal file at your shared_palettes_path or no bps patch at your 
global_data_path, check Lunar Monitor's log file to make sure it's set up correctly!


# Moving an existing project

If you are moving an existing project, simply place your ROM at the location specified in 
Lunar Helper's "output" configuration variable. Place a lunar-monitor-config.txt
file in the same folder as this "output" ROM as described in Lunar Monitor's readme.
Now open this ROM in Lunar Magic (make sure it's the one you set Lunar Monitor up on!)
and:

- export all (modified) levels to your level_directory
- save map16 once
- save shared palettes once
- save the overworld, title screen or credits once
- export (Ex)GFX once
- manually export the title moves file using the overworld editor if you are 
  using Lunar Helper's title_moves configuration variable

(just make an insignificant change so you can save, i.e. open the color dialog in the 
palette editor and click OK, move tiles on the overworld somewhere and move them back etc.)

If Lunar Monitor is set up correctly, saving each of these once should export files to 
the specified locations. If there are no levels in your level_directory, no map16 file at 
your map16_path, no pal file at your shared_palettes_path or no bps patch at your 
global_data_path, check Lunar Monitor's log file to make sure it's set up correctly!


## (Finally) building your ROM ##

At this point, you should be able to rebuild your ROM from the extracted resources.

Please keep a backup of your existing project's ROM before trying this, if you're 
moving an existing project, just to make sure. 

You should be able to delete the "output" ROM and then create an exact copy of it 
by using Lunar Helper's Build function from its menu!
