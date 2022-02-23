;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Horizontal proximity subroutine
;calculates distance between mario and sprite and compares with set proximity range.
;
;Input:
;$00 - Proximity Range, low byte
;$01 - Proximity Range, high byte
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LDA !sprite_x_high,x
XBA
LDA !sprite_x_low,x
REP #$20
SEC
SBC $94
BPL +
EOR #$FFFF
INC

+
CMP $00             
SEP #$20
RTL