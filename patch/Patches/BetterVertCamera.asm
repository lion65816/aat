;do not change anything in this file.
;open BetterVertCamTable.asm to set up your camera.
 
;------------------------------------------------------------------------------------------
;Defines
;------------------------------------------------------------------------------------------

if read1($00FFD5) == $23
    sa1rom
    !sa1  = 1
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1  = 0
    !addr = $0000
    !bank = $800000
endif
;------------------------------------------------------------------------------------------
;Main Code
;------------------------------------------------------------------------------------------
org $05D8B9
	JSR LevelNumCode

org $05DC46
LevelNumCode:
	LDA.b $0E  						;|\ 
	STA.w $010B|!addr				;|| Store Level number to RAM
	ASL A							;|/
RTS
	
org $00F805
	autoclean JML BetterVertCam
	NOP
	
org $00F810
	autoclean JSL PosStopScroll
	
freecode
;------------------------------------------------------------------------------------------
BetterVertCam:
    PHB								;|\ 
    PHK								;|| Set and preserve bank
    PLB								;|/
	REP #$10						;16-bit XY
	LDA $010B|!addr					;|\ Set Y = index
	TAY								;|/
	SEP #$20						;8-bit A
	LDA #$00						;|\ Set 00 as high byte for A
	XBA								;|/
	LDA YPosTriggerTable,y			;load A low byte from table
	SEP #$10						;8-bit XY
	REP #$20						;16-bit A
	STA $02							;store result to scratch RAM
	LDA $00							;|\ Compare both values to determine scroll direction
	CMP $02							;|/
	BMI ClearY						;branch if scrolling upwards
	LDY #$02						;|\ Else, Y = 2 for scrolling downwards.
	BRA Return						;|/ Y is used to determine the direction of vertical scroll
ClearY:
	LDY #$00						;Y = 0 , going upwards
Return:
	PLB								;pull previous bank
	JML $00F80C						;return to the original routine to set scrolling direction
;------------------------------------------------------------------------------------------
PosStopScroll:
    PHB								;|\ 
    PHK								;|| Set bank, also
    PLB								;|| preserve bank...
	PHX 							;|| X...
	PHA								;|/ and A!
	REP #$10						;16 bit XY
	LDA $010B|!addr					;|\ Set X as table index
	TAX								;|/
	PLA								;|\ Pull A to decide vertical scroll direction,
	PHA								;|| by setting Y = A,
	TYA								;|/ but also preserve A for later
	BEQ ScrollUpwards				;branch if A = 0, scrolling upwards	
ScrollDownwards:									 
	SEP #$20						;8-bit A
	LDA #$00						;|\ Set 00 as high byte for A
	XBA								;|/
	LDA ScrollStopDownTable,x		;load A low byte from table
	REP #$20						;16-bit A
	STA $00							;store to scratch RAM for later
	PLA								;|\ 
	SEC								;|| Substract calculated value from A
	SBC $00							;|/
	BRA Return2 					;finally, prepare data to jump back to the vanilla routine
ScrollUpwards:
	SEP #$20						;8-bit A
	LDA #$00						;|\ Set 00 as high byte for A
	XBA								;|/
	LDA ScrollStopUpTable,x			;load A low byte from table
	REP #$20						;16-bit A
	STA $00							;store to scratch RAM for later
	PLA								;|\ 
	SEC								;|| Substract calculated value from A
	SBC $00							;|/
Return2:
	SEP #$10						;8 bit XY
	PLX								;|\ restore X...
	PLB								;|/ and bank.
RTL									;return to the original routine (which stores A to scratch RAM)

incsrc "BetterVertCamTable.asm"