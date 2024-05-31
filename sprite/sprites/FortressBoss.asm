;cleartable




	!dp = $0000
	!addr = $0000
    !rom = $800000
	!sa1 = 0
	!gsu = 0
    !sram7000 = $000000
    !sram7008 = $000000
    !ram7F9A7B = $000000
    !ram7FC700 = $000000

if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!gsu = 1
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
    !rom = $000000
    !sram7000 = $2E4000
    !sram7008 = $2E6800
    !ram7F9A7B = $3E127B
    !ram7FC700 = $3DFF00
endif

;########################################
;######## Scratchs Rams [$00,$0F] #######
;########################################
!Scratch0 = $00
!Scratch1 = $01
!Scratch2 = $02
!Scratch3 = $03
!Scratch4 = $04
!Scratch5 = $05
!Scratch6 = $06
!Scratch7 = $07
!Scratch8 = $08
!Scratch9 = $09
!ScratchA = $0A
!ScratchB = $0B
!ScratchC = $0C
!ScratchD = $0D
!ScratchE = $0E
!ScratchF = $0F

;########################################
;############## Counters ################
;########################################
!TrueFrameCounter = $13
!EffectiveFrameCounter = $14

;########################################
;############## Control #################
;########################################
!ButtonPressed_BYETUDLR = $15
!ButtonDown_BYETUDLR = $16
!ButtonPressed_AXLR0000 = $17
!ButtonDown_AXLR0000 = $18

;########################################
;############## Layers ##################
;########################################
!Layer1X = $1A
!Layer1Y = $1C
!Layer2X = $1E
!Layer2Y = $20
!Layer3X = $22
!Layer3Y = $24

;########################################
;############## Player ##################
;########################################
!PlayerX = $94
!PlayerY = $96
!PlayerXSpeed = $7B
!PlayerYSpeed = $7D
!PowerUp = $19
!Lives = $0DBE|!addr
!Coins = $0DBF|!addr
!ItemBox = $0DC2|!addr
!PlayerInAirFlag = $72
!PlayerDuckingFlag = $73
!PlayerClimbingFlag_N00SIFHB = $74
!PlayerWaterFlag = $75
!PlayerDirection = $76
!PlayerBlockedStatus_S00MUDLR = $77
!PlayerHide_DLUCAPLU = $78
!CurrentPlayer = $0DB3|!addr
!CapeImage = $13DF|!addr
!PlayerPose = $13E0|!addr
!PlayerSlope = $13E1|!addr
!SpinjumpTimer = $13E2|!addr
!PlayerWallRunningFlag = $13E3|!addr
!PlayerFrozenFlag = $13FB|!addr
!PlayerCarryingFlag = $1470|!addr
!PlayerCarryingFlagImage = $148F|!addr
!PlayerAnimationTimer = $1496|!addr
!PlayerFlashingTimer = $1497|!addr
!P1PowerUp = $0DB8|!addr
!P2PowerUp = $0DB9|!addr
!P1Lives = $0DB4|!addr
!P2Lives = $0DB5|!addr
!P1Coins = $0DB6|!addr
!P2Coins = $0DB7|!addr
!P1YoshiColor = $0DBA|!addr
!P2YoshiColor = $0DBB|!addr
!P1ItemBox = $0DBC|!addr
!P2ItemBox = $0DBD|!addr

;########################################
;############### Global #################
;########################################
!LockAnimationFlag = $9D
!HScrollEnable = $1411|!addr
!VScrollEnable = $1412|!addr
!HScrollLayer2Type = $1413|!addr
!VScrollLayer2Type = $1414|!addr
!WaterFlag = $85
!SlipperyFlag = $86
!GameMode = $0100|!addr
!TwoPlayersFlag = $0DB2|!addr

;########################################
;################ OAM ###################
;########################################
!TileXPosition200 = $0200|!addr
!TileYPosition200 = $0201|!addr
!TileCode200 = $0202|!addr
!TileProperty200 = $0203|!addr
!TileSize420 = $0420|!addr
!TileXPosition = $0300|!addr
!TileYPosition = $0301|!addr
!TileCode = $0302|!addr
!TileProperty = $0303|!addr
!TileSize460 = $0460|!addr

;########################################
;############### Yoshi ##################
;########################################
!YoshiX = $18B0|!addr
!YoshiY = $18B2|!addr
!YoshiKeyInMouthFlag = $191C|!addr

;########################################
;############## Clusters ################
;########################################
!ClusterNumber = $1892|!addr
!ClusterXLow = $1E16|!addr
!ClusterYLow = $1E02|!addr
!ClusterXHigh = $1E3E|!addr
!ClusterYHigh = $1E2A|!addr
!ClusterMiscTable1 = $0F4A|!addr
!ClusterMiscTable2 = $0F5E|!addr
!ClusterMiscTable3 = $0F72|!addr
!ClusterMiscTable4 = $0F86|!addr
!ClusterMiscTable5 = $0F9A|!addr
!ClusterMiscTable6 = $1E52|!addr
!ClusterMiscTable7 = $1E66|!addr
!ClusterMiscTable8 = $1E7A|!addr
!ClusterMiscTable9 = $1E8E|!addr

;########################################
;############## Extended ################
;########################################
!ExtendedNumber = $170B|!addr
!ExtendedXLow = $171F|!addr
!ExtendedYLow = $1715|!addr
!ExtendedXHigh = $1733|!addr
!ExtendedYHigh = $1729|!addr
!ExtendedXSpeed = $1747|!addr
!ExtendedYSpeed = $173D|!addr
!ExtendedXSpeedAccumulatingFraction = $175B|!addr
!ExtendedYSpeedAccumulatingFraction = $1751|!addr
!ExtendedBehindLayersFlag = $1779|!addr
!ExtendedMiscTable1 = $1765|!addr
!ExtendedMiscTable2 = $176F|!addr

;########################################
;############### Sprites ################
;########################################
!SpriteIndex = $15E9|!addr
!SpriteNumber = $9E
!SpriteStatus = $14C8
!SpriteXLow = $E4
!SpriteYLow = $D8
!SpriteXHigh = $14E0
!SpriteYHigh = $14D4
!SpriteXSpeed = $B6
!SpriteYSpeed = $AA
!SpriteXSpeedAccumulatingFraction = $14F8
!SpriteYSpeedAccumulatingFraction = $14EC
!SpriteDirection = $157C
!SpriteBlockedStatus_ASB0UDLR = $1588
!SpriteHOffScreenFlag = $15A0
!SpriteVOffScreenFlag = $186C
!SpriteHMoreThan4TilesOffScreenFlag = $15C4
!SpriteSlope = $15B8
!SpriteYoshiTongueFlag = $15D0
!SpriteInteractionWithObjectEnable = $15DC
!SpriteIndexOAM = $15EA
!SpriteProperties_YXPPCCCT = $15F6
!SpriteLoadStatus = $161A
!SpriteBehindEscenaryFlag = $1632
!SpriteInLiquidFlag = $164A
!SpriteDecTimer1 = $1540
!SpriteDecTimer2 = $154C
!SpriteDecTimer3 = $1558
!SpriteDecTimer4 = $1564
!SpriteDecTimer5 = $15AC
!SpriteDecTimer6 = $163E
!SpriteDecTimer7 = $1FE2
!SpriteTweaker1656_SSJJCCCC = $1656
!SpriteTweaker1662_DSCCCCCC = $1662
!SpriteTweaker166E_LWCFPPPG = $166E
!SpriteTweaker167A_DPMKSPIS = $167A
!SpriteTweaker1686_DNCTSWYE = $1686
!SpriteTweaker190F_WCDJ5SDP = $190F
!SpriteMiscTable1 = $0DF5|!addr
!SpriteMiscTable2 = $0E0B|!addr
!SpriteMiscTable3 = $C2
!SpriteMiscTable4 = $1504
!SpriteMiscTable5 = $1510
!SpriteMiscTable6 = $151C
!SpriteMiscTable7 = $1528
!SpriteMiscTable8 = $1534
!SpriteMiscTable9 = $1570
!SpriteMiscTable10 = $1594
!SpriteMiscTable11 = $1602
!SpriteMiscTable12 = $160E
!SpriteMiscTable13 = $1626
!SpriteMiscTable14 = $187B
!SpriteMiscTable15 = $1FD6

;########################################
;############### GIEPY ##################
;########################################
!ExtraBits = $7FAB10
!NewCodeFlag = $7FAB1C
!ExtraProp1 = $7FAB28
!ExtraProp2 = $7FAB34
!ExtraByte1 = $7FAB40
!ExtraByte2 = $7FAB4C
!ExtraByte3 = $7FAB58
!ExtraByte4 = $7FAB64
!ShooterExtraByte = $7FAB70
!GeneratorExtraByte = $7FAB78
!ScrollerExtraByte = $7FAB79
!CustomSpriteNumber = $7FAB9E
!ShooterExtraBits = $7FABAA
!GeneratorExtraBits = $7FABB2
!Layer1ExtraBits = $7FABB3
!Layer2ExtraBits = $7FABB4
!SpriteFlags = $7FABB5

if !sa1

!SpriteNumber = $3200
!SpriteYSpeed = $9E
!SpriteXSpeed = $B6
!SpriteMiscTable3 = $D8
!SpriteYLow = $3216
!SpriteXLow = $322C
!SpriteStatus = $3242
!SpriteYHigh = $3258
!SpriteXHigh = $326E
!SpriteYSpeedAccumulatingFraction = $74C8
!SpriteXSpeedAccumulatingFraction = $74DE
!SpriteMiscTable4 = $74F4
!SpriteMiscTable5 = $750A
!SpriteMiscTable6 = $3284
!SpriteMiscTable7 = $329A
!SpriteMiscTable8 = $32B0
!SpriteDecTimer1 = $32C6
!SpriteDecTimer2 = $32DC
!SpriteDecTimer3 = $32F2
!SpriteDecTimer4 = $3308
!SpriteMiscTable9 = $331E
!SpriteDirection = $3334
!SpriteBlockedStatus_ASB0UDLR = $334A
!SpriteMiscTable10 = $3360
!SpriteHOffScreenFlag = $3376
!SpriteDecTimer5 = $338C
!SpriteSlope = $7520
!SpriteHMoreThan4TilesOffScreenFlag = $7536
!SpriteYoshiTongueFlag = $754C
!SpriteInteractionWithObjectEnable = $7562
!SpriteIndexOAM = $33A2
!SpriteProperties_YXPPCCCT = $33B8
!SpriteMiscTable11 = $33CE
!SpriteMiscTable12 = $33E4
!SpriteLoadStatus = $7578
!SpriteMiscTable13 = $758E
!SpriteBehindEscenaryFlag = $75A4
!SpriteDecTimer6 = $33FA
!SpriteInLiquidFlag = $75BA
!SpriteTweaker1656_SSJJCCCC = $75D0
!SpriteTweaker1662_DSCCCCCC = $75EA
!SpriteTweaker166E_LWCFPPPG = $7600
!SpriteTweaker167A_DPMKSPIS = $7616
!SpriteTweaker1686_DNCTSWYE = $762C
!SpriteVOffScreenFlag = $7642
!SpriteMiscTable14 = $3410
!SpriteTweaker190F_WCDJ5SDP = $7658
!SpriteMiscTable15 = $766E
!SpriteDecTimer7 = $7FD6

!ExtraBits = $400040
!NewCodeFlag = $400056
!ExtraProp1 = $400057
!ExtraProp2 = $40006D
!ExtraByte1 = $4000A4
!ExtraByte2 = $4000BA
!ExtraByte3 = $4000D0
!ExtraByte4 = $4000E6
!ShooterExtraByte = $400110
!GeneratorExtraByte = $4000FC
!ScrollerExtraByte = $4000FD
!CustomSpriteNumber = $400083
!ShooterExtraBits = $400099
!GeneratorExtraBits = $4000A1
!Layer1ExtraBits = $4000A2
!Layer2ExtraBits = $4000A3
!SpriteFlags = $400118

endif 


;######################################
;############## MaxTile ###############
;######################################
; MaxTile shared routines
!maxtile_flush_nmstl		= $0084A8
!maxtile_get_sprite_slot	= $0084AC
!maxtile_get_slot			= $0084B0
!maxtile_finish_oam			= $0084B4

;######################################
;########### Boss Defines #############
;######################################
!SFXBuffer					= !SpriteDecTimer3
!BossDamageTimer			= !SpriteDecTimer4
!IntroTimer_Buffer			= !SpriteDecTimer5
!IntroTimer					= !SpriteDecTimer6
!BossSubTimer				= !SpriteDecTimer7

;!SpriteMiscTable1 - DO NOT USE
;!SpriteMiscTable2 - DO NOT USE
!HealthRam					= !SpriteMiscTable3
!SFXToPlay					= !SpriteMiscTable4; - unused originally
!GlobalFlip					= !SpriteMiscTable5
!SpriteXLowTarget			= !SpriteMiscTable6
!SpriteXHighTarget			= !SpriteMiscTable7
!SpriteYLowTarget			= !SpriteMiscTable8
!SpriteYHighTarget			= !SpriteMiscTable9
!GroundHit					= !SpriteMiscTable10
!BossStates					= !SpriteMiscTable11
!BossSubStates				= !SpriteMiscTable12
!FrameIndex					= !SpriteMiscTable13
!BossCurrentAttackOffset	= !SpriteMiscTable14
!SFXBank					= $418800; - noob boss ram whoa
!SpriteInit_Because_ThisisDumb		= !SpriteMiscTable15

;######################################
;########## Attack Defines ############
;######################################
!MissileAnimation			= !SpriteMiscTable10
!MissileType				= !SpriteMiscTable11
!MissilePos					= !SpriteMiscTable12

!PencilState				= !BossStates
!PencilTimer				= !IntroTimer


;######################################
;########### Init Routine #############
;######################################
print "INIT ",pc
	; uncomment these to kill boss right away (test)
;		LDA #$05 : STA !HealthRam,x
;		LDA #$0B : STA !BossStates,x
;		LDA #$04 : STA !SpriteXLowTarget,x ; explode timer

	;TAY
	;LDA FINISH_SUBSTATE_StateLists,y : STA !BossCurrentAttackOffset,x
	
	LDA #$02 : STA !IntroTimer_Buffer,x

	LDA $1F2B|!Base2
	AND #$01
	BNE +
	LDA #$60 : STA !IntroTimer_Buffer,x
+

	LDA #$00
	STA !GlobalFlip,x
	%invoke_snes(.setthedumbramsto00)
RTL
.setthedumbramsto00
	LDA #$00
	STA $7FC0FC
	STA $7FC0FD
	RTL

;######################################
;########## Main Routine ##############
;######################################
print "MAIN ",pc
    PHB
    PHK
    PLB
    JSR SpriteCode
    JSR GraphicRoutine    ; why not do this?
	JSR DISPLAY_HEALTH
    PLB
RTL

WhatSprite:
	db $00,$1E,$2A,$2B,$2C
Return:
RTS
SpriteCode:
	; $00 - Boss
	; $01 - Missile
		; !MissileType
		; $00		- Aimed
		; $01		- Aimed, x speed following active
		; $02		- Not Aimed
		; $03		- Not aimed, x speed following active
	; $02 - Mini Castle
		; !SpriteDirection
		; $00 - go left
		; $01 - go right
	; $03 - Bolder Big
	; $04 - Pencil (Deadly)

; First frame in sprite code, essentially an init but actually functional (for some reason)
	LDA !SpriteInit_Because_ThisisDumb,x
	BNE +
	INC !SpriteInit_Because_ThisisDumb,x

	LDA !extra_byte_1,x ; simplest way of doing it imo
	TAY
	LDA WhatSprite,y
	STA !FrameIndex,x
+

    LDA !SpriteStatus,x			        
	CMP #$08                            ;if sprite dead return
	BNE Return	

	LDA !LockAnimationFlag				    
	BNE Return			                    ;if locked animation return.

    %SubOffScreen()

    JSR InteractMarioSprite
	LDA !FrameIndex,x ; 
	JSL $0086DF|!BankB
		dw .Faro
		dw .Faro
		dw .Faro ; $02
		dw .Fortress ; $03
		dw .Fortress ; flying
		dw .Fortress ; flying
		dw .FortressDying ; $06
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .FortressDying
		dw .CastleDestructionCutscene ; $1D
		dw .MissileUp
		dw .MissileUp
		dw .MissileUp
		dw .MissileUp ; $21
		dw .MissileDown
		dw .MissileDown
		dw .MissileDown
		dw .MissileDown ; $25
		dw .MissileBlownUp
		dw .MissileBlownUp
		dw .MissileBlownUp
		dw .MissileBlownUp ; $29
		dw .MiniCastle ; $2A
		dw .Bolder ; $2B
		dw .Pencil ; $2C
	
.Faro
	LDA !IntroTimer_Buffer,x
	BEQ +
	LDA #$FF : STA !IntroTimer,x
+
	STZ !FrameIndex,x
	LDA !IntroTimer,x
	CMP #$50
	BCS +
	CMP #$00
	BNE ++
	LDA !SpriteYSpeed,x
	DEC A
	CMP #$C0
	BCC ++
	STA !SpriteYSpeed,x
	JSL $01801A|!BankB
	LDA !SpriteYHigh,x : XBA : LDA !SpriteYLow,x
	REP #$20
	CMP #$00A0
	BCS ++
	LDA #$01CA
	SEP #$20
	STA !SpriteXLow,x : XBA : STA !SpriteXHigh,x
	LDA #$03 : STA !FrameIndex,x
	STZ !SpriteYSpeed,x
	STZ !SpriteXSpeed,x
	; initial timer
	LDA #$FF : STA !IntroTimer,x
	LDA $1F2B|!Base2
	AND #$01
	BEQ .firsttime
	LDA #$70 : STA !IntroTimer,x
	LDA #$61 : STA $1DFB|!Base2 ; play music right away
.firsttime
	RTS
++	SEP #$20
	
	LDA $14
	AND #$01
	TAY
	CLC : ADC #$01
	STA !FrameIndex,x
	
	LDA .AffectXPos,y
	STA !SpriteXSpeed,x
	JSL $018022|!BankB
	
	LDA !IntroTimer,x
	BEQ +
	LDA $14
	AND #$07
	BNE +
	LDA #$17 : STA $1DFC|!Base2
+	RTS
.AffectXPos
	db $F0,$10
	
	
	
.Fortress
	LDA !IntroTimer,x
	BEQ .BBBBBOSS_BATTLE
	DEC A
	BNE +
	LDA $1F2B|!Base2
	AND #$01
	BNE +
	EOR #$01 : STA $1F2B|!Base2 ; set sram
	LDA #$61 : STA $1DFB|!Base2
	LDA #$01 : STA $1426|!Base2
+

	JSL $01802A|!BankB
	JSL $019138|!BankB		;interact with objects
	LDA !1588,x
	AND #$04
	BEQ +
	LDA !GroundHit,x
	BNE +
	LDA #$E0 : STA !SpriteYSpeed,x
	JSR ImpactEffect
	INC !GroundHit,x
+	RTS
.BBBBBOSS_BATTLE
	JSR DetectDamage
	LDA !BossDamageTimer,x
	BEQ +
	STA $18E6|!Base2
	JMP .IsDamaged
+
	%invoke_snes(.set7fc0fdto0bs)
	LDA !BossStates,x
	JSL $0086DF|!BankB
		dw .Missiles ; DONE
		dw .MiniCastles
		dw .Bolders
		dw .Pencils ; DONE
		dw .ThwompLand ; DONE
		dw .MissilesM ;Pattern, will just do it inside the .Missiles subroutine
		dw .Fire ; kinda DONE (priority issues)
		dw .Earthquake ; DONE
		dw .Bouncy ; DONE
		dw .RAM ; DONE
		dw .Wyatt ; .ThwompLand + .Earthquake
		dw .YouAreDeadDeadDead
.set7fc0fdto0bs
	LDA #$00 : STA $7FC0FD
	RTL

;;;;;;;
.MissilesM
	%invoke_snes(.set7fc0fdto1bs)
	BRA .Missiles
.set7fc0fdto1bs
	LDA #$01 : STA $7FC0FD
	RTL
.Missiles
;;;;;;;
	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .Firing
		dw .Firing
		dw .Firing
		dw .Wait
		dw FINISH_SUBSTATE

.Firing
	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
	
	LDA !BossSubStates,x : TAY
	LDA .Times1,y : STA !BossSubTimer,x
	
	LDA #$57 : JSR GenCSpr
	CPY #$FF
	BEQ +
	
	LDA #$01
	PHX : TYX
	STA !extra_byte_1,x
	PLX
	LDA #$00 : STA !MissileType,y ; aim mode

	; If it's supposed to be posed
	LDA !BossStates,x
	CMP #$05
	BNE +
	PHX : TYX
	INC !MissileType,x ; posmode
	PLX : PHY
	LDA !BossSubStates,x : DEC A : TAY
	LDA .SetPos,y : PLY : STA !MissilePos,y
+	RTS
.SetPos
	db $30,$78,$C0

.Wait
	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
+	RTS

.Times1
	db $30,$30,$30,$F0


;;;;;;;
.MiniCastles
	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .jumpandfly
		dw .Firelo
		dw .Firelo
		dw .Firelo
		dw .ReturnToGround
		dw FINISH_SUBSTATE
.jumpandfly
	%invoke_snes(.set7fc0fdto1bs)
	
	LDA #-$0C : STA !sprite_speed_y,x
	JSL $01801A|!BankB ; y
	
	LDA !sprite_y_low,x
	CMP #$10
	BCS +
	INC !BossSubStates,x
+
.doflyframes
	LDA $14
	LSR A : AND #$01
	CLC : ADC #$04
	STA !FrameIndex,x
	RTS
	
.Firelo
	JSR .doflyframes
	STZ !GroundHit,x
	LDA !BossSubTimer,x
	BNE +
	LDA #$40 : STA !BossSubTimer,x
	INC !BossSubStates,x

	STZ $00 : STZ $01
	STZ $02 : STZ $03

	LDA #$57 : JSR GenCSpr
	CPY #$FF
	BEQ +
	
	LDA #$02
	PHX : TYX
	STA !extra_byte_1,x
	PLX
	
	PHY
	LDY #$00
	LDA !sprite_x_low,x
	BMI ++
	INY
++	TYA : PLY : STA !SpriteDirection,y
	
	LDA #$20 : STA $1DF9|!Base2
+	JMP .wavymotion

.ReturnToGround
	LDA #$03 : STA !FrameIndex,x
	JSL $01802A|!BankB
	
	LDA !GroundHit,x
	BNE +
	LDA #$20 : STA !BossSubTimer,x
+
	
	LDA !1588,x
	AND #$04
	BEQ +
	LDA !GroundHit,x
	BNE +
	LDA #$E0 : STA !SpriteYSpeed,x
	JSR ImpactEffect
	INC !GroundHit,x
+

	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
+
	RTS
;;;;;;;
;;;;;;;
.Bolders
;	JMP FINISH_SUBSTATE

	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .flyup
		dw .leftright
		dw .leftright
		dw .leftright
		dw .oop
		dw .returntospot
		dw FINISH_SUBSTATE
.oop
	LDA #$50 : STA !BossSubTimer,x
	INC !BossSubStates,x
	BRA .Bolders
.flyup
	%invoke_snes(.set7fc0fdto1bs)
;	LDA #$40 : STA !BossSubTimer,x
	
	LDA #-$18 : STA !sprite_speed_y,x
	JSL $01801A|!BankB ; y
	
	STZ !sprite_speed_x,x
	
	LDA !sprite_y_high,x
	BNE +
	LDA !sprite_y_low,x
	CMP #$D0
	BCS +
	INC !BossSubStates,x
+	JMP .doflyframes


.speeeed
	db $20,-$20
.momentuummmm
	db $02,-$02
.leftright
	JSR .doflyframes
	STZ !GroundHit,x
	
	%SubHorzPos()
	
	LDA !sprite_speed_x,x
	CMP .speeeed,y
	BEQ +
	CLC : ADC .momentuummmm,y
	STA !sprite_speed_x,x
+	JSL $018022|!BankB

	LDA !BossSubTimer,x
	BNE +
	LDA #$40 : STA !BossSubTimer,x
	INC !BossSubStates,x

	STZ $00 : STZ $01
	STZ $02 : LDA #-$20 : STZ $03

	LDA #$57 : JSR GenCSpr
	CPY #$FF
	BEQ +
	
	LDA #$03
	PHX : TYX
	STA !extra_byte_1,x
	PLX
	
	LDA #$20 : STA $1DF9|!Base2
+	JMP .wavymotion

.returntospot
	STZ !sprite_speed_x,x
	JMP .ReturnToPoint_Bypass
	RTS
;;;;;;;
;;;;;;;
.Pencils
;	LDA #$01 : STA $7FC0FD
	%invoke_snes(.set7fc0fdto1bs)

	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .DrawDemoLol
		dw .DrawDemoLol
		dw .DrawDemoLol
		dw .Wait
		dw .Wait
		dw FINISH_SUBSTATE
.DrawDemoLol
	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
	LDA !BossSubStates,x : TAY
	LDA .Times2,y : STA !BossSubTimer,x
	
	LDA #$57 : JSR GenCSpr
	CPY #$FF
	BEQ +
	
	LDA #$04
	PHX : TYX
	STA !extra_byte_1,x
	PLX
	
	LDA #$20 : STA $1DF9|!Base2

+	RTS
.Times2
	db $40,$40,$40,$F0,$40
;;;;;;;
;;;;;;;
.ThwompLand
	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .SetTimern
		dw .PoofGone
		dw .PrestoItsGusto
		dw .ThwompsForDays
		dw .ReturnToPoint
		dw FINISH_SUBSTATE
.SetTimern
	STZ $00 : STZ $01
	LDA #$18 : STA $02
	LDA #$01 : %SpawnSmoke()

	LDA #$14 : STA !BossSubTimer,x
	LDA #$03 : STA !sprite_x_high,x
	INC !BossSubStates,x
	BRA .ThwompLand

.PoofGone
	LDA !BossSubTimer,x
	BNE +
	LDA #$30 : STA !BossSubTimer,x
	LDA #$01 : STA !sprite_x_high,x : STA !sprite_y_high,x
	LDA #$00 : STA !sprite_y_low,x
	LDA #$78 : STA !sprite_x_low,x
	INC !BossSubStates,x
	
	STZ $00 : STZ $01
	LDA #$18 : STA $02
	LDA #$01 : %SpawnSmoke()
+	RTS

.ThwompsForDays
	JSR .T_hwomp
	JSR .PrestoItsGusto
	RTS

.Set02To7FC0FC
	LDA $7FC0FC : ORA #$02 : STA $7FC0FC
	RTL
.T_hwomp
	%invoke_snes(.Set02To7FC0FC)

	LDA $14 : AND #$1F
	BNE +
.T_hanos
	STZ $00 : STZ $01
	STZ $02 : STZ $03
	LDA #$93 : SEC
	%SpawnSprite()
	CPY #$FF : BEQ +
	
	PHY ;STY $0C
	LDA #$03 : %Random()
	TAY
	LSR A : EOR #$01 : STA $00 ;!1534,y
	LDA .xposs,y : STA $01 ; ypos low
	LDA .xposh,y : STA $02
	LDA .yposs,y : STA $03
	;LDA .yposh,y : STA $04
	PLY
	LDA $00 : STA !1534,y
	LDA $01 : STA !sprite_x_low,y
	LDA $02 : STA !sprite_x_high,y
	LDA $03 : STA !sprite_y_low,y
	LDA #$01 : STA !sprite_y_high,y
	PHX : TYX
	;LDA !7FAB10,x : ORA #$04 : STA !7FAB10,x ; set extra bit
	PLX
+	RTS
.PrestoItsGusto
	LDA !BossSubTimer,x
	BNE +
	STZ !GroundHit,x
	STZ !sprite_speed_y,x
	LDA #$FF : STA !BossSubTimer,x
	INC !BossSubStates,x
+

	LDA $14
	LSR A : AND #$01
	CLC : ADC #$04
	STA !FrameIndex,x

.wavymotion
	LDA $14
	LSR #3 : AND #$07
	TAY	: LDA .WavySpd,y
	STA !sprite_speed_y,x
	JSL $01801A|!BankB
	RTS
.WavySpd
	db $00,$F8,$F2,$F8,$00,$08,$0E,$08
.xposs
	db $E8,$E8,$08,$08
.xposh
	db $00,$00,$02,$02
.yposs
	db $38,$5B,$40,$60
;.yposh

.Clear02To7FC0FC
	LDA $7FC0FC : AND #$FD : STA $7FC0FC
	RTL
.ReturnToPoint
	%invoke_snes(.Clear02To7FC0FC)
	LDA !BossSubTimer,x
	CMP #$50
	BCC +
	LDA #$48 : STA !BossSubTimer,x
+
.ReturnToPoint_Bypass

	LDA #$03 : STA !FrameIndex,x

	STZ !sprite_speed_x,x
	LDA #$CA; : STA !SpriteXLowTarget,x
	LDY #$01; : STA !SpriteXHighTarget,x

	;LDY !SpriteXHighTarget,x
	;LDA !SpriteXLowTarget,x
	JSR EaseIn_X

	JSL $01802A|!BankB
	JSL $019138|!BankB		;interact with objects
	LDA !1588,x
	AND #$04
	BEQ +
	LDA !GroundHit,x
	BNE +
	LDA #$E0 : STA !SpriteYSpeed,x
	JSR ImpactEffect
	INC !GroundHit,x
+

	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
+	RTS

;;;;;;;
;;;;;;;
.Fire
;	LDA #$01 : STA $7FC0FD
	%invoke_snes(.set7fc0fdto1bs)
	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .timerstuffman
		dw .Firer
		dw .Firer
		dw .Firer
		dw .TheReurn
		dw FINISH_SUBSTATE

.timerstuffman
	;LDA $7FC0FC : ORA #$02 : STA $7FC0FC
	%invoke_snes(.Set02To7FC0FC)
	LDA #$40 : STA !BossSubTimer,x
	LDA #$0E : STA $1DFC|!Base2
	INC !BossSubStates,x
	BRA .Fire

.Firer
	LDA !BossSubTimer,x
	CMP #$10
	BCS ++
	PHA
	JSR DoShake
	PLA
++	CMP #$00
	BNE +
	INC !BossSubStates,x
;	JSR GetScreenSide_Sprite
	LDY #$00
	LDA !sprite_x_low,x
	BPL ++ : INY : ++
	STY $0C
	
	LDA #$30 : STA !BossSubTimer,x
	LDA #-$08 : STA $00
	LDA #-$10 : STA $01
	;LDA .spritexspawnsp,y : STA $02
	STZ $02 : STZ $03
	LDA #$94 : SEC : %SpawnSprite()
	CPY #$FF : BEQ +
	LDA !1528,y : INC : STA !1528,y ; change to fire
;	LDA $0C : STA !SpriteDirection,y
	PHX : LDX $0C
	LDA .spritexspawnsp,x : STA !sprite_speed_x,y
	PLX
	
	LDA #-$08 : STA $00
	STZ $01 : LDA #$1B : STA $02
	LDA #$01 : %SpawnSmoke()
+	RTS
.spritexspawnsp
	db $20,-$20

.TheReurn
;	LDA $7FC0FC : AND #$FD : STA $7FC0FC
	%invoke_snes(.Clear02To7FC0FC)
	JMP .Stool

;;;;;;;
;;;;;;;
.Earthquake
	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .SetTimer
		dw .Shaker
		dw .Rise
		dw .SMAAAASH
		dw .Rise
		dw .SMAAAASH
		dw .Rise
		dw .SMAAAASH
		dw .ReturnRise
		dw .SMAAAASH
		dw .Stool
		dw FINISH_SUBSTATE
.SetTimer
	LDA #$20 : STA !BossSubTimer,x : STA $1887|!addr
	INC !BossSubStates,x
	BRA .Earthquake

.Shaker
	JSR DoShake
	LDA !BossSubTimer,x
	BNE +
	JSR .DoPose1
	LDA #$30 : STA !BossSubTimer,x
	INC !BossSubStates,x
	LDA #$0E : STA $1DFC|!addr
+	RTS

.ReturnRise
	LDA #$CA : STA !SpriteXLowTarget,x
.Rise
	STZ !GroundHit,x
	LDY !SpriteXHighTarget,x
	LDA !SpriteXLowTarget,x
	JSR EaseIn_X
	LDY !SpriteYHighTarget,x
	LDA !SpriteYLowTarget,x
	JSR EaseIn_Y
	LDA !BossSubTimer,x
	BNE +
	LDA #$20 : STA !BossSubTimer,x
	INC !BossSubStates,x
	;LDA #$2B : STA $1DFC|!addr ; fall sfx
	;LDA #$00 : 
	STZ $00
	LDA #$28 : STA $01
	JSR SetUpPlaySFX
+

	LDA $14
	LSR A : AND #$01
	CLC : ADC #$04
	STA !FrameIndex,x
	RTS

.SMAAAASH
	JSR PlaySFXForOneFrame

	LDA !GroundHit,x
	BNE +
	LDA #$03 : STA !FrameIndex,x
	LDA #$70 : STA !sprite_speed_y,x
	JSL $01802A|!BankB

	LDA !1588,x
	AND #$04
	BEQ +
	JSR ImpactEffect
	INC !GroundHit,x
+

	LDA !BossSubTimer,x
	BNE +
	JSR .DoPose1
	LDA #$18 : STA !BossSubTimer,x
	INC !BossSubStates,x
+
	RTS

.Stool
	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
+	RTS

.DoPose1
	LDA #$01 : STA !SpriteXHighTarget,x : STZ !SpriteYHighTarget,x
	LDA $94 : STA !SpriteXLowTarget,x
	LDA #$D0 : STA !SpriteYLowTarget,x
	RTS
;;;;;;;
;;;;;;;
.Bouncy
JSL $01802A|!BankB

	LDA !BossSubStates,x
	JSL $0086DF|!BankB
	dw .DoBounceOnce
	dw .KeepBouncing
	dw .Stallerella
	dw FINISH_SUBSTATE
.DoBounceOnce
	JSR GetScreenSide_Sprite
	LDA #$A0 : STA !sprite_speed_y,x
	LDA .side,y : STA !sprite_speed_x,x
	INC !BossSubStates,x
	;BRA .Bouncy
	RTS
.side
	db $09,-$09

.KeepBouncing
	LDA !1588,x
	AND #$04
	BEQ +
	LDA !sprite_speed_x,x
	BEQ .donebounce
	LDA #$A8 : STA !sprite_speed_y,x
	JSR ImpactEffect
+
	LDY #$00
	LDA !sprite_speed_x,x
	BPL +
	INY
+
	LDA !sprite_x_low,x
	CLC : ADC #$08
	EOR .Reverse,y
	CMP #$30
	BCS +
	STZ !sprite_speed_x,x
+	RTS
.Reverse
	db $FF,$00
	
.donebounce
	INC !BossSubStates,x
	LDA #$20 : STA !BossSubTimer,x
;	LDA #$09 : STA $1DFC|!Base2
	JSR ImpactEffect
	RTS
.Stallerella
	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
+	RTS

;;;;;;;
;;;;;;;
.RAM
	LDA !BossSubStates,x
	JSL $0086DF|!BankB
	dw .dotimerset
	dw .WhoaBackAwayFriend
	dw .RAAAAAAAAAAAA
	dw .bump
	dw FINISH_SUBSTATE

.dotimerset
	LDA #$1C : STA !BossSubTimer,x
	INC !BossSubStates,x
	BRA .RAM

.WhoaBackAwayFriend
	JSR GetScreenSide_Sprite
	LDA .sideh,y : STA !sprite_speed_x,x
.lel
	
	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
	LDA .sideE,y : STA !sprite_speed_x,x
+	
	JSL $018022|!BankB
	RTS
.sideh
	db -$08,$08
	
	
.RAAAAAAAAAAAA
	LDA $14
	AND #$07
	BNE +
	LDA #$01 : STA $1DF9|!Base2
	STZ $00
	LDA #$0B : STA $01
	LDA #$14 : STA $02
	LDA #$03 : %SpawnSmoke()
+


	LDA !sprite_x_high,x
	CMP #$01 : BEQ +
	TAY ; ez
	INC !BossSubStates,x
	LDA .xpostarget,y : STA !SpriteXLowTarget,x
	LDA #$01 : STA !SpriteXHighTarget,x
	JSR ImpactEffect
	LDA #-$10 : STA !sprite_speed_y,x
+

	LDA #$30 : STA !BossSubTimer,x ; literally bs lol
	JSR .lel
	RTS
.xpostarget
	db $2B,$FF,$CA
.sideE
	db $34,-$34

.bump
	LDY !SpriteXHighTarget,x
	LDA !SpriteXLowTarget,x
	JSR EaseIn_X

	STZ !sprite_speed_x,x
	JSL $01802A|!BankB
	JMP .Stool

;;;;;;;
;;;;;;;
.Wyatt
	;JMP .ThwompLand

	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .SetTimern
		dw .PoofGone
		dw .PrestoItsGuston
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysButWithATwist
		
		dw .ThwompsForDaysButWithATwist
		dw .ThwompsForDaysTwistFinale
		dw .ThwompsForDaysTwistFinale
		dw FINISH_SUBSTATE

.PrestoItsGuston
	LDA !BossSubTimer,x
	BNE +
	LDA #$40 : STA $1887|!addr
+
	JSR .PrestoItsGusto
	RTS

.ThwompsForDaysButWithATwist
	JSR .definitelyknowwhatimdoing
	JSR .ahdamnit
	RTS

.ThwompsForDaysTwistFinale
	JSR .definitelyknowwhatimdoing
	
	LDA !BossSubStates,x
	AND #$01
	JSL $0086DF|!BankB
		dw .ReturnRise
		dw .SMAAAASH

.definitelyknowwhatimdoing
	LDA !BossSubTimer,x
	CMP #$50
	BCC +
	LDA #$40 : STA !BossSubTimer,x
+
	LDA $14
	AND #$3F
	BNE +
	JSR .T_hanos
+	RTS
.ahdamnit
	LDA !BossSubStates,x
	INC : AND #$03
	JSL $0086DF|!BankB
		dw .Shaker
		dw .Rise
		dw .Rise
		dw .SMAAAASH





;######################################
;##### Boss Dead/Damaged Routines #####
;######################################
.IsDamaged
	LDY #$01
	LDA #$CA
	JSR EaseIn_X
	JSL $01802A|!BankB

	LDA !GroundHit,x
	BNE +
	LDA !1588,x
	AND #$04
	BEQ +
	JSR ImpactEffect
	INC !GroundHit,x
	LDA #$E0 : STA !sprite_speed_y,x
+

	LDA !BossDamageTimer,x
	CMP #$20
	BNE .nohealther
	LDA !HealthRam,x
	CMP #$02 : BEQ .healther
	CMP #$04 : BEQ .healther
	BRA .nohealther
.healther
	LDA #$01 : STA $0DC2|!Base2
	LDA #$1C : STA $1DF9|!Base2
	LDA #$0B : STA $1DFC|!Base2
.nohealther
	RTS

.YouAreDeadDeadDead
	LDA #$FF : STA $1DFB|!Base2
	
	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .DoSmoke
		dw .shakerrrr
		dw .DoDie
.shakerrrr
	LDA #$28 : STA $1887|!Base2
	INC !BossSubStates,x
	JMP .YouAreDeadDeadDead

.DoSmoke
	LDA !BossSubStates,x
	BEQ +
	CMP #$10
	BCC ++
	JSR DoShake
++	JSR DoShake
+
	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
	LDA !SpriteXLowTarget,x
	CMP #$04
	BEQ ++
	DEC !SpriteXLowTarget,x
++	LDA !SpriteXLowTarget,x
	STA !BossSubTimer,x
	
	LDA #$09 : STA $1DFC|!Base2
	
	LDA #$30 : %Random()
	SEC : SBC #$18 : STA $0E
	LDA #$40 : %Random()
	SEC : SBC #$30
	STA $01 : LDA $0E : STA $00
	LDA #$1B : STA $02
	LDA #$01 : %SpawnSmoke()
	CPY #$FF : BEQ +
+	RTS

.DoDie
	STZ !SpriteXLowTarget,x
	LDA #$06 : STA !FrameIndex,x ; move to death
	LDA #$30 : STA !BossSubTimer,x
	LDA #$16 : STA $1DFC|!Base2	
RTS

.FortressDying
	LDA !BossSubTimer,x
	BEQ .DoTheDie
;	DEC A : BNE .nosfx
;.nosfx
	LDA $14 : LSR A : AND #$03 : PHA
	CLC : ADC #$06
	STA !FrameIndex,x
	PLA : AND #$01
	ASL A : TAY
	REP #$20
	LDA .backpal,y : STA $0701|!Base2 : STA $0903|!Base2
	SEP #$20
	RTS
.backpal
	dw $4A94,$4EB5

.DoTheDie
	REP #$20
	LDA .backpal : STA $0701|!Base2 : STA $0903|!Base2
	SEP #$20
	
;	LDA !FrameIndex,x
;	CMP #$1D
;	BEQ +
	LDA $14
	AND #$03 : BNE .skip
	LDA #$09 : STA $1DFC|!Base2 : STA $1887|!Base2
	INC !FrameIndex,x
	LDA !FrameIndex,x
	CMP #$1D : BNE .skip
	STZ !BossSubStates,x
	LDA #$30 : STA !BossSubTimer,x
;	BRA .skip
;+
;	LDA #$22 : STA $1DF9|!Base2
;	LDA #$13 : STA $1DFB|!Base2
;	LDA #$0B : STA $71 : STZ $7B
;	LDA $13EF|!Base2 : BEQ +
;	LDA #$26 : STA $13E0|!Base2 : STA $13D3|!Base2
.skip
	STZ !sprite_speed_y,x
	STZ !sprite_speed_x,x

	RTS


.CastleDestructionCutscene
	LDA !BossSubStates,x
	JSL $0086DF|!BankB
		dw .DelayOfText
		dw .FreezeVictory ;
		dw .DisplayText
		dw .FreezeVictory
		dw .DisplayText
		dw .FreezeVictory
		dw .DisplayText
		dw .FreezeVictory
		dw .DisplayText
		dw .FreezeVictory
		dw .DisplayText
		dw .FreezeVictory
		dw .DisplayText
		dw .FreezeVictory
		dw .DisplayText
		dw .FreezeVictory
		dw .DisplayTextFinal
		dw .FreezeVictoryToEnd
	
.DelayOfText
	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
	LDA #60 : STA !BossSubTimer,x
+	RTS

.FreezeVictory
	JSR .TheFreeze

	LDA !BossSubTimer,x
	BNE +
	INC !BossSubStates,x
+	RTS

.TheFreeze
;	LDA #$22 : STA $1DF9|!Base2
	LDA #$13 : STA $1DFB|!Base2
;	LDA #$0B : STA $71 : STZ $7B
;	LDA $13EF|!Base2 : BEQ +
;	LDA #$26 : STA $13E0|!Base2 : STA $13D3|!Base2
;+
	STZ !sprite_speed_y,x
	STZ !sprite_speed_x,x
	RTS


.DisplayText
	INC $18CB|!Base2 ; all handled in uberasm
	INC !BossSubStates,x
	LDA #$28 : STA !BossSubTimer,x
	RTS


.DisplayTextFinal
	JSR .DisplayText
	
;	INC !BossSubStates,x
	LDA #$FF : STA !BossSubTimer,x
	RTS

.FreezeVictoryToEnd
	JSR .TheFreeze

	LDA !BossSubTimer,x
	BNE .keeptimerfrosten
	LDA !SpriteDecTimer3,x
	BNE +
	LDA $16 : ORA $18
	BEQ +
	; clear level through regular fade
	LDA #$01
	STA $13CE|!Base2
	STA $0DD5|!Base2
	INC $1DE9|!Base2
	LDA #$0B
	STA $0100|!Base2
+
	RTS
.keeptimerfrosten
	LDA #$FF : STA !SpriteDecTimer3,x
	RTS


;######################################
;########   Other Sprites   ###########
;######################################
.MissileUp
	; Animation
	INC !MissileAnimation,x
	LDA !MissileAnimation,x
	LSR A
	AND #$03
	CLC : ADC #$1E
	STA !FrameIndex,x
	
	; fly up speed
	LDA !SpriteYSpeed,x
	DEC A
	CMP #$C0
	BCC +
	STA !SpriteYSpeed,x
+	JSL $01801A|!BankB

	; sound
	LDA !MissileAnimation,x
	AND #$07
	BNE +
	LDA #$17 : STA $1DFC|!Base2 ; big fire
+

	; pos check
	LDA !SpriteYHigh,x : XBA : LDA !SpriteYLow,x
	REP #$20
	CMP #$0080
	SEP #$20
	BCS +
	LDA !MissileType,x
			BEQ .AimDemo
	DEC A : BEQ .SetAim
+	RTS
.AimDemo
	LDA $D1
	BRA .FinishAim
.SetAim
	LDA !MissilePos,x
.FinishAim
	STA !SpriteXLow,x
	LDA #$90 : STA !SpriteYLow,x
	LDA #$22 : STA !FrameIndex,x
	STZ !MissileAnimation,x
	LDA #$2B : STA $1DFC|!Base2
	RTS

.MissileDown
	; Animation
	INC !MissileAnimation,x
	LDA !MissileAnimation,x
	LSR A
	AND #$03
	CLC : ADC #$22
	STA !FrameIndex,x
	
	; downwards speed (FAST)
	LDA #$60 : STA !SpriteYSpeed,x
	JSL $01801A|!BankB
	
	; check for ground
	JSL $019138|!BankB		;interact with objects
	LDA !1588,x
	AND #$04
	BEQ +
	LDA #$26 : STA !FrameIndex,x
	STZ !MissileAnimation,x
	JSR ImpactEffect
+	RTS
.MissileBlownUp
	INC !MissileAnimation,x
	LDA !MissileAnimation,x
	AND #$03
	BNE +
	INC !FrameIndex,x
	LDA !FrameIndex,x
	CMP #$2A
	BNE +
	DEC A
	STA !FrameIndex,x
	STZ !14C8,x
+	RTS

;;;;;;;;;;;;;;;;;;;;
.MiniCastle
	LDA !SpriteDirection,x
	TAY

	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$04
	BEQ +
	LDA .direc,y : STA !sprite_speed_x,x
	LDA #$D0 : STA !sprite_speed_y,x
+


;.Bolder
	JSL $01802A|!BankB
	
	LDA !SpriteHMoreThan4TilesOffScreenFlag,x
	;ORA !SpriteVOffScreenFlag,x
	BEQ +
	STZ !14C8,x
+	RTS
.direc
	db -$20,$20

;;;;;;;;;;;;;;;;;;;; lol
.Bolder
	STZ !sprite_speed_x,x
	JSL $01802A|!BankB ; yea das it
	
	LDA !SpriteBlockedStatus_ASB0UDLR,x
	AND #$04
	BEQ +
	STZ !14C8,x
	
	LDY #$01
-
	STY $0C
	STZ $00 : STZ $01
	LDA .xspeedrock,y : STA $02
	LDA #$D0 : STA $03
	LDA #$48 : CLC : %SpawnSprite()
	CPY #$FF : BEQ ++
	
++	LDY $0C : DEY : BPL -

	LDA #$08 : STA $1887|!Base2

	STZ $00 : STZ $01
	LDA #$1B : STA $02
	LDA #$01 : %SpawnSmoke()
+	RTS
.xspeedrock
	db $30,-$30

;;;;;;;;;;;;;;;;;;;;
.Pencil
	LDA !PencilState,x
	JSL $0086DF|!BankB
		dw .repos
		dw .dofollow
		dw .delayrise
		dw .SPIKE
		dw .delaydrop
		dw .drop
		dw .endme
.repos
	LDA !sprite_y_low,x
	CLC : ADC #$05
	STA !sprite_y_low,x
	INC !PencilState,x
	BRA .Pencil

.dofollow
	LDA !PencilTimer,x
	BNE +
	PHA
	LDA #$60 : STA !PencilTimer,x
	PLA
+	CMP #$01
	BNE +
	INC !PencilState,x
	LDA #$1C : STA !PencilTimer,x
+
.easein
	REP #$20
	LDA $94
	CLC : ADC #$0002
	STA $0C
	SEP #$20
	LDY $0D
	LDA $0C
	JSR EaseIn_X
	RTS

.delayrise
	JSR .easein
	LDA !PencilTimer,x
	AND #$03
	BNE +
	LDA #$23 : STA $1DFC|!Base2
+

	LDA !PencilTimer,x
	BNE +
	LDA #$06 : STA !PencilTimer,x
	LDA #$27 : STA $1DFC|!Base2
	INC !PencilState,x
+	RTS

.SPIKE
	LDA !sprite_y_high,x : XBA : LDA !sprite_y_low,x
	REP #$20
	SEC : SBC #$0008
	SEP #$20
	STA !sprite_y_low,x : XBA : STA !sprite_y_high,x

.delaydrop
	LDA !PencilTimer,x
	BNE +
	LDA #$10 : STA !PencilTimer,x
	INC !PencilState,x
+	RTS

.drop
	LDA !sprite_y_high,x : XBA : LDA !sprite_y_low,x
	REP #$20
	CLC : ADC #$0008
	SEP #$20
	STA !sprite_y_low,x : XBA : STA !sprite_y_high,x
	BRA .delaydrop

.endme
	STZ !14C8,x
	RTS




;######################################
;######## Common Subroutines ###########
;######################################
FINISH_SUBSTATE:
	STZ !BossSubStates,x
	STZ !SpriteXSpeed,x : STZ !SpriteYSpeed,x ; clean up speed
	;INC 
;	LDA #$04 : STA !BossStates,x ; for now

	INC !BossCurrentAttackOffset,x
	LDA !BossCurrentAttackOffset,x
	TAY
	LDA .BEGIN,y
	CMP #$FF
	BNE +
;	PHY
	LDA !HealthRam,x : TAY
	LDA .StateLists,y : STA !BossCurrentAttackOffset,x
	STA $0C;	PLY
	
	STZ $00 : STZ $01
	STZ $02 : STZ $03
	LDA #$94 : SEC : %SpawnSprite()
	CPY #$FF : BEQ ++
	LDA #$01 : STA !sprite_x_high,y
	DEC : STA !sprite_y_high,y
	LDA #$E0 : STA !sprite_y_low,y
	LDA #$78 : STA !sprite_x_low,y
++
	LDY $0C
+	

	LDA .BEGIN,y : STA !BossStates,x

	RTS ;JMP SpriteCode_Fortress_BBBBBOSS_BATTLE
.BEGIN
	db $00,$08,$00,$09,$01,$FF
.INCHING
	db $03,$09,$09,$02,$FF,$FF
.TRICKY
	db $09,$05,$08,$07,$FF,$FF
.HARD_ONLY
	db $09,$06,$09,$06,$04,$FF,$FF
.LAST_RUSH
	db $00,$03,$08,$01,$05,$09,$06,$09,$02,$06,$07,$0A,$FF

.StateLists
	db $00,$06,$0C,$12,$19

GenCSpr:
	PHA ; save it
	STZ $00 : STZ $01
	STZ $02 : STZ $03
	PLA : SEC ; pull it
GenSpr:
	%SpawnSprite()
	RTS
GenNSpr:
	PHA ; save it
	STZ $00 : STZ $01
	STZ $02 : STZ $03
	PLA : CLC ; pull it
	BRA GenSpr

	; generates noise and causes earthquake
ImpactEffect:
	LDA #$09 : STA $1DFC|!Base2 : ASL A : STA $1887|!Base2
	RTS

EaseIn_X:
	; 16bit value of Sprite's "target" x position
	STA $00 : STY $01
	
	; 16bit value of Sprite's x position
	LDA !sprite_x_low,x : STA $02
	LDA !sprite_x_high,x : STA $03

	; Find the middle of the two numbers
	JSR DoMiddleTwoNumberMath	
	STA !sprite_x_low,x : XBA : STA !sprite_x_high,x ; Store it to sprite's x position.
	RTS

EaseIn_Y:
	; 16bit value of Sprite's "target" x position
	STA $00 : STY $01
	
	; 16bit value of Sprite's x position
	LDA !sprite_y_low,x : STA $02
	LDA !sprite_y_high,x : STA $03

	; Find the middle of the two numbers
	JSR DoMiddleTwoNumberMath	
	STA !sprite_y_low,x : XBA : STA !sprite_y_high,x ; Store it to sprite's x position.
	RTS

; formula is basically (a+b)/2
;
; Input (16-bit):
; $00 - Target Position
; $02 - Current Position
;
; Output:
; A - Result
;
; keep in mind, this does not account for "negative numbers".
DoMiddleTwoNumberMath:
	REP #$20 : LDA $00 : CLC : ADC $02 ; Add the values of the sprite vs target location
	LSR A : STA $00
	LDA $00 : CLC : ADC $02 
	LSR A : SEP #$20 ; Divide it by 2 and return to 8bit
	RTS


DoShake:
	LDA $14 : AND #$01
	ASL A : TAY
	LDA !sprite_x_high,x : XBA : LDA !sprite_x_low,x
	REP #$20 : CLC : ADC .Shk,y : SEP #$20
	STA !sprite_x_low,x : XBA : STA !sprite_x_high,x
	RTS
.Shk
	dw $0002,$FFFE


GetScreenSide_Sprite:
	LDA !sprite_x_low,x
	AND #$80 : ROL #2
	TAY : RTS


DetectDamage:
	LDY.b #!SprSize-1
-
	PHX : TYX
	LDA !7FAB9E,x ; custom sprite num
	PLX
	CMP #$94 ; TNT
	BNE +
	
	PHX : TYX
	LDA !7FAB10,x
	PLX
	AND #$08
	BEQ +

	LDA !14C8,y
	CMP #$08
	BNE + ; invalid
	LDA !1534,y
	BEQ + ; not exploding
	JSR BombLogic
+	DEY
	BPL -
	RTS

BombLogic:
	;  bomb pos
	;PHX : TYX
	;JSL $03B6E5|!BankB ; $03B69F
	;PLX
	LDA !sprite_x_high,y : XBA : LDA !sprite_x_low,y
	REP #$20
	SEC : SBC #$0008
	SEP #$20
	STA $00 : XBA : STA $08
	LDA !sprite_y_low,y : STA $01
	LDA !sprite_y_high,y : STA $09
	LDA #$40 : STA $02
	LDA #$20 : STA $03

	; boss pos
	;LDA !SpriteXHigh,x : XBA : LDA !SpriteXLow,x
	;REP #$20 : SEC : SBC #$0008 : SEP #$20 ; shift centerpoint right a bit
	;STA $04 : XBA : STA $0A
	LDA !sprite_x_low,x : STA $04
	LDA !sprite_x_high,x : STA $0A
    ;LDA !SpriteYLow,x : STA $05
    ;LDA !SpriteYHigh,x : STA $0B
	LDA !SpriteYHigh,x : XBA : LDA !SpriteYLow,x
	REP #$20
	SEC : SBC #$0018
	SEP #$20
	STA $05 : XBA : STA $0B
	LDA #$30 : STA $06
	LDA #$40 : STA $07

	; compare contact
	JSL $03B72B|!BankB
	BCC .invalid
	
	JSR BombDamage
	
.invalid
	RTS
	

BombDamage:
;	STA $18E6|!Base2
	; winning
	LDA !BossDamageTimer,x ; damage timer
	BEQ .damageboss
	RTS

.damageboss
    LDA #$56 : STA !BossDamageTimer,x
    INC !HealthRam,x
    
    LDA !HealthRam,x : TAY
    LDA FINISH_SUBSTATE_StateLists,y : STA !BossCurrentAttackOffset,x
    LDA !BossCurrentAttackOffset,x : TAY
    LDA FINISH_SUBSTATE_BEGIN,y : STA !BossStates,x
    STZ !BossSubStates,x
    STZ !BossSubTimer,x
    STZ !SpriteXSpeed,x : STZ !SpriteYSpeed,x
    STZ !GroundHit,x

    LDA #$03 : STA !FrameIndex,x ; reset frame
    
    JSR KillAllButSelf
    
    LDA !HealthRam,x
    CMP #$05 : BNE .nokillboss
    LDA #$0B : STA !BossStates,x
    ASL A : STA !SpriteXLowTarget,x
    LDA #$FF : STA !BossSubTimer,x
.nokillboss
    RTS

KillAllButSelf:
	PHY
	LDY #!SprSize-1
-	LDA !SpriteIndex : STA $00
	CPY $00
	BEQ .dontkill
	LDA !9E,y
	CMP #$74 : BEQ .dontkill ; mushroom
	CMP #$75 : BEQ .dontkill ; flower
	CMP #$76 : BEQ .dontkill ; cape
	CMP #$77 : BEQ .dontkill ; star
	CMP #$78 : BEQ .dontkill ; 1-up
	CMP #$7F : BEQ .dontkill ; flying 1-up (why not)
	
	PHX : TYX
	LDA !CustomSpriteNumber,x
	PLX
	CMP #$94 : BNE .IsNotTNT
	LDA !1528,y : BEQ .dontkill
.IsNotTNT
	LDA #$00
	STA !14C8,y
.dontkill
	DEY : BPL -
	PLY
	RTS


PlaySFXForOneFrame:
	LDA !SFXBuffer,x
	BEQ +
	
	LDA !SFXBank,x : TAY ; I mean really it can only be 0 or 3
	LDA !SFXToPlay,x : STA $1DF9|!addr,y
	
+	RTS

SetUpPlaySFX:
	LDA #$02 : STA !SFXBuffer,x ; do you need more than 1 frame?
	LDA $00 : STA !SFXBank,x ; 0 or 3 is recommended
	LDA $01 : STA !SFXToPlay,x ; what sfx
	RTS

;######################################
;########## Graphics Space ############
;######################################
GraphicRoutine:
	; basic flash
	LDA !BossDamageTimer,x
	LSR A : AND #$01 ; make it a 30fps flash for raocow :point_at_camera:
	BEQ +
	RTS
+

    %GetDrawInfo()                     ;Calls GetDrawInfo to get the free slot and the XDisp and YDisp

    STZ !Scratch3                       ;$02 = Free Slot but in 16bits
    STY !Scratch2


    STZ !Scratch5
    LDA !GlobalFlip,x   
    ASL
    STA !Scratch4                       ;$04 = Global Flip but in 16bits


    PHX                                 ;Preserve X
    
    STZ !Scratch7
    LDA !FrameIndex,x
    STA !Scratch6                       ;$06 = Frame Index but in 16bits

    REP #$30                            ;A/X/Y 16bits mode
    LDY !Scratch4                       ;Y = Global Flip
    LDA !Scratch6
    ASL
	CLC
    ADC FramesFlippers,y
    TAX                                 ;X = Frame Index

    LDA FramesLength,x
    CMP #$FFFF
    BNE +
    SEP #$30
    PLX
    RTS
+
    STA !Scratch8

    LDA FramesEndPosition,x
    STA !Scratch4                       ;$04 = End Position + A value used to select a frame version that is flipped

    LDA FramesStartPosition,x           
    TAX                                 ;X = Start Position
    SEP #$20                            ;A 8bits mode
    LDY !Scratch2                       ;Y = Free Slot
    CPY #$00FD
    BCS .return                         ;Y can't be more than #$00FD
-
    LDA Tiles,x
    STA !TileCode,y                     ;Set the Tile code of the tile Y

    LDA Properties,x
    STA !TileProperty,y                 ;Set the Tile property of the tile Y

    LDA !Scratch0
	CLC
	ADC XDisplacements,x
	STA !TileXPosition,y                ;Set the Tile x pos of the tile Y

    LDA !Scratch1
	CLC
	ADC YDisplacements,x
	STA !TileYPosition,y                ;Set the Tile y pos of the tile Y

    PHY
	REP #$20                                 
    TYA
    LSR
    LSR
    TAY                                 ;Y = Y/4 because size directions are not continuous to map 200 and 300
	SEP #$20
    LDA Sizes,x
    STA !TileSize460,y                  ;Set the Tile size of the tile Y
    PLY

    INY
    INY
    INY
    INY                                 ;Next OAM Slot
    CPY #$00FD
    BCS .return                         ;Y can't be more than #$00FD

    DEX
    BMI .return
    CPX !Scratch4                       ;if X < start position or is negative then return
    BCS -                               ;else loop

.return
    SEP #$10
    PLX                                 ;Restore X
    
    LDY #$FF                            ;Allows mode of 8 or 16 bits
    LDA !Scratch8                       ;Load the number of tiles used by the frame
    JSL $01B7B3|!rom                  		;This insert the new tiles into the oam, 
                                        ;A = #$00 => only tiles of 8x8, A = #$02 = only tiles of 16x16, A = #$04 = tiles of 8x8 or 16x16
                                        ;if you select A = #$04 then you must put the sizes of the tiles in !TileSize
RTS


FramesLength:
    dw $0001,$0002,$0002,$000C,$000D,$000D,$0012,$0012,$0012,$0012,$000F,$000F,$000F,$000B,$000B,$000B
	dw $000B,$0008,$0008,$0008,$0008,$0005,$0006,$0006,$0006,$0007,$0007,$0007,$0007,$0004,$0008,$0008
	dw $0008,$0008,$0008,$0008,$0008,$0008,$000B,$000B,$000B,$000B,$0009,$0003,$0003
	dw $0001,$0002,$0002,$000C,$000D,$000D,$0012,$0012,$0012,$0012,$000F,$000F,$000F,$000B,$000B,$000B
	dw $000B,$0008,$0008,$0008,$0008,$0005,$0006,$0006,$0006,$0007,$0007,$0007,$0007,$0004,$0008,$0008
	dw $0008,$0008,$0008,$0008,$0008,$0008,$000B,$000B,$000B,$000B,$0009,$0003,$0003


FramesFlippers:
    dw $0000,$005A


FramesStartPosition:
    dw $0001,$0004,$0007,$0014,$0022,$0030,$0043,$0056,$0069,$007C,$008C,$009C,$00AC,$00B8,$00C4,$00D0
	dw $00DC,$00E5,$00EE,$00F7,$0100,$0106,$010D,$0114,$011B,$0123,$012B,$0133,$013B,$0140,$0149,$0152
	dw $015B,$0164,$016D,$0176,$017F,$0188,$0194,$01A0,$01AC,$01B8,$01C2,$01C6,$01CA
	dw $01CC,$01CF,$01D2,$01DF,$01ED,$01FB,$020E,$0221,$0234,$0247,$0257,$0267,$0277,$0283,$028F,$029B
	dw $02A7,$02B0,$02B9,$02C2,$02CB,$02D1,$02D8,$02DF,$02E6,$02EE,$02F6,$02FE,$0306,$030B,$0314,$031D
	dw $0326,$032F,$0338,$0341,$034A,$0353,$035F,$036B,$0377,$0383,$038D,$0391,$0395


FramesEndPosition:
    dw $0000,$0002,$0005,$0008,$0015,$0023,$0031,$0044,$0057,$006A,$007D,$008D,$009D,$00AD,$00B9,$00C5
	dw $00D1,$00DD,$00E6,$00EF,$00F8,$0101,$0107,$010E,$0115,$011C,$0124,$012C,$0134,$013C,$0141,$014A
	dw $0153,$015C,$0165,$016E,$0177,$0180,$0189,$0195,$01A1,$01AD,$01B9,$01C3,$01C7
	dw $01CB,$01CD,$01D0,$01D3,$01E0,$01EE,$01FC,$020F,$0222,$0235,$0248,$0258,$0268,$0278,$0284,$0290
	dw $029C,$02A8,$02B1,$02BA,$02C3,$02CC,$02D2,$02D9,$02E0,$02E7,$02EF,$02F7,$02FF,$0307,$030C,$0315
	dw $031E,$0327,$0330,$0339,$0342,$034B,$0354,$0360,$036C,$0378,$0384,$038E,$0392




Tiles:
    
Frame0_FarAway_Tiles:
	db $00,$10
Frame1_FarAway_Fly_1_Tiles:
	db $8A,$00,$10
Frame2_FarAway_Fly_2_Tiles:
	db $8B,$00,$10
Frame3_BigCastle_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E
Frame4_BigCastleFly1_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$E0
Frame5_BigCastleFly2_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$E2
Frame6_Destruction1_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A0,$A2,$A4
	db $C0,$C2,$A6
Frame7_Destruction2_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A0,$A2,$A4
	db $C0,$C2,$A6
Frame8_Destruction3_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A0,$A2,$A4
	db $C0,$C2,$A6
Frame9_Destruction4_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A0,$A2,$A4
	db $C0,$C2,$A6
Frame10_Crashing1_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A8,$A9,$AB
Frame11_Crashing2_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A8,$A9,$AB
Frame12_Crashing3_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A8,$A9,$AB
Frame13_Crashing4_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$A8,$A9,$AB
Frame14_Crashing5_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$A8,$A9,$AB
Frame15_Crashin6_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$A8,$A9,$AB
Frame16_Crashing7_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$A8,$A9,$AB
Frame17_Crashing8_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$A8,$A9,$AB
Frame18_Crashing9_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$A8,$A9,$AB
Frame19_Crashing10_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$A8,$A9,$AB
Frame20_Crashing11_Tiles:
	db $0A,$0C,$0E,$60,$62,$64,$A8,$A9,$AB
Frame21_Crashing12_Tiles:
	db $0A,$0C,$0E,$A8,$A9,$AB
Frame22_Crashing13_Tiles:
	db $EA,$0A,$0C,$0E,$A8,$A9,$AB
Frame23_Crashing14_Tiles:
	db $EA,$0A,$0C,$0E,$A8,$A9,$AB
Frame24_Crashing15_Tiles:
	db $EA,$0A,$0C,$0E,$A8,$A9,$AB
Frame25_Crashin16_Tiles:
	db $EA,$E4,$E6,$E8,$F4,$A8,$A9,$AB
Frame26_Crashing17_Tiles:
	db $EA,$E4,$E6,$E8,$F4,$A8,$A9,$AB
Frame27_Crashing18_Tiles:
	db $EA,$E4,$E6,$E8,$F4,$A8,$A9,$AB
Frame28_Crashing19_Tiles:
	db $EA,$E4,$E6,$E8,$F4,$A8,$A9,$AB
Frame29_Dead_Tiles:
	db $EA,$E4,$E6,$E8,$F4
Frame30_BigFFFFFMissile_Tiles:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E0
Frame31_BigFFFFFMissile2_Tiles:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E2
Frame32_BigFFFFFMissile3_Tiles:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E0
Frame33_BigFFFFFMissile4_Tiles:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E2
Frame34_BigBoiDown1_Tiles:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E0
Frame35_BigBoiDown2_Tiles:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E2
Frame36_BigBoiDown3_Tiles:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E0
Frame37_BigBoiDown4_Tiles:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E2
Frame38_MissileBlowup1_Tiles:
	db $60,$60,$60,$60,$60,$60,$A0,$C0,$A2,$C2,$A4,$A6
Frame39_MissileBlowup2_Tiles:
	db $62,$62,$62,$62,$62,$62,$A0,$C0,$A2,$C2,$A4,$A6
Frame40_MissileBlowup3_Tiles:
	db $64,$64,$64,$64,$64,$64,$A0,$C0,$A2,$C2,$A4,$A6
Frame41_MissileBlowup4_Tiles:
	db $66,$66,$66,$66,$66,$66,$A0,$C0,$A2,$C2,$A4,$A6
Frame42_MiniCastle_Tiles:
	db $0A,$0E,$2E,$60,$2A,$2F,$4E,$4E,$1C,$1D
Frame43_Bolder_Tiles:
	db $CC,$EC,$CE,$EE
Frame44_Pencil_Tiles:
	db $4A,$6A,$6A,$6A
Frame0_FarAway_TilesFlipX:
	db $00,$10
Frame1_FarAway_Fly_1_TilesFlipX:
	db $8A,$00,$10
Frame2_FarAway_Fly_2_TilesFlipX:
	db $8B,$00,$10
Frame3_BigCastle_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E
Frame4_BigCastleFly1_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$E0
Frame5_BigCastleFly2_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$E2
Frame6_Destruction1_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A0,$A2,$A4
	db $C0,$C2,$A6
Frame7_Destruction2_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A0,$A2,$A4
	db $C0,$C2,$A6
Frame8_Destruction3_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A0,$A2,$A4
	db $C0,$C2,$A6
Frame9_Destruction4_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A0,$A2,$A4
	db $C0,$C2,$A6
Frame10_Crashing1_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A8,$A9,$AB
Frame11_Crashing2_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A8,$A9,$AB
Frame12_Crashing3_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$64,$60,$4E,$4E,$A8,$A9,$AB
Frame13_Crashing4_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$A8,$A9,$AB
Frame14_Crashing5_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$A8,$A9,$AB
Frame15_Crashin6_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$A8,$A9,$AB
Frame16_Crashing7_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$2A,$2C,$64,$A8,$A9,$AB
Frame17_Crashing8_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$A8,$A9,$AB
Frame18_Crashing9_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$A8,$A9,$AB
Frame19_Crashing10_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$A8,$A9,$AB
Frame20_Crashing11_TilesFlipX:
	db $0A,$0C,$0E,$60,$62,$64,$A8,$A9,$AB
Frame21_Crashing12_TilesFlipX:
	db $0A,$0C,$0E,$A8,$A9,$AB
Frame22_Crashing13_TilesFlipX:
	db $EA,$0A,$0C,$0E,$A8,$A9,$AB
Frame23_Crashing14_TilesFlipX:
	db $EA,$0A,$0C,$0E,$A8,$A9,$AB
Frame24_Crashing15_TilesFlipX:
	db $EA,$0A,$0C,$0E,$A8,$A9,$AB
Frame25_Crashin16_TilesFlipX:
	db $EA,$E4,$E6,$E8,$F4,$A8,$A9,$AB
Frame26_Crashing17_TilesFlipX:
	db $EA,$E4,$E6,$E8,$F4,$A8,$A9,$AB
Frame27_Crashing18_TilesFlipX:
	db $EA,$E4,$E6,$E8,$F4,$A8,$A9,$AB
Frame28_Crashing19_TilesFlipX:
	db $EA,$E4,$E6,$E8,$F4,$A8,$A9,$AB
Frame29_Dead_TilesFlipX:
	db $EA,$E4,$E6,$E8,$F4
Frame30_BigFFFFFMissile_TilesFlipX:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E0
Frame31_BigFFFFFMissile2_TilesFlipX:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E2
Frame32_BigFFFFFMissile3_TilesFlipX:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E0
Frame33_BigFFFFFMissile4_TilesFlipX:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E2
Frame34_BigBoiDown1_TilesFlipX:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E0
Frame35_BigBoiDown2_TilesFlipX:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E2
Frame36_BigBoiDown3_TilesFlipX:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E0
Frame37_BigBoiDown4_TilesFlipX:
	db $07,$27,$47,$67,$08,$28,$48,$68,$E2
Frame38_MissileBlowup1_TilesFlipX:
	db $60,$60,$60,$60,$60,$60,$A0,$C0,$A2,$C2,$A4,$A6
Frame39_MissileBlowup2_TilesFlipX:
	db $62,$62,$62,$62,$62,$62,$A0,$C0,$A2,$C2,$A4,$A6
Frame40_MissileBlowup3_TilesFlipX:
	db $64,$64,$64,$64,$64,$64,$A0,$C0,$A2,$C2,$A4,$A6
Frame41_MissileBlowup4_TilesFlipX:
	db $66,$66,$66,$66,$66,$66,$A0,$C0,$A2,$C2,$A4,$A6
Frame42_MiniCastle_TilesFlipX:
	db $0A,$0E,$2E,$60,$2A,$2F,$4E,$4E,$1C,$1D
Frame43_Bolder_TilesFlipX:
	db $CC,$EC,$CE,$EE
Frame44_Pencil_TilesFlipX:
	db $4A,$6A,$6A,$6A





Properties:
    
Frame0_FarAway_Properties:
	db $3D,$3D
Frame1_FarAway_Fly_1_Properties:
	db $A5,$3D,$3D
Frame2_FarAway_Fly_2_Properties:
	db $A5,$3D,$3D
Frame3_BigCastle_Properties:
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$3D
Frame4_BigCastleFly1_Properties:
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$3D,$35
Frame5_BigCastleFly2_Properties:
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$3D,$35
Frame6_Destruction1_Properties:
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$3D,$35,$35,$35
	db $35,$35,$35
Frame7_Destruction2_Properties:
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$3D,$37,$37,$37
	db $37,$37,$37
Frame8_Destruction3_Properties:
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$3D,$39,$39,$39
	db $39,$39,$39
Frame9_Destruction4_Properties:
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$3D,$3B,$3B,$3B
	db $3B,$3B,$3B
Frame10_Crashing1_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$6D,$2D,$23,$23,$23
Frame11_Crashing2_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$6D,$2D,$63,$63,$63
Frame12_Crashing3_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$6D,$2D,$23,$23,$23
Frame13_Crashing4_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$63,$63,$63
Frame14_Crashing5_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$23,$23,$23
Frame15_Crashin6_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$63,$63,$63
Frame16_Crashing7_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$2D,$23,$23,$23
Frame17_Crashing8_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$63,$63,$63
Frame18_Crashing9_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$23,$23,$23
Frame19_Crashing10_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$63,$63,$63
Frame20_Crashing11_Properties:
	db $2D,$2D,$2D,$2D,$2D,$2D,$23,$23,$23
Frame21_Crashing12_Properties:
	db $2D,$2D,$2D,$63,$63,$63
Frame22_Crashing13_Properties:
	db $2D,$2D,$2D,$2D,$23,$23,$23
Frame23_Crashing14_Properties:
	db $2D,$2D,$2D,$2D,$63,$63,$63
Frame24_Crashing15_Properties:
	db $2D,$2D,$2D,$2D,$23,$23,$23
Frame25_Crashin16_Properties:
	db $2D,$2D,$2D,$2D,$6D,$63,$63,$63
Frame26_Crashing17_Properties:
	db $2D,$2D,$2D,$2D,$6D,$23,$23,$23
Frame27_Crashing18_Properties:
	db $2D,$2D,$2D,$2D,$6D,$63,$63,$63
Frame28_Crashing19_Properties:
	db $2D,$2D,$2D,$2D,$6D,$23,$23,$23
Frame29_Dead_Properties:
	db $2D,$2D,$2D,$2D,$6D
Frame30_BigFFFFFMissile_Properties:
	db $2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$25
Frame31_BigFFFFFMissile2_Properties:
	db $2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$25
Frame32_BigFFFFFMissile3_Properties:
	db $2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$65
Frame33_BigFFFFFMissile4_Properties:
	db $2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$65
Frame34_BigBoiDown1_Properties:
	db $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF,$A5
Frame35_BigBoiDown2_Properties:
	db $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF,$A5
Frame36_BigBoiDown3_Properties:
	db $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF,$E5
Frame37_BigBoiDown4_Properties:
	db $AF,$AF,$AF,$AF,$AF,$AF,$AF,$AF,$E5
Frame38_MissileBlowup1_Properties:
	db $24,$64,$24,$24,$64,$24,$25,$25,$25,$25,$25,$25
Frame39_MissileBlowup2_Properties:
	db $24,$64,$24,$24,$64,$24,$27,$27,$27,$27,$27,$27
Frame40_MissileBlowup3_Properties:
	db $24,$64,$24,$24,$64,$24,$29,$29,$29,$29,$29,$29
Frame41_MissileBlowup4_Properties:
	db $24,$24,$64,$24,$24,$64,$2B,$2B,$2B,$2B,$2B,$2B
Frame42_MiniCastle_Properties:
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$7D,$3D,$3D
Frame43_Bolder_Properties:
	db $2D,$2D,$2D,$2D
Frame44_Pencil_Properties:
	db $2D,$2D,$2D,$2D


Frame0_FarAway_PropertiesFlipX:
	db $7D,$7D
Frame1_FarAway_Fly_1_PropertiesFlipX:
	db $E5,$7D,$7D
Frame2_FarAway_Fly_2_PropertiesFlipX:
	db $E5,$7D,$7D
Frame3_BigCastle_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D
Frame4_BigCastleFly1_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$75
Frame5_BigCastleFly2_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$75
Frame6_Destruction1_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$75,$75,$75
	db $75,$75,$75
Frame7_Destruction2_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$77,$77,$77
	db $77,$77,$77
Frame8_Destruction3_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$79,$79,$79
	db $79,$79,$79
Frame9_Destruction4_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$7B,$7B,$7B
	db $7B,$7B,$7B
Frame10_Crashing1_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$73,$73,$73
Frame11_Crashing2_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$33,$33,$33
Frame12_Crashing3_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$73,$73,$73
Frame13_Crashing4_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$33,$33,$33
Frame14_Crashing5_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$73,$73,$73
Frame15_Crashin6_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$33,$33,$33
Frame16_Crashing7_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$7D,$73,$73,$73
Frame17_Crashing8_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$33,$33,$33
Frame18_Crashing9_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$73,$73,$73
Frame19_Crashing10_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$33,$33,$33
Frame20_Crashing11_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$73,$73,$73
Frame21_Crashing12_PropertiesFlipX:
	db $7D,$7D,$7D,$33,$33,$33
Frame22_Crashing13_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$73,$73,$73
Frame23_Crashing14_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$33,$33,$33
Frame24_Crashing15_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$73,$73,$73
Frame25_Crashin16_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$3D,$33,$33,$33
Frame26_Crashing17_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$3D,$73,$73,$73
Frame27_Crashing18_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$3D,$33,$33,$33
Frame28_Crashing19_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$3D,$73,$73,$73
Frame29_Dead_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$3D
Frame30_BigFFFFFMissile_PropertiesFlipX:
	db $6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$65
Frame31_BigFFFFFMissile2_PropertiesFlipX:
	db $6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$65
Frame32_BigFFFFFMissile3_PropertiesFlipX:
	db $6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$25
Frame33_BigFFFFFMissile4_PropertiesFlipX:
	db $6F,$6F,$6F,$6F,$6F,$6F,$6F,$6F,$25
Frame34_BigBoiDown1_PropertiesFlipX:
	db $EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$E5
Frame35_BigBoiDown2_PropertiesFlipX:
	db $EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$E5
Frame36_BigBoiDown3_PropertiesFlipX:
	db $EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$A5
Frame37_BigBoiDown4_PropertiesFlipX:
	db $EF,$EF,$EF,$EF,$EF,$EF,$EF,$EF,$A5
Frame38_MissileBlowup1_PropertiesFlipX:
	db $64,$24,$64,$64,$24,$64,$65,$65,$65,$65,$65,$65
Frame39_MissileBlowup2_PropertiesFlipX:
	db $64,$24,$64,$64,$24,$64,$67,$67,$67,$67,$67,$67
Frame40_MissileBlowup3_PropertiesFlipX:
	db $64,$24,$64,$64,$24,$64,$69,$69,$69,$69,$69,$69
Frame41_MissileBlowup4_PropertiesFlipX:
	db $64,$64,$24,$64,$64,$24,$6B,$6B,$6B,$6B,$6B,$6B
Frame42_MiniCastle_PropertiesFlipX:
	db $7D,$7D,$7D,$7D,$7D,$7D,$7D,$3D,$7D,$7D
Frame43_Bolder_PropertiesFlipX:
	db $6D,$6D,$6D,$6D
Frame44_Pencil_PropertiesFlipX:
	db $6D,$6D,$6D,$6D




XDisplacements:
    
Frame0_FarAway_XDisp:
	db $00,$00
Frame1_FarAway_Fly_1_XDisp:
	db $04,$00,$00
Frame2_FarAway_Fly_2_XDisp:
	db $04,$00,$00
Frame3_BigCastle_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00
Frame4_BigCastleFly1_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$00
Frame5_BigCastleFly2_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$00
Frame6_Destruction1_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$F0,$00,$10
	db $F0,$00,$10
Frame7_Destruction2_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$F0,$00,$10
	db $F0,$00,$10
Frame8_Destruction3_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$F0,$00,$10
	db $F0,$00,$10
Frame9_Destruction4_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$F0,$00,$10
	db $F0,$00,$10
Frame10_Crashing1_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$F0,$00,$10
Frame11_Crashing2_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$10,$00,$F0
Frame12_Crashing3_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$F0,$F8,$00,$F0,$00,$10
Frame13_Crashing4_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$00,$F0
Frame14_Crashing5_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$F0,$00,$10
Frame15_Crashin6_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$10,$00,$F0
Frame16_Crashing7_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10,$F0,$00,$10
Frame17_Crashing8_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$10,$00,$F0
Frame18_Crashing9_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10
Frame19_Crashing10_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$10,$00,$F0
Frame20_Crashing11_XDisp:
	db $F0,$00,$10,$F0,$00,$10,$F0,$00,$10
Frame21_Crashing12_XDisp:
	db $F0,$00,$10,$10,$00,$F0
Frame22_Crashing13_XDisp:
	db $00,$F0,$00,$10,$F0,$00,$10
Frame23_Crashing14_XDisp:
	db $00,$F0,$00,$10,$10,$00,$F0
Frame24_Crashing15_XDisp:
	db $00,$F0,$00,$10,$F0,$00,$10
Frame25_Crashin16_XDisp:
	db $00,$EC,$FC,$0C,$1C,$10,$00,$F0
Frame26_Crashing17_XDisp:
	db $00,$EC,$FC,$0C,$1C,$F0,$00,$10
Frame27_Crashing18_XDisp:
	db $00,$EC,$FC,$0C,$1C,$10,$00,$F0
Frame28_Crashing19_XDisp:
	db $00,$EC,$FC,$0C,$1C,$F0,$00,$10
Frame29_Dead_XDisp:
	db $00,$EC,$FC,$0C,$1C
Frame30_BigFFFFFMissile_XDisp:
	db $FC,$FC,$FC,$FC,$04,$04,$04,$04,$00
Frame31_BigFFFFFMissile2_XDisp:
	db $FC,$FC,$FC,$FC,$04,$04,$04,$04,$00
Frame32_BigFFFFFMissile3_XDisp:
	db $FC,$FC,$FC,$FC,$04,$04,$04,$04,$00
Frame33_BigFFFFFMissile4_XDisp:
	db $FC,$FC,$FC,$FC,$04,$04,$04,$04,$00
Frame34_BigBoiDown1_XDisp:
	db $FC,$FC,$FC,$FC,$04,$04,$04,$04,$00
Frame35_BigBoiDown2_XDisp:
	db $FC,$FC,$FC,$FC,$04,$04,$04,$04,$00
Frame36_BigBoiDown3_XDisp:
	db $FC,$FC,$FC,$FC,$04,$04,$04,$04,$00
Frame37_BigBoiDown4_XDisp:
	db $FC,$FC,$FC,$FC,$04,$04,$04,$04,$00
Frame38_MissileBlowup1_XDisp:
	db $01,$F9,$07,$FB,$06,$FF,$F0,$F0,$00,$00,$10,$10
Frame39_MissileBlowup2_XDisp:
	db $03,$F5,$0A,$F7,$0A,$FC,$F0,$F0,$00,$00,$10,$10
Frame40_MissileBlowup3_XDisp:
	db $F8,$0E,$F3,$0D,$F3,$05,$F0,$F0,$00,$00,$10,$10
Frame41_MissileBlowup4_XDisp:
	db $07,$11,$11,$F6,$F1,$F0,$F0,$F0,$00,$00,$10,$10
Frame42_MiniCastle_XDisp:
	db $F8,$08,$08,$F8,$F8,$10,$04,$FC,$00,$08
Frame43_Bolder_XDisp:
	db $F8,$F8,$08,$08
Frame44_Pencil_XDisp:
	db $00,$00,$00,$00
Frame0_FarAway_XDispFlipX:
	db $00,$00
Frame1_FarAway_Fly_1_XDispFlipX:
	db $04,$00,$00
Frame2_FarAway_Fly_2_XDispFlipX:
	db $04,$00,$00
Frame3_BigCastle_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00
Frame4_BigCastleFly1_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$00
Frame5_BigCastleFly2_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$00
Frame6_Destruction1_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$10,$00,$F0
	db $10,$00,$F0
Frame7_Destruction2_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$10,$00,$F0
	db $10,$00,$F0
Frame8_Destruction3_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$10,$00,$F0
	db $10,$00,$F0
Frame9_Destruction4_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$10,$00,$F0
	db $10,$00,$F0
Frame10_Crashing1_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$10,$00,$F0
Frame11_Crashing2_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$F0,$00,$10
Frame12_Crashing3_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$10,$08,$00,$10,$00,$F0
Frame13_Crashing4_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$00,$10
Frame14_Crashing5_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$10,$00,$F0
Frame15_Crashin6_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$F0,$00,$10
Frame16_Crashing7_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0,$10,$00,$F0
Frame17_Crashing8_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$F0,$00,$10
Frame18_Crashing9_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0
Frame19_Crashing10_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$F0,$00,$10
Frame20_Crashing11_XDispFlipX:
	db $10,$00,$F0,$10,$00,$F0,$10,$00,$F0
Frame21_Crashing12_XDispFlipX:
	db $10,$00,$F0,$F0,$00,$10
Frame22_Crashing13_XDispFlipX:
	db $00,$10,$00,$F0,$10,$00,$F0
Frame23_Crashing14_XDispFlipX:
	db $00,$10,$00,$F0,$F0,$00,$10
Frame24_Crashing15_XDispFlipX:
	db $00,$10,$00,$F0,$10,$00,$F0
Frame25_Crashin16_XDispFlipX:
	db $00,$14,$04,$F4,$EC,$F0,$00,$10
Frame26_Crashing17_XDispFlipX:
	db $00,$14,$04,$F4,$EC,$10,$00,$F0
Frame27_Crashing18_XDispFlipX:
	db $00,$14,$04,$F4,$EC,$F0,$00,$10
Frame28_Crashing19_XDispFlipX:
	db $00,$14,$04,$F4,$EC,$10,$00,$F0
Frame29_Dead_XDispFlipX:
	db $00,$14,$04,$F4,$EC
Frame30_BigFFFFFMissile_XDispFlipX:
	db $04,$04,$04,$04,$FC,$FC,$FC,$FC,$00
Frame31_BigFFFFFMissile2_XDispFlipX:
	db $04,$04,$04,$04,$FC,$FC,$FC,$FC,$00
Frame32_BigFFFFFMissile3_XDispFlipX:
	db $04,$04,$04,$04,$FC,$FC,$FC,$FC,$00
Frame33_BigFFFFFMissile4_XDispFlipX:
	db $04,$04,$04,$04,$FC,$FC,$FC,$FC,$00
Frame34_BigBoiDown1_XDispFlipX:
	db $04,$04,$04,$04,$FC,$FC,$FC,$FC,$00
Frame35_BigBoiDown2_XDispFlipX:
	db $04,$04,$04,$04,$FC,$FC,$FC,$FC,$00
Frame36_BigBoiDown3_XDispFlipX:
	db $04,$04,$04,$04,$FC,$FC,$FC,$FC,$00
Frame37_BigBoiDown4_XDispFlipX:
	db $04,$04,$04,$04,$FC,$FC,$FC,$FC,$00
Frame38_MissileBlowup1_XDispFlipX:
	db $FF,$07,$F9,$05,$FA,$01,$10,$10,$00,$00,$F0,$F0
Frame39_MissileBlowup2_XDispFlipX:
	db $FD,$0B,$F6,$09,$F6,$04,$10,$10,$00,$00,$F0,$F0
Frame40_MissileBlowup3_XDispFlipX:
	db $08,$F2,$0D,$F3,$0D,$FB,$10,$10,$00,$00,$F0,$F0
Frame41_MissileBlowup4_XDispFlipX:
	db $F9,$EF,$EF,$0A,$0F,$10,$10,$10,$00,$00,$F0,$F0
Frame42_MiniCastle_XDispFlipX:
	db $08,$F8,$F8,$08,$10,$F8,$FC,$04,$08,$00
Frame43_Bolder_XDispFlipX:
	db $08,$08,$F8,$F8
Frame44_Pencil_XDispFlipX:
	db $00,$00,$00,$00




YDisplacements:
    
Frame0_FarAway_YDisp:
	db $F0-7,$F8-7
Frame1_FarAway_Fly_1_YDisp:
	db $07-6,$F0-6,$F8-6
Frame2_FarAway_Fly_2_YDisp:
	db $07-6,$F0-6,$F8-6
Frame3_BigCastle_YDisp:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00
Frame4_BigCastleFly1_YDisp:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$10
Frame5_BigCastleFly2_YDisp:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$10
Frame6_Destruction1_YDisp:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$F0,$F0,$F0
	db $00,$00,$00
Frame7_Destruction2_YDisp:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$F0,$F0,$F0
	db $00,$00,$00
Frame8_Destruction3_YDisp:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$F0,$F0,$F0
	db $00,$00,$00
Frame9_Destruction4_YDisp:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$F0,$F0,$F0
	db $00,$00,$00
Frame10_Crashing1_YDisp:
	db $D4,$D4,$D4,$E4,$E4,$E4,$F4,$F4,$F4,$04,$04,$04,$04,$0C,$0C,$0C
Frame11_Crashing2_YDisp:
	db $D8,$D8,$D8,$E8,$E8,$E8,$F8,$F8,$F8,$08,$08,$08,$08,$08,$08,$08
Frame12_Crashing3_YDisp:
	db $DC,$DC,$DC,$EC,$EC,$EC,$FC,$FC,$FC,$0C,$0C,$0C,$0C,$04,$04,$04
Frame13_Crashing4_YDisp:
	db $E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$00,$00
Frame14_Crashing5_YDisp:
	db $E4,$E4,$E4,$F4,$F4,$F4,$04,$04,$04,$00,$00,$00
Frame15_Crashin6_YDisp:
	db $E8,$E8,$E8,$F8,$F8,$F8,$08,$08,$08,$00,$00,$00
Frame16_Crashing7_YDisp:
	db $EC,$EC,$EC,$FC,$FC,$FC,$0C,$0C,$0C,$00,$00,$00
Frame17_Crashing8_YDisp:
	db $F0,$F0,$F0,$00,$00,$00,$00,$00,$00
Frame18_Crashing9_YDisp:
	db $F4,$F4,$F4,$04,$04,$04,$00,$00,$00
Frame19_Crashing10_YDisp:
	db $F8,$F8,$F8,$08,$08,$08,$00,$00,$00
Frame20_Crashing11_YDisp:
	db $FC,$FC,$FC,$0C,$0C,$0C,$00,$00,$00
Frame21_Crashing12_YDisp:
	db $00,$00,$00,$00,$00,$00
Frame22_Crashing13_YDisp:
	db $FC,$04,$04,$04,$00,$00,$00
Frame23_Crashing14_YDisp:
	db $F8,$08,$08,$08,$00,$00,$00
Frame24_Crashing15_YDisp:
	db $F5,$0C,$0C,$0C,$00,$00,$00
Frame25_Crashin16_YDisp:
	db $F5,$00,$00,$00,$08,$00,$00,$00
Frame26_Crashing17_YDisp:
	db $F5,$00,$00,$00,$08,$04,$04,$04
Frame27_Crashing18_YDisp:
	db $F5,$00,$00,$00,$08,$08,$08,$08
Frame28_Crashing19_YDisp:
	db $F5,$00,$00,$00,$08,$0C,$0C,$0C
Frame29_Dead_YDisp:
	db $F5,$00,$00,$00,$08
Frame30_BigFFFFFMissile_YDisp:
	db $D1,$E1,$F1,$01,$D1,$E1,$F1,$01,$10
Frame31_BigFFFFFMissile2_YDisp:
	db $D1,$E1,$F1,$01,$D1,$E1,$F1,$01,$10
Frame32_BigFFFFFMissile3_YDisp:
	db $D1,$E1,$F1,$01,$D1,$E1,$F1,$01,$10
Frame33_BigFFFFFMissile4_YDisp:
	db $D1,$E1,$F1,$01,$D1,$E1,$F1,$01,$10
Frame34_BigBoiDown1_YDisp:
	db $10,$00,$F0,$E0,$10,$00,$F0,$E0,$D1
Frame35_BigBoiDown2_YDisp:
	db $10,$00,$F0,$E0,$10,$00,$F0,$E0,$D1
Frame36_BigBoiDown3_YDisp:
	db $10,$00,$F0,$E0,$10,$00,$F0,$E0,$D1
Frame37_BigBoiDown4_YDisp:
	db $10,$00,$F0,$E0,$10,$00,$F0,$E0,$D1
Frame38_MissileBlowup1_YDisp:
	db $0B,$FD,$F7,$EA,$E3,$D6,$E8,$F8,$E8,$F8,$E8,$F8
Frame39_MissileBlowup2_YDisp:
	db $0E,$FC,$F5,$E8,$E1,$D3,$E8,$F8,$E8,$F8,$E8,$F8
Frame40_MissileBlowup3_YDisp:
	db $CF,$DC,$E4,$F3,$FE,$11,$E8,$F8,$E8,$F8,$E8,$F8
Frame41_MissileBlowup4_YDisp:
	db $13,$EF,$D9,$CC,$E2,$01,$E8,$F8,$E8,$F8,$E8,$F8
Frame42_MiniCastle_YDisp:
	db $F0,$F0,$00,$00,$FA,$FA,$00,$00,$F8,$F8
Frame43_Bolder_YDisp:
	db $F8,$08,$F8,$08
Frame44_Pencil_YDisp:
	db $00,$10,$20,$30
Frame0_FarAway_YDispFlipX:
	db $F0,$F8
Frame1_FarAway_Fly_1_YDispFlipX:
	db $07,$F0,$F8
Frame2_FarAway_Fly_2_YDispFlipX:
	db $07,$F0,$F8
Frame3_BigCastle_YDispFlipX:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00
Frame4_BigCastleFly1_YDispFlipX:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$10
Frame5_BigCastleFly2_YDispFlipX:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$10
Frame6_Destruction1_YDispFlipX:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$F0,$F0,$F0
	db $00,$00,$00
Frame7_Destruction2_YDispFlipX:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$F0,$F0,$F0
	db $00,$00,$00
Frame8_Destruction3_YDispFlipX:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$F0,$F0,$F0
	db $00,$00,$00
Frame9_Destruction4_YDispFlipX:
	db $D0,$D0,$D0,$E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$F0,$F0,$F0
	db $00,$00,$00
Frame10_Crashing1_YDispFlipX:
	db $D4,$D4,$D4,$E4,$E4,$E4,$F4,$F4,$F4,$04,$04,$04,$04,$0C,$0C,$0C
Frame11_Crashing2_YDispFlipX:
	db $D8,$D8,$D8,$E8,$E8,$E8,$F8,$F8,$F8,$08,$08,$08,$08,$08,$08,$08
Frame12_Crashing3_YDispFlipX:
	db $DC,$DC,$DC,$EC,$EC,$EC,$FC,$FC,$FC,$0C,$0C,$0C,$0C,$04,$04,$04
Frame13_Crashing4_YDispFlipX:
	db $E0,$E0,$E0,$F0,$F0,$F0,$00,$00,$00,$00,$00,$00
Frame14_Crashing5_YDispFlipX:
	db $E4,$E4,$E4,$F4,$F4,$F4,$04,$04,$04,$00,$00,$00
Frame15_Crashin6_YDispFlipX:
	db $E8,$E8,$E8,$F8,$F8,$F8,$08,$08,$08,$00,$00,$00
Frame16_Crashing7_YDispFlipX:
	db $EC,$EC,$EC,$FC,$FC,$FC,$0C,$0C,$0C,$00,$00,$00
Frame17_Crashing8_YDispFlipX:
	db $F0,$F0,$F0,$00,$00,$00,$00,$00,$00
Frame18_Crashing9_YDispFlipX:
	db $F4,$F4,$F4,$04,$04,$04,$00,$00,$00
Frame19_Crashing10_YDispFlipX:
	db $F8,$F8,$F8,$08,$08,$08,$00,$00,$00
Frame20_Crashing11_YDispFlipX:
	db $FC,$FC,$FC,$0C,$0C,$0C,$00,$00,$00
Frame21_Crashing12_YDispFlipX:
	db $00,$00,$00,$00,$00,$00
Frame22_Crashing13_YDispFlipX:
	db $FC,$04,$04,$04,$00,$00,$00
Frame23_Crashing14_YDispFlipX:
	db $F8,$08,$08,$08,$00,$00,$00
Frame24_Crashing15_YDispFlipX:
	db $F5,$0C,$0C,$0C,$00,$00,$00
Frame25_Crashin16_YDispFlipX:
	db $F5,$00,$00,$00,$08,$00,$00,$00
Frame26_Crashing17_YDispFlipX:
	db $F5,$00,$00,$00,$08,$04,$04,$04
Frame27_Crashing18_YDispFlipX:
	db $F5,$00,$00,$00,$08,$08,$08,$08
Frame28_Crashing19_YDispFlipX:
	db $F5,$00,$00,$00,$08,$0C,$0C,$0C
Frame29_Dead_YDispFlipX:
	db $F5,$00,$00,$00,$08
Frame30_BigFFFFFMissile_YDispFlipX:
	db $D1,$E1,$F1,$01,$D1,$E1,$F1,$01,$10
Frame31_BigFFFFFMissile2_YDispFlipX:
	db $D1,$E1,$F1,$01,$D1,$E1,$F1,$01,$10
Frame32_BigFFFFFMissile3_YDispFlipX:
	db $D1,$E1,$F1,$01,$D1,$E1,$F1,$01,$10
Frame33_BigFFFFFMissile4_YDispFlipX:
	db $D1,$E1,$F1,$01,$D1,$E1,$F1,$01,$10
Frame34_BigBoiDown1_YDispFlipX:
	db $10,$00,$F0,$E0,$10,$00,$F0,$E0,$D1
Frame35_BigBoiDown2_YDispFlipX:
	db $10,$00,$F0,$E0,$10,$00,$F0,$E0,$D1
Frame36_BigBoiDown3_YDispFlipX:
	db $10,$00,$F0,$E0,$10,$00,$F0,$E0,$D1
Frame37_BigBoiDown4_YDispFlipX:
	db $10,$00,$F0,$E0,$10,$00,$F0,$E0,$D1
Frame38_MissileBlowup1_YDispFlipX:
	db $0B,$FD,$F7,$EA,$E3,$D6,$E8,$F8,$E8,$F8,$E8,$F8
Frame39_MissileBlowup2_YDispFlipX:
	db $0E,$FC,$F5,$E8,$E1,$D3,$E8,$F8,$E8,$F8,$E8,$F8
Frame40_MissileBlowup3_YDispFlipX:
	db $CF,$DC,$E4,$F3,$FE,$11,$E8,$F8,$E8,$F8,$E8,$F8
Frame41_MissileBlowup4_YDispFlipX:
	db $13,$EF,$D9,$CC,$E2,$01,$E8,$F8,$E8,$F8,$E8,$F8
Frame42_MiniCastle_YDispFlipX:
	db $F0,$F0,$00,$00,$FA,$FA,$00,$00,$F8,$F8
Frame43_Bolder_YDispFlipX:
	db $F8,$08,$F8,$08
Frame44_Pencil_YDispFlipX:
	db $00,$10,$20,$30




Sizes:
    
Frame0_FarAway_Sizes:
	db $02,$02
Frame1_FarAway_Fly_1_Sizes:
	db $00,$02,$02
Frame2_FarAway_Fly_2_Sizes:
	db $00,$02,$02
Frame3_BigCastle_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame4_BigCastleFly1_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame5_BigCastleFly2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame6_Destruction1_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02
Frame7_Destruction2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02
Frame8_Destruction3_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02
Frame9_Destruction4_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02
Frame10_Crashing1_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame11_Crashing2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame12_Crashing3_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame13_Crashing4_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame14_Crashing5_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame15_Crashin6_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame16_Crashing7_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame17_Crashing8_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame18_Crashing9_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame19_Crashing10_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame20_Crashing11_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame21_Crashing12_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame22_Crashing13_Sizes:
	db $02,$02,$02,$02,$02,$02,$02
Frame23_Crashing14_Sizes:
	db $02,$02,$02,$02,$02,$02,$02
Frame24_Crashing15_Sizes:
	db $02,$02,$02,$02,$02,$02,$02
Frame25_Crashin16_Sizes:
	db $02,$02,$02,$02,$00,$02,$02,$02
Frame26_Crashing17_Sizes:
	db $02,$02,$02,$02,$00,$02,$02,$02
Frame27_Crashing18_Sizes:
	db $02,$02,$02,$02,$00,$02,$02,$02
Frame28_Crashing19_Sizes:
	db $02,$02,$02,$02,$00,$02,$02,$02
Frame29_Dead_Sizes:
	db $02,$02,$02,$02,$00
Frame30_BigFFFFFMissile_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame31_BigFFFFFMissile2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame32_BigFFFFFMissile3_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame33_BigFFFFFMissile4_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame34_BigBoiDown1_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame35_BigBoiDown2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame36_BigBoiDown3_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame37_BigBoiDown4_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame38_MissileBlowup1_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame39_MissileBlowup2_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame40_MissileBlowup3_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame41_MissileBlowup4_Sizes:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame42_MiniCastle_Sizes:
	db $02,$02,$02,$02,$00,$00,$02,$02,$00,$00
Frame43_Bolder_Sizes:
	db $02,$02,$02,$02
Frame44_Pencil_Sizes:
	db $02,$02,$02,$02
Frame0_FarAway_SizesFlipX:
	db $02,$02
Frame1_FarAway_Fly_1_SizesFlipX:
	db $00,$02,$02
Frame2_FarAway_Fly_2_SizesFlipX:
	db $00,$02,$02
Frame3_BigCastle_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame4_BigCastleFly1_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame5_BigCastleFly2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame6_Destruction1_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02
Frame7_Destruction2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02
Frame8_Destruction3_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02
Frame9_Destruction4_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02
Frame10_Crashing1_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame11_Crashing2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame12_Crashing3_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame13_Crashing4_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame14_Crashing5_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame15_Crashin6_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame16_Crashing7_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame17_Crashing8_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame18_Crashing9_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame19_Crashing10_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame20_Crashing11_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame21_Crashing12_SizesFlipX:
	db $02,$02,$02,$02,$02,$02
Frame22_Crashing13_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02
Frame23_Crashing14_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02
Frame24_Crashing15_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02
Frame25_Crashin16_SizesFlipX:
	db $02,$02,$02,$02,$00,$02,$02,$02
Frame26_Crashing17_SizesFlipX:
	db $02,$02,$02,$02,$00,$02,$02,$02
Frame27_Crashing18_SizesFlipX:
	db $02,$02,$02,$02,$00,$02,$02,$02
Frame28_Crashing19_SizesFlipX:
	db $02,$02,$02,$02,$00,$02,$02,$02
Frame29_Dead_SizesFlipX:
	db $02,$02,$02,$02,$00
Frame30_BigFFFFFMissile_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame31_BigFFFFFMissile2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame32_BigFFFFFMissile3_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame33_BigFFFFFMissile4_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame34_BigBoiDown1_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame35_BigBoiDown2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame36_BigBoiDown3_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame37_BigBoiDown4_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02
Frame38_MissileBlowup1_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame39_MissileBlowup2_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame40_MissileBlowup3_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame41_MissileBlowup4_SizesFlipX:
	db $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
Frame42_MiniCastle_SizesFlipX:
	db $02,$02,$02,$02,$00,$00,$02,$02,$00,$00
Frame43_Bolder_SizesFlipX:
	db $02,$02,$02,$02
Frame44_Pencil_SizesFlipX:
	db $02,$02,$02,$02

;######################################
;######## Interaction Space ###########
;######################################

InteractMarioSprite:
	LDA !SpriteTweaker167A_DPMKSPIS,x
	AND #$20
	BNE ProcessInteract      
	TXA                       
	EOR !TrueFrameCounter      			
	AND #$01                	
	ORA !SpriteHOffScreenFlag,x 				
	BEQ ProcessInteract       
ReturnNoContact:
	CLC                       
	RTS
ProcessInteract:
	%SubHorzPos()
	LDA !ScratchF                  
	CLC                       
	ADC #$50                
	CMP #$A0                
	BCS ReturnNoContact       ; No contact, return 
	%SubVertPos()
	LDA !ScratchE                   
	CLC                       
	ADC #$60                
	CMP #$C0                
	BCS ReturnNoContact       ; No contact, return 
	LDA $71    ; \ If animation sequence activated... 
	CMP #$01                ;  | 
	BCS ReturnNoContact       ; / ...no contact, return 
	LDA #$00                ; \ Branch if bit 6 of $0D9B set? 
	BIT $0D9B|!addr               ;  | 
	BVS +           ; / 
	LDA $13F9|!addr ; \ If Mario and Sprite not on same side of scenery... 
	EOR !SpriteBehindEscenaryFlag,x ;  |
+
	BNE ReturnNoContact2
	JSL $03B664|!rom				; MarioClipping
	JSR Interaction

	BCC ReturnNoContact2
	LDA !ScratchE
	CMP #$01
	BNE +
	JSR DefaultAction
+
	SEC
	RTS
ReturnNoContact2:
	CLC
	RTS

Interaction:
    STZ !ScratchE
	LDA !GlobalFlip,x
    ASL
	TAY                     ;Y = Flip Adder, used to jump to the frame with the current flip

    LDA !FrameIndex,x
	STA !Scratch4
	STZ !Scratch5

    REP #$20
	LDA !Scratch4
	ASL
	CLC
	ADC HitboxAdder,y
	REP #$10
	TAY

    LDA FrameHitboxesIndexer,y
    TAY
    SEP #$20

-
    LDA FrameHitBoxes,y
    CMP #$FF
    BNE +
    LDA !ScratchE
    BNE ++
	SEP #$10
	LDX !SpriteIndex
    CLC
    RTS
++
	SEP #$10
	LDX !SpriteIndex
    SEC
    RTS
+
    STA !Scratch4
    STZ !Scratch5
    PHY

    REP #$20
    LDA !Scratch4
    ASL
    TAY

    LDA HitboxesStart,y
    TAY
    SEP #$20
+

	STZ !ScratchA
    LDA Hitboxes+1,y
    STA !Scratch4           ;$04 = Low X Offset
    BPL +
    LDA #$FF
    STA !ScratchA           ;$0A = High X offset
+

	STZ !ScratchB
    LDA Hitboxes+2,y
    STA !Scratch5           ;$05 = Low Y Offset
    BPL +
    LDA #$FF
    STA !ScratchB           ;$0B = High Y Offset
+

    LDA Hitboxes+3,y
    STA !Scratch6           ;$06 = Width

    LDA Hitboxes+4,y
    STA !Scratch7           ;$07 = Height

	PHY
	SEP #$10
	LDX !SpriteIndex

	LDA !SpriteXHigh,x
	XBA
	LDA !SpriteXLow,x
	REP #$20
	PHA
	SEP #$20

	LDA !ScratchA
	XBA
	LDA !Scratch4
	REP #$20
	CLC
	ADC $01,s
	PHA
	SEP #$20
	PLA 
	STA !Scratch4
	PLA
	STA !ScratchA
	PLA
	PLA

	LDA !SpriteYHigh,x
	XBA
	LDA !SpriteYLow,x
	REP #$20
	PHA
	SEP #$20

	LDA !ScratchB
	XBA
	LDA !Scratch5
	REP #$20
	CLC
	ADC $01,s
	PHA
	SEP #$20
	PLA 
	STA !Scratch5
	PLA
	STA !ScratchB
	PLA
	PLA

    JSL $03B72B|!rom
	REP #$10
	BCS ++
	PLY
	PLY
	INY
	JMP -
++
	PLY
	PLY
	LDA !ScratchE
	ORA #$01
	STA !ScratchE
	SEP #$10
	LDX !SpriteIndex
	SEC
	RTS

HitboxAdder:
    dw $0000,$005A

FrameHitboxesIndexer:
    dw $0000,$0001,$0002,$0003,$0005,$0007,$0009,$000A,$000B,$000C,$000D,$000E,$000F,$0010,$0011,$0012
	dw $0013,$0014,$0015,$0016,$0017,$0018,$0019,$001A,$001B,$001C,$001D,$001E,$001F,$0020,$0021,$0023
	dw $0025,$0027,$0029,$002B,$002D,$002F,$0031,$0033,$0035,$0037,$0039,$003B,$003D
	dw $003F,$0040,$0041,$0042,$0044,$0046,$0048,$0049,$004A,$004B,$004C,$004D,$004E,$004F,$0050,$0051
	dw $0052,$0053,$0054,$0055,$0056,$0057,$0058,$0059,$005A,$005B,$005C,$005D,$005E,$005F,$0060,$0062
	dw $0064,$0066,$0068,$006A,$006C,$006E,$0070,$0072,$0074,$0076,$0078,$007A,$007C

FrameHitBoxes:
    db $FF
	db $FF
	db $FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $01,$FF
	db $02,$FF
	db $02,$FF
	db $02,$FF
	db $02,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $04,$FF
	db $05,$FF
	db $06,$FF
	
	db $FF
	db $FF
	db $FF
	db $07,$FF
	db $07,$FF
	db $07,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $FF
	db $08,$FF
	db $08,$FF
	db $08,$FF
	db $08,$FF
	db $09,$FF
	db $09,$FF
	db $09,$FF
	db $09,$FF
	db $0A,$FF
	db $0A,$FF
	db $0A,$FF
	db $0A,$FF
	db $0B,$FF
	db $0C,$FF
	db $0D,$FF
	

HitboxesStart:
    dw $0000,$0006,$000C,$0012,$0018,$001E,$0024,$002A,$0030,$0036,$003C,$0042,$0048,$004E

Hitboxes:
    db $01,$F4,$D4,$28,$3C,$00
	db $01,$00,$DC,$10,$34,$00
	db $01,$00,$E0,$10,$34,$00
	db $01,$F8,$F0,$20,$10,$00
	db $01,$FC,$F4,$18,$1C,$00
	db $01,$FC,$FC,$18,$18,$00
	db $01,$04,$0C,$08,$34,$00
	db $01,$F4,$D4,$28,$3C,$00
	db $01,$00,$DC,$10,$34,$00
	db $01,$00,$E0,$10,$34,$00
	db $01,$F8,$F0,$20,$10,$00
	db $01,$FC,$F4,$18,$1C,$00
	db $01,$FC,$FC,$18,$18,$00
	db $01,$04,$0C,$08,$34,$00
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine
DefaultAction:
	LDA !extra_byte_1,x
	BEQ +
JustHurt:
	JSL $00F5B7
RTS

+
	LDA !BossDamageTimer,x
	BEQ +
	RTS
+
	LDA !BossStates,x
	CMP #$0B
	BNE +
	RTS
+

	BRA .a
.check7FC0FD
	LDA $7FC0FD : STA $00
	RTL
.a	
	%invoke_snes(.check7FC0FD)
	LDA $00
	BNE JustHurt
	%SubVertPos()
	LDA !ScratchF
	CLC : ADC #$40
	BPL JustHurt
	LDA $140D|!addr
	BEQ JustHurt
; taken from czar's burning ropes I and mellon made lol
DoLogic:
	LDA !PlayerX : SEC : SBC !SpriteXLow,x
	STA $00
	LDA !PlayerY : SEC : SBC !SpriteYLow,x : CLC : ADC #$10
	STA $01
	LDA #$08 : STA $02
	LDA #$02
	%SpawnSmoke()
	LDA.b #$02
	STA.w $1DF9|!addr
	LDA.b #$D0					;$01AA37	|\\ Speed Mario bounces off of an enemy without A being pressed.
	BIT $15						;$01AA39	||
	BPL +						;$01AA3B	||
	LDA.b #$A8					;$01AA3D	||| Speed Mario bounces off of an enemy with A pressed.
+
	STA $7D						;$01AA3F	|/
	RTS							;$01AA41	|


; this thing is total garbage btw, I'm just needing it for demonstration.
DISPLAY_HEALTH:
	LDA !extra_byte_1,x
	BEQ +
	RTS
+

	LDA !FrameIndex,x
	CMP #$03 : BCC +
	CMP #$06 : BCS +
	BRA ++
+	RTS
++
	LDA !HealthRam,x : STA $0C
;	CMP #$0B
;	BNE +
;	RTS
;+
	PHX
	LDY #$FC
	LDX #$16
	
-
;	CPY #((75-64)*4) : BEQ ++
;	CPY #((76-64)*4) : BEQ ++
;	CPY #((77-64)*4) : BEQ ++
;	CPY #((78-64)*4) : BEQ ++
	lda $0301|!addr,y : cmp #$F0 : beq +
++	dey #4 : bpl -

	PLX : rts

+
	LDA .ex,x : CLC : ADC #$78 : STA $0300|!addr,y
	LDA .why,x : CLC : ADC #$CE : STA $0301|!addr,y
	
	LDA .tilebytile,x : CMP #$30
	BNE +
	CPX $0C
	BCS +
	LDA #$25
+
	STA $0302|!addr,y
	LDA #$3D : STA $0303|!addr,y
	PHY : TYA : LSR #2 : TAY
	LDA .minesbigger,x : STA $0460|!addr,y
	PLY : DEY #4 : DEX : BPL -

	PLX : RTS

.ex
db $28,$14,$00,$EC,$D8

db $BC,$C4,$CC,$D4,$DC,$E4,$EC,$F4,$FC,$04,$0C,$14
db $24,$2C,$34,$3C,$44,$4C

.why
db $00,$00,$00,$00,$00
db $F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7,$F7
db $F7,$F7,$F7,$F7,$F7,$F7

;.props
;db $2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F,$2F
;db $2F,$2F,$2F,$2F,$2F,$2F
;db $2F,$2F,$2F,$2F,$2F

.minesbigger
db $02,$02,$02,$02,$02
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00

.tilebytile
db $30,$30,$30,$30,$30
db $23,$24,$02,$03,$04,$05,$02,$24,$24,$06,$23,$12
db $23,$02,$13,$14,$15,$16