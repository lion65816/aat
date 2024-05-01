; Increase Torpedo Ted arm launcher priority in Level 10E specifically.
; Patch by PSI Ninja.

sa1rom

!addr = $6000
!bank = $000000

org $029E71|!bank
	autoclean JSL torpedo_ted_priority

freecode

torpedo_ted_priority:
	PHA				;> Preserve the extended sprite's properties.
	LDA $13BF|!addr	;\ If not Level 10E,
	CMP #$32		;| then use the original priority.
	BNE +			;/
	PLA				;> Restore the extended sprite's properties.
	AND #$00		;\ Change priority to 2.
	ORA #$23		;/
	BRA .return
+
	PLA				;> Restore the extended sprite's properties.
	AND #$00		;\ Original code.
	ORA #$13		;/
.return
	RTL
