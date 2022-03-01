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
ORG $00F878|!bank 			;Free Vertical Scrolling Camera
db $80				;Free Vertical Scrolling Camera
ORG $0090D9|!bank			;DEMO START
db $15,$4E,$04,$4B,$5E,$FF	;DEMO START
ORG $00910D|!bank			;DEMO START
db $15,$4E,$14,$4B,$5E,$FF	;DEMO START
ORG $009141|!bank			;DEMO START
db $34,$34,$34,$34,$B4,$34	;DEMO START
ORG $009172|!bank			;DEMO START
db $B4,$B4,$34,$B4,$34,$34	;DEMO START
db $09				;Fix the palette for Mega Moles
ORG $02FBBF|!bank			;Fix GFX for Boo rings and generators
db $88,$88,$a8,$8e,$aa,$ae,$88	;Fix GFX for Boo rings and generators
db $88				;Fix GFX for Boo rings and generators
ORG $01FA37|!bank			;Fix GFX for Boo block
db $88				;Fix GFX for Boo block
ORG $01C34C|!bank			;Non flipping fire flower
db $00				;Non flipping fire flower
ORG $02FDB8|!bank			;Death bat ceiling fix
db $ae,$ae,$c0,$e8		;Death bat ceiling fix
ORG $019BC1|!bank			;Tile83Fix
db $69,$69,$C4,$C4,$69,$69	;Tile83Fix
ORG $019C25			;Tile83Fix
db $69,$69			;Tile83Fix
ORG $01DEE3|!bank			;Tile83Fix
db $58,$59,$69,$69,$48,$49,$58	;Tile83Fix
db $59,$69,$69,$48,$49,$34,$35	;Tile83Fix
db $69,$69,$24,$25,$34,$35,$69	;Tile83Fix
db $69,$24,$25,$36,$37,$69,$69	;Tile83Fix
db $26,$27,$36,$37,$69,$69,$26	;Tile83Fix
db $27				;Tile83Fix
ORG $02AD4D|!bank			;Tile83Fix
db $69,$69,$69,$69		;Tile83Fix
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
db $20

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