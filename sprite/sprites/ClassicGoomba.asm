;Classic Goomba/Paragoomba (revision 2019-02-24)
;by Blind Devil

;A simple Goomba/Paragoomba sprite that dies when jumped on, like in SMB1/SMB3.
;If it's a Paragoomba, it'll turn into a regular one when stomped.

;Extra bit:
;clear: regular Goomba.
;set: bouncing Paragoomba.

;stop 1337-asm-writing lul
;and please comment your codes - for your own and everyone else's good :3

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defines
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;TILEMAPS
;What tiles to use for the Goomba, Paragoomba wings and squished Goomba.
;!Wing1 and !Squished should be 8x8, others are 16x16.
!Walk = $88
!Wing1 = $5D
!Wing2 = $C6 
!Squished = $38

;WING PROPERTIES
;Palette/page/properties for the Paragoomba wings, YXPPCCCT format.
!WingProp = $06

;WALKING SPEED
;Speed of the Goomba when walking.
!WalkSpeed = $08

;BOUNCING PARAGOOMBA SPEEDS
;Jumping heights of bouncing Paragoomba, low and high.
!BounceLow = $E8
!BounceHigh = $C0

;FOLLOW PLAYER
;If non-zero, Paragoomba will face the player when on ground.
;Set to 0 to disable this behavior.
!ParaFollow = 1

;CHAINKILL SCORE INCREMENT
;If enabled, each Goomba killed via sliding will increment points in sequence (200, 400, 800...).
!ChainKillEnabled = 0

;PARAGOOMBA PALETTE
;If 0, the Paragoomba will use the palette from CFG. Else, it'll have a different palette (SMB3 behavior).
!UseSeparatePal = 1

!ParagoombaProp = $06		;palette for Paragoomba, YXPPCCCT format (if separate palette define is set to 1).

				;Palette cheatsheet:
				;$00 = palette 8
				;$02 = palette 9
				;$04 = palette A
				;$06 = palette B
				;$08 = palette C
				;$0A = palette D
				;$0C = palette E
				;$0E = palette F

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;

		print "INIT ",pc
		%SubHorzPos()		;get player position relative to sprite horizontally
		TYA			;transfer sprite direction to A
		STA !157C,x		;store to sprite direction. face the player.

		LDA !7FAB10,x		;load extra bits
		AND #$04		;check if first extra bit is set
		BEQ +			;if not set, return.

if !UseSeparatePal
		LDA !15F6,x		;load palette/properties from CFG
		AND #$F1		;preserve flip/priority/page bits, clear palette bits
		ORA #!ParagoombaProp	;add user-defined palette bits
		STA !15F6,x		;store result back.
endif

		INC !1528,x		;increment "extra hitpoint" flag.
		INC !C2,x		;increment sprite pointer.
+
		STZ !1510,x		;reset "times bounced" address. has to be cleared manually because SMW doesn't do it.
		RTL			;return.

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;

		print "MAIN ",pc
		PHB			;preserve data bank
		PHK			;push program bank
		PLB			;pull program  bank value as new data bank
		JSR SpriteCode		;call sprite code.
		PLB			;restore data bank
		RTL			;return.

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Sprite Code Below
;;;;;;;;;;;;;;;;;;;;;;;;;;

ShowSquish:
		STZ !B6,x		;reset X speed.

		JSL $01802A|!BankB	;keep applying gravity.

		LDA !167A,x		;load fourth tweaker byte
		ORA #$02		;set bit to make it immune to cape/fire/bricks
		STA !167A,x		;store result back.
		LDA !166E,x		;load third tweaker byte
		ORA #$20		;set bit to make it not interact to cape spins (immune =/= interactable)
		STA !166E,x		;store result back.
		LDA !1686,x		;load fifth tweaker byte
		ORA #$09		;set bit to make it inedible by Yoshi, and disable interaction with other sprites
		STA !1686,x		;store result back.
		
		LDA !1540,x		;load spinjumped/squished timer
		BNE NReturn		;if not equal zero, return.

		STZ !14C8,x		;clear sprite status - erase self.
NReturn:
		RTS			;return.

SpriteCode:
		LDA #$00		;load value
		%SubOffScreen()		;call sprite offscreen handling routine.

		JSR Graphics		;call graphics code.

		LDA !14C8,x		;load sprite status
		CMP #$08		;check if alive/default
		BNE NReturn		;if not equal, return.
		LDA $9D			;load sprites/animation locked flag
		BNE NReturn		;if not zero, return.

		JSL $018032|!BankB	;interact with other sprites (default).
		JSR PlayerInteraction	;call custom player interaction subroutine.

		LDA !1588,x		;load sprite blocked status flag
		AND #$08		;check if blocked above (touching ceiling)
		BEQ +			;if not, don't reset Y speed.

		STZ !AA,x		;reset sprite's Y speed.

+
		LDA !14C8,x		;load sprite status
		CMP #$08		;check if default/alive
		BNE NReturn		;if not alive, don't set default speeds.

		LDA !C2,x		;load sprite pointer value
		BEQ Walk		;if zero, walk (can bounce shortly after).
		CMP #$01		;compare to value
		BEQ Bounce		;if equal, do low bounces then a high bounce.
		CMP #$FF		;compare to value
		BEQ ShowSquish		;if equal, show it squished. else...

		LDA !15AC,x		;load action timer
		BNE Walk		;if not equal zero, do regular walking action.
		LDA !1588,x		;load sprite blocked status flag
		AND #$04		;check if blocked below (on ground)
		BEQ Walk		;if not on ground, do regular walking action.

	if !ParaFollow
		%SubHorzPos()		;get player position relative to sprite horizontally
		TYA			;transfer sprite direction to A
		STA !157C,x		;store to sprite direction. face the player.
	endif

		STZ !C2,x		;reset sprite pointer value.

		LDA #$18		;load amount of frames
		STA !15AC,x		;store to action timer.
		RTS			;return.

Walk:
		LDA !1588,x		;load sprite blocked status flag
		AND #$04		;check if blocked below (touching ground)
		BEQ +			;if not, don't reset Y speed.

		LDA #$08
		STA !AA,x		;store to sprite's Y speed.

+
		LDA !1528,x		;load "extra hitpoint" flag
		BEQ JustWalk		;if equal zero, make sprite walk only. else...

		LDA !15AC,x		;load action timer
		BNE JustWalk		;if not equal zero, just walk. else...

		INC !C2,x		;increment sprite pointer value by one.

JustWalk:
		LDA !1588,x		;load sprite blocked status flag
		AND #$03		;check if blocked on left or right (touching a wall)
		BEQ +			;if not touching, skip ahead.

		LDA !157C,x		;load sprite direction
		EOR #$01		;flip bit 0 to change direction
		STA !157C,x		;store result back.

+
		LDA #!WalkSpeed		;load speed value
		PHA			;preserve onto stack

		LDA !157C,x		;load sprite direction
		BNE Left		;if facing left, make it move left.

		PLA			;restore speed value from stack
		BRA StoreSpd		;branch to store speed.

Left:
		PLA			;restore speed value from stack
		EOR #$FF		;invert all bits
		INC A			;increment result by one to get correct negative value

StoreSpd:
		STA !B6,x		;store to sprite's X speed.
		JSL $01802A|!BankB	;update sprite positions based on speeds (apply gravity/object interaction).

Return:
		RTS			;return.

Bounce:
		LDA !1588,x		;load sprite blocked status flag
		AND #$04		;check if blocked below (on ground)
		BEQ JustWalk		;if not on ground, make sprite just walk.

		LDA !1510,x		;load number of times sprite has bounced
		CMP #$03		;compare to value
		BEQ HigherBounce	;if equal, bounce higher.
		BCC LowerBounce		;if lower, bounce lower. else...

		STZ !1510,x		;reset number of times sprite has bounced.
		INC !C2,x		;increment sprite pointer value by one.
		LDA #$10		;load amount of frames
		STA !15AC,x		;store to action timer.
		BRA JustWalk		;keep the sprite walking.

LowerBounce:
		LDA #!BounceLow		;load speed value
		BRA StoreJump		;branch to store speed.

HigherBounce:
		LDA #!BounceHigh	;load speed value
StoreJump:
		STA !AA,x		;store to sprite's Y speed.
		INC !1510,x		;increment number of times the sprite has bounced.
+
		BRA JustWalk		;keep the sprite walking.

PlayerInteraction:
		JSL $01A7DC|!BankB	;interact with the player.
		BCC NoProc		;if carry is clear, don't process contact.

		LDA !C2,x		;load sprite pointer value.
		CMP #$FF		;compare to value (squished state)
		BEQ NoProc		;if squished, don't process interaction.

		LDA $1490|!Base2	;load star power timer
		BNE +			;if not equal zero, kill the sprite.

;leftover slidekill routine (forgotten since 2017 holy cow)
		LDA $13ED|!Base2	;load sliding downhill related address
		BEQ HasNoStar		;if not, skip ahead to other checks.

if !ChainKillEnabled == 0
		STZ $18D2|!Base2	;reset consecutive enemies stomped
endif

+
		%Star()			;starkill macro routine from PIXI (at last it's here after almost 2 years)

NoProc:
		RTS			;return.

HasNoStar:
		LDA !154C,x		;load timer that disables interaction with player
		BNE +			;if not equal zero, don't process contact.

;updated stomp routine (2019-02-24)
		%SubVertPos()		;check sprite's Y-pos relative to player, if above or below, etc
		CPY #$01		;compare Y to value
		BNE SprWins		;if not equal, means that the player is below the sprite, so hurt the player.
		LDA $0F			;load player's Y-pos relative to sprite
		CMP #$ED		;compare to value
		BCS SprWins		;if higher, hurt the player.

		LDA #$08		;load amount of frames
		STA !154C,x		;store to disable interaction with player (prevents unfair hits after stomping the sprite).
		JSR GiveScore		;give points
		JSL $01AA33|!BankB	;set mario speed
		JSL $01AB99|!BankB	;display contact graphic
		LDA $140D|!Base2	;load spin jump flag
		BNE SpinKill		;if set, spinkill sprite (zero player speed).
		ORA $187A|!Base2	;OR with riding Yoshi flag
		BNE SpinKillY		;if set, spinkill sprite (bounce player upwards).

		LDA !1528,x		;load "extra hitpoint" flag
		BEQ SquishSprite	;if equal zero, squish the sprite.

		STZ !1528,x		;reset "extra hitpoint" flag, and make Paragoomba a regular Goomba.
		STZ !1510,x		;reset number of times sprite has bounced.
		STZ !C2,x		;reset sprite pointer value.
		STZ !AA,x		;reset sprite's Y speed.
+
		RTS			;return.

SquishSprite:
		LDA #$FF		;load value
		STA !C2,x		;store to sprite pointer value.
		LDA #$20		;load amount of frames
		STA !1540,x		;store to timer, to show squished sprite.
		STA !154C,x		;store same value to disable interaction with player as well.
		RTS			;return.

SprWins:
		LDA $1497|!Base2        ;load player's flashing invulnerability timer
		ORA $187A|!Base2	;OR with riding Yoshi flag
		BNE +			;if any flags are set, return (run default interaction).

		JSL $00F5B7|!BankB	;else, hurt the player.
+
		RTS			;return.

SpinKill:
		LDA #$F8		;load value
		STA $7D			;store to player's Y speed.

		LDA $1497|!Base2	;load player invulnerability timer
		BNE SpinKillY		;if not equal zero, don't set its timer to 1.

		LDA #$01		;load value
		STA $1497|!Base2	;store to make the player invulnerable (use for chain-killing sprites without getting hurt).
SpinKillY:
		LDA #$04                ;load new status (spinkilled)
		STA !14C8,x		;store to sprite status.
		LDA #$1F                ;load amount of frames
		STA !1540,x             ;store to spinjumped timer.
		JSL $07FC3B|!BankB	;show star animation
		LDA #$08                ;load SFX value
		STA $1DF9|!Base2	;store to address to play it.
		RTS			;return.

GiveScore:
		PHY                     ; 
		LDA $1697|!Base2        ; \
		CLC			;  | 
		ADC !1626,x             ; / some enemies give higher pts/1ups quicker??
		INC $1697|!Base2        ; increase consecutive enemies stomped
		TAY
		INY
		CPY #$08		; \ if consecutive enemies stomped >= 8 ...
		BCS +			; /    ... don't play sound from table
		LDA STAR_SOUNDS,y	; \ play sound effect
		BRA ++			;  |
+
		LDA #$02		;sound effect for 8+ stomps
++
		STA $1DF9|!Base2	; /
		TYA			; \
		CMP #$08		;  | if consecutive enemies stomped >= 8, reset to 8
		BCC NO_RESET		;  |
		LDA #$08		; /
NO_RESET:
		JSL $02ACE5|!BankB      ; give mario points
		PLY			;
		RTS			; return

STAR_SOUNDS:
db $00,$13,$14,$15,$16,$17,$18,$19

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; GFX Drawing Code Below
;;;;;;;;;;;;;;;;;;;;;;;;;;

WingTiles:
db !Wing1,!Wing2	;closed, open

WingXDisp:
db $FE,$0A,$F6,$0A	;closed (left), closed (right), open (left), open (right)

WingYDisp:
db $FE,$F6		;closed, open

SquishXDisp:
db $00,$08		;left tile, right tile

!SquishYDisp = $08

Properties:
db $40,$00

Graphics:
		%GetDrawInfo()		;get OAM index for tiles and positions within the screen

		STZ $02			;erase scratch RAM.
		STZ $03			;erase scratch RAM.
		STZ $04			;erase scratch RAM.
		STZ $05			;erase scratch RAM.

		LDA !1510,x		;load times Goomba has bounced
		BNE Flutter		;if not equal zero, make wings flutter.
		LDA !1588,x		;load sprite blocked status
		AND #$04		;check if touching ground
		BEQ Flutter		;if not touching, make wings flutter.

		LDA #$02		;load value
		STA $05			;store to scratch RAM.
		BRA DoneWingAnima	;skip ahead.

Flutter:
		LDA $14			;load effective frame counter
		LSR #2			;divide by 2 twice
		PHA			;preserve A

		LDA !AA,x		;load sprite's Y speed
		BPL Slow		;if positive, make wings flutter slower.

		LDA !1510,x		;load times Goomba has bounced
		CMP #$04		;compare to value
		BCS Fast		;if doing the fourth jump, make wings flutter fast.

Slow:
		PLA			;restore A
		LSR			;divide A by 2 once more
		BRA StoreCount		;branch ahead

Fast:
		PLA			;restore A
StoreCount:
		AND #$01		;preserve bit 0
		ASL			;multiply by 2
		STA $05			;store to scratch RAM.

DoneWingAnima:
		LDA !14C8,x		;load sprite status
		CMP #$02		;check if starkilled
		BNE NoYFlip		;if not equal, don't flip tile.

		LDA #$80		;load Y-flip value
		STA $02			;store to scratch RAM.

		PHX			;preserve sprite index
		BRA DeadGoomba		;skip flipping tile X-wise and draw a single tile

NoYFlip:
		LDA $14			;load effective frame counter
		LSR #3			;divide by 2 three times
		AND #$01		;preserve bit 0 and clear all others
		STA $03			;store to scratch RAM.

NoXFlip:
		PHX			;preserve sprite index
		LDA !C2,x		;load sprite pointer
		CMP #$FF		;compare to value (check if squished)
		BNE NormGoomba		;if not equal, draw Goomba normally.

		LDX #$01		;loop count
SquishLoop:
		JSR DrawSquished	;call squished tiles drawing routine.

		INY
		INY
		INY
		INY			;increment OAM index by one four times
		DEX			;decrement loop count by one
		BPL SquishLoop		;loop if value is positive.
		BRA FinishOAM		;branch to finish OAM writing

NormGoomba:
		LDA !1528,x		;load "extra hitpoint" flag
		BNE +			;if not zero, make the loop draw wings.

DeadGoomba:
		LDX #$00		;loop count (zero, draw a single tile)
		BRA DrawBody		;branch and draw the body

+
		LDX #$02		;loop count
GFXLoop:
		CPX #$02		;compare X to value
		BEQ DrawBody		;if equal, draw body tiles.

		JSR DrawWings		;call wing tiles drawing routine
		BRA +			;branch ahead

DrawBody:
		JSR GoombaTile		;call Goomba tile drawing routine

+
		INY
		INY
		INY
		INY			;increment OAM index by one four times
		DEX			;decrement loop count by one
		BPL GFXLoop		;loop if value is positive.

FinishOAM:
		PLX			;restore sprite index
		LDY #$FF		;tiles size = determined by $0460
		LDA $04			;tiles drawn = determined by drawing routines
		JSL $01B7B3|!BankB	;bookkeeping/finish OAM writing
		RTS			;return.

GoombaTile:
		PHY			;preserve Y
		TYA			;transfer tile index to A
		LSR #2			;divide by 2 twice - get correct index for size table
		TAY			;transfer A to Y
		LDA #$02		;load 16x16 size value
		STA $0460|!Base2,y	;store to OAM.
		PLY			;restore Y

		REP #$20		;16-bit A
		LDA $00			;load sprite positions within screen from scratch RAM
		STA $0300|!Base2,y	;store to OAM.
		SEP #$20		;8-bit A

		LDA #!Walk		;load tilemap number
		STA $0302|!Base2,y	;store to OAM.

		PHX			;preserve loop count
		LDX $15E9|!Base2	;load sprite index into X
		LDA !15F6,x		;load palette/properties from CFG
		LDX $03			;load tile animation index from scratch RAM into X
		ORA Properties,x	;add flip bits from table according to index
		ORA $02			;add Y-flip if dead
		ORA $64			;set in level priority bits
		STA $0303|!Base2,y	;store to OAM.
		PLX			;restore loop count

		INC $04			;a tile was drawn, so increment scratch RAM value for OAM finish.
		RTS			;return.

DrawSquished:
		PHY			;preserve Y
		TYA			;transfer tile index to A
		LSR #2			;divide by 2 twice - get correct index for size table
		TAY			;transfer A to Y
		LDA #$00		;load 8x8 size value
		STA $0460|!Base2,y	;store to OAM.
		PLY			;restore Y

		LDA $00			;load sprite X-pos within screen from scratch RAM
		CLC			;clear carry
		ADC SquishXDisp,x	;add displacement from table according to index
		STA $0300|!Base2,y	;store to OAM.

		LDA $01			;load sprite Y-pos within screen from scratch RAM
		CLC			;clear carry
		ADC #!SquishYDisp	;add displacement
		STA $0301|!Base2,y	;store to OAM.

		LDA #!Squished		;load tilemap number
		STA $0302|!Base2,y	;store to OAM.

		PHX			;preserve loop count
		LDX $15E9|!Base2	;load sprite index into X
		LDA !15F6,x		;load palette/properties from CFG
		PLX			;restore loop count
		CPX #$00		;compare X to value
		BEQ +			;if equal, don't X-flip tile.
		ORA #$40		;add X-flip
+
		ORA $64			;set in level priority bits
		STA $0303|!Base2,y	;store to OAM.

		INC $04			;a tile was drawn, so increment scratch RAM value for OAM finish.
		RTS			;return.

DrawWings:
		PHY			;preserve Y
		TYA			;transfer tile index to A
		LSR #2			;divide by 2 twice - get correct index for size table
		TAY			;transfer A to Y
		LDA $05			;load size value from scratch RAM (#$00 or #$02)
		STA $0460|!Base2,y	;store to OAM.
		PLY			;restore Y

		PHX			;preserve loop count
		TXA			;transfer X to A
		CLC			;clear carry
		ADC $05			;add wing tile size value
		TAX			;transfer A to X
		LDA $00			;load sprite X-pos within screen from scratch RAM
		CLC			;clear carry
		ADC WingXDisp,x		;add displacement from table according to index
		STA $0300|!Base2,y	;store to OAM.

		TXA			;transfer X to A
		LSR			;divide A by 2
		TAX			;transfer A to X
		LDA $01			;load sprite Y-pos within screen from scratch RAM
		CLC			;clear carry
		ADC WingYDisp,x		;add displacement from table according to index
		STA $0301|!Base2,y	;store to OAM.

		LDA WingTiles,x		;load tilemap number from table according to index
		STA $0302|!Base2,y	;store to OAM.
		PLX			;restore loop count

		LDA #!WingProp		;load wing palette/properties
		CPX #$01		;compare X to value
		BEQ +			;if equal, don't X-flip tile.
		ORA #$40		;add X-flip
+
		ORA $64			;set in level priority bits
		STA $0303|!Base2,y	;store to OAM.

		INC $04			;a tile was drawn, so increment scratch RAM value for OAM finish.
		RTS			;return.