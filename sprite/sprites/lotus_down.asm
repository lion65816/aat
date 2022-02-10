;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Volcano Lotus Disassembly By Nekoh
; 
; Upside-down edit by leod
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



Pollen_X:        db $38,$C8,$20,$E0
;mess with these values to spread the pollen out further/less

;the order is right left, right left
;where the first two are the two outer pollen
;and the latter two are the inner two pollen


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                           print "INIT ",pc
                           RTL   

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                           
                           print "MAIN ",pc
                           PHB                       
                           PHK                       
                           PLB                             
                           JSR VolcanoLotus         
                           PLB                       
                           RTL                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VolcanoLotus:       JSR VolcanoLotusGfx     
                    LDA $9D     
                    BNE Return02DFC8          
                    STZ !151C,X             
                    JSL $01803A  
                    JSR SubOffscreen0Bnk3   
                    LDA !AA,X    
                    CMP #$40                
                    BPL CODE_02DFAF           
                    INC !AA,X    
CODE_02DFAF:        LDA !C2,X     
                    JSL $0086DF          

VolcanoLotusPtrs:   dw CODE_02DFC9&$FFFF           
                    dw CODE_02DFDF&$FFFF           
                    dw CODE_02DFEF&$FFFF           

Return02DFC8:       RTS                          ; Return 

CODE_02DFC9:        LDA !1540,X             
                    BNE CODE_02DFD6           
                    LDA #$40                
CODE_02DFD0:        STA !1540,X             
                    INC !C2,X     
                    RTS                          ; Return 

CODE_02DFD6:        LSR                       
                    LSR                       
                    LSR                       
                    AND #$01                
                    STA !1602,X             
                    RTS                          ; Return 

CODE_02DFDF:        LDA !1540,X             
                    BNE CODE_02DFE8           
                    LDA #$40                
                    BRA CODE_02DFD0           

CODE_02DFE8:        LSR                       
                    AND #$01                
                    STA !151C,X             
                    RTS                          ; Return 

CODE_02DFEF:        LDA !1540,X             
                    BNE CODE_02DFFB           
                    LDA #$80                
                    JSR CODE_02DFD0         
                    STZ !C2,X     
CODE_02DFFB:        CMP #$38                
                    BNE CODE_02E002           
                    JSR CODE_02E079         
CODE_02E002:        LDA #$02                
                    STA !1602,X             
                    RTS                          ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Volcano Lotus Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


VolcanoLotusTiles:  db $8E,$9E,$E2

VolcanoLotusGfx:    JSR MushroomScaleGfx    
                    LDY !15EA,X                  ; Y = Index into sprite OAM 
                    LDA #$CE                
                    STA $0302|!Base2,Y          
                    STA $0306|!Base2,Y         
                    LDA $0303|!Base2,Y          
                    AND #$B0                
                    ORA #$8B                
                    STA $0303|!Base2,Y          
                    ORA #$C0                
                    STA $0307|!Base2,Y     
                    LDA $0300|!Base2,Y         
                    CLC                       
                    ADC #$08                
                    STA $0308|!Base2,Y    
                    CLC                       
                    ADC #$08                
                    STA $030C|!Base2,Y    
                    LDA $0301|!Base2,Y         
                    STA $0309|!Base2,Y    
                    STA $030D|!Base2,Y    
                    PHX                       
                    LDA !1602,X             
                    TAX                       
                    LDA VolcanoLotusTiles,X 
                    STA $030A|!Base2,Y         
                    INC A                     
                    STA $030E|!Base2,Y         
                    PLX                       
                    LDA !151C,X             
                    CMP #$01                
                    LDA #$B9                
                    BCC CODE_02E05B           
                    LDA #$B5
CODE_02E05B:        STA $030B|!Base2,Y     
                    STA $030F|!Base2,Y     
                    LDA !15EA,X   
                    CLC                       
                    ADC #$08                
                    STA !15EA,X   
                    
                    LDA $0301|!Base2,Y
                    CLC
                    ADC #$08
                    STA $0309|!Base2,Y
                    STA $030D|!Base2,Y
                    
                    
                    LDY #$00                
                    LDA #$01                
                    JSL $01B7B3      
                    RTS                          ; Return         

Pollen_Y:        db $FD,$FD,$FE,$FE

CODE_02E079:        LDA !15A0,X 
                    ORA !186C,X 
                    BNE Return02E0C4          
                    LDA #$03                
                    STA $00                   
CODE_02E085:        LDY #$07                     ; \ Find a free extended sprite slot 
CODE_02E087:        LDA $170B|!Base2,Y                  ;  | 
                    BEQ CODE_02E090              ;  | 
                    DEY                          ;  | 
                    BPL CODE_02E087              ;  | 
                    RTS                          ; / Return if no free slots 

CODE_02E090:        LDA #$0C                     ; \ Extended sprite = Volcano Lotus fire 
                    STA $170B|!Base2,Y                  ; / 
                    LDA !E4,X       
                    CLC                       
                    ADC #$04                
                    STA $171F|!Base2,Y   
                    LDA !14E0,X     
                    ADC #$00                
                    STA $1733|!Base2,Y   
                    LDA !D8,X       
                    CLC
                    ADC #$10
                    STA $1715|!Base2,Y   
                    LDA !14D4,X     
                    ADC #$00
                    STA $1729|!Base2,Y   
                    PHX                       
                    LDX $00                   
                    LDA Pollen_X,X       
                    STA $1747|!Base2,Y   
                    LDA Pollen_Y,X       
                    STA $173D|!Base2,Y   
                    PLX                       
                    DEC $00                   
                    BPL CODE_02E085           
Return02E0C4:       RTS                          ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mushrom Scale GFX Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MushroomScaleGfx:   %GetDrawInfo()       
                    LDA $00                   
                    SEC                       
                    SBC #$08                
                    STA $0300|!Base2,Y         
                    CLC                       
                    ADC #$10                
                    STA $0304|!Base2,Y    
                    LDA $01                   
                    DEC A                     
                    STA $0301|!Base2,Y         
                    STA $0305|!Base2,Y    
                    LDA #$80                
                    STA $0302|!Base2,Y          
                    STA $0306|!Base2,Y         
                    LDA !15F6,X     
                    ORA $64                   
                    STA $0303|!Base2,Y          
                    ORA #$40                
                    STA $0307|!Base2,Y     
                    LDA #$01                
                    LDY #$02                
                    JSL $01B7B3      
                    RTS                          ; Return      



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite Graphics Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DATA_03B83B:                      db $40,$B0
DATA_03B83D:                      db $01,$FF
DATA_03B83F:                      db $30,$C0,$A0,$80,$A0,$40,$60,$B0
DATA_03B847:                      db $01,$FF,$01,$FF,$01,$00,$01,$FF

SubOffscreen0Bnk3:  STZ $03                     ; / 
                    JSR IsSprOffScreenBnk3      ; \ if sprite is not off screen, return 
                    BEQ RETURNONE               ; / 
                    LDA $5B                     ; \  vertical level 
                    AND #$01                    ;  | 
                    BNE VerticalLevelBnk3       ; / 
                    LDA !D8,X                   ; \ 
                    CLC                         ;  | 
                    ADC #$50                    ;  | if the sprite has gone off the bottom of the level... 
                    LDA !14D4,X                 ;  | 
                    ADC #$00                    ;  | 
                    CMP #$02                    ;  | 
                    BPL OffScrEraseSprBnk3      ; /    ...erase the sprite 
                    LDA !167A,X                 ; \ if "process offscreen" flag is set, return 
                    AND #$04                    ;  | 
                    BNE RETURNONE               ; / 
                    LDA $13      
                    AND #$01                
                    ORA $03                   
                    STA $01                   
                    TAY                       
                    LDA $1A    
                    CLC                       
                    ADC DATA_03B83F,Y       
                    ROL $00                   
                    CMP !E4,X       
                    PHP                       
                    LDA $1B    
                    LSR $00                   
                    ADC DATA_03B847,Y       
                    PLP                       
                    SBC !14E0,X     
                    STA $00                   
                    LSR $01                   
                    BCC CODE_03B8A8           
                    EOR #$80                
                    STA $00        
           
CODE_03B8A8:        LDA $00                   
                    BPL RETURNONE   
       
OffScrEraseSprBnk3: LDA !14C8,X                 ; \ If sprite status < 8, permanently erase sprite 
                    CMP #$08                    ;  | 
                    BCC OffScrKillSprBnk3       ; / 
                    LDY !161A,X                 ; \ Branch if should permanently erase sprite 
                    CPY #$FF                    ;  | 
                    BEQ OffScrKillSprBnk3       ; / 
                    PHX
                    TYX
                    LDA #$00                    ; \ Allow sprite to be reloaded by level loading routine 
                    STA !1938,X                 ; / 
                    PLX
OffScrKillSprBnk3:  STZ !14C8,X 
            
RETURNONE:          RTS                         ; Return 

VerticalLevelBnk3:  LDA !167A,X                 ; \ If "process offscreen" flag is set, return 
                    AND #$04                    ;  | 
                    BNE RETURNONE               ; / 
                    LDA $13                     ; \ Return every other frame 
                    LSR                         ;  | 
                    BCS RETURNONE               ; / 
                    AND #$01                
                    STA $01                   
                    TAY                       
                    LDA $1C    
                    CLC                       
                    ADC DATA_03B83B,Y       
                    ROL $00                   
                    CMP !D8,X       
                    PHP                       
                    LDA $1D  
                    LSR $00                   
                    ADC DATA_03B83D,Y       
                    PLP                       
                    SBC !14D4,X     
                    STA $00                   
                    LDY $01                   
                    BEQ CODE_03B8F5           
                    EOR #$80                
                    STA $00  
                 
CODE_03B8F5:        LDA $00                   
                    BPL RETURNONE          
                    BMI OffScrEraseSprBnk3 
   
IsSprOffScreenBnk3: LDA !15A0,X                 ; \ If sprite is on screen, A = 0  
                    ORA !186C,X                 ;  | 
                    RTS                         ; / Return 

