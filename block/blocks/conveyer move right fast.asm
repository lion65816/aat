;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; custom conveyer block          by EternityLarva
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "conveyer move right fast"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;switch (check 00 or not00)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  0   - no switch
;$14AF - on/off
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!switch  = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;reverse flag 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;0 - normal
;1 - reverse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!isReverse = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;speed (super mario maker style)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;$01 - fast
;$03 - normal
;$07 - slow
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!speed = $01


db $42
JMP MarioBelow : JMP MarioAbove : JMP Return
JMP SpriteV : JMP Return : JMP Return : JMP Return
JMP Corner : JMP Return : JMP Return

Corner:
MarioAbove:
	LDA $14
	AND #!speed 
	BNE Return
	if !switch != 0
		LDA !switch          ;\mario xpos - 1 if switch is off
		if !isReverse == 0
			BNE mario_subtract
		else
			BNE mario_add
		endif
	endif
	if !isReverse != 0
		BRA mario_subtract
	endif
mario_add:
	LDA $94              ;\
	CLC                  ;|
	ADC #$01             ;|
	STA $94              ;|mario xpos + 1
	LDA $95              ;|
	ADC #$00             ;|
	STA $95              ;/
	RTL

MarioBelow:
	LDA $14
	AND #!speed
	BNE Return
	if !switch != 0
		LDA !switch          ;\mario xpos + 1 if switch is off
		if !isReverse == 0
			BNE mario_add
		else
			BNE mario_subtract
		endif
	endif
	if !isReverse != 0
		BRA mario_add
	endif

mario_subtract:
	LDA $94              ;\
	SEC                  ;|
	SBC #$01             ;|
	STA $94              ;|mario xpos - 1
	LDA $95              ;|
	SBC #$00             ;|
	STA $95              ;/
Return:
	RTL

SpriteV:
	LDA $14
	AND #!speed
	BNE Return
	LDA !AA,x
	BMI +
	if !switch != 0
		LDA !switch          ;\sprite xpos + 1 if switch is off
		if !isReverse == 0
			BNE sprite_subtract
		else
			BNE sprite_add
		endif
	endif
	if !isReverse != 0
		BRA sprite_subtract
	endif
sprite_add:
	LDA !E4,x            ;\
	CLC                  ;|
	ADC #$01             ;|
	STA !E4,x            ;|sprite xpos + 1
	LDA !14E0,x          ;|
	ADC #$00             ;|
	STA !14E0,x          ;/
	RTL

+
	if !switch != 0
		LDA !switch          ;\sprite xpos - 1 if switch is off
		if !isReverse == 0
			BNE sprite_add
		else
			BNE sprite_subtract
		endif
	endif
	if !isReverse != 0
		BRA sprite_add
	endif

sprite_subtract:
	LDA !E4,x            ;\
	SEC                  ;|
	SBC #$01             ;|
	STA !E4,x            ;|sprite xpos - 1
	LDA !14E0,x          ;|
	SBC #$00             ;|
	STA !14E0,x          ;/
	RTL
