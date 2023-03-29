; To be upplied to a level using UberASMTool.

init:          ; 
   LDA #$17    ;\  BG1, BG2, BG3, OBJ on main screen (TM)
   STA $212C   ; | 
   LDA #$00    ; | 0 on main screen should use windowing. (TMW)
   STA $212E   ;/  
   LDA #$00    ;\  0 on sub screen (TS)
   STA $212D   ; | 
   LDA #$00    ; | 0 on sub screen should use windowing. (TSW)
   STA $212F   ;/  
   LDA #$37    ; BG1, BG2, BG3, OBJ, Backdrop for color math
   STA $40     ;/  mirror of $2131

	REP #$20
	LDA #$3200
	STA $4330
	LDA #.RedTable
	STA $4332
	LDY.b #.RedTable>>16
	STY $4334
	SEP #$20
	LDA #$08
	TSB $0D9F|!addr
	RTL

.RedTable:           ; 
   db $11 : db $20   ; 
   db $10 : db $21   ; 
   db $10 : db $22   ; 
   db $0F : db $23   ; 
   db $0F : db $24   ; 
   db $10 : db $25   ; 
   db $10 : db $26   ; 
   db $10 : db $27   ; 
   db $10 : db $28   ; 
   db $10 : db $29   ; 
   db $10 : db $2A   ; 
   db $0F : db $2B   ; 
   db $0F : db $2C   ; 
   db $10 : db $2D   ; 
   db $03 : db $2E   ; 
   db $00            ; 
