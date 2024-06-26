if read1($00FFD6) == $15
	sfxrom
	!dp = $6000
	!addr = !dp
	!gsu = 1
	!bank = $000000
elseif read1($00FFD5) == $23
	sa1rom
	!dp = $3000
	!addr = $6000
	!sa1 = 1
	!bank = $000000
endif

; DEMO START
org $0090D9|!bank
	db $15,$4E,$04,$4B,$5E,$FF
org $00910D|!bank
	db $15,$4E,$14,$4B,$5E,$FF
org $009141|!bank
	db $34,$34,$34,$34,$B4,$34
org $009172|!bank
	db $B4,$B4,$34,$B4,$34,$34

; IRIS START
org $0090DF|!bank
	db $5D,$00,$4C,$00,$FF,$FF
org $009113|!bank
	db $5D,$00,$5C,$00,$FF,$FF
org $009178|!bank
	db $F4,$B4,$34,$B4,$34,$00

; Fix GFX for Boo rings and generators
org $02FBBF|!bank			
	db $88,$88,$A8,$8E,$AA,$AE,$88,$88

; Fix GFX for Boo block
org $01FA37|!bank
	db $88

; Non flipping fire flower
org $01C34C|!bank
	db $00

; Death bat ceiling fix
org $02FDB8|!bank
	db $ae,$ae,$c0,$e8

; Blank tile ($83) fixes. Map to AAT-specific blank tile $0A in GFX00.
org $019BC1|!bank					;\ Piranha Plant tilemap
    db $0A,$0A,$C4,$C4,$0A,$0A		;/
    
org $019C25|!bank					;\ Portable springboard tilemap
    db $0A,$0A						;/
    
org $01DEE3|!bank					;\
    db $58,$59,$0A,$0A,$48,$49,$58		;|
    db $59,$0A,$0A,$48,$49,$34,$35		;|
    db $0A,$0A,$24,$25,$34,$35,$0A		;| Bonus roulette tilemap
    db $0A,$24,$25,$36,$37,$0A,$0A		;|
    db $26,$27,$36,$37,$0A,$0A,$26		;|
    db $27							;/
    
org $02AD4D|!bank					;\ Floating point notations
    db $0A,$0A,$0A,$0A				;/

ORG $00CBA3|!bank			;Misplaced tile on the keyhole "iris in" effect fix
db $49					;Misplaced tile on the keyhole "iris in" effect fix

ORG $048E2E|!bank			;OW Music Still Plays After a Boss Fix
db $80					;OW Music Still Plays After a Boss Fix

ORG $07F47C|!bank			;Flying Red Coins immune to fireballs
db $38					;Flying Red Coins immune to fireballs

ORG $00A439|!bank			;Fix SP1 Exgfx
db $80					;Fix SP1 Exgfx

ORG $009725|!bank			;Change Intro Music in LM (Welcome to Dinosaur Land)
db $9C,$FB,$1D				;Change Intro Music in LM

ORG $05C7BC|!bank			;bg will scroll fast with generator F4 without needing to touch platform C1
db $A9,$08,$EA				;Fast BG Scroll

ORG $02A98B|!bank			;by chdata.
db $00					;these fix red koopas becoming blue and another turning yellow
ORG $02A98F|!bank			; the ORG tells the patch where to make a hex edit
db $00					; the db $00 hex edits the value defined at the ORG (SNES address) 
ORG $02A991|!bank			; from whatever it is to 00
db $01					;look in the rom map for 12B8B to understand this better
ORG $02A995|!bank			; the hex edit basically causes x sprite to turn into x sprite when the special world is passed
db $01					; and since the values are the same it changes into itself

ORG $02895F|!bank			;Fix dir coins restart
db $80					;Fix dir coins restart

ORG $01F75C|!bank			;Yoshi egg crack tile deletion
db $01					;Smoke appearance fix
ORG $01F760|!bank			;Yoshi egg crack tile deletion
db $02					;Smoke appearance fix
ORG $01F7C8|!bank			;Yoshi egg crack tile deletion
db $60					;Smoke appearance fix

ORG $009FAE|!bank			;[Layer3_forest_fog] Layer3 propery 3rd Stripe of tileset C(forest)
db $81					; set to translucent and slowly scrolling
ORG $059072|!bank			;[Layer3_forest_fog] Layer3 stripe pointer for 3rd stripe of tileset C(forest)
db $DE,$95,$05				; set to Fog table (instead of beta cage)


; initial lives (15)
org $009E25|!bank
db $0E

;Noteblock
org $02878A|!bank
db $02
org $0291F2|!bank
db $C2

;Hex edits for Course Clear
org $05CC17|!bank			; move "DEMO" text Layer 3 text (2nd byte)
db $4D					; format 0bYYY.XXXXX -> change bits to move image around
org $05CC25|!bank			; move "COURSE CLEAR" text Layer 3 text (2nd byte)
db $A9					; format 0bYYY.XXXXX -> change bits to move image around
org $05CC42|!bank			; disable stripe image: "(time icon)     x 50 = "
db $FF
org $05CD3F|!bank			; disable stripe image: "Bonus x 0"
db $FF
org $05CEA3|!bank			; disable stripe image for tallying bonus / time counters
db $FF
org $05CD04|!bank			; instead of storing "Time x 50" STA $04F0 use STZ $04F0
db $9C

org $00FAE0|!bank
db $F0,$F0,$F0,$F1 ;change item reward table for non-small player
org $00FAE7|!bank
db $F0,$F0,$F0,$F1 ;change item reward table for non-small player


org $02AC18|!bank
db $80				; fix the carry sprite into pipe glitch
org $00EEB2|!bank
db $04				; re-play switch palaces


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;
; Lemmy hex edits.
; Note: Specific taunts relating to Lemmy below are based on: https://www.spriters-resource.com/snes/smarioworld/sheet/144218/
;;;;;;;;;;;;;;;;;;;;

; Fix Lemmy's head dislocation for Taunt B (side face).
org $03CEFE|!bank
	db $FD			; X position (originally: db $F8)
org $03CF00|!bank
	db $05			; X position (originally: db $00)

; Fix Lemmy's head dislocation for Taunt B (forward face).
org $03CF04|!bank
	db $FE			; X position (originally: db $FB)
org $03CF06|!bank
	db $FE			; X position (originally: db $FB)
org $03CF07|!bank
	db $06			; X position (originally: db $03)

; Fix Lemmy's head dislocation for Taunt A (side face #1).
org $03CF16|!bank
	db $FD			; X position (originally: db $F8)
org $03CF18|!bank
	db $05			; X position (originally: db $00)

; Fix Lemmy's head dislocation for Taunt A (side face #2).
org $03CF1C|!bank
	db $FD			; X position (originally: db $F8)
org $03CF1E|!bank
	db $0D			; X position (originally: db $08)

; Use a unique second tile for Lemmy's hair (tile numbers).
org $03D12E|!bank	; Taunt B (forward face)
	db $52,$43		; (originally: db $12,$12)
org $03D135|!bank	; Taunt F (forward face)
	db $52,$43		; (originally: db $12,$12)
org $03D15A|!bank	; Taunt E (big left eye/looking left/tongue face)
	db $78,$79		; (originally: db $12,$12)
org $03D15F|!bank	; Taunt E (big right eye/looking right)
	db $79,$78		; (originally: db $12,$12)
org $03D171|!bank	; Taunt D (big right eye/looking right)
	db $79,$78		; (originally: db $12,$12)
org $03D177|!bank	; Taunt D (big left eye/looking left)
	db $78,$79		; (originally: db $12,$12)

; Use a unique second tile for Lemmy's hair (tile properties).
org $03D243|!bank	; Taunt B (forward face)
	db $05			; (originally: db $45)
org $03D24A|!bank	; Taunt F (forward face)
	db $05			; (originally: db $45)
org $03D26F|!bank	; Taunt E (big left eye/looking left/tongue face)
	db $05			; (originally: db $45)
org $03D273|!bank	; Taunt E (big right eye/looking right)
	db $45			; (originally: db $05)
org $03D285|!bank	; Taunt D (big right eye/looking right)
	db $45			; (originally: db $05)
org $03D28C|!bank	; Taunt D (big left eye/looking left)
	db $05			; (originally: db $45)

;;;;;;;;;;;;;;;;;;;;
; Wendy hex edits (needs SP3 = ExGFX18D).
; Note: Specific taunts relating to Wendy below are based on: https://www.spriters-resource.com/snes/smarioworld/sheet/144218/
;;;;;;;;;;;;;;;;;;;;

; Fix Wendy's head dislocation for Taunt B (forward face).
org $03CF8E|!bank
	db $FE			; X position (originally: db $FB)
org $03CF90|!bank
	db $FE			; X position (originally: db $FB)
org $03CF91|!bank
	db $06			; X position (originally: db $03)

; Wendy's bow fix for Taunt C.
org $03CFAF|!bank
	db $08
org $03CFB5|!bank
	db $08
org $03D1D7|!bank
	db $1F,$1E
org $03D1DD|!bank
	db $1E,$1F

; Use a unique second tile for Wendy's bow (tile numbers).
org $03D1B9|!bank	; Taunt B (forward face)
	db $43			; (originally: db $52)
org $03D1C0|!bank	; Taunt F (forward face)
	db $43			; (originally: db $52)
org $03D1E5|!bank	; Taunt E (tongue face)
	db $43			; (originally: db $52)
org $03D1EA|!bank	; Taunt E (forward face)
	db $43			; (originally: db $52)
org $03D1FB|!bank	; Taunt D (big right eye/looking right)
	db $79,$78		; (originally: db $52,$52)
org $03D201|!bank	; Taunt D (big left eye/looking left)
	db $78,$79		; (originally: db $52,$52)

; Use a unique second tile for Wendy's bow (tile properties).
org $03D2CD|!bank	; Taunt B (forward face)
	db $09			; (originally: db $49)
org $03D2D4|!bank	; Taunt F (forward face)
	db $09			; (originally: db $49)
org $03D2F9|!bank	; Taunt E (tongue face)
	db $09			; (originally: db $49)
org $03D2FE|!bank	; Taunt E (forward face)
	db $09			; (originally: db $49)
org $03D30F|!bank	; Taunt D (big right eye/looking right)
	db $49			; (originally: db $09)
org $03D316|!bank	; Taunt D (big left eye/looking left)
	db $09			; (originally: db $49)

; Use a unique second tile for the Wendy Decoy's bow.
org $03D21A|!bank
	db $69			; Tile number (originally: db $68)
org $03D32E|!bank
	db $05			; Tile property (originally: db $45)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Only applies to sprite memory $0A
org $02A773+$A
db $13    ;Highest slot for normal sprites
org $02A7AC+$A
db $FF    ;Lowest slot-1 for normal sprites
org $02A786+$A
db $04    ;Highest slot for reserved sprite 1
org $02A799+$A
db $03    ;Highest slot for reserved sprite 2 (has a hardcoded lowest slot 0)
org $02A7BF+$A
db $00    ;Lowest slot-1 for reserved sprite 1 (Slot 0 is reserved for held items)
org $02A7D2+$A
db $86    ;Reserved sprite 1 ID, also applies to custom sprite $86
org $02A7E4+$A
db $6D    ;Reserved sprite 2 ID, ($6D is Wiggler disassembly)

; Banzai Bill hex edits (needs SP2 = ExGFX181 and SP4 = ExGFX182).
org $02D5C4|!bank						;\
	db $80,$82,$84,$86,$A0,$88,$CE,$EE	;| Tilemap
	db $C0,$C2,$E0,$E2,$8E,$AE,$E4,$EC	;/
org $02D5D4|!bank						;\
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3D	;| Tile properties
	db $3D,$3D,$3D,$3D,$3D,$3D,$3D,$3C	;/

; Remap floating point notation tiles (score/1-Up) to free up space in GFX00.
org $02AD51|!bank						;\ 1st half
	db $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A	;| originally: $44,$54,$46,$47,$44,$54,$46,$47
	db $56,$56,$56,$56					;/             $56,$29,$39,$38
org $02AD63|!bank						;\ 2nd half
	db $0A,$0A,$0A,$0A,$0A,$0A,$0A,$0A	;| originally: $44,$54,$46,$47,$45,$45,$45,$45
	db $0A,$0A,$0A,$0A,$57,$57,$57,$57	;|             $55,$55,$55,$55,$57,$57,$57,$57
	db $4E,$0A,$4F,$0A					;/             $4E,$44,$4F,$54

; Remap some of the water splash tiles (goodbye tile $68).
org $028D42|!bank
	db $64,$64				;> originally: $68,$68

; Demo/Iris on Yoshi victory pose fix.
; Source: https://smwc.me/1226116
org $00DCEC+$14
	db $00					;> originally: $0E

; Fix the "partially red" overworld Yoshi glitch.
org $048A36
	db $42,$22,$43,$22,$52,$22,$53,$22

; Remove Yoshi's throat tile when swallowing.
org $01F08B|!bank
	db $0A					;> Tile number (originally: $3F)
org $01F097|!bank
	db $00					;> Tile properties (originally: $01)

; Change broken brick tile palettes from 8 to A.
org $028B8C|!bank
	db $04,$04,$84,$84,$84,$C4,$44,$04	;> originally: $00,$00,$80,$80,$80,$C0,$40,$00

; Change castle entrance door palette from 8 to A.
org $02F6DA|!bank
	db $25					;> originally: $21

; Change Yoshi rescue message location.
org $01EC2C
LDA #$00 : NOP #2

; width of door enterable region of the door (up to 0x10, default 0x08) 
org $00F44B : db $10

; offset of door enterable region, which is half of above (default 0x04)
org $00F447 : db $05 

; Allows play SFX when exiting horizontal pipes.
org $00D24E
	LDA $7D
	NOP
	NOP
; Allow re-entering any castle without L+R
org $049199
    NOP #6
    
; Activate Unused Yoshi Dust
org $028BB4
db $B9

; Skip Player Select Menu
ORG $009DFA
	INC $0100
	BRA +
	
ORG $009E0B
	+
	LDX.b #$00
	
ORG $05B872
	db $FF

; Change "Nintendo Presents" Timer
org $0093C5
    lda.b #$80
    
; Dino-Rhino Stuck Against Walls Fix
org $039C6F
    db $FF,$01
    
; Disable Title Screen Colors
org $009A9E
BRA +
org $009AA4
+

; Don't Erase Sprites on File Select
org $009C9F
    nop #4
    
; Dim screen brightness on File Select similar to Erase File screen
org $009CD4
    dw $39C9

org $009CD7
    db $60
    
; Don't reset lives, powerup, etc when loading a save
org $009E1C|!bank
	STZ.w $13C9|!addr
	BRA +
org $009E54|!bank
+
; Fix the glitch where bouncing on a note block can allow you to collect a coin
; positioned 16 screens away and one block above
; Source: https://www.smwcentral.net/?p=viewthread&t=94186
org $0292AC
	db $10
org $0292BD
	db $10
org $0292FF
	db $10
org $029310
	db $10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Miscellaneous palette hex edits ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org $038882|!bank			;change Mega mole palette
db $09					; change palette from 8 to C (YXPPCCCT $x1 -> $x9)

org $02A2E7|!bank			;change hammer extended GFX from B to A
db $45,$45,$05,$05			; changed palette from B to A
db $85,$85,$C5,$C5			; (YXPPCCCT: $x7 -> $x5)

ORG $07F47D|!bank			;Flying Mushroom
db $2A					;change palette from 8 to D (green)

org ($07F3FE+$1B)|!bank  ; Football
db $05  ; palette A | originally: db $01

org ($07F3FE+$7D)|!bank  ; P-Balloon
db $25  ; palette A | originally: db $21

org ($07F3FE+$2E)|!bank  ; Spike Top
db $15  ; palette A | originally: db $19

org $02CAFA|!bank        ; Chuck Arm
db $4B,$0B  ; palette D | originally db $47,$07

; Fix Diggin' Flower arm palette.
org $02CB96|!bank
	db $4B,$0B		; Use palette D (originally: db $47,$07)
	

org $02A988	; Change from 10 to 80 to disable the green and red koopa shells
	db $80		;from becoming yellow and blue after the special world is passed
org $02A98F	; What sprite Green Koopa becomes after beating Special World
	db $04
org $02A995	; What Red Koopa becomes after beating Special World 
	db $05
