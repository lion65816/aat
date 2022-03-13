;############################################;
;# Cluster Bullet Shooter                   #;
;# By MiniMawile303                         #;
;# Credit if used, do not claim as your own #;
;############################################;

;###########################################################################################################;
;# Extra Byte/Bit Information                                                                              #;
;#                                                                                                         #;
;# Extra Bit                - If clear, it shoots at a specified angle (extra bit = 2)                     #;
;#                            If set, it shoots while aimed at the player (extra bit = 3)                  #;
;#                                                                                                         #;
;# Extra Byte 1             - Reserved for future expansion (leave as $00)                                 #;
;#                                                                                                         #;
;# Extra Byte 2             - Rate, how often the shooter... shoots. ANDed with the global timer ($14)     #;
;#                            $07: shoot 1 bullet, every 8 frames                                          #;
;#                            $33: shoot 4 bullets rapidly, every 64 frames                                #;
;#                                                                                                         #;
;# Extra Byte 3             - Speed of bullet, not based on x/y direction (basically the hypotenuse)       #;
;#                            Use values between $00 and $7F, where $7F is faster (really fast)            #;
;#                            $80-$FF also work, but note they'll shoot opposite to where you intend       #;
;#                                                                                                         #;
;# Extra Byte 4             - Angle of bullet (unused if extra bit is set, since the aim overrides angle)  #;
;#                            $00: shoot going right                                                       #;
;#                            $40: shoot going down                                                        #;
;#                            $80: shoot going left                                                        #;
;#                            $C0: shoot going up                                                          #;
;#                            And of course any values in between would give diagonals                     #;
;#                                                                                                         #;
;# Extra Byte 5             - Offset from timer, basically how much to desync (wait) from the global timer #;
;#                                                                                                         #;
;# Extra Byte 6             - Shoot if parameter is met, such as a switch being active or not              #;
;#                            $00: no parameter, shoot normally                                            #;
;#                            $01: shoot only if on/off switch is ON                                       #;
;#                            $02: shoot only if on/off switch is OFF                                      #;
;#                            $03: shoot only if blue pswitch is ACTIVE                                    #;
;#                            $04: shoot only if blue pswitch is INACTIVE                                  #;
;#                            $05: shoot only if silver pswitch is ACTIVE                                  #;
;#                            $06: shoot only if silver pswitch is INACTIVE                                #;
;#                            $07: shoot only if first RNG value ($148D) is POSITIVE                       #;
;#                            $08: shoot only if first RNG value ($148D) is NEGATIVE                       #;
;#                            $09: shoot only if second RNG value ($148E) is POSITIVE                      #;
;#                            $0A: shoot only if second RNG value ($148E) is NEGATIVE                      #;
;#                                 I have no idea why you would want to use RNG but it's there if you want #;
;#                            $0B: shoot only if player is on shooter's RIGHT SIDE                         #;
;#                            $0C: shoot only if player is on shooter's LEFT SIDE                          #;
;#                            $0D: shoot only if player is BELOW SHOOTER                                   #;
;#                            $0E: shoot only if player is ABOVE SHOOTER                                   #;
;#                            $0F-$1F: reserved for potential future expansion, do not use                 #;
;#                            $20-$7F: open for your own usage, requires writing your own code though      #;
;#                            $80-$FF: do not use                                                          #;
;#                                                                                                         #;
;# Extra Byte 7             - Bullet timer, how many frames the bullet stays active before disappearing    #;
;#                            $00: stays active indefinitely (or at least until it goes offscreen)         #;
;#                            $01-$FF: number of frames before the bullet just disappears                  #;
;#                            This might be limited to $1F in order to save bits for future settings       #;
;#                                                                                                         #;
;# Extra Byte 8             - Bullet limit, how many bullets the shooter can shoot before deactivating     #;
;#                            $00: no bullet limit, can shoot forever                                      #;
;#                            $01-$FF: number of bullets the shooter can shoot                             #;
;#                            This might be limited to $1F in order to save bits for future settings       #;
;#                                                                                                         #;
;# Extra Byte 9             - Sprite to attach to, vanilla sprite number that shooter will latch to        #;
;#                            $00: do not attach to anything, RIP green koopa, no shell shooter            #;
;#                            $C9-$FF: do not use, as vanilla uses these for generators, shooters, etc     #;
;#                            I plan on adding compatability with custom sprites eventually, but not now   #;
;#                            To make the sprite attach, place the shooter on the same x tile as the host  #;
;#                            sprite. For sprites that are sort of halfway between two tiles, placing the  #;
;#                            shooter on either tile should work just fine                                 #;
;#                                                                                                         #;
;# Extra Byte 10            - Y/X offset, shifts the shooter slightly from the sprite it attaches to       #;
;#                            Format: yyyyxxxx, where the offset is counted by every 8 pixels (half tile)  #;
;#                            The highest y bit marks its sign, shifting up instead of down                #;
;#                            The highest x bit marks its sign, shifting left instead of right             #;
;#                            $00: no y offset, no x offset                                                #;
;#                            $01: no y offset, x shifted half a tile to the right                         #;
;#                            $10: y shifted half a tile downward, no x offset                             #;
;#                            $77: y shifted 4 tiles downward, x shifted 4 tiles to the right              #;
;#                                                                                                         #;
;# Extra Byte 11            - Reserved for future expansion (leave as $00)                                 #;
;#                                                                                                         #;
;# Extra Byte 12            - Reserved for future expansion (leave as $00)                                 #;
;#                                                                                                         #;
;# Extra Property Byte 1    - Tile number for the bullet to use                                            #;
;#                            $C2: default, smiley coin but replaced by a plasma ball exanimation          #;
;#                                                                                                         #;
;# Extra Property Byte 2    - yxppccct value for the bullet to use                                         #;
;#                            $3E: default, highest priority with palette F                                #;
;#                                                                                                         #;
;###########################################################################################################;

;#####################;
;# Defines and Stuff #;
;#####################;

	!bulletAmount         = 20					; maximum number of cluster bullets to have on screen, do not set higher than 20 or I will be sad
	!bulletSpriteNum      = $10					; cluster sprite number as defined in list.txt

	!shootSFX             = $27					; if $00, it won't play a sound effect
	!shootChannel         = $1DFC|!addr			; should either be $1DF9 or $1DFC. check out https://www.smwcentral.net/?p=viewthread&t=6665 for a detailed list of sound effecta
	
	; do not edit anything past this point, unless you know what you're doing

	!cluster_speed_y      = $1E52|!addr
	!cluster_speed_x      = $1E66|!addr
	!cluster_speed_y_frac = $1E7A|!addr
	!cluster_speed_x_frac = $1E8E|!addr
	
	!cluster_expire_timer = $0F4A|!addr
	!cluster_tile         = $0F72|!addr
	!cluster_props        = $0F86|!addr
	
	!shotCounter          = !1504
	!attachedSpriteIndex  = !1510

	!EB1_reserved         = $00
	!EB2_shootRate        = $01
	!EB3_bulletSpeed      = $02
	!EB4_bulletAngle      = $03
	!EB5_timerOffset      = $04
	!EB6_parameter        = $05
	!EB7_bulletTimer      = $06
	!EB8_shotCap          = $07
	!EB9_attachNum        = $08
	!EB10_attachOffsets   = $09
	!EB11_reserved        = $0A
	!EB12_reserved        = $0B
	
;######################;
;# Parameter Pointers #;
;######################;

parameterPointers:
	dw NoParameter				; $00
	
	dw OnOff_isON				; $01
	dw OnOff_isOFF				; $02
	dw BlueP_isACTIVE			; $03
	dw BlueP_isNOTACTIVE		; $04
	dw SilverP_isACTIVE			; $05
	dw SilverP_isNOTACTIVE		; $06
	dw RNG1_isPOSITIVE			; $07
	dw RNG1_isNEGATIVE			; $08
	dw RNG2_isPOSITIVE			; $09
	dw RNG2_isNEGATIVE			; $0A
	dw Player_onRIGHT			; $0B
	dw Player_onLEFT			; $0C
	dw Player_isBELOW			; $0D
	dw Player_isABOVE			; $0E

	dw Reserved_0F				; $0F
	dw Reserved_10				; $10
	dw Reserved_11				; $11
	dw Reserved_12				; $12
	dw Reserved_13				; $13
	dw Reserved_14				; $14
	dw Reserved_15				; $15
	dw Reserved_16				; $16
	dw Reserved_17				; $17
	dw Reserved_18				; $18
	dw Reserved_19				; $19
	dw Reserved_1A				; $1A
	dw Reserved_1B				; $1B
	dw Reserved_1C				; $1C
	dw Reserved_1D				; $1D
	dw Reserved_1E				; $1E
	dw Reserved_1F				; $1F
	
	; if you wanted to write your own custom parameter checks, you would write the pointer here.
	; then where all these pointers are, you'd add the code under everything else.

;##########################;
;# Init and Main Wrappers #;
;##########################;

print "INIT ",pc
	LDA #$FF
	STA !attachedSpriteIndex,x

	LDA !extra_byte_1,x				; \ set up the 12 extra bytes
	STA $0A							; |
	LDA !extra_byte_2,x				; |
	STA $0B							; |
	LDA !extra_byte_3,x				; |
	STA $0C							; /
	
	LDY #!EB8_shotCap				; \ load the shot cap and store it to easily accessible RAM
	LDA [$0A],y						; |
	STA !shotCounter,x				; /
	
	JSR AttachToSprite

	RTL

print "MAIN ",pc
	PHB : PHK : PLB
	JSR SpriteCode
	PLB
	RTL

;################;
;# Main Routine #;
;################;

SpriteCode:
	LDA !extra_byte_1,x				; \ set up the 12 extra bytes
	STA $0A							; |
	LDA !extra_byte_2,x				; |
	STA $0B							; |
	LDA !extra_byte_3,x				; |
	STA $0C							; /

	LDA #$00
	%SubOffScreen()					; don't try shooting when offscreen
	
	LDA $9D							; \ if sprites are locked, don't do things
	BNE .done						; /
	
	LDA #$01						; \ run cluster sprite code
	STA $18B8|!addr					; /
	
	LDA !sprite_status,x			; \ if not normal status, don't run
	CMP #$08						; |
	BNE .done						; /
	
	JSR AttachToSprite

	LDY #!EB5_timerOffset			; \ store timer offset into scratch
	LDA [$0A],y						; |
	STA $00							; /
	
	LDY #!EB2_shootRate				; \ store fire rate into scratch
	LDA [$0A],y						; |
	STA $01							; /
	
	LDA $14							; \ load the global timer
	SEC : SBC $00					; | add in the offset
	AND $01							; | AND it with how often you want to shoot for
	BNE .done						; / if not zero, don't shoot
	
	LDY #!EB6_parameter				; load parameter index
	
	CLC								; \ clear carry, it will be set if the parameter is met. if not met, then the bullet won't shoot
	LDA [$0A],y						; | load parameter settings from extra byte
	ASL								; | 
	TAX								; | 
	JSR (parameterPointers,x)		; / jump to parameter check routine
	
	BCC .done						; \ if carry is clear, don't shoot a bullet
	JSR GenerateBullet				; / shoot the bullet
	
	.done
	RTS
	
GenerateBullet:
	LDY #!bulletAmount-1			; \ load the highest possible slot index
	-								; | 
	LDA !cluster_num,y				; | load the cluster sprite number
	BEQ +							; | if zero, then a bullet can be spawned
	DEY								; | if not found, try another slot
	BPL -							; | if no more slots
	RTS								; / just return
	
	+
	
	PHY
	
	LDY #!EB3_bulletSpeed			; \ store bullet speed into scratch
	LDA [$0A],y						; |
	STA $04							; /
	
	INY								; \ store bullet angle into scratch
	LDA [$0A],y						; |
	STA $06							; /
	
	PLY
	
	LDA !shotCounter,x				; \ load the shot counter
	BEQ +							; | if it's 0 then we don't care and we don't bother counting
	DEC !shotCounter,x				; | decrement number of shots left
	BNE +							; | if not 0 then it can keep shooting
	LDA #$00						; | if it's 0,
	STA !sprite_status,x			; | then we kill the shooter
	+								; /

	LDA.b #!bulletSpriteNum+!ClusterOffset			; \ store bullet number
	STA !cluster_num,y								; /
	
	LDA #!shootSFX					; \ play sound effect when shot
	BEQ +							; |
	STA !shootChannel				; |
	+								; /
	
	LDA !sprite_x_low,x				; \ have cluster sprite spawn at the shooter's x position
	STA !cluster_x_low,y			; |
	LDA !sprite_x_high,x			; |
	STA !cluster_x_high,y			; /
	
	LDA !sprite_y_low,x				; \ have cluster sprite spawn at the shooter's y position
	STA !cluster_y_low,y			; |
	LDA !sprite_y_high,x			; |
	STA !cluster_y_high,y			; /
	
	PHY								; \ store the bullet expiration timer into the cluster sprite table
	LDY #!EB7_bulletTimer			; |
	LDA [$0A],y						; |
	PLY								; |
	STA !cluster_expire_timer,y		; /
	
	LDA !extra_prop_1,x				; \ load wanted tile
	STA !cluster_tile,y				; | store it into cluster sprite table
	LDA !extra_prop_2,x				; | load wanted props
	STA !cluster_props,y			; / store it into cluster sprite table
	
	LDA !extra_bits,x				; \ shoot at specified angle if extra bit is clear
	AND #$04						; |
	BEQ SetAngle					; |
	BRA Aim							; / aim at mario if extra bit is set
	
	SetAngle:
		LDA #$00
		XBA
		LDA $04						; load speed
		REP #$20
		STA $04						; store speed
		SEP #$20

		%MathGetCoordSpd()			; $06 is already set to the necessary angle, so nothing else is needed here
		
		LDA $00						; \ now that math is done, store x and y speeds properly
		ASL #4						; |
		STA !cluster_speed_x,y		; |
		LDA $02						; |
		ASL #4						; |
		STA !cluster_speed_y,y		; /
		
		RTS
	
	Aim:
		LDA !sprite_x_low,x			; \ store sprite position into scratch RAM
		STA $00						; |
		LDA !sprite_x_high,x		; |
		STA $01						; |
		LDA !sprite_y_low,x			; |
		STA $02						; |
		LDA !sprite_y_high,x		; |
		STA $03						; /
		
		LDA $00						; \ subtract sprite x position with player x position
		SEC : SBC $94				; |
		STA $00						; |
		LDA $01						; |
		SBC $95						; |
		STA $01						; /
		
		REP #$20					; \ subtract sprite y position with player y position (and a constant so it aims a bit lower)
		LDA $02						; |
		SEC : SBC $96				; |
		SBC #$0010					; |
		STA $02						; |
		SEP #$20					; /
		
		LDA $04						; load speed
		
		%Aiming()					; aim at the player
		LDA $00						; \ store x and y speeds
		STA !cluster_speed_x,y		; |
		LDA $02						; |
		STA !cluster_speed_y,y		; /
		
		RTS
		
AttachToSprite:
	LDY #!EB9_attachNum
	LDA [$0A],y
	BNE +
	RTS	
	+
	STA $09

	LDA !attachedSpriteIndex,x		; \ load attached sprite index
	TAY								; |
	BPL ++							; /	if one is already set, dont't search for a sprite to attach to

	LDY #!SprSize
	-
	SEP #$20
	DEY
	BMI .noAvailableAttach
	LDA !sprite_num,y
	CMP $09
	BNE -

	LDA !sprite_status,y
	CMP #$01
	BEQ +
	CMP #$08
	BMI -
	
	+
	LDA !sprite_x_low,x
	SEC : SBC !sprite_x_low,y
	STA $00
	LDA !sprite_x_high,x
	SBC !sprite_x_high,y
	STA $01
	
	REP #$20
	LDA $00
	BPL +
	EOR #$FFFF
	INC
	+
	
	SEC : SBC #$001F
	BCS -
	
	SEP #$20
	TYA
	STA !attachedSpriteIndex,x

	++
	
	LDA !sprite_status,y
	CMP #$01
	BEQ +
	CMP #$08
	BMI .killShooter
	
	JSR AttachmentOffset
	
	.noAvailableAttach
	RTS
	
	.killShooter
	LDA #$00
	STA !sprite_status,x
	RTS
	
AttachmentOffset:
	LDY #!EB10_attachOffsets		; \ load in the offset
	LDA [$0A],y						; |
	STA $04							; / $02 will contain the whole offset, both y and x unmodified. now we get to make sense of the 4 bits each
	
	AND #$08
	BNE +
	LDA $04
	AND #$0F
	ASL #3
	STA $00
	STZ $01
	BRA ++

	+
	LDA $04
	EOR #$FF
	INC
	AND #$0F
	ASL #3
	EOR #$FF
	STA $00
	LDA #$FF
	STA $01
	
	++
	
	LDA $04
	LSR #4
	AND #$08
	BNE +
	LDA $04
	LSR #4
	AND #$0F
	ASL #3
	STA $02
	STZ $03
	BRA ++

	+
	LDA $04
	LSR #4
	EOR #$FF
	INC
	AND #$0F
	ASL #3
	EOR #$FF
	STA $02
	LDA #$FF
	STA $03
	
	++
	
	LDA !attachedSpriteIndex,x
	TAY
	
	LDA !sprite_x_low,y				; \ store the host sprite's x position into the shooter's
	CLC : ADC $00					; |
	STA !sprite_x_low,x				; |
	LDA !sprite_x_high,y			; |
	ADC $01							; |
	STA !sprite_x_high,x			; /
	
	LDA !sprite_y_low,y				; \ store the host sprite's y position into the shooter's
	CLC : ADC $02					; |
	STA !sprite_y_low,x				; |
	LDA !sprite_y_high,y			; |
	ADC $03							; |
	STA !sprite_y_high,x			; /
	
	RTS
	
;############################;
;# Parameter Check Routines #;
;############################;

NoParameter:
	LDX $15E9|!addr					; basically the code for all of these is load some RAM and if it fits the parameter wanted,
	SEC								; then set the carry flag. if it doesn't fit the parameter, it stays clear
	RTS
	
OnOff_isON:
	LDX $15E9|!addr
	LDA $14AF|!addr
	BNE +
	SEC	
	+
	RTS

OnOff_isOFF:
	LDX $15E9|!addr
	LDA $14AF|!addr
	BEQ +
	SEC	
	+
	RTS

BlueP_isACTIVE:
	LDX $15E9|!addr
	LDA $14AD|!addr
	BEQ +
	SEC	
	+
	RTS

BlueP_isNOTACTIVE:
	LDX $15E9|!addr
	LDA $14AD|!addr
	BNE +
	SEC	
	+
	RTS

SilverP_isACTIVE:
	LDX $15E9|!addr
	LDA $14AE|!addr
	BEQ +
	SEC	
	+
	RTS

SilverP_isNOTACTIVE:
	LDX $15E9|!addr
	LDA $14AE|!addr
	BNE +
	SEC	
	+
	RTS

RNG1_isPOSITIVE:
	LDX $15E9|!addr
	LDA $148D|!addr
	BPL +
	SEC
	+
	RTS
	
RNG1_isNEGATIVE:
	LDX $15E9|!addr
	LDA $148D|!addr
	BMI +
	SEC
	+
	RTS
	
RNG2_isPOSITIVE:
	LDX $15E9|!addr
	LDA $148E|!addr
	BPL +
	SEC
	+
	RTS

RNG2_isNEGATIVE:
	LDX $15E9|!addr
	LDA $148D|!addr
	BMI +
	SEC
	+
	RTS
	
Player_onRIGHT:
	LDX $15E9|!addr
	%SubHorzPos()
	CPY #$00
	CLC
	BNE +
	SEC
	+
	RTS

Player_onLEFT:
	LDX $15E9|!addr
	%SubHorzPos()
	CPY #$00
	CLC
	BEQ +
	SEC
	+
	RTS

Player_isBELOW:
	LDX $15E9|!addr
	%SubVertPos()
	CPY #$00
	CLC
	BNE +
	SEC
	+
	RTS

Player_isABOVE:
	LDX $15E9|!addr
	%SubVertPos()
	CPY #$00
	CLC
	BEQ +
	SEC
	+
	RTS

Reserved_0F:
Reserved_10:
Reserved_11:
Reserved_12:
Reserved_13:
Reserved_14:
Reserved_15:
Reserved_16:
Reserved_17:
Reserved_18:
Reserved_19:
Reserved_1A:
Reserved_1B:
Reserved_1C:
Reserved_1D:
Reserved_1E:
Reserved_1F:
	LDX $15E9|!addr
	SEC
	RTS
	
; add more parameter checks below here if you so desire
