;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Gray Moving Castle Block (sprite BB), by imamelia
;;
;; This is a disassembly of sprite BB in SMW, the moving castle block.
;;
;; Uses first extra bit: YES
;;
;; If the extra bit is clear, the sprite will move horizontally.  If the extra bit is set,
;; it will move vertically.  (Obviously, this was not a feature of the original; I added
;; it because it was easy to do and this was an easy sprite to disassemble anyway.)
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!ExtraBit = $04	; normally $04; may be set to $01 if using GEMS

Speed:
db $00,$F0,$00,$10
TimeInState:
db $40,$50,$40,$50
TileDispX:
db $00,$10,$00,$10
TileDispY:
db $00,$00,$10,$10
Tilemap:
db $2A,$2C,$4A,$4C

print "INIT ",pc
RTL

print "MAIN ",pc
PHB : PHK : PLB
JSR GrayBlockMain
PLB
RTL

GrayBlockMain:
JSR GrayBlockGFX	; draw the sprite
LDA $9D		; if sprites are locked...
BNE Return0	; return

LDA !1540,x
BNE NoStateChange	;

INC !C2,x	; increment the sprite state
LDA !C2,x	;
AND #$03	; 4 indexes
TAY		;
LDA TimeInState,y	;
STA !1540,x
BRA SkipRedundant	;

NoStateChange:	;
LDA !C2,x	;
AND #$03	; 4 indexes
TAY		;

SkipRedundant:
LDA Speed,y	;
TAY		; get the sprite speed into Y

LDA !7FAB10,x	;
AND #!ExtraBit	; if the extra bit is set...
BNE MoveVertically	; move vertically

STY !B6,x		; if we're moving horizontally, store the speed value to the X speed table
JSL $018022	; and update sprite X position without gravity
STA !1528,x	; prevent the player from sliding
BRA SolidBlock	;

MoveVertically:	;

STY !AA,x	; if we're moving vertically, store the speed value to the Y speed table
JSL $01801A	; and update sprite Y position without gravity

SolidBlock:	;

LDA !9E,x	; this code wasn't in the original sprite; I had to add it
PHA		; preserve the current sprite number
LDA #$BB		; temporarily set the sprite number to the same as the original
STA !9E,x		; (this is necessary to prevent the player glitching through the sides)
JSL $01B44F	; invisible solid block routine
PLA		;
STA !9E,x		; restore the sprite number

Return0:
RTS

GrayBlockGFX:
%GetDrawInfo()
LDX #$03		; 4 tiles to draw

GFXLoop:		;
LDA $00		;
CLC		;
ADC TileDispX,x	; set the tile X displacement
STA $0300|!Base2,y	;

LDA $01		;
CLC		;
ADC TileDispY,x	; set the tile Y displacement
STA $0301|!Base2,y	;

LDA Tilemap,x	; set the tile number
STA $0302|!Base2,y	;

LDA #$09	; second GFX page, palette C
ORA $64		; add in level priority bits
STA $0303|!Base2,y	; set the tile properties

INY #4		;
DEX		; decrement the tile index
BPL GFXLoop	; if positive, draw more tiles

LDX $15E9|!Base2
LDY #$02		; the tiles are 16x16
LDA #$03		; 4 tiles were drawn
JSL $01B7B3|!BankB	;
RTS