;=====================================
; All these routines are called in 8-bit A/X/Y mode and DBR is already set.
; Don't worry about overwriting registers, they'll be restored afterwards (except for direct page :P).
; All the routines must end with rts.
;=====================================

;=====================================
; This routine will be called when loading the title screen.
; It can be used to reset particular RAM addresses for a new save file (see "docs/sram_info.txt").
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
load_title:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called when the level is reset by the retry system or when entering from the overworld.
; Unlike UberASM level init routine, this won't be executed during regular level transitions.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
reset:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be executed everytime the player dies.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
death:
    ; Feel free to put your code here.



    ; Code to reset some stuff related to lx5's Custom Powerups.
    ; You shouldn't need to edit this.
if !custom_powerups == 1
    stz.w ($170B|!addr)+$08
    stz.w ($170B|!addr)+$09
    lda #$00 : sta !projectile_do_dma

    ldx #$07
-   lda $170B|!addr,x : cmp #$12 : bne +
    stz $170B|!addr,x
+   dex : bpl -
    
    lda !item_box_disable : ora #$02 : sta !item_box_disable
endif

    rts

;=====================================
; This routine will be called every time the player touches a midway (vanilla or custom midway object).
; NOTE: on SA-1 roms, this runs on the SA-1 cpu.
;=====================================
midway:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time the player gets a checkpoint through a room transition.
; Remember you can check for $13BF and $010B to know in which trans/sub-level you are.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
room_checkpoint:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time the player selects "exit" on the retry prompt.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
prompt_exit:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time the game is saved (before anything gets saved).
; Remember that you can check for the current save file in $010A.
; NOTE: on SA-1 roms, this may run on either cpu depending on what's calling the save routine.
;=====================================
save_file:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time an existing save file is loaded (before anything gets loaded).
; Remember that you can check for the current save file in $010A.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
load_file:
    ; Feel free to put your code here.



    rts

;=====================================
; This routine will be called every time a new save file is loaded (before anything gets reset).
; Remember that you can check for the current save file in $010A.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
load_new_file:
    ; Feel free to put your code here.


    
    rts

;=====================================
; This routine will be called during the game over screen.
; This is called after the save file data is loaded from SRAM (only the data put before ".not_game_over" in "tables.asm") but before all the data is saved again to SRAM.
; This can be useful if you want to initialize some addresses for the game over and/or have them saved to SRAM.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
game_over:
    ; Feel free to put your code here.


    
    rts

;=====================================
; This routine will be called when Mario enters a door, every frame during the fade out.
; This could be useful since the door animation is the only one that can't be intercepted
; with level ASM or sprite ASM (since it immediately goes to the fading gamemode).
; If you need some level-specific action here, you can check the sublevel number in $010B (16 bit).
; If you need to only run the code for 1 frame, you can check for $0DB0 equal to 0.
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
door_animation:
    ; Feel free to put your code here.


    
    rts

;=====================================
; This routine will be called at the end of the game loop during gamemodes 7 and 14 (title screen and levels),
; just before Retry draws the prompt and AddmusicK's code runs.
; If you have other patches that hijack $00A2EA, you could try to put their freespace code in this routine to solve the conflict.
; NOTE: this runs at the end of the level frame in each level. If you want to run level-specific code, see "level_end_frame.asm".
; NOTE: on SA-1 roms, this runs on the SNES cpu.
;=====================================
gm14_end:
	; Feel free to put your code here.
	LDA $13E6|!addr		;\
	CMP #$01			;| If the status bar is disabled in the level,
	BEQ +				;/ then branch.

	LDA $19				;\ Print a different head based on the current powerup.
	STA $7FC070			;/ Uses Manual 0 Global ExAnimation trigger.

	%invoke_sa1(custom_bar)
	;JSR custom_bar
+
	RTS

;=====================================
; Subroutine to draw the custom status bar.
; Note that we cannot run this during the normal GM14.asm code,
; as sprite tiles cannot be drawn because $7F8000 is called
; shortly after their main code.
;=====================================

!MainLvlBackup	= $192C|!addr	;Have to resort to using a freeram because of too many resources changing $13BF temporarily

!NumTilesMax = $1D		;> Full status bar ($1D = 29 tiles)
!NumTilesMin = $09		;> Minimal status bar ($09 = 9 tiles), prints only the lives and Dragon Coin counters
!Offset = $1010			;> YYXX

custom_bar:
	; Use the MaxTile system to request OAM slots. Needs SA-1 v1.40.
	LDA $13E6|!addr		;\ Determine number of tiles to draw based on status bar type.
	CMP #$02			;/ Y is an input parameter for call to MaxTile.
	BEQ +
	LDY.b #$00+(!NumTilesMax)
	BRA ++
+
	LDY.b #$00+(!NumTilesMin)
++
	REP #$30			;> (As the index registers were 8-bit, this fills their high bytes with zeroes)
	LDA.w #$0000		;> Maximum priority. Input parameter for call to MaxTile.
	JSL $0084B0			;\ Request MaxTile slots (does not modify scratch ram at the time of writing).
						;| Returns 16-bit pointer to the OAM general buffer in $3100.
						;/ Returns 16-bit pointer to the OAM attribute buffer in $3102.
	BCC .return			;\ Carry clear: Failed to get OAM slots, abort.
						;/ ...should never happen, since this will be executed before sprites, but...
	JSR draw_custom_bar
.return
	SEP #$30
	;RTS
	RTL

draw_custom_bar:
	PHB
	PHK
	PLB

	; OAM table
	LDX $3100			;> Main index (16-bit pointer to the OAM general buffer)
	STX $00
	SEP #$10
	LDX #$40
	STX $02
	LDA.w #!NumTilesMax*4
	LDX $13E6|!addr		;\ Load the loop index depending on status bar type.
	CPX #$02			;/
	BNE +
	LDA.w #!NumTilesMin*4
+
	STA $0C
	LSR
	TAX
	DEX #2
	LDY #$00
-
	JSR (counters,x)
	DEX #2
	BPL -

	TYA
	LSR
	LSR
	DEC
	ADC $3102
	STA $03
	LDA #$F0F0
-
	CPY $0C
	BEQ +
	STA [$00],y
	INY #4
	BRA -
+
	TYA
	LSR
	LSR
	TAY
	DEY
	; OAM extra bits
	REP #$10
	LDX $3102			;> Bit table index (16-bit pointer to the OAM attribute buffer)

;Store Extra OAM bits for all allocated tiles
	LDA #$0000
	BRA +
-
	STA $400000,x

	INX #2
+
	DEY #2
	BPL -
	INY
	BPL +
	DEX
+
	STA $400000,x
	SEP #$20
	LDX $03
	LDA #$02
	STA $400000,x
	PLB
	RTS

counters:
dw .default
dw .default
dw .return
dw .lives
dw .return
dw .return
dw .return
dw .return
dw .raocoins
dw .default
dw .default
dw .return
dw .bonusstars
dw .default
dw .return
dw .return
dw .timer
dw .default
dw .default
dw .return
dw .coins
dw .demosiris
dw .demosiris
dw .demosiris
dw .demosiris
dw .return
dw .return
dw .return
dw .demos

.default
	LDA TileCoord,x
	STA [$00],y
	INY #2
	LDA TileProps,x
	STA [$00],y
	INY #2
.return
	RTS

.lives
	SEP #$20
	LDA $0DBE|!addr
	INC
	PHX
	JSR get2digits
	LDX TileProps+7
	STX $07
	REP #$20
	LDA TileCoord+6
	STA [$00],y
	INY #2
	LDA $06
	STA [$00],y
	INY #2
	LDX $04
	BEQ +
	LDX TileProps+5
	STX $05
	LDA TileCoord+4
	STA [$00],y
	INY #2
	LDA $04
	STA [$00],y
	INY #2
+
	PLX
	DEX #2
	RTS

.raocointable
db %00100011 ;db %11000100	;00-07
db %01010001 ;db %10001110	;08-0F
db %11111011 ;db %11011111	;10-17
db %01110010 ;db %01001110	;18-1F
db %11111011 ;db %11011111	;20-24,101-103
db %10110111 ;db %11101101	;104-10B
db %10111111 ;db %11111101	;10C-113
db %01101100 ;db %00110110	;114-11B
db %11111101 ;db %10111111	;11C-123
db %11101111 ;db %11110111	;124-12B
db %10010111 ;db %11101001	;12C-133
db %11111110 ;db %01111111	;134-13B
db %00000000
.raocoins
	SEP #$20
	PHX
	STY $03
	LDA $1426|!addr
	BNE +
	LDA !MainLvlBackup
	BNE ++
	LDA $13BF|!addr			;Assume that $13BF will be set to the correct value on the first frame of the HUD being drawn
	STA !MainLvlBackup
++
	LDA $13BF|!addr
	CMP !MainLvlBackup
	BNE +
	LSR #3
	TAY
	LDA $13BF|!addr
	AND #$07
	TAX
	LDA .raocointable,y
	AND.l $0DA8A6|!bank,x
	BNE ++
	LDA #$FF
	STA $1420|!addr
	STA $1422|!addr
	BRA +
++
	LDA $1F2F|!addr,y
	AND.l $0DA8A6|!bank,X
	BEQ +
	LDA #$05
	STA $1420|!addr
	STA $1422|!addr
+
	STZ $05
	LDY $03
	LDA $1422|!addr
	STA $04
	REP #$20
	BMI ++
	LDX #$08
-
	LDA TileCoord+8,x
	STA [$00],y
	INY #2
	LDA.w #$3046
	DEC $04
	BPL +
	INC
+
	STA [$00],y
	INY #2
	DEX #2
	BPL -
++
	PLX
	TXA
	SEC
	SBC #$0008
	TAX
	RTS

.bonusstars
	SEP #$20
	PHX
	LDX $0DB3|!addr
	LDA $0F48|!addr,x
	JSR get2digits
	LDX TileProps+$19
	STX $07
	REP #$20
	LDA TileCoord+$18
	STA [$00],y
	INY #2
	LDA $06
	STA [$00],y
	INY #2
	LDX $04
	BEQ +
	LDX TileProps+$17
	STX $05
	LDA TileCoord+$16
	STA [$00],y
	INY #2
	LDA $04
	STA [$00],y
	INY #2
+
	PLX
	DEX #2
	RTS

.timer
	PHX
	LDX #$1D
	STX $04
	STZ $06
	LDX $0F31|!addr
	BEQ +
	INC $06
	LDA TileCoord+$20
	STA [$00],y
	INY #2
	CPX #$0A
	BCS ++
	LDA digits,x
	STA $04
++
	LDX TileProps+$21
	STX $05
	LDA $04
	STA [$00],y
	INY #2
+
	LDX #$1D
	STX $04
	LDX $0F32|!addr
	BNE +
	LDA $06
	BEQ +++
+
	LDA TileCoord+$1E
	STA [$00],y
	INY #2
	CPX #$0A
	BCS ++
	LDA digits,x
	STA $04
++
	LDX TileProps+$1F
	STX $05
	LDA $04
	STA [$00],y
	INY #2
+++
	LDX #$1D
	STX $04
	LDX $0F33|!addr
	LDA TileCoord+$1C
	STA [$00],y
	INy #2
	CPX #$0A
	BCS ++
	LDA digits,x
	STA $04
++
	LDX TileProps+$1D
	STX $05
	LDA $04
	STA [$00],y
	INY #2
	PLX
	DEX #4
	RTS

.coins
	SEP #$20
	PHX
	LDA $0DBF|!addr
	JSR get2digits
	LDX TileProps+$29
	STX $07
	REP #$20
	LDA TileCoord+$28
	STA [$00],y
	INY #2
	LDA $06
	STA [$00],y
	INY #2
	LDX $04
	BEQ +
	LDX TileProps+$27
	STX $05
	LDA TileCoord+$26
	STA [$00],y
	INY #2
	LDA $04
	STA [$00],y
	INY #2
+
	PLX
	DEX #2
	RTS

.demosiris
	LDA TileCoord,x
	STA [$00],y
	INY #2
	PHX
	LDA TileProps,x
	STA $04
	LDX $0DB3|!addr
	BEQ +
	LDX #$3A
	STX $05
+
	LDA $04
	STA [$00],y
	INY #2
	PLX
	RTS

.demos
	SEP #$20
	PHX
	LDA $010A|!addr
	ASL
	CLC
	ADC $010A|!addr
	TAX
	LDA.l $41C7EF,x
	REP #$20
	BNE +
	LDA.l $41C7ED,x
	CMP #$2710
	BCC ++
+
	LDA #$270F
++
	STZ $06
	STZ $08
	STZ $0A
-
	CMP #$03E8
	BCC +
	INC $0A
	SBC #$03E8
	BRA -
+
-
	CMP #$0064
	BCC +
	INC $08
	SBC #$0064
	BRA -
+
-
	CMP #$000A
	BCC +
	INC $06
	SBC #$000A
	BRA -
+
	TAX
	LDA digits,x
	STA $04
	LDX TileProps+$39
	STX $05
	LDA TileCoord+$38
	STA [$00],y
	INY #2
	LDA $04
	STA [$00],y
	INY #2
	STZ $04
	LDX $0A
	BEQ +
	INC $04
	LDA digits,x
	STA $0A
	LDX TileProps+$37
	STX $0B
	LDA TileCoord+$36
	STA [$00],y
	INY #2
	LDA $0A
	STA [$00],y
	INY #2
+
	LDX $08
	BNE ++
	LDA $04
	BEQ +
++
	INC $04
	LDA digits,x
	STA $08
	LDX TileProps+$35
	STX $09
	LDA TileCoord+$34
	STA [$00],y
	INY #2
	LDA $08
	STA [$00],y
	INY #2
+
	LDX $06
	BNE ++
	LDA $04
	BEQ +
++
	LDA digits,x
	STA $06
	LDX TileProps+$33
	STX $07
	LDA TileCoord+$32
	STA [$00],y
	INY #2
	LDA $06
	STA [$00],y
	INY #2
+
	PLX
	DEX #6
	RTS

digits:
	db $20,$21,$22,$23	;> 0, 1, 2, 3
	db $30,$31,$32,$33	;> 4, 5, 6, 7
	db $38,$39			;> 8, 9

get2digits:
	LDX #$00
	SEC
	BRA +
-
	INX
+
	SBC #$0A
	BCS -
	ADC #$0A
	PHX
	TAX
	LDA digits,x
	STA $06
	STZ $04
	LDA #$1D
	PLX
	BEQ ++
	CPX #$0A
	BCS +
	LDA digits,x
+
	STA $04
++
	RTS

TileCoord:						; YYXX
	dw $0000+!Offset,$0410+!Offset,$0418+!Offset,$0420+!Offset	; Lives counter
	dw $0050+!Offset,$0048+!Offset,$0040+!Offset,$0038+!Offset	; Dragon coins
	dw $0030+!Offset											; Dragon coins (continued)
	dw $0834+!Offset,$083C+!Offset,$0844+!Offset,$084C+!Offset	; Bonus star counter
	dw $0088+!Offset,$00A0+!Offset,$0098+!Offset,$0090+!Offset	; Timer
	dw $0888+!Offset,$0890+!Offset,$0898+!Offset,$08A0+!Offset	; Coin counter
	dw $00B4+!Offset,$00BC+!Offset,$00C4+!Offset,$00CC+!Offset	; Death counter ("demos")
	dw $08C4+!Offset,$08BC+!Offset,$08B4+!Offset,$08CC+!Offset	; Death counter (digits)

; Y index starts from 58 (decimal), then decrements by 2 each time
TileProps:						; High byte = YXPPCCCT, low byte = tile number
	dw $3044,$3029,$300A,$300A	; Lives counter				indices 00-06
	dw $300A,$300A,$300A,$300A	; Dragon coins				indices 08-0E
	dw $300A					; Dragon coins (continued)	indices 10
	dw $30EF,$3029,$300A,$300A	; Bonus star counter		indices 12-18
	dw $307E,$300A,$300A,$300A	; Timer						indices 1A-20
	dw $3046,$3029,$300A,$300A	; Coin counter				indices 22-28
	dw $360C,$360D,$361A,$361B	; Death counter ("demos")	indices 2A-30
	dw $300A,$300A,$300A,$300A	; Death counter (digits)	indices 32-38

; Y index starts from 28 (decimal), then decrements by 2 each time
TileExtra:						; High byte = first tile, low byte = second tile
	dw $0200,$0000				; Lives counter			
	dw $0000,$0000				; Dragon coins			
	db $00						; Dragon coins (continued)
	dw $0000,$0000				; Bonus star counter	
	dw $0000,$0000				; Timer					
	dw $0000,$0000				; Coin counter			
	dw $0000,$0000				; Death counter	("demos")
	dw $0000,$0000				; Death counter (digits)
