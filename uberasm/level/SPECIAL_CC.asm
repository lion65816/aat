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
	JSL start_select_init
	JSL MultipersonReset_init
	RTL
	
.BrightTable:                 ; 
   db $80 : db $09            ; 
   db $80 : db $09            ; 
   db $00

main:
	JSL start_select_main

	; Reload the room upon death.
	LDA $010B|!addr
	STA $0C
	LDA $010C|!addr
	ORA #$04
	STA $0D
	JSL MultipersonReset_main
.return
	RTL
