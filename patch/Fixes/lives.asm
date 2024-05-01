; This patch will fix the lives issue that the game has if you switch to Luigi in 1 player mode and keeps the life 
; exchanger in tact if you choose two player mode. Set !patch to 0 if you want to undo the changes although it really won't hurt anything if you don't 
; want to bother with it. The game will work fine even if you don't unpatch this. 

!base1 = $0000
!base2 = $0000

if read1($00FFD5) == $23
sa1rom
!base1 = $3000
!base2 = $6000
endif

!patch = 1 ; set to 0 if you want to undo the changes in this patch.

org $A0BF

autoclean JML New

freecode

New:
if !patch == 1
LDA $0DB2|!base2
BNE Player
LDA $0DBE|!base2
BPL ContinueEND
LDA #$01
STA $13C9|!base2
LDA #$FF
STA $0DBE|!base2 ; current player lives minus 1
JML $00A0C4

ContinueEND:
JML $00A0C7

Player:
LDA $0DBE|!base2
BPL +
INC $1B87|!base2
+
JML $00A0C7
else
LDA $0DBE|!base2
BPL +
INC $1B87|!base2
+
JML $00A0C7
endif