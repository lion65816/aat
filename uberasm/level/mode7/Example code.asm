; The following code tells the game to go into Mode 7 and then uploads an interleaved tilemap.
;
; NOTE 1:	As you probably know, the SNES's VRAM contains graphics and tilemaps for the different layers.
;	They are normally separated, but in Mode 7, all even bytes are graphics-related and all odd bytes are tilemap-related (Or maybe it's the opposite I dunno :P)
;	Long story short, the VRAM constantly alternates between graphics data and tilemap data.
;	You can create this sort of tilemap with Vitor Vilela's SNESGFX program.
;	Please note that you must not use more than 256 different 8x8 tiles or things might get sorta buggy or glitchy.
; NOTE 2:	It's also recommended to actually use only 127 different colors instead of all 255 because it will overwrite sprite palettes, beginning with Mario's.
; NOTE 3:	If you're using UberASMTool, take advantage of the prot_file macro to insert your interleaved tilemap into your ROM without problems.
; NOTE 4:	This code is already SA-1 compatible as it uses direct page adressing ($XX adresses) and SNES registers ($2000+).

; === ExE Boss’s Changes ===
; I’ve modified the code so that you can create the Mode 7 graphics and tilemap separately by doing two consecutive
; DMA uploads instead, one to upload the graphics and one to upload the tilemap.
;
; This allows storing the Graphics and Tilemap seperately, making editing easier,
; since you can now use Mzuenni’s Graphics Editor (https://www.smwcentral.net/?p=section&a=details&id=15530),
; which supports the SNES 8BPP and Mode 7 formats to edit the graphics.

incsrc ../easy_mode7_conf.asm	;> Load configuration

math	pri	on	;\ Asar defaults to Xkas settings instead
math	round	off	;/ of proper math rules, this fixes that.

Init: {
	LDA #$07	;\ Set BG Mode to 7.
;	ORA #$08	;|> Uncomment this line to enable the Layer 3 status bar (note that the Mode 7 background will get cut off if you try to move it behind the status bar)
	STA $3E	;/

	REP #$10
	LDA.b #GFX>>$10	;\ Upload GFX
	LDX.w #GFX	;|
	LDY.w #$1	;|
	JSL !UploadMode7gfxSubroutine|!bank	;/
	LDA.b #Tilemap>>$10	;\ Upload Tilemap
	LDX.w #Tilemap	;|
	LDY.w #$2	;|
	JSL !UploadMode7gfxSubroutine|!bank	;/
	SEP #$10

	REP #$20
	LDA #$0180 : STA $2A	;\ Set effect center to tilemap center
	LDA #$0180 : STA $2C	;/
	STZ $36	;> Set angle to 0°
	LDA #$8080 : STA $38	;> Set size to 25% so the whole tilemap is visible
	LDA #$0180 : STA $3A	;\ Set layer position to tilemap center
	LDA #$0180 : STA $3C	;/
	SEP #$20

	RTL
}

Main: {
	LDA $13D4|!addr	; If game is paused...
	BNE .end	; ...skip this.
	REP #$20
	INC $36	; Increment angle
	SEP #$20

.end:
	RTL
}

%prot_file("TestFile.gfx.bin",	GFX)
%prot_file("TestFile.tilemap.bin",	Tilemap)
