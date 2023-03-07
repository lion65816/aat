;;;;;;;;;;;;;;;
; PaletteShift.asm
; Gradually oscillates between two palettes.
; Code by PSI Ninja.
;;;;;;;;;;;;;;;

;;;;;;;;;;;;
; Free RAM ;
;;;;;;;;;;;;

!StartingColorCounter = $18C8|!addr
!ColorCounter = $18C9|!addr
!PaletteFrames = $18CB|!addr

;;;;;;;;;;;
; Defines ;
;;;;;;;;;;;

!PaletteSpeed = $06		;> How many frames to wait before a palette row is updated.

BackgroundColor:		;> Starting from $24C3 (to 2469).
	dw $24A4
	dw $24A6
	dw $2487
	dw $2488
	dw $2469
	dw $2488
	dw $2487
	dw $24A6
	dw $24A4
	dw $24C3

StartingColor:			;> (palette #, color #)
	db $02
	db $02
	db $02
	db $02
	db $02
	db $02
	db $02
	db $02
	db $02
	db $02

PaletteTable:			;> (set 1 = palette 0)
	;> $1462,$3546,$45A9,$520D,$62B1,$7B77
	dw $1042,$3527,$458A,$520E,$66B3,$7B58
	dw $0C41,$3107,$458B,$55F0,$6694,$7F5A
	dw $0821,$3108,$416C,$55F1,$6A95,$7F3B
	dw $0420,$2CE9,$416D,$55D2,$6E77,$7F3C
	dw $0000,$2CC9,$414E,$55D3,$6E78,$7F1D
	dw $0420,$2CE9,$416D,$55D2,$6E77,$7F3C
	dw $0821,$3108,$416C,$55F1,$6A95,$7F3B
	dw $0C41,$3107,$458B,$55F0,$6694,$7F5A
	dw $1042,$3527,$458A,$520E,$66B3,$7B58
	dw $1462,$3546,$45A9,$520D,$62B1,$7B77

;;;;;;;;
; Code ;
;;;;;;;;

init:
	; Various initial settings for flags and starting positions.
	STZ !StartingColorCounter
	STZ !ColorCounter
	STZ !PaletteFrames

	STZ $1B96|!addr			;> Disable the side exit flag that was set in the previous sublevel.
	RTL

main:
	INC !PaletteFrames		;\ Check if we are updating the palettes this frame.
	LDA !PaletteFrames		;|
	CMP #!PaletteSpeed		;| 
	BNE +				;/ If not, then wait for the next frame.
	STZ !PaletteFrames		;\ Otherwise, prepare for the palette uploads. First, reset the palette delay counter.
	LDA !StartingColorCounter	;| Then, get the current index into the StartingColor table.
	CMP #$0A			;| The total number of palette uploads that need to happen.
	BEQ .reset			;| If we finished uploading all palettes, then we start from the beginning again.
	JSR upload_palettes		;| Otherwise, run the palette subroutine.
	INC !StartingColorCounter	;/ Increment the index into the StartingColor table.
+
	RTL
.reset
	STZ !StartingColorCounter
	STZ !ColorCounter
	STZ !PaletteFrames
	RTL

;;;;;;;;;;
; Dynamically change the palette.
; Sources: https://www.smwcentral.net/?p=viewthread&t=105481&page=1&pid=1563356#p1563356
;          https://www.smwcentral.net/?p=viewthread&t=16714 (register $2121)
;;;;;;;;;;

upload_palettes:
	REP #$20
	LDX !StartingColorCounter	;> Load the current index into the StartingColor table (we can also use it for the BackgroundColor table).
	TXA				;\
	ASL				;| Need to double the index value, since we are using dw instead of db.
	TAX				;/
	LDA BackgroundColor,X		;\ Change background color according to the current position in the table.
	STA $0701|!addr			;/
	SEP #$20

	; Upload changes to the current palette. Can only upload to CGRAM once per frame.
	LDX !StartingColorCounter	;> Load the current index into the StartingColor table.
	LDA #$0C			;\ $0682: number of bytes (=number of colors * 2) (12 bytes)
	STA $0682|!addr			;/
	LDA StartingColor,X		;\ $0683: starting color
	STA $0683|!addr			;/
	REP #$30

	LDY #$0000
-
	CPY #$000C			;\
	BEQ +				;| Loop over the current palette row, adding one color at a time.
	LDX !ColorCounter		;|
	LDA PaletteTable,X		;| End the loop once all 6 colors in the palette row have been added.
	STA $0684|!addr,Y		;| Note that the color counter is incremented by 2, since we are using dw instead of db.
	INC !ColorCounter		;|
	INC !ColorCounter		;|
	INY #2				;|
	BRA -				;/
+
	SEP #$30
	STZ $0690			;> 00 byte to mark the end of the color data
	STZ $0680|!addr			;> $0680 = 0: upload from $0682

	RTS
