; This will map player 1 and player 2's controls to player 1's controller. This effects 2 player games as well. If you want to undo this patch
; just set !patch to 0 or any number other than "1"  

!patch = 1 ; set to 0 if you want to set controls back to default.


org $86A0
if !patch == 1
db $9C,$A0,$0D,$AD,$A0,$0D,$A2,$00
else
db $AE,$A0,$0D,$10,$03,$AE,$B3,$0D
endif