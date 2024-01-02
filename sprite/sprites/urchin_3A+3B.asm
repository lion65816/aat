;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Urchins (sprites 3A & 3B), by imamelia
;;
;; This is a disassembly of sprites 3A and 3B in SMW, the non-wall-following Urchins.
;;
;; Uses first extra bit: YES
;;
;; If the extra bit is clear, this sprite will act like sprite 3A, which moves a fixed
;; horizontal/vertical distance.  If the extra bit is set, this sprite will act like sprite
;; 3B, which moves until it hits a surface.  Either way, it will move horizontally or
;; vertically depending on its X position.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XSpeed:
db $08,$00

YSpeed:
db $00,$08

XDisp:
db $08,$00,$10,$00,$10

YDisp:
db $08,$00,$00,$10,$10

TileProp:
db $37,$37,$77,$B7,$F7

Tilemap:
db $C4,$E6,$C8,$E6

Frame:
db $00,$01,$02,$01

!EyesTile1 = $E8
!EyesTile2 = $EA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
PHB
PHK
PLB
JSR UrchinInit
PLB
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
JSR UrchinMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UrchinInit:

LDA !E4,x			;
LDY #$00			;
AND #$10			;
STA !151C,x			;
BNE InitHorizontal	;
INY					;
InitHorizontal:		;
LDA XSpeed,y		;
STA !B6,x			;
LDA YSpeed,y		;
STA !AA,x			;
INC !164A,x			;
RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UrchinMain:

JSL $018032|!bank	; interact with sprites
JSL $01ACF9|!bank	; get a random number
ORA $9D				;
BNE NoSet1			; if sprites are locked or the number was not 0...
LDA #$0C			; don't set this timer
STA !1558,x			;
NoSet1:				;

JSR UrchinGFX		;

LDA !14C8,x			;
CMP #$08			; if the sprite status is normal...
BEQ ContinueMain	; continue
STZ !1528,x			;
LDA #$FF			;
STA !1558,x			;
RTS					;

ContinueMain:		;

LDA $9D				; return if sprites are locked
BNE Return00		;
LDA #$03
%SubOffScreen()
JSL $01A7DC|!bank	;

; removed sprite number checks ($2E, $3C, $A5, $A6)

LDA !C2,x			;
AND #$01			; only 2 pointers here
TXY
ASL
TAX
JMP (.pointers,x)

;JSL $0086DF|!bank	; jump to a pointer depending on bit 0 of the sprite state

.pointers
dw Stationary		;
dw Moving			;

Stationary:			;
TYX
LDA !1540,x			; if the state timer is set...
BNE Return00		; return
LDA #$80			; if it is not set...
STA !1540,x			; set it
INC !C2,x			; and increment the sprite state

Return00:			;
RTS					;

Moving:				;
TYX
LDA !7FAB10,x		;
AND #$04			; if the extra bit is set and the sprite acts like 3B...
BNE NoTurn			; don't turn when the sprite state timer runs out

LDA !1540,x			; if the extra bit is clear and the sprite acts like 3A...
BEQ ReverseSpeed	; change direction with the sprite state timer runs out

NoTurn:				;

JSL $018022|!bank	; update sprite X position
JSL $01801A|!bank	; update sprite Y position
JSL $019138|!bank	; interact with objects

LDA !1588,x			;
AND #$0F			; if the sprite is touching a wall...
BEQ Return00		;

ReverseSpeed:		;

LDA !B6,x			;
EOR #$FF			; flip the X speed
INC					;
STA !B6,x			;

LDA !AA,x			;
EOR #$FF			; flip the Y speed
INC					;
STA !AA,x			;

LDA #$40			;
STA !1540,x			; set the time until the sprite state changes
INC !C2,x			; increment the sprite state

RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UrchinGFX:

LDA !163E,x		;
BNE SkipReset1	;
INC !1528,x		; not sure what the purpose of these 5 lines is...
LDA #$0C		;
STA !163E,x		; change the frame shown every 0C frames?
SkipReset1:		;

LDA !1528,x		;
AND #$03		;
TAY				;
LDA Frame,y		;
STA !1602,x		;

%GetDrawInfo()

STZ $05				;
LDA !1602,x			;
STA $02				;
LDA !1558,x			;
STA $03				;

GFXLoop:			;

LDX $05				; tilemap index
LDA $00				;
CLC					;
ADC XDisp,x			;
STA $0300|!addr,y	;

LDA $01				;
CLC					;
ADC YDisp,x			;
STA $0301|!addr,y	;

LDA TileProp,x		;
STA $0303|!addr,y	;

CPX #$00			; if the tilemap index is 00...
BNE NotEyesYet		;
LDA #!EyesTile1		; then draw the eyes
LDX $03				;
BEQ StoreTile		;
LDA #!EyesTile2		;
BRA StoreTile		;

NotEyesYet:			;

LDX $02				;
LDA Tilemap,x		;
StoreTile:			;
STA $0302|!addr,y	;

INY #4				;
INC $05				;
LDA $05				;
CMP #$05			; if we've drawn 5 tiles...
BNE GFXLoop			; end the loop

LDX $15E9|!addr		; restore index
LDY #$02			;
LDA #$04			;
JSL $01B7B3|!bank	; finish OAM

RTS					;