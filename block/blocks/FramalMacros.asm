macro LoadSlot1_7()
if !sa1
L:
	LDA $7FC070+!Gl+!Slot
	STA $00
	RTL

M:
	LDA.b #L
	STA $0183
	LDA.b #L/256
	STA $0184
	LDA.b #L/65536
	STA $0185
	LDA #$D0
	STA $2209
-	LDA $018A
	BEQ -
	STZ $018A
	LDA $00
else
M:
	LDA $7FC080+!Gl+!Slot
endif
endmacro

macro LoadSlot1_6()
if !sa1
L:
	LDA $7FC004
	STA $00
	RTL

M:
	LDA.b #L
	STA $0183
	LDA.b #L/256
	STA $0184
	LDA.b #L/65536
	STA $0185
	LDA #$D0
	STA $2209
-	LDA $018A
	BEQ -
	STZ $018A
	LDA $00
else
M:
	LDA $7FC004
endif
endmacro
