!DEF_lowest = $30	; Lower bound of water. Default: 40 (Low tide)
!DEF_highest = $A2	; Higher bound of water: Default A2 (High tide)

!RAM_switch = $0DD9|!addr	; Switch. When activated the water will rise
;Common switches: BLue pow: $14AD ; Silver pow: $14AE ; On-Off: $14AF


HeightTable:
	db !DEF_lowest-1,!DEF_highest+1
RiseTable:
	db $FF,$01
load:
	JSL MultipersonReset_load
	RTL
init:
	stz !RAM_switch
	LDA #!DEF_lowest
	STA $24
	RTL

!screen_num = $0D

main:
    LDA ($19B8+!screen_num)|!addr
    STA $0C
    LDA ($19D8+!screen_num)|!addr
    STA $0D
    JSL MultipersonReset_main
	lda $9D
	ora $13D4|!addr
	beq + : rtl
+	LDY #$00
	LDA !RAM_switch
	BEQ +
	INY
+	LDA $24
	CLC : ADC RiseTable,y
	CMP HeightTable,y
	BEQ +
	STA $24
	RTL;
+	lda !RAM_switch : eor #$01 : sta !RAM_switch
	rtl