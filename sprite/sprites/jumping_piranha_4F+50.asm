;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Jumping Piranha Plants (sprites 4F & 50), by imamelia
;;
;; This is a disassembly of sprites 4F and 50 in SMW, the Jumping Piranha Plants.
;;
;; Uses first extra bit: YES
;;
;; If the extra bit is clear, the sprite will act like sprite 4F.  If the extra bit is set, it
;; will act like sprite 50, meaning that it will spit fireballs when it jumps.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisp:
db $00,$08,$00,$08

YDisp:
db $00,$00,$08,$08

XFlip:
db $00,$40,$00,$40

Tilemap:		; the sprite tilemap (the two $CEs are unused for this sprite)
db $AC,$CE,$AE,$CE,$4A,$4A,$C4,$C4,$4A,$4A,$C5,$C5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc

LDA !E4,x	;
CLC		;
ADC #$08	; shift the sprite's X position to the right 8 pixels
STA !E4,x		;
DEC !D8,x	; shift the sprite down 1 pixels
LDA !D8,x	;
CMP #$FF		; if there was overflow...
BNE EndInit	;
DEC !14D4,x	; decrement the high byte as well
EndInit:		;

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
JSR JumpingPiranhaMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JumpingPiranhaMain:

;JSL $07F78B	; load sprite tables? I don't know what the purpose of this is...
;JSL $0187A7	; I'd have to include this, too, since this is now a custom sprite.

LDA #$08		;
STA !15F6,x	; Oh, I see now.

LDA $64		;
PHA		; preserve the level's sprite priority
LDA #$20		;
STA $64		; so that it can be set to 10 temporarily

LDA !1570,x	; animation frame counter
AND #$08	;
LSR #2		;
EOR #$02		; make the sprite flip between 2 frames
STA !1602,x	;

JSR JumpingPiranhaGFX1	; draw the head

LDA !15EA,x		;
CLC			;
ADC #$04		; increment the sprite OAM index by 4
STA !15EA,x		;

LDA !151C,x		;
AND #$04		;
LSR #2			;
INC			;
STA !1602,x		; set the frame number for the leaves at the bottom of the plant

LDA !D8,x		;
PHA			; preserve the sprite Y position
CLC			;
ADC #$08		; so we can shift it down 8 pixels
STA !D8,x		;
LDA !14D4,x		;
PHA			;
ADC #$00		;
STA !14D4,x		;

LDA #$0A			;
STA !15F6,x		; set the sprite palette to green

JSR JumpingPiranhaGFX2	; draw the leaves

PLA			;
STA !14D4,x		;
PLA			;
STA !D8,x		;
PLA			;
STA $64			;

LDA $9D			;
BNE Return00		; return if sprites are locked

LDA #$00
%SubOffScreen()		;
JSL $01803A|!BankB		; interact with the player and with other sprites
JSL $01801A|!BankB		; update sprite Y position without gravity

LDA !C2,x		; sprite state
JSL $0086DF|!BankB	; execute 16-bit pointer subroutine

dw State00		;
dw State01		;
dw State02		;

Return00:			;
RTS			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; code for sprite state 00
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State00:

STZ !AA,x	; set the sprite Y speed to 0
LDA !1540,x	;
BNE Return01	;

%SubHorzPos()	;

LDA $0E		; horizontal distance between the sprite and the player
CLC		;
ADC #$1B		;
CMP #$37		; if the player is close enough...
BCC Return01	;

LDA #$C0		; set the sprite's jumping Y speed
STA !AA,x	;
INC !C2,x	; increment the sprite state
STZ !1602,x	; and set the frame to 0

Return01:		;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; code for sprite state 01
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State01:

LDA !AA,x	; if the sprite's Y speed is negative...
BMI Accelerate	;
CMP #$40		; or it is positive and less than 40...
BCS NoAccelerate	;
Accelerate:	;
CLC		;
ADC #$02	; add 2 to it to make the sprite accelerate
STA !AA,x	;

NoAccelerate:	;

INC !1570,x	; increment the animation frame counter
LDA !AA,x	; if the sprite's Y speed
CMP #$F0		; is between F1 and FF...
BMI Return02	;
LDA #$50		;
STA !1540,x	; set the timer
INC !C2,x	; and increment the sprite state

RTS		;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; code for sprite state 02
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

State02:

INC !151C,x	; increment the secondary animation frame counter
LDA !1540,x	; if the timer is set, then skip the next part of code
BNE MaybeSpitFire	; and go to the part where it checks to see whether or not the sprite should spit fireballs

NoFire:		;

INC !1570,x	;

LDA $14		;
AND #$03	; once every 4 frames...
BNE NoAccelerate2	;
LDA !AA,x	;
CMP #$08		; if the sprite Y speed is greater than 08...
BPL NoAccelerate2	;
INC		;
STA !AA,x	; increment the sprite Y speed

NoAccelerate2:	;

JSL $019138|!BankB	; interact with objects

LDA !1588,x	;
AND #$04	; if the sprite is on the ground...
BEQ Return02	;
STZ !C2,x	; reset the sprite state to 0
LDA #$40		;
STA !1540,x	; and set the time before it checks the player's proximity again

Return02:		;
RTS

MaybeSpitFire:

LDA !7FAB10,x	;
AND #$04	; if the extra bit is not set...
BEQ NoFire	; don't spit fireballs

STZ !1570,x	; reset the animation frame counter

LDA !1540,x	; I had to reload this because of the extra bit check.
CMP #$40		; if the timer isn't at exactly 40...
BNE NoFire	;
LDA !15A0,x	; or the sprite is offscreen horizontally or vertically...
ORA !186C,x	;
BNE NoFire	; don't spit fireballs

LDA #$10		; X speed for the first fireball
JSR SpitFireballs	;
LDA #$F0		; X speed for the second fireball

SpitFireballs:	; It's kind of interesting how they did this, really.

STA $00		; save the X speed value

LDY #$07		; 8 extended sprite indexes to loop through

ExSpriteLoop:	;

LDA $170B|!Base2,y	; check this slot
BEQ SpawnFire	; if the slot is free, we can use it for a fireball
DEY		; if not, decrement the index
BPL ExSpriteLoop	; and try again

RTS		;

SpawnFire:	;

LDA #$0B		; extended sprite number = 0B
STA $170B|!Base2,y	; piranha fireball

LDA !E4,x	; sprite X position
CLC		;
ADC #$04	; the fireball spawns 4 pixels to the right of the plant
STA $171F|!Base2,y	;
LDA !14E0,x	;
ADC #$00	; prevent overflow
STA $1733|!Base2,y	;

LDA !D8,x	;
STA $1715|!Base2,y	; same Y position as the plant
LDA !14D4,x	;
STA $1729|!Base2,y	;

LDA #$D0	; extended sprite Y speed = D0
STA $173D|!Base2,y	;
LDA $00		; $00 had the X speed value from before
STA $1747|!Base2,y	;

JMP NoFire	; finish up with the regular code
;Do note that I (RussianMan) had to change BRA to JMP, because it gives error when inserting in SA-1 rom.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

JumpingPiranhaGFX1:	; ripped from $0190B2

%GetDrawInfo()		;

LDA !157C,x		;
STA $02			;

LDA !1602,x		;
TAX			;
LDA Tilemap,x		; set the sprite tilemap
STA $0302|!Base2,y		;

LDX $15E9|!Base2	;
LDA $00		;
STA $0300|!Base2,y	; no X displacement
LDA $01		;
STA $0301|!Base2,y	; no Y displacement

LDA !157C,x	;
LSR		; if the sprite is facing right...
LDA !15F6,x	;
BCS NoXFlipTile	; X-flip the tile
EOR #$40		;
NoXFlipTile:	;
ORA $64		;
STA $0303|!Base2,y	;

TYA		;
LSR #2		;
TAY		;

LDA #$02		;
ORA !15A0,x	;
STA $0460|!Base2,y	; set the tile size

PHK		;
PER $0006	;
PEA $8020	;
JML $01A3DF|!BankB	; set up some stuff in OAM

RTS		;

JumpingPiranhaGFX2:	; ripped from $018042

STA $05			;

LDA !1504,x		;
STA $06			;

%GetDrawInfo()	;

LDA !1602,x	;
ASL #2		;
STA $02		;

LDA !15F6,x	;
ORA $64		;
STA $03		;

LDA #$03		;
STA $04		;

PHX		;

GFXLoop:		;

LDX $04		;

LDA $00		;
CLC		;
ADC XDisp,x	;
STA $0300|!Base2,y	;

LDA $01		;
CLC		;
ADC YDisp,x	;
STA $0301|!Base2,y	;

LDA $02		;
CLC		;
ADC $04		;
TAX		;

LDA Tilemap,x	;
STA $0302|!Base2,y	;

LDX $04		;

LDA XFlip,x	;
ORA $03		;
STA $0303|!Base2,y	;

INY #4		;
DEC $04		;
BPL GFXLoop	;

PLX		;
LDA #$03		;
LDY #$00		;
JSL $01B7B3|!BankB	;
RTS		;