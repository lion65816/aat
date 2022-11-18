;;;;;;;;;;;;;;;
; DeathWarp_1D6.asm
; Warp scrolls the player to the most recently activated checkpoint upon death.
; Note: Won't work in levels with horizonal scrolling disabled.
; Code by PSI Ninja (inspired by Mandew's "Live Respawn" patch).
;;;;;;;;;;;;;;;

;;;;;;;;;;;;
; Free RAM ;
;;;;;;;;;;;;

!IsWarping = $18C5|!addr
!FrozenTimer = $18C6|!addr
!DiedOnce = $18C7|!addr
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

!LevelStartXPosition = $0010	;\ Default restart point for Level 1D6.
!LevelStartYPosition = $0150	;/

!FramesToWait = $1E		;> How long Demo should remain in her frozen death pose before warping. (1E = 30 frames)
!WarpSpeed = $0008		;\ How fast Demo should warp (in pixels per frame) while dying.
				;/ Note: Must be a power of 2 below 16 (i.e., 1, 2, 4, or 8), or else Demo will overshoot the destination.

;;;;;;;;
; Code ;
;;;;;;;;

init:
	STZ !IsWarping
	STZ !FrozenTimer
	STZ !DiedOnce
	REP #$20
	LDA #!LevelStartXPosition
	STA !RespawnX
	LDA #!LevelStartYPosition
	STA !RespawnY
	SEP #$20
	RTL

main:
	LDA $71				;> Load the player animation trigger state.
	CMP #$09			;\ If the player isn't dying...
	BEQ +				;| ...exit the code.
	JMP exit			;/
+
	LDA !IsWarping			;\ If the player is warping (!IsWarping is 1),
	BNE +				;/ then skip the following Map16 part of the code.

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
	CLC				;\ Shift the Map16 tile's y-coordinate down by one tile from the player's death location.
	ADC #$0010			;/
	STA $98				;> Store the 16-bit y-coordinate for the Map16 tile to be generated.
	LDA #$1642			;> Load the Map16 value of the Demo's body tile.
	JSR change_map16		;> With the (x,y)-coordinates and the Map16 value set, we can now update the Map16 to Demo's body tile.

	LDA $98				;\ Demo's death sprite is two tiles high! We don't want the top of Demo's head to overwrite an existing body tile.
	SEC				;|
	SBC #$0010			;|
	STA $98				;| Store the 16-bit y-coordinate for the Map16 tile above Demo's body tile that was just written.
	STZ $1933|!addr			;| The Map16 tile is on Layer 1 (need to store zero to this address).
	JSR get_map16			;| Lookup the Map16 tile based on the (x,y)-coordinates and layer, and return the 16-bit value in A.
	REP #$20			;| Reset A to 16-bit.
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
+
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

;	LDA !DiedOnce			;|
;	BNE ++				;|
;	LDA #$6F			;| ...and change the level music, but only upon the first death.
;	STA $1DFB|!addr			;| (Note: Causes an abrupt pause while loading the track.)
;					;/ (See: https://www.smwcentral.net/?p=viewthread&t=93349&page=1&pid=1466288#p1466288 and https://www.smwcentral.net/?p=viewthread&t=94964)
;	LDA #$01			;\ Make sure the music change only happens once per level load, to avoid restarting the music upon every death.
;	STA !DiedOnce			;/ (Note: Needs to be used together with a hijack for the death routine.)
;++
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
