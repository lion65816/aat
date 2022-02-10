;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bumpty from YI by Romi (optimized by Blind Devil - revision 2018-23-01)
; Corrected by Darolac (2021-12-07)
;
;will have different abilities depending on extra bits and initial X position
;
;Uses first extra bit: YES
;Clear
;X0 = Walks
;X1 = Tackles
;Set
;X0 = Flies
;X1 = Flies and won't change direction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BoingSFX = $08
!BoingPort = $1DFC

Xspeed:			db $08,$F8
Xspeed2:		db $F4,$0C
TacklingSpeed:		db $20,$E0
MarioSpeed:		db $40,$C0
SpeedTable:		db $FF,$01,$FF
CheckMarioPos:		db $F4,$00

TacklingAnime:		db $07,$FF,$00,$06
TacklingBodyIndex:	db $03,$00,$01,$02,$02,$01,$00
TacklingImageIndex:	db $0E,$0B,$0C,$0D,$0D,$0C,$0B

FlyingXspeed:		db $0A,$F6

FlyingMaxSpeed:		db $10,$F0
FlyingMaxYspeed:	db $F4,$0C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Body0			= $8C
!Body1			= $82
!Body2			= $80
!Body3			= $84
!Body4			= $86
!BodyProp0		= $50
!BodyProp1		= $10

!Leg0			= $8A
!Leg1			= $8B
!Leg2			= $9A
!Leg3			= $9B
!LegProp0		= $17
!LegProp1		= $57

!Hand0			= $88
!Hand1			= $98
!Sweat0			= $89
!Sweat1			= $99

;;;;;;;;;;;;;;;;;;;;;;;;;

BodyTile:		db !Body0,!Body1,!Body2,!Body3,!Body4

BodyVertDisp:		db $FF,$FE,$FE,$FF,$00,$00,$FF,$FF
			db $FE,$00,$00,$00,$00,$00,$00,$00
			db $00,$00

BodyProperty:		db !BodyProp0,!BodyProp1


LegTileMap:		db !Leg3,!Leg3
			db !Leg1,!Leg1
			db !Leg1,!Leg1
			db !Leg0,!Leg1
			db !Leg2,!Leg2
			db !Leg3,!Leg0
			db !Leg3,!Leg2
			db !Leg3,!Leg3

			db !Leg2,!Leg2
			db !Leg2,!Leg2
			db !Leg3,!Leg3
			db !Leg0,!Leg0
			db !Leg0,!Leg0
			db !Sweat1,!Sweat1
			db !Leg0,!Leg0
			db !Leg0,!Leg0

			db !Leg0,!Leg0
			db !Leg2,!Leg2

			db !Hand0,!Sweat0
			db !Hand1,!Sweat1


LegHorzDisp:		db $02,$06,$01,$08,$01,$08,$FC,$0A,$FE,$0A,$00,$0C,$02,$08,$04,$06
			db $01,$06,$00,$06,$02,$06,$FD,$03,$FC,$FC,$00,$00,$00,$08,$00,$08
			db $03,$08,$FE,$03
			db $08,$0C,$06,$0D

LegVertDisp:		db $08,$08,$07,$08,$07,$08,$06,$08,$08,$08,$08,$08,$08,$07,$08,$07
			db $0A,$0A,$09,$09,$08,$08,$08,$08,$08,$08,$00,$00,$08,$08,$0C,$0C
			db $0D,$0D,$09,$09
			db $02,$FE,$06,$FF

LegProperty:		db !LegProp0,!LegProp0
			db !LegProp0,!LegProp1
			db !LegProp0,!LegProp1
			db !LegProp1,!LegProp1
			db !LegProp0,!LegProp1
			db !LegProp0,!LegProp0
			db !LegProp1,!LegProp0
			db !LegProp0,!LegProp0

			db !LegProp1,!LegProp1
			db !LegProp0,!LegProp0
			db !LegProp0,!LegProp0
			db !LegProp0,!LegProp0
			db !LegProp0,!LegProp0
			db !LegProp0,!LegProp0
			db !LegProp0,!LegProp1
			db !LegProp1,!LegProp0

			db !LegProp0,!LegProp0
			db !LegProp0,!LegProp0

			db !LegProp0,!LegProp0
			db !LegProp0,!LegProp0




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT & MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			%SubHorzPos()
			TYA
			STA !157C,x
			LDA !7FAB10,x
			AND #$04
			STA !C2,x
			BEQ Init001
			INC !1504,x
Init001:		LDA !E4,x
			AND #$10
			BEQ Init000
			INC !C2,x
			INC !C2,x
Init000:		LDA !C2,x
			CMP #$06
			BNE InitReturn
			%SubHorzPos()
			TYA
			STA !157C,x
InitReturn:		RTL

			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR SpriteRoutine
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Return:			RTS

SpriteRoutine:		JSR SpriteGraphic

			LDA !14C8,x
			CMP #$08
			BNE Return
			LDA $9D
			BNE Return
			LDA #$00
			%SubOffScreen()

			PER.w $0015
			LDA !C2,x
			JSL $0086DF|!BankB
			dd Walking,Tackling,Flying,Flying

Update:			JSL $018032|!BankB
			LDA !C2,x
			AND #$04
			BNE InteractWithMario

			LDA !E4,x
			PHA
			LDA !14E0,x
			PHA
			LDA !D8,x
			PHA
			LDA !14D4,x
			PHA
			LDA !1588,x
			PHA
			JSL $01802A|!BankB
			LDA !C2,x
			CMP #$02
			BNE Update000
			LDA !1588,x
			AND #$03
			BEQ Update000
			LDA !B6,x
			EOR #$FF
			INC A
			STA !B6,x
			LDA !157C,x
			EOR #$01
			STA !157C,x

Update000:		PLA
			AND #$04
			BEQ UpdatePull
			LDA !C2,x
			BNE UpdatePull
			LDA !1588,x
			BIT #$04
			BEQ UpdatePull0
			AND #$03
			BEQ UpdatePull
UpdatePull0:		PLA
			STA !14D4,x
			PLA
			STA !D8,x
			PLA
			STA !14E0,x
			PLA
			STA !E4,x
			STZ !B6,x
			BRA InteractWithMario

UpdatePull:		PLA
			PLA
			PLA
			PLA

InteractWithMario:	LDA #$83
			LDY $1490|!Base2
			BEQ NotHaveStar
			LDA #$01
NotHaveStar:		STA !167A,x
			LDA !154C,x
			BNE InteractReturn
			JSL $01A7DC|!BankB
			LDA #$83
			STA !167A,x
			BCC InteractReturn

			%SubVertPos()
			LDA $0F
			PHA

			LDA $187A|!Base2
			BEQ +

			PLA
			CLC
			ADC #$10
			BRA ++

+
			PLA
++
			CMP #$EB
			BPL TouchesSides
			LDA $7D
			BMI TouchesSides

			LDA $187A|!Base2
			BEQ +

			LDA #$2C
			BRA ++
+
			LDA #$1C
++
			STA $00
			STZ $01

			LDA !14D4,x
			XBA
			LDA !D8,x
			REP #$20

			SEC
			SBC $00
			STA $96
			SEP #$20

			LDA #$B8
MARIO_Y_SPEED:		STA $7D
			LDA #!BoingSFX
			STA !BoingPort|!Base2
InteractReturn:		RTS

TouchesSides:		%SubHorzPos()
			LDA MarioSpeed,y
			STA $7B
			LDA #!BoingSFX
			STA !BoingPort|!Base2

			LDA !C2,x
			AND #$04
			BNE InteractReturn

			%SubHorzPos()
			TYA
			STA !157C,x
			LDA Xspeed2,y
			STA !B6,x
			LDA #$01
			STA !1504,x
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;Main routine
;;;;;;;;;;;;;;;;;;;;;;;;;

Walking:		LDA !1588,x
			AND #$04
			PHP
			LDA !1504,x
			BEQ Walking000
			PLP
			BEQ WalkingReturn1
DecreaseSpeed:		TXA
			EOR $13
			LSR
			BCC WalkingReturn1
			LDY #$00
			LDA !B6,x
			BPL WalkingDecSpeed
			INY
WalkingDecSpeed:	CLC
			ADC SpeedTable,y
			STA !B6,x
			BNE WalkingReturn1
			STZ !1504,x
			LDA !C2,x
			BNE WalkingReturn1
			STZ !1558,x
			STZ !1602,x
WalkingReturn1:		RTS
Walking000:		PLP
			BEQ StopWalking

WalkingOnGround:	LDA !1558,x
			BNE WalkingCheckTimer0
			JSL $01ACF9|!BankB
			AND #$3F
			CLC
			ADC #$80
			STA !1558,x
WalkingCheckTimer0:	BPL WalkingCheckTimer
			BIT #$0F
			BEQ WalkingChangeDir
WalkingCheckTimer:	CMP #$60
			BCC JustWalking
			CMP #$61
			BNE WalkingNotMove
			INC !1602,x
			JSL $01ACF9|!BankB
			AND #$01
			BRA WalkingDirection

WalkingChangeDir:	LDA !157C,x
			EOR #$01
WalkingDirection:	STA !157C,x
WalkingNotMove:		STZ !1602,x
			STZ !B6,x
			RTS

JustWalking:		INC !1602,x
			LDA !1602,x
			CMP #$08
			BNE WalkingSetSpeed
			LDA #$01
			STA !1602,x
WalkingSetSpeed:	LDY !157C,x
			LDA Xspeed,y
			STA !B6,x

			LDA !1588,x
			BEQ StopWalking
			AND #$03
			BEQ WalkingReturn

StopWalking:		STZ !1558,x
WalkingReturn:		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;

Tackling:		LDA !1504,x
			BEQ TacklingMain
			LDA #$20
			STA !1558,x
			STZ !151C,x
			LDA #$0B
			STA !1602,x
			STZ !1528,x
			JMP DecreaseSpeed

TacklingMain:		LDA !1588,x
			AND #$04
			STA $00
			LDA !1528,x
			DEC A
			BPL Tackling1
			LDA $00
			BEQ TacklingReturn
			LDA !1558,x
			BNE TacklingReturn
TacklingJump:		LDA #$E8
			STA !AA,x
			INC !1528,x
			LDA #$08
			STA !1602,x
			STZ !151C,x
			LDA #$01
			STA !1534,x
TacklingReturn:		RTS

Tackling1:		BNE Tackling2
			LDA !AA,x
			BMI Tackling1A
			LDA #$09
			STA !1602,x
Tackling1A:		LDA $00
			BEQ TacklingReturn
			INC !1528,x
			LDA #$0F
			STA !1558,x
			LDA #$0A
			STA !1602,x
			RTS

Tackling2:		DEC A
			BNE Tackling3
			LDA !1558,x
			BNE Tackling2A
			INC !1528,x
			%SubHorzPos()
			LDA TacklingSpeed,y
			STA !B6,x
			LDA #$02
			STA !1602,x
			TYA
TacklingDirection:	STA !157C,x
			RTS
Tackling2A:		AND #$03
			BNE TacklingReturn
			LDA !157C,x
			EOR #$01
			BRA TacklingDirection

Tackling3:		DEC A
			BNE Tackling4
			LDA !1558,x
			BNE Tackling3A
			TXA
			EOR $13
			LSR A
			BCC TacklingReturn2
			INC !1602,x
			LDA !1602,x
			CMP #$06
			BNE TacklingReturn2
			STZ !1602,x
			LDA #$08
			STA !1558,x
TacklingReturn2:	RTS
Tackling3A:		DEC A
			BEQ TacklingJump
			RTS

Tackling4:		LDA $00
			BEQ TacklingReturn2
			LDA !1558,x
			BNE TacklingReturn2

			LDY #$00
			LDA !B6,x
			BPL Tackling4B
			INY

Tackling4B:		LDA $14
			AND #$03
			BNE Tackling4A
			LDA !B6,x
			CLC
			ADC SpeedTable,y
			STA !B6,x
			BNE Tackling4A
			JSL $01ACF9|!BankB
			AND #$1F
			ADC #$30
			STA !1558,x
			STZ !1528,x

Tackling4A:		LDA #$03
			STA $01
			LDA !B6,x
			CLC
			ADC #$10
			CMP #$20
			BCS Tackling4C
			LDA #$07
			STA $01
Tackling4C:		LDA $14
			AND $01
			BNE Tackling4D
			LDA !1534,x
			CLC
			ADC SpeedTable+1,y
			CMP TacklingAnime,y
			BNE Tackling4E
			LDA TacklingAnime+2,y
Tackling4E:		STA !1534,x

Tackling4D:		LDA !1534,x
			TAY
			LSR #2
			STA !157C,x
			LDA TacklingBodyIndex,y
			STA !151C,x
			LDA TacklingImageIndex,y
			STA !1602,x
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;

Flying:			JSL $01801A|!BankB
			JSL $018022|!BankB

			LDA #$04
			STA !151C,x
			
			LDA !1540,x
			BNE Flying000
			LDA #$03
			STA !1540,x
			LDA !1528,x
			INC A
			AND #$01
			CLC
			ADC #$12
			STA !1528,x

Flying000:		LDA !C2,x
			AND #$02
			BEQ Flying007
			LDA #$10
			STA !1602,x
			LDY !157C,x
			LDA FlyingXspeed,y
			STA !B6,x
			BRA Flying005

Flying007:		LDA !1558,x
			BEQ Flying003
			DEC A
			BNE Flying004
			LDA !157C,x
			EOR #$01
			STA !157C,x
			INC !1504,x
Flying004:		LDA #$0F
			STA !1602,x
			DEC !151C,x
			BRA Flying005

Flying003:		TXA
			EOR $13
			AND #$03
			BNE Flying001
			LDA !1504,x
			CLC
			ADC !157C,x
			TAY
			LDA !B6,x
			CLC
			ADC SpeedTable,y
			STA !B6,x
			BNE Flying002
			LDA #$10
			STA !1558,x
Flying002:		LDY !157C,x
			CMP FlyingMaxSpeed,y
			BNE Flying001
			STZ !1504,x
Flying001:		LDA !1504,x
			EOR #$01
			CLC
			ADC #$10
			STA !1602,x

Flying005:		LDA !15AC,x
			BEQ Flying006
			DEC A
			BNE FlyingReturn
			LDA !1594,x
			EOR #$01
			STA !1594,x
			RTS

Flying006:		LDA $13
			AND #$01
			BNE FlyingReturn
			LDY !1594,x
			LDA !AA,x
			CLC
			ADC SpeedTable,y
			STA !AA,x
			CMP FlyingMaxYspeed,y
			BNE FlyingReturn
			LDA #$04
			STA !15AC,x
FlyingReturn:		RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite Graphic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SpriteGraphic:		%GetDrawInfo()

			PHX
			LDA !157C,x
			STA $02
			LDA !151C,x
			STA $04
			STZ $0F
			LDA !1602,x
			STA $03
			CMP #$0F
			BNE Graphic000
Graphic002:		JSR DrawBodyTile
			JSR DrawLegTile
			BRA GraphicLast

Graphic000:		LDA !C2,x
			AND #$04
			BEQ Graphic001
			LDA $03
			PHA
			LDA !1528,x
			STA $03
			JSR DrawLegTile
			PLA
			STA $03
			CMP #$10
			BEQ Graphic002
Graphic001:		JSR DrawLegTile
			JSR DrawBodyTile

GraphicLast:		PLX
			LDY #$FF
			LDA $0F
			DEC A
			JSL $01B7B3|!BankB
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;

DrawLegTile:		LDX #$01

LegGraphicLoop:		PHX
			TXA
			CLC
			ADC $03
			ADC $03
			TAX

			PHX
			TYA
			LSR #2
			TAX
			STZ $0460|!Base2,x
			PLX

			PHX
			LDA LegHorzDisp,x
			LDX $02
			BNE NoFlipLegHorz
			SEC
			SBC #$04
			EOR #$FF
			INC A
			CLC
			ADC #$04
NoFlipLegHorz:		CLC
			ADC $00
			STA $0300|!Base2,y
			PLX

			LDA $01
			CLC
			ADC LegVertDisp,x
			STA $0301|!Base2,y

			LDA LegTileMap,x
			STA $0302|!Base2,y

			LDA LegProperty,x
			LDX $02
			BNE NoFlipLegProp
			EOR #$40
NoFlipLegProp:		ORA $64
			STA $0303|!Base2,y

			PLX
			INY
			INY
			INY
			INY
			INC $0F
			DEX
			BPL LegGraphicLoop
			RTS
DontDrawLeg:
			PLX
			DEX
			BRA LegGraphicLoop

DrawBodyTile:		TYA
			LSR #2
			TAX
			LDA #$02
			STA $0460|!Base2,x

			LDX $02
			LDA BodyProperty,x
			LDX $15E9|!Base2
			ORA !15F6,x
			ORA $64
			STA $0303|!Base2,y

			LDA $00
			STA $0300|!Base2,y

			LDX $03
			LDA $01
			CLC
			ADC BodyVertDisp,x
			STA $0301|!Base2,y

			LDX $04
			LDA BodyTile,x
			STA $0302|!Base2,y

			INY
			INY
			INY
			INY
			INC $0F
			RTS