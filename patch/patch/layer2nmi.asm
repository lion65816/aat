
if read1($00FFD6) == $23
	sa1rom
	!bank = $000000
	!dp = $3000
	!addr = $6000
else
    lorom
	!bank = $800000
	!dp = $0000
	!addr = $0000
endif

org $008275
autoclean JML Layer2Upload
          NOP
    
freecode
Layer2Upload:
    REP #$20
    LDA $010B|!addr
    CMP #$0105
    BEQ +
    SEP #$20
    
    LDA #$80
    STA $2115
    
    LDA #$04
    STA $4300
    LDA #$16
    STA $4301
    REP #$20
    LDA #16
    STA $4305
    LDA #Wily
    STA $4302
    SEP #$20
    LDA #Wily>>16
    STA $4304
    LDA #$01
    STA $420B
    BRA ++

+   SEP #$20
++  LDA.w $0D9B|!addr				;$008275	|\ If not in a special level continue as normal.
	BEQ Continue
    JML $00827A
Continue:
    JML $008292
    
Wily:
    dw $3800                    ; index in Layer 2 coordenates
    db $2E,$0F                  ; Tile number, property
    dw $3801
    db $2F,$0F
    dw $3855
    db $3E,$0F
    dw $3856
    db $3F,$0F