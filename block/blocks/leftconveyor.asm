;Left Conveyor Block
;by HackerOfTheLegend

print "A left conveyor block."

db $42

JMP End : JMP Mario : JMP End : JMP End : JMP End : JMP End : JMP End : JMP Mario : JMP End : JMP End

Mario:
LDA $94
SEC
SBC #$01 ;Increase this number to make the belt go faster. Any number higher than 9 is bad.
STA $94
LDA $95
SBC #$00
STA $95
End:
RTL