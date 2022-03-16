;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Sea Pokey, by Darolac
;; 
;; This boss will throw fire particles at Mario. Sometimes it will throw a thrown-block. 
;; You can defeat it by throwing carryable sprites at him. Everytime his HP decreases, it
;; will enter in a frenzy state, jumping around and stunning Mario everytime it hits the ground.
;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Boss HP. Should be equal or lower than 4.

!HP = 4

; 16x16 tiles used by the boss.

!Tile1 = $00

!Tile2 = $02

!Tile3 = $20

!Tile4 = $22

; Speed of the boss. The number refers to the HP of the boss.

!Speed4 = $02

!Speed3 = $03

!Speed2 = $03

!Speed1 = $04

; Speed when on "frenzy" state. The number refers to the HP of the boss.

!SpeedF4 = $09

!SpeedF3 = $09

!SpeedF2 = $0A

!SpeedF1 = $0B

; Jump period. Set it to $00 and the boss will not jump. 
; The number refers to the HP of the boss.

!Jump4 = $00

!Jump3 = $00

!Jump2 = $00

!Jump1 = $FF

!JumpF = $40		; Jump period when on "frenzy" state.		

; Defines related to the spawn of lava particles.

!Shoot = $D0		; Time between each spray of lava particles.

!ExSpriteNumber = $0C	; Number of the extended sprite spawned by the sprite.
					; It is set to spawn Volcano Lotus particles.
				
!NPart = $04		; Number of particles spawned. It should be set to
					; 4, 3, 2 or 1; other values will cause errors.

!ExtraP = $02		; When the HP of the boss is equal or below this, the
					; boss will spawn an extra lava particle over his
					; head.

; Number of lava particles sprays after which a throw block will be spawned.
; The number refers to the HP of the boss.

!Cycles4 = $02

!Cycles3 = $03

!Cycles2 = $03

!Cycles1 = $04

; Other defines.

!JHeight = $D0		; Related to the height the boss will reach when jumping.
					; Higher values mean less height.

!FTime = $BF		; Related to the duration of the "frenzy" state.
					; Higher values mean higher duration.

!STime = $40		; Period of time the boss will stand still at the start of the
					; frenzy state.

!Frenzyon = 0		; If this is set to anything other than 0, the boss will start
					; on a "frenzy" state.

!GoalMusic = $03	; Music to play when the boss is defeated.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Tiles:

db !Tile1,!Tile2
db !Tile3,!Tile4

db !Tile1,!Tile2
db !Tile3,!Tile4

Prop:

db $40,$40
db $40,$40

db $40,$40
db $40,$40

XOffset:

db $08,$F8
db $08,$F8

db $08,$F8
db $08,$F8

YOffset:

db $F0,$F0
db $00,$00

XSpeed:

db !Speed1,!Speed2,!Speed3,!Speed4,!Speed1^$FF+1,!Speed2^$FF+1,!Speed3^$FF+1,!Speed4^$FF+1

XSpeedF:

db !SpeedF1,!SpeedF2,!SpeedF3,!SpeedF4,!SpeedF1^$FF+1,!SpeedF2^$FF+1,!SpeedF3^$FF+1,!SpeedF4^$FF+1

XSpeedProj:

db $12,$10,$0E,$0C,$12^$FF+1,$10^$FF+1,$0E^$FF+1,$0C^$FF+1

YSpeedProj:

db $F3,$F0,$ED,$EA,$F3,$F0,$ED,$EA

XOffsetProj:

db $10,$F8

XSpeedBlock:

db $14^$FF+1,$14

XOffsetBlock:

db $13^$FF+1,$14

Jumpfrec:

db !Jump1,!Jump2,!Jump3,!Jump4

KilledXSpeed:

db $F0,$10

Cycle:

db !Cycles1,!Cycles2,!Cycles3,!Cycles4

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
%SubHorzPos()
TYA					; turn to face the player
STA !157C,x			;

LDA #!HP-1			; \ set boss max HP
STA !1528,x			; /

if !Frenzyon != 0

LDA #$01			; if !Frenzyon is not 0...
STA !C2,x			; ...the sprite will start in frenzy state

endif

RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR SeaPokeyMain
PLB
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SeaPokeyMain:

JSR GFX				; call the GFX routine
LDA !14C8,x			; \ 
EOR #$08			; | load sprite status, check if default/alive, 
ORA $9D				; | sprites/animation locked flag.
BEQ +				; |
JML Return			; /
+

LDA #$03			;
%SubOffScreen()	; check if the sprite is offscreen and despawn it if it does

LDA !C2,x			; \ check if it's time to end the frenzy state
CMP #!FTime			; /
BNE +				;
STZ !1602,x			; \ ...if it is, reset the 
STZ !15AC,x			; | relevant sprite tables and the frenzy state timer
STZ !C2,x			; /
+

LDA !C2,x			; \ load frenzy state timer...
BEQ +				; / ...if it's 0, skip this	
CMP #!STime			; \
BCS +				; |
INC !C2,x			; | if it's below a certain value, increase frenzy timer
STZ !B6,x			; | and stand still 
JMP End				; /
+

LDA $0C				; load sprite direction multiplied by four...
CLC					; \ 
ADC !1528,x			; | add the sprite's HP - 1 to the previous value,
TAY					; / and translate it to the Y register
LDA XSpeed,y		; load speed value from a table, depending on previous value
STA !B6,x			; store it in the corresponding adress

LDY !1528,x			; load in the Y register the HP - 1.

LDA !15AC,x			; load the jump counter
BNE +				; if it's not 0, then skip this.
LDA Jumpfrec,y		; load jump period from table and depending on HP
STA !15AC,x			; store it into the jump counter
LDA !C2,x			; \ check if the sprite is in frenzy state
BEQ +				; / and skip if not
LDA !JumpF			; load jump period from table and depending on HP
STA !15AC,x			; store it into the jump counter
+

LDA !1504,x			; load the stomp flag
BEQ +				; if it's not 0...
LDA !1588,x			; \
AND #$04			; | ...and also the sprite is blocked from below...
BEQ +				; /
LDA #$10			; \ shake layer 1
STA $1887|!Base2	; /
LDA #$09			; \ play sound effect
STA $1DFC|!Base2	; /
STZ !1504,x			; reset stomp flag
LDA $77				; \
AND #$04			; | check if Mario is touching the floor...
BEQ +  				; /
LDA #$20			; \ if it is, freeze Mario
STA $18BD|!Base2	; /
+

LDA !15AC,x			; load jump counter
CMP #$01			; \ if it has just been set...
BNE +				; /
LDA !1588,x			; \ ...and the sprite is blocked from below...
AND #$04			; |
BEQ +				; /
LDA #!JHeight		; \ then jump
STA !AA,x			; /
INC !1504,x			; and set the stomp flag
+

LDA !C2,x			; load the frenzy-status counter
BEQ Skip			; \ if it's 0...
JMP ++				; /

Skip:

INC !1602,x			; \ then increase the throw counter...
LDA !1602,x			; /
CMP #!Shoot			; \ ...and check if it's equal to a certain value
BEQ Skip2			; / if it is, then it's shooting time
JMP +

Skip2:

LDA #!NPart-1		; load the number of particles to spawn minus one
STA $0B				; store it into scratch RAM

Repeat:

LDY !157C,x			; load sprite direction into Y        

LDA XOffsetProj,y	; load X offset of the fire particles...
STA $00				; ...and store it

LDA $0B				; load number of particles left to spawn - 1...
CLC					; \ ...and add it to
ADC $0C				; / the sprite direction multiplied by four
TAY

LDA #$F0			; load Y offset of the fire particles...
STA $01				; ...and store it

LDA XSpeedProj,y	; load X speed of the fire particles...
STA $02				; ...and store it

LDA YSpeedProj,y	; load Y speed of the fire particles...
STA $03				; ...and store it

LDA #!ExSpriteNumber; load sprite number

%SpawnExtended()	; call the routine to spawn the fire particles

DEC $0B				; decrease number of particles left to spawn - 1...
BPL Repeat			; and loop if it's still a positive number

LDA !1528,x			; load sprite's HP - 1
CMP #!ExtraP		; if it's below a certain value...
BCS +++				; ...spawn another extra particle
LDA #$04 			; same steps as before...
STA $00				; ...this time with a single particle
LDA #$EB			;
STA $01				;
STZ $02				;
LDA #$F3			;
STA $03				;
LDA #!ExSpriteNumber;
%SpawnExtended()	; call the routine again
+++

LDY !1528,x			; load in the Y register the HP - 1.

LDA Cycle,y			; load number of cycles after which a throw block will be spawned
STA $0A				; and store it into scratch RAM

INC !1534,x			; increase spawn counter
LDA !1534,x			; \
CMP $0A				; | if it gets to a certain value...
BNE +++				; /

LDY !157C,x			; load sprite direction into the Y register

LDA XOffsetBlock,y	; load X offset to spawn the block depending on direction
STA $00				; store it

LDA #$E8			; load Y offset to spawn the block
STA $01				; store it

LDA XSpeedBlock,y	; load X speed of the block depending on direction
STA $02				; store it

LDA #$53			;
CLC
%SpawnSprite()
BCS ++++
LDA #$09                        ; Set status of sprite.
STA !sprite_status,y
LDA #$9F			; \ set to a certain value the stunned counter
STA !1540,y			; /
++++

STZ !1534,x			; reset the spawn counter
+++

STZ !1602,x			; reset throw counter
BRA +				; and branch
++
LDA !1528,x			; load HP - 1...
CLC					; \ ...and add it to the 
ADC $0C				; / sprite direction multiplied by 4
TAY					; translate the value into Y...
LDA XSpeedF,y		; ...and load X speed in function of that value
STA !B6,x			; store X speed in corresponding adress
LDA $14				; load frame counter
AND #$03			; \ every 4 frames...
BNE +				; /
INC !C2,x			; increase the frenzy counter
+

End:

LDY.b #!SprSize-1	; sprite is being kicked

-
LDA !14C8,y			; \ check if the sprite status is...
CMP #$09			; | ...shell-like
BCS +				; /

--
DEY					; decrease the Y register value by one		
BPL -				; \ branch if we still have values to search
JMP ++				; /

+
PHX					; push the sprite index of the current sprite into the stack
TYX					; translate the sprite index of the interacting sprite into X
JSL $03B6E5|!BankB	; get sprite clipping B routine
PLX					; pull the sprite index of the current sprite from the stack
JSL $03B69F|!BankB	; get sprite clipping A routine
JSL $03B72B|!BankB	; call the check-for-contact routine
BCC --				; cycle
PHX					; push the sprite index of the current sprite into the stack
TYX					; translate the sprite index of the interacting sprite into X

JSL $01AB72|!BankB	; call the show-sprite-contact gfx routine

LDA #$02			; \ Kill thrown sprite
STA !14C8,x			; /

PLX					; pull the sprite index of the current sprite from the stack

DEC !1528,x			; decrease the HP of the sprite
BPL NotKilled		; branch if it's a negative number

LDA #$02			; \ kill sprite
STA !14C8,x			; /


LDA #$D0			; \ some fancy "arg - I'm defeated" pose
STA !AA,x			; / (loading and storing some Y speed)
LDY !157C,x			; load the sprite direction into the Y register
LDA KilledXSpeed,y	; load the X speed in function of the direction
STA !B6,x			; store it into the corresponding adress
LDA #$1F			; \ play sound effect
STA $1DF9|!Base2	; /
LDA $1493|!Base2	; \
BNE +				;  |
INC $13C6|!Base2	;  |
LDA #$FF			;  | end level
STA $1493|!Base2	;  |
LDA #!GoalMusic		;  |
STA $1DFB|!Base2	; /
+
BRA ++

NotKilled:

LDA #$20			; \ play sound effect
STA $1DF9|!Base2	; /
LDA #$01			; \ increase frenzy counter
STA !C2,x			; / (boss goes crazy)
STZ !1534,x			; \
STZ !15AC,x			; | reset spawn and jump counters and stomp flag 
STZ !1504,x			; /
++

JSL $019138         ; sprite-object interaction

JSL $01A7DC|!BankB	; Mario interacts with the sprite.

LDA !1588,x			; \
AND #$08			; | if the sprite is touching the ceiling... 
BEQ +				; /
STZ !AA,x			; ...set the Y speed to 0
+

LDA !1588,x			; \
AND #$03			; | check if it's blocked from the sides
BEQ +				; /
STZ !B6,x			; if it is, then set the X speed to 0
+

JSL $01802A|!BankB	; update sprite position.

LDA !1588,x			; \ check if the sprite is blocked from below...
AND #$04			; /
BEQ +
%SubHorzPos()		; \ if it is...
TYA					; | ...turn to face the player
STA !157C,x			; /
+

Return:
RTS					; end this sprite routine :)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GFX:

%GetDrawInfo()		; call the getdrawninfo routine

STZ $02				; store 0 to scratch RAM

LDA !15F6,x			; load sprite YXPPCCCT table
STA $03				; store it into scratch RAM

LDA !14C8,x			; load sprite status
CMP #$02			; \ check if the sprite status is normal...
BEQ +				; /
LDA $14				; \
LSR #2				; | if it is, set frame index
AND #$04			; | and store it into scratch RAM
STA $02				; /

LDA !C2,x			; load frenzy counter...
BEQ +				; ...and branch if it's 0
LDA $03				; \
EOR #$0C			; | change palette
STA $03				; /
+

LDA !157C,x			; \ multiply sprite direction by
ASL #2				; | four and store it into
STA $0C				; / scratch RAM

LDA #$03			; \ number of tiles to draw - 1
STA $05				; /

GFXLoop:

LDA $05				; load number of tiles left to draw...
CLC					; \ ...and add it to the sprite direction
ADC $0C				; / multiplied by four
TAX					; get that into X register
LDA XOffset,x		; \
CLC					; | load X offset depending on X register
ADC $00				; / and add it to X position of tile
STA $0300|!Base2,y	; store it

LDA Prop,x			; load properties of tile
ORA $03				; \ put it together with the sprite's and level's OAM properties
ORA $64				; /
STA $0303|!Base2,y	; store them

LDA $05				; load number of tiles left to draw...
CLC					; \ ...add it to the frame index
ADC $02				; /
TAX					; translate it into the X register
LDA Tiles,x			; load tile number
STA $0302|!Base2,y	; store it

LDX $05				; \
LDA YOffset,x		; | load Y offset depending on tile
CLC					; | and add it to Y position of tile
ADC $01				; /
STA $0301|!Base2,y	; store it

INY #4				; get ready for the next tile, increasing the Y register by four
	
DEC $05				; one tile less to draw
BPL GFXLoop			; branch if there are still some tiles to draw

LDX $15E9|!Base2 	; reload the sprite index into the X register

LDA #$03			; load number of tiles to draw - 1
LDY #$02			; 16x16 tiles
JSL $01B7B3|!BankB	; finish OAM routine

RTS					; end gfx routine
