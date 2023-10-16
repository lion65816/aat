;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Big Boo (sprite 28), by imamelia
;;
;; This is a disassembly of sprite 28 in SMW, the Big Boo.
;;
;; Uses first extra bit: YES
;;
;; If the first extra bit is set, the sprite will either chase you when you're facing it (Anti Boo),
;; or keep following you even when you look away.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!AntiOrAlwaysChase = 1		;0 = Anti Boo if extra bit set. 1 = Always chase if extra bit is set.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SpeedMax:
db $08,$F8

IncTable:
db $01,$FF

Frame:
db $01,$02,$02,$01

XDisp:
db $08,$08,$20,$00,$00,$00,$00,$10
db $10,$10,$10,$20,$20,$20,$20,$30
db $30,$30,$30,$FD,$0C,$0C,$27,$00
db $00,$00,$00,$10,$10,$10,$10,$1F
db $20,$20,$1F,$2E,$2E,$2C,$2C,$FB
db $12,$12,$30,$00,$00,$00,$00,$10
db $10,$10,$10,$1F,$20,$20,$1F,$2E
db $2E,$2E,$2E,$F8,$11,$FF,$08,$08
db $00,$00,$00,$00,$10,$10,$10,$10
db $20,$20,$20,$20,$30,$30,$30,$30

YDisp:
db $12,$22,$18,$00,$10,$20,$30,$00
db $10,$20,$30,$00,$10,$20,$30,$00
db $10,$20,$30,$18,$16,$16,$12,$22
db $00,$10,$20,$30,$00,$10,$20,$30
db $00,$10,$20,$30,$00,$10,$20,$30

Tilemap:
db $EA,$EA,$E8,$80,$A0,$C0,$E0,$82,$A2,$C2,$E2,$84,$A4,$C4,$E4,$86	;\
db $A6,$C6,$E6,$E8,$EA,$EA,$E8,$80,$A0,$C0,$E0,$82,$A2,$C2,$E2,$84	;| Bee Boo (Level 3E)
db $A4,$C4,$E4,$86,$A6,$C6,$E6,$E8,$EA,$EA,$E8,$80,$A0,$C0,$E0,$82	;|
db $A2,$C2,$E2,$84,$A4,$C4,$E4,$86,$A6,$C6,$E6,$E8,$E8,$E8,$A1,$C1	;|
db $80,$A0,$C0,$E0,$82,$A2,$C2,$E2,$84,$A4,$C4,$E4,$86,$A6,$C6,$E6	;/
;db $C0,$E0,$E8,$80,$A0,$A0,$80,$82
;db $A2,$A2,$82,$84,$A4,$C4,$E4,$86
;db $A6,$C6,$E6,$E8,$C0,$E0,$E8,$80
;db $A0,$A0,$80,$82,$A2,$A2,$82,$84
;db $A4,$C4,$E4,$86,$A6,$C6,$E6,$E8
;db $C0,$E0,$E8,$80,$A0,$A0,$80,$82
;db $A2,$A2,$82,$84,$A4,$A4,$84,$86
;db $A6,$A6,$86,$E8,$E8,$E8,$C2,$E2
;db $80,$A0,$A0,$80,$82,$A2,$A2,$82
;db $84,$A4,$C4,$E4,$86,$A6,$C6,$E6

TileProp:
db $00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;\
db $00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00,$00,$00,$00,$00	;| Bee Boo (Level 3E)
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00,$00,$00,$00	;|
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$40,$00,$00	;|
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	;/
;db $00,$00,$40,$00,$00,$80,$80,$00
;db $00,$80,$80,$00,$00,$00,$00,$00
;db $00,$00,$00,$00,$00,$00,$40,$00
;db $00,$80,$80,$00,$00,$80,$80,$00
;db $00,$00,$00,$00,$00,$00,$00,$00
;db $00,$00,$40,$00,$00,$80,$80,$00
;db $00,$80,$80,$00,$00,$80,$80,$00
;db $00,$80,$80,$00,$00,$40,$00,$00
;db $00,$00,$80,$80,$00,$00,$80,$80
;db $00,$00,$00,$00,$00,$00,$00,$00


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
JSL $01ACF9|!BankB
STA !1570,x

if !AntiOrAlwaysChase == 0
	LDA !7FAB10,x		;load extra bits
	AND #$04		;check if first extra bit is set
	BEQ +			;if not set, Boo will chase normally.

	LDA #$01		;load value for EOR chase table value
	STA !1534,x		;store to sprite RAM.
	RTL

+
endif
	STZ !1534,x		;clear sprite RAM used for EOR chase table value.
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR BigBooMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BigBooMain:
LDA #$01
%SubOffScreen()

LDA #$20		;
STA $18B6|!Base2	; unknown RAM address?

LDA !14C8,x	;
CMP #$08		; if the sprite is not in normal status...
BNE SkipToGFX	;
LDA $9D		; or sprites are locked...
BEQ ContinueMain	; skip most of the main routine and just run the GFX routine
SkipToGFX:	;
JMP InteractGFX	;

ContinueMain:	;

%SubHorzPos()	;

LDA !1540,x	; if the timer is set...
BNE NoChangeState	;

LDA #$20			;
STA !1540,x		;
LDA !C2,x		; if the sprite state is zero...
BEQ NoCheckProximity	;
LDA $0E			;
CLC			;
ADC #$0A		;
CMP #$14		;
BCC Skip1		; skip the next part of code if the Boo is within a certain distance
NoCheckProximity:	;

if !AntiOrAlwaysChase != 0
LDA !7FAB10,x		;
AND #$04		; if the extra bit is set...
BNE NoChangeState	; make the Boo always follow the player
endif

STZ !C2,x		;
CPY $76			; if the Boo is facing the player...
BNE NoChangeState	; don't make it follow him/her
INC !C2,x		;

NoChangeState:		;
LDA $0E			;
CLC			;
ADC #$0A		;
CMP #$14			;
BCC Skip1		;

LDA !15AC,x		; if the sprite is turning...
BNE Skip2			; skip the check and set
TYA			;
CMP !157C,x		;
BEQ Skip1			;
LDA #$1F			;
STA !15AC,x		; set the turn timer
BRA Skip2			;

Skip1:

STZ !1602,x		;
LDA !C2,x		;
EOR !1534,x	;flip bit 0 if value is set
BEQ Skip3			;
LDA #$03			;
STA !1602,x		;
AND $13			;
BNE Skip4			;
INC !1570,x		;
LDA !1570,x		;
BNE NoSetTimer2		;
LDA #$20			;
STA !1558,x		;
NoSetTimer2:		;
LDA !B6,x		; increment or decrement the sprite X speed
BEQ XSpdZero		; depending on whether it is positive, negative, or zero
BPL XSpdPlus		;
INC			;
INC			;
XSpdPlus:			;
DEC			;
XSpdZero:			;
STA !B6,x			;
LDA !AA,x		; same for the Y speed
BEQ YSpdZero		;
BPL YSpdPlus		;
INC			;
INC			;
YSpdPlus:			;
DEC			;
YSpdZero:			;
STA !AA,x		;

Skip4:
JMP UpdatePosition

Skip2:

CMP #$10		;
BNE NoFlipDir	;
PHA		;
LDA !157C,x	;
EOR #$01		; flip sprite direction
STA !157C,x	;
PLA		;
NoFlipDir:	;
LSR #3		;
TAY		;
LDA Frame,y	;
STA !1602,x	;

Skip3:

STZ !1570,x	;
LDA $13		;
AND #$07	; skip this every 8 frames
BNE UpdatePosition	;

%SubHorzPos()	;

LDA !B6,x	;
CMP SpeedMax,y	;
BEQ NoIncXSpeed	;
CLC		;
ADC IncTable,y	;
STA !B6,x		;
NoIncXSpeed:	;

LDA $D3		;
PHA		;
SEC		;
SBC $18B6|!Base2	;
STA $D3		;
LDA $D4		;
PHA		;
SBC #$00		;
STA $D4		;

JSR SubVertPos2	;

PLA		;
STA $D4		;
PLA		;
STA $D3		;

LDA !AA,x	;
CMP SpeedMax,y	;
BEQ UpdatePosition	;
CLC		;
ADC IncTable,y	;
STA !AA,x	;

UpdatePosition:

JSL $018022	;
JSL $01801A	;

InteractGFX:	;

LDA !14C8,x	;
CMP #$08		; if the sprite is not in normal status...
BNE NoInteraction	; don't interact with the player

JSL $01A7DC	;

NoInteraction:	;

JSR BigBooGFX	;

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BigBooGFX:

%GetDrawInfo()

LDA !1602,x	;
STA $06		;
ASL #2		;
STA $03		;
ASL #2		;
ADC $03		;
STA $02		;
LDA !157C,x	;
STA $04		;
LDA !15F6,x	;
STA $05		;
LDX #$00		;

GFXLoop:		;

PHX		;
LDX $02		;
LDA Tilemap,x	;
STA $0302|!Base2,y	;

LDA $04		;
LSR		;
LDA TileProp,x	;
ORA $05		;
BCS NoFlipTile	;
EOR #$40		;
NoFlipTile:	;
ORA $64		;
STA $0303|!Base2,y	;

LDA XDisp,x	;
BCS NoFlipXDisp	;
EOR #$FF		;
INC		;
CLC		;
ADC #$28	;
NoFlipXDisp:	;
CLC		;
ADC $00		;
STA $0300|!Base2,y	;

PLX		;
PHX		;
LDA $06		;
CMP #$03		;
BCC NoAdd14	;
TXA		;
CLC		;
ADC #$14	;
TAX		;
NoAdd14:		;

LDA $01		;
CLC		;
ADC YDisp,x	;
STA $0301|!Base2,y	;

PLX		;
INY #4		;
INC $02		;
INX		;
CPX #$14		;
BNE GFXLoop	;

LDX $15E9|!Base2	;
LDA !1602,x	;
CMP #$03		;
BNE NoShift	;
LDA !1558,x	;
BEQ NoShift	;
LDY !15EA,x	;
LDA $0301|!Base2,y	;
CLC		;
ADC #$05	;
STA $0301|!Base2,y	;
STA $0305|!Base2,y	;
NoShift:		;
LDA #$13		;
LDY #$02		;
JSL $01B7B3	;
RTS		;

SubVertPos2:

LDY #$00
LDA $D3
SEC
SBC !D8,x
STA $0E
LDA $D4
SBC !14D4,x
BPL $01
INY
RTS











