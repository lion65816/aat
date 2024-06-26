;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Conditional Direct Map16 Switch Blocks
;	by MarioFanGamer
;
; This simple UberASM library allows to place Direct Map16 !-blocks in Lunar Magic and still
; let them affect by the switch or even invert the flags, allowing the use of inverted
; !-blocks without the of ObjecTool and custom blocks + ExAnimation (the latter which IMO is
; quite wasteful).
; Call this library from game mode 11 to allow Direct Map16 objects to be able to use it.
; Once done, simply select the DM16 objects you want to affect, go to Edit >
; Conditional Direct Map16... enter the flag number as specified below as well as whether the
; object should disappear or just use the tile of the next Map16 page and you're done.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The type of switch 
; !Regular: Flags set when corresponding switches are pressed and clear when not
; !Inverted: Flags clear when corresponding switches are pressed and set when not
; !Both: Lower four flags contain the bits for the pressed switches and upper four flags for the unpressed ones
!SwitchFlags = !Both

; The conditional direct Map16 flags to affect. Each switch reserves one flag in the order
; green (+0), yellow (+1), blue (+2) and red (+3).
; That means, if a DM16 object should check for the blue switch, you want to enter !CDM16Flag+2.
; If you set the above to !Both then add +4 to get all the inverted values.
; Note that for internal limitations, you can only enter multiples of 4 except if !SwitchFlags
; is set to !Both in which you need to use a multiple of eight instead.
!CDM16Flags = $00
!CDM16FlagsAlt = $08

; Internal defines, do not change!

!Regular = 0
!Inverted = 1
!Both = 2

!CDM16Ram #= $7FC060+(!CDM16Flags>>3)
!CDM16Upper #= !CDM16Flags&$4
!CDM16RamAlt #= $7FC060+(!CDM16FlagsAlt>>3)
!CDM16UpperAlt #= !CDM16FlagsAlt&$4

if !SwitchFlags == !Both && !CDM16Flags&7 > 0
	warn "\!CDM16Flag is not divisible by 8, rounding down to nearest multiple of 8."
elseif !CDM16Flags&3 > 0
	warn "\!CDM16Flag is not divisible by 4, rounding down to nearest multiple of 4."
endif

if !SwitchFlags == !Both && !CDM16FlagsAlt&7 > 0
	warn "\!CDM16FlagAlt is not divisible by 8, rounding down to nearest multiple of 8."
elseif !CDM16FlagsAlt&3 > 0
	warn "\!CDM16FlagAlt is not divisible by 4, rounding down to nearest multiple of 4."
endif

if !SwitchFlags > 2
	error "Error, \!CDM16Flag is an invalid value!"
endif

init:
	; Lock the screen.
	STZ $1A
	STZ $1462|!addr
	STZ $1411|!addr			;> Disable horizontal scroll.
	LDA $95					;\ Disable vertical scroll
	BNE +					;| if the screen is 00.
	STZ $1412|!addr			;/
+
	STA $1B
	STA $1463|!addr
	REP #$20			;Fix layer 2 position
	LDA $1462|!addr
	LSR
	STA $1466|!addr
	STA $1E
	SEP #$20
	RTL

load:
	; Disable the status bar.
	JSL NoStatus_load

	STZ $00
	LDX #$03
-	LDA $1F27|!addr,x
	LSR
	ROL $00
	DEX
	BPL -
if !SwitchFlags == !Both
	LDA $00
	ASL #4
	ORA $00
	EOR #$F0
	STA !CDM16Ram
else
	if !CDM16Upper
		LDA $00
		ASL #4
		STA $00
		LDA !CDM16Ram
		AND #$0F
		ORA $00
		if !SwitchFlags == !Inverted
			EOR #$F0
		endif
	else
		LDA !CDM16Ram
		AND #$F0
		ORA $00
		if !SwitchFlags == !Inverted
			EOR #$0F
		endif
	endif
endif
	STA !CDM16Ram

	STZ $00
	LDX #$03
-	LDA $0DC3|!addr,x	;set in levelASM of each sublevel containing a switch
	LSR
	ROL $00
	DEX
	BPL -
if !SwitchFlags == !Both
	LDA $00
	ASL #4
	ORA $00
	EOR #$F0
	STA !CDM16RamAlt
else
	if !CDM16UpperAlt
		LDA $00
		ASL #4
		STA $00
		LDA !CDM16RamAlt
		AND #$0F
		ORA $00
		if !SwitchFlags == !Inverted
			EOR #$F0
		endif
	else
		LDA !CDM16RamAlt
		AND #$F0
		ORA $00
		if !SwitchFlags == !Inverted
			EOR #$0F
		endif
	endif
endif
	STA !CDM16RamAlt
	RTL
