### Lunar Helper ###


## Introduction ##

Lunar Helper is a build system for SMW ROMs originally made by Maddy Thorson and 
slightly modified by me (underway). 

Step by step, what it does is 

- Taking a clean SMW ROM
- Applying an initial .bps patch to it (more on this later)
- Running GPS and PIXI on it
- Applying your patches to it
- Running UberASM Tool on it
- Running AddmusicK on it
- Inserting various SMW data (graphics, map16, overworld, title screen,  
  title screen moves etc.) into it
- Inserting level files into it

As you can see, it basically takes a bunch of resources stored as individual files 
(i.e. all of your blocks, sprites, patches, graphics, levels, etc.) and creates a 
single fully functional hacked ROM from them. 

Lunar Helper also offers convenient functionality for

- Opening the built ROM in Lunar Magic
- Running it inside an emulator of your choice


## Source code ##

The original source code by Maddy Thorson is available at:

    https://github.com/MaddyThorson/LunarHelper

The source for this version, which is only slightly altered to work as a 
single file executable and to remove the Save function, can be found here:

    https://github.com/Underrout/LunarHelper/tree/main


## Assumptions ##

The rest of this guide will assume you are already familiar with basic SMW hacking 
tools, such as Lunar Magic, FLIPS, GPS, PIXI, Asar, AddmusicK and UberASM Tool. 


## Setup ##

Lunar Helper setup is relatively straightforward provided you already have all the 
tools it relies on (FLIPS, GPS, PIXI, Asar, AddmusicK and UberASM Tool) set up. If 
you don't yet, please get those set up somewhere first!


### Extracting and checking files ###

Take the LunarHelper.exe, config_user.txt and config_project.txt files 
from this zip archive and extract them so some location on your computer. 

Let's look at these files in detail. 

As you might have guessed, LunarHelper.exe is the actual tool itself. You should 
be able to launch it simply by double-clicking it.

If a window launches containing the "Welcome to Lunar Helper ^_^" message, the tool 
is launching correctly!

Note that you will very likely get an error if you try any of the menu options 
except H or ESC at this point, since we have not yet configured the tool!

If you press H you will see what all of the other menu options do. I will thus not 
discuss them here, since they should be pretty self-explanatory.

Once you've made sure the tool has launched correctly, go ahead and close it 
for now.


### Configuration ###

We will now take care of actually configuring the tool so it can perform its tasks 
correctly by editing the two config files which should be in the same folder as the 
exe file.

Open up config_project.txt and config_user.txt, read through them and then 
come back.

As you should know now, config_*.txt files are used to tell the tool where it can 
find various tools and resources it will need to build your ROM. Being able to 
split the configuration into different files as we please can be useful if you are
working on a team project and want to separate individual user settings from the 
project's settings!

Generally I would recommend sticking with separating the configuration into two 
files just like the provided config files.

Note that all paths you specify inside configuration files are relative to a "dir" 
path which by default is specified inside config_user.txt. You should change this 
path to the absolute path to your project folder on your PC before following the 
rest of this configuration guide. For example, if my hack were in a folder called 
"hack" and I'd stored it in my documents folder I would change 

    dir = C:/Users/user/Documents/my_hack 

to 

    dir = C:/Users/underway/Documents/hack
    
Any other paths I specify in config files would then be relative to this path, 
i.e. if I had GPS stored at 

    C:/Users/underway/Documents/hack/tools/gps/gps.exe 
    
I would then set the "gps_path" variable like this: 

    gps_path = tools/gps/gps.exe
    
Likewise, if I'd stored GPS outside my hack folder, let's say I had it at 

    C:/Users/underway/Documents/tools/gps/gps.exe 
    
instead, I would have to set "gps_path" like this:

    gps_path = ../tools/gps/gps.exe

You can use forward (/) or backward slashes (\) interchangeably in paths, 
Lunar Helper can handle both.

If you feel like you understand most or all of the configuration variables already
feel free to skip forward a bit, though I would recommend reading at least the 
"initial_patch" and "flips_path" sections no matter what since they contain 
some important notes!

If you just want jump to the end of the configuration process feel free to 
jump to the "Finishing up" section afterwards.

I will now go through the configuration variables we need to specify one by one.


# initial_patch

This variable specifies the path to an initial .bps patch that will be applied to 
the clean ROM at the very start of the build process. 

## Using included .bps patches

There are two such .bps patches for common scenarios included in this archive inside 
the "initial_patches" directory. 

One is a 4MB FastROM patch ("initial_patches/SA-1/initial_patch.bps") and the other 
is a 4MB SA-1 patch ("initial_patches/SA-1/initial_patch.bps"). Both are set up 
identically with compression optimized for speed and all usually relevant 
Lunar Magic hijacks inserted (see list below in the "Creating your own patch" section 
for steps I performed to create these patches). 

Both of them do NOT have the Shift+F8 fix inserted, if you would like to have that 
included you could just patch one of the patches, add the fix and create a new patch 
from the resulting ROM to use instead.

If you want to use one of the two included .bps patches, just extract the one you 
want from the archive and set the "initial_patch" variable to the location you 
moved the patch to.

## Creating your own patch

To create a .bps patch by hand, I would recommend grabbing a clean ROM and making 
Lunar Magic install all the hijacks you might need later. 

Personally, I would recommend you

- Open the ROM
- Expand the ROM to 2 MB
- Apply FastROM or SA-1 (if you want to use them)
- Change the compression options to whatever you prefer
- Expand the ROM to 4 MB
- Save a level
- Extract GFX and ExGFX
- Import GFX and ExGFX
- Create an exanimation, save the level, delete the exanimation and save the level 
  again (so Lunar Magic installs exanimation hijacks)
- Enable a custom palette in a level, change the background color and any other 
  color in the palette, save the level, disable the custom palette and save the 
  level again (for palette hijacks)
- Open the overworld editor
- Edit a path (for the hijacks)
- Edit a level tile (for the hijacks)
- Edit a level name (for the hijacks)
- Edit a message box (for the hijacks)
- Edit the normal layer (for the hijacks)
- Save the overworld (for the hijacks)
- Revert your changes and save again (if you want to have the vanilla overworld 
  back exactly as it was)
- Switch back to the level editor, press Shift+F8 and apply the fix (if you want 
  to have it)

After you're done with this admittedly long list of tasks, you should have a 
solid base. Go ahead and create a .bps patch from this ROM using FLIPS.

Now just set "initial_patch" to the location of the patch you just created.

Example: 

If I had my initial patch at 

    C:/Users/underway/Documents/hack/other/initial_patch.bps 
    
I would use 

    initial_patch = other/initial_patch.bps


# patches

The "patches" variable simply specifies a list of paths to patches you want the 
tool to apply to your ROM during the build process using Asar.

Simply specify the path to each patch on its own line between the angled brackets, 
there are already two patches in the list to show you the format. Note that 
patches are applied in order from top to bottom if that's something that matters 
for your patches, also you may not leave extra blank lines between patch paths or 
the tool will throw an error.

Example: 

If I had a folder with a few patches and another subfolder in it inside my hack 
folder like so:

    C:/Users/underway/Documents/hack/patches/
        retry.asm
        cutscenes.asm
        some_other_patches/
            another_patch.asm

I would write:

patches
[
    patches/retry.asm
    patches/cutscenes.asm
    patches/some_other_patches/another_patch.asm
]

and Lunar Helper would apply all of them in order from top to bottom for me 
during builds.


# gps_path

This variable simply specifies the path to your gps.exe program.

Example: 

If I had GPS at 

    C:/Users/underway/Documents/hack/tools/gps/gps.exe 
    
I would write

    gps_path = tools/gps/gps.exe


# pixi_path

"pixi_path" is exactly the same as "gps_path" but for PIXI (pixi.exe).


# addmusick_path

"addmusick_path" is exactly the same as the previous two but for AddmusicK 
(AddmusicK.exe).


# uberasm_path

"uberasm_path" is exactly the same as the previous three but for UberASM Tool
(UberASMTool.exe).


# levels

This variable specifies the path to a folder which contains all the (altered) 
levels from your SMW hack. If you're using the standard version of Lunar Helper, 
this is the folder all your .mwl level files are saved to whenever you use the 
save function. All of these level files are then imported from this directory 
into the clean ROM during the build process whenever you build your ROM using 
Lunar Helper.

Go ahead and create such a directory in your project's folder and then set the 
variable to the path to this directory.

Example:

If I had created my directory at 

    C:/Users/underway/Documents/hack/levels 
    
I would just write 

    levels = levels

since that is the name of the folder.


# shared_palette

This variable specifies where you would like Lunar Helper to retrieve your 
hack's exported shared palettes from. 

Note that you do not need to export this file yourself, just specify where you 
would like it to go.

Example:

If I wanted that location to be 

    C:/Users/underway/Documents/hack/other/shared_palettes.pal 
    
I would write 

    shared_palette = other/shared_palettes.pal


# map16

This variable specifies where you would like Lunar Helper to retrieve your 
hack's exported all.map16 file from, which is a .map16 file containing all of 
your hack's map16 pages in one place.

Note that you do not need to export this file yourself, just specify where you 
would like it to go.

Example:

If I wanted that location to be 

    C:/Users/underway/Documents/hack/other/all.map16 
    
I would write

    map16 = other/all.map16
    

# human_readable_map16_cli_path

This variable specifies the path to a human-readable-map16-cli.exe, which you can 
get at https://github.com/Underrout/human-readable-map16-cli. This variable is 
optional. If it is supplied, Lunar Helper will be compatible with the human 
readable map16 format that can also be used with Lunar Monitor.

Example:

If I had this executable at 

    C:/Users/underway/Documents/tools/human-readable-map16-cli.exe

I would write

    human_readable_map16_cli_path = ../tools/human-readable-map16-cli.exe


# human_readable_map16_directory_path

This variable specifies where you would like Lunar Helper to retrieve the 
directory of human readable text files generated by human-readable-map16-cli.exe 
from. This variable is optional and has no effect unless "human_readable_map16_cli_path"
is also specified. If this variable is left unspecified, Lunar Helper will use the 
"map16" path without the .map16 extension for this path. For example, if you leave 
this variable unspecified and your "map16" variable is "resources/all_map16.map16", 
the human readable text files will be retrieved from a directory called "all_map16" in the 
"resources" directory.

Example:

If I wanted Lunar Helper to retrieve this directory from

    C:/Users/underway/Documents/hack/other/all_map16

I would write

    human_readable_map16_directory_path = other/all_map16


# title_moves

This variable specifies where you would like Lunar Helper to retrieve your 
hack's title screen moves, as a .zst file, from. 

Note that you do not need to export this file yourself, just specify where you 
would like it to go.

Example:

If I wanted that location to be 

    C:/Users/underway/Documents/hack/other/smwtitledemo.zst
    
I would write

    title_moves = other/smwtitledemo.zst


# test_level

This variable specifies the level number of a level you would like Lunar Helper 
to copy to a different level number if you use its Test option from its menu.

Useful if you have a test level you only want to be accessible when you are 
actually testing your hack.

Note: must always be a 3-digit hex value, so to specify level 1 as a test 
level you would have to write 001, not 1!

Example:

If my test level were A7 I would write

    test_level = A7


# test_level_dest

This variable specifies at which level number the "test_level" should be inserted
when Lunar Helper's Test option is run. This number must also always be a 3-digit 
hex value.

Example:

If I wanted the test level to be inserted as level 105 I would write

    test_level_dest = 105


# global_data

This variable specifies where you would like Lunar Helper to store/retrieve a 
.bps patch containing various other data (overworld, titlescreen, credits, etc.) 
at/from. Note that you do not need to create this patch yourself, just specify 
where you would like it to go. All the contained data will be copied from this 
patch to the clean ROM during the build process.

Example:

If I wanted that location to be 

    C:/Users/underway/Documents/hack/other/global_data.bps 
    
I would write 

    global_data = other/global_data.bps


# dir

We already talked about dir earlier, which is inside config_user.txt by default, 
which you should have open now since the remaining variables are all inside 
config_user.txt.

Just make sure this path is set to the root directory of your project as described 
earlier and you should be fine.


# clean 

This variable specifies the path to a (preferably) clean SMW ROM which will be 
the base ROM Lunar Helper starts from during the build process.

Note that Lunar Helper always uses a copy of your clean ROM and not the actual 
ROM itself so you don't have to worry about it being altered in any way.

Example:

If my clean ROM were at 

    C:/Users/underway/Documents/hack/clean.smc 
    
I would write 

    clean = clean.smc
    
If instead I had my clean ROM at 

    C:/Users/underway/Documents/my_clean_rom_folder/clean.smc 
    
I would write 

    clean = ../my_clean_rom_folder/clean.smc


# output

This variable specifies the name and location you would like the built ROM 
(aka your hack) to have.

Example:

If I wanted my output ROM to be called "hack.smc" and be located in the root 
directory of my project I would just write 

    output = hack.smc


# temp

This variable just specifies the location and name you want the ROM Lunar Helper 
builds on to have during the build process. Basically Lunar Helper takes your 
clean ROM, copies it to this temp location and then if the build succeeds this 
ROM will be renamed and moved to the location specified by output. 

Example:

If I wanted my temp ROM to be called "temp.smc" and be inside the project's root 
directory during the build process I would write 

    temp = temp.smc


# package

This variable specifies the name and location you want Lunar Helper to give to 
the .bps patch it creates of your hack when you use the Package option from 
its menu. Basically it just builds your ROM like normal and then runs FLIPS on 
it to create a .bps patch of it.

Example:

If I wanted Lunar Helper to produce this patch at 

    C:/Users/underway/Documents/hack/hack.bps 
    
I would write 
    
    package = hack.bps


# asar_path

This variable just specifies the path to your asar.exe file.

If you want to have an asar.exe inside your project folder make sure to move 
this variable to config_project.txt.

Example:

If I had asar.exe at 

    C:/Users/underway/Documents/tools/asar/asar.exe 
    
I would write 

    asar_path = ../tools/asar/asar.exe


# lm_path

Same as asar_path but for Lunar Magic.

Example:

If I had Lunar Magic at 

    C:/Users/underway/Documents/tools/lunar_magic/lunar_magic.exe 
    
I would write 

    lm_path = ../tools/lunar_magic/lunar_magic.exe


# flips_path

Same as the two above but for FLIPS.

Note that older versions of FLIPS (including the one currently hosted in 
SMW Central's tools section) have a bug that may make Lunar Helper think there 
was an error with .bps patch application/creation even though no error occurred. 

Make sure you get an up-to-date version, either from FLIPS's GitHub page (though 
you will have to build it yourself) or from a comment on the tool page for FLIPS 
on SMW Central (though there is of course no guarantee that this version has 
not been tempered with).

If you want a version that is verified to be safe you will have to either build 
it yourself or wait for SMW Central or some other trusted site to host an 
up-to-date version.

Example:

If I had FLIPS at 

    C:/Users/underway/Documents/tools/flips/flips.exe 
    
I would write 

    flips_path = ../tools/flips/flips.exe


# retroarch_path 

This variable lets you specify the path to your retroarch emulator if you want 
to be able to run the built ROM in it from Lunar Helper's menu via the Run 
and/or Test menu options.

In contrast to the other variables I believe this one is actually an absolute 
path rather than a relative one.

Example:

If I had retroarch installed at 

    C:/Program Files/retroarch/retroarch.exe 
    
I would thus write 

    retroarch_path = C:/Program Files/retroarch/retroarch.exe


# retroarch_core

Same as retroarch_path but for the retroarch core you want to use. 

Example: 

If I had a snes9x libretro core at 

    C:/Program Files/retroarch/cores/snes9x_libretro.dll 
    
I would write 

    retroarch_core = C:/Program Files/retroarch/cores/snes9x_libretro.dll
