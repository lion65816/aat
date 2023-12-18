!DEF_lowest = $50	; Lower bound of water. Default: 40 (Low tide)
!DEF_highest = $80	; Higher bound of water: Default A2 (High tide)

!RAM_switch = $14AF|!addr	; Switch. When activated the water will rise
;Common switches: BLue pow: $14AD ; Silver pow: $14AE ; On-Off: $14AF

HeightTable:
	db !DEF_lowest-1,!DEF_highest+1
RiseTable:
	db $FF,$01

load:
	JSL FilterYoshi_load
	RTL

init:
	LDA #!DEF_lowest
	STA $24
	RTL

main:
	JSL PitCode_main
	LDY #$00
	LDA !RAM_switch
	BEQ +
	INY
+	LDA $24
	CLC : ADC RiseTable,y
	CMP HeightTable,y
	BEQ +
	STA $24
+	RTL
