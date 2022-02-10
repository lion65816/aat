if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
	!9E = $3200
	!15EA = $33A2
else
	lorom
	!bank = $800000
	!9E = $9E
	!15EA = $15EA
endif

ORG $019821
autoclean JML Skip

ORG $01984D
autoclean JML BuzzyCheck
NOP

freecode

Skip:
PLA
STA !15EA,x
JML $01982A|!bank

BuzzyCheck:

LDA !9E,x
CMP #$11		; Exclude the Buzzy Beetle from the "Special World passed" check (never draw eyes).
BEQ .Return
LDA $9826		; LM modifies this ($1EEB) based on the "Special World Levels" setting for sprite graphics - indirect addressing makes checking that easy.
STA $00
LDA $9827
STA $01
LDA ($00)
BMI .Return		; Return (don't draw eyes) if Special World level passed.
JML $019853|!bank

.Return
JML $0198A6|!bank