;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Falling Fireball, by imamelia
;
; This is the falling fireball from the Bowser battle in SMW, though not really a
; disassembly.
;
; Extra bytes: 0
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!Timer2Check = $20

Tilemap:
	db $6C,$6E,$6C,$6E

TileProps:
	db $05,$05,$45,$45

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
    %BEC(skipsfx)
	LDA #$27		; uncomment this if you want the sprite to play a fire sound effect
	STA $1DFC|!Base2		; when you place it in the level
    skipsfx:
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR FallingFireballMain
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FallingFireballMain:
	STZ !15D0,x			; clear the...being eaten flag??
	LDA $9D				; if sprites are locked...
	BEQ .NotLocked		;
	JMP Locked			; skip the speed setting, interaction, etc.
.NotLocked				;
	JSL $01A7DC|!BankB	; interact with the player
	JSR SubSetAniFrame		;
	JSL $019138|!BankB		; check for contact with objects
	JSL $01801A|!BankB	; update sprite Y position without gravity
	LDA !1564,x			;
	BNE .NoAccelerate		;
	LDA !AA,x			;
	BMI .StartAccelerating	;
	CMP #!Timer2Check	;
	BCS .NoAccelerate		;
.StartAccelerating			;
	CLC					;
	ADC #$02			;
	STA !AA,x			;
.NoAccelerate				;
	LDA #$00			;
	%SubOffScreen()		;
Locked:					;
	LDY $9D				;
	BNE .Locked2			;
	LDA !1588,x			;
	AND #$04			; if the sprite is on the ground...
	BEQ .InAir			;
	STZ !AA,x			; zero out its Y speed
	LDA !1558,x			;
	BEQ .SetVanishTimer	; if the timer for vanishing has not been set, then do so
	CMP #$01			; if it has almost run out..
	BNE .Locked2			;
.SpriteDisappears			; then make the sprite disappear
	LDA #$04			;
	STA !14C8,x			;
	LDA #$1F				;
	STA !1540,x			;
	RTS					;
.SetVanishTimer			;
	LDA #$80			;
	STA !1558,x			;
	BRA .Locked2			;
.InAir					;
	TXA					;
	ASL #2				;
	CLC					;
	ADC $14				;
	LDY #$F0				; make the sprite's X speed alternate
	AND #$04			; between F0 and 10
	BEQ $02				; to get the waving effect
	LDY #$10				;
	STY !B6,x			;
	JSL $018022|!BankB		; update sprite X position without gravity
.Locked2
	; go right to the GFX routine

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
	%GetDrawInfo()		;
	LDA $00				;
	STA $0300|!Base2,y			; tile X position
	LDA $01				;
	STA $0301|!Base2,y			; tile Y position
	LDA $14				;
	AND #$0C			;
	LSR					;
	ADC $15E9|!Base2			;
	LSR					;
	AND #$03			;
	TAX					;
	LDA Tilemap,x			;
	STA $0302|!Base2,y			; tile number
	LDA TileProps,x		;
	ORA $64				;
	STA $0303|!Base2,y			; tile properties
	LDX $15E9|!Base2			;
	LDY #$02				;
	LDA #$00			;
	JSL $01B7B3|!BankB		;
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; subroutines
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubSetAniFrame:
	INC !1570,x		;
	LDA !1570,x		;
	LSR				;
	LSR				;
	AND #$01		;
	STA !1602,x		;
	RTS				;

