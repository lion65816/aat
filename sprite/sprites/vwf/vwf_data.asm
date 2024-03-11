
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
	dw BinPtr+$0,  BinPtr+$2DE,  BinPtr+$447,  BinPtr+$591,  BinPtr+$6F3,  BinPtr+$858,  BinPtr+$992,  BinPtr+$AF7
	dw BinPtr+$C57,  BinPtr+$DB7,  BinPtr+$FF8,  BinPtr+$1625,  BinPtr+$1F97,  BinPtr+$2E21,  BinPtr+$2E53
RoutinePtr:
	dw Routine00
Routine00:

LDA $14
AND #$0F
STA $18C5
RTL

