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
db $8E,$8E,$AE,$AE,$C8

!AngryFace = $CA

Properties:
db $01,$41,$01,$41,$01

!PROP_CLEAR		= $0C
!PROP_SET		= $0E

XSpeed:
	db $E0,$20 ; speed if extra bit clear
	db $C0,$40 ; speed if extra bit set

!TimeOnFloor = $10		;how long it stays on floor when hit it (when it's about to rise up)

!SoundEf = $09			;sound effect that plays when it lands

!SoundBank = $1DFC		;

!MaxYSpeed = $50		;it's maximum speed

RISE_SPEED:
	db $E0,$D0

!Acceleration = $08		;how fast it gets speed

!ShakeTime = $18		;how long screen shakes

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;RAM Defines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!ThwompStates	= !C2
!LockedHeight	= !151C
!LockedHei_Hi	= !1570
!ThwompFace		= !1528
!MoveCheck		= !1534 ; 1 = right, 0 = left

!ThwompTimer	= !1540

!SpriteVOffScreenFlag = !186C
!SpriteHOffScreenFlag = !15A0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Print "INIT ",pc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LDA !D8,x : STA !LockedHeight,x		;store it's original position
LDA !14D4,x : STA !LockedHei_Hi,x

LDA !E4,x			;Slightly displace horizontally
CLC : ADC #$08			;
STA !E4,x			;so it'll be in the middle of two blocks
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Print "MAIN ",pc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PHB
PHK
PLB
JSR Thwomp
JSR GFX				;GFX is the most important part!
PLB
RTL

Thwomp:

LDA !14C8,x			;those guys know how to return
EOR #$08			;
ORA $9D				;
BNE .Re3				;they should tell you what they do, not me!
%SubOffScreen()			;

JSL $01A7DC|!BankB		;interaction - check

LDA !ThwompStates,x			;
JSL $0086DF|!BankB		;pointers...

dw .CalmState
dw .FallState
dw .RiseState

;BEQ .CalmState			; but we can do better!
;DEC					; daizo edit: are you sure about that?
;BEQ .FallState			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;State 3 - Rising
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.RiseState


LDA !ThwompTimer,x			;If it's not time to rise yet
BNE .Re3				;welp
STZ !ThwompFace,x			;reset face

LDA !LockedHei_Hi,x : STA $01
LDA !LockedHeight,x : STA $00

LDA !14D4,x : XBA : LDA !D8,x
REP #$20 : CMP $00 : SEP #$20
BCS .KeepGoin		;keep raising, untill it reaches it's original position

STA !D8,x : XBA : STA !14D4,x ; store og pos

STZ !ThwompStates,x
RTS

.KeepGoin
LDA #$01			;
STA !ThwompFace,x

	; y check
	lda !7FAB10,x
	AND #$04
	LSR #2
	TAY

LDA RISE_SPEED,y			;Keep raising
STA !AA,x			;
JSL $01801A|!BankB		;update speed
.Re3
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;State 1 - Calm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.CalmState

;LDA !SpriteVOffScreenFlag,x			;this is what makes it fall instantly when offscreen vertically
;BNE .EEE			;because 01AEEE

;LDA !SpriteHOffScreenFlag,x			;don't do a thing when horizontally offscreen
;BNE .Re				;

%SubHorzPos()			;
;TYA				;
;STA !157C,x			;157C isn't used anywhere?

;STZ !ThwompFace,x			;calm down the face

	; old check
;LDA $0E				;if not close enough
;CLC : ADC #$40			;
;CMP #$80			;
;BCS .SkipFace			;don't change face expression

;LDA #$01			;
STZ !ThwompFace,x			; always have this face (lol)

;.SkipFace
;LDA $0E				;if even more close
;CLC : ADC #$24			;
;CMP #$50			;
;BCS .Re				;

; move check
LDA !MoveCheck,x
TAY
%BEC(+)
INY : INY ; increase by 2 if extra bit set
+
LDA XSpeed,y
STA !B6,x
JSL $018022|!BankB

; colision check
JSL $019138|!BankB		;interact with objects
LDA !1588,x				;
AND #$03				;
BEQ .Re					;if it's not walls, return

LDA !MoveCheck,x
EOR #$01
STA !MoveCheck,x

;.EEE
LDA #$02			;
STA !ThwompFace,x			;it'll be angry, and...
INC !ThwompStates,x			;...it's gonna crash! AAA!

;LDA #$00			;are you serious?
;STA !AA,x			;nah, you're not

STZ !AA,x			;just like me

.Re
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;State 2 - Falling
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

.FallState
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
STA !ThwompTimer,x			;how long it stays on floor

INC !ThwompStates,x			;to the next state!

.Re2
RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Graphics
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GFX:

; color check
LDA #!PROP_CLEAR : STA $0C
%BEC(+)
LDA #!PROP_SET : STA $0C
+

%GetDrawInfo()			;

LDA !ThwompFace,x			;thwomp's expression to 02
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
ORA $0C
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