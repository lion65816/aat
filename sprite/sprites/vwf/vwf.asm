;##################################################################################################
;# Variable Width Font Cutscene v2.0
;# by Romi, updated by lx5
;#
;# Proper documentation later.

incsrc "vwf_defines.asm"

print "INIT ",pc
VWFInitCode_wrapper:
if !sa1
    LDA.B #VWFInitCode
    STA $0183
    LDA.B #VWFInitCode/256
    STA $0184
    LDA.B #VWFInitCode/65536
    STA $0185
    LDA #$D0
    STA $2209
.Wait
    LDA $018A
    BEQ .Wait
    STZ $018A
    RTL
endif

VWFInitCode:
    LDA !7FAB10,x			; Extra byte not supported!
    AND #$04
-	
    BNE -

    LDA #$FF				; Erase Mario
    STA $78

    LDA #$80				; Force blank
    STA $2100
    STZ $0D9D|!addr			; Disable main and subscreen
    STZ $0D9E|!addr

    PHX
    LDX #$04				; Setup HDMAs
-
    LDA.l HDMATable1,x		; CH3 = Brightness
    STA $4330,x
    LDA.l HDMATable2,x		; CH4 = Layer 3 X Pos
    STA $4340,x
    LDA.l HDMATable3,x		; CH5 = Layer 3 GFX & Tilemap address
    STA $4350,x
    DEX
    BPL -

    LDX #$4F
    LDA #$80
-
    STA.l !VWF_HDMA,x
    DEX
    BPL -
    LDA.b #!VWF_HDMA/$10000
    STA $4337
    STA $4347
    PLX

    LDA #$88
    STA $420C				; Enable HDMA channels 3 and 7
    STA $0D9F|!addr
    LDA $0DAE|!addr
    STA $2100
    RTL

HDMATable1:
    db $40,$00 : dl .src
.src
    db $5F : dw !VWF_HDMA
    db $8C : dw !VWF_HDMA+$10
    db $90 : dw !VWF_HDMA+$20
    db $54 : dw !VWF_HDMA+$30
    db $90 : dw !VWF_HDMA+$40
    db $00

HDMATable2:
    db $43,$11 : dl .src
.src
    db $5F : dw !VWF_SCROLL+$00
    db $0C : dw !VWF_SCROLL+$10
    db $01 : dw !VWF_SCROLL+$20
    db $00

HDMATable3:
    db $00,$09 : dl .src
.src
    db $5F : db $59
    db $0C : db $5C
    db $01 : db $59
    db $00

print "MAIN ",pc
    LDA #$38
    STA $0D9F|!addr				; Enable HDMA channels 3, 4 & 5
    LDA $0100|!addr
    CMP #$14
    BEQ VWFMainCode_wrapper
    RTL

VWFMainCode_wrapper:
if !sa1
    LDA.B #VWFMainCode
    STA $0183
    LDA.B #VWFMainCode/256
    STA $0184
    LDA.B #VWFMainCode/65536
    STA $0185
    LDA #$D0
    STA $2209
.Wait
    LDA $018A
    BEQ .Wait
    STZ $018A
    RTL
endif

VWFMainCode:
    PHX
    PHB
    SEI
    STZ $4200					; Disable NMI
    STZ $420C					; Disable HDMA

    STZ $1BE4|!addr				; Disable updating BG1
    STZ $1CE6|!addr				; Disable updating BG1

    PHD
    LDA #$21					; Change DP for speeed reasons
    XBA
    LDA #$00
    TCD

    LDA #$80
    STA $00						; Enable force blank
    STA $15						; VRAM control

    LDA #$02
    STA $0C						; Layer 3 GFX addr

    REP #$30
    LDA #$0014					; Mainscreen = Layer 3 & Sprites
    STA $2C						; Subscreen = Nothing

    LDA #$2000					; VRAM address
    STA $16
-	
    STZ $18						; Clear 0x2000 bytes of VRAM at $2000
    DEC A
    BNE -

    LDA #$5800					; Initialize VRAM at $5800 ($0400 bytes)
    STA $16

    LDX #$0400
    LDA #$0000
-	
    STA $18
    INC A
    AND #$01FF
    DEX
    BNE -

    LDX #$0040					; Initialize VRAM at $5C00 ($0040 bytes)
    LDA #$0600
-	
    STA $18
    INC A
    DEX
    BNE -

    PLD
    SEP #$30

    PEA.w ((!VWF_VARS>>8)&$FF00)|(!VWF_VARS>>16)
    PLB
    PLB


    LDX #$4F					; Clear $50 bytes of RAM
-	
    STZ.w !VWF_HDMA,x
    DEX
    BPL -

    LDX #$0F					; Initialize brightness HDMA table
    TXA
    LDY #$00
    STA.w !VWF_HDMA+$30
-	
    STA.w !VWF_HDMA+$20,x
    STA.w !VWF_HDMA+$40,y
    INY
    DEX
    DEC A
    BPL -

    JSL $7F8000					; Clear all OAM position

    LDA.w !VWF_DATA+$02			; Setup indirect addressing for the VWF data
    STA $D7
    REP #$30
    LDA.w !VWF_DATA+$00
    STA $D5

    LDX #$03FE
-
    STZ.w !VWF_GFX,x
    DEX #2
    BPL -

                                ; Initialize VWF related RAM
    STZ.w !CurrentLine			; Current line
    STZ.w !FontColor			; Font color
    STZ.w !TermChars			; Num of characters until end of line

    LDA #$0008					; Padding
    STA.w !LeftPad				; Left padding
    STA.w !NewLeftPad			; New line? padding
    STA.w !RightPad				; Right padding
    ;STA.w !NewRightPad		;/

    STA.w !Xposition			; Current/Initial X position
    STZ.w !LineDrawn			; Num of line
    STZ.w !Timer				; Timer
    STZ.w !LineBroken			; Line break flag
    STZ.w !Inner				; ?
    STZ.w !ForcedScroll			; ?
    STZ.w !SelectMsg			; for branch

    LDA #$FFFF
    STA.w !SkipPos
    STZ.w !Skipped

    LDA #$0004
    STA.w !SpaceWidth

    STZ.w !ASMPointer
    STZ.w !SavedPointer
    STZ.w !OffsetPointer
    STZ.w !NewPointer

    LDA.w #$0100
    STA.w !VWF_SCROLL+$00
    STA.w !VWF_SCROLL+$10
    LDA.w #$0080
    STA.w !VWF_SCROLL+$02
    LDA.w #$FFFF-$5F
    STA.w !VWF_SCROLL+$12
    STZ.w !VWF_SCROLL+$20
    LDA #$FF80
    STA.w !VWF_SCROLL+$22

    STZ $13E0    

    LDX #$001E
-
    STZ $0400,x					; Clear OAM high bits
    DEX #2
    BPL -
    SEP #$20


    LDA #$81
    STA $004200					; Enable NMI and wait for V-Blank once
-	

    LDA $10
    BEQ -
    STZ $10
    
    JSR RunGlobal	    		; Run global code

    LDA #$81
    STA $004200
    LDA $0D9F
    STA $00420C

    LDY #$0000
.Loop
    LDA.w !Skipped				; Check if the player has skipped text
    BEQ .normal_vwf
    LDA #$00
    REP #$20
    BRA .ForcedEnd

.normal_vwf
    LDA.w !ForcedScroll			; Check if text should scroll down
    BEQ +
    INC.w !VWF_SCROLL+$22		; Move text's position down 1px every frame
    LDA.w !VWF_SCROLL+$22			; also check if text has scrolled for 16 px
    AND #$0F
    BNE +
    STZ.w !ForcedScroll			; Stop if it has scrolled 16px down
+
    LDA.w !TermChars			; Check if a word has ended.
    BNE .NoNewTerm

    LDA [$D5],y					; Load next VWF data byte
    REP #$20
    BPL .IsChar					; If < $80, it's a character

.ForcedEnd						; If => $80, it's a command
    PEA.w .ReturnedCommand-1	; Push return address
    AND #$007F
    ASL 						; Grab command ID
    TAX
    LDA.l CommandAddress,x		; Push command address to jump to
    PHA
    RTS							; Jump to command
.ReturnedCommand
    SEP #$20					; Finalize command parsing
    BRA .Finalize

.IsChar	
    STZ.w !TermWidth			; Word width
    DEC.w !TermWidth			; Make it $FFFF

    PHY							; Calculate line's total width
.calculate_line
    AND #$00FF					; Grab VWF data and get font width
    TAX
    LDA.l FontWidth,x
    AND #$00FF
    SEC
    ADC.w !TermWidth
    STA.w !TermWidth			; Calculate word's current width
    INC.w !TermChars			; Increase word's characters
    INY
    LDA [$D5],y					; Grab next VWF data byte
    BIT #$0080
    BEQ .calculate_line
    PLY

    LDA #$0100					; Calculate line's valid width by substracting paddings
    SEC
    SBC.w !LeftPad
    SBC.w !RightPad				; Invalid width (doesn't fit into $0100 px) hangs the game
    STA.w !ValidWidth
-	
    BMI -
    LDA.w !TermWidth			; Same here; if line end is over the valid width, hang the game.
    CMP.w !ValidWidth
-	
    BCS -

    CLC
    ADC.w !Xposition
    SEC
    SBC.w !LeftPad
    CMP.w !ValidWidth
    SEP #$20
    BCC .Finalize

    REP #$20
    INC.w !Inner
    JSR BreakLine				; if there isn't much space to render a term, break a line
    STZ.w !Inner
    BCS +
    STZ.w !TermChars			; Reset word's characters
+
    SEP #$20
    BRA .Finalize

.NoNewTerm	
    LDA.b #!VWF_GFX
    STA $04						; Just draw a character without calculating the current line
    LDA.b #!VWF_GFX>>8
    STA $05
    LDA [$D5],y					; Grab next VWF data byte
    JSR DrawChar

.Finalize
    LDA.w !SkipPos+1			; Determine if the current text can be skipped with START
    BMI .WaitVblank
    XBA
    LDA $16
    AND #$10					; Check if START has been pressed
    BEQ .WaitVblank
    LDA.w !SkipPos				; Get skip position and use it as the new VWF data index
    TAY
    INC.w !Skipped				; Activate "text skipped" flag


.WaitVblank
    LDA $10						; Wait for V-Blank
    BEQ .WaitVblank
    STZ $10

    INC $13						; Increase frame counter

    LDA #$00
    STA $00420C					; Disable HDMA
    LDA #$80
    STA $002100					; Force blank and turn screen to black
    STA $002115					; Enable VRAM increment

if !sa1 == 1
    LDX #$120B					; Optimization for DMA upload
else
    LDX #$420B					; Optimization for DMA upload
endif
    REP #$20
    LDA.w !CurrentLine
    LSR.w !LineBroken
    BCC +
    SBC #$0E00
+
    AND #$0E00					; Calculate VRAM address
    ORA #$2000
    STA $002116

    LDA #$1801					; DMA setting = $01
    STA $F5,x					; DMA destination = VRAM Write
    LDA.w #!VWF_GFX
    STA $F7,x
    LDA.w #!VWF_GFX>>8
    STA $F8,x
    LDA #$0400					; Transfer 0x400 bytes (whole tilemap)
    STA $FA,x
    SEP #$20
    LDA #$01					; Enable DMA transfer
    STA $00,x
    LDA $0D9F					; Enable HDMA
    STA $01,x
    
    JSR RunGlobal				; Call global code

    JMP .Loop					; Gameloop

CommandAddress:
    dw FinishVWF-1				; 80
    dw PutSpace-1				; 81
    dw BreakLine-1				; 82
    dw WaitButton-1				; 83
    dw WaitTime-1				; 84
    dw FontColor1-1				; 85
    dw FontColor2-1				; 86
    dw FontColor3-1				; 87
    dw PadLeft-1				; 88
    dw PadRight-1				; 89
    dw PadBoth-1				; 8A
    dw ChangeMusic-1			; 8B
    dw EraseSentence-1			; 8C
    dw ChangeTopic-1			; 8D
    dw ShowOAM-1				; 8E
    dw HideOAM-1				; 8F
    dw BranchLabel-1			; 90
    dw JumpLabel-1				; 91
    dw SkipLabel-1				; 92
    dw ChangeMusicNoSamples-1	; 93
    dw ChangeSpaceChar-1		; 94
    dw ChangeSwitchOn-1			; 95
    dw ChangeSwitchOff-1		; 96
    dw ToggleOnOffSwitch-1		; 97
    dw Compare-1				; 98
    dw PlaySFX1DF9-1			; 99
    dw PlaySFX1DFC-1			; 9A
    dw ExAniManual-1			; 9B
    dw ExAniCustom-1			; 9C
    dw ExAniOneShot-1			; 9D
    dw TurnOnSFXEcho-1			; 9E
    dw TurnOffSFXEcho-1			; 9F
    dw ExecuteASM-1				; A0
    dw ExecuteASMEveryFrame-1	; A1
    dw StopASMEveryFrame-1		; A2

;##################################################################################################
;# Handles code after VWF code

RunGlobal:
    PHY
    PHX
    PHP

    REP #$20
    LDA.w !ASMPointer
    BEQ .no_custom_asm

	PHY
    PHB
    PHD
    PHP

    LDA.w !VWF_ASM_PTRS+2
    STA $02
    LDA.w !ASMPointer
    STA $00
    LDA [$00]
    STA $00

    SEP #$20
    PHK
    PER $0002
    JML [$0000|!dp]

    PLP
    PLD
    PLB
	PLY

.no_custom_asm

    LDA.w #$8076				; read3($008076)
    STA $00
    LDA.w #$0080
    STA $01

    LDA [$00]					; read3(read3($008076)+$03)
    CLC
    ADC #$000A
    STA $03
    INC $00
    INC $00
    LDA [$00]
    STA $05

    PHK
    PER $0002
    JML [$0003|!dp]

    SEP #$30

    INC $14

    JSL read3($00A2A6)			; Run (Ex)Animations


    LDA #$FF				; Erase Mario
    STA $78
    JSL $00E2BD                 ; Run Mario's pose handler

    PLP 
    PLX 
    PLY 
    RTS

;##################################################################################################
;# Handles commands

incsrc "vwf_commands.asm"

;##################################################################################################
;# Draw character on screen
;# 
;# Input:
;# 		A: Character number. Can't be over $80
;#		$04: 16-bit address of the tilemap in RAM

DrawChar:
    PHY
    STA $00					; Preserve character number

    PHK
    PLA
    STA $0C					; Get current bank
    STA $0F

    REP #$20
    LDA $00					; Calculate character width from LUT
    AND #$00FF
    TAX
    LDA.l FontWidth,x
    AND #$00FF
    STA $08					; $08 = Current character width

    TXA
    ASL #2					; Calculate index for character's GFX
    STA $00					; Index = char_loc + char_num * 6
    ASL
    ADC $00
    ADC.w #Letters			; Add characters ROM location
    STA $0A					; $0A = Address for the left part of the current character GFX

    ADC #$0400
    STA $0D					; $0D = Address for the right part of the current character GFX

                            ; There are some characters that don't fit in a 8px width space
                            ; W doesn't fit, so it's broke down into two different tiles

    LDY #$0000
.YLoop
    STZ $00					
    LDA [$0A],y
    STA $01					; $00 = Left tile's px
    LDA [$0D],y				
    AND #$00FF
    ORA $00					; A = LLLLLLLL RRRRRRRR

    LDX #$0000
.XLoop
    ASL						; Check if the current pixel isn't blank
    BCC .NoPixel			; also shift its position

    PHA						; Preserve GFX tiles
    PHX						; and loop

    TXA
    CLC						; Calculate pixel's X position in the screen
    ADC.w !Xposition
    PHA

    AND #$FFF8
    ASL
    CPY #$0008
    BCC +
    ORA #$0200
+	
    STA $00

    TYA
    AND #$0007
    ASL
    ADC $04					; Add GFX data
    ADC $00
    STA $00					; $00 = GFX address to draw to
    PLA

    AND #$0007
    ASL
    ORA.w !FontColor		; Grab font color and apply it
    TAX
    LDA ($00)
    ORA.l BitTable,x		; Merge GFX data together
    STA ($00)

    PLX
    PLA

.NoPixel
    INX
    CPX $08					; Check if all of the pixels in the current character have been merged into the tilemap
    BNE .XLoop

    INY
    CPY #$000C				; Check if every pixel has been drawn. (Chracters can't be over 12 px tall)
    BCC .YLoop

    LDA.w !Xposition
    ADC $08					; Add the character's width + 1 to the X position
    STA.w !Xposition		; Basically preparing the new character to be drawn

    DEC.w !TermChars		; Decrease amount of characters to be drawn in the current line

-	
    CMP #$0100				; Failsafe. Hangs the game if somehow the text goes out of bounds.
    BCS -

    SEP #$20
    PLY
    INY						; Increase VWF data index

    RTS


BitTable:
    dw $0080,$0040,$0020,$0010,$0008,$0004,$0002,$0001
    dw $8000,$4000,$2000,$1000,$0800,$0400,$0200,$0100
    dw $8080,$4040,$2020,$1010,$0808,$0404,$0202,$0101

Letters:
    incbin "vwf.bin"
FontWidth:
    incbin "width.bin"