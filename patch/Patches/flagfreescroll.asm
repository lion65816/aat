if read1($00FFD5) == $23
	sa1rom
	!addr	= $6000
	!bank	= $000000
else
	lorom
	!addr	= $0000
	!bank	= $800000
endif

!Flag = $140B|!addr   ; The flag to use. Should be one byte of free RAM.

org $00F875|!bank
autoclean JML CheckFlag
NOP

freedata

CheckFlag:
LDA !Flag
BEQ NoFreeScroll

Scroll:
JML $00F881|!bank

NoFreeScroll:
LDA $1404|!addr
BNE Scroll
JML $00F87A|!bank

print "Inserted ",freespaceuse," bytes at PC address $",pc
