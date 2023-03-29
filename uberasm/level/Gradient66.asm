; To be upplied to a level using UberASMTool.

init: 
	REP #$20
	LDA #$3200
	STA $4330
	LDA #.RedTable
	STA $4332
	LDY.b #.RedTable>>16
	STY $4334
	LDA #$3200
	STA $4340
	LDA #.GreenTable
	STA $4342
	LDY.b #.GreenTable>>16
	STY $4344
	LDA #$3200
	STA $4350
	LDA #.BlueTable
	STA $4352
	LDY.b #.BlueTable>>16
	STY $4354
	SEP #$20
	LDA #$38
	TSB $0D9F|!addr
	RTL

.RedTable:           ; 
   db $0A : db $38   ; 
   db $24 : db $39   ; 
   db $25 : db $3A   ; 
   db $21 : db $3B   ; 
   db $25 : db $3C   ; 
   db $21 : db $3D   ; 
   db $25 : db $3E   ; 
   db $01 : db $3F   ; 
   db $00            ; 

.GreenTable:         ; 
   db $08 : db $40   ; 
   db $07 : db $41   ; 
   db $08 : db $42   ; 
   db $07 : db $43   ; 
   db $07 : db $44   ; 
   db $07 : db $45   ; 
   db $07 : db $46   ; 
   db $08 : db $47   ; 
   db $07 : db $48   ; 
   db $07 : db $49   ; 
   db $07 : db $4A   ; 
   db $08 : db $4B   ; 
   db $07 : db $4C   ; 
   db $07 : db $4D   ; 
   db $07 : db $4E   ; 
   db $08 : db $4F   ; 
   db $07 : db $50   ; 
   db $07 : db $51   ; 
   db $07 : db $52   ; 
   db $07 : db $53   ; 
   db $07 : db $54   ; 
   db $08 : db $55   ; 
   db $07 : db $56   ; 
   db $07 : db $57   ; 
   db $07 : db $58   ; 
   db $08 : db $59   ; 
   db $07 : db $5A   ; 
   db $07 : db $5B   ; 
   db $07 : db $5C   ; 
   db $08 : db $5D   ; 
   db $06 : db $5E   ; 
   db $00            ; 

.BlueTable:          ; 
   db $07 : db $87   ; 
   db $10 : db $86   ; 
   db $0E : db $85   ; 
   db $10 : db $84   ; 
   db $10 : db $83   ; 
   db $10 : db $82   ; 
   db $0E : db $81   ; 
   db $1D : db $80   ; 
   db $0F : db $81   ; 
   db $10 : db $82   ; 
   db $10 : db $83   ; 
   db $0F : db $84   ; 
   db $0F : db $85   ; 
   db $10 : db $86   ; 
   db $03 : db $87   ; 
   db $00            ; 
