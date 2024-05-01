; Custom Bounce Blocks
; By Kaijyuu
; Updated by GreenHammerBro
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;There should be exactly 7 items in folder (file name arranged):

-"BlockRoutines" A folder containing a routine file just in case if you need a block that disable itself
 when all bounce blocks slots are used.
-"CustomBlocks" self explanatory.
-"CustomBounceBlkDefines" A folder containing a define in case if you need to change the defines for
 every stuff.
-"Advanced Readme.txt", usage on how to get your bounce block working with custom blocks.
-"BounceBlocks Readme.txt", Seriously?!? you don't know what that is?
-"CustBounceBlocks.asm", the patch that lets you have custom bounce blocks.
-"CoinObject.txt", not a patch but a code which you can insert with ObjecTool. Use it for coins which turn
 into bricks AND have the item memory enabled.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Q: WHAT THE CRAP IS THIS?


A: This is a patch that will allow you to make your own bounce block sprites. 
No more will your custom blocks stay still when mario hits them. 
No more will you have to overwrite turnblock graphics.
No more will you have to use those silly SMB3 breakable bricks with a weird bounce animation. 


Q: OK, HOW EXACTLY IS THIS USEFUL?

A: The biggest use of this, obviously, is giving custom blocks the ability to bounce without them turning
into a regular SMW block. The second biggest use is allowing custom graphics to be used for your block
without overwriting turnblocks, ? blocks or whatever. Thirdly, and less likely to be used, are
behaviors. SMW used these to spawn sprites out of item blocks and play sound effects, which
of course can be done in normal block code. You can do much better.


Q: WHAT'S INCLUDED ALREADY?

A: Included is the patch and an example block.

The patch allows:
- Custom bounce block sprites (duh)
- Includes a "base" bounce block sprite. Has everything a bounce sprite needs and almost nothing else.
- Custom map16 changes without the fuss of hex edits or inserting huge blocks of code into your block
- Optional fix for the coin-over-a-questionblock-turns-into-invisible-solid-block glitch. 

The block is/has:
- A SMB3 breakable brick
- Example code for creating a bounce sprite and changing to any map16

NOTE: The SMB3 breakable brick block included MUST be inserted with GPS. It is not automatically applied
with the patch. It will also crash horribly if inserted without the included patch.
In addition, the item memory feature (remembers whether a coin is collected or not) is only usable for
the coin (use it only for coins which turn into bricks not for bricks which turn into coins) and only if
the coin has been inserted with the included object (i.e. not with as a Direct Map16 object).


Q: HOW DO I USE THIS?

A: Follow these instructions.

1) Edit the freeram in "CustomBounceBlkDefines". If copied and pasted, make sure that you have them
   all matching.
2) Use Asar to insert "CustBounceBlocks.asm".

3) Now paste any block you want in "CustomBlocks" in GPS. Make sure you also paste the EDITED
   defines INSIDE GPS's blocks folder.

4) Insert using GPS.


Q: ALRIGHT, I WANT TO MAKE MY OWN BOUNCE BLOCK SPRITES NOW. HOW DO I START?

A: First off, you should know enough ASM to make a simple block. If you know that much, you should be able
to change the graphics of the included sprite. You can copy/paste the code for the SMB3 brick sprite to
the other spaces. Remember to change the labels so they're all unique. And uncomment the RTS at the end.
If you really want to go crazy and make a 32x32 bounce sprite or zelda push blocks or something, you
should at least know how to make sprites. A detailed explanation is included in the advanced readme.


Q: COINOBJECT.TXT DOESN'T WORK!

A: There are multiple reasons why it might not work. But the first thing is that CoinObject.txt is a
code insertable with ObjecTool.
Keep in mind that Lunar Magic doesn't support custom object graphics so they might look like glitchy
tiles in Lunar Magic but are actually fine in-game. Think of it as custom sprites except there is
ABSOLUTELY no way to fix (custom sprites can but it's somewhat difficult unless the current sprite
tool generates custom sprite display graphics) it unless you managed to reverse engineer Lunar Magic
for some reason.
The item memory feature also only works with


Q: ARE THERE ANY COMPATIBILITY ISSUES?

A: None that I know of. It's highly unlikely anything is incompatible, but ya never know. Anything that
messes with the bounce block routines risks it, however slightly. 


Q: DO I HAVE TO CREDIT YOU?

A: No. Host this anywhere, give it to anyone, claim it as your own, it's all good :)


Q: I HAVE A QUESTION!

A: Ask in the Advanced SMW Hacking forum at SMWCentral.net. The "Official Hex/ASM/Ect. Help Thread" is a
good place. Do not PM me simple questions, please. If you have some super advanced difficult problem
that somehow relates to this, make a thread. A PM is only appropriate if...


Q: I IS AVDACED HAKCR AND WNT 2 TEL U SOMTING ABOUT UR CODE SUCKS

A: A PM would be appropriate if you find a bug or fatal crash that's my fault, or if you have a suggestion
to improve the patch. However, if you type like the above I might have to reply with radioactive
scorpions. Just an FYI. 

Q: WHEN I BREAK A BLOCK IN A VERTICAL LEVEL, THE SHATTER PIECES DON'T SHOW UP OR IS SPAWNED IN THE WRONG
LOCATION, WHAT HAPPENED?

A: When using such routines such as smw's tile generation and custom map16 change routine in a vertical
level, they left $7E0099 and $7E009B (the high bytes of the position the blocks being touched) being
swapped, and then they run the "Spawn shatter pieces" routine. The spawn pieces routine uses $98~$9B to set
the position to spawn. The reason why it need to swap the XY is because vertical levels are "sideways"
compared to horizontal levels. To fix this, every time you use any tile change routine, re-switch them back
using this code:

	LDA $5B		;\If vertical level, then swap the X and Y high bytes due to level
	AND #$01	;|format. This is because the tile change routine (both GPS and SMW's
	BEQ +		;/left them swapped).
	LDA $99		;\Fix the $99 and $9B from glitching up if placed
	LDY $9B		;|other than top-left subscreen boundaries of vertical
	STY $99		;|levels!!!!! (barrowed from the map16 change routine of GPS).
	STA $9B		;/
+

Q: WHAT THE HECK IS !EnableBounceUnrestrictor?

A: !EnableBounceUnrestrictor enables you to use the Bounce Block Unrestrictor option which can be seen as a
custom bounce block lite. That means, you can chose how the block looks like and into which tile it changes
to without creating a new custom bounce sprite! !RAM_BounceTileTbl is also usable as freeRAM since it only
affects regular bounce blocks with BBU enabled but not inside custom bounce block sprites.



~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
GHB updates (yes, I ask the admin that I have the right to update asms to asar),
and not only that, here is the offical permit from GHB's private message:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GreenHammerBro:
Ignore the first pm, is it okay if I can convert any of your patches? I choose "any" because I don't
want to keep asking for each patch you have made, which is annoying to both of us.

Kaijyuu:
Go for it.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Smw central Asm guidelines now prohibits xkas patches. Alcaro's superior patcher, Asar is dominating it.


10/20/2015
	-Converted the patch to work with asar and the block work with GPS (oh
	 no! Not using the old blocktool that has 7 offsets!)
	-Improved the brick block to have options (like a p-switch turns it into
	 a coin) and breakable by spinjump, it now doesn't push kicked upward sprites
	 sideways.
	-Fix a brick block's reverting glitch that happens if you spawn a bounce
	 sprite while all 4 bounce sprite are occupied by a spinning turn block
	 causes the brick block to turn into a random map16 tile. Its fixed by
	 Preserving $03 and $04.
10/22/2015
	-Improved the reset turn block routine to use GPS's routine. As well as
	 improving the advanced readme code to be more efficient.
11/13/2015
	-Fix an awful bug where the shatter pieces don't show up in vertical levels.
5/21/2017 - 2.0
	-Freeram Defines as well as "universal" defines are now in a seperate folder
	 with other asm files incsrc "<path>" so you don't have to edit every single
	 asm.
	-SA-1 compatible on all ASM.
	-Patch now uses .sublabels so if you make another custom bounce block, never
	 worry about conflicting redefined labels.
5/22/2017 - 3.0
	-Noticed that sprites that don't interact with other sprites (including bounce
	 sprites) have a bug where the sprite can "hit itself" (such as a dropped shell)
	 when hitting the side. Fixed by checking the tweaker bit.
6/15/2017 - 3.1
	-Added a vanilla on/off switch (but made using my own ASM coding)
6/21/2017 - 3.2 [removal reason fix]
	-Fix a custom block error that the defines causing the tool to not insert due
	 to SA-1 Macro already used in GPS.
7/12/2017 - 3.2
	-Fix the sprite hit side detection, allowing true consistency with smw's
	 bounceable blocks to prevent self-hitting..
12/14/2017 - 3.3 Remoderation update:
	-Merged the patch with Bounce Block Unrestrictor
	-Fixed the SMB3 brick which shatters when hit with a fireball (and if Mario is big
	 and but that usually is the case with fire Mario).
	-Seperated the Map16 table into a high and a low byte table so you don't need to do
	 a ASL whenever you want to access the table.