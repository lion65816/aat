; Needs to be the same free RAM address as in RequestRetry.asm.
!RetryRequested = $18D8|!addr

init:                         ; Code to be inserted INIT
   	REP #$20                  ;\  16 bit mode
   	LDA #$0000                ; | 
   	STA $4330                 ; | 
   	LDA #.BrightTable         ; | load high and low byte of table address
   	STA $4332                 ; | 
   	SEP #$20                  ; | back to 8 bit mode
   	LDA.b #.BrightTable>>16   ; | load bank byte of table address
   	STA $4334                 ; | 
   	LDA #$08                  ; | 
   	TSB $0D9F|!addr           ; | enable HDMA channel 3
	JSL RequestRetry_init
	RTL
	
.BrightTable:                 ; 
   db $80 : db $09            ; 
   db $80 : db $09            ; 
   db $00

main:
	; Exit out of SPECIAL rooms with a special button combination (A+X+L+R).
	LDA #%11110000 : STA $00
	JSL RequestRetry_main
	LDA !RetryRequested
	BNE .return

	; Otherwise, the SPECIAL rooms will reload upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
.return
	RTL
