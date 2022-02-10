;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Iceball
;; A fireball which hurts and freezes the player when touched.
;; By Sonikku
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The sprite tiles to use for the iceball.
!Tile1 = $2C
!Tile2 = $2D

; The palette to use for the iceball.
!Palette = $0B

; Graphics page for the iceball ($00 for SP1/2, $01 for SP3/4).
!Page = $00

; Set to 0 if you don't want the iceball to hurt Mario.
!HurtPlayer = 1

; How long to freeze the player for.
; Set to $00 if you don't want the iceball to freeze the player.
!FreezeTime = $40

; Sound effect to play when touching the ground.
!GroundSFX = $01
!GroundBank = $1DFC

; Sound effect to play when freezing the player.
!FreezeSFX = $01
!FreezeBank = $1DFC

print "MAIN ",pc
	PHB : PHK : PLB
	LDA $9D
	BEQ Continue
	JMP Graphics

Continue:
	LDA !extended_y_low,x
	CMP $1C
	LDA !extended_y_high,x
	SBC $1D
	BEQ NotOffscreen
	STZ !extended_num,x
	PLB
	RTL

NotOffscreen:
	INC !extended_table,x

    LDA $171F|!Base2,x
    CLC : ADC #$03
    STA $04
    LDA $1733|!Base2,x
    ADC #$00
    STA $0A
    LDA #$0A
    STA $06
    STA $07
    LDA $1715|!Base2,x
    CLC : ADC #$03
    STA $05
    LDA $1729|!Base2,x
    ADC #$00
    STA $0B
    JSL $03B664|!BankB
    JSL $03B72B|!BankB
    BCC .skip
    if !FreezeTime > $00
        LDA.b #!FreezeTime
        STA $18BD|!Base2
        LDA.b #!FreezeSFX
        STA.w !FreezeBank|!Base2
    endif
    if !HurtPlayer != 0
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
    endif
    JSR Smoke
    STZ !extended_num,x
    PLB
    RTL

.skip
	LDA $173D|!Base2,x
	CMP #$30
	BPL .enoughGravity
	CLC : ADC #$04
	STA $173D|!Base2,x
.enoughGravity
	%ExtendedBlockInteraction()
Iceball:
	BCC .inAir
	JSR Smoke
    STZ !extended_num,x
    LDA.b #!GroundSFX
    STA.w !GroundBank|!Base2
    PLB
    RTL

.inAir
	STZ $175B|!Base2,x
.updatePos
	LDY #$00
	LDA $1747|!Base2,x
	BPL +
        DEY
+   CLC : ADC !extended_x_low,x
	STA !extended_x_low,x
	TYA
	ADC !extended_x_high,x
	STA !extended_x_high,x
	%SpeedY()
Graphics:
	%ExtendedGetDrawInfo()
	LDA $1747|!Base2,x
	AND #$80
	LSR A
	STA $03
	LDA !extended_behind,x
	STA $00
	LDA $01
	STA $0200|!Base2,y
	LDA $02
	STA $0201|!Base2,y
	LDA !extended_table,x
	LSR #2
	AND #$03
	TAX
	LDA.w IceballTiles,x
	STA $0202|!Base2,y
	LDA.w IceballProps,x
	EOR $03
	ORA $64
	LDX $00
	BEQ +
        AND #$CF
        ORA #$10
+   STA $0203|!Base2,y
	TYA
	LSR #2
	TAY
	LDA #$00
	STA $0420|!Base2,y
	LDX $15E9|!Base2
	PLB
	RTL

IceballTiles:
	db !Tile1,!Tile2,!Tile1,!Tile2

IceballProps:
    db (!Palette-$08<<$01)|(!Page&$01)
    db (!Palette-$08<<$01)|(!Page&$01)
    db (!Palette-$08<<$01)|(!Page&$01)|$C0
    db (!Palette-$08<<$01)|(!Page&$01)|$C0

Smoke:
    LDY #$03                    ; Number of smoke slots -1 (0-3 inclusive)
-   LDA $17C0|!Base2,y          ;\ Search for free smoke slot index.
    BEQ +                       ; |
    DEY                         ; |
    BPL -                       ; |
    RTS                         ;/

+   LDA #$01                    ; set smoke type
    STA $17C0|!Base2,y
    LDA #$1B                    ; set smoke existence timer
    STA $17CC|!Base2,y
    LDA !extended_y_low,x       ; set smoke y position
    STA $17C4|!Base2,y
    LDA !extended_x_low,x       ; set smoke x position
    STA $17C8|!Base2,y
    RTS
