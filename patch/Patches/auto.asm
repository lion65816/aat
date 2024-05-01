;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Auto-Scroll Speed Customizer, by imamelia
;;
;; This patch allows you to customize the speeds for the auto-scroll sprite (sprite F3).
;; You can have up to 16 different speeds.
;;
;; Usage instructions:
;;
;; Put your speeds in the "AutoScrollSpeeds:" table.  This is actually the number of
;; frames that will pass before the auto-scroll gets up to maximum speed.  The
;; first three are meant to mirror the original sprite approximately; technically, the
;; medium and fast auto-scroll sprites were never used in SMW anyway, but 0080
;; is about the speed of the slow one, 0100 is twice as fast, and 0300 is three times
;; as fast as the medium one.  The Y position of the sprite in Lunar Magic will
;; determine which speed setting it uses.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
header
if read1($00FFD5) == $23
	; SA-1 base addresses	;Give thanks to absentCrowned for this:
				;http://www.smwcentral.net/?p=viewthread&t=71953
	!Base1 = $3000		;>$0000-$00FF -> $3000-$30FF
	!Base2 = $6000		;>$0100-$0FFF -> $6100-$6FFF and $1000-$1FFF -> $7000-$7FFF
	sa1rom
else
	; Non SA-1 base addresses
	!Base1 = $0000
	!Base2 = $0000
endif

org $05C00D
autoclean JML SetAutoScrollSpeed
NOP

org $05C79E
CMP $1440|!Base2

freecode

AutoScrollSpeeds:
dw $0080,$0100,$0300,$0000,$0000,$0000,$0000,$0000
dw $0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

SetAutoScrollSpeed:
PHB
PHK
PLB
TYA
LSR #2
TAY
REP #$20
LDA AutoScrollSpeeds,y
STA $1440|!Base2
PLB
JML $05C012
print "Freespace used: ",bytes," bytes."

