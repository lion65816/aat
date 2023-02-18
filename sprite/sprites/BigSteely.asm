;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Bowser Bowling Ball (sprite A1), by imamelia
;;
;; This is a disassembly of sprite A1 in SMW, Bowser's bowling ball.
;;
;; Uses first extra bit: YES
;;
;; If the extra bit is set, the sprite will detect ground.  If not, it will act like the
;; original and travel along hardcoded paths.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;(Small edit by Rykon-V73)Edit the X, Y speeds, palette, sound effects, ground-shaking timer and tilemap below. You should leave the Y speeds like it is.
!RBBBSXS		= $0D	;right x speed of the Bowser Bowling Ball/Big Steely
!LBBBSXS		= $F3	;left x speed of the Bowser Bowling Ball/Big Steely
;;The y speeds are risky. You can edit them, but you might not get the wanted result:
!BBBSYS1		= $00
!BBBSYS2		= $FE
!BBBSYS3		= $FC
!BBBSYS4		= $F8
!BBBSYS5		= $EC
!BBBSYS6		= $E8
!BBBSYS7		= $E4
!BBBSYS8		= $E0
!BBBSYS9		= $DC
!BBBSYS10		= $D8
!BBBSYS11		= $D4
!BBBSYS12		= $D0
!BBBSYS13		= $CC
!BBBSYS14		= $C8
;;The palettes should be easy to edit. Edit only the 2nd value, as that controls palette and GFX page.(0D-palette E, GFX page 2; 0E-palette F, GFX page 1; etc.)
!PalEdit1			= $0D
!PalEdit2			= $4D
!PalEdit3			= $8D
!PalEdit4			= $CD
;;The sound effects and it's bank is simple to edit:
!BSHI			= $25	;this is the sound effect used by the chuck when it runs, but the SFX is a bit loud.
!BSHISB			= $1DFC	;the sound bank
!BSLI			= $01	;this is the sound effect used by the chuck when it runs.
!BSLISB			= $1DF9	;the sound bank
;The shaking timer is one value. Edit it below:
!SG			= $10	;timer used to shake the ground.
;;The tilemap should be easy to edit as well:
!BSULT			= $A8	;tile of the upper-left part of Big Steely. It's used 4 times.
!BSUMT			= $AA	;tile of the upper-middle part of Big Steely. It's used twice.
!BSMLT			= $C6	;tile of the middle-left part of Big Steely. It's also used for the middle-right part.
!BSTF			= $E6	;tile of the center part of Big Steely. I also consider this a 'tile filler'.
!BSSA			= $8C	;Big Steely's shining area.
!BSSDA			= $BC	;the small dot animation of Big Steely. It spins around and its an 8x8 tile.
!BSBDA			= $AC	;the big dot animation of Big Steely. It spins around and its an 8x8 tile.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ExtraBit = $04

BowserBallXSpeed:
db !RBBBSXS,!LBBBSXS

BowserBallYSpeed:
db !BBBSYS1,!BBBSYS1,!BBBSYS1,!BBBSYS1,!BBBSYS2,!BBBSYS3,!BBBSYS4,!BBBSYS5
db !BBBSYS5,!BBBSYS5,!BBBSYS6,!BBBSYS7,!BBBSYS8,!BBBSYS9,!BBBSYS10,!BBBSYS11
db !BBBSYS12,!BBBSYS13,!BBBSYS14

BowserBallDispX:
db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$00,$00,$F8

BowserBallDispY:
db $E2,$E2,$E2,$F2,$F2,$F2,$02,$02,$02,$02,$02,$EA

BowserBallTilemap:
db !BSULT,!BSUMT,!BSULT,!BSMLT,!BSTF,!BSMLT,!BSULT,!BSUMT,!BSULT,!BSSDA,!BSBDA,!BSSA

BowserBallTileProp:
db !PalEdit1,!PalEdit1,!PalEdit2,!PalEdit1,!PalEdit1,!PalEdit2,!PalEdit3,!PalEdit3,!PalEdit4,!PalEdit1,!PalEdit1,!PalEdit1

BowserBallTileSize:
db $02,$02,$02,$02,$02,$02,$02,$02,$02,$00,$00,$02

BowserBallDispX2:
db $04,$0D,$10,$0D,$04,$FB,$F8,$FB

BowserBallDispY2:
db $00,$FD,$F4,$EB,$E8,$EB,$F4,$FD

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
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
JSR BowserBallMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BowserBallMain:

JSR BowserBallGFX	;

LDA $9D		; if sprites are locked...
BNE Return0	; return

LDA #$00
%SubOffScreen()
JSL $01A7DC	;
JSL $018022	;
JSL $01801A	;

LDA !AA,x	; if the sprite's Y speed
CMP #$40		; has not reached 40...
BPL MaxSpeed	;
CLC		;
ADC #$03	; make the sprite accelerate
BRA StoreSpeed	;

MaxSpeed:	;

LDA #$40		;

StoreSpeed:	;

STA !AA,x	;

LDA !AA,x	; if the sprite speed is negative...
BMI SkipSpeedSet	;
LDA !14D4,x	; or its Y position high byte is negative...
BMI SkipSpeedSet	; branch

LDA !7FAB10,x	;
AND #!ExtraBit	; if the extra bit is set...
BNE DetectGround	; make the sprite detect ground like a normal sprite

LDA !D8,x	; if not...
CMP #$B0		; check the sprite's Y position
BCC SkipSpeedSet	; don't set its X speed if the sprite Y position is less than B0
LDA #$B0		; if it is B0 or greater...
STA !D8,x	; make it stay at B0

Continue:		;

LDA !AA,x	; if the sprite Y speed
CMP #$3E		; is less than 3E...
BCC NoShake	; don't shake the ground

LDY #!BSHI		;
STY !BSHISB|!Base2	; play a sound effect
LDY #!SG		;
STY $1887|!Base2	; shake the ground

NoShake:		;

CMP #$08		; if the sprite's Y speed is less than 08...
BCC NoSound2	; don't play the second sound effect

LDA #!BSLI		;
STA !BSLISB|!Base2	;

NoSound2:	;

JSR HandleYSpeed	;

LDA !B6,x	; if the sprite's X speed is nonzero...
BNE SkipSpeedSet	; there is no need to set it again

%SubHorzPos()		;
LDA BowserBallXSpeed,y	;
STA !B6,x

SkipSpeedSet:

LDA !B6,x	;
BEQ Return0	; return if the sprite's X speed is zero
BMI IncFrame	; increment the frame if the sprite's X speed is negative
DEC !1570,x	; decrement the frame if the sprite's X speed is positive
DEC !1570,x	;
IncFrame:		;
INC !1570,x	;

Return0:		;
RTS

DetectGround:	;

JSL $019138	; interact with objects

LDA !1588,x	;
AND #$04	;
BEQ SkipSpeedSet	;
BRA Continue	;

HandleYSpeed:	;

LDA !AA,x		;
STZ !AA,x		;
LSR			;
LSR			;
TAY			;
LDA BowserBallYSpeed,y	;
LDY !1588,x		;
BMI Return1		;
STA !AA,x		;

Return1:			;
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BowserBallGFX:

%GetDrawInfo()		;

;LDA #$70			;
;STA $15EA,x		;

PHX			;
LDX #$0B			; 12 tiles to draw

GFXLoop:			;

LDA $00			;
CLC			;
ADC BowserBallDispX,x	;
STA $0300|!Base2,y		;

LDA $01			;
CLC			;
ADC BowserBallDispY,x	;
STA $0301|!Base2,y		;

LDA BowserBallTilemap,x	;
STA $0302|!Base2,y		;

LDA BowserBallTileProp,x	;
ORA $64			;
STA $0303|!Base2,y		;

PHY			;
TYA			;
LSR #2			;
TAY			;
LDA BowserBallTileSize,x	;
STA $0460|!Base2,y		;
PLY			;

INY #4			;
DEX			;
BPL GFXLoop		;

PLX			;
PHX			;
LDY !15EA,x		;
LDA !1570,x		;
LSR #3			;
AND #$07		;
PHA			;
TAX			;

LDA $0304|!Base2,y		;
CLC			;
ADC BowserBallDispX2,x	;
STA $0304|!Base2,y		;

LDA $0305|!Base2,y		;
CLC			;
ADC BowserBallDispY2,x	;
STA $0305|!Base2,y		;

PLA			;
CLC			;
ADC #$02		;
AND #$07		;
TAX			;

LDA $0308|!Base2,y		;
CLC			;
ADC BowserBallDispX2,x	;
STA $0308|!Base2,y		;

LDA $0309|!Base2,y		;
CLC			;
ADC BowserBallDispY2,x	;
STA $0309|!Base2,y		;

PLX			;
LDA #$0B			;
LDY #$FF			;
JSL $01B7B3		;

RTS


