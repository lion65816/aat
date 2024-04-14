;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Enabling extra bit for side exit sprite ($8C) will make it trigger goal on side exit.
;since X-position determines whether or not it spawns smoke, it uses Y-position for which exit to trigger.
;
;Y = 0 - Trigger normal exit
;Y = 1 - Trigger Secret exit 1
;Y = 2 - Trigger Secret exit 2
;Y = 3 - Trigger Secret exit 3
;after which value repeats.
;
;By RussianMan. Credit is optional.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!addr = $0000
!bank = $800000
!7FAB10 = $7FAB10
!D8 = $D8

if read1($00FFD5) == $23	;sa-1 compatibility
sa1rom
!addr = $6000
!bank = $000000
!7FAB10 = $400040
!D8 = $3216
endif

org $00E99C			;replace original side exit handling
autoclean JSL SideExitTrigger	;

org $02F4D5			;hijack sprite
autoclean JSL SideScreenSet	;
NOP				;

freecode

SideExitTrigger:
LDA $1B96|!addr			;
DEC				;vanilla sprite set to 1
BEQ .Vanilla			;so if it is 1, trigger vanilla side exit (no event trigger)
;INC				;i won't reload value, instead i'll restore it by increasing
;DEC

;STZ $0109			;
STA $13CE|!addr			;
INC $1DE9|!addr			;

JML $05B165			;exit to OW with event

.Vanilla
JML $05B160|!bank		;exit to OW w/o event

SideScreenSet:
LDA !7FAB10,x			;check extra bit
AND #$04			;if isn't set, act as vanilla
BEQ .store			;

LDA !D8,x			;Y-positon determines exit triggered
LSR #4				;
AND #$03			;
INC				;+1 and +1 after that so it's minimum 2 (which triggers goal)

.store
INC				;
STA $1B96|!addr			;
RTL				;