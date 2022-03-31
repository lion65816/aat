;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW POW switch (sprite 3E), by mellonpizza
;;
;; This is a disassembly of sprite 3E in SMW, the blue and silver P-switches.
;;
;; Uses first extra bit: YES
;;
;; If the first extra bit is clear, the switch will be blue. If it's set,
;; the switch will be silver.
;;
;; The main routine of the Pswitch sprite essentially does not exist, all its code is embedded into sprite states 9/A/B.
;; So I've set the extra property byte in this sprite to ignore vanilla routines, and run code in here.
;; Otherwise, this entire file would be an init that sets $14C8,x to #$09 and a main routine that returns immediately.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Switch_Effect_Time = $B0 ; How long the p-switch effect lasts
!Switch_Sfx_Number = $0B ; SFX number to load when you press the pswitch
!Switch_Sfx_Bank = $1DF9 ; SFX bank to load SFX number into
!Blue_Palette = $03 ; Which palette slot to use for blue pswitch. palette 08 in LM = 00, 09 -> 01, ect.
!Silver_Palette = $01 ; Which palette slot to use for silver pswitch. 

;; Draw properties
;; Top number is the initial 16x16 tile,
;; Bottom two numbers are the 8x8 pressed tiles.

Pswitch_Xoff:
db $00
db $00,$08

Pswitch_Yoff:
db $00
db $08,$08

Pswitch_Tile:
db $42
db $FE,$FE

Pswitch_Prop:
db $00
db $00,$40

;; Defines stolen from Dyzen
!TrueFrameCounter = $13
!EffectiveFrameCounter = $14

!ButtonPressed_BYETUDLR = $15
!ButtonDown_BYETUDLR = $16
!ButtonPressed_AXLR0000 = $17
!ButtonDown_AXLR0000 = $18

!Layer1X = $1A

!PlayerX = $94
!PlayerY = $96
!PlayerXSpeed = $7B
!PlayerYSpeed = $7D
!PowerUp = $19
!PlayerInAirFlag = $72
!PlayerDuckingFlag = $73
!PlayerClimbingFlag = $74
!PlayerDirection = $76
!PlayerRideYoshi = $187A|!Base2

!LockAnimationFlag = $9D

!OAM_XPos = $0300|!Base2
!OAM_YPos = $0301|!Base2
!OAM_Tile = $0302|!Base2
!OAM_Prop = $0303|!Base2

!sprite_direction = !157C
!pswitch_color = !151C

print "INIT ",pc
	;; $151C,x = Blue/Silver, depending on extra bit
	lda !extra_bits,x : lsr #2 : and #$01 : sta !pswitch_color,x

	;; Store appropriate palette to RAM
	phx
	tax
	lda.l PSwitchPal,x
	plx
	sta !sprite_oam_properties,x

	;; Sprite status = Carryable
	lda #$08 : sta !sprite_status,x
	rtl

PSwitchPal:
	db (!Blue_Palette&7)<<1,(!Silver_Palette&7)<<1

print "MAIN ",pc
	;; Handle which state to manage
	phb : phk : plb
	lda !sprite_status,x : cmp #$0B : beq +
	jsr Pswitch_Main
	bra ++
	+
	jsr HandleSprCarried
	++
	;; Set sprite to handle vanilla settings if needed
	;; this might need to be tweaked
	lda !sprite_status,x : cmp #$08 : bcs +
	lda #$00 : bra ++
	+
	lda #$80
	++
	sta !extra_prop_2,x
	plb : rtl


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;									;;
;;		Stunned/Main routine		;;
;;									;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Pswitch_Main:
	;; Branch if sprites locked
	lda !LockAnimationFlag : beq +
	jmp .graphics
	+
	;; Offscreen moved from bottom of sprite routine
	%SubOffScreen()

	;; Update sprite position with gravity
	jsl $01802A|!BankB

	;; Handle touching the ground
	lda !sprite_blocked_status,x : and #$04 : beq .Not_Touching_Ground
	jsr Handle_Touch_Ground

.Not_Touching_Ground
	;; Handle touching the ceiling
	lda !sprite_blocked_status,x : and #$08 : beq .Not_Touching_Ceiling

	;; Set downward speed
	lda #$10 : sta !sprite_speed_y,x

	;; Branch away if touching the side
	lda !sprite_blocked_status,x : and #$03 : bne .Handle_Touch_Side

	;; Offset X position by #$08 and store to block info
	lda !sprite_x_low,x : clc : adc #$08 : sta $9A
	lda !sprite_x_high,x : adc #$00 : sta $9B

	;; Set high nybble of Y position to block info
	lda !sprite_y_low,x : and #$F0 : sta $98
	lda !sprite_y_high,x : sta $99

	;; Store "layer2 below blocked" status to layer handler
	LDA !sprite_blocked_status,x : asl #3 : rol : and #$01 : sta $1933|!Base2

	;; Run routine to handle knocking into block
	ldy #$00 : lda $1868|!Base2 : jsl $00F160|!BankB
	bra .Not_Touching_Side

.Not_Touching_Ceiling
	lda !sprite_blocked_status,x : and #$03 : beq .Not_Touching_Side

.Handle_Touch_Side
	jsr Hit_wall

	;; Invert/half speed
	lda !sprite_speed_x,x : asl : php
	ror !sprite_speed_x,x : plp : ror !sprite_speed_x,x

.Not_Touching_Side
	;; Interact with player. 'PowInteract' extracted from default interaction handler.
	jsl $01A7DC|!BankB : bcc +
	jsr PowInteract
	+
.graphics
	;; Set default priority for sprite drawing
	lda #$20 : sta $02
	jmp POW_Draw_and_Stun_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	P-Switch collision handler	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PowInteract:
	;; Handle stun timer
	stz $18D2|!Base2
	lda !154C,x : bne .return2
	lda #$08 : sta !154C,x

	;; Test if X/Y button held
	lda $15 : and #$40 : beq .No_Carry

	;; Branch if carrying an enemy, or on yoshi
	lda $1470|!Base2 : ora !PlayerRideYoshi : bra .No_Carry

	;; Set sprite status to being carried and set mario to carry an item
	lda #$0B : sta !sprite_status,x
	inc $1470|!Base2

	;; Set pose to hold an item
	lda #$08 : sta $1498|!Base2
.return2
	rts

.No_Carry
	;; Jump away if pswitch is already pressed
	lda !163E,x : bne .return

	;; Enable contact with player
	stz !154C,x

	;; Check if player is within range of the sprite to be "inside"
	lda !sprite_y_low,x : sec : sbc $D3
	clc : adc #$08 : cmp #$20 : bcc .Inside_Sprite

	;; If player is below sprite, make them fall down
	bpl +
	lda #$10 : sta !PlayerYSpeed
	rts
	+
	;; If player is moving upward, exit routine
	lda !PlayerYSpeed : bmi .return

	;; Set player speed to 0, set to be on the ground, and set flag for standing on sprite.
	stz !PlayerYSpeed : stz !PlayerInAirFlag : inc $1471|!Base2

	;; Load player's height
	lda #$1F : ldy !PlayerRideYoshi : beq +
	lda #$2F
	+
	sta $00

	;; Set player Y position relative to sprite
	lda !sprite_y_low,x : sec : sbc $00 : sta !PlayerY
	lda !sprite_y_high,x : sbc #$00 : sta !PlayerY+1

	;; Play switch SFX
	lda.b #!Switch_Sfx_Number : sta.w !Switch_Sfx_Bank|!Base2

	;; If star or switch music not already playing, then don't set the music to play
	lda $0DDA|!Base2 : bmi +
	lda #$0E : sta $1DFB|!Base2
	+
	;; Set timer for how long the pswitch will stay onscreen before dissapearing
	lda #$20 : sta !163E,x

	;; Set the timer for the corresponding pswitch
	ldy !pswitch_color,x : lda.b #!Switch_Effect_Time : sta $14AD|!Base2,y

	;; Set time to shake ground
	lda #$20 : sta $1887|!Base2

	;; If silver pswitch, set appropriate sprites to coins
	cpy #$01 : bne .return
	jsl $02B9BD|!BankB
.return
	rts

.Inside_Sprite
	;; Clear Xspeed
	stz !PlayerXSpeed

	;; Nudge player 1 pixel every frame, in the corresponding direction
	%SubHorzPos()
	tya : asl : tay
	rep #$20
	lda !PlayerX : clc : adc .Nudge_Player_offsets,y : sta !PlayerX
	sep #$20
	rts

.Nudge_Player_offsets
dw $0001,$FFFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	P-switch hitting the ground routine	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Handle_Touch_Ground:
	;; Halve X speed
	lda !sprite_speed_x,x
	php : bpl +
	eor #$FF : inc a
	+
	lsr a
	plp : bpl +
	eor #$FF : inc a
	+
	sta !sprite_speed_x,x
	
	;; Preserve Y speed
	lda !sprite_speed_y,x
	pha
	
	;; Set y speed depending on whether the sprite is on a slope
	;; (SetSomeYSpeed??)
	lda !1588,x : bmi ++
	lda #$00 : ldy !sprite_slope,x : beq +
	++
	lda #$18
	+
	sta !sprite_speed_y,x

	;; use Yspeed to index a table of values to use as bouncing speeds
	pla
	lsr #2 : tay
	lda .Yspeed_bounce_table,y
	
	;; Do not change the sprite's speed adjusted previously,
	;; in the case that layer2 is touching from above.
	ldy !sprite_blocked_status,x : bmi +
	sta !sprite_speed_y,x
	+
	rts

.Yspeed_bounce_table
db $00,$00,$00,$F8,$F8,$F8,$F8,$F8
db $F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8
db $E8,$E8,$E8

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	P-switch hitting a wall routine	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Hit_wall:
	;; Play contact SFX
	lda #$01 : sta $1DF9|!Base2

	;; Invert speed and flip sprite direction
	lda !sprite_speed_x,x : eor #$FF : inc a : sta !sprite_speed_x,x
	lda !sprite_direction,x : eor #$01 : sta !sprite_direction,x

	;; Don't interact with blocks if offscreen
	lda !sprite_off_screen_horz,x : bne .return
	lda !sprite_x_low,x : sec : sbc !Layer1X
	clc : adc #$14 : cmp #$1C : bcc .return

	;; Store "layer2 side blocked" status to layer handler
	lda !1588,x : asl #2 : rol : and #$01 : sta $1933|!Base2

	;; Run routine to handle knocking into block
	ldy #$00 : lda $18A7|!Base2 : jsl $00F160|!BankB

.return
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;								;;
;;		Carried routine			;;
;;								;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HandleSprCarried:
	;; Handles all the logic for carrying sprites
	jsr Carried_Sprite_Main
	
	;; If player is in a way that the sprite needs to be drawn infront of them,
	;; set OAM index to zero.
	lda $13DD|!Base2 : bne +
	lda $1419|!Base2 : bne +
	lda $1499|!Base2 : beq ++
	+
	stz !sprite_oam_index,x
	++
	;; Set default priority for sprite drawing
	lda #$20 : sta $02
	
	;; If signaled that player is to be drawn behind layers, set draw priority to #$10.
	lda $1419|!Base2 : beq +
	lda #$10 : sta $02
	+
	jmp POW_Draw_and_Stun_Handler

Carried_Sprite_Main:
	;; call object interaction routine
	jsl $019138|!BankB
	
	;; Go back to stunned state if the player has a special animation,
	;; and yoshi isn't set to have a special value for drawing behind pipes
	lda $71 : cmp #$01 : bcc +
	lda $1419|!Base2 : bne +
	lda #$09 : sta !sprite_status,x
	rts
	+
	;; Return if the sprite has changed back into its normal state
	lda !sprite_status,x : cmp #$08 : bne +
	rts
	+
	lda !LockAnimationFlag : beq +
	jmp Attatch_Sprite_To_Player
	+
	;; Check if X/Y not held; if not, then release sprite
	lda $1419|!Base2 : bne +
	bit !ButtonPressed_BYETUDLR
	bvc ReleaseSprCarried
	+
	jmp Attatch_Sprite_To_Player
	
ReleaseSprCarried:
	;; Clear Y speed and set to stunned state.
	stz !sprite_speed_y,x
	lda #$09 : sta !sprite_status,x
	
	;; Branch to throw the sprite upward
	lda !ButtonPressed_BYETUDLR : and.B #$08 : bne TossUpSprCarried

	;; Branch to kick sprite left/right
	lda !ButtonPressed_BYETUDLR : and #$03 : bne KickSprCarried
	
	;; Else, the sprite is to be dropped down.
	ldy !PlayerDirection
	lda $D1 : clc : adc Drop_Xoffset_Low,y : sta !sprite_x_low,x
	lda $D2 : adc Drop_Xoffset_High,y : sta !sprite_x_high,x
	%SubHorzPos()
	lda Drop_Xspeed,y : clc : adc !PlayerXSpeed : sta !sprite_speed_x,x
	bra StartKickPose

Drop_Xspeed:
db $FC,$04

Drop_Xoffset_Low:
db $F3,$0D
Drop_Xoffset_High:
db $FF,$00

TossUpSprCarried:
	;; Display contact graphic
	jsl $01AB6F|!BankB
	
	;; Set sprite speeds (-112 Y, Player/2 X)
	lda #$90 : sta !sprite_speed_y,x
	lda !PlayerXSpeed : sta !sprite_speed_x,x
	asl a : ror !sprite_speed_x,x
	bra StartKickPose

KickSprCarried:
	;; Display contact graphic
	jsl $01AB6F|!BankB
	
	;; Set sprite X speed
	ldy !PlayerDirection : lda !PlayerRideYoshi : beq +
	iny #2
	+
	lda ShellSpeedX,y : sta !sprite_speed_x,x
	eor !PlayerXSpeed : bmi StartKickPose
	lda !PlayerXSpeed : sta $00
	asl $00 : ror
	clc : adc ShellSpeedX,y : sta !sprite_speed_x,x

StartKickPose:
	;; Disable collisions with mario for 16 frames
	LDA #$10 : sta !154C,x
	
	;; Display kicking pose
	lda #$0C : sta $149A|!Base2
	rts

ShellSpeedX:
db $D2,$2E,$CC,$34
	
Attatch_Sprite_To_Player:
	;; Get index to table which will determine where in relation to the player,
	;; on the x axis the sprite will be moved to
	ldy #$00 : lda !PlayerDirection : bne +
	iny
	+
	lda $1499|!Base2 : beq +
	iny #2
	cmp #$05 : bcc +
	iny
	+
	;; if mario is facing the screen or climbing, use the final index
	lda $1419|!Base2 : beq +
	cmp #$02 : beq ++
	+
	lda $13DD|!Base2 : ora !PlayerClimbingFlag : beq +
	++
	ldy #$05
	+
	;; If the player is on a sprite that calculate's the player's position based
	;; on the current frame, then use $94-$97 to calculate the carried sprite's
	;; position. otherwise use $D1-D4. This should ensure the sprite never looks
	;; "disjointed" in relation to the player
	phy : ldy #$00
	lda $1471|!Base2 : cmp #$03 : beq +
	ldy #$3D
	+
	;; Store player positions to scratch ram
	lda $0094|!Base1,y : sta $00
	lda $0095|!Base1,y : sta $01
	lda $0096|!Base1,y : sta $02
	lda $0097|!Base1,y : sta $03
	ply
	lda $00 : clc : adc CarriedSpr_OffsetToPlayer_Low,y : sta !sprite_x_low,x
	lda $01 : adc CarriedSpr_OffsetToPlayer_High,y : sta !sprite_x_high,x
	
	lda #$0D : ldy !PlayerDuckingFlag : bne +
	ldy !PowerUp : bne ++
	+
	lda #$0F
	++
	ldy $1489|!Base2 : beq +
	lda #$0F
	+
	clc : adc $02 : sta !sprite_y_low,x
	lda $03 : adc #$00 : sta !sprite_y_high,x
	
	;; Set flags to indicate player is holding an item
	lda #$01 : sta $148F|!Base2 : sta $1470|!Base2
	rts

CarriedSpr_OffsetToPlayer_Low:
db $0B,$F5,$04,$FC,$04,$00

CarriedSpr_OffsetToPlayer_High:
db $00,$FF,$00,$FF,$00,$00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	P-switch graphics routine	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
POW_Draw_and_Stun_Handler:
	;; Perpetually set to facing left
	lda #$01 : sta !sprite_direction,x

	;; Handle time to make P-switch dissapear
	ldy !163E,x : cpy #$01 : bne .draw

	;; Set to spinjump killed, set time to show cloud,
	;; and allow vanilla routine to take over for the rest
	lda #$04 : sta !sprite_status,x
	lda #$1F : sta !1540,x
	rts
	
.draw
	%GetDrawInfo()
	phx
	
	;; Set number of tiles to draw 
	lda !163E,x : beq +
	lda #$01
	+
	pha : sta $04
	
	;; Set palette
	lda !sprite_oam_properties,x : ora $02 : sta $02
	
	ldx $04
	lda .Pswitch_Size,x : pha
	lda .Frame_Offset,x : tax
	-
	lda $00 : clc : adc Pswitch_Xoff,x : sta !OAM_XPos,y
	lda $01 : clc : adc Pswitch_Yoff,x : sta !OAM_YPos,y
	lda Pswitch_Tile,x : sta !OAM_Tile,y
	lda Pswitch_Prop,x : ora $02 : sta !OAM_Prop,y
	iny #4 : dex : dec $04 : bpl -
	ply : pla : plx
	jsl $01B7B3|!BankB
	rts

.Pswitch_Size
db $02,$00
.Frame_Offset
db $00,$02