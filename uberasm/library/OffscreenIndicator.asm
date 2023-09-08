; Offscreen indicator. Displays a small sprite at the top/bottom of the screen to show where Mario is when he's offscreen.
;  Change the settings below as you need to, then insert with UberASM as either level asm or gamemode asm (for mode 14).
; PSI Ninja edit: Made modifications to instead draw the indicator for sprites that are vertically offscreen.
; Note: All SA-1 sprite table remappings are found in PIXI's sa1def.asm file.

;;;;;;;;;;;;;;;;
;;; Settings ;;;
;;;;;;;;;;;;;;;;

; Tile and YXPPCCCT for the marker when Mario is above the screen.
!tileAbove  =   $1D     ; Tile number
!propsAbove =   $24     ; YXPPCCCT properties

; Tile and YXPPCCCT for the marker when Mario is below the screen.
!tileBelow  =   $0A     ; Tile number
!propsBelow =   $24     ; YXPPCCCT properties

; How many pixels the tile should be offset from the very top/bottom of the screen.
;  Use this if you want a small gap between the very edge and the actual tile.
!yOffAbove  =   $30     ; From the top of the screen
!yOffBelow  =   $02     ; From the bottom of the screen

;;;;;;;;;;;;;;;;;;;;;;;;;

!oamIndex   =   $0000   ; OAM index (from $0200) to use.
    ; ^ don't touch this one unless you know how it works.
    ;   this default value isn't really used by much so it should be fine.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!distL	=	$0010	; distance to check offscreen on the left (0010 = 1 16x16 tiles)
!distR	=	$0010	; distance to check offscreen on the right

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
	;> Wrapper code to iterate through all sprite slots.
	;> Note: There are 12 (0xB) sprite slots in LoROM (for most sprite headers). For SA-1, there are 22 (0x16) sprite slots.
	;> Source: https://www.smwcentral.net/?p=viewthread&t=30203&page=1&pid=445658#p445658
	PHB : PHK : PLB
	;LDX #$0B
	LDX #$16				;> Set up loop counter (number of sprite slots). This is the initial sprite slot index to check.

check_offscreen:
	;LDA $14C8|!addr,x
	LDA $3242,x				;\ Check the sprite status table for the current sprite slot index. For SA-1: $14C8 -> $3242
	BEQ next_slot				;/ If it doesn't exist (status is 0), then check the next slot.

	;> Otherwise, if a sprite exists, check if it's vertically offscreen. If so, then the carry is set.
	;> Source: https://www.smwcentral.net/?p=viewthread&t=97046&page=1&pid=1496648#p1496648
	;LDA $14D4|!addr,x
	LDA $3258,x				;> Load the high bytes of the sprite's Y position (screen number). For SA-1: $14D4 -> $3258
	XBA
	;LDA $D8,x
	LDA $3216,x				;> Load the low bytes of the sprite's Y position (screen position in pixels). For SA-1: $D8 -> $3216
	REP #$20
	SEC : SBC $1C
	CLC : ADC #!distL
	CMP #$0100+!distL+!distR
	SEP #$20

	BCS draw_indicator			;> If a sprite exists and it's vertically offscreen, then draw the offscreen indicator.

next_slot:
	DEX					;> Decrement the loop counter (the sprite slot index).
	;CPX #$00
	CPX #$FF				;\ If the sprite slot index underflowed from 0x00 to 0xFF, then we have finished checking all the sprite slots.
	BEQ exit				;/ Note: Indexing includes 0, so we can't skip over it.
	BRA check_offscreen			;> Otherwise, there are still sprite slots to check.

draw_indicator:
	;> Draw an indicator at the top of the screen that charts an offscreen sprite's X position.
	;> Source: OffscreenIndicator.asm
	LDY #$00				;> Register Y indexes where to draw the indicator (initially, it will draw at the top of the screen).

	LDA $3258,x				;\
	XBA					;| Similar code segment as with "check_offscreen".
	LDA $3216,x				;| This time, we increment the register Y index to draw the indicator at the bottom of the screen
	REP #$20				;| if the sprite's Y position is below the layer 1 Y position (16-bit value stored in $1C).
	CMP $1C					;|
	SEP #$20				;|
	BCC skip				;|
	INY					;/

skip:
	;LDA $E4,x
	LDA $322C,x				;> Load the low bytes of the sprite's X position. For SA-1: $E4 -> $322C
	CLC : ADC #$04				;> Offset to center the indicator tile under the sprite. Note: Currently hardcoded for smaller, 16x16 sprites.
	PHA					;\
	TXA					;| Need to do some math to account for multiple offscreen sprites, and fit their indicators into their own OAM slots.
	ASL A					;| First, we preserve A on the stack, which currently holds the indicator's X position.
	ASL A					;| Then we copy the sprite slot index (held in index register X) to A, because we can't perform math on index registers.
	TAX					;| Finally, we multiply the sprite slot index by 4 (each OAM slot is offset by 4 bytes), copy it back to the X register, then restore A.
	PLA					;/
	STA $0200|!addr+!oamIndex,x		;> Byte 1 of first OAM slot: store the X coordinate of the upper left corner of the indicator tile.
	LDA yOffs,y
	STA $0201|!addr+!oamIndex,x		;> Byte 2 of first OAM slot: store the Y coordinate of the upper left corner of the indicator tile.
	LDA Tiles,y
	STA $0202|!addr+!oamIndex,x		;> Byte 3 of first OAM slot: the lower 8 bits of the indicator tile number.
	LDA Props,y
	STA $0203|!addr+!oamIndex,x		;> Byte 4 of first OAM slot: the YXPPCCCT data.
	TXA					;\
	LSR A					;| Restore the previous value of the X register before it was multiplied by 4 above (i.e., the original sprite slot number).
	LSR A					;|
	TAX					;/
	STZ $0420|!addr+(!oamIndex/4),x		;> OAM extra bits associated with this OAM slot. Stores 00000000, where bit 0 = 0 (the high (9th) bit of the X position), and bit 1 = 0 (size is 8x8).

	BRA next_slot				;> Finished processing this offscreen sprite. Need to check the other sprite slots, too.
exit:
	PLB
	RTL

Tiles:
    db !tileAbove,!tileBelow
Props:
    db !propsAbove,!propsBelow
yOffs:
    db !yOffAbove,$D7-!yOffBelow
