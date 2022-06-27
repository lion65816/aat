;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; SMW Banzai Bill (sprite 9F), by imamelia
;;
;; This is a disassembly of sprite 9F in SMW, the Banzai Bill.
;;
;; Uses first extra bit: YES
;;
;; If the first extra bit is set, the sprite will face the player initially.  If not, it will
;; act like the original Banzai Bill and not show up at all when the player is on the
;; wrong side.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;(Small config by Rykon-V73)Edit the GFX and palette here:

!BBillHorzSpeed = 	$E8

;Change sound effect here:

!BanzaiSFX	= 	$09
!BanzaiSongBank =	$1DFC

!BanzaiGFX1 	=	$80	;tile of the upper left part of the sprite. It's also used for the bottom part.
!BanzaiGFX2	=	$82	;tile of the almost upper left part of the sprite. It's also used for the bottom part.
!BanzaiGFX3	=	$84	;tile of the almost upper left part of the sprite. It's also used for the bottom part.
!BanzaiGFX4	= 	$86	;tile of the upper right part of the sprite. It's also used for the bottom part.
!BanzaiGFX5	=	$A0	;tile of one of the 1st eye part of the sprite.
!BanzaiGFX6	=	$88	;tile of the 2nd eye part of the sprite.
!BanzaiGFX7	=	$CE	;tile of one of the connector parts of the sprite. It's also used below.
!BanzaiGFX8	=	$EE	;tile of the other connector part of the sprite. It's also used below.
!BanzaiGFX9	=	$C0	;tile of the first part of the GFX file of the sprite's mouth.
!BanzaiGFX10	=	$C2	;tile of the 2nd part of the GFX file of the sprite's mouth.
!BanzaiGFX11	=	$8E	;tile of the 3rd part of the GFX file of the sprite's mouth.
!BanzaiGFX12	=	$AE	;tile of the last part of the GFX file of the sprite's mouth.

!BanzaiPal1	=	$3F	;uses palette 3 on 2nd GFX page. For the 1st palette and GFX page 1, set to $30.
!BanzaiPal2	=	$BF	;uses palette 3 on 2nd GFX page. For the 1st palette and GFX page 1, set to $B0.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!XSpeed = !BBillHorzSpeed

print "INIT ",pc
%SubHorzPos()
TYA		;
BEQ MaybeErase	; if the sprite isn't facing the player, it might be erased
STA !157C,x	;
FinishInit:		;
LDA #!BanzaiSFX		;
STA !BanzaiSongBank|!Base2	; play the bullet sound effect
RTL		;

MaybeErase:	;
LDA !7FAB10,x	;
AND #$04	; if the extra bit is set...
BNE FinishInit	; don't erase the sprite
LDA !14C8,x	;
CMP #$08		; if the sprite is in status 07 or less...
BCC EraseSprite1	;
LDA !161A,x	;
CMP #$FF		;
BEQ EraseSprite1	;
TAX
LDA #$00		;
STA !1938,x
LDX $15E9|!Base2
EraseSprite1:	;
STZ !14C8,x	;
RTL

print "MAIN ",pc
PHB : PHK : PLB
JSR BanzaiBillMain
PLB
RTL

BanzaiBillMain:
JSR BanzaiBillGFX	; draw the sprite

LDA !14C8,x	;
CMP #$02		; if the sprite status is 02...
BEQ Return0	; return
LDA $9D		; if sprites are locked...
BNE Return0	; return

%SubOffScreen()

LDA #!XSpeed	;
LDY !157C,x	; if the sprite is facing right...
BNE NoFlipSpeed	;
EOR #$FF		; flip its X speed
INC		; (this wasn't in the original; I added it to account for my modification)
NoFlipSpeed:	;
STA !B6,x		; store the X speed value

JSL $018022|!BankB	; update sprite X position without gravity
JSL $01A7DC|!BankB	;

; Check for "Don't use default interaction with player" tweaker bit in $167A,x
; Format: dpmksPiS
; d=Don't use default interaction with player
	PHP ; save carry, in case d==1
	LDA !167A,x
	AND #$80
	BNE kill_interaction
	JMP normal_interaction

kill_interaction: PLP
	BCC Return0
	PHY
	;JSL $00F606 ;>Kill the player.
	JSL $00F5B7	;>Hurt the player.
	PLY
	RTS

normal_interaction: PLP

Return0:		;
RTS		;

XDisp:
db $00,$10,$20,$30,$00,$10,$20,$30,$00,$10,$20,$30,$00,$10,$20,$30
db $30,$20,$10,$00,$30,$20,$10,$00,$30,$20,$10,$00,$30,$20,$10,$00
YDisp:
db $00,$00,$00,$00,$10,$10,$10,$10,$20,$20,$20,$20,$30,$30,$30,$30

Tilemap:
db !BanzaiGFX1,!BanzaiGFX2,!BanzaiGFX3,!BanzaiGFX4,!BanzaiGFX5,!BanzaiGFX6,!BanzaiGFX7,!BanzaiGFX8,!BanzaiGFX9,!BanzaiGFX10,!BanzaiGFX7,!BanzaiGFX8,!BanzaiGFX11,!BanzaiGFX12,!BanzaiGFX3,!BanzaiGFX4
TileProp:
db !BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal1,!BanzaiPal2,!BanzaiPal2

BanzaiBillGFX:
%GetDrawInfo()

LDA !157C,x	;
STA $02		; save the sprite direction

LDX #$0F		; 16 tiles to draw
GFXLoop:		;

PHX		;
LDA $02		; if the sprite is facing right...
BNE NoChangeDisp	;
TXA		;
CLC		;
ADC #$10	; change the index for the X displacement
TAX		;
NoChangeDisp:	;

LDA $00		;
CLC		;
ADC XDisp,x	; set the X displacement of the tiles
STA $0300|!Base2,y	;
PLX

LDA $01		;
CLC		;
ADC YDisp,x	; set the Y displacement of the tiles
STA $0301|!Base2,y	;

LDA Tilemap,x	; set the tile number
STA $0302|!Base2,y	;

LDA TileProp,x	; set the tile properties
PHX		;
LDX $02		;
BNE NoFlip	;
EOR #$40		;
NoFlip:		;
PLX		;
STA $0303|!Base2,y	;

INY #4		; increment the OAM index
DEX		; decrement the tile counter
BPL GFXLoop	; if there are more tiles to draw, run the loop again

LDX $15E9|!Base2
LDY #$02		; the tiles are 16x16
LDA #$0F		; and we drew 16 tiles
JSL $01B7B3|!BankB	;
RTS		;