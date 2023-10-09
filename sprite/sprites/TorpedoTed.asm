;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Torpedo Ted disassembly
; By nekoh
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
Return01AD41:       RTL                       


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                           
                    print "MAIN ",pc
                    PHB                       
                    PHK                       
                    PLB                             
                    JSR TorpedoTed         
                    PLB                       
                    RTL                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TorpedoTed:         LDA $64                   ; \ Save $64 
                    PHA                       ; / 
                    LDA !1540,X               ; \ If being launched... 
                    BEQ CODE_02B896           ;  | ...set $64 = #$10... 
                    LDA #$20                  ;  | ...so it will be drawn behind objects 
                    STA $64                   ; / 
CODE_02B896:        JSR TorpedoGfxRt          ; Draw sprite 
                    PLA                       ; \ Restore $64 
                    STA $64                   ; / 
                    LDA $9D                   ; \ Return if sprites locked 
                    BNE Return02B8B7          ; / 
                    LDA #$00
		    %SubOffScreen()   
                    JSL $01803A|!BankB        ; Update Y position without gravity
                    LDA !1540,X               ; \ Branch if not being launched 
                    BEQ CODE_02B8BC           ; / 
                    LDA #$08                  ; \ Sprite Y speed = #$08 
                    STA !AA,X                 ; / 
                    JSL $01801A|!BankB        ; Apply speed to position 
                    LDA #$10                  ; \ Sprite Y speed = #$10 
                    STA !AA,X                 ; / 
Return02B8B7:       RTS                       ; Return 


TorpedoMaxSpeed:    db $20,$F0

TorpedoAccel:       db $01,$FF

CODE_02B8BC:        LDA $13                   ; \ Only increase X speed every 4 frames 
                    AND #$03                  ;  | 
                    BNE CODE_02B8D2           ; / 
                    LDY !157C,X               ; \ If not at maximum, increase X speed 
                    LDA !B6,X                 ;  | 
                    CMP TorpedoMaxSpeed,Y     ;  | 
                    BEQ CODE_02B8D2           ;  | 
                    CLC                       ;  | 
                    ADC TorpedoAccel,Y        ;  | 
                    STA !B6,X                 ; / 
CODE_02B8D2:        JSL $018022|!BankB        ; \ Apply speed to position 
                    JSL $01803A|!BankB        ; / 
                    LDA !AA,X                 ; \ If sprite has Y speed... 
                    BEQ CODE_02B8E4           ;  | 
CODE_02B8DC:        LDA $13                   ;  | ...Decrease Y speed every other frame 
                    AND #$01                  ;  | 
                    BNE CODE_02B8E4           ;  | 
                    DEC !AA,X                 ; / 
CODE_02B8E4:        TXA                       ; \ Run $02B952 every 8 frames 
                    CLC                       ;  | 
                    ADC $14                   ;  | 
                    AND #$07                  ;  | 
                    BNE Return02B8EF          ;  | 
                    JSR CODE_02B952           ; / 
Return02B8EF:       RTS                       ; Return 


DATA_02B8F0:        db $10

DATA_02B8F1:        db $00,$10,$80,$82

DATA_02B8F5:        db $40,$00

TorpedoGfxRt:       %GetDrawInfo()        
                    LDA $01                   
                    STA $0301|!Base2,Y         
                    STA $0305|!Base2,Y    
                    PHX                       
                    LDA !15F6,X     
                    ORA $64                   
                    STA $02                   
                    LDA !157C,X     
                    TAX                       
                    LDA $00                   
                    CLC                       
                    ADC DATA_02B8F0,X       
                    STA $0300|!Base2,Y         
                    LDA $00                   
                    CLC                       
                    ADC DATA_02B8F1,X       
                    STA $0304|!Base2,Y    
                    LDA DATA_02B8F5,X       
                    ORA $02                   
                    STA $0303|!Base2,Y          
                    STA $0307|!Base2,Y     
                    PLX                       
                    LDA #$80                
                    STA $0302|!Base2,Y          
                    LDA !1540,X             
                    CMP #$01                
                    LDA #$82                
                    BCS CODE_02B944           
                    LDA $14     
                    LSR                       
                    LSR                       
                    LDA #$A0                
                    BCC CODE_02B944           
                    LDA #$82                
CODE_02B944:        STA $0306|!Base2,Y         
                    LDA #$01                
                    LDY #$02                
                    JSL $01B7B3|!BankB      
                    RTS                       ; Return 
    

DATA_02B94E:        db $F4,$1C

DATA_02B950:        db $FF,$00

CODE_02B952:        LDY #$03                
CODE_02B954:        LDA $17C0|!Base2,Y             
                    BEQ CODE_02B969           
                    DEY                       
                    BPL CODE_02B954           
                    DEC $18E9|!Base2               
                    BPL CODE_02B966           
                    LDA #$03                
                    STA $18E9|!Base2               
CODE_02B966:        LDY $18E9|!Base2               
CODE_02B969:        LDA !E4,X       
                    STA $00                   
                    LDA !14E0,X     
                    STA $01                   
                    PHX                       
                    LDA !157C,X     
                    TAX                       
                    LDA $00                   
                    CLC                       
                    ADC DATA_02B94E,X       
                    STA $02                   
                    LDA $01                   
                    ADC DATA_02B950,X       
                    PHA                       
                    LDA $02                   
                    CMP $1A    
                    PLA                       
                    PLX                       
                    SBC $1B    
                    BNE Return02B9A3          
                    LDA #$01                
                    STA $17C0|!Base2,Y             
                    LDA $02                   
                    STA $17C8|!Base2,Y             
                    LDA !D8,X       
                    STA $17C4|!Base2,Y             
                    LDA #$0F                
                    STA $17CC|!Base2,Y             
Return02B9A3:       RTS                       ; Return   