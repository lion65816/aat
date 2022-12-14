lorom

if read1($00FFD5) == $23
	; SA-1 base addresses
	sa1rom
	!sa1 = 1
	!dp = $3000
	!addr = $6000
	!bank = $000000
else
	; Non SA-1 base addresses
	!sa1 = 0
	!dp = $0000
	!addr = $0000
	!bank = $800000
endif

; RAM defines

; These are just vanilla defines but if you know what you're doing, you can change them as well.
!MessageNumber	= $1426|!addr	; The message number
!MessageState	= $1B88|!addr	; Which state the game is currently in.
!MessageTimer	= $1B89|!addr	; Same as in the vanilla game: Controls the box's size and when to change the state but also which side to write

; These can stay in WRAM because code is handled by SNES
!MessageBuff = $7FC700			; 18 * 8 = 144 bytes

; Other defines

!TextProp = $39					; The text's properties.
!EmptyTile = $1F				; The tile to draw for the border and reminder of the text.
!EnableSwitchPalace = 1			; If set to 1: Display dotted and exclamation mark blocks on switch palace messages.
!HijackNmi = 1					; If set to 1: Handle NMI code with this patch (requires UberASM if disabled).
!AutomaticIntro = 0				; If set to 1: Don't wait for player input in the intro.

; Don't edit them unless necessary

YoshisHouseLevel = $03BB9B|!bank
YellowSwitchPalace = $03BBA2|!bank
BlueSwitchPalace = $03BBA7|!bank
RedSwitchPalace = $03BBAC|!bank
GreenSwitchPalace = $03BBB1|!bank
MessageIndex = $03BE80|!bank
MessageTable = $03BC0B|!bank

ExclamationMarkTiles = $05B29B|!bank
ExclamationMarkOffsets = $05B2DB|!bank

!Layer3Tilemap = $5000

!WindowingChannel = read1($05B295)	; Starting from v1.35, SA-1 Pack moving Windowing to HDMA channel 1 instead of 7.

assert read4($05B1A3) == $03BB9022, "Please edit the messages at least once before you apply this patch."

org $05B10C
autoclean JML NewMessageSystem

; Make the table relative offsets only
org ExclamationMarkOffsets
db $00,$00,$08,$00,$00,$08,$08,$08
db $40,$00,$48,$00,$40,$08,$48,$08

freecode

NewMessageSystem:
	PHB
	PHK
	PLB
	LDX !MessageState
	TXA
	JSR (MessageBoxActions,x)
	PLB
RTL

MessageBoxActions:
dw .Grow
dw .WaitForNMI
dw .GenerateMessage
dw .WaitForPlayer
dw .WaitForNMI
dw .Shrink

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Grow:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; Disable every layer and colour maths in the window.
	LDA #$22
	STA $41
	STA $42
	STA $44
	LDX $13D2|!addr
	BEQ +
	LDA #$20			; Don't mask out sprites if a switch message.
+	STA $43
	
	JSR GenerateWindow
	LDA !MessageTimer
	CMP #$50
	BEQ ..NextState
	CLC : ADC #$04
	STA !MessageTimer
RTS

..NextState:
	LDA !MessageState
	INC #2
	STA !MessageState
	STZ !MessageTimer
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.GenerateMessage:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDA #$00
	XBA
	LDX $1426|!addr
	CPX #$03
	BEQ ..YoshiMessage
	LDA $13BF|!addr
	CMP YoshisHouseLevel
	BEQ ..YoshisHouse
	CPX #$02
BRA ..NormalMessage

..YoshiMessage:
	LDA #$00			; Level 0
	SEC					; Message 2
	BRA ..NormalMessage

..YoshisHouse:
	CLC					; Message 1
	LDY $187A|!addr		;
	BEQ ..NormalMessage	; If on Yoshi...
	SEC					; Message 2
..NormalMessage:
	; In the end:
	; A: Translevel number
	; C: CLC for message 1, SEC for message 2
	REP #$30
	ROL
	ASL
	TAX
	PEA.w (!MessageBuff>>16)|(NewMessageSystem>>16<<8)
	PLB
	LDA.l !MessageTimer
	AND #$0001
	BNE ..Shared
	LDY #$0000
	LDA MessageTable+1
	STA $01				; Fixed bank.
	LDA MessageIndex,x
	CLC : ADC MessageTable
	STA $00
	SEP #$20
-	LDA [$00],y
	CMP #$FE			; If tile is $FE: Reached the end of message
	BEQ ..Empty
	STA.w !MessageBuff,y
	INY
	CPY #$0090
	BNE -
	BRA ..Shared

..Empty:
	LDA #!EmptyTile
-	STA.w !MessageBuff,y
	INY
	CPY #$0090
	BNE -
	
..Shared:
	REP #$30
	
	; Get VRAM Address
	LDY #$0000
	LDA $22
	CLC : ADC #$0034	; 6 tiles to the right
	BIT #$0100			; Is on right half?
	BEQ +
	INY
+	LSR #3
	AND #$001F
	STA $00
	LDA $24
	CLC : ADC #$0034	; 5 tiles to the bottom
	BIT #$0100			; Is on bottom half?
	BEQ +
	INY #2
+	ASL #2
	AND #$03E0
	ORA $00
	STA $00
	TYA
	XBA
	ASL #2				; Y << 10
	ORA $00
	ORA #$5000
	STA $00

	; Get left side's width.
	AND #$001F
	EOR #$001F
	INC
	CMP #$0014
	BCC ..Split
	LDA #$0014			; Maximally 0x14
..Split:
	STA $02

	; Write the message
	LDA $7F837B
	TAX

	LDA.l !MessageTimer
	AND #$0001
	STA $06
	BNE ..RightSide
	LDA.w #!MessageBuff
	STA $04
	JSR PlaceTiles
	LDA #$FFFF
	STA $7F837D,x
	TXA
	STA $7F837B
	PLB
	SEP #$30
	INC !MessageTimer
RTS

; The process goes the following:
; - Set the X position to the left side of the other half.
; - Increment the text buffer by the current box with - 1 (because of the border)
; - Decrement the full width by the current width
..RightSide:
	LDA.w #!MessageBuff
	CLC : ADC $02
	DEC
	STA $04
	LDA #$0014
	SEC : SBC $02
	BEQ ..SingleSide
	STA $02
	LDA $00
	AND #~$001F
	EOR #$0400
	STA $00

	JSR PlaceTiles
	LDA #$FFFF
	STA $7F837D,x
	TXA
	STA $7F837B
..SingleSide:
	PLB

; Initialise next state
	SEP #$30
	INC !MessageState
	INC !MessageState
	STZ !MessageTimer
	LDA #$20			; Display layer 3
	STA $42				;
	LDY #$82			; Disables mainscreen inside the mask...
	LDA $0D9D|!addr		; ... but only if layer 3 is on subscreen
	AND #$04			;
	BEQ +				;
	LDY #$22			; Disable subscreen instead. 
+	STY $44				; Handles both colour maths and subscreen layer 3.
if !EnableSwitchPalace
	LDX #$00			;
	LDA $13BF|!addr		; Check for switch palace levels.
	CMP YellowSwitchPalace
	BEQ ..SwitchMessage
	INX
	CMP BlueSwitchPalace
	BEQ ..SwitchMessage
	INX
	CMP RedSwitchPalace
	BEQ ..SwitchMessage
	INX
	CMP GreenSwitchPalace
	BNE .WaitForNMI
..SwitchMessage
	INX
	STX $13D2|!addr		; Mark message as Switch Palace message
	LDA #$20			; Don't mask out sprites.
	STA $43
	JMP DrawExclamationBlocks
endif

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.WaitForNMI:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.WaitForPlayer:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDA $0109|!addr
	ORA $13D2|!addr
	BEQ ..NotSpecial	
	LDA $1DF5|!addr
	BEQ ..NotSpecial
	LDA $13
	AND #$03
	BNE ..Return
	DEC $1DF5|!addr
	BNE ..Return
	LDA $13D2|!addr
	BEQ ..NotSpecial
	INC $1DE9|!addr
	LDA #$01
	STA $13CE|!addr

..ToOverworld:
	STA $0DD5|!addr
	LDA #$0B
	STA $0100|!addr
RTS
	
..NotSpecial:
if !AutomaticIntro
	LDA $0109|!addr
	BNE ..IntroMessage
	LDA $18
	AND #$C0
	ORA $16
	AND #$F0
	BEQ ..Return
	BRA ..CloseMessage

..IntroMessage
else
	LDA $18
	AND #$C0
	ORA $16
	AND #$F0
	BEQ ..Return
	LDA $0109|!addr
	BEQ ..CloseMessage
endif
	;LDA #$8E
	;STA $1F19|!addr
	LDA #$00
	STA $0109|!addr
BRA ..ToOverworld

..CloseMessage
	LDA #$22			; Disable layer 3 and subscreen again
	STA $42
	STA $44
	LDA !MessageState
	INC #2
	STA !MessageState
..Return:
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.Shrink:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	LDA !MessageTimer
	SEC : SBC #$04
	STA !MessageTimer
	BNE GenerateWindow
	STZ !MessageNumber	;
	STZ !MessageState
	LDA.b #!WindowingChannel
	TRB $0D9F|!addr
RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GenerateWindow:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDA $22
	AND #$07
	CMP #$04
	BCS +
	ORA #$08
+	EOR #$FF
	INC
	CLC : ADC #$88		; 0x80 + 8
	STA $00
	REP #$20
	LDA $24				; Get offset
	AND #$0007
	CMP #$0004
	BCS +
	ORA #$0008
+	EOR #$FFFF
	INC
	CLC : ADC #$005F	; 0x58 + 8 - 1

	ASL					; Windowing table is made of words.
	TAX					; Top half, goes from bottom to top.
	DEX					; Fix offset
	DEX
	CLC : ADC #$04A0|!addr
	STA $01				; Indirect because Y is also the loop count.

	SEP #$20
	LDA $00				; Get edges
	DEC
	CLC : ADC !MessageTimer
	XBA
	LDA $00
	SEC : SBC !MessageTimer
	REP #$20

	LDY #$00
.Loop:
	CPY $1B89|!addr		;
	BCC .NoWindow		; If outside the box...
	LDA #$00FF			; Disable window.
.NoWindow:
	STA $04A0|!addr,x
	STA ($01),y
	DEX
	DEX
	INY
	INY
	CPY #$50
	BNE .Loop
	SEP #$20

	LDA.b #!WindowingChannel
	TSB $0D9F|!addr
RTS

if !EnableSwitchPalace
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DrawExclamationBlocks:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Places the exclamation mark blocks on the message.
	WDM
	TXA
	ASL #4
	TAX
	STZ $00
	LDA $22
	AND #$07
	CMP #$04
	BCS +
	ORA #$08
+	EOR #$FF
	INC
	CLC : ADC #$59		; 0x80 + 8 + 1
	STA $01
	LDA $24				; Get offset
	AND #$07
	CMP #$04
	BCS +
	ORA #$08
+	EOR #$FF
	INC
	CLC : ADC #$5F	; 0x58 + 8 - 1
	STA $02
	REP #$20
	LDY #$1C
.Loop
	LDA.l ExclamationMarkTiles-16,x
	STA $0202|!addr,y
	PHX
	LDX $00
	LDA.l ExclamationMarkOffsets,x
	CLC : ADC $01
	STA $0200|!addr,y
	PLX
	INX #2
	INC $00
	INC $00
	DEY #4
	BPL .Loop
	STZ $0400|!addr
	SEP #$20
RTS
endif

; Input:
; $00: Leftmost VRAM address
; $02: Total columns to place
; $04: Message pointer (high byte in DB)
; $06: Which side to place.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PlaceTiles:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LDA #$0009			; 10 rows
	STA $0A
	LDA $00
	STA $08
.Loop:
	LDA $08
	PHA
	PHA
	XBA
	STA $7F837D,x
	LDA $02				; Columns in total to place
	STA $0C
	ASL
	DEC
	XBA
	STA $7F837F,x
	INX #4
	
	; Check if it's the top or bottom most row.
	LDA $0A
	BEQ .EmptyTiles
	CMP #$0009
	BNE .PlaceText
.EmptyTiles:
	LDA.w #!TextProp<<8|!EmptyTile
	STA $7F837D,x
	INX #2
	DEC $0C
	BNE .EmptyTiles

; Increment the VRAM address
; Keep in mind to switch the tilemap. As such, increment the Y-position individually
; before you ORA it with the rest of the VRAM address without the Y position.
.Shared:
	PLA
	AND #$0BE0			; Get Y position only
	ORA #$0400			; Carry over on overflow.
	CLC : ADC #$0020
	AND #$0BE0
	STA $08
	PLA
	AND #~$0BE0
	ORA $08
	STA $08
	DEC $0A
	BPL .Loop
RTS

; This is complex:
; I have no trouble to place the text but it makes a difference to also consider the border.
; The solution: If it's the left half, place the border, decrement the column counter
; and then place the text.
; If it's the right half, place the text at first and then overwrite the column with the border tile.
; Do the same with the left half if the full box is drawn
.PlaceText:
	LDY #$0000			; Set the message pointer to 0.
	LDA $06
	BNE ..PlaceTextLoop
	LDA.w #!TextProp<<8|!EmptyTile
	STA $7F837D,x
	INX #2
	DEC $0C
	BEQ ..PlaceTextFinish
	
..PlaceTextLoop:
	LDA ($04),y			; Get text
	AND #$00FF			; (8-bit values only)
	ORA.w #!TextProp<<8	; Add in the properties.
	STA $7F837D,x
	INX #2
	INY
	DEC $0C
	BNE ..PlaceTextLoop
	
..PlaceTextFinish:
	LDA $06				; If it's the right side, always place a border tile
	BNE ..RightSide		;
	LDA $02				; Otherwise only if the full box is drawn.
	CMP #$0014
	BNE ..NotFullBox
..RightSide:
	LDA.w #!TextProp<<8|!EmptyTile
	STA $7F837B,x
..NotFullBox:
	LDA $04				; Load the next row of text.
	CLC : ADC #$0012
	STA $04
JMP .Shared

if !HijackNmi

namespace "InlineMessageNmi"

pushpc

org $00820D
JML HijackNmi

pullpc

HijackNmi:
	JSL nmi
	LDA $143A|!addr
	BEQ +
JML $008212|!bank
+
JML $008217|!bank

incsrc InlineMessageNmi.asm

namespace off

else
	if read3($00820D) != $143AAD
	print " Revert NMI hijack."
	org $00820D
		LDA $143A|!addr
		BEQ $05
	endif
endif
