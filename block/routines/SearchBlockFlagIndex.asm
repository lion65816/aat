;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Functions to make it easy to to list the coordinates into $C800 index.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function GetC800IndexHoriziLvl(RAM13D7, XPos, YPos) = (RAM13D7*(XPos/16))+(YPos*16)+(XPos%16)
function GetC800IndexVertiLvl(XPos, YPos) = (512*(YPos/16))+(256*(XPos/16))+((YPos%16)*16)+(XPos%16)
;Make sure you have [math round on] to prevent unexpected rounded numbers.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This routine takes the current block $C800 index (first convert its XY coordinate into $C800 index)
;compares it to a list of $C800 indexes determine what flag number the block is assigned to.
;
;The reason of having a list of indexes instead of XY coordinates is because each XY coordinate takes up a total of 4
;bytes (2 bytes for each axis, X and Y) per flag, while $C800_index takes only 2 bytes per flag.
;
;Input:
;-$00-$01: The $C800 index (Execute [BlkCoords2C800Index.asm] subroutine first)
;-[$010B|!addr] to [$010C|!addr]: Current level number. No need to write on this since it is pre-written.
;
;Output:
;-A (16-bit): the flag number, times 2 (so if it is flag 3, then A = $0006). With 16 (maximum) group-256s, A would range
; from 0 to 4094 ($0000 to $0FFE).
; Recommended to add a check X=$FFFE as a failsafe in case of a bug could happen or if you accidentally placed a block
; at a location that isn't assigned.
;
;CTRL+F these to insta-jump to a specific table:
; GetFlagNumberLevelIndexStart
; GetFlagNumberLayerProcessingStart
; GetFlagNumberC800IndexStart
;
;Note: as an easy way to work with tables here, use the javascript found in [Readme_files/JS_MemoryCalculator.html],
;and it will generate placeholder tables for you after the HTML table for you to copy and paste here.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PHX							;>This is needed if you are going to have sprites interacting with this block.
	PHY
	PHB							;>Preserve bank
	PHK							;\Adjust bank for any $xxxx,y
	PLB							;/
	REP #$30						;>16-bit XY, thankfully, with the number of group-128 at max, not even close to 32768 ($8000) on the index for flag number.
	LDX.w #(?GetFlagNumberC800IndexEnd-?GetFlagNumberC800IndexStart)-2 ;>Start at the last index.
	LDY.w #((?GetFlagNumberC800IndexEnd-?GetFlagNumberC800IndexStart)/2)-1
	-
	LDA $010B|!addr						;>Current level number
	CMP.l ?GetFlagNumberLevelIndexStart,x			;\If level number not match, next
	BNE ++							;/
	SEP #$20
	LDA $1933|!addr						;\If layer 1 or 2 does not match, next
	CMP.w ?GetFlagNumberLayerProcessingStart,y		;|
	REP #$20
	BNE ++							;/
	LDA $00							;\If C800 index number not match, next
	CMP.l ?GetFlagNumberC800IndexStart,x			;/
	BNE ++
	BRA +							;>Match found.
	++
	DEY
	DEX #2							;>Next item.
	BPL -							;>Loop till X=$FFFE (no match found), thankfully, 255*2 = 510 ($01FE) is less than 32768 ($8000).
	+
	TXA							;>Transfer indexCount*2 to A
	SEP #$30
	PLB							;>Restore bank.
	PLY
	PLX							;>Restore potential sprite index.
	RTL
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of level numbers. This is essentially what level the flags are in.
;
;Note: you CAN have duplicate level numbers here if you have multiple flags
;in a single level.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?GetFlagNumberLevelIndexStart:
	dw $01EB		;>Flag $0 (Group $0) -> LM's CM16 flag $0
	dw $01EB		;>Flag $1 (Group $0) -> LM's CM16 flag $1
	dw $01EB		;>Flag $2 (Group $0) -> LM's CM16 flag $2
	dw $01EB		;>Flag $3 (Group $0) -> LM's CM16 flag $3
	dw $01EB		;>Flag $4 (Group $0) -> LM's CM16 flag $4
	dw $01EC		;>Flag $5 (Group $0) -> LM's CM16 flag $5
	dw $01EC		;>Flag $6 (Group $0) -> LM's CM16 flag $6
	dw $01EC		;>Flag $7 (Group $0) -> LM's CM16 flag $7
	dw $01EC		;>Flag $8 (Group $0) -> LM's CM16 flag $8
	dw $01ED		;>Flag $9 (Group $0) -> LM's CM16 flag $9
	dw $01ED		;>Flag $A (Group $0) -> LM's CM16 flag $A
	dw $01ED		;>Flag $B (Group $0) -> LM's CM16 flag $B
	dw $01EE		;>Flag $C (Group $0) -> LM's CM16 flag $C
	dw $01EE		;>Flag $D (Group $0) -> LM's CM16 flag $D
	dw $01EF		;>Flag $E (Group $0) -> LM's CM16 flag $E
	dw $01E2		;>Flag $F (Group $0) -> LM's CM16 flag $F
	dw $FFFF		;>Flag $10 (Group $0) -> LM's CM16 flag $10
	dw $FFFF		;>Flag $11 (Group $0) -> LM's CM16 flag $11
	dw $FFFF		;>Flag $12 (Group $0) -> LM's CM16 flag $12
	dw $FFFF		;>Flag $13 (Group $0) -> LM's CM16 flag $13
	dw $FFFF		;>Flag $14 (Group $0) -> LM's CM16 flag $14
	dw $FFFF		;>Flag $15 (Group $0) -> LM's CM16 flag $15
	dw $FFFF		;>Flag $16 (Group $0) -> LM's CM16 flag $16
	dw $FFFF		;>Flag $17 (Group $0) -> LM's CM16 flag $17
	dw $FFFF		;>Flag $18 (Group $0) -> LM's CM16 flag $18
	dw $FFFF		;>Flag $19 (Group $0) -> LM's CM16 flag $19
	dw $FFFF		;>Flag $1A (Group $0) -> LM's CM16 flag $1A
	dw $FFFF		;>Flag $1B (Group $0) -> LM's CM16 flag $1B
	dw $FFFF		;>Flag $1C (Group $0) -> LM's CM16 flag $1C
	dw $FFFF		;>Flag $1D (Group $0) -> LM's CM16 flag $1D
	dw $FFFF		;>Flag $1E (Group $0) -> LM's CM16 flag $1E
	dw $FFFF		;>Flag $1F (Group $0) -> LM's CM16 flag $1F
	dw $FFFF		;>Flag $20 (Group $0) -> LM's CM16 flag $20
	dw $FFFF		;>Flag $21 (Group $0) -> LM's CM16 flag $21
	dw $FFFF		;>Flag $22 (Group $0) -> LM's CM16 flag $22
	dw $FFFF		;>Flag $23 (Group $0) -> LM's CM16 flag $23
	dw $FFFF		;>Flag $24 (Group $0) -> LM's CM16 flag $24
	dw $FFFF		;>Flag $25 (Group $0) -> LM's CM16 flag $25
	dw $FFFF		;>Flag $26 (Group $0) -> LM's CM16 flag $26
	dw $FFFF		;>Flag $27 (Group $0) -> LM's CM16 flag $27
	dw $FFFF		;>Flag $28 (Group $0) -> LM's CM16 flag $28
	dw $FFFF		;>Flag $29 (Group $0) -> LM's CM16 flag $29
	dw $FFFF		;>Flag $2A (Group $0) -> LM's CM16 flag $2A
	dw $FFFF		;>Flag $2B (Group $0) -> LM's CM16 flag $2B
	dw $FFFF		;>Flag $2C (Group $0) -> LM's CM16 flag $2C
	dw $FFFF		;>Flag $2D (Group $0) -> LM's CM16 flag $2D
	dw $FFFF		;>Flag $2E (Group $0) -> LM's CM16 flag $2E
	dw $FFFF		;>Flag $2F (Group $0) -> LM's CM16 flag $2F
	dw $FFFF		;>Flag $30 (Group $0) -> LM's CM16 flag $30
	dw $FFFF		;>Flag $31 (Group $0) -> LM's CM16 flag $31
	dw $FFFF		;>Flag $32 (Group $0) -> LM's CM16 flag $32
	dw $FFFF		;>Flag $33 (Group $0) -> LM's CM16 flag $33
	dw $FFFF		;>Flag $34 (Group $0) -> LM's CM16 flag $34
	dw $FFFF		;>Flag $35 (Group $0) -> LM's CM16 flag $35
	dw $FFFF		;>Flag $36 (Group $0) -> LM's CM16 flag $36
	dw $FFFF		;>Flag $37 (Group $0) -> LM's CM16 flag $37
	dw $FFFF		;>Flag $38 (Group $0) -> LM's CM16 flag $38
	dw $FFFF		;>Flag $39 (Group $0) -> LM's CM16 flag $39
	dw $FFFF		;>Flag $3A (Group $0) -> LM's CM16 flag $3A
	dw $FFFF		;>Flag $3B (Group $0) -> LM's CM16 flag $3B
	dw $FFFF		;>Flag $3C (Group $0) -> LM's CM16 flag $3C
	dw $FFFF		;>Flag $3D (Group $0) -> LM's CM16 flag $3D
	dw $FFFF		;>Flag $3E (Group $0) -> LM's CM16 flag $3E
	dw $FFFF		;>Flag $3F (Group $0) -> LM's CM16 flag $3F
	dw $FFFF		;>Flag $40 (Group $0) -> LM's CM16 flag $40
	dw $FFFF		;>Flag $41 (Group $0) -> LM's CM16 flag $41
	dw $FFFF		;>Flag $42 (Group $0) -> LM's CM16 flag $42
	dw $FFFF		;>Flag $43 (Group $0) -> LM's CM16 flag $43
	dw $FFFF		;>Flag $44 (Group $0) -> LM's CM16 flag $44
	dw $FFFF		;>Flag $45 (Group $0) -> LM's CM16 flag $45
	dw $FFFF		;>Flag $46 (Group $0) -> LM's CM16 flag $46
	dw $FFFF		;>Flag $47 (Group $0) -> LM's CM16 flag $47
	dw $FFFF		;>Flag $48 (Group $0) -> LM's CM16 flag $48
	dw $FFFF		;>Flag $49 (Group $0) -> LM's CM16 flag $49
	dw $FFFF		;>Flag $4A (Group $0) -> LM's CM16 flag $4A
	dw $FFFF		;>Flag $4B (Group $0) -> LM's CM16 flag $4B
	dw $FFFF		;>Flag $4C (Group $0) -> LM's CM16 flag $4C
	dw $FFFF		;>Flag $4D (Group $0) -> LM's CM16 flag $4D
	dw $FFFF		;>Flag $4E (Group $0) -> LM's CM16 flag $4E
	dw $FFFF		;>Flag $4F (Group $0) -> LM's CM16 flag $4F
	dw $FFFF		;>Flag $50 (Group $0) -> LM's CM16 flag $50
	dw $FFFF		;>Flag $51 (Group $0) -> LM's CM16 flag $51
	dw $FFFF		;>Flag $52 (Group $0) -> LM's CM16 flag $52
	dw $FFFF		;>Flag $53 (Group $0) -> LM's CM16 flag $53
	dw $FFFF		;>Flag $54 (Group $0) -> LM's CM16 flag $54
	dw $FFFF		;>Flag $55 (Group $0) -> LM's CM16 flag $55
	dw $FFFF		;>Flag $56 (Group $0) -> LM's CM16 flag $56
	dw $FFFF		;>Flag $57 (Group $0) -> LM's CM16 flag $57
	dw $FFFF		;>Flag $58 (Group $0) -> LM's CM16 flag $58
	dw $FFFF		;>Flag $59 (Group $0) -> LM's CM16 flag $59
	dw $FFFF		;>Flag $5A (Group $0) -> LM's CM16 flag $5A
	dw $FFFF		;>Flag $5B (Group $0) -> LM's CM16 flag $5B
	dw $FFFF		;>Flag $5C (Group $0) -> LM's CM16 flag $5C
	dw $FFFF		;>Flag $5D (Group $0) -> LM's CM16 flag $5D
	dw $FFFF		;>Flag $5E (Group $0) -> LM's CM16 flag $5E
	dw $FFFF		;>Flag $5F (Group $0) -> LM's CM16 flag $5F
	dw $FFFF		;>Flag $60 (Group $0) -> LM's CM16 flag $60
	dw $FFFF		;>Flag $61 (Group $0) -> LM's CM16 flag $61
	dw $FFFF		;>Flag $62 (Group $0) -> LM's CM16 flag $62
	dw $FFFF		;>Flag $63 (Group $0) -> LM's CM16 flag $63
	dw $FFFF		;>Flag $64 (Group $0) -> LM's CM16 flag $64
	dw $FFFF		;>Flag $65 (Group $0) -> LM's CM16 flag $65
	dw $FFFF		;>Flag $66 (Group $0) -> LM's CM16 flag $66
	dw $FFFF		;>Flag $67 (Group $0) -> LM's CM16 flag $67
	dw $FFFF		;>Flag $68 (Group $0) -> LM's CM16 flag $68
	dw $FFFF		;>Flag $69 (Group $0) -> LM's CM16 flag $69
	dw $FFFF		;>Flag $6A (Group $0) -> LM's CM16 flag $6A
	dw $FFFF		;>Flag $6B (Group $0) -> LM's CM16 flag $6B
	dw $FFFF		;>Flag $6C (Group $0) -> LM's CM16 flag $6C
	dw $FFFF		;>Flag $6D (Group $0) -> LM's CM16 flag $6D
	dw $FFFF		;>Flag $6E (Group $0) -> LM's CM16 flag $6E
	dw $FFFF		;>Flag $6F (Group $0) -> LM's CM16 flag $6F
	dw $FFFF		;>Flag $70 (Group $0) -> LM's CM16 flag $70
	dw $FFFF		;>Flag $71 (Group $0) -> LM's CM16 flag $71
	dw $FFFF		;>Flag $72 (Group $0) -> LM's CM16 flag $72
	dw $FFFF		;>Flag $73 (Group $0) -> LM's CM16 flag $73
	dw $FFFF		;>Flag $74 (Group $0) -> LM's CM16 flag $74
	dw $FFFF		;>Flag $75 (Group $0) -> LM's CM16 flag $75
	dw $FFFF		;>Flag $76 (Group $0) -> LM's CM16 flag $76
	dw $FFFF		;>Flag $77 (Group $0) -> LM's CM16 flag $77
	dw $FFFF		;>Flag $78 (Group $0) -> LM's CM16 flag $78
	dw $FFFF		;>Flag $79 (Group $0) -> LM's CM16 flag $79
	dw $FFFF		;>Flag $7A (Group $0) -> LM's CM16 flag $7A
	dw $FFFF		;>Flag $7B (Group $0) -> LM's CM16 flag $7B
	dw $FFFF		;>Flag $7C (Group $0) -> LM's CM16 flag $7C
	dw $FFFF		;>Flag $7D (Group $0) -> LM's CM16 flag $7D
	dw $FFFF		;>Flag $7E (Group $0) -> LM's CM16 flag $7E
	dw $FFFF		;>Flag $7F (Group $0) -> LM's CM16 flag $7F
?GetFlagNumberLevelIndexEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of what layer the flag is on. Put "$01" for layer 2 blocks if you
;are using a layer 2 level and have that flagged block on that layer, otherwise put "$00" instead.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?GetFlagNumberLayerProcessingStart:
	db $00		;>Flag $0 (Group $0) -> LM's CM16 flag $0
	db $00		;>Flag $1 (Group $0) -> LM's CM16 flag $1
	db $00		;>Flag $2 (Group $0) -> LM's CM16 flag $2
	db $00		;>Flag $3 (Group $0) -> LM's CM16 flag $3
	db $00		;>Flag $4 (Group $0) -> LM's CM16 flag $4
	db $00		;>Flag $5 (Group $0) -> LM's CM16 flag $5
	db $00		;>Flag $6 (Group $0) -> LM's CM16 flag $6
	db $00		;>Flag $7 (Group $0) -> LM's CM16 flag $7
	db $00		;>Flag $8 (Group $0) -> LM's CM16 flag $8
	db $00		;>Flag $9 (Group $0) -> LM's CM16 flag $9
	db $00		;>Flag $A (Group $0) -> LM's CM16 flag $A
	db $00		;>Flag $B (Group $0) -> LM's CM16 flag $B
	db $00		;>Flag $C (Group $0) -> LM's CM16 flag $C
	db $00		;>Flag $D (Group $0) -> LM's CM16 flag $D
	db $00		;>Flag $E (Group $0) -> LM's CM16 flag $E
	db $00		;>Flag $F (Group $0) -> LM's CM16 flag $F
	db $00		;>Flag $10 (Group $0) -> LM's CM16 flag $10
	db $00		;>Flag $11 (Group $0) -> LM's CM16 flag $11
	db $00		;>Flag $12 (Group $0) -> LM's CM16 flag $12
	db $00		;>Flag $13 (Group $0) -> LM's CM16 flag $13
	db $00		;>Flag $14 (Group $0) -> LM's CM16 flag $14
	db $00		;>Flag $15 (Group $0) -> LM's CM16 flag $15
	db $00		;>Flag $16 (Group $0) -> LM's CM16 flag $16
	db $00		;>Flag $17 (Group $0) -> LM's CM16 flag $17
	db $00		;>Flag $18 (Group $0) -> LM's CM16 flag $18
	db $00		;>Flag $19 (Group $0) -> LM's CM16 flag $19
	db $00		;>Flag $1A (Group $0) -> LM's CM16 flag $1A
	db $00		;>Flag $1B (Group $0) -> LM's CM16 flag $1B
	db $00		;>Flag $1C (Group $0) -> LM's CM16 flag $1C
	db $00		;>Flag $1D (Group $0) -> LM's CM16 flag $1D
	db $00		;>Flag $1E (Group $0) -> LM's CM16 flag $1E
	db $00		;>Flag $1F (Group $0) -> LM's CM16 flag $1F
	db $00		;>Flag $20 (Group $0) -> LM's CM16 flag $20
	db $00		;>Flag $21 (Group $0) -> LM's CM16 flag $21
	db $00		;>Flag $22 (Group $0) -> LM's CM16 flag $22
	db $00		;>Flag $23 (Group $0) -> LM's CM16 flag $23
	db $00		;>Flag $24 (Group $0) -> LM's CM16 flag $24
	db $00		;>Flag $25 (Group $0) -> LM's CM16 flag $25
	db $00		;>Flag $26 (Group $0) -> LM's CM16 flag $26
	db $00		;>Flag $27 (Group $0) -> LM's CM16 flag $27
	db $00		;>Flag $28 (Group $0) -> LM's CM16 flag $28
	db $00		;>Flag $29 (Group $0) -> LM's CM16 flag $29
	db $00		;>Flag $2A (Group $0) -> LM's CM16 flag $2A
	db $00		;>Flag $2B (Group $0) -> LM's CM16 flag $2B
	db $00		;>Flag $2C (Group $0) -> LM's CM16 flag $2C
	db $00		;>Flag $2D (Group $0) -> LM's CM16 flag $2D
	db $00		;>Flag $2E (Group $0) -> LM's CM16 flag $2E
	db $00		;>Flag $2F (Group $0) -> LM's CM16 flag $2F
	db $00		;>Flag $30 (Group $0) -> LM's CM16 flag $30
	db $00		;>Flag $31 (Group $0) -> LM's CM16 flag $31
	db $00		;>Flag $32 (Group $0) -> LM's CM16 flag $32
	db $00		;>Flag $33 (Group $0) -> LM's CM16 flag $33
	db $00		;>Flag $34 (Group $0) -> LM's CM16 flag $34
	db $00		;>Flag $35 (Group $0) -> LM's CM16 flag $35
	db $00		;>Flag $36 (Group $0) -> LM's CM16 flag $36
	db $00		;>Flag $37 (Group $0) -> LM's CM16 flag $37
	db $00		;>Flag $38 (Group $0) -> LM's CM16 flag $38
	db $00		;>Flag $39 (Group $0) -> LM's CM16 flag $39
	db $00		;>Flag $3A (Group $0) -> LM's CM16 flag $3A
	db $00		;>Flag $3B (Group $0) -> LM's CM16 flag $3B
	db $00		;>Flag $3C (Group $0) -> LM's CM16 flag $3C
	db $00		;>Flag $3D (Group $0) -> LM's CM16 flag $3D
	db $00		;>Flag $3E (Group $0) -> LM's CM16 flag $3E
	db $00		;>Flag $3F (Group $0) -> LM's CM16 flag $3F
	db $00		;>Flag $40 (Group $0) -> LM's CM16 flag $40
	db $00		;>Flag $41 (Group $0) -> LM's CM16 flag $41
	db $00		;>Flag $42 (Group $0) -> LM's CM16 flag $42
	db $00		;>Flag $43 (Group $0) -> LM's CM16 flag $43
	db $00		;>Flag $44 (Group $0) -> LM's CM16 flag $44
	db $00		;>Flag $45 (Group $0) -> LM's CM16 flag $45
	db $00		;>Flag $46 (Group $0) -> LM's CM16 flag $46
	db $00		;>Flag $47 (Group $0) -> LM's CM16 flag $47
	db $00		;>Flag $48 (Group $0) -> LM's CM16 flag $48
	db $00		;>Flag $49 (Group $0) -> LM's CM16 flag $49
	db $00		;>Flag $4A (Group $0) -> LM's CM16 flag $4A
	db $00		;>Flag $4B (Group $0) -> LM's CM16 flag $4B
	db $00		;>Flag $4C (Group $0) -> LM's CM16 flag $4C
	db $00		;>Flag $4D (Group $0) -> LM's CM16 flag $4D
	db $00		;>Flag $4E (Group $0) -> LM's CM16 flag $4E
	db $00		;>Flag $4F (Group $0) -> LM's CM16 flag $4F
	db $00		;>Flag $50 (Group $0) -> LM's CM16 flag $50
	db $00		;>Flag $51 (Group $0) -> LM's CM16 flag $51
	db $00		;>Flag $52 (Group $0) -> LM's CM16 flag $52
	db $00		;>Flag $53 (Group $0) -> LM's CM16 flag $53
	db $00		;>Flag $54 (Group $0) -> LM's CM16 flag $54
	db $00		;>Flag $55 (Group $0) -> LM's CM16 flag $55
	db $00		;>Flag $56 (Group $0) -> LM's CM16 flag $56
	db $00		;>Flag $57 (Group $0) -> LM's CM16 flag $57
	db $00		;>Flag $58 (Group $0) -> LM's CM16 flag $58
	db $00		;>Flag $59 (Group $0) -> LM's CM16 flag $59
	db $00		;>Flag $5A (Group $0) -> LM's CM16 flag $5A
	db $00		;>Flag $5B (Group $0) -> LM's CM16 flag $5B
	db $00		;>Flag $5C (Group $0) -> LM's CM16 flag $5C
	db $00		;>Flag $5D (Group $0) -> LM's CM16 flag $5D
	db $00		;>Flag $5E (Group $0) -> LM's CM16 flag $5E
	db $00		;>Flag $5F (Group $0) -> LM's CM16 flag $5F
	db $00		;>Flag $60 (Group $0) -> LM's CM16 flag $60
	db $00		;>Flag $61 (Group $0) -> LM's CM16 flag $61
	db $00		;>Flag $62 (Group $0) -> LM's CM16 flag $62
	db $00		;>Flag $63 (Group $0) -> LM's CM16 flag $63
	db $00		;>Flag $64 (Group $0) -> LM's CM16 flag $64
	db $00		;>Flag $65 (Group $0) -> LM's CM16 flag $65
	db $00		;>Flag $66 (Group $0) -> LM's CM16 flag $66
	db $00		;>Flag $67 (Group $0) -> LM's CM16 flag $67
	db $00		;>Flag $68 (Group $0) -> LM's CM16 flag $68
	db $00		;>Flag $69 (Group $0) -> LM's CM16 flag $69
	db $00		;>Flag $6A (Group $0) -> LM's CM16 flag $6A
	db $00		;>Flag $6B (Group $0) -> LM's CM16 flag $6B
	db $00		;>Flag $6C (Group $0) -> LM's CM16 flag $6C
	db $00		;>Flag $6D (Group $0) -> LM's CM16 flag $6D
	db $00		;>Flag $6E (Group $0) -> LM's CM16 flag $6E
	db $00		;>Flag $6F (Group $0) -> LM's CM16 flag $6F
	db $00		;>Flag $70 (Group $0) -> LM's CM16 flag $70
	db $00		;>Flag $71 (Group $0) -> LM's CM16 flag $71
	db $00		;>Flag $72 (Group $0) -> LM's CM16 flag $72
	db $00		;>Flag $73 (Group $0) -> LM's CM16 flag $73
	db $00		;>Flag $74 (Group $0) -> LM's CM16 flag $74
	db $00		;>Flag $75 (Group $0) -> LM's CM16 flag $75
	db $00		;>Flag $76 (Group $0) -> LM's CM16 flag $76
	db $00		;>Flag $77 (Group $0) -> LM's CM16 flag $77
	db $00		;>Flag $78 (Group $0) -> LM's CM16 flag $78
	db $00		;>Flag $79 (Group $0) -> LM's CM16 flag $79
	db $00		;>Flag $7A (Group $0) -> LM's CM16 flag $7A
	db $00		;>Flag $7B (Group $0) -> LM's CM16 flag $7B
	db $00		;>Flag $7C (Group $0) -> LM's CM16 flag $7C
	db $00		;>Flag $7D (Group $0) -> LM's CM16 flag $7D
	db $00		;>Flag $7E (Group $0) -> LM's CM16 flag $7E
	db $00		;>Flag $7F (Group $0) -> LM's CM16 flag $7F
	?GetFlagNumberLayerProcessingEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of positions.
;With the help of asar's function (not sure if Xkas first made this or not),
;adding a location to the table is very easy. Format:
;
;dw GetC800IndexHoriziLvl($HHHH, $XXXX, $YYYY)
;dw GetC800IndexVertiLvl($XXXX, $YYYY)
;
;-$HHHH is the level height (in pixels), basically RAM address $13D7. Fastest way to
; know what value is this in a level is in lunar magic, hover your mouse on the last
; row of blocks, and the status bar on the window (<XPos_in_hex>,<YPos_in_hex>:<TileNumber>),
; take the <YPos_in_hex> and add 1 AND THEN multiply by $10 (or just add a zero at the end;
; example: ($1A + 1)*$10 = $1B0)
;-$XXXX and $YYYY are the block coordinates, in units of 16x16 blocks (not pixels).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?GetFlagNumberC800IndexStart:
	dw GetC800IndexVertiLvl($0005, $000B)		;>Flag $0 (Group $0) -> LM's CM16 flag $0
	dw GetC800IndexVertiLvl($0005, $001B)		;>Flag $1 (Group $0) -> LM's CM16 flag $1
	dw GetC800IndexVertiLvl($0005, $002B)		;>Flag $2 (Group $0) -> LM's CM16 flag $2
	dw GetC800IndexVertiLvl($0005, $003B)		;>Flag $3 (Group $0) -> LM's CM16 flag $3
	dw GetC800IndexVertiLvl($0005, $004B)		;>Flag $4 (Group $0) -> LM's CM16 flag $4
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $5 (Group $0) -> LM's CM16 flag $5
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $6 (Group $0) -> LM's CM16 flag $6
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $7 (Group $0) -> LM's CM16 flag $7
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $8 (Group $0) -> LM's CM16 flag $8
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $9 (Group $0) -> LM's CM16 flag $9
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $A (Group $0) -> LM's CM16 flag $A
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $B (Group $0) -> LM's CM16 flag $B
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $C (Group $0) -> LM's CM16 flag $C
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $D (Group $0) -> LM's CM16 flag $D
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $E (Group $0) -> LM's CM16 flag $E
	dw GetC800IndexHoriziLvl($01B0, $0006, $0016)		;>Flag $F (Group $0) -> LM's CM16 flag $F
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $10 (Group $0) -> LM's CM16 flag $10
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $11 (Group $0) -> LM's CM16 flag $11
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $12 (Group $0) -> LM's CM16 flag $12
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $13 (Group $0) -> LM's CM16 flag $13
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $14 (Group $0) -> LM's CM16 flag $14
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $15 (Group $0) -> LM's CM16 flag $15
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $16 (Group $0) -> LM's CM16 flag $16
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $17 (Group $0) -> LM's CM16 flag $17
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $18 (Group $0) -> LM's CM16 flag $18
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $19 (Group $0) -> LM's CM16 flag $19
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $1A (Group $0) -> LM's CM16 flag $1A
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $1B (Group $0) -> LM's CM16 flag $1B
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $1C (Group $0) -> LM's CM16 flag $1C
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $1D (Group $0) -> LM's CM16 flag $1D
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $1E (Group $0) -> LM's CM16 flag $1E
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $1F (Group $0) -> LM's CM16 flag $1F
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $20 (Group $0) -> LM's CM16 flag $20
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $21 (Group $0) -> LM's CM16 flag $21
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $22 (Group $0) -> LM's CM16 flag $22
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $23 (Group $0) -> LM's CM16 flag $23
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $24 (Group $0) -> LM's CM16 flag $24
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $25 (Group $0) -> LM's CM16 flag $25
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $26 (Group $0) -> LM's CM16 flag $26
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $27 (Group $0) -> LM's CM16 flag $27
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $28 (Group $0) -> LM's CM16 flag $28
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $29 (Group $0) -> LM's CM16 flag $29
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $2A (Group $0) -> LM's CM16 flag $2A
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $2B (Group $0) -> LM's CM16 flag $2B
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $2C (Group $0) -> LM's CM16 flag $2C
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $2D (Group $0) -> LM's CM16 flag $2D
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $2E (Group $0) -> LM's CM16 flag $2E
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $2F (Group $0) -> LM's CM16 flag $2F
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $30 (Group $0) -> LM's CM16 flag $30
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $31 (Group $0) -> LM's CM16 flag $31
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $32 (Group $0) -> LM's CM16 flag $32
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $33 (Group $0) -> LM's CM16 flag $33
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $34 (Group $0) -> LM's CM16 flag $34
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $35 (Group $0) -> LM's CM16 flag $35
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $36 (Group $0) -> LM's CM16 flag $36
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $37 (Group $0) -> LM's CM16 flag $37
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $38 (Group $0) -> LM's CM16 flag $38
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $39 (Group $0) -> LM's CM16 flag $39
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $3A (Group $0) -> LM's CM16 flag $3A
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $3B (Group $0) -> LM's CM16 flag $3B
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $3C (Group $0) -> LM's CM16 flag $3C
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $3D (Group $0) -> LM's CM16 flag $3D
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $3E (Group $0) -> LM's CM16 flag $3E
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $3F (Group $0) -> LM's CM16 flag $3F
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $40 (Group $0) -> LM's CM16 flag $40
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $41 (Group $0) -> LM's CM16 flag $41
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $42 (Group $0) -> LM's CM16 flag $42
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $43 (Group $0) -> LM's CM16 flag $43
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $44 (Group $0) -> LM's CM16 flag $44
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $45 (Group $0) -> LM's CM16 flag $45
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $46 (Group $0) -> LM's CM16 flag $46
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $47 (Group $0) -> LM's CM16 flag $47
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $48 (Group $0) -> LM's CM16 flag $48
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $49 (Group $0) -> LM's CM16 flag $49
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $4A (Group $0) -> LM's CM16 flag $4A
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $4B (Group $0) -> LM's CM16 flag $4B
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $4C (Group $0) -> LM's CM16 flag $4C
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $4D (Group $0) -> LM's CM16 flag $4D
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $4E (Group $0) -> LM's CM16 flag $4E
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $4F (Group $0) -> LM's CM16 flag $4F
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $50 (Group $0) -> LM's CM16 flag $50
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $51 (Group $0) -> LM's CM16 flag $51
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $52 (Group $0) -> LM's CM16 flag $52
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $53 (Group $0) -> LM's CM16 flag $53
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $54 (Group $0) -> LM's CM16 flag $54
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $55 (Group $0) -> LM's CM16 flag $55
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $56 (Group $0) -> LM's CM16 flag $56
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $57 (Group $0) -> LM's CM16 flag $57
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $58 (Group $0) -> LM's CM16 flag $58
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $59 (Group $0) -> LM's CM16 flag $59
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $5A (Group $0) -> LM's CM16 flag $5A
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $5B (Group $0) -> LM's CM16 flag $5B
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $5C (Group $0) -> LM's CM16 flag $5C
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $5D (Group $0) -> LM's CM16 flag $5D
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $5E (Group $0) -> LM's CM16 flag $5E
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $5F (Group $0) -> LM's CM16 flag $5F
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $60 (Group $0) -> LM's CM16 flag $60
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $61 (Group $0) -> LM's CM16 flag $61
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $62 (Group $0) -> LM's CM16 flag $62
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $63 (Group $0) -> LM's CM16 flag $63
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $64 (Group $0) -> LM's CM16 flag $64
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $65 (Group $0) -> LM's CM16 flag $65
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $66 (Group $0) -> LM's CM16 flag $66
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $67 (Group $0) -> LM's CM16 flag $67
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $68 (Group $0) -> LM's CM16 flag $68
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $69 (Group $0) -> LM's CM16 flag $69
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $6A (Group $0) -> LM's CM16 flag $6A
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $6B (Group $0) -> LM's CM16 flag $6B
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $6C (Group $0) -> LM's CM16 flag $6C
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $6D (Group $0) -> LM's CM16 flag $6D
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $6E (Group $0) -> LM's CM16 flag $6E
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $6F (Group $0) -> LM's CM16 flag $6F
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $70 (Group $0) -> LM's CM16 flag $70
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $71 (Group $0) -> LM's CM16 flag $71
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $72 (Group $0) -> LM's CM16 flag $72
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $73 (Group $0) -> LM's CM16 flag $73
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $74 (Group $0) -> LM's CM16 flag $74
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $75 (Group $0) -> LM's CM16 flag $75
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $76 (Group $0) -> LM's CM16 flag $76
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $77 (Group $0) -> LM's CM16 flag $77
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $78 (Group $0) -> LM's CM16 flag $78
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $79 (Group $0) -> LM's CM16 flag $79
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $7A (Group $0) -> LM's CM16 flag $7A
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $7B (Group $0) -> LM's CM16 flag $7B
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $7C (Group $0) -> LM's CM16 flag $7C
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $7D (Group $0) -> LM's CM16 flag $7D
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $7E (Group $0) -> LM's CM16 flag $7E
	dw GetC800IndexVertiLvl($0000, $0000)		;>Flag $7F (Group $0) -> LM's CM16 flag $7F
?GetFlagNumberC800IndexEnd: