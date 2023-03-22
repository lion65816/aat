;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Parallax Toolkit
;
; This toolkit allows you to calculate a more "dynamic"
; scrolling HDMA. This includes more fine parallax
; and waves.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; In total 448 bytes per table
!HDMATable = $7F1853

if !sa1
	!HDMATable = $418AFF	; If using SA-1
endif

; Init code
; This one sets up the HDMA for the parallax scrolling.
init:
	STA $4351
	LDA #$42
	STA $4350
	LDA.b #HDMAPtrs
	STA $4352
	LDA.b #HDMAPtrs>>8
	STA $4353
	LDA.b #HDMAPtrs>>16
	STA $4354
	LDA.b #!HDMATable>>16
	STA $4357
	LDA #$20
	TSB $0D9F|!addr
RTL

HDMAPtrs:
db $F0 : dw !HDMATable
db $F0 : dw !HDMATable+$E0

; NMI Code
; While this looks redundant, there is a practical reason:
; Calculating the HDMA table is a race against time if you don't buffer them.
; If the electron beam is faster than the SNES, only parts of the screen gets updated
; (also known as screen tearing). To avoid this, we first calculate the table and then
; upload it onto a second HDMA table
; If you take too long. This isn't too noticable with simple parallax scrolling
; but handling polygons (such as those in Yoshi's Island or Donkey Kong Country 2)
; will look weird with a double buffer.
; Do note that this only works if the table and buffer are on different memory.
; Store the to HDMA.

; Main Code:
; That's the heart of the code.
; Input:
;   A (16-bit): Parallax table address
;   X (8-bit): Parallax table bank.
;   $08: Frame counter for waves
;   $0A: Base X position (should be layer 1 X position)
;   $0C: Base Y position (should be layer 3 Y position)

; Scratch RAM for coders:
; $00: Wave amplitude / radius
; $02: Wavelength (only high byte)
; $04: Max Y position
; $06: New position (for waves)
; $08: Frame counter
; $0A: Base X position (should be layer 1 X offset)
; $0C: Base Y position (should be layer 3 Y offset at start)
; $0E: Pointer to HDMA table (just requires A).
; $8A: Index to HDMA table
; $8C: Current wave "angle"
; $8E: Scratch RAM for SNES multiplication
main:
	STA $0E
	PHB
	PHX
	PLB
	LDY #$00
	STY $8A
	STY $8B
	STY $2250		; Multiply
.Loop
	LDA ($0E),y
	INY
	TAX
	LDA.l ParallaxModes,x
	PHA
	RTS

ParallaxModes:
dw .SimpleParallax-1
dw .ParallaxWaves-1

.SimpleParallax
if !sa1
	LDX #$00
	STX $2250		; Multiply
	LDA $0A			; Get X position
	STA $2251
	LDA ($0E),y		; Get scroll factor
	STA $2253
	INY #2
	LDA ($0E),y		; Get max. Y position
	STA $04
	INY #2
	PHY
	REP #$10
	LDX $8A			; Get screen index
	LDA $2307		; Only get middle bytes of scroll factor
	LDY $04
else
	LDA ($0E),y		; Get scroll factor
	INY #2
	JSR Multiply
	LDA ($0E),y		; Get max. Y position
	STA $04
	INY #2
	PHY
	REP #$10
	LDX $8A			; Get screen index
	LDA $06			; Get the result
	LDY $04
endif
..Loop
	CPY $0C
	BCC ..Return	; Not on-screen? Go get the next lines!
	STA !HDMATable,x
	INX #2			; Increment HDMA index
	CPX #$01C0		; Terminate if end of the screen
	BEQ .Terminate
	INC $0C			; Increment heigth
	BRA ..Loop

..Return
	STX $8A
	SEP #$10
	PLY
JMP main_Loop

.Terminate	; If nothing to loop, terminate.
	SEP #$30
	PLY
	PLB
RTL

.ParallaxWaves
if !sa1
	LDA $0A			; Get X position
	STA $2251
	LDA ($0E),y		; Get scroll factor
	STA $2253
	INY #2
	LDA ($0E),y		; Get max. Y position
	STA $04
	INY #2
	LDA ($0E),y
	INY #2
	STA $02			; Wave properties
	AND #$00FE
	ASL
	STA $00
	LDA $02			; High byte for signed multiplication
	AND #$FF00
	STA $02
	LDA $0C
	ASL				; Double the screen height 
	CLC : ADC $08	; This one fixes the wavelength to the screen.
	STA $8C			; So the wave doesn't move when moving up the screen.
	PHY
	REP #$10
	LDA $2307		; Only get middle bytes of scroll factor
	STA $06
	LDY $04
..Loop
	CPY $0C
	BCC ..Return	; Not on-screen? Go get the next lines!
	LDX $8C
	LDA.l SineTable,x
	STA $2251
	LDA $02			; Remember: The high byte is the amplitude and signed
	STA $2253
	LDX $8A			; Get screen index
	ASL $2306		; Rounding
	LDA $2308		; Get only the last two bytes of the result
	ADC #$0000
else
	LDA ($0E),y		; Get scroll factor
	INY #2
	JSR Multiply
	LDA ($0E),y		; Get max. Y position
	STA $04
	INY #2
	LDA ($0E),y
	INY #2
	STA $02			; Wave properties
	AND #$00FF
	ASL
	STA $00
	LDA $02
	AND #$FF00
	STA $02
	LDA $0C
	ASL				; Double the screen height 
	CLC : ADC $08	; This one fixes the wavelength to the screen.
	STA $8C			; So the wave doesn't move when moving up the screen.
	PHY
	REP #$10
	LDY $04
..Loop
	CPY $0C
	BMI ..Return	; Not on-screen? Go get the next lines!
	LDX $8C
	LDA.l SineTable,x
	SEP #$20
	STA $211B
	XBA
	STA $211B
	LDA $03			; Remember: The amplitude is signed
	STA $211C
	ASL $2134
	REP #$20
	LDA $2135
	LDX $8A			; Get screen index
endif
	ADC $06
	STA !HDMATable,x
	INX #2			; Increment HDMA index
	CPX #$01C0		; Terminate if end of the screen
	BEQ .Terminate
	STX $8A
	INC $0C			; Increment heigth
	LDA $8C
	ADC $00			; $00 is always even and bit 0 gets cleared out afterwards.
	AND #$01FE		; So do I really need to clear carry here?
	STA $8C
	BRA ..Loop

..Return
	SEP #$10
	PLY
JMP main_Loop

if not(!sa1)
; We need to kind of recreate a 16-bit times 16-bit multiplication.
; It's costy since we need four bytes to store the result (and we
; have used up quite a bit of scratch RAM already).
; However, it's less dramatic than it actually sounds: We only care for the
; middle bytes of the result. The low byte is a fractional value, only
; useful for rounding, and the high byte doesn't matter as the values should
; never become so large so that it becomes a non-zero value.
; In addition, I only used two NOPs. The rest of the wait cycles are used
; for important processes.
Multiply:
print "SNES Multiplication: $",pc
	STA $8E			; Preserve A
	SEP #$20
	LDA $0A
	STA $4202
	LDA $8E
	STA $4203
	NOP
	LDA #$80
	CLC : ADC $4216	; (Subpixel) Get carry for rounding
	LDA $4217		; (Actual pixel) Load high byte (don't add carry yet)
	STA $06			; RAM in object code (so scratch RAM)
	LDA $8F
	STA $4203
	STZ $07			; Not only for 16-bit addition but also to for the multiplication
	REP #$20
	LDA $4216
	ADC $06
	STA $06
	SEP #$20
	LDA $0B
	STA $4202
	LDA $8E
	STA $4203
+	REP #$21
	LDA $06
	ADC $4216
	STA $06
	SEP #$20
	LDA $8F
	STA $4203
	LDA $07
	CLC : ADC $4216
	STA $07
	REP #$20
RTS
endif

SineTable:
dw $0000,$FFFA,$FFF3,$FFED
dw $FFE7,$FFE1,$FFDA,$FFD4
dw $FFCE,$FFC8,$FFC2,$FFBC
dw $FFB6,$FFB0,$FFAA,$FFA4
dw $FF9E,$FF98,$FF93,$FF8D
dw $FF87,$FF82,$FF7C,$FF77
dw $FF72,$FF6D,$FF68,$FF63
dw $FF5E,$FF59,$FF54,$FF4F
dw $FF4B,$FF47,$FF42,$FF3E
dw $FF3A,$FF36,$FF32,$FF2F
dw $FF2B,$FF28,$FF24,$FF21
dw $FF1E,$FF1B,$FF19,$FF16
dw $FF13,$FF11,$FF0F,$FF0D
dw $FF0B,$FF09,$FF08,$FF06
dw $FF05,$FF04,$FF03,$FF02
dw $FF01,$FF01,$FF00,$FF00
dw $FF00,$FF00,$FF00,$FF01
dw $FF01,$FF02,$FF03,$FF04
dw $FF05,$FF06,$FF08,$FF09
dw $FF0B,$FF0D,$FF0F,$FF11
dw $FF13,$FF16,$FF19,$FF1B
dw $FF1E,$FF21,$FF24,$FF28
dw $FF2B,$FF2F,$FF32,$FF36
dw $FF3A,$FF3E,$FF42,$FF47
dw $FF4B,$FF4F,$FF54,$FF59
dw $FF5E,$FF63,$FF68,$FF6D
dw $FF72,$FF77,$FF7C,$FF82
dw $FF87,$FF8D,$FF93,$FF98
dw $FF9E,$FFA4,$FFAA,$FFB0
dw $FFB6,$FFBC,$FFC2,$FFC8
dw $FFCE,$FFD4,$FFDA,$FFE1
dw $FFE7,$FFED,$FFF3,$FFFA
dw $0000,$0006,$000D,$0013
dw $0019,$001F,$0026,$002C
dw $0032,$0038,$003E,$0044
dw $004A,$0050,$0056,$005C
dw $0062,$0068,$006D,$0073
dw $0079,$007E,$0084,$0089
dw $008E,$0093,$0098,$009D
dw $00A2,$00A7,$00AC,$00B1
dw $00B5,$00B9,$00BE,$00C2
dw $00C6,$00CA,$00CE,$00D1
dw $00D5,$00D8,$00DC,$00DF
dw $00E2,$00E5,$00E7,$00EA
dw $00ED,$00EF,$00F1,$00F3
dw $00F5,$00F7,$00F8,$00FA
dw $00FB,$00FC,$00FD,$00FE
dw $00FF,$00FF,$0100,$0100
dw $0100,$0100,$0100,$00FF
dw $00FF,$00FE,$00FD,$00FC
dw $00FB,$00FA,$00F8,$00F7
dw $00F5,$00F3,$00F1,$00EF
dw $00ED,$00EA,$00E7,$00E5
dw $00E2,$00DF,$00DC,$00D8
dw $00D5,$00D1,$00CE,$00CA
dw $00C6,$00C2,$00BE,$00B9
dw $00B5,$00B1,$00AC,$00A7
dw $00A2,$009D,$0098,$0093
dw $008E,$0089,$0084,$007E
dw $0079,$0073,$006D,$0068
dw $0062,$005C,$0056,$0050
dw $004A,$0044,$003E,$0038
dw $0032,$002C,$0026,$001F
dw $0019,$0013,$000D,$0006

