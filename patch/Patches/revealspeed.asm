!sa1	= 0
!addr	= $0000
!bank	= $800000

if read1($00FFD5) == $23
	sa1rom
	!sa1	= 1
	!addr	= $6000
	!bank	= $000000
endif

if read1($04E6FA) == $62	;event path fade hack check.
	org $04EB38|!bank
	autoclean JML EventCheck : NOP #8	;vanilla hijack
endif

if read1($04E6FA) == $96	;I'll give you this though: not having lm's hijacks documented is not fun.
	org $04EACC|!bank
	autoclean JML LMEventCheck		;hack hijack
endif
	
freecode

incsrc revealspeed_settings.asm

EventCheck:
	LDY #!DefaultSpeed		;load reveal speed in Y (vanilla)
	LDX $1DEA|!addr			;\call & compare
	LDA.l EventTable,x		;/event number
	BMI +					;if negative ($FF), keep the default speed in Y
	TAY						;otherwise, transfer value from table to Y
+	JML $04EB46|!bank		;return.

LMEventCheck:
	LDA $04EAD1|!bank		;check the default speed in rom
	STA $03					;store to scratch ram
	LDX $1DEA|!addr			;\call & compare
	LDA.l EventTable,x		;/event number
	BMI +					;branch if negative
	INC						;increase by 1 to match the actual values
	STA $03					;store to scratch ram
	
+	LDA $1495|!addr			;\
	CLC						;|same as the lm hijack,
	ADC $03					;|except we add whatever is in our scratch ram here instead.
	STA $1495|!addr			;/
	
	JML $04EAD5|!bank		;return.