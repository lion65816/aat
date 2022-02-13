header 
lorom 

; ORG $05B129			;Don't disable HDMA after hitting message boxes
; NOP #3				;Disable STZ $0D9F
; ORG $05B296			;Don't disable HDMA after hitting message boxes
; db $0C				;STA $0D9F to TSB $0D9F
ORG $00F878			;Free Vertical Scrolling Camera
db $80				;Free Vertical Scrolling Camera
ORG $0090D9			;DEMO START
db $15,$4E,$04,$4B,$5E,$FF	;DEMO START
ORG $00910D			;DEMO START
db $15,$4E,$14,$4B,$5E,$FF	;DEMO START
ORG $009141			;DEMO START
db $34,$34,$34,$34,$B4,$34	;DEMO START
ORG $009172			;DEMO START
db $B4,$B4,$34,$B4,$34,$34	;DEMO START
db $09				;Fix the palette for Mega Moles
ORG $02FBBF			;Fix GFX for Boo rings and generators
db $88,$88,$a8,$8e,$aa,$ae,$88	;Fix GFX for Boo rings and generators
db $88				;Fix GFX for Boo rings and generators
ORG $01FA37			;Fix GFX for Boo block
db $88				;Fix GFX for Boo block
ORG $01C34C			;Non flipping fire flower
db $00				;Non flipping fire flower
ORG $02FDB8			;Death bat ceiling fix
db $ae,$ae,$c0,$e8		;Death bat ceiling fix
ORG $019BC1			;Tile83Fix
db $69,$69,$C4,$C4,$69,$69	;Tile83Fix
ORG $019C25			;Tile83Fix
db $69,$69			;Tile83Fix
ORG $01DEE3			;Tile83Fix
db $58,$59,$69,$69,$48,$49,$58	;Tile83Fix
db $59,$69,$69,$48,$49,$34,$35	;Tile83Fix
db $69,$69,$24,$25,$34,$35,$69	;Tile83Fix
db $69,$24,$25,$36,$37,$69,$69	;Tile83Fix
db $26,$27,$36,$37,$69,$69,$26	;Tile83Fix
db $27				;Tile83Fix
ORG $02AD4D			;Tile83Fix
db $69,$69,$69,$69		;Tile83Fix
;ORG $9D30			;title screen "Erase Game" palette darken fix
;db $EA,$EA,$EA,$EA,$EA		;title screen "Erase Game" palette darken fix
ORG $00CBA3			;Misplaced tile on the keyhole "iris in" effect fix
db $49				;Misplaced tile on the keyhole "iris in" effect fix
;ORG $02CAFA			;Charlie's Arm uses the green palette
;db $4B,$0B			;Charlie's Arm uses the green palette
ORG $048E2E			;OW Music Still Plays After a Boss Fix
db $80				;OW Music Still Plays After a Boss Fix
ORG $07F47C			;Flying Red Coins immune to fireballs
db $38				;Flying Red Coins immune to fireballs
ORG $00A439			;Fix SP1 Exgfx
db $80				;Fix SP1 Exgfx
ORG $00FFD8			;SRAM Increase
db $05				;SRAM Increase
ORG $009725			;Change Intro Music in LM (Welcome to Dinosaur Land)
db $9C,$FB,$1D			;Change Intro Music in LM
ORG $05C7BC			;bg will scroll fast with generator F4 without needing to touch platform C1
db $A9,$08,$EA			;Fast BG Scroll
ORG $00A23B			;Music continues on pause
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
ORG $02A98B			;by chdata.
db $00				;these fix red koopas becoming blue and another turning yellow
ORG $02A98F			; the ORG tells the patch where to make a hex edit
db $00				; the db $00 hex edits the value defined at the ORG (SNES address) 
ORG $02A991			; from whatever it is to 00
db $01				;look in the rom map for 12B8B to understand this better
ORG $02A995			; the hex edit basically causes x sprite to turn into x sprite when the special world is passed
db $01				; and since the values are the same it changes into itself
ORG $02895F			;Fix dir coins restart
db $80				;Fix dir coins restart
ORG $01F75C			;Yoshi egg crack tile deletion
db $01				;Smoke appearance fix
ORG $01F760			;Yoshi egg crack tile deletion
db $02				;Smoke appearance fix
ORG $01F7C8			;Yoshi egg crack tile deletion
db $60				;Smoke appearance fix
ORG $009FAE			;[Layer3_forest_fog] Layer3 propery 3rd Stripe of tileset C(forest)
db $81				; set to translucent and slowly scrolling
ORG $059072			;[Layer3_forest_fog] Layer3 stripe pointer for 3rd stripe of tileset C(forest)
db $DE,$95,$05			; set to Fog table (instead of beta cage)
org $038882			;change Mega mole palette
db $09				; change palette from 8 to C (YXPPCCCT $x1 -> $x9)
org $02A2E7			;change hammer extended GFX from B to A
db $45,$45,$05,$05		; changed palette from B to A
db $85,$85,$C5,$C5		; (YXPPCCCT: $x7 -> $x5)

;Hex edits for Course Clear
org $05CC17			; move "DEMO" text Layer 3 text (2nd byte)
db $4D				; format 0bYYY.XXXXX -> change bits to move image around
org $05CC25			; move "COURSE CLEAR" text Layer 3 text (2nd byte)
db $A9				; format 0bYYY.XXXXX -> change bits to move image around
org $05CC42			; disable stripe image: "(time icon)     x 50 = "
db $FF
org $05CD3F			; disable stripe image: "Bonus x 0"
db $FF
org $05CEA3			; disable stripe image for tallying bonus / time counters
db $FF
org $05CD04			; instead of storing "Time x 50" STA $04F0 use STZ $04F0
db $9C
org $00FAE0
db $F0,$F0,$F0,$F1 ;change item reward table for non-small player
org $00FAE7
db $F0,$F0,$F0,$F1 ;change item reward table for non-small player
