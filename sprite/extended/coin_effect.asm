;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Coin Effect Sprite by EternityLarva
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!coin_tile = $4D
!sp10_tile = $44
!sp30_tile = $1D
!sp50_tile = $54

!Tile_info = $34   ;yxppccct

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Graphics
	LDA $9D
	BNE Return
	%SubOffScreen()

	LDA !extended_timer|!Base2,x
	BNE +
	STZ !extended_num|!Base2,x
+
	PHY
	LDA !extended_timer|!Base2,x
	TAY
	LDA speed,y
	STA !extended_y_speed|!Base2,x
	PLY
	%SpeedY()
Return:
	PLB
	RTL

speed: db $F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8,$F8
       db $F8,$F0,$F0,$F0,$F0,$F0,$F0,$F0,$E0,$E0,$E0,$E0,$E0,$E0,$E0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Tile: db !coin_tile,!sp10_tile
      db !coin_tile,!sp30_tile
      db !coin_tile,!sp50_tile

flip: db $00,$00
      db $00,$00
      db $00,$80

Xpos: db $00,$08

Graphics:
	%ExtendedGetDrawInfo()

	LDA !extended_behind|!Base2,x
	ASL A
	STA $04                    ;coin(10,30,50)

	PHX
	LDX #$01
-
	PHX
	LDA Xpos,x
	CLC
	ADC $01                    ;x
	STA $0200|!Base2,y
	PLX

	LDA $02                    ;y
	STA $0201|!Base2,y

	PHX
	TXA
	CLC
	ADC $04                    ;coin(10,30,50)
	TAX
	LDA Tile,x
	STA $0202|!Base2,y
	PLX

	PHX
	TXA
	CLC
	ADC $04                    ;coin(10,30,50)
	TAX
	LDA flip,x
	STA $05
	PLX

	LDA #!Tile_info
	ORA $05
	ORA $64
	STA $0203|!Base2,y
	
	PHX
	TYA
	LSR #2
	TAX
	LDA #$00
	STA $0420|!Base2,x
	PLX
	
	INY
	INY
	INY
	INY
	DEX
	BPL -

	PLX
	RTS