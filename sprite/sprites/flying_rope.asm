; flying rope by Von Fahrenheit
; this is a line-guided rope mechanism... except it's not line-guided!
; i guess that makes it just a rope mechanism lol
; it moves back and forth like a flying platform, but it can be climbed just like you'd expect
; credit to imamelia for rope mechanism disassembly!
; as usual, extra bit makes the rope longer
; wing and smoke animation rate depends on the sprite's current speed
; the faster it goes, the more smoke comes out and the faster the wings flap (if wings are enabled)

	!maxspeed	= 24

	!wings		= 0	; 0 = no wings, 1 = wings
				; note that wings make the sprite use 2 more OAM tiles, for a total of 8 (short rope) or 12 (long rope)
				; use with caution to avoid sprite flickering

	!accel		= 1	; 0 = acceleration is instant, 1 = acceleration is 1/frame, 2 = acceleration is 1/2frames

	; period variables determine the period of the rope's movement
	; this means each sprite placed in Lunar Magic can have a unique pattern (as long as they're mapped to extra bytes, at least)
	; default of 0000 means the sprite doesn't move at all
	; you can experiment with these to make all sorts of shapes, for example...
	;
	; horizontal line: !horz = 80, !vert = 00
	; vertical line: !horz = 00, !vert = 80
	; horizontal zig-zag: !horz = 80, !vert = 01
	; vertical zig-zag: !horz = 01, !vert = 80
	; diagonal line: !horz = 40, !vert = 40
	;
	; there are way more options, feel free to experiment! this is just to get you started :D

	!horz_period	= !extra_byte_1,x
	!vert_period	= !extra_byte_2,x

	; extra byte 3 determines the directions of the sprite
	; lo nybble affects horizontal direction, hi nybble affects vertical direction
	; X0 = start right, can turn
	; X1 = start left, can turn
	; X2 = go right
	; X3 = go left
	; 0X = start down, can turn
	; 1X = start up, can turn
	; 2X = go down
	; 3X = go up

	; for either one:
	; add 4 to make it start moving after Mario grabs it
	; add 8 to make it move only while Mario is holding it
	; add C to make it move normally but stop while Mario is holding it


	; !157C = horizontal direction
	; !151C = horizontal timer
	; !1528 = vertical direction
	; !1534 = vertical timer

	!grabbed	=	!C2,x	; 00 = never grabbed, 01 = not grabbed now but was previously, 80 = currently grabbed

	!smoketimer	=	!1FE2	; set to prevent sprite from spawning too much smoke and looking silly

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables (old)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MotorTiles:
db $8A,$CE,$8A,$CE

RopeTiles:
db $CE,$AC,$AC,$AC,$AC,$AC,$AC,$AC,$AC

!BottomRopeTile = $CC

!MotorTileProp = $37
!RopeTileProp = $37

SmokeXOffset:
db $F8,$00

XOffsetLo:
db $FC,$04,$FC,$04

XOffsetHi:
db $FF,$00,$FF,$00

YOffsetLo:
db $FC,$FC,$04,$04

YOffsetHi:
db $FF,$FF,$00,$00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
LineRopeInit:
		PHB : PHK : PLB

		LDA !extra_byte_3,x
		AND #$01 : STA !157C,x
		LDA !extra_byte_3,x
		LSR #4
		AND #$01 : STA !1528,x

		%BEC(+)
		INC !1662,x
	+

		INC !1540,x			;
		JSR LineRopeMain		;
		JSR LineRopeMain		;
		INC !1626,x			;

		PLB
		RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR LineRopeMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LineRopeMain:

		LDA !1504,x
		CMP #$10 : BCC NoSmoke
		STZ !1504,x

LDA $02			;
LSR #3			;
AND #$01		; 2 possible X offsets for the smoke
TAY			;
LDA SmokeXOffset,y	; set the X displacement of the smoke
STA $00			;
LDA #$F2			; Y displacement = $F2
STA $01			;

JSR MotorSmoke		; show the smoke

NoSmoke:

LDA $13		;
AND #$07	; every 8 frames...
ORA !1626,x	; if the sprite is moving...
ORA $9D		; and sprites are not locked...
BNE NoSound	;
LDA #$00		; play the ticking sound effect
STA $1DFA|!Base2	;
NoSound:		;
    
JSR LineRopeGFX	; draw the sprite

LDA !E4,x	;
PHA		; preserve the low bytes of the sprite's position
LDA !D8,x	; (why not the high bytes?...)
PHA		;

LDA #$01
%SubOffScreen()

; main code here
; you can tell it's written by me, Von Fahrenheit
; how?
; because i use tabs like a reasonable person >:(

		LDA !sprite_status,x
		SEC : SBC #$08
		ORA $9D : BEQ .Process
		JMP .MainDone

		.Process


	if !accel == 0
		STZ !sprite_speed_x,x
		STZ !sprite_speed_y,x

		LDA !horz_period : BEQ .HDone
		LDA !extra_byte_3,x
		AND #$0C : BEQ .NormH
		CMP #$04 : BEQ .CheckHasBeenGrabbedH
		CMP #$08 : BEQ .CurrentlyGrabbedH
	.NegativeH
		BIT !grabbed : BMI .HDone
		BRA .NormH
	.CurrentlyGrabbedH
		BIT !grabbed : BPL .HDone
		BRA .NormH
	.CheckHasBeenGrabbedH
		LDA !grabbed : BEQ .HDone

	.NormH	LDA !extra_byte_3,x
		AND #$02 : BNE .Horz
		LDA !151C,x
		CMP !horz_period : BEQ .SwapH
		INC !151C,x
		BRA .Horz
	.SwapH	LDA !157C,x
		EOR #$01
		STA !157C,x
		STZ !151C,x
	.Horz	LDY !157C,x
		LDA .SpeedTable,y : STA !sprite_speed_x,x
		.HDone

		LDA !vert_period : BEQ .VDone
		LDA !extra_byte_3,x
		AND #$C0 : BEQ .NormV
		CMP #$40 : BEQ .CheckHasBeenGrabbedV
		CMP #$80 : BEQ .CurrentlyGrabbedV
	.NegativeV
		BIT !grabbed : BMI .VDone
		BRA .NormV
	.CurrentlyGrabbedV
		BIT !grabbed : BPL .VDone
		BRA .NormV
	.CheckHasBeenGrabbedV
		LDA !grabbed : BEQ .VDone

	.NormV	LDA !extra_byte_3,x
		AND #$20 : BNE .Horz
		LDA !1534,x
		CMP !vert_period : BEQ .SwapV
		INC !1534,x
		BRA .Vert
	.SwapV	LDA !1528,x
		EOR #$01
		STA !1528,x
		STZ !1534,x
	.Vert	LDY !1528,x
		LDA .SpeedTable,y : STA !sprite_speed_y,x
		.VDone
		INC !1504,x : INC !1570,x
		INC !1504,x : INC !1570,x
		JSL $01801A|!BankB
		JSL $018022|!BankB
		BRA .MainDone
	.SpeedTable
		db !maxspeed,-!maxspeed



	else
		LDA #$00 : STA !extra_prop_1,x
		LDA !horz_period : BNE $03 : JMP .HDone
		LDA !extra_byte_3,x
		AND #$0C : BEQ .NormH
		CMP #$04 : BEQ .CheckHasBeenGrabbedH
		CMP #$08 : BEQ .CheckCurrentlyGrabbedH
	.NegativeH
		BIT !grabbed : BPL .NormH
		BRA .HDone
	.CheckCurrentlyGrabbedH
		BIT !grabbed : BMI .NormH
		BRA .HDone
	.CheckHasBeenGrabbedH
		LDA !grabbed : BEQ .HDone
		.NormH
		LDA !157C,x : BNE .Right
	.Left	LDA !sprite_speed_x,x
		CMP.b #!maxspeed : BNE .AccR
		LDA !extra_byte_3,x
		AND #$02 : BNE .ApplyH
		LDA !151C,x
		CMP !horz_period : BEQ .SwapH
		INC !151C,x
		BRA .ApplyH
	.AccR	BIT !sprite_speed_x,x : BMI +
		if !accel == 2					;\
			LDA $14					; | conditional: slow acceleration
			LSR A : BCC .ApplyH			; |
		endif						;/
	+	INC !sprite_speed_x,x
		BRA .ApplyH

	.Right	LDA !sprite_speed_x,x
		CMP.b #-!maxspeed : BNE .AccL
		LDA !extra_byte_3,x
		AND #$02 : BNE .ApplyH
		LDA !151C,x
		CMP !horz_period : BEQ .SwapH
		INC !151C,x
		BRA .ApplyH
	.AccL	BIT !sprite_speed_x,x : BPL +
		if !accel == 2					;\
			LDA $14					; | conditional: slow acceleration
			LSR A : BCC .ApplyH			; |
		endif						;/
	+	DEC !sprite_speed_x,x
		BRA .ApplyH

	.SwapH	LDA !157C,x
		EOR #$01
		STA !157C,x
		STZ !151C,x
	.ApplyH	JSL $018022|!BankB
		LDA #$40 : STA !extra_prop_1,x
		.HDone

		LDA !vert_period : BNE $03 : JMP .VDone
		LDA !extra_byte_3,x
		AND #$C0 : BEQ .NormV
		CMP #$40 : BEQ .CheckHasBeenGrabbedV
		CMP #$80 : BEQ .CheckCurrentlyGrabbedV
	.NegativeV
		BIT !grabbed : BPL .NormV
		BRA .VDone
	.CheckCurrentlyGrabbedV
		BIT !grabbed : BMI .NormV
		BRA .VDone
	.CheckHasBeenGrabbedV
		LDA !grabbed : BEQ .VDone
		.NormV
		LDA !1528,x : BNE .Down
	.Up	LDA !sprite_speed_y,x
		CMP.b #!maxspeed : BNE .AccD
		LDA !extra_byte_3,x
		AND #$20 : BNE .ApplyV
		LDA !1534,x
		CMP !vert_period : BEQ .SwapV
		INC !1534,x
		BRA .ApplyV
	.AccD	BIT !sprite_speed_y,x : BMI +
		if !accel == 2					;\
			LDA $14					; | conditional: slow acceleration
			LSR A : BCC .ApplyV			; |
		endif						;/
	+	INC !sprite_speed_y,x
		BRA .ApplyV

	.Down	LDA !sprite_speed_y,x
		CMP.b #-!maxspeed : BNE .AccU
		LDA !extra_byte_3,x
		AND #$20 : BNE .ApplyV
		LDA !1534,x
		CMP !vert_period : BEQ .SwapV
		INC !1534,x
		BRA .ApplyV
	.AccU	BIT !sprite_speed_y,x : BPL +
		if !accel == 2					;\
			LDA $14					; | conditional: slow acceleration
			LSR A : BCC .ApplyV			; |
		endif						;/
	+	DEC !sprite_speed_y,x
		BRA .ApplyV

	.SwapV	LDA !1528,x
		EOR #$01
		STA !1528,x
		STZ !1534,x
	.ApplyV	JSL $01801A|!BankB
		LDA !extra_prop_1,x
		ORA #$80
		STA !extra_prop_1,x
		.VDone

		.Animation
		LDA !extra_prop_1,x : STA $0F
		BEQ .2						; full animation speed when standing still

		LDA.b #!maxspeed
		LSR A
		STA $00
		STZ $02
		LDA !horz_period : BEQ +
		LDA !vert_period : BEQ +
		INC $02						; don't average if only 1 axis is uesd
	+	LDA !sprite_speed_x,x
		BPL $03 : EOR #$FF : INC A
		BIT $0F
		BVS $02 : LDA #$00
		STA $01
		LDA !sprite_speed_y,x
		BPL $03 : EOR #$FF : INC A
		BIT $0F
		BMI $02 : LDA #$00
		CLC : ADC $01
		LDY $02
		BEQ $01 : LSR A
		CMP.b #!maxspeed : BEQ .1
		CMP $00 : BCC .MainDone
	.2	INC !1504,x : INC !1570,x
	.1	INC !1504,x : INC !1570,x
	endif
		.MainDone


		LDA !grabbed : BPL +
		LDA #$01 : STA !grabbed
		+


PLA		;
SEC		;
SBC !D8,x	;
EOR #$FF		;
INC		;
STA $185E|!Base2	;
PLA		;
SEC		;
SBC !E4,x		;
EOR #$FF		;
INC		;
STA $18B6|!Base2	;

LDA $77		;
AND #$03	; if the player is touching a wall...
BNE Return00	; don't interact with the sprite

PHK		; I'm not going to disassemble the code at $01A80F, because...
PER $0006	; well, it's just part of the normal player/sprite interaction subroutine, $01A7DC.
PEA $8020	; The line-guided rope just bypasses the first part of it.
JML $01A80F	;
BCS MaybeClimb	; if the player is touching the sprite, go to the rope interaction routine

NoClimb:		;

LDA !163E,x	; unless the grab timer is already zero...
BEQ Return00	;
STZ !163E,x	; clear it
STZ $18BE|!Base2	; and clear the climb flag as well

Return00:		;
RTS		;

MaybeClimb:

LDA !sprite_status,x		; if the sprite is nonexistent...
BEQ SkipClimbCheck	; skip the next part of code

LDA $1470|!Base2	; if the player is carrying something...
ORA $187A|!Base2	; or on Yoshi...
BNE NoClimb	; don't let him/her climb the rope

LDA #$03		;
STA !163E,x	; set the climb timer

LDA !154C,x	; if interaction is disabled...
BNE Return00	; return

LDA $18BE|!Base2		; if the player is already climbing...
BNE SkipButtonCheck1	; don't check to see if he/she is pressing the up button

		LDA $15		;
		AND #$08	; if the player is pressing Up...
		BEQ Return00	;
		STA $18BE|!Base2	; set the climbing flag

	SkipButtonCheck1:

		BIT $16		; if the player is pressing A or B...
		BPL NoJumpOffRope	;

		LDA #$B0		;
		STA $7D		; make mario go upward

	SkipClimbCheck:

STZ $18BE|!Base2	; clear the climb flag
LDA #$10		;
STA !154C,x	; and disable interaction for a few frames

NoJumpOffRope:

		LDA #$80 : STA !grabbed	; mark sprite as "currently grabbed"

LDY #$00		; Y = 00
LDA $185E|!Base2	; check the necessary position offset
BPL PlusOffset	; if it is negative...
DEY		; Y = FF
PlusOffset:	;
CLC		;
ADC $96		; add the amount the sprite moved on the Y-axis during the line-guide routine
STA $96		; to the player's Y position
TYA		;
ADC $97		; handle the high byte
STA $97		;

LDA !D8,x	;
STA $00		; put the sprite's Y position
LDA !14D4,x	; into adjacent scratch RAM
STA $01		;
REP #$20		; set A to 16-bit mode
LDA $96		;
SEC		;
SBC $00		;
CMP.w #$0000	; I'm not exactly sure what the purpose of this is...
BPL NoIncYPos	;
INC $96		;
NoIncYPos:	;
SEP #$20		;

LDA $18B6|!Base2	; the amount the sprite moved on the X-axis during the line-guide routine
JSR PlayerXOffsetRt	;

LDA !E4,x	;
SEC		;
SBC #$08		; sprite X position - $08
CMP $94		;
BEQ StartMoving	; if the player is at the sprite's X position, there is no need to offset his/her position
BPL XCheckPlus	; if the result was positive, do another check with A = 01
LDA #$FF		; if the result was positive, do another check with A = FF
BRA Check2	;

XCheckPlus:	;
LDA #$01		;
Check2:		;
JSR PlayerXOffsetRt	;

LDA !1626,x	;

StartMoving:

LDA !1626,x	; if the stationary flag is not already clear...
BEQ NoClearSFlag	;
STZ !1626,x	; clear it
STZ !1540,x	; as well as the move timer
NoClearSFlag:	;
RTS		;

PlayerXOffsetRt:

LDY #$00		; Y = 00
CMP #$00		; check the position offset
BPL PlusOffset2	; if it is negative...
DEY		; Y = FF
PlusOffset2:	;
CLC		;
ADC $94		; add the amount the sprite moved on the X-axis during the line-guide routine
STA $94		; to the player's X position
TYA		;
ADC $95		; handle the high byte
STA $95		;
RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; motor smoke subroutine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MotorSmoke:
		LDA !smoketimer,x : BNE Return04

		LDA !15A0,x	; if the sprite is offscreen
		ORA !186C,x	; in either direction...
		BNE Return04	; don't make smoke

		LDY #$03		; 4 indexes per smoke table

	SmokeLoop:	;

		LDA $17C0|!Base2,y	; if this slot is free...
		BEQ FreeSmoke	; use it
		DEY		; if not, check the next index
		BPL SmokeLoop	;
		RTS

	FreeSmoke:	;

		LDA #$03		; set the type of smoke
		STA $17C0|!Base2,y	;
		LDA !E4,x	;
		ADC $00		; smoke X offset
		STA $17C8|!Base2,y	;
		LDA !D8,x	;
		ADC $01		; smoke Y offset
		STA $17C4|!Base2,y	;
		LDA #$13		; time to show smoke
		STA $17CC|!Base2,y	;

		LDA #$10 : STA !smoketimer,x

	Return04:		;
		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LineRopeGFX:
%GetDrawInfo()

LDA $00		;
SEC		;
SBC #$08		; X offset - 8
STA $00		;

LDA $01		;
SEC		;
SBC #$08		; Y offset - 8
STA $01		;

		TXA			;
		ASL #2			;
		EOR !1570,x		;
		LSR #4			;
		AND #$03		;
		STA $02			; index to the motor tiles

;LDA #$05		; if the rope is short, draw 5 tiles
STZ $04		;
		LDA !extra_bits,x	;
		AND #$04 : BEQ ShortRopeTilesNum
LDA #$09		; if the rope is long, draw 9 tiles
BRA SetTileCount
ShortRopeTilesNum:
LDA #$05		; if the rope is short, draw 5 tiles
SetTileCount:	;
STA $03		;

LDY !15EA,x	; load the OAM index back into Y
LDX #$00		; start X off at 00   

GFXLoop:

LDA $00		;
STA $0300|!Base2,y	; no X displacement
LDA $01		; or Y displacement
STA $0301|!Base2,y	; for the motor tile
CLC		;
ADC #$10	; offset the next tile by $10 pixels
STA $01		;

LDA RopeTiles,x	;
CPX #$00		; if the tilemap index is 0...
BNE UseRopeTiles	;
PHX		;
LDX $02		;
LDA MotorTiles,x	; then use the motor tilemap
PLX		;
UseRopeTiles:	; else, use the rope tilemap
STA $0302|!Base2,y	; set the tile number

LDA #!MotorTileProp	;
CPX #$01			; if the tilemap index is 0...
BCC SetTileProp		; use the tile properties of the motor
LDA #!RopeTileProp		; else, use the tile properties of the rope
SetTileProp:		;
STA $0303|!Base2,y		; set the tile properties

INY #4		; increment the OAM index
INX		; and the tilemap index
CPX $03		; if we have reached our tile count...
BNE GFXLoop	; break the loop

LDA #!BottomRopeTile	; set the tile number for the bottom of the rope
STA $02FE|!Base2,y		;

		LDX $15E9|!Base2	; sprite index back into X

		LDA !extra_bits,x	;\
		AND #$04		; | number of tiles = 5 or 9
		CLC : ADC #$04		;/
		LDY #$02		; the tiles were all 16x16
		STA !1602,x
		JSL $01B7B3|!BankB	;


	if !wings == 1
		LDA !1602,x
		INC A
		ASL #2
		CLC : ADC !sprite_oam_index,x
		TAY
		LDA !sprite_x_low,x : STA $00
		LDA !sprite_x_high,x : STA $01
		LDA !sprite_y_low,x : STA $02
		LDA !sprite_y_high,x : STA $03
		LDA !1570,x
		LSR #3
		AND #$02
		STA $04
		PHX
	.Wing1
		REP #$20
		LDA $00
		SEC : SBC #$0014
		LDX $04
		BNE $04 : CLC : ADC #$0008
		SEC : SBC $1A
		CMP #$0100 : BCC ..OKX
		CMP #$FFF0 : BCC .Wing2
	..OKX	STA $0E
		LDA $02
		SEC : SBC #$0010
		LDX $04
		BNE $04 : CLC : ADC #$0008
		SEC : SBC $1C
		CMP #$00E0 : BCC ..OKY
		CMP #$FFF0 : BCC .Return
	..OKY	STA $0301|!Base2,y
		SEP #$20
		LDA $0E
		STA $0300|!Base2,y
		LDA .WingTile,x : STA $0302|!Base2,y
		LDA #$76 : STA $0303|!Base2,y
		PHY
		TYA
		LSR #2
		TAY
		LDA $0F
		AND #$01
		ORA $04
		STA $0460|!Base2,y
		PLY
		INY #4
	.Wing2
		REP #$20
		LDA $00
		CLC : ADC #$0004
		SEC : SBC $1A
		CMP #$0100 : BCC ..OKX
		CMP #$FFF0 : BCC .Return
	..OKX	STA $0E
		LDA $02
		SEC : SBC #$0010
		LDX $04
		BNE $04 : CLC : ADC #$0008
		SEC : SBC $1C
		CMP #$00E0 : BCC ..OKY
		CMP #$FFF0 : BCC .Return
	..OKY	STA $0301|!Base2,y
		SEP #$20
		LDA $0E
		STA $0300|!Base2,y
		LDA .WingTile,x : STA $0302|!Base2,y
		LDA #$36 : STA $0303|!Base2,y
		TYA
		LSR #2
		TAY
		LDA $0F
		AND #$01
		ORA $04
		STA $0460|!Base2,y
	.Return
		SEP #$20
		PLX
		RTS

	.WingTile
		db $5D,$FF,$C6

	else
		RTS
	endif




