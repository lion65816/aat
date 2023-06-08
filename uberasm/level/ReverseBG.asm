;Reverse BG - A Jimmy Production

;This lets your background move in reverse.

main:
STZ $1413|!addr
	REP #$20
	LDA $1462|!addr
	EOR #$FFFF
	LSR A
	STA $1466|!addr
	SEP #$20
RTL


load:
    lda #$01
    sta $13E6|!addr
    rtl
    
