;Baron Von Zeppelin by smkdan (optimized by Blind Devil)
;An enemy from SMW2 that holds a sprite of your choice and drops it when Mario gets near.

;USES EXTRA BIT
;If set, it will come back after it's dropped its payload.  Else, it won't come back.

;Extra prop 1 = How close Mario should get in order to drop payload.

;Graphics defines:
!Balloon =	$0C		;Baron Von Zeppelin's tile
!Chain =	$17		;Chain tile

!DropSFX =	$15		;sound to play when sprite is dropped
!DropPort =	$1DF9		;port for above sfx

Speed:	db $04,$FC

;===

;Data to use for the sprite to be generated.  It takes a 16x16 sprite for its dummy graphics.

!SpawnIsCustom = 1	;carried sprite is custom or normal? - 0 = normal. 1 = custom.

!SpawnNum =	$3F	;carried sprite number.
!SpawnTile =	$0E	;16x16 tile to use for the carried sprite.
!SpawnProp =	$1B	;tile properties for carried sprite, YXPPCCCT format.

;=====

SINE:	db $00,$01,$02,$03,$04,$03,$02,$01 
	db $00,$FF,$FE,$FD,$FC,$FD,$FE,$FF

;C2: YSpd
;1570: Drop / fly flag
;1602: Sine index


print "MAIN ",pc
	PHB
	PHK
	PLB
	LDA #$FF
	STA !161A,x
	JSR Run
	PLB
print "INIT ",pc
	RTL	;also nothing


Run:
	LDA #$00
	%SubOffScreen()
	%GetDrawInfo()
	JSR GFX			;draw sprite
	JSR GFXItem		;draw sprite payload it's holding

	LDA !14C8,x
	CMP #$08          	 
	BNE Return           
	LDA $9D			;locked sprites?
	BNE Return
	LDA !15D0,x		;yoshi eating?
	BNE Return

	LDY !157C,x
	LDA Speed,y		;speed depending on direction
	STA !B6,x

	LDA !1570,x		;if already generated, fly away
	BEQ CheckProx

FlyAway:
	LDA $14
	AND #$01
	BNE SkipFly		;slow ascent

	LDA !C2,x		;Yspd
	DEC A
	STA !C2,x
	STA !AA,x
	CMP #$F0
	BCS SkipFly

	INC !C2,x		;compensate
	STA !C2,x
	STA !AA,x

	BRA SkipFly

CheckProx:
	JSR PROXIMITY		;my common proximity routine
	BEQ NoGen
	JSR Generate		;if in range, generate it

	LDA !1570,x		;this is not zero if generation was successful
	BEQ NoGen		;just continue until time comes

	LDA #!DropSFX		;play sound
	STA !DropPort|!Base2

	LDA !7FAB10,x		;extra bit
	AND #$04
	BNE NoGen		;if bit is clear, don't come back

	LDA #$FF		;erase sprite permanentley
	STA !161A,x

NoGen:
	JSR SINEMOTION		;wavy motion, Xspd
	LDA !AA,x		;keep storing to storage
	STA !C2,x
	
	%SubHorzPos()
	TYA
	STA !157C,x		;$09: Always face Mario

SkipFly:
	JSL $01802A|!BankB	;speed update

Return:
	RTS     

;generate sprite routine edited by Blind Devil

Generate:
	STZ $00			;spawn at same X-pos
	LDA #$19		;load Y offset
	STA $01			;store to scratch RAM.
	STZ $02 : STZ $03	;spawn sprites with zero speed

	LDA #!SpawnNum		;sprite number to spawn

if !SpawnIsCustom
	SEC
else
	CLC
endif
	%SpawnSprite()

	INC !1570,x		;only do this once

ReturnG:
	RTS
		
;=====

TILEMAP:	db !Balloon,!Chain,!Chain	;balloon, chain, chain

XDISP:		db $00,$04,$04

YDISP:		db $00,$0E,$12

XBIAS:		db $00,$08,$08
SIZE:		db $02,$00,$00

EORF:		db $40,$00

GFX:
	LDA !15F6,x	;load properties
	STA $04		;into $04

	LDA !157C,x	;direction...
	STA $03

	LDX #$00	;loop index

OAM_Loop:
	TYA
	LSR #2
	PHY
	TAY
	LDA SIZE,x
	STA $0460|!Base2,y		;size table
	PLY			;restore

	LDA $03
	BNE XLeft

	LDA $00
	SEC
	SBC XDISP,x
	CLC
	ADC XBIAS,x		;add bias since it throws it on the other side
	STA $0300|!Base2,y
	BRA XNext

XLeft:
	LDA $00
	CLC
	ADC XDISP,x
	STA $0300|!Base2,y

XNext:
	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!Base2,y

	LDA TILEMAP,x
	STA $0302|!Base2,y

	LDA $64
	ORA $04
	PHX
	LDX $03
	EOR EORF,x
	PLX
	STA $0303|!Base2,y

	INY
	INY
	INY
	INY
	INX
	CPX #$03	;3 tiles for balloon and chain
	BNE OAM_Loop

	LDX $15E9|!Base2
	RTS	
	
GFXItem:
	LDA !1570,x
	BNE GFXI4_Return	;return if GFX shouldn't be drawn

	PHY
	TYA
	LSR #2
	TAY
	LDA #$02
	STA $0460|!Base2,y	;it's a 16x16 sprite being held
	PLY

	LDA $00
	STA $0300|!Base2,y	;same x pos

	LDA $01
	CLC
	ADC #$19		;below it
	STA $0301|!Base2,y

	LDA #!SpawnTile
	STA $0302|!Base2,y	;sprite to gen GFX

	LDA #!SpawnProp		;sprite properties to generate
	ORA $64
	PHX
	LDX $03
	EOR EORF,x
	PLX
	STA $0303|!Base2,y

GFXI3_Return:
	LDY #$FF
	LDA #$03		;4 tiles
	JSL $01B7B3|!BankB	;bookkeeping
	RTS

GFXI4_Return:
	LDY #$FF
	LDA #$02		;only 3 tiles
	JSL $01B7B3|!BankB	;bookkeeping
	RTS

;=====
;a routine to calculate whether or not Mario is within range of wiggler.  Based off fang.asm
;Z = 0 when in range, 1 when out of range

EORTBLI:	db $FF,$00
EORTBL:		db $00,$FF
		
PROXIMITY:
	LDA !14E0,x		;sprite x high
	XBA
	LDA !E4,x		;sprite x low
	REP #$20		;16bitA
	SEC
	SBC $94			;sub mario x
	SEP #$20		;8bitA
	PHA			;preserve for routine jump
	%SubHorzPos()		;horizontal distance
	PLA			;restore
	EOR EORTBLI,y		;invert if needed
	CMP !7FAB28,x		;range define by Extra Prop 1*
	BCS PRange_Out		;return not within range
	LDA #$01		;Z = 0
	RTS

PRange_Out:
	LDA #$00		;Z = 1
	RTS

SINEMOTION:
	LDA !1602,x		;dedicated sine index
	INC A			;advance
	STA !1602,x		;and store

	LSR #3
	AND #$0F		;only 16 entries
	TAY
	LDA SINE,y		;grab entry
	STA !AA,x		;new Yspd
	RTS