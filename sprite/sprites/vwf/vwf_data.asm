
incsrc "vwf_defines.asm"

print "INIT ",pc
    PHX
    PHK
    PLA
    STA.l !VWF_DATA+$02
    STA.l !VWF_ASM_PTRS+$02
    REP #$30
    LDA !E4,x
    AND #$00F0
    LSR #3
    STA $00
    LDA !D8,x
    AND #$00F0
    ASL 
    ORA $00
    TAX
    LDA.l DataPtr,x
    STA.l !VWF_DATA
    LDA.w #RoutinePtr
    STA.l !VWF_ASM_PTRS
    SEP #$30
    PLX

print "MAIN ",pc
    RTL


BinPtr:
	incbin "vwf_data.bin"
DataPtr:
	dw BinPtr+$0,  BinPtr+$2DE,  BinPtr+$443,  BinPtr+$589,  BinPtr+$6E7,  BinPtr+$848,  BinPtr+$97E,  BinPtr+$ADF
	dw BinPtr+$C3B,  BinPtr+$D97,  BinPtr+$F5C,  BinPtr+$1565,  BinPtr+$1ED7,  BinPtr+$2BB3
RoutinePtr:
