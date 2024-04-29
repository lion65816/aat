
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
	dw BinPtr+$0,  BinPtr+$2E1,  BinPtr+$463,  BinPtr+$5C6,  BinPtr+$A91,  BinPtr+$C0F,  BinPtr+$D62,  BinPtr+$EE0
	dw BinPtr+$1059,  BinPtr+$11D2,  BinPtr+$1416,  BinPtr+$1A46,  BinPtr+$23BB,  BinPtr+$4BFD,  BinPtr+$58C1,  BinPtr+$5CAC
	dw BinPtr+$5EF3,  BinPtr+$613F,  BinPtr+$634E
RoutinePtr:
	dw Routine00
Routine00:

LDA $14
AND #$0F
STA $18C5
RTL

