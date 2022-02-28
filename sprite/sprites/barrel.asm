!FlyTime = !7FAB40,x
!BarrelPace = !7FAB4C,x ; 1, 2 or 3.

print "INIT ",pc
	STZ !157C,x
	STZ !C2,x
	STZ !1570,x
	RTL
	
print "MAIN ",pc
	PHB : PHK : PLB
	JSR CodeStart
	PLB
	RTL
	
MarioSpeedY:	db $90,$D0,$00,$30,$70,$30,$00,$D0
MarioSpeedX:	db $00,$30,$40,$30,$00,$D0,$C0,$D0 
MarioDir:		db $00,$01,$01,$01,$01,$00,$00,$00
MarioPose:		db $24,$0C,$0C,$0C,$24,$0C,$0C,$0C
CenterSpeed:	db $B0,$50

Return:
	RTS
CodeStart:
	JSR GFX
	LDA $9D
	BNE Return
	LDA !14C8,x
	CMP #$08
	BNE Return
	LDA !1540,x
	BEQ SkipFlying
	JMP Flying
SkipFlying:
	JSL $01A7DC
	BCC Return
	LDA #$05 : STA $1497|!Base2
	PHX
	LDX #!SprSize-1
LOOP:	
	LDA !7FAB9E,x
	CMP !7FAB9E,x
	BNE DONE
	STZ !1540,x
	DEX
	BPL LOOP
DONE:	
	PLX
	LDA !7FAB10,x
	AND #$04
	BNE ExtraSet
	INC !1570,x
	BRA FrameCount
ExtraSet:
	DEC !1570,x
FrameCount:
	LDA !BarrelPace
	TAY
	LDA !1570,x
-	LSR
	DEY : BPL -
	AND #$07
	STA !C2,x
	LDA #$FF
	STA $78
	STZ $7D
	PHY
	%SubHorzPos()
	LDA CenterSpeed,y
	STA $7B
	PLY
	LDA !D8,x
	SEC
	SBC #$16
	STA $96
	LDA !14D4,x
	SBC #$00
	STA $97
	BIT $16
	BMI FlyIt
	RTS
FlyIt:
	STZ $140D|!Base2
	LDA #$09	; \ plays the sound effect when a
	STA $1DFC|!Base2	; / Thwomp hits the ground
	LDA !FlyTime
	STA !1540,x
	RTS
Flying:
	LDA $77
	BNE Stop
	LDY !C2,x
	LDA MarioSpeedX,y : STA $7B
	LDA MarioSpeedY,y : STA $7D
	LDA MarioPose,y : STA $72
	LDA MarioDir,y : STA $76
	RTS
Stop:
	STZ !1540,x
	RTS
	

Tilemap:
	db $80,$82,$A0,$A2
	db $84,$86,$A4,$A6
	db $88,$8A,$A8,$AA
	db $8C,$8E,$AC,$AE
	db $C0,$C2,$E0,$E2
	db $8C,$8E,$AC,$AE
	db $88,$8A,$A8,$AA
	db $84,$86,$A4,$A6
	
X_OFFSET:	
	db $F8,$08,$F8,$08
	db $F8,$08,$F8,$08
	db $F8,$08,$F8,$08
	db $F8,$08,$F8,$08
	db $F8,$08,$F8,$08
	db $08,$F8,$08,$F8
	db $08,$F8,$08,$F8
	db $08,$F8,$08,$F8
Y_OFFSET:	
	db $F9,$F9,$09,$09
Flip:
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $00,$00,$00,$00
	db $40,$40,$40,$40
	db $40,$40,$40,$40
	db $40,$40,$40,$40
	
GFX:
	%GetDrawInfo()
	LDA !C2,x
	ASL #2
	STA $02
	LDA #$03 : STA $03
.loop
	LDA $02
	CLC : ADC $03
	TAX
	LDA Flip,x
	STA $04
	LDA $00
	CLC : ADC X_OFFSET,x
	STA $0300|!Base2,y
	PHX
	LDX $03
	LDA $01
	CLC : ADC Y_OFFSET,x
	STA $0301|!Base2,y
	PLX
	LDA Tilemap,x
	STA $0302|!Base2,y
	PHX
	LDX $15E9|!Base2
	LDA !15F6,x
	ORA $64
	ORA $04
	PLX
	STA $0303|!Base2,y
	INY #4
	DEC $03
	BPL .loop
	LDX $15E9|!Base2
	LDY #$02
	LDA #$03
	JSL $01B7B3
	RTS
