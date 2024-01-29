;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Castle destruction cutscene hex edits.
; All of $0CB800~$0CBE85 (1,669 bytes) is being treated as freespace for the stripe images.
; Therefore, the addresses for each cutscene's stripe images need to be readjusted first.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
else
	lorom
	!bank = $800000
endif

; Repoint stripe image pointer for the Layer 2 background in the World 4 scene.
org $0084DF|!bank
db $56,$BA,$0C	;> Originally: $00,$B8,$0C

; Repoint stripe image pointer for the Layer 2 background in the World 6 scene.
org $00859C|!bank
db $56,$BA,$0C	;> Originally: $B9,$BB,$0C

; Repoint stripe image pointer for the Layer 1 castle.
org $00859F|!bank
db $00,$B8,$0C	;> Originally: $BF,$B9,$0C

; Repoint stripe image pointer for the Layer 2 background in the World 1/2/5 scenes.
org $0085CF|!bank
db $56,$BA,$0C	;> Originally: $02,$BD,$0C

; Generic stripe image for the Layer 1 castle.
; Dimensions are 8x8 8x8 tiles, plus 1x6 8x8 tiles.
; 183 bytes in total.
org $0CB800|!bank
db $20,$00,$5F,$FE	;> Blank out the entire layer
db $F8,$00

db $20,$F3,$00,$0F	;> First row, 8 tiles, $0F = 16-1 bytes
db $E0,$00
db $80,$01,$81,$01
db $82,$01,$83,$01
db $84,$01,$85,$01
db $E4,$00

db $21,$13,$00,$0F
db $F0,$00
db $90,$01,$91,$01
db $92,$01,$93,$01
db $94,$01,$95,$01
db $F4,$00

db $21,$33,$00,$0F
db $E1,$00
db $A0,$01,$A1,$01
db $A2,$01,$A3,$01
db $A4,$01,$A5,$01
db $E5,$00

db $21,$53,$00,$0F
db $F1,$00
db $B0,$01,$B1,$01
db $B2,$01,$B3,$01
db $B4,$01,$B5,$01
db $F5,$00

db $21,$73,$00,$0F
db $E2,$00
db $C8,$01,$C9,$01
db $E3,$01,$E4,$01
db $E5,$01,$E6,$01
db $E6,$00

db $21,$93,$00,$0F
db $F2,$00
db $D8,$01,$D9,$01
db $F3,$01,$F4,$01
db $F5,$01,$F6,$01
db $F6,$00

db $21,$B3,$00,$0F
db $E3,$00
db $E8,$01,$E9,$01
db $EB,$01,$EC,$01
db $ED,$01,$EE,$01
db $E7,$00

db $21,$D3,$00,$0F
db $F3,$00
db $F8,$01,$F9,$01
db $FB,$01,$FC,$01
db $FD,$01,$FE,$01
db $F7,$00

db $21,$F4,$00,$0B	;> Last row, 6 tiles, $0B = 12-1 bytes
db $D0,$89,$D0,$C9
db $E0,$09,$E1,$09
db $D0,$C9,$E2,$09

db $FF

; Generic stripe image for the Layer 2 backgrounds.
; Dimensions are 24x14 8x8 tiles.
; Rows 1-12 use palette 3, and rows 13-14 use palette 2.
; 735 bytes in total.
org $0CBA56|!bank
db $30,$00,$5F,$FE	;> Blank out the entire layer
db $FA,$28

db $30,$64,$00,$2F	;> First row, 24 tiles, $2F = 48-1 bytes
db $00,$0C,$01,$0C,$02,$0C,$03,$0C,$04,$0C,$05,$0C,$06,$0C,$07,$0C
db $08,$0C,$09,$0C,$0A,$0C,$0B,$0C,$0C,$0C,$0D,$0C,$0E,$0C,$0F,$0C
db $00,$0D,$01,$0D,$02,$0D,$03,$0D,$04,$0D,$05,$0D,$06,$0D,$07,$0D

db $30,$84,$00,$2F
db $10,$0C,$11,$0C,$12,$0C,$13,$0C,$14,$0C,$15,$0C,$16,$0C,$17,$0C
db $18,$0C,$19,$0C,$1A,$0C,$1B,$0C,$1C,$0C,$1D,$0C,$1E,$0C,$1F,$0C
db $10,$0D,$11,$0D,$12,$0D,$13,$0D,$14,$0D,$15,$0D,$16,$0D,$17,$0D

db $30,$A4,$00,$2F
db $20,$0C,$21,$0C,$22,$0C,$23,$0C,$24,$0C,$25,$0C,$26,$0C,$27,$0C
db $28,$0C,$29,$0C,$2A,$0C,$2B,$0C,$2C,$0C,$2D,$0C,$2E,$0C,$2F,$0C
db $20,$0D,$21,$0D,$22,$0D,$23,$0D,$24,$0D,$25,$0D,$26,$0D,$27,$0D

db $30,$C4,$00,$2F
db $30,$0C,$31,$0C,$32,$0C,$33,$0C,$34,$0C,$35,$0C,$36,$0C,$37,$0C
db $38,$0C,$39,$0C,$3A,$0C,$3B,$0C,$3C,$0C,$3D,$0C,$3E,$0C,$3F,$0C
db $30,$0D,$31,$0D,$32,$0D,$33,$0D,$34,$0D,$35,$0D,$36,$0D,$37,$0D

db $30,$E4,$00,$2F
db $40,$0C,$41,$0C,$42,$0C,$43,$0C,$44,$0C,$45,$0C,$46,$0C,$47,$0C
db $48,$0C,$49,$0C,$4A,$0C,$4B,$0C,$4C,$0C,$4D,$0C,$4E,$0C,$4F,$0C
db $40,$0D,$41,$0D,$42,$0D,$43,$0D,$44,$0D,$45,$0D,$46,$0D,$47,$0D

db $31,$04,$00,$2F
db $50,$0C,$51,$0C,$52,$0C,$53,$0C,$54,$0C,$55,$0C,$56,$0C,$57,$0C
db $58,$0C,$59,$0C,$5A,$0C,$5B,$0C,$5C,$0C,$5D,$0C,$5E,$0C,$5F,$0C
db $50,$0D,$51,$0D,$52,$0D,$53,$0D,$54,$0D,$55,$0D,$56,$0D,$57,$0D

db $31,$24,$00,$2F
db $60,$0C,$61,$0C,$62,$0C,$63,$0C,$64,$0C,$65,$0C,$66,$0C,$67,$0C
db $68,$0C,$69,$0C,$6A,$0C,$6B,$0C,$6C,$0C,$6D,$0C,$6E,$0C,$6F,$0C
db $60,$0D,$61,$0D,$62,$0D,$63,$0D,$64,$0D,$65,$0D,$66,$0D,$67,$0D

db $31,$44,$00,$2F
db $70,$0C,$71,$0C,$72,$0C,$73,$0C,$74,$0C,$75,$0C,$76,$0C,$77,$0C
db $78,$0C,$79,$0C,$7A,$0C,$7B,$0C,$7C,$0C,$7D,$0C,$7E,$0C,$7F,$0C
db $70,$0D,$71,$0D,$72,$0D,$73,$0D,$74,$0D,$75,$0D,$76,$0D,$77,$0D

db $31,$64,$00,$2F
db $80,$0C,$81,$0C,$82,$0C,$83,$0C,$84,$0C,$85,$0C,$86,$0C,$87,$0C
db $88,$0C,$89,$0C,$8A,$0C,$8B,$0C,$8C,$0C,$8D,$0C,$8E,$0C,$8F,$0C
db $08,$0D,$09,$0D,$0A,$0D,$0B,$0D,$0C,$0D,$0D,$0D,$0E,$0D,$0F,$0D

db $31,$84,$00,$2F
db $90,$0C,$91,$0C,$92,$0C,$93,$0C,$94,$0C,$95,$0C,$96,$0C,$97,$0C
db $98,$0C,$99,$0C,$9A,$0C,$9B,$0C,$9C,$0C,$9D,$0C,$9E,$0C,$9F,$0C
db $18,$0D,$19,$0D,$1A,$0D,$1B,$0D,$1C,$0D,$1D,$0D,$1E,$0D,$1F,$0D

db $31,$A4,$00,$2F
db $A0,$0C,$A1,$0C,$A2,$0C,$A3,$0C,$A4,$0C,$A5,$0C,$A6,$0C,$A7,$0C
db $A8,$0C,$A9,$0C,$AA,$0C,$AB,$0C,$AC,$0C,$AD,$0C,$AE,$0C,$AF,$0C
db $28,$0D,$29,$0D,$2A,$0D,$2B,$0D,$2C,$0D,$2D,$0D,$2E,$0D,$2F,$0D

db $31,$C4,$00,$2F
db $B0,$0C,$B1,$0C,$B2,$0C,$B3,$0C,$B4,$0C,$B5,$0C,$B6,$0C,$B7,$0C
db $B8,$0C,$B9,$0C,$BA,$0C,$BB,$0C,$BC,$0C,$BD,$0C,$BE,$0C,$BF,$0C
db $38,$0D,$39,$0D,$3A,$0D,$3B,$0D,$3C,$0D,$3D,$0D,$3E,$0D,$3F,$0D

db $31,$E4,$00,$2F
db $C0,$28,$C1,$28,$C2,$28,$C3,$28,$C4,$28,$C5,$28,$C6,$28,$C7,$28
db $C8,$28,$C9,$28,$CA,$28,$CB,$28,$CC,$28,$CD,$28,$CE,$28,$CF,$28
db $48,$29,$49,$29,$4A,$29,$4B,$29,$4C,$29,$4D,$29,$4E,$29,$4F,$29

db $32,$04,$00,$2F	;> Last row, 24 tiles, $2F = 48-1 bytes
db $D0,$28,$D1,$28,$D2,$28,$D3,$28,$D4,$28,$D5,$28,$D6,$28,$D7,$28
db $D8,$28,$D9,$28,$DA,$28,$DB,$28,$DC,$28,$DD,$28,$DE,$28,$DF,$28
db $58,$29,$59,$29,$5A,$29,$5B,$29,$5C,$29,$5D,$29,$5E,$29,$5F,$29

db $FF
