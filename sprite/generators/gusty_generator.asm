;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generator
; Extra Bits : NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!CUST_SPRITE_TO_GEN =	$3C		;change this to the same slot number you inserted the gusty!

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			print "INIT ",pc
			print "MAIN ",pc
			PHB
			PHK
			PLB
			JSR SPRITE_CODE_START
			PLB
			RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TBL_B2D0:		db $E8,$FF
TBL_B2D2:		db $FF,$00

SPRITE_CODE_START:	LDA $14
			AND #$3F
			ORA $9D
			BNE RETURN
			JSL $02A9DE|!BankB
			BMI RETURN
			TYX

			LDA #$01
			STA !14C8,x

			JSL $01ACF9|!BankB
			AND #$7F
			ADC #$40
			ADC $1C
			STA !D8,x
			LDA $1D
			ADC #$00
			STA !14D4,x
			LDA $148E|!Base2
			AND #$01
			TAY
			LDA TBL_B2D0,y
			CLC
			ADC $1A
			STA !E4,x
			LDA $1B
			ADC TBL_B2D2,y
			STA !14E0,x

			LDA #!CUST_SPRITE_TO_GEN
			STA !7FAB9E,x
			JSL $07F7D2|!BankB
			JSL $0187A7|!BankB
			JSL $01ACF9|!BankB
			AND #$01
			ASL #2
			ORA #$88
			STA !7FAB10,x
RETURN:			RTS