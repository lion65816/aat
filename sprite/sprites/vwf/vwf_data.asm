
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
	dw BinPtr+$0,  BinPtr+$2DE,  BinPtr+$45D,  BinPtr+$5BD,  BinPtr+$A89,  BinPtr+$C04,  BinPtr+$D54,  BinPtr+$ECF
	dw BinPtr+$1045,  BinPtr+$11BB,  BinPtr+$13FC,  BinPtr+$1A29,  BinPtr+$239B,  BinPtr+$3225,  BinPtr+$3271
RoutinePtr:
	dw Routine00
Routine00:

LDA $14
AND #$0F
STA $18C5
RTL

