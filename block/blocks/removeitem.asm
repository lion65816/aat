db $42 ; or db $37
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

BodyInside:
HeadInside:
LDA #$00
STA $0DC2|!addr

;WallFeet:	; when using db $37
;WallBody:

Mario:
RTL

print "Removes the item in the player's item box."
