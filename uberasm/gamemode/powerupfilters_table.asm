;table of filters per translevel. the valid values are:
;	$00 = no filter
;	$01 = mushroom filter (small only)
;	$02 = feather filter
;	$03 = fire flower filter
;	$04 = fire flower and feather filter (big only)

FilterTable:
	db $00,$00,$00,$00,$00,$00,$00,$00		;levels 000-007
	db $00,$00,$00,$00,$00,$04,$00,$00		;levels 008-00F
	db $04,$00,$00,$04,$00,$04,$00,$00		;levels 010-017
	db $00,$00,$00,$00,$04,$00,$00,$00		;levels 018-01F
	db $00,$00,$00,$04,$00					;levels 020-024
	db     $00,$00,$00,$00,$00,$00,$00		;levels 101-107
	db $00,$00,$00,$00,$00,$00,$00,$00		;levels 108-10F
	db $04,$00,$04,$00,$00,$00,$00,$01		;levels 110-117
	db $00,$04,$04,$02,$00,$00,$00,$00		;levels 118-11F
	db $00,$00,$00,$00,$00,$00,$04,$02		;levels 120-127
	db $00,$00,$00,$00,$00,$00,$00,$00		;levels 128-12F
	db $00,$00,$00,$00,$00,$04,$04,$00		;levels 130-137
	db $00,$01,$01,$00						;levels 138-13B