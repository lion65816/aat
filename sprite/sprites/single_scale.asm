;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Single Mushroom Scale, by Darolac
;;
;; This platform sinks when Mario is touching it from above and rises when it is not.
;; The first extra byte customises its sinking speed; the second one, its rising speed
;; (vanilla values: 08FE). Please note that very high speeds can make the scale tiles 
;; not appear.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!cutoff = 1	; fixes the cutoff that appears when the platforms despawn in a position of non-equilibrium. Be careful, as
			; black bars may appear on the top of the screen when lots of tiles are drawn.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Scaletiles:

db $02,$07

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine wrapper
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print "MAIN ",pc
PHB
PHK
PLB
JSR Main
PLB
RTL

print "INIT ",pc

LDA !D8,x					;Sprite Ypos Low Byte (table)
STA !1534,x
LDA !14D4,x					;Sprite Ypos High Byte (table)
STA !151C,x	
RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:

JSR GFX

LDA $9D			; check if sprites are locked.
BEQ +
JMP Return
+

LDA #$04
%SubOffScreen()

if !cutoff = 1
LDA !14C8,x
BNE +
LDA !186C,x
BNE +
LDA !AA,x
BEQ +
Loop:
LDA !1534,x
CLC
ADC #$10
STA !1534,x
LDA !151C,x
ADC #$00
STA !151C,x

LDA #$07			;Set scale tiles
STA $9C						;Generate Map16 tile
LDA !E4,x					;Sprite Xpos Low Byte (table)
STA $9A						;Block creation: X position (low)
LDA !14E0,x					;Sprite Xpos High Byte (table)
STA $9B						;Block creation: X position (high)
LDA !1534,x					;Sprite Ypos Low Byte (table)
STA $98						;Block creation: Y position (low)
LDA !151C,x					;Sprite Ypos High Byte (table)
STA $99						;Block creation: Y position (high)

JSL $00BEB0|!BankB			;Generate tiles

LDA !1534,x
CMP !D8,x
BCC Loop
LDA !151C,x
CMP !14D4,x
BCC Loop
+
endif

JSL $01B44F|!BankB					;Invisible Block Main
LDY #$00
BCS +
INY
+
LDA !extra_byte_1,x
STA $00
LDA !extra_byte_2,x
STA $01
LDA $00,y
STA !AA,x
CPY #$00
BEQ +
LDA !1534,x
CMP !D8,x
BCC +
LDA !151C,x
CMP !14D4,x
BCC +
LDA !1534,x
STA !D8,x
LDA !151C,x
STA !14D4,x
STZ !AA,x
+

LDA !D8,x					;Sprite Ypos Low Byte (table)
AND #$0F					;Generate tile every 16 pixel
BNE Update

LDA !AA,x
BEQ Update

LDA Scaletiles,y			;Set scale tiles
STA $9C						;Generate Map16 tile
LDA !E4,x					;Sprite Xpos Low Byte (table)
STA $9A						;Block creation: X position (low)
LDA !14E0,x					;Sprite Xpos High Byte (table)
STA $9B						;Block creation: X position (high)
LDA !D8,x					;Sprite Ypos Low Byte (table)
STA $98						;Block creation: Y position (low)
LDA !14D4,x					;Sprite Ypos High Byte (table)
STA $99						;Block creation: Y position (high)

JSL $00BEB0|!BankB			;Generate tiles

Update:
JSL $01801A|!BankB					;ypos no gravity
Return:
RTS					; end 2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GFX:

%GetDrawInfo()

LDA $00
SEC
SBC #$08
STA $0300|!Base2,y
CLC
ADC #$10
STA $0304|!Base2,y

LDA $01
SEC
SBC #$01
STA $0301|!Base2,y
STA $0305|!Base2,y

LDA #$80
STA $0302|!Base2,y
STA $0306|!Base2,y

LDA !15F6,x
ORA $64
STA $0303|!Base2,y
ORA #$40
STA $0307|!Base2,y	 

LDA #$01			; we draw 2 tiles
LDY #$02			; 16x16 tiles
JSL $01B7B3|!BankB	; finish OAM write routine

RTS					; end this gfx routine
