!sa1	= 0
!dp	= $0000
!addr	= $0000
!bank	= $800000
!bank8	= $80

if read1($00FFD5) == $23
	sa1rom
	!sa1	= 1
	!dp	= $3000
	!addr	= $6000
	!bank	= $000000
	!bank8	= $00

endif

org $009D6C		; number of total exits (or the number after which we show the *96 graphics) 
	CMP #122		; CHANGE THIS!!! (it's in decimal btw)
	BCC $06
	LDY #$87        ;\ Two tiles for the *96 gfx
	LDA #$88        ;/ Tile number targets GFX28,GFX29 (or whatever you set LG1,LG2 to for the titlescreen level)
	
org $009D7C
	STA $7F8383,x

org $009D86
	autoclean JML Mymain

org $009D96
	LDY #$02

org $009D9B	;disable one of the tiles
	STA $7F8385,x

freedata
Mymain:
	LDY #$FC
	CMP #$80;nobody, NOBODY is EVER going to make 1280 exits. and it'd overflow HexToDec anyways
	BCS .Return
	PHX
	JSL $00974C|!bank
	TXY
	PLX
	.Return
	STA $7F8381,x
	TYA
	BNE +
	LDA #$FC
	+
	STA $7F837F,x
	LDA #$38
	STA $7F8384,x
	JML $009D8C|!bank