!Speed = $02                ; How many pixels to move per frame.
!YInteractSmOrDu = $20      ; How many pixels to interact with small or ducking Mario, vertically.
!YInteractSmNorDu = $30     ; How many pixels to interact with powerup Mario (not ducking), vertically.

; Properties table, per sprite. YXPPCCCT.
Properties:
    db $05,$05

; Sprite tiles, per sprite.
Tiles:
    db $42,$44

; Speed table, per sprite. Amount of pixels to move down each frame. 00 = still, 80-FF = rise, 01-7F = sink.
SpeedTable1:
    db $FD,$03

OAMStuff:
    db $40,$44

print "MAIN ",pc
Main:
    LDA $14
    LSR #2
    AND #$01
    BEQ .animate
    LDA #$00
    BRA .store

.animate
    LDA #$01
.store
    STA $01

SkipIntro:
    LDA $9D                         ; \ Don't move if sprites are frozen.
    BNE Immobile                    ; /

    LDA !cluster_x_low,y            ; \ 
    CLC : ADC SpeedTable1,y         ;  | Movement.
    STA !cluster_x_low,y            ; /

    LDA $94                         ; \ Sprite <-> Mario collision routine starts here.
    SEC                             ;  | X collision = #$18 pixels. (#$0C left, #$0C right.)
    SBC !cluster_x_low,y            ;  |
    CLC : ADC #$0C                  ;  |
    CMP #$18                        ;  |
    BCS Immobile                    ; /
    LDA #!YInteractSmOrDu           ; Y collision routine starting here.
    LDX $73
    BNE StoreToNill
    LDX $19
    BEQ StoreToNill
    LDA #!YInteractSmNorDu
StoreToNill:
    STA $00
    LDA $96
    SEC : SBC !cluster_y_low,y
    CLC : ADC #$20
    CMP $00
    BCS Immobile
    JSL $00F5B7|!BankB              ; Hurt Mario if sprite is interacting.
Immobile:                           ; Graphics routine starts here.
    LDX.w OAMStuff,y                ; Get OAM index.
    LDA !cluster_y_low,y            ; \ Copy Y position relative to screen Y to OAM Y.
    SEC : SBC $1C                   ;  |
    STA $0201|!Base2,x              ; /
    LDA !cluster_x_low,y            ; \ Copy X position relative to screen X to OAM X.
    SEC : SBC $1A                   ;  |
    STA $0200|!Base2,x              ; /
    PHX
    LDA Tiles,y
    CLC : ADC $01
    STA Tiles,y
    PLX
    LDA Tiles,y                     ; \ Tile
    STA $0202|!Base2,x
    LDA Properties,y                ; \ Properties per bolt.
    STA $0203|!Base2,x              ; /
    PHX
    TXA
    LSR #2
    TAX
    LDA #$02
    STA $0420|!Base2,x
    PLX

    LDA $0200|!Base2,x
    CMP #$F0
    BCC .return
    LDA #$00
    STA !cluster_num,y
.return
    RTL
