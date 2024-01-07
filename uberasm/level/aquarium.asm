;; Disables scrolling in a particular direction, similar to Super Mario Bros.
;;  By kaizoman/Thomas. No credit necessary.


!disabledDirection	=	!down
;; Which direction to disable scrolling in, e.g. !left means you can't scroll left (like SMB).
;;  Other options: !right, !up, !down


!left = 0
!right = 1
!up = 2
!down = 3

init:

	STZ $1411|!addr


!screen_num = $0D

main:
    LDA ($19B8+!screen_num)|!addr
    STA $0C
    LDA ($19D8+!screen_num)|!addr
    STA $0D
    JSL MultipersonReset_main

	LDY #$00
	REP #$20
if !disabledDirection == !right || !disabledDirection == !left
	STY $1401|!addr
	LDA $7E
	CMP $142A|!addr
else
	LDA $80
	CMP #$0070
endif
	SEP #$20
if !disabledDirection == !left || !disabledDirection == !up
	BMI +
else
	BPL +
endif
	INY
+	
if !disabledDirection == !left || !disabledDirection == !right
	STY $1411|!addr
else
	STY $1412|!addr
endif
	RTL