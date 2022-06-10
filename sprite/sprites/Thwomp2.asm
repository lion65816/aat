;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;SMW Thwomp
;;
;;This is a disassembly of sprite 26 in SMW - Thwomp
;;
;;Pure version - for your ASMing needs (or just w/o fluff)
;;Only difference is a few optimizations.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisplay:
db $FC,$04,$FC,$04,$00

YDisplay:
db $00,$00,$10,$10,$08

Tiles:
db $80,$80,$82,$82,$84

!AngryFace = $86

Properties:
db $03,$43,$03,$43,$03

!TimeOnFloor = $40		;how long it stays on floor when hit it (when it's about to rise up)

!SoundEf = $09			;sound effect that plays when it lands

!SoundBank = $1DFC		;

!MaxYSpeed = $3E		;it's maximum speed

!Acceleration = $04		;how fast it gets speed

!ShakeTime = $18		;how long screen shakes

Print "INIT ",pc
LDA !D8,x			;store it's original position
STA !151C,x			;

LDA !E4,x			;Slightly displace horizontally
CLC : ADC #$08			;
STA !E4,x			;so it'll be in the middle of two blocks
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

;dw .State1
;dw .State2
;dw .State3

BEQ .State1			;but we can do better!
DEC				;
BEQ .State2			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;State 3 - Rising
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.State3
LDA !1540,x			;If it's not time to rise yet
BNE .Re				;welp
STZ !1528,x			;reset face
LDA !D8,x			;
CMP !151C,x			;
BNE .KeepGoin			;keep raising, untill it reaches it's original position

;LDA #$00			;ew, really?
;STA !C2,x			;Nintendo, what're ya doin' with my life?

STZ !C2,x			;
RTS

.KeepGoin
LDA #$F0			;Keep raising
STA !AA,x			;
JSL $01801A|!BankB		;update speed
RTS

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
;State 2 - Falling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.State2
JSL $01801A|!BankB		;update speed and positions based on it and etc. and etc. and lalalala.
LDA !AA,x			;
CMP #!MaxYSpeed			;
BCS .NoBoost			;
ADC #!Acceleration		;accelerate
STA !AA,x			;

.NoBoost

JSL $019138|!BankB		;interact with objects
LDA !1588,x			;
AND #$04			;
BEQ .Re2			;if it's not on floor, return
;JSR $019A04			;

LDA !1588,x			;If touching anything that is layer 2
BMI .Speed1			;set falling speed
LDA #$00			;otherwise reset
LDY !15B8,x			;unless it's on some slope
BEQ .Speed2			;

.Speed1
LDA #$18			;

.Speed2				;
STA !AA,x			;

LDA #!ShakeTime			;
STA $1887|!Base2		;shake screen

LDA #!SoundEf			;
STA !SoundBank|!Base2		;sound effect

LDA #!TimeOnFloor		;
STA !1540,x			;how long it stays on floor

INC !C2,x			;to the next state!

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