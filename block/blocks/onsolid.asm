db $42 ; or db $37
JMP Mario : JMP Mario : JMP Mario
JMP Mario : JMP Mario : JMP Return : JMP Mario
JMP Mario : JMP Return : JMP Return
; JMP WallFeet : JMP WallBody ; when using db $37

Mario:
    LDA $14AF|!addr
    BNE +
    LDY #$01
    LDA #$30
    BRA ++

+   LDY #$00
    LDA #$25
++  STA $1693|!addr
Return:
    RTL

print "A switchblock that turns solid if the on off switch is On, else it is walkthrough."
