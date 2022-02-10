; Custom Bounce Block Sprites
; By Kaijyuu
;
; See readme if you don't know how to use
;;;;;;;;;;;;;;;;;;;;;
!RAM_BounceMap16Low			= $7FC275
!RAM_BounceMap16High		= $7FC279
;^two 4 byte tables that holds the map16 number for custom block changes
!RAM_BounceMap16Low_SA1		= $6132
!RAM_BounceMap16High_SA1	= $6136
;^same but for SA-1
!RAM_BounceMap16Low_GSU		= $6132
!RAM_BounceMap16High_GSU	= $6136
;^same but for Super FX
!EnableBounceUnrestrictor = 1	; Set this to 1 so that if a bounce sprite's $9C value is set to 0xFF, its GFX are customisable.

!RAM_BounceTileTbl			= $7FC27D
;^4 byte table which only is used if BBU is activated
; Vanilla bounce blocks with $16C1,x being set to 0xff will have a custom tile number (low byte) controlled by this address
!RAM_BounceTileTbl_SA1		= $613A
;^same but for SA-1
!RAM_BounceTileTbl_GSU		= $613A
;^same but for Super FX

!ApplyCoinFix = 1				; Coins leave a solid block if a bounce block collects it. Set this to 0 to disable for some reason.

;;;;;;;;;;;;;;;;;;;;;
;Don't touch these.
;;;;;;;;;;;;;;;;;;;;;
	!dp = $0000
	!addr = $0000
	!bank = $800000
	!sa1 = 0
	!gsu = 0

if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!bank = $000000
	!RAM_BounceMap16Low = !RAM_BounceMap16Low_GSU
	!RAM_BounceMap16High = !RAM_BounceMap16High_GSU
	!RAM_BounceTileTbl = !RAM_BounceTileTbl_GSU
	!gsu = 1
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!bank = $000000
	!RAM_BounceMap16Low = !RAM_BounceMap16Low_SA1
	!RAM_BounceMap16High = !RAM_BounceMap16High_SA1
	!RAM_BounceTileTbl = !RAM_BounceTileTbl_SA1
	!sa1 = 1
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Defines
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ORG $00BFBC					; routine that changes block's map16 in smw. Used for all block changes
	autoclean JML BLOCK_STUFF		; hijack it so bounce block sprites can change into any map16 number (remove this?)

ORG $029052					; Hijack bounce block sprite routines
	autoclean JML MAIN


org $02924E
if !EnableBounceUnrestrictor

		JML BlkBounceTileHack

else

	LDA $1699|!addr,x
	TAX

endif

if !ApplyCoinFix

ORG $029347			;\ Fixes the bug where hitting a block under a coin
	JSR COIN_FIX		; |will leave an invisible solid block in place of the coin
				; |
ORG $02D51E			; |(random freespace in bank 02)
				; |
COIN_FIX:			; |This is not neccessary for this patch to run, 
	LDA #$02		; |so delete it if for some reason you don't want it
	JMP $91BA		;/

endif

freecode

MainStart:

POINTERS:
dw Bounce8
dw Bounce9
dw BounceA
dw BounceB
dw BounceC
dw BounceD
dw BounceE		; pointers
dw BounceF		
dw Bounce10
dw Bounce11		; feel free to add more if needed
dw Bounce12		; max possible would be 86
dw Bounce13
dw Bounce14
dw Bounce15
dw Bounce16
dw Bounce17
dw Bounce18
dw Bounce19
dw Bounce1A
dw Bounce1B
dw Bounce1C
dw Bounce1D
dw Bounce1E
dw Bounce1F

BOUNCE_SPEED_Y:			; Generic bounce sprite speed modifiers for y speed
	db $10,$00,$00,$F0	; these are added to the y speed every frame for sprites that use it
BOUNCE_SPEED_X:			; Generic bounce sprite speed modifiers for x speed
	db $00,$F0,$10,$00	;
BOUNCE_OAM: 			; OAM addresses for bounce extended sprites
	db $10,$14,$18,$1C

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite code starts here
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Bounce8:	; SMB3 brick
	; graphics

	JSR SUB_OFFSCREEN	; check if offscreen
				; $00 holds the x position relative to screen border
				; $01 holds the y
				; carry set if offscreen
	BCS .SMB3_SKIP_GFX	; skip graphics if offscreen

	LDA BOUNCE_OAM,y	; get OAM offset
	TAX			; stick in x

	LDA $00			; x pos
	STA $0200|!addr,X		; store to OAM
	
	LDA $01			; y pos
	STA $0201|!addr,x		; store to OAM

	LDA #$40		; tile number
	STA $0202|!addr,x 		; store to OAM

	LDA $1901|!addr,y		; properties
	ORA $64			; add in prority bits from level settings
	STA $0203|!addr,x		; store to OAM

	TXA			; set tile size
	LSR			; 
	LSR			;
	TAX			;
	LDA #$02		; #$02 = 16x16
	STA $0420|!addr,x		; #$00 = 8x8

.SMB3_SKIP_GFX

	LDA $9D			; check if sprites are locked
	BNE .SMB3_RETURN		; return if so
	LDA $169D|!addr,y		; check if init should be run
	BNE .SMB3_NO_INIT	; branch if not
	LDA #$01		; stop init from running again
	STA $169D|!addr,y
	JSR InvisSldFromBncSpr
;	PHK
;	PEA ..return-1
;	PEA $8070
;	JSL $029265|!bank
;..return
	; More init would go here if there were more
.SMB3_NO_INIT

	; speeds

	JSR SUB_SPEEDS		; regular bounce block speed routines

	LDA $16C9|!addr,y		; $16C9 = LxxxxxBB
				; L = layer. 0 = layer 1, 1 = layer 2
				; x = unused extra bits
				; BB = speed modifiers
	AND #$03		; get speed modifiers only
	TAX			; stick in x
	LDA $16B1|!addr,y		; sprite y speed
	CLC
	ADC BOUNCE_SPEED_Y,x	; add to speed based on table
	STA $16B1|!addr,y		; set y speed
	LDA $16B5|!addr,y		; sprite x speed
	CLC
	ADC BOUNCE_SPEED_X,x	; add to speed based on table
	STA $16B5|!addr,y		; set x speed

	; check if timer's ended

	LDA $16C5|!addr,y		; timer
	BNE .SMB3_RETURN		; return if not yet 0
				; this timer is automatically decremented every frame until it hits 0
    ;This code runs when switching back into a block.
	JSR TileFromBounceSpr0

	LDA #$00
	STA $1699|!addr,y	; kill bounce block sprite

.SMB3_RETURN
	RTS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Put your own bounce block sprites here


Bounce9: ;>OnOff block
	JSR SUB_OFFSCREEN	; check if offscreen
				; $00 holds the x position relative to screen border
				; $01 holds the y
				; carry set if offscreen
	BCS .OnOffSkipGfx	; skip graphics if offscreen

	LDA BOUNCE_OAM,y	; get OAM offset
	TAX			; stick in x

	LDA $00			; x pos
	STA $0200|!addr,X		; store to OAM
	
	LDA $01			; y pos
	STA $0201|!addr,x		; store to OAM

	LDA #$8A		; tile number
	STA $0202|!addr,x 		; store to OAM

	LDA $1901|!addr,y		; properties
	ORA $64			; add in prority bits from level settings
	STA $0203|!addr,x		; store to OAM

	TXA			; set tile size
	LSR			; 
	LSR			;
	TAX			;
	LDA #$02		; #$02 = 16x16
	STA $0420|!addr,x		; #$00 = 8x8

.OnOffSkipGfx

	LDA $9D			; check if sprites are locked
	BNE .SMB3_RETURN		; return if so
	LDA $169D|!addr,y		; check if init should be run
	BNE .SMB3_NO_INIT	; branch if not
	LDA #$01		; stop init from running again
	STA $169D|!addr,y
	; Init would go here if there was one
	LDA $14AF|!addr          ;\Flip on/off
	EOR #$01                 ;|
	STA $14AF|!addr          ;/
	LDA #$0B                 ;\SFX
	STA $1DF9|!addr          ;/
	JSR InvisSldFromBncSpr
.SMB3_NO_INIT

	; speeds

	JSR SUB_SPEEDS		; regular bounce block speed routines

	LDA $16C9|!addr,y		; $16C9 = LxxxxxBB
				; L = layer. 0 = layer 1, 1 = layer 2
				; x = unused extra bits
				; BB = speed modifiers
	AND #$03		; get speed modifiers only
	TAX			; stick in x
	LDA $16B1|!addr,y		; sprite y speed
	CLC
	ADC BOUNCE_SPEED_Y,x	; add to speed based on table
	STA $16B1|!addr,y		; set y speed
	LDA $16B5|!addr,y		; sprite x speed
	CLC
	ADC BOUNCE_SPEED_X,x	; add to speed based on table
	STA $16B5|!addr,y		; set x speed

	; check if timer's ended

	LDA $16C5|!addr,y		; timer
	BNE .SMB3_RETURN		; return if not yet 0
				; this timer is automatically decremented every frame until it hits 0
    ;This code runs when switching back into a block.
	JSR TileFromBounceSpr0

	LDA #$00
	STA $1699|!addr,y	; kill bounce block sprite

.SMB3_RETURN

	RTS
BounceA:
	;RTS	; uncomment an RTS if you want to use a new sprite slot. Commented to save space if unused
BounceB:
	;RTS
BounceC:
	;RTS
BounceD:
	;RTS
BounceE:
	;RTS
BounceF:
	;RTS
Bounce10:
	;RTS
Bounce11:
	;RTS
Bounce12:
	;RTS
Bounce13:
	;RTS
Bounce14:
	;RTS
Bounce15:
	;RTS
Bounce16:
	;RTS
Bounce17:
	;RTS
Bounce18:
	;RTS
Bounce19:
	;RTS
Bounce1A:
	;RTS
Bounce1B:
	;RTS
Bounce1C:
	;RTS
Bounce1D:
	;RTS
Bounce1E:
	;RTS
Bounce1F:
	RTS


; Various other routines below
; You should never need to modify them

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main hijack routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MAIN:
	LDY $9D			;
	BNE CODE_RESTORE	;
	LDY $16C5|!addr,x		;
	BEQ CODE_RESTORE	;
	DEC $16C5|!addr,x		; Restore old code
CODE_RESTORE:			;

	CMP #$08		; if bounce sprite number 8 or above...
	BCS CUST_BOUNCE_SPRITES	; do custom bounce block sprite code
	JML $02905E		; otherwise return to normal code

CUST_BOUNCE_SPRITES:
	PHB		;\
	PHK		; |wrapper
	PLB		; |
	PHX		; |
	PHY		;/
	TXY		; stick sprite table offset in y 
	SEC
	SBC #$08	; subtract 8 for jump offset
	ASL 		; x2 for two byte pointers 
	TAX
	JSR (POINTERS,x); jump to appropriate subroutine
	PLY		;\
	PLX		; |wrapper
	PLB		;/
	JML $02919C|!bank	; return

;;;;;;;;;;;;;;;;;;;;;;;;;
; Generic speed routine
;;;;;;;;;;;;;;;;;;;;;;;;;

			; this sets the sprite's position based on speed values
SUB_SPEEDS:		; taken from $02B51A & $02B526
	LDA $16B1|!addr,y	; sprite y speed
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC $16B9|!addr,y	; accumulating fraction bits for y speed
	STA $16B9|!addr,y	; set it
	PHP
	LDA $16B1|!addr,y	; sprite y speed
	LSR
	LSR
	LSR
	LSR
	CMP #$08
	LDX #$00
	BCC SPEED_1
	ORA #$F0
	DEX
SPEED_1:
	PLP
	ADC $16A1|!addr,y	; sprite y (low)
	STA $16A1|!addr,y	; set it
	TXA
	ADC $16A9|!addr,y	; sprite y (high)
	STA $16A9|!addr,y	; set it

	; do it all again for x speeds

	LDA $16B5|!addr,y	; sprite x speed
	ASL
	ASL
	ASL
	ASL
	CLC
	ADC $16BD|!addr,y	; accumulating fraction bits for x speed
	STA $16BD|!addr,y	; set it
	PHP
	LDA $16B5|!addr,y	; sprite x speed
	LSR
	LSR
	LSR
	LSR
	CMP #$08
	LDX #$00
	BCC SPEED_2
	ORA #$F0
	DEX
SPEED_2:
	PLP
	ADC $16A5|!addr,y	; sprite x (low)
	STA $16A5|!addr,y	; set it
	TXA
	ADC $16AD|!addr,y	; sprite x (high)
	STA $16AD|!addr,y	; set it

	RTS		; return


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subroutine that checks if offscreen. Taken from $0291F8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_OFFSCREEN:
	LDX #$00	; check if on layer 2
	LDA $16C9|!addr,y	; highest bit of this number is set if so
	BPL OFFSCREEN_1
	LDX #$04	; all this is to check if offscreen
OFFSCREEN_1:		;
	LDA $16A1|!addr,y	; bounce sprite y (low)
	SEC
	SBC $1C,x	; layer 1 y (low). 
	STA $01		; store to scratch
	LDA $16A9|!addr,y	; bounce sprite y (high)
	SBC $1D,x	; layer 1 y (high)
	BNE OFFSCREEN_END; offscreen if not 0 
	LDA $16A5|!addr,y	; sprite x (low)
	SEC
	SBC $1A,x	; layer 1 x (low)
	STA $00		; store to scratch
	LDA $16AD|!addr,y	; sprite x (high)
	SBC $1B,x	; layer 1 x (high)
	BNE OFFSCREEN_END; branch if offscreen
	CLC		; clear carry (on screen)
	RTS

OFFSCREEN_END:
	SEC	; set carry (offscreen)
	RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generates a blocks (either invisible or set in $16C1,y). Taken and modified from $0291B8
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TileFromBounceSpr0:
    LDA $16C1|!addr,y
    BRA arLabelDC
InvisSldFromBncSpr:
	LDA #$09
arLabelDC:
	STA $9C
	LDA $16A5|!addr,y
	CLC : ADC #$08
	AND #$F0
	STA $9A
	LDA $16AD|!addr,y
	ADC #$00
	STA $9B
	LDA $16A1|!addr,y
	CLC : ADC #$08
	AND #$F0
	STA $98
	LDA $16A9|!addr,y
	ADC #$00
	STA $99
	LDA $16C9|!addr,y
	ASL : ROL
	AND #$01
	STA $1933|!addr
	TYX		; The game assumes X is the bounce sprite index but this patch uses Y instead
	JSL $00BEB0|!bank
	TXY
RTS

if !EnableBounceUnrestrictor

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Bounce Block Unrestrictor Stuff
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BlkBounceTileHack:
	LDA.w $16C1|!addr,x
	CMP.b #$FF		; FF will generate with custom sprite tile (and map16 tile)
	BEQ .CustomSprTile
	LDA.w $1699|!addr,x
	TAX
	LDA.w $91F0,x		; DB = 02
	STA.w $0202|!addr,y
	JML $029258

.CustomSprTile
	LDA.l !RAM_BounceTileTbl,x
	STA.w $0202|!addr,y
	JML $029258|!bank

endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code for custom bounce block map16 changes
;
; Probably not a good idea to touch this
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

BLOCK_STUFF:
	SEP #$30		; 8 bit A X Y
				; old code
	LDA $9C			; block number
	CMP #$FF		; 0xff tells the routine it's a custom bouncesprite
	BEQ CUSTOM_BLOCKS	; do normal stuff if below 1c
				; jump to custom block code otherwise
	JML $00BFC0|!bank		; return


CUSTOM_BLOCKS:
	;The inital change when a block is hit.
			; If the code reaches here, we have a custom map16 number to turn the block into
	LDA $03,s	; Get x index for custom block map16 number
	TAX		; stick in x
	REP #$30        ; Index (16 bit) Accum (16 bit) 
	LDA $98		; block x       
	AND #$3FF0              
	STA $04                   
	LDA $9A		; block y        
	LSR                       
	LSR    		; bunch of code from all.log that I really don't know the exact purpose of
	LSR                       
	LSR                       
	AND #$000F              
	ORA $04                   
	TAY                       
	SEP #$20	; 8 bit A
	LDA !RAM_BounceMap16Low,x  	; get low map16 number 
	STA [$6B],Y		; set low byte 
	PHA
	LDA !RAM_BounceMap16High,x	; get high byte of map16 number
	STA [$6E],Y		; set it
	XBA
	PLA				; get full map16 number
	REP #$20		; 16 bit A
	ASL A			; more code I'm uncertain the purpose of
	TAY			;
	JML $00C0FB|!bank		; finish up with regular SMW code
;;;;;;;;;;;;;;;;;;;;;;;;;
