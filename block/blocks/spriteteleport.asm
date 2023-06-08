;~@sa1 <-- DO NOT REMOVE THIS LINE!
;Teleport By Sprite
;By ImJake9
;Requested by G.n.k.
;
;Set to act like anything (should work)

!SPRITENUM = $A4	;Sprite that will cause Mario to teleport. Default is a goomba.
!CUSTOMSPRITE = $01	;Set to $01 if you are using custom sprites.
!SOUNDBANK = $7DFC	;Bank of sound effect to play.
!SOUNDEFFECT = $0F	;Sound effect played when the right sprite hits the block. Default is door sound effect.

db $42
JMP Return : JMP Return : JMP Return : JMP Code : JMP Code : JMP Return : JMP Return : JMP Return : JMP Return : JMP Return

print "Teleport when sprite !SPRITENUM touches the block"

Code:
LDA #!CUSTOMSPRITE	;\
CMP #$00		;| Check if sprite is custom.
BNE Custom		;/ If so, execute custom code.
LDA $3200,x		;\
BRA CheckSprite		;/ Otherwise, execute normal code.

Custom:
LDA $400083,x

CheckSprite:
CMP #!SPRITENUM		;\ If the sprite isn't the right one...
BNE Return		;/ return.

Teleport:
LDA #!SOUNDEFFECT	;\
STA !SOUNDBANK		;| Otherwise, play a sound effect.
JSL $01AB99		;/

LDA #$06		;\
STA $71			;| Then teleport.
STZ $88			;|
STZ $89			;/

Return:
RTL
