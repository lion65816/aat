;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Trouter
;; by Sonikku
;; Description: From SMB2, these red fish hop upward, and like the dolphins, act
;; as platforms to the player. Unlike the dolphins, these sprites don't need
;; water to jump (exception: you set bit 0 of the first extra property byte).
;; The minimum height is the position you placed them.
;; Uses Extra Bit: YES
;; If the Extra Bit is set, it will be a "friendly", blue Trouter, that will
;; do no harm to the player. The settings below still apply, however.
;;
;; Uses first Extra Property Byte: YES
;; Byte 0: Makes this sprite buoyant.
;; Byte 1: Allow carrying it.
;; Byte 2: Allow spin jump to kill it.
;;
;; NOTE: If using TrouterStomp.cfg, extra bit will have no effect.
;; 
!YSPD =	$D0	; jumping y speed
!TILE =	$E2	; tilemap of sprite
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; INIT and MAIN JSL targets
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	PRINT "INIT ",pc
	LDA !7FAB28,x
	AND #$01
	BNE BUOYANCE
	LDA !D8,x
	STA !151C,x
	LDA !14D4,x
	STA !157C,x
	LDA #!YSPD
	STA !AA,x
BUOYANCE:
	LDA !1656,x
	AND #$10
	BNE NOBIT
	LDA !7FAB10,x
	AND #$04
	BEQ NOBIT
	LDA #$07	; palette of sprite when extra bit set.
	STA !15F6,x
	LDA #$01
	STA !1594,x
NOBIT:	RTL         

	PRINT "MAIN ",pc			
	PHB
	PHK				
	PLB				
	CMP #09
	BCS STUN
	JSR SPRITE_ROUTINE	
	PLB
	RTL     
STUN:	JSR SUB_GFX
	LDA $14
	AND #$01
	BNE MAINRTN
	LDA !15F6,x
	EOR #$40
	STA !15F6,x
MAINRTN:	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; SPRITE_ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RETURN:	RTS
SPRITE_ROUTINE:
	JSR SUB_GFX	; jump to gfx routine
	LDA #$00
	%SubOffScreen()	; process off screen situation
	LDA $9D		; return if..
	BNE RETURN	; sprites locked.
	LDA !14C8,x	; return if..
	CMP #$08	; sprite's status
	BNE RETURN	; isn't normal.
	JSL $018032|!BankB	; interact with sprites
	LDA $14		; if current frame..
	AND #$03	; isn't a multiple of 4..
	BNE NOFLIP	; don't flip sprite.
	LDA !15F6,x	; if it is..
	EOR #$40	; flip sprite properties by #$40..
	STA !15F6,x	; to flip horizontally, and store.
NOFLIP:	JSL $01802A|!BankB	; update positions based on speed.
	DEC !AA,x	; decrease y speed.
	DEC !AA,x	; decrease y speed.
	LDA $14		; and if current frame..
	AND #$0F	; isn't a multiple of #$0F..
	BNE NOINCS	; don't increase speed.
	INC !AA,x	; otherwise, increase speed.
NOINCS:	JSL $01A7DC|!BankB	; is mario touching sprite?
	BCC NOCON2	; if he isn't, skip passed this code
	LDA $1490|!Base2	; if the star is active
	BNE STARKIL	; kill sprite
	LDA $0E		; is mario above the sprite?
	CMP #$E8	; cause if he isn't..
	BPL SPWINS	; sprite should hurt him.
	LDA $7D		; is mario speed upward?
	BMI NOCON2	; if so, don't ride sprite.
	LDA $140D|!Base2	; is mario spin jumping?
	BEQ NOSPIN	; ..if not, then let him ride sprite.
	LDA !7FAB28,x	; can sprite..
	AND #$04	; be spin jumped?
	BEQ NOSPIN	; if not, don't kill it.
	LDA #$04	; set sprite status..
	STA !14C8,x	; and store
	LDA #$1F	; set cloud timer..
	STA !1540,x	; and store
	LDA #$08	; play sound effect..
	STA $1DF9|!Base2	; and store.
	LDA #$F8	; set mario y speed..
	STA $7D		; so he doesn't fall immediately.
	LDA #$01	; give mario 200 points..
	JSL $02ACE5|!BankB	; and store
	JSL $07FC3B|!BankB	; jump to spin jump stars routine.
NOCON2:	BRA NOCON	; jump to NOCON
NOSPIN:	LDA !7FAB28,x	; if sprite..
	AND #$02	; cannot be carried..
	BEQ NOCARRY	; then sprite won't be carriable.
	LDA $187A|!Base2	; if mario is on yoshi..
	ORA $148F|!Base2	; or carrying something..
	BNE NOCARRY	; then don't let mario attempt to carry it.
	BIT $16		; is mario pressing the right button?
	BVC NOCARRY	; if he isn't, then don't let him carry it.
	LDA #$0B	; set sprite as being carried..
	STA !14C8,x	; store to sprite status.
	LDA !167A,x	; make it so..
	EOR #$80	; sprite now interacts..
	STA !167A,x	; with mario normally.
	LDA #$10	; set grabbing timer..
	STA $1498|!Base2	; and store.
	STZ !1540,x
	RTS
NOCARRY:	JSL $01B44F|!BankB	; load invisible solid block routine (yes I was lazy shut up)
	LDA #$08	; disable interaction..
	STA !154C,x	; for 8 frames.
	BRA NOCON	; jump to NOCON
KILXSPD:	db $F0,$10
SPWINS:	LDA !154C,x	; if timer is set..
	ORA !1594,x	; or extra bit set..
	BNE NOCON	; don't hurt mario.
	JSL $00F5B7|!BankB	; if it isn't set, hurt him.
	BRA NOCON	; jump to NOCON
STARKIL:	LDA #$02	; set sprite status..
	STA !14C8,x	; as killed.
	LDA #$D0	; set sprite y speed..
	STA !AA,x	; and store it.
	JSL $01ACF9|!BankB	; jump to getrand routine..
	AND #$01	; and now there are only 2 values possible..
	TAY		; so transfer a to y..
	LDA KILXSPD,y	; and randomly set x speed to the 2 values a bit above..
	STA !B6,x	; and store.
	LDA #$03	; play sound effect..
	STA $1DF9|!Base2	; and store.
	LDA #$01	; and also give mario some points..
	JSL $02ACE5|!BankB	; cause he totally needs them.
NOCON:	LDA !1540,x	; if timer is set..
	BNE SETSPD	; force sprite upward (so sprite doesn't constantly jump up and get stuck in water).
	LDA !7FAB28,x
	AND #$01
	BEQ NOBUOYANCE
	LDA !164A,x
	BEQ RETURN2
	LDA #$08
	STA !1540,x
	BRA SETSPD

NOBUOYANCE:
	LDA !151C,x	; check if..
	CMP !D8,x	; sprite is at or below original position..
	BPL RETURN2	; if its above said position, return.
	LDA !157C,x	; now lets check the high byte..
	CMP !14D4,x	; since if its high byte isn't the same, it might always jump..
	BNE RETURN2	; so we return if its not at the original y screen.
	LDA #$08	; and set a timer..
	STA !1540,x	; so its speed is set for a few frames.
	JSR SPLASH	; delete/comment out this line to disable water splash.
SETSPD:	LDA #!YSPD	; set y speed..
	STA !AA,x	; and store it.
	RTS		; return.
SPLASH:	LDY #$0B	; load number of times to go through loop
FNDFREE:	LDA $17F0|!Base2,y	; if there is a free slot..
	BEQ FNDONE	; show the effect.
	DEY		; if not, decrease y..
	BPL FNDFREE 	; and run through loop again.
	RTS		; return.
FNDONE:	LDA #$07	; set minor extended sprite type..
	STA $17F0|!Base2,y	; and store.
	LDA !D8,x	; the effect..
	SEC		; will be about..
	SBC #$10	; 16 pixels..
	STA $17FC|!Base2,y	; above sprite.
	LDA !14D4,x	; this just sets..
	SBC #$00	; the high byte..
	STA $1814|!Base2,y	; so it doesn't go all sdgdfhg.
	LDA !E4,x	; effect has the same x position..
	STA $1808|!Base2,y	; as sprite.
	LDA !14E0,x	; and this sets the high byte of..
	STA $18EA|!Base2,y	; its x position.
	LDA #$00	; and here we set that its active..
	STA $1850|!Base2,y	; I guess?
RETURN2:	RTS		; return.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SUB_GFX:             %GetDrawInfo()       ; after: Y = index to sprite OAM ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  
                    LDA !14C8,x
                    CMP #$08
                    BEQ NOTDEAD

                    LDA !15F6,x
                    ORA #$80
                    STA !15F6,x
NOTDEAD:
                    ;LDA #$F0
                    ;STA $0309,y

                    LDA !157C,x             ; $02 = sprite direction
                    STA $02

                    LDA $00                 ; set x position of the tile
                    STA $0300|!Base2,y

                    LDA $01                 ; set y position of the tile
                    STA $0301|!Base2,y

                    LDA #!TILE                ; set tile number
                    STA $0302|!Base2,y


                    LDA !15F6,x

                    ORA $64

                    STA $0303|!Base2,y

                    ;INY                     ; get the index to the next slot of the OAM
                    ;INY                     ; (this is needed if you wish to draw another tile)
                    ;INY
                    ;INY
                    
                    LDY #$02                ; #$02 means the tiles are 16x16
                    LDA #$00                ; This means we drew one tile
                    JSL $01B7B3|!BankB
                    RTS

