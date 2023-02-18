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
db $04,$4D,$9C
db $08,$4E,$9C
db $08,$4F,$9C
db $08,$50,$9C
db $09,$51,$9D
db $09,$52,$9D
db $0A,$53,$9D
db $0A,$54,$9D
db $0B,$55,$9D
db $0B,$56,$9D
db $0D,$57,$9D
db $09,$58,$9D
db $04,$58,$9E
db $10,$59,$9E
db $12,$5A,$9E
db $17,$5B,$9E
db $2A,$5C,$9E
db $0B,$5D,$9E
db $00

.Table2
db $02,$20
db $05,$21
db $05,$22
db $06,$23
db $05,$24
db $06,$25
db $05,$26
db $06,$27
db $06,$28
db $07,$29
db $06,$2A
db $06,$2B
db $07,$2C
db $07,$2D
db $08,$2E
db $08,$2F
db $08,$30
db $09,$31
db $09,$32
db $0B,$33
db $0B,$34
db $0D,$35
db $10,$36
db $16,$37
db $1E,$38
db $00

load:
    lda #$01
    sta $13E6|!addr
    rtl