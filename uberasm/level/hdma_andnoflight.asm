macro call_library(i)
	PHB
	LDA.b #<i>>>16
	PHA
	PLB
	JSL <i>
	PLB
endmacro

init:         	; CURRENTLY HAS THE INIT CODE FOR THE HDMA (MODIFY IF ADDING OTHER FILES)
	JSL start_select_init

	LDA #$17    ;\  BG1, BG2, BG3, OBJ on main screen (TM)
	STA $212C   ; | 
	LDA #$00    ; | 0 on main screen should use windowing. (TMW)
	STA $212E   ;/  
	LDA #$00    ;\  0 on sub screen (TS)
	STA $212D   ; | 
	LDA #$00    ; | 0 on sub screen should use windowing. (TSW)
	STA $212F   ;/  
	LDA #$77    ; BG1, BG2, BG3, OBJ, Backdrop, Half for color math
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
   db $08 : db $20   ; 
   db $07 : db $21   ; 
   db $08 : db $22   ; 
   db $07 : db $23   ; 
   db $07 : db $24   ; 
   db $07 : db $25   ; 
   db $07 : db $26   ; 
   db $08 : db $27   ; 
   db $07 : db $28   ; 
   db $07 : db $29   ; 
   db $07 : db $2A   ; 
   db $08 : db $2B   ; 
   db $07 : db $2C   ; 
   db $07 : db $2D   ; 
   db $07 : db $2E   ; 
   db $08 : db $2F   ; 
   db $07 : db $30   ; 
   db $07 : db $31   ; 
   db $07 : db $32   ; 
   db $07 : db $33   ; 
   db $07 : db $34   ; 
   db $08 : db $35   ; 
   db $07 : db $36   ; 
   db $07 : db $37   ; 
   db $07 : db $38   ; 
   db $08 : db $39   ; 
   db $07 : db $3A   ; 
   db $07 : db $3B   ; 
   db $07 : db $3C   ; 
   db $08 : db $3D   ; 
   db $06 : db $3E   ; 
   db $00            ; 

main:         ; CURRENTLY HAS THE MAIN CODE FROM THE DISABLE FLIGHT FILE
	STZ $149F|!addr

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
