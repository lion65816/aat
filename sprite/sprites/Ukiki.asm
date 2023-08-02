;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Ukiki/Grinder/Monkey (from Yoshi's Island) v0.25
;; Special C3 Edition
;; by Sonikku
;; 
;; Extra Property Byte 1:
;;;; Bit 0 (x01) - Can be carried.
;;;;			(Note: Due to how many OAM slots the sprite uses, it'll usually make Mario invisible during the turning
;;;;			animation as a limitation of SMW. As such, this function is not recommended unless you've fixed this yourself.)
;; 
;; Extra Byte 1 (First extension byte in Lunar Magic):
;;;; x00 - Hopping Grinder
;;;;			;; Will hop away from the player when within a certain range
;;;;			;; and try to "juke" them out if they get too close.
;;;;			;; Climbs on walls or tiles that act like vines.
;;;; x01 - Escaping Grinder
;;;;			;; Will always run from the player. All Grinders change to this variant once stomped or spit out by Yoshi.
;;;; x02 - Seedy Sally/Short Fuse
;;;;			;; Remains at the placed location occasionally throwing a sprite down.
;;;;			;; Extra Byte 2 (Second extension byte in Lunar Magic) determines what type of sprite it throws, from a list (defined at "SpriteList").
;;;;			;; Default values as follows:
;;;;			;; x00 - Bob-omb
;;;;			;; x01 - Spiny Egg
;;;;			;; x02 - Horizontal Fish
;;;;			;; x03 - Hopping Flame
;;;;			;; x04 - Springboard
;;;;			;; Adding x40 to this value makes the sprite avoid throwing another sprite until
;;;;			;; the previously-thrown sprite no longer exists.
;;;; x03 - Melon-Eating Grinder
;;;;			;; Looks around and runs away from the player.
;;;;			;; If the player gets too close, it jumps in the opposite direction.
;;;;			;; If the player remains at a distance for too long, it'll take a bite of its melon before spitting seeds at them.
;;;;			;; 
;;;; x04 - Melon-Eating Grinder on Vine
;;;;			;; Climbs up and down on a vine to try to match the player's Y position.
;;;;			;; It will take a bite of its melon when it's around the same Y position before spitting seeds at the player.
;;;; x05 - Thief Grinder
;;;;			;; Jumps after the player and tries to steal something of theirs.
;;;;			;; If the player is carrying a sprite, it'll steal that sprite.
;;;;			;; If the player isn't carrying anything, it'll try to steal their reserve item.
;;;;			;; If the player has no reserve item, it'll act as a Hopping Grinder.
;;;;			;;;; If Extra Byte 2 (Second extension byte in Lunar Magic) is modified, you can adjust certain behaviors:
;;;;			;;;;   x01 - Only try to steal carried items.
;;;;			;;;;   x02 - Only try to steal reserve items.
;;;;			;;;;   x80 - Spawn with Goal Sphere in hand.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; misc defines (don't touch these pls)
!Normal =	$00
!Custom =	$01
!Custom2 =	$02
!True =		$01
!False =	$00
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Customization Options
;;;; Behavior-wise changes
;;;; If any label beginning as "!SFX_" is set to $00, it won't play that sound.


!Range_OnGround =	$0060		; Range player must be to a hopping Grinder for it to run away while on the ground
!Range_InAir =		$0030		; Range player must be to a hopping Grinder for it to run away while in the air

!Jump_XSpeed =		$18		; X Speed of a hopping Grinder.
!Jump_YSpeed =		$D0		; Y Speed of a hopping Grinder.
!ThiefJump_YSpeed =	$DC		; Y Speed of an item-stealing Grinder when it's idle.

!TileInteract_Vine =	$06		; Acts-Like setting of the tile a Grinder can climb up like a vine.
!Climbing_YSpeed =	$0C		; Y Speed of a Grinder when climbing.

	!SFX_Stomp =		$13	; What sound to play when stomping the sprite?
	!Bank_Stomp =		$F9	; SFX Bank for the above.

	!SFX_Kick =		$03	; What sound to play when kicking the sprite to defeat it?
	!Bank_Kick =		$F9	; SFX Bank for the above.

	!SFX_Stolen =		$00	; SFX to play when an item is stolen from the player.
	!Bank_Stolen =		$F9	; SFX Bank for the above.

!StunBounce =		$01		; Does the sprite bounce several times with equal velocity when spit out by Yoshi (like in YI), or does the bounce height get lower with each bounce (like in SMW)?
!StunBounce_YSpeed =	$E8		; Y Speed of sprite when stunned and bouncing along the ground.
	!SFX_StunBounce =	$01	; What sound to play when spit out by Yoshi, and bouncing along the ground?
	!Bank_StunBounce =	$F9	; SFX Bank for the above.

!Range_Climbing =	$0060		; Range player must be to a climbing Grinder for it to stop looking around.

!SpawnMelon =		$01		; Is a melon spawned when stunning the sprite (when it's holding one)?
!SprNum_Melon =		$02		; Sprite number of the melon.

!SprNum_Seed =		$00		; Extended Sprite number of the seed.

!GiveScore =		$01		; Give score when stomping sprite or killing it?

!Score_Stomped =	$01		; Score when stomping the sprite (only if not previously stunned)
!Score_Kicked =		$02		; Score when kicking sprite (and killing it)
!Score_Chucked =	$00		; Score when being hit by another sprite.
					;;;;;; $00 = 100 pts
					;;;;;; $01 = 200 pts
					;;;;;; $02 = 400 pts
					;;;;;; $03 = 800 pts
					;;;;;; $04 = 1000 pts
					;;;;;; $05 = 2000 pts
					;;;;;; $06 = 4000 pts
					;;;;;; $07 = 8000 pts
					;;;;;; $08 = 1up
					;;;;;; $09 = 2up
					;;;;;; $0A = 3up
					;;;;;; $0B = 5up


!Range_Retreat =	$0050		; Range for a melon-carrying Grinder to retreat.
!Range_Jump =		$0020		; Range for a melon-carrying Grinder to jump in the opposite direction of the player (or to jump off a vine).

!Evade_XSpeed =		$18		; X Speed of a melon-carrying Grinder to run away from the player.
!Evade_YSpeed =		$C0		; Y Speed of a melon-carrying Grinder to jump away from the player.

!Seed_XSpeed =		$28		; X speed of the spit seeds.
!Seed_YSpeed =		$02		; Y speed of the spit seeds.
	!SFX_Eat =		$06	; What sound to play when the sprite is eating a melon?
	!Bank_Eat =		$F9	; SFX Bank for the above.

	!SFX_Spit =		$06	; What sound to play when spitting seeds at the player?
	!Bank_Spit =		$FC	; SFX Bank for the above.

;; Sprite list for the item-throwing Ukiki to throw
;; First byte is the sprite number.
;; Second byte is if it's a normal or custom sprite (or custom sprite w/ extra byte set).
;; Third byte is the status of the thrown sprite.
;; Fourth byte handles if the sprite is how long the sprite remains stunned, if carriable.
;; i.e. "db $14 : db !Normal : db $08 : db $00" to spawn a Spiny Egg, or "db $01 : db !Custom : db $08 : db $00" to spawn Custom Sprite 1.
SpriteList:	; leave this label alone
	db $0D : db !Normal : db $09 : db $80	; x00 - Bob-omb
	db $14 : db !Normal : db $08 : db $00	; x01 - Spiny Egg
	db $15 : db !Normal : db $08 : db $00	; x02 - Horizontal Fish
	db $1D : db !Normal : db $08 : db $00	; x03 - Hopping Flame
	db $2F : db !Normal : db $09 : db $00	; x04 - Springboard
SpriteListEnd:	; leave this label alone

!Thrown_YSpeed =	$50		; Thrown sprite's Y speed.
	!SFX_Throw =		$00	; SFX to play when throwing a sprite.
	!Bank_Throw =		$FC	; SFX Bank for the above.

;;;; Graphic-related

!Palette_Stunned =	$0E		; palette to use when "stunned"

!Tile_Head1 =		$E0		; Normal/idle head
!Tile_Head2 =		$E2		; Head when looking down/eating/stunned
!Tile_Head3 =		$E4		; Head when mouth open/screeching/eating
!Tile_Head4 =		$E6		; Head spitting

!Tile_Body1 =		$F8		; Left tile of body
!Tile_Body2 =		$F9		; Right tile of body
!Tile_Body3 =		$FA		; Left tile of body when jumping

!Tile_Tail  =		$E8		; Tile of the tail.
!Tile_Hand1 =		$E9		; Tile for a 0-degree angled arm.
!Tile_Hand2 =		$EA		; Tile for a 45-degree angled arm.
!Tile_Hand3 =		$EB		; Tile for a 90-degree angled arm.
!Tile_Foot1 =		$DD		; Tile for a 0-degree angled foot.
!Tile_Foot2 =		$DC		; Tile for a 45-degree angled foot.
!Tile_Foot3 =		$FB		; Tile for a 90-degree angled foot.
!Tile_Foot4 =		$CC		; Tile for a pair of 90-degree angled feet.
!Tile_Eyes  =		$CD		; Tile for the "closed" pair of eyes.

!Tile_Seed =		$BD		; Tile used by the seed it shoots.

!Tile_Melon =		$C0		; Tile used by the melon.
!Pal_Melon =		$0B		; Palette of the melon.

print "INIT ",pc
	PHB
	PHK
	PLB
	LDA #$FF
	STA !1510,x
	%SubHorzPos()
	TYA
	STA !157C,x
	STZ !151C,x
	LDA !extra_byte_1,x
	AND #$07
	STA !C2,x
	ASL
	TXY
	TAX
	JMP (.ptr,x)
.ptr	dw Init_Grinder_Hopping			; x00 hops and evades player
	dw Init_Grinder_RunsAway		; x01 runs away constantly
	dw Init_Grinder_ThrowingItem		; x02 Throwing objects at player from vine
	dw Init_Grinder_SpitsSeeds		; x03 spits seeds
	dw Init_Grinder_SpitsSeeds_Climbing	; x04 spits seeds while climbing
	dw Init_Grinder_Grabs_Item		; x05 runs after player and grabs whatever they are holding (or reserve item)
	dw Finish_Init
	dw Finish_Init
Init_Grinder_SpitsSeeds_Climbing:
	TYX
	LDA #$FF
	STA !1594,x
	LDA !157C,x
	EOR #$01
	STA !157C,x
	BRA Init_Grinder_ThrowingItem_main
Init_Grinder_ThrowingItem:
	TYX
	LDA !157C,x
	EOR #$01
	STA !157C,x
.main	ASL
	TAY
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	CLC
	ADC .vine_xoffs,y
	SEP #$20
	STA !E4,x
	XBA
	STA !14E0,x
	STZ !1540,x
	LDA !C2,x
	AND #$07
	CMP #$04
	BEQ Init_Grinder_SpitsSeeds
	LDA #$FF
	STA !151C,x
	BRA Finish_Init
.vine_xoffs
	dw $FFF8,$0008

Init_Grinder_SpitsSeeds:
	TYX
	LDA #$FF
	STA !1594,x
	BRA Finish_Init
Init_Grinder_Grabs_Item:
	TYX
	LDA !extra_byte_2,x
	AND #$80
	BEQ +
	STZ $00
	STZ $01
	STZ $02
	STZ $03
	LDA #$4A
	CLC
	%SpawnSprite()
	BCS +
	LDA #$08
	STA !14C8,y
	TYA
	STA !1510,x
+	LDA !extra_byte_2,x
	BNE Finish_Init
	LDA !extra_byte_2,x
	ORA #$03
	STA !extra_byte_2,x
Init_Grinder_Hopping:
Init_Grinder_RunsAway:
Finish_Init:
	PLB
	RTL

!base2 = !Base2
print "MAIN ",pc
	PHB
	PHK
	PLB
;; detects if sprite is in a "stunned" state and, if so, forces them into the local stunned state
	LDA !14C8,x
	CMP #$09
	BNE +
	JSR DropMelon
	LDA #$08
	STA !14C8,x
	LDA #$04
	STA !1570,x
	JSR SpriteInteraction_become_stunned
+	LDA #$0F
	STA !9E,x
	JSR Main
	LDA $64
	PHA
	LDA !C2,x
	AND #$20
	BEQ +
.forcebehind
	LDA #$10
	STA $64
+	JSR SubGFX
	PLA
	STA $64
	PLB
	RTL

Main:	%SubOffScreen()
	LDA $9D
	BNE .return
	LDA !14C8,x
	CMP #$08
	BEQ .main
	BCS .return
	JSR DropMelon
.return	RTS
.main	JSR SpriteInteraction
;; force sprite to become stunned if being eaten by yoshi
	LDA !15D0,x
	BEQ +
	LDA #$06
	STA !C2,x
	JSR DropMelon
	BRA ++
+	LDA !14C8,x
	PHA
	LDA !1686,x
	AND #$F7
	STA !1686,x
	LDA !C2,x
	AND #$07
	CMP #$06
	BNE +
	LDA #$09
	STA !14C8,x
+	JSL $018032|!BankB
	LDA !14C8,x
	CMP #$05
	BCS +
	PLA
	BRA ++
+	PLA
	STA !14C8,x
++
;; force sprite to use climbing behavior if the flag is set to
	LDA !C2,x
	AND #$30
	BEQ .not_climbing
	LDA !C2,x
	AND #$10
	BNE .climb
	LDA #$09
	BRA .state
.climb	LDA #$08
	BRA .state
.not_climbing
	LDA !C2,x
	AND #$07
.state	ASL
	TXY
	TAX
	JMP (.ptr,x)

.ptr	dw Grinder_Hopping			; x00 hops and evades player
	dw Grinder_RunsAway			; x01 runs away constantly
	dw Grinder_ThrowingItem			; x02 Throwing objects at player from vine
	dw Grinder_SpitsSeeds			; x03 spits seeds
	dw Grinder_SpitsSeeds_Climbing		; x04 spits seeds while climbing
	dw Grinder_Grabs_Item			; x05 jumps after player and grabs whatever they are holding (or reserve item)
	dw Grinder_Stunned			; x06 bouncing stunned
	dw Grinder_StunnedOnGround		; x07 stunned/on ground
	dw Grinder_Climbing			; x08 climbing
	dw Grinder_Swimming			; x09 swimming
Grinder_Swimming:
	TYX
	JSR Manage_HoldingItem
	LDA !1588,x
	AND #$04
	BEQ +
	LDA #$20
	STA !1558,x
	LDA !C2,x
	AND #%00001111
	STA !C2,x
	PHY
	JMP Grinder_Hopping_jump_away
+	JSL $01801A|!BankB
	JSL $018022|!BankB
	LDA !166E,x
	PHA
	LDA #$40
	STA !166E,x
	JSL $019138|!BankB
	PLA
	STA !166E,x
	LDY #$00
	LDA !164A,x
	BEQ +
	INY
+	LDA !AA,x
	CMP .y_speed,y
	BEQ +
	CLC
	ADC .y_accel,y
	STA !AA,x
+	LDA !1540,x
	BEQ .swimaway
	CMP #$80
	BCC +
	LDA #$11
	BRA ++
+	LSR : LSR : LSR
	AND #$01
	TAY
	STZ !B6,x
	LDA .anim_swimhurt,y
	PHA
	JSR DropMelon
	PLA
++	BRA .set_frame
.anim_swimhurt
	db $00,$20
.swimaway
	LDA !C2,x
	AND #$07
	CMP #$05
	BEQ +
	STA $00
	CMP #$05
	BCC +
	LDA !C2,x
	AND #$B0
	ORA #$01
	STA !C2,x
+	%SubHorzPos()
	LDA $00
	CMP #$01
	BEQ .always_evade
	REP #$20
	LDA $0E
	CLC
	ADC #$0040
	CMP #$0080
	SEP #$20
	BCC .always_evade
	LDA $14
	AND #$01
	BEQ +
	TYA
	STA !157C,x
	LDA !B6,x
	BEQ +
	BPL ++
	INC !B6,x
	INC !B6,x
++	DEC !B6,x
	BRA +
.always_evade
	TYA
	EOR #$01
	STA !157C,x
	LDA $14
	AND #$01
	BNE +
	LDA !B6,x
	CMP .x_speed,y
	BEQ +
	CLC
	ADC .x_accel,y
	STA !B6,x
+	LDA #$00
.set_frame
	STA !1602,x
	JMP Grinder_Hopping_checkforclimb
.y_speed	db $08,$F8
.y_accel	db $01,$FF
.x_speed	db $F8,$08
.x_accel	db $FF,$01

;; hopping behavior
Grinder_RunsAway:
Grinder_Hopping:
	STZ $0C
	TYX
	LDY #$00
	JSR HandleForceSwim
;; handle the "prepare jump" substate; sprite has zero velocity until the end of the animation
.main	LDY #$04
	LDA !1540,x
	BEQ .no_timer
	LDY #$03
	PHY
	CMP #$01
	BNE .preparehop
.jump_away
	PHY
	LDY #!Jump_YSpeed
	LDA !C2,x
	AND #$07
	CMP #$05
	BNE +
	LDY #!ThiefJump_YSpeed
+	TYA
	PLY
	STA !AA,x
	LDY !157C,x
	LDA !163E,x
	BEQ .preparehop
	LDA .xspeed,y
	STA !B6,x
.preparehop
	PLY
	BRA .inair
.no_timer
;; on ground handler
	LDA !1588,x
	AND #$04
	BEQ .inair
	LDA !1540,x
	BNE .inair
	STZ !AA,x
	STZ !B6,x
	LDA #$08
	STA !1540,x
	PHY
	%SubHorzPos()
;; jump away or toward mario always
	LDA !C2,x
	AND #$07
	CMP #$01
	BEQ .run_away
	LDA $0C
	BNE .chase

;; check if mario is close or not based on inair status of mario
	PHY
	LDY #$00
	LDA $72
	BEQ +
	INY : INY
+	REP #$20
	LDA $0E
	CLC
	ADC .range,y
	CMP .range2,y
	SEP #$20
	PLY
	BCS .set_dir
;; run away if mario is on the ground, and jump toward him to juke him out if he's in the air
	REP #$20
	LDA $0E
	SEP #$20
	BPL .run_away
	LDA $72
	BNE .chase
.run_away
	TYA
	EOR #$01
	TAY
.chase	LDA #$10
	STA !163E,x
	BRA .set_dir
.set_dir
	TYA
	STA !157C,x
	PLY
.inair	TYA
	STA !1602,x
.checkwalls
	JSL $01802A|!BankB
	JSR Manage_HoldingItem
;; nullify y speed if hitting ceiling
	LDA !1588,x
	AND #$08
	BEQ +
	STZ !AA,x
+	LDA !1558,x
	BEQ .checkforclimb
;; nullify x speed if touching wall (when it can't climb walls)
	LDA !1588,x
	AND #$03
	BEQ .no_climb
	STZ !B6,x
	RTS
.checkforclimb
	STZ $00
;; handle touching vine
	LDA $1693|!Base2
	CMP #!TileInteract_Vine
	BEQ .setclimbing
;; handle touching walls
	LDA !1588,x
	AND #$03
	BEQ .no_climb
	LDA #$04
	STA $00
.setclimbing
;; set climbing state
	LDA !C2,x
	AND #$07
	CMP #$04
	BEQ .set_xpos
	LDA !C2,x
	AND #$10
	BNE +
	LDA #$30
	STA !1558,x
+	LDA !C2,x
	AND #$07
	ORA #$10
	STA !C2,x
	STZ !AA,x
	LDA #$00
	LDY !B6,x
	BPL +
	INC
+	STA !157C,x
.set_xpos
;; adjust sprite based on if it's touching wall or vine
	LDY $00
	LDA !157C,x
	BNE +
	INY : INY
+	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	AND #$FFF0
	CLC
	ADC .x_offset,y
	SEP #$20
	STA !E4,x
	XBA
	STA !14E0,x
.no_climb
	RTS
.x_offset
	dw $0008,$0008
	dw $000C,$0004
.xspeed	db !Jump_XSpeed,-!Jump_XSpeed
.range	dw !Range_OnGround,!Range_InAir
.range2	dw !Range_OnGround*2,!Range_InAir*2

Grinder_SpitsSeeds:
	TYX
	LDY #$00
	JSR HandleForceSwim
;; if the sprite has lost its item, revert to a running-away ukiki
	LDA !1594,x
	BNE +
	LDA #$01
	STA !C2,x
+	LDY #$20

;; handle spitting
	LDA !1540,x
	BEQ .not_spitting
	JMP HandleSpitting
.not_spitting
;; handle basic animation
	LDY #$26
	LDA !1588,x
	AND #$04
	BNE +
	JMP .set_frame
+	STZ !AA,x
;; check if mario is inside jumping range
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC #!Range_Jump
	CMP #!Range_Jump*2
	SEP #$20
	BCC .jump_away
;; run away if mario gets too close
	LDA !163E,x
	BNE .runningaway
	REP #$20
	LDA $0E
	CLC
	ADC #!Range_Retreat
	CMP #!Range_Retreat*2
	SEP #$20
	BCS .look_around
	LDA #$20
	STA !163E,x
.runningaway
	TYA
	EOR #$01
	STA !157C,x
	TAY
	LDA .xspeed,y
+	STA !B6,x
	LDA !1570,x
	INC !1570,x
	LSR
	AND #$01
	CLC
	ADC #$1C
	BRA .set_frame2
.jump_away
;; jump toward mario to juke him out
	LDA #!Evade_YSpeed
	STA !AA,x
	LDA !157C,x
	EOR #$01
	STA !157C,x
	TAY
	LDA .xspeed,y
	STA !B6,x
	LDY #$26
	BRA .set_frame
.xspeed
	db !Evade_XSpeed,-!Evade_XSpeed
	db -!Evade_XSpeed,!Evade_XSpeed

.look_around
;; handle "looking around" animation
	SEP #$20
	STZ !B6,x
	LDA !1570,x
	LDY !1594,x
	CPY #$FF
	BNE +
	CMP #$FF
	BEQ .shootseeds
+	INC !1570,x
	LSR : LSR : LSR : LSR
	AND #$01
	CLC
	ADC #$1E
	TAY
.set_frame
	TYA
.set_frame2
	STA !1602,x
	JMP Grinder_Hopping_checkwalls
.shootseeds
	STZ !1570,x
	LDA #$80
	STA !1540,x
	RTS

Grinder_SpitsSeeds_Climbing:
	TYX
;; pointer to animations
	LDA #$FF
	STA !1594,x
	LDA !151C,x
	AND #$03
	ASL
	TXY
	TAX
	JMP (.ptr,x)

.ptr	dw .movetomarioy
	dw .spitting
	dw .turning
	dw .turning

.movetomarioy
	TYX
	STZ $8C
;; detect distance from mario and whether he's above or below
	LDY #$00
	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20
	SEC
	SBC $96
	BPL +
	INY
+	CLC
	ADC #$FFF8
	STY $8A
	STA $0E
	CLC
	ADC #$0008
	CMP #$0010
	SEP #$20
	BCS .not_spitting
.beginspit
;; set animation to turning around if sprite wouldn't be aiming at him
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC #$0008
	CMP #$0010
	SEP #$20
	BCC +
	TYA
	EOR #$01
	CMP !157C,x
	BNE .turnaround
+
;; sprite is spitting
	LDA #$80
	STA !1540,x
	LDA #$01
	STA !151C,x
	STZ !1570,x
	RTS
.turnaround
;; this feels like an unsmart way to do this
;; i feel like it could eventually escape the vine
;; but i havent ever been able to prove it would
	LDA #$02
	STA !151C,x
	LDA #$08
	STA !1540,x
	LDY !157C,x
	LDA .xspeed,y
	STA !B6,x
	RTS
.xspeed	db $20,$E0
.spitting
	TYX
;; handle spitting and the reset of status
	LDA !1540,x
	BEQ +
	JMP HandleSpitting
+	STZ !1570,x
	STZ !151C,x
	JSL $01ACF9|!BankB
	AND #$07
	CLC
	ADC #$08
	STA !163E,x
	RTS
.not_spitting
;; adjust sprite positions for object collision purposes
	PHY
	LDA !14E0,x
	PHA
	LDA !E4,x
	PHA
	LDA !157C,x
	ASL
	TAY
	LDA !14E0,x
	XBA
	LDA !E4,x
	REP #$20
	AND #$FFF0
	CLC
	ADC .x_offs,y
	SEP #$20
	STA !E4,x
	XBA
	STA !14E0,x
	JSL $019138|!BankB
	PLA
	STA !E4,x
	PLA
	STA !14E0,x
	JSL $01801A|!BankB
	PLY

	LDA !163E,x
	BNE .stop
;; prevent moving up/down if we determined it's not on a vine (later)
	TYA
	INC
	CMP !1504,x
	BNE .setyspd

.stop	LDY #$02
.setyspd
	LDA .yspeed,y
	STA !AA,x
;; play animation
	CPY #$02
	BNE +
	LDA !1570,x
	LSR : LSR : LSR : LSR
	AND #$01
	CLC
	ADC #$2C
	BRA .setframe
+	LDA !1570,x
	INC !1570,x
	LSR : LSR
	AND #$03
	CMP #$03
	BCC +
	LDA #$00
	STA !1570,x
+	CPY #$01
	BNE +
	CLC
	ADC #$04
+	PHY
	TAY
	LDA Grinder_Climbing_anim_climbing,y
	PLY
.setframe
	STA !1602,x

;; check if sprite is touching vine. if not, set the direction it *was* moving and prevent it from going that way
	LDY #$00
	LDA !AA,x
	BEQ +
	LDA $185F|!Base2
	CMP #!TileInteract_Vine
	BNE ++
	STZ !1504,x
	RTS
++	LDY #$01
	LDA !AA,x
	BMI +
	INY
+	TYA
	BEQ ++
	STA !1504,x
	STZ $00
	TYA
	EOR #$FF
	INC
	BPL +
	DEC $00
+	CLC
	ADC !D8,x
	STA !D8,x
	LDA $00
	ADC !14D4,x
	STA !14D4,x
++	RTS
.clipping
	db $0B,$0C
.bittest2
	db $FD,$FE
.frameinc	db $01,$FF
.framemax	db $03,$FF
.x_offs		dw $0008,$FFF8
.y_offs		dw $FFFC,$0004
.yspeed		db -!Climbing_YSpeed,!Climbing_YSpeed,$00

.turning
	TYX
;; shift sprite around and reset state
	LDA !1540,x
	BEQ +
	CMP #$04
	BNE ++
	LDA #$16
	STA !1602,x
	LDA !157C,x
	EOR #$01
	STA !157C,x
++	JSL $018022|!BankB
	RTS
+	STZ !151C,x
	RTS

HandleSpitting:
;; setup basic handlers for spitting
	LDY #$00
	CMP #$78
	BCS .set_frame3
	LDY #$01
	CMP #$70
	BCS .set_frame3
	INC !1570,x
	CMP #$50
	BCS .chewing
	LDY #$02
	CMP #$28
	BCS .set_frame3
;; don't turnaround to face mario unless it's not on a vine (vine is handled separately)
	LDA !C2,x
	AND #$07
	CMP #$04
	BEQ +
	%SubHorzPos()
	TYA
	EOR #$01
	STA !157C,x
+	LDA !1540,x
	AND #$07
	BNE +
	PHA
	JSR SpawnSeeds
	PLA
+	LSR : LSR
	AND #$01
	CLC
	ADC #$04
	BRA .set_frame4
.chewing
	LDA !1570,x
if !SFX_Eat
	AND #$07
	BNE +
	PHA
	LDA #!SFX_Eat
	STA $1D00+!Bank_Eat|!Base2
	PLA
+
endif
	LSR : LSR
	AND #$01
	TAY
	LDA ++,y
	BRA .set_frame4
++	db $02,$03
.set_frame3
	TYA
.set_frame4
	LDY !C2,x
	CPY #$04
	BNE +
	CLC
	ADC #$06
+	TAY
	LDA .frame,y
	STA !1602,x
	RTS
.frame
	db $20,$21,$1E,$22,$23,$24
	db $27,$28,$2C,$29,$2A,$2B

;; throwing object from vine behavior
Grinder_ThrowingItem:
	TYX
;; handle setup of states
	LDA !151C,x
	AND #$03
	TAY
;; stop progressing in animation if last thrown sprite still exists
	LDA !1540,x
	BNE .no_newstate
	LDA !extra_byte_2,x
	AND #$40
	BEQ .not_lookingaround
	TYA
	BNE .not_lookingaround
;; clear "last sprite" flag if that sprite dies
	LDA !1510,x
	CMP #$FF
	BEQ .not_lookingaround
	PHY
	AND #$1F
	TAY
	LDA !14C8,y
	PLY
	CMP #$0B
	BNE +
	LDA !1510,x
	ORA #$80
	STA !1510,x
	BRA .no_newstate
+	CMP #$07
	BCS .no_newstate
	LDA #$FF
	STA !1510,x
.not_lookingaround
	LDA .timer,y
	STA !1540,x
	STZ !1528,x
	INC !151C,x
	STZ !1570,x
	CPY #$01
	BNE .no_newstate
	JSR .CreateProjectile
.no_newstate
	TYA
	ASL
	TXY
	TAX
	JMP (.ptr,x)
.timer	db $50,$5F,$00,$70

.ptr	dw .looking
	dw .digging
	dw .throwing
	dw .throwing
.looking
	TYX
	JSR .getframe
	LSR : LSR : LSR : LSR
	AND #$01
	CLC
	ADC #$1A
	BRA .setframe
.digging
	TYX
	JSR .getframe
	LSR : LSR : LSR
	AND #$01
	CLC
	ADC #$05
	BRA .setframe
.throwing
	TYX
	LDA !1510,x
	BMI +
	JSR .ManageProjectile
+	LDA !1540,x
	LSR
	TAY
	LDA .itemframe1,y
	STA !160E,x
	LDA .pickingupframe,y
.setframe
	STA !1602,x
	RTS
.pickingupframe
	db $10,$10,$10,$10,$10,$0F,$0E,$0D
	db $0C,$0B,$0B,$0B,$0B,$0B,$0B,$0B
	db $0B,$0B,$09,$09,$09,$0A,$0A,$0A
	db $0A,$0A,$0A,$0A,$0A,$0A,$09,$09
	db $09,$09,$09,$09,$09,$09,$08,$09
	db $0A,$09,$08,$07,$07,$06,$06,$06
.itemframe1
	db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$0D
	db $0C,$0B,$0A,$0A,$0A,$0A,$0A,$0A
	db $0A,$0A,$0A,$08,$08,$09,$09,$09
	db $09,$09,$09,$09,$09,$09,$09,$09
	db $09,$09,$09,$09,$09,$09,$08,$07
	db $06,$05,$04,$03,$02,$01,$00,$00
.getframe
	TYX
	LDA !1570,x
	INC !1570,x
	RTS

.CreateProjectile
;; setup variables
	LDA !extra_byte_2,x
	AND #$3F
	PHX
	CMP.b #((SpriteListEnd-SpriteList)/4)-$1
	BCC +
	LDA.b #((SpriteListEnd-SpriteList)/4)-$1
+	ASL : ASL
	TAX
	LDA SpriteList,x
	STA $08
	LDA SpriteList+$1,x
	STA $09
	LDA SpriteList+$2,x
	STA $0A
	LDA SpriteList+$3,x
	STA $0B
	PLX

;; spawn sprite (and also create a failsafe if no slots are free)
	LDA #$FF
	STA !1510,x
	PHY
	STZ $00
	LDA #$FB
	STA $01
	STZ $02
	STZ $03
	LDA $08
	LDY $09
	BEQ .normalspr
	SEC
	BRA +
.normalspr
	CLC
+	%SpawnSprite()
	BCS .no_spawn
	TYA
	STA !1510,x
	STZ !160E,x
	PHX
	TYX
	LDA #$08
	STA !1564,x
	STA !154C,x
	LDA $0A
	STA !14C8,x
	LDA $0B
	BEQ +
	STA !1540,x
+	LDA $09
	CMP #$02
	BNE +
	LDA #$04
	STA !7FAB10,x
+	PLX
.no_spawn
	PLY
	RTS

.ManageProjectile
	AND #$1F
	TAY
;; for redundancy: clear flag if the carried sprite dies
	LDA !14C8,y
	CMP #$0B
	BNE +
	LDA !1510,x
	ORA #$80
	STA !1510,x
	PHX
	TYX
	LDA #$08
	STA !1564,x
	STZ !15DC,x
	PLX
	RTS
+	CMP #$01
	BEQ +
	CMP #$07
	BCS ++
	LDA #$FF
	STA !1510,x
	RTS

++	LDA !E4,x
	STA $00
	LDA !14E0,x
	STA $01
	LDA !D8,x
	STA $02
	LDA !14D4,x
	STA $03
	LDA !157C,x
	STA $05
	LDA !160E,x
	BMI .no_lock
;; lock thrown sprite to ukiki
	PHX
	TYX
	TAY
	STZ $04
	PHY
	LDA .xpos,y
	LDY $05
	BEQ +
	EOR #$FF
	INC
+	PLY
	STA $08
	LDA $08
	BPL +
	DEC $04
+	CLC
	ADC $00
	STA !E4,x
	LDA $04
	ADC $01
	STA !14E0,x
	STZ $04
	LDA .ypos,y
	BPL +
	DEC $04
+	CLC
	ADC $02
	STA !D8,x
	LDA $04
	ADC $03
	STA !14D4,x
	STZ !AA,x
	STZ !B6,x
	LDA #$08
	STA !1564,x
	STA !15DC,x
	PLX
	RTS
.no_lock
;; setup thrown sprite values
	PHX
	TYX
	LDA #!Thrown_YSpeed
	STA !AA,x
	STZ !B6,x
	LDA #$08
	STA !1564,x
	STZ !15DC,x
	PLX
	LDA !1510,x
	ORA #$80
	STA !1510,x
if !SFX_Throw
	LDA #!SFX_Throw
	STA $1D00+!Bank_Throw|!Base2
endif
	RTS
.xpos	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FB,$00,$F5,$F2
.ypos	db $FB,$F5,$F0,$EC,$E9,$E7,$E6,$E7,$E9,$E7,$EA,$E7,$EC,$FC

Grinder_Grabs_Item:
	TYX
	LDY #$00
	JSR HandleForceSwim
	LDA !1510,x
	BPL .holdingitem
	STZ $0C
	LDA !extra_byte_2,x
	AND #$02
	BEQ +
	LDA $0DC2|!Base2
	BNE .beginchase
+	LDA !extra_byte_2,x
	AND #$01
	BEQ .hopping
	LDA $1470|!Base2
	ORA $148F|!Base2
	BEQ .hopping
	LDA $1891|!Base2
	BNE .hopping
.beginchase
	LDA #$FF
	STA $0C
.hopping
	JMP Grinder_Hopping_main

.holdingitem
	JMP Grinder_SpitsSeeds_not_spitting

Manage_HoldingItem:
	LDA !1510,x
	BMI .not_holdingitem
	TAY
	PHX
	LDA !157C,x
	TYX
	LDY !9E,x
	CPY #$4A
	BNE +
	LDA #$00
+	STA !157C,x
	LDA !14C8,x
	CMP #$0B
	BEQ .endholding
	CMP #$07
	BCC .endholding
	LDA !9E,x
	CMP #$0D
	BNE .no_bomb
	LDA !1534,x
	BEQ +
.endholding
	PLX
	LDA #$FF
	STA !1510,x
	LDA #$00
	STA !15DC,y
	LDA #$08
	STA !1564,y
	STA !154C,y
.not_holdingitem
	RTS
.no_bomb
	PHY
	TAY
	CPY #$2F
	BEQ +
	LDA !1540,x
	BEQ +
	LDA #$80
	STA !1540,x
+	CPY #$80
	BEQ +
	LDA #$08
	STA !1564,x
	STA !154C,x
+	LDA #$01
	STA !15DC,x
	STZ !B6,x
	STZ !AA,x
	LDA !9E,x
	PLX
	LDX $15E9|!Base2
	CPY #$2D
	BNE +
	LDA #$80
	STA !9E,x
+	PLY
	TYA
	LDY !1510,x
	SEC
	SBC #$74
	CMP #$04
	BCS +
	LDA #$08
	STA !1540,x
+	PHY
	STZ $00
	LDY !1602,x
	LDA NoOAM_xpos,y
	LDY !157C,x
	BNE +
	EOR #$FF
	INC
+	STA $01
	LDA $01
	BPL +
	DEC $00
+	PLY
	CLC
	ADC !E4,x
	PHX
	TYX
	STA !E4,x
	PLX
	LDA $00
	ADC !14E0,x
	STA !14E0,y

	LDA !B6,x
	STA $0C

	STZ $00
	PHY
	LDY !1602,x
	LDA NoOAM_ypos,y
	BPL +
	DEC $00
+	PLY
	CLC
	ADC !D8,x
	PHX
	TYX
	STA !D8,x
	PLX
	LDA $00
	ADC !14D4,x
	STA !14D4,y
	PHX
	TYX
	LDA !9E,x
	CMP #$35
	BNE +
	LDA !D8,x
	SEC
	SBC #$10
	STA !D8,x
	LDA !14D4,x
	SBC #$00
	STA !14D4,x
	STZ !15DC,x
	STZ !1564,x
	LDA #$C0
	STA !AA,x
	LDA $0C
	STA !B6,x
	LDX $15E9|!Base2
	LDA #$FF
	STA !1510,x
+	PLX
	RTS

;; stunned (in the air)
Grinder_Stunned:
	TYX
	LDY #$80
	JSR HandleForceSwim
	JSR DropMelon
;; handle on-ground/in-air stuff
	LDA !15D0,x
	BNE .inair
	LDA !1588,x
	AND #$04
	BEQ .inair
	LDA !AA,x
	BMI .inair
if !StunBounce
	LDA !1570,x
	BEQ .set_as_stunned
if !SFX_StunBounce
	PHA
	LDA #!SFX_StunBounce
	STA $1D00+!Bank_StunBounce|!Base2
	PLA
endif
	DEC !1570,x
	CMP #$01
	BEQ .inair
	LDA #!StunBounce_YSpeed
	STA !AA,x
else
	LDA !AA,x
	CMP #$0C
	BCS +
	LDA #$00
+	LSR
	EOR #$FF
	INC
	STA !AA,x
if !SFX_StunBounce
	LDA #!SFX_StunBounce
	STA $1D00+!Bank_StunBounce|!BankB
endif
	LDA !B6,x
	CLC
	ADC #$08
	CMP #$10
	BCC .set_as_stunned

endif
	BRA .reducespeed
.inair
;; ricochet off walls
	LDA !1588,x
	AND #$03
	BEQ .no_walls
	LDA !B6,x
	EOR #$FF
	INC
	STA !B6,x
	LDA !157C,x
	EOR #$01
	STA !157C,x
.reducespeed
	LDA !B6,x
	PHP
	BPL +
	EOR #$FF
	INC
+	LSR
	PLP
	BPL +
	EOR #$FF
	INC
+	STA !B6,x
.no_walls
	LDA #$11
	STA !1602,x
	LDA !190F,x
	PHA
	LDA !190F,x
	ORA #$80
	STA !190F,x
	JSL $01802A|!BankB
	PLA
	STA !190F,x
	RTS
.set_as_stunned
;; force sprite to be stunned
	STZ !AA,x
	STZ !B6,x
	LDA #$07
	STA !C2,x
	STZ !1570,x
	STZ !1528,x
	LDA #!Palette_Stunned
	STA !15F6,x
	RTS

;; stunned (on the ground)
Grinder_StunnedOnGround:
	TYX
	LDY #$80
	JSR HandleForceSwim
	JSR DropMelon
;; on-ground handler again
	LDA !1588,x
	AND #$04
	BNE +
	LDA #$06
	STA !C2,x
	STZ !1570,x
	RTS
+	LDY !1528,x
	LDA !1570,x
	INC !1570,x
	CMP .timer,y
	BCC +
	STZ !1570,x
	INC !1528,x
+	LDA .frame,y
	CMP #$FF
	BEQ .recover
	STA !1602,x
	RTS
.recover
;; sprite recovers to be a running-away ukiki when animation ends
	STZ !1570,x
	STZ !1528,x
	LDA #$01
	STA !C2,x
	%SubHorzPos()
	TYA
	EOR #$01
	STA !157C,x
	LDA #$10
	STA !163E,x
	LDY #$04
	PHY
	JMP Grinder_Hopping_jump_away
.timer
	db $04,$04,$04,$04,$04,$40,$04,$04,$10,$04,$20,$08,$08,$08,$08,$00
.frame	db $11,$18,$12,$13,$12,$13,$14,$13,$14,$15,$00,$01,$02,$01,$02,$FF

Grinder_Climbing:
	TYX
;; sprite always climbing up if running away
	LDA !1558,x
	BNE .climbing
	LDA !C2,x
	AND #$07
	CMP #$01
	BEQ .climbing
	CMP #$05
	BNE +
	LDA !1510,x
	BPL .climbing
+
;; only climb up if mario gets close
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC #!Range_Climbing
	CMP #!Range_Climbing*2
	SEP #$20
	BCC .climbup
	STZ !AA,x
	LDA !1570,x
	INC !1570,x
	LSR : LSR : LSR : LSR
	AND #$01
	CLC
	ADC #$1A
	BRA .setframe
.climbup
	REP #$20
	LDA $0E
	CLC
	ADC #$0010
	CMP #$0020
	SEP #$20
	BCC .climbing
	LDA $72
	BNE .climbing
	STZ !AA,x
	LDA #$19
	BRA .setframe
.climbing
;; jump off of vine if it has a melon and mario gets too close
	LDA !C2,x
	AND #$07
	CMP #$03
	BNE +
	LDA !1558,x
	BNE +
	LDA !1588,x
	AND #$03
	BNE +
	%SubHorzPos()
	REP #$20
	LDA $0E
	CLC
	ADC #!Range_Jump
	CMP #!Range_Jump*2
	SEP #$20
	BCC .drop_off
+	LDA !1588,x
	AND #$08
	BEQ +
	LDA !157C,x
	EOR #$01
	STA !157C,x
	BRA .drop_off
+	LDA #-!Climbing_YSpeed
	STA !AA,x
	LDA !1570,x
	INC !1570,x
	LSR : LSR
	CMP #$03
	BCC +
	LDA #$00
	STA !1570,x
+	TAY
	LDA .anim_climbing,y
.setframe
	STA !1602,x
;; do some stuff to determine if the sprite is on a wall or vine
	LDA !14E0,x
	PHA
	LDA !E4,x
	PHA
	JSL $01801A|!BankB
	JSL $019138|!BankB
	PLA
	STA !E4,x
	PLA
	STA !14E0,x
	JSR Manage_HoldingItem
	STZ $00
	LDA $1693|!Base2
	CMP #!TileInteract_Vine
	BNE .checkwall
	LDA #$08
	STA !163E,x
	BRA +
.checkwall
	LDA !1588,x
	AND #$03
	BNE .touching_walls
.drop_off
;; jump off of the vine
	LDA !C2,x
	AND #$EF
	STA !C2,x
	LDA #$30
	STA !1558,x
	LDY #$00
	LDA !163E,x
	BNE .noyspd
	LDY #$D0
.noyspd	TYA
	STA !AA,x
	LDY !157C,x
	LDA Grinder_Hopping_xspeed,y
	STA !B6,x
	RTS
.touching_walls
	LDA #$04
	STA $00
+	JMP Grinder_Hopping_set_xpos

.anim_climbing
	db $16,$17,$19,$FF
	db $19,$17,$16,$FF

;; collision w/ mario
SpriteInteraction:
	LDA !154C,x
	BNE .no_contact
	JSL $01A7DC|!BankB
	BCC .no_contact
	LDA $96
	LDY $187A|!Base2
	BEQ +
	CLC
	ADC #$10
+	SEC
	SBC $05
	CMP #$E8
	BPL .sides
	LDA $7D
	SEC
	SBC #$04
	BMI .no_contact
	JSL $01AA33|!BankB
	JSL $01AB99|!BankB
	STZ !1570,x
if !SFX_Stomp
	LDA #!SFX_Stomp
	STA $1D00+!Bank_Stomp|!Base2
endif
	STZ !AA,x
	STZ !B6,x
	LDA !15F6,x
	CMP #!Palette_Stunned
	BEQ .become_stunned
	LDA #!Palette_Stunned
	STA !15F6,x
if !GiveScore
	LDA #!Score_Stomped
	JSL $02ACE5|!BankB
endif
.become_stunned
	LDA !C2,x
	AND #$20
	BEQ +
	LDA #$88
	STA !1540,x
	LDA #$08
	STA !AA,x
	LDA #$21
	BRA ++
+	LDA #$06
++	STA !C2,x
	LDA #$30
	STA !154C,x
	STZ !1588,x
.no_contact
	RTS
.sides
;; don't interact with the player from the sides when it's not outright stunned (or can't steal)
	LDA !C2,x
	CMP #$05
	BEQ .can_steal
	CMP #$07
	BNE .no_contact
;; allow picking up the sprite when it's set to be carriable
	LDA !extra_prop_1,x
	AND #$01
	BEQ +
	BIT $15
	BVC +
	LDA #$10
	STA $1498|!Base2
	LDA #$0B
	STA !14C8,x
	RTS
+	%SubHorzPos()
	LDA .xspeed,y
	STA !B6,x
	LDA #$E0
	STA !AA,x
	LDA #$02
	STA !14C8,x
if !SFX_Kick
	LDA #!SFX_Kick
	STA $1D00+!Bank_Kick|!Base2
endif
	LDA #$10
	STA $149A|!Base2
if !GiveScore
	LDA #!Score_Kicked
	JSL $02ACE5|!BankB
endif
	RTS
.xspeed	db $F0,$10

.can_steal
	LDA !1510,x
	BPL .no_contact
	LDA !extra_byte_2,x
	AND #$01
	BEQ +
	LDA $1470|!Base2
	ORA $148F|!Base2
	BNE .steal_carrieditem
+	LDA !extra_byte_2,x
	AND #$02
	BEQ .no_contact
	LDA $0DC2|!Base2
	BEQ .no_contact
	STZ $00
	STZ $01
	STZ $02
	STZ $03
	CLC
	ADC #$73
	%SpawnSprite()
	BCS .no_contact
	LDA #$08
	STA !14C8,y
	STZ $0DC2|!Base2
	BRA .set_sprite_stolen
.steal_carrieditem
	LDY #!SprSize-1
-	LDA !14C8,y
	CMP #$0B
	BNE .loop
	PHX
	TYX
	LDA !9E,x
	PLX
	CMP #$7D
	BNE +
.loop	DEY
	BPL -
	RTS
+	LDA #$09
	STA !14C8,y
.set_sprite_stolen
	TYA
	STA !1510,x
if !SFX_Stolen
	LDA #!SFX_Stolen
	STA $1D00+!Bank_Stolen|!Base2
endif
	JMP Grinder_SpitsSeeds_jump_away

SpawnSeeds:
	LDY !157C,x
	LDA .seed_xpos,y
	STA $00
	LDA #$01
	STA $01
	LDA .seed_xspeed,y
	STA $02
	LDA #!Seed_YSpeed
	STA $03
	LDA #!SprNum_Seed+!ExtendedOffset
	%SpawnExtended()
	BCS .nospawn
	LDA #$00
	STA $1765|!Base2,y

	LDA #$08
	STA $176F|!Base2,y
	LDA #!Tile_Seed
	STA $1779|!Base2,y
if !SFX_Spit
	LDA #!SFX_Spit
	STA $1D00+!Bank_Spit|!Base2
endif
.nospawn
	RTS
.seed_xpos	db $00,$08
.seed_xspeed	db -!Seed_XSpeed,!Seed_XSpeed

DropMelon:
	PHX
	LDY !1602,x
	LDA NoOAM_xpos,y
	PHX
	LDY !157C,x
	BNE +
	EOR #$FF
	INC
+	PLX
	STA $00
	LDA NoOAM_ypos,y
	STA $01
	%SubHorzPos()
	TYA
	EOR #$01
	TAY
	LDA Grinder_Hopping_xspeed,y
	STA $02
	LDA #$D0
	STA $03
	LDA !1510,x
	BMI .no_loseitem
	TAY
	LDA #$FF
	STA !1510,x
	PHY
	TYX
	LDA $02
	STA !B6,x
	LDA $03
	STA !AA,x
	STZ !15DC,x
	PLX
.no_loseitem
if !SpawnMelon
	LDA !1594,x
	BEQ .no_losemelon
	CMP #$FF
	BNE .no_losemelon
	LDA #!SprNum_Melon
	SEC
	%SpawnSprite()
	BCS .no_losemelon
	PHX
	TYX
	LDA #$30
	STA !154C,x
	LDA #$08
	STA !14C8,x
	LDA #!Tile_Melon
	STA !extra_prop_1,x
	LDA #!Pal_Melon
	STA !extra_prop_2,x
	PLX
endif
	STZ !1594,x
.no_losemelon
	PLX
	RTS

;; forces swim flag
HandleForceSwim:
	LDA !164A,x
	BEQ +
	LDA !C2,x
	ORA #$20
	STA !C2,x
	STZ !B6,x
	LDA #$08
	STA !AA,x
	STZ !1570,x
	STZ !1528,x
	STZ !1540,x
	STZ !163E,x
	TYA
	STA !1540,x
+	RTS
;; graphics routine
;; only take a look if you want to see my pain

!0300	= $0300|!Base2
!0301	= $0301|!Base2
!0302	= $0302|!Base2
!0303	= $0303|!Base2
!0460	= $0460|!Base2

!Tile_Empty =	!Tile_Head1+$01	; This is the "tile" that is used for empty tiles
				; Not recommended to change this since it's already automatically calculated.

SubGFX:	%GetDrawInfo()
	LDA #$FF
	STA $0F

	LDA !157C,x
	ASL
	STA $02

	LDA !1602,x
	PHY
	LDY !14C8,x
	CPY #$04
	BCC .setkilledframe
	CPY #$0B
	BNE +
	LDA $76
	EOR #$01
	STA !157C,x
.setkilledframe
	LDA #$11
+	PLY
	CMP #$2F
	BCC +
	LDA #$00
+	STA $03

	STZ $06
	LDA !14C8,x
	CMP #$02
	BNE +
	INC $06
+	LDA !166E,x
	AND #$01
	ORA !15F6,x
	PHX
	LDX $02
	BNE +
	EOR #$40
+	LDX $06
	BEQ +
	EOR #$80
+	PLX
	STA $04
	STZ $0C

	LDA #%00011100
	JSR DrawLimbs
	JSR DrawHead
	LDA #%00000001
	JSR DrawLimbs
	JSR DrawBody
	LDA #%00000010
	JSR DrawLimbs
	JSR DrawItem

	LDY #$FF
	LDA $0F
	JSL $01B7B3
	RTS

;; !1602,x = frame:
;;     x00 - standing
;;     x01 - head scratch 1
;;     x02 - head scratch 2
;;     x03 - prepare jump
;;     x04 - jumping
;;     x05 - prepare to throw 1
;;     x06 - prepare to throw 2
;;     x07 - prepare to throw 3
;;     x08 - Throwing 1
;;     x09 - Throwing 2
;;     x0A - Throwing 3
;;     x0B - Throwing 4
;;     x0C - Throwing 5
;;     x0D - Throwing 6
;;     x0E - Throwing 7
;;     x0F - Throwing 8
;;     x10 - Throwing 9
;;     x11 - hurt (in air)
;;     x12 - hurt 1
;;     x13 - hurt 2
;;     x14 - hurt 3
;;     x15 - recovering
;;     x16 - climbing wall 1
;;     x17 - climbing wall 2
;;     x18 - hurt transition
;;     x19 - holding onto vine
;;     x1A - looking around on vine 1
;;     x1B - looking around on vine 2
;;     x1C - running w/ item 1
;;     x1D - running w/ item 2
;;     x1E - standing w/ item
;;     x1F - looking back w/ item
;;     x20 - eating 1
;;     x21 - eating 2
;;     x22 - eating 3
;;     x23 - spitting 1
;;     x24 - spitting 2
;;     x25 - preparing to jump w/ item
;;     x26 - jumping w/ item
;;     x27 - eating on vine 1
;;     x28 - eating on vine 2
;;     x29 - eating on vine 3
;;     x2A - spitting on vine 1
;;     x2B - spitting on vine 2
;;     x2C - sitting on vine 1
;;     x2D - sitting on vine 2
;;     x2E - hurt transition

;; draws the head of the ukiki
DrawHead:
	PHX
	LDX $03
	LDA .xpos,x
	PHX
	LDX $02
	BNE +
	EOR #$FF
	INC
+	PLX
	CLC
	ADC $00
	STA !0300,y

	LDA .ypos,x
	PHX
	LDX $06
	BEQ +
	EOR #$FF
	INC
+	PLX
	CLC
	ADC $01
	STA !0301,y

	PHX
	LDA .tilemap,x
	BMI .notile
	TAX
	LDA .head_tilemap,x
	CMP #!Tile_Empty
	BEQ .notile
	STA !0302,y

	LDA $04
	EOR .head_properties,x
	PLX
	ORA $64
	STA !0303,y

	PHY
	TYA
	LSR : LSR
	TAY
	LDA #$02
	STA !0460,y
	PLY

	PHX
	JSR NextOAM
.notile	PLX
	PLX
	RTS

		;;  01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16
		;;  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32
		;;  33  34  35  36  37  38  39  40  41  42  43  44  45  46
.xpos		db $00,$FF,$FF,$FD,$FC,$00,$FF,$00,$02,$02,$02,$04,$04,$04,$04,$04
		db $04,$00,$FD,$FD,$FD,$FC,$00,$01,$FD,$01,$04,$03,$00,$00,$00,$01
		db $00,$FB,$00,$02,$01,$FF,$00,$00,$FB,$01,$02,$01,$01,$01

.ypos		db $F9,$FA,$FA,$FB,$F5,$FA,$FC,$F9,$FA,$F9,$F8,$FA,$FB,$FC,$FD,$FE
		db $FB,$F9,$FF,$00,$00,$FE,$F8,$F9,$FA,$FA,$FA,$FA,$F6,$F5,$F8,$F8
		db $F8,$F9,$F8,$F8,$F8,$FC,$F5,$F9,$FA,$FA,$FA,$FA,$FA,$FA

.tilemap	db $00,$00,$00,$00,$00,$01,$01,$01,$04,$04,$04,$05,$05,$05,$05,$05
		db $05,$00,$00,$01,$01,$01,$00,$00,$00,$00,$05,$01,$00,$00,$00,$04
		db $02,$01,$01,$06,$06,$00,$02,$02,$01,$01,$06,$06,$00,$04

.head_tilemap
	db !Tile_Head1,!Tile_Head2,!Tile_Head3,!Tile_Head4,!Tile_Head1,!Tile_Head2,!Tile_Head4
.head_properties
	db $00,$00,$00,$00,$40,$40,$40

;; draws the body of the ukiki
DrawBody:
	STZ $0C
	LDA !157C,x
	BNE +
	LDA #$06
	STA $0C
+	PHX
	LDX $03
	LDA .xpos,x
	LDX $02
	BNE +
	EOR #$FF
	INC
+	STA $0B

	LDX #$01
-	STX $0E
	PHX

	LDX $03
	LDA .tilemap,x
	ASL
	CLC
	ADC $0E
	STA $0D
	CLC
	ADC $0C
	TAX
	LDA .body_xpos,x
	CLC
	ADC $0B
	ADC $00
	STA !0300,y

	LDX $03
	LDA .ypos,x
	PHX
	LDX $06
	BEQ +
	EOR #$FF
	INC
	CLC
	ADC #$08
+	PLX
	CLC
	ADC $01
	STA !0301,y

	LDX $0D
	LDA .body_tilemap,x
	CMP #!Tile_Empty
	BEQ .loop
	STA !0302,y

	LDA $04
	ORA $64
	STA !0303,y

	PHY
	TYA
	LSR : LSR
	TAY
	LDA #$00
	STA !0460,y
	PLY

	JSR NextOAM
.loop	PLX
	DEX
	BPL -
	PLX
	RTS
		;;  01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16
		;;  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32
		;;  33  34  35  36  37  38  39  40  41  42  43  44  45  46
.xpos		db $01,$01,$01,$00,$FF,$FF,$FF,$FF,$FF,$FF,$FF,$00,$00,$FF,$FF,$01
		db $01,$FF,$02,$02,$02,$01,$FD,$FD,$FE,$FD,$00,$01,$FF,$FF,$FF,$FF
		db $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FD,$FD,$FD,$FD,$FD,$FD,$FD,$FB

.ypos		db $07,$06,$06,$06,$01,$08,$09,$08,$08,$07,$06,$08,$09,$09,$0A,$0A
		db $08,$07,$06,$05,$05,$05,$06,$07,$06,$08,$08,$08,$05,$04,$07,$07
		db $07,$06,$07,$07,$07,$07,$03,$08,$07,$08,$09,$09,$08,$08,$0A

.tilemap	db $01,$02,$02,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$02,$00,$02,$02,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

.body_tilemap
	db !Tile_Body2,!Tile_Body1
	db !Tile_Body2,!Tile_Body3
	db !Tile_Body2,!Tile_Empty
.body_xpos
	db $08,$01
	db $08,$02
	db $08,$01

	db $00,$07
	db $00,$06
	db $00,$07

DrawLimbs:
	STA $0C
	LDA $03
	ASL : ASL
	ADC $03
	STA $0E
	PHX
	LDX #$04
-	LDA #$F0
	STA !0301,y
	LDA $0C
	AND .bit,x
	BEQ .loop
	PHX
	TXA
	CLC
	ADC $0E
	TAX
	LDA .xpos,x
	PHX
	LDX $02
	BNE +
	SEC
	SBC #$08
	EOR #$FF
	INC
+	PLX
	CLC
	ADC $00
	STA !0300,y

	LDA .ypos,x
	PHX
	LDX $06
	BEQ +
	EOR #$FF
	INC
	CLC
	ADC #$08
+	PLX
	CLC
	ADC $01
	STA !0301,y

	LDA .tilemap,x
	CMP #!Tile_Empty
	BEQ .loop2
	STA !0302,y

	LDA $04
	EOR .properties,x
	ORA $64
	STA !0303,y

	PHY
	TYA
	LSR : LSR
	TAY
	LDA #$00
	STA !0460,y
	PLY

	JSR NextOAM
.loop2	PLX
.loop	DEX
	BPL -
	PLX
	RTS

.bit	db $10,$08,$04,$02,$01
;; this is the limb handler
;; if a tile is set to $7F, it won't draw
;; why is there 46 frames of animation for this enemy
.xpos		db $00,$03,$09,$FF,$10 : db $00,$03,$09,$FF,$10 : db $00,$03,$09,$FE,$10 : db $FF,$02,$09,$FF,$0E	;;  01    02    03    04
		db $01,$05,$FF,$08,$0C : db $FE,$02,$FF,$FF,$0E : db $FE,$02,$FF,$FF,$0E : db $FE,$02,$FF,$FF,$0E	;;  05    06    07    08
		db $FE,$02,$FF,$07,$0E : db $FE,$02,$FF,$07,$0E : db $FE,$02,$FF,$07,$0E : db $FF,$02,$FF,$0C,$0F	;;  09    10    11    12
		db $FE,$02,$FF,$10,$0F : db $FE,$02,$FF,$11,$0E : db $FE,$02,$FF,$0D,$0F : db $FE,$02,$FF,$09,$0F	;;  13    14    15    16
		db $FE,$02,$FF,$09,$0F : db $02,$0C,$06,$02,$0E : db $FF,$0A,$FF,$0C,$0F : db $FF,$FF,$0E,$0C,$09	;;  17    18    19    20
		db $FF,$FF,$0E,$0C,$09 : db $FF,$0A,$04,$FC,$10 : db $FF,$FF,$FF,$01,$0C : db $FD,$FF,$FF,$00,$0C	;;  21    22    23    24
		db $0B,$FF,$08,$FF,$0C : db $00,$FF,$FF,$FF,$0C : db $0F,$03,$FF,$FF,$0F : db $0A,$03,$FF,$FF,$10	;;  25    26    27    28
		db $03,$FE,$0B,$FF,$0E : db $00,$FE,$08,$FF,$0E : db $FE,$00,$0A,$FF,$0E : db $FE,$00,$0A,$FF,$0D	;;  29    30    31    32
		db $FE,$00,$0A,$FF,$0E : db $FF,$00,$0A,$FF,$0D : db $FE,$00,$0A,$FF,$0E : db $00,$00,$0A,$FF,$0E	;;  33    34    35    36
		db $00,$00,$0A,$FF,$0E : db $00,$0A,$0F,$FF,$09 : db $00,$FF,$0D,$06,$08 : db $00,$FF,$FF,$FF,$0C	;;  37    38    39    40
		db $00,$FE,$FF,$FF,$0C : db $00,$FF,$FF,$FF,$0C : db $00,$00,$FF,$FF,$0C : db $00,$00,$FF,$FF,$0C	;;  41    42    43    44
		db $00,$FF,$FF,$FF,$0C : db $00,$FF,$FF,$FF,$0C							 	;;  45    46

.ypos		db $08,$08,$0C,$FF,$04 : db $08,$08,$0C,$F9,$02 : db $08,$08,$0C,$FA,$02 : db $FF,$08,$0B,$08,$01	;;  01    02    03    04
		db $09,$09,$FF,$09,$FB : db $06,$0B,$FF,$FF,$06 : db $07,$0B,$FF,$FF,$07 : db $06,$0B,$FF,$FF,$06	;;  05    06    07    08
		db $06,$0B,$FF,$F7,$06 : db $05,$0B,$FF,$F5,$05 : db $04,$0B,$FF,$F4,$04 : db $04,$0B,$FF,$F8,$06	;;  09    10    11    12
		db $04,$0B,$FF,$FC,$06 : db $04,$0B,$FF,$09,$07 : db $04,$0A,$FF,$0D,$07 : db $04,$0A,$FF,$10,$08	;;  13    14    15    16
		db $04,$0B,$FF,$0D,$07 : db $FA,$02,$09,$08,$05 : db $00,$0A,$FF,$0A,$00 : db $03,$FF,$FF,$07,$09	;;  17    18    19    20
		db $03,$FF,$FF,$07,$09 : db $FF,$0C,$08,$08,$02 : db $FF,$FF,$FF,$0E,$04 : db $02,$FF,$FF,$0D,$05	;;  21    22    23    24
		db $02,$FB,$0B,$FF,$01 : db $0A,$07,$FF,$FF,$06 : db $FD,$0C,$FF,$04,$06 : db $FD,$0C,$FF,$04,$05	;;  25    26    27    28
		db $0B,$04,$06,$FF,$02 : db $06,$03,$0B,$FF,$01 : db $06,$0C,$0C,$FF,$04 : db $06,$0C,$0C,$FF,$04	;;  29    30    31    32
		db $06,$0C,$0C,$FF,$03 : db $07,$0C,$0C,$FF,$01 : db $06,$0C,$0C,$FF,$03 : db $07,$0C,$0C,$FF,$05	;;  33    34    35    36
		db $07,$0C,$0C,$FF,$05 : db $0C,$0C,$05,$FA,$FA : db $EE,$FF,$01,$09,$EE : db $0A,$06,$FF,$FF,$06	;;  37    38    39    40
		db $0A,$07,$FF,$FF,$04 : db $0A,$07,$FF,$FF,$06	: db $0C,$09,$FF,$FF,$06 : db $0C,$09,$FF,$FF,$06	;;  41    42    43    44
		db $0A,$07,$FF,$FF,$06 : db $0A,$07,$FF,$FF,$06							 	;;  45    46

.tilemap	db !Tile_Hand2,!Tile_Hand2,!Tile_Foot1,!Tile_Empty,!Tile_Tail  : db !Tile_Empty,!Tile_Hand2,!Tile_Foot1,!Tile_Hand3,!Tile_Tail  : db !Tile_Empty,!Tile_Hand2,!Tile_Foot1,!Tile_Hand3,!Tile_Tail  : db !Tile_Empty,!Tile_Hand2,!Tile_Foot2,!Tile_Hand2,!Tile_Tail 	;;  01    02    03    04
		db !Tile_Hand3,!Tile_Hand3,!Tile_Empty,!Tile_Foot4,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Empty,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Empty,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Empty,!Tile_Tail 	;;  05    06    07    08
		db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand3,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand3,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand3,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand3,!Tile_Tail 	;;  09    10    11    12
		db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand2,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand2,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand2,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand3,!Tile_Tail 	;;  13    14    15    16
		db !Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Hand3,!Tile_Tail  : db !Tile_Eyes, !Tile_Hand2,!Tile_Foot3,!Tile_Foot3,!Tile_Tail  : db !Tile_Eyes, !Tile_Hand1,!Tile_Empty,!Tile_Foot2,!Tile_Tail  : db !Tile_Eyes, !Tile_Empty,!Tile_Tail, !Tile_Foot1,!Tile_Hand1	;;  17    18    19    20
		db !Tile_Empty,!Tile_Empty,!Tile_Tail, !Tile_Foot1,!Tile_Hand1 : db !Tile_Empty,!Tile_Foot1,!Tile_Hand2,!Tile_Hand2,!Tile_Tail  : db !Tile_Hand3,!Tile_Empty,!Tile_Empty,!Tile_Foot2,!Tile_Tail  : db !Tile_Hand2,!Tile_Empty,!Tile_Empty,!Tile_Foot2,!Tile_Tail 	;;  21    22    23    24
		db !Tile_Hand2,!Tile_Eyes, !Tile_Foot2,!Tile_Empty,!Tile_Tail  : db !Tile_Foot3,!Tile_Hand1,!Tile_Empty,!Tile_Empty,!Tile_Tail  : db !Tile_Hand3,!Tile_Foot3,!Tile_Empty,!Tile_Hand1,!Tile_Tail  : db !Tile_Hand3,!Tile_Foot3,!Tile_Empty,!Tile_Hand1,!Tile_Tail 	;;  25    26    27    28
		db !Tile_Foot2,!Tile_Hand1,!Tile_Foot3,!Tile_Empty,!Tile_Tail  : db !Tile_Foot3,!Tile_Hand1,!Tile_Foot2,!Tile_Empty,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot1,!Tile_Foot1,!Tile_Empty,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot1,!Tile_Foot1,!Tile_Empty,!Tile_Tail 	;;  29    30    31    32
		db !Tile_Hand1,!Tile_Foot1,!Tile_Foot1,!Tile_Empty,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot1,!Tile_Foot1,!Tile_Empty,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot1,!Tile_Foot1,!Tile_Empty,!Tile_Tail  : db !Tile_Hand1,!Tile_Foot1,!Tile_Foot1,!Tile_Empty,!Tile_Tail 	;;  33    34    35    36
		db !Tile_Hand1,!Tile_Foot1,!Tile_Foot1,!Tile_Empty,!Tile_Tail  : db !Tile_Foot1,!Tile_Foot1,!Tile_Tail, !Tile_Hand3,!Tile_Hand3 : db !Tile_Hand3,!Tile_Empty,!Tile_Tail, !Tile_Foot4,!Tile_Hand3 : db !Tile_Foot3,!Tile_Hand1,!Tile_Empty,!Tile_Empty,!Tile_Tail 	;;  37    38    39    40
		db !Tile_Foot3,!Tile_Hand1,!Tile_Empty,!Tile_Empty,!Tile_Tail  : db !Tile_Foot3,!Tile_Hand1,!Tile_Empty,!Tile_Empty,!Tile_Tail  : db !Tile_Foot3,!Tile_Hand1,!Tile_Empty,!Tile_Empty,!Tile_Tail  : db !Tile_Foot3,!Tile_Hand1,!Tile_Empty,!Tile_Empty,!Tile_Tail 	;;  41    42    43    44
		db !Tile_Foot3,!Tile_Hand1,!Tile_Empty,!Tile_Empty,!Tile_Tail  : db !Tile_Foot3,!Tile_Hand1,!Tile_Empty,!Tile_Empty,!Tile_Tail 															 			;;  45    46    47

.properties	db $00,$00,$00,$00,$00 : db $00,$00,$00,$80,$00 : db $00,$00,$00,$80,$00 : db $00,$00,$40,$00,$00	;;  01    02    03    04
		db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00	;;  05    06    07    08
		db $00,$00,$00,$C0,$00 : db $00,$00,$00,$C0,$00 : db $00,$00,$00,$C0,$00 : db $00,$00,$00,$C0,$00	;;  09    10    11    12
		db $00,$00,$00,$C0,$00 : db $00,$00,$00,$40,$00 : db $00,$00,$00,$40,$00 : db $00,$00,$00,$40,$00	;;  13    14    15    16
		db $00,$00,$00,$40,$00 : db $00,$C0,$00,$00,$00 : db $00,$40,$00,$40,$00 : db $00,$00,$00,$C0,$C0	;;  17    18    19    20
		db $00,$00,$00,$C0,$C0 : db $00,$00,$00,$00,$00 : db $C0,$00,$00,$40,$00 : db $80,$00,$00,$00,$00	;;  21    22    23    24
		db $C0,$00,$00,$00,$00 : db $00,$00,$00,$00,$00 : db $C0,$00,$00,$00,$00 : db $C0,$00,$00,$00,$00	;;  25    26    27    28
		db $00,$00,$40,$00,$00 : db $00,$00,$40,$00,$00 : db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00	;;  29    30    31    32
		db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00	;;  33    34    35    36
		db $00,$00,$00,$00,$00 : db $00,$00,$00,$C0,$80 : db $C0,$00,$00,$00,$80 : db $00,$00,$00,$00,$00	;;  37    38    39    40
		db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00	;;  41    42    43    44
		db $00,$00,$00,$00,$00 : db $00,$00,$00,$00,$00							 	;;  45    46    47

DrawItem:
	LDA !1602,x
	STA $03
	LDA !C2,x
	AND #$20
	BEQ +
	LDA #$1C
	STA $03
+	LDA !1594,x
	BEQ NoOAM
	CMP #$FF
	BNE +
	LDA #$C0
	STA $04
	LDA #$0B
	STA $05

+	PHX
	LDX $03
	LDA NoOAM_xpos,x
	PHX
	LDX $02
	BNE +
	EOR #$FF
	INC
+	PLX
	CLC
	ADC $00
	STA !0300,y

	LDA NoOAM_ypos,x
	CLC
	ADC $01
	STA !0301,y

	LDA $04
	STA !0302,y

	LDA $05
	PHX
	LDX $02
	BNE +
	EOR #$40
+	PLX
	ORA $64
	STA !0303,y

	PHY
	TYA
	LSR : LSR
	TAY
	LDA #$02
	STA !0460,y
	PLY
.nodraw	PLX
NextOAM:
	INY : INY
	INY : INY
	INC $0F
NoOAM:	RTS

		;;  01  02  03  04  05  06  07  08  09  10  11  12  13  14  15  16
		;;  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32
		;;  33  34  35  36  37  38  39  40  41  42  43  44  45  46
.xpos		db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$02,$02,$02
		db $02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$F3,$F3,$F3,$F3
		db $F3,$F4,$F3,$F8,$F8,$00,$00,$F6,$F7,$F6,$F8,$F8,$F6,$F6

.ypos		db $F0,$F1,$F1,$F5,$EE,$F0,$F1,$EF,$EF,$EE,$ED,$EF,$F0,$F1,$F2,$F2
		db $F2,$EE,$F2,$F3,$F3,$F3,$F1,$EE,$EF,$EE,$EE,$EE,$FA,$F9,$FB,$FB
		db $FB,$FC,$FB,$00,$00,$F0,$E4,$FB,$FC,$FB,$00,$00,$FB,$FB