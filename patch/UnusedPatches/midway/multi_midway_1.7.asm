;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Multiple Midway Points 1.6 patch.
;; By Kaijyuu
;; Fixed on Lunar Magic 2.4+ by LX5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

incsrc multi_midway_defines.asm

!sa1	= 0			; 0 if LoROM, 1 if SA-1 ROM.
!dp	= $0000			; $0000 if LoROM, $3000 if SA-1 ROM.
!addr	= $0000			; $0000 if LoROM, $6000 if SA-1 ROM.
!bank	= $800000		; $80:0000 if LoROM, $00:0000 if SA-1 ROM.
!bank8	= $80			; $80 if LoROM, $00 if SA-1 ROM.
!7ED000 = $7ED000		; $7ED000 if LoROM, $40D000 if SA-1 ROM.

if read1($00ffd5) == $23
	!sa1	= 1
	!dp	= $3000
	!addr	= $6000
	!bank	= $000000
	!bank8	= $00
	!7ED000 = $40D000		; $7ED000 if LoROM, $40D000 if SA-1 ROM.
	!RAM_Midway	= !RAM_Midway_SA1
	sa1rom
endif

org $05D842
	autoclean JML mmp_main

ORG $05D9DE
	autoclean JML secondary_exits	; additional code for secondary exits

org $048F74
	autoclean JML reset_midpoint	; hijack the code that resets the midway point

org $05DAA3
	autoclean JML no_yoshi		; make secondary exits compatible with no yoshi intros

freecode

incsrc multi_midway_tables.asm

mmp_main:
	LDA $141A|!addr		; skip if not the opening level
	BNE .return
	LDA $1B93|!addr		; prevent infinite loop if using a secondary exit
	BNE .return
	LDA $0109|!addr
	BNE .code_05D8A2
	JSR get_translevel
	TAY 
	;LDY $13BF|!addr		; get translevel number
	LDA $1EA2|!addr,y	; get level settings
	AND #$40		; check midway point flag
	BEQ .return		; return if not set
	REP #$30
	TYA			; stick translevel number in A
	AND #$00FF		; clear high byte of A
	ASL			; x 2
	STA $0E			; store to scratch
	TYX			; stick y in x temporarily
	LDA !RAM_Midway,x	;\ get midway point number to use
	AND #$00FF		; |
	ASL			;/
	LDY #$0000		; 
	CLC
.loop
	ADC $0E			; multiply it by the number of midway points in use per level
	INY
	CPY.w #!total_midpoints
	BCC .loop
	TAX			; stick in y
	LDA.l level_mid_tables,x	; get new level number
	;CMP #$1000		; check secondary exit flag
	;BCS .secondary_exit	; use secondary exit
	BMI .secondary_exit		; If negative, use secondary exit
	AND #$01FF		; failsafe
	STA $0E			; store level number
	JML $05D8B7|!bank
.return
;	LDA $0109|!addr
;	BNE .code_05D8A2
	JML $05D847|!bank
.code_05D8A2
	JML $05D8A2|!bank

.secondary_exit
	print "Secondary Exit Code $",pc
; <MFG> Here is where I made the biggest changes
	;AND #$0FFF		; clear secondary exit flag here
	SEP #$30		; No need to be in 8-bit mode anymore
	STA $19B8|!addr		; store secondary exit number (low)
	XBA				; We only need to modify the high byte
	PHA				; Preserve exit number
	AND #$20		; Only the water flag
	LSR #2			; Move the water flag into the correct bit
	ORA #$06		; Set the appropriate flags
	STA $19D8|!addr		; Dunno if this is faster than storing to scratch RAM and then store the value there
	PLA				; Now to the secondary exit number.

	LSR				; Move bit 0 into the carry flag
	PHP				; We shift back so the carry flag gets destroyed 
	ASL #3			; Three shifts because the next one is a ROL
	PLP				; Get the carry flag back
	ROL				; I'm a genious. ^.^
	TSB $19D8|!addr		; store secondary exit number (high and properties)
	STZ $95			; set these to 0
	STZ $97
	JML $05D7B3|!bank	; return and load level at a secondary exit position
; </MFG>

secondary_exits:
	LDX $1B93|!addr		; check if using a secondary exit for this
	BNE .return		; if so, skip the code that sets mario's x position to the midway entrance
	STA $13CF|!addr		; restore old code
	LDA $02			; restore old code
	JML $05D9E3|!bank	; return
.return	
	JML $05D9EC|!bank	; return without setting mario's x to the midway entrance

reset_midpoint:
	STA $1EA2|!addr,x	; restore old code
	INC $13D9|!addr		;
	LDA !RAM_Midway,x
	AND #$FF00		; reset midway point number too
	STA !RAM_Midway,x
	JML $048F7A|!bank	; return

no_yoshi:
	STZ $1B93|!addr		; reset this (prevents glitch with no yoshi intros and secondary entrances)
	LDA $05D78A|!bank,x	; restore old code
	JML $05DAA7|!bank	; return

get_translevel:
	LDY $0DD6|!addr		;get current player*4
	LDA $1F17|!addr,y		;ow player X position low
	LSR #4
	STA $00
	LDA $1F19|!addr,y		;ow player y position low
	AND #$F0
	ORA $00
	STA $00
	LDA $1F1A|!addr,y		;ow player y position high
	ASL
	ORA $1F18|!addr,y		;ow player x position high
	LDY $0DB3|!addr		;get current player
	LDX $1F11|!addr,y		;get current map
	BEQ +
	CLC : ADC #$04		;if on submap, add $0400
+	STA $01
	REP #$10
	LDX $00
	LDA !7ED000,x		;load layer 1 tilemap, and thus current translevel number
	STA $13BF|!addr
	SEP #$10
	RTS

print freespaceuse