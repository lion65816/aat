;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Homing Thwomp, by yoshicookiezeus
;;
;; Description: A Thwomp that follows Mario horizontally when on the ceiling, and falls
;;		whenever it gets close to him.
;;
;; PSI Ninja edit: Made some adjustments so that the Thwomp works in vertical autoscrollers.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
			; symbolic names for RAM addresses (don't change these)
			!SPRITE_Y_SPEED	= !AA
			!SPRITE_X_SPEED	= !B6
			!SPRITE_STATE	= !C2
			!SPRITE_Y_POS	= !D8
			!SPRITE_X_POS	= !E4
			!ORIG_Y_POS		= !151C
			!EXPRESSION      = !1594
			!FREEZE_TIMER    = !1540
			!SPR_OBJ_STATUS  = !1588
			!H_OFFSCREEN     = !15A0
			!V_OFFSCREEN     = !186C
			
			; definitions of bits (don't change these)
			!IS_ON_GROUND    = $04             
			
			; sprite data
			!SPRITE_GRAVITY	= $04
			!MAX_Y_SPEED	= $48 
			;!RISE_SPEED		= $D8	;\ PSI Ninja edit: Make Thwomp rise faster
			!RISE_SPEED		= $C8		;/ to prevent the player from riding it upwards.
			!TIME_TO_SHAKE	= $18
			!SOUND_EFFECT	= $09 
			!TIME_ON_GROUND	= $10
			!ANGRY_TILE		= $CA

			!X_SPEED_LEFT	= $30
			!X_SPEED_RIGHT	= $CF

X_SPEED:		db !X_SPEED_LEFT,!X_SPEED_RIGHT
X_OFFSET:		db $FC,$04,$FC,$04,$00
Y_OFFSET:		db $00,$00,$10,$10,$08
TILE_MAP:		db $8E,$8E,$AE,$AE,!ANGRY_TILE
;PROPERTIES:		db $03,$43,$03,$43,$03		;> PSI Ninja edit: Gray palette.
PROPERTIES:		db $07,$47,$07,$47,$07		;> PSI Ninja edit: Blue palette.
						          
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			PRINT "INIT ",pc
			LDA !SPRITE_Y_POS,x  
			STA !ORIG_Y_POS,x
			LDA !E4,x  
			CLC        
			ADC #$08   
			STA !E4,x  
			RTL
      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			PRINT "MAIN ",pc
			PHB			 
			PHK			 
			PLB			 
			JSR SPRITE_CODE_START   
			PLB			 
			RTL			 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETURN:			RTS  

SPRITE_CODE_START:	JSR SUB_GFX

			LDA !14C8,x		; return if sprite status != 8
			CMP #$08            	 
			BNE RETURN           
			
			LDA $9D			; return if sprites locked
			BNE RETURN    

			;JSR SUB_OFF_SCREEN_X0	; only process sprite while on screen           
			
			JSL $01A7DC|!BankB		; interact with mario 
			
			LDA !SPRITE_STATE,x     
			CMP #$01
			BEQ FALLING
			CMP #$02
			BEQ RISING0

;-----------------------------------------------------------------------------------------
; state 0
;-----------------------------------------------------------------------------------------

HOVERING:		;LDA V_OFFSCREEN,x	;fall if offscreen vertically
			;BNE SET_FALLING
			
			;LDA H_OFFSCREEN,x	;return if offscreen horizontally
			;BNE RETURN0
			
			STZ !SPRITE_Y_SPEED,x
			%SubHorzPos()
			TYA        
			STA !157C,x

			;LDY !1528,x
			;PHY
			;%SubHorzPos()	;check what side of sprite Mario is on
			;TYA			;and set x speed accordingly
			;BEQ LEFT
			;PLY
			;LDA !X_SPEED_RIGHT
			;BRA CONTINUE

;LEFT:			;PLY
			;LDA !X_SPEED_LEFT

;CONTINUE:

			; Why not use a table instead? <_<
			LDA X_SPEED,y
			STA !SPRITE_X_SPEED,x
			LDA $95
			CMP !14E0,x
			BNE RETURN0
			LDA !SPRITE_X_POS,x
			CLC
			ADC #$08
			SEC
			SBC $94
			CMP #$10
			BCS RETURN0

SET_FALLING:		STZ !SPRITE_X_SPEED,x
			LDA #$02		;set expression    
			STA !EXPRESSION,x  

			LDA #$2E		;\ PSI Ninja edit: Frame counter for how long the Thwomp should be in a falling state. We do this to force
			STA !1564,x		;| it to stop at or near the bottom of the screen. Therefore, the number of frames chosen depends on how
						;/ fast the screen is scrolling, and how fast the Thwomp is falling. (0x2E -> 46 frames)

			INC !SPRITE_STATE,x	;change state to falling

			LDA #$00     
			STA !SPRITE_Y_SPEED,x	;set initial speed

RETURN0:			JSL $01802A|!BankB		;apply speed
			RTS	

RISING0:			BRA RISING		 

;-----------------------------------------------------------------------------------------
; state 1
;-----------------------------------------------------------------------------------------

FALLING:			JSL $01801A|!BankB		;apply speed
			
			LDA !SPRITE_Y_SPEED,x	;increase speed if below the max
			CMP #!MAX_Y_SPEED
			BCS DONT_INC_SPEED
			ADC #!SPRITE_GRAVITY
			STA !SPRITE_Y_SPEED,x    
DONT_INC_SPEED:
			JSL $019138|!BankB		;interact with objects
			
			LDA !SPR_OBJ_STATUS,x
			AND #!IS_ON_GROUND
			;BEQ RETURN68		;\
			BNE CHANGE_TO_RISING	;/ PSI Ninja edit: If the Thwomp is on the ground, then end the falling state.

			LDA !1564,x		;\ PSI Ninja edit: Else, if the Thwomp falling timer reached zero, then end the falling state.
			BNE RETURN68		;/
			
CHANGE_TO_RISING:
			JSR SUB_9A04		; ?? speed related
			
			LDA #!TIME_TO_SHAKE	;shake ground
			STA $1887|!Base2
			
			LDA #!SOUND_EFFECT	;play sound effect
			STA $1DFC|!Base2

			;LDY !1528,x			
			LDA #!TIME_ON_GROUND	;set time to stay on ground
			STA !FREEZE_TIMER,x  
			
			INC !SPRITE_STATE,x	;go to rising state

RETURN68:		RTS

;-----------------------------------------------------------------------------------------
; state 2
;-----------------------------------------------------------------------------------------

RISING:              	LDA !FREEZE_TIMER,x	;if we're still waiting on the ground, return
			BNE RETURN2
			
			STZ !EXPRESSION,x	;reset expression
			
			JSL $019138|!BankB		;interact with objects
			LDA !SPR_OBJ_STATUS,x	;check if the sprite is in original position
			AND #$08 
			;BEQ RISE		;\
			BNE CHANGE_TO_HOVERING	;/ PSI Ninja edit: If the Thwomp is blocked from the top by an object, then end the rising state.

			LDA !V_OFFSCREEN,x	;\
			AND #$03		;| PSI Ninja edit: Else, if the Thwomp reaches the top of the screen, then end the rising state.
			BEQ RISE		;/
			
CHANGE_TO_HOVERING:
			STZ !SPRITE_STATE,x	;reset state to hovering
			RTS			 

RISE:			;LDY !1528,x
			LDA #!RISE_SPEED	;set rising speed and apply it
			STA !SPRITE_Y_SPEED,x
			JSL $01801A|!BankB             
RETURN2:			RTS			 


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:			%GetDrawInfo()
			
			LDA !EXPRESSION,x   
			STA $02       
			PHX			 
			LDX #$03                
			CMP #$00			    
			BEQ LOOP_START
			INX			 
LOOP_START:		LDA $00    
			CLC			 
			ADC X_OFFSET,x
			STA $0300|!Base2,y

			LDA $01    
			CLC			 
			ADC Y_OFFSET,x
			STA $0301|!Base2,y

			LDA PROPERTIES,x
			ORA $64    
			STA $0303|!Base2,y

			LDA TILE_MAP,x
;			CPX #$04                
;			BNE NORMAL_TILE
;			PHX			 
;			LDX $02    
;			CPX #$02                
;			BNE NOT_ANGRY
;			LDA #!ANGRY_TILE               
;NOT_ANGRY:		PLX			 
NORMAL_TILE:		STA $0302|!Base2,y

			INY			 
			INY			 
			INY			 
			INY			 
			DEX			 
			BPL LOOP_START

			PLX			 
			               
			LDY #$02		; \ 460 = 2 (all 16x16 tiles)
			LDA #$04		;  | A = (number of tiles drawn - 1)
			JSL $01B7B3|!BankB		; / don't draw if offscreen
			RTS			; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; speed related
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
			
SUB_9A04:            LDA !SPR_OBJ_STATUS,x
			BMI THWOMP_1
			LDA #$00                
			LDY !15B8,x
			BEQ THWOMP_2
THWOMP_1:            LDA #$18
THWOMP_2:            STA !SPRITE_Y_SPEED,x  
			RTS		
