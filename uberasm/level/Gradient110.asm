
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
	RTL					; Return 


init:
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

	LDA $19
	BEQ +
	LDA #$01
	STA $19
+	LDA $0DC2|!addr
	BEQ +
	LDA #$01
	STA $0DC2|!addr
+	RTL

.Table1
db $12,$29,$9D
db $21,$28,$9C
db $0A,$27,$9C
db $15,$27,$9B
db $17,$26,$9B
db $0A,$26,$9A
db $20,$25,$9A
db $02,$24,$9A
db $1F,$24,$99
db $0B,$23,$99
db $15,$23,$98
db $0C,$22,$98
db $00

.Table2
db $0D,$4B
db $0C,$4C
db $0C,$4D
db $0C,$4E
db $0C,$4F
db $0C,$50
db $0C,$51
db $0C,$52
db $0C,$53
db $0C,$54
db $0E,$55
db $0C,$56
db $0C,$57
db $0C,$58
db $0C,$59
db $0C,$5A
db $0C,$5B
db $0C,$5C
db $05,$5D
db $00
