;A simple patch that lets you bring up the save prompt in the map by pressing Select.

!addr = $0000
!bank = $800000
if read1($00FFD5) = $23
	sa1rom
	!addr = $6000
	!bank = $000000
endif

org $048359
	autoclean JML Prompt

freedata

Prompt:
	;original code
	CMP #$03
	BEQ +
	JML $04835D|!bank
	+
	
	;check for a select press
	LDA $16
	AND #$20
	BEQ +
	
	;check if the player is standing on a level and not in looking around mode
	LDA $13D9|!addr
	SEC
	SBC #$03
	ORA $13D4|!addr
	BEQ ++
+	JML $048366|!bank	;return
	++
	
	;copy of $048F94, some setup to save the game
	LDX #$2C
-	LDA $1F02|!addr,x
	STA $1FA9|!addr,x
	DEX
	BPL -
	REP #$30
	LDX $0DD6|!addr
	TXA
	EOR #$0004
	TAY
	LDA $1FBE|!addr,x
	STA $1FBE|!addr,y
	LDA $1FC0|!addr,x
	STA $1FC0|!addr,y
	LDA $1FC6|!addr,x
	STA $1FC6|!addr,y
	LDA $1FC8|!addr,x
	STA $1FC8|!addr,y
	TXA
	LSR
	TAX
	EOR #$0002
	TAY
	LDA $1FBA|!addr,x
	STA $1FBA|!addr,y
	TXA
	SEP #$30
	LSR
	TAX
	EOR #$01
	TAY
	LDA $1FB8|!addr,x
	STA $1FB8|!addr,y
	
	;send to $049037, where the prompt is brought up, and prepare to return to $048375 from there
	INC $13CA|!addr
	PEA $8375
	JML $049037|!bank 