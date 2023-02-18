;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;Boo Blah from Yoshi's Island;;;;;   
;;;;;Made by codfish1002         ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Extra bit
;;If the extra bit is set it will
;;Be the ceiling booblah if not
;;then it will be the ground booblah
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;ExtraByte Options
;;00 Normal 
;;01 turn around after stretching
;;02 Only Attack if mario is near
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Make sure to put blocks to make the 
;;ceiling booblah turn around as it does 
;;not detect whether or not its 
;;touching the ceiling anymore.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    Xspeed: db $F7,-$F7
	
    !GrowSFXNum = $14
    !SFXBank = $1DFC
    
    !TimeToAttack = $40                     ;Timer before stretching
    !EndAttack = $40                        ;Timer before boo blah goes back to normal
	
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
;############### Yoshi ##################
;########################################
!YoshiX = $18B0|!addr
!YoshiY = $18B2|!addr
!YoshiKeyInMouthFlag = $191C|!addr

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
;############## Defines ###############
;######################################

!FrameIndex = !SpriteMiscTable1
!AnimationTimer = !SpriteDecTimer1
!AnimationIndex = !SpriteMiscTable2
!AnimationFrameIndex = !SpriteMiscTable3
!LocalFlip = !SpriteMiscTable4

;######################################
;########### Init Routine #############
;######################################
print "INIT ",pc
	JSL InitWrapperChangeAnimationFromStart
	
	%SubHorzPos()
	TYA 
	EOR #$01
	STA !157C,x
	
    ;Here you can write your Init Code
    ;This will be excecuted when the sprite is spawned 
    RTL

;######################################
;########## Main Routine ##############
;######################################
print "MAIN ",pc
    PHB
    PHK
    PLB
    JSR SpriteCode
    PLB
RTL

;>Routine: SpriteCode
;>Description: This routine excecute the logic of the sprite
;>RoutineLength: Short
Return:
RTS

SpriteCode:

    JSR GraphicRoutine                  ;Calls the graphic routine and updates sprite graphics

    ;Here you can put code that will be excecuted each frame even if the sprite is locked

    LDA !SpriteStatus,x			        
	CMP #$08                            ;if sprite dead return
	BNE Return	

	LDA !LockAnimationFlag				    
	BNE Return			                    ;if locked animation return.

    %SubOffScreen()

    JSR InteractMarioSprite
    JSR AnimationRoutine                ;Calls animation routine and decides the next frame to draw
    
	LDA !1570,x
	JSL $0086DF|!BankB
    dw Walk
	dw Rise
	dw Smush
	
	
Walk:
    LDA !ExtraBits,x
	AND #$04
	BEQ +
	LDA !AnimationIndex,x
	CMP #$01
	BEQ +
	JSR ChangeAnimationFromStart_MoveUD
	RTS
+
	LDA !1534,x
	CMP #$02
	BEQ +
	
	LDA #!TimeToAttack
	STA !15AC,x
	LDA #$02
	STA !1534,x
	RTS
+
    JSR Move
	
	LDA !extra_byte_1,x
	CMP #$02
	BEQ Near
	
	LDA !15AC,x
	BNE Return	
-
	LDA !extra_byte_1,x
	CMP #$02
	BNE Face
	
	%SubHorzPos()
	TYA 
	EOR #$01
	STA !157C,x
Face:	
    LDA !ExtraBits,x
	AND #$04
	BEQ +    
    JSR ChangeAnimationFromStart_RiseUD
	BRA ++
+	
	JSR ChangeAnimationFromStart_Rise
++	INC !1570,x
	STZ !1534,x 
    RTS
Near:
	%SubHorzPos()		                               ;If Mario not closer than 0x30 pixels horizontally,
	LDA $0F				
	ADC #$30			
	CMP #$60			
	BCS +			                               ;Branch

	%SubVertPos()		                               ;If Mario not closer than 0x30 pixels vertically,
	LDA $0E			                               
	ADC #$30			                               
	CMP #$60			                              
	BCS +			                               ;Branch
	BRA -
	%SubHorzPos()
	TYA 
	EOR #$01
	STA !157C,x	
+	RTS
Near2:
	%SubHorzPos()		                               ;If Mario not closer than 0x30 pixels horizontally,
	LDA $0F				
	ADC #$30			
	CMP #$60			
	BCS End2			                               ;Branch

	%SubVertPos()		                               ;If Mario not closer than 0x30 pixels vertically,
	LDA $0E			                               
	ADC #$30			                               
	CMP #$60			                              
	BCS End2			                               ;Branch

	RTS
Increase:
    INC !1534,x
--- RTS
Rise:
	STZ !AA,x
    STZ !B6,x

    LDA !AnimationIndex,x
	CMP #$04
	BEQ Attack
	CMP #$05
	BEQ Attack		
	CMP #$06
	BEQ Finish
	CMP #$07
	BEQ Finish
	
	LDA !AnimationFrameIndex,x
	CMP #$05
	BCC +
	LDA !AnimationTimer,x
	BCC +
	LDA #!GrowSFXNum
	STA !SFXBank|!addr
	
    LDA !ExtraBits,x
	AND #$04
	BEQ ++    

	JSR ChangeAnimationFromStart_AttackUD
	BRA Time
++
    JSR ChangeAnimationFromStart_Attack
Time:
	LDA #!EndAttack
	STA !15AC,x
+
    RTS

Attack:
	LDA !extra_byte_1,x
	CMP #$02
	BEQ Near2

	LDA !15AC,x
	BNE +	
End2:    
    LDA !ExtraBits,x
	AND #$04
	BEQ ++    
	JSR ChangeAnimationFromStart_EndUD
	BRA +
++
    JSR ChangeAnimationFromStart_End
+
-
    RTS	
Finish:
	LDA !AnimationFrameIndex,x
	CMP #$05
	BCC -
	LDA !AnimationTimer,x
	BCC -

    LDA !ExtraBits,x
	AND #$04
	BEQ ++    
	JSR ChangeAnimationFromStart_MoveUD
	BRA +
++
    JSR ChangeAnimationFromStart_Move
+
    STZ !1570,x
	STZ !1534,x 
	
    LDA !extra_byte_1,x
	CMP #$01
	BNE -
	
	LDA !157C,x
	EOR #$01
	STA !157C,x
    RTS
Bounce:	
	LDA !AnimationFrameIndex,x
	CMP #$04
	BCC -
	LDA !AnimationTimer,x
	BCC - 	

	LDA !1510,x
	BEQ +
	
	LDA $15					
	AND #$80				
	BNE Kill				
+	
	JSR ChangeAnimationFromStart_Move
	
    STZ !1570,x
	STZ !1534,x   
    RTS
Kill:
    JSR ChangeAnimationFromStart_Rise
    LDA #$01
    STA !1534,x 
	LDA #!GrowSFXNum
	STA !SFXBank|!addr
    RTS
Ouch:
	LDA !AnimationFrameIndex,x
	CMP #$05
	BCC +
	LDA !AnimationTimer,x
	BCC +
    JSR ChangeAnimationFromStart_End
	RTS
Bonked:    
	LDA !AnimationFrameIndex,x
	CMP #$05
	BCC +
	LDA !AnimationTimer,x
	BCC +
	
    STZ !1510,x
    STZ !1570,x
	STZ !1534,x  

	JSR ChangeAnimationFromStart_Move
    RTS
No:
    LDA !AnimationIndex,x
	CMP #$06
	BEQ Bonked

	LDA !AnimationFrameIndex,x
	CMP #$05
	BCC +
	LDA !AnimationTimer,x
	BCC +
	
	JSR ChangeAnimationFromStart_End
    RTS
Smush:
    LDA !1534,x  
	CMP #$01
	BEQ No
	
    STZ !B6,x
	
    LDA !AnimationIndex,x
	CMP #$02
	BEQ Ouch	
	CMP #$08
	BEQ Bounce
	
	LDA !AnimationFrameIndex,x
	CMP #$05
	BCC +
	LDA !AnimationTimer,x
	BCC +
	JSR ChangeAnimationFromStart_Bounce
+
    RTS
Move:
	JSL $01802A|!BankB
	
    STZ !AA,x
	
    LDA !1588,x
	AND #$03
	BEQ +
	
	LDA !157C,x
	EOR #$01
	STA !157C,x 	
+	
    LDY !157C,x
	LDA Xspeed,y
	STA !B6,x
	
	LDA.w !1588,X
	AND.b #$04
	BNE .onGround

.inAir
    LDA !ExtraBits,x
	AND #$04
	BNE +
	
	LDA.w !151C,X		;
	BNE +			;|
	LDA !157C,x
	EOR #$01
	STA !157C,x 	
	LDA.b #$01		;|
	STA.w !151C,X		;/
    +
	RTS

.onGround
	LDA.w !1588,X		;\ 
	BMI .onL2orSlope	;|
	LDA.w !15B8,X		;|
	BEQ .onFlat		;| optimized from $019A04
.onL2orSlope		;| set y speed accordingly
	LDA.b #$18		;|
.onFlat			;|
	STA !AA,X		;/
	STZ.w !151C,X		; not walking off a ledge anymore
	RTS
;Don't Delete or write another >Section Graphics or >End Section
;All code between >Section Graphics and >End Graphics Section will be changed by Dyzen : Sprite Maker
;>Section Graphics
;######################################
;########## Graphics Space ############
;######################################

;This space is for routines used for graphics
;if you don't know enough about asm then
;don't edit them.

;>Routine: GraphicRoutine
;>Description: Updates tiles on the oam map
;results will be visible the next frame.
;>RoutineLength: Short
GraphicRoutine:

    %GetDrawInfo()                     ;Calls GetDrawInfo to get the free slot and the XDisp and YDisp

    STZ !Scratch3                       ;$02 = Free Slot but in 16bits
    STY !Scratch2


    STZ !Scratch5
    LDA !157C,x   
    EOR !LocalFlip,x
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
;>EndRoutine

;All words that starts with '@' and finish with '.' will be replaced by Dyzen

;>Table: FramesLengths
;>Description: How many tiles use each frame.
;>ValuesSize: 16
FramesLength:
    dw $0001,$0001,$0001,$0003,$0007,$0005,$0005,$0009,$0005,$0005,$0005,$0005,$0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0003,$0007,$0005,$0005,$0009,$0005,$0005,$0005,$0005,$0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0003,$0007,$0005,$0005,$0009,$0005,$0005,$0005,$0005,$0001,$0001,$0001,$0001
	dw $0001,$0001,$0001,$0003,$0007,$0005,$0005,$0009,$0005,$0005,$0005,$0005,$0001,$0001,$0001,$0001
;>EndTable


;>Table: FramesFlippers
;>Description: Values used to add values to FramesStartPosition and FramesEndPosition
;To use a flipped version of the frames.
;>ValuesSize: 16
FramesFlippers:
    dw $0000,$0020,$0040,$0060
;>EndTable


;>Table: FramesStartPosition
;>Description: Indicates the index where starts each frame
;>ValuesSize: 16
FramesStartPosition:
    dw $0001,$0003,$0005,$0009,$0011,$0017,$001D,$0027,$002D,$0033,$0039,$003F,$0041,$0043,$0045,$0047
	dw $0049,$004B,$004D,$0051,$0059,$005F,$0065,$006F,$0075,$007B,$0081,$0087,$0089,$008B,$008D,$008F
	dw $0091,$0093,$0095,$0099,$00A1,$00A7,$00AD,$00B7,$00BD,$00C3,$00C9,$00CF,$00D1,$00D3,$00D5,$00D7
	dw $00D9,$00DB,$00DD,$00E1,$00E9,$00EF,$00F5,$00FF,$0105,$010B,$0111,$0117,$0119,$011B,$011D,$011F
;>EndTable

;>Table: FramesEndPosition
;>Description: Indicates the index where end each frame
;>ValuesSize: 16
FramesEndPosition:
    dw $0000,$0002,$0004,$0006,$000A,$0012,$0018,$001E,$0028,$002E,$0034,$003A,$0040,$0042,$0044,$0046
	dw $0048,$004A,$004C,$004E,$0052,$005A,$0060,$0066,$0070,$0076,$007C,$0082,$0088,$008A,$008C,$008E
	dw $0090,$0092,$0094,$0096,$009A,$00A2,$00A8,$00AE,$00B8,$00BE,$00C4,$00CA,$00D0,$00D2,$00D4,$00D6
	dw $00D8,$00DA,$00DC,$00DE,$00E2,$00EA,$00F0,$00F6,$0100,$0106,$010C,$0112,$0118,$011A,$011C,$011E
;>EndTable


;>Table: Tiles
;>Description: Tiles codes of each tile of each frame
;>ValuesSize: 8
Tiles:
    
Frame0_Frame0_Tiles:
	db $E0,$E1
Frame1_Frame1_Tiles:
	db $E3,$E4
Frame2_Frame2_Tiles:
	db $E6,$E7
Frame3_Frame3_Tiles:
	db $EC,$E0,$E1,$A8
Frame4_Frame4_Tiles:
	db $AA,$AB,$E9,$EC,$ED,$FC,$A8,$EA
Frame5_Frame5_Tiles:
	db $AA,$AB,$EC,$A8,$E9,$EA
Frame6_Frame6_Tiles:
	db $AA,$AB,$EC,$A8,$E9,$EA
Frame7_Frame7_Tiles:
	db $EC,$A8,$E9,$EA,$AD,$AE,$AF,$BD,$BE,$BF
Frame8_Frame8_Tiles:
	db $88,$89,$E9,$EA,$EC,$A8
Frame9_Frame9_Tiles:
	db $88,$89,$E9,$EA,$EE,$A8
Frame10_Frame10_Tiles:
	db $88,$89,$E9,$EA,$EC,$EC
Frame11_Frame11_Tiles:
	db $88,$89,$E9,$EA,$A8,$EE
Frame12_Frame12_Tiles:
	db $8B,$8B
Frame13_Frame13_Tiles:
	db $8B,$8B
Frame14_Frame14_Tiles:
	db $8D,$8D
Frame15_Frame15_Tiles:
	db $8D,$8D
Frame0_Frame0_TilesFlipX:
	db $E0,$E1
Frame1_Frame1_TilesFlipX:
	db $E3,$E4
Frame2_Frame2_TilesFlipX:
	db $E6,$E7
Frame3_Frame3_TilesFlipX:
	db $EC,$E0,$E1,$A8
Frame4_Frame4_TilesFlipX:
	db $AA,$AB,$E9,$EC,$ED,$FC,$A8,$EA
Frame5_Frame5_TilesFlipX:
	db $AA,$AB,$EC,$A8,$E9,$EA
Frame6_Frame6_TilesFlipX:
	db $AA,$AB,$EC,$A8,$E9,$EA
Frame7_Frame7_TilesFlipX:
	db $EC,$A8,$E9,$EA,$AD,$AE,$AF,$BD,$BE,$BF
Frame8_Frame8_TilesFlipX:
	db $88,$89,$E9,$EA,$EC,$A8
Frame9_Frame9_TilesFlipX:
	db $88,$89,$E9,$EA,$EE,$A8
Frame10_Frame10_TilesFlipX:
	db $88,$89,$E9,$EA,$EC,$EC
Frame11_Frame11_TilesFlipX:
	db $88,$89,$E9,$EA,$A8,$EE
Frame12_Frame12_TilesFlipX:
	db $8B,$8B
Frame13_Frame13_TilesFlipX:
	db $8B,$8B
Frame14_Frame14_TilesFlipX:
	db $8D,$8D
Frame15_Frame15_TilesFlipX:
	db $8D,$8D
Frame0_Frame0_TilesFlipY:
	db $E0,$E1
Frame1_Frame1_TilesFlipY:
	db $E3,$E4
Frame2_Frame2_TilesFlipY:
	db $E6,$E7
Frame3_Frame3_TilesFlipY:
	db $EC,$E0,$E1,$A8
Frame4_Frame4_TilesFlipY:
	db $AA,$AB,$E9,$EC,$ED,$FC,$A8,$EA
Frame5_Frame5_TilesFlipY:
	db $AA,$AB,$EC,$A8,$E9,$EA
Frame6_Frame6_TilesFlipY:
	db $AA,$AB,$EC,$A8,$E9,$EA
Frame7_Frame7_TilesFlipY:
	db $EC,$A8,$E9,$EA,$AD,$AE,$AF,$BD,$BE,$BF
Frame8_Frame8_TilesFlipY:
	db $88,$89,$E9,$EA,$EC,$A8
Frame9_Frame9_TilesFlipY:
	db $88,$89,$E9,$EA,$EE,$A8
Frame10_Frame10_TilesFlipY:
	db $88,$89,$E9,$EA,$EC,$EC
Frame11_Frame11_TilesFlipY:
	db $88,$89,$E9,$EA,$A8,$EE
Frame12_Frame12_TilesFlipY:
	db $8B,$8B
Frame13_Frame13_TilesFlipY:
	db $8B,$8B
Frame14_Frame14_TilesFlipY:
	db $8D,$8D
Frame15_Frame15_TilesFlipY:
	db $8D,$8D
Frame0_Frame0_TilesFlipXY:
	db $E0,$E1
Frame1_Frame1_TilesFlipXY:
	db $E3,$E4
Frame2_Frame2_TilesFlipXY:
	db $E6,$E7
Frame3_Frame3_TilesFlipXY:
	db $EC,$E0,$E1,$A8
Frame4_Frame4_TilesFlipXY:
	db $AA,$AB,$E9,$EC,$ED,$FC,$A8,$EA
Frame5_Frame5_TilesFlipXY:
	db $AA,$AB,$EC,$A8,$E9,$EA
Frame6_Frame6_TilesFlipXY:
	db $AA,$AB,$EC,$A8,$E9,$EA
Frame7_Frame7_TilesFlipXY:
	db $EC,$A8,$E9,$EA,$AD,$AE,$AF,$BD,$BE,$BF
Frame8_Frame8_TilesFlipXY:
	db $88,$89,$E9,$EA,$EC,$A8
Frame9_Frame9_TilesFlipXY:
	db $88,$89,$E9,$EA,$EE,$A8
Frame10_Frame10_TilesFlipXY:
	db $88,$89,$E9,$EA,$EC,$EC
Frame11_Frame11_TilesFlipXY:
	db $88,$89,$E9,$EA,$A8,$EE
Frame12_Frame12_TilesFlipXY:
	db $8B,$8B
Frame13_Frame13_TilesFlipXY:
	db $8B,$8B
Frame14_Frame14_TilesFlipXY:
	db $8D,$8D
Frame15_Frame15_TilesFlipXY:
	db $8D,$8D
;>EndTable


;>Table: Properties
;>Description: Properties of each tile of each frame
;>ValuesSize: 8
Properties:
    
Frame0_Frame0_Properties:
	db $23,$23
Frame1_Frame1_Properties:
	db $23,$23
Frame2_Frame2_Properties:
	db $23,$23
Frame3_Frame3_Properties:
	db $23,$23,$23,$23
Frame4_Frame4_Properties:
	db $23,$23,$23,$23,$23,$23,$23,$23
Frame5_Frame5_Properties:
	db $23,$23,$23,$23,$23,$23
Frame6_Frame6_Properties:
	db $23,$23,$23,$23,$23,$23
Frame7_Frame7_Properties:
	db $23,$23,$23,$23,$23,$23,$23,$23,$23,$23
Frame8_Frame8_Properties:
	db $23,$23,$23,$23,$23,$23
Frame9_Frame9_Properties:
	db $23,$23,$23,$23,$23,$23
Frame10_Frame10_Properties:
	db $23,$23,$23,$23,$23,$23
Frame11_Frame11_Properties:
	db $23,$23,$23,$23,$23,$23
Frame12_Frame12_Properties:
	db $63,$23
Frame13_Frame13_Properties:
	db $23,$63
Frame14_Frame14_Properties:
	db $23,$63
Frame15_Frame15_Properties:
	db $23,$63
Frame0_Frame0_PropertiesFlipX:
	db $63,$63
Frame1_Frame1_PropertiesFlipX:
	db $63,$63
Frame2_Frame2_PropertiesFlipX:
	db $63,$63
Frame3_Frame3_PropertiesFlipX:
	db $63,$63,$63,$63
Frame4_Frame4_PropertiesFlipX:
	db $63,$63,$63,$63,$63,$63,$63,$63
Frame5_Frame5_PropertiesFlipX:
	db $63,$63,$63,$63,$63,$63
Frame6_Frame6_PropertiesFlipX:
	db $63,$63,$63,$63,$63,$63
Frame7_Frame7_PropertiesFlipX:
	db $63,$63,$63,$63,$63,$63,$63,$63,$63,$63
Frame8_Frame8_PropertiesFlipX:
	db $63,$63,$63,$63,$63,$63
Frame9_Frame9_PropertiesFlipX:
	db $63,$63,$63,$63,$63,$63
Frame10_Frame10_PropertiesFlipX:
	db $63,$63,$63,$63,$63,$63
Frame11_Frame11_PropertiesFlipX:
	db $63,$63,$63,$63,$63,$63
Frame12_Frame12_PropertiesFlipX:
	db $23,$63
Frame13_Frame13_PropertiesFlipX:
	db $63,$23
Frame14_Frame14_PropertiesFlipX:
	db $63,$23
Frame15_Frame15_PropertiesFlipX:
	db $63,$23
Frame0_Frame0_PropertiesFlipY:
	db $A3,$A3
Frame1_Frame1_PropertiesFlipY:
	db $A3,$A3
Frame2_Frame2_PropertiesFlipY:
	db $A3,$A3
Frame3_Frame3_PropertiesFlipY:
	db $A3,$A3,$A3,$A3
Frame4_Frame4_PropertiesFlipY:
	db $A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3
Frame5_Frame5_PropertiesFlipY:
	db $A3,$A3,$A3,$A3,$A3,$A3
Frame6_Frame6_PropertiesFlipY:
	db $A3,$A3,$A3,$A3,$A3,$A3
Frame7_Frame7_PropertiesFlipY:
	db $A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3,$A3
Frame8_Frame8_PropertiesFlipY:
	db $A3,$A3,$A3,$A3,$A3,$A3
Frame9_Frame9_PropertiesFlipY:
	db $A3,$A3,$A3,$A3,$A3,$A3
Frame10_Frame10_PropertiesFlipY:
	db $A3,$A3,$A3,$A3,$A3,$A3
Frame11_Frame11_PropertiesFlipY:
	db $A3,$A3,$A3,$A3,$A3,$A3
Frame12_Frame12_PropertiesFlipY:
	db $E3,$A3
Frame13_Frame13_PropertiesFlipY:
	db $A3,$E3
Frame14_Frame14_PropertiesFlipY:
	db $A3,$E3
Frame15_Frame15_PropertiesFlipY:
	db $A3,$E3
Frame0_Frame0_PropertiesFlipXY:
	db $E3,$E3
Frame1_Frame1_PropertiesFlipXY:
	db $E3,$E3
Frame2_Frame2_PropertiesFlipXY:
	db $E3,$E3
Frame3_Frame3_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3
Frame4_Frame4_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3
Frame5_Frame5_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3,$E3,$E3
Frame6_Frame6_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3,$E3,$E3
Frame7_Frame7_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3,$E3
Frame8_Frame8_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3,$E3,$E3
Frame9_Frame9_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3,$E3,$E3
Frame10_Frame10_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3,$E3,$E3
Frame11_Frame11_PropertiesFlipXY:
	db $E3,$E3,$E3,$E3,$E3,$E3
Frame12_Frame12_PropertiesFlipXY:
	db $A3,$E3
Frame13_Frame13_PropertiesFlipXY:
	db $E3,$A3
Frame14_Frame14_PropertiesFlipXY:
	db $E3,$A3
Frame15_Frame15_PropertiesFlipXY:
	db $E3,$A3
;>EndTable
;>Table: XDisplacements
;>Description: X Displacement of each tile of each frame
;>ValuesSize: 8
XDisplacements:
    
Frame0_Frame0_XDisp:
	db $FC,$04
Frame1_Frame1_XDisp:
	db $FC,$04
Frame2_Frame2_XDisp:
	db $FC,$04
Frame3_Frame3_XDisp:
	db $F8,$FC,$04,$02
Frame4_Frame4_XDisp:
	db $FC,$04,$FC,$FA,$02,$FA,$04,$04
Frame5_Frame5_XDisp:
	db $FC,$04,$FA,$04,$FC,$04
Frame6_Frame6_XDisp:
	db $FC,$04,$FA,$04,$FC,$04
Frame7_Frame7_XDisp:
	db $FA,$04,$FC,$04,$FC,$04,$0C,$FC,$04,$0C
Frame8_Frame8_XDisp:
	db $FC,$04,$FC,$04,$FA,$04
Frame9_Frame9_XDisp:
	db $FC,$04,$FC,$04,$FA,$04
Frame10_Frame10_XDisp:
	db $FC,$04,$FC,$04,$FA,$04
Frame11_Frame11_XDisp:
	db $FC,$04,$FC,$04,$FA,$04
Frame12_Frame12_XDisp:
	db $04,$FC
Frame13_Frame13_XDisp:
	db $F8,$08
Frame14_Frame14_XDisp:
	db $F8,$08
Frame15_Frame15_XDisp:
	db $FA,$06
Frame0_Frame0_XDispFlipX:
	db $04,$FC
Frame1_Frame1_XDispFlipX:
	db $04,$FC
Frame2_Frame2_XDispFlipX:
	db $04,$FC
Frame3_Frame3_XDispFlipX:
	db $08,$04,$FC,$FE
Frame4_Frame4_XDispFlipX:
	db $04,$FC,$04,$0E,$06,$0E,$FC,$FC
Frame5_Frame5_XDispFlipX:
	db $04,$FC,$06,$FC,$04,$FC
Frame6_Frame6_XDispFlipX:
	db $04,$FC,$06,$FC,$04,$FC
Frame7_Frame7_XDispFlipX:
	db $06,$FC,$04,$FC,$0C,$04,$FC,$0C,$04,$FC
Frame8_Frame8_XDispFlipX:
	db $04,$FC,$04,$FC,$06,$FC
Frame9_Frame9_XDispFlipX:
	db $04,$FC,$04,$FC,$06,$FC
Frame10_Frame10_XDispFlipX:
	db $04,$FC,$04,$FC,$06,$FC
Frame11_Frame11_XDispFlipX:
	db $04,$FC,$04,$FC,$06,$FC
Frame12_Frame12_XDispFlipX:
	db $FC,$04
Frame13_Frame13_XDispFlipX:
	db $08,$F8
Frame14_Frame14_XDispFlipX:
	db $08,$F8
Frame15_Frame15_XDispFlipX:
	db $06,$FA
Frame0_Frame0_XDispFlipY:
	db $FC,$04
Frame1_Frame1_XDispFlipY:
	db $FC,$04
Frame2_Frame2_XDispFlipY:
	db $FC,$04
Frame3_Frame3_XDispFlipY:
	db $F8,$FC,$04,$02
Frame4_Frame4_XDispFlipY:
	db $FC,$04,$FC,$FA,$02,$FA,$04,$04
Frame5_Frame5_XDispFlipY:
	db $FC,$04,$FA,$04,$FC,$04
Frame6_Frame6_XDispFlipY:
	db $FC,$04,$FA,$04,$FC,$04
Frame7_Frame7_XDispFlipY:
	db $FA,$04,$FC,$04,$FC,$04,$0C,$FC,$04,$0C
Frame8_Frame8_XDispFlipY:
	db $FC,$04,$FC,$04,$FA,$04
Frame9_Frame9_XDispFlipY:
	db $FC,$04,$FC,$04,$FA,$04
Frame10_Frame10_XDispFlipY:
	db $FC,$04,$FC,$04,$FA,$04
Frame11_Frame11_XDispFlipY:
	db $FC,$04,$FC,$04,$FA,$04
Frame12_Frame12_XDispFlipY:
	db $04,$FC
Frame13_Frame13_XDispFlipY:
	db $F8,$08
Frame14_Frame14_XDispFlipY:
	db $F8,$08
Frame15_Frame15_XDispFlipY:
	db $FA,$06
Frame0_Frame0_XDispFlipXY:
	db $04,$FC
Frame1_Frame1_XDispFlipXY:
	db $04,$FC
Frame2_Frame2_XDispFlipXY:
	db $04,$FC
Frame3_Frame3_XDispFlipXY:
	db $08,$04,$FC,$FE
Frame4_Frame4_XDispFlipXY:
	db $04,$FC,$04,$0E,$06,$0E,$FC,$FC
Frame5_Frame5_XDispFlipXY:
	db $04,$FC,$06,$FC,$04,$FC
Frame6_Frame6_XDispFlipXY:
	db $04,$FC,$06,$FC,$04,$FC
Frame7_Frame7_XDispFlipXY:
	db $06,$FC,$04,$FC,$0C,$04,$FC,$0C,$04,$FC
Frame8_Frame8_XDispFlipXY:
	db $04,$FC,$04,$FC,$06,$FC
Frame9_Frame9_XDispFlipXY:
	db $04,$FC,$04,$FC,$06,$FC
Frame10_Frame10_XDispFlipXY:
	db $04,$FC,$04,$FC,$06,$FC
Frame11_Frame11_XDispFlipXY:
	db $04,$FC,$04,$FC,$06,$FC
Frame12_Frame12_XDispFlipXY:
	db $FC,$04
Frame13_Frame13_XDispFlipXY:
	db $08,$F8
Frame14_Frame14_XDispFlipXY:
	db $08,$F8
Frame15_Frame15_XDispFlipXY:
	db $06,$FA
;>EndTable
;>Table: YDisplacements
;>Description: Y Displacement of each tile of each frame
;>ValuesSize: 8
YDisplacements:
    
Frame0_Frame0_YDisp:
	db $FF,$FF
Frame1_Frame1_YDisp:
	db $FF,$FF
Frame2_Frame2_YDisp:
	db $FF,$FF
Frame3_Frame3_YDisp:
	db $F6,$FF,$FF,$F6
Frame4_Frame4_YDisp:
	db $FF,$FF,$F7,$EF,$EF,$F7,$EF,$F7
Frame5_Frame5_YDisp:
	db $FF,$FF,$E9,$E9,$F3,$F3
Frame6_Frame6_YDisp:
	db $FF,$FF,$E5,$E5,$F1,$F1
Frame7_Frame7_YDisp:
	db $E2,$E2,$F0,$F0,$FF,$FF,$FF,$07,$07,$07
Frame8_Frame8_YDisp:
	db $FF,$FF,$EF,$EF,$DF,$DF
Frame9_Frame9_YDisp:
	db $FF,$FF,$EF,$EF,$DF,$DF
Frame10_Frame10_YDisp:
	db $FF,$FF,$EF,$EF,$DF,$DF
Frame11_Frame11_YDisp:
	db $FF,$FF,$EF,$EF,$DF,$DF
Frame12_Frame12_YDisp:
	db $FF,$FF
Frame13_Frame13_YDisp:
	db $FF,$FF
Frame14_Frame14_YDisp:
	db $FF,$FF
Frame15_Frame15_YDisp:
	db $FF,$FF
Frame0_Frame0_YDispFlipX:
	db $FF,$FF
Frame1_Frame1_YDispFlipX:
	db $FF,$FF
Frame2_Frame2_YDispFlipX:
	db $FF,$FF
Frame3_Frame3_YDispFlipX:
	db $F6,$FF,$FF,$F6
Frame4_Frame4_YDispFlipX:
	db $FF,$FF,$F7,$EF,$EF,$F7,$EF,$F7
Frame5_Frame5_YDispFlipX:
	db $FF,$FF,$E9,$E9,$F3,$F3
Frame6_Frame6_YDispFlipX:
	db $FF,$FF,$E5,$E5,$F1,$F1
Frame7_Frame7_YDispFlipX:
	db $E2,$E2,$F0,$F0,$FF,$FF,$FF,$07,$07,$07
Frame8_Frame8_YDispFlipX:
	db $FF,$FF,$EF,$EF,$DF,$DF
Frame9_Frame9_YDispFlipX:
	db $FF,$FF,$EF,$EF,$DF,$DF
Frame10_Frame10_YDispFlipX:
	db $FF,$FF,$EF,$EF,$DF,$DF
Frame11_Frame11_YDispFlipX:
	db $FF,$FF,$EF,$EF,$DF,$DF
Frame12_Frame12_YDispFlipX:
	db $FF,$FF
Frame13_Frame13_YDispFlipX:
	db $FF,$FF
Frame14_Frame14_YDispFlipX:
	db $FF,$FF
Frame15_Frame15_YDispFlipX:
	db $FF,$FF
Frame0_Frame0_YDispFlipY:
	db $FF,$FF
Frame1_Frame1_YDispFlipY:
	db $FF,$FF
Frame2_Frame2_YDispFlipY:
	db $FF,$FF
Frame3_Frame3_YDispFlipY:
	db $08,$FF,$FF,$08
Frame4_Frame4_YDispFlipY:
	db $FF,$FF,$07,$17,$17,$0F,$0F,$07
Frame5_Frame5_YDispFlipY:
	db $FF,$FF,$15,$15,$0B,$0B
Frame6_Frame6_YDispFlipY:
	db $FF,$FF,$19,$19,$0D,$0D
Frame7_Frame7_YDispFlipY:
	db $1C,$1C,$0E,$0E,$07,$07,$07,$FF,$FF,$FF
Frame8_Frame8_YDispFlipY:
	db $FF,$FF,$0F,$0F,$1F,$1F
Frame9_Frame9_YDispFlipY:
	db $FF,$FF,$0F,$0F,$1F,$1F
Frame10_Frame10_YDispFlipY:
	db $FF,$FF,$0F,$0F,$1F,$1F
Frame11_Frame11_YDispFlipY:
	db $FF,$FF,$0F,$0F,$1F,$1F
Frame12_Frame12_YDispFlipY:
	db $FF,$FF
Frame13_Frame13_YDispFlipY:
	db $FF,$FF
Frame14_Frame14_YDispFlipY:
	db $FF,$FF
Frame15_Frame15_YDispFlipY:
	db $FF,$FF
Frame0_Frame0_YDispFlipXY:
	db $FF,$FF
Frame1_Frame1_YDispFlipXY:
	db $FF,$FF
Frame2_Frame2_YDispFlipXY:
	db $FF,$FF
Frame3_Frame3_YDispFlipXY:
	db $08,$FF,$FF,$08
Frame4_Frame4_YDispFlipXY:
	db $FF,$FF,$07,$17,$17,$0F,$0F,$07
Frame5_Frame5_YDispFlipXY:
	db $FF,$FF,$15,$15,$0B,$0B
Frame6_Frame6_YDispFlipXY:
	db $FF,$FF,$19,$19,$0D,$0D
Frame7_Frame7_YDispFlipXY:
	db $1C,$1C,$0E,$0E,$07,$07,$07,$FF,$FF,$FF
Frame8_Frame8_YDispFlipXY:
	db $FF,$FF,$0F,$0F,$1F,$1F
Frame9_Frame9_YDispFlipXY:
	db $FF,$FF,$0F,$0F,$1F,$1F
Frame10_Frame10_YDispFlipXY:
	db $FF,$FF,$0F,$0F,$1F,$1F
Frame11_Frame11_YDispFlipXY:
	db $FF,$FF,$0F,$0F,$1F,$1F
Frame12_Frame12_YDispFlipXY:
	db $FF,$FF
Frame13_Frame13_YDispFlipXY:
	db $FF,$FF
Frame14_Frame14_YDispFlipXY:
	db $FF,$FF
Frame15_Frame15_YDispFlipXY:
	db $FF,$FF
;>EndTable
;>Table: Sizes.
;>Description: size of each tile of each frame
;>ValuesSize: 8
Sizes:
    
Frame0_Frame0_Sizes:
	db $02,$02
Frame1_Frame1_Sizes:
	db $02,$02
Frame2_Frame2_Sizes:
	db $02,$02
Frame3_Frame3_Sizes:
	db $02,$02,$02,$02
Frame4_Frame4_Sizes:
	db $02,$02,$02,$00,$00,$00,$02,$02
Frame5_Frame5_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame6_Frame6_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame7_Frame7_Sizes:
	db $02,$02,$02,$02,$00,$00,$00,$00,$00,$00
Frame8_Frame8_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame9_Frame9_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame10_Frame10_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame11_Frame11_Sizes:
	db $02,$02,$02,$02,$02,$02
Frame12_Frame12_Sizes:
	db $02,$02
Frame13_Frame13_Sizes:
	db $02,$02
Frame14_Frame14_Sizes:
	db $02,$02
Frame15_Frame15_Sizes:
	db $02,$02
Frame0_Frame0_SizesFlipX:
	db $02,$02
Frame1_Frame1_SizesFlipX:
	db $02,$02
Frame2_Frame2_SizesFlipX:
	db $02,$02
Frame3_Frame3_SizesFlipX:
	db $02,$02,$02,$02
Frame4_Frame4_SizesFlipX:
	db $02,$02,$02,$00,$00,$00,$02,$02
Frame5_Frame5_SizesFlipX:
	db $02,$02,$02,$02,$02,$02
Frame6_Frame6_SizesFlipX:
	db $02,$02,$02,$02,$02,$02
Frame7_Frame7_SizesFlipX:
	db $02,$02,$02,$02,$00,$00,$00,$00,$00,$00
Frame8_Frame8_SizesFlipX:
	db $02,$02,$02,$02,$02,$02
Frame9_Frame9_SizesFlipX:
	db $02,$02,$02,$02,$02,$02
Frame10_Frame10_SizesFlipX:
	db $02,$02,$02,$02,$02,$02
Frame11_Frame11_SizesFlipX:
	db $02,$02,$02,$02,$02,$02
Frame12_Frame12_SizesFlipX:
	db $02,$02
Frame13_Frame13_SizesFlipX:
	db $02,$02
Frame14_Frame14_SizesFlipX:
	db $02,$02
Frame15_Frame15_SizesFlipX:
	db $02,$02
Frame0_Frame0_SizesFlipY:
	db $02,$02
Frame1_Frame1_SizesFlipY:
	db $02,$02
Frame2_Frame2_SizesFlipY:
	db $02,$02
Frame3_Frame3_SizesFlipY:
	db $02,$02,$02,$02
Frame4_Frame4_SizesFlipY:
	db $02,$02,$02,$00,$00,$00,$02,$02
Frame5_Frame5_SizesFlipY:
	db $02,$02,$02,$02,$02,$02
Frame6_Frame6_SizesFlipY:
	db $02,$02,$02,$02,$02,$02
Frame7_Frame7_SizesFlipY:
	db $02,$02,$02,$02,$00,$00,$00,$00,$00,$00
Frame8_Frame8_SizesFlipY:
	db $02,$02,$02,$02,$02,$02
Frame9_Frame9_SizesFlipY:
	db $02,$02,$02,$02,$02,$02
Frame10_Frame10_SizesFlipY:
	db $02,$02,$02,$02,$02,$02
Frame11_Frame11_SizesFlipY:
	db $02,$02,$02,$02,$02,$02
Frame12_Frame12_SizesFlipY:
	db $02,$02
Frame13_Frame13_SizesFlipY:
	db $02,$02
Frame14_Frame14_SizesFlipY:
	db $02,$02
Frame15_Frame15_SizesFlipY:
	db $02,$02
Frame0_Frame0_SizesFlipXY:
	db $02,$02
Frame1_Frame1_SizesFlipXY:
	db $02,$02
Frame2_Frame2_SizesFlipXY:
	db $02,$02
Frame3_Frame3_SizesFlipXY:
	db $02,$02,$02,$02
Frame4_Frame4_SizesFlipXY:
	db $02,$02,$02,$00,$00,$00,$02,$02
Frame5_Frame5_SizesFlipXY:
	db $02,$02,$02,$02,$02,$02
Frame6_Frame6_SizesFlipXY:
	db $02,$02,$02,$02,$02,$02
Frame7_Frame7_SizesFlipXY:
	db $02,$02,$02,$02,$00,$00,$00,$00,$00,$00
Frame8_Frame8_SizesFlipXY:
	db $02,$02,$02,$02,$02,$02
Frame9_Frame9_SizesFlipXY:
	db $02,$02,$02,$02,$02,$02
Frame10_Frame10_SizesFlipXY:
	db $02,$02,$02,$02,$02,$02
Frame11_Frame11_SizesFlipXY:
	db $02,$02,$02,$02,$02,$02
Frame12_Frame12_SizesFlipXY:
	db $02,$02
Frame13_Frame13_SizesFlipXY:
	db $02,$02
Frame14_Frame14_SizesFlipXY:
	db $02,$02
Frame15_Frame15_SizesFlipXY:
	db $02,$02
;>EndTable

;>End Graphics Section

;Don't Delete or write another >Section Animation or >End Section
;All code between >Section Animations and >End Animations Section will be changed by Dyzen : Sprite Maker
;>Section Animations
;######################################
;########## Animation Space ###########
;######################################

;This space is for routines used for graphics
;if you don't know enough about asm then
;don't edit them.
InitWrapperChangeAnimationFromStart:
	PHB
    PHK
    PLB
	STZ !AnimationIndex,x
	JSR ChangeAnimationFromStart
	PLB
	RTL

ChangeAnimationFromStart_Move:
	STZ !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_MoveUD:
	LDA #$01
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_Rise:
	LDA #$02
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_RiseUD:
	LDA #$03
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_Attack:
	LDA #$04
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_AttackUD:
	LDA #$05
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_End:
	LDA #$06
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_EndUD:
	LDA #$07
	STA !AnimationIndex,x
	JMP ChangeAnimationFromStart
ChangeAnimationFromStart_Bounce:
	LDA #$08
	STA !AnimationIndex,x


ChangeAnimationFromStart:
	STZ !AnimationFrameIndex,x

	STZ !Scratch1
	LDA !AnimationIndex,x
	STA !Scratch0					;$00 = Animation index in 16 bits

	STZ !Scratch3
	LDA !AnimationFrameIndex,x
	STA !Scratch2					;$02 = Animation Frame index in 16 bits

	STZ !Scratch5
	STX !Scratch4					;$04 = sprite index in 16 bits

	REP #$30						;A7X/Y of 16 bits
	LDX !Scratch4					;X = sprite index in 16 bits

	LDA !Scratch0
	ASL
	TAY								;Y = 2*Animation index

	LDA !Scratch2
	CLC
	ADC AnimationIndexer,y
	TAY								;Y = Position of the first frame of the animation + animation frame index

	SEP #$20						;A of 8 bits

	LDA Frames,y
	STA !FrameIndex,x				;New Frame = Frames[New Animation Frame Index]

	LDA Times,y
	STA !AnimationTimer,x			;Time = Times[New Animation Frame Index]

	LDA Flips,y
	STA !LocalFlip,x				;Flip = Flips[New Animation Frame Index]

	LDA !Scratch2
	STA !AnimationFrameIndex,x

	SEP #$10						;X/Y of 8 bits
	LDX !Scratch4					;X = sprite index in 8 bits
RTS
	

;>Routine: AnimationRoutine
;>Description: Decides what will be the next frame.
;>RoutineLength: Short
AnimationRoutine:
    LDA !AnimationTimer,x
    BEQ +

	RTS

+
	STZ !Scratch1
	LDA !AnimationIndex,x
	STA !Scratch0					;$00 = Animation index in 16 bits

	STZ !Scratch3
	LDA !AnimationFrameIndex,x
	STA !Scratch2					;$02 = Animation Frame index in 16 bits

	STZ !Scratch5
	STX !Scratch4					;$04 = sprite index in 16 bits

	REP #$30						;A7X/Y of 16 bits
	LDX !Scratch4					;X = sprite index in 16 bits

	LDA !Scratch0
	ASL
	TAY								;Y = 2*Animation index

	INC !Scratch2					;New Animation Frame Index = Animation Frame Index + 1

	LDA !Scratch2			        ;if Animation Frame index < Animation Lenght then Animation Frame index++
	CMP AnimationLenght,y			;else go to the frame where start the loop.
	BCC +							

	LDA AnimationLastTransition,y
	STA !Scratch2					;New Animation Frame Index = first frame of the loop.

+
	LDA !Scratch2
	CLC
	ADC AnimationIndexer,y
	TAY								;Y = Position of the first frame of the animation + animation frame index

	SEP #$20						;A of 8 bits

	LDA Frames,y
	STA !FrameIndex,x				;New Frame = Frames[New Animation Frame Index]

	LDA Times,y
	STA !AnimationTimer,x			;Time = Times[New Animation Frame Index]

	LDA Flips,y
	STA !LocalFlip,x				;Flip = Flips[New Animation Frame Index]

	LDA !Scratch2
	STA !AnimationFrameIndex,x

	SEP #$10						;X/Y of 8 bits
	LDX !Scratch4					;X = sprite index in 8 bits
RTS
;>EndRoutine

;All words that starts with '>' and finish with '.' will be replaced by Dyzen

AnimationLenght:
	dw $0004,$0004,$0006,$0006,$0004,$0004,$0006,$0006,$0005

AnimationLastTransition:
	dw $0000,$0000,$0005,$0005,$0000,$0000,$0005,$0005,$0004

AnimationIndexer:
	dw $0000,$0004,$0008,$000E,$0014,$0018,$001C,$0022,$0028

Frames:
	
Animation0_Move_Frames:
	db $00,$01,$02,$01
Animation1_MoveUD_Frames:
	db $00,$01,$02,$01
Animation2_Rise_Frames:
	db $03,$04,$05,$06,$07,$08
Animation3_RiseUD_Frames:
	db $03,$04,$05,$06,$07,$08
Animation4_Attack_Frames:
	db $09,$0A,$0B,$0A
Animation5_AttackUD_Frames:
	db $09,$0A,$0B,$0A
Animation6_End_Frames:
	db $08,$07,$06,$05,$04,$03
Animation7_EndUD_Frames:
	db $08,$07,$06,$05,$04,$03
Animation8_Bounce_Frames:
	db $0C,$0D,$0E,$0F,$0D

Times:
	
Animation0_Move_Times:
	db $06,$07,$07,$0A
Animation1_MoveUD_Times:
	db $06,$07,$07,$0A
Animation2_Rise_Times:
	db $02,$02,$02,$02,$02,$04
Animation3_RiseUD_Times:
	db $02,$02,$02,$02,$02,$02
Animation4_Attack_Times:
	db $03,$03,$03,$03
Animation5_AttackUD_Times:
	db $03,$03,$03,$03
Animation6_End_Times:
	db $02,$02,$02,$02,$02,$02
Animation7_EndUD_Times:
	db $02,$02,$02,$02,$02,$02
Animation8_Bounce_Times:
	db $02,$02,$08,$04,$04

Flips:
	
Animation0_Move_Flips:
	db $00,$00,$00,$00
Animation1_MoveUD_Flips:
	db $02,$02,$02,$02
Animation2_Rise_Flips:
	db $00,$00,$00,$00,$00,$00
Animation3_RiseUD_Flips:
	db $02,$02,$02,$02,$02,$02
Animation4_Attack_Flips:
	db $00,$00,$00,$00
Animation5_AttackUD_Flips:
	db $02,$02,$02,$02
Animation6_End_Flips:
	db $00,$00,$00,$00,$00,$00
Animation7_EndUD_Flips:
	db $02,$02,$02,$02,$02,$02
Animation8_Bounce_Flips:
	db $00,$00,$00,$00,$00

;>End Animations Section

;Don't Delete or write another >Section Hitbox Interaction or >End Section
;All code between >Section Hitboxes Interaction and >End Hitboxes Interaction Section will be changed by Dyzen : Sprite Maker
;>Section Hitboxes Interaction
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
	LDA !ScratchF                   
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
	
    LDA !ExtraBits,x
	AND #$04
	BNE Hurt
	
    LDA !1570,x	
	CMP #$02
	BEQ +
					
	LDA $7D
	BMI Hurt
					
	CMP #$10
	BCC Hurt
					
	JSL $01AB99|!rom					
	JSL $01AA33|!rom	
					
    LDA #$06
	STA $1DF9|!addr				
	
	LDA $15					
	AND #$80				
	BNE Super	
	
	LDA #-$40
	STA $7D
	BRA Nope
Super:
    LDA #$01
	STA !1510,x
 	LDA #-$60
	STA $7D
Nope:					
	LDA #$02
	STA !1570,x		
	STZ !1534,x
					
	LDA !AnimationIndex,x
	BEQ Bonk
	JSR ChangeAnimationFromStart_End
	RTS
Bonk:
    JSR ChangeAnimationFromStart_Bounce
    RTS					
Hurt:
    JSL $00F5B7|!BankB							
+
	SEC
	RTS
ReturnNoContact2:
	CLC
	RTS

Interaction:
    STZ !ScratchE
	LDA !157C,x
    EOR !LocalFlip,x
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
	SEP #$20
	STA !Scratch4
	XBA
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
	SEP #$20
	STA !Scratch5
	XBA
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
    dw $0000,$0020,$0040,$0060

FrameHitboxesIndexer:
    dw $0000,$0002,$0004,$0006,$0008,$000A,$000C,$000E,$0010,$0012,$0014,$0016,$0018,$0019,$001A,$001B
	dw $001C,$001E,$0020,$0022,$0024,$0026,$0028,$002A,$002C,$002E,$0030,$0032,$0034,$0035,$0036,$0037
	dw $0038,$003A,$003C,$003E,$0040,$0042,$0044,$0046,$0048,$004A,$004C,$004E,$0050,$0051,$0052,$0053
	dw $0054,$0056,$0058,$005A,$005C,$005E,$0060,$0062,$0064,$0066,$0068,$006A,$006C,$006D,$006E,$006F

FrameHitBoxes:
    db $00,$FF
	db $00,$FF
	db $00,$FF
	db $00,$FF
	db $01,$FF
	db $01,$FF
	db $02,$FF
	db $02,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $03,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	
	db $04,$FF
	db $04,$FF
	db $04,$FF
	db $04,$FF
	db $05,$FF
	db $05,$FF
	db $06,$FF
	db $06,$FF
	db $07,$FF
	db $07,$FF
	db $07,$FF
	db $07,$FF
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
	db $0A,$FF
	db $0A,$FF
	db $0B,$FF
	db $0B,$FF
	db $0B,$FF
	db $0B,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	
	db $0C,$FF
	db $0C,$FF
	db $0C,$FF
	db $0C,$FF
	db $0D,$FF
	db $0D,$FF
	db $0E,$FF
	db $0E,$FF
	db $0F,$FF
	db $0F,$FF
	db $0F,$FF
	db $0F,$FF
	db $FF
	db $FF
	db $FF
	db $FF
	

HitboxesStart:
    dw $0000,$0006,$000C,$0012,$0018,$001E,$0024,$002A,$0030,$0036,$003C,$0042,$0048,$004E,$0054,$005A

Hitboxes:
    db $01,$00,$00,$10,$10,$00
	db $01,$00,$F0,$10,$20,$00
	db $01,$00,$E8,$10,$28,$00
	db $01,$00,$E0,$10,$30,$00
	db $01,$00,$00,$10,$10,$00
	db $01,$00,$F0,$10,$20,$00
	db $01,$00,$E8,$10,$28,$00
	db $01,$00,$E0,$10,$30,$00
	db $01,$00,$00,$10,$10,$00
	db $01,$00,$00,$10,$20,$00
	db $01,$00,$00,$10,$28,$00
	db $01,$00,$00,$10,$30,$00
	db $01,$00,$00,$10,$10,$00
	db $01,$00,$00,$10,$20,$00
	db $01,$00,$00,$10,$28,$00
	db $01,$00,$00,$10,$30,$00
	

;This routine will be executed when mario interact with a standar hitbox.
;It will be excecuted if $0E is 1 after execute Interaction routine