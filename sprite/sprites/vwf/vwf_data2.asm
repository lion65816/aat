
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
	dw BinPtr+$0,  BinPtr+$BAD,  BinPtr+$1A54,  BinPtr+$1BF1,  BinPtr+$1EA7,  BinPtr+$2324,  BinPtr+$3380,  BinPtr+$4059
	dw BinPtr+$4E95
RoutinePtr:
	dw Routine00
Routine00:



!EventRAM1 = $1F02+($43>>3) ;\ Beat Level 6: Thwompire State Building
!EventBit1 = 1<<(7-($43&7)) ;/
!EventRAM2 = $1F02+($2A>>3) ;\ Beat Level D: Puella Magi Demoka Magica
!EventBit2 = 1<<(7-($2A&7)) ;/
!EventRAM3 = $1F02+($5A>>3) ;\ Beat Level 101: Spikes do hurt (sometimes)
!EventBit3 = 1<<(7-($5A&7)) ;/
!EventRAM4 = $1F02+($1B>>3) ;\ Beat Level 11D: Castle of SERIOUS BUSINESS (normal exit)
!EventBit4 = 1<<(7-($1B&7)) ;/
STZ $18C5
LDA !EventRAM1
AND #!EventBit1
BNE +
RTL
+
LDA !EventRAM2
AND #!EventBit2
BNE +
RTL
+
LDA !EventRAM3
AND #!EventBit3
BNE +
RTL
+
LDA !EventRAM4
AND #!EventBit4
BNE +
RTL
+
LDA #$01
STA $18C5
RTL

