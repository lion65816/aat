;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check if player presses left or right in the direction
;of the block from either left or rightside.
;Carry = Set if player is pressing right on the left side of the block
; or pressing left on the right side of the block. Clear otherwise.
;
;When used for the keylock gates, is to prevent accidental triggering of
;the block.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	REP #$20
	LDA $9A
	AND #$FFF0
	CMP $94
	SEP #$20
	BMI ?PlayerRightSideOfBlock
	
	;?PlayerLeftSideOfBlock
	LDA $15
	BIT.b #%00000001
	BNE ?Set
	BRA ?Clear
	
	?PlayerRightSideOfBlock
	LDA $15
	BIT.b #%00000010
	BNE ?Set
	
	?Clear:
	CLC
	RTL
	
	?Set:
	SEC
	RTL