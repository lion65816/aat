;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Bowser Statue, by imamelia
;
; This is a customizable version of the Bowser statue in SMW (sprite BC).
;
; Extra bytes: 1
;
; The extra byte determines the sprite's behavior.  You can also set bit 7 (add $80
; to the number) to make it start out facing right instead of left.
; - 00: stationary
; - 01: stationary, spit fire
; - 02: jump around
; - 03: jump around, spit fire
;
; Note: Made SA-1 compatible by PSI Ninja.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TileDispX:
	db $08,$F8,$00,$00,$08,$00
TileDispY:
	db $10,$F8,$00
Tilemap:
	db $56,$30,$41,$56,$30,$35
TileSize:
	db $00,$02,$02
TileProps:
	db $00,$00,$00,$40,$40,$40

FireDispXLo:
	db $10,$F0
FireDispXHi:
	db $00,$FF

JumpXSpeed:
	db $10,$F0

SubtypePtrs:
	dw Type00_Stationary
	dw Type01_SpitFire
	dw Type02_JumpAround
	dw Type03_JumpAndSpit

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
	PHB
	PHK
	PLB
	JSR SpriteInitRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteInitRt:
	LDA !7FAB40,x
	ROL #2
	AND #$01
	EOR #$01
	STA !157C,x
	LDA !7FAB40,x
	AND #$7F
	STA !1510,x
	ASL
	TAY
	LDA SubtypePtrs,y
	;STA $7FABC2,x
	STA !1504,x		;> PSI Ninja edit: For SA-1 compatibility, need to use a miscellaneous sprite table instead.
	LDA SubtypePtrs+1,y
	;STA $7FABCE,x
	STA !151C,x		;> PSI Ninja edit: For SA-1 compatibility, need to use a miscellaneous sprite table instead.
	LDA !1510,x
	CMP #$02
	BCC .Return
	LDA !15F6,x
	AND #$F1
	STA !15F6,x
	LDA !167A,x
	AND #$7F
	STA !167A,x
.Return
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMainRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteMainRt:
	JSR SubGFX
	LDA $9D
	BNE ReturnMain
	LDA #$00
	%SubOffScreen()
	;LDA $7FABC2,x
	LDA !1504,x		;> PSI Ninja edit: For SA-1 compatibility, need to use a miscellaneous sprite table instead.
	STA $00
	;LDA $7FABCE,x
	LDA !151C,x		;> PSI Ninja edit: For SA-1 compatibility, need to use a miscellaneous sprite table instead.
	STA $01
	JMP ($0000)
ReturnMain:
	RTS

;------------------------------------------------
; code for the individual subtypes
;------------------------------------------------

Type01_SpitFire:
	JSR SubSpitFire
Type00_Stationary:
	JSL $01B44F|!BankB
	JSL $01802A|!BankB
	LDA !1588,x
	AND #$04
	BEQ .Return
	STZ !AA,x
.Return
	RTS

Type03_JumpAndSpit:
	LDA !1588,x
	AND #$04
	BEQ .NoFire
	JSR SubSpitFire
.NoFire
Type02_JumpAround:
	JSL $01A7DC|!BankB
	STZ !1602,x
	LDA !AA,x
	CMP #$10
	BPL .NoIncFrame
	INC !1602,x
.NoIncFrame
	JSL $01802A|!BankB
	LDA !1588,x
	AND #$03
	BEQ .NoFlipSpeed
	LDA !B6,x
	EOR #$FF
	INC
	STA !B6,x
	LDA !157C,x
	EOR #$01
	STA !157C,x
.NoFlipSpeed
	LDA !1588,x
	AND #$04
	BEQ .Return
	LDA #$10
	STA !AA,x
	STZ !B6,x
	LDA !1540,x
	BEQ .ResetJumpTimer
	DEC
	BEQ .Continue
.Return
	RTS
.ResetJumpTimer
	LDA #$30
	STA !1540,x
	RTS
.Continue
	LDA #$C0
	STA !AA,x
	%SubHorzPos()
	TYA
	STA !157C,x
	LDA JumpXSpeed,y
	STA !B6,x
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
	%GetDrawInfo()
	LDA !1602,x
	STA $04
	EOR #$01
	DEC
	STA $03
	LDA !15F6,x
	STA $05
	LDA !157C,x
	STA $02
	PHX
	LDX #$02
.Loop
	PHX
	LDA $02
	BNE .FacingLeft
	INX #3
.FacingLeft
	LDA $00
	CLC
	ADC TileDispX,x
	STA $0300|!addr,y
	LDA TileProps,x
	ORA $05
	ORA $64
	STA $0303|!addr,y
	PLX
	LDA $01
	CLC
	ADC TileDispY,x
	STA $0301|!addr,y
	PHX
	LDA $04
	BEQ .NoJumpFrame
	INX #3
.NoJumpFrame
	LDA Tilemap,x
	STA $0302|!addr,y
	PLX
	PHY
	TYA
	LSR #2
	TAY
	LDA TileSize,x
	STA $0460|!addr,y
	PLY
	INY #4
	DEX
	CPX $03
	BNE .Loop
	PLX
	LDY #$FF
	LDA #$02
	JSL $01B7B3|!BankB
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; subroutines
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;------------------------------------------------
; fire-spitting subroutine
;------------------------------------------------

SubSpitFire:
	TXA
	ASL #2
	ADC $13
	AND #$7F
	BNE .Return
	JSL $02A9E4|!BankB	;> Find an empty sprite slot, and return it in Y.
	BMI .Return
	LDA #$17
	STA $1DFC|!addr
	LDA #$08
	STA !14C8,y
	LDA #$B3		;\ Bowser Statue Fireball (sprite B3)
	STA !9E,y		;/ Store it in the sprite number table.
	LDA !E4,x		;\ Bowser Statue X position, low byte.
	STA $00			;/ Store it in scratch RAM ($00).
	LDA !14E0,x		;\ Bowser Statue X position, high byte.
	STA $01			;/ Store it in scratch RAM ($01).
	PHX			;> Save the Bowser Statue's index to the stack.
	LDA !157C,x		;\ Load the direction that the Bowser Statue is facing...
	TAX			;/ ...and put it in X.
	LDA $00			;\ Load the low byte of the Bowser Statue's X position...
	CLC			;|
	ADC FireDispXLo,x	;| ...add to it the low byte offset based on the direction it's facing...
	STA !E4,y		;/ ...and store the offsetted value to the low byte of the Bowser Statue Fireball's X position.
	LDA $01			;\ Load the high byte of the Bowser Statue's X position...
	ADC FireDispXHi,x	;| ...add to it the high byte offset based on the direction it's facing...
	STA !14E0,y		;/ ...and store the offsetted value to the high byte of the Bowser Statue Fireball's X position.
	TYX
	JSL $07F7D2|!BankB
	PLX			;> Load the Bowser Statue's index from the stack.
	LDA !D8,x		;\ Bowser Statue Y position, low byte.
	SEC			;|
	SBC #$02		;| Slightly offset the low byte of the Bowser Statue's Y position...
	STA !D8,y		;/ ...and store the offsetted value to the low byte of the Bowser Statue Fireball's Y position.
	LDA !14D4,x		;\ Bowser Statue Y position, high byte.
	SBC #$00		;|
	STA !14D4,y		;/ Store it to the high byte of the Bowser Statue Fireball's Y position.
	LDA !157C,x		;\ Load the direction that the Bowser Statue is facing...
	STA !157C,y		;/ ...and store it as the direction that the Bowser Statue Fireball is facing.
.Return
	RTS
