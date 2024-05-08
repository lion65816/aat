; Cycle through the bonus game music
; based on a free RAM flag.

!track_num = $1F2D|!addr	;> This address saves to SRAM

init:
	LDA !track_num
	BEQ .track1
	CMP #$01
	BEQ .track2
	CMP #$02
	BEQ .track3
	STZ !track_num			;\ Failsafe
	LDA #$8C				;/
	BRA .store
.track1
	INC !track_num
	LDA #$8C
	BRA .store
.track2
	INC !track_num
	LDA #$8D
	BRA .store
.track3
	STZ !track_num
	LDA #$8E
	BRA .store
.store
	STA $1DFB|!addr
	
	STZ $60
	STZ $61
	STZ $62
	STZ $63
	STZ $1493|!addr
	
	RTL
	
main:
	LDA $1479|!addr
	CMP #$03
	BNE +
	LDA #$03
	STA $0DD5|!addr
+	RTL
