; FreeRAM addresses.
!BlockSet = $140C|!addr		;> FreeRAM flag to tell us once a block has been set by the player.
!Index = $18C5|!addr		;> Index into the Map16 block tables (16 bits).
!Subject = $18C7|!addr		;> Starting address for "DEMO" ($18C7), "CATNIP" ($18C8), and "SHELL" ($18C9) property bytes.
;!BlueSwitch = $18CA|!addr	;> Flag to draw the Blue Switch tiles.
;!Catnip = $18CA|!addr		;> Catnip's index in the sprite tables.

; Starting addresses for the level's Map16 block tables (SA-1).
!Map16TableLow = $40C800	;\ Low byte contains the block number on a given Map16 page.
!Map16TableHigh = $41C800	;/ High byte contains the Map16 page number.

init:
	; Processor flags: A is 8-bit, X/Y are 8-bit.

	LDA #$01		;\ Check the initial configuration of the level for active rules.
	STA !BlockSet		;/
	;STZ !BlockSet
	RTL

main:
	; Processor flags: A is 8-bit, X/Y are 8-bit.

;	LDA $1497|!addr		;\ If Demo's flashing animation is active, then do not process the rules.
;	BEQ +			;| Not sure if this is needed for the below code block to work.
;	JMP exit		;/ Note: Commented out because this prevents the block check from running if you pick up the blocks while hurt.
;+
	LDA $71			;\ If Demo is hurt (flashing), then activate the rules.
	CMP #$01		;| This has the effect of keeping Demo's powerup status when Big, Fire, or Cape, but killing her when Small.
	BNE +			;| However, the code might not be entirely correct. For example, Demo can be in a "hurt" state for a longer period than
	LDA #$01		;| normal. This could be caused by longer level lengths (i.e., more tiles need to be checked).
	STA !BlockSet		;/
+
	LDA $71			;\
	CMP #$06		;| If Demo enters a vertical pipe, remove her reserve powerup.
	BNE +			;|
	STZ $0DC2|!addr		;/
+
	LDA !BlockSet		;\ Every frame, check if the player had just set down a block.
	BNE +			;| If so, then initiate the Map16 block search.
	JMP exit		;/ Else, exit the code.
+
	REP #$30		;> Reset A and the X/Y registers to 16-bit.
	STZ !Index

block_search:
	; Processor flags: A is 16-bit, X/Y are 16-bit.

	LDX !Index		;> Load the index into an indexing register.
	SEP #$20		;> Set A to 8-bit, keeping the X/Y registers 16-bit.
	LDA !Map16TableHigh,X	;> Load the high byte of the Map16 block into the low byte of A.
	XBA			;> Swap the low byte of A into its high byte.
	LDA !Map16TableLow,X	;> Load the low byte of the Map16 block into the low byte of A.
	REP #$20		;> Reset A to 16-bit.

	CMP #$1602		;\ If the current block is an "IS" block, then start processing its rules.
	BEQ process_rules	;/

	CMP #$1609		;\
	BNE +			;| Else, if we reached the end of the level (i.e., found the custom "end" block), then stop the search.
	JMP change_state	;/
	;JMP exit		;/
+
	JMP increment_loop	;> Else, continue to the next block.

process_rules:
	; Processor flags: A is 16-bit, X/Y are 16-bit.

	; Process horizontal rules.
	JSR get_index_left	;> Input: Index of the current block in !Index. Output: Index of the left block in A.
	JSR get_subject		;> Input: Index of the left block in A. Output: Offset into the subject property byte table in Y.
	JSR get_index_right	;> Input: Index of the current block in !Index. Output: Index of the right block in A.
	JSR get_adjective	;> Input: Index of the right block in A. Output: Bit corresponding to a certain adjective in A.
	JSR set_property

	; Process vertical rules.
	JSR get_index_top	;> Input: Index of the current block in !Index. Output: Index of the top block in A.
	JSR get_subject		;> Input: Index of the top block in A. Output: Offset into the subject property byte table in Y.
	JSR get_index_bottom	;> Input: Index of the current block in !Index. Output: Index of the bottom block in A.
	JSR get_adjective	;> Input: Index of the bottom block in A. Output: Bit corresponding to a certain adjective in A.
	JSR set_property

	;BRA increment_loop

increment_loop:
	; Processor flags: A is 16-bit, X/Y are 16-bit.

	INC !Index		;\ Increment the loop counter and continue the block search.
	JMP block_search	;/

change_state:
	; Processor flags: A is 16-bit, X/Y are 16-bit.

	SEP #$20		;> Set A to 8-bit, keeping the X/Y registers 16-bit.

	LDA !Subject+$0000	;\
	AND #$08		;| If the adjective for "DEMO" is "YELLOW"...
	CMP #$08		;|
	BEQ demo_yellow		;/ ...then change state to Cape Demo.

	LDA !Subject+$0000	;\
	AND #$04		;| Else, if the adjective for "DEMO" is "RED"...
	CMP #$04		;|
	BEQ demo_red		;/ ...then change state to Fire Demo.

	LDA !Subject+$0000	;\
	AND #$02		;| Else, if the adjective for "DEMO" is "BLUE"...
	CMP #$02		;|
	BEQ demo_blue		;/ ...then change state to Big Demo.

	LDA !Subject+$0000	;\
	AND #$01		;| Else, if the adjective for "DEMO" is "GREEN"...
	CMP #$01		;|
	BEQ demo_green		;/ ...then change state to Green Demo. (Todo: Change to Iris graphics, or give Demo a green palette.)

	BRA demo_small		;> Else, change state to Small Demo.

demo_yellow:
	LDA #$02
	STA $19
	BRA +

demo_red:
	LDA #$03
	STA $19
	BRA +

demo_blue:
	LDA #$01
	STA $19
	BRA +

demo_green:			;> Todo: Change to Iris graphics, or give Demo a green palette.
	LDA #$00
	STA $19
	BRA +

demo_small:
	LDA #$00
	STA $19
+
	LDX #$0000
	LDA !Subject+$0002	;\
	AND #$02		;| If the adjective for "SWITCH" is "BLUE"...
	CMP #$02		;|
	BEQ switch_blue		;/ ...then change the tiles to that of a Blue Switch.

	BRA switch_null		;> Else, change the tiles to that of a Null Switch.

switch_blue:
	REP #$20		;> Reset A to 16-bit.
	LDA SwitchY,X		;\ Load the y-coordinate of the Null Switch tile currently indicated by X.
	STA $98			;/
	LDA SwitchX,X		;\ Load the x-coordinate of the Null Switch tile currently indicated by X.
	STA $9A			;/
	LDA SwitchBlue,X	;> Load the Map16 value of the Blue Switch tile currently indicated by X.
	JSR change_map16	;> With the (x,y)-coordinates and the Map16 value set, we can now update the Map16 to a Blue Switch tile.
	SEP #$20		;> Set A to 8-bit.

	INX #2			;\ If we didn't reach the end of the data table yet, then continue to change the Map16 blocks to the Blue Switch.
	CPX #$0008		;| Note that we need to increment the index register twice, since we are using "dw" instead of "db" for the tables.
	BNE switch_blue		;/

	BRA +

switch_null:
	REP #$20		;> Reset A to 16-bit.
	LDA SwitchY,X		;\ Load the y-coordinate of the Blue Switch tile currently indicated by X.
	STA $98			;/
	LDA SwitchX,X		;\ Load the x-coordinate of the Blue Switch tile currently indicated by X.
	STA $9A			;/
	LDA SwitchNull,X	;> Load the Map16 value of the Null Switch tile currently indicated by X.
	JSR change_map16	;> With the (x,y)-coordinates and the Map16 value set, we can now update the Map16 to a Null Switch tile.
	SEP #$20		;> Set A to 8-bit.

	INX #2			;\ If we didn't reach the end of the data table yet, then continue to change the Map16 blocks to the Blue Switch.
	CPX #$0008		;| Note that we need to increment the index register twice, since we are using "dw" instead of "db" for the tables.
	BNE switch_null		;/
+
	LDX #$0015		;> Initialize the number of sprite slots to search for Catnip (for SA-1, 0x15 = 21 slots, plus the zeroth slot).

catnip_search:
	LDA !9E,X		;\
	CMP #$35		;| Loop through all of the sprite slots until Catnip is found.
	BEQ catnip_found	;| When found, Catnip's index is in X.
	CPX #$FFFF		;|
	BEQ exit		;| Exit if no Catnip was found after all sprite slots have been searched (i.e., the index underflows).
	DEX			;|
	BRA catnip_search	;/

catnip_found:
	LDA !Subject+$0001	;\
	AND #$08		;| If the adjective for "CATNIP" is "YELLOW"...
	CMP #$08		;|
	BEQ catnip_yellow	;/ ...then set Catnip's palette to yellow.

	LDA !Subject+$0001	;\
	AND #$04		;| Else, if the adjective for "CATNIP" is "RED"...
	CMP #$04		;|
	BEQ catnip_red		;/ ...then set Catnip's palette to red.

	LDA !Subject+$0001	;\
	AND #$02		;| Else, if the adjective for "CATNIP" is "BLUE"...
	CMP #$02		;|
	BEQ catnip_blue		;/ ...then set Catnip's palette to blue.

	LDA !Subject+$0001	;\
	AND #$01		;| Else, if the adjective for "CATNIP" is "GREEN"...
	CMP #$01		;|
	BEQ catnip_green	;/ ...then set Catnip's palette to green.

	BRA catnip_green	;> Else, set Catnip's palette to green by default.

catnip_yellow:
	LDA #$04
	STA !15F6,X
	BRA +

catnip_red:
	LDA #$08
	STA !15F6,X
	BRA +

catnip_blue:
	LDA #$06
	STA !15F6,X
	BRA +

catnip_green:
	LDA #$0A
	STA !15F6,X
+
	REP #$20		;> Reset A to 16-bit.

exit:
	; Processor flags: A is 16-bit, X/Y are 16-bit.

	SEP #$30		;> Set A and the X/Y registers to 8-bit.
	STZ !BlockSet		;> Zero out the "block is set" flag for the next run.
	STZ !Subject+$0000	;\
	STZ !Subject+$0001	;| Zero out the "DEMO", "CATNIP", and "SHELL" property bytes, too.
	STZ !Subject+$0002	;/
	RTL

;;;;;;;;;;;;;;;
; Subroutines ;
;;;;;;;;;;;;;;;

get_index_left:
	; Preconditions: A is 16-bit, X/Y are 16-bit.
	; Output: Index of the left block in A.

	LDA !Index		;\
	AND #$000F		;| Check if the block is on the leftmost screen boundary (i.e., index ends in zero).
	BNE +			;/ If not, then the block is not on the leftmost screen boundary.

	LDA !Index		;\
	SEC			;| Else, need to subtract the entire screen offset from the index.
	SBC #$01A1		;|
	RTS			;/
+
	LDA !Index		;\
	DEC A			;| If the block is not on the leftmost screen boundary, then we can just decrement the index.
	RTS			;/

get_index_right:
	; Preconditions: A is 16-bit, X/Y are 16-bit.
	; Output: Index of the right block in A.

	LDA !Index		;\
	AND #$000F		;| Check if the block is on the rightmost screen boundary (i.e., index ends in 0xF).
	CMP #$000F		;|
	BNE +			;/ If not, then the block is not on the rightmost screen boundary.

	LDA !Index		;\
	CLC			;| Else, need to add the entire screen offset to the index.
	ADC #$01A1		;|
	RTS			;/
+
	LDA !Index		;\
	INC A			;| If the block is not on the rightmost screen boundary, then we can just increment the index.
	RTS			;/

get_index_top:
	; Preconditions: A is 16-bit, X/Y are 16-bit.
	; Output: Index of the top block in A.

	LDA !Index		;\
	SEC			;| Subtract the row offset from the index.
	SBC #$0010		;|
	RTS			;/

get_index_bottom:
	; Preconditions: A is 16-bit, X/Y are 16-bit.
	; Output: Index of the bottom block in A.

	LDA !Index		;\
	CLC			;| Add the row offset to the index.
	ADC #$0010		;|
	RTS			;/

get_subject:
	; Preconditions: A is 16-bit, X/Y are 16-bit.
	; Input: Map16 block index in A.
	; Output: #$0001 in A if "DEMO", #$0002 in A if "CATNIP", #$0003 in A if "SHELL", #$0000 in A otherwise.
	; Output: Offset into the subject property byte table in Y (#$0000 if "DEMO", #$0001 if "CATNIP", #$0002 if "SHELL", #$0003 otherwise).

	TAX			;> Transfer the Map16 index in A to X.
	SEP #$20		;> Set A to 8-bit, keeping the X/Y registers 16-bit.
	LDA !Map16TableHigh,X	;> Load the high byte of the Map16 block into the low byte of A.
	XBA			;> Swap the low byte of A into its high byte.
	LDA !Map16TableLow,X	;> Load the low byte of the Map16 block into the low byte of A.
	REP #$20		;> Reset A to 16-bit.

	LDY #$0000		;\
	CMP #$1601		;|
	BNE +			;| If "DEMO" block, then return #$0001 in A and #$0000 in Y.
	LDA #$0001		;|
	RTS			;/
+
	INY			;\
	CMP #$1607		;|
	BNE +			;| Else, if "CATNIP" block, return #$0002 in A and #$0001 in Y.
	LDA #$0002		;|
	RTS			;/
+
	INY			;\
	CMP #$1608		;|
	BNE +			;| Else, if "SHELL" block, return #$0003 in A and #$0002 in Y.
	LDA #$0003		;|
	RTS			;/
+
	INY			;\
	LDA #$0000		;| Else, return #$0000 in A and #$0003 in Y.
	RTS			;/

get_adjective:
	; Preconditions: A is 16-bit, X/Y are 16-bit.
	; Input: Map16 block index in A.

	TAX			;> Transfer the Map16 index in A to X.
	SEP #$20		;> Set A to 8-bit, keeping the X/Y registers 16-bit.
	LDA !Map16TableHigh,X	;> Load the high byte of the Map16 block into the low byte of A.
	XBA			;> Swap the low byte of A into its high byte.
	LDA !Map16TableLow,X	;> Load the low byte of the Map16 block into the low byte of A.
	REP #$20		;> Reset A to 16-bit.

	CMP #$1604		;\
	BNE +			;| If "GREEN" block, then return #$0001 in A (set bit 0).
	LDA #$0001		;|
	RTS			;/
+
	CMP #$1603		;\
	BNE +			;| Else, if "BLUE" block, return #$0002 in A (set bit 1).
	LDA #$0002		;|
	RTS			;/
+
	CMP #$1605		;\
	BNE +			;| Else, if "RED" block, return #$0004 in A (set bit 2).
	LDA #$0004		;|
	RTS			;/
+
	CMP #$1606		;\
	BNE +			;| Else, if "YELLOW" block, return #$0008 in A (set bit 3).
	LDA #$0008		;|
	RTS			;/
+
	LDA #$0000		;\ Else, return #$0000 in A (don't set any bits).
	RTS			;/

set_property:
	SEP #$20		;> Set A to 8-bit, keeping the X/Y registers 16-bit.
	ORA !Subject,Y		;\ Set the bits in the subject's (Y) property byte based on their adjective (A).
	STA !Subject,Y		;/
	REP #$20		;> Reset A to 16-bit.
	RTS

;;;;;;;;;;
; The subroutine below changes a Map16 tile given a 16-bit Y value ($98-99), a 16-bit X value ($9A-9B), and the 16-bit block number (stored in A).
; Note: This was copy/pasted from the equivalent PIXI macro, with a few changes to definitions and labels to make it work with UberASM.
;;;;;;;;;;

!SA1 = 1
!Base2 = $6000
!BankB = $000000
!EXLEVEL = 0

change_map16:
	PHX
	PHP
	REP #$10
	TAX
	SEP #$20
	PHB
	PHY
	PHX
	LDY $98
	STY $0E
	LDY $9A
	STY $0C
	SEP #$30
	LDA $5B
	LDX $1933|!Base2
	BEQ .layer1
	LSR A
.layer1
	STA $0A
	LSR A
	BCC .horz
	LDA $9B
	LDY $99
	STY $9B
	STA $99
.horz
if !EXLEVEL
	BCS .verticalCheck
	REP #$20
	LDA $98
	CMP $13D7|!Base2
	SEP #$20
	BRA .check
endif
.verticalCheck
	LDA $99
	CMP #$02
.check
	BCC .noEnd
	REP #$10
	PLX
	PLY
	PLB
	PLP
	PLX
	SEC
	RTL
	
.noEnd
	LDA $9B
	STA $0B
	ASL A
	ADC $0B
	TAY
	REP #$20
	LDA $98
	AND.w #$FFF0
	STA $08
	AND.w #$00F0
	ASL #2			; 0000 00YY YY00 0000
	XBA			; YY00 0000 0000 00YY
	STA $06
	TXA
	SEP #$20
	ASL A
	TAX
	
	LDA $0D
	LSR A
	LDA $0F
	AND #$01		; 0000 000y
	ROL A			; 0000 00yx
	ASL #2			; 0000 yx00
	ORA #$20		; 0010 yx00
	CPX #$00
	BEQ .noAdd
	ORA #$10		; 001l yx00
.noAdd
	TSB $06			; $06 : 001l yxYY
	LDA $9A			; X LowByte
	AND #$F0		; XXXX 0000
	LSR #3			; 000X XXX0
	TSB $07			; $07 : YY0X XXX0
	LSR A
	TSB $08

	LDA $1925|!Base2
	ASL A
	REP #$31
	ADC $00BEA8|!BankB,x
	TAX
	TYA
if !SA1
    ADC.l $00,x
    TAX
    LDA $08
    ADC.l $00,x
else
    ADC $00,x
    TAX
    LDA $08
    ADC $00,x
endif
	TAX
	PLA
	ASL A
	TAY
	LSR A
	SEP #$20
if !SA1
	STA $400000,x
	XBA
	STA $410000,x
else
	STA $7E0000,x
	XBA
	STA $7F0000,x
endif
	LSR $0A
	LDA $1933|!Base2
	REP #$20
	BCS .vert
	BNE .horzL2
.horzL1
	LDA $1A			;\
	SBC #$007F		; |$08 : Layer1X - 0x80
	STA $08			;/
	LDA $1C			;  $0A : Layer1Y
	BRA +
.horzL2
	LDA $1E			;\ $08 : Layer2X
	STA $08			;/
	LDA $20			;\ $0A : Layer2Y - 0x80
	SBC #$007F		;/
	BRA +
	
.vert
	BNE .vertL2
	LDA $1A			;\ $08 : Layer1X
	STA $08			;/
	LDA $1C			;\ $0A : Layer1Y - 0x80
	SBC #$0080		;/
	BRA +
.vertL2
	LDA $1E			;\
	SBC #$0080		; |$08 : Layer2X - 0x80
	STA $08			;/
	LDA $20			;  $0A : Layer2Y
+
	STA $0A
	PHK
-	PEA.w (-)+9
	PEA $804C
	JML $00C0FB|!BankB
	PLY
	PLB
	PLP
	PLX
	CLC
	RTS

SwitchY:
	dw $0160,$0160,$0170,$0170	;> Y-coordinate of the Switch (in order: top left, top right, bottom left, bottom right).
SwitchX:
	dw $0270,$0280,$0270,$0280	;> X-coordinate of the Switch (in order: top left, top right, bottom left, bottom right).
;	dw $0010,$0020,$0010,$0020
SwitchBlue:
	dw $00F4,$00F5,$00F6,$00F7	;> Map16 tiles for the Blue Switch (in order: top left, top right, bottom left, bottom right).
SwitchNull:
	dw $1620,$1621,$1622,$1623	;> Map16 tiles for the Null Switch (in order: top left, top right, bottom left, bottom right).
