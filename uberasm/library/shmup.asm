; Code adapted from A2MT's Mad Science Laboratory (Level 10E).

	!shmupspd = $30
	!shmuptopc = $06	; control limit
	!shmupbotc = $B6
	!shmuptopb = $04	; shift limit
	!shmupbotb = $B8
	!shmupleft = $0C	; horizontal limits
	!shmupright = $E4

	!SprSize = $16		;> Number of SA-1 sprite slots ($16 = 22).

	!firespeedset1 = $1924|!addr	;\ Free RAM needed to ensure that active
	!firespeedset2 = $1923|!addr	;/ fireballs' speed is only set once.
	!PlayerCurrentHP = $58			;> Needs to be the same free RAM address as in SimpleHP.asm.

init:
	STZ !firespeedset1
	STZ !firespeedset2
	LDA #$1E			;\ Set the Green Star Block coin counter to 30.
	STA $0DC0|!addr		;/ Used to keep track of when to grant bonus HP.
	RTL

main:
	LDA $71				;\ Don't execute any of the following
	CMP #$09			;| code if Demo dies.
	BNE .continue		;|
	JMP .coin_counter	;/
.continue
	LDA $17			;\ Branch if not pressing R.
	AND #$10		;|
	BEQ +			;/
	LDA #$01		;\ Lock Demo facing right if R is held.
	STA $76			;/
+
	LDA $17			;\ Branch if not pressing L.
	AND #$20		;|
	BEQ +			;/
	STZ $76			;> Lock Demo facing left if L is held.
+
	LDA #$02		;\ Demo always has a cape
	STA $19			;/

	STZ $7B
	STZ $7D
	STZ $03

	LDA $1493|!addr			;\ During the level end sequence,
	BEQ +					;| stop processing player inputs,
	;JMP .ammnostandanim	;| but keep Demo floating.
	JMP .ammnoup			;/
+

	LDA $15			; right pressed
	AND #$01
	BEQ .ammnoright
	LDA $77			; no block right
	AND #$01
	BNE .ammnoright
	LDA $7E			; limit right
	CMP #!shmupright
	BCS .ammnoright
	LDA $7B
	CLC
	ADC #!shmupspd
	STA $7B
.ammnoright
	LDA $15			; left pressed
	AND #$02
	BEQ .ammnoleft
	LDA $77			; no block left
	AND #$02
	BNE .ammnoleft
	LDA $7E			; limit left
	CMP #!shmupleft
	BCC .ammnoleft
	LDA $7B
	SEC
	SBC #!shmupspd
	STA $7B
.ammnoleft
	LDA $15			; down pressed
	AND #$04
	BEQ .ammnodown
	LDA $77			; no block down
	AND #$04
	BNE .ammnodown
	LDA $80			; limit down
	CMP #!shmupbotc
	BCS .ammnodown
	LDA $7D
	CLC
	ADC #!shmupspd
	STA $7D
.ammnodown
	LDA $15			; up pressed
	AND #$08
	BEQ .ammnoup
	LDA $77			; no block up
	AND #$08
	BNE .ammnoup
	LDA $80			; limit up
	CMP #!shmuptopc
	BCC .ammnoup
	LDA $7D
	SEC
	SBC #!shmupspd
	STA $7D
.ammnoup
	STZ $73				; never ducking
	STZ $13DF|!addr		;> Show Demo's broom
	STZ $13E0|!addr		;> Demo's still frame
	LDA $14A6|!addr		; let cape spin show through
	BNE .ammnoflyanim
	STZ $13E0|!addr		;> Demo's still frame
.ammnoflyanim
	LDA $1471|!addr		; fix platform stuffs
	BNE .ammunplatf
	LDA $7B				; no standstill while moving
	BNE .ammnounplatf
	LDA $77				; stand on ground
	AND #$04
	BEQ .ammnounplatf
.ammunplatf
	;REP #$20			;\ Commented out to prevent Demo from sliding towards
	;DEC $94			;| the left when grounded on a platform.
	;SEP #$20			;/
	LDA $14A6|!addr		; let cape spin show through
	BNE .ammnostandanim
	STZ $13E0|!addr
.ammnostandanim
.ammnounplatf
	; Limitfix
.ammlimit
	LDA $80
	CMP #!shmupbotb
	BCC .ammnobdown
	LDA $80			; expanding overtop realm
	CMP #$DD
	BCS .ammbup
	REP #$20
	DEC $96
	DEC $80
	SEP #$20
	BRA .ammlimit
.ammnobdown
	LDA $80
	CMP #!shmuptopb
	BCS .ammnobup
	LDA $77			; no forcedown if on ground
	AND #$04
	BNE .ammnobup
.ammbup
	REP #$20
	INC $96
	INC $80
	SEP #$20
	BRA .ammnobdown
.ammnobup
	; Straight fire
	STZ $1745|!addr		;\ Extended sprite Y speed (these two bytes for fireballs)
	STZ $1746|!addr		;/
	STZ $1759|!addr		;\ Fraction bits for extended sprite Y position (these two bytes for fireballs)
	STZ $175A|!addr		;/

	; Faster fire (rewritten to account for fireballs in both directions)
.firestatus1
	LDA $1714|!addr			;\ Check status of first fireball.
	CMP #$05				;| If the first fireball is not active,
	BNE .resetfirestatus1	;/ then its speed may be set again.
	LDA !firespeedset1		;\ Otherwise, if first fireball's speed already set,
	BNE .firestatus2		;/ then skip to checking status of second fireball.
	LDA $76					;\ If Demo is facing left,
	BEQ .fireleft1			;/ then give the first fireball left speed.
	LDA #$06				;> Otherwise, give the first fireball right speed.
	BRA .firespeed1
.fireleft1
	LDA #$FA			;> Left fireball speed.
.firespeed1
	STA $1750|!addr		;> Apply first fireball speed.
	LDA #$01			;\ Set this free RAM flag to make sure that the first fireball
	STA !firespeedset1	;/ does not have its speed changed when active.
	BRA .firestatus2
.resetfirestatus1
	STZ !firespeedset1
.firestatus2
	LDA $1713|!addr			;\ Check status of second fireball.
	CMP #$05				;| If the second fireball is not active,
	BNE .resetfirestatus2	;/ then its speed may be set again.
	LDA !firespeedset2		;\ Otherwise, if second fireball's speed already set,
	BNE .firedone			;/ then we no longer have any fireball slots to check.
	LDA $76					;\ If Demo is facing left,
	BEQ .fireleft2			;/ then give the second fireball left speed.
	LDA #$06				;> Otherwise, give the second fireball right speed.
	BRA .firespeed2
.fireleft2
	LDA #$FA			;> Left fireball speed.
.firespeed2
	STA $174F|!addr		;> Apply second fireball speed.
	LDA #$01			;\ Set this free RAM flag to make sure that the second fireball
	STA !firespeedset2	;/ does not have its speed changed when active.
	BRA .firedone
.resetfirestatus2
	STZ !firespeedset2
.firedone

	LDA $1493|!addr		;\ During the level end sequence,
	BEQ +				;| stop processing player inputs.
	JMP .coin_counter	;/
+

	; Control Override
	STZ $17			; clear things
	LDA $18			; but keep $18 as $01
	STA $01
	STZ $18
	LDA $15			; keep UDLR
	AND #$0F
	STA $15

	LDA $16			; make all four buttons fire
	AND #$20
	STA $00
	LDA $01			; fire on a
	AND #$80
	BNE .ammfirea
	LDA $16			; otherwise no fire if not pressing any other button
	AND #$C0
	BEQ .ammnofire
	LDA $16			; cape spin on x/y
	AND #$40
	BEQ .ammfirea
	LDA #$02
	STA $19
	BRA .ammcapespin
.ammfirea
	STZ $14A6|!addr		; force fire
	LDA #$03
	STA $19
.ammcapespin
	LDA #$40
	STA $00
.ammnofire
	LDA $00
	STA $16

	; Allow bullets to be killed by fireballs.
	LDX #!SprSize-3		;> Skip the last two slots (otherwise, the tweaker properties may not work).
-
	LDA !9E,x		;\ Check if the sprite is a Bullet Bill.
	CMP #$1C		;|
	BNE +			;/
	LDA !166E,x		;\ Can be killed with fireballs and cape.
	AND #$CF		;|
	STA !166E,x		;/
+
	LDA !9E,x		;\ Check if the sprite is a Banzai Bill.
	CMP #$9F		;|
	BNE +			;/
	LDA !166E,x		;\ Can be killed with fireballs, but not cape.
	AND #$EF		;|
	STA !166E,x		;/
	LDA !190F,x		;\ Needs 5 fireballs to kill.
	ORA #$08		;|
	STA !190F,x		;/
+
	LDA !7FAB9E,x	;\ Check if the sprite is a Homing Bill.
	CMP #$1A		;|
	BNE +			;/
	LDA !166E,x		;\ Can be killed with fireballs and cape.
	AND #$CF		;|
	STA !166E,x		;/
+
	;LDA !9E,x		;\ Check if the sprite is a Moving Coin.
	;CMP #$21		;|
	;BNE +			;/
	;LDA #$01		;\ If so, freeze it in place.
	;STA !C2,x		;/
;+
	DEX
	BPL -

	; Get +1 HP for every five coins collected.
	LDA $0DC0|!addr			;> Use the Green Star Block coin counter. Counts down every time a coin is collected.
	CMP #$1A				;\ If less than 26 coins, increment the player's HP.
	BCS .coin_counter		;|
	INC !PlayerCurrentHP	;/
	LDA #$0B				;\ Play the "item placed in reserve box" SFX.
	STA $1DFC|!addr			;/
	LDA #$1E				;\ Reset the coin counter to 30.
	STA $0DC0|!addr			;/
.coin_counter
	LDA $0DC0|!addr		;\ Set the appropriate coin counter frame
	SEC					;| for manual trigger 1.
	SBC #$1A			;|
	STA $7FC071			;/
	LDY.b #$02			;> Request 2 tiles to draw.
	REP #$30			;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0000		;> Maximum priority. Input parameter for call to MaxTile.
	JSL $0084B0			;\ Request MaxTile slots (does not modify scratch ram at the time of writing).
						;| Returns 16-bit pointer to the OAM general buffer in $3100.
						;/ Returns 16-bit pointer to the OAM attribute buffer in $3102.
	BCC .return			;\ Carry clear: Failed to get OAM slots, abort.
						;/ ...should never happen, since this will be executed before sprites, but...
	JSR draw_coin_counter
.return
	SEP #$30
	RTL

;=================================
; Draw coin counter (sprite-based,
; make sure the graphics are in
; the appropriate places in SP2)
;=================================

draw_coin_counter:
	PHB
	PHK
	PLB

	; OAM table
	LDX $3100			;> Main index (16-bit pointer to the OAM general buffer)
	LDA.w #$02			;\ Calculate loop index
	DEC					;| and store in Y.
	ASL					;|
	TAY					;/
-
	LDA TileCoord,y		;\ Load tile X and Y coordinates
	STA $400000,x		;/

	LDA TileProps,y		;\ Load tile properties.
	STA $400002,x		;/

	INX #4				;\ Move to next slot and loop
	DEY #2				;|
	BPL -				;/

	; OAM extra bits
	LDX $3102			;> Bit table index (16-bit pointer to the OAM attribute buffer)
	LDA.w #$02			;\ Calculate loop index
	DEC #2				;| and store in Y.
	TAY					;/
-
	LDA #$0202			;\ Store extra bits for two tiles at a time.
	STA $400000,x		;/ 

	INX #2				;\ Loop to set the remaining OAM extra bits.
	DEY #2				;|
	BPL -				;/

	PLB
	RTS

TileCoord:				; YYXX
	dw $5804,$5814		; Draw directly below the HP meter.

TileProps:				; High byte = YXPPCCCT, low byte = tile number
	dw $30AC,$30AE		; The second tile will change depending on coin count.
