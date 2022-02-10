; Custom Bounce Block Sprites Advanced Readme
; CBBSAR for short
; By Kaijyuu


Let's go over the included sprite first. Open CustBounceBlocks.asm and scroll down to "sprite code starts here."


Bounce8:	; SMB3 brick

Bounce8-1F are the default available spots for bounce sprites. 
You can actually have up to x86, but I somehow doubt you'll use up to 1F, much less all the available slots.
If you really do need more than 1F though, just add more pointers to the list above the sprite code.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Graphics!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	JSR SUB_OFFSCREEN	; check if offscreen
				; $00 holds the x position relative to screen border
				; $01 holds the y
				; carry set if offscreen
	BCS SMB3_SKIP_GFX	; skip graphics if offscreen
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SUB_OFFSCREEN is much like SUB_GETDRAWINFO used in many sprites. 
It checks if it's offscreen, and sets scratch ram appropriate for setting the tile positions. 
The carry flag is set if offscreen, and clear if on. 
Blah blah, explained in comments already. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BOUNCE_OAM: 			; OAM addresses for bounce extended sprites
	db $10,$14,$18,$1C


	LDA BOUNCE_OAM,y	; get OAM offset
	TAX			; stick in x

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
The default bounce block OAM positions are $0210-$021C. This is four tiles. 
All the above code does is pull the default OAM offset for the sprite depending on the sprite number.
Basic stuff.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDA $00			; x pos
	STA $0200,X		; store to OAM
	
	LDA $01			; y pos
	STA $0201,x		; store to OAM

	LDA #$40		; tile number
	STA $0202,x 		; store to OAM

	LDA $1901,y		; properties
	ORA $64			; add in prority bits from level settings
	STA $0203,x		; store to OAM
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Self explanitory if you've ever worked with sprites. 
If you want to change the tile number, change the one marked tile number. 
Wanna use sprite page 2? Normally that would be set in the block that spawned the sprite. 
However you can hardcode it by adding ORA #$01 after ORA $64. 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	TXA			; set tile size
	LSR			; 
	LSR			;
	TAX			;
	LDA #$02		; #$02 = 16x16
	STA $0420,x		; #$00 = 8x8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^Sets the tile size. Explaining why it works this way is beyond this readme, though.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDA $9D			; check if sprites are locked
	BNE SMB3_RETURN		; return if so
	LDA $169D,y		; check if init should be run
	BNE SMB3_NO_INIT	; branch if not
	LDA #$01		; stop init from running again
	STA $169D,y
	JSR InvisSldFromBncSpr
	; More init would go here if there were more
SMB3_NO_INIT:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^An init routine is included here, but only generates an invisible solid block.
That's how SMW vanishes the block when you hit a block which generates a bounce sprite.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	JSR SUB_SPEEDS		; regular bounce block speed routines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^This updates the sprite's position based on speed values. Moving on...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BOUNCE_SPEED_Y:			; Generic bounce sprite speed modifiers for y speed
	db $10,$00,$00,$F0	; these are added to the y speed every frame for sprites that use it
BOUNCE_SPEED_X:			; Generic bounce sprite speed modifiers for x speed
	db $00,$F0,$10,$00	;

	LDA $16C9,y		; $16C9 = LxxxxxBB
				; L = layer. 0 = layer 1, 1 = layer 2
				; x = unused extra bits
				; BB = speed modifiers
	AND #$03		; get speed modifiers only
	TAX			; stick in x
	LDA $16B1,y		; sprite y speed
	CLC
	ADC BOUNCE_SPEED_Y,x	; add to speed based on table
	STA $16B1,y		; set y speed
	LDA $16B5,y		; sprite x speed
	CLC
	ADC BOUNCE_SPEED_X,x	; add to speed based on table
	STA $16B5,y		; set x speed
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^Modifies the speed values based on the tables above. Almost a direct copy from SMW. 
The last two bits of $16C9 are important. If you want the sprite to bounce like any other SMW bounce sprite,
you need to set these bits within the block.
00 = Initial speed should be set to UP. sprite pushed down within code
01 = Initial speed should be set to RIGHT. sprite pushed left within code
10 = Initial speed should be set to LEFT. sprite pushed right within code
11 = Initial speed should be set to DOWN. sprite pushed up within code

If you set the sprite's initial y speed downward, and the first two bits of $16C9 to 00, it will rocket downward at incredible speeds.
Generally a bad thing.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	LDA $16C5,y		; timer
	BNE SMB3_RETURN		; return if not yet 0
				; this timer is automatically decremented every frame until it hits 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
^Like the comments say, this timer is automatically decremented every frame by SMW. Maybe of note: Does not decrement when sprites are locked.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	TYX		; stick block index in x
	PHK
	PER $0006	; Replace block with block set in $16C1
	PEA $94F3	; 
	JML $02919F
	TXY		; get it back into y
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^This sets the block to whatever was set to $16C1. The sprite's index must be in x for this.
Will change to a custom map16 if this number is 1C-FF, but more on that later.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	LDA #$00
	STA $1699,y	; kill bounce block sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^Kills the bounce sprite. Yay. 


Now on to the included block's code. Open SMB3Brick.asm. What we're looking at is at the very top.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDA.b #!bounce_tile
	STA $02
	; $03 is already set
	LDX !bounce_tile
	LDA #!bounce_num
	LDX #$FF
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!bounce_properties
	STA $1901|!addr,y

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^This small piece of code spawns a bounce sprites with the following properties:
-its tile number (BBU sprites only) (in $02)
-the tile it turns into (in $03 but since the brick doesn't change the tile, we'll just leave it)
-the bounce block tile number (in A)
-the $9C value (though for custom bounce blocks, 0xFF is enough) (in X)
-the direction the bounce block moves (possible values are: 0 = up, 1 = left, 2 = right and 3 = down) (in Y)
The rest is done within spawn_bounce_sprite.asm
The only exception are the properties which are set after the routine and have to be set manually.

If you want to see a code which change the tile the block turns into any tile, there you have it:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDA.b #!bounce_tile
	STA $02
	LDA.b #!map16_tile
	STA $03
	LDA.b #!map16_tile
	STA $04
	LDX !bounce_tile
	LDA #!bounce_num
	LDX #$FF
	LDY #$00
	%spawn_bounce_sprite()
	LDA #!bounce_properties
	STA $1901|!addr,y

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
As you can see, it isn't that much different from the previous code except I set $03 to a fixed value instead
of the current tile number.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Thank god that this package is compatible with the "Bounce block multi-hit fix"
patch that I made. But you still have to have a code that changes a block to $0152 in a blocks code to prevent
this said glitch, do this AFTER you spawn the bounce block, else it would have the after-changed block stored
in memory.

GHB: Actually, the reason why its solid is so that when the block is hit, the block isn't passable, preventing
the player from passing through.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ADVANCED NOT-SO-FREQUENTLY ASKED QUESTIONS:


AM I LIMITED TO 1 GRAPHIC TILE PER BOUNCE SPRITE?

Yes and no. You of course could use more of the OAM, but you run the risk of overwriting things. The best place
to put additional tiles would probably be in the cluster sprite area. That obviously won't work well with cluster
sprites, though.


WHAT'S HERE THAT I COULDN'T DO IN A REGULAR OR CLUSTER SPRITE?

Well, for one, different tables means you can have more sprites on the screen. 
Two, it's a lot more efficient than regular sprites.
Three, the tables for changing the map16 of the spawning block are already set up.


ANY LIMITATIONS?

The big, big, and I do mean big, limitation is that there's only 4 sprite slots for these.
You could, for example, make an elevator out of a bounce sprite. 
However, if mario jumped off that elevator and rapidly hit 4 blocks somehow, your elevator just disappeared. 
There are ways to extend the lifespan of your bounce sprite, but immortal it is not. But when expanding your
slots mean you have to change ALL the slot loops (and when I mean all, I mean all your blocks that uses bounce
sprites):
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDY #$xx	;>how many slots -1 (for example, 4 slots means this value is #$03), this is the loop starter
-	LDA $1699,y	; check status
	[...]
	DEY		;>next slot
	BPL -		;>if slot is 0 or positive, loop.

ANY "NOT LIMITED TO ONE PREDEFINED PURPOSE" TABLES?
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
None that I noticed. However, you could probably skip the speed routine and use the accumulating fraction bit
tables as "free." Also $169D would be free if your sprite doesn't need an init. $16C9 contains several unused
bits, too, that are 100% free to use. In addition, !RAM_BounceTileTbl which is used for the BBU bounce blocks,
is unused in custom bounce sprites.


I HAVE ANOTHER ADVANCED QUESTION!

Ask in the Advanced SMW Hacking forum at SMWCentral.net. The "Official Hex/ASM/Ect. Help Thread" is a good
place. Do not PM me simple questions, please. If you have some super advanced difficult problem that somehow
relates to this, make a thread.

My block suddenly changes into tile $125 (key/wings/balloon/shell)!

This is caused by subroutines modifying the Y register. To fix that, put PHY before the routine to save it,
then PLY to restore it. Its because the Y register is reserved for block behavor purposes.