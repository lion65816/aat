
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
	incbin "vwf_data2.bin"
DataPtr:
	dw BinPtr+$0,  BinPtr+$BAD,  BinPtr+$1A12,  BinPtr+$1BAF,  BinPtr+$1E65,  BinPtr+$22E2,  BinPtr+$332A,  BinPtr+$34C8
	dw BinPtr+$41A1,  BinPtr+$4FDD
RoutinePtr:
