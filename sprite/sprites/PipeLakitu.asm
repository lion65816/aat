
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Pipe Lakitu disassembly
; By nekoh
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
                    LDA !E4,X                 ; \ Center sprite between two tiles 
                    CLC                       ;  | 
                    ADC #$08                  ;  | 
                    STA !E4,X                 ; / 
                    DEC !D8,X       
                    LDA !D8,X       
                    CMP #$FF                
                    BNE Return0185C2          
                    DEC !14D4,X     
Return0185C2:       RTL                       


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                           
                    print "MAIN ",pc
                    PHB                       
                    PHK                       
                    PLB                             
                    JSR PipeLakitu         
                    PLB                       
                    RTL                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PipeLakitu:         LDA !14C8,X             
                    CMP #$02                
                    BNE CODE_02E94C           
                    LDA #$02                
                    STA !1602,X             
                    JMP CODE_02E9EC     
                        

CODE_02E94C:        JSR CODE_02E9EC         
                    LDA $9D     
                    BNE Return02E985          
                    STZ !1602,X             
                    JSR SubOffscreen0Bnk2   
                    JSL $01803A  
                    LDA !C2,X     
                    JSL $0086DF          

PipeLakituPtrs:     dw CODE_02E96D           
                    dw CODE_02E986           
                    dw CODE_02E9B4           
                    dw CODE_02E9BD           
                    dw CODE_02E9D5           

CODE_02E96D:        LDA !1540,X             
                    BNE Return02E985          
                    LDY #$00                
                    LDA $94         
                    SEC                       
                    SBC !E4,X       
                    STA $0F                   
                    LDA $95       
                    SBC !14E0,X     
                    ;BPL Return02E985    
                    INY                            
                    TYA                              
                    LDA $0F                   
                    CLC                       
                    ADC #$13                
                    CMP #$36                
                    BCC Return02E985          
                    LDA #$90                
CODE_02E980:        STA !1540,X             
                    INC !C2,X     
Return02E985:       RTS                       ; Return 

CODE_02E986:        LDA !1540,X             
                    BNE CODE_02E996           
                    LDY #$00                
                    LDA $94         
                    SEC                       
                    SBC !E4,X       
                    STA $0F                   
                    LDA $95       
                    SBC !14E0,X     
                    ;BPL Return02E9B3          
                    INY                            
                    TYA                       
                    STA !157C,X
                    wowie2:
                    LDA #$0C                
                    BRA CODE_02E980           

CODE_02E996:        CMP #$7C                
                    BCC CODE_02E9A2           
CODE_02E99A:        
                    %SubHorzPos()
                    TYA
                    STA !157C,X
                    LDA #$F8                
CODE_02E99C:        STA !AA,X    
                    JSL $01801A   
                    RTS                       ; Return 

CODE_02E9A2:        CMP #$50                
                    BCS Return02E9B3          
                    LDY #$00                
                    LDA $13      
                    AND #$20                
                    BEQ CODE_02E9AF           
                    INY                       
CODE_02E9AF:        TYA                       
                    STA !157C,X     
Return02E9B3:       RTS                       ; Return 

CODE_02E9B4:        LDA !1540,X             
                    BNE CODE_02E99A           
                    LDA #$80                
                    BRA CODE_02E980           

CODE_02E9BD:        LDA !1540,X             
                    BNE CODE_02E9C6           
                    LDA #$20                
                    BRA CODE_02E980           

CODE_02E9C6:        CMP #$40                
                    BNE CODE_02E9CF           
                    JSL $01EA19         
                    RTS                       ; Return 

CODE_02E9CF:        BCS Return02E9D4          
                    INC !1602,X             
Return02E9D4:       RTS                       ; Return 

CODE_02E9D5:        LDA !1540,X             
                    BNE CODE_02E9E2           
                    LDA #$50                
                    JSR CODE_02E980         
                    STZ !C2,X     
                    RTS                       ; Return 

CODE_02E9E2:        LDA #$08                
                    BRA CODE_02E99C           


PipeLakitu1:        db $EC,$A8,$CE

PipeLakitu2:        db $EE,$EE,$EE

CODE_02E9EC:        %GetDrawInfo()       
                    LDA $00                   
                    STA $0300|!Base2,Y         
                    STA $0304|!Base2,Y    
                    LDA $01                   
                    STA $0301|!Base2,Y         
                    CLC                       
                    ADC #$10                
                    STA $0305|!Base2,Y    
                    PHX                       
                    LDA !1602,X             
                    TAX                       
                    LDA PipeLakitu1,X       
                    STA $0302|!Base2,Y          
                    LDA PipeLakitu2,X       
                    STA $0306|!Base2,Y         
                    PLX                       
                    LDA !157C,X     
                    LSR                       
                    ROR                       
                    LSR                       
                    EOR #$6B                
                    STA $0303|!Base2,Y          
                    STA $0307|!Base2,Y     
                    LDA #$01                
                    LDY #$02                
                    JSL $01B7B3      
                    RTS                       ; Return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_02D003:        db $40,$B0
DATA_02D005:        db $01,$FF
DATA_02D007:        db $30,$C0,$A0,$C0,$A0,$70,$60,$B0
DATA_02D00F:        db $01,$FF,$01,$FF,$01,$FF,$01,$FF


SubOffscreen0Bnk2:  STZ $03                   ; / 
                    JSR IsSprOffScreenBnk2  ; \ if sprite is not off screen, return 
                    BEQ Return02D090          ; / 
                    LDA $5B     ; \  vertical level 
                    AND #$01                ;  | 
                    BNE VerticalLevelBnk2     ; / 
                    LDA $03                   
                    CMP #$04                
                    BEQ CODE_02D04D           
                    LDA !D8,X       ; \ 
                    CLC                       ;  | 
                    ADC #$50                ;  | if the sprite has gone off the bottom of the level... 
                    LDA !14D4,X     ;  | (if adding 0x50 to the sprite y position would make the high byte >= 2) 
                    ADC #$00                ;  | 
                    CMP #$02                ;  | 
                    BPL OffScrEraseSprBnk2    ; /    ...erase the sprite 
                    LDA !167A,X   ; \ if "process offscreen" flag is set, return 
                    AND #$04                ;  | 
                    BNE Return02D090          ; / 
CODE_02D04D:        LDA $13      
                    AND #$01                
                    ORA $03                   
                    STA $01                   
                    TAY                       
                    LDA $1A    
                    CLC                       
                    ADC DATA_02D007,Y       
                    ROL $00                   
                    CMP !E4,X       
                    PHP                       
                    LDA $1B    
                    LSR $00                   
                    ADC DATA_02D00F,Y       
                    PLP                       
                    SBC !14E0,X     
                    STA $00                   
                    LSR $01                   
                    BCC CODE_02D076           
                    EOR #$80                
                    STA $00                   
CODE_02D076:        LDA $00                   
                    BPL Return02D090          
OffScrEraseSprBnk2: LDA !14C8,X             ; \ If sprite status < 8, permanently erase sprite 
                    CMP #$08                ;  | 
                    BCC OffScrKillSprBnk2     ; / 
                    LDY !161A,X ; \ Branch if should permanently erase sprite 
                    CPY #$FF                ;  | 
                    BEQ OffScrKillSprBnk2     ; / 
                    LDA #$00                ; \ Allow sprite to be reloaded by level loading routine 
                    PHX
                    TYX
                    STA !1938,X ; / 
                    PLX
OffScrKillSprBnk2:  STZ !14C8,X             ; Erase sprite 
Return02D090:       RTS                       ; Return 

VerticalLevelBnk2:  LDA !167A,X   ; \ If "process offscreen" flag is set, return 
                    AND #$04                ;  | 
                    BNE Return02D090          ; / 
                    LDA $13      ; \ Return every other frame 
                    LSR                       ;  | 
                    BCS Return02D090          ; / 
                    AND #$01                
                    STA $01                   
                    TAY                       
                    LDA $1C    
                    CLC                       
                    ADC DATA_02D003,Y       
                    ROL $00                   
                    CMP !D8,X       
                    PHP                       
                    LDA $1D  
                    LSR $00                   
                    ADC DATA_02D005,Y       
                    PLP                       
                    SBC !14D4,X     
                    STA $00                   
                    LDY $01                   
                    BEQ CODE_02D0C3           
                    EOR #$80                
                    STA $00                   
CODE_02D0C3:        LDA $00                   
                    BPL Return02D090          
                    BMI OffScrEraseSprBnk2    
IsSprOffScreenBnk2: LDA !15A0,X 
                    ORA !186C,X 
                    RTS                       ; Return 