; ---------------- ;
;  +/- Time Clock  ;
;   by JamesD28    ;
; ---------------- ;

; A Clock that can add to or subtract from the timer when collected, like in games such as Super Mario 3D Land/World.
; It also handles overflow and underflow - If adding to the timer would take it past 999, the timer is set to 999. If subtracting from it would take it
; below 0, the timer is set to 0 and the player is killed with a TIME UP!.

; Extra bit clear: Adds to the timer.
; Extra bit set: Subtracts from the timer.

; Extra byte 1: How many timer seconds to add/subtract.

; Extra byte 2: Behaviours. Bitwise format: N----eee
	; N: If set ($80), the block will be NON-solid, and can be collected from any side. If clear ($00), it will be solid and must be hit from below.
	; -: Unused.
	; e: Effect type.
		; 0 = "Shatter" particles.
		; 1 = Rainbow "Shatter" particles.
		; 2 = Puff of smoke.
		; 3 = "Contact" spark.
		; 4 = Smoke when the player turns around abruptly.
		; 5 = Unused/none.
		; 6 = Glitter.
		; 7 = Unused.

; ---------------- ;

!SFXAdd = $29			; Sound effect to play when adding to the timer.
;!SFXAdd = $00			; Sound effect to play when adding to the timer.
!SFXAddBank = $1DFC		; Bank.
!SFXSub = $00			; Sound effect to play when subtracting from the timer.
!SFXSubBank = $1DFC		; Bank.

!TileNumFace = $6D		; Tile number to use for the clock face.
!TileNumButton = $08	; Tile number to use for the clock's button.
!AddBasePal = $05		; Palette to use for the Add version below the Alt threshold. Valid range = $00-$07.
;!AddBasePal = $07		; Palette to use for the Add version below the Alt threshold. Valid range = $00-$07.
!AddAltPal = $05		; Palette to use for the Add version above the Alt threshold.
!SubBasePal = $02		; Palette to use for the Subtract version below the Alt threshold.
!SubAltPal = $04		; Palette to use for the Subtract version above the Alt threshold.
!SPpage = 1				; 0 = Use SP1/SP2. 1 = Use SP3/SP4.

!AltThreshold = 100		; How many seconds the block must add/subtract (set in extra byte 1) before using the alternate palette.
						; Set to 0 if you want to always use the same palette regardless of the +/- timer value (!AddAltPal and !SubAltPal will be used).

; ---------------- ;

print "MAIN ",pc

PHB
PHK
PLB
JSR BlockMain
PLB
RTL

Return:
RTS

BlockMain:

JSR Graphics

LDA $9D
BNE Return

%SubOffScreen()

LDA !extra_byte_2,x
BMI Nonsolid

LDA !9E,x
PHA
LDA #$B9
STA !9E,x
JSL $01B44F|!BankB
PLA
STA !9E,x
LDA !C2,x
STZ !C2,x
BNE Collected
RTS

Nonsolid:

JSL $01A7DC|!BankB
BCS Collected
RTS

Collected:

STZ !14C8,x
LDA !extra_byte_2,x
STZ $00
AND #$07
BEQ Shatter2
DEC A
BEQ Shatter
CMP #$06
BCC +
LDA #$04
+

STZ $01
TAY
DEY
PHA
LDA.w Timers,y
STA $02
PLA
%SpawnSmoke()
BRA Timer

Shatter:
INC $00
Shatter2:
LDA !E4,x
STA $9A
LDA !14E0,x
STA $9B
LDA !D8,x
STA $98
LDA !14D4,x
STA $99
LDA $5B
AND #$01
BEQ +
LDA $99
LDY $9B
STY $99
STA $9B
+
PEA.w $02|(Shatter>>16<<8)
PLB
LDA $00
JSL $028663|!BankB
PLB
STZ $1DFC|!addr

Timer:
%BEC(+)
JMP Subtract
+

LDA $0F31|!addr
ORA $0F32|!addr
ORA $0F33|!addr
PHP
LDA !extra_byte_1,x
-
CMP #$64
BCC Tens
SBC #$64
INC $0F31|!addr
LDY $0F31|!addr
CPY #$0A
BCS MaxTime
BRA -

Tens:
-
CMP #$0A
BCC Ones
SBC #$0A
INC $0F32|!addr
LDY $0F32|!addr
CPY #$0A
BCC -
STZ $0F32|!addr
INC $0F31|!addr
LDY $0F31|!addr
CPY #$0A
BCC -

MaxTime:
LDA #$09
STA $0F31|!addr
STA $0F32|!addr
STA $0F33|!addr
LDA #$28
STA $0F30|!addr
BRA AddSFX

Ones:
ADC $0F33|!addr
CMP #$0A
BCC +
SBC #$0A
STA $0F33|!addr
INC $0F32|!addr
LDA $0F32|!addr
CMP #$0A
BCC AddSFX
STZ $0F32|!addr
INC $0F31|!addr
LDA $0F31|!addr
CMP #$0A
BCS MaxTime
BRA AddSFX
+
STA $0F33|!addr

AddSFX:
PLP
BNE +
LDA #$28
STA $0F30|!addr
+
LDA #!SFXAdd
STA !SFXAddBank|!addr
RTS

Subtract:
LDA !extra_byte_1,x
-
CMP #$64
BCC SubTens
SBC #$64
DEC $0F31|!addr
BMI Zero
BRA -

SubTens:
-
CMP #$0A
BCC SubOnes
SBC #$0A
DEC $0F32|!addr
BPL -
LDY #$09
STY $0F32|!addr
DEC $0F31|!addr
BPL -

Zero:
STZ $0F31|!addr
STZ $0F32|!addr
STZ $0F33|!addr
JSL $00F606|!BankB
BRA SubSFX

SubOnes:
STA $00
LDA $0F33|!addr
SEC
SBC $00
BCS +
ADC #$0A
STA $0F33|!addr
DEC $0F32|!addr
BPL CheckZero
LDY #$09
STY $0F32|!addr
DEC $0F31|!addr
BMI Zero
BRA CheckZero
+
STA $0F33|!addr

CheckZero:
LDA $0F31|!addr
ORA $0F32|!addr
ORA $0F33|!addr
BEQ Zero
SubSFX:
LDA #!SFXSub
STA !SFXSubBank|!addr
RTS

; ---------------- ;

Timers:
db $1B,$08,$14,$00,$1B

; ---------------- ;

Graphics:

%GetDrawInfo()

LDA $00
STA $0300|!addr,y
CLC
ADC #$04
STA $0304|!addr,y

LDA $01
STA $0301|!addr,y
SEC
SBC #$08
STA $0305|!addr,y

LDA #!TileNumFace
STA $0302|!addr,y
LDA #!TileNumButton
STA $0306|!addr,y

LDA !extra_byte_1,x
CMP #!AltThreshold
ROL
AND #$01
STA $02
LDA !7FAB10,x
AND #$04
LSR
ORA $02
TAX
LDA Palettes,x
if !SPpage
INC A
endif
STA $0303|!addr,y
STA $0307|!addr,y

TYA
LSR #2
TAX
LDA #$02
STA $0460|!addr,x
STZ $0461|!addr,x

LDY #$FF
LDA #$01
LDX $15E9|!addr
JSL $01B7B3|!BankB
RTS

Palettes:
db !AddBasePal*2,!AddAltPal*2,!SubBasePal*2,!SubAltPal*2