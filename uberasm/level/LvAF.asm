!InputByte1 = #%00000000

; Below, enter the buttons you want disbaled. 1 = disabled, 0 = enabled
; Format = axlr----
; a = A; x = X only; l = L; r = R, - = null/unused.
; In this case the 4 least significant bits don't do anything and should be 0.
; Example: %10110000 would disable A, L and R respectively.
; setting bit 6 here (x) still allows you to still run, and sort of carry some stuff.
; I know. SMW is weird. 
; Disabling bit 6 in both input bytes completely disables carrying and running.


!InputByte2 = #%00110000

main:
	LDA !InputByte1		; Load input
	AND #%10110000		; Bitmask of which bits not to run through $15
	BEQ +				; If none of these bits are set, branch
	EOR !InputByte1		; Flip masked bits out for now
	TRB $15				; Reset bits for currently held down controller buttons
	TRB $16
	EOR !InputByte1		; Flip back the bits previously disabled
	TSB $0DAA|!addr		; And set those ones here, allowing to hold some buttons.
	TSB $0DAB|!addr		; Same for second controller
	BRA ++				; Branch to second input
+	LDA !InputByte1		; Reload data
	TSB $0DAA|!addr		;\ Since none of the masked bits were set,
	TSB $0DAB|!addr		;|
	TRB $15				;/ Just disable them at addresses as normal. (including second controller)
	TRB $16
++	LDA !InputByte2		;\ Disable second byte normally as there are no exeptions.
	TRB $17				;|
	TSB $0DAC|!addr		;/
	TSB $0DAD|!addr		; Same for controller 2
	RTL

init:
    LDA #$01
    STA $140B|!addr
   

		LDA #$00
		STA $4330
		LDA #$02
		STA $4340

		LDA #$32
		STA $4331
		STA $4341

		REP #$20
		LDA.w #.Table2
		STA $4332
		LDA.w #.Table1
		STA $4342

		SEP #$20

		LDA.b #.Table2>>16
		STA $4334
		LDA.b #.Table1>>16
		STA $4344

		LDA #$18
		TSB $0D9F|!addr

		RTL

.Table1
db $01,$36,$42
db $0D,$37,$42
db $0D,$38,$43
db $0F,$39,$44
db $10,$3A,$45
db $11,$3B,$46
db $13,$3C,$47
db $16,$3D,$48
db $1A,$3E,$49
db $26,$3F,$4A
db $2C,$3F,$4B
db $00

.Table2
db $05,$80
db $0B,$81
db $0C,$82
db $0D,$83
db $0E,$84
db $0E,$85
db $10,$86
db $12,$87
db $14,$88
db $19,$89
db $24,$8A
db $28,$8B
db $00

load:
    lda #$01
    sta $13E6|!addr
    rtl
