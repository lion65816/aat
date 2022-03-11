;===========================;
;  Grey Falling Platform    ;
;===========================;

print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR GreyFallingPlat
	PLB
print "INIT ",pc
	RTL

;=========
;Main
;=========	       
GreyFallingPlat:
	JSR Graphics            ; Always Draw graphics for the sprite.       
	LDA $9D                 ;\
	BNE .return             ;/ If sprites are locked, return.  

	%SubOffScreen()
	LDA !AA,X               ;\
	BEQ .checkContact       ;/ If sprite is stationary, branch.
	
	LDA.w !1540,X			;\             
	BNE .updateSpeed        ;/ If initial fall timer is set, branch.
	LDA !AA,X               ;\   
	CMP.b #$40              ; | Wait until it gets faster and goes beyond 40 ..
	BPL .updateSpeed        ;/ Then branch.
	CLC
	ADC.b #$05              ; Increase the speed by 2 all the time (until it's above 40).                
	STA !AA,X               ; Store Y speed.  
.updateSpeed
	JSL $01801A|!BankB      ; Apply update with affecting position.
.checkContact	
	JSL $01B44F|!BankB      ; Make the sprite "solid".     
	BCC .return          
	LDA !AA,X               ;\    
	BNE .return             ;/ If the Y speed is non-zero, there's no need to continue.
	LDA.b #$03              ;\                
	STA !AA,X               ;/ Initial Y speed when stood on.
	LDA.b #$04  			;\              
	STA.w !1540,X           ;/ Timer it takes to fall down initially when stood upon.
.return
	RTS                     ; Return 

;================
; Graphics
;================
XDISP: 
 db $00,$10,$20,$30
Tiles:
 db $60,$61,$61,$62

Graphics:
	%GetDrawInfo()
	LDX #$03               ; # of tiles to go through loop and draw tiles = 03.
.loop
	LDA $00                ;\
	CLC                    ; |
	ADC XDISP,x            ; | Load X position and apply X displacement.
	STA $0300|!Base2,y     ;/ Store to sprite X position.
	LDA $01                ;\
	STA $0301|!Base2,y     ;/ There is no YDISP, so return.
	LDA Tiles,x            ;\
	STA $0302|!Base2,y     ;/ Draw current tile from loop.
	LDA #$03               ;\ Property from .cfg
	ORA $62                ; | Add in sprite property byte.
	STA $0303|!Base2,y     ;/ And store to sprite props.
	INY #4                 ; Increment Y 4 times, because OAM is 8x8.
	DEX                    ; Decrease # of times to go through loop.
	BPL .loop              ; Loop until all tiles are done.

	LDX $15E9|!Base2       ; Pull sprite index.
	LDY #$02               ; 16x16 tiles.
	LDA #$03               ; We drew 4 tiles.
	JSL $01B7B3|!BankB     ; Call OAM write.
	RTS                    ; Return.