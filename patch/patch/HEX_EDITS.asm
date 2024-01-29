if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
else
	lorom
	!bank = $800000
endif

; ORG $05B129			;Don't disable HDMA after hitting message boxes
; NOP #3				;Disable STZ $0D9F
; ORG $05B296			;Don't disable HDMA after hitting message boxes
; db $0C				;STA $0D9F to TSB $0D9F

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
    db $58,$59,$0A,$0A,$48,$49,$58	;|
    db $59,$0A,$0A,$48,$49,$34,$35	;|
    db $0A,$0A,$24,$25,$34,$35,$0A	;| Bonus roulette tilemap
    db $0A,$24,$25,$36,$37,$0A,$0A	;|
    db $26,$27,$36,$37,$0A,$0A,$26	;|
    db $27							;/
org $02AD4D|!bank					;\ Floating point notations
    db $0A,$0A,$0A,$0A				;/

;ORG $9D30			;title screen "Erase Game" palette darken fix
;db $EA,$EA,$EA,$EA,$EA		;title screen "Erase Game" palette darken fix
ORG $00CBA3|!bank			;Misplaced tile on the keyhole "iris in" effect fix
db $49				;Misplaced tile on the keyhole "iris in" effect fix
;ORG $02CAFA			;Charlie's Arm uses the green palette
;db $4B,$0B			;Charlie's Arm uses the green palette
ORG $048E2E|!bank			;OW Music Still Plays After a Boss Fix
db $80				;OW Music Still Plays After a Boss Fix
ORG $07F47C|!bank			;Flying Red Coins immune to fireballs
db $38				;Flying Red Coins immune to fireballs
ORG $00A439|!bank			;Fix SP1 Exgfx
db $80				;Fix SP1 Exgfx
ORG $009725|!bank			;Change Intro Music in LM (Welcome to Dinosaur Land)
db $9C,$FB,$1D			;Change Intro Music in LM
ORG $05C7BC|!bank			;bg will scroll fast with generator F4 without needing to touch platform C1
db $A9,$08,$EA			;Fast BG Scroll
ORG $00A23B|!bank			;Music continues on pause
db $80				;Music continues on pause
;ORG $00A907			;overworld sprites gfx fix
;db $10,$xx,$1C,$1D		;(OW Sprite Tool Exgfx)
;ORG $03964C			;Rex Yoshi head horizontal disposition
;db $F7,$00,$F7,$00,$F7,$00,$00	;(ASMT - Yoshi Offsets)
;db $00,$00,$00,$00,$08,$09,$00	;(ASMT - Yoshi Offsets)
;db $09,$00,$09,$00,$00,$00,$00	;(ASMT - Yoshi Offsets)
;db $00,$08,$00			;(ASMT - Yoshi Offsets)
;ORG $03964C			;Rex's head to be above his body
;db $00,$00,$00,$00,$00		;Rex's head to be above his body
;ORG $039658			;Rex's head to be above his body
;db $00,$00,$00,$00,$00		;Rex's head to be above his body
;ORG $039664			;Stops Rex's head from bouncing when walking
;db $F0				;Stops Rex's head from bouncing when walking
ORG $02A98B|!bank			;by chdata.
db $00				;these fix red koopas becoming blue and another turning yellow
ORG $02A98F|!bank			; the ORG tells the patch where to make a hex edit
db $00				; the db $00 hex edits the value defined at the ORG (SNES address) 
ORG $02A991|!bank			; from whatever it is to 00
db $01				;look in the rom map for 12B8B to understand this better
ORG $02A995|!bank			; the hex edit basically causes x sprite to turn into x sprite when the special world is passed
db $01				; and since the values are the same it changes into itself
ORG $02895F|!bank			;Fix dir coins restart
db $80				;Fix dir coins restart
ORG $01F75C|!bank			;Yoshi egg crack tile deletion
db $01				;Smoke appearance fix
ORG $01F760|!bank			;Yoshi egg crack tile deletion
db $02				;Smoke appearance fix
ORG $01F7C8|!bank			;Yoshi egg crack tile deletion
db $60				;Smoke appearance fix
ORG $009FAE|!bank			;[Layer3_forest_fog] Layer3 propery 3rd Stripe of tileset C(forest)
db $81				; set to translucent and slowly scrolling
ORG $059072|!bank			;[Layer3_forest_fog] Layer3 stripe pointer for 3rd stripe of tileset C(forest)
db $DE,$95,$05			; set to Fog table (instead of beta cage)
org $038882|!bank			;change Mega mole palette
db $09				; change palette from 8 to C (YXPPCCCT $x1 -> $x9)
org $02A2E7|!bank			;change hammer extended GFX from B to A
db $45,$45,$05,$05		; changed palette from B to A
db $85,$85,$C5,$C5		; (YXPPCCCT: $x7 -> $x5)

; File select
org $05B7F1|!bank ; demo a
	db $7C,$30,$73,$31,$76,$31,$83,$30,$FC,$38,$71,$31,$FC,$38
org $05B815|!bank ; demo b
	db $7C,$30,$73,$31,$76,$31,$83,$30,$FC,$38,$2C,$31,$FC,$38
org $05B839|!bank ; demo c
	db $7C,$30,$73,$31,$76,$31,$83,$30,$FC,$38,$2D,$31,$FC,$38

; status bar rejiggering
org $008C89|!bank
    db $30,$28,$31,$28,$32,$28,$33,$28
	db $34,$28,$FC,$38,$FC,$3C,$FC,$3C
	db $FC,$3C,$FC,$3C,$FC,$38,$FC,$38
	db $4A,$38,$FC,$38,$FC,$38,$4A,$78
	db $76,$3C,$77,$3C,$FC,$3C,$FC,$3C
    db $FC,$3C,$FC,$38,$0D,$28,$0E,$28
    db $16,$28,$18,$28,$1C,$28,$FC,$38
org $008CDF|!bank
    db $2E,$3C,$26,$38,$FC,$38,$FC,$38
    db $FC,$38,$4A,$38,$FC,$38,$FC,$38
    db $4A,$38,$2E,$38,$26,$38,$FC,$38 
org $008E73|!bank
    db $0B
org $008E79|!bank
    db $0C
org $008E7F|!bank
    db $0D

; where to draw coins on status bar
org $008F7F|!bank
db $27
org $008F82|!bank
db $26

; where to draw time on status bar
org $008E8D|!bank
db $FB,$0E

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
db $4D				; format 0bYYY.XXXXX -> change bits to move image around
org $05CC25|!bank			; move "COURSE CLEAR" text Layer 3 text (2nd byte)
db $A9				; format 0bYYY.XXXXX -> change bits to move image around
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

; Palette edits
org ($07F3FE+$1B)|!bank  ; Football
db $05  ; palette A | originally: db $01
org ($07F3FE+$7D)|!bank  ; P-Balloon
db $25  ; palette A | originally: db $21
org ($07F3FE+$2E)|!bank  ; Spike Top
db $15  ; palette A | originally: db $19
org $02CAFA|!bank        ; Chuck Arm
db $4B,$0B  ; palette D | originally db $47,$07

org $02AC18|!bank
db $80				; fix the carry sprite into pipe glitch
org $00EEB2|!bank
db $04				; re-play switch palaces

; Change life swap menu text (2 Player Mode).
; First byte is the tile, second byte is the tile property (YXPC CCTT = $3C = 0011 1100 -> CCC = 111).
org $04F4B6|!bank	; Mario text
	db $0D,$3C		; D
	db $0E,$3C		; E
	db $16,$3C		; M
	db $18,$3C		; O
	db $29,$3C		; (blank)
org $04F4C4|!bank	; Luigi text
	db $12,$3C		; I
	db $1B,$3C		; R
	db $12,$3C		; I
	db $1C,$3C		; S
	db $29,$3C		; (blank)
org $04F4D3|!bank	;\
	db $3C			;|
org $04F4D5|!bank	;| Change tile properties of Demo's lives.
	db $3C			;|
org $04F4D7|!bank	;|
	db $3C			;/
org $04F4DD|!bank	;\
	db $3C			;|
org $04F4DF|!bank	;| Change tile properties of Iris' lives.
	db $3C			;|
org $04F4E1|!bank	;|
	db $3C			;/

; Fix Diggin' Flower arm palette.
org $02CB96|!bank
	db $4B,$0B		; Use palette D (originally: db $47,$07)

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

; Change palette rows for overworld Yoshi. Follows YXPPCCCT convention.
;org $048CDF
;	db $08					;> Yellow Yoshi (originally: $00)
;org $048CE1
;	db $0A					;> Blue Yoshi (originally: $02)
;org $048CE3
;	db $0C					;> Red Yoshi (originally: $04)
;org $048CE5
;	db $0E					;> Green Yoshi (originally: $06)

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
