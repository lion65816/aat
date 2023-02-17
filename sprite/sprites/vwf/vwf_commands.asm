includefrom "vwf.asm"

;##################################################################################################
;# Every command available for the VWF system

;################################################
;# Command $80
;# Finish VWF dialogue

FinishVWF:
	SEP #$20

.clear_data
	LDX #$004F
..loop
	LDA.w !VWF_HDMA,x				; Fade to black everything
	BEQ ..skip
	DEC.w !VWF_HDMA,x
..skip
	DEX
	BPL ..loop

	LDA.w !VWF_HDMA+$30
	REP #$20
	BNE PutSpace_return
	INY
	LDA [$D5],y						; Load VWF ending sequence
	PLX
	SEP #$30
	PLB								; Return DB to normal
	PLX
	STA $F0
	CMP #$20
	BCS .no_teleport

.teleport
	TAY								; < $20: Teleport using screen exits
	LDA $19B8|!addr,y
	STA $19B8|!addr
	LDA $19D8|!addr,y
	STA $19D8|!addr
	LDA #$05
	STA $71
	RTL

.no_teleport
	CMP #$20
	BNE .end_level
	JML $05B160						; != $20: Side exit

.end_level							; == $20: End level
	SBC #$20
	STA $13CE|!addr
	STA $0DD5|!addr
	INC $1DE9|!addr
	LDA #$0B
	STA $0100|!addr
	RTL

;################################################
;# Command $81
;# Put a 4px width space

PutSpace:	
	LDA.w !Xposition
	CLC
	ADC.w !SpaceWidth
	STA.w !Xposition
	INY
.return
	RTS

;################################################
;# Command $82
;# (Forced) Line break

BreakLine:
	LDA.w !ForcedScroll			; If text is already scrolling, ignore the line break
	BEQ .no_scrolling
	CLC
	RTS

.no_scrolling
	LDA.w !LineDrawn			; Check lines drawn on screen, if > 4, scroll text
	CMP #$0004
	BCC +
	INC.w !ForcedScroll			; Activate scroll flag if needed
	BRA ++
+	
	INC.w !LineDrawn			; Increase lines drawn
++	
	LDA.w !CurrentLine
	CLC
	ADC #$0200
	STA.w !CurrentLine
	LDA.w !NewLeftPad
	STA.w !LeftPad
	STA.w !Xposition

.clear_tilemap
	LDX #$03FE
..loop
	STZ.w !VWF_GFX,x
	DEX #2
	BPL ..loop

	INC.w !LineBroken			; Activate line break flag
	LDA.w !Inner
	BNE .return
	INY
	SEC
.return
	RTS

;################################################
;# Command $83
;# Wait for button to continue text

WaitButton:	
	LDA.b $15-1					; Check if a button has been pressed or is being pressed
	BPL .return
	LDA.b $17-1
	BPL .INY
	LDA.b $18-1
	BPL .return

.INY
	INY							; Load next VWF byte in the next frame

.Erase
	LDA #$00F0					; Reset first OAM slot position (arrow GFX)
	STA $0201
	RTS

.return
	LDA $13						; Make the arrow blink
	AND #$0010
	BNE .Erase
	LDA.w !ForcedScroll
	BNE .Erase

	LDA.w !Xposition
	STA $0200
	LDA.w !LineDrawn
	ASL #4
	ADC #$0086
	STA $0201
	LDA.w #!RightArrowGFX
	STA $0202
	RTS

;################################################
;# Command $84
;# Waits a few frames before continuing with the text

WaitTime:
	INY
	LDA [$D5],y					; Load wait duration from VWF data
	AND #$00FF
	CMP.w !Timer				; Check if time is over
	BEQ .INY
	INC.w !Timer				; Increase timer
	DEY							; And reset VWF data index to keep getting into the same routine
	RTS

.INY
	STZ.w !Timer				; Done waiting, reset timer and increase VWF data index
	INY
	RTS

;################################################
;# Command $85
;# Change font color #1

FontColor1:
	STZ.w !FontColor				; Forces font color to the first option
	INY
	RTS

;################################################
;# Command $86
;# Change font color #2

FontColor2:						; Forces font color to the second option
	LDA #$0010
	STA.w !FontColor
	INY
	RTS

;################################################
;# Command $87
;# Change font color #3

FontColor3:
	LDA #$0020					; Forces font color to the third option
	STA.w !FontColor
	INY
	RTS

;################################################
;# Command $88
;# Change left padding

PadLeft:
	INY
	LDA [$D5],y					; Grab new left padding width
	AND #$00FF
	STA.w !NewLeftPad
	INY
	RTS

;################################################
;# Command $89
;# Change right padding

PadRight:
	INY
	LDA [$D5],y					; Grab new right padding width
	AND #$00FF
	STA.w !RightPad
	INY
	RTS

;################################################
;# Command $8A
;# Change both paddings

PadBoth:
	INY
	LDA [$D5],y					; Grab new left padding width
	AND #$00FF
	STA.w !NewLeftPad
	BRA PadRight				; and the right one.

;################################################
;# Command $8B
;# Change music

ChangeMusic:
	INY
	SEP #$20
	LDA [$D5],y
	STA $1DFB
	REP #$20
	INY
	RTS

;################################################
;# Command $8C
;# EraseSentence

EraseSentence:
	LDA !ForcedScroll
	BEQ .clear_gfx_buffer
	RTS 

.clear_gfx_buffer
	LDX #$03FE
..loop
	STZ.w !VWF_GFX,x
	DEX #2
	BPL ..loop
	SEP #$20

.loop

.wait_vblank
	LDA $10						; Wait for V-Blank
	BEQ .wait_vblank
	STZ $10

	LDA #$00
	STA $00420C					; Disable HDMA
	LDA #$80
	STA $002100					; Enable F-Blank
	STA $002115					; VRAM Increment

if !sa1 == 1
	LDX #$120B						; Optimization for DMA upload
else
	LDX #$420B						; Optimization for DMA upload
endif
	REP #$21
	LDA.w !CurrentLine
	ADC #$0200
	STA.w !CurrentLine
	AND #$0E00
	ORA #$2000
	STA $002116					; Calculate VRAM Addr

	LDA #$1801					; Write to VRAM
	STA $F5,x
	LDA.w #!VWF_GFX
	STA $F7,x
	LDA.w #!VWF_GFX>>8
	STA $F8,x
	LDA #$0400
	STA $FA,x
	SEP #$20

	LDA #$01
	STA $00,x					; Enable DMA
	LDA $0D9F
	STA $01,x					; Enable HDMA

	JSR RunGlobal	    		; Run global code

	INC.w !Timer
	LDA.w !Timer
	CMP #$08
	BNE .loop
	INY
	
	REP #$20
	STZ.w !CurrentLine
	LDA.w !NewLeftPad
	STA.w !LeftPad
	STA.w !Xposition
	STZ.w !LineDrawn
	STZ.w !Timer
	LDA #$FF80
	STA.w !VWF_SCROLL+$22
.return

	RTS

;################################################
;# Not a command
;# Fades out topic

TopicFadeOut:
	LDA.w !ForcedScroll
	BNE .return

	PHY
	PHP
	SEP #$30
.loop
	LDA.w !VWF_HDMA+$15				; If topic is black, return
	BEQ .faded_out


	LDX.w !Timer
	LDA #$0B
	SEC
	SBC.w !Timer
	TAY
..dec_loop
	LDA.w !VWF_HDMA+$10,x			; Fade out the topic by updating the HDMA table
	BEQ ..min_brightness
	DEC.w !VWF_HDMA+$10,x
	PHX
	TYX
	DEC.w !VWF_HDMA+$10,x
	PLX
..min_brightness

	INY
	DEX
	BPL ..dec_loop

	LDA.w !Timer
	CMP #$05
	BCS ..skip
	INC.w !Timer
..skip


.wait_vblank
	LDA $10							; Wait for next V-Blank
	BEQ .wait_vblank
	STZ $10
	
	JSR RunGlobal	    		; Run global code

	BRA .loop

.faded_out
	PLP
	STZ.w !Timer
	PLY

.return
	RTS

;################################################
;# Not a command
;# Fades in topic

TopicFadeIn:
	LDA !ForcedScroll
	BNE .return

	PHY
	PHP
	SEP #$30
	LDA #$04
	STA.w !Timer

.loop	
	LDA.w !VWF_HDMA+$10
	CMP #$0F
	BEQ .faded_in

	LDX #$05
	LDY #$06
..inc_loop
	LDA.w !VWF_HDMA+$10,x
	CMP #$0F
	BEQ ..max_brightness
	INC.w !VWF_HDMA+$10,x
	PHX
	TYX
	INC.w !VWF_HDMA+$10,x
	PLX
..max_brightness	

	INY
	DEX
	CPX.w !Timer
	BNE ..inc_loop
	LDA.w !Timer
	BMI ..skip
	DEC.w !Timer
..skip


.wait_vblank
	LDA $10
	BEQ .wait_vblank
	STZ $10
	
	JSR RunGlobal	    		; Run global code

	BRA .loop
	
.faded_in
	PLP
	STZ.w !Timer
	PLY

.return
	RTS

;################################################
;# Command $8D
;# Changes the current topic

ChangeTopic:
	JSR TopicFadeOut

	SEP #$A0
	LDA #$00
	STA $004200
	REP #$20

	LDA.w !Xposition
	PHA
	STZ.w !Xposition

	LDA.w #!VWF_TOPIC_GFX
	STA $04
	LDX #$03FE
-	
	STZ.w !VWF_TOPIC_GFX,x
	DEX #2
	BPL -
	SEP #$20
	INY
.Loop
	LDA [$D5],y
	BPL .IsChar
	CMP #$8D
	BEQ .END
	REP #$20
	PEA.w .ReturnedCommand-1
	AND #$007F
	ASL A
	TAX
	LDA.l CommandAddress,x
	PHA
	RTS
.ReturnedCommand
	SEP #$20
	BRA .Loop
.IsChar
	JSR DrawChar
	BRA .Loop

.END
	LDA #$81
	STA $004200
-

	LDA $10
	BEQ -
	STZ $10

	LDA #$00
	STA $00420C
	LDA #$80
	STA $002100
	STA $002115

if !sa1 == 1
	LDX #$120B						; Optimization for DMA upload
else
	LDX #$420B						; Optimization for DMA upload
endif
	REP #$20
	LDA #$3000
	STA $002116
	LDA #$1801
	STA $F5,x
	LDA.w #!VWF_TOPIC_GFX
	STA $F7,x
	LDA.w #!VWF_TOPIC_GFX>>8
	STA $F8,x
	LDA #$0400
	STA $FA,x
	SEP #$20
	LDA #$01
	STA $00,x
	LDA $0D9F
	STA $01,x

	REP #$20
	LDA.w !Xposition
	LSR
	CLC
	ADC #$FF80
	STA $CA10
	PLA
	STA.w !Xposition
	STZ.w !TermChars
	INY
	JSR TopicFadeIn
	
	JSR RunGlobal	    		; Run global code
	
	RTS

;################################################
;# Not a command
;# Fades out OAM tiles

TopFadeOut:
	LDA !ForcedScroll
	BNE .return

	PHY
	PHP
	SEP #$30
.loop
	LDA.w !VWF_HDMA
	BEQ .faded_out
	DEC.w !VWF_HDMA


.wait_vblank
	LDA $10
	BEQ .wait_vblank
	STZ $10
	
	JSR RunGlobal	    		; Run global code

	BRA .loop

.faded_out
	PLP
	PLY

.return
	RTS

;################################################
;# Not a command
;# Fades in the OAM tiles

TopFadeIn:
	LDA.w !ForcedScroll
	BNE .return

	PHY
	PHP
	SEP #$30
.loop
	LDA.w !VWF_HDMA
	CMP #$0F
	BEQ .max_brightness

	INC.w !VWF_HDMA


.wait_vblank
	LDA $10
	BEQ .wait_vblank
	STZ $10

	JSR RunGlobal	    		; Run global code

	BRA .loop

.max_brightness
	PLP
	PLY

.return
	RTS

;################################################
;# Command $8E
;# Draws OAM tiles on screen

ShowOAM:
	JSR HideOAM
	LDA #$0001					; High OAM index
	STA $0E

	LDX #$0004					; Starting OAM index

	LDA [$D5],y					; Fetch amount of tiles to be drawn on screen
	AND #$00FF
	STA $0C
	INY

; Format:
; XX YY TT yxs?ccct

.draw_loop
	LDA [$D5],y					; Get X/Y positions
	STA $0200,x
	INY #2
	LDA [$D5],y					; Grab tile and properties data
	STA $0202,x

	LDA [$D5],y					; Get extra info for later usage
	AND #$2000
	ASL #2
	STA $08

	INX #4						; Increase indexes for the next tile
	INY #2

	PHX							; Calculate a proper high OAM index for $0400
	LDA $0E						; No need for $0420
	LSR #2
	ORA #$0400					; $0400 | (index >> 2)
	STA $00
	LDA $0E
	AND #$0003					
	ASL 
	TAX
	LDA ($00)
	AND.l .Mask,x
	ASL $08
	BCC +
	ORA.l .OR,x
+
	STA ($00)
	PLX

	INC $0E
	DEC $0C
	BNE .draw_loop

	JSR TopFadeIn
	RTS

.Mask
	dw $FFFC,$FFF3,$FFCF,$FF3F
.OR	
	dw $0002,$0008,$0020,$0080

;################################################
;# Command $8F
;# Hides every sprite tile

HideOAM:
	JSR TopFadeOut
	SEP #$20
	LDA #$F0
	JSL $7F8005
	REP #$20
	INY
.return
	RTS

;################################################
;# Command $90
;# Option menu

BranchLabel:
	LDA !ForcedScroll
	BNE HideOAM_return

	LDA [$D5],y				; Fetch amount of options
	STA $06
	XBA
	AND #$007F
	STA $02
	ASL #4
	STA $04

	LDA.w !LeftPad
	SEC
	SBC #$000A
	BCS +
	LDA #$0000
+	
	STA $0200
	LDA.w !SelectMsg
	ASL #4
	STA $00
	LDA.w !LineDrawn
	ASL #4
	ADC #$008F
	ADC $00
	SEC
	SBC $04
	STA $0201
	LDA.w #!DownArrowGFX
	STA $0202

	LDA $16
	AND #$000C
	BEQ ++
	CMP #$000C
	BEQ ++
	BIT #$0004
	BEQ +
	INC.w !SelectMsg
	LDA.w !SelectMsg
	CMP $02
	BCC ++
	STZ.w !SelectMsg
	BRA ++
+
	DEC.w !SelectMsg
	BPL ++
	LDA $02
	DEC A
	STA.w !SelectMsg
++
	LDA.b $16-1
	ORA.b $18-1
	BPL .return
	LDA #$00F0
	STA $0201
	INY
	INY
	TYA
	ASL.w !SelectMsg
	ADC.w !SelectMsg
	TAY
	LDA [$D5],y
	TAY
	STZ.w !SelectMsg
	LDA $06
	BMI .return
	INC.w !Inner
	JSR BreakLine
	STZ.w !Inner

.return
	RTS

;################################################
;# Command $91
;# Jump label

JumpLabel:
	INY
	LDA [$D5],y
	TAY
	RTS

;################################################
;# Command $92
;# Skip label

SkipLabel:
	INY
	LDA [$D5],y
	STA.w !SkipPos
	INY #2
	RTS

;################################################
;# Command $93
;# Changes the current music without reloading samples

ChangeMusicNoSamples: 
	INY
	SEP #$20
	LDA [$D5],y
	STA $1DFB
	LDA #$01
	STA.l !AddMusicK_RAM+1
	REP #$20
	INY
	RTS

;################################################
;# Command $94
;# Changes the default space used in the space command

ChangeSpaceChar:
	INY
	LDA [$D5],y
	AND #$00FF
	STA.w !SpaceWidth
	INY
	RTS 

;################################################
;# Command $95
;# Forces the ON/OFF switch status to ON

ChangeSwitchOn:
	SEP #$20
	STZ $14AF
	REP #$20
	INY 
	RTS

;################################################
;# Command $96
;# Forces the ON/OFF switch status to OFF

ChangeSwitchOff:
	SEP #$20
	LDA #$01
	STA $14AF
	REP #$20
	INY 
	RTS

;################################################
;# Command $97
;# Toggles the ON/OFF switch status

ToggleOnOffSwitch:
	SEP #$20
	LDA $14AF
	EOR #$01
	STA $14AF
	REP #$20
	INY 
	RTS

;################################################
;# Command $98
;# Compares a RAM value with a constant

Compare:
	SEP #$20
	INY
	LDA [$D5],y
	STA $00
	INY
	LDA [$D5],y
	STA $01
	INY
	LDA [$D5],y
	STA $02					; $00-$02: RAM/ROM to read from

	INY
	LDA [$D5],y
	STA $03					; $03: Value to compare to

	INY
	LDA [$D5],y				; Determine comparison
	BEQ .equal
	DEC 
	BEQ .not_equal
	DEC 
	BEQ .greater
.less
	LDA [$00]
	CMP $03
	BCC .true
	BRA .false
.equal
	LDA [$00]
	CMP $03
	BEQ .true
	BRA .false
.not_equal
	LDA [$00]
	CMP $03
	BNE .true
	BRA .false
.greater
	LDA [$00]
	CMP $03
	BCS .true
.false
	INY #2
.true
	INY 
	REP #$20 
	LDA [$D5],y
	TAY
	RTS

;################################################
;# Command $99
;# Plays a SFX in the $1DF9 port

PlaySFX1DF9:
	INY
	SEP #$20
	LDA [$D5],y
	STA $1DF9
	REP #$20
	INY
	RTS

;################################################
;# Command $9A
;# Plays a SFX in the $1DFC port

PlaySFX1DFC:
	INY
	SEP #$20
	LDA [$D5],y
	STA $1DFC
	REP #$20
	INY
	RTS

;################################################
;# Command $9B
;# Updates a manual exanimation trigger

ExAniManual:
    INY
    LDA [$D5],y             ; Grab correct slot
    AND #$000F
    TAX
    INY
    LDA [$D5],y             ; Load frame to show
    STA.l $7FC070,x
    INY
    RTS

;################################################
;# Command $9C
;# Enables or disables a custom exanimation trigger

ExAniCustom:
    INY
    LDA [$D5],y             ; Grab correct slot
    AND #$000F
    ASL
    TAX

    LDA [$D5],y             ; Check if we should enable
    AND #$0080              ; or disable an slot
    BEQ .enable 
.disable
    LDA.l $7FC0FC
    AND.l ExAni_AND,x 
    BRA .return
.enable
    LDA.l $7FC0FC
    ORA.l ExAni_OR,x 
    BRA .return
.return
    STA.l $7FC0FC

    INY
    RTS

ExAni_OR:
    dw $0001,$0002,$0004,$0008
    dw $0010,$0020,$0040,$0080
    dw $0100,$0200,$0400,$0800
    dw $1000,$2000,$4000,$8000

ExAni_AND:
    dw ~$0001,~$0002,~$0004,~$0008
    dw ~$0010,~$0020,~$0040,~$0080
    dw ~$0100,~$0200,~$0400,~$0800
    dw ~$1000,~$2000,~$4000,~$8000

;################################################
;# Command $9D
;# Enables or disables a one shot exanimation trigger

ExAniOneShot:
    INY
    LDA [$D5],y             ; Grab correct slot
    AND #$001F
    ASL
    TAX

    LDA [$D5],y             ; Check if we should enable
    AND #$0080              ; or disable an slot
    BEQ .enable 
.disable
    CPX #$0020
    BCS ..second_group
    LDA.l $7FC0F8
    AND.l ExAni_AND,x       ; Disable the desired slot
    STA.l $7FC0F8
    BRA .return
..second_group
    LDA.l $7FC0FA
    AND.l ExAni_AND-$20,x       ; Disable the desired slot
    STA.l $7FC0FA
    BRA .return

.enable
    CPX #$0020
    BCS ..second_group
    LDA.l $7FC0F8
    ORA.l ExAni_OR,x        ; Enable the desired slot
    STA.l $7FC0F8
    BRA .return
..second_group
    LDA.l $7FC0FA
    ORA.l ExAni_OR-$20,x        ; Enable the desired slot
    STA.l $7FC0FA
.return

    INY
    RTS 

;################################################
;# Command $9E
;# Turns on echo fo SFXs

TurnOnSFXEcho:
	SEP #$20
	LDA #$06
	STA $1DFA
	REP #$20
	INY
    RTS

;################################################
;# Command $9F
;# Turns off echo fo SFXs

TurnOffSFXEcho:
	SEP #$20
	LDA #$05
	STA $1DFA
	REP #$20
	INY
    RTS

;################################################
;# Command $A0
;# Executes ASM code ONCE

ExecuteASM:
    INY
	PHY
    PHB
    PHD
    PHP
	LDA [$D5],y
	AND #$00FF
	ASL 
	ADC.w !VWF_ASM_PTRS
	STA $00
	LDA.w !VWF_ASM_PTRS+2
	STA $02
	LDA [$00]
	STA $00
	INY


    SEP #$20
	PHK
	PER $0002               ; Execute code
	JML [$0000|!dp]

    PLP
    PLD
    PLB
	PLY
	INY
    RTS

;################################################
;# Command $A1
;# Runs ASM code every frame.

ExecuteASMEveryFrame:
    INY 
	LDA [$D5],y
	AND #$00FF
	ASL 
	ADC.w !VWF_ASM_PTRS
	STA.w !ASMPointer
    INY 
    RTS

;################################################
;# Command $A2
;# Stops ASM code.

StopASMEveryFrame:
    STZ.w !ASMPointer
    INY
    RTS 

