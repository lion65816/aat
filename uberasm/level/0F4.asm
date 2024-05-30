!FreeRAM	= $18B4|!addr
!BossBass	= $30

ParaSprite:
db $3F,$40
XSpd:
db $FA,$FB,$FC,$FD

load:
	JSL MultipersonReset_load
	RTL

init:
	JSL start_select_init

	LDX #!sprite_slots
-
	LDA !extra_bits,x
	AND #$08
	BEQ +
	LDA !new_sprite_num,x
	CMP #!BossBass
	BNE +
	LDA #$01
	STA !1504,x
	LDA #$39
	STA !166E,x
	STA !1686,x
	LDA #$BF
	STA !167A,x
+
	DEX
	BPL -
	LDA #$56
	STA !FreeRAM
	RTL

main:
	LDA $13D4|!addr
	ORA $9D
	BNE .ret
	DEC !FreeRAM
	BNE .ret
	LDA #$56
	STA !FreeRAM
	JSL $02A9DE|!bank
	BMI .ret
	TYX
	LDA #$08
	STA !14C8,x
	JSL $01ACF9|!bank
	LSR
	LDY #$00
	BCC +
	INY
+
	LDA.w ParaSprite,Y
	STA !9E,X
	JSL $07F7D2|!bank
	LDA $1C
	SEC
	SBC.b #$20
	STA !D8,X
	LDA $1D
	SBC.b #$00
	STA.w !14D4,X
	LDA.w $148D|!addr
	CLC
	ADC.b #$30
	PHP
	ADC $1A
	STA !E4,X
	PHP
	AND.b #$0E
	STA.w !1570,X
	LSR
	AND.b #$03
	TAY
	LDA.w XSpd,Y
	STA !B6,X
	LDA $1B
	PLP
	ADC.b #$00
	PLP
	ADC.b #$00
	STA.w !14E0,X
.ret
	JSL start_select_main

	; Reload the room upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
.return
	RTL
