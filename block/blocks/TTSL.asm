;==================================================
;Teleport to Specified Level (TTSL) - Teo17
;It'll teleport you to specified level, be sure
;to read the readme as it has important properties.
;==================================================
;Make it act like tile 25!
;==================================================

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside


!Property	= !Door		;Input the property here. "!Door" is door, "!Block" is teleport block.
!Level		= $00FF		;The level to teleport to.
!Level2		= $00FE		;The level to teleport to.

!Secondary	= 1		; Secondary exit? 0 = false, 1 = true.
!Water		= 0		; If secondary exit, water level? 0 = false, 1 = true.


MarioBelow:
MarioAbove:
MarioSide:

TopCorner:
HeadInside:
BodyInside:

!Door = 1
!Block = 0

if !Property
	LDA $16		;Check if...
	AND #$08	;...Mario is...
	BEQ MarioFireball ;...pressing up.
	LDA #$2A	;Give the door...
	STA $1DFC|!addr	;...sound effect.
endif
	LDA $141A|!addr		;Load number of levels entered
	CMP #10
	BCS .GotTrophy		

	REP #$20
	LDA #!Level|(((!Water<<3)|(1<<2)|(!Secondary<<1))<<8)
	JMP .Tel
	
.GotTrophy
	REP #$20
	LDA #!Level2|(((!Water<<3)|(1<<2)|(!Secondary<<1))<<8)

	.Tel
	%teleport()

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
	RTL		;Return.

if !Property
	print "A door."
else
	print "Teleports the player."
endif
