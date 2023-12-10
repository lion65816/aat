;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This routine searches what key counter to use based on what level the player is in.
;
;Although I could have the tables do it this way:
;
;Index = $01FF ;Index = level number
;Table:
;db $xx		;>Level Number $0000
;db $xx		;>Level Number $0001
;;[...]
;db $xx		;>Level Number $01FF
;
;This would cost more space than this method of having only the levels that uses the lock and
;key mechanic.
;
;Output:
; -A (8-bit): A number 0-255 to be used as an index from !Freeram_KeyCounter.
; -Carry (check using BCC/BCS): Set if you are trying to use this block in a level that isn't
;  assigned to what key counter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	PHX							;>This is needed if you are going to have sprites interacting with this block.
	PHY
	PHB							;>Preserve bank
	PHK							;\Adjust bank for any $xxxx,y
	PLB							;/
	REP #$30
	LDX.w #(?LevelList_End-?LevelList)-2			;>Start at the last index.
	LDY.w #((?LevelList_End-?LevelList)/2)-1
	-
	LDA $010B|!addr						;\Check if the current level matches with one item in list.
	CMP ?LevelList,x					;|
	BNE +							;/>Next if not match.
	
	SEP #$20						;\Level found
	LDA ?KeyCountList,y					;|
	CLC							;|
	BRA ++							;/
	
	+
	DEY							;\Next item over
	DEX #2							;/
	BPL -							;>Loop till X=$FFFE (no match found), thankfully, 255*2 = 510 ($01FE) is less than 32768 ($8000).
	SEC							;>If no levels matching found, set the carry.
	
	++
	SEP #$30
	PLB							;>Restore bank.
	PLY
	PLX							;>Restore potential sprite index.
	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of level numbers. This is essentially what key counter the levels are associated with.
;
;Note: you can't have duplicate level numbers here.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?LevelList:
	dw $01EB			;>Index = $0000 ($0000)
	dw $01EC			;>Index = $0000 ($0002)
	dw $01ED			;>Index = $0002 ($0004)
	dw $01EE
	dw $01EF			;>Index = $0003 ($0006)
	dw $01E2
?.End
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;List of what key counter the levels should use.
;You can have 2+ levels using the same key counter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
?KeyCountList:
	db $00				;>Index = $0000
	db $00				;>Index = $0001
	db $00				;>Index = $0002
	db $00				;>Index = $0003
	db $00

?.End