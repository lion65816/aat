;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Boomerang:
;; Flies to the left or right depending on direction thrown,
;; then flies back toward the direction it was thrown.
;; Can be caught by the Boomerang Bros.

        !HammerProp = #!Palette9|!SP3SP4

;don't touch, made so it's actually easy to change hardcoded prop without having to look up for help

!Palette8 = %00000000
!Palette9 = %00000010
!PaletteA = %00000100
!PaletteB = %00000110
!PaletteC = %00001000
!PaletteD = %00001010
!PaletteE = %00001100
!PaletteF = %00001110

!SP1SP2 = %00000000
!SP3SP4 = %00000001

print "MAIN ",pc
Boomerang:
    JSR Graphics

    LDA $9D
    BNE Return

    %SpeedNoGrav()
    ;%ExtendedHurt()
	JSR CustomInteraction

    INC $0E05|!Base2,x
    LDA $176F|!Base2,x              ; if timer isn't zero, branch.
    BNE NoDecrement

    LDA $1765|!Base2,x
    TAY
    LDA $1747|!Base2,x              ; accelerate sprite based on "direction."
    CMP X_Speed_Max,y
    BEQ NoDecrement
    LDA $1747|!Base2,x
    CLC : ADC X_Accel,y
    STA $1747|!Base2,x
NoDecrement:
    LDA $14                         ; run every other frame.
    LSR A
    BCS Return
    LDA $1779|!Base2,x
    CMP #$01
    BCS ++
    LDA $1779|!Base2,x              ; increment/decrement y speed based on stuff.
    AND #$01
    TAY
    LDA $173D|!Base2,x
    CMP Y_Speed_Max,y
    BNE +
        INC $1779|!Base2,x
+   LDA $173D|!Base2,x
    CLC : ADC Y_Accel,y
    STA $173D|!Base2,x
    RTL

++  LDA $173D|!Base2,x
    BEQ Return
    DEC $173D|!Base2,x              ; decrement timer used by the x speed.
Return:
    RTL

X_Accel:
    db $01,$FF

X_Speed_Max:
    db $20,$E0

Y_Accel:
    db $01,$FF

Y_Speed_Max:
    db $12,$EE

Graphics:
    %ExtendedGetDrawInfo()

    LDA $1747|!Base2,x
    STA $03

    LDA $0E05|!Base2,x              ; get frame based on $0E05,x
    LSR #2
    AND #$03
    PHX
    TAX

    LDA $01
    STA $0200|!Base2,y

    LDA $02
    STA $0201|!Base2,y

    LDA Tilemap,x
    STA $0202|!Base2,y

    LDA !HammerProp                       ; palette
    PHY
    TXY
    LDX $03                         ; flip based on direction.
    BPL +
        INY #4
+   ORA Properties,y                ; set properties.
    ORA $64
    PLY
    STA $0203|!Base2,y

    TYA
    LSR #2
    TAX
    LDA #$02
    STA $0420|!Base2,x
    PLX
    RTS

Properties:
    db $40,$40,$80,$80
    db $00,$00,$C0,$C0

Tilemap:
    db $4B,$4E,$4B,$4E

CustomInteraction:
JSR GetExClipping
JSL $03B664|!BankB			;get mario's clipping
JSL $03B72B|!BankB
BCC .nah

LDY #$00               ;A:25A1 X:0007 Y:0001 D:0000 DB:03 S:01EA P:envMXdizCHC:0130 VC:085 00 FL:924
LDA $96                ;A:25A1 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdiZCHC:0146 VC:085 00 FL:924
SEC                    ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0170 VC:085 00 FL:924
SBC $1715|!Base2,x              ;A:2546 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizCHC:0184 VC:085 00 FL:924
STA $0F                ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0214 VC:085 00 FL:924
LDA $97                ;A:25D6 X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0238 VC:085 00 FL:924
SBC $1729|!Base2,x            ;A:2501 X:0007 Y:0000 D:0000 DB:03 S:01EA P:envMXdizcHC:0262 VC:085 00 FL:924
BPL +            ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0294 VC:085 00 FL:924
INY                    ;A:25FF X:0007 Y:0000 D:0000 DB:03 S:01EA P:eNvMXdizcHC:0310 VC:085 00 FL:924

+
LDA $0F					;
CMP #$E6				;
BPL .hurt

LDA $140D|!Base2		; if player's either spinjumping
ORA $187A|!Base2		; or on yoshi
BNE .Spinjmp			; make sprite die in four stars of life force that last 23 frames.

.nah
RTS

.hurt
	PHB
	LDA.b #($02|!BankB>>16)
	PHA
	PLB
	PHK
	PEA.w .return-1
	PEA.w $B889-1
	JML $02A469|!BankB
.return
	PLB
	RTS				;p-sure should be RTL
	
.Spinjmp
JSL $01AB9E|!BankB 
JSL $01AA33|!BankB

LDA #$02			;
STA $1DF9|!Base2		; spin-killed sound effect
RTS

GetExClipping:
LDA $171F|!Base2,x		;Get X position
SEC				;Calculate hitbox
SBC #$02			;
STA $04				;

LDA $1733|!Base2,x		;
SBC #$00			;Take care of high byte
STA $0A				;

LDA #$0C			;width
STA $06				;

LDA $1715|!Base2,x		;Y pos
;SEC				;
;SBC #$04			;
STA $05				;

LDA $1729|!Base2,x		;
;SBC #$00			;
STA $0B				;

LDA #$10			;length
STA $07				;
RTS				;