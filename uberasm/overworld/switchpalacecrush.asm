!yel	#= $10D-$DC
!red	#= $11B-$DC
!grn	#= $127-$DC
!blu	#= $121-$DC

SwitchLevel:
db !yel,!red,!grn,!blu
SwitchDestructionIndex:
db $01,$04,$09,$0A

init:
	JSL CrushSwitches
	PHB
	LDX $0DB3|!addr
	LDA $1F11|!addr,x
	REP #$30
	PHP
	PEA.w $7F7F
	PLB
	PLB
	LDX $837B
	LDA #$0300
	STA $837D+2,x
	STA $837D+10,x
	STA $837D+18,x
	STA $837D+26,x
	LDA #$FFFF
	STA $837D+32,x
	PLP
	BNE .submap
	LDA #$C027
	STA $837D,x
	LDA #$E027
	STA $837D+8,x
	LDA #$4021
	STA $837D+16,x
	LDA #$6021
	STA $837D+24,x
	PLB
	LDA.l $40C850
	PHA
	LDA.l $40C9F0
	BRA +
.submap
	LDA #$5022
	STA $837D,x
	LDA #$7022
	STA $837D+8,x
	LDA #$9828
	STA $837D+16,x
	LDA #$B828
	STA $837D+24,x
	PLB
	LDA.l $40CE2C
	PHA
	LDA.l $40CC98
+
	JSR DrawOVTile
	TXA
	CLC
	ADC #$0010
	TAX
	PLA
	JSR DrawOVTile
	SEP #$30
	RTL

DrawOVTile:
	AND #$00FF
	ASL
	JSL $06F540|!bank
	STA $0A
	LDY #$0000
	LDA [$0A],y
	STA $7F837D+4,x
	INY #2
	LDA [$0A],y
	STA $7F837D+12,x
	INY #2
	LDA [$0A],y
	STA $7F837D+6,x
	INY #2
	LDA [$0A],y
	STA $7F837D+14,x
	RTS

CrushSwitches:
.yellow
	LDA.l $40C9F0
	CMP #$79
	BNE .red
	LDA $1EA2+!yel|!addr
	BPL .red
	LDA #$86
	STA.l $40C9F0
.red
	LDA.l $40C850
	CMP #$77
	BNE .green
	LDA $1EA2+!red|!addr
	BPL .green
	LDA #$85
	STA.l $40C850
.green
	LDA.l $40CC98
	CMP #$79
	BNE .blue
	LDA $1EA2+!grn|!addr
	BPL .blue
	LDA #$86
	STA.l $40CC98
.blue
	LDA.l $40CE2C
	CMP #$77
	BNE .end
	LDA $1EA2+!blu|!addr
	BPL .end
	LDA #$85
	STA.l $40CE2C
.end
	RTL

main:
	LDA $13D9|!addr
	CMP #$0A
	BNE +
	LDY $1DE8|!addr
	CPY #$01
	BEQ CrushSwitches
+
	CMP #$01
	BNE .ret
	LDY #$03
	LDA $13BF|!addr
-
	CMP SwitchLevel,y
	BEQ +
	DEY
	BPL -
	RTL
+
	LDA $1B86|!addr
	BNE ++
	LDA $1DE9|!addr
	BEQ .ret
	INC $1B86|!addr
	LDX SwitchDestructionIndex,Y
	PHB
	LDA #$04|!bank8
	PHA
	PLB
	PHK
	PEA.w (+)-1
	PEA.w $8574
	PEA.w $E649-1
	JML $04E68A|!bank
+
	PLB
	LDA $1B86|!addr
++
	CMP #$02
	BNE .ret
	LDA $1DEA|!addr
	CMP #$FF
	BNE .ret
	STZ $1B86|!addr
.ret
	RTL