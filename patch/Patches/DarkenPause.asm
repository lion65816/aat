;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Darken the screen when you pause
;Made by GhettoYouth, tweaked by Ersanio, edited by Ultimaximus
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Some variables you can change

!Pause		= $11			;Pause SFX, change to 12 to allow music playing
!Unpause	= $12			;Unpause SFX
!Pausebright	= $06			;Pause brightness - dark
!Unpausebright	= $0F			;Unpaused brightness - normal

if read1($00FFD5) == $23
	sa1rom
	!base1 = $3000
	!base2 = $6000
	!base3 = $000000
else	
	lorom
	!base1 = $0000
	!base2 = $0000
	!base3 = $800000
endif

ORG $00A233|!base3
autoclean JSL Paused
BRA Nonop
NOP #9
Nonop:

freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+

Paused:
LDA $13D4|!base2
BNE NotPause
Pause:
LDA #$01
STA $13D4|!base2
LDA #!Pausebright
STA $0DAE|!base2
LDA #!Pause
STA $1DF9|!base2
RTL

NotPause:
STZ $13D4|!base2
LDA #!Unpausebright
STA $0DAE|!base2
LDA #!Unpause
STA $1DF9|!base2
RTL