;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; SMB3 Nipper v2, by imamelia
;
; This is the Nipper from SMB3.  It is a little plant creature that stays in one place
; or hops back and forth until the player tries to jump over it, at which point it
; either jumps into the air and then starts moving around or spits a stream of
; fireballs.  It can be found in, for example, 5-1 and 6-5.
;
; Extra bytes: 1
;
; - 00: stationary; jumps in place
; - 01: starts out stationary, but starts moving once triggered
; - 02: move back and forth about 3 tiles
; - 03: spit fireballs
;
; Sprite tables:
; - !C2,x: Sprite state.
; - !1504,x: Time to wait before moving.
; - !1510,x: Sprite type.
; - !151C,x: Unused.
; - !1528,x: Fireball counter.
; - !1534,x: Unused.
; - !1540,x: Fireball spitting timer.
; - !1558,x: Fireball wait timer.
; - !1570,x: Frame counter.
; - !157C,x: Direction.
; - !1594,x: Unused.
; - !15AC,x: Timer for moving back and forth.
; - !1602,x: Animation frame.
; - !160E,x: Horizontal/upright frame status.
; - !1626,x: Unused.
; - !163E,x: Unused.
; - !187B,x: Unused.
; - !1FD6,x: Unused.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;!GFXFile1 = $00B6
;!GFXFile2 = $00B6

!JumpRange = $10		; how close the player has to be to the sprite before it will jump
!JumpSpeed = $C0		; what speed the sprite will use when it jumps
!XSpeed = $0A			; what speed the sprite will use when moving around
!FireRange = $48		; how close the player has to be to the sprite before it will spit fireballs 
!FireWaitTimer = $60	; the Nipper won't spit fireballs when this is nonzero, even if the player is in range
!FireSound = $06		; the sound to play when the sprite is spitting a fireball
!FireSoundBank = $1DFC	; the sound bank this sound will come from
;!FireXSpeed = $10		; the X speed to spit the fireball
!FireYSpeed = $DD		; the Y speed to spit the fireball
!MoveTimer = $60		; time to move back and forth
!MoveTStop = $20		; time below which the sprite will not move back and forth

Tilemap:
;	db $00,$02,$04,$06
	db $40,$42,$44,$46	; closed mouth sideways, open, closed upright, open

InitState:
	db $00,$00,$02,$00

; 00 - stationary; waiting on the ground
; 01 - waiting to move after jumping
; 02 - moving
; 03 - spitting fire
StatePointers:
	dw S00_Stationary
	dw S01_Waiting
	dw S02_Moving
	dw S03_SpitFire

Frame:
	db $00,$00,$01,$01,$02,$03,$02,$03

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
	PHB
	PHK
	PLB
	JSR SpriteInitRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteInitRt:
	LDA !7FAB40,x
	STA !1510,x
	TAY
	LDA InitState,y
	STA !C2,x
	CPY #$02
	BNE .NotType2
	LDA.b #!MoveTimer
	STA !15AC,x
.NotType2
;	LDA.b #!GFXFile1
;	STA $7F88D0,x
;	LDA.b #!GFXFile1>>8
;	STA $7F88DC,x
;	LDA.b #!GFXFile2
;	STA $7F88E8,x
;	LDA.b #!GFXFile2>>8
;	STA $7F88F4,x
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMainRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteMainRt:
	LDA !160E,x			;
	ASL #2				;
	STA $00				;
	LDA !1570,x			;
	LSR #2				;
	AND #$03			;
	ORA $00				; make the sprite animate between open and closed frames
	TAY					;
	LDA Frame,y			;
	STA !1602,x			;
	LDA !1540,x			; unless, of course, it is spitting fire,
	BEQ .NotOpen			; in which case it should always have an open mouth
	LDA #$01			;
	STA !1602,x			;
.NotOpen					;
	JSR SubGFX			;
	LDA !14C8,x			;
	EOR #$08				;
	ORA $9D				;
	BNE ReturnMain		;
	LDA #$00			;
	%SubOffScreen()		;
	INC !1570,x			;
    LDA !C2,x			;
    ASL A				;
    TAX					;
    JSR.w (StatePointers,x)	;
	JSL $01802A|!BankB	; update sprite position
	JSL $01803A|!BankB	; interact with sprites and the player
	LDA !1588,x			;
	AND #$03			; if the sprite is touching a wall...
	BEQ ReturnMain		;
	LDA !157C,x			;
	EOR #$01				; flip its direction
	STA !157C,x			;
	LDA !B6,x			; and its X speed
	EOR #$FF				;
	INC					;
	STA !B6,x			;
ReturnMain:				;
	RTS					;

;------------------------------------------------
; state 00 - stationary
;------------------------------------------------

S00_Stationary:
	LDX $15E9|!Base2
	%SubHorzPos()	;
DummyLabel0:		;
	TYA				; make the sprite always face the player
	STA !157C,x		;
	LDA !1588,x		;
	AND #$04		; if the sprite isn't on the ground...
	BEQ .NoJump		;
	STZ !160E,x		;
	LDA #$10		;
	STA !AA,x		;
	LDA !1510,x		;
	CMP #$03		; if it's sprite type 3...
	BEQ .CheckForSpit	; then make the Nipper spit fire instead of jumping
	JSR Proximity1		; if the sprite is out of range...
	BEQ .NoJump		; don't make it jump
	LDA.b #!JumpSpeed	;
	STA !AA,x		; set its jumping speed
	INC !160E,x		; set the frame to upright
	LDA #$18		;
	STA !1504,x		; set the timer for it to wait before moving
	LDA !1510,x		;
	BEQ .NoJump		;
	INC !C2,x		; set the sprite state to waiting
.NoJump				;
	RTS				;
.CheckForSpit			;
	JSR Proximity2		;
	BEQ .NoSpit		;
	LDA !1558,x		; if the sprite just spat already...
	BNE .NoSpit		; don't spit any fireballs
	LDA #$0C		;
	STA !1540,x		; fireball timer
	LDA #$04		;
	STA !1528,x		; fireball counter: 4 fireballs to spit
	LDA #$03		;
	STA !C2,x		; change the sprite state to spitting
.NoSpit				;
	RTS				;

;------------------------------------------------
; state 01 - waiting to move
;------------------------------------------------

S01_Waiting:
    LDX $15E9|!Base2
	LDA !1504,x		; if the wait timer has not run out...
	BNE .NoMove		; don't start moving
	INC !C2,x		;
.NoMove				;
	LDA !1588,x		;
	AND #$04		; if the sprite is in the air...
	BEQ .InAir		;
	DEC !1504,x		; don't decrement the wait timer
	STZ !160E,x		;
.InAir				;
	%SubHorzPos()	;
	TYA				; make the sprite always face the player
	STA !157C,x		;
	RTS				;

;------------------------------------------------
; state 02 - moving
;------------------------------------------------

S02_Moving:
    LDX $15E9|!Base2
	LDA !1588,x		;
	AND #$04		; if the sprite is not on the ground...
	BEQ .NoClearFrame	; don't set its Y speed
	LDA #$EE			;
	STA !AA,x		; make the sprite hop a little
	LDA.b #!XSpeed		; give the sprite some X speed
	LDY !157C,x		;
	BEQ $03			; flip the X speed value if the sprite is facing left
	EOR #$FF			;
	INC				;
	STA !B6,x		;
	JSR Proximity1		; if the sprite is out of range...
	BEQ .NoJump		; don't make it jump
	LDA.b #!JumpSpeed	;
	STA !AA,x		; set its jumping speed
	LDA #$01		; set the frame to upright
	STA !160E,x		;
	BRA .NoClearFrame	;
.NoJump				;
	STZ !160E,x		;
.NoClearFrame			;
	LDA !1510,x		;
	CMP #$02		;
	BEQ NoFace2		;
	LDA !1570,x		;
	AND #$1F		; every few frames...
	BNE NoFace		;
	%SubHorzPos()	;
	TYA				; make the sprite turn to face the player
	STA !157C,x		;
NoFace:				;
	RTS				;
NoFace2:				;
	LDA !15AC,x		;
	BEQ .Turn			;
	CMP.b #!MoveTStop	;
	BCS NoFace		;
	STZ !B6,x		;
	RTS				;
.Turn				;
	LDA !157C,x		;
	EOR #$01			;
	STA !157C,x		;
	LDA !B6,x		;
	EOR #$FF			;
	INC				;
	STA !B6,x		;
	LDA.b #!MoveTimer	;
	STA !15AC,x		;
	RTS				;

;------------------------------------------------
; state 03 - spitting fireballs
;------------------------------------------------

S03_SpitFire:
    LDX $15E9|!Base2
	LDA !1540,x		; check the spit timer
;	AND #$07		;
	BNE .NoSpit		;
	JSR SubFireSpit		; fireball-spawning routine
	DEC !1528,x		; decrement the fireball counter
	BEQ .EndSpit		;
	LDA #$08		;
	STA !1540,x		;
	RTS				;
.EndSpit				;
	LDA.b #!FireWaitTimer
	STA !1558,x		; reset the fire-spit timer
	STZ !C2,x		;
.NoSpit				;
	RTS				;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
;	JSL !GetDrawInfoPlus
	%GetDrawInfo()
	LDA !15F6,x
	ORA $64
	STA $03
	LDA !1602,x
	STA $04
;	LDA $05
	LDA !157C,x
	ROR #3
	AND #$40
	EOR #$40
	TSB $03
	LDA !14C8,x
	CMP #$08
	BEQ +
	LDA #$80
	TSB $03
+	LDA $00
	STA $0300|!Base2,y
	LDA $01
	STA $0301|!Base2,y
	LDX $04
	LDA.w Tilemap,x
;	CLC
;	ADC $02
	STA $0302|!Base2,y
	LDA $03
	STA $0303|!Base2,y
	LDX $15E9|!Base2
	LDY #$02
	LDA #$00
	JSL $01B7B3|!BankB
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; fire-spitting routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FireXOffsetsLo:
	db $06,$FA
FireXOffsetsHi:
	db $00,$FF
!FireYOffsetLo = $03
!FireYOffsetHi = $00

SubFireSpit:
	LDY #$07
.ExSpriteLoop
	LDA $170B|!Base2,y
	BEQ .FoundExSlot
	DEY
	BPL .ExSpriteLoop
	RTS

.FoundExSlot
	LDA #$0B
	STA $170B|!Base2,y
	LDA !E4,x
	PHY
	LDY !157C,x
	CLC
	ADC FireXOffsetsLo,y
	PLY
	STA $171F|!Base2,y
	LDA !14E0,x
	PHY
	LDY !157C,x
	ADC FireXOffsetsHi,y
	PLY
	STA $1733|!Base2,y
	LDA !D8,x
	CLC
	ADC.b #!FireYOffsetLo
	STA $1715|!Base2,y
	LDA !14D4,x
	ADC.b #!FireYOffsetHi
	STA $1729|!Base2,y
;	LDA.b #!FireXSpeed
	JSR Proximity1
	REP #$20
	LDA $0C
	LSR
	SEP #$20
	PHY
	LDY !157C,x
	BEQ $03
	EOR #$FF
	INC
	PLY
	STA $1747|!Base2,y
	LDA.b #!FireYSpeed
	STA $173D|!Base2,y
	LDA #$FF
	STA $176F|!Base2,y
	LDA.b #!FireSound
	STA.w !FireSoundBank|!Base2
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; miscellaneous subroutines
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Proximity1:				;
	LDA.b #!JumpRange		;
	BRA StoreRange		;
Proximity2:				;
	LDA.b #!FireRange		;
StoreRange:				;
	STA $0A				;
ProximityMain:			;
	LDA !14E0,x			; sprite X position high byte
	XBA					; into high byte of A
	LDA !E4,x			; sprite X position low byte into low byte of A
	REP #$20				; set A to 16-bit mode
	SEC					; subtract the player's X position
	SBC $94				; from the sprite's
	STA $0E				;
	BPL .NoInvertH			; if the result of the subtraction was negative...
	EOR #$FFFF			; then invert it
	INC					;
.NoInvertH				;
	STA $0C				;
	CMP #$0100			; if the difference is bigger than 1 screen...
	SEP #$20				;
	BCS .RangeOut1		; then the player is out of range anyway
	CMP $0A				; if not, compare the result to the desired range
	BCS .RangeOut1		;
.RangeIn1				;
	LDA #$01			;
	RTS					;
.RangeOut1				;
	LDA #$00			;
	RTS					;


