;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Thwimp, adapted by mikeyk
;;
;; Description: 
;;   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!JUMP_SFX = $2B
		!JUMP_PORT = $1DF9|!Base2

		!HEIGHT = $B4		;how high thwimp jumps
		!FREEZE_TIME = $15			;freeze time in frames      
		!SPRITE_X_SPEED = !B6
		!SPRITE_STATE = !C2
		!SPRITE_STATUS = !14C8
		!FREEZE_TIMER = !1540
		!SPR_OBJ_STATUS = !1588
                    
		!TILE_JUMP = $A7
		!TILE = $A9
  
SP:
db $12,$EE		;SPEEDS

WOWHEIGHT:
db $CB,$C2,$B4,$A8     

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ", pc
		    %SubHorzPos()
		    TYA
		    STA !157C,x
                    RTL
      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ", pc
                    PHB                     
                    PHK                     
                    PLB                     
                    JSR SPRITE_CODE_START   
                    PLB                     
                    RTL      


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
SPRITE_CODE_START:   JSR SUB_GFX
		    LDA !SPRITE_STATUS,x 
                    CMP #$08    
                    BEQ TEMP_2
		    JMP LBL_09
TEMP_2: 
                    LDA $9D     
                    BEQ TEMP
		    JMP LBL_09
TEMP:
                    LDA #$00
                    %SubOffScreen()

                    JSL $01A7DC|!BankB    ; interact with mario
                    JSL $01801A|!BankB	  ; set Y speed no gravity
                    JSL $018022|!BankB	  ; set X speed no gravity
                    JSL $019138           ; force interact with objects (set 1588)

                    LDA !AA,x  
                    BMI LBL_03 
                    CMP #$40      
                    BCS LBL_04

                    ADC #$05 
LBL_03:                
                    CLC           
                    ADC #$04      
                    BRA LBL_05 
LBL_04:
                    LDA #$40   
LBL_05:
                    STA !AA,x

                    LDA !SPR_OBJ_STATUS,x 
                    AND #$08
                    BEQ LBL_06 
                    LDA #$10
                    STA !AA,x
LBL_06:
                    LDA !SPR_OBJ_STATUS,x 
                    AND #$04 
                    BEQ LBL_09 
                    JSR SUB_9A04
                    STZ !SPRITE_X_SPEED,x  
                    STZ !AA,x
                    LDA !FREEZE_TIMER,x
                    BEQ LBL_08 
                    DEC A      
                    BNE LBL_09 
		    INC !1528,x
		    LDY !1528,x
		    LDA WOWHEIGHT,y
		    STA !AA,x
		    LDA #!JUMP_SFX
		    STA !JUMP_PORT
		    %SubHorzPos()
		    TYA
		    STA !157C,x
                    INC !SPRITE_STATE,x  
                    LDA !SPRITE_STATE,x  
                    LSR A
RedoSpdUpdate:
		    LDY !157C,x
		    LDA SP,y
LBL_07:
                    STA !SPRITE_X_SPEED,x  
                    BRA LBL_09 
LBL_08:  
                    LDA #!FREEZE_TIME   
                    STA !FREEZE_TIMER,x
		    LDA !1528,x
		    CMP #$03
		    BCC NO_RESET
		    STZ !1528,x
NO_RESET:
LBL_09:		    LDA !SPR_OBJ_STATUS,x
		    AND #$03
		    BEQ +
		    LDA !15AC,x
		    BNE +

		    LDA !157C,x
		    EOR #$01
		    STA !157C,x
		    LDA #$10
		    STA !15AC,x
		    BRA RedoSpdUpdate
+
                    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERIC GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:             %GetDrawInfo()       ; after: Y = index to sprite OAM ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  
                   
		    LDA !157C,x
		    STA $02

                    LDA $00                 ; set x position of the tile
                    STA $0300|!Base2,y

                    LDA $01                 ; set y position of the tile
                    STA $0301|!Base2,y

		    LDA !FREEZE_TIMER,x
		    CMP #!FREEZE_TIME
		    BEQ WOWTILE_2

		    LDA !AA,x
		    BPL WOWTILE_2
		    LDA #!TILE_JUMP
		    BRA SET_THTILE
WOWTILE_2:
                    LDA #!TILE
SET_THTILE:
                    STA $0302|!Base2,y

                    LDA !15F6,x             ; get sprite palette info
		    PHX
	            LDX $02
		    BNE NO_X_FLIP
		    ORA #$40
NO_X_FLIP:
                    ORA $64                 ; add in the priority bits from the level settings
                    STA $0303|!Base2,y             ; set properties
		    PLX
                    LDY #$02                ; #$02 means the tiles are 16x16
                    LDA #$00                ; This means we drew one tile
                    JSL $01B7B3
                    RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_9A04: 
           	    LDA !SPR_OBJ_STATUS,x 
                    BMI LBL_01 
                    LDA #$00    
                    LDY !15B8,x 
                    BEQ LBL_02 
LBL_01:
                    LDA #$18
LBL_02:                     
                    STA !AA,x   
                    RTS  
