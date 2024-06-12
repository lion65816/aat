;================================;
;quickass autowalk by mathos edited by Tattletale
;but also edited by Daizo, which is a thing apparently
;================================;

; limit should be between $00-$7F, otherwise you'll walk backwards
!SlowSpeed = $00
!MedSpeed = $10    ; player x speed: see https://www.smwcentral.net/?p=nmap&m=smwram#7E007B for details
!FastSpeed = $40

!Direction = 1  ; 1 = right, 0 = left : see https://www.smwcentral.net/?p=nmap&m=smwram#7E0076 for details
                ; make sure it's coherent with your speed !


;Controller buttons currently held down. Format: byetUDLR.
;b = A or B; y = X or Y; e = select; t = Start; U = up; D = down; L = left, R = right.
!HeldDownDisabler15 = %00001111

;Controller buttons newly pressed this frame. Format: byetUDLR.
;b = B only; y = X or Y; e = select; t = Start; U = up; D = down; L = left, R = right.
!NewlyPressedDisabler16 = %00001111
       
;Controller buttons currently held down. Format: axlr----.
;a = A; x = X; l = L; r = R, - = null/unused.
!HeldDownDisabler17 = %00000000

;Controller buttons newly pressed this frame. Format: axlr----.
;a = A; x = X; l = L; r = R, - = null/unused.
!NewlyPressedDisabler18 = %00000000

;Free RAM addresses to help control the walking animation/pose for Demo.
!FreeRAM1 = $1696|!addr
!FreeRAM2 = $18F6|!addr
!FreeRAM3 = $18C5|!addr

;===========================================================================================================================================

load:
	JSL NoStatus_load
	LDA #$01		;\ Always keep Demo big.
	STA $19			;/
	LDA #$03		;\ Give Iris Demo's palette.
	STA $1477|!addr	;/ Handled by global_code.asm.
	RTL

init:
	LDA $7E : STA $18C6|!addr
    LDA.b #!Direction
	STA $76

	LDA.b #!MedSpeed
	STA !FreeRAM3

	STZ !FreeRAM1
	STZ !FreeRAM2
	RTL

main:
	; Walk speed system
	LDA $15 : AND #$03 ; left or right
	TAY
	LDX #$01
-	LDA !FreeRAM3
	CMP .speeds,y
	BEQ +
	BCS .bigger
	INC !FreeRAM3
	BRA ++
.bigger
	DEC !FreeRAM3
++	DEX : BPL -
	BRA +
	.speeds
	db !MedSpeed,!FastSpeed,!SlowSpeed,!FastSpeed
+

	; print cart system
	JSR PrintCart

	LDA #$08
	STA $1496|!addr
;	INC !FreeRAM1
;	LDA !FreeRAM1
;	CMP #$08
;	BNE +
;	STZ !FreeRAM1
;	INC !FreeRAM2
;	LDA !FreeRAM2
;	CMP #$03
;	BNE +
;	STZ !FreeRAM2
;
;	+
;	LDA !FreeRAM2
	LDA $7B : BEQ +
	LDA $94 : LSR #2 : AND #$03 : CMP #$03 : BNE + : DEC #2 : +
+	STA $13E0|!addr
	LDA $71
	CMP #$06
	BNE +
	LDA #$2A
	STA $100|!addr
	+
	LDA $15
	AND #~!HeldDownDisabler15
	STA $15

	LDA $16
	AND #~!NewlyPressedDisabler16
	STA $16

	LDA $17
	AND #~!HeldDownDisabler17
	STA $17

	LDA $18
	AND #~!NewlyPressedDisabler18
	STA $18
	
    LDA.b #!Direction
	STA $76
    LDA $77
    AND.b #(((!Direction+1)%2)+1)
    BNE .nospd
    LDA !FreeRAM3
	STA $7B
    .nospd:
    
    STZ $1401|!addr
    LDA #$80
	TRB $16
	TRB $18
	RTL
	RTL
   

	; old fasioned way; idk how maxtile works.
PrintCart:

	REP #$20
;	LDA $D1 : SEC : SBC $1A
	LDA $D1 : SEC : SBC $1462|!addr ; least jarring 1 frame delay (I can't figure out how to fix it)
;	LDA $94 : SEC : SBC $1A
;	LDA $94 : SEC : SBC $1462|!addr
	STA $00
	SEP #$20

;	LDA $94
;	LSR #2 : AND #$01
;	ASL : STA $00

;	LDA $010B
;	SEC : SBC #$E1
;	ASL ;#2 ; 4
	;CLC : ADC $00
;	STA $00

	LDY #$B0
	LDX #$01
-
	LDA $00 : CLC : ADC .xpos,x : STA $0200|!addr,y
	LDA $80 : CLC : ADC #$10 : STA $0201|!addr,y
	
	LDA .carttile,x : STA $0202|!addr,y
	LDA #$63 : STA $0203|!addr,y
	
	PHY : TYA : LSR #2 : TAY
	LDA #$02 : STA $0420|!addr,y
	PLY : INY #4
	DEX : BPL -

	RTS
.xpos
	db $20-6,$10-6
.carttile
	db $A0,$A2