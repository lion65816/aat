;Fast Bg scroll, but in Uberasm version.
;Dissasembled and optimised by Darolac.

!flag = 0	; set this to anything but 0 to make the BG scroll activate
			; only when Mario steps on the unused orange platform (sprite 5E)
			; or the flying turn blocks (sprite C1), like the original.

init:
REP #$20
LDA #$0D00
STZ $1446|!addr
STZ $144E|!addr
STZ $144A|!addr
SEP #$20
STZ $1413|!addr
RTL

main:
if !flag
LDA $1B9A|!addr					;$05C7BC	|
BEQ .return
endif
LDA $9D
ORA $13D4|!addr
BNE .return
LDA #$02
STA $56
REP #$20
;LDA $144A|!addr
;CMP #$0400
;BEQ +
;INC A
;+
LDA #$0400	;> Edit: Skips the acceleration period. (Source: https://www.smwcentral.net/?p=viewthread&t=119248)
STA $144A|!addr

LDA $1452|!addr
AND #$00FF
CLC
ADC $144A|!addr
STA $1452|!addr
AND #$FF00
BPL +
ORA #$00FF
+
XBA
CLC
ADC $1466|!addr
STA $1466|!addr

LDA $17BD|!addr
AND #$00FF
CMP #$0080
BCC +
ORA #$FF00
+
CLC
ADC $1466|!addr
STA $1466|!addr
.return
SEP #$20
RTL