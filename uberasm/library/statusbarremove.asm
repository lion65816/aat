init:
LDA #$01
STA $0D9B|!addr

REP #$20
LDA #$1143
STA $4330
LDA.w #.q
STA $4332
LDY.b #.q>>16
STY $4334
SEP #$20
STZ $4337
LDA #$08
TSB $0D9F|!addr
RTL

.q
db $01 : dw $0022|!dp
db $00
