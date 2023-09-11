load:
	; Enable echo for SFX.
	LDA #$06
	STA $1DFA|!addr
	RTL

;Flashlight effect by Incognito (optimized by Blind Devil, allow effect for other layers by MarioFanGamer)

!Layer = 3	; Which layer to affect (note that layer 1 isn't particularly recommend)

; Determine RAM tables
if !Layer == 1
	!layer_x_next = $1462|!addr
	!layer_y_next = $1464|!addr
	!layer_x_curr = $1A
	!layer_y_curr = $1C
elseif !Layer == 2
	!layer_x_next = $1466|!addr
	!layer_y_next = $1468|!addr
	!layer_x_curr = $1E
	!layer_y_curr = $20
elseif !Layer == 3
	!layer_x_next = $00	; No layer 3 next frame position.
	!layer_y_next = $00
	!layer_x_curr = $22
	!layer_y_curr = $24
elseif !Layer == 4
	assert 1, "Note that layer 4 needs its own tables which are all freeRAM and needs to be provided by yourself."
	!layer_x_next = $00
	!layer_y_next = $00
	!layer_x_curr = $00
	!layer_y_curr = $00
else
	assert 1, "Error, there are only four possibles layers you can chose from on the SNES."
endif

init:
	LDA #$BF&~(1<<(!Layer-1))
	STA $40
	LDA.b #$1F&~(1<<(!Layer-1))
	STA $0D9D|!addr
	STA $212C
	STA $212E
	LDA.b #1<<(!Layer-1)
	STA $0D9E|!addr
	STA $212D
	STA $212F

main:
	LDA $71
	CMP #$09
	BNE +
	RTL
+
	REP #$20
	LDA #$00F8
	SEC
	SBC $7E
if !Layer != 3
	STA !layer_x_next
endif
	STA !layer_x_curr
     
	LDA #$00EC
	SEC
	SBC $80
	CMP #$FF80
	BPL .FL
     
	LDA #$FF80
.FL
if !Layer != 3
	STA !layer_y_next
endif
	STA !layer_y_curr
	SEP #$20
	RTL
