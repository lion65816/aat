;====================;
; Grinder            ;
;====================;

	!SFX     = $04
	!SFXBank = $1DFA
	!SFXAMK     = $1A	;\
	!SFXBankAMK = $1DF9	;/  Use these if you're using AddMusicK.
	!Tile  = $6C
	!jumpspeed = $A4   ;jump highed
	XSpeeds:      db $18,$E8		; Speed of sprite, right, left.
	PropertyInfo: db $03,$43,$83,$C3	; Property for each 16x16 tile, YXPPCCCT.


print "INIT ",pc
	%SubHorzPos()				;\ 
	TYA					; | Face Mario's direction.
	STA !157C,x				;/
	RTL

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Spr
	PLB
	RTL

;=======;
; Main  ;
;=======;
Spr:
Grinder:                  	  JSR Tilemaps		; Graphics routine.         
CODE_01DB5F:                      LDA !14C8,X 		;\            
CODE_01DB62:                      CMP #$08              ; | Sprite dead?
CODE_01DB64:                      BNE Return01DB95      ;/ Return if so.
CODE_01DB66:                      LDA $9D		;\
CODE_01DB68:                      BNE Return01DB95 	;/ Return if locked.
CODE_01DB6A:                      LDA $13      		;\
CODE_01DB6C:                      AND #$03              ; |
CODE_01DB6E:                      BNE CODE_01DB75       ; |
if read1($008075|!BankB) = $5C				; |
CODE_01DB70:                      LDA #!SFXAMK		; | Play sound every 3 frames. 
CODE_01DB72:                      STA !SFXBankAMK|!Base2	; |
else							; |
CODE_01DB70:                      LDA #!SFX		; |
CODE_01DB72:                      STA !SFXBank|!Base2	;/
endif
CODE_01DB75:			  LDA #$00 : %SubOffScreen()
CODE_01DB78:                      JSL $01A7DC|!BankB	; Default interaction with Mario.
CODE_01DB7B:                      LDY !157C,X     	;\
CODE_01DB7E:                      LDA XSpeeds,Y         ; | Set X speeds based on direction of sprite.
CODE_01DB81:                      STA !B6,X    		;/
CODE_01DB83:                      JSL $01802A|!BankB   	; Update speed.
CODE_01DB86:                      JSR IsOnGround        ;\
CODE_01DB89:                      BEQ CODE_01DB8D       ;/ Freeze Y speed if sprite is on ground.  
CODE_01DB8B:                      lda #!jumpspeed         ;beep this just maked it jumpedwhen it is on grounded :3          
				  sta !AA,x      ;basically this is all
CODE_01DB8D:                      ;JSR.w IsTouchingObjSide 	;\  
CODE_01DB90:                      ;BEQ Return01DB95          	; | Garbage code, involves JSRs, so I wrote my own one:
CODE_01DB92:                      ;JSR.w FlipSpriteDir

LDA !1588,x		;\
AND #$03		; |
BEQ Return01DB95	; | Return if not touching a wall.
LDA !157C,x		; |
EOR #$01		; | Otherwise flip direction.
STA !157C,x		; |
Return01DB95:		; |
RTS			;/

IsOnGround:		;\
LDA !1588,x		; |
AND #$04		; | If bit clear, sprite isn't on ground.
RTS			;/ (waste of cycles, why not just add it up there in the main code?)

;Tilemaps Routine
;============
DATA_01DB96:                      db $F8,$08,$F8,$08		; X DISP
DATA_01DB9A:                      db $00,$00,$10,$10		; Y DISP

Tilemaps:                         %GetDrawInfo()
CODE_01DBA5:                      PHX              		; Preserve sprite index.         
CODE_01DBA6:                      LDX #$03                	; X = # of times to loop through for each tile.
CODE_01DBA8:                      LDA $00                   	;\
CODE_01DBAA:                      CLC                       	; |
CODE_01DBAB:                      ADC DATA_01DB96,X       	; | X pos + displacement,
CODE_01DBAE:                      STA $0300|!Base2,Y 		;/        
CODE_01DBB1:                      LDA $01                   	;\
CODE_01DBB3:                      CLC                       	; |
CODE_01DBB4:                      ADC DATA_01DB9A,X       	; |
CODE_01DBB7:                      STA.w $0301|!Base2,Y        	;/ Y pos + displacement.
CODE_01DBBA:                      LDA $14     			;\
CODE_01DBBC:                      AND #$02			;/ Does this make it use the next tile??
CODE_01DBBE:                      ORA #!Tile  			;\              
CODE_01DBC0:                      STA $0302|!Base2,Y   		;/ Store tile.
CODE_01DBC3:                      LDA PropertyInfo,X 		;\      
CODE_01DBC6:                      STA $0303|!Base2,Y  		;/ Store property for each tile.
CODE_01DBC9:                      INY                       	;\
CODE_01DBCA:                      INY                       	; |
CODE_01DBCB:                      INY                       	; |
CODE_01DBCC:                      INY                       	;/ Increase Y four times, because OAM is 8x8.
CODE_01DBCD:                      DEX                       	;\
CODE_01DBCE:                      BPL CODE_01DBA8  		;/ Loop until all tiles done.
				  PLX				;\ Pull X.
				  LDY #$02      		;/ Y = $02 (16x16 tiles).
CODE_01DBD0:                      LDA #$03                	;\ A = 03, tiles drawn.
CODE_01DBD2:                      JSL $01B7B3|!BankB		; | Call OAM write.
				  RTS           		;/