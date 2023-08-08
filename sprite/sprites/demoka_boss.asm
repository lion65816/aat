;=========================================================
; Giant Reflecting Fireball
; Original by ASM
; Remoderated, recoded and made customizable by Erik557.
;
; Uses first extra bit: NO
;
; Extra property byte 1:
; 01 = Flip graphically if hitting a wall
; 02 = Follow Mario
;=========================================================

!BossStartHP = $0A
!BossCurrentHP = $18C5|!addr	;> Free RAM address
!Cooldown = $1E			;> Cooldown period in frames ($1E = 30 frames)
!PhaseNumber = $18C6|!addr	;> Free RAM address
!Animation = $18C7|!addr	;> Free RAM address

!DirCheckTime = $3F		;\ How many frames before checking if the player and sprite are facing in the same direction.
				;/ Allowed values: 01,03,07,0F,1F,3F,7F,FF

XSpeeds:
       db $18,$E8
YSpeeds:
       db $18,$E8

;=================================
; INIT and MAIN Wrappers
;=================================

print "INIT ",pc
	LDA #!BossStartHP	;\ Initialize boss HP.
	STA !BossCurrentHP	;/
	STA $0F48|!addr		;> [[[[[DEBUG]]]]]
	STZ !PhaseNumber	;> Start at Phase 0.
	STZ !Animation

	LDA #$02		;\ Initialize the first extra property byte of this custom sprite.
	STA !7FAB28,x		;/ #$02 = the sprite follows the player

	%SubHorzPos()		;\
	TYA			;| Determine the sprite's initial horizontal direction.
	STA $157C,x		;/
	%SubVertPos()		;\
	TYA			;| Determine the sprite's initial vertical direction.
	STA $151C,x		;/
	RTL

print "MAIN ",pc
	PHB			;\
	PHK			;|
	PLB			;| Main sprite function, just calls local subroutine.
	JSR Boss		;|
	PLB			;|
	RTL			;/

;========================
; Main routine
;========================

Boss:
	LDA !157C,x		;\ [[[[[DEBUG]]]]]
	STA $0DBF|!addr		;/ [[[[[DEBUG]]]]]

	LDA !1540,x		;\ If the cooldown timer is not zero,
	BNE .no_damage		;/ then the sprite cannot be damaged.
	%FireballContact()	;\ Otherwise, check if a fireball made contact with the sprite.
	BCC .no_damage		;/ If not, then do not damage the sprite.
	DEC !BossCurrentHP	;> Otherwise, the sprite loses 1 HP.
	DEC $0F48|!addr		;> [[[[[DEBUG]]]]]
	LDA #!Cooldown		;\ Set the cooldown timer to give the
	STA !1540,x		;/ sprite some invincibility frames.

	; [[[[[TBD]]]]]
	LDA !BossCurrentHP
	BEQ .kill
	CMP #$05
	BNE .no_damage
	LDA #$01
	STA !PhaseNumber
	BNE .no_damage
.kill
	%Star()

.no_damage
	LDA !1540,x		;\ Draw the sprite graphics normally
	BEQ .draw_gfx		;/ if the cooldown timer is zero.
	LSR			;\ Otherwise, draw the graphics every other frame to make the
	AND #$01		;| sprite flicker, to indicate that it has been damaged.
	BNE .check_phase	;/

.draw_gfx
	JSR Graphics

.check_phase
	LDA !PhaseNumber
	BEQ .phase0
	CMP #$01
	BEQ .phase1
	BRA .return
.phase0
	JSR Phase_0
	BRA .return
.phase1
	JSR Phase_1
	BRA .return
.return
	RTS

;=============================================
; Phase 0: Following Diagonal Podoboo behavior
;=============================================

Phase_0:
	LDA !14C8,x
	EOR #$08
	ORA $9D
	BNE .return
	LDA #$00
	%SubOffScreen()

	JSL $01A7DC
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
	LDA XSpeeds,y
	STA !B6,x
	LDY !151C,x
	LDA YSpeeds,y
	STA !AA,x

	JSL $01802A		;> Update X/Y position, including gravity and block interaction.
.return:
	RTS

;=============================================
; Phase 1: Phanto behavior
;=============================================

X_Accel:
	db $02,$FE		;> The horizontal acceleration of the sprite.
Y_Accel:
	db $02,$FE		;> The vertical acceleration of the sprite.
Max_X_Speed:
	db $28,$D8		;> The maximum horizontal speed of the sprite.
Max_Y_Speed:
	db $18,$E8		;> The maximum vertical speed of the sprite.

Phase_1:
	JSL $01A7DC|!BankB	; interact with Mario

	LDA $14			;\ only change speeds every fourth frame
	AND #$03		;|
	BNE .ApplySpeed		;/

	%SubHorzPos()		;\ 
	TYA			;| Update the sprite's direction
	STA !157C,x		;| facing the player.
	LDA !sprite_speed_x,x	;| if max horizontal speed in the appropriate
	CMP Max_X_Speed,y	;| direction achieved,
	BEQ .MaxXSpeedReached	;/ don't change horizontal speed
	CLC			;\ else,
	ADC X_Accel,y		;| accelerate in appropriate direction
	STA !sprite_speed_x,x	;/
.MaxXSpeedReached
	%SubVertPos()		;\ if max vertical speed in the appropriate
	LDA !sprite_speed_y,x	;| direction achieved,
	CMP Max_Y_Speed,y	;|
	BEQ .ApplySpeed		;/ don't change vertical speed
	CLC			;\ else,
	ADC Y_Accel,y		;| accelerate in appropriate direction
	STA !sprite_speed_y,x	;/
.ApplySpeed
	JSL $019138|!bank	;> Interact with blocks (or $01802A)
	LDA !1588,x
	AND #$03
	BNE .x_collision
	BRA +
.x_collision
	;LDA !sprite_speed_x,x
	;EOR #$FF
	;STA !sprite_speed_x,x
	STZ !sprite_speed_x,x
+
	LDA !1588,x
	AND #$0C
	BNE .y_collision
	BRA +
.y_collision
	;LDA !sprite_speed_y,x
	;EOR #$FF
	;STA !sprite_speed_y,x
	STZ !sprite_speed_y,x
+
	JSL $018022|!BankB	;> Update X position without gravity (apply X speed).
	JSL $01801A|!BankB	;> Update Y position without gravity (apply Y speed).
.return
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
	db $0C,$0E,$60,$2C,$2E,$62,$4C,$4E,$64	;> Animation frame 2
	db $06,$08,$0A,$26,$28,$2A,$46,$48,$4A	;> Animation frame 3
Props:
	db $0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E,$0E	;> Facing left (to flip the tiles, use: EOR #$40)

Graphics:
	%GetDrawInfo()		;\ Returns sprite index in Y,
				;| sprite X position (relative to the screen) in $00, and
				;/ sprite Y position (relative to the screen) in $01.

	LDX #$08		;> Need to run this loop 9 times (upload 9 sprite tiles).
-	PHX

	LDA $01			;\
	CLC			;| Store sprite's Y position in OAM.
	ADC YDisp,x		;|
	STA $0301|!Base2,y	;/

	LDA XDisp,x		;\
	STA $02			;| Save these to scratch RAM while we
	LDA Props,x		;| check the sprite's direction.
	STA $03			;/

	LDX $15E9|!Base2	;> Load the sprite index.
	LDA !157C,x		;\ If the sprite is facing left (!157C = #$01),
	BNE .no_flip		;/ then load the XDisp and Props bytes normally.

	LDA $02			;\
	BEQ +			;|
	EOR #$E0		;| Otherwise, reverse the X direction draw
+				;| order for non-zero tiles, and store
	STA $02			;| sprite's X position in OAM.
	LDA $00			;|
	CLC			;|
	ADC $02			;|
	STA $0300|!Base2,y	;/

	LDA $03			;\
	EOR #$40		;| Flip the sprite's X direction in
	ORA !15F6,x		;| YXPPCCCT, and store it in OAM.
	ORA $64			;|
	STA $0303|!Base2,y	;/

	BRA .check_animation

.no_flip
	LDA $00			;\
	CLC			;| Store sprite's X position in OAM.
	ADC $02			;|
	STA $0300|!Base2,y	;/

	LDA $03			;\
	ORA !15F6,x		;| Store sprite's YXPPCCCT in OAM.
	ORA $64			;|
	STA $0303|!Base2,y	;/

.check_animation
	PLX			;\ Restore the loop counter, but store it to scratch RAM
	STX $02			;/ in case its value needs to be manipulated further below.
	LDA !Animation
	CMP #$20
	BNE +
	STZ !Animation
+
	LDA !Animation
	CMP #$08
	BCC .store_tile
	CMP #$10
	BCC .frame1
	CMP #$18
	BCC .frame2
	INX #27
	BRA .store_tile
.frame1
	INX #9
	BRA .store_tile
.frame2
	INX #18
.store_tile
	LDA Tilemap,x		;\ Store sprite's tile number in OAM.
	STA $0302|!Base2,y	;/

	INY #4			;> Offset by four bytes to get the next OAM slot.
	LDX $02			;> Restore the loop counter, in case it had been offset to calculate animation frame tiles.
	DEX			;\
	BMI +			;| Repeat the loop.
	JMP -			;/
+
	LDX $15E9|!Base2	;> Load the boss' sprite index.
	LDY #$02		;> Needed for the final JSL (#$02 = size of OAM tiles is 16x16).
	LDA #$08		;> Needed for the final JSL (write to 9 OAM slots, minus 1).
	JSL $01B7B3		;> Finish OAM write caller subroutine.
	INC !Animation		;> Increment the animation frame counter.
	RTS
