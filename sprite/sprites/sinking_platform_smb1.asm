;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; SMB1 Sinking Platform, by imamelia
;
; This is the platform from SMB1 that moves downward quickly when you stand on it.
;
; Extra bytes: 1
;
; The width of the platform is a number of 8x8 tiles equal to the value of the extra
; byte plus 2.  Setting it higher than 0F or so is not recommended.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

!Tile1 = $06
!Tile2 = $07

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine and main routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
	LDA !7FAB40,x
	STA !1510,x
	INC
	INC
	STA !160E,x
	LDA !1510,x
	ASL #2
	EOR #$FF : INC
	SEC
	SBC #$04
	STA !151C,x
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR SpriteMainRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteMainRt:
	JSR SubGFX			;
	LDA !14C8,x			;
	EOR #$08				;
	ORA $9D				;
	BNE ReturnMain		;
	LDA #$00			;
	%SubOffScreen()		;
	JSR Interact			;
	BCC NoMotion			;
	LDA !AA,x			;
	CMP #$30			;
	BCS NoAccel			;
	LDA !AA,x			;
	CLC					;
	ADC #$04			;
	STA !AA,x			;
NoAccel:					;
	JSL $01801A|!BankB	;
ReturnMain:				;
	RTS					;
NoMotion:				;
	STZ !AA,x			;
	RTS					;
	
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
	%GetDrawInfo()		;
	LDA !15F6,x			;
	ORA $64				;
	STA $03				;
	LDA !151C,x			;
	STA $06				;
	LDA !160E,x			;
	STA $05				;
	TAX					;
.Loop					;
	LDA $00				;
	CLC					;
	ADC $06				;
	STA $0300|!Base2,y			;
	LDA $01				;
	DEC					;
	STA $0301|!Base2,y			;
	LDA #!Tile1			;
	CPX #$00				;
	BEQ .StoreTile			;
	CPX $05				;
	BEQ .StoreTile			;
	LDA #!Tile2			;
.StoreTile					;
	STA $0302|!Base2,y			;
	LDA $03				;
	CPX #$00				;
	BNE .SetProps			;
	ORA #$40			;
.SetProps					;
	STA $0303|!Base2,y			;
	LDA $06				;
	CLC					;
	ADC #$08			;
	STA $06				;
	INY #4				;
	DEX					;
	BPL .Loop				;
	LDX $15E9|!Base2			;
	LDY #$00				;
	LDA $05				;
	JSL $01B7B3|!BankB		;
	RTS					;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; subroutines
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;------------------------------------------------
; platform interaction
;------------------------------------------------

Interact:
	STZ $09
	LDA !151C,x
	BPL $02
	DEC $09
	STA $08
	LDA !160E,x
	ASL #3
	CLC
	ADC #$0E
	STA $0C
	STZ $0D
	LDA #$FE
	STA $0A
	LDA #$FF
	STA $0B
	LDA #$0E
	STA $0E
	STZ $0F
	JSR SetPlayerClipping
	JSR SetSpriteClipping
	JSR CheckForContact
	BCC .NoContact
	PHB
	LDA.b #$01|!BankB>>16
	PHA
	PLB
	PHK
	PEA.w .Return2-1
	PEA $8020
	JML $01B45C|!BankB
.Return2
	PLB
	RTS
.NoContact
	CLC
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; custom sprite clipping routine
;
; - Sets up a sprite's interaction field with 16-bit values
; - Input:
;	- $08-$09 = X displacement
;	- $0A-$0B = Y displacement
;	- $0C-$0D = width
;	- $0E-$0F = height
; - Output: None
; - Note: This should be used in conjunction with the following two routines.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SetSpriteClipping:
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	CLC
	ADC $08
	STA $08
	SEP #$20
	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	CLC
	ADC $0A
	STA $0A
	SEP #$20
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; custom player clipping routine
;
; - Sets up the player's interaction field with 16-bit values
; - Input: None
; - Output: None
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SetPlayerClipping:
	PHX
	REP #$20
	LDA $94
	CLC
	ADC #$0002
	STA $00
	LDA #$000C
	STA $04
	SEP #$20
	LDX #$00
	LDA $73
	BNE .Inc1
	LDA $19
	BNE .Next1
.Inc1
	INX
.Next1
	LDA $187A|!Base2
	BEQ .Next2
	INX #2
.Next2
	LDA $03B660|!BankB,x
	STA $06
	STZ $07
	LDA $03B65C|!BankB,x
	REP #$20
	AND #$00FF
	CLC
	ADC $96
	STA $02
	SEP #$20
	PLX
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; custom contact check routine
;
; - Checks for contact between whatever two things were set up previously
; - Input: $00-$07 = clipping set 1, $08-$0F = clipping set 2
; - Output: Carry clear = no contact, carry set = contact
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

CheckForContact:
	REP #$20
.CheckX
	LDA $00
	CMP $08
	BCC .CheckXSub2
.CheckXSub1
	SEC
	SBC $08
	CMP $0C
	BCS .ReturnNoContact
	BRA .CheckY
.CheckXSub2
	LDA $08
	SEC
	SBC $00
	CMP $04
	BCS .ReturnNoContact
.CheckY
	LDA $02
	CMP $0A
	BCC .CheckYSub2
.CheckYSub1
	SEC
	SBC $0A
	CMP $0E
	BCS .ReturnNoContact
.ReturnContact
	SEP #$21
	RTS
.CheckYSub2
	LDA $0A
	SEC
	SBC $02
	CMP $06
	BCC .ReturnContact
.ReturnNoContact
	CLC
	SEP #$20
	RTS














