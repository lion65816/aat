;; ----------------------------------------------------------------------------
;;
;; ExtendedMarioInteraction:
;;    Provides player interaction between the player and the extended sprite.
;;    Includes the default behavior of most vanilla extended sprites.
;;
;; Input:
;;    $04,$05,$06,$07,$0A,$0B: Clipping values (can be your own, or the ones
;;    set by ExtendedClipping)
;;    A: 80 to bypass the vanilla behavior
;;    X: Extended sprite index
;;
;; Output:
;;    Carry set if there was interaction, clear if there wasn't.
;;
;; Clobbers: A, $0A to $0F
;;
;; ----------------------------------------------------------------------------

        STA $0E
        LDA $13F9|!Base2
        EOR $1779|!Base2,x
        BNE .no_contact
        JSL $03B664|!BankB
        JSL $03B72B|!BankB
        BCC .no_contact
        ASL $0E
        BCC .default_interaction
.no_contact
        RTL

.default_interaction
        LDA $1490|!Base2
        BNE .has_star
        LDA $187A|!Base2
        BEQ .not_on_yoshi
        LDX $18DF|!Base2
        LDA #$10
        STA !163E-1,x
        LDA #$03
        STA $1DFA|!Base2
        LDA #$13
        STA $1DFC|!Base2
        LDA #$02
        STA !C2-1,x
        STZ $187A|!Base2
        STZ $0DC1|!Base2
        LDA #$C0
        STA $7D
        STZ $7B
        PHX
        LDA !157C-1,x
        TAX
        LDA.l .hurt_yoshi_x_speed,x
        PLX
        STA !B6-1,x
        STZ !1594-1,x
        STZ !151C-1,x
        STZ $18AE|!Base2
        LDA #$30
        STA $1497|!Base2
        LDX $15E9|!Base2
        SEC
        RTL

.hurt_yoshi_x_speed
        db $10,$F0

.not_on_yoshi
        JSL $00F5B7|!BankB
        SEC
        RTL

.has_star
        LDA $171F|!Base2,x
        SEC
        SBC #$04
        STA $171F|!Base2,x
        LDA $1733|!Base2,x
        SBC #$00
        STA $1733|!Base2,x
        LDA $1715|!Base2,x
        SEC
        SBC #$04
        STA $1715|!Base2,x
        LDA $1729|!Base2,x
        SBC #$00
        STA $1729|!Base2,x
        LDA #$07
        STA $176F|!Base2,x
        LDA #$01
        STA $170B|!Base2,x
        SEC
        RTL

