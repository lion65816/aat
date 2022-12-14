;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Balloon (sprite 7D), by mellonpizza
;;
;; This is a disassembly of sprite 7D in SMW, the Balloon.
;;
;; Uses first extra bit: YES
;;
;; When the extra bit is set the balloon will fly toward the left instead.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Balloon_Tile = $E4 ; Graphic tile to draw for balloon
!Balloon_Float_Amplitude = $10 ; Maximum Y speed
!Balloon_Float_Frequency = 1 ; How quickly the wavy motion of the ballon is
!Balloon_Float_Drift = -2 ; Net speed per frame of movement (makes the ballon float more upward overtime)
!Balloon_Float_Xspeed = $0C ; X speed when floating
!Inflate_SFX = $1E ; Sound to play when mario inflates
!Inflate_Bank = $1DF9 ; Bank to play SFX

!Keep_Items_On_Inflate = 0 ; Clear = drop all held items on inflation (Vanilla). Set = keep holding any items when you get the ballon.
!Allow_Carry_Items = 0 ; Clear = Can't pick up items while in balloon (vanilla). Set = Can pick up items


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

!sprite_direction = !157C

!LockAnimationFlag = $9D

!OAM_XPos = $0300|!Base2
!OAM_YPos = $0301|!Base2
!OAM_Tile = $0302|!Base2
!OAM_Prop = $0303|!Base2

print "INIT ",pc
	;; Set the "drift"
	;; This is to make a simplification in the code where the balloon's y speed oscillates from 16 to -16,
	;; but then is offset -2 when doing the actual speed upate. the simplification sets neutral y speed to -2
	;; and shifts the range down. (Though here, you can specify what value to use in place of -2!)
	lda.b #!Balloon_Float_Drift : sta !sprite_speed_y,x
	rtl
	
print "MAIN ",pc
	wdm #$01
	phb : phk : plb
	lda !sprite_status,x : cmp #$0B : beq +
	jsr Balloon_Main
	bra ++
	+
	jsr Balloon_Carried
	++
	plb
	rtl 
	
YspeedAdd:
db -!Balloon_Float_Frequency,!Balloon_Float_Frequency

YspeedMax:
!Ballon_Speed_Max_Neg = 0
while !Ballon_Speed_Max_Neg < (!Balloon_Float_Amplitude-!Balloon_Float_Drift)
	!Ballon_Speed_Max_Neg #= !Ballon_Speed_Max_Neg+!Balloon_Float_Frequency
endif
db -!Ballon_Speed_Max_Neg

!Ballon_Speed_Max_Pos = 0
while !Ballon_Speed_Max_Pos < (!Balloon_Float_Amplitude+!Balloon_Float_Drift)
	!Ballon_Speed_Max_Pos #= !Ballon_Speed_Max_Pos+!Balloon_Float_Frequency
endif
db !Ballon_Speed_Max_Pos

Balloon_Main:
	;; Don't run default things if sprites locked, or is powerup past goal
	lda !sprite_status,x : cmp #$0C : beq +
	lda !LockAnimationFlag : beq ++
	+
	jmp DrawBalloonExtra
	++
	;; Moved offscreen upward
	%SubOffScreen()
	
	;; Only run below code every other frame
	lda !TrueFrameCounter : lsr a : bcs +
	
	;; Oscillate ballon movement up/down
	lda !151C,x : and #$01 : tay
	lda !sprite_speed_y,x : clc : adc YspeedAdd,y : sta !sprite_speed_y,x
	cmp YspeedMax,y : bne +
	inc !151C,x
	+
	;; Set constant speed X, and update speeds
	ldy.b #!Balloon_Float_Xspeed
	lda !extra_bits,x : and #$04 : beq +
	ldy.b #-!Balloon_Float_Xspeed
	+
	tya : sta !sprite_speed_x,x
	jsl $018022|!BankB
	jsl $01801A|!BankB
	
	;; Check collision with player
	jsl $01A7DC|!BankB : bcc .graphics
	
	;; Drop all other sprites ignoring balloons
if !Keep_Items_On_Inflate == 0
	phx
	ldx.b #!SprSize-1
	-
	lda !sprite_status,x : cmp #$0B : bne +
	lda !9E,x : cmp #$7D : beq +
	lda #$09 : sta !sprite_status,x
	+
	dex : bpl -
	plx
endif
	;; Set sprite to carried, or delete if another ballon is already in use
	lda #$00 : ldy $13F3|!Base2 : bne +
	lda #$0B
	+
	sta !sprite_status,x
	
	;; Transfer player speed to sprite
	lda !PlayerYSpeed : sta !sprite_speed_y,x
	lda !PlayerXSpeed : sta !sprite_speed_x,x
	
	;; Setup balloon info
	lda #$09 : sta $13F3|!Base2
	lda #$FF : sta $1891|!Base2
	lda.b #!Inflate_SFX : sta.w !Inflate_Bank|!Base2
.graphics
	;; Graphics routine moved down
	jmp DrawBalloonExtra

Balloon_Carried:
	;; Only run below processes every 4th frame
	lda !TrueFrameCounter : and #$01 : bne +
	
	;; Decrement balloon timer
	dec $1891|!Base2 : beq .BalloonExpired
	
	;; Show deflating frame when almost expired
	lda $1891|!Base2 : cmp #$30 : bcs +
	ldy #$01 : and #$04 : beq ++
	ldy #$09
	++
	sty $13F3|!Base2
	+
	;; Disable balloon as soon as any animation occurs
	lda $71 : cmp #$01 : bcc .BalloonActive

.BalloonExpired
	;; Clear sprite 
	stz $13F3|!Base2
	
	;; Clears sprite status, set to respawn as needed
	lda !sprite_status,x : cmp #$08 : bcc +
	ldy !sprite_index_in_level,x : cpy #$FF : beq +
	phx : phy
	tyx
	lda #$00 : sta !1938,x
	ply : plx
	+
	stz !sprite_status,x
	rts

.BalloonActive
	;; Handles moving the player around while in the balloon
	phb : lda #$02 : pha : plb
	jsl $02D214|!BankB
	plb
	lda $94 : sta !sprite_x_low,x
	lda $95 : sta !sprite_x_high,x
	lda $96 : sta !sprite_y_low,x
	lda $97 : sta !sprite_y_high,x
if !Allow_Carry_Items == 0
	lda #$01 : sta $148F|!Base2 : sta $1470|!Base2
endif
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;	Balloon graphics routine	;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawBalloonExtra:
	;; Some stuff for boss battles
	lda $140F|!Base2 : bne DrawBalloon
	lda $0D9B|!Base2 : cmp #$C0 : bne DrawBalloon
	lda #$D8 : sta !sprite_oam_index,x
DrawBalloon:
	lda #$20 : sta $02
	lda #$01 : sta !sprite_direction,x
	%GetDrawInfo()
	;; Draw tiles
	lda $00 : sta !OAM_XPos,y
	lda $01 : dec a : sta !OAM_YPos,y
	lda !sprite_direction,x : lsr a
	lda #$00 : bcs +
	lda #$40
	+
	ora !sprite_oam_properties,x : ora $02 : sta !OAM_Prop,y
	lda.b #!Balloon_Tile : sta !OAM_Tile,y
	lda #$00 : ldy #$02
	jsl $01B7B3|!BankB
	rts  