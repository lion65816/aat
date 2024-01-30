!CustomShooter = $C1        ; Number of the custom shooter

db $37
JMP MarioBelow : JMP MarioAbove : JMP MarioSide
JMP SpriteV : JMP SpriteH : JMP MarioCape : JMP MarioFireball
JMP TopCorner : JMP BodyInside : JMP HeadInside
JMP WallFeet : JMP WallBody

SpriteV:
SpriteH:
    LDA #$69
    STA $07
    BRA Activate

MarioBelow:
MarioAbove:
MarioSide:
TopCorner:
BodyInside:
HeadInside:
WallFeet:
WallBody:
    STZ $69

Activate:
    STZ $05
    STZ $06
    LDA #$FF        ;\ 
    STA $04         ;/ Address which holds index of closest shooter so far
    STA $02         ;\ Address which holds closest Xpos so far
    STA $03         ;/
    LDX #$07
-   LDA $1783|!addr,x
    ORA #$40
    CMP.b #!CustomShooter+$01
    BEQ .found
.continue
    DEX
    BPL -

    LDA $04             ;\ 
    BMI +               ;/ if index of closest shooter is negative ($FF)
    TAX
    LDA #$80            ; So if we have an index...
    STA $17AB|!addr,x   ; activate shooter. x = shooter index of closest one
+   RTL

.found
    LDA $17A3|!addr,x   ; shooter x high
    XBA
    LDA $179B|!addr,x   ; shooter x low
    REP #$20
    STA $00             ;= shooter xpos
    SEP #$20
    LDA $07
    CMP #$69
    BNE .playerTouchX
    PHX
    LDX $15E9|!addr
    LDA !14E0,x        ; sprite xpos
    XBA
    LDA !E4,x
    PLX
    BRA +

.playerTouchX
    REP #$20
    LDA $D1             ; player xpos
+   REP #$20

    SEC : SBC $00
    BCS +
        EOR #$FFFF
        INC A
+   STA $05             ; XDIFF

    SEP #$20

    LDA $1793|!addr,x   ; shooter x high
    XBA
    LDA $178B|!addr,x   ; shooter x low
    REP #$20
    STA $00             ;= shooter xpos
    SEP #$20
    LDA $07
    CMP $69
    BNE .playerTouchY
    PHX
    LDX $15E9|!addr
    LDA !14D4,x         ; sprite ypos
    XBA
    LDA !D8,x
    PLX
.playerTouchY
    REP #$20
    LDA $D3             ; player ypos
    REP #$20
    SEC : SBC $00
    BCS +
        EOR #$FFFF
        INC A
+   CLC : ADC $05
    STA $05             ; XYDIFF

    LDA $02
    CMP $05
    BCC .continue8
    LDA $05
    STA $02             ; $02 = Xdis
    STX $04
.continue8
    SEP #$20
    JMP .continue

MarioCape:
MarioFireball:
    RTL

print "Activates the nearest laser shooter when touched by the player or a sprite."
