;Common stomp code from SMW, slightly optimized
;Just like %Star() doesn't check wether Mario actually stomped sprite.
;What this does is only spawn score, plays sound effect
;unlike %Star() however, this doesn't set dead sprite status, so you can set it to whatever value afterwards

LDA $1697|!Base2		;
CLC : ADC !1626,x		;
INC $1697|!Base2		;Consecutive enemies stomped + 1
TAY				;
INY				;
CPY #$08			;1-up does sound effect on it's own
BCS .NoStompSound		;
CLC : ADC #$13			;add offset
STA $1DF9|!Base2		;

.NoStompSound
TYA				;if not 1-up only time
CMP #$08			;
BCC .Continue			;give score like normal

LDA #$08			;1-ups only

.Continue
JSL $02ACE5|!BankB		;give score
RTL				;