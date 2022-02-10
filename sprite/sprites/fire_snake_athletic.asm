;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; Fire Snake v1.1, by imamelia, based on the Wiggler disassembly by edit1754
; With edits by A-l-e-x-99, done to make the sprite killable by cape.
;
; This is the Fire Snake from SMB3.
;
; Uses extra bit?: NO.
; Uses extra bytes?: NO.
; Uses extensions?: NO.
; Anything else?: This file requires the "cape.asm" file to be put in your Routines folder.
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;(Small change by Rykon-V73): Edit the GFX, speeds and jumping timer here:

!JMPTimer  		= $80
!HeadTile1		= $46
!HeadTile2		= $48
!SFTile1			= $67
!SFTile2			= $69
!FSnakeXSpeedRight	= $09
!FSnakeXSpeedLeft		= $F7
!FSnakeYSpeedBottom	= $E7
!FSnakeYSpeedTop		= $DD

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;Bonus: If you want Mario to die in one shot, find:
;.HurtPlayer				
;	JSL $00F5B7|!BankB		
;	RTS		
;and replace JSL $00F5B7-hurt routine with JSL $00F606-kill routine.			
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; defines and tables
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Data02EFEA:
	db $00,$80,$00,$80
Data02EFEE:
	db $00,$00,$01,$01
Data02F103:
	db $00,$0E,$1C,$2A,$38
StarSounds:
	db $13,$14,$15,$16,$17,$18,$19

Tilemap:
	db !HeadTile1,!HeadTile2,!SFTile1,!SFTile2,!SFTile2,!SFTile1,!SFTile1,!SFTile2,!SFTile2,!SFTile1
	
XSpeed:
	db !FSnakeXSpeedRight,!FSnakeXSpeedLeft	
YSpeed:
	db !FSnakeYSpeedBottom,!FSnakeYSpeedTop
!TimeTillJump = !JMPTimer

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

print "INIT ",pc
	PHB
	PHK
	PLB
	JSR SpriteInitRt
	PLB
	RTL

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; init routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SpriteInitRt:
	LDA #!TimeTillJump
	STA !1534,x
	JSR SetUpPointer
	LDY #$7E
.Loop
	LDA !E4,x
	STA [$D5],y
	LDA !D8,x
	INY
	STA [$D5],y
	DEY #3
	BPL .Loop
	%SubHorzPos()
	TYA
	STA !157C,x
	RTS

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; main routine wrapper
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
	JSR SetUpPointer		; set up [$D5]
	LDA $9D				;
	BEQ Continue			; return if sprites are locked
	JMP SprLocked		;
Continue:				;
	LDA #$00			;
	%SubOffScreen()		;
	LDA !160E,x			;
	CMP #$02			;
	BEQ StarKilled			;
	JSL $018032|!BankB		; interact with other sprites
	LDA !14C8,x			;
	CMP #$02			;
	BNE NoStarKill			;
	JSR CapeKill			; Alex edit.
NoStarKill:				;
	LDA !14C8,x
	CMP #$02
	BEQ StarKilled
	JSL $019138|!BankB		; interact with objects
	INC !1570,x			; increment the frame counter for this sprite
	LDA !160E,x			; jump state (0 = waiting, 1 = jumping, 2 = star-killed)
	CMP #$01			;
	BEQ Jumping			;
	DEC !1534,x			;
	LDA !1534,x			;
	BNE NoJump			;
	LDA !160E,x			;
	EOR #$01				;
	STA !160E,x			;
	%SubHorzPos()		;
	TYA					;
	STA !157C,x			;
	LDA XSpeed,y			;
	STA !B6,x			;
	JSL $01ACF9|!BankB			;
	AND #$01			;
	TAY					;
	LDA YSpeed,y			;
	STA !AA,x			;
NoJump:					;
	BRA Shared			;
StarKilled:				;
	INC !1570,x			; increment the frame counter for this sprite
	JSL $01801A|!BankB	;
	INC !AA,x			;
	BRA Shared			;
Jumping:					;
	JSL $018022|!BankB		; update sprite X position without gravity
	JSL $01801A|!BankB	; update sprite Y position without gravity
	INC !AA,x			;
	LDA !1588,x			;
	BIT #$03				;
	BNE TouchedWall		;
	BIT #$04				; if the sprite has landed on the ground...
	BEQ Shared			;
	LDA !160E,x			;
	EOR #$01				; switch the state from jumping to waiting
	STA !160E,x			;
	LDA #!TimeTillJump		; set the jump timer
	STA !1534,x			;
	BRA Shared			;
TouchedWall:				;
	LDA !15AC,x			;
	BNE Shared			;
	LDA !157C,x			;
	EOR #$01				;
	STA !157C,x			;
	LDA #$08			;
	STA !15AC,x			;
Shared:					;
	JSR UpdatePointer		;
SprLocked:				;
	JSR SubGFX			;
	JMP SubPlayerInteract	;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; graphics routine
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SubGFX:
	%GetDrawInfo()		;
	LDA !1570,x			;
	STA $03				;
	LDA !15F6,x			;
	STA $07				;
	LDA !157C,x			;
	STA $02				;
	LDA !14C8,x			;
	STA $04				;
	LDX #$00				;
.Loop1					;
	PHX					;
	STX $05				;
	TXA					;
	ASL					;
	STA $06				;
	LDA $03				;
	LSR #3				;
	AND #$01			;
	TSB $06				;
	PHY					;
	LDY Data02F103,x		;
	STY $09				;
	LDA [$D5],y			;
	PLY					;
	SEC					;
	SBC $1A				;
	STA $0300|!Base2,y			;
	PHY					;
	LDY $09				;
	INY					;
	LDA [$D5],y			;
	PLY					;
	SEC					;
	SBC $1C				;
	LDX $06				;
	STA $0301|!Base2,y			;
	LDX $06				;
	LDA Tilemap,x			;
	STA $0302|!Base2,y			;
	PLX					;
	LDA $02				;
	LSR					;
	LDA $07				;
	ORA $64				;
	BCS $02				;
	ORA #$40			;
	STA $0303|!Base2,y			;
	INY #4				;
	INX					;
	CPX #$05				;
	BNE .Loop1			;
	LDX $15E9|!Base2			;
	LDY #$02				;
	LDA #$04			;
	JSL $01B7B3|!BankB		;
	RTS					;

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;
; subroutines
;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;------------------------------------------------
; player interaction
;------------------------------------------------

SubPlayerInteract:
	LDA !E4,x			;
	STA $00				;
	LDA !14E0,x			;
	STA $01				;
	REP #$20				;
	LDA $00				;
	SEC					;
	SBC $94				;
	CLC					;
	ADC #$0050			;
	CMP #$00A0			;
	SEP #$20				;
	BCS .Return			;
	LDA !14C8,x			;
	CMP #$08			;
	BNE .Return			;
	LDA #$04			; 5 tiles to interact with
	STA $00				;
	LDY !15EA,x			;
.InteractLoop				;
	LDA $0300|!Base2,y			;
	SEC					;
	SBC $7E				;
	ADC #$0C			;
	CMP #$18			;
	BCC .Label1			;
	JMP .NextTile			;
.Label1					;
	LDA $0301|!Base2,y			;
	SEC					;
	SBC $80				;
	SBC #$10				;
	PHY					;
	LDY $187A|!Base2			;
	BEQ $02				;
	SBC #$10				;
	PLY					;
	CLC					;
	ADC #$0C			;
	CMP #$18			;
	BCC .Label2			;
	JMP .NextTile			;
.Label2					;
	LDA $1490|!Base2			;
	BNE StarKill			;
	LDA !154C,x			;
	ORA $81				;
	BNE .NextTile			;
	LDA #$08			;
	STA !154C,x			;
	LDA $7D				;
	CMP #$08			;
	BMI .HurtPlayer		;
.Label3					;
	LDA $140D|!Base2			;
	BEQ .HurtPlayer		;
	LDA #$02			;
	STA $1DF9|!Base2			;
	JSL $01AA33|!BankB	; set bounce-off speed
	JSL $01AB99|!BankB		; display contact GFX
.Return					;
	RTS					;
.HurtPlayer				;
	JSL $00F5B7|!BankB			;
	RTS					;
.NextTile					;
	INY #4				;
	DEC $00				;
	BMI .Return			;
	JMP .InteractLoop		;
	RTS					;
CapeKill:				;another Alex edit
	LDA #$02			;
	STA !160E,x			;
	LDA !15F6,x			;
	ORA #$80			;
	STA !15F6,x			;
	%cape()				;
	RTS					;Alex edit ends here.
StarKill:					;
	LDA #$02			;
	STA !160E,x			;
	LDA !15F6,x			;
	ORA #$80			;
	STA !15F6,x			;
	%Star()				;
	RTS					;

;------------------------------------------------
; routine for initializing the pointer, i.e. [$D5]
;------------------------------------------------

SetUpPointer:
	TXA
	AND #$03
	TAY
	LDA #$7B
	CLC
	ADC Data02EFEA,y
	STA $D5
	LDA #$9A
	ADC Data02EFEE,y
	STA $D6
if !SA1
	LDA #$41
else
	LDA #$7F
endif
	STA $D7
	RTS
	
;------------------------------------------------
; update the pointer to the positions
;------------------------------------------------

UpdatePointer:
	PHB
	PHX
	REP #$30
	LDA $D5
	CLC
	ADC #$007D
	TAX
	LDA $D5
	CLC
	ADC #$007F
	TAY
	LDA #$007D
if !SA1
	MVP $4141
else
	MVP $7F7F
endif
	SEP #$30
	PLX
	PLB
	LDY #$00
	LDA !E4,x
	STA [$D5],y
	LDA !D8,x
	INY
	STA [$D5],y
	RTS
	
;------------------------------------------------
; ???
;------------------------------------------------

SetSomeYSpeed:
	LDA !1588,x
	BMI .Label1
	LDA #$00
	LDY !15B8,x
	BEQ .Label2
.Label1
	LDA #$18
.Label2
	STA !AA,x
	RTS