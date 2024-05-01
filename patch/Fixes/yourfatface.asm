if read1($00FFD5) == $23		; check if the rom is sa-1
	sa1rom
else
	lorom
endif

org $02D214
autoclean JSL Mymain

freespace noram
Mymain:
LDA $15
AND #$03
BEQ .Ret
TAY
AND #$01
STA $76
TYA
.Ret
RTL