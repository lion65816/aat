;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Roto Disc, by mikeyk
;;
;; Description: This sprite circles a block.  Mario cannot touch it, even with a spin
;; jump.  
;;
;; NOTE: Like the Ball and Chain, this enemy should not be used in levels that
;; allow Yoshi.
;;
;; Uses first extra bit: YES
;; Set the first extra bit to make the roto disc go counter clockwise
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    !TILE = $E4
                    !RADIUS = $38
;                    !CLOCK_SPEED = $03
;                    !COUNTER_CLOCK_SPEED = $FD
!CLOCK_SPEED = $02
!COUNTER_CLOCK_SPEED = $FE
                    
                    !EXTRA_BITS = !7FAB10
                    !EXTRA_PROP_2 = !7FAB34

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite initialization JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ", pc
            
                    LDA #!RADIUS
                    ;LDA !EXTRA_PROP_2,x                 
                    STA !187B,x
                    
                    LDA #$80                ;set initial clock position
                    STA !1602,x
                    TXA
                    AND #$01
                    STA !151C,x         
                    
                    RTL
                    
                    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            
                    print "MAIN ", pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR START_SPRITE_CODE   ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite sprite code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

START_SPRITE_CODE:   LDA #$01
    %SubOffScreen()
		    LDA $9D
                    BNE LABEL92
                    LDA !EXTRA_BITS,x
                    LDY #!CLOCK_SPEED
                    AND #$04
                    BNE LABEL90
                    LDY #!COUNTER_CLOCK_SPEED
LABEL90:             TYA
                    LDY #$00
                    CMP #$00
                    BPL LABEL91
                    DEY
LABEL91:             CLC
                    ADC !1602,x
                    STA !1602,x
                    TYA
                    ADC !151C,x
                    AND #$01
                    STA !151C,x
LABEL92:             LDA !151C,x
                    STA $01
                    LDA !1602,x
                    STA $00
                    REP #$30
STZ $02
;                    LDA $00
;                    CLC
;                    ADC.W #$0080
;                    AND.W #$01FF
;                    STA $02
                    LDA $00
                    AND.W #$00FF
                    ASL A
                    TAX
;                    LDA $07F7DB,x
LDA HorzSineTable,x
SEP #$10
BPL NotHorzFlip
LDX #$01
STX $02
EOR #$FFFF
INC A
NotHorzFlip:
LDX $01
BEQ NotHorzFlip2
LDX $02
DEX
STX $02
NotHorzFlip2:
REP #$10

                    STA $04
;                    LDA $02
LDA $00
                    AND.W #$00FF
                    ASL A
                    TAX
;                    LDA $07F7DB,x
LDA VertSineTable,x
BPL NotVertFlip
SEP #$10
LDX #$01
STX $03
EOR #$FFFF
INC A
NotVertFlip:
                    STA $06
                    SEP #$30
                    LDX $15E9|!Base2
                    if !SA1
                    STZ $2250
                    LDA $04
                    STA $2251
                    STZ $2252
                    LDA !187B,x
                    LDY $05
                    BNE LABEL93
                    STA $2253
                    STZ $2254
                    NOP
                    BRA $00
                    ASL $2306
                    LDA $2307
                    else
                    LDA $04
                    STA $4202
                    LDA !187B,x
                    LDY $05
                    BNE LABEL93
                    STA $4203
                    NOP
                    NOP
                    NOP
                    NOP
                    ASL $4216
                    LDA $4217
                    endif
                    ADC #$00
;LABEL93             LSR $01
;                    BCC LABEL94
LABEL93:
LDY $02
BEQ LABEL94
                    EOR #$FF                ; \ reverse direction of rotation
                    INC A                   ; /
LABEL94:             STA $04
                    if !SA1
                    STZ $2250
                    LDA $06
                    STA $2251
                    STZ $2252
                    LDA !187B,x
                    LDY $07
                    BNE LABEL95
                    STA $2253
                    STZ $2254
                    NOP
                    BRA $00
                    ASL $2306
                    LDA $2307
                    else
                    LDA $06
                    STA $4202
                    LDA !187B,x
                    LDY $07
                    BNE LABEL95
                    STA $4203
                    NOP
                    NOP
                    NOP
                    NOP
                    ASL $4216
                    LDA $4217
                    endif
                    ADC #$00
;LABEL95             LSR $03
;                    BCC LABEL96
LABEL95:
LDY $03
BEQ LABEL96
                    EOR #$FF
                    INC A
LABEL96:             STA $06
                    LDA !E4,x
                    PHA
                    LDA !14E0,x
                    PHA
                    LDA !D8,x
                    PHA
                    LDA !14D4,x
                    PHA
                    ;LDY $0F86,x
                    STZ $00
                    LDA $04
                    BPL LABEL97
                    DEC $00
LABEL97:             CLC
                    ADC !E4,x
                    STA !E4,x
                    PHP
                    PHA
                    SEC
                    SBC !1534,x
                    STA !1528,x
                    PLA
                    STA !1534,x
                    PLP
                    LDA !14E0,x
                    ADC $00
                    STA !14E0,x
                    STZ $01
                    LDA $06
                    BPL LABEL98
                    DEC $01
LABEL98:             CLC
                    ADC !D8,x
                    STA !D8,x
                    LDA !14D4,x
                    ADC $01
                    STA !14D4,x
            
                    JSL $01A7DC             ; check for mario/sprite contact
                    BCC RETURN_EXTRA          ; (carry set = mario/sprite contact)
                    LDA $1490|!Base2               ; \ if mario star timer > 0 ...
                    BNE HAS_STAR            ; /    ... goto HAS_STAR

SPRITE_WINS:         LDA $1497|!Base2               ; \ if mario is invincible...
                    ORA $187A|!Base2               ;  }  ... or mario on yoshi...
                    BNE RETURN_EXTRA          ; /   ... return
                    JSL $00F5B7             ; hurt mario

RETURN_EXTRA:        JSR SUB_GFX
                    
                    LDA !14C8,x             ; \ if sprite status != 8...
                    CMP #$08
                    BEQ ALIVE
                    
                    PLA
                    PLA
                    PLA
                    PLA
                    BRA DONE
                    
ALIVE:               PLA     
                    STA !14D4,x
                    PLA        
                    STA !D8,x  
                    PLA        
                    STA !14E0,x
                    PLA        
                    STA !E4,x                   
                    
DONE:                LDY #$02                ; \ 02 because we haven't written to $0460
                    LDA #$00                ; | A = number of tiles drawn - 1
                    JSL $01B7B3             ; / don't draw if offscreen
               
                    RTS

HAS_STAR:            LDA #$02                ; \ sprite status = 2 (being killed by star)
                    STA !14C8,x             ; /
                    LDA #$D0                ; \ set y speed
                    STA !AA,x               ; /
                    %SubHorzPos()         ; get new sprite direction
                    LDA KILLED_X_SPEED,y    ; \ set x speed based on sprite direction
                    STA !B6,x               ; /
                    INC $18D2|!Base2               ; increment number consecutive enemies killed
                    LDA $18D2|!Base2               ; \
                    CMP #$08                ; | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET2           ; |
                    LDA #$08                ; |
                    STA $18D2|!Base2               ; /   
NO_RESET2:           JSL $02ACE5             ; give mario points
                    LDY $18D2|!Base2               ; \ 
                    CPY #$08                ; | if consecutive enemies stomped < 8 ...
                    BCS NO_SOUND2           ; |
                    LDA STAR_SOUNDS,y       ; |    ... play sound effect
                    STA $1DF9|!Base2               ; /
NO_SOUND2:           BRA RETURN_EXTRA        ; final return

KILLED_X_SPEED:      db $F0,$10
STAR_SOUNDS:         db $00,$13,$14,$15,$16,$17,$18,$19

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine - specific to sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PALS:                db $05,$07,$09,$0B

SUB_GFX:             %GetDrawInfo()      ; after: Y = index to sprite tile map ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  

                    LDA $00                 ; tile x position
                    STA $0300|!Base2,y             ; 

                    LDA $01                 ; tile y position
                    STA $0301|!Base2,y             ; 

                    LDA #!TILE               ; store tile
                    STA $0302|!Base2,y             ;  
                    
                    PHX
                    
                    ;LDX $15E9
                    ;LDA $15F6,x            ; load tile pallette
                    
                    LDA $14
                    ;LSR A
                    AND #$07
                    ASL A
                    ORA #$01
                    ;TAX
                    ;LDA PALS,x
                    ORA $64                    
                    STA $0303|!Base2,y             ; store tile properties
                    
                    PLX
                   
                    INY                     ; | increase index to sprite tile map ($300)...
                    INY                     ; |    ...we wrote 4 bytes of data...
                    INY                     ; |    
                    INY                     ; |    ...so increment 4 times

                    RTS                     ; return
            
;For circletool.exe to work, those MUST be last and the labels/format may NOT be changed.
HorzSineTable:
db $00,$00,$04,$00,$09,$00,$0E,$00,$13,$00,$18,$00,$1D,$00,$22,$00
db $27,$00,$2C,$00,$30,$00,$35,$00,$3A,$00,$3F,$00,$43,$00,$48,$00
db $4D,$00,$51,$00,$56,$00,$5A,$00,$5F,$00,$63,$00,$68,$00,$6C,$00
db $70,$00,$74,$00,$79,$00,$7D,$00,$81,$00,$85,$00,$89,$00,$8C,$00
db $90,$00,$94,$00,$98,$00,$9B,$00,$9F,$00,$A2,$00,$A6,$00,$A9,$00
db $AC,$00,$AF,$00,$B2,$00,$B6,$00,$B8,$00,$BB,$00,$BE,$00,$C1,$00
db $C4,$00,$C6,$00,$C9,$00,$CB,$00,$CE,$00,$D0,$00,$D2,$00,$D4,$00
db $D6,$00,$D8,$00,$DA,$00,$DC,$00,$DE,$00,$E0,$00,$E2,$00,$E3,$00
db $E5,$00,$E6,$00,$E8,$00,$E9,$00,$EB,$00,$EC,$00,$ED,$00,$EE,$00
db $EF,$00,$F0,$00,$F1,$00,$F2,$00,$F3,$00,$F4,$00,$F5,$00,$F6,$00
db $F7,$00,$F7,$00,$F8,$00,$F9,$00,$F9,$00,$FA,$00,$FA,$00,$FB,$00
db $FB,$00,$FC,$00,$FC,$00,$FC,$00,$FD,$00,$FD,$00,$FD,$00,$FD,$00
db $FE,$00,$FE,$00,$FE,$00,$FE,$00,$FE,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $00,$01,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
db $FF,$00,$FF,$00,$FF,$00,$FF,$00,$FE,$00,$FE,$00,$FE,$00,$FE,$00
db $FE,$00,$FD,$00,$FD,$00,$FD,$00,$FD,$00,$FC,$00,$FC,$00,$FC,$00
db $FB,$00,$FB,$00,$FA,$00,$FA,$00,$F9,$00,$F9,$00,$F8,$00,$F7,$00
db $F7,$00,$F6,$00,$F5,$00,$F4,$00,$F3,$00,$F2,$00,$F1,$00,$F0,$00
db $EF,$00,$EE,$00,$ED,$00,$EC,$00,$EB,$00,$E9,$00,$E8,$00,$E6,$00
db $E5,$00,$E3,$00,$E2,$00,$E0,$00,$DE,$00,$DC,$00,$DA,$00,$D8,$00
db $D6,$00,$D4,$00,$D2,$00,$D0,$00,$CE,$00,$CB,$00,$C9,$00,$C6,$00
db $C4,$00,$C1,$00,$BE,$00,$BB,$00,$B8,$00,$B6,$00,$B2,$00,$AF,$00
db $AC,$00,$A9,$00,$A6,$00,$A2,$00,$9F,$00,$9B,$00,$98,$00,$94,$00
db $90,$00,$8C,$00,$89,$00,$85,$00,$81,$00,$7D,$00,$79,$00,$74,$00
db $70,$00,$6C,$00,$68,$00,$63,$00,$5F,$00,$5A,$00,$56,$00,$51,$00
db $4D,$00,$48,$00,$43,$00,$3F,$00,$3A,$00,$35,$00,$30,$00,$2C,$00
db $27,$00,$22,$00,$1D,$00,$18,$00,$13,$00,$0E,$00,$09,$00,$04,$00
VertSineTable:
db $00,$01,$FF,$00,$FF,$00,$FF,$00,$FF,$00,$FE,$00,$FE,$00,$FD,$00
db $FC,$00,$FC,$00,$FB,$00,$FA,$00,$F9,$00,$F8,$00,$F6,$00,$F5,$00
db $F4,$00,$F2,$00,$F0,$00,$EF,$00,$ED,$00,$EB,$00,$E9,$00,$E7,$00
db $E5,$00,$E3,$00,$E1,$00,$DF,$00,$DC,$00,$DA,$00,$D8,$00,$D5,$00
db $D3,$00,$D0,$00,$CD,$00,$CB,$00,$C8,$00,$C5,$00,$C2,$00,$BF,$00
db $BC,$00,$BA,$00,$B7,$00,$B4,$00,$B0,$00,$AD,$00,$AA,$00,$A7,$00
db $A4,$00,$A1,$00,$9E,$00,$9B,$00,$97,$00,$94,$00,$91,$00,$8E,$00
db $8B,$00,$87,$00,$84,$00,$81,$00,$7E,$00,$7B,$00,$77,$00,$74,$00
db $71,$00,$6E,$00,$6B,$00,$68,$00,$65,$00,$62,$00,$5F,$00,$5C,$00
db $59,$00,$56,$00,$53,$00,$50,$00,$4D,$00,$4B,$00,$48,$00,$45,$00
db $42,$00,$40,$00,$3D,$00,$3B,$00,$38,$00,$36,$00,$33,$00,$31,$00
db $2F,$00,$2C,$00,$2A,$00,$28,$00,$26,$00,$24,$00,$22,$00,$20,$00
db $1E,$00,$1C,$00,$1A,$00,$19,$00,$17,$00,$15,$00,$14,$00,$12,$00
db $11,$00,$0F,$00,$0E,$00,$0D,$00,$0C,$00,$0A,$00,$09,$00,$08,$00
db $07,$00,$06,$00,$05,$00,$05,$00,$04,$00,$03,$00,$03,$00,$02,$00
db $01,$00,$01,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$01,$00
db $01,$00,$02,$00,$03,$00,$03,$00,$04,$00,$05,$00,$05,$00,$06,$00
db $07,$00,$08,$00,$09,$00,$0A,$00,$0C,$00,$0D,$00,$0E,$00,$0F,$00
db $11,$00,$12,$00,$14,$00,$15,$00,$17,$00,$19,$00,$1A,$00,$1C,$00
db $1E,$00,$20,$00,$22,$00,$24,$00,$26,$00,$28,$00,$2A,$00,$2C,$00
db $2F,$00,$31,$00,$33,$00,$36,$00,$38,$00,$3B,$00,$3D,$00,$40,$00
db $42,$00,$45,$00,$48,$00,$4B,$00,$4D,$00,$50,$00,$53,$00,$56,$00
db $59,$00,$5C,$00,$5F,$00,$62,$00,$65,$00,$68,$00,$6B,$00,$6E,$00
db $71,$00,$74,$00,$77,$00,$7B,$00,$7E,$00,$81,$00,$84,$00,$87,$00
db $8B,$00,$8E,$00,$91,$00,$94,$00,$97,$00,$9B,$00,$9E,$00,$A1,$00
db $A4,$00,$A7,$00,$AA,$00,$AD,$00,$B0,$00,$B4,$00,$B7,$00,$BA,$00
db $BC,$00,$BF,$00,$C2,$00,$C5,$00,$C8,$00,$CB,$00,$CD,$00,$D0,$00
db $D3,$00,$D5,$00,$D8,$00,$DA,$00,$DC,$00,$DF,$00,$E1,$00,$E3,$00
db $E5,$00,$E7,$00,$E9,$00,$EB,$00,$ED,$00,$EF,$00,$F0,$00,$F2,$00
db $F4,$00,$F5,$00,$F6,$00,$F8,$00,$F9,$00,$FA,$00,$FB,$00,$FC,$00
db $FC,$00,$FD,$00,$FE,$00,$FE,$00,$FF,$00,$FF,$00,$FF,$00,$FF,$00
