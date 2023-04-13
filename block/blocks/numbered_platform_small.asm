; Defines which you are freely allowed to change

!PlatformSprite = $61

!StompSFX = $02
!StompPort = $1DF9|!addr

; RAM defines for readability, don't change.
!PlatformNumber = !C2
!Type = !151C
!Map16Low = !157C
!Map16High = !1594

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody ; when using db $37

NoSprite:
	PLX
	PLA
	PLA
RTL

MarioAbove:
TopCorner:
	LDA $7D		; You need to fall on them to activate.
	BMI Return
	LDA $90		; The player must touch the eight topmost pixel to activate.
	CMP #$08	; (Same as for vanilla ledges.)
	BCS Return

	PEI ($03)
	LDA $03		; This one determines the type
	AND #$03	; Can be changed to $000F to support sixteen platforms.
	PHA
	
	LDA #!PlatformSprite
	SEC
	%spawn_sprite()
	BCS NoSprite
	TAX
	%move_spawn_into_block()
	
	PLA
	STA !PlatformNumber,x
	PLA
	STA !Map16Low,x
	PLA
	STA !Map16High,x
	
	LDA #$08
	STA !14C8,x
	LDA #$04
	STA !Type,x

	LDA #!StompSFX
	STA !StompPort

	REP #$30
	LDA $03
	CLC : ADC #$0010
	TAX
	SEP #$20
	%change_map16()
	SEP #$30
Return:

MarioBelow:
MarioSide:

BodyInside:
HeadInside:

WallFeet:	; when using db $37
WallBody:

SpriteV:
SpriteH:

MarioCape:
MarioFireball:
RTL

print "A numbered platform from Yoshi's Island. You can jump on them only for a limited amount. Number of activations before explosion depends on the last digit of the Map16 number."