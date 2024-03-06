; Note that since global code is a single file, all code below should return with RTS.

; Free RAM. Needs to be the same address used in UberASM that uploads custom player palettes.
!PaletteUsed = $18B7|!addr

load:
	STZ $1477|!addr
	rts
init:
	rts
main:
	jsl mario_exgfx_main

	; Skip if a level is already uploading custom player palettes.
	LDA !PaletteUsed
	BNE .Return

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
	

.Return
	LDA $1477|!addr
	CMP #$01
	BNE +
	JSL GrayscalePalette_main
	+
	CMP #$02
	BNE ++
	JSL InvertPalette_main
	++
	rts
;nmi:
;	rts
