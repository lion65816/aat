;Block that is passable only when you have 4 (or specified number) dragon coins.

!CoinRequirement = 10			;how many yoshi/dragon coins needed to make this block passable

print "A block that is passable only when the player has ",dec(!CoinRequirement)," dragon coins."

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP Corner : JMP BodyIn : JMP HeadIn
JMP WallFeet : JMP WallBody

Corner:
HeadIn:
BodyIn:
MarioAbove:
MarioBelow:
MarioSide:
WallFeet:
WallBody:
	LDA $141A|!addr		;Load number of dragon coins
	CMP #!CoinRequirement
	BCS GotCoins		;Branch to 'Gotcoins'

	LDY #$01	;act like tile 130 (Grey cement block)
	LDA #$30
	STA $1693|!addr
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
GotCoins:
	RTL
