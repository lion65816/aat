
; Sprite tile to use for the masking effect.
; It needs to be the same shape as the used block,
; and the same shape as the note block if you are using the note block items,
; but otherwise it doesn't matter what it looks like.
!maskTile = $2e


!dp = $0000
!addr = $0000
!sa1 = 0
!gsu = 0
!15ea = $15ea
!1540 = $1540
!151c = $151c
!14e0 = $14e0
!14d4 = $14d4
!d8 = $d8
!e4 = $e4

if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!gsu = 1
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
	!15ea = $33A2
	!1540 = $32C6
	!151c = $3284
	!14e0 = $326E
	!14d4 = $3258
	!d8 = $3216
	!e4 = $322C
endif

org $01c39c
	autoclean jsl DrawBlockTile

freecode
DrawBlockTile:
	; wait until the block is done bouncing to draw the mask
	lda !1540,x : cmp #$36 : bcs .end
	; use priority if we are the changing item
	; (that has to go behind its glass block all the time,
	;  so it's hard to make it work)
	lda !151c,x : bne .changingItem

	ldy !15ea,x

	; X position of mask - same as item
	lda !14e0,x : xba : lda !e4,x
	rep #$20
	sec : sbc $1a
	cmp #$fff0 : bcs +
	cmp #$0100 : bcs .dont
+	sep #$20
	sta !addr|$0300,y

	; size and x position hi bit to $00
	lda #$02
	adc #$00
	sta $00

	; Y position of mask - aligned to the block containing the
	; bottom of the item
	lda !14d4,x : xba : lda !d8,x
	rep #$20
	clc : adc #$000f
	and #$fff0
	dec
	sec : sbc $1c
	cmp #$fff0 : bcs +
	cmp #$00e0 : bcs .dont
+	sep #$20
	sta !addr|$0301,y

	; tile and properties
	lda.b #!maskTile : sta !addr|$0302,y
	lda.b #((!maskTile)>>8)&1 : sta !addr|$0303,y

	; size and x position hi bit to size/hi bit table
	tya : lsr #2 : tay
	lda $00 : sta !addr|$0460,y

	; make the item draw its tile after the mask,
	; by moving its oam slot one tile forward
	lda !15ea,x : adc #$04 : sta !15ea,x

.dont:
	sep #$20
.end:
	rtl

.changingItem:
	lda #$10 : sta $64
	rtl
