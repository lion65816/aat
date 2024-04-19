
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
	dw BinPtr+$0,  BinPtr+$2DE,  BinPtr+$45D,  BinPtr+$5BD,  BinPtr+$A85,  BinPtr+$C00,  BinPtr+$D50,  BinPtr+$ECB
	dw BinPtr+$1041,  BinPtr+$11B7,  BinPtr+$13F8,  BinPtr+$1A25,  BinPtr+$2397,  BinPtr+$4BD9,  BinPtr+$589A,  BinPtr+$5C82
	dw BinPtr+$5EC6,  BinPtr+$610F,  BinPtr+$631B
RoutinePtr:
	dw Routine00
Routine00:

LDA $14
AND #$0F
STA $18C5
RTL

