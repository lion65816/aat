; Interaction routine with blocks for extended sprites.
;
; Input: N/A
; Output:
;   $0B = Slope type that the sprite is touching
;   $0C = Low byte of the map16 number in Layer 1 that the sprite is touching
;   $0D = Low byte of the map16 number in Layer 2/3 that the sprite is touching
;   $0E = Sprite has interacted with a interactable/solid block in any Layer flag
;   $0F = Sprite has been processed with Layer 2/3
;   $8B = High byte of the map16 number in Layer 1 that the sprite is touching
;   $8C = High byte of the map16 number in Layer 2/3 that the sprite is touching

    STZ $0F
    STZ $0E
    STZ $0B
    STZ $1694|!Base2
    LDA $140F|!Base2                ; checking if we're in a special level
    BNE .normalLevel
    LDA $0D9B|!Base2                ; boss battles
    BPL .normalLevel
    AND #$40                        ; Larry/Iggy platform
    BEQ .larryPlatform
    LDA $0D9B|!Base2
    CMP #$C1                        ; check Bowser battle
    BEQ .normalLevel
.specialLevel
    LDA !extended_y_low,x           ; check if Y pos is XXA8
    CMP #$A8
    RTL

.larryPlatform
    LDA !extended_x_low,x
    CLC : ADC #$0A
    STA $14B4|!Base2
    LDA !extended_x_high,x
    ADC #$00
    STA $14B5|!Base2
    LDA !extended_y_low,x
    CLC : ADC #$08
    STA $14B6|!Base2
    LDA !extended_y_high,x
    ADC #$00
    STA $14B7|!Base2
    JSL $01CC9D|!BankB
    LDX $15E9|!Base2
    RTL

.normalLevel
    PEA $00DA
    JSR .runInteraction
    PLA : PLA
    ROL $0E
    LDA $1693|!Base2
    STA $0C
    LDA $8A
    STA $8B
    LDA $5B
    BPL ..normalLevel
    INC $0F
    LDA !extended_x_low,x
    PHA
    CLC : ADC $26
    STA !extended_x_low,x
    LDA !extended_x_high,x
    PHA
    ADC $27
    STA !extended_x_high,x
    LDA !extended_y_low,x
    PHA
    CLC : ADC $28
    STA !extended_y_low,x
    LDA !extended_y_high,x
    PHA
    ADC $29
    STA !extended_y_high,x
    PEA $00DA
    JSR .runInteraction
    PLA : PLA
    ROL $0E
    LDA $1693|!Base2
    STA $0D
    LDA $8A
    STA $8C
    PLA : STA !extended_y_high,x
    PLA : STA !extended_y_low,x
    PLA : STA !extended_x_high,x
    PLA : STA !extended_x_low,x
..normalLevel
    LDA $0E                         ; $0E = has extended sprite touched anything???
    CMP #$01
    RTL

.runInteraction
    LDA $0F
    INC A
    AND $5B
    BEQ .horizontalLevel

    LDA !extended_y_low,x
    CLC : ADC #$08
    STA $98
    AND #$F0                        ; process interaction, Y position
    STA $00
    LDA !extended_y_high,x
    ADC #$00
    CMP $5D
    BCS .shortReturn
    STA $03
    STA $99

    LDA !extended_x_low,x
    CLC : ADC #$0A
    STA $9A
    STA $01                         ; process interaction, X position
    LDA !extended_x_high,x
    ADC #$00
    CMP #$02
    BCS .shortReturn
    STA $9B
    STA $02

    LDA $01
    LSR #4                          ; merge Y and X high nybbles
    ORA $00                         ; format: YYYYXXXX
    STA $00

    LDX $03
    LDA.l $00BA80|!BankB,x          ; load map16 pointers based on Y pos high byte.
    LDY $0F                         ; $0F = ???
    BEQ +
        LDA.l $00BA8E|!BankB,x      ; load map16 pointers based on Y pos high byte.
+   CLC : ADC $00                   ; merge the pointers with the merged Y and X nybbles
    STA $05
    LDA.l $00BABC|!BankB,x
    LDY $0F
    BEQ +                           ; do the same as above
        LDA.l $00BACA|!BankB,x
+   ADC $02                         ; but add the pointers to X high position
    STA $06
    BRA .continueShort

.shortReturn
    CLC
    RTS

.horizontalLevel
    LDA !extended_y_low,x
    CLC : ADC #$08
    STA $98
    AND #$F0                        ; process interaction, Y position
    STA $00
    LDA !extended_y_high,x
    ADC #$00
    STA $02
    STA $99
    LDA $00
    SEC : SBC $1C
    CMP #$F0
    BCS .shortReturn

    LDA !extended_x_low,x
    CLC : ADC #$0A
    STA $9A
    STA $01                         ; process interaction, X position
    LDA !extended_x_high,x
    ADC #$00
    CMP $5D
    BCS .shortReturn
    STA $9B
    STA $03

    LDA $01
    LSR #4                          ; merge Y and X high nybbles
    ORA $00                         ; format: YYYYXXXX
    STA $00

    LDX $03
    LDA.l $00BA60|!BankB,x          ; load map16 pointers based on Y pos high byte.
    LDY $0F                         ; $0F = ???
    BEQ +
        LDA.l $00BA70|!BankB,x      ; load map16 pointers based on Y pos high byte.
+   CLC : ADC $00                   ; merge the pointers with the merged Y and X nybbles
    STA $05
    LDA.l $00BA9C|!BankB,x
    LDY $0F
    BEQ +                           ; do the same as above
        LDA.l $00BAAC|!BankB,x
+   ADC $02                         ; but add the pointers to X high position
    STA $06
.continueShort
    LDA.b #!BankA>>16
    STA $07
    LDX $15E9|!Base2
    LDA [$05]
    STA $1693|!Base2
    INC $07
    LDA [$05]
    STA $8A
    JSL $06F7A0|!BankB              ; replaced code to get extended sprites to work with MarioFireball offset
    CMP #$00
    BEQ .passable
    LDA $1693|!Base2
    CMP #$11
    BCC .waterTiles                 ; ledges
    CMP #$6E
    BCC .switchPalaceBlocks         ; solid block
    CMP #$D8
    BCS .tilesetSpecific            ; corners

    LDY $9A                         ; slopes
    STY $0A
    LDY $98
    STY $0C
    JSL $00FA19|!BankB              ; prepare check for slopes
    LDA $00
    CMP #$0C                        ; compare position+pointer
    BCS .decentPos
    CMP [$05],y                     ; check if passable on slope
    BCC .passable
.decentPos
    LDA [$05],y                     ; load slopes collision
    STA $1694|!Base2
    PHX
    LDX $08
    LDA.l $00E53D|!BankB,x
    PLX
    STA $0B                         ; interact with slopes
.switchPalaceBlocks
    SEC
    RTS

.passable
    CLC
    RTS

.waterTiles
    LDA $98
    AND #$0F
    CMP #$06
    BCS .passable
    SEC
    RTS

.tilesetSpecific
    LDA $98
    AND #$0F                        ; check if this is inside enough of a tile
    CMP #$06
    BCS .passable
    LDA !extended_y_low,x
    SEC : SBC #$02                  ; adjust Y pos and run again the routine
    STA !extended_y_low,x
    LDA !extended_y_high,x
    SBC #$00
    STA !extended_y_high,x          ; probably it's a check to see if sprite is inside of a block?
    JMP .runInteraction
