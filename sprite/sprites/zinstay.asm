;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Zinger by Beyrevia - Stationary
;; originally for Vip5
;; Edited by Koba
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    !EXTRA_BITS = !7FAB10
                    !GraphicsIndex = !1594
                    !DirectionMirror = !157C
                    !Direction = !151C
                    !XSpeed = !B6
                    !YSpeed = !AA
                    !DirectionBuffer = !1504
                    !BlockCollisionTable = !1588
                    
                    !XOffsetIndex = $02
                    !TilemapIndex = $0E

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    PRINT "INIT ",pc
                    PHY
                    
                    ; Get direction relative to Mario.
                    %SubHorzPos()
                    TYA
                    STA !DirectionMirror,x
                    
                    ; Initialize graphics index.
                    LDA #$10
                    STA !GraphicsIndex,x
                    
                    ; Restore Y
                    PLY
                    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    PRINT "MAIN ",pc                                    
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR SPRITE_CODE_START   ;  |
                    PLB                     ;  |
                    RTL                     ; /


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_CODE_START:
                    ; Run Graphics Routine
                    JSR SUB_GFX

                    ; Mirror current direction.
                    %SubHorzPos()
                    TYA
                    STA !Direction,x

                    ; Only run code if animation is active and if sprite is alive.
                    LDA !14C8,x
                    CMP #$08
                    BNE RETURN_24
                    LDA $9D
                    BNE RETURN_24
                    
                    ; Run SubOffScreen X0 to properly render offscreen.
                    %SubOffScreen()
                    
                    ; Increment Animation pointer
                    INC !GraphicsIndex,x
                    
                    ; Handle contact.
CHECK_CONTACT:      JSL $01A7DC|!BankB            ; check for mario/sprite contact (carry set = contact)
                    JSL $018032|!BankB
RETURN_24:          RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:
			 db $C6,$C8,$E6,$E8     ;1
			 db $C6,$C8,$E6,$E8     ;1
			 db $CA,$CC,$EA,$EC     ;1
             db $CA,$CC,$EA,$EC     ;1
			  
			 db $80,$82,$A0,$A2     ;1
	         db $84,$86,$A4,$A6     ;2
	         db $88,$8A,$A8,$AA     ;3
	         db $8C,$8E,$AC,$AE     ;4
	         db $C2,$C4,$E2,$E4     ;5
			 db $80,$82,$A0,$A2     ;1

X_OFFSET:    db $0E,$FE,$0E,$FE,$FE,$0E,$FE,$0E
Y_OFFSET:    db $F0,$F0,$00,$00

SUB_GFX:            %GetDrawInfo()

                    ; Mirror Direction to use as Tile X Offset table index.
                    LDA !Direction,x             ; \ $02 = direction
                    STA !XOffsetIndex                 ; /
			  
                    ; Initialize Graphics Index routine
                    ;; Make sure it never goes beyond #$24 (at which point it reaches the final TILEMAP row)
                    LDA !GraphicsIndex,x
                    CMP #$24
                    BCC NOT_RENDER_TILE
                    
                    ; Initialize the Graphics index to start at tile $80 (row 4)
                    LDA #$10
                    STA !GraphicsIndex,x
                    
NOT_RENDER_TILE: 
                    ; Lock Graphics Index to cap at 3C (the amount of tiles in the tilemap table).
                    LDA !GraphicsIndex,x
                    AND #$3C
                    STA !TilemapIndex
			  
                    ; Loop 3 times (4 runs through the bwlo)
                    PHX
                    LDX #$03

                    ; Add (current loop) + (Direction*4) to get proper X Offset.
LOOP_START:          PHX
                    TXA
                    CLC
                    ADC !XOffsetIndex
                    ADC !XOffsetIndex
                    ADC !XOffsetIndex
                    ADC !XOffsetIndex
                    TAX
                    
                    ; Add the Sprite's Y location to draw the Tile.
                    LDA X_OFFSET,x
                    CLC
                    ADC $00                 ; \ tile x position = sprite y location ($01)
                    STA $0300|!addr,y             ; /

                    ; Reload X (to get loop counter again) and draw Y Tile. Add the Sprite's X location to draw the Tile.
                    PLX

                    LDA Y_OFFSET,x
                    CLC
                    ADC $01                 ; \ tile y position = sprite x location ($00)
                    STA $0301|!addr,y             ; /
                    
                    ; Get tilemap by adding (current loop + tilemap row index) to get correct tile.
                    PHX
                    TXA
                    CLC
                    ADC !TilemapIndex
                    TAX
                    LDA TILEMAP,x
                    STA $0302|!addr,y
                    
                    ; Reload X and add Tweaker properties.
                    PLX
                    
                    PHX
                    LDX $15E9|!addr
                    LDA !15F6,x             ; tile properties xyppccct, format
                    LDX $02                 ; \ if direction == 0...
                    BNE NO_FLIP             ;  |
                    ORA #$40                ; /    ...flip tile
NO_FLIP:             ORA $64                 ; add in tile priority of level
                    STA $0303|!addr,y             ; store tile properties
                    PLX            
                    
                    ; Draw Tile.
                    INY                     ; \ increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ; /    ...so increment 4 times
                    DEX
                    BPL LOOP_START

                    ; End loop routine by loading the GFX Drawing Finish routines.
                    PLX
                    LDY #$02                ; \ 460 = 2 (all 16x16 tiles)
                    LDA #$03                ;  | A = (number of tiles drawn - 1)
                    JSL $01B7B3|!BankB             ; / don't draw if offscreen
                    RTS                     ; return