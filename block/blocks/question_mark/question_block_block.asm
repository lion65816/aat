; Block specific defines
!SoundEffect = $03			; Set to zero to play no sound effect
!APUPort = $1DFC|!addr		; Refer to the RAM Map or AMK for more information

!bounce_num			= $03	; See RAM $1699 for more details. If set to 0, the block changes into the Map16 tile directly
!bounce_direction	= $00	; Should be generally $00
!bounce_block		= $0D	; See RAM $9C for more details. Can be set to $FF to change the tile manually
!bounce_properties	= $00	; YXPPCCCT properties

; If !bounce_block is $FF.
!bounce_Map16 = $0132		; Changes into the Map16 tile directly (also used if !bounce_num is 0x00)
!bounce_tile = $2A			; The tile number (low byte) if BBU is enabled

!item_memory_dependent = 0	; Makes the block stay collected
!invisible_block = 0		; Not solid, doesn't detect sprites, can only be hit from below
!activate_per_spin_jump = 0	; Activateable with a spin jump (doesn't work if invisible)
; 0 for false, 1 for true


; Placed there for technical reasons
incsrc question_block_base.asm


; Spawn specific defines
!new_map16_tile = $006E		; The Map16 tile which should be generated

!spawn_smoke = 1			; Whether a smoke is spawned at the block or not

; Only multiples of $10 are allowed
!XPlacement = $00			; Remember: $01-$7F moves the enemy to the right and $80-$FF to the left.
!YPlacement = $F0			; Remember: $01-$7F moves the enemy to the bottom and $80-$FF to the top.


; Code stuff
SpawnThing:
	LDA $9A
	PHA
	AND #$F0
	CLC : ADC #!XPlacement
	STA $9A
	LDA $9B
	PHA
if !XPlacement < $80
	ADC #$00
else
	SBC #$00
endif
	STA $9B
	LDA $98
	PHA
	AND #$F0
	CLC : ADC #!YPlacement
	STA $98
	LDA $99
	PHA
if !YPlacement < $80
	ADC #$00
else
	SBC #$00
endif
	STA $99

if !bounce_num
	%swap_XY()
endif

	REP #$10
	LDX #!new_map16_tile
	%change_map16()
	SEP #$10

if !spawn_smoke
	%create_smoke()
endif

	PLA
	STA $99
	PLA
	STA $98
	PLA
	STA $9A
	PLA
	STA $9B

.Return:
RTS

print "A question mark block which spawns a Map16 tile $",hex(!new_map16_tile),"."
