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

!BossStartHP = $09
!BossCurrentHP = $18C5|!addr	;> Free RAM address
!Cooldown = $1E			;> Cooldown period in frames ($1E = 30 frames)
!PhaseNumber = $18C6|!addr	;> Free RAM address

!DirCheckTime = $3F		;\ How many frames before checking if the player and sprite are facing in the same direction.
				;/ Allowed values: 01,03,07,0F,1F,3F,7F,FF

XSpeeds:
       db $18,$E8
YSpeeds:
       db $18,$E8

; Phase 1 tables for Phanto behavior.
X_Accel:
	db $02,$FE		;> The horizontal acceleration of the sprite.
Y_Accel:
	db $02,$FE		;> The vertical acceleration of the sprite.
Max_X_Speed:
	db $28,$D8		;> The maximum horizontal speed of the sprite.
Max_Y_Speed:
	db $18,$E8		;> The maximum vertical speed of the sprite.

;=================================
; INIT and MAIN Wrappers
;=================================

print "INIT ",pc
	LDA #!BossStartHP	;\ Initialize boss HP.
	STA !BossCurrentHP	;/
	STA $0F48|!addr		;> [[[[[DEBUG]]]]]
	STZ !PhaseNumber	;> Start at Phase 0.

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
	BNE .no_damage
	LDA #$01
	STA !PhaseNumber
;	%Star()

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

Phase_1:
	JSL $01A7DC|!BankB	; interact with Mario

	LDA $14			;\ only change speeds every fourth frame
	AND #$03		;|
	BNE ApplySpeed		;/

	%SubHorzPos()		;\ if max horizontal speed in the appropriate
	LDA !sprite_speed_x,x	;| direction achieved,
	CMP Max_X_Speed,y	;|
	BEQ MaxXSpeedReached	;/ don't change horizontal speed
	CLC			;\ else,
	ADC X_Accel,y		;| accelerate in appropriate direction
	STA !sprite_speed_x,x	;/
MaxXSpeedReached:
	%SubVertPos()		;\ if max vertical speed in the appropriate
	LDA !sprite_speed_y,x	;| direction achieved,
	CMP Max_Y_Speed,y	;|
	BEQ ApplySpeed		;/ don't change vertical speed
	CLC			;\ else,
	ADC Y_Accel,y		;| accelerate in appropriate direction
	STA !sprite_speed_y,x	;/
ApplySpeed:
;	LDA !1588,x
;	AND #$01
;	BEQ .invert_x
;	AND #$02
;	BEQ .invert_x
;	BRA .skip
;.invert_x
;	LDA !sprite_speed_x,x
;	EOR #$FF
;	STA !sprite_speed_x,x
;.skip
;	LDA !1588,x
;	AND #$04
;	BEQ .invert_y
;	AND #$08
;	BEQ .invert_y
;	BRA .continue
;.invert_y
;	LDA !sprite_speed_y,x
;	EOR #$FF
;	STA !sprite_speed_y,x
;.continue
	JSL $018022|!BankB	;> Update X position without gravity (apply X speed).
	JSL $01801A|!BankB	;> Update Y position without gravity (apply Y speed).
.return
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

XDisp:
	db $00,$10,$00,$10	;> Facing left (to flip the tiles, use: EOR #$10)
YDisp:
	db $00,$00,$10,$10
Tilemap:
	db $C2,$C4,$E2,$E4
Props:
	db $00,$00,$00,$00	;> Facing left (to flip the tiles, use: EOR #$40)

Graphics:
	%GetDrawInfo()		;\ Returns sprite index in Y,
				;| sprite X position (relative to the screen) in $00, and
				;/ sprite Y position (relative to the screen) in $01.

	LDX #$03		;> Need to run this loop four times (upload four sprite tiles).
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
	EOR #$10		;| Otherwise, reverse the X direction
	STA $02			;| draw order, and store sprite's X
	LDA $00			;| position in OAM.
	CLC			;|
	ADC $02			;|
	STA $0300|!Base2,y	;/

	LDA $03			;\
	EOR #$40		;| Flip the sprite's X direction in
	ORA !15F6,x		;| YXPPCCCT, and store it in OAM.
	ORA $64			;|
	STA $0303|!Base2,y	;/

	BRA .store_tile

.no_flip
	LDA $00			;\
	CLC			;| Store sprite's X position in OAM.
	ADC $02			;|
	STA $0300|!Base2,y	;/

	LDA $03			;\
	ORA !15F6,x		;| Store sprite's YXPPCCCT in OAM.
	ORA $64			;|
	STA $0303|!Base2,y	;/

.store_tile
	PLX
	LDA Tilemap,x		;\ Store sprite's tile number in OAM.
	STA $0302|!Base2,y	;/

	INY #4			;> Offset by four bytes to get the next OAM slot.
	DEX			;\ Repeat the loop.
	BPL -			;/

	LDX $15E9|!Base2	;> Load the boss' sprite index.
	LDY #$02		;> Needed for the final JSL (#$02 = size of OAM tiles is 16x16).
	LDA #$03		;> Needed for the final JSL (write to 4 OAM slots, minus 1).
	JSL $01B7B3		;> Finish OAM write caller subroutine.
	RTS
