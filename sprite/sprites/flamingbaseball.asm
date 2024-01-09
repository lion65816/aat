
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite INIT
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "INIT ",pc
		    RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite MAIN
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB                     ; \
PHK                     ;  | The same old
PLB                     ; /
JSR MainCode            ;  Jump to sprite code
PLB                     ; Yep
RTL                     ; Return1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MainCode:


LDA !14C8,x
CMP #$02
BEQ Deadbaseball

JSL $018022|!bank
LDA #$02
%SubOffScreen()
JSR SmashThings
JSR SUB_DRAW_GFX
RTS

Deadbaseball:
JSR SUB_DEAD_GFX
RTS

SmashThings:
JSL $03B69F|!bank ; get clipping

PHX
TXY
LDX #!SprSize-1

XLoop:
LDA !14C8,x
CMP #$08
BCC NoContact
LDA !167A,x
AND #$02
BNE NoContact

JSL $03B6E5|!bank

JSL $03B72B|!bank
BCC NoContact
JSR HitHit

NoContact:
DEX
BPL XLoop
PLX
RTS


HitHit:

LDA #$02
STA !14C8,x

LDA #$08
JSL $02ACEF|!bank
LDA #$15
STA $1DF9|!addr

LDA !B6,y
AND #$80
BEQ GoRight

LDA #$C0
STA !B6,x
BRA GoUp

GoRight:

LDA #$40
STA !B6,x

GoUp:

LDA #$C0
STA !AA,x


LDA #$02
STA !14C8,y
LDA #$00
SEC
SBC !B6,y
STA !B6,y


DoneBatting:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERIC GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SUB_DRAW_GFX:				    ; after: Y = index to sprite OAM ($6300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  
	%GetDrawInfo()


                   
XC:                 

		    LDA $00                 ; set x position of the tile
                    STA $0300|!addr,y

		    LDA !B6,x
		    AND #$80
		    BEQ BattingRight


                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings	
                    STA $0303|!addr,y             ; set properties

		    BRA BattingDraw

	BattingRight:

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
		    ORA #$40
                    STA $0303|!addr,y             ; set properties

	BattingDraw:

                    LDA $01                 ; set y position of the tile
                    STA $0301|!addr,y

		    LDA $14
		    LSR
		    LSR
		    AND #$01
		    BEQ SecondTile

                    LDA #$6D
                    STA $0302|!addr,y
		    BRA DrawIt

SecondTile:
		    LDA #$7D
                    STA $0302|!addr,y

DrawIt:

		    INY
		    INY
		    INY
		    INY

		    LDA !B6,x
		    AND #$80
		    BEQ BattingRight2

		    LDA $00                 ; set x position of the tile
		    CLC
		    ADC #$08
                    STA $0300|!addr,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
                    STA $0303|!addr,y             ; set properties

		    BRA BattingDraw2

	BattingRight2:
		    LDA $00                 ; set x position of the tile
		    SEC
           	    SBC #$08
                    STA $0300|!addr,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
		    ORA #$40
                    STA $0303|!addr,y             ; set properties

	BattingDraw2:

                    LDA $01                 ; set y position of the tile
                    STA $0301|!addr,y
	
                    LDA #$7E
                    STA $0302|!addr,y

                    LDY #$00                ; #$02 means the tiles are 16x16
                    LDA #$01                ; This means we drew one tile
                    JSL $01B7B3|!bank
                    RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_DEAD_GFX:
		    %GetDrawInfo()

		    LDA $00                 ; set x position of the tile
                    STA $0300|!addr,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
                    STA $0303|!addr,y             ; set properties

                    LDA $01                 ; set y position of the tile
                    STA $0301|!addr,y

                    LDA #$AD
                    STA $0302|!addr,y

                    LDY #$00                ; #$02 means the tiles are 16x16
                    LDA #$00                ; This means we drew one tile
                    JSL $01B7B3|!bank

		    RTS
