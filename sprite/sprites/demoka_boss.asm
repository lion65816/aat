;=========================================================
; The Bunny Queen (Not Reisen)
; by PSI Ninja
; based on code by yoshicookiezeus, ASM, and Erik557
;
; Does not use the first extra bit.
;
; Extra property byte 1:
; 01 = Flip graphically if hitting a wall
; 02 = Follow Mario
;=========================================================

!BossStartHP = $40		;> $63 = 99 HP, $40 = 64 HP, $0A = 10 HP
!BossEnrageHP = $21		;> $32 = 50 HP, $20 = 32 HP, $05 = 5 HP
!Cooldown = $14			;> $0F = 15 frames, $14 = 20 frames, $1E = 30 frames

; Free RAM addresses.
!BossCurrentHP = $18C5|!addr
!PhaseNumber = $18C6|!addr
!Animation = $18C7|!addr
!Enraged = $18C8|!addr
!PhaseCounter = $18C9|!addr
!SpawnedBullets = $18CA|!addr

;=================================
; INIT and MAIN Wrappers
;=================================

print "INIT ",pc
	LDA #!BossStartHP	;\ Initialize boss HP.
	STA !BossCurrentHP	;/
	STZ !PhaseNumber
	STZ !Animation
	STZ !Enraged
	STZ !PhaseCounter
	STZ !SpawnedBullets
	LDA #$FF			;\ Initialize the frame counter.
	STA !154C,x			;/

	LDA #$02			;\ Initialize the first extra property byte of this custom sprite.
	STA !7FAB28,x		;/ #$02 = the sprite follows the player

	%SubHorzPos()		;\ Determine the sprite's initial horizontal direction.
	TYA					;|
	STA $157C,x			;/
	%SubVertPos()		;\ Determine the sprite's initial vertical direction.
	TYA					;|
	STA $151C,x			;/
	LDA #$01			;\ Force the sprite to face left, initially.
	STA !157C,x			;/
	RTL

print "MAIN ",pc
	PHB					;\ Main sprite function, just calls local subroutine.
	PHK					;|
	PLB					;|
	JSR Boss			;|
	PLB					;|
	RTL					;/

;========================
; Main routine
;========================

Boss:
	JSR Intro_Sequence	;> Phases 0-2
	JSR Enrage			;> Phases 5-6
	JSR Spawn_Bullets	;> Phases 7-8
	JSR Death_Sequence	;> Phases 9-10

	; Every 255 frames, change the sprite's movement pattern.
	LDA !154C,x
	BNE +
	LDA !PhaseNumber
	CMP #$03
	BEQ .change_to_phase4
	CMP #$04
	BEQ .change_to_phase3
	BRA +
.change_to_phase4
	INC !PhaseNumber
	INC !PhaseCounter
	LDA #$FF
	STA !154C,x
	BRA +
.change_to_phase3
	DEC !PhaseNumber
	INC !PhaseCounter
	LDA #$FF
	STA !154C,x
	BRA +
+

	LDA !PhaseNumber	;\ Don't damage the sprite during the intro sequence.
	CMP #$03			;|
	BCC .no_damage		;/
	CMP #$05			;\ Nor during the enrage sequence.
	BEQ .no_damage		;|
	CMP #$06			;|
	BEQ .no_damage		;/
	CMP #$09			;\ Nor during the death sequence.
	BEQ .no_damage		;|
	CMP #$0A			;|
	BEQ .no_damage		;/

	LDA !1540,x			;\ If the cooldown timer is not zero,
	BNE .no_damage		;/ then the sprite cannot be damaged.
	%FireballContact()	;\ Otherwise, check if a fireball made contact with the sprite.
	BCC .no_damage		;/ If not, then do not damage the sprite.
	DEC !BossCurrentHP	;> Otherwise, the sprite loses 1 HP.
	LDA #!Cooldown		;\ Set the cooldown timer to give the
	STA !1540,x			;/ sprite some invincibility frames.
	LDA !BossCurrentHP	;\ Start the death sequence when the
	BNE .no_damage		;| boss has zero HP.
	LDA #$09			;|
	STA !PhaseNumber	;|
	LDA #$FF			;|
	STA !154C,x			;/

.no_damage
	LDA !1540,x			;\ Draw the sprite graphics normally
	BEQ .draw_gfx		;/ if the cooldown timer is zero.
	LSR					;\ Otherwise, draw the graphics every other frame to make the
	AND #$01			;| sprite flicker, to indicate that it has been damaged.
	BNE .check_phase	;/

.draw_gfx
	JSR Graphics

.check_phase
	LDA !PhaseNumber
	CMP #$03
	BEQ .phase3
	CMP #$04
	BEQ .phase4
	BRA .return
.phase3
	JSR Phase_3
	BRA .return
.phase4
	JSR Phase_4
	BRA .return
.return
	RTS

;=============================================
; Phases 0-2: Play intro sequence
;=============================================

Intro_Sequence:
	LDA !PhaseNumber
	BEQ .phase0
	CMP #$01
	BEQ .phase1
	CMP #$02
	BEQ .phase2
	BNE .return
.phase0
	LDA !154C,x				;\ For 159 frames, the boss rises
	CMP #$60				;| up one pixel at a time.
	BEQ .change_to_phase1	;|
	DEC !D8,x				;|
	BRA .return				;/
.change_to_phase1
	LDA #$FF
	STA !154C,x
	INC !PhaseNumber
.phase1
	LDA !154C,x				;\ For 127 frames, the boss
	CMP #$80				;| waits in place.
	BEQ .change_to_phase2	;|
	BRA .return				;/
.change_to_phase2
	LDA #$FF
	STA !154C,x
	INC !PhaseNumber
.phase2
	LDA !154C,x				;\ For 127 frames, the boss
	CMP #$80				;| does the winking pose.
	BEQ .change_to_phase3	;|
	JMP .return				;/
.change_to_phase3
	LDA #$52				;\ Change the music and enter
	STA $1DFB|!addr			;| the main AI loop.
	LDA #$FF				;|
	STA !154C,x				;|
	INC !PhaseNumber		;/
.return
	RTS

;=============================================
; Phase 3: Phanto behavior
; Code mostly based on Phanto by yoshicookiezeus.
;=============================================

X_Accel:
	db $02,$FE,$06,$FA		;> The horizontal acceleration of the sprite.
Y_Accel:
	db $02,$FE,$06,$FA		;> The vertical acceleration of the sprite.
Max_X_Speed:
	db $28,$D8,$38,$C8		;> The maximum horizontal speed of the sprite.
Max_Y_Speed:
	db $18,$E8,$28,$D8		;> The maximum vertical speed of the sprite.

Phase_3:
	LDA !14C8,x
	EOR #$08
	ORA $9D
	BEQ +
	JMP .return
+

	LDA $14					;\ Every 128 frames,
	CMP #$80				;| spawn a Homing Bullet.
	BNE +					;|
	LDA #$1A				;|
	SEC						;|
	STZ $00					;|
	STZ $01					;|
	STZ $02					;|
	STZ $03					;|
	%SpawnSprite2()			;/
	TYX
	LDA !166E,x				;\ Can be killed with fireballs and cape.
	AND #$CF				;|
	STA !166E,x				;/
+

	JSL $01A7DC|!BankB		;> Process contact with the player.
	BCC +
	JSL $00F5B7|!BankB
+

	LDA $14					;\ only change speeds every fourth frame
	AND #$03				;|
	BNE .ApplySpeed			;/

	%SubHorzPos()			;\ Update the sprite's direction
	TYA						;| facing the player.
	STA !157C,x				;/
	LDA !Enraged			;\ While enraged, increase the X speed.
	BEQ +					;|
	INY #2					;/
+
	LDA !sprite_speed_x,x	;\ if max horizontal speed in the appropriate
	CMP Max_X_Speed,y		;| direction achieved,
	BEQ .MaxXSpeedReached	;/ don't change horizontal speed
	CLC						;\ else,
	ADC X_Accel,y			;| accelerate in appropriate direction
	STA !sprite_speed_x,x	;/
.MaxXSpeedReached
	%SubVertPos()
	LDA !Enraged			;\ While enraged, increase the Y speed.
	BEQ +					;|
	INY #2					;/
+
	LDA !sprite_speed_y,x	;\ if max vertical speed in the appropriate
	CMP Max_Y_Speed,y		;| direction achieved,
	BEQ .ApplySpeed			;/ don't change vertical speed
	CLC						;\ else,
	ADC Y_Accel,y			;| accelerate in appropriate direction
	STA !sprite_speed_y,x	;/
.ApplySpeed
	JSL $019138|!bank		;> Interact with blocks (or $01802A)
	LDA !1588,x
	AND #$03
	BNE .x_collision
	BRA +
.x_collision
	STZ !sprite_speed_x,x
+
	LDA !1588,x
	AND #$0C
	BNE .y_collision
	BRA +
.y_collision
	STZ !sprite_speed_y,x
+
	JSL $018022|!BankB		;> Update X position without gravity (apply X speed).
	JSL $01801A|!BankB		;> Update Y position without gravity (apply Y speed).
.return
	RTS

;=============================================
; Phase 4: Following Diagonal Podoboo behavior
; Code mostly based on Giant Reflecting Fireball
; by ASM and Erik557.
;=============================================

!DirCheckTime = $3F		;\ How many frames before checking if the player and sprite are facing in the same direction.
						;/ Allowed values: 01,03,07,0F,1F,3F,7F,FF

XSpeeds:
	db $18,$E8,$28,$D8
YSpeeds:
	db $18,$E8,$28,$D8

Phase_4:
	LDA !14C8,x
	EOR #$08
	ORA $9D
	BEQ +
	JMP .return
+
	LDA #$00
	%SubOffScreen()

	LDA $14				;\ Every 128 frames,
	CMP #$80			;| spawn a Homing Bullet.
	BNE +				;|
	LDA #$1A			;|
	SEC					;|
	STZ $00				;|
	STZ $01				;|
	STZ $02				;|
	STZ $03				;|
	%SpawnSprite2()		;/
	TYX
	LDA !166E,x			;\ Can be killed with fireballs and cape.
	AND #$CF			;|
	STA !166E,x			;/
+

	JSL $01A7DC|!BankB	;\ Process contact with the player.
	BCC +				;| If contact was made, then hurt the player.
	JSL $00F5B7|!BankB	;/
+
	LDA !7FAB28,x
	AND #$02
	BEQ .DontFlipY
	LDA $14
	AND.b #!DirCheckTime
	BNE .DontFlipY

	%SubHorzPos()
	TYA
	CMP !157C,x
	BEQ .DontFlipX
	STA !157C,x

.DontFlipX
	%SubVertPos()
	TYA
	CMP !151C,x
	BEQ .DontFlipY
	STA !151C,x

.DontFlipY
	LDA !1588,x
	BIT #$03
	BEQ .NoXCont
	LDA !157C,x
	EOR #$01
	STA !157C,x

	LDA !1588,x
.NoXCont
	AND #$0C
	BEQ .NoYCont
	LDA !151C,x
	EOR #$01
	STA !151C,x

.NoYCont
	LDY !157C,x
	LDA !Enraged		;\ While enraged, increase the X speed.
	BEQ +				;|
	INY #2				;/
+
	LDA XSpeeds,y
	STA !B6,x
	LDY !151C,x
	LDA !Enraged		;\ While enraged, increase the Y speed.
	BEQ +				;|
	INY #2				;/
+
	LDA YSpeeds,y
	STA !AA,x

	JSL $01802A			;> Update X/Y position, including gravity and block interaction.
.return:
	RTS

;=============================================
; Phases 5-6: Enrage
;=============================================

Enrage:
	LDA !BossCurrentHP
	CMP #!BossEnrageHP
	BCS +
	LDA !Enraged
	BNE +
	LDA #$05
	STA !PhaseNumber
	LDA #$FF
	STA !154C,x
	INC !Enraged		;> !Enraged = $01
+
	LDA !PhaseNumber
	CMP #$05
	BEQ .phase5
	CMP #$06
	BEQ .phase6
	BNE .return
.phase5
	STZ !SpawnedBullets	;> Reset this flag just in case the boss becomes enraged during phase 8.
	LDA $14				;\ Play the coin SFX
	AND #$02			;| every other frame.
	BEQ +				;|
	LDA #$01			;|
	STA $1DFC|!addr		;|
	BRA ++				;|
+						;|
	STZ $1DFC|!addr		;/
++
	LDA !154C,x
	CMP #$80
	BEQ .change_to_phase6
	BRA .return
.change_to_phase6
	LDA #$FF
	STA !154C,x
	INC !PhaseNumber
	INC !Enraged		;> !Enraged = $02
.phase6
	LDA !154C,x
	CMP #$80
	BEQ .change_to_phase3
	BRA .return
.change_to_phase3
	LDA #$FF
	STA !154C,x
	LDA #$03
	STA !PhaseNumber
.return
	RTS

;=============================================
; Phases 7-8: Spawn bullets
;=============================================

BulletHeightLow:
	db $D0,$E0,$F0,$00,$10,$20,$30,$40,$50,$60,$70,$80
BulletHeightHigh:
	db $00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01,$01
BanzaiHeightLow:
	db $D0,$10,$50
BanzaiHeightHigh:
	db $00,$01,$01

Spawn_Bullets:
	LDA !PhaseCounter
	CMP #$03
	BNE +
	STZ !PhaseCounter
	LDA #$07
	STA !PhaseNumber
	LDA #$FF
	STA !154C,x
+
	LDA !PhaseNumber
	CMP #$07
	BEQ .phase7
	CMP #$08
	BEQ .phase8
	JMP .return
.phase7
	JSR BulletWarning

	LDA $14				;\ Play the coin SFX
	AND #$02			;| every other frame.
	BEQ +				;|
	LDA #$01			;|
	STA $1DFC|!addr		;|
	BRA ++				;|
+						;|
	STZ $1DFC|!addr		;/
++
	LDA !154C,x
	CMP #$80
	BEQ .change_to_phase8
	JMP .return
.change_to_phase8
	LDA #$FF
	STA !154C,x
	INC !PhaseNumber
.phase8
	LDA !154C,x
	CMP #$80
	BNE +
	JMP .change_to_phase3
+
	LDA !SpawnedBullets
	BEQ +
	JMP .return
+
	LDA !Enraged
	BNE ..spawn_banzai

..spawn_bullet
	PHX
	LDY #$00
--
	CPY #$0C
	BEQ ++
	LDX #!SprSize-3		;> Skip the last two slots (otherwise, the tweaker properties may not work).
-
	LDA !14C8,x
	BEQ +
	DEX
	BPL -
	BRA ++				;> If no free slot found, then return.
+
	LDA #$1C			;\ Spawn Bullet Bill.
	STA !9E,x			;|
	JSL $07F7D2|!BankB	;/
	LDA #$01
	STA !14C8,x
	LDA #$FF
	STA !E4,x
	LDA #$00
	STA !14E0,x
	LDA BulletHeightLow,y
	STA !D8,x
	LDA BulletHeightHigh,y
	STA !14D4,x
	LDA #$00
	STA !B6,x
	STA !AA,x
	LDA #$01
	STA !SpawnedBullets
	INY
	BRA --
++
	PLX
	BRA .return

..spawn_banzai
	PHX
	LDY #$00
--
	CPY #$03
	BEQ ++
	LDX #!SprSize-3		;> Skip the last two slots (otherwise, the tweaker properties may not work).
-
	LDA !14C8,x
	BEQ +
	DEX
	BPL -
	BRA ++				;> If no free slot found, then return.
+
	LDA #$9F			;\ Spawn Banzai Bill.
	STA !9E,x			;|
	JSL $07F7D2|!BankB	;/
	LDA #$01
	STA !14C8,x
	LDA #$FF
	STA !E4,x
	LDA #$00
	STA !14E0,x
	LDA BanzaiHeightLow,y
	STA !D8,x
	LDA BanzaiHeightHigh,y
	STA !14D4,x
	LDA #$00
	STA !B6,x
	STA !AA,x
	LDA #$01
	STA !SpawnedBullets
	INY
	BRA --
++
	PLX
	BRA .return
.change_to_phase3
	STZ !SpawnedBullets
	LDA #$FF
	STA !154C,x
	LDA #$03
	STA !PhaseNumber
.return
	RTS

;=============================================
; Phases 9-10: Play death sequence
;=============================================

Death_Sequence:
	LDA !PhaseNumber
	CMP #$09
	BEQ .phase9
	CMP #$0A
	BEQ .phase10
	;BNE .return
	JMP .return
.phase9
	PHX
	LDX #!SprSize-3	;> Kill all bullets on the screen (skip the last two sprite slots).
-
	LDA !9E,x		;\ Check if the sprite is a Banzai Bill.
	CMP #$9F		;|
	BNE +			;/
	LDA !14C8,x		;\ If it's already killed, then branch.
	CMP #$08		;|
	BCC +			;/
	STZ $00			;\ Spawn a puff of smoke at the last position of the bullet.
	STZ $01			;| The smoke lasts for 27 frames.
	LDA #$1B		;|
	STA $02			;|
	LDA #$01		;|
	%SpawnSmoke()	;/
	LDA #$04		;\ Kill as if by a spinjump.
	STA !14C8,x		;/
+
	LDA !7FAB9E,x	;\ Check if the sprite is a Homing Bill.
	CMP #$1A		;|
	BNE +			;/
	LDA !14C8,x		;\ If it's already killed, then branch.
	CMP #$08		;|
	BCC +			;/
	STZ $00			;\ Spawn a puff of smoke at the last position of the bullet.
	STZ $01			;| The smoke lasts for 27 frames.
	LDA #$1B		;|
	STA $02			;|
	LDA #$01		;|
	%SpawnSmoke()	;/
	LDA #$04		;\ Kill as if by a spinjump.
	STA !14C8,x		;/
+
	DEX
	BPL -
	PLX

	LDA $14			;\ Play the magic SFX
	AND #$02		;| every other frame.
	BEQ +			;|
	LDA #$10		;|
	STA $1DF9|!addr	;|
	BRA ++			;|
+					;|
	STZ $1DF9|!addr	;/
++
	LDA !154C,x
	CMP #$80
	BEQ .change_to_phase10
	BRA .return
.change_to_phase10
	LDA #$FF
	STA !154C,x
	INC !PhaseNumber
.phase10
	LDA !154C,x
	CMP #$80
	BEQ .kill
	BRA .return
.kill
	LDA #$23		;\ Play Lemmy/Wendy fall SFX.
	STA $1DF9|!addr	;/
	LDA #$02		;\ Kill as if by a shell.
	STA !14C8,x		;/
	LDA #$01		;\ Freeze the player on level end and enable boss sequence cutscene.
	STA $13C6|!addr	;/
	LDA #$FF		;\ Set level end timer.
	STA $1493|!addr	;/
	LDA #$03		;\ Set the boss victory music.
	STA $1DFB|!addr	;/
.return
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bullet warning routine
; Uses the MaxTile system to request OAM slots. Needs SA-1 v1.40.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Needs to be an even number of tiles because of how the bit table is set up.
!NumWarningTiles = 4

WarningYX:
	dw $F8F0,$28F0,$68F0,$A8F0		;> Three warning indicators are shown (the first tile is drawn offscreen).

BulletWarning:
	LDY.b #$00+(!NumWarningTiles)	;> Request 3 tiles. Input parameter for call to MaxTile.
	REP #$30						;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0000					;> Maximum priority. Input parameter for call to MaxTile.
	JSL $0084B0						;\ Request MaxTile slots (does not modify scratch ram at the time of writing).
									;| Returns 16-bit pointer to the OAM general buffer in $3100.
									;/ Returns 16-bit pointer to the OAM attribute buffer in $3102.
	BCC +							;\ Carry clear: Failed to get OAM slots, abort.
									;/ ...should never happen, since this will be executed before sprites, but...
	PHX

	LDX $3100								;> Main index (16-bit pointer to the OAM general buffer)
	LDY.w #$0000+((!NumWarningTiles-1)*2)	;> Loop index
-
	LDA WarningYX,y			;\ Load X and Y coordinates
	STA $400000,x			;/
	LDA $14
	AND #$0004				;> Change the palette every four frames (flashing).
	BEQ .palette1
	LDA.w #$381D			;> High byte: YXPP CCCT, Low byte: Tile number
	BRA .palette2
.palette1
	LDA.w #$341D			;> High byte: YXPP CCCT, Low byte: Tile number
.palette2
	STA $400002,x

	INX #4					;\ Move to next slot and loop
	DEY #2					;|
	BPL -					;/

	LDX $3102							;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDY.w #$0000+(!NumWarningTiles)/2-1	;> Loop index
	LDA.w #$0000						;> Small (8x8) for both tiles
-
	STA $400000,x			;> Store to both

	INX #2					;\ Loop to set the remaining OAM extra bits.
	DEY						;|
	BPL -					;/

	PLX
+
	SEP #$30
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10	;> Facing left (to flip the non-zero tiles, use: EOR #$E0)
YDisp:
	db $F0,$F0,$F0,$00,$00,$00,$10,$10,$10
Tilemap:
	db $00,$02,$04,$20,$22,$24,$40,$42,$44	;> Animation frame 0
	db $06,$08,$0A,$26,$28,$2A,$46,$48,$4A	;> Animation frame 1
	db $0C,$0E,$60,$2C,$2E,$62,$4C,$4E,$45	;> Animation frame 2
	db $06,$08,$0A,$26,$28,$2A,$46,$48,$4A	;> Animation frame 3
	db $64,$66,$68,$6A,$6C,$6E,$C6,$C8,$CA	;> Animation frame 4 (wink)
	db $4C,$8A,$4C,$4C,$8C,$A8,$AA,$AC,$4C	;> Animation frame 5 (death)
Props:
	db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E	;> Facing left (to flip the tiles, use: EOR #$40)

Graphics:
	%GetDrawInfo()		;\ Returns sprite index in Y,
						;| sprite X position (relative to the screen) in $00, and
						;/ sprite Y position (relative to the screen) in $01.

	LDX #$08			;> Need to run this loop 9 times (upload 9 sprite tiles).
-
	PHX

	LDA $01				;\ Store sprite's Y position in OAM.
	CLC					;|
	ADC YDisp,x			;|
	STA $0301|!Base2,y	;/

	LDA XDisp,x			;\ Save these to scratch RAM while we
	STA $02				;| check the sprite's direction.
	LDA Props,x			;|
	STA $03				;/

	LDX $15E9|!Base2	;> Load the sprite index.
	LDA !157C,x			;\ If the sprite is facing left (!157C = #$01),
	BNE .no_flip		;/ then load the XDisp and Props bytes normally.

	LDA $02				;\ Otherwise, reverse the X direction draw
	BEQ +				;| order for non-zero tiles, and store
	EOR #$E0			;| sprite's X position in OAM.
+						;|
	STA $02				;|
	LDA $00				;|
	CLC					;|
	ADC $02				;|
	STA $0300|!Base2,y	;/

	LDA $03				;\ Flip the sprite's X direction in
	EOR #$40			;| YXPPCCCT, and store it in OAM.
	ORA !15F6,x			;|
	ORA $64				;|
	STA $0303|!Base2,y	;/
	LDA !Enraged		;\ If the sprite is enraged (phase 5),
	CMP #$01			;| then skip to the palette flashing code.
	BEQ +				;| Otherwise, while enraged
	CMP #$02			;| (after reaching phase 6),
	BNE ++				;| change the sprite's palette
	LDA $0303|!Base2,y	;| for the remainder of the
	DEC #$04			;| fight.
	STA $0303|!Base2,y	;|
	BRA ++				;/
+
	LDA $14				;\ Every two frames, switch the
	AND #$02			;| palette from normal to
	BEQ ++				;| enraged to make it flash.
	LDA $0303|!Base2,y	;|
	EOR #$04			;|
	STA $0303|!Base2,y	;/
++
	LDA !PhaseNumber	;\ If the sprite is in predeath (phase 9),
	CMP #$09			;| then skip to the palette flashing code.
	BEQ +++				;| Otherwise, while dying
	CMP #$0A			;| (after reaching phase 10),
	BNE ++++			;| change the sprite's palette
	LDA $0303|!Base2,y	;| for the remainder of the
	DEC #$04			;| fight.
	STA $0303|!Base2,y	;|
	BRA ++++			;/
+++
	LDA $14				;\ Every two frames, switch the
	AND #$02			;| palette from enraged to
	BEQ ++++			;| dying to make it flash.
	LDA $0303|!Base2,y	;|
	EOR #$0C			;|
	STA $0303|!Base2,y	;/
++++
	BRA .check_animation

.no_flip
	LDA $00				;\ Store sprite's X position in OAM.
	CLC					;|
	ADC $02				;|
	STA $0300|!Base2,y	;/

	LDA $03				;\ Store sprite's YXPPCCCT in OAM.
	ORA !15F6,x			;|
	ORA $64				;|
	STA $0303|!Base2,y	;/
	LDA !Enraged		;\ If the sprite is enraged (phase 5),
	CMP #$01			;| then skip to the palette flashing code.
	BEQ +				;| Otherwise, while enraged
	CMP #$02			;| (after reaching phase 6),
	BNE ++				;| change the sprite's palette
	LDA $0303|!Base2,y	;| for the remainder of the
	DEC #$04			;| fight.
	STA $0303|!Base2,y	;|
	BRA ++				;/
+
	LDA $14				;\ Every two frames, switch the
	AND #$02			;| palette from normal to
	BEQ ++				;| enraged to make it flash.
	LDA $0303|!Base2,y	;|
	EOR #$04			;|
	STA $0303|!Base2,y	;/
++
	LDA !PhaseNumber	;\ If the sprite is in predeath (phase 9),
	CMP #$09			;| then skip to the palette flashing code.
	BEQ +++				;| Otherwise, while dying
	CMP #$0A			;| (after reaching phase 10),
	BNE ++++			;| change the sprite's palette
	LDA $0303|!Base2,y	;| for the remainder of the
	DEC #$04			;| fight.
	STA $0303|!Base2,y	;|
	BRA ++++			;/
+++
	LDA $14				;\ Every two frames, switch the
	AND #$02			;| palette from enraged to
	BEQ ++++			;| dying to make it flash.
	LDA $0303|!Base2,y	;|
	EOR #$0C			;|
	STA $0303|!Base2,y	;/
++++

.check_animation
	PLX					;\ Restore the loop counter, but store it to scratch RAM
	STX $02				;/ in case its value needs to be manipulated further below.
	LDA !Animation		;\ When frame 32 is reached,
	CMP #$20			;| repeat the animation frame
	BNE +				;| draw cycle.
	STZ !Animation		;/
+
	LDA !PhaseNumber	;\ Do the winking pose during
	CMP #$02			;| the boss intro sequence,
	BEQ .wink			;| while enraging, and during
	CMP #$05			;| the bullet wall summoning.
	BEQ .wink			;|
	CMP #$06			;|
	BEQ .wink			;|
	CMP #$07			;|
	BEQ .wink			;|
	CMP #$08			;|
	BEQ .wink			;/
	CMP #$09			;\ Transform during the death sequence.
	BEQ .predeath		;|
	CMP #$0A			;|
	BEQ .death			;/
	BRA .normal			;> Otherwise, draw the regular frames.
.predeath
	LDA $14
	AND #$02
	BEQ .normal
.death
	TXA					;\ Increment X by 45 to draw
	CLC					;| animation frame 5.
	ADC #$2D			;|
	TAX					;|
	BRA .store_tile		;/
.wink
	TXA					;\ Increment X by 36 to draw
	CLC					;| animation frame 4.
	ADC #$24			;|
	TAX					;|
	BRA .store_tile		;/
.normal
	LDA !Animation		;\ For frames 0-7, draw
	CMP #$08			;| animation frame 0.
	BCC .store_tile		;/
	CMP #$10			;\ For frames 8-15, draw
	BCC .frame1			;/ animation frame 1.
	CMP #$18			;\ For frames 16-23, draw
	BCC .frame2			;/ animation frame 2.
	TXA					;\ Otherwise, for frames 24-31,
	CLC					;| increment X by 27 to draw
	ADC #$1B			;| animation frame 3.
	TAX					;/
	BRA .store_tile
.frame1
	TXA					;\ Increment X by 9 to draw
	CLC					;| animation frame 1.
	ADC #$09			;|
	TAX					;/
	BRA .store_tile
.frame2
	TXA					;\ Increment X by 18 to draw
	CLC					;| animation frame 2.
	ADC #$12			;|
	TAX					;/
.store_tile
	LDA Tilemap,x		;\ Store sprite's tile number in OAM.
	STA $0302|!Base2,y	;/

	INY #4				;> Offset by four bytes to get the next OAM slot.
	LDX $02				;> Restore the loop counter, in case it had been offset to calculate animation frame tiles.
	DEX					;\ Repeat the loop.
	BMI +				;|
	JMP -				;/
+
	LDX $15E9|!Base2	;> Load the boss' sprite index.
	LDY #$02			;> Needed for the final JSL (#$02 = size of OAM tiles is 16x16).
	LDA #$08			;> Needed for the final JSL (write to 9 OAM slots, minus 1).
	JSL $01B7B3			;> Finish OAM write caller subroutine.
	INC !Animation		;> Increment the animation frame counter.
	RTS
