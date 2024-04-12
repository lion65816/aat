
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
	dw BinPtr+$0,  BinPtr+$5C2,  BinPtr+$1055,  BinPtr+$11E9,  BinPtr+$149C,  BinPtr+$1857,  BinPtr+$1C09,  BinPtr+$1DA7
	dw BinPtr+$266F,  BinPtr+$2E48
RoutinePtr:
