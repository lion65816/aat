	incsrc "../FlagMemoryDefines/Defines.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Load flag table into conditional map16 flags (CM16: $7FC060)
;
;Because the CM16 is 16 bytes large ($7FC060-$7FC06F; total of
;128 bits numbered from $00-$7F), !Freeram_MemoryFlag will have
;to be divided into groups of 16 bytes:
;
;Group 0: !Freeram_MemoryFlag+$00 to !Freeram_MemoryFlag+$0F
;Group 1: !Freeram_MemoryFlag+$10 to !Freeram_MemoryFlag+$1F
;Group 2: !Freeram_MemoryFlag+$20 to !Freeram_MemoryFlag+$0F
;[...]
;
;This code handles it like this (in this order):
;1) Find what index number of the current level being loaded
;2) Use that index number to find what group the level is
;   associated with.
;3) Take the now-known group in !Freeram_MemoryFlag and transfer
;   the data into $7FC060-$7FC06F.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
LoadFlagTableToCM16:
	PHB				;\update bank
	PHK				;|
	PLB				;/
	REP #$30			;>16-bit AXY
	
	LDX.w #(.LevelList_End-.LevelList)-2
	LDY.w #((.LevelList_End-.LevelList)/2)-1
	
	.Loop
	LDA $010B|!addr			;\Search what index the current level is on.
	CMP .LevelList,x		;|
	BEQ .Found			;|
	
	..Next
	DEY				;|
	DEX #2				;|
	BPL .Loop			;/
	
	.NotFound
	;X=$FFFE			;\If in a level not listed, don't do anything
	;Y=$FFFF			;|
	BRA .Done			;/
	
	.Found
	;X = (levelIndex*2)
	;Y = LevelIndex
	SEP #$20					;
	LDA.b #!Freeram_MemoryFlag     : STA $00	;\Find what level listed is associated to what 128-group.
	LDA.b #!Freeram_MemoryFlag>>8  : STA $01	;|
	LDA.b #!Freeram_MemoryFlag>>16 : STA $02	;|
	
	LDA $00						;|
	CLC						;|
	ADC .OneHundredTwentyEightFlagGroupList,y	;|
	STA $00						;|
	LDA $01						;|
	ADC #$00					;|
	STA $01						;|
	;LDA $02					;|
	;ADC #$00					;|
	;STA $02					;/$00-$02 = !Freeram_MemoryFlag+(GroupNumber*$10)
	
	.TransferTo7FC060
	SEP #$30
	LDY #$0F					;\Transfer.
	LDX #$0F					;|>Because STA $xxxxxx,y does not exist.
	..Loop
	LDA [$00],y					;|
	STA $7FC060,x					;|
	DEY						;|
	DEX						;|
	BPL ..Loop					;/
	
	.Done
	SEP #$30
	PLB				;>Restore bank
	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of levels. Each level are given what group-128 to use.
;You cannot have one level with multiple group-128s, however
;you can have multiple levels using the same group-128, which
;that saves you memory if you find one level using less than 128
;flags.
;
;Also, you cannot have duplicate level numbers here, else during
;running this, it will ONLY take the last level number of the duplicates
;matching with the current level number.
;
;Although I could simply only have the table [.OneHundredTwentyEightFlagGroupList], have the index be
;the level number (X ranging from $0000 to $01FF), and have the value $FF to indcate that the level does
;not use MBCM16, it is very possible that you may have levels that don't use MBCM16 at all, thus resulting
;lots of unused values in the table with $FF, which waste space.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.LevelList
	dw $01EB		;>Item 0 (X = $0000, Y = $0000)
	dw $01EC		;>Item 1 (X = $0002, Y = $0001)
	dw $01ED
	dw $01EE
	dw $01EF 
	dw $01F0
..End
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This table specifies what group-128 each level should use.
;Only enter numbers here as [$X0], where X is the group number in hex (therefore, numbers here must be
;multiples of 16: [ValueYouPutHere = GroupNumber * $10]).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.OneHundredTwentyEightFlagGroupList
	db $00			;>Item 0
	db $10			;>Item 1
	db $20
	db $30
	db $40
	db $50
..End