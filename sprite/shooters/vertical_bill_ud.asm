;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Diagonal Shooter, modified by Yan
;; Original by mikeyk
;; Description: This shoots custom bullet bills diagonally downwards
;;
;; Uses first extra bit: YES
;; The bullet will shoot to the right if the first extra bit is set
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Definition
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!CUST_SPRITE_NUMBER = $50
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    print "INIT ", pc
                    print "MAIN ", pc
                    PHB
                    PHK
                    PLB
                    JSR SPRITE_CODE_START
                    PLB
                    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main bullet bill shooter code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RETURN2:             RTS                     ; return
                    ; return
SPRITE_CODE_START:   LDA $17AB|!Base2,x             ; \ return if it's not time to generate
                    BNE RETURN2             ; /
                    LDA #$60                ; \ set time till next generation = 60
                    STA $17AB|!Base2,x             ; /
                    LDA $178B|!Base2,x             ; \ don't generate if off screen vertically
                    CMP $1C                 ;  |
                    LDA $1793|!Base2,x             ;  |
                    SBC $1D                 ;  |
                    BNE RETURN2             ; /
                    LDA $179B|!Base2,x             ; \ don't generate if off screen horizontally
                    CMP $1A                 ;  |
                    LDA $17A3|!Base2,x             ;  |
                    SBC $1B                 ;  |
                    BNE RETURN2             ; /
                    LDA $179B|!Base2,x             ; \ ?? something else related to x position of generator??
                    SEC                     ;  |
                    SBC $1A                 ;  |
                    CLC                     ;  |
                    ADC #$10                ;  |
                    CMP #$10                ;  |
                    BCC RETURN2             ; /
                    JSL $02A9DE|!BankB             ; \ get an index to an unused sprite slot, return if all slots full
                    BMI RETURN2             ; / after: Y has index of sprite being generated

					PHX
					TYX

GENERATE_SPRITE:     LDA #$09                ; \ play sound effect
                    STA $1DFC|!Base2               ; /
					LDA #$08                ; \ set sprite status for new sprite
                    STA !14C8,y             ; /



					LDA #!CUST_SPRITE_NUMBER
					STA !7FAB9E,x
					JSL $07F7D2|!BankB				; FastROM Address
					JSL $0187A7|!BankB
					LDA #$88
					STA !7FAB10,x
					PLX

					LDA $179B|!Base2,x             ; \ set x position for new sprite
                    STA !E4,y             ;  |
                    LDA $17A3|!Base2,x             ;  |
                    STA !14E0,y             ; /
                    LDA $178B|!Base2,x             ; \ set y position for new sprite
                    SEC                     ;  | (y position of generator - 1)
                    SBC #$01                ;  |
                    STA !D8,y             ;  |
                    LDA $1793|!Base2,x             ;  |
                    SBC #$00                ;  |
                    STA !14D4,y             ; /

					LDA $00
                    PHA

					LDA $1783|!Base2,x 
                    AND #$40
                    BEQ LEFT
					LDA #$02
					BRA FIRE
LEFT:
					LDA #$03
FIRE:
					STA !C2,y
					STA $00
                    PHX
                    TYX
		STZ $00 : STZ $01
		LDA #$1B : STA $02
		LDA #$01
					%SpawnSmoke()
                    PLX
					PLA
                    STA $00
       
RETURN:              RTS                     ; return