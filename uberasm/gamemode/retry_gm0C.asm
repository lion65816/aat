	incsrc powerupfilters_settings.asm
	
init:
	jsl retry_load_overworld_init
	LDA !FilterRAM
	BEQ .EndOWHandle	;if nothing is stored, skip over
	AND #$83			;clear all but the powerup+fingerprint bits
	if !ruleset
		BIT #$80		;\
		BNE ++			;/ignore this check if this is the small filter
		LDX $19			;\
		BEQ +			;/if player lost mushroom, don't give their powerup back 
++		AND #$03		;clear fingerprint
	endif
	BEQ +				;skip if empty
	STA $19				;store
+	LDA !FilterRAM		;load again
	LSR					;\
	LSR					;/shift back the item box bits
	if !ruleset
		BIT #$20			;\
		BNE +				;/again, ignore this check if this is the small filter
		LDX $0DC2|!addr		;\
		BEQ .EndOWHandle	;/if player lost item box mushroom, don't give their item back
+		AND #$07			;clear fingerprint
	endif
	BEQ .EndOWHandle	;skip if empty
	STA $0DC2|!addr		;and store back
	
.EndOWHandle
	STZ !FilterRAM		;clear ram
	RTL
