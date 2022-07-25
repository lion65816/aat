; Pass-through block that hurts the player on contact.
; Custom block by PSI Ninja.

db $42 ; or db $37
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP BodyInside : JMP HeadInside
; JMP WallFeet : JMP WallBody ; when using db $37

BodyInside:
HeadInside:
JSL $00F5B7	; Call the hurt subroutine.

;WallFeet:	; when using db $37
;WallBody:

Mario:
RTL

print "Hurts the player on contact."
