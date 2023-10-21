;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fire Magikoopa
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Uses first extra bit: YES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!OnlyOne =		0	;If 1 then no other Fire Magikoopa can spawn
!WandTile =		$99


print "INIT ",pc
if !OnlyOne
			LDA !7FAB9E,x
			STA $00
			TXY
			LDX #!SprSize-1
CheckSprite:
			CPX $15E9|!addr
			BEQ NextSprite
			LDA !14C8,x
			BEQ NextSprite
			LDA !7FAB9E,x
			CMP $00
			BNE NextSprite
			LDA !7FAB10,x
			AND #$08
			BEQ NextSprite
			LDA #$00
			STA !14C8,y
			TYX
			RTL
NextSprite:	DEX
			BPL CheckSprite
			STZ $18BF|!addr
			TYX
endif
			RTL

print "MAIN ",pc
			PHB
			PHK
			PLB
			LDA !9E,x
			PHA
if !SA1
			LDA $87
			PHA
endif
			LDA #$1F
			STA !9E,x
if !SA1
			STA $87
endif
			JSR MainCode
if !SA1
			PLA
			STA $87
endif
			PLA
			STA !9E,x
			LDX $15E9|!addr
			LDA !14C8,x
			BEQ ReturnL
			CMP #$05
			BCS ReturnL
			LDA !14C8,x
			STA !1FD6,x
			LDA #$08
			STA !14C8,x
ReturnL:	PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainCode:	LDA !1FD6,x
			BEQ LabelFF
			BMI SprWait
			CMP #$02
			BEQ SprKilled
			CMP #$04
			BEQ SprSpinJump
LabelFF:		LDA #$01
			STA !15D0,x
			LDA !15A0,x
			BEQ Label00
			STZ !C2,x
Label00:	LDA !C2,x
			AND #$03
			JSL $0086DF|!bank

States:		dw State0,State1,State2,State3

SprWait:	LDA $14
			AND #$03
			BEQ Return8
			DEC !1626,x
			BNE Return8
			STZ !1FD6,x
			LDA #$7F
			AND !15F6,x
			STA !15F6,x
			LDA #$7F
			AND !1686,x
			STA !1686,x
			STZ !C2,x
Return8:	RTS

SprKilled:	LDA !1686,x
			ORA #$80
			STA !1686,x
			LDA $9D
			BNE LabelA0
			JSL $01802A|!bank
LabelA0:	LDA #$00
			%SubOffScreen()
			LDA !15F6,x
			ORA #$80
			STA !15F6,x
			STZ !1602,x
			JSL $019D5F|!bank		;SubSprGfx1
			RTS

SprSpinJump:
			LDA #$FF
			STA !1626,x
			STA !1FD6,x
			RTS

State0:		LDA $18BF|!addr
			BEQ Label10
			STZ !14C8,x
			RTS

Label10:		LDA $9D
			BNE Return0
			LDY #$24
			STY $40
			LDA !1540,x
			BNE Return0
			JSL $01ACF9|!bank
			CMP #$D1
			BCS Return0
			;CLC
			ADC $1C
			AND #$F0
			STA !D8,x
			LDA $1D
			ADC #$00
			STA !14D4,x
			JSL $01ACF9|!bank
			CLC
			ADC $1A
			AND #$F0
			STA !E4,x
			LDA $1B
			ADC #$00
			STA !14E0,x
			%SubHorzPos()
			LDA $0E
			CLC
			ADC #$20
			CMP #$40
			BCC Return0
			STZ !AA,x
			LDA #$01
			STA !B6,x
			JSL $019138|!bank
			LDA !1588,x
			AND #$04
			BEQ Return0
			LDA $1862|!addr
			BNE Return0
			INC !C2,x
			STZ !1570,x
			JSR S_Label0
			%SubHorzPos()
			TYA
			STA !157C,x
Return0:	RTS

Table00:		db $04,$02,$00
X_Offset:		db $10,$F8

State2:		STZ !15D0,x
			JSL $01803A|!bank
			%SubHorzPos()
			TYA
			STA !157C,x
			LDA !1540,x
			BNE Label08
			INC !C2,x
S_Label0:		LDY #$34
			STY $40
Label08:		CMP #$40
			BNE Label1F
			PHA
			LDA $9D
			ORA !15A0,x
			BNE Label11
			JSR S_Label1
Label11:	PLA
Label1F:	LSR
			LSR
			LSR
			LSR
			LSR
			LSR
			TAY
			PHY
			LDA !1540,x
			LSR
			LSR
			LSR
			AND #$01
			ORA Table00,y
			STA !1602,x
			JSL $019D5F|!bank		;SubSprGfx1
			LDA !1602,x
			SEC
			SBC #$02
			CMP #$02
			BCC Label12
			LSR
			BCC Label12
			LDA !15EA,x
			TAX
			INC $0301|!addr,x
			LDX $15E9|!addr
Label12:		PLY
			CPY #$01
			BNE Label13
			JSR S_Label2
Label13:		LDA !1602,x
			CMP #$04
			BCC Return1
			LDY !157C,x
			LDA !E4,x
			CLC
			ADC X_Offset,y
			SEC
			SBC $1A
			LDY !15EA,x
			STA $0308|!addr,y
			LDA !D8,x
			SEC
			SBC $1C
			CLC
			ADC #$10
			STA $0309|!addr,y
			LDA !157C,x
			LSR A
			BCS Label14
			ORA #$40
Label14:	ORA $64
			ORA !15F6,x
			STA $030B|!addr,y
			LDA #!WandTile
			STA $030A|!addr,y
			TYA
			LSR A
			LSR A
			TAY
			LDA !15A0,x
			STA $0462|!addr,y
Return1:	RTS

S_Label1:	LDA !E4,x
			CLC
			ADC #$0A
			STA $00
			LDA !14E0,x
			ADC #$00
			STA $01
			LDA !D8,x
			STA $02
			LDA !14D4,x
			STA $03
			REP #$20
			LDA $94
			STA $04
			LDA $96
			STA $06
			SEP #$20
			JSR GetAngle
			LDA $00
			STA $0C
			LDA $01
			STA $0D
			LDY #$00
			LDA !7FAB10,x
			AND #$04
			BEQ Label2F
			LDY #$02
Label2F:	STY $0F
			LDA #$10
			STA $1DF9|!addr
GenLoop:	LDY #$07
Label21:	LDA $170B|!addr,y
			BEQ Label20
			DEY
			BPL Label21
			RTS

AddAngleL:		db $00,$20,$E0
AddAngleH:		db $00,$00,$FF

Label20:	LDA #$02
			STA $170B|!addr,y
			LDA !E4,x
			STA $171F|!addr,y
			LDA !14E0,x
			STA $1733|!addr,y
			LDA !D8,x
			CLC
			ADC #$0A
			STA $1715|!addr,y
			LDA !14D4,x
			ADC #$00
			STA $1729|!addr,y
			LDX $0F
			LDA #$20
			STA $0E
			LDA $0C
			CLC
			ADC AddAngleL,x
			STA $00
			LDA $0D
			ADC AddAngleH,x
			STA $01
			PHY
			JSR S_Label3
			PLY
			LDX $15E9|!addr
			LDA $00
			STA $1747|!addr,y
			LDA $01
			STA $173D|!addr,y
			DEC $0F
			BPL GenLoop
			RTS

S_Label3:	REP #$31
			LDA $00
			ADC.w #$0080
			AND.w #$01FF
			STA $02
			AND.w #$00FF
			ASL A
			TAX
			LDA $07F7DB|!bank,x
			STA $06
			LDA $00
			AND.w #$00FF
			ASL A
			TAX
			LDA $07F7DB|!bank,x
			STA $04
			SEP #$30
			LDA $0E
if !SA1
			STZ $2250
			STA $2251
			STZ $2252
else
			STA $4202
endif
			LDY $07
			BNE SkipCos0
			LDA $06
if !SA1
			STA $2253
			STZ $2254
			NOP
			BRA $00
			ASL $2306
			LDA $2307
else
			STA $4203
			NOP #4
			ASL $4216
			LDA $4217
endif
			ADC #$00
SkipCos0:	LSR $03
			BCC NotNegCos0
			EOR #$FF
			INC A
NotNegCos0:	STA $00
			LDA $0E
			LDY $05
			BNE SkipSin0
			LDA $04
if !SA1
			STA $2253
			STZ $2254
			NOP
			BRA $00
			ASL $2306
			LDA $2307
else
			STA $4203
			NOP #4
			ASL $4216
			LDA $4217
endif
			ADC #$00
SkipSin0:	LSR $01
			BCC NotNegSin0
			EOR #$FF
			INC A
NotNegSin0:	STA $01
			RTS

S_Label2:	LDA $13
			AND #$03
			ORA !186C,x
			ORA $9D
			BNE Return2
			JSL $01ACF9|!bank
			AND #$0F
			CLC
			LDY #$00
			ADC #$FC
			BPL Label40
			DEY
Label40:	CLC
			ADC !E4,x
			STA $02
			TYA
			ADC !14E0,x
			PHA
			LDA $02
			CMP $1A
			PLA
			SBC $1B
			BNE Return2
			LDA $148E|!addr
			AND #$0F
			;CLC
			;ADC #$FE
			ADC #$FD
			ADC !D8,x
			STA $00
			LDA !14D4,x
			ADC #$00
			STA $01
			JSL $0285BA|!bank
Return2:	RTS

State1:		JSR S_Label4
			STZ !1602,x
			JSL $019D5F|!bank		; SubSprGfx1
			RTS

; Disappear
S_Label5:	LDA !1540,x				;\ Only run code every third frame.
			BNE Return5				;|
			LDA #$02				;|
			STA !1540,x				;/
			DEC !1570,x				;\ If palette changing done,
			BNE Label52				;/ then branch.
			INC !C2,x				;> Go to the next sprite state.
			LDA #$10				;\ Set time until next appearance.
			STA !1540,x				;/
			PLA						;\ Return directly from main routine,
			PLA						;/ skipping graphics routine.
Return5:	RTS

; CheckPalette
S_Label4:	LDA !1540,x				;\ Only run code every fifth frame.
			BNE Label50				;|
			LDA #$04				;|
			STA !1540,x				;/
			INC !1570,x
			LDA !1570,x				;\ If palette changing done,
			CMP #$09				;| then branch.
			BNE Label51				;/
			LDY #$24				;\ Store CGADSUB settings.
			STY $40					;/ #$24 = backdrop enable, enable Layer 3
Label51:	CMP #$09				;\ If palette changing done,
			BNE Label52				;/ then branch.
			INC !C2,x				;> Go to the next sprite state.
			LDA #$70				;\ Set time before appearing again.
			STA !1540,x				;/
			RTS

; ChangePalette
Label52:	LDA !15F6,x
			ASL A
			ASL A
			ASL A
			ORA #$80
			AND #$F0
			STA $01
			LDA !1570,x				;\ Get color table offset (MagiKoopaPals).
			DEC A					;| Each row is 16 bytes, so need to
			ASL A					;| multiply by 4 after decrementing
			ASL A					;| the accumulator.
			ASL A					;|
			ASL A					;|
			TAX						;/
			STZ $00					;> Zero out the loop counter for dynamically uploading palette colors.
			LDY $0681|!addr
Label53:	LDA MagiKoopaPals,x
			STA $0684|!addr,y
			INY
			INX
			INC $00
			LDA $00
			CMP #$10
			BNE Label53
			LDX $0681|!addr
			LDA #$10
			STA $0682|!addr,x
			LDA $01
			STA $0683|!addr,x
			STZ $0694|!addr,x
			TXA
			;CLC
			;ADC #$12
			ADC #$11
			STA $0681|!addr
Label50:	LDX $15E9|!addr
			RTS

State3:		JSR S_Label5
			JSL $019D5F|!bank		; SubSprGfx1
			RTS

MagiKoopaPals:
			dw $7FFF,$294A,$0000,$0404,$042A,$469F,$000A,$002A
			dw $7FFF,$35AD,$0000,$0806,$044F,$321F,$000D,$00AD
			dw $7FFF,$4210,$0000,$0809,$0451,$1D7F,$0050,$0110
			dw $7FFF,$4E73,$0000,$080C,$0453,$08DF,$00B3,$0173
			dw $7FFF,$5AD6,$0000,$080F,$0455,$049B,$0116,$01D6
			dw $7FFF,$6739,$0000,$0812,$0458,$0457,$0179,$0239
			dw $7FFF,$739C,$0000,$0815,$045B,$0452,$01DC,$029C
			dw $7FFF,$7FFF,$0000,$0818,$087F,$087F,$023F,$02FF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetAngle:		REP #$20
			LDY #$00
			LDA $02
			SEC
			SBC $06
			BPL If_Plus20
			INY
			EOR.w #$FFFF
			INC A
If_Plus20:		STA $02
			LDA $00
			SEC
			SBC $04
			BPL If_Plus21
			INY
			INY
			EOR.w #$FFFF
			INC A
If_Plus21:		STA $00
			STY $04
			BEQ X_Zero
			CMP.w #$0100
			XBA
			ROR A
			XBA
			TAY
			LDA $02
			BEQ Y_Zero
			CMP.w #$0100
			XBA
			ROR A
			AND.w #$FF80
if !SA1
			PHX
			LDX #$01
			STX $2250
			LSR
			STA $2251
			STY $2253
			DEX
			STX $2254
			PLX
			TYA
			PHA
			LDA $2308
			ASL
			CMP $01,s
			PLA
			PHP
			LDA $2306
			ASL
			PLP
			ADC #$0000
else
			STA $4204
			STY $4206
			NOP #8
			LDA $4214
endif
			LSR A
			LSR A
			LSR A
			LSR A
			CMP.w #$0100
			SEP #$20
			BCC NoOverFlow
			LDA #$FF
NoOverFlow:		TAY
			LDA AtanTable,y
			LSR $04
			BCS If_Plus30
			EOR #$FF		;\
			INC A			; | É∆:360Åã-É∆
			BEQ If_Plus30		; |
			INC $01			;/
If_Plus30:		LSR $04
			BCS If_Plus31
			EOR #$FF		;\
			INC A			; | É∆:180Åã-É∆
			BNE If_Plus31		; |
			INC $01			;/
If_Plus31:		STA $00
			LDA #$FE
			TRB $01
			RTS

X_Zero:			SEP #$20
			LDY #$00
			LSR $04
			BCS If_Plus32
			INY
If_Plus32:		STY $01
			LDA #$80
			STA $00
			LDY #$FF
			RTS

Y_Zero:			SEP #$20
			STZ $00
			LDY #$00
			LDA $04
			AND #$02
			BNE If_Plus33
			INY
If_Plus33:		STY $01
			LDY #$00
			RTS

AtanTable:
db $00,$05,$0A,$0F,$13,$18,$1D,$21,$25,$29,$2D,$31,$34,$37,$3A,$3D
db $40,$42,$44,$46,$49,$4A,$4C,$4E,$50,$51,$53,$54,$55,$56,$58,$59
db $5A,$5B,$5C,$5D,$5D,$5E,$5F,$60,$60,$61,$62,$62,$63,$64,$64,$65
db $65,$66,$66,$67,$67,$68,$68,$68,$69,$69,$6A,$6A,$6A,$6B,$6B,$6B
db $6C,$6C,$6C,$6C,$6D,$6D,$6D,$6D,$6E,$6E,$6E,$6E,$6F,$6F,$6F,$6F
db $6F,$70,$70,$70,$70,$70,$71,$71,$71,$71,$71,$71,$71,$72,$72,$72
db $72,$72,$72,$72,$73,$73,$73,$73,$73,$73,$73,$73,$74,$74,$74,$74
db $74,$74,$74,$74,$74,$74,$75,$75,$75,$75,$75,$75,$75,$75,$75,$75
db $75,$75,$76,$76,$76,$76,$76,$76,$76,$76,$76,$76,$76,$76,$76,$76
db $76,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77,$77
db $77,$77,$77,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$78
db $78,$78,$78,$78,$78,$78,$78,$78,$78,$78,$79,$79,$79,$79,$79,$79
db $79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79,$79
db $79,$79,$79,$79,$79,$79,$79,$79,$79,$7A,$7A,$7A,$7A,$7A,$7A,$7A
db $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A
db $7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$7A,$80;