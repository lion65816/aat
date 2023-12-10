;Act as $025.
;Give credit to MarioFanGamer for the door blocks.

;Note: If you have [!TopPart] set to !False, (becomes a "16x32" door),
;the top part becomes the selected block coordinate to check.

db $42

JMP Return : JMP Return : JMP Return
JMP Return : JMP Return
JMP Return : JMP Return
JMP Return : JMP MarioInside : JMP Return

; Teleport settings
!FixTeleport = !False		; Set to !False so the door uses Mario's position
!FixedDestination = !False	; Set to !True so the destination is set by the door, not the current screen
!TeleDest = $01FD			; What level to teleport to
!TeleSecond = !True		; Activates secondary exits
!TeleMidwayWater = !True	; Teleports to the midway point (non-secondary) / transforms the level into a water level (secondary)

; Door settings
!TopPart = !True			; Only let Mario pass if he's small
!BossDoor = !False			; Doesn't check if Mario is really inside similar to boss doors.

; Don't change these!
!True = 1
!False = 0

incsrc "../../FlagMemoryDefines/Defines.asm"

MarioInside:
	LDA $71			;\If already entering, don't subtract additional keys (just in case)
	BNE Return		;/
	LDA $16			;\  Only enter the door if you press up.
	AND #$08		; |
	BEQ Return		;/ 
	LDA $8F			;\  Surprise: It's a backup of $72
	BNE Return		;/
if !TopPart
	LDA $19			;   If it's the top door part
	BNE Return		;   don't enter if big.
endif
if not(!BossDoor)
	%door_approximity()
	BCS Return		;   Check if Mario is centered enough
endif

;GHB's code:
		%GetWhatKeyCounter()					;>Get what counter based on what level.
		BCS Done						;>If not found, skip.
		TAX							;>Transfer key counter index to X.
		PHX							;>Preserve key counter index.
		LDA !Freeram_KeyCounter,x				;\No keys, no pass
		BEQ DonePullX						;/
	;Set flags to not respawn.
		REP #$20
		LDA $9A							;\BlockXPos = floor(PixelXPos/16)
		LSR #4							;|
		STA $00							;/
		LDA $98							;\BlockYPos = floor(PixelYPos/16)
		if not(!TopPart)
			print "buggy if statement!"
			SEC
			SBC #$0010
			BPL +						;>If the user places the 16x32 door bottom half at the top of the level (results Y=$0000 - upper tile at Y=$FFF0)
			LDA #$0000					;>Then set a bottom limit to avoid invalid index.
			+
		endif
		LSR #4							;|
		STA $02							;/
		SEP #$20
		%BlkCoords2C800Index()
		BCS DonePullX						;>Failsafe prevention: If user places bottom half of 16x32 door at Y=$0000, don't use Y=$FFFF.
		%SearchBlockFlagIndex()
		REP #$20						;\If flag number associated with this block location not found, return.
		CMP #$FFFE						;|
		BEQ DonePullX						;/
		LSR							;>Convert to index number from Index*2.
		SEP #$20
		CLC
		%WriteBlockFlagIndex()
		PLX							;>Reobtain key counter index.
		LDA !Freeram_KeyCounter,x				;\Decrement key counter
		DEC A							;|
		STA !Freeram_KeyCounter,x				;/

	LDA #$0F		;\  Enter door SFX
	STA $1DFC|!addr	;/

if !FixedDestination
	LDX $95			;   The teleport destination and settings are fixed.
	REP #$20
	LDA.w #(((!TeleDest&$1E00)<<3)|(!TeleSecond<<9)|(!TeleMidwayWater<<11)|(!TeleDest&$1FF)|$400)
	LDX #$FF
else
	if !FixTeleport
		LDX #$01
	else
		LDX #$00
	endif
endif
	%teleport_direct()
Return:
Done:
	RTL
DonePullX:
	SEP #$30
	PLX
	RTL

;print "A small locked door."
