;  Sticky hands, by Darolac
; This code makes it so the first carriable sprite that 
; Mario takes on a level can't be discarded, so Mario 
; must keep carrying it until the end of the level.

main:
LDA $1470|!addr
ORA $148F|!addr
BEQ .notcarrying
LDA #$40
TSB $15
.notcarrying
RTL