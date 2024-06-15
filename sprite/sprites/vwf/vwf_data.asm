
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
	dw BinPtr+$0,  BinPtr+$329,  BinPtr+$4F3,  BinPtr+$69E,  BinPtr+$BB1,  BinPtr+$D77,  BinPtr+$F12,  BinPtr+$10D8
	dw BinPtr+$1299,  BinPtr+$145A,  BinPtr+$16E6,  BinPtr+$1D5E,  BinPtr+$26D0,  BinPtr+$4F14,  BinPtr+$5C20,  BinPtr+$6053
	dw BinPtr+$629C,  BinPtr+$64EA,  BinPtr+$66FB
RoutinePtr:
	dw Routine00
Routine00:

LDA $14
AND #$0F
STA $18C5
RTL

