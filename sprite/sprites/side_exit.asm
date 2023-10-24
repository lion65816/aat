
;===========================;
;    Side Exit Sprite       ;
;===========================;

print "INIT ",pc
	LDA #$28	;\ Disable sprite contact time?
	STA !1564,x	;/
	RTL	

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR Spr ; Call local subroutine.
	PLB
	RTL

;=========
;Main
;=========

;Side exit code.

Spr:
CODE_02F4D5:                      LDA.b #$01		;\                
;CODE_02F4D7:                      STA.w $1B96|!Base2           ;/ Set side exit enabled flag.  
CODE_02F4DA:                      LDA !E4,X       
CODE_02F4DC:                      AND.b #$10		; X&1                
CODE_02F4DE:                      BNE Return02F4E6 	; Return.         
;CODE_02F4E0:                      JSR.w CODE_02F4EB 	;\        
CODE_02F4E3:                      JSR.w CODE_02F53E     ;/ Controls fireplace.  
Return02F4E6:                     RTS 	

;==========
;Fire Code Graphics
;==========
DATA_02F4E7:                      db $D4,$AB

DATA_02F4E9:                      db $BB,$9A

CODE_02F4EB:                      LDA.w !15EA,X ; Sprite index to OAM.   
CODE_02F4EE:                      CLC                       
CODE_02F4EF:                      ADC.b #$08 ; Add 8                
CODE_02F4F1:                      TAY                ; -> Y.        
CODE_02F4F2:                      LDA.b #$B8                
CODE_02F4F4:                      STA.w $0300|!Base2,Y ; Draw X position based on index.       
CODE_02F4F7:                      STA.w $0304|!Base2,Y    
CODE_02F4FA:                      LDA.b #$B0                
CODE_02F4FC:                      STA.w $0301|!Base2,Y ; Y position.         
CODE_02F4FF:                      LDA.b #$B8                
CODE_02F501:                      STA.w $0305|!Base2,Y    
CODE_02F504:                      LDA $13      
CODE_02F506:                      AND.b #$03		                
CODE_02F508:                      BNE CODE_02F516           
CODE_02F50A:                      PHY                       
CODE_02F50B:                      JSL.l $01ACF9             
CODE_02F50F:                      PLY                       
CODE_02F510:                      AND.b #$03                
CODE_02F512:                      BNE CODE_02F516           
CODE_02F514:                      INC !C2,X     
CODE_02F516:                      PHX                       
CODE_02F517:                      LDA !C2,X     
CODE_02F519:                      AND.b #$01                
CODE_02F51B:                      TAX                       
CODE_02F51C:                      LDA.w DATA_02F4E7,X       
CODE_02F51F:                      STA.w $0302|!Base2,Y ; Tiledata.          
CODE_02F522:                      LDA.w DATA_02F4E9,X       
CODE_02F525:                      STA.w $0306|!Base2,Y         
CODE_02F528:                      LDA.b #$35                
CODE_02F52A:                      STA.w $0303|!Base2,Y ; Property byte.          
CODE_02F52D:                      STA.w $0307|!Base2,Y     
CODE_02F530:                      TYA                       
CODE_02F531:                      LSR                       
CODE_02F532:                      LSR                       
CODE_02F533:                      TAY                       
CODE_02F534:                      LDA.b #$00                
CODE_02F536:                      STA.w $0460|!Base2,Y      
CODE_02F539:                      STA.w $0461|!Base2,Y             
CODE_02F53C:                      PLX                       
Return02F53D:                     RTS                       ; Return

;========

CODE_02F53E:                      LDA $14     
CODE_02F540:                      AND.b #$3F                
CODE_02F542:                      BNE Return02F547          
CODE_02F544:                      JSR.w CODE_02F548         
Return02F547:                     RTS                       ; Return

CODE_02F548:                      LDY.b #$09                
CODE_02F54A:                      LDA.w !14C8,Y             
CODE_02F54D:                      BEQ CODE_02F553           
CODE_02F54F:                      DEY                       
CODE_02F550:                      BPL CODE_02F54A           
Return02F552:                     RTS                       ; Return 

CODE_02F553:                      LDA.b #$8B                
CODE_02F555:                      STA.w !9E,Y     
CODE_02F558:                      LDA.b #$08                ; \ Sprite status = Normal 
CODE_02F55A:                      STA.w !14C8,Y             ; / 
CODE_02F55D:                      PHX                       
CODE_02F55E:                      TYX                       
CODE_02F55F:                      JSL.l $07F7D2		    ; Reset sprite properites, and get sprite 8E.

;===============
;Position of Fire
;===============
    
CODE_02F563:                      LDA.b #$BB                ; Side exit itself.
CODE_02F565:                      STA !E4,X		      
CODE_02F567:                      LDA.b #$00                
CODE_02F569:                      STA.w !14E0,X  ; X pos high.	      
CODE_02F56C:                      LDA.b #$00                
CODE_02F56E:                      STA.w !14D4,X ; Y pos high (prevents screen boundary crap)    
CODE_02F571:                      LDA.b #$E0                
CODE_02F573:                      STA !D8,X ; Y Pos low.       
CODE_02F575:                      LDA.b #$20                
CODE_02F577:                      STA.w !1540,X             
CODE_02F57A:                      PLX                       
Return02F57B:                     RTS                       ; Return
