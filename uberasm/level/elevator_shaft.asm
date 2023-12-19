!Mall_SRAM = $41C7EA,x	;> Index SRAM by save file (initialized in the deathcounter.asm patch).

; Set manual triggers when the corresponding mall floors are cleared.
main:
	LDA $010A|!addr
	TAX
	LDA !Mall_SRAM
	BIT #%00000001
	BEQ +
	LDA #$01 : STA $7FC072
+
	LDA !Mall_SRAM
	BIT #%00000010
	BEQ +
	LDA #$01 : STA $7FC073
+
	LDA !Mall_SRAM
	BIT #%00000100
	BEQ +
	LDA #$01 : STA $7FC074
+
	LDA !Mall_SRAM
	BIT #%00001000
	BEQ +
	LDA #$01 : STA $7FC075
+
	LDA !Mall_SRAM
	BIT #%00010000
	BEQ +
	LDA #$01 : STA $7FC076
+
	LDA !Mall_SRAM
	BIT #%00100000
	BEQ +
	LDA #$01 : STA $7FC077
+
	RTL
