;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Ninji (sprite 51), by imamelia
;;
;; This is a disassembly of sprite 51 in SMW, the Ninji.
;;
;; Uses first extra bit: NO
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

YSpeed:
db $D0,$C0,$B0,$D0

Tilemap:
db $CA,$CC

!CeilingFix = 1		;Previously you had to uncomment some code, now you can just change this option to fix ninjis, so they won't go throught ceiling.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

%SubHorzPos()	;
TYA			; face the player
STA !157C,x	;

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
JSR NinjiMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NinjiMain:

JSR NinjiGFX			; draw the sprite

LDA $9D				; if sprites are locked...
BNE .Return			; return

%SubHorzPos()			;
TYA				; always face the player
STA !157C,x			;

LDA #$00			; offscreen processing
%SubOffScreen()
JSL $01803A|!BankB		; interact with the player and with other sprites
JSL $01802A|!BankB		; update sprite position with gravity

If !CeilingFix == 1 
LDA !1588,x			;
AND #$08			; these 5 lines of code were not in the original sprite
BEQ .NoTouchCeiling		; this prevents the Ninji from jumping through the ceiling
STZ !AA,x			;
endif
.NoTouchCeiling			;

LDA !1588,x			;
AND #$04			; if the sprite is not on the ground...
BEQ .SetFrame			; don't set its Y speed

STZ !AA,x			; initialize the Y speed to 0
LDA !1540,x			; if the sprite has just jumped and isn't ready to jump again...
BNE .SetFrame			; don't set its Y speed
LDA #$60			;
STA !1540,x			; if it is ready to jump, set the timer between jumps
INC !C2,x			; increment the sprite state
LDA !C2,x			;
AND #$03			; only the lowest 2 bits of the sprite state matter
TAY				; these will be used to index the Y speed table
LDA.w YSpeed,y			; and the four possible Y speeds will cycle
STA !AA,x			;

.SetFrame			;

LDA #$00			;
LDY !AA,x			; if the sprite is moving upward, use the first frame;
BMI $01				; if the sprite is moving downward or is stationary,
INC				; use the second frame
STA !1602,x			;

.Return				;
RTS				;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

NinjiGFX:

%GetDrawInfo()			;

;LDA $157C,x			;
;STA $02			; utterly pointless, since $02 is never even used

LDA !1602,x			;
TAX				;
LDA Tilemap,x			; set the sprite tilemap
STA $0302|!Base2,y			;

LDX $15E9|!Base2			;
LDA $00				;
STA $0300|!Base2,y		; no X displacement
LDA $01				;
STA $0301|!Base2,y		; no Y displacement

LDA !157C,x			;
LSR				; if the sprite is facing right...
LDA !15F6,x			;
BCS .NoXFlip			; X-flip it
EOR #$40			;
.NoXFlip			;
ORA $64				;
STA $0303|!Base2,y		;

TYA				;
LSR #2				;
TAY				;

LDA #$02			;
ORA !15A0,x			;
STA $0460|!Base2,y		; set the tile size

PHK				;
PEA.w .EndGFX-$01		;
PEA $8020			;
JML $01A3DF|!BankB		; set up some stuff in OAM
.EndGFX				;

RTS
