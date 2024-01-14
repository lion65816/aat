;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Thunder version 2.0, by Mattrizzle, original version by Ghettoyouth
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

main:
		PHX
		LDX.W $0681|!addr
		LDA.B #$10
		STA.W $0682|!addr,X
		STZ.W $0683|!addr,X
		STZ.W $0684|!addr,X
		STZ.W $0685|!addr,X
		TXY
		LDX.W $1FFB|!addr
		BNE .ADDR_03E01B
		LDA.W $190D|!addr
		BEQ .ADDR_03DFF0
		REP #$20		; Accum (16 bit) 
		LDA.W $0701|!addr
		BRA .ADDR_03E031
.ADDR_03DFF0
		LDA $14			; Accum (8 bit) 
		LSR
		BCC .ADDR_03E036
		DEC $1FFC|!addr
		BNE .ADDR_03E036
		TAX
		LDA #$A9
		AND #$07
		TAX
		LDA .DATA_04F6F8,X
		STA $1FFC|!addr
		LDA .DATA_04F700,X
		STA $1FFB|!addr
		TAX
		LDA #$08
		STA $1FFD|!addr
		LDA #$18
		STA $1DFC|!addr		; / Play sound effect 
.ADDR_03E01B
		DEC $1FFD|!addr
		BPL .ADDR_03E028
		DEC $1FFB|!addr
		LDA #$04
		STA $1FFD|!addr
.ADDR_03E028
		TXA
		ASL
		TAX
		REP #$20		; Accum (16 bit) 
		LDA.L $00B5DE|!bank,X
.ADDR_03E031
		STA $0684|!addr,Y 
		SEP #$20		; Accum (8 bit) 
.ADDR_03E036
		LDX $1429|!addr
		LDA #$00
		TAX
		LDA #$0E
		STA $00
.ADDR_03E042
		LDA $0705|!addr,X
		STA $0686|!addr,Y
		INX
		INY
		DEC $00
		BNE .ADDR_03E042
		TYX
		STZ $0686|!addr,X
		INX
		INX
		INX
		INX
		STX $0681|!addr
		PLX
		RTL

.DATA_04F6F8
db $20,$58,$43,$CF,$18,$34,$A2,$5E

.DATA_04F700
db $07,$05,$06,$07,$04,$06,$07,$05