;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Chasing Porcupuffer
; By Darolac
;
; This porcupuffer will follow Mario even underwater. It doesn't move along layer 1 as the
; original porcupuffer does, and it's also customisable regarding its speed and acceleration.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ", pc
%SubHorzPos()                            
TYA                       
STA !157C,X     
RTL                       


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                           
print "MAIN ", pc
PHB                       
PHK                       
PLB                             
JSR PorcuPuffer         
PLB                       
RTL                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Defines

!XAccel = $05 ; X acceleration.
!MaxSpeed = $1E ; Max speed of the Porcupuffer.
!YSpeed = $08 ; Y speed of the Porcupuffer.

PorcuPuffXAccel:   
db !XAccel,-!XAccel
PorcuPuffMaxXSpeed: 
db !MaxSpeed,-!MaxSpeed
PorcuPuffYSpeed:
db !YSpeed,-!YSpeed

PorcuPuffer:        
JSR PorcuPufferGfx                  
LDA !14C8,x            
EOR #$08
ORA $9D
BNE Return         
;%SubOffScreen() ; uncomment this if you want the sprite to dissapear if offscreen. 
JSL $01803A|!BankB  
%SubHorzPos()     
TYA                       
STA !157C,x

LDA $14
AND #$03
BNE +
LDA !B6,x    ; \ Branch if at max speed
CMP PorcuPuffMaxXSpeed,y ;  | 
BEQ +          ; / 
CLC                       ; \ Otherwise, accelerate
ADC PorcuPuffXAccel,y    ;  |
STA !B6,x    ; /
+

JSL $018022|!BankB
JSL $019138|!BankB

REP #$20		;
LDA $96			;
CLC				;
ADC #$0010		;
STA $0C			;
SEP #$20		;
LDY #$00
LDA $0C
SEC
SBC !D8,x
LDA $0D
SBC !14D4,x
BPL +
INY
+
LDA PorcuPuffYSpeed,y
TAY
LDA !164A,x           
BNE +     
LDY #$08
+
STY !AA,x

LDA !14E0,x	
CMP $5D
BCC +
STZ !AA,x
+

JSL $01801A|!BankB

Return:
RTS                       ; Return 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PorcuPuffer graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PorcuPufferDispX:   
db $F8,$08,$F8,$08,$08,$F8,$08,$F8

PorcuPufferDispY:   
db $F8,$F8,$08,$08

PorcuPufferTiles:
db $C4,$C6,$E4,$E6,$C4,$C6,$E4,$EC

PorcuPufferGfxProp:
db $3D,$3D,$3D,$3D,$7D,$7D,$7D,$7D

PorcuPufferGfx:

%GetDrawInfo()
LDA $14     
AND #$04                
STA $03                   
LDA !157C,x    
STA $02                   
PHX                       
LDX #$03                
GFXLoop:
LDA $01                   
CLC                       
ADC PorcuPufferDispY,x  
STA $0301|!Base2,Y         
PHX                       
LDA $02                   
BNE +           
TXA                       
ORA #$04                
TAX                       
+        
LDA $00                   
CLC                       
ADC PorcuPufferDispX,x  
STA $0300|!Base2,y        
LDA PorcuPufferGfxProp,x 
ORA $64                   
STA $0303|!Base2,y         
PLA                       
PHA                       
ORA $03                   
TAX                       
LDA PorcuPufferTiles,x  
STA $0302|!Base2,y         
PLX                       
INY                       
INY                       
INY                       
INY                       
DEX                       
BPL GFXLoop          
PLX                       
LDY #$02                
LDA #$03                
JSL $01B7B3|!BankB      
RTS                       ; Return 