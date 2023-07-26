; Sets a flag to print out the room/author names for sublevel 151.
; Custom block by PSI Ninja.

db $42 ; or db $37
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

BodyInside:
HeadInside:
LDA #$0E
STA $1923|!addr

;WallFeet:	; when using db $37
;WallBody:

Mario:
RTL

print "Print the room/author names for sublevel 151."
