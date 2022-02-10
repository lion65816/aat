;------------;
;   LASER    ;
;------------;

; Initial XY positions set by the generating sprite.

; Set to 0 to disable killing other sprites.
!KillOtherSprites = 1

; The sound effect to use when killing other sprites.
!SoundEffect = $47
!SoundBank = $1DFC

; The tile to use for the sprite (default: coin tile in SP2).
!Tile = $C2

; The palettes to flash between.
Palettes:
    db $04,$06,$08,$0A

OAMStuff:
    db $40,$44,$48,$4C,$D0,$D4,$D8,$DC,$80,$84,$88,$8C,$B0,$B4,$B8,$BC,$C0,$C4,$C8,$CC

Return: RTL

print "MAIN ",pc
    JSR Graphics
    LDA $9D                         ; Return if sprites locked.
    BNE Return

    PHY : PHX                       ; Mario interaction
    TYX
    JSL $03B664|!BankB              ; Get mario clipping
    JSR GetClipping                 ; Get cluster clipping
    JSL $03B72B|!BankB              ; Check for contact
    PLX
    PLY
    BCC +                           ; If interacting, hurt Mario
    JSL $00F5B7|!BankB
+

    if !KillOtherSprites == 1
        PHX : TYX
        JSR GetClipping

        LDX.b #!SprSize-1
-       LDA !14C8,x
        BEQ +
        PHY : PHX
        JSL $03B6E5|!BankB          ; Get sprite clipping B
        JSL $03B72B|!BankB
        PLX : PLY
        BCC +
        PHX
        STZ !14C8,x
        LDA.b #!SoundEffect
        STA !SoundBank|!Base2
        JSR Smoke2
        PLX
+       DEX
        BPL -
        PLX
    endif

    ; Y
    LDA !cluster_y_low,y
    CLC : ADC #$08
    STA !cluster_y_low,y
    LDA !cluster_y_high,y
    ADC #$00
    STA !cluster_y_high,y

    ;X
    LDX $1E52|!Base2,y
    BNE +
    LDA !cluster_x_low,y
    SEC : SBC #$08
    STA !cluster_x_low,y
    LDA !cluster_x_high,y
    SBC #$00
    STA !cluster_x_high,y
    BRA .continue

+   LDA !cluster_x_low,y
    CLC : ADC #$08
    STA !cluster_x_low,y
    LDA !cluster_x_high,y
    ADC #$00
    STA !cluster_x_high,y
.continue
    PHY

    ; $1693 = low byte
    ; $18D7 = high byte
    JSR ObjectInteraction
    PLY

    LDA $18D7|!Base2                ; Put the Map16 tile we're interacting with into C.
    XBA : LDA $1693|!Base2
    REP #$20
-   ASL A                           ; Resolve its "acts like" setting; pages 40-7F use another table.
    BMI .highPage
    ADC $06F624|!BankB
    STA $0D
    SEP #$20
    LDA $06F626|!BankB
    STA $0F
.readTile
    REP #$20
    LDA [$0D]                       ; C now has the acts like setting of the tile.
    CMP #$0200                      ; If it's not on page 0 or 1, check one level deeper.
    BCS -
    SEP #$20

    XBA                             ; C has the acts like setting in the range [0; 1FF].
    BEQ .noObject                   ; All tiles on page 0 are not solid.
    XBA                             ; Tiles [16E; 1FF] are not solid.
    CMP #$6E
    BCS .noObject

    LDA !cluster_y_low,y            ; We have hit a solid tile, [100; 16D], interact.
    AND #$F0
    SEC : SBC #$05
    STA !cluster_y_low,y
    LDA !cluster_y_high,y
    ADC #$00
    STA !cluster_y_high,y

    LDA !cluster_x_low,y
    AND #$F0
    SEC : SBC #$04
    STA !cluster_x_low,y
    LDA !cluster_x_high,y
    ADC #$00
    STA !cluster_x_high,y

    LDA #$00
    STA !cluster_num,y
    STA $1E52|!Base2,y
    JSR Smoke1
.noObject
    RTL

.highPage
    ADC $06F63A|!BankB
    ORA #$8000
    STA $0D
    SEP #$20
    LDA $06F63C|!BankB
    STA $0F
    BRA .readTile

Graphics:
    LDA !cluster_x_low,y
    CMP $1A
    LDA !cluster_x_high,y
    SBC $1B
    BNE .finish
    LDX.w OAMStuff,y            ; Get OAM index.
    LDA !cluster_y_low,y        ; \ Copy Y position relative to screen Y to OAM Y.
    SEC : SBC $1C               ;  |
    STA $0201|!Base2,x          ; /
    LDA !cluster_x_low,y        ; \ Copy X position relative to screen X to OAM X.
    SEC : SBC $1A               ;  |
    STA $0200|!Base2,x          ; /
    LDA #!Tile                  ; \ Tile = #$E0.
    STA $0202|!Base2,x          ; / (cloud)
    LDA $14
    AND #$0F
    LSR A
    LSR A
    PHY
    TAY
    LDA Palettes,y
    PLY
    PHA
    LDA $1E52|!Base2,y
    CLC
    rep 3 : ROR A

    ORA $01,s               ; I can be really lazy at times
    ORA $64                 ; \ Properties per spike, some are rising so this needs a seperate table.
    STA $0203|!Base2,x      ; /
    PLA

    PHX
    TXA
    LSR #2
    TAX
    LDA #$02
    STA $0420|!Base2,x
    PLX
    LDA $0201|!Base2,x
    CMP #$F0                ; As soon as the spike is off-screen...
    BCC .return
.finish
    LDA #$00                ; Kill sprite.
    STA !cluster_num,y
    STA $1E52|!Base2,y
.return
    RTS

GetClipping:
    LDA !cluster_x_low,y
    CLC : ADC #$04
    STA $04
    LDA !cluster_x_high,y
    ADC #$00
    STA $0A
    LDA #$02                ; Width of sprite clipping
    STA $06
    LDA !cluster_y_low,y
    CLC : ADC #$03
    STA $05
    LDA !cluster_y_high,y
    ADC #$00
    STA $0B
    LDA #$02                ; Height of sprite clipping
    STA $07
    RTS

ObjectInteraction:
    LDA !cluster_y_low,y
    CLC : ADC #$01          ; clipping Y
    STA $0C
    AND #$F0
    STA $00
    LDA !cluster_y_high,y
    ADC #$00
    STA $0D
    REP #$20
    LDA $0C
    CMP #$01B0
    SEP #$20
    BCS .return
    LDA !cluster_x_low,y
    CLC : ADC #$01          ; clipping X
    STA $0A
    STA $01
    LDA !cluster_x_high,y
    ADC #$00
    STA $0B
    BMI .return
    CMP $5D
    BCS .return
    LDA $01
    LSR #4
    ORA $00
    STA $00
    LDX $0B
    LDA.l $00BA60|!BankB,x
    CLC : ADC $00
    STA $05
    LDA.l $00BA9C|!BankB,x
    ADC $0D
    STA $06
    LDA.b #!BankA>>16
    STA $07
    LDX $15E9|!Base2
    LDA [$05]               ; read map16 low byte table ($7EC800)
    STA $1693|!Base2        ; Block you're interacting with (low byte) goes into $1693
    INC $07                 ; Switch to map16 high byte table ($7FC800)
    LDA [$05]               ; Load map16 high byte
    STA $18D7|!Base2        ; Block you're interacting with (high byte) goes into $18D7
    RTS

.return
    LDX $0F
    LDA #$00
    STA $1693|!Base2
    STA $1694|!Base2
    RTS

Smoke2:
    LDX #$03
    BRA Smoke1_findFree

Smoke1:
    LDX #$01                ; \ find a free slot to display effect
.findFree
    LDA $17C0|!Base2,x      ;  |
    BEQ .found              ;  |
    DEY                     ;  |
    BPL .findFree           ;  |
    RTS                     ; / return if no slots open

.found
    LDA #$01                ; \ set effect graphic to smoke graphic
    STA $17C0|!Base2,x      ; /
    LDA #$17                ; \ set time to show smoke
    STA $17CC|!Base2,x      ; /
    LDA !cluster_y_low,y    ; \ smoke y position = generator y position
    STA $17C4|!Base2,x      ; /
    LDA !cluster_x_low,y    ; \ load generator x position and store it for later
    STA $17C8|!Base2,x      ; /
    RTS
