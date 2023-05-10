db $42 ; or db $37
JMP Mario : JMP MarioAbove : JMP Mario
JMP Sprite : JMP Sprite : JMP Mario : JMP Mario
JMP MarioAbove : JMP Mario : JMP Mario
; JMP WallFeet : JMP WallBody ; when using db $37

MarioAbove:
; Check if the game is paused or frozen due to animation and such.
LDA $9D
BNE Ret
; Trigger the low jump level asm flag.
; 7C is also used on HP system, be careful!
LDA #$02
STA $7C
; Check Mario's speed.
LDA $7B
BEQ Ret
; If X speed is rightwards, move on to Part 2.
CMP #$7F
BCC Part2
; If X speed is left, etc etc Part 3.
CMP #$80
BCS Part3
Ret:
RTL

Mario:
Sprite:
RTL

Part2:
; Make sure Mario's speed isn't toned down completely.
LDA $7B
CMP #$12
BCC Ret
; Decrement Mario's position rightwards, wind effect basically.
REP #$20
DEC $94
SEP #$20
RTL

Part3:
; Ditto with the above, make sure speed isn't toned down completely.
LDA $7B
CMP #$EE
BCS Ret
; Increment Mario's position rightwards.
REP #$20
INC $94
SEP #$20
RTL

print "Sand block from ASPE Mario, by a random ASPE contributor, extracted for Big Brawler."
