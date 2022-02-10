db $42 ; or db $37
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

BodyInside:
HeadInside:
LDA #$03
STA $19

;WallFeet:	; when using db $37
;WallBody:

Mario:
RTL

print "Turns the player into Fire Mario when inside."
