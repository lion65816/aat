main:
	LDA #$01
	STA $18B7|!addr
	
	;Handle "Hey There Everyone!"
	LDA #$84 ; Colour number. This is palette 0, colour 2.
	STA $2121
	LDA #$4D ; Low byte of SNES RGB
	STA $2122 ; Format = -bbbbbgg gggrrrrr
	LDA #$37 ; High byte
	STA $2122
	LDA #$85 ; Colour number. This is palette 0, colour 2.
	STA $2121
	LDA #$EC ; Low byte of SNES RGB
	STA $2122 ; Format = -bbbbbgg gggrrrrr
	LDA #$33 ; High byte
	STA $2122

	RTS
