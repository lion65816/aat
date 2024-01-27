;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Hammer Disassembly
;
; This is a disassembly of extended sprite 04 in SMW, Hammer.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc EasyPropDefines.txt

!HammerProp  = !PaletteA|!SP3SP4

HammerTiles:
	db $06,$26,$26,$06,$06,$26,$26,$06

;contains flip data
HammerGfxProp:
;horz flip
	db !HammerProp|!PropXFlip
	db !HammerProp|!PropXFlip

;no flip
	db !HammerProp
	db !HammerProp

;vert flip
	db !HammerProp|!PropYFlip
	db !HammerProp|!PropYFlip

;horz vert flip
	db !HammerProp|!PropXFlip|!PropYFlip
	db !HammerProp|!PropXFlip|!PropYFlip

;cape interaction
Print "CAPE",pc
    LDA #$04
    STA $00			;x-clipping offset
    STA $02			;y-clipping offset

    LDA #$08
    STA $01			;width
    STA $03			;height

    %ExtendedCapeClipping()
    BCC CAPE_RETURN		;no interaction? BEGONE

    LDA #$07			;puff of smoke timer
    STA $176F|!addr,X

    LDA #$01			;Change the sprite into a puff of smoke.
    STA $170B|!addr,x

CAPE_RETURN:
RTL

Print "MAIN ",pc
Hammer:
LDA $9D			;don't do things
BNE GFX			;

LDA #$01		;speed
%ExtendedSpeed()	;

LDA $173D|!Base2,x	;custom gravity
CMP #$40		;max downward speed
BPL .no			;
INC $173D|!Base2,x	;\decrease speed
INC $173D|!Base2,x	;/

.no
LDA #$04
STA $00			;x-clipping offset
STA $02			;y-clipping offset

LDA #$08
STA $01			;width
STA $03			;height
%ExtendedHurtCustom()	;hurt da player maybe

INC $1765|!Base2,x	;graphical frame counter

GFX:
;LDA $170B|!addr,x	;extended sprite check, the code is shared with piranha plant's fireball
;CMP #$0B
;BNE .HammerGFX

;JSR FireballGFX	;this is a hammer, not a fireball and not both
;RTS

.HammerGFX
%ExtendedGetDrawInfo()	;

LDA $01			;
STA $0200|!Base2,y	;

LDA $02			;
STA $0201|!Base2,y	;

LDA $1765|!Base2,x	;
LSR #3			;
AND #$07		;
;PHX			;tile
TAX			;
LDA HammerTiles,x	;
STA $0202|!Base2,y	;

LDA HammerGfxProp,x	;props
EOR $00			;
EOR #!PropXFlip		;>X flip... ok? couldn't edit table entries to take this into account, now could you
ORA $64			;
STA $0203|!Base2,y	;

TYA			;
LSR #2			;
TAX			;
LDA #$02		;
STA $0420|!Base2,x	;tile size - checkmark
;PLX			;

LDX $15E9|!Base2	;restore extended sprite index
RTL			;