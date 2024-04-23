; Note that since global code is a single file, all code below should return with RTS.

; Free RAM addresses. 
!CustomPalette = $1477|!addr	;> Activate certain custom palettes. Needed so that palettes don't change while dying or reading messages.
!PaletteUsed = $18B7|!addr		;> Needs to be the same address used in UberASM that uploads custom player palettes.

load:
	STZ !CustomPalette
	RTS

init:
	RTS

main:
	;Reset Lives after Continuing
	LDA $13C9|!addr
	BEQ +++
	LDA $0DB4|!addr
	BNE +
	LDA #$0E
	STA $0DB4|!addr
+	LDA $0DB5|!addr
	BNE ++
	LDA #$0E
	STA $0DB5|!addr
++	LDA $0DBE|!addr
	;BNE +++
	LDA #$0E
	STA $0DBE|!addr	

+++	JSL mario_exgfx_main

	; Handle custom palette for intro stage.
	LDA !CustomPalette
	CMP #$01
	BNE +
	JSL GrayscalePalette_main
+
	; Handle custom palette for Level 125 secret path.
	CMP #$02
	BNE +
	JSL InvertPalette_main
+
	; Handle custom palette for Level 121 if the player is Iris.
	CMP #$03
	BNE +
	JSL BlueIrisPalette_main
+
	; Skip if a level is already uploading custom player palettes.
	LDA !PaletteUsed
	BNE .Return
	
	LDA $0100|!addr
	CMP #$01
	BEQ .Test
	CMP #$02
	BEQ .Test

	; Handle Iris palette with ExAnimation custom trigger.
	LDA $0DB3|!addr 
	CMP #$00
	BNE .Iris
	

.Demo
	; Prevents Iris' eye colors from loading prematurely when switching to her on the overworld.
	;LDA $0100|!addr
	;CMP #$0B
	;BEQ .IrisPal
.DemoPal
	LDA #$83 ; Colour number. This is palette 0, colour 2.
	STA $2121
	LDA #$54 ; Low byte of SNES RGB
	STA $2122 ; Format = -bbbbbgg gggrrrrr
	LDA #$00 ; High byte
	STA $2122
	LDA #$84 ; Colour number. This is palette 0, colour 2.
	STA $2121
	LDA #$3F ; Low byte of SNES RGB
	STA $2122 ; Format = -bbbbbgg gggrrrrr
	LDA #$02 ; High byte
	STA $2122
	LDA #$85 ; Colour number. This is palette 0, colour 2.
	STA $2121
	LDA #$3F ; Low byte of SNES RGB
	STA $2122 ; Format = -bbbbbgg gggrrrrr
	LDA #$0F ; High byte
	STA $2122
	JML .Return

.Iris
	; Prevents Demo's eye colors from loading prematurely when switching to her on the overworld.
	;LDA $0100|!addr
	;CMP #$0B
	;BEQ .DemoPal
.IrisPal
	LDA #$83 ; Colour number. This is palette 0, colour 2.
	STA $2121
	LDA #$8E ; Low byte of SNES RGB
	STA $2122 ; Format = -bbbbbgg gggrrrrr
	LDA #$4C ; High byte
	STA $2122
	LDA #$84 ; Colour number. This is palette 0, colour 2.
	STA $2121
	LDA #$B3 ; Low byte of SNES RGB
	STA $2122 ; Format = -bbbbbgg gggrrrrr
	LDA #$59 ; High byte
	STA $2122
	LDA #$85 ; Colour number. This is palette 0, colour 2.
	STA $2121
	LDA #$99 ; Low byte of SNES RGB
	STA $2122 ; Format = -bbbbbgg gggrrrrr
	LDA #$72 ; High byte
	STA $2122
	JML .Return

.Return
	RTS
	
.Test
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
	REP #$20
	LDA #$14A5
	STA $0701|!addr
	SEP #$20
	RTS
