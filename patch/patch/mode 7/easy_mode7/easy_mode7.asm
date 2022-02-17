@asar 1.50
; === ExE Boss’s Changes ===
;
; - Full compatibility with all of the original game’s Mode 7 bosses
;
; - Added a subroutine for uploading the Mode 7 GFX and Tilemap to VRAM
;
; - The Layer 3 status bar can now enabled by setting the Layer 3 absolute
;       priority bit of $3E, this then works the same way
;       as in the Koopaling/Reznor battles by using IRQ to change the
;       background mode at scanline $24 ($26 with Super Status Bar) to mode 1.
;
; === HUFLUNGDU'S NOTES ===
;
; This patch makes it so that SMW's Mode 7 mirrors as well as rotation and scaling routines can be used in any level where the BG Mode ($3E) is set to 7.
;
; === MATHOS'S NOTES ===
;
; (Fortunately ?) this patch doesn't automatically disable scrolling when you go into Mode 7.
; So you'll have to do this manually in LM.
; However, it disables ExAnimation (so that you don't have VRAM uploads that may glitch your tilemap)
;
; Plus, it appears that when you go into Mode 7, the Mode 7 image acts like Iggy/Larry's platform: that is to say, it tilts.
; Animated lava sprite tiles are also present at the bottom of the screen. However, Iggy/Larry's platform interaction is absent.
; So, to disable these, I implemented 2 minor tweaks. Both are enabled by default.
; Obvious consequences are, if you use them, Iggy/Larry's boss battles will be "unusable" even if they'll stay playable.
; To be precise, Iggy/Larry will stay to the right side of the platform and will be able able to be thrown into lava only by this side.
; 
; Important fact:  when you go into Mode 7, the status bar and layer 2 background disappear: THE WHOLE SCREEN GOES INTO MODE 7.
; So if you're skilled enough, you could put some custom static sprites to have a minimal scenery.
;
; It is also to be noted that when you use a Mode 7 background, you'd better not use anything that changes VRAM, not even parts of it.
; That include question mark blocks, for example, because as they transform into brown used ones, they change the tilemap.
;
incsrc easy_mode7.cfg	;> Load configuration

print ""
print " Easy Mode 7 v1.1 – © HuFlungDu "
print " Updated by ExE Boss and Mathos "
print " ============================== "
print ""

	!base = $0000
	!base2 = $800000

if read1($00FFD5) == $23
	sa1rom
	!base = $6000
	!base2 = $000000
endif

math	pri	on	;\ Asar defaults to Xkas settings instead
math	round	off	;/ of proper math rules, this fixes that.

	function is_less_equal_zero(value) = (value-1)>>31

	function greater_equal(val_a, val_b) = is_less_equal_zero(val_b-val_a)

	function get_bank_byte(address) = (address&$FF0000)>>16

;-------------------------------------
; Fix the Iggy/Larry battles

org $00988C
	autoclean JSL IggyLarry_Lava

org $03C0C8
	autoclean JML IggyLarry_Platform
	NOP

;-------------------------------------

org $0081C6
	autoclean JML MirrorCheck
	NOP

org $008385
	autoclean JML Mode7Pos
	NOP
	BMI $2E

org $00A28A
	autoclean JML ScrollRotateCheck
	NOP

org $00A5AF
	autoclean JML ExAnimCheck
	NOP

;-------------------------------------

if !UploadMode7gfxSubroutine
	org !UploadMode7gfxSubroutine
	if greater_equal(get_bank_byte(!UploadMode7gfxSubroutine),$10)
		org !UploadMode7gfxSubroutine-8
		db $53,$54,$41,$52	;\ Asar complains about the lack of `;@xkas` when
		dw UploadMode7gfx_end-UploadMode7gfx	;| it finds `db "STAR"`.
		dw (UploadMode7gfx_end-UploadMode7gfx)^$FFFF	;/
	endif
	UploadMode7gfx:
		autoclean JML .main
	.end:
endif

;-------------------------------------
freedata	;> This doesn’t affect the program data bank registers, so toss this into banks $40+

; This makes SMW use the Mode 7 mirrors in ANY Mode 7 level instead
; of just boss levels.

MirrorCheck: {
	LDA $3E
	AND #$07
	CMP #$07
	BEQ .customMode7level
	LDA $0D9B|!base
	BMI .mode7level
	JML $0081CE|!base2

.mode7level:
	JML $0082C4|!base2

.customMode7level:
	LDA $3E	;\ Check if the Layer 3 status bar should be enabled
	BIT #$08	;/
	BEQ ..disableStatusBar
	LDA #$14	;\ Ensure that only the Layer 3 status bar and sprites
	STA $212C	;| are visible on the status bar scanlines (i.e. hide L1/L2 garbage tiles)
	STZ $212D	;/
	LDA #$00	;> Set battle mode to #$00 to enable the status bar subroutine
	BRA ..return
..disableStatusBar:
	LDA #$07	;> Set battle mode to #$07 to disable the status bar subroutine
..return:
	STA $0D9B|!base
	JML $0082C4|!base2
}

Mode7Pos: {
	LDA $3E
	AND #$07
	CMP #$07
	BEQ .customMode7level
	LDA #$81
	LDY $0D9B|!base
	JML $00838A|!base2

.customMode7level:
	LDA $3E
	STA $2105
	LDA $0D9D|!base
	STA $212C
	LDA $0D9E|!base
	STA $212D
	LDA #$81
	JML $0083BA|!base2
}

;-------------------------------------
; Handles rotation and scaling.

ScrollRotateCheck: {
	LDA $3E
	AND #$07
	CMP #$07
	BEQ .mode7level
	LDA $0D9B|!base
	BMI .bosslevel
	JML $00A295|!base2

.mode7level:
	JSR .jsl00987D
	JML $00A295|!base2

.bosslevel:
	JSR .jsl00987D
	JML $00A2A9|!base2

.jsl00987D:
    PHK
    PEA.w ..end-1
	PEA.w $84CF-1
	JML $00987D|!base2
..end:
	RTS
}

;-------------------------------------
; Turns off ExAnimation in Mode 7 levels.

ExAnimCheck: {
	JSL ResetMode7Registers
	LDA $3E
	AND #$07
	CMP #$07
	BEQ .mode7level
	LDA $0D9B|!base
	BMI .mode7level
	JML $00A5B9|!base2

.mode7level:
	JML $00A5B4|!base2
}

;-------------------------------------
; Fixes the Iggy/Larry battle mode

IggyLarry: {
.Lava:
if !FixIggyLarry
	LDA $0D9B|!base
	CMP #$80
	BNE ..return
	JSL $03C0C6|!base2
endif
..return:
	RTL

.Platform:
if !FixIggyLarry
	BNE ..return
	LDA $0D9B|!base
	CMP #$80
	BNE ..return
	JSR ..jsl03C11E
endif
..return:
	JML $03C0CD|!base2

..jsl03C11E:
    PHK
    PEA.w ...end-1
	PEA.w $C02A-1
	JML $03C11E|!base2
...end:
	RTS
}

UploadMode7gfx_main: {
	STX $4302	;\ Address where our data is.
	STA $4304	;/ Bank where our data is.
	STZ $4300	;> Set mode to 1 register write once.

.processY:
	TYA
	BEQ .return

	AND #$03	: CMP #$03	: BEQ ..interleaved	;\ Get type of DMA
	TYA	: AND #$01	: BNE ..gfx	;|
	TYA	: AND #$02	: BNE ..tilemap	;/
	BRA .return
..tilemap:
	STZ $2115	;> Increase on $2118 write.
	LDA #$18	;\ Writing to $2118.
	STA $4301	;/
	BRA .write
..gfx:
	LDA #$80	;\ Increase on $2119 write.
	STA $2115	;/
	LDA #$19	;\ Writing to $2119.
	STA $4301	;/
	BRA .write
..interleaved:
	LDA #$80	;\ Increase on $2119 write.
	STA $2115	;/
	LDA #$18	;\ Writing to $2118/19.
	STA $4301	;/
	LDA #$01	;\ Set mode to 2 registers write once.
	STA $4300	;/

.write:
	LDX #$0000	;\ Set where to write in VRAM...
	STX $2116	;/ ...and since Mode 7 is layer 1 we can just put $0000 here.
	LDX #$4000	;\ Size of our data.
	STX $4305	;/
	LDA #$01	;\ Start DMA transfer on channel 0.
	STA $420B	;/

.return:
	RTL
}

ResetMode7Registers: {
	PHP : REP #$20
	STZ $2A : STZ $2C	;> Mode 7 transformation origin
	STZ $2E : STZ $30	;\ Mode 7 transformation matrix
	STZ $32 : STZ $34	;/
	STZ $36	;> Mode 7 rotation	\ Merged together into the above
	STZ $38	;> Mode 7 scaling	/ matrix during V-blank
	STZ $3A : STZ $3C	;> Mode 7 translation
	PLP : RTL
}

print "Installed at $",hex(MirrorCheck)," using ",freespaceuse," bytes of free ROM"
if (!UploadMode7gfxSubroutine) : print "Mode 7 graphics DMA subroutine located at: JSL $",hex(!UploadMode7gfxSubroutine|!base2)
print ""
