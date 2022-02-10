;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hot Foot, by Magus (optimized by Blind Devil)
;;
;; This sprite walks following Mario, unless he's facing at it.
;;
;; Extra bit: if set, sprite will follow Mario when he's actually facing it.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!AntiProp = $06			;palette/properties for reverse hotfoot

TILEMAP:
db $00,$02,$04,$43		;walk 1, walk 2, idle 1, idle 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
                    %SubHorzPos()
                    TYA
                    STA !157C,x

                    LDA !1588,x             ; if on the ground, reset the turn counter
                    ORA #$04
                    STA !1588,x             ; if on the ground, reset the turn counter
                    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR SPRITE_CODE_START   ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    
X_SPEED:            db $08,$F8,$E0,$20
KILLED_X_SPEED:     db $F0,$10

RETURN:             RTS
SPRITE_CODE_START:  JSR SPRITE_GRAPHICS       ; graphics routine
                    LDA !14C8,x             ; \ 
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

		LDA #$00
		%SubOffScreen()
                    
                    LDA $14                 ; \ 
                    LSR #3                  ;  |
                    CLC                     ;  |
                    ADC $15E9|!Base2        ;  |
                    AND #$01                ;  |
                    STA !1602,x

                    %SubHorzPos()         ; \ always face mario
                    TYA                   ;  | 
                    STA !157C,x           ; /
                    
	            LDA !1588,x             ; if on the ground, reset the turn counter
                    AND #$04
                    BEQ IN_AIR
                    LDA #$10                ; \  y speed = 10
                    STA !AA,x               ; /

		    LDY !157C,x

		    LDA $140D|!Base2
		    BNE ++

		    LDA !7FAB10,x
		    AND #$04
		    BEQ +

                    CPY $76		    ; \ if mario is looking at same direction,
		    BNE SCARED		    ; / looks at sprite and it gets scared
		    BRA ++

+
                    CPY $76		    ; \ if mario is looking at different direction,
		    BEQ SCARED		    ; / looks at sprite and it gets scared

++
                    LDA !1588,x             ; \ if sprite is in contact with an object...
                    AND #$03                ;  |
                    BEQ X_TIME_2            ;  |
	            INY	                    ; / add 2 to counter to exchange speeds
		    INY			    ; 
X_TIME_2:	    LDA X_SPEED,y           ;  |
                    STA !B6,x               ; /
		    BRA IN_AIR
		   		    
SCARED:		    STZ !B6,x
                                                            
IN_AIR:             JSL $01802A|!BankB      ; update position based on speed values
  		    JSL $01A7DC|!BankB	    ; process interaction with player
DONE_WITH_SPEED:    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_GRAPHICS:    %GetDrawInfo()	    ; sets y = OAM offset
                    LDA !157C,x             ; \ $02 = direction
                    STA $02                 ; / 
                    LDA !1602,x
                    STA $03                 ;  | $03 = index to frame start (0 or 1)
                    
                    LDA !14C8,x
                    CMP #$02
                    BNE START_2
                    STZ $03
                    LDA !15F6,x
                    ORA #$80
                    STA !15F6,x

START_2:	    REP #$20
                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!Base2,y      ; /
                    SEP #$20

		    PHX
		    LDA !7FAB10,x
		    AND #$04
		    BNE Anti

                    LDA !15F6,x             ;tile properties, yxppccct format
		    BRA +

Anti:
                    LDA !15F6,x             ;tile properties, yxppccct format
		    AND #$F1		    ;clear palette config from CFG
		    ORA #!AntiProp	    ;set new palette bits
+
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP             ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP:            ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

		    LDX $15E9|!Base2
		    LDA !B6,x
		    CMP #$00
		    BNE NEXTSTEP
		    LDA $03
		    CLC
		    ADC #$02
		    STA $03

NEXTSTEP:
                    LDX $03                 ; \ store tile
                    LDA TILEMAP,x           ;  |
                    STA $0302|!Base2,y      ; /

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return