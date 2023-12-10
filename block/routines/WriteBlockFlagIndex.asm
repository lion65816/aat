	incsrc "../FlagMemoryDefines/Defines.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Bit search. This is basically euclidean division
;by 8 to determine what bit and byte to read and
;write. Very useful if you have a table where each
;item is 1 bit large instead of a byte.
;
;Input:
; A (8-bit) = what bit number (a flag), 0-255 ($00-$FF)
; Carry = SET if to set a bit in table, otherwise clear.
;Output:
; -X (8-bit) = What byte in byte-array to check from.
;  Up to X=31 ($1F) due to floor(255/8).
; -Y (8-bit) = what bit number in each byte: 0-7.
;
;Edited to work with my FlagMemory blocks.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PHB				;>Preserve bank
	PHK				;\Switch to current bank
	PLB				;/
	PHY				;>Preserve Y
	PHP				;>Preserve processor flags (we need the carry bit)
	PHA				;>A as input preserved.
	AND.b #%00000111		;>WhatBit = Bitnumber MOD 8
	TAY				;>Place in Y.
	PLA				;>Restore what was originally in the input.
	LSR #3				;>ByteNumber = floor(Bitnumber/8)
	TAX				;>Place in X.
	PLP				;>Restore processor flags.
	BCS ?SetBit
	
	;ClearBit
	LDA ?BitSelectTable,y		;\Force bit to be 0
	EOR.b #%11111111		;|
	AND !Freeram_MemoryFlag,x	;|
	STA !Freeram_MemoryFlag,x	;|
	BRA ?Done			;/
	
	?SetBit
	LDA ?BitSelectTable,y		;\Force bit to be 1
	ORA !Freeram_MemoryFlag,x	;|
	STA !Freeram_MemoryFlag,x	;/
	
	?Done:
	PLY			;>Restore Y
	PLB			;>Restore bank
	RTL
	
	?BitSelectTable:
	db %00000001 ;>Bit 0
	db %00000010 ;>Bit 1
	db %00000100 ;>Bit 2
	db %00001000 ;>Bit 3
	db %00010000 ;>Bit 4
	db %00100000 ;>Bit 5
	db %01000000 ;>Bit 6
	db %10000000 ;>Bit 7