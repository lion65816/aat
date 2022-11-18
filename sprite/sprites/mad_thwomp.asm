;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;Mad Thwomp, based on new disassembly by RussianMan, original modification by yoshicookiezeus.
;;
;;This thwomp when triggered keeps smashing up'n down.
;;
;;On Extra bit it'll move up first, otherwise it'll go down first.
;;
;;Credit is optional.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisplay:
db $FC,$04,$FC,$04,$00

YDisplay:
db $00,$00,$10,$10,$08

Tiles:
db $8E,$8E,$AE,$AE,$C8

!AngryFace = $CA

Properties:
db $03,$43,$03,$43,$03

!TimeOnFloor = $10		;how long it stays on floor when hit it (when it's about to rise up)

!SoundEf = $09			;sound effect that plays when it lands

!SoundBank = $1DFC		;

!MaxYSpeedDown = $3E		;it's maximum speed when going down

!MaxYSpeedUp = $C2		;it's maximum speed when going up

!Acceleration = $04		;how fast it gets speed

!ShakeTime = $18		;how long screen shakes

Blocked_Bits:
db $04,$08

Speed:
db $18,$00-$18

Print "INIT ",pc
LDA !extra_bits,x		;
AND #$04			;
BEQ .NoINC			;

INC !1534,x			;make it move up first on extra bit

.NoINC

LDA !E4,x			;Slightly displace horizontally
CLC : ADC #$08			;
STA !E4,x			;so it'll be in the middle of two blocks
.EndInit
RTL

Print "MAIN ",pc
PHB
PHK
PLB
JSR Thwomp
PLB
RTL

Thwomp:
JSR GFX				;GFX is the most important part!

LDA !14C8,x			;those guys know how to return
EOR #$08			;
ORA $9D				;
BNE .Re				;they should tell you what they do, not me!
%SubOffScreen()			;

JSL $01A7DC|!BankB		;interaction - check

LDA !C2,x			;
;JSL $0086DF|!BankB		;pointers...

BNE .StateWhatever		;why they exist

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;State 1 - Calm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.State1

LDA !186C,x			;this is what makes it fall instantly when offscreen vertically
BNE .EEE			;because 01AEEE

LDA !15A0,x			;don't do a thing when horizontally offscreen
BNE .Re				;

%SubHorzPos()			;
;TYA				;
;STA !157C,x			;157C isn't used anywhere?

STZ !1528,x			;calm down the face

LDA $0E				;if not close enough
CLC : ADC #$40			;
CMP #$80			;
BCS .SkipFace			;don't change face expression

;LDA #$01			;
;STA !1528,x			;

INC !1528,x			;I mean it's always zero before, so INC is ok, right?

.SkipFace
LDA $0E				;if even more close
CLC : ADC #$24			;
CMP #$50			;
BCS .Re				;

.EEE
LDA #$02			;
STA !1528,x			;it'll be angry, and...
INC !C2,x			;...it's gonna crash! AAA!

;LDA #$00			;are you serious?
;STA !AA,x			;nah, you're not

STZ !AA,x			;just like me

.Re
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;State 2 - Falling/Raising
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Probably not super effective, but better than how it was done original Mad Thwomp sprite, right?

.StateWhatever
JSL $01801A|!BankB		;update speed and positions based on it and etc. and etc. and lalalala.
JSL $019138|!BankB		;interact with objects

LDA !1540,x			;
BNE .Re2			;

LDA !1534,x			;
AND #$01			;
TAY				;
BNE .Raise			;

LDA !AA,x			;
CMP #!MaxYSpeedDown		;
BCS .NoBoost			;
ADC #!Acceleration		;accelerate
BRA .End			;

.Raise

LDA !AA,x			;
CMP #!MaxYSpeedUp		;
BMI .NoBoost			;
SBC #!Acceleration		;accelerate x2

.End
STA !AA,x			;

.NoBoost

LDA !1588,x			;
AND Blocked_Bits,y		;
BEQ .Re2			;if it's not on floor, return
;JSR $019A04			;

LDA !1588,x			;If touching anything that is layer 2
BMI .Speed1			;set falling speed
LDA #$00			;otherwise reset
LDY !15B8,x			;unless it's on some slope
BEQ .Speed2			;(it's not possible for when it goes up. oh well.)

.Speed1
LDA #$18;Speed,y		;

.Speed2				;
STA !AA,x			;

LDA #$18			;
STA $1887|!Base2		;shake screen

LDA #!SoundEf			;
STA !SoundBank|!Base2		;sound effect

LDA #!TimeOnFloor		;
STA !1540,x			;how long it stays on floor

;CPY #$01			;
;BEQ .DEC			;DEC or INC? That's the question.

INC !1534,x			;Change movement

.Re2
RTS

GFX:
%GetDrawInfo()			;

LDA !1528,x			;thwomp's expression to 02
STA $02				;

PHX				;
LDX #$03			;

CMP #$00			;if calm, there's no additional face tile
BEQ Loop			;
INX				;

Loop:
LDA $00				;tiles X pos
CLC : ADC XDisplay,x		;
STA $0300|!Base2,y		;

LDA $01				;tiles Y pos
CLC : ADC YDisplay,x		;
STA $0301|!Base2,y		;

LDA Properties,x		;tiles properties
ORA $64				;
STA $0303|!Base2,y		;

LDA Tiles,x			;
CPX #$04			;if it's not additional face tile
BNE .SimplyStore		;SimplyStore
PHX				;
LDX $02				;
CPX #$02			;if angry
BNE .RestoreX			;
LDA #!AngryFace			;use angry face instead of what we have in table

.RestoreX
PLX				;

.SimplyStore
STA $0302|!Base2,y		;

INY #4				;next tile
DEX				;
BPL Loop			;loop

PLX				;we need to pull this x outta here.

LDY #$02			;LDY #$02 means 16x16 tiles, LDY #$00 means 8x8 tiles.
LDA #$04			;we have 5 tiles. 0 counts. nothingness doesn't mean nothing.
JSL $01B7B3|!BankB		;call routine that'll do the job of displaying tiles on screen. magic!
RTS