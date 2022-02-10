;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Spike's Ball, by mikeyk (optimized by Blind Devil)
;;
;; Description: This is the ball that Spike throws.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!TILEMAP = $88			;ball tile
             
SpeedX:
	db $20,$E0		;ball speeds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	print "MAIN ",pc
	PHB                     
	PHK                     
	PLB                     
	JSR MainSub
	PLB
	print "INIT ",pc
	RTL                     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


MainSub:	
	JSR SubGfx		; Draw Sprite
        LDA !14C8,x             
        CMP #$08                
        BNE RETURN              
        LDA $9D                 ; Return if sprites locked
        BNE RETURN

	LDA #$03
	%SubOffScreen()

        LDY !157C,x             ; Set X speed based on direction
        LDA SpeedX,y
        STA !B6,x
        STZ !AA,x               
                                        
	JSL $01802A|!BankB	; Update position based on speed values
	JSL $01A7DC|!BankB	; Interact with Mario
RETURN:
	RTS
                  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SubGfx:
		    %GetDrawInfo()
                    LDA !157C,x             ; \ $02 = direction
                    STA $02                 ; /

                    LDA !14C8,x
                    CMP #$02
                    BNE +

                    LDA !15F6,x
                    ORA #$80
                    STA !15F6,x

+
		    REP #$20
                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!Base2,y      ; /
		    SEP #$20

		    PHX
                    LDA !15F6,x             ; tile properties, yxppccct format
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP             ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP:            ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

                    LDA #!TILEMAP	    ;  |
                    STA $0302|!Base2,y      ; /

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$00                ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return