; Optimized Spotlight Patch by Yoshifanatic
; This patch significantly improves the performance of sprite C6's code.
; The performance impact will roughly be 40% of what it originally was, making this sprite above average in terms of performance impact rather than being the most demanding SMW sprite.
; Also this patch frees up the RAM at $001472-$001486, which are unique to the spotlight, but could easily be substituted with direct page scratch RAM or normal sprite RAM tables.

!Define_UseOnOffBlock = 0								; Set this to 1 if you want the spotlight to be controlled by the on/off block rather than the light switch sprite.
!Define_HandleOverscan = 0								; Set this to 1 if you've increased the vertical resolution by enabling overscan. Note that the overscan lines won't show up correctly unless you also modify the routine at $009250 (which will affect other windowing effects).

if read1($00FFD5) == $23
	!SA1ROM = 1
	if read1($00FFD7) == $0D
		fullsa1rom
	else
		sa1rom
	endif
	!Base1 = $3000
	!Base2 = $6000
	!FastROM = $000000
	!RAM_SMW_NorSpr_Table7E00C2 = $0030D8
	!RAM_SMW_NorSpr_Table7E1504 = $0074F4
	!RAM_SMW_NorSpr_Table7E1510 = $00750A
	!RAM_SMW_NorSpr_Table7E151C = $003284
	!RAM_SMW_NorSpr_Table7E1528 = $00329A
	!RAM_SMW_NorSpr_Table7E1570 = $00331E
	!RAM_SMW_NorSpr_Table7E157C = $003334
else
	!SA1ROM = 0
	!Base1 = $0000
	!Base2 = $0000
	!FastROM = $800000
	!RAM_SMW_NorSpr_Table7E00C2 = $0000C2
	!RAM_SMW_NorSpr_Table7E1504 = $001504
	!RAM_SMW_NorSpr_Table7E1510 = $001510
	!RAM_SMW_NorSpr_Table7E151C = $00151C
	!RAM_SMW_NorSpr_Table7E1528 = $001528
	!RAM_SMW_NorSpr_Table7E1570 = $001570
	!RAM_SMW_NorSpr_Table7E157C = $00157C
endif

;---------------------------------------------------------------------------

; Remapped spotlight RAM addresses

!RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow = !RAM_SMW_Misc_ScratchRAM05
!RAM_SMW_NorSpr0C6_Spotlight_WidthOfRightSideOfWindow = !RAM_SMW_Misc_ScratchRAM06
!RAM_SMW_NorSpr0C6_Spotlight_BottomRightWindowPosRelativeToTop = !RAM_SMW_Misc_ScratchRAM07
!RAM_SMW_NorSpr0C6_Spotlight_BottomLeftWindowPosRelativeToTop = !RAM_SMW_Misc_ScratchRAM09
!RAM_SMW_NorSpr0C6_Spotlight_WidthOfLeftSideOfWindow = !RAM_SMW_Misc_ScratchRAM0B
!RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow = !RAM_SMW_Misc_ScratchRAM0C
!RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos = !RAM_SMW_Misc_ScratchRAM0D
!RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos = !RAM_SMW_Misc_ScratchRAM0E

!RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosTop = !RAM_SMW_NorSpr_Table7E1504
!RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosTop = !RAM_SMW_NorSpr_Table7E1510
!RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom = !RAM_SMW_NorSpr_Table7E151C
!RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom = !RAM_SMW_NorSpr_Table7E1528
!RAM_SMW_Flag_SkipSpotlightWindowInitialization = !RAM_SMW_NorSpr_Table7E1570
!RAM_SMW_NorSpr0C6_Spotlight_Direction = !RAM_SMW_NorSpr_Table7E157C

;---------------------------------------------------------------------------

; SMW RAM defines. Don't touch these unless you remapped them.

!RAM_SMW_Misc_ScratchRAM05 = $000005|!Base1
!RAM_SMW_Misc_ScratchRAM06 = $000006|!Base1
!RAM_SMW_Misc_ScratchRAM07 = $000007|!Base1
!RAM_SMW_Misc_ScratchRAM08 = $000008|!Base1
!RAM_SMW_Misc_ScratchRAM09 = $000009|!Base1
!RAM_SMW_Misc_ScratchRAM0A = $00000A|!Base1
!RAM_SMW_Misc_ScratchRAM0B = $00000B|!Base1
!RAM_SMW_Misc_ScratchRAM0C = $00000C|!Base1
!RAM_SMW_Misc_ScratchRAM0D = $00000D|!Base1
!RAM_SMW_Misc_ScratchRAM0E = $00000E|!Base1
!RAM_SMW_Misc_ScratchRAM0F = $00000F|!Base1
!RAM_SMW_Counter_GlobalFrames = $000013|!Base1
!RAM_SMW_Flag_SpritesLocked = $00009D|!Base1
!RAM_SMW_NorSpr0C6_Spotlight_OnFlag = !RAM_SMW_NorSpr_Table7E00C2
!RAM_SMW_Misc_HDMAWindowEffectTable = $0004A0|!Base2
!RAM_SMW_Palettes_BackgroundColorLo = $000701|!Base2
!RAM_SMW_Flag_OnOffSwitch = $0014AF|!Base2

;---------------------------------------------------------------------------

org $03C4F9|!FastROM
Return03C4F9:

org $03C514|!FastROM
	LDY.b !RAM_SMW_NorSpr0C6_Spotlight_OnFlag,x
	LDA.w $03C4D8,y
	STA.w !RAM_SMW_Palettes_BackgroundColorLo
	LDA.w $03C4DA,y
	STA.w !RAM_SMW_Palettes_BackgroundColorLo+$01
	LDA.b !RAM_SMW_Flag_SpritesLocked
	BNE.b Return03C4F9
	LDA.w !RAM_SMW_Flag_SkipSpotlightWindowInitialization,x
	BNE.b CODE_03C54D
	LDA.b #$90
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom,x
	LDA.b #$78
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosTop,x
	LDA.b #$87
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosTop,x
	INC.w !RAM_SMW_Flag_SkipSpotlightWindowInitialization,x
CODE_03C54D:
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_Direction,x
	AND.b #$01
	TAY
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom,x
	CLC
	ADC.w $03C48F,y
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom,x
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom,x
	CLC
	ADC.w $03C48F,y
	STA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom,x
	CMP.w $03C491,y
	BNE.b CODE_03C572
	INC.w !RAM_SMW_NorSpr0C6_Spotlight_Direction,x
CODE_03C572:
	LDY.b #$FF
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosTop,x
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
	SEC
	SBC.w !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowXPosBottom,x
	BCS.b CODE_03C58A
	LDY.b #$01
	EOR.b #$FF
	INC
CODE_03C58A:
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_WidthOfLeftSideOfWindow
	STY.b !RAM_SMW_NorSpr0C6_Spotlight_BottomLeftWindowPosRelativeToTop
	STZ.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	LDY.b #$FF
	LDA.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosTop,x
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
	SEC
	SBC.w !RAM_SMW_NorSpr0C6_Spotlight_RightWindowXPosBottom,x
	BCS.b CODE_03C5A5
	LDY.b #$01
	EOR.b #$FF
	INC
CODE_03C5A5:
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_WidthOfRightSideOfWindow
	STY.b !RAM_SMW_NorSpr0C6_Spotlight_BottomRightWindowPosRelativeToTop
	STZ.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	LDY.b #$01
	LDA.b !RAM_SMW_Counter_GlobalFrames
	LSR
if !Define_UseOnOffBlock == 1
	LDA.w !RAM_SMW_Flag_OnOffSwitch
	EOR.b #$01
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_OnFlag,x
else
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_OnFlag,x
endif
	REP.b #$30
	PHX
	BNE.b SpotlightOn
if !Define_HandleOverscan == 1
	LDX.w #$01DC
else
	LDX.w #$01BC
endif
	BCS.b +
	INX
	INX
+:
	TYA
-:
	STA.w !RAM_SMW_Misc_HDMAWindowEffectTable,x
	DEX
	DEX
	DEX
	DEX
	BPL.b -
	BRA.b Return

SpotlightOn:
	LDX.w #!RAM_SMW_Misc_HDMAWindowEffectTable
	BCS.b +
	INX
	INX
+:
-:
	STY.b (!RAM_SMW_Misc_HDMAWindowEffectTable&$000000)+$00,x
	STY.b (!RAM_SMW_Misc_HDMAWindowEffectTable&$000000)+$04,x
	STY.b (!RAM_SMW_Misc_HDMAWindowEffectTable&$000000)+$08,x
	STY.b (!RAM_SMW_Misc_HDMAWindowEffectTable&$000000)+$0C,x
	TXA
	CLC
	ADC.w #$0010
	TAX
	CPX.w #!RAM_SMW_Misc_HDMAWindowEffectTable+$005F
	BCC.b -
	SEP.b #$20
-:
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	;CLC
	ADC.b !RAM_SMW_NorSpr0C6_Spotlight_WidthOfLeftSideOfWindow
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	SBC.b #$64
	BCC.b ++
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	SBC.b #$64
	BCC.b +
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftLeftSideOfWindow
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
	CLC
	ADC.b !RAM_SMW_NorSpr0C6_Spotlight_BottomLeftWindowPosRelativeToTop
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
+:
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
	CLC
	ADC.b !RAM_SMW_NorSpr0C6_Spotlight_BottomLeftWindowPosRelativeToTop
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
++:
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	;CLC
	ADC.b !RAM_SMW_NorSpr0C6_Spotlight_WidthOfRightSideOfWindow
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	SBC.b #$64
	BCC.b ++
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	SBC.b #$64
	BCC.b +
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_ShiftRightSideOfWindow
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
	CLC
	ADC.b !RAM_SMW_NorSpr0C6_Spotlight_BottomRightWindowPosRelativeToTop
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
+:
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
	CLC
	ADC.b !RAM_SMW_NorSpr0C6_Spotlight_BottomRightWindowPosRelativeToTop
	STA.b !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
++:
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_LeftWindowScanlineXPos
	STA.b (!RAM_SMW_Misc_HDMAWindowEffectTable&$000000)+$00,x
	LDA.b !RAM_SMW_NorSpr0C6_Spotlight_RightWindowScanlineXPos
	STA.b (!RAM_SMW_Misc_HDMAWindowEffectTable&$000000)+$01,x
+:
	INX
	INX
	INX
	INX
if !Define_HandleOverscan == 1
	CPX.w #!RAM_SMW_Misc_HDMAWindowEffectTable+$01E0
else
	CPX.w #!RAM_SMW_Misc_HDMAWindowEffectTable+$01C0
endif
	BCC.b -
Return:
	PLX
	SEP.b #$30
	RTS

pad $03C626|!FastROM : padbyte $00
warnpc $03C626|!FastROM