	incsrc "../FlagMemoryDefines/Defines.asm"
;Execute like this:
;in level:
;	init:						;>Init so the counter displays as the level loads.
;	LDY #$00					;>$xx is what key counter to use, as an index from !Freeram_KeyCounter.
;	JSL MBCM16DisplayKeyCounter_DisplayHud
;	;[...]
;	RTL
;	main:
;	LDY #$00					;>$xx is what key counter to use, as an index from !Freeram_KeyCounter.
;	JSL MBCM16DisplayKeyCounter_DisplayHud
;	;[...]
;	RTL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Display key counter on the HUD
;
;Y index = Index from !Freeram_KeyCounter.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayHud:
	
	.ClearTiles
	LDX.b #(!StatusBarFormat*$03)
	
	..Loop
	LDA #!Settings_MBCM16_KeyCounterBlankTileNumb
	STA !Settings_MBCM16_KeyCounterTileNumbPos,x
	if !EditTileProps != 0
		LDA #!Settings_MBCM16_KeyCounterBlankTileProp
		STA !Settings_MBCM16_KeyCounterTilePropPos,x
	endif
	DEX #!StatusBarFormat
	BPL ..Loop
	
	TYX
	LDA !Freeram_KeyCounter,x
	BEQ .Done
	.WriteTilePrefix
	;Write <keysymbol>X<1 or 2 digits here>
	LDA #!Settings_MBCM16_KeyCounterKeySymbolTileNumb : STA !Settings_MBCM16_KeyCounterTileNumbPos
	if !EditTileProps != 0
		LDA #!Settings_MBCM16_KeyCounterKeySymbolTileProp : STA !Settings_MBCM16_KeyCounterTilePropPos
	endif
	LDA #!Settings_MBCM16_KeyCounterXSymbolTileNumb : STA !Settings_MBCM16_KeyCounterTileNumbPos+(!StatusBarFormat*$01)
	if !EditTileProps != 0
		LDA #!Settings_MBCM16_KeyCounterXSymbolTileProp : STA !Settings_MBCM16_KeyCounterTilePropPos+(!StatusBarFormat*$01)
	endif
	
	.WriteDigits
	if !EditTileProps != 0
		LDA.b #!Settings_MBCM16_KeyCounterDigitsTileProp
		STA !Settings_MBCM16_KeyCounterTilePropPos+(!StatusBarFormat*$02)
		STA !Settings_MBCM16_KeyCounterTilePropPos+(!StatusBarFormat*$03)
	endif
	
	LDA !Freeram_KeyCounter,x
	CMP.b #10
	BCS ..TwoDigits
	
	..OneDigit
	STA !Settings_MBCM16_KeyCounterTileNumbPos+(!StatusBarFormat*$02)
	RTL
	
	..TwoDigits
	JSL $00974C								;>HexDec.
	STA !Settings_MBCM16_KeyCounterTileNumbPos+(!StatusBarFormat*$03)	;>Ones
	TXA									;\Tens
	STA !Settings_MBCM16_KeyCounterTileNumbPos+(!StatusBarFormat*$02)	;/
	.Done
	RTL
	