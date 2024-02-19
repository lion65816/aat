
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
	dw BinPtr+$0,  BinPtr+$2DE,  BinPtr+$445,  BinPtr+$58D,  BinPtr+$6ED,  BinPtr+$850,  BinPtr+$988,  BinPtr+$AEB
	dw BinPtr+$C49,  BinPtr+$DA7,  BinPtr+$F6C,  BinPtr+$1577,  BinPtr+$1EE9,  BinPtr+$2BC5
RoutinePtr:
