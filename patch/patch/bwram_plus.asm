;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; BW-RAM Plus
;; By LX5
;; And inspired in SRAM Plus
;; 
;; This patch makes possible to save some BW-RAM/I-RAM/W-RAM bytes to BW-RAM
;; by using MVN instead of DMA (BW-RAM to BW-RAM DMA doesn't work).
;; 
;; The maximum amount of bytes that can be saved to a save file is 2730,
;; unlike SRAM Plus that let you to save up to 8190 bytes per save file.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sa1rom

org $009CF5
	autoclean JML init_save : NOP #2

org $009BD2
	autoclean JML save_routine

freecode
prot bw_ram_table

init_save:
	BNE .initFile
	PHX
	STZ $6109
	JSR load_routine
	JML $009CFB
.initFile
	JSR load_init_vals
	JML $009D22

bw_ram_slots:
	dw $A000	;MARIO A
	dw $AAAA	;MARIO B
	dw $B556	;MARIO C
	
save_routine:	
	XBA				;recover replaced code
	LDA.l	$009CCE,x
		
	PHP
	REP #$30		
	
	PHA	
	PHX				;preserve stuff
	PHY	
		
	JSR	get_bw_ram		;get current save slot and other info
	LDX	#$0000			;initialize loop.
-	LDA.l	bw_ram_table,x		;get BW-RAM addresses to save to BW-RAM.
	STA	$00
	PHX	
	PHB	
	LDA.l	bw_ram_table+3,x	;get how many bytes we will save from that address.	
	STA	$04
	DEC
	PHA
	LDA.l	bw_ram_table+2,x	;get bank byte of the address.
	LDX	$00
	LDY	$02
	AND	#$00FF
	BEQ	.use_00
	CMP	#$0040			;if bank byte is $40, do something different
	BEQ	.use_40
	CMP	#$007E
	BEQ	.use_7E
	CMP	#$007F
	BEQ	.use_7F
	PLA	
	MVN	$41,$41			;Save to BW-RAM adresses from bank $41 (BW-RAM)
	BRA	+
.use_40		
	PLA	
	MVN	$41,$40			;Save to BW-RAM adresses from bank $40 (BW-RAM)
	BRA	+
.use_7E		
	PLA	
	MVN	$41,$7E			;Save to BW-RAM addresses from bank $7E (WRAM)
	BRA	+
.use_7F		
	PLA	
	MVN	$41,$7F			;Save to BW-RAM addresses from bank $7E (WRAM)
	BRA	+
.use_00		
	PLA	
	MVN	$41,$00			;Save to BW-RAM addresses from bank $00 (I-RAM)
+		
	LDA	$02
	CLC	
	ADC	$04			;move address source
	STA	$02
	PLB	
	PLX	
	TXA	
	CLC	
	ADC	#$0005			;get the next BW-RAM adresses to save
	TAX	
	CPX.w	#bw_ram_table_end-bw_ram_table
	BCC	-
		
	;REP #$30		;should still be.
	PLY	
	PLX				;recover stuff
	PLA
	PLP		
		
	JML	$009BD6

load_routine:
	PHY	
		
	PHP	
	JSR	get_bw_ram		;get current save slot and other info
	LDX	#$0000
-	
	LDA.l	bw_ram_table,x		;get BW-RAM addresses to load to BW-RAM
	TAY				;transfer them to Y
	PHX	
	PHB	
	LDA.l	bw_ram_table+3,x	;get how many bytes we will load to BW-RAM	
	STA	$04
	DEC
	PHA
	LDA.l	bw_ram_table+2,x	;get bank byte of the address.
	LDX	$02
	AND	#$00FF
	BEQ	.use_00
	CMP	#$0040
	BEQ	.use_40
	CMP	#$007E
	BEQ	.use_7E
	CMP	#$007F
	BEQ	.use_7F
	PLA	
	MVN	$41,$41			;Load to bank $41 addresses from BW-RAM (BW-RAM)
	BRA	+
.use_40		
	PLA	
	MVN	$40,$41			;Load to bank $40 addresses from BW-RAM (BW-RAM)
	BRA	+
.use_7E		
	PLA	
	MVN	$7E,$41			;Load to bank $7E addresses from BW-RAM (WRAM)
	BRA	+
.use_7F		
	PLA	
	MVN	$7F,$41			;Load to bank $7F addresses from BW-RAM (WRAM)
	BRA	+
.use_00		
	PLA	
	MVN	$00,$41			;Load to bank $00 addresses from BW-RAM (I-RAM)
+		
	LDA	$02
	CLC	
	ADC	$04			;move address destination
	STA	$02
	PLB	
	PLX	
	TXA	
	CLC	
	ADC	#$0005			;get the next BW-RAM adresses to load
	TAX	
	CPX.w	#bw_ram_table_end-bw_ram_table
	BCC	-
	PLP

	PLY
	RTS


load_init_vals:
	PHX				;preserve X & Y
	PHY	
		
	REP	#$30
	LDA.w	#bw_ram_defaults	;get the address of the default BW-RAM values
	STA	$02
	LDX	#$0000
-
	LDA.l	bw_ram_table,x		;get BW-RAM addresses
	TAY	
	PHX	
	PHB	
	LDA.l	bw_ram_table+3,x	;get how many bytes we will write to BW-RAM		
	STA	$04
	DEC
	PHA
	LDA.l	bw_ram_table+2,x	;get bank byte
	LDX	$02
	AND	#$00FF
	BEQ	.use_00
	CMP	#$0040
	BEQ	.use_40
	CMP	#$007E
	BEQ	.use_7E
	CMP	#$007F
	BEQ	.use_7F
	PLA	
	MVN	$41,bw_ram_defaults>>16	;transfer default values to BW-RAM in bank $41
	BRA	+
.use_40		
	PLA	
	MVN	$40,bw_ram_defaults>>16	;transfer default values to BW-RAM in bank $40
	BRA	+
.use_7E		
	PLA	
	MVN	$7E,bw_ram_defaults>>16	;transfer default values to WRAM in bank $7E
	BRA	+
.use_7F		
	PLA	
	MVN	$7F,bw_ram_defaults>>16	;transfer default values to WRAM in bank $7F
	BRA	+
.use_00		
	PLA	
	MVN	$00,bw_ram_defaults>>16	;transfer default values to I-RAM in bank $00
+		
	LDA	$02
	CLC	
	ADC	$04			;move address destination
	STA	$02
	PLB	
	PLX	
	TXA	
	CLC	
	ADC	#$0005			;get the next adresses to write
	TAX	
	CPX.w	#bw_ram_table_end-bw_ram_table
	BCC	-
		
	PLY
	PLX
	SEP	#$30
	RTS
		
get_bw_ram:
	REP	#$30
	LDA	$610A			;get save slot
	AND	#$00FF
	ASL				;and multiply it by 2
	TAX	
	LDA.l	bw_ram_slots,x		;get the BW-RAM address to save or read bytes
	STA	$02			;save the address to 2
	RTS 

print "Freespace used by BW-RAM save/load/clean routines: ",freespaceuse," bytes."

freedata
reset bytes

print "SRAM Plus tables are located at: $",pc
	incsrc bwram_tables.asm
print "Freespace used by BW-RAM tables: ",bytes," bytes."
