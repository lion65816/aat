;rideable balloon by smkdan (optimized by Blind Devil)
;balloon that you can step on for a ride

;USES EXTRA BIT
;If set, balloon will be loaded with a random color rather than a fixed one.

;Tilemap defines:
TILEMAP:	db $E0,$E2		;top-left, top-right
		db $C4,$C6		;bottom-left, bottom-right

PAL:		db $04,$06,$08,$0A	;possible random palettes to use, YXPPCCCT format.

XDISP:		db $00,$10,$00,$10

YDISP:		db $FE,$FE,$0E,$0E
		db $00,$00,$0E,$0E

XSPD:		db $FC,$00,$04,$00
COUNT:		db $40,$10,$40,$10

XADJUST:	dw $FFFF,$0000,$0001,$0000

SPDCMP:		db $FA,$FD
INCDEC:		db $FF,$01

;C2: riding bit
;1570: behaviour count
;1602: X scroll counter


HeightTbl:	dw $FFE6,$FFD6,$FFD6
ClipTbl:	dw $0016,$0026,$0026

print "INIT ",pc
	LDA !7FAB10,x
	AND #$04
	BEQ NormPal

	JSL $01ACF9|!BankB	;get random
	AND #$03		;only low 2 bits
	TAY			;to be used as index

	LDA !15F6,x		;load properties
	AND #$F1		;all but pal bits

	PHB
	PHK
	PLB
	ORA PAL,y		;set palette bits
	PLB

	STA !15F6,x		;new palette

NormPal:
	LDA #$FA		;fixed Yspd
	STA !AA,x		;initial Yspd
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL

Return_l:
	RTS

Run:
	LDA #$00
	%SubOffScreen()
	JSR GFX			;draw sprite

	LDA !14C8,x
	CMP #$08          	 
	BNE Return_l           
	LDA $9D			;locked sprites?
	BNE Return_l
	LDA !15D0,x		;yoshi eating?
	BNE Return_l

	STZ !C2,x		;reset riding sprite, may get set later

	JSL $01A7DC|!BankB	;mario interact
	BCC NoInteraction	;do nothing if there's no contact

        LDA $7D			;don't interact on rising speed
        BMI NoInteraction


	LDA $187A|!Base2	;yoshi flag
	CLC
	ASL
	TAY			;into Y

;control height required to be on top of sprite

	LDA !14D4,x		;sprite high Y
	XBA
	LDA !D8,x		;sprite low Y
	REP #$20		;16bit math
	SEC
	SBC $96			;sub mario Y pos.  Mario is OVER the sprite.  Mario Y < sprite Y
	CMP ClipTbl,y		;compare depending on mario or yoshi mario
	SEP #$20
	BCC LeaveMario		;return if he's too low (underflows)

;interacting, set positions

	LDA #$01
	STA !C2,x		;set riding sprite for GFX routine

	LDA #$01
	STA $1471|!Base2	;'riding sprite'
	STZ $7D			;no Y speed

	LDA $187A|!Base2	;yoshi flag
	CLC
	ASL A			;2 bytes
	TAY			;into Y reg

	LDA !14D4,x		;sprite high Y
	XBA
	LDA !D8,x		;sprite low Y
	REP #$20
	CLC
	ADC HeightTbl,y		;stepped on height
	STA $96			;new mario Y position
	SEP #$20

NoInteraction:
	INC !1602,x		;advance counter
	LDA !1602,x
	LDY !1570,x		;load behaviour as index
	CMP COUNT,y		;X frames
	BCC NoChange		;if count not yet reached, maintain C2

;advance behaviour since count was reached

	LDA !1570,x		;load scroll behaviour...
	INC A
	AND #$03		;4 variables
	STA !1570,x		;...new scroll behaviour
	STZ !1602,x		;reset counter

;apply speed

NoChange:
	LDY !1570,x		;load as index
	LDA XSPD,y		;speed value
	STA !B6,x		;new Xspd

	LDA !C2,x		;load riding bit
	BEQ LeaveMario

;adjust Mario position
	
	LDA !1602,x		;load counter...
	AND #$03
	BNE LeaveMario		;every 2nd frame

	LDY !1570,x		;load balloon behaviour as index
	TYA			;transfer Y to A
	ASL			;multiply by 2
	TAY			;transfer A to Y
	REP #$20		;16-bit A
	LDA XADJUST,y		;load adjustment
	CLC
	ADC $94			;MarioX low added
	STA $94			;store
	SEP #$20		;8-bit A

;DO HIGH

LeaveMario:
	LDA !AA,x		;load Yspd
	LDY !C2,x		;load ride bit as index
	CMP SPDCMP,y		;load targetspeed
	BEQ StoreY

	CLC
	ADC INCDEC,y		;add or dec to Yspd

StoreY:
	STA !AA,x		;store Yspd

UpdateXPosNoGrvty:
	JSL $018022|!BankB
	JSL $01801A|!BankB	;update Y pos no gravity

Return:
	RTS        
			
;=====

GFX:
	%GetDrawInfo()
	LDA !C2,x	;stepped on?
	ASL #2		;x4
	STA $08

	LDA !157C,x	;$03ection...
	STA $03

	LDA !15F6,x	;properties...
	STA $04

	LDX #$00	;loop index

OAM_Loop:
	LDA $00
	CLC
	ADC XDISP,x
	STA $0300|!Base2,y	;xpos

	TXA	
	CLC
	ADC $08			;variable YDISP
	PHX
	TAX
	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!Base2,y	;ypos
	PLX

	LDA TILEMAP,x
	STA $0302|!Base2,y	;chr

	LDA $04
	ORA $64
	STA $0303|!Base2,y	;properties

	INY
	INY
	INY
	INY
	INX
	CPX #$04		;4 tiles
	BNE OAM_Loop

	LDX $15E9|!Base2	;restore sprite index
	LDY #$02		;16x16 tiles
	LDA #$03		;4 tiles
	JSL $01B7B3|!BankB
	RTS			;return