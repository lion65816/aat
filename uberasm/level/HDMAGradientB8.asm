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

LDA #$00
STA $1697|!addr

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
	REP   #$20 ; 16-bit A

	; Set transfer modes.
	LDA   #$3202
	STA   $4330 ; Channel 3
	LDA   #$3200
	STA   $4340 ; Channel 4

	; Point to HDMA tables.
	LDA   #Gradient1_RedGreenTable
	STA   $4332
	LDA   #Gradient1_BlueTable
	STA   $4342

	SEP   #$20 ; 8-bit A

	; Store program bank to $43x4.
	PHK
	PLA
	STA   $4334 ; Channel 3
	STA   $4344 ; Channel 4

	; Enable channels 3 and 4.
	LDA.b #%00011000
	TSB   $6D9F

	RTL ; <-- Can also be RTL.

; --- HDMA Tables below this line ---
Gradient1_RedGreenTable:
db $55,$21,$41
db $03,$21,$42
db $03,$22,$42
db $03,$22,$43
db $02,$23,$43
db $01,$23,$44
db $02,$24,$44
db $02,$24,$45
db $02,$25,$45
db $01,$25,$46
db $03,$26,$46
db $03,$27,$46
db $03,$28,$46
db $82,$29,$46,$29,$47
db $02,$2A,$47
db $82,$2B,$47,$2B,$48
db $02,$2C,$48
db $03,$2D,$49
db $01,$2E,$49
db $02,$2E,$4A
db $03,$2F,$4A
db $5E,$30,$4B
db $00

Gradient1_BlueTable:
db $54,$86
db $03,$87
db $02,$88
db $03,$89
db $03,$8A
db $02,$8B
db $02,$8C
db $02,$8D
db $0E,$8E
db $05,$8F
db $0B,$90
db $5D,$91
db $00
