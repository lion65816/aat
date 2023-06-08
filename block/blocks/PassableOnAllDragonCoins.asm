;Block that is passable only when you have all dragon coins.
;if you want it to be passable on collecting less than the full complement of five dragon coins, use the "Passable On Yoshi Coins" block (this adapts that block and uses the vanilla code at $0DB2CA)
;make it act like 25

print "A block that is passable only when the player has all (5) dragon (yoshi) coins."

db $42
JMP MarioBelow : JMP MarioAbove : JMP MarioSide : JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireBall
JMP Corner : JMP BodyIn : JMP HeadIn

Corner:
HeadIn:
BodyIn:
MarioAbove:
MarioBelow:
MarioSide:
LDA.W $13BF|!addr              
LSR #3                    
TAY                       
LDA.W $13BF|!addr              
AND.B #$07                
TAX                       
LDA.W $1F2F|!addr,Y             
AND.L $0DA8A6|!bank,X
BNE GotCoins		;Branch to 'Gotcoins'
	LDY #$01	;act like tile 130 (Grey cement block)
	LDA #$30
	STA $1693|!addr
	RTL
	GotCoins:
	LDY #$00
	LDA #$25
	STA $1693|!addr
SpriteV:
SpriteH:
MarioCape:
MarioFireBall:
	RTL