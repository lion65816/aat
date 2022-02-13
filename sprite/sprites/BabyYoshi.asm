;=================================
; Baby Yoshi disassembly with added options
; By Djief, credit appreciated
; For vanilla Yoshi just leave everything at 00
;
; Uses extra bit : No
;
; Uses extra byte : Yes
;
; Uses extra property byte : Yes? have to set the 2nd one to 80 to not run vanilla code (Already set like that in the json)
;
; Extra byte 1 : Palette (00 = green, 01 = red, 02 = blue, 03 = yellow)
;
; Extra byte 2 : Hunger or amount of sprites Yoshi needs to eat before growing up (00 defaults to vanilla 05, FF means never grow up)
;
; Extra byte 3 : Powerups count for X eats (00 = grow instantly with powerups, as per vanilla. 01 = they count as any other sprite)
;
; Extra byte 4 : Hop speed (speed at which yoshi hops, higher value means hop higher, any negative value (80-FF) means no hop, 00 will be the vanilla 10)
;
;=================================

;=================================
; Glitch fixes
; Turned off by default to act as vanilla
; set to 1 to use
;=================================
!FixDoubleEat = 0			;Prevents double eat (when you get 3 eats with 2 sprites)
!FixOffScreenEat = 0		;Prevents eating off screen sprites, which results in getting a eat and respawning the sprite


!UseCustomTiles = 1		;Set to 1 if you want to point to actual tiles on the tilemap and set the tilemap to those tiles
!CustomTilesPage = 1	;0 for page 1, 1 for page 2, only used with custom tile map

;vanilla tilemap is not for the actual tiles, value is used to get a pointer to transfer the GFX into tile 06 and then tile is set to 06
;If not using custom tilemap you should keep it $40,$44,$42,$2C
TileMap:
db $20,$22,$24,$26

;Sounds
!SoundGulp = $06		;vanilla $06 and $1DF9
!SoundGulpBank = $1DF9

!SoundGrow = $1F		;vanilla $1F and $1DFC
!SoundGrowBank = $1DFC

!SoundKick = $03		;vanilla $03 and $1DF9
!SoundKickBank = $1DF9

!SoundHitBlock = $01	;vanilla $01 and $1DF9
!SoundHitBlockBank = $1DF9

;Redefines
!HopSpeed = !extra_byte_4
!Hunger = !extra_byte_2


;Tables
KickSpeed:				;Speeds when you kick baby Yoshi
db $D2,$2E,$CC,$34
XPositionAdjustLow:		;Low byte for the position adjustement when you drop baby Yoshi
db $F3,$0D
XPositionAdjustHigh:	;High byte for the same
db $FF,$00
DropSpeed:		;X speed when you drop baby Yoshi
db $FC,$04
db $00,$10
HandAdjustmentLow:		;Low byte of the X adjustement when holding baby Yoshi
db $0B,$F5,$04,$FC,$04,$00
HandAdjustmentHigh:		;
db $00,$FF,$00,$FF,$00,$00
CarriableBounceSpeed:	;Bounce speed when hitting the ground, kept this in for when the no hop option is on otherwise it is overwritten by the hop
db $00,$00,$00,$F8,$F8,$F8,$F8,$F8,$F8,$F7,$F6,$F5,$F4,$F3,$F2,$E8,$E8,$E8,$E8	;Non goomba values
db $00,$00,$00,$00,$FE,$FC,$F8,$EC,$EC,$EC,$E8,$E4,$E0,$DC,$D8,$D4,$D0,$CC,$C8	;Goomba values
EatingAnim:		;Poses for the eating animation
db $00,$03,$02,$02,$01,$01,$01


;=================================
; INIT and MAIN Wrappers
;=================================
print "INIT ",pc
	LDA #$09 : STA !14C8,x		;sprite status = carryable
	LDA #$05					;\ Set palette
	SEC : SBC !extra_byte_1,x	;|
	ASL							;|
	STA !15F6,x					;/
	;All other init stuff basically just puts vanilla values if it's 00
	LDA !Hunger,x
	BNE .NotVanilla
	LDA #$05
	.NotVanilla
	STA !Hunger,x
	LDA !HopSpeed,x
	BEQ .VanillaBounce
	BMI .ZeroBounce
	EOR #$FF : INC : BRA .SetBounce
	.VanillaBounce
	LDA #$F0 : BRA .SetBounce
	.ZeroBounce
	LDA #$00
	.SetBounce
	STA !HopSpeed,x
RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR BabyYoshi
	PLB
RTL

;========================
; Main routine
;========================
BabyYoshi:
	
	LDA $9D					;\ Since we have the check for sprite lock
	BEQ .NotFrozen			;| at the start we have to include some checks
	LDA !14C8,x				;| that are supposed to be in the carrying
	CMP #$0B				;| section since we would never reach that otherwise
	BNE .JustGFX			;|
	LDA $71					;|
	CMP #$01				;|
	BCS .NoCarry			;|
.KeepCarry					;|
	JSR PositionInHands		;|
.JustGFX					;|
	JMP RunGFX				;|
.NoCarry					;|
	LDA $1419|!Base2		;|
	BNE .KeepCarry			;|
	LDA #$09 : STA !14C8,x	;|
	JMP RunGFX				;/

.NotFrozen
	JSR HandleState
	JSR HandleFood
	
	LDA !163E,x		;\ Check if eating animation is on
	BNE .Eating		;/
	DEC
	STA !160E,x		;If not eating store $FF in eating slot (no sprites)
	
	LDA !HopSpeed,x
	BEQ .NoHop
	XBA
	LDA !14C8,x			;\ If alive and not carried
	CMP #$09			;|
	BNE .NoHop			;|
	LDA !1588,x			;| And on ground
	AND #$04			;|
	BEQ .NoHop			;|
	XBA					;| do a small hop
	STA !AA,x			;/
	
.NoHop
	LDY #$00		;normal pose
	LDA $14 : AND #$18	;\ For 8 frames every 32 frames
	BNE .NormalPose		;|
	LDY #$03			;/ put idle/gulp pose instead
	.NormalPose
	TYA
	STA !1602,x		;animation frames
	JMP .GFX
	
.Eating
	STZ !15EA,x		;Put yoshi in slot 0 in AOM so he appears in fron of the other sprite
	CMP #$20
	BEQ .GulpDown
	JMP .EatingAnimation
	
.GulpDown
	JSR GulpSprite
	
.EatingAnimation
	LDA !163E,x				;\ Get animation frame
	LSR #3					;| based on eating timer
	TAY						;|
	LDA EatingAnim,y		;|
	STA !1602,x				;/
	
	STZ $01				;\ If eaten sprite is not there anymore
	LDA !163E,x			;| don't bother moving it
	CMP #$20			;|
	BCC .GFX			;/
	
	LDY !160E,x
	SBC #$10									;\ eaten sprite animation
	LSR #2										;|
	LDY !157C,x									;|
	BEQ .SkipInvert								;|
	EOR #$FF : INC : DEC $01					;|
.SkipInvert										;|
	LDY !160E,x : CLC : ADC !E4,x : STA !E4,y	;|
	LDA !14E0,x : ADC $01 : STA !14E0,y			;|
	LDA !D8,x : SEC : SBC #$02 : STA !D8,y		;|
	LDA !14D4,x : SBC #$00 : STA !14D4,y		;/
	
.GFX
	JMP RunGFX
RTS

;========================
; Subroutine for handling berry tiles and sprites
;========================
HandleFood:
	LDA !E4,x			;\ Store position in scratch RAM for berry detection
	CLC : ADC #$08		;|
	STA $00				;|
	LDA !14E0,x			;|
	ADC #$00			;|
	STA $08				;|
	LDA !D8,x			;|
	CLC : ADC #$08		;|
	STA $01				;|
	LDA !14D4,x			;|
	ADC #$00			;|
	STA $09				;/
	
	JSL $02B9FA|!BankB		;checks for berry tiles
	;Calling the vanilla routine as it includes changes from LM due to different possible level sizes and I don't have easy access to those. Either way all this one does is transforming the berry tile into a sprite and then the following subroutine handles that sprite and you can check $18D8 to know which type of berry it was if you want something special for different berries
	;The sprite it creates is a mushroom with $01 in the $160E table and the type of berry in $18D6
	JSR HandleSprites
RTS

;========================
; Subroutine for handling other Sprites interactions
;========================
HandleSprites:
	LDY #!SprSize-1
.LoopSprites
	TYA
	CMP !160E,x			;If currently being eaten don't eat again
	BEQ .NextSprite
	EOR $13 : LSR		;Only check half the sprites every frame
	BCS .NextSprite
	CPY $15E9|!Base2	;Don't eat yourself
	BEQ .NextSprite
	LDA !14C8,y : CMP #$08	;Don't eat dead sprites
	BCC .NextSprite
	STY $1695|!Base2
	LDA !9E,y
	CMP #$70			;Pokies are full of spines, don't eat
	BEQ .NextSprite
	CMP #$0E			;Can't eay keyholes, they're just holes
	BEQ .NextSprite
	CMP #$1D			;Can eat anything else below 1D
	BCC .CheckEat
	LDA !1686,y : AND #$03	;\If inedible or something that stays in yoshi's mouth (keys/p-switches/etc, shells are allowed with check above)
	ORA $18E8|!Base2		;|or Yoshi's growing
	BNE .NextSprite			;/Don't eat
.CheckEat
	JSR CheckContactEat
.NextSprite
	DEY
	BPL .LoopSprites
RTS

;========================
; Subroutine for checking if baby Yoshi is in contact with a sprite to eat
;========================
CheckContactEat:
	PHX : TYX
	JSL $03B6E5|!BankB		;Get clippings B
	PLX
	JSL $03B69F|!BankB		;Get clippings A
	JSL $03B72B|!BankB		;Check contact
	BCC .Return
	LDA !163E,x		;If not currently eating something
	BEQ .EatSprite
	if !FixDoubleEat == 1
		CMP #$20
		BCC .EatSprite
	endif
	JSR GulpSprite
	LDA $18E8|!Base2		;If Yoshi's growing
	BNE .CancelEat
.EatSprite
	LDA #$37 : STA !163E,x			;Eat timer
	LDY $1695|!Base2 : STA !1632,y	;Eaten sprite behind scene
	TYA : STA !160E,x				;Eaten sprite
	
	STZ !157C,x		;\Make Yoshi face the food
	LDA !E4,x		;|
	CMP !E4,y		;|
	LDA !14E0,x		;|
	SBC !14E0,y		;|
	BCC .Return		;|
	INC !157C,x		;/
	
.Return
RTS
.CancelEat
	STZ !163E,x
RTS

;========================
; Subroutine for making baby Yoshi swallow the food and check if growing
;========================
GulpSprite:
	PHY
	LDY !160E,x
if !FixOffScreenEat == 1
	LDA !14C8,y
	BEQ .NoGulp
endif
	LDA #$00 : STA !14C8,y	;kill food
	LDA #!SoundGulp : STA !SoundGulpBank|!Base2
	LDA !Hunger,x
	INC
	BEQ .JustCoin
	LDA !160E,y				;\ If sprite has a 160E value it's not a powerup
	BNE .IncreaseEatCount	;/ so no need to check
	LDA !9E,y
	CMP #$81			;\ If eaten sprite is a changing powerup sprite
	BEQ .Powerup		;/ Grow Yoshi
	CMP #$74				;\ If not a powerup
	BCC .IncreaseEatCount	;| go to increase the count
	CMP #$78				;| of things yoshi ate
	BCS .IncreaseEatCount	;/ else grow Yoshi
.Powerup
	LDA !extra_byte_3,x				;\ Check if set to grow instantly
	BEQ .GrowYoshi					;|
	CLC : ADC !1570,x : STA !1570,x	;| or add the amount of eats
	BCC .CheckEatCount				;/
	
.GrowYoshi
	STZ $18AC|!Base2		;clear Yoshi eat timer
	STZ $141E|!Base2		;clear Yoshi wings
	LDA #$35 : STA !9E,x	;Set sprite ID to Yoshi
	LDA #$08 : STA !14C8,x	;Change state to normal
	LDA #!SoundGrow : STA !SoundGrowBank|!Base2		;Play grow sound
	LDA !D8,x : SBC #$10 : STA !D8,x		;\ Adjust Y position
	LDA !14D4,x : SBC #$00 : STA !14D4,x	;/
	LDA !15F6,x : PHA		;Save palette
	JSL $07F7D2|!BankB		;init sprite tables
	PLA : AND #$FE : STA !15F6,x			;restore palette
	LDA #$0C : STA !1602,x	;Set growing pose
	DEC !160E,x				;No sprite on tongue
	LDA #$40 : STA $18E8|!Base2		;Growing timer
.NoGulp
	PLY
RTS
	
.IncreaseEatCount
	INC !1570,x				;\ Check if baby Yoshi ate enough to grow
.CheckEatCount
	LDA !1570,x				;|
	CMP !Hunger,x			;|
	BCS .GrowYoshi			;/
.JustCoin
	JSL $05B34A|!BankB		;Give player a coin
	LDA #$06				;\ Give player points
	JSL $02ACEF|!BankB		;/
	PLY
RTS

;========================
; Pointer routine to send to correct place depending on state
;========================
HandleState:
	LDA !14C8,x
	SEC : SBC #$09
	BCC .Return
	ASL		;Multiply by 2 because pointers are 2 bytes long
	TXY : TAX		;there are many ways to handle getting X back after the jump, turns out using Y to store and retrieve it saves us a few bytes overall and a whole 2 cycles when passing by kicked state every once in a while so huh that's why
	JMP (StatePtr,x)
.Return
RTS

StatePtr:
dw HandleCarriable, HandleKicked, HandleCarried, HandleGoal

HandleGoal:	;Shouldn't end up here but just in case
	TYX
RTS

;========================
; "Routine" for kicked state, Yoshi doesn't like being kicked
;========================
HandleKicked:
	TYX
	LDA #$09
	STA !14C8,x

;========================
; Routine for Carriable state
;========================
HandleCarriable:
	TYX
	JSL $01802A|!BankB		;update position and interact with objects
	
	LDA !1588,x			;\ if hit the ground
	AND #$04			;|
	BEQ .CheckCeiling	;/
	
	LDA !B6,x			;\ Cut X speed in half
	PHP					;|
	BPL .NoInvert		;|
	EOR #$FF : INC		;|
	.NoInvert			;|
	LSR					;|
	PLP					;|
	BPL .NoInvert2		;|
	EOR #$FF : INC		;|
	.NoInvert2			;|
	STA !B6,x			;/
	
	;Bounce routine for carriables to bounce on the ground
	;Baby Yoshi code usually overwrites this with the Yoshi hop on the ground thing but keeping it here for when the no hop option is set
	LDA #$18		;\ Carriable sprites don't bounce on layer 2 ground
	LDY  !1588,x	;| The game instead sets the speed to 18
	BMI .SetYSpeed	;/ I am guessing 18 because it also uses that subroutine for slopes but in this one it overwrites the 18 if it's a slope
	LDA !AA,x
	LSR #2
	TAY		;Increase Y by $13 to get the goomba bounce value
	LDA CarriableBounceSpeed,y
	.SetYSpeed
	STA !AA,x
	
.CheckCeiling
	LDA !1588,x : AND #$08	;\ If touching ceiling
	BEQ .CheckSides			;/
	LDA #$10 : STA !AA,x	;Bounce down
	LDA !1588,x : AND #$03	;\ If also touching sides
	BNE .HandleSides		;/ Skip next part
	;Game checks sides after top so if you hit both it's only gonna have saved the map 16 of the side block so if you manage to throw something and hit the corner you're gonna activate the side block but not the top block
	
	LDA !E4,x : CLC : ADC #$08 : STA $9A	;\ Position of the block hit
	LDA !14E0,x : ADC #$00 : STA $9B		;|
	LDA !D8,x : AND #$F0 : STA $98			;|
	LDA !14D4,x : STA $99					;/
	LDA !1588,x			;\ Layer hit
	ASL #3 : ROL		;|
	AND #$01			;|
	STA $1933|!Base2	;/
	LDY #$00
	LDA $1868|!Base2	;Map 16 of the block hit, only need low byte as only blocks that can be hit and register a hit are on 100
	JSL $00F160|!BankB	;Hit block
	
.CheckSides
	LDA !1588,x : AND #$03
	BEQ .Return
	
.HandleSides
	LDA #!SoundHitBlock : STA !SoundHitBlockBank|!Base2
	LDA !B6,x : EOR #$FF : INC : STA !B6,x	;\ invert speed
	LDA !157C,x : EOR #$01 : STA !157C,x	;/ and direction
	
	LDA !15A0,x		;\ If off screen or block off screen
	BNE .CutSpeed	;| don't hit it
	LDA !E4,x		;|
	SEC				;|
	SBC $1A			;|
	CLC				;|
	ADC #$14		;|
	CMP #$1C		;|
	BCC .CutSpeed	;/
	
	;Side block was the last one to be checked so no need to reget the location
	LDA !1588,x					;\ Layer hit
	ASL #2 : ROL : 	AND #$01	;|
	STA $1933|!Base2			;/
	LDY #$00
	LDA $18A7|!Base2	; Map 16 of the block
	JSL $00F160|!BankB	; Hit block

.CutSpeed
	LDA !B6,x	;\ divide speed by 4
	ASL			;|
	PHP			;|
	ROR !B6,x	;|
	PLP			;|
	ROR !B6,x	;/
	
.Return
	JSR HandleMario
RTS

;========================
; Subroutine for handling Mario contact
;========================
HandleMario:
	LDA !154C,x
	BNE .Return
	JSL $01A7DC|!BankB		;Check if touching Mario
	BCC .Return
	LDA $15		;\ if not holding run just bump Yoshi
	AND #$40	;/
	BEQ .CheckBump
	LDA $1470|!Base2	;\ same if on yoshi or holding something else
	ORA $187A|!Base2	;/
	BNE .CheckBump
	LDA #$0B : STA !14C8,x		;\ Carry Yoshi
	INC $1470|!Base2			;|
	LDA #$08 : STA $1498|!Base2	;/
.Return
	RTS
.CheckBump
	LDA #!SoundKick : STA !SoundKickBank|!Base2		;Sound
	LDA #$0A : STA !14C8,x		;Kicked state
	LDA #$10 : STA !154C,x		;Don't interact for 16 frames
	%SubHorzPos()
	LDA KickSpeed,y : STA !B6,x	;Bump
RTS


;========================
; Routine when being carried
;========================
HandleCarried:
	TYX
	PHK		;Get data bank to restore after
	PHK		;Return Bank for the RTL
	LDA #$01|!Bank8	;\ Set data bank for the jump
	PHA				;|
	PLB				;/
	PER $0006	;Return adress for the RTL
	PEA $8020	;Return adress for the RTS which points to an RTL
	JML $019140|!BankB		;Subroutine that checks if sprites are in water and sets the correct things for that, we really just use it to display water splashes since Mario is holding Yoshi anyway. Routine is modified by Lunar Magic due to different level sizes so just gonna call it the old fashioned way rather than reverse engineer that. Might try to optimize later because we only need to know if we display water splashes.
	PLB		;Set data bank back
	
.CheckController
	BIT $15				;\ Check if Y/X is released
	BVC .ReleaseCarry	;/
.PositionOnly
	JMP PositionInHands
	
.ReleaseCarry
	STZ !AA,x				;No vertical speed
	LDA #$09 : STA !14C8,x	;Back in carriable status
	LDA $15 : BIT #$08	;\ Check dpad
	BNE .TossUp			;|
	BIT #$03			;|
	BNE .Kick			;/
	
.Drop
	LDY $76
	LDA $D1
	CLC
	ADC XPositionAdjustLow,y
	STA !E4,x
	LDA $D2
	ADC XPositionAdjustHigh,y
	STA !14E0,x
	%SubHorzPos()
	LDA DropSpeed,y
	CLC
	ADC $7B
	STA !B6,x
	BRA .KickPose
	
.TossUp
	JSL $01AB6F|!BankB		;Sound + smoke routine
	LDA #$90
	STA !AA,x
	LDA $7B
	STA !B6,x
	ASL
	ROR !B6,x
	BRA .KickPose
	
.Kick
	JSL $01AB6F|!BankB		;Sound + smoke routine
	LDA #$0A
	STA !14C8,x
	LDY $76
	LDA $187A|!Base2	; Leaving the on Yoshi check so grab/mount glitch works the same
	BEQ .NotOnYoshi
	INY #2
.NotOnYoshi
	LDA KickSpeed,y
	STA !B6,x
	EOR $7B
	BMI .KickPose
	LDA $7B
	STA $00
	ASL $00
	ROR
	CLC
	ADC KickSpeed,y
	STA !B6,x
	
.KickPose
	LDA #$10 : STA !154C,x		;Disable mario contact for 16 frames
	LDA #$0C : STA $149A|!Base2	;Kick pose for 12 frames
	
.Return
RTS

;========================
; Positions Item correctly when carrying depending on powerups/poses
;========================
PositionInHands:
	LDY #$00				;\ Checks current state of Mario/animations to see which side and how far from Mario we put the item in hand
	LDA $76					;| Facing adds one to the index
	EOR #$01			;\ While we have Mario's direction
	STA !157C,x			;| we take the time to set yoshi's direction
	EOR #$01			;/
	BNE .CheckFacingTimer	;|
	INY						;|
	.CheckFacingTimer		;|
	LDA $1499|!Base2		;| If Mario is facing the camera add 2
	BEQ .CheckPipe			;|
	INY #2					;|
	CMP #$05				;| Depending how far in the dacing animation it is add 1 more
	BCC .CheckPipe			;|
	INY						;|
	.CheckPipe				;|
	LDA $1419|!Base2		;| If going in a pipe
	BEQ .CheckChangeDir		;|
	CMP #$02				;| and pipe is vertical
	BEQ .MaxY				;| set Y to 5 (item on mario)
	.CheckChangeDir			;|
	LDA $13DD|!Base2		;| If turning pose
	ORA $74					;| or climbing set Y to 5
	BEQ .MarioPosition		;|
	.MaxY					;|
	LDY #$05				;/
.MarioPosition
	PHX
	LDX #$00
	LDA $1471|!Base2		;\ some platforms use current frame for calculations
	CMP #$03				;| when you're on them
	BEQ .UseNextFrame		;|
	LDX #$3D				;/
	.UseNextFrame
	LDA $95,x : STA $01	;\ Load up current frame or next frame position in scratch RAM
	LDA $96,x : STA $02	;|
	LDA $97,x : STA $03	;|
	LDA $94,x : STA $00	;/ Load this one last 'cause we'd reload it into acc anyway
	PLX
	CLC : ADC HandAdjustmentLow,y : STA !E4,x			;\ X position adjusted
	LDA $01 : ADC HandAdjustmentHigh,y : STA !14E0,x	;/
	LDA #$0D			;\ Load up a different adjustement to the Y position depending on Mario height
	LDY $73				;|
	BNE .Ducking		;|
	LDY $19				;|
	BNE .NotSmall		;|
	.Ducking			;|
	LDA #$0F			;|
	.NotSmall			;|
	LDY $1498|!Base2	;|
	BEQ .NotPickingUp	;|
	LDA #$0F			;|
	.NotPickingUp		;/
	CLC : ADC $02 : STA !D8,x			;\ Y position
	LDA $03 : ADC #$00 : STA !14D4,x	;/
	LDA #$01			;\ Mario holding something flags
	STA $148F|!Base2	;|
	STA $1470|!Base2	;/
	
RTS


;========================
; GFX routine
; Includes the check make carriable items appear over Mario when turning and behind pipes when going in pipes
;========================
RunGFX:
	LDA $64 : STA $08		;Sprite priority in $08 so we don't have to restore $64 after
	LDA !14C8,x : CMP #$0B	;If not carrying use normal priority
	BNE .NotCarried
	LDA $13DD|!Base2		;\ If turning around
	ORA $1419|!Base2		;| or going in a pipe
	BNE .ZeroIndex			;/ draw Yoshi over Mario
	LDA $1499|!Base2		;\ If not facing camera
	BEQ .CheckPriority		;/ don't draw over Mario
.ZeroIndex
	STZ !15EA,x		;Index 0 of this part of the OAM is reserved for carriable items for when you need to draw them over Mario since SNES draws sprites in order of index
.CheckPriority
	LDA $1419|!Base2		;\ If in pipe draw behind layer 1
	BEQ .NotCarried			;|
	LDA #$10 : STA $08		;/
	
.NotCarried
	LDA #$00
	%SubOffScreen()
	%GetDrawInfo()

	PHY
	LDY !1602,x		;\ get current pose
	LDA TileMap,y	;/
	PLY
	
	;If using normal tile map, gets the pointer for baby Yoshi GFX
	if !UseCustomTiles == 0
		REP #$20
		AND #$00FF
		ASL #5
		CLC
		ADC #$8500
		STA $0D8B|!Base2
		CLC
		ADC #$0200
		STA $0D95|!Base2
		SEP #$20
		LDA #$06
	endif
	
	STA $0302|!Base2,y		;Tile
	LDA $00
	STA $0300|!Base2,y		;X position
	LDA $01
	STA $0301|!Base2,y		;Y position
	
	LDA !157C,x			;facing
	LSR
	LDA !15F6,x
	BCS .NoFlip
	ORA #$40
	.NoFlip
	ORA $08
	if !UseCustomTiles == 1
		ORA #!CustomTilesPage
	endif
	STA $0303|!Base2,y	;YXPPCCCT

	LDY #$02			;tile size = 16x16
	LDA #$00			;tiles to display = 1
	JSL $01B7B3|!BankB		;finish OAM write
RTS