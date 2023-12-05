	incsrc powerupfilters_settings.asm
	
init:
	jsl retry_level_init_2_init
	LDA $89					;\with this, the filter will only take effect after the no yoshi intro cutscene
	BNE .EndLevelHandle		;/feel free to remove these lines if you want to remove that effect.
	
	LDX $13BF|!addr			;load current translevel as table index
	LDA FilterTable,x		;\
	BEQ .EndLevelHandle		;/if $00, skip over
	CMP #$04
	BCS .BigPowerupFilter
	CMP #$01
	BEQ .MushroomFilter
	
	;this handles the fire only and feather only filters simultaneously by preserving $02 or $03 in A
	CMP $19
	BNE +
	STA !FilterRAM		;store filtered powerup to ram
	STZ $19				;\
	INC $19				;/make player big
	
	;quick item box format conversion
+	CMP #$02
	BEQ +
	DEC			;flower $03 -> $02
	BRA ++
+	ASL			;feather $02 -> $04
	
++	CMP $0DC2|!addr
	BNE .EndLevelHandle		;branch if item box does not have the filtered powerup
	BRA ++					;branch to a place where the item box is handled
	
.BigPowerupFilter	
	LDA $19
	CMP #$02
	BCC +				;branch if powerup state is lower than $02
	STA !FilterRAM		;store filtered powerup to ram
	STZ $19				;\
	INC $19				;/make player big
	
+	LDA $0DC2|!addr
	CMP #$02
	BCC .EndLevelHandle		;branch if item box is lower than $02
++	ASL						;\
	ASL						;|store current item box item to ram in our format
	TSB !FilterRAM			;/
	LDA #$01				;\
	STA $0DC2|!addr			;/store mushroom in item box
	BRA .EndLevelHandle
	
.MushroomFilter
	LDA $19
	BEQ +				;branch if already small
	STA !FilterRAM		;store filtered powerup to ram
	STZ $19				;make player small
	
+	LDA $0DC2|!addr	
	BEQ +				;branch if item box is empty
	ASL					;\
	ASL					;|store current item box item to ram in our format
	TSB !FilterRAM		;/
	STZ $0DC2|!addr		;empty out item box
+	if !ruleset
		LDA #$80		;\
		TSB !FilterRAM	;/set small filter fingerprint
	endif
	
.EndLevelHandle
	RTL
	
	incsrc powerupfilters_table.asm
