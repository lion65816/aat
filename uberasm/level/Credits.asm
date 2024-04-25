;================================;
;quickass autowalk by mathos edited by Tattletale
;================================;
!Speed = $14    ; player x speed: see https://www.smwcentral.net/?p=nmap&m=smwram#7E007B for details
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


;===========================================================================================================================================

load:
	JSL NoStatus_load
	LDA #$01		;\ Always keep Demo big.
	STA $19			;/
	RTL

init:
    LDA.b #!Direction
	STA $76
	RTL

main:
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
    LDA.b #!Speed
	STA $7B
    .nospd:
    
    STZ $1401|!addr
    LDA #$80
	TRB $16
	TRB $18
	RTL
	RTL
    