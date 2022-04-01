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