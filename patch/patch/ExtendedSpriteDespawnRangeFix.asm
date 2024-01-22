;This patch fixes a problem with extended sprites having a short despawn range that they despawn when a single pixel of the tile
;goes beyond the left or top edges of the screen.

;NOTES:
;-Extended No Sprite Tile Limits patch is required! Download here: https://www.smwcentral.net/?p=section&a=details&id=24642
;
;-Not compatiable with my directional quake: https://www.smwcentral.net/?p=section&a=details&id=18776
; unless you remove the hijacks of that patch for extended sprites not to despawn from shifted screen and have this patch
; handle the shifted screen (as stated, despawning boundaries should not use the moved screen by taking the moved screen, and subtract by the
; shake displacement, BUT the OAM handling *MUST* use the shifted screen position so that their image shakes with layer 1. Just like
; any other sprite types (normal, pixi, and others), $1A-$1D and $1462-$1465 may already be the shooked position and not original position.
; In some cases, it is easier just to take the XY 16-bit on-screen position and ADD by the quake displacement,
; check if they're offscreen, then restore it back before writing OAM data into the OAM RAM.

;Note to self: The list of extended sprites can be found via CTRL+F "ExtendedSpritePtrs" on the disassembly.

;No Sprite Tile Limits patch defines (must match!)
	!RAM_ExtOAMIndex = $1869|!addr

;Defines and settings
	;Boundary positions, as you increase the values, the positions of the borders moves rightwards or downwards.
	;-$0000 means the top of the screen on the horizontal axis or vertical axis
	;-$0100 means the right edge of the screen on the horizontal axis, $00E0 means the bottom of the screen on the vertical axis.
		!Despawn_LeftEdge = $FFE0		;>How far left, in pixels sprites have to be at in order to despawn
		!Despawn_RightEdge = $0120		;>Same as above but rightwards
		!Despawn_Top = $FF70			;>Same as above but upwards above the screen
		!Despawn_Bottom = $0100			;>Same as above but bottom of the screen

;Don't touch, although this patch does work under SA-1, there are still some odd bugs as listed in
;KnownBugs.txt.
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!sa1 = 0
	!gsu = 0
	
	if read1($00FFD6) == $15
		sfxrom
		!dp = $6000
		!addr = !dp
		!bank = $000000
		!gsu = 1
	elseif read1($00FFD5) == $23
		sa1rom
		!dp = $3000
		!addr = $6000
		!bank = $000000
		!sa1 = 1
	endif
org $029B54 ;volcano lotus seeds
	autoclean JML VolcanoLotusDespawnAndOAM
org $029C61 ;Puff of smoke from yoshi stomp (when yoshi lands on the ground with yellow shell in mouth)
	autoclean JSL SetOnlySizeBitY
	NOP
org $029CF8 ;Coin game cloud and wiggler's flower
	autoclean JML CloudCoin
org $029F93 ;Yoshi fireball
	autoclean JSL SetOnlySizeBitY
	NOP
org $029BA0 ;Volcano lotus
	autoclean JSL ClearOnlySizeBitY
	NOP
org $029D27 ;Wiggler flower
	autoclean JML WigglerFlower
org $029D45 ;Part of the coin cloud OAM handler, we've already finish the OAM XY position
	NOP #5
org $029D3F ;Wiggler flower
	autoclean JSL ClearOnlySizeBitY
	NOP
org $029D54 ;Cloud coin
	autoclean JSL SetOnlySizeBitY
	NOP
org $029E7C ;Torpeto launcher arm
	autoclean JSL SetOnlySizeBitY
	NOP
org $029EA0 ;Lava splash
	autoclean JML LavaSplash
org $029EDD ;Lava splash
	autoclean JSL ClearOnlySizeBitY
	NOP
org $029F2A ;water bubble (spawned by player when in water)
	autoclean JML WaterBubble
org $029FB3 ;Mario's fireball
	autoclean JML MarioFireballDespawnHandler
org $02A19D ;Reznor fireball
	autoclean JSL SetOnlySizeBitX
	NOP
org $02A1B1
	;Several extended sprites use this as a base code (this starts at $02A1A4).
	;By Modifiying this, the vast majority of extended sprites (most of them uses this btw)
	;will be affected.
	autoclean JML ExtendedSpriteBaseCode
org $02A33D ;hammer
	autoclean JSL SetOnlySizeBitX
	NOP
org $02A208 ;Base code for most extended sprites
	autoclean JSL ClearOnlySizeBitY
	NOP
org $02A2B9 ;baseball
	autoclean JSL ClearOnlySizeBitY
	NOP
org $02A271 ;baseball
	autoclean JML BaseballDespawnAndOAM
org $02A36C ;Smoke puff (outside reznor fight)
	autoclean JML SmokePuffDespawnAndOAM
org $02A3A5 ;Smoke puff (outside reznor fight)
	autoclean JSL SetOnlySizeBitY
	NOP
org $02A3F0 ;Smoke puff (inside reznor fight)
	autoclean JSL Set0460OnlySizeBitY
	NOP
freecode
ExtendedSpriteBaseCode: ;JML from $02A1B1
	REP #$20		;\Preserve $01-$04 just in case if they're going to be used for something else
	LDA $01
	PHA
	LDA $03
	PHA
	SEP #$20
	
	LDA $171F|!addr,x	;\$01-$02: X position
	SEC			;|
	SBC $1A			;|
	STA $01			;|
	LDA $1733|!addr,x	;|
	SBC $1B			;|
	STA $02			;/
	REP #$20
	LDA $01
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	SEP #$20
	LDA $1715|!addr,x	;\$03-$04: Y position
	SEC			;|
	SBC $1C			;|
	STA $03			;|
	LDA $1729|!addr,x	;|
	SBC $1D			;|
	STA $04			;/
	REP #$20
	LDA $03
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	.OAM
		PHB				;>Preserve bank of SMW code where my hijack is at
		PHK				;\Switch bank to use the bank of the following table
		PLB				;/
		PHY				;>Preserve OAM index Y
		LDA $170B|!addr,x
		AND #$00FF
		ASL
		TAY
		LDA $03				;\Y position -1 because sprite OAM are shifted 1 px lower
		DEC				;/
		CMP NoDrawOAMBoundary-2,y	;\Y offscreen
		BMI ..NoOAM			;|
		CMP.w #$00E0-1			;|>Because of the Y-1, this position must be shifted as well.
		BPL ..NoOAM			;/
		LDA $01				;\X offscreen
		CMP NoDrawOAMBoundary-2,y	;|
		BMI ..NoOAM			;|
		CMP #$0100			;|
		BPL ..NoOAM			;/
		SEP #$20
		PLY				;>Restore OAM index Y
		
		..XPos
			LDA $01			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $02			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $03			;\Y position
			STA $0201|!addr,y	;/
		BRA ..NoOAMSkipPullY
	
		..NoOAM
			PLY
		..NoOAMSkipPullY
	PLB					;>Restore bank
	REP #$20
	PLA
	STA $03
	PLA
	STA $01
	SEP #$20
	JML $02A1DD				;>Jump back to where it handles the properties
	.Despawn
		PLA
		STA $03
		PLA
		STA $01
		SEP #$20
		JML $02A211
	NoDrawOAMBoundary:
	;Negative X and Y positions that is the rightmost or bottomost that cannot be seen on the screen.
	;They differ depending on the tile size (8x8 or 16x16). For bottom and right edges, regardless
	;of their sizes, their positions are always $0100 and $00E0.
	dw $FFF0	;>$01 - Smoke puff
	dw $FFF0	;>$02 - Reznor fireball
	dw $FFF8	;>$03 - Flame left by hopping flame
	dw $FFF0	;>$04 - Hammer
	dw $FFF8	;>$05 - Player fireball
	dw $FFF0	;>$06 - Bone from Dry Bones
	dw $FFF8	;>$07 - Lava splash
	dw $FFF0	;>$08 - Torpedo Ted shooter's arm
	dw $FFF8	;>$09 - Unknown flickering object
	dw $FFF0	;>$0A - Coin from coin cloud game
	dw $FFF8	;>$0B - Piranha Plant fireball
	dw $FFF8	;>$0C - Lava Lotus's fiery objects
	dw $FFF8	;>$0D - Baseball
	dw $FFF8	;>$0E - Wiggler's flower
	dw $FFF0	;>$0F - Trail of smoke (from Yoshi stomping the ground)
	dw $FFF8	;>$10 - Spinjump stars
	dw $FFF0	;>$11 - Yoshi fireballs
	dw $FFF8	;>$12 - Water bubble
	
VolcanoLotusDespawnAndOAM: ;JML from $029B54
	LDA $171F|!addr,x	;\$00-$01: X position
	SEC			;|
	SBC $1A			;|
	STA $00			;|
	LDA $1733|!addr,x	;|
	SBC $1B			;|
	STA $01			;/
	REP #$20
	LDA $00
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	SEP #$20
	LDA $1715|!addr,x	;\$02-$03: Y position
	SEC			;|
	SBC $1C			;|
	STA $02			;|
	LDA $1729|!addr,x	;|
	SBC $1D			;|
	STA $03			;/
	REP #$20
	LDA $02
	CMP #!Despawn_Top
	BMI .CODE_029BA5	;>Equivalent to BMI CODE_029BA5 (skips all OAM-related stuff)
	CMP #!Despawn_Bottom
	BPL .CODE_029BDA	;>Equivalent to CODE_029BDA (despawns the sprite)
	;BRA CODE_029B76	;>Equivalent to BEQ CODE_029B76
	
	PHB				;>Preserve bank of SMW code where my hijack is at
	PHK				;\Switch bank to use the bank of the following table
	PLB				;/
	PHY
	LDA $170B|!addr,x		;\Get left boundary index
	ASL				;|
	TAY				;/
	REP #$20
	LDA $00				;\Check if OAM tile is offscreen horizontally
	CMP NoDrawOAMBoundary-2,y	;|
	BMI .NoOAM			;|
	CMP #$0100			;|
	BPL .NoOAM			;/
	LDA $02				;\Same but vertically
	CMP NoDrawOAMBoundary-2,y	;|
	BMI .NoOAM			;|
	CMP.w #$00E0-1			;|
	BPL .NoOAM			;/
	SEP #$20
	PLY
	PLB				;>Restore bank
	
	LDA $00			;\Bits 0-7 X position
	STA $0200|!addr,y	;/
	TYA			;\Bit 8 X position
	LSR #2			;|
	PHY			;|
	TAY			;|
	LDA $01			;|
	AND.b #%00000001	;|
	STA $0420|!addr,y	;|
	PLY			;/
	LDA $02			;\Y position
	STA $0201|!addr,y	;/
	JML $029B84		;>Handle tile prop and number and we are done.
	
	.NoOAM
		PLY
		PLB
	.CODE_029BA5
		SEP #$20
		JML $029BA5
	.CODE_029BDA
	.Despawn
		SEP #$20
		JML $029BDA
CloudCoin: ;JML from $029CF8
	LDA $1715|!addr,x	;\$01-$02: Y position
	SEC			;|
	SBC $1C			;|
	STA $01			;|
	LDA $1729|!addr,x	;|
	SBC $1D			;|
	STA $02			;/
	REP #$20
	LDA $01
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	SEP #$20
	LDA $171F|!addr,x	;\$03-$04: X position
	SEC			;|
	SBC $1A			;|
	STA $03			;|
	LDA $1733|!addr,x	;|
	SBC $1B			;|
	STA $04			;/
	REP #$20
	LDA $03
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	LDY !RAM_ExtOAMIndex
	.OAM
		PHB				;>Preserve bank of SMW code where my hijack is at
		PHK				;\Switch bank to use the bank of the following table
		PLB				;/
		PHY				;>Preserve OAM index Y
		LDA $170B|!addr,x
		AND #$00FF
		ASL
		TAY
		LDA $01				;\Y position -1 because sprite OAM are shifted 1 px lower
		DEC				;/
		CMP NoDrawOAMBoundary-2,y	;\Y offscreen
		BMI ..NoOAM			;|
		CMP.w #$00E0-1			;|>Because of the Y-1, this position must be shifted as well.
		BPL ..NoOAM			;/
		LDA $03				;\X offscreen
		CMP NoDrawOAMBoundary-2,y	;|
		BMI ..NoOAM			;|
		CMP #$0100			;|
		BPL ..NoOAM			;/
		SEP #$20
		PLY				;>Restore OAM index Y
		
		..XPos
			LDA $03			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $04			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $01			;\Y position
			STA $0201|!addr,y	;/
			BRA ..NoOAMSkipPullY
	
		..NoOAM
			PLY
			PLB
			SEP #$20
			JML $029D44
		..NoOAMSkipPullY
	PLB					;>Restore bank
	SEP #$20
	JML $029D20
	.Despawn
		SEP #$20
		JML $029D5A
WigglerFlower: ;JML from $029D27
	;Since we obtain our 16-bit position from a hijack at $029CF8
	;We have:
	;$01-$02: Y position
	;$03-$04: X position
	REP #$20
	LDA $01
	SEC
	SBC #$0005
	CMP #$FFF8
	BMI .NoOAM
	CMP.w #$00E0-1
	BPL .NoOAM
	SEP #$20
	STA $0201|!addr,y
	JML $029D2F
	.NoOAM
		JML $029D44
LavaSplash: ;JML from $029EA0
	LDA $171F|!addr,x	;\$00-$01: X position
	SEC			;|
	SBC $1A			;|
	STA $00			;|
	LDA $1733|!addr,x	;|
	SBC $1B			;|
	STA $01			;/
	REP #$20
	LDA $00
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	SEP #$20
	LDA $1715|!addr,x	;\$02-$03: Y position
	SEC			;|
	SBC $1C			;|
	STA $02			;|
	LDA $1729|!addr,x	;|
	SBC $1D			;|
	STA $03			;/
	REP #$20
	LDA $02
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	.OAM
		PHB				;>Preserve bank of SMW code where my hijack is at
		PHK				;\Switch bank to use the bank of the following table
		PLB				;/
		PHY				;>Preserve OAM index Y
		LDA $170B|!addr,x
		AND #$00FF
		ASL
		TAY
		LDA $02				;\Y position -1 because sprite OAM are shifted 1 px lower
		DEC				;/
		CMP NoDrawOAMBoundary-2,y	;\Y offscreen
		BMI ..NoOAM			;|
		CMP.w #$00E0-1			;|>Because of the Y-1, this position must be shifted as well.
		BPL ..NoOAM			;/
		LDA $00				;\X offscreen
		CMP NoDrawOAMBoundary-2,y	;|
		BMI ..NoOAM			;|
		CMP #$0100			;|
		BPL ..NoOAM			;/
		SEP #$20
		PLY				;>Restore OAM index Y
		
		..XPos
			LDA $00			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $01			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $02			;\Y position
			STA $0201|!addr,y	;/
			BRA ..NoOAMSkipPullY
		
		..NoOAM
			PLY
		..NoOAMSkipPullY
	PLB					;>Restore bank
	SEP #$20
	JML $029EC1
	
	
	.Despawn
		SEP #$20
		JML $029EE6
WaterBubble: ;JML from $029F2A
;Interesting thing to note: The offscreen check checks the sprite's position as normal (non-offset
;position), but the drawn tiles are offset by a table at $029EEA horizontally and Y+5 at $029F52 after
;getting the base extended sprite values (including the non-offset positions) from calling $02A1A4.

;$02A1B1 is hijacked within $02A1A4 btw, so we don't need to expand the no-despawn-zone here.

;The code at $02A1A4 already have an offscreen check (deletes the sprite when outside the screen),
;which that checks the extended sprite's non-offset position. Therefore I have to rewrite this
;entire thing from scratch.
	PHK
	PEA.w .jslrtsreturn-1
	PEA $A772-1		;>RTL at $02A772
	JML $02A1A4		;>Extended sprite base code (which is now hijacked at $02A1B1)
	.jslrtsreturn

	LDA.W $1765|!addr,X		;\$00 = horizontal displacement (offset)
	AND.B #$0C			;|
	LSR				;|
	LSR				;|
	TAY				;|
	LDA.W $029EEA,Y			;|
	STA $00				;/
	.OAMHighByte
		BMI ..NegativeX			;\Add a high byte to make this a signed 16-bit number
		..PositiveX
			STZ $01
			BRA ..Skip
			
		..NegativeX
			LDA #$FF
			STA $01
		..Skip				;/
	LDA $1733|!addr,x		;\This mimicks a part of the code in $02A1A4 that deals with simply
	XBA				;|getting their onscreen OAM X position at $02A1B1.
	LDA $171F|!addr,x		;|
	REP #$20			;|
	SEC				;|
	SBC $1A				;/
	CLC				;\...And move by offset
	ADC $00				;/
	STA $00				;>$00-$01 = 16-bit X position of the OAM tile would be at relative to the screen, with offset.
	SEP #$20
	LDA $1729|!addr,x		;\This mimicks a part of the code in $02A1A4 that deals with simply
	XBA				;|getting their onscreen OAM Y position at $02A1C0.
	LDA $1715|!addr,x		;|
	REP #$20			;|
	SEC				;|
	SBC $1C				;/
	CLC				;\...And move by offset
	ADC #$0005			;/
	STA $02				;>$02-$03 = 16-bit Y position of the OAM tile would be at relative to the screen, with offset.

	LDY !RAM_ExtOAMIndex		;>Y = OAM index
	;We now have our 16-bit OAM XY position in $00-$01 and $02-$03.
	;We need to write our own OAM handler aside from "ExtendedSpriteBaseCode"
	;only takes the non-offset positions.
	.CheckIfTileOnScreen
		LDA $00
		CMP #$FFF8
		BMI .NoOAM
		CMP #$0100
		BPL .NoOAM
		LDA $02
		CMP #$FFF8
		BMI .NoOAM
		CMP.w #$00E0-1
		BPL .NoOAM
	.DrawOAMXY
		SEP #$20
		..XPos
			LDA $00			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $01			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $02			;\Y position
			STA $0201|!addr,y	;/
			BRA .SkipNoOAM
	.NoOAM
		SEP #$20
		LDA #$F0			;\Had to write this because the non-offset Y pos
		STA $0201|!addr,y		;/may be set this to non $F0 values when the offsetted image is offscreen
	.SkipNoOAM
		SEP #$20
	.DrawOAMTileNumb
		LDA #$1C
		STA $0202|!addr,y
	JML $029F60
MarioFireballDespawnHandler: ;JML from $029FB3
	REP #$20
	LDA $00
	PHA
	LDA $02
	PHA
	SEP #$20
	LDA $1715|!addr,x	;\$00-$01: Y position
	SEC			;|
	SBC $1C			;|
	STA $00			;|
	LDA $1729|!addr,x	;|
	SBC $1D			;|
	STA $01			;/
	REP #$20
	LDA $00
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	;REP #$20
	PLA
	STA $02
	PLA
	STA $00
	SEP #$20
	JML $029FC2
	.Despawn
		;REP #$20
		PLA
		STA $02
		PLA
		STA $00
		SEP #$20
		JML $02A211
BaseballDespawnAndOAM: ;JML from $02A271
	LDY !RAM_ExtOAMIndex	;>My hijack happens to occur before it even gets the OAM index.
	LDA $171F|!addr,x	;\$00-$01: X position on screen
	SEC			;|
	SBC $1A			;|
	STA $00			;|
	LDA $1733|!addr,x	;|
	SBC $1B			;|
	STA $01			;/
	REP #$20
	;Interisting info to note: In the original game, the baseballs (thrown from pitchin' chuck)
	;do not get deleted offscreen if they are going in one direction away opposite from the edges
	;of the screen (if they're going left, then the right edge of the screen will not despawn them)
	.DespawnHoriz
		..DespawnHandlerLeftEdge
			LDA $00
			CMP #!Despawn_LeftEdge
			BPL ..DespawnHandlerRightEdge
			SEP #$20
			LDA $1747|!addr,x
			BMI .DespawnBaseball
			REP #$20
		..DespawnHandlerRightEdge
			LDA $00
			CMP #!Despawn_RightEdge
			BMI ..NoDespawnHoriz
			SEP #$20
			LDA $1747|!addr,x
			BPL .DespawnBaseball
		..NoDespawnHoriz
	SEP #$20
	LDA $1715|!addr,x	;\$02-$03: Y position on screen
	SEC			;|
	SBC $1C			;|
	STA $02			;|
	LDA $1729|!addr,x	;|
	SBC $1D			;|
	STA $03			;/
	REP #$20
	LDA $02
	CMP #!Despawn_Top
	BMI .DespawnBaseball
	CMP #!Despawn_Bottom
	BPL .DespawnBaseball
	SEP #$20
	.ShouldItBeDrawn
		PHB				;>Preserve bank of SMW code where my hijack is at
		PHK				;\Switch bank to use the bank of the following table
		PLB				;/
		PHY				;>Preserve Y index (OAM index)
		LDA $170B|!addr,x		;\Get left boundary index
		ASL				;|
		TAY				;/
		REP #$20
		LDA $00				;\Check if OAM tile is offscreen horizontally
		CMP NoDrawOAMBoundary-2,y	;|
		BMI .NoOAM			;|
		CMP #$0100			;|
		BPL .NoOAM			;/
		LDA $02				;\Same but vertically
		CMP NoDrawOAMBoundary-2,y	;|
		BMI .NoOAM			;|
		CMP.w #$00E0-1			;|
		BPL .NoOAM			;/
		SEP #$20
		PLY				;>Restore Y index (OAM index)
		PLB				;>Restore bank
	.HandleOAM
		LDA $00			;\Bits 0-7 X position
		STA $0200|!addr,y	;/
		TYA			;\Bit 8 X position
		LSR #2			;|
		PHY			;|
		TAY			;|
		LDA $01			;|
		AND.b #%00000001	;|
		STA $0420|!addr,y	;|
		PLY			;/
		LDA $02			;\Y position
		STA $0201|!addr,y	;/
	.Done
		JML $02A2A3
	.NoOAM
		SEP #$20
		PLY				;>Restore Y index (OAM index)
		PLB
		JML $02A2BE
	
	
	.DespawnBaseball
	SEP #$20
	JML $02A2BF
SmokePuffDespawnAndOAM: ;JML from $02A36C
	LDA $171F|!addr,x	;\$00-$01: X position
	SEC			;|
	SBC $1A			;|
	STA $00			;|
	LDA $1733|!addr,x	;|
	SBC $1B			;|
	STA $01			;/
	REP #$20
	LDA $00
	CMP #!Despawn_LeftEdge
	BMI .Despawn
	CMP #!Despawn_RightEdge
	BPL .Despawn
	SEP #$20
	LDA $1715|!addr,x	;\$02-$03: Y position
	SEC			;|
	SBC $1C			;|
	STA $02			;|
	LDA $1729|!addr,x	;|
	SBC $1D			;|
	STA $03			;/
	REP #$20
	LDA $02
	CMP #!Despawn_Top
	BMI .Despawn
	CMP #!Despawn_Bottom
	BPL .Despawn
	
	LDA $00
	CMP #$FFF0
	BMI .NoOAM
	CMP #$0100
	BPL .NoOAM
	LDA $02
	CMP #$FFF0
	BMI .NoOAM
	CMP.w #$00E0-1
	BPL .NoOAM
	.DrawOAMXY
		SEP #$20
		..XPos
			LDA $00			;\Bits 0-7 X position
			STA $0200|!addr,y	;/
			TYA			;\Bit 8 X position
			LSR #2			;|
			PHY			;|
			TAY			;|
			LDA $01			;|
			AND.b #%00000001	;|
			STA $0420|!addr,y	;|
			PLY			;/
		..YPos
			LDA $02			;\Y position
			STA $0201|!addr,y	;/
	.Done
		JML $02A386
	
	.NoOAM
		SEP #$20
		JML $02A3AA	;>Skip all tile write-related code
	
	.Despawn
		SEP #$20
		JML $02A211
SetOnlySizeBitX:
	;In the original game, it sets the entire byte to %00000010,
	;therefore clearing the high bit of the X position. This means
	;it's X position is restricted to a screen graphically.
	LDA $0420|!addr,x
	AND.b #%00000011		;>Just in case a 0.001% that some random code would set any bits in bits 2-7
	ORA.b #%00000010		;>Set only the size bit.
	STA $0420|!addr,x
	RTL
	
ClearOnlySizeBitY:
	LDA $0420|!addr,y
	AND.b #%00000001
	STA $0420|!addr,y
	RTL
SetOnlySizeBitY:
	LDA $0420|!addr,y
	AND.b #%00000011		;>Just in case a 0.001% that some random code would set any bits in bits 2-7
	ORA.b #%00000010		;>Set only the size bit.
	STA $0420|!addr,y
Set0460OnlySizeBitY:
	LDA $0460|!addr,y
	ORA.b #%00000010
	STA $0460|!addr,y
	RTL