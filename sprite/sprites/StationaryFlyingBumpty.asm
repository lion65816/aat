;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bumpty from YI by Romi (optimized by Blind Devil - revision 2018-23-01)
; Corrected by Darolac (2021-12-07)
;  Made flying-only stationary/up and down only by RussianMan (requested by Anorakun) (hopefully before 2023)
;
;Extra Bit:
;Clear - Flying in place, doesn't move in any way
;Set - Flying up and down
;
;Extra Bytes are only used if extra bit is set
;
;Extra Byte 1:
;Max Y-speed (1-7F - downward, 81-FF - upward)
;
;Extra Byte 2:
;Acceleration (you probably don't want this to be too high, recommended values are from 1 to F)
;
;be aware of high speed and acceleration combos (there's potential of clipping inside bumpty when bouncing on top with extreme speeds)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!BoingSFX = $08
!BoingPort = $1DFC

MarioSpeed:		db $40,$C0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!FlyingBody 		= $86				;the only body tile it's using, since it's always flying

!LegTile		= $8A				;the only leg tile it's using

!Wing1			= $88
!Wing2			= $98

!Sweat1			= $89
!Sweat2			= $99

;flap wings and sweat, must be a real work out
WingAndSweatTiles:
			db !Wing1,!Wing2
			db !Sweat1,!Sweat2

;order: wing1, wing 2, sweat1, sweat2
WingAndSweatXDisp:
			db $08,$06
			db $0C,$0D

WingAndSweatYDisp:
			db $02,$06
			db $FE,$FF	

!LegXDisp1 = 		$03
!LegXDisp2 =		$08

!LegYDisp =		$0D

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;INIT & MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!SpriteFlyingState = !C2,x			;0 - flying in place (no speed), 1 - flying up and down

!YSpeedAccel = !1510,x
!YSpeedMax = !151C,x

!RAM_SpriteSpeedY	= !AA
!RAM_SpriteSpeedX	= !B6

			print "INIT ",pc
			%SubHorzPos()
			TYA
			STA !157C,x

			LDA !extra_bits,x			;either flying, or flying but its up and down
			AND #$04
			STA !SpriteFlyingState
			BEQ InitReturn

;extra bytes set
LDA !extra_byte_1,x
STA !YSpeedMax

LDA !extra_byte_2,x
STA !YSpeedAccel

LDA !YSpeedMax
BPL InitReturn

LDA !YSpeedAccel
EOR #$FF
INC
STA !YSpeedAccel

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

SpriteRoutine:
			JSR GFX

			LDA !14C8,x
			EOR #$08
			ORA $9D
			BNE Return
			%SubOffScreen()

JSR FLY

;more movement related and interact with player
Update:			JSL $018032|!BankB

InteractWithMario:	LDA #$83
			LDY $1490|!Base2
			BEQ NotHaveStar

			LDA #$01
NotHaveStar:		STA !167A,x
			LDA !154C,x
			BNE InteractReturn

			JSL $01A7DC|!BankB
			;LDA #$83
			;STA !167A,x				;???
			BCC InteractReturn

STZ $00

			%SubVertPos()

.CheckPosition
			LDA $0F
			PHA

			LDA $187A|!Base2	;yoshi check
			BEQ +

			PLA
			CLC
			ADC #$10
			BRA ++

+
			PLA
++
			CMP #$EB
			;BPL TouchesSides
			BPL .SecondCheck

			;LDA $7D		;reduce likelyhood of triggering side interaction when clipping even further
			;BMI TouchesSides

			LDA $187A|!Base2
			BEQ +

			LDA #$2C
			BRA ++

.SecondCheck
LDA $00						;both checks failed
BNE TouchesSides				;player wasn't above the sprite, go away
%SubVertPosActualPos()				;double check the position, so that clipping inside bumpty and triggering "touched from side" check is less likely
INC $00
BRA .CheckPosition

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

			%SubHorzPos()						;face the player
			TYA
			STA !157C,x

			;LDA #$01
			;STA !1504,x						;i forgot what used this but w/e (probably tackling related, but I removed coding for it)

.Re
			RTS

;;;;;;;;;;;;;;;;;;;;;;;;;
;Main routine
;;;;;;;;;;;;;;;;;;;;;;;;;

FLY:			
			JSL $01801A|!BankB
			JSL $018022|!BankB

			;LDA #$04				;flying body
			;STA !151C,x
			
			LDA !1540,x				;flapping wings timer
			BNE Flying000

			LDA #$03
			STA !1540,x				;every few frames

LDA !1528,x				;alternate wing and sweat
EOR #$01
STA !1528,x

Flying000:
LDA !SpriteFlyingState					;stay still in one place
BEQ .FlyingReturn

;even slower than before, thanks to additional fixes (can't wait for this to get rejected because it turns out it's faulty since explosive urchin hasn't been accepted (as of writing this which is Dec. 25 2022))
LDA !YSpeedMax				;no y-speed = move the heck on
BEQ .NoMove
CMP !AA,x				;same max check
BNE .Move

LDA !YSpeedMax
EOR #$FF
INC
STA !YSpeedMax

LDA !YSpeedAccel
EOR #$FF
INC
STA !YSpeedAccel
BRA .Move

.NoMove
.FlyingReturn
RTS

.Move
;now handle Y speed in the same janky way
.AccelerateY
LDA !YSpeedMax
BMI .NegativeVert

LDA !RAM_SpriteSpeedY,x
BMI .NormAccelVertPositive
CMP !YSpeedMax
;LDA !YSpeedMax
BCC .NormAccelVertPositive

.FixValueVert
LDA !YSpeedMax
STA !RAM_SpriteSpeedY,x
RTS

.NormAccelVertPositive
LDY #$00
LDA !RAM_SpriteSpeedY,x
BMI .StillNegativeVert
INY					;mark that we were positive beforehand

.StillNegativeVert
CLC : ADC !YSpeedAccel
STA !RAM_SpriteSpeedY,x

DEY
BNE .ContinueForReal

LDA !RAM_SpriteSpeedY,x			;did it overflow?
BMI .FixValueVert			;
RTS

.NegativeVert
LDA !RAM_SpriteSpeedY,x
BPL .NormAccelVertNegative
CMP !YSpeedMax
;LDA !YSpeedMax
BCC .FixValueVert

.NormAccelVertNegative
LDY #$00
LDA !RAM_SpriteSpeedY,x
BPL .StillPositiveVert
INY					;mark that we were negative beforehand

.StillPositiveVert
CLC : ADC !YSpeedAccel
STA !RAM_SpriteSpeedY,x

DEY
BNE .ContinueForReal

LDA !RAM_SpriteSpeedY,x			;did it overflow?
BPL .FixValueVert			;y'know the drill

.ContinueForReal
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sprite Graphic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!WingSlot = 0
!SweatSlot = 1
!BodySlot = 2
!Leg1Slot = 3
!Leg2Slot = 4

;a more straightforward routine, since it's always flying
GFX:
%GetDrawInfo()

LDA !1528,x		;wing+sweat animation
;ASL
STA $03

LDA !157C,x		;facing
STA $02

LDA $64
ORA !15F6,x
STA $04			;prop

LDA $02
BNE .Live

LDA #$40
TSB $04

.Live
;draw wing and sweat, then body, then legs

;Tile X-positions---------------- (handle x-displacement)
LDX $03
LDA WingAndSweatXDisp,x
JSR HandleTileXFlipDisplacement
STA $0300+(!WingSlot*4)|!addr,y

;LDA $00
LDA WingAndSweatXDisp+2,x
JSR HandleTileXFlipDisplacement
STA $0300+(!SweatSlot*4)|!addr,y

LDA $00
STA $0300+(!BodySlot*4)|!addr,y

;LDA $00
;CLC : ADC #!LegXDisp1
LDA #!LegXDisp1
JSR HandleTileXFlipDisplacement
STA $0300+(!Leg1Slot*4)|!addr,y

;LDA $00
;CLC : ADC #!LegXDisp2
LDA #!LegXDisp2
JSR HandleTileXFlipDisplacement
STA $0300+(!Leg2Slot*4)|!addr,y

;Tile Y-positions----------------
LDA $01
CLC : ADC WingAndSweatYDisp,x
STA $0301+(!WingSlot*4)|!addr,y

LDA $01
CLC : ADC WingAndSweatYDisp+2,x
STA $0301+(!SweatSlot*4)|!addr,y

LDA $01
STA $0301+(!BodySlot*4)|!addr,y

LDA $01
CLC : ADC #!LegYDisp
STA $0301+(!Leg1Slot*4)|!addr,y
STA $0301+(!Leg2Slot*4)|!addr,y

;Tilemap------------------------

LDA WingAndSweatTiles,x
STA $0302+(!WingSlot*4)|!addr,y

LDA WingAndSweatTiles+2,x
STA $0302+(!SweatSlot*4)|!addr,y

LDA #!FlyingBody
STA $0302+(!BodySlot*4)|!addr,y

LDA #!LegTile
STA $0302+(!Leg1Slot*4)|!addr,y
STA $0302+(!Leg2Slot*4)|!addr,y

;Properties---------------------

LDA $04
STA $0303+(!WingSlot*4)|!addr,y
STA $0303+(!SweatSlot*4)|!addr,y
STA $0303+(!BodySlot*4)|!addr,y
STA $0303+(!Leg1Slot*4)|!addr,y
STA $0303+(!Leg2Slot*4)|!addr,y

;Tile sizes---------------------

TYA
LSR #2
TAX
STZ $0460+!WingSlot|!addr,x		;8x8 tiles
STZ $0460+!SweatSlot|!addr,x
STZ $0460+!Leg1Slot|!addr,x
STZ $0460+!Leg2Slot|!addr,x

LDA #$02
STA $0460+!BodySlot|!addr,x		;16x16 tile

LDX $15E9|!addr
LDY #$FF
LDA #$04				;5 tiles total
%FinishOAMWrite()
RTS

;an ugly way to handle tile x positions for different facing, which is what the original sprite uses. does make changing x-disp table more straightforward though
HandleTileXFlipDisplacement:
PHY
LDY $02
BNE .NoFaceDisp

SEC
SBC #$04
EOR #$FF
INC A
CLC
ADC #$04

.NoFaceDisp
PLY
CLC : ADC $00
RTS