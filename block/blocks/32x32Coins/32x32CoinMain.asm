;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 32x32 coin by EternityLarva
; ver 1.2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; effect config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0 - effect off
; 1 - effect on
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!effect = 0
!extended_sprite = $13

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; pow config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 0 - like 2C(coin - coin)
; 1 - like 2B(coin - brown)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!powpow = 0

	if !powpow != 0
		LDA $14AD|!addr
		BEQ +
		LDA #$30
		STA $1693|!addr
		LDY #$01
		RTL
	+
	endif
	
	LDA #$1C         ;sound effect(Yoshi coin)
	STA $1DF9|!addr

	LDA $98      ;\
	PHA          ;|
	LDA $99      ;|
	PHA          ;|block info push
	LDA $9A      ;|
	PHA          ;|
	LDA $9B      ;|
	PHA          ;/

	%erase_block()

	if !block_pos == 0          ;up-left
		JSR horizontal_add      ;Å®
		%erase_block()
		JSR vertical_add        ;Å´
		%erase_block()
		JSR horizontal_subtract ;Å©
		%erase_block()
	endif

	if !block_pos == 1          ;up-right
		JSR vertical_add        ;Å´
		%erase_block()
		JSR horizontal_subtract ;Å©
		%erase_block()
		JSR vertical_subtract   ;Å™
		%erase_block()
	endif

	if !block_pos == 2          ;down_right
		JSR horizontal_subtract ;Å©
		%erase_block()
		JSR vertical_subtract   ;Å™
		%erase_block()
		JSR horizontal_add      ;Å®
		%erase_block()
	endif

	if !block_pos == 3          ;down_left
		JSR vertical_subtract   ;Å™
		%erase_block()
		JSR horizontal_add      ;Å®
		%erase_block()
		JSR vertical_add        ;Å´
		%erase_block()
	endif

	PLA          ;\
	STA $9B      ;|
	PLA          ;|
	STA $9A      ;|block info pull
	PLA          ;|
	STA $99      ;|
	PLA          ;|
	STA $98      ;/

	if !effect != 0
		PHX
		PHY
		LDA #!extended_sprite
		%spawn_extended_sprite()
		BCS +
		LDA #$1E
		STA $176F|!addr,y   ;timer
		LDA #!coins
		STA $1779|!addr,y   ;coins
		LDA $98
		AND #$F0
		STA $1715|!addr,y
		LDA $99
		STA $1729|!addr,y
		LDA $9A
		AND #$F0
		STA $171F|!addr,y
		LDA $9B
		STA $1733|!addr,y
	+
		LDY #!coins
		LDA coin_table,y
		JSL $05B329
		PLY
		PLX
	endif
	
	if !effect == 0
		LDA #!coins
		JSL $05B329
	endif
	RTL

coin_table: db $0A,$1E,$32

vertical_add:
	JSR check_vertical
	LDA $98
	CLC
	ADC #$10
	STA $98
	LDA $99
	ADC #$00
	STA $99
	RTS

vertical_subtract:
	JSR check_vertical
	LDA $98
	SEC
	SBC #$10
	STA $98
	LDA $99
	SBC #$00
	STA $99
	RTS

horizontal_add:
	JSR check_vertical
	LDA $9A
	CLC
	ADC #$10
	STA $9A
	LDA $9B
	ADC #$00
	STA $9B
	RTS

horizontal_subtract:
	JSR check_vertical
	LDA $9A
	SEC
	SBC #$10
	STA $9A
	LDA $9B
	SBC #$00
	STA $9B
	RTS

check_vertical:
	LDA $5B
	AND #$01
	BEQ +
	PHY
	LDA $99
	LDY $9B
	STY $99
	STA $9B
	PLY
+
	RTS