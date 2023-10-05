;YI Big Boo by smkdan (optimized by Blind Devil)
;A 32x32 sized Boo.

;USES EXTRA BIT
;If set, it'll act like an Anti Boo and chase the player if he's facing the sprite.

;TILEMAP defines:
TILEMAP:	db $48,$4A	;shy frames
		db $68,$6A

		db $4C,$4E	;chase frames
		db $6C,$6E

EORTBL:		db $00,$FF

ADDSUB:		db $01,$FF
INCDEC:		db $01,$FF

;$76: set = facing right
;     clr = facing left

;bit 0: Mario placement from SUB_HORZ_POS
;bit 1: Mario direction from $76

CHASETBL:	db $00	;00: Mario facing left, mario on right.  Shy.
		db $01	;01: Mario facing left, mario on left. Chase.
		db $01	;10: Mario facing right, mario on right. Chase.
		db $00	;11. Mario facing right, mario on left. Shy.

;$C2: Chase status	
;!1570,x: Timer

;1602: storage Xspd
;151c: storage Yspd

print "INIT ",pc
	%SubHorzPos()
	TYA
	STA !157C,x

	LDA !7FAB10,x		;load extra bits
	AND #$04		;check if first extra bit is set
	BEQ +			;if not set, Boo will chase normally.

	LDA #$01		;load value for EOR chase table value
	STA !1534,x		;store to sprite RAM.
	RTL

+
	STZ !1534,x		;clear sprite RAM used for EOR chase table value.
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Run
	PLB
	RTL

RETURN_L:
	RTS

Run:
	LDA #$01
	%SubOffScreen()
	JSR GFX			;draw sprite

	LDA !14C8,x
	CMP #$08          	 
	BNE RETURN_L           
	LDA $9D			;locked sprites?
	BNE RETURN_L
	LDA !15D0,x		;yoshi eating?
	BNE RETURN_L

	%SubHorzPos()		;get what side Mario is on
	TYA			;into A
	STA $09			;$09
	LDA $76
	ASL			;bit 1
	ORA $09			;set bit 0
	TAY			;new index

	LDA CHASETBL,y		;load chase data
	CMP !C2,x		;compare with existing chase data
	BEQ RESETCOUNT		;may decrement counter if different

	LDA $140D|!Base2	;spin jump flag
	BNE DONTCHANGEACTION	;do nothing if Mario is spin jumping

	LDA CHASETBL,y		;is set to not chase?  It reloads because of needed order of checking
	BEQ SKIPCOUNT		;don't count.  shy right away.

	LDA !1570,x		;inc counter otherwise
	INC A
	STA !1570,x
	CMP #$10		;16 frames waiting
	BCC DONTCHANGEACTION

SKIPCOUNT:
	LDA CHASETBL,y
	STA !C2,x		;otherwise we have a new status, which we also reset counter with

	%SubHorzPos()		;Face Mario with new status
	TYA
	STA !157C,x

RESETCOUNT:
	STZ !1570,x		;reset counter


DONTCHANGEACTION:
	LDA !C2,x		;load status to follow
	EOR !1534,x		;flip bit 0 if value is set
	BEQ DONTCHASE		;freeze if clear

;Chase code
	%SubHorzPos()	;Face Mario while chasing
	TYA
	STA !157C,x

	LDA $14			;only update every 4th frame
	AND #$03
	BEQ UPDATESPD		;else just store the stored values

	LDA !1602,x
	STA !B6,x
	LDA !151C,x
	STA !AA,x
	BRA SKIPELSE		;skip around the rest

UPDATESPD:
	%SubHorzPos()

	LDA ADDSUB,y		;load appropriate additive
	CLC
	ADC !1602,x

	BMI GOINGLEFT		;high bit set = going left
	CMP #$08
	BCC DONTCLIPX
	LDA #$08
	BRA DONTCLIPX		;skip to store

GOINGLEFT:
	CMP #$F8
	BCS DONTCLIPX
	LDA #$F8		;speed on cap

DONTCLIPX:
	STA !1602,x
	STA !B6,x		;new X spd

	%SubVertPos()

	LDA ADDSUB,y
	CLC
	ADC !151C,x

	BMI GOINGUP
	CMP #$08
	BCC DONTCLIPY
	LDA #$08
	BRA DONTCLIPY
GOINGUP:
	CMP #$F8
	BCS DONTCLIPY
	LDA #$F8

DONTCLIPY:
	STA !151C,x
	STA !AA,x		;new Y spd
		
	BRA SKIPELSE
	
DONTCHASE:
	STZ !AA,x		;freeze speed
	STZ !B6,x

	STZ !151C,x		;erase storage Yspd
	STZ !1602,x		;erase storage Xspd

SKIPELSE:
	JSL $01802A|!BankB	;update speed
	JSL $01A7DC|!BankB	;mario interact
RETURN:
	RTS        
			
;=====

XDISP:	db $00,$10
	db $00,$10

YDISP:	db $00,$00
	db $10,$10

XBIAS:	db $10,$10
	db $10,$10

EORF:	db $40,$00

GFX:
	%GetDrawInfo()
	LDA !157C,x	;direction...
	STA $03

	LDA !15F6,x	;properties
	STA $04

	LDA !C2,x	;load chase status
	EOR !1534,x	;flip bit 0 if value is set
	ASL #2		;x4
	STA $08

	LDX #$00	;loop index

OAM_LOOP:
	LDA $03
	BNE XLEFT

	LDA $00
	SEC
	SBC XDISP,x
	CLC
	ADC XBIAS,x		;XBIAS
	STA $0300|!Base2,y
	BRA XNEXT
XLEFT:
	LDA $00
	CLC
	ADC XDISP,x
	STA $0300|!Base2,y
XNEXT:

	LDA $01
	CLC
	ADC YDISP,x
	STA $0301|!Base2,y

	TXA	
	CLC
	ADC $08
	PHX
	TAX
	LDA TILEMAP,x
	STA $0302|!Base2,y
	PLX

	LDA $04
	ORA $64
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
	CPX #$04	;4 tiles ATM
	BEQ END_LOOP
	JMP OAM_LOOP

END_LOOP:
	LDX $15E9|!Base2	;sprite index

	LDY #$02		;16x16
	LDA #$03		;4 tiles
	JSL $01B7B3|!BankB	;bookkeeping
	RTS