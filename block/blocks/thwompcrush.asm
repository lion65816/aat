;This block shatters when hit by a Thwomp
;by Roy
;act like 130
; PSI Ninja edit: Added SpriteH code from shatter_sprite.asm.

print "Thwomp Crush Block\nA block that shatters when hit by a Thwomp."

!RiseUp = 1 ; rise up (0 = Set it to 0 if you don't want the Thwomp to rise up)

db $37

JMP Return : JMP Return : JMP Return
JMP SpriteV : JMP SpriteH
JMP Return : JMP Return
JMP Return : JMP Return : JMP Return
JMP Return : JMP Return


!CUSTOM_SPRITE = $55    ; set custom sprite
!NORMAL_SPRITE = $26    ; set normal sprite

!SHAKE_TIMER = $18      ; time to shake the ground
!SOUND_EFFECT = $09     ; set sound effect
!TIME_TO_RISE = $40     ; time to rise up
!SHATTER_TYPE = $00     ; 00 = normal, FF = flashing


SpriteV:
	LDX $15E9|!addr         ; load sprite index
	LDA !7FAB10,x           ; \ check if its a custom sprite...
	AND #$08                ;  |
	BEQ Normal              ; /
Custom:
	LDA !7FAB9E,x           ; \ if its a certain custom sprite...
	CMP #!CUSTOM_SPRITE     ;  |
	BNE Return              ; /
	BRA Status
	
Normal:
	LDA !9E,x               ; \ if the sprite is a thwomp...
	CMP #!NORMAL_SPRITE     ;  |
	BNE Return              ; /
Status:
	LDA !14C8,x             ; \ if the sprite is alive...
	CMP #$08                ;  |
	BNE Return              ; /

Crush:
	LDA !E4,x               ; \ setup block properties
	STA $9A                 ;  |
	LDA !14E0,x             ;  |
	STA $9B                 ;  |
	LDA !D8,x               ;  |
	CLC                     ;  |
	ADC #$20                ;  | set y position
	STA $98                 ;  |
	LDA !14D4,x             ;  |
	ADC #$00                ;  |
	STA $99                 ; /
	
	JSR Shatter_Routine     ; go to shatter block routine
	
	LDA $9A                 ; \ setup block properties
	CLC                     ;  |
	ADC #$10                ;  | set x position
	STA $9A                 ;  |
	LDA $9B                 ;  |
	ADC #$00                ;  |
	STA $9B                 ; /
	
	JSR Shatter_Routine     ; go to shatter block routine

	if !RiseUp
		LDA #!SHAKE_TIMER       ; \ amount of time the ground shakes
		STA $1887|!addr         ; / 
		LDA #!SOUND_EFFECT      ; \ set sound effect
		STA $1DFC|!addr         ; / sound effect bank $1DFC
		INC !C2,x               ; set Thwomp to rise up
		LDA #!TIME_TO_RISE      ; \ amount of time it takes Thwomp to get back up
		STA !1540,x             ; /
	endif

Return:
	RTL                     ; return

Shatter_Routine:
	%erase_block()
	PHK                     ; push bank register
	PER Return_Add-$01	    ; push return address -1 
	PEA $8020		        ; push return address containing PLB + RTL
	LDY #!SHATTER_TYPE      ; set animation for the shatter
	JML $0199F8|!bank       ; shatter block routine
Return_Add:
	RTS                     ; return

SpriteH:
	%sprite_block_position()
	%shatter_block()
	RTL
