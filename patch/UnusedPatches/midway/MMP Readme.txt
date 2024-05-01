Readme for Multiple Midway Points 1.7 patch




WHAT BE THIS?

This is a patch that allows you to have more than 1 midway point in your levels.
All the way up to a maximum of 256 midway entrances for each level. 
Not that you'll ever use anywhere close to that amount.

Anyway, you'll be able to use any level's midway entrance, from 000-1FF, for any level.
Also, in addition to midway entrances, you can use secondary entrances.
Instructions on how to do all that later.





WHAT ARE THE REQUIREMENTS?

Almost certainly requires Lunar Magic 1.70 or 1.71 to be installed on your ROM.
Earlier versions are not guarenteed to work with this patch.
Also, to take advantage of the multiple midway points feature, you'll need GPS or a way to insert .asm blocks.
Custom blocks are not required if you don't want multiple midway points.
If all you want is allowing midway entrances to be in levels other than the starting level or be a secondary entrance,
you can use this patch for that.

SRAM Plus/BW-RAM Plus is needed to save the midway flags (and reset their values too).




PATCHING GUIDE:
1) Modify whatever you want on multi_midway_tables.asm
2) Patch multi_midway_1.7.asm
3) Use SRAM/BR-RAM Plus to reset and make the game to remember which midpoints are collected, I included a sram_table.asm (and bw_table.asm for SA-1 users) already.
4) Done.




HOW DO I USE IT?

- To make the midway entrance use a different level number or secondary entrance:

Open multi_midway_tables.asm.
You will see these tables:

dw $0000 : $0000	; Level 0000
dw $0001 : $0001	; Level 0001
dw $0002 : $0002	; Level 0002
dw $0003 : $0003	; Level 0003
dw $0004 : $0004	; Level 0004
dw $0005 : $0005	; Level 0005
dw $0006 : $0006	; Level 0006
dw $0007 : $0007	; Level 0007
dw $0008 : $0008	; Level 0008
dw $0009 : $0009	; Level 0009
dw $000A : $000A	; Level 000A
dw $000B : $000B	; Level 000B
dw $000C : $000C	; Level 000C
dw $000D : $000D	; Level 000D
dw $000E : $000E	; Level 000E
dw $000F : $000F	; Level 000F

Furthermore, you can set the midway point destination to a secondary entrance instead of the midway entrances.
In order to do that, you need to add $8000 to the "level" number (so e.g. "$00FF" becomes "$80FF").
That way, you can chose secondary entrances $0000-$1FFF.
Alternatively, you can use Asar's math functions and attach to the secondary entrance number "+$8000" (without quotes, that's it).
You also can set the entrance as a water level if you add to the secondary entrance number $2000 (so e.g. "$80FF" becomes "$A0FF").
Keep in mind that due to how Lunar Magic handles exits, the water level flag doesn't get activated if the destination is set to
be a regular midway entrance. It needs to be a secondary exit.
Note that this change also made the previous versions incompatible with each other. That means, you need to change any instance of
$1xxx to $8xxx.


- To use multiple midway points in the same level:

In the main patch, there are two entrances defined for each level by default. 

To use the second one, you'll need to: 
1) Insert the "MultiMidwayBlock1.asm" into your ROM.
1.5) Place this in any map16 slot 
2) Paste it over the bar of a midway point in your level (not in the map16).
Done.

When mario breaks this bar, a flag is set making the level use the second midway point.


- To use more than two midway points:

In MultiMidwayPoints.asm, you'll see this:

!MIDWAY_NUMBER	= $0002

Change this number to however many midway points you want for each level.

WARNING! If you change this number, you must also expand the tables for EACH and EVERY level.
If you changed it to 0003, then the following change must be made:

dw $0000 : dw $0000

would become:

dw $0000 : dw $0000 : dw $0000

Every level must have a midway entrance defined for every possibility. 
Otherwise, your game will be pulling the wrong midway point number and will send you weird places!

In order to save the amount of work on changing the tables, I (MFG) have included a python (version 3) script to auto-generate the tables.
(Unlike many scripts, which behave like Xkas when opening, this one works per command line as well as per double-click similar to Asar.)
Don't forget that it will overwrite any changes you made beforehand!

Next, you'll need to insert "MultiMidwayBlock2.asm" just like you did the other block
Give it it's own unique map16 slot.
Paste over a goal tape bar like before. 

If you need more midway point blocks, just make copies of the current ones and change the number at the top.

	!MIDWAY_POINT_NUMBER = $01	
01 = regular midway point
02 = second midway point
03 = third
04 = fourth
ect



FAQ - AKA POSSIBLE PITFALLS:


Why am I being sent to the wrong level? 

Several possibilities for this.
1) If you changed the total number of midway points for each level, be sure you expanded the tables as well.
2) Double check you have the level number/secondary entrance number set right.
3) If you're using NPCs or anything else that messes with the translevel number ($13BF), it will screw up the midway point bar blocks.
Find a way to restore the translevel number, or just don't use NPCs or the like in the same levels as ones with multiple midway points.
4) The intial overworld loading routine MUST be run. This runs when you start a new game, or load a game from the title screen.
If you open a savestate that was made before this patch was applied, your midway points will send you odd places.
That's because the table that holds which midway number to use wasn't initialized.
Make sure you loaded your game from the title screen before testing this patch.


Why am I seeing a "no yoshi" intro? I turned it off in the starting level!
(alternatively, why am I NOT seeing a "no yoshi" intro?)

The game checks whether to use the no yoshi intro based on the first level that's loaded.
If you set your midway point to be in a level who's tileset has a no yoshi intro, it will use a no yoshi intro until you turn it off in that level.
If you WANT a no-yoshi intro and aren't getting one with your midway point, same thing. 
Make sure your destination level is using a tileset that has a no yoshi intro and that you didn't disable it in the level settings.


I can't use a custom block/direct map16 access for my additional midway points! They'll reappear and give mario a free powerup!

The original game made the midway point bar not appear because they had an object to do it with.
As such, I (MFG) have included. All you need to do is to insert the object into ObjecTool (or with some modifications, UNKO) and put it into your ROM.
Keep in mind that the midway index is set per the second entension byte.
That means, when inserting a custom normal object into the level, the object number is determined by the field "extension".
That being said, it can take two bytes: The first for the object number and the second for miscellanous settings object 2D settings.
The format is following: "xxyy" where "xx" is the object number (e.g. if the midway point bar is object 42, you put 42 in there) and
"yy" here the midway point number.

Another method would be to make an identical level, only without the midway point bar, and send mario there instead.
Otherwise... it's a mushroom, whupidedoo.




DO I NEED TO CREDIT YOU?

No. Use this patch however you like, host it anywhere, claim it as your own, it's all good. :)




I HAS QUESTION!

Please do NOT PM me questions on how to use this patch.
Go here: http://www.smwcentral.net/?p=forum&id=6
Ask in the "Official Hex/ASM/Etc. Help Thread", or make a topic.



I NOTICED BUG, YOU IS SUCKS PROGRAMMAR!

A bug report would be appropriate for a PM.
And yes, I am. 