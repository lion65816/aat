

!SlotPointer = $07			;16bit pointer for source GFX
!SlotBank = $09		;bank
!SlotDestination = $05		;VRAM address

!GFXPointer = $02					;Pointer for the graphics
!GFXBank = $04						;Bank for the graphics

!MAXSLOTS = $04		;maximum selected slots
!dsx_buffer = $418000
!SlotsUsed = $66FE			;how many slots have been used
	
?main:
	phy		;preserve OAM index
	pha		;preserve frame
	lda !SlotsUsed	;test if slotsused == maximum allowed
	cmp #!MAXSLOTS
	bne ?+
		
	pla
	ply
	clc
	rtl

?+
	pla		;pop frame
	phx
	rep #$20	;16bit A
	and.w #$00FF	;wipe high
	xba		;<< 8
	lsr		;>> 1 = << 7
	clc
	adc !GFXPointer	;add frame offset	
	sta !SlotPointer	;store to pointer to be used at transfer time
	sep #$20	;8bit store
	lda !GFXBank	;Get data bank
	sta !SlotBank	;store bank to 24bit pointer


	ldx !SlotsUsed		;calculate VRAM address + tile number
	lda.l ?SlotsTable,x	;get tile# in VRAM
	pha		;preserve for eventual pull
	rep #$20
    and #$00FF
    sec 
    sbc #$00C0
    asl #5
    clc 
    adc.w #!dsx_buffer
	sta !SlotDestination	;destination address in the buffer
	sep #$10

;first
	sei 
	ldy.b #%11000100
	sty $2230
	lda !SlotPointer
	sta $2232	;low 16bits
	ldy !SlotBank
	sty $2234	;bank
	lda #$0080
	sta $2238
	lda !SlotDestination
	sta $2235
	ldy.b #(!dsx_buffer>>16)
	sty $2237
	cli

?-	
	ldy $318C
	beq ?-
	ldy #$00
	sty $318C
	sty $2230



;second
	sei 
	ldy.b #%11000100
	sty $2230
	lda !SlotPointer
	clc
	adc #$0200
	sta $2232	;low 16bits
	sta !SlotPointer
	ldy !SlotBank
	sty $2234	;bank
	lda #$0080
	sta $2238
	lda !SlotDestination
	clc 
	adc #$0200
	sta $2235
	sta !SlotDestination
	ldy.b #(!dsx_buffer>>16)
	sty $2237
	cli


?-	
	ldy $318C
	beq ?-
	ldy #$00
	sty $318C
	sty $2230

;third
	sei 
	ldy.b #%11000100
	sty $2230
	lda !SlotPointer
	clc 
	adc #$0200
	sta $2232	;low 16bits
	sta !SlotPointer
	ldy !SlotBank
	sty $2234	;bank
	lda #$0080
	sta $2238
	lda !SlotDestination
	clc 
	adc #$0200
	sta $2235
	sta !SlotDestination
	ldy.b #(!dsx_buffer>>16)
	sty $2237
	cli

?-	
	ldy $318C
	beq ?-
	ldy #$00
	sty $318C
	sty $2230


;fourth
	sei 
	ldy.b #%11000100
	sty $2230
	lda !SlotPointer
	clc 
	adc #$0200
	sta $2232	;low 16bits
	sta !SlotPointer
	ldy !SlotBank
	sty $2234	;bank
	lda #$0080
	sta $2238
	lda !SlotDestination
	clc 
	adc #$0200
	sta $2235
	sta !SlotDestination
	ldy.b #(!dsx_buffer>>16)
	sty $2237
	cli

?-	
	ldy $318C
	beq ?-
	ldy #$00
	sty $318C
	sty $2230

	sep #$20	;8bit A	
	inc !SlotsUsed	;one extra slot has been used

	pla		;return starting tile number
	plx
	ply
	sec
	rtl

?SlotsTable:			;avaliable slots.  Any more transfers and it's overflowing by a dangerous amount.
    db $CC,$C8,$C4,$C0

?destination_table:
	dw !dsx_buffer+$0500
	dw !dsx_buffer+$0400
	dw !dsx_buffer+$0100
	dw !dsx_buffer+$0000
