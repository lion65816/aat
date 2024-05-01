if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!gsu = 1
	!bank = $000000
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
	!bank = $000000
endif

!yellow = $0C
!blue   = $09
!red    = $0A
!green  = $0B

org $038882|!bank			;change Mega mole palette
db $09					; change palette from 8 to C (YXPPCCCT $x1 -> $x9)

org $02A2E7|!bank			;change hammer extended GFX from B to A
db $45,$45,$05,$05			; changed palette from B to A
db $85,$85,$C5,$C5			; (YXPPCCCT: $x7 -> $x5)

ORG $07F47D|!bank			;Flying Mushroom
db $2A					;change palette from 8 to D (green)

org ($07F3FE+$1B)|!bank  ; Football
db $05  ; palette A | originally: db $01

org ($07F3FE+$7D)|!bank  ; P-Balloon
db $25  ; palette A | originally: db $21

org ($07F3FE+$2E)|!bank  ; Spike Top
db $15  ; palette A | originally: db $19

org $02CAFA|!bank        ; Chuck Arm
db $4B,$0B  ; palette D | originally db $47,$07

; Fix Diggin' Flower arm palette.
org $02CB96|!bank
	db $4B,$0B		; Use palette D (originally: db $47,$07)

; Allow the palette of the Falling Spike to be changed. By PSI Ninja
mole_palette:
	LDA !15F6,x		;\ Use palette A instead of
	ORA #$04		;| palette 8 for the mole.
	STA !15F6,x		;/
	LDA !9E,x		;\ Original code.
	CMP #$4D		;/
	RTL
	
; Allow the palette of the Falling Spike to be changed. By PSI Ninja
org $03921B|!bank
	autoclean JSL falling_spike_palette
	NOP

freecode

falling_spike_palette:
	LDA #$E0			;\ Original code.
	STA $0302|!addr,y	;/
	LDA #$45			;\ Use palette A instead of palette 8.
	STA $0303|!addr,y	;/
	RTL
	
; Overworld Yoshi Palette Fix
function prop(pal) = (pal-8)*2

org $048CDF
	db prop(!yellow)

org $048CE1
	db prop(!blue)

org $048CE3
	db prop(!red)

org $048CE5
	db prop(!green)
	
org $00A0EB : db $20

; Overworld Switch Palace Palette Fix
org $04F365
    autoclean jml set_props

freedata

set_props:
    phx
    ldx $13D2|!addr
    lda.l palette-1,x
    plx
    jml $04F36A|!bank


palette:
    db prop(!yellow),prop(!blue),prop(!red),prop(!green)
    
; Use different Banzai Bill palettes depending on the level. By PSI Ninja
org $02D608|!bank
	autoclean JSL banzai_palette

freecode

banzai_palette:
	PHA
	LDA $13BF|!addr
	CMP #$07
	BNE +
	PLA
	ORA #$02			;> If Level 7, use palette row F.
	STA $0303|!addr,y
	BRA ++
+
	PLA
++
	INY #4				;> Original code.
	RTL