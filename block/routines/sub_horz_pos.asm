;~@sa1
; Output = Sprite direction in A (left = 1)

	PHY
	LDY #$00
	LDA $94
	SEC
	SBC !E4,x
	STA $0F
	LDA $95
	SBC !14E0,x
	BPL $01
	INY
	TYA
	PLY
	RTL 