if read1($00FFD5) == $23		; check if the rom is sa-1
	sa1rom
	!Base2 = $6000
	!BankB = $000000
	!E4 = $322C
else
	lorom
	!Base2 = $0000
	!BankB = $800000
	!E4 = $E4
endif


org $019162
autoclean JML Tidefix1

org $019183
autoclean JML Tidefix2


freecode


Tidefix1:
ADC $26
LDY $1403|!Base2
BNE .Dont
STA !E4,x
JML $019166|!BankB
.Dont
JML $01916E|!BankB

Tidefix2:
SBC $26
LDY $1403|!Base2
BNE .Dont
STA !E4,x
JML $019187|!BankB
.Dont
JML $01918F|!BankB