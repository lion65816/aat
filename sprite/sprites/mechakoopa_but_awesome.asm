; super mechakoopa from mario maker 2
; credit to imamelia for disassembly of original sprite
; modifications by von fahrenheit
; graphics by eminus

; set extra bit to enable flight

; choose page with CFG editor
; palette for each version is defined below
; the sprite uses one extra byte, which determines which type it is
;	00 - green, no special abilities unless flight is enabled with extra bit
;	01 - red gunner, shoots projectiles through its mouth
;	02 - blue lightning boy, shoots lightning through its mouth
;	03 - yellow bomb, explodes upon waking up


	; numeric defines
	!normalpalette		= $D		; default: D green
	!gunnerpalette		= $C		; default: C red
	!lightningpalette	= $B		; default: B blue
	!explodingpalette	= $A		; default: A yellow

	!attacktime		= 240		; number of frames until attack starts
	!flytime		= 128		; number of frames until flight (only applies if flight is enabled)

	!walkspeed		= 8



	; gunner version
	!projectile_speed	= 32
	!projectile_num		= $1C		; sprite num of projectile (defualt bullet bill)
	!projectile_custom	= 0		; set to 1 for custom sprite
	!projectile_bullet_bill	= 1		; set to 0 if something else should be shot (bullet bill has some odd programming choices so this was necessary)

	; lightning version
	!lightning_speed	= 40
	!lightning_num		= $03		; sprite num of lightning

	; exploding version
	!fuselength		= 180		; how many frames the sprite ticks before exploding upon being stunned

	; sprite tables
	!attacktimer		= !1504
	!flytimer		= !1510
	!state			= !151C		; 0 = normal, 1 = attacking, 2 = flying

	!keytimer		= !1570

	!fuse			= !1FD6		; used instead of !1540 for exploding version
	!takeofftimer		= !1FE2		; timer used for takeoff


	; toggles
	!secondhalf		= 1		; 0 = use SP1 or SP3, 1 = use SP2 or SP4



	; differences:
	;	- attack index
	;	- attack tilemap
	;	- attack code (.Attack)



Speed:
	db !walkspeed,-!walkspeed

XDisp:
	db $F8,$08,$F8,$00,$08,$00,$10,$00

YDisp:
	db $F8,$F8,$08,$00,$F9,$F9,$09,$00
	db $F8,$F8,$08,$00,$F9,$F9,$09,$00
	db $FD,$00,$05,$00,$00,$00,$08,$00

Tilemap:
	db $40,$42,$60,$51,$40,$42,$60,$0A
	db $40,$42,$60,$0C,$40,$42,$60,$0E
	db $00,$02,$10,$01,$00,$02,$10,$01

TileProp:
	db $00,$00,$00,$00,$40,$40,$40,$40
TileSize:
	db $02,$00,$00,$02


KeyXDisp:
	db $F9,$0F
KeyTileProp:
	db $40,$00
KeyTilemap:
	db $70,$71,$72,$71





AttackIndex:
	.Gunner
	db $00,$06,$0C,$12,$18,$18,$18,$18
	db $18,$18,$18,$18,$18,$18,$18,$18
	.Lightning
	db $00,$06,$0C,$12,$12,$12,$12,$12
	db $12,$12,$12,$12,$12,$12,$12,$12
AttackTilemap:		; format: each frame has 1 8x8 mouth tile, 2 16x16 head tiles and 3 8x8 foot tiles
	.Gunner
	db $23
	db $04,$05
	db $24,$25,$26
	db $36
	db $07,$08
	db $27,$28,$29
	db $36
	db $20,$21
	db $33,$34,$35
	db $37
	db $20,$21
	db $33,$34,$35
	db $23
	db $20,$21
	db $33,$34,$35
	.Lightning
	db $23
	db $04,$05
	db $24,$25,$26
	db $38
	db $07,$08
	db $27,$28,$29
	db $38
	db $20,$21
	db $33,$34,$35
	db $39
	db $20,$21
	db $33,$34,$35

AttackTileSize:
	db $00
	db $02,$02
	db $00,$00,$00

AttackDispX:
	db $FD
	db $F9,$01
	db $F9,$01,$09

AttackDispY:
	db $03
	db $F8,$F8
	db $08,$08,$08

FlyTilemap:
	db $04,$05
	db $24,$25,$26
	db $43,$43

FlyTileSize:
	db $02,$02
	db $00,$00,$00
	db $00,$00

FlyDispX:
	db $F9,$01
	db $F9,$01,$09
	db $01,$09

FlyDispY:
	db $F8,$F8
	db $08,$08,$08
	db $10,$10

ShootXDisp:
	db $04,$FC
ShootXSpeed:
	db !projectile_speed,-!projectile_speed

LightningXDisp:
	db $07,$F9
LightningXSpeed:
	db !lightning_speed,-!lightning_speed


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "INIT ",pc
	INIT:
		PHB : PHK : PLB
		%SubHorzPos()
		TYA : STA !157C,x
		LDA !15F6,x
		AND #$F1
		STA $00
		LDA !extra_byte_1,x
		CMP #$03
		BCC $02 : LDA #$03
		TAY
		LDA .Palette,y
		ORA $00
		STA !15F6,x
		STZ !fuse,x
		STZ !takeofftimer,x
		PLB
		RTL

	.Palette
		db (!normalpalette&$7)*2
		db (!gunnerpalette&$7)*2
		db (!lightningpalette&$7)*2
		db (!explodingpalette&$7)*2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "MAIN ",pc
	MAIN:
		PHB : PHK : PLB
		JSR MechakoopaMain
		PLB
		RTL


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	MechakoopaMain:
		JSL $03B69F|!BankB
		JSR CheckQuake
		BCC $03 : JSR QuakeStun


		LDA !sprite_status,x			; check the sprite state
		CMP #$09				; if it is stunned...
		BCC .Normal				; run a different routine
		LDA !fuse,x : BEQ .NoFuse
		DEC A
		STA !fuse,x
		BNE .NoFuse

		.Explode
		LDA #$09 : STA $1DFC|!Base2		; explosion sfx
		LDA #$15 : STA $1887|!Base2
		LDA #$0D : STA !9E,x			; sprite = bomb
		LDA #$08 : STA !sprite_status,x		; status = main
		LDA #$00 : STA !extra_bits,x
		JSL $07F7D2|!BankB			; reset sprite
		LDA #$01 : STA !1534,x			;\
		LDA #$40 : STA !1540,x			; | bomb stats
		LDA #$1B : STA !167A,x			; |
		INC !1FD6,x				;/
		LDA !1686,x				;\
		ORA #$01				; | prevent explosion from being eaten omegalul
		STA !1686,x				;/
		RTS					; return

		.NoFuse
		JMP Stunned

	.Normal
		JSR MechakoopaGFX			;

		LDA !sprite_status,x			;
		SEC : SBC #$08				; if the sprite status is not normal...
		ORA $9D : BEQ .Process			; or sprites are locked...
		RTS					; return

	.Process
		LDA #$00
		%SubOffScreen()				;
		JSL $01803A|!BankB			; interact with the player and other sprites
		LDA !takeofftimer,x : BEQ .Move
		CMP #$01 : BNE .NoMovement
		LDA #$17 : STA $1DFC|!Base2		; jet fire sfx
	.Move	JSL $01802A|!BankB			; update sprite position
		LDA !1588,x
		AND #$08 : BEQ .NoMovement
		STZ !sprite_speed_y,x			; ceiling bonk
		.NoMovement

		LDA !1588,x				;
		AND #$04 : BNE .Ground			; see if sprite is on ground
		JMP .Air				;

	.Ground
		LDA !state,x : BEQ .Walk
		CMP #$01 : BEQ .Attack
		CMP #$02 : BEQ .Land
		BRA .Walk

		.Land
		STZ !state,x
		STZ !flytimer,x

		.Walk
		LDA !extra_bits,x
		AND #$04 : BEQ .NoFly
		INC !flytimer,x
		LDA !flytimer,x
		CMP.b #!flytime : BNE .NoFly

		.InitFly
		LDA !1588,x
		AND #$04 : BEQ +			; instant takeoff in midair
		LDA #$28 : STA !takeofftimer,x		; prepare for takeoff!
	+	LDA #$17 : STA $1DFC|!Base2		; jet fire sfx
		STZ !flytimer,x
		LDA #$02 : STA !state,x
		LDA #$E0 : STA !sprite_speed_y,x
		STZ !1588,x
		LDA !sprite_speed_x,x
		BPL +
		EOR #$FF
		ASL A
		EOR #$FF
		BRA ++
	+	ASL A
	++	STA !sprite_speed_x,x

		JMP .Air
		.NoFly

		LDA !extra_byte_1,x : BNE $03		; no attack for green
	-	JMP .NoAttack				; > hacky label
		CMP #$03 : BCS -			; no attack for yellow
		INC !attacktimer,x			; count up for attack
		LDA !attacktimer,x
		CMP.b #!attacktime : BNE -
		STZ !attacktimer,x
		LDA #$01 : STA !state,x
		LDA !extra_byte_1,x
		CMP #$02 : BNE .Attack
		LDA #$1E : STA $1DF9|!Base2		; lightning charge sfx

		.Attack
		STZ !sprite_speed_x,x
		STZ !sprite_speed_y,x
		INC !attacktimer,x
		INC !attacktimer,x
		LDA !attacktimer,x : BNE $03 : JMP .EndAttack
		CMP #$80 : BNE .NoShoot
		LDY !157C,x
		LDA !extra_byte_1,x
		CMP #$02 : BEQ .Lightning
	.Gunner
		LDA ShootXDisp,y : STA $00
		LDA #$FC : STA $01
		LDA ShootXSpeed,y : PHA
		STZ $02
		STZ $03
		LDA #$01
		%SpawnExtended()
		BCS +
		LDA #$0F : STA $176F|!Base2,y
	+	LDA #$09 : STA $1DFC|!Base2		; bullet bill shoot sfx
		PLA : STA $02
	if !projectile_custom == 0
		CLC
	else
		SEC
	endif
		LDA #!projectile_num
		%SpawnSprite()
		BCS .NoShoot
		LDA !157C,x
	if !projectile_bullet_bill == 1
		STA.w !C2|!Base1,y
	else
		STA !157C,y
	endif
		LDA #$08 : STA !sprite_status,y
		BRA .NoShoot

	.Lightning
		LDA LightningXDisp,y : STA $00
		LDA #$FE : STA $01
		LDA LightningXSpeed,y : STA $02
		STZ $03
		SEC : LDA #!lightning_num
		%SpawnSprite()
		LDA #$10 : STA $1DF9|!Base2		; lightning discharge sfx
		BCS .NoShoot
		LDA !157C,x : STA !157C,y
		LDA #$01 : STA !sprite_status,y

.NoShoot	INC !keytimer,x				; spin key faster during attack
		BRA .SpeedDone

		.NoAttack

		STZ !sprite_speed_y,x			; y speed = 0
		LDY !157C,x				;
		LDA Speed,y				; set the X speed depending on direction
		STA !sprite_speed_x,x				;
		LDA !C2,x				;
		INC !C2,x				;
		AND #$3F				; every 40 frames...
		BNE .SpeedDone				;
		%SubHorzPos()
		TYA					; turn to face the player
		STA !157C,x				;
		BRA .SpeedDone

	.Air
		LDA !state,x
		CMP #$01 : BEQ .EndAttack
		CMP #$02 : BEQ .Fly
		LDA !extra_bits,x
		AND #$04 : BEQ .EndAttack
		JMP .InitFly

		.Fly
		LDA !takeofftimer,x : BNE .SpeedDone
		DEC !sprite_speed_y,x
		DEC !sprite_speed_y,x
		LDA $14
		LSR A : BCC +
		DEC !sprite_speed_y,x
	+	INC !keytimer,x				; spin key faster during flight
		LDA !flytimer,x : BMI .SpeedDone
		CMP #$7E : BNE +
		LDA #$17 : STA $1DFC|!Base2		; jet fire sfx
	+	INC !flytimer,x
		INC !flytimer,x
		BRA .SpeedDone

		.EndAttack
		STZ !state,x
		STZ !attacktimer,x			; clear attack timer

	.SpeedDone
		LDA !1588,x				;
		AND #$03				; if the sprite is touching a wall...
		BEQ NoFlipDir				;
		LDA !sprite_speed_x,x			;
		EOR #$FF				; flip its x speed
		INC					;
		STA !sprite_speed_x,x			;
		LDA !157C,x				;
		EOR #$01				; and direction
		STA !157C,x				;

	NoFlipDir:
		INC !keytimer,x				;
		LDA !keytimer,x				; key image
		AND #$0C				; !1602 is main sprite image
		LSR #2					;
		STA !1602,x				;

	Return00:
		RTS

	Stunned:
		LDA $1A : PHA				;
		STZ !state,x
		STZ !attacktimer,x
		STZ !flytimer,x
		STZ !takeofftimer,x
		LDA !extra_byte_1,x
		CMP #$03 : BCC .NormalStunned

		.ExplodingStunned
		LDA !fuse,x : BNE +
		LDA.b #!fuselength : STA !fuse,x
	+	INC !keytimer,x
		LDA !fuse,x
		CLC : ADC #$10
		STA !1540,x
		CMP #$40 : BCS NoShake
		AND #$01
		EOR $1A
		STA $1A
		INC !keytimer,x
		BRA NoShake

		.NormalStunned
		LDA !1540,x				;
		CMP #$30 : BCS NoShake			;
		AND #$01				;
		EOR $1A					; make the Mechakoopa shake back and forth 1 pixel
		STA $1A					;
	NoShake:

		JSR MechakoopaGFX			;

		LDY !sprite_oam_index,x			;
		LDA #$F0 : STA $0309|!Base2,y		; prevent a glitched tile from showing up

		PLA : STA $1A				;

		LDA !sprite_status,x			;
		CMP #$0B : BNE Return01			;
		LDA $76					;
		EOR #$01				;
		STA !157C,x				; set the sprite direction

	Return01:
		RTS					;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	MechakoopaGFX:
		LDA !1540,x				; if the stun timer is set...
		BEQ NotStunnedGFX			;

		LDY #$05				;
		CMP #$05				;
		BCC StunFrame4				;
		CMP #$FA				;
		BCC StoreStunFrame			;
		LDY #$04				;
	StunFrame4:
	StoreStunFrame:
		TYA					;
		STA !1602,x				;
		LDA !1540,x				;
		CMP #$30				; if the stun timer is below 30...
		BCS NotStunnedGFX			;
		AND #$01				;\
		ASL A					; |
		CLC : ADC !15F6,x			; |
		AND #$0E				; |
		CMP #$0C : BCC +			; | flash palette, but keep it within the A-D range
		LDA #$04				; |
	+	STA $04					; |
		LDA !15F6,x				; |
		AND #$01				; |
		TSB $04					;/
		BRA GoDraw

	NotStunnedGFX:
		LDA !15F6,x				;
		AND #$0F
		STA $04					;

	GoDraw:
		%GetDrawInfo()

		TYA					;
		CLC					;
		ADC #$0C				;
		TAY					;

	if !secondhalf == 0
		STZ $0F
	else
		LDA #$80 : STA $0F
	endif
		LDA !state,x : BEQ .Normal
		CMP #$01 : BEQ .Attack

	.Fly
		LDA !157C,x
		BEQ $02 : LDA #$40
		EOR #$40
		TSB $04
		LDA !flytimer,x : STA $02
		AND #$08
		ASL #3
		STA $0E
		LDA !takeofftimer,x : BNE .TakeOff

		PHX
		LDX #$06
		TYA
		CLC : ADC #$0C
		TAY
		JMP FlyLoop

	.TakeOff
		PHX
		LDX #$04
		TYA
		CLC : ADC #$04
		TAY
		JMP FlyLoop

	.Attack
		LDA !extra_byte_1,x : STA $08		; 1 = gunner, 2 = lightning
		LDA !157C,x
		BEQ $02 : LDA #$40
		EOR #$40
		TSB $04
		LDA !attacktimer,x
		LSR #4
		AND #$0F
		STA $02
		PHX
		LDX #$05
		TYA
		CLC : ADC #$08
		TAY
		JMP AttackLoop

	.Normal
		LDA !1602,x				;
		ASL #2					;
		STA $03					;
		LDA !157C,x				;
		ASL #2					;
		EOR #$04				;
		STA $02					;

		PHX					;
		LDX #$03				; 4 tiles to draw

	GFXLoop:
		PHX					;
		PHY					;
		TYA					;
		LSR #2					;
		TAY					;
		LDA TileSize,x				;
		STA $0460|!Base2,y			;     

		PLY					;
		PLA					;
		PHA					;
		CLC					;
		ADC $02					;
		TAX					;

		LDA $00					;
		CLC					;
		ADC XDisp,x				;
		STA $0300|!Base2,y			;

		LDA TileProp,x				;
		ORA $04					;
		ORA $64					;
		STA $0303|!Base2,y			;

		PLA					;
		PHA					;
		CLC					;
		ADC $03					;
		TAX					;

		LDA Tilemap,x				;
		CLC : ADC $0F				;
		STA $0302|!Base2,y			;

		LDA $01					;
		CLC					;
		ADC YDisp,x				;
		STA $0301|!Base2,y			;

		PLX					;
		DEY #4					;
		DEX					;
		BPL GFXLoop				;

		PLX
		LDY #$FF				;
		LDA #$03				;
		JSL $01B7B3|!BankB			;

		LDA !sprite_oam_index,x			;
		CLC					;
		ADC #$10				;
		STA !sprite_oam_index,x			;



	FinishGFX:
		LDA !15F6,x
		AND #$0F
		STA $0E
		%GetDrawInfo()				;

		PHX					;
		LDA !keytimer,x				;
		LSR #2					;
		AND #$03				;
		STA $02					;

		LDA !157C,x				;
		TAX					;
		LDA $00					;
		CLC					;
		ADC KeyXDisp,x				;
		STA $0300|!Base2,y			;
		LDA $01					;
		STA $0301|!Base2,y			;
		LDA KeyTileProp,x			;
		ORA $64					;
		ORA $0E
		STA $0303|!Base2,y			;
		LDX $02					;
		LDA KeyTilemap,x			;
		CLC : ADC $0F
		STA $0302|!Base2,y			;

		PLX					;
		LDY #$00				;
		LDA #$00				;
		JSL $01B7B3|!BankB			;
		RTS					;


	AttackLoop:
		PHX					; push loop counter

		PHY					;
		TYA					;
		LSR #2					; set tile size
		TAY					;
		LDA AttackTileSize,x			;
		STA $0460|!Base2,y			;     
		PLY					;

		LDA AttackDispX,x			;
		BIT $04
		BVC +
		EOR #$FF : INC A
		CPX #$03 : BCS ++
		CPX #$00 : BNE +
	++	CLC : ADC #$08
	+	CLC : ADC $00				;
		STA $0300|!Base2,y			; set tile coordinates
		LDA $01					;
		CLC					;
		ADC AttackDispY,x			;
		STA $0301|!Base2,y			;

		STX $0C					;\ get tilemap index
		LDX $02					;/
		LDA $0C : BNE +				;\
		CPX #$02 : BEQ ++			; |
		CPX #$03 : BNE +			; |
	++	LDA $0301|!Base2,y			; | weapon tile is 2px higher on third attack frame
		DEC A					; | ...and 1px higher on second attack frame
		CPX #$03 : BEQ ++			; |
		DEC A					; |
	++	STA $0301|!Base2,y			;/

	+	LDA $08
		CMP #$02 : BEQ .Lightning
	.Gunner
		LDA AttackIndex_Gunner,x
		CLC : ADC $0C
		TAX
		LDA $04
		ORA $64
		STA $0303|!Base2,y
		LDA AttackTilemap_Gunner,x
		BRA .Shared

	.Lightning
		LDA AttackIndex_Lightning,x
		CLC : ADC $0C
		TAX
		LDA $04					;
		ORA $64					;
		STA $0303|!Base2,y			; set property
		LDA AttackTilemap_Lightning,x		;

	.Shared
		CLC : ADC $0F				;
		STA $0302|!Base2,y			; set tile

		PLX					; pull loop counter
		DEY #4					; decrement indexes
		DEX : BMI $03 : JMP AttackLoop		; loop

		PLX
		LDY #$FF				; pull sprite index and draw tiles
		LDA #$05				;
		JSL $01B7B3|!BankB			;

		LDA !sprite_oam_index,x			; go to draw key tile
		CLC : ADC #$18
		STA !sprite_oam_index,x
		JMP FinishGFX


	FlyLoop:
		PHY					;
		TYA					;
		LSR #2					; set tile size
		TAY					;
		LDA FlyTileSize,x			;
		STA $0460|!Base2,y			;     
		PLY					;

		LDA FlyDispX,x				;
		BIT $04 : BVC +
		EOR #$FF : INC A
		CPX #$02 : BCC +
		CLC : ADC #$08
	+	CLC : ADC $00				;
		STA $0300|!Base2,y			; set tile coordinates
		LDA $01					;
		CLC					;
		ADC FlyDispY,x				;
		STA $0301|!Base2,y			;
		LDA FlyTilemap,x
		CLC : ADC $0F				;
		CPX #$05 : BCC +
		BIT $02 : BPL +
		PHA
		LDA $14
		LSR #2
		PLA
		BCC +
		INC A
	+	STA $0302|!Base2,y			; set tile
		LDA $04					;
		CPX #$05 : BCC +			;
		AND #$01				;
		ORA #$04				;
		EOR $0E					;
	+	ORA $64					;
		STA $0303|!Base2,y			; set property


		DEY #4					; decrement indexes
		DEX : BPL FlyLoop			; loop

		PLX
		LDY #$FF				; pull sprite index and draw tiles
		LDA #$06				;
		JSL $01B7B3|!BankB			;

		LDA !sprite_oam_index,x			; go to draw key tile
		CLC : ADC #$1C
		STA !sprite_oam_index,x
		JMP FinishGFX

	CheckQuake:
		LDA !1540,x					;\ can't interact with quake sprite again for first 16 frames of stun
		CMP #$EF : BCS ++				;/
		LDA #$18 : STA $07
		LDA #$10
		STA $02
		STA $03
		LDY #$03
	-	LDA $16CD|!Base2,y : BEQ +
		LDA $16D1|!Base2,y : STA $00
		LDA $16D5|!Base2,y : STA $08
		LDA $16D9|!Base2,y : STA $01
		LDA $16DD|!Base2,y : STA $09
		JSL $03B72B|!BankB
		BCS .Return
	+	DEY : BPL -
	++	CLC
	.Return	RTS

	QuakeStun:
		LDA #$09 : STA !sprite_status,x
		LDA #$FF : STA !1540,x				; set stun
		STZ !sprite_speed_x,x
		LDA #$D8 : STA !sprite_speed_y,x
		STZ $00
		STZ $01
		LDA #$08 : STA $02
		LDA #$02
		%SpawnSmoke()
		LDA #$03 : STA $1DF9|!Base2
		LDA #$00					; quake hit worth 100 points
		JSL $02ACE5|!BankB				; give mario points
		RTS




