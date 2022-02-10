;Cape Kill Routine
;by A-l-e-x-99
;Based on the "Star.asm" macro file pre-packaged with Pixi(?), author unknown.
;I made this to fix a glitch with imamelia's Fire Snake sprite.
;The sprite is set, by default, to be immune to cape whacks,
;but when I made it killable by cape in Tweaker, this opened up a glitch
;where the kills accumulated, as if it had been killed by a star or Koopa shell.
;
;A routine to cape-kill a sprite if it can't use the existing code on its own.
;Doesn't check whether or not Mario actually has a cape.

		PHB
		PHK
		PLB
		JSL $01AB6F|!BankB
		LDA #$02                ; \ sprite status = 2 (being killed by cape)
		STA !14C8,x             ; /
		LDA #$D0                ; \ set y speed
		STA !AA,x               ; /
		JSR .SubHorzPos
		LDA .speed,y            ; \ set x speed based on sprite direction
		STA !B6,x               ; /
		LDA #$00				; Give Mario points.
		JSL $02ACEF|!BankB      ;
		LDA $03            		; |    ... play sound effect
		STA $1DF9|!Base2        ; /
		PLB						;
		RTL                     ; final return

.speed	db $F0,$10

.SubHorzPos
		LDY #$00
		LDA $94
		SEC
		SBC !E4,x
		STA $0E
		LDA $95
		SBC !14E0,x
		STA $0F
		BPL ?+
		INY		
?+		RTS
