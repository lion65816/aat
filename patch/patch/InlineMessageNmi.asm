; Same as in the patch
!MessageNumber	= $1426|!addr	; Only used if you use Retry
!MessageState	= $1B88|!addr
!MessageTimer	= $1B89|!addr

!Layer3Buff = $7FA600			; 1024 bytes since we want to restore it

!UseRetry = 0					; If set to 1: Fixes incompatibilities with Retry.

nmi:
	PHB
	PHK
	PLB
	if !UseRetry
		LDA !MessageNumber
		CMP #$04
		BCS .Return
	endif
	LDX !MessageState
	JSR (MessageStates,x)
.Return
	PLB
RTL

MessageStates:
dw .Return
dw .BackupLayer3
dw .Return
dw .Return
dw .RestoreLayer3
dw .Return

.BackupLayer3:
	JSR Initialisation
	BCC ..TwoReads
	
	LDA #$0280
	STA $02
	JSR ReadLayer3
	SEP #$20
RTS

..TwoReads
	JSR ReadLayer3
	LDA $00
	AND #~$03E0
	EOR #$0800
	STA $00
	LDA $04
	CLC : ADC $02
	STA $04
	LDA #$0280
	SEC : SBC $02
	STA $02
	JSR ReadLayer3
	SEP #$20
.Return
RTS

.RestoreLayer3:
	JSR Initialisation
	BCC ..TwoWrites

	LDA #$0280
	STA $02
	JSR WriteLayer3
	SEP #$20
RTS

..TwoWrites
	JSR WriteLayer3
	LDA $00
	AND #~$03E0
	EOR #$0800
	STA $00
	LDA $04
	CLC : ADC $02
	STA $04
	LDA #$0280
	SEC : SBC $02
	STA $02
	JSR WriteLayer3
	SEP #$20
RTS

; Initialises the read/write by getting the VRAM address as well as set the state.
Initialisation:
	LDA #$80
	STA $2115
	REP #$30
	LDA #!Layer3Buff
	STA $04
	LDY #$0000
	LDA $24
	CLC : ADC #$0034	; 40 pixels to the bottom
	BIT #$0100
	BEQ +
	INY #2
+	ASL #2
	AND #$03E0
	PHA
	STA $00
	TYA
	XBA
	ASL #2				; Y << 10
	ORA $00
	ORA #$5000
	STA $00
	PLA
	ASL
	EOR #$07FF
	INC
	STA $02
	SEP #$10
	LDY !MessageTimer
	BEQ .leftHalf
	LDA $00
	EOR #$0400
	STA $00
	LDA $04
	CLC : ADC #$0280
	STA $04
	LDA !MessageState
	INC
	INC
	STA !MessageState
.leftHalf
	LDY #$50
	STY !MessageTimer
	LDA $02
	CMP #$0280
RTS

; Reads a subtilemap row
; Input:
;  $00: VRAM address to read
;  $02: Rows to upload * 2
;  $04: Pointer to buffer
ReadLayer3:
	LDA $00
	STA $2116
	LDA $2139
	LDA #$3981
	STA $4300
	LDA $04
	STA $4302
	LDY.b #!Layer3Buff>>16
	STY $4304
	LDA $02
	STA $4305
	LDY #$01
	STY $420B
RTS

; Writes to a subtilemap row
; Input:
;  $00: VRAM address to write
;  $02: Rows to upload * 2
;  $04: Pointer to buffer
WriteLayer3:
	LDA $00
	STA $2116
	LDA #$1801
	STA $4300
	LDA $04
	STA $4302
	LDY.b #!Layer3Buff>>16
	STY $4304
	LDA $02
	STA $4305
	LDY #$01
	STY $420B
RTS
