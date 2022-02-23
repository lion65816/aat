;; ----------------------------------------------------------------------------
;;
;; ExtendedClipping:
;;    Provides really basic clipping values for extended sprites.
;;
;; Input:
;;    X: For the clipping size (0 - 8x8, 1 - 16x16)
;;
;; Output:
;;    $04: X displacement lo
;;    $05: Y displacement lo
;;    $06: Width
;;    $07: Height
;;    $0A: X displacement hi
;;    $0B: Y displacement hi
;;    X: Extended sprite index
;;
;; Clobbers: A
;;
;; ----------------------------------------------------------------------------

        LDY $15E9|!Base2
        LDA $171F|!Base2,y
        CLC
        ADC.l .clipping_x_disp_lo,x
        STA $04
        LDA $1733|!Base2,y
        ADC #$00
        STA $0A
        LDA.l .clipping_width,x
        STA $06
        LDA $1715|!Base2,y
        CLC
        ADC.l .clipping_y_disp_lo,x
        STA $05
        LDA $1729|!Base2,y
        ADC #$00
        STA $0B
        LDA.l .clipping_height,x
        STA $07
        TYX
        RTL

.clipping_x_disp_lo
        db $03,$04
.clipping_y_disp_lo
        db $03,$04
.clipping_width
        db $01,$08
.clipping_height
        db $01,$08

