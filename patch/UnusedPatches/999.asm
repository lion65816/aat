header

lorom
!sa1	= 0
!addr	= $0000			; $0000 if LoROM, $6000 if SA-1 ROM.
!bank	= $800000		; $80:0000 if LoROM, $00:0000 if SA-1 ROM.

if read1($00FFD5) == $23
	sa1rom
	!sa1	= 1
	!addr	= $6000
	!bank	= $000000
endif

!AlignLv1 = !Mid ; Valid values are !Left, !Mid and !Right.
!AlignLv2 = !Left ; Valid values are !Left and !Right.

!AlignOw1 = !Right ; Valid values are !Left, !Mid and !Right.
!AlignOw2 = !Right ; Valid values are !Left and !Right.

!OwLivesPos = !Left ; Valid values are !Left and !Right.
;!Left overwrites the X (if the leftmost slot is used), !Right touches the level name.

!Freeram1 = $0D9C|!addr
!Freeram2 = $0DA1|!addr

;WARNING: These freeram addresses MUST be within 255 bytes of each other!
;This means $0700/$07FF or $0780/$087F is valid, but $0700/$0800 is not.
;Additionally, !Freeram2 must be higher than !Freeram1.
;The default addresses should work, but if you're not sure, just try it (on a backup, obviously).
;It'll tell you if you're doing it wrong.

;These are scratch RAM. The first one must be two bytes; the latter two are one each. You should probably not change them.
!Scratch16 = $142C|!addr
!Scratch8 = $142E|!addr
!Scratch8b = $142F|!addr


;;don't ask
;macro assertcore(error)
;error <error>
;!x = xxxxxxxxxxxxxxx : !x = xxxxxxxxxxxxxxxxxxx
;endmacro
;macro assert(val, error)
;rep <val>*2-1 : %assertcore(<error>)
;endmacro
;%assert(!Freeram2-!Freeram1-256, "Your freeram addresses are too far from each other.")
;%assert(!Freeram1-!Freeram2, "Your first freeram address is higher than your second one. Please swap them.")

assert (!Freeram2)-(!Freeram1) < 256, "Your freeram addresses are too far from each other."
assert (!Freeram1)-(!Freeram2) != 0, "Your first freeram address is higher than your second one. Please swap them."

;don't ask about this either
!Right = munchermunchermunchermunchermunchermunchermuncher
!Left = munchermunchermunchermunchermunchermunchermuncher
!Mid = munchermunchermunchermunchermunchermunchermuncher
macro calldef(define)
!<define>
endmacro
macro Align3(LvOrOw, left, mid, right)
!Left = "<left>"
!Mid = "<mid>"
!Right = "<right>"
%calldef(Align<LvOrOw>1)
endmacro
macro Align2(LvOrOw, left, right)
!Left = "<left>"
!Right = "<right>"
%calldef(Align<LvOrOw>2)
endmacro

org $008F3B
	autoclean JML Mymain
;Return to 808F5B

org $05DBF2
	autoclean JML MainOW
;Return to RTL


;Fix various parts of the life exchanger routine
org $04F4B2
LifeExgStripe:
db $52,$49,$00,$09,$16,$28,$0A,$28,$1B,$28,$12,$28,$18,$28 ; MARIO
db $52,$52,$00,$09,$15,$28,$1E,$28,$12,$28,$10,$28,$12,$28 ; LUIGI
db $52,$0B,$00,$07
 LifeExgStripeMarioLives: db $FC,$28,$26,$28,$00,$28,$00,$28 ; x00 (left)
db $52,$14,$00,$07
 LifeExgStripeLuigiLives: db $FC,$28,$26,$28,$00,$28,$00,$28 ; x00 (right)
db $52,$0F,$00,$03
 LifeExgStripeDir1: db $FC,$38,$FC,$38 ; blank, direction is stored here
db $52,$2F,$00,$03
 LifeExgStripeDir2: db $FC,$38,$FC,$38 ; blank, lower half
db $51,$C9,$00,$03
 LifeExgStripeMarioHalo: db $85,$29,$85,$69 ; halo on Mario
db $51,$D2,$00,$03
 LifeExgStripeLuigiHalo: db $85,$29,$85,$69 ; halo on Luigi
LifeExgStripeEnd:
db $FF

org $04F594
LDY #$54

org $04F5E2
LDA.w NewArrowTable,y ; the stripe image expanded into this table; let's move it

;fix up where the halos are stored
org $04F5B7
STA.l $7F837D+LifeExgStripeMarioHalo-LifeExgStripe+0,x
STA.l $7F837D+LifeExgStripeMarioHalo-LifeExgStripe+2,x
org $04F5C7
STA.l $7F837D+LifeExgStripeLuigiHalo-LifeExgStripe+0,x
STA.l $7F837D+LifeExgStripeLuigiHalo-LifeExgStripe+2,x

;fix up where the direction is stored
org $04F5E5
STA.l $7F837D+LifeExgStripeDir1-LifeExgStripe+0,x
org $04F5EC
STA.l $7F837D+LifeExgStripeDir1-LifeExgStripe+2,x
org $04F5F3
STA.l $7F837D+LifeExgStripeDir2-LifeExgStripe+0,x
org $04F5FA
STA.l $7F837D+LifeExgStripeDir2-LifeExgStripe+2,x

;fix up size of the life-containing stripes
;org $04F608
;ADC.b #LifeExgStripeLuigiLives-LifeExgStripeMarioLives

org $04F600
	autoclean JML LifeExgDraw
RTSBank4:
RTS
NewArrowTable: db $7D,$38,$7E,$78

warnpc $04F625

freecode

Mymain:
LDX.b #!Freeram2-!Freeram1
LDA $0DB3|!addr
BNE .Luigi
LDX #$00
.Luigi

macro debug();macros are awesome
LDA $15
AND #$0C
BEQ .x
LSR A
CLC
ADC $0DBE|!addr
SEC
SBC #$03
STA $0DBE|!addr
.x
endmacro
;%debug()

;clear existing lives
LDA #$FC
STA $0F16|!addr
STA $0F17|!addr
STA $0F18|!addr

LDA $0DBE|!addr
JSR CalcLives
STA $0DBE|!addr

REP #$20
LDA !Scratch16
INC A;why are lives 0 when they're 1?

;convert to dec
JSR HexDec16to311

SEP #$20
;Ones: X
;Tens: Y
;100s: A
CMP #$00
BNE .ThreeDigits
CPY #$00
BNE .TwoDigits

if !sa1 == 0
%Align3(Lv, "STX $0F16", "STX $0F17", "STX $0F18")
else
%Align3(Lv, "STX $6F16", "STX $6F17", "STX $6F18")
endif
JML $008F5B|!bank

.TwoDigits
if !sa1 == 0
%Align2(Lv, "STY $0F16 : STX $0F17", "STY $0F17 : STX $0F18")
else
%Align2(Lv, "STY $6F16 : STX $6F17", "STY $6F17 : STX $6F18")
endif
JML $008F5B|!bank

.ThreeDigits
STX $0F18|!addr
STY $0F17|!addr
STA $0F16|!addr

.Return
JML $008F5B|!bank



MainOW:
LDX #$0C
.CopyLoop
LDA.l .Stripe,x
STA $7F837B,x
DEX
BPL .CopyLoop

LDX $0DB3|!addr
LDA $0DB4|!addr,x
STA !Scratch16
STZ !Scratch16+1
BPL +
STA !Scratch16+1;game over sets 0DB4 to FF
+

LDX.b #!Freeram2-!Freeram1
LDA $0DB3|!addr
BNE .Luigi
LDX #$00
.Luigi

REP #$20
LDA !Freeram1,x
AND #$00FF
ASL #4
CLC
ADC !Scratch16
INC A
JSR HexDec16to311

SEP #$20
;Ones: X
;Tens: Y
;100s: A
CMP #$00
BNE .ThreeDigits
CPY #$00
BNE .TwoDigits

TXA
CLC
ADC #$22
%Align3(Ow, "STA $7F8381 : LDA #$39 : STA $7F8382", "STA $7F8383 : LDA #$39 : STA $7F8384", "STA $7F8385 : LDA #$39 : STA $7F8386")
RTL

.TwoDigits
TYA
CLC
ADC #$22
%Align2(Ow, "STA $7F8381 : LDA #$39 : STA $7F8382", "STA $7F8383 : LDA #$39 : STA $7F8384")

TXA
CLC
ADC #$22
%Align2(Ow, "STA $7F8383 : LDA #$39 : STA $7F8384", "STA $7F8385 : LDA #$39 : STA $7F8386")
RTL

.ThreeDigits
CLC
ADC #$22
STA $7F8381
LDA #$39
STA $7F8382

TYA
CLC
ADC #$22
STA $7F8383
LDA #$39
STA $7F8384

TXA
CLC
ADC #$22
STA $7F8385
LDA #$39
STA $7F8386
RTL

.Stripe
!Left = 1
!Right = 0
db $0A,$00			;this is the value put in $7F837B. it violates the protocol, but if a code from the original SMW can do that, I can too.
db $50,$88-!OwLivesPos,$00,$05	;I'll just have to hope that nothing else tries to write to a fixed location before loading this one...
!Left = $8F
!Right = $FE
db !OwLivesPos,$38
db $FE,$38
db $FE,$38
db $FF



LifeExgDraw:
;LDA $123456
; 16 = lives
; 8 = offset to $7F837D where the stripe starts, plus #LifeExgStripeLuigiLives-LifeExgStripeMarioLives if needed
STX !Scratch8

LDX #$00
LDA $0DB4|!addr
JSR CalcLives
STA $0DB4|!addr
JSR .Core

LDX.b #!Freeram2-!Freeram1
LDA $0DB5|!addr
JSR CalcLives
STA $0DB5|!addr
LDA !Scratch8
CLC
ADC.b #LifeExgStripeLuigiLives-LifeExgStripeMarioLives
STA !Scratch8
JSR .Core

JML RTSBank4


.Core
REP #$20
LDA !Scratch16
INC A

;convert to dec
JSR HexDec16to311
SEP #$20
BEQ .OnlyTwoDigits
STX !Scratch16 ; we don't need this anymore
LDX !Scratch8
STA.l $7F837D+LifeExgStripeMarioLives-LifeExgStripe+2,x
LDA #$26
STA.l $7F837D+LifeExgStripeMarioLives-LifeExgStripe+0,x
LDA !Scratch16
BRA .WriteLastTwo
.OnlyTwoDigits
TYA
BNE +
LDY #$FC
+
TXA
LDX !Scratch8
.WriteLastTwo
STA.l $7F837D+LifeExgStripeMarioLives-LifeExgStripe+6,x
TYA
STA.l $7F837D+LifeExgStripeMarioLives-LifeExgStripe+4,x
RTS



CalcLives:
;in:
; A=lives low byte (possibly outside standard range)
; X=0 for Mario, !Freeram2-!Freeram1 for Luigi
;out:
; A=lives low byte, now inside standard range (store it where you got it)
; the relevant freeram is also updated
; X=unchanged
; Y=unchanged
; !Scratch16.w=number of lives
STA !Scratch16
STZ !Scratch16+1
REP #$20
LDA !Freeram1,x
AND #$00FF
ASL #4
CLC
ADC !Scratch16

;cap it at 999
CMP #$03E6
BCC .DontDrop
LDA #$03E6
.DontDrop

STA !Scratch16

CMP #$0030
BCC .ZeroHigh
LSR #4
SEP #$20
SEC
SBC #$03
STA !Freeram1,x
LDA !Scratch16
AND #$0F
ORA #$30
RTS
.ZeroHigh
SEP #$20
STZ !Freeram1,x
RTS


HexDec16to311:
if !sa1 == 0

;X=ones, Y=tens, A=hundreds, Z=(A==0)
STA $4204
LDY #$0A
STY $4206
JSR Waste24Cycles
LDX $4216
LDA $4214

;Y=ones, A=tens and hundreds, Z=(A==0)
STA $4204
LDY #$0A
STY $4206
JSR Waste24Cycles
LDY $4216
LDA $4214
RTS

;For use with the division registers. 16 is enough outside of fastrom,
;but many users do put it in fastrom, and I want bsnes compatibility for everyone.
Waste24Cycles:
JSR Waste12Cycles
Waste12Cycles:
RTS

else
	ldy #$01
	sty $2250
	sta $2251
	lda #$000A
	sta $2253
	nop : bra $00
	ldx $2308
	lda $2306

	sty $2250
	sta $2251
	lda #$000A
	sta $2253
	nop : bra $00
	ldy $2308
	lda $2306
	rts
endif