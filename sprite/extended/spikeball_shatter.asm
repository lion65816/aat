;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spikeball shatter effect  by E.L
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tile: db $28,$29,$28,$29      ;\ tilemap
      db $38,$39,$38,$39      ;/

prop: db $39,$39,$F9,$F9      ;\ YXPPCCCT table
      db $39,$39,$F9,$F9      ;/

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Print "MAIN ",pc
	JSR GFX
	LDA $9D
	BNE ++
	
	%Speed()
	LDA !extended_behind,x  ;clock flag
	AND #$01
	BEQ +
	
	INC !extended_table,x  ;direction
	BRA ++
+
	DEC !extended_table,x  ;direction
++
	RTL
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GFX:
	%ExtendedGetDrawInfo()
	LDA $01
	STA $0200|!Base2,y

	LDA $02
	STA $0201|!Base2,y

	LDA !extended_behind,x
	AND #$04
	STA $03

	PHX
	LDA !extended_table,x
	AND #$30
	LSR #4
	ORA $03
	TAX

	LDA tile,x
	STA $0202|!Base2,y

	LDA prop,x
	ORA $64
	STA $0203|!Base2,y
	PLX

	TYA
	LSR #2
	TAY
	LDA #$00
	STA $0420|!Base2,y

	RTS
