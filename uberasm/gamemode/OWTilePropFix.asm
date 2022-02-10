;Overworld Level Tile Properties Fix - by Blind Devil (last revision: 2017-03-21)
;This ASM file is meant to be placed in Gamemode E, in case your teleporting code is configured
;to activate an event, beat the level and teleport to other place in the OW (actions 5 or 6).
;It preserves the actual level destination flags and its usage is recommended, unless you want
;your level destination to enable moving and have its 'level has been passed' flag checked after
;the event is run.

;above description applies to uberASM Cutscene Mode code, but this should be used whenever you
;beat a level then OW warp, which's the case of the warping Goal Sphere.

;~FREE RAM~
;Well you will need something to be used temporarily as free RAM.
;It'll be used to preserve the OW level setting flags of the level destination.
!FreeRAM = $13F2

init:
LDA $0DD4|!addr		;load our flag from cutscene OW teleporting
BEQ .return		;if equal zero, return.

JSL main_IAmASubroutine	;get current translevel number in OW

LDX $02			;Load level currently stepped on on X
LDA $1EA2|!addr,x	;Load flags value
STA !FreeRAM|!addr	;Store to our RAM.

.return
RTL			;Return.

main:
LDA $13D9|!addr		;Load pointer to processes on OW.
CMP #$02		;Compare.
BNE .return		;If value is lower, return.
LDA $1DEB|!addr		;Load current event tile being loaded
CMP $1DED|!addr		;Compare with last event tile to load
BNE .return		;If not equal, return.

LDA $0DD4|!addr		;Load our flag from cutscene OW teleporting
BEQ .return		;If not set, do nothing.

JSL .IAmASubroutine

LDX $02			;Load level currently stepped on on X
LDA !FreeRAM|!addr	;Load free RAM, now containing properties of the destination level
STA $1EA2|!addr,x	;Store to respective byte from OW level setting flags.

LDA #$05
STA $13D9|!addr
STZ $0DD4|!addr		;Flag has served its purpose and now can be reset.
STZ !FreeRAM|!addr	;The configured free RAM is also cleared.

.return
RTL

.IAmASubroutine
LDY $0DD6|!addr		;Code portion by Ladida.
LDA $1F17|!addr,y	;Calculates coordinates to search OW translevel in the ROM table
LSR #4 : STA $00	;and stores in scratch RAM.
LDA $1F19|!addr,y
AND #$F0
ORA $00 : STA $00
LDA $1F1A|!addr,y
ASL : ORA $1F18|!addr,y
LDY $0DB3|!addr
LDX $1F11|!addr,y
BEQ +
CLC : ADC #$04
+
STA $01
REP #$10		;Now get the coordinates to find the right spot,
LDX $00			;find translevel and store to scratch RAM.
if !sa1
	LDA $40D000,x	;Load OW translevel number table (SA-1)
else
	LDA $7ED000,x	;Load OW translevel number table (normal)
endif
STA $02
SEP #$10
RTL