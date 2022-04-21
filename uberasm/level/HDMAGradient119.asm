;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; uberASM to disable controller buttons by janklorde   	;
; Special thanks to RussianMan							;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is a simple uberASM that allows you to disable  	;
; any combination of controller inputs. You cannot     	;
; disable combinations of buttons without disabling    	;
; them individually. For example, if you wanted Y and B	;
; to function individually but Y+B to be disabled, this	; 
; is not possible. Please use sensibly, disabling all  	;
; buttons isn't going to be fun for anyone.				;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Below, enter the buttons you want disbaled. 1 = disabled, 0 = enabled
; Format =  byetUDLR
; b = B; y = Y or X ; e = select; t = Start; U = up; D = down; L = left, R = right.
; Example: %00001011 would disable up, left and right respectively.
; setting bit 6 here (y) disables running completely.

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
db $03,$2A,$40
db $02,$2B,$40
db $02,$2C,$40
db $01,$2D,$40
db $03,$2E,$40
db $02,$2F,$40
db $02,$31,$40
db $02,$32,$40
db $02,$33,$40
db $0D,$34,$41
db $0D,$34,$42
db $0C,$34,$43
db $05,$34,$44
db $01,$35,$44
db $02,$35,$45
db $03,$35,$46
db $01,$35,$47
db $02,$36,$47
db $03,$36,$48
db $01,$36,$49
db $01,$37,$49
db $03,$37,$4A
db $03,$37,$4B
db $03,$38,$4C
db $03,$38,$4D
db $02,$39,$4E
db $03,$39,$4F
db $01,$39,$51
db $02,$3A,$51
db $03,$3A,$52
db $02,$3A,$53
db $03,$3B,$54
db $03,$3B,$55
db $02,$3C,$56
db $03,$3C,$57
db $01,$3C,$58
db $02,$3D,$58
db $02,$3D,$59
db $03,$3D,$5A
db $03,$3E,$5B
db $03,$3E,$5C
db $02,$3F,$5D
db $03,$3F,$5E
db $5D,$3F,$5F
db $00

.Table2
db $13,$93
db $01,$94
db $02,$93
db $03,$92
db $02,$91
db $03,$8F
db $02,$8E
db $03,$8D
db $03,$8C
db $03,$8B
db $03,$8A
db $03,$89
db $03,$88
db $03,$87
db $03,$86
db $03,$85
db $08,$84
db $07,$85
db $07,$86
db $07,$87
db $06,$88
db $07,$89
db $05,$8A
db $06,$8B
db $06,$8C
db $05,$8D
db $05,$8E
db $60,$8F
db $00