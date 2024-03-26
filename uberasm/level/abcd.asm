; Keeps track of password inputs.
; Must be the same free RAM as in the password_correct.asm and password_incorrect.asm blocks.
!FreeRAM = $13E7|!addr

init:
	JSL SimpleHP_init
	
	STZ !FreeRAM	;> Just in case.
	RTL

main:
	JSL SimpleHP_main

	; Debug
	;LDX $0DB3|!addr
	;LDA !FreeRAM
	;STA $0F48|!addr,x

	; Teleport if password is correct.
	LDA !FreeRAM
	CMP #$16
	BNE .return
	REP #$20
	LDA #$00DB
	JSR teleport
.return
	RTL

; From GPS routine.
teleport:
	PHX
	PHY
	PHA
	STZ $88
	SEP #$30
	LDX $95
	PHA
	LDA $5B
	LSR
	PLA
	BCC +
	LDX $97
+
	PLA
	STA $19B8|!addr,x
	PLA
	ORA #$04
	STA $19D8|!addr,x
	LDA #$06
	STA $71
	PLY
	PLX
	RTS
