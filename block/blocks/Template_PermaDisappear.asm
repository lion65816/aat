;Act as $025.
;This is a test block (or simply a template) for creating non-respawning blocks.
;
db $42 ; or db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
BodyInside:
HeadInside:

;WallFeet:	; when using db $37
;WallBody:
	PHY				;>Prevent overwriting the block behavior high byte stored in Y.
	REP #$20
	LDA $9A				;\BlockXPos = floor(PixelXPos/16)
	LSR #4				;|
	STA $00				;/
	LDA $98				;\BlockYPos = floor(PixelYPos/16)
	LSR #4				;|
	STA $02				;/
	SEP #$20
	%BlkCoords2C800Index()
	%SearchBlockFlagIndex()
	REP #$20			;\If flag number associated with this block location not found, return.
	CMP #$FFFE			;|
	BEQ Done			;/
	LSR				;>Convert to index number from Index*2.
	SEP #$20
	CLC
	%WriteBlockFlagIndex()
	
	%erase_block()
	%create_smoke()
	
	Done:
	SEP #$30			;>Just in case.
	PLY				;>Restore block behavior
	RTL
SpriteV:
SpriteH:
MarioCape:
MarioFireball:
RTL

print "A block that permanently disappear when touched by the player."