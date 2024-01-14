;==================================
; Sprite Morph Blocks v3
; By Erik557
;==================================
; Turns a sprite into another one.
; It has configurable settings.
;==================================

db $42
JMP SpriteV : JMP Ret : JMP Ret : JMP Ret : JMP SpriteH : JMP Ret : JMP Ret : JMP Ret : JMP Ret : JMP Ret

!MorphType = 0      ;Explained below

                    ;If morph type is 0:
!SpriteType = 0     ;0 = Normal; 1 = Custom
                    ;
                    ;If morph type is 1:
                    ;0 = Normal to custom; 1 = Custom to normal


!SprNum = $53       ;Sprite number
!SprMorph = $75     ;Morph Result


!Sound = $00        ;Sound effect (default: Magikoopa Magic)
!SFXBank = $1DF9    ;SFX Bank

;Don't touch these.

if !SpriteType == 1
    !SprDesc = "custom"
else
    !SprDesc = "normal"
endif

;==============================================

SpriteH:
SpriteV:
if !SpriteType == 1
    LDA !7FAB9E,x
else
    LDA !9E,x               ;\ 
endif
    CMP #!SprNum            ; | Check if the correct sprite is stteping into the block
    BNE Ret                 ;/

    LDA !14C8,x             ;\ 
    CMP #$08                ; | We don't want a dead sprite to be morphed, do we?
    BCC Ret                 ;/
    
    LDA !7FAB10,x           ;\ 
    AND #$08                ; |
if !SpriteType == 1         ; |
    BEQ Ret                 ; | Check for correct sprite type
else                        ; |
    BNE Ret                 ; |
endif                       ;/

    LDA #!SprMorph          ; Change the sprite number
if !MorphType == 1
    if !SpriteType == 0
        STA !7FAB9E,x
        JSL $07F7D2|!bank   ;\ Reset sprite tables
        JSL $0187A7|!bank   ;/
        LDA #$08
        STA !7FAB10,x
    
    else
        STA !9E,x
        JSL $07F7D2|!bank   ; Reset sprite tables
    endif
else
    if !SpriteType == 1
        STA !7FAB9E,x
        JSL $07F7D2|!bank   ;\ Reset sprite tables
        JSL $0187A7|!bank   ;/
        LDA #$08
        STA !7FAB10,x
    else
        STA !9E,x
        JSL $07F7D2|!bank   ; Reset sprite tables
    endif
endif
    LDA #$08                ;\ Set new sprite status
    STA !14C8,x             ;/
    %create_smoke()         ;\ Spawn smoke
    PHY                     ;/
    TAY                     ;\
    LDA !D8,x               ; | Move smoke to sprite's position
    STA $17C4|!addr,y       ; |
    LDA !E4,x               ; |
    STA $17C8|!addr,y       ;/
    PLY
    %sub_horz_pos()
    STA !157C,x

    LDA #!Sound             ;\ Play sound
    STA !SFXBank|!addr      ;/
    LDA #-$13
    STA !AA,x
Ret:
    RTL

print "This block will turn a !SprDesc sprite into another sprite."