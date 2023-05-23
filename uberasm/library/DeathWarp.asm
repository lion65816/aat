;;;;;;;;;;;;;;;
; DeathWarp.asm
; Warp scrolls the player to the most recently activated checkpoint upon death,
; and changes the level palette and music upon the first death.
; Note: Won't work in levels with horizonal scrolling disabled.
; Code by PSI Ninja (inspired by Mandew's "Live Respawn" patch).
;;;;;;;;;;;;;;;

;;;;;;;;;;;;
; Free RAM ;
;;;;;;;;;;;;

!DeathPointer = $0DDB|!addr
!HPSettings = $188A|!addr
!IsWarping = $18C5|!addr
!FrozenTimer = $18C6|!addr
!DiedOnce = $18C7|!addr
!StartingColorCounter = $18C8|!addr
!ColorCounter = $18C9|!addr
!PaletteFrames = $18CB|!addr
!RetryRequested = $18CC|!addr	;> Important: Also referenced in the retry_config/code/in_level.asm. May need to protect this FreeRAM address?
!RespawnX = $1923|!addr		;\ 2 bytes each
!RespawnY = $1926|!addr		;/

;;;;;;;;;;;
; Defines ;
;;;;;;;;;;;

!bank = $000000

!PlayerXPositionNext = $94
!PlayerYPositionNext = $96
!PlayerXPositionNow = $D1
!PlayerYPositionNow = $D3

!LevelStartXPosition = $01F0	;\ Default restart point for Level 1D0.
!LevelStartYPosition = $0160	;/

!PaletteSpeed = $03		;> How many frames to wait before a palette row is updated.
!FramesToWait = $1E		;> How long Demo should remain in her frozen death pose before warping. (1E = 30 frames)
!WarpSpeed = $0008		;\ How fast Demo should warp (in pixels per frame) while dying.
				;/ Note: Must be a power of 2 below 16 (i.e., 1, 2, 4, or 8), or else Demo will overshoot the destination.

; Starting from $5D80.
BackgroundColor:
	dw $4940,$4940,$4940
	dw $38E0,$38E0,$38E0
	dw $24A0,$24A0,$24A0
	dw $1440,$1440,$1440
	dw $0000,$0000,$0000

; (palette #, color #)
StartingColor:
	db $02,$22,$32
	db $02,$22,$32
	db $02,$22,$32
	db $02,$22,$32
	db $02,$22,$32

; (set 1 = palette 0, set 2 = palette 2, set 3 = palette 3)
PaletteTable:
	dw $0920,$0984,$09C8,$0A0C,$0A92,$0EF6, $0000,$10C8,$1D4D,$29D2,$3A77,$4F1C, $0000,$10AB,$18CD,$2170,$29F2,$3675
	dw $04E0,$1145,$15A9,$15ED,$0E72,$1B16, $0000,$14C7,$214C,$2DD1,$3276,$4B1B, $0000,$0C8E,$10B0,$1974,$21F6,$2A97
	dw $0480,$1925,$1D89,$1DED,$1672,$2717, $0000,$18C7,$254B,$2DAF,$2E55,$471A, $0000,$0851,$0C74,$1158,$15F9,$1ABA
	dw $0040,$1CE5,$2569,$25CD,$1E53,$3318, $0000,$20C6,$294A,$2DAE,$2654,$4319, $0000,$0433,$0458,$095B,$0E1C,$0EFD
	dw $0000,$24C5,$2D49,$2DAD,$2253,$3F18, $0000,$24C5,$2D49,$2DAD,$2253,$3F18, $0000,$0016,$001B,$015F,$021F,$031F

; Defines needed for the retry button (pressing L+R).
; Source: teleport_button.asm (part of Teleport Pack by Alcaro and MarioE)
!controller	= $17		; Up, Down, Left, Right, B, X or Y, Start, Select => $16
				; A, X, L, R => $18
!mask		= $30		; Up = $08,	Down = $04,	Left = $02,	Right = $01
				; B = $80,	X or Y = $40,	Select = $20,	Start = $10
				; A = $80,	X = $40,	L = $20,	R = $10

;;;;;;;;
; Code ;
;;;;;;;;

init:
	; Set up death pointer to the "respawn" label/address.
	LDA.b #respawn     : STA !DeathPointer
	LDA.b #respawn>>8  : STA !DeathPointer+1
	LDA.b #respawn>>16 : STA !DeathPointer+2

	; Various initial settings for flags and starting positions.
	STZ !IsWarping
	STZ !FrozenTimer
	STZ !DiedOnce
	STZ !StartingColorCounter
	STZ !ColorCounter
	STZ !PaletteFrames
	STZ !RetryRequested
	REP #$20
	LDA #!LevelStartXPosition
	STA !RespawnX
	LDA #!LevelStartYPosition
	STA !RespawnY
	SEP #$20
	RTL

main:
	LDA #$40 : STA !HPSettings	;> Set bit 6 to activate custom death code (via the Simple HP system). Needs to be done every frame!

	LDA !RetryRequested		;\ If the player requested a retry by pressing select, then don't do the death warp.
	BEQ +				;| Needed for the UberASM Retry System.
	JMP exit			;/
+
	LDA $9D				;\
	ORA $13D4|!addr			;| If the game is paused, then don't check if the player is requesting a retry (pressing Select).
	BNE +				;/
	LDA !controller			;\
	AND #!mask			;| If the player presses Select, then take a death and exit to the overworld.
	CMP #!mask			;|
	BNE +				;|
	LDA #$01			;|
	STA !RetryRequested		;|
	JML respawn			;|
;	LDA #$01			;|
;	STA !DiedForReal		;|
;	JMP exit			;/ We don't need to process the death warp code anymore.
+
	LDA !DiedOnce			;\
	BEQ +				;/ If Demo didn't die in this level yet, then skip the palette subroutine.
	INC !PaletteFrames		;\ Otherwise, check if we are updating the palettes this frame.
	LDA !PaletteFrames		;|
	CMP #!PaletteSpeed		;| 
	BNE +				;/ If not, then skip to the player death checks.
	STZ !PaletteFrames		;\ Otherwise, prepare for the palette uploads. First, reset the palette delay counter.
	LDA !StartingColorCounter	;| Then, get the current index into the StartingColor table.
	CMP #$0F			;| The total number of palette uploads that need to happen.
	BEQ +				;| If we finished uploading all palettes, then we don't need to run the palette subroutine anymore.
	JSR upload_palettes		;| Otherwise, run the palette subroutine.
	INC !StartingColorCounter	;/ Increment the index into the StartingColor table.

;;;;; Todo: Change back the music after the star runs out. For some reason, the music playback doesn't sound right.
;+
;	LDA $1490|!addr			;\
;	STA $0F48|!addr			;| (Debug.)
;	CMP #$1E			;| If the star timer reaches 1E...
;	BNE +				;|
;	LDA #$6F			;| ...then change the level music back.
;	STA $1DFB|!addr			;| (Note: This is hard-coded to play back the second track, not the first (which cannot happen, anyway).)

+
	LDA $71				;> Load the player animation trigger state.
	CMP #$09			;\ If the player isn't dying...
	BEQ +				;| ...exit the code.
	JMP exit			;/
+
	LDA !IsWarping			;\ If the player is not warping (!IsWarping is 0),
	BEQ +				;| then process Demo's Map16 death tiles.
	JMP continue_warping		;/ Else, if Demo is warping, then continue warping her back to her respawn point.
+

	; When dying, snap the player to the nearest tile, then spawn Map16 Demo blocks in the same location.
	; We need to do this, because we can't create Map16 tiles in offset positions.
	REP #$20			;> Reset A to 16-bit.
	LDA !PlayerXPositionNow
	;AND #$FFF0
	AND #$000F			;> Isolate the pixel value of the x-coordinate.
	CMP #$0008			;\ Branch if the pixel is in the right half of the tile (i.e., 8 and above).
	BCS round_up_x			;/
	LDA !PlayerXPositionNow		;\
	AND #$FFF0			;| Else, we snap Demo's position to the first pixel of the tile.
	BRA round_finished_x		;/
round_up_x:
	LDA !PlayerXPositionNow		;\
	AND #$FFF0			;| Snap Demo's position to the first pixel one tile to the right.
	CLC				;|
	ADC #$0010			;/
round_finished_x:
	STA !PlayerXPositionNow
	STA !PlayerXPositionNext
	STA $9A				;> Store the 16-bit x-coordinate for the Map16 tile to be generated.
	LDA !PlayerYPositionNow
	AND #$FFF0

;;;;; Todo: More precise y-coordinate tile snapping (if using this, uncomment the above line: "AND #$FFF0").
;;;;; Issues: Creates cutoff with the lava tiles (since Demo has to dip into them relatively deep before dying),
;;;;; (?) and the below code with the combined body/head tile would need to be modified.
;	AND #$000F			;> Isolate the pixel value of the y-coordinate.
;	CMP #$0008			;\ Branch if the pixel is in the bottom half of the tile (i.e., 8 and above).
;	BCS round_up_y			;/
;	LDA !PlayerYPositionNow		;\
;	AND #$FFF0			;| Else, we snap Demo's position to the first pixel of the tile.
;	BRA round_finished_y		;/
;round_up_y:
;	LDA !PlayerYPositionNow		;\
;	AND #$FFF0			;| Snap Demo's position to the first pixel one tile below.
;	CLC				;|
;	ADC #$0010			;/
;round_finished_y:
;;;;;

	STA !PlayerYPositionNow
	STA !PlayerYPositionNext

	STA $98				;\ Store the 16-bit y-coordinate for Demo's death location.
	STZ $1933|!addr			;| Process Layer 1 tiles (i.e., store zero to this address). Needed for subsequent calls to the "get_map16" routine.
	JSR get_map16			;/ Lookup the Map16 tile based on the (x,y)-coordinates and layer, and return the 16-bit value in A.
	REP #$20			;> Reset A to 16-bit.
	CMP #$1654			;\ If the tile is the respawn point for the second midpoint, then don't draw Demo's Map16 death tiles.
	BEQ +++				;/ Otherwise, a softlock will occur (Demo will constantly get crush-killed by her own body tile).

	LDA $98				;> Load the y-coordinate for Demo's death location.
	CLC				;\ Shift the Map16 tile's y-coordinate down by one tile from the player's death location.
	ADC #$0010			;/
	STA $98				;> Store the 16-bit y-coordinate for the Map16 tile to be generated.
	JSR get_map16			;\ First, check if the new tile's location is the respawn point for the second midpoint.
	CMP #$1654			;| If so, then don't draw Demo's Map16 death tiles.
	BEQ +++				;/ Otherwise, a softlock will occur if Demo dies underneath it.
	CMP #$1632			;\
	BNE +				;| If Demo's head doesn't occupy the current tile, then just draw the normal body tile.
	LDA #$1643			;| Else, we need to draw the combined body/head tile for Demo.
	JSR change_map16		;|
	BRA demo_head			;/ Perform checks for the drawing the head part of the Demo blocks.
+
	LDA #$1642			;> Load the Map16 value of the Demo's body tile.
	JSR change_map16		;> With the (x,y)-coordinates and the Map16 value set, we can now update the Map16 to Demo's body tile.
demo_head:
	LDA $98				;\ Demo's death sprite is two tiles high! We don't want the top of Demo's head to overwrite an existing body tile.
	SEC				;|
	SBC #$0010			;|
	STA $98				;| Store the 16-bit y-coordinate for the Map16 tile above Demo's body tile that was just written.
	;STZ $1933|!addr		;| The Map16 tile is on Layer 1 (need to store zero to this address).
	JSR get_map16			;| Lookup the Map16 tile based on the (x,y)-coordinates and layer, and return the 16-bit value in A.
	;REP #$20			;| Reset A to 16-bit.
	CMP #$1642			;| If the returned Map16 value is Demo's body tile...
	BEQ ++				;/ ...then replace it with a combined body/head tile to avoid cutoff graphics.
	CMP #$0025			;\ Else, if the tile is not blank, then don't draw the head to avoid additional cutoff graphics.
	BNE +++				;/
	LDA #$1632			;\
	JSR change_map16		;| Else, just draw the tile for the top of Demo's head.
	BRA +++				;/
++
	LDA #$1643			;\ Update the Map16 to a combined body/head Demo tile.
	JSR change_map16		;/
+++
	SEP #$20			;> Set A to 8-bit.

	LDA #$01			;\ After the Map16 routine has finished running,
	STA !IsWarping			;/ trigger the warping sequence.
	LDA #!FramesToWait
	STA !FrozenTimer
	STZ $7B				;\ Zero out the player's (x,y) speed to prevent
	STZ $7D				;/ momentum from carrying over post-warp.
continue_warping:
	LDA #$FF			;\ Keep the player's death timer running (for now).
	STA $1496|!addr			;/ Needed to keep Demo in the "dying" state, otherwise the level will end when the timer runs out.

	LDA !FrozenTimer		;\ If Demo is out of her frozen death pose,
	BEQ +				;| then start moving her position.
	DEC !FrozenTimer		;| Else, decrement the time she remains frozen.
	JMP exit			;/
+
	REP #$20			;> Reset A to 16-bit.

	LDA !PlayerXPositionNext	;\
	;CMP #!LevelStartXPosition	;|
	CMP !RespawnX			;| If the player has reached the starting
	BNE +				;| (x,y) position...
	LDA !PlayerYPositionNext	;|
	;CMP #!LevelStartYPosition	;|
	CMP !RespawnY			;|
	BNE +				;|
	SEP #$20			;|
	STZ $71				;| ...then remove the dying status...

;;;;; Goal walk.
;	LDA $1DFB|!addr
;	CMP #$04
;	BNE continue
;	JSL $00FA80|!bank		;> Run goal walk routine.
;	LDX #$16			;> Set up loop counter (number of sprite slots). This is the initial sprite slot index to check.
;sprite_slot_loop:
;	LDA $3242,x			;\ Check the sprite status table for the current sprite slot index. For SA-1: $14C8 -> $3242
;	BNE next_slot			;/ If it's not empty (status is not 0), then check the next slot.
;STA $0F48|!addr
;	;LDA #$7B
;LDA #$00
;	STA $3200,x			;> For SA-1: $9E -> $3200
;	JSL $07F7D2|!bank
;	LDA #$08			;\ sprite_status, "14C8", $14C8, $3242
;	STA $3242,x			;/
;	LDA #$02			;\ sprite_x_high, "14E0", $14E0, $326E
;	STA $326E,x			;/
;	LDA #$A0			;\ sprite_x_low, "E4", $E4, $322C
;	STA $322C,x			;/
;	LDA #$01			;\ sprite_y_high, "14D4", $14D4, $3258
;	STA $3258,x			;/
;	LDA #$50			;\ sprite_y_low, "D8", $D8, $3216
;	STA $3216,x			;/
;	;JSL $07F7D2|!bank
;	BRA continue
;next_slot:
;	DEX				;> Decrement the loop counter (the sprite slot index).
;	CPX #$FF			;\ If the sprite slot index underflowed from 0x00 to 0xFF, then we have finished checking all the sprite slots.
;	BEQ continue			;/ Note: Indexing includes 0, so we can't skip over it.
;	BRA sprite_slot_loop		;> Otherwise, there are still sprite slots to check.
continue:
;;;;; Goal walk.

	LDA !DiedOnce			;|
	BNE ++				;|
	LDA #$6F			;| ...and change the level music, but only upon the first death.
;LDA #$0A
	STA $1DFB|!addr			;| (Note: Causes an abrupt pause while loading the track.)
					;/ (See: https://www.smwcentral.net/?p=viewthread&t=93349&page=1&pid=1466288#p1466288 and https://www.smwcentral.net/?p=viewthread&t=94964)
;LDA #$FF		;\ Needed when changing the music in-level?
;STA $0DDA|!addr	;/
	LDA #$01			;\ Make sure the music change only happens once per level load, to avoid restarting the music upon every death.
	STA !DiedOnce			;/ (Note: Needs to be used together with a hijack for the death routine.)
++
	STZ $1496|!addr			;> Zero out the player's death timer, to avoid a glitch where Demo slides for a few seconds instead of walking.
	LDA #$7F			;\
	STA $1497|!addr			;| Give the player some invincibility frames.
	STZ !IsWarping			;| Clear the !IsWarping flag, and exit the code.
	BRA exit			;/
+
	LDA !PlayerXPositionNext	;\ If the player died to the left of the starting
	CMP !RespawnX			;| position, then start warping to the right.
	;CMP #!LevelStartXPosition	;|
	BCC warp_right			;|
	LDA !PlayerXPositionNext	;|
	SEC				;|
	SBC #!WarpSpeed			;|
	STA !PlayerXPositionNext	;/ Else, warp to the left.
	BRA +
warp_right:
	LDA !PlayerXPositionNext
	CLC
	ADC #!WarpSpeed
	STA !PlayerXPositionNext
+
	LDA !PlayerYPositionNext	;\ If the player died above the starting
	CMP !RespawnY			;| position, then start warping downwards.
	;CMP #!LevelStartYPosition	;|
	BCC warp_down			;|
	LDA !PlayerYPositionNext	;|
	SEC				;|
	SBC #!WarpSpeed			;|
	STA !PlayerYPositionNext	;/ Else, warp upwards.
	BRA +
warp_down:
	LDA !PlayerYPositionNext
	CLC
	ADC #!WarpSpeed
	STA !PlayerYPositionNext
+
	SEP #$20			;> Set A to 8-bit.
exit:
	RTL

;;;;;;;;;;
; The subroutine below changes a Map16 tile given a 16-bit Y value ($98-99), a 16-bit X value ($9A-9B), and the 16-bit block number (stored in A).
; Note: This was copy/pasted from the equivalent PIXI macro, with a few changes to definitions and labels to make it work with UberASM.
;;;;;;;;;;

!SA1 = 1
!Base2 = $6000
!BankB = $000000
!EXLEVEL = 0

change_map16:
	PHX
	PHP
	REP #$10
	TAX
	SEP #$20
	PHB
	PHY
	PHX
	LDY $98
	STY $0E
	LDY $9A
	STY $0C
	SEP #$30
	LDA $5B
	LDX $1933|!Base2
	BEQ .layer1
	LSR A
.layer1
	STA $0A
	LSR A
	BCC .horz
	LDA $9B
	LDY $99
	STY $9B
	STA $99
.horz
if !EXLEVEL
	BCS .verticalCheck
	REP #$20
	LDA $98
	CMP $13D7|!Base2
	SEP #$20
	BRA .check
endif
.verticalCheck
	LDA $99
	CMP #$02
.check
	BCC .noEnd
	REP #$10
	PLX
	PLY
	PLB
	PLP
	PLX
	SEC
	RTL
	
.noEnd
	LDA $9B
	STA $0B
	ASL A
	ADC $0B
	TAY
	REP #$20
	LDA $98
	AND.w #$FFF0
	STA $08
	AND.w #$00F0
	ASL #2			; 0000 00YY YY00 0000
	XBA			; YY00 0000 0000 00YY
	STA $06
	TXA
	SEP #$20
	ASL A
	TAX
	
	LDA $0D
	LSR A
	LDA $0F
	AND #$01		; 0000 000y
	ROL A			; 0000 00yx
	ASL #2			; 0000 yx00
	ORA #$20		; 0010 yx00
	CPX #$00
	BEQ .noAdd
	ORA #$10		; 001l yx00
.noAdd
	TSB $06			; $06 : 001l yxYY
	LDA $9A			; X LowByte
	AND #$F0		; XXXX 0000
	LSR #3			; 000X XXX0
	TSB $07			; $07 : YY0X XXX0
	LSR A
	TSB $08

	LDA $1925|!Base2
	ASL A
	REP #$31
	ADC $00BEA8|!BankB,x
	TAX
	TYA
if !SA1
    ADC.l $00,x
    TAX
    LDA $08
    ADC.l $00,x
else
    ADC $00,x
    TAX
    LDA $08
    ADC $00,x
endif
	TAX
	PLA
	ASL A
	TAY
	LSR A
	SEP #$20
if !SA1
	STA $400000,x
	XBA
	STA $410000,x
else
	STA $7E0000,x
	XBA
	STA $7F0000,x
endif
	LSR $0A
	LDA $1933|!Base2
	REP #$20
	BCS .vert
	BNE .horzL2
.horzL1
	LDA $1A			;\
	SBC #$007F		; |$08 : Layer1X - 0x80
	STA $08			;/
	LDA $1C			;  $0A : Layer1Y
	BRA +
.horzL2
	LDA $1E			;\ $08 : Layer2X
	STA $08			;/
	LDA $20			;\ $0A : Layer2Y - 0x80
	SBC #$007F		;/
	BRA +
	
.vert
	BNE .vertL2
	LDA $1A			;\ $08 : Layer1X
	STA $08			;/
	LDA $1C			;\ $0A : Layer1Y - 0x80
	SBC #$0080		;/
	BRA +
.vertL2
	LDA $1E			;\
	SBC #$0080		; |$08 : Layer2X - 0x80
	STA $08			;/
	LDA $20			;  $0A : Layer2Y
+
	STA $0A
	PHK
-	PEA.w (-)+9
	PEA $804C
	JML $00C0FB|!BankB
	PLY
	PLB
	PLP
	PLX
	CLC
	RTS

;;;;;;;;;;
; The subroutine below gets a Map16 tile's value based on its 16-bit Y value ($98-99), its 16-bit X value ($9A-9B), and its layer (stored in A).
; Note: This was copy/pasted from the equivalent PIXI macro, with a few changes to definitions and labels to make it work with UberASM.
;;;;;;;;;;

; input:
; $98-$99 block position Y
; $9A-$9B block position X
; $1933   layer
;
; output:
; A Map16 lowbyte (or all 16bits in 16bit mode)
; Y Map16 highbyte

get_map16:
	PHX
	PHP
	REP #$10		; Index registers are 16-bit.
	PHB
	LDY $98
	STY $0E
	LDY $9A
	STY $0C
	SEP #$30		; A, X, and Y are 8-bit.
	LDA $5B
	LDX $1933|!Base2
	BEQ .layer1
	LSR A
.layer1
	STA $0A
	LSR A
	BCC .horz
	LDA $9B
	LDY $99
	STY $9B
	STA $99
.horz
if !EXLEVEL
	BCS .verticalCheck
	REP #$20
	LDA $98
	CMP $13D7|!Base2
	SEP #$20
	BRA .check
endif
.verticalCheck
	LDA $99
	CMP #$02
.check
	BCC .noEnd
	REP #$20		; \ load return value for call in 16bit mode
	LDA #$FFFF		; /
	PLB
	PLP
	PLX
	TAY			; load high byte of return value for 8bit mode and fix N and Z flags
	RTL
	
.noEnd
	LDA $9B
	STA $0B
	ASL A
	ADC $0B
	TAY
	REP #$20
	LDA $98
	AND.w #$FFF0
	STA $08
	AND.w #$00F0
	ASL #2			; 0000 00YY YY00 0000
	XBA			; YY00 0000 0000 00YY
	STA $06
	TXA
	SEP #$20
	ASL A
	TAX
	
	LDA $0D
	LSR A
	LDA $0F
	AND #$01		; 0000 000y
	ROL A			; 0000 00yx
	ASL #2			; 0000 yx00
	ORA #$20		; 0010 yx00
	CPX #$00
	BEQ .noAdd
	ORA #$10		; 001l yx00
.noAdd
	TSB $06			; $06 : 001l yxYY
	LDA $9A			; X LowByte
	AND #$F0		; XXXX 0000
	LSR #3			; 000X XXX0
	TSB $07			; $07 : YY0X XXX0
	LSR A
	TSB $08

	LDA $1925|!Base2
	ASL A
	REP #$31
	ADC $00BEA8|!BankB,x
	TAX
	TYA
if !SA1
    ADC.l $00,x
    TAX
    LDA $08
    ADC.l $00,x
else
    ADC $00,x
    TAX
    LDA $08
    ADC $00,x
endif
	TAX
	SEP #$20
if !SA1
	LDA $410000,x
	XBA
	LDA $400000,x
else
	LDA $7F0000,x
	XBA
	LDA $7E0000,x
endif
	SEP #$30		; A, X, and Y are 8-bit.
	XBA
	TAY
	XBA

	PLB
	PLP
	PLX
	RTS

;;;;;;;;;;
; Dynamically change the palette upon Demo's first death.
; Sources: https://www.smwcentral.net/?p=viewthread&t=105481&page=1&pid=1563356#p1563356
;          https://www.smwcentral.net/?p=viewthread&t=16714 (register $2121)
;;;;;;;;;;

upload_palettes:
	PHB : PHK : PLB
	REP #$20
	LDX !StartingColorCounter	;> Load the current index into the StartingColor table (we can also use it for the BackgroundColor table).
	TXA				;\
	ASL				;| Need to double the index value, since we are using dw instead of db.
	TAX				;/
	LDA BackgroundColor,X		;\ Change background color according to the current position in the table.
	STA $0701|!addr			;/
	SEP #$20

	; Upload changes to the current palette. Can only upload to CGRAM once per frame.
	LDX !StartingColorCounter	;> Load the current index into the StartingColor table.
	LDA #$0C			;\ $0682: number of bytes (=number of colors * 2) (12 bytes)
	STA $0682|!addr			;/
	LDA StartingColor,X		;\ $0683: starting color
	STA $0683|!addr			;/
	REP #$30

	LDY #$0000
-
	CPY #$000C			;\
	BEQ +				;| Loop over the current palette row, adding one color at a time.
	LDX !ColorCounter		;|
	LDA PaletteTable,X		;| End the loop once all 6 colors in the palette row have been added.
	STA $0684|!addr,Y		;| Note that the color counter is incremented by 2, since we are using dw instead of db.
	INC !ColorCounter		;|
	INC !ColorCounter		;|
	INY #2				;|
	BRA -				;/
+
	SEP #$30
	STZ $0690			;> 00 byte to mark the end of the color data
	STZ $0680|!addr			;> $0680 = 0: upload from $0682
	PLB
	RTS

;;;;;;;;;;
; Custom death code, which is partially handled by the Simple HP system.
;;;;;;;;;;

!midpoint1	= $0028		; Secondary exit #28, placed at the first midpoint.
!midpoint2	= $0022		; Secondary exit #22, placed at the first midpoint.
!secondary	= 1		; Secondary exit? 0 = false, 1 = true.
!water		= 0		; If secondary exit, water level? 0 = false, 1 = true.

respawn:
;	LDA !RetryRequested		;\
;	BEQ +				;| Not needed if using the UberASM Retry System.
;	BRA .retry			;/
;+
	LDA !RetryRequested		;\
	BEQ +				;| Keep the music playing while the UberASM Retry System prompt is showing (before the first death).
	BRA .already_died		;/
+
	LDA !DiedOnce			;\ Check if the player died for the first time in this sublevel.
	BNE .already_died		;/ If not, then we don't have to keep restarting the death music for every death.
	LDA #$01			;\ Play the normal death music only for the player's first death.
	STA $1DFB|!addr			;/
	BRA +				;> Skip playing the "Quick Retry" death SFX upon for the first death.
.already_died
	LDA #$20			;\ Play the conventional "Quick Retry" death SFX whenever the player dies after the first death.
	STA $1DF9|!addr			;/
+
	JSR .LoseYoshi			;> Make the player lose Yoshi when riding it.
	LDA #$FF                        ;\ Needed for the "STA.W $0DDA" instruction to follow.
	JML $00F611			;/
	RTL				;> Needs to end with an RTL, because the Simple HP system JMLs to this code section.

; This subroutine is copied mostly from SimpleHP6.asm.
; Not called if using the UberASM Retry System.
.retry
    ;Note: Bank isn't set automatically. But this code can use any bank with RAM access.
    LDA $6DBE : CMP #$05 : BCS +    ;Only run custom death code when the player has more than five lives.
    LDA #$01 : STA $7DFB            ;Restore, set death music 
    LDA #$FF                        ;Restore, some music thing
    JML $00F611                     ;Go back to regular death code. Let player farm lives/handle game over. 
+   DEC $6DBE                       ;Decrease lives
    
    ;Death counter
    PHX
    LDA $610A                       ;Current save slot
    ASL : CLC : ADC $610A           ;Triple
    TAX                             ;Use as index
    LDA $41C7ED,x                   ;Load death counter (lowest byte)
    INC                         ;o:z
    STA $41C7ED,x                   ;Store incremented counter
    BNE +                       ;i:z;If the result was zero, we've wrapped around, and should increment the high bytes too
    REP #$20
    LDA $41C7EE,x                   ;Load death counter (high bytes)
    INC 
    STA $41C7EE,x                   ;Store incremented counter
    SEP #$20
+   PLX
    
    ; Most of the following is copied from the %teleport GPS macro.
    REP #$20
    LDA !RespawnX                   ;\ Decide where to respawn Demo if the player requests a reset.
    CMP #$0570                      ;| If the first midpoint was touched (the respawn_point_1_1d0.asm block was triggered),
    BEQ .midpoint1                  ;| then start Demo at the first midpoint.
    CMP #$0960                      ;| Else, if the first midpoint was touched (the respawn_point_2_1d0.asm block was triggered),
    BEQ .midpoint2                  ;| then start Demo at the second midpoint.
    LDA $010B|!addr                 ;| Else, start Demo at the beginning of the sublevel (load the level/sublevel number).
    BRA +                           ;/
.midpoint1
    LDA #!midpoint1|(((!water<<3)|(1<<2)|(!secondary<<1))<<8) ;> Load secondary exit #28.
    BRA +
.midpoint2
    LDA #!midpoint2|(((!water<<3)|(1<<2)|(!secondary<<1))<<8) ;> Load secondary exit #22.
+
    PHX
    PHY
    PHA

    STZ $88
    SEP #$30

    JSL $03BCDC|!bank

    PLA
    STA $19B8|!addr,x
    PLA
    ORA #$04
    STA $19D8|!addr,x

    LDA #$06
    STA $71

    LDA #$20                        ;\ Play the conventional "Quick Retry" death SFX.
    STA $1DF9|!addr                 ;/

    PLY
    PLX
RTL

;; LoseYoshi:
;;    Taken from GIEPY's routines.
;;    If the player is riding Yoshi, this routine will make him run away as if
;;    hit by an enemy.
;; No input
;; Preserves:
;;    A (8-bit)
;;    X/Y (8-bit)

.LoseYoshi
    PHA
    LDA $187A|!addr                ; If the player is not on Yoshi, return.
    BEQ .noYoshi
    PHX
    PHY
    LDX $18E2|!addr                ; Load index to Yoshi in the sprite tables.
    LDA #$10                        ; Set timer to disable damage to Yoshi.
    STA !sprite_misc_163e-1,x
    LDA #$03                        ; Play sound effects.
    STA $1DFA|!addr
    LDA #$13
    STA $1DFC|!addr
    LDA #$02                        ; Update phase pointer to "running".
    STA !sprite_misc_c2-1,x
    STZ $187A|!addr                ; Clear Yoshi flags.
    STZ $0DC1|!addr
    LDA #$C0                        ; Set player speed.
    STA $7D
    STZ $7B
    LDY !sprite_misc_157c-1,x       ; Set X speed of Yoshi based on his facing.
    PHX : TYX
    LDA $02A4B3|!bank,x
    PLX
    STA !sprite_speed_x-1,x
    STZ !sprite_misc_1594-1,x       ; Cancel tounge animations.
    STZ !sprite_misc_151c-1,x
    STZ $18AE|!addr
    LDA #$30                        ; Give invulnerability to the player.
    STA $1497|!addr
    PLY
    PLX
.noYoshi
    PLA
    RTS
