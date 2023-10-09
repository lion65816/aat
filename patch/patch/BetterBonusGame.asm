;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Better Bonus Game
;; by Sonikku
;;;; Adds a few changes to the default bonus game as well as some fixes.
;;;; -- Will trigger the "bonus game end" theme and animation even if the bonus game is entered from the Overworld or as a sublevel
;;;;    preventing a softlock.
;;;; -- Rewrites the Cluster Sprite 1up so that it no longer appears out of thin air, and properly "exits" the pipe and plays a sound.
;;;; -- Adds functionality for the SMA2 "failure" pose if Mario fails to get a single 1up.
;;
;; Note: This does NOT make any changes to Mario's tilemap, so if you want to make use of the original SMA2 poses, you must
;;       find a way to do so on your own. By default, it will use the crouching frames.

!TriggerEvents =	!true		; Completing the bonus game will trigger overworld events for that level tile.
	!ExitType =	$01			; Which type of exit to trigger upon beating the bonus game, if entered from a sublevel/overworld.
						;;;; See this link for valid values:
						;;;; https://www.smwcentral.net/?p=memorymap&game=smw&address=0DD5&region[]=ram

!RewriteCluster1up =	!true		; Rewrites most of the cluster sprite 1up to have better collision, and to "exit" the pipe instead of just appearing.
	!Cluster1upInitialX =	$0018		; Initial X position of all spawned cluster sprite 1ups.
	!Cluster1upInitialY =	$00F0		; Initial Y position of all spawned cluster sprite 1ups.
	!Cluster1upFloorY =	$0180		; Y position of the floor.
	!Cluster1upWallL =	$0010		; X Position of the left wall.
	!Cluster1upWallR =	$00E0		; X Position of the right wall.
	!Cluster1upXSpeed =	$08		; X Speed of the 1ups once they hit the ground.

	!1upTilemap =		$24		; Tile used by the cluster sprite 1up.
	!1upProps =		$0A		; Palette/flip used by the cluster sprite 1up.

!FailurePose =		!true		; Adds a "failure" pose akin to SMA2 when you fail to get any 1ups
	!Get1up		= 	$26		; Frame to use when Mario gets at least 1 1up in the Bonus Game.
	!Get1upY	= 	$14		; Frame to use when Mario gets at least 1 1up in the Bonus Game while riding Yoshi.
	!Fail1up	= 	$3C		; Frame to use when Mario gets zero 1ups in the Bonus Game.
	!Fail1upY	= 	$1D		; Frame to use when Mario gets zero 1ups in the Bonus Game while riding Yoshi.
						;;;; See this link for valid values:
						;;;; https://www.smwcentral.net/?p=memorymap&game=smw&address=13E0&region[]=ram

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sets up defines and other stuff for sa-1. don't touch

	!addr	= $0000
	!bank	= $000000
	!sa1	= 0
if read1($00FFD5) == $23
	!addr	= $6000
	!bank	= $000000
	!sa1	= 1
	sa1rom
endif

macro define_sprite_table(name, addr, addr_sa1, addr_more_sprites)
if !sa1 == 0
	!<name> = <addr>
elseif !sa1 == 1
	!<name> = <addr_sa1>
else
	!<name> = <addr_more_sprites>
endif
endmacro

%define_sprite_table(14C8, $14C8, $74C8, $3242)

!true = 1 : !false = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

freecode

reset bytes

BonusGameInit:
	LDA #$01		; \  when $1425|!addr is 00, the bonus game won't trigger the "bonus end" sequence.
	STA $1425|!addr		;  | it only ever gets by the default game if the bonus star counter hits 100...
				; /  ...so it never happens if you enter it as a sublevel or from the overworld.
	STZ $1427|!addr		; we use this for scratch ram
	LDA $1B94|!addr		; \
	BEQ +			;  | game does some weird stuff man
	STZ !14C8,x		; / 
	JML $01DDB4|!bank	; 
+	JML $01DDB5|!bank	; (tells the game to spawn 9 of the bonus game blocks)

if !TriggerEvents
BonusGameEnd:
	PHB			; 
	PHK			; 
	PLB			; 
	LDY #$0B		; \ game normally only ever sets the gamemode
	STY $0100|!addr		; /
	STY $13CE|!addr		; \
	LDY $0DD5|!addr		;  | 
	BNE +			;  | we'll set the flags to trigger events too though
	LDY #!ExitType		;  | 
	STY $0DD5|!addr		;  | 
+	INC $1DE9|!addr		; /
	PLB			; 
	JML $00C533|!bank	; 
endif

if !RewriteCluster1up
SpawnCluster1up:
	PHB				; 
	PHK				; 
	PLB				; 
	REP #$20			; \
	LDA.w #!Cluster1upInitialY	;  | 
	SEP #$20			;  | set initial y position
	STA $1E02|!addr,y		;  | 
	XBA				;  | 
	STA $1E2A|!addr,y		; /
	REP #$20			; \
	LDA.w #!Cluster1upInitialX	;  | 
	SEP #$20			;  | set initial x position
	STA $1E16|!addr,y		;  | 
	XBA				;  | 
	STA $1E3E|!addr,y		; /
	LDA #!Cluster1upXSpeed		; \ set x speed
	STA $1E66|!addr,y		; /
	LDA #$20			; \ time before leaving pipe
	STA $1E8E|!addr,y		; /
	LDA #$02			; \ spawn sfx
	STA $1DFC|!addr			; /
	PLB				; 
	JML $01E2AF|!bank		; 

Cluster1up:
	PHB			; 
	PHK			; 
	PLB			; 
	TXA			; \
	ADC $13			;  | run collision every other frame
	AND #$01		;  | 
	BNE .NoContact		; /
	LDA $1E16|!addr,x	; \
	CLC			;  | 
	ADC #$02		;  | 
	STA $04			;  | 
	LDA $1E3E|!addr,x	;  | 
	ADC #$00		;  | 
	STA $0A			;  | 
	LDA $1E02|!addr,x	;  | setup cluster sprite clipping
	CLC			;  | 
	ADC #$02		;  | 
	STA $05			;  | 
	LDA $1E2A|!addr,x	;  | 
	ADC #$00		;  | 
	STA $0B			;  | 
	LDA #$0C		;  | 
	STA $06			;  | 
	STA $07			; /
	JSL $03B664|!bank	; \
	JSL $03B72B|!bank	;  | get mario clipping + check for contact
	BCC .NoContact		; /
	STZ $1892|!addr,x	; \
	PHK			;  | 
	PEA.w .jslrtsreturn-1	;  | jsl -> rts to the routine that gives mario a 1up
	PEA $F80F-1		;  | 
	JML $02FF6C|!bank	; /
.jslrtsreturn
	DEC $1920|!addr		; \
	BNE .NoContact		;  | end bonus game when all of the 1ups are collected
	LDA #$58		;  | 
	STA $14AB|!addr		; /
.NoContact
	LDA $1E8E|!addr,x	; \
	BEQ .NotInPipe		;  | 
	DEC			;  | 
	STA $1E8E|!addr,x	;  | 
	LDA #$08		;  | 
	STA $1E52|!addr,x	;  | 
	JMP .DrawGFX		; /
.NotInPipe
	LDA $1E52|!addr,x	; \
	BMI ++			;  | 
	CMP #$40		;  | 
	BPL +			;  | make sprite fall
++	CLC			;  | 
	ADC #$03		;  | 
+	STA $1E52|!addr,x	; /
	LDA $1E2A|!addr,x	; \
	XBA			;  | 
	LDA $1E02|!addr,x	;  | set "floor" for 1up
	REP #$20		;  | 
	CMP.w #!Cluster1upFloorY;  | 
	BCC .NotOnGround	; /
	LDA.w #!Cluster1upFloorY; \
	SEP #$20		;  | 
	STA $1E02|!addr,x	;  | force sprite position to floor
	XBA			;  | 
	LDA $1E2A|!addr,x	; /
	STZ $1E52|!addr,x	; no y speed

	LDA $1E66|!addr,x	; \
	ASL #4			;  | 
	CLC			;  | 
	ADC $0F9A|!addr,x	;  | 
	STA $0F9A|!addr,x	;  | 
	PHP			;  | 
	LDY #$00		;  | 
	LDA $1E66|!addr,x	;  | 
	LSR #4			;  | 
	CMP #$08		;  | give sprite horizontal gravity
	BCC +			;  | 
	ORA #$F0		;  | 
	DEY			;  | 
+	PLP			;  | 
	ADC $1E16|!addr,x	;  | 
	STA $1E16|!addr,x	;  | 
	TYA			;  | 
	ADC $1E3E|!addr,x	;  | 
	STA $1E3E|!addr,x	; /
	XBA			; \
	LDA $1E16|!addr,x	;  | 
	REP #$20		;  | 
	CMP #!Cluster1upWallL	;  | establish "walls"
	BCC .TouchWall		;  | 
	CMP #!Cluster1upWallR	;  | 
	BCC .NotOnGround	; /
.TouchWall
	SEP #$20		; 

	LDA $1E66|!addr,x	; \
	EOR #$FF		;  | turn sprite around
	INC			;  | 
	STA $1E66|!addr,x	; /
.NotMoving
	BRA .DrawGFX		; 
.NotOnGround
	SEP #$20		; 
.DrawGFX
	LDA $02FF64|!bank,x	; \ setup oam slots
	TAY			; /
	LDA $1E16|!addr,x	; \
	SEC			;  | set x position
	SBC $1A			;  | 
	STA $0200|!addr,y	; /
	LDA $1E02|!addr,x	; \
	SEC			;  | set y position
	SBC $1C			;  | 
	STA $0201|!addr,y	; /
	LDA #!1upTilemap	; \ set tile
	STA $0202|!addr,y	; /
	PHY			; \
	LDY #$10		;  | 
	LDA $1E8E|!addr,x	;  | 
	BNE +			;  | 
	LDY #$30		;  | set properties/palette
+	TYA			;  | 
	PLY			;  | 
	ORA #!1upProps		;  | 
	STA $0203|!addr,y	; /
	TYA			; \
	LSR			;  | 
	LSR			;  | set tilesize
	TAY			;  | 
	LDA #$02		;  | 
	STA $0420|!addr,y	; /
	PLB			; 
	JML $02FE70|!addr	; 
endif

if !FailurePose
SetMarioPeaceImage:
	PHB			; 
	PHK			; 
	PLB			; 
	PHX			; 
	LDX $187A|!addr		; x&00 = not riding yoshi
	LDA $1427|!addr		; x&01 = riding yoshi
	BEQ +			; 
	INX #2			; 
+	LDA .Frame,x		; \ set frame
	STA $13E0|!addr		; /
	PLX			; 
	PLB			; 
	LDA #$0D		; 
	JML $00A1FE|!bank	; 

.Frame	db !Get1up,!Get1upY
	db !Fail1up,!Fail1upY

SetMarioLose:
	LDA #$58		; \ set timer to end game
	STA $14AB|!addr		; /
	STA $1427|!addr		; we failed the bonus game :(
	JML $01E04B|!bank	; 
endif

print bytes, " bytes of data inserted."

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; sets up hijacks

org $01DDAC|!bank
	autoclean JML BonusGameInit

org $00C52E|!bank
if !TriggerEvents
	autoclean JML BonusGameEnd
else
	LDY #$0B
	STA $0100|!addr
endif

org $01E291|!bank
if !RewriteCluster1up
	autoclean JML SpawnCluster1up
	NOP

org $02FDBF|!bank
	autoclean JML Cluster1up
	NOP
else
	LDA #$00
	STA $1E02|!addr,y

org $02FDBF|!bank
	LDA $1E52|!addr,x
	CMP #$40
endif

org $00A1F9|!bank
if !FailurePose
	autoclean JML SetMarioPeaceImage
	NOP

org $01E046|!bank
	JML SetMarioLose
	NOP
else
	JSR $CA31
	LDA #$0D

org $01E046|!bank
	LDA #$58
	STA $14AB|!addr
endif