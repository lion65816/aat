; Separate Luigi Graphics v3
; By Smallhacker
; Update by DiscoMan
; Asar port by Snowshoe
; SA1 support and overworld reload fix by Bensalot

; Mario and Luigi graphics are stored separately in the files
; "Mario.bin" and "Luigi.bin". The graphics in GFX32 are no longer used.
; Make sure "Mario.bin" or "Luigi.bin" are around 24 KB in size,
; the same size as GFX32.bin, to avoid taking up freespace.

; The hack must have been edited by Lunar Magic before applying this patch.
; If you haven't used Lunar Magic, open your ROM, extract GFX, insert GFX
; and save a level.

; MUST BE AN UNUSED RAM ADDRESS
; (Default address: "Unused" part of stack)
!currentGfx = $7E010F

; Replacement GFX files for Luigi
!gfx00Luigi = #$00 ; Extended tiles
!gfx22Luigi = #$22 ; Blushing graphics (Small)
!gfx24Luigi = #$24 ; Blushing graphics (Super)

header
if read1($00FFD5) == $23
sa1rom
!addr = $6000
else
lorom
!addr = $0000
endif

org $00AA6B
	autoclean JSL Gfx

org $049DD6
	autoclean JSL SwitchPlayer

org $00B8A4
	autoclean JSL Load1st
	RTS

org $009AA4
	autoclean JSL Title

org $00A99B
	autoclean JSL Setup

org $00A1DA
	autoclean JML Select
	
org $00A0B9
	autoclean JML Select3

freecode
prot MarioGfx,LuigiGfx

Select:

JSR Change		;\ Don't change this, it will upload the graphics every frame.
JSR Upload		;/ Scroll Down to see the Change:

LDA $1426|!addr		;\
BEQ Select2		;| Restore Codes
JML $00A1DF		;|
				;|
Select2:		;|
JML $00A1E4	;/

SwitchPlayer:
	STA $0DB3|!addr
	TAX
	JSR Change
	JSR Upload
	RTL

Setup:
	LDA #$FF
	STA !currentGfx
	LDA #$03
	STA $0F
	RTL

Load1st:
	SEP #$30
	JSR Change
	JSR Upload
	RTL

Title:
	JSR Change
	JSR Upload
	JML $04F675
	
Select3:
	JSR Change
	JSR Upload
GoBack:
    STZ $0DDA|!addr
    LDX $0DB3|!addr
	JML $00A0BF

Change:
	LDA $0DB3|!addr		;\
	CMP #$00		;| See this? You can change this to whatever you want.
	BEQ Mario		;|
					;|
	LDA $0DB3|!addr		;|
	CMP #$01		;|
	BEQ Luigi		;/
	RTS

Luigi:
	LDA.b #LuigiGfx
	STA $4322
	LDA.b #LuigiGfx>>8
	STA $4323
	LDA.b #LuigiGfx>>16
	STA $4324
	LDA #$01
	RTS
	;BRA Upload
Mario:
	LDA.b #MarioGfx
	STA $4322
	LDA.b #MarioGfx>>8
	STA $4323
	LDA.b #MarioGfx>>16
;	LDA.b #MarioGfx>>16
	STA $4324
	LDA #$00
	RTS

Upload:
	CMP !currentGfx
	BEQ Return
	STA !currentGfx
	LDA #$00
	STA $4325
	LDA #$5D
	STA $4326
	LDA #$00
	STA $2181
	LDA #$20
	STA $2182
	LDA #$7E
	STA $2183
	LDA #$80
	STA $4321
	LDA #$00
	STA $4320
	LDA #$04
	STA $420B

Return:
	RTS

Gfx:
	LDA !currentGfx
	CMP #$01
	BNE GfxGo
	CPY #$00
	BEQ Gfx00
	CPY #$22
	BEQ Gfx22
	CPY #$24
	BEQ Gfx24

GfxGo:
	if read3($0FF160) == $FFFFFF
	JML $00BA28
	else
	JML $0FF160
	endif
Gfx00:
	LDY !gfx00Luigi
	BRA GfxGo
Gfx22:
	LDY !gfx22Luigi
	BRA GfxGo
Gfx24:
	LDY !gfx24Luigi
	BRA GfxGo
	


; Point these to the start of two empty banks

freecode align

MarioGfx:
	incbin Mario.bin

freecode align

LuigiGfx:
	incbin Luigi.bin