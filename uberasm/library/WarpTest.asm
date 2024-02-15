;=======================================================================;
; Overworld Warp Menu v1.1                                              ;
; by KevinM                                                             ;
;                                                                       ;
; Insert in gamemode 0E with UberASMTool.                               ;
; Make sure to have the ow_teleport_defines.asm and ascii.txt files in  ;
; the gamemode folder too.                                              ;
;                                                                       ;
; The ExGFX provided is GFX28 with an additional "/" tile, to be used   ;
; with the !ShowCounter option (insert it in LG1 in all submaps).       ;
;                                                                       ;
; Unless you want to modify how this code works, don't touch this file. ;
; Edit the ow_teleport_defines.asm file instead.                        ;
;=======================================================================;
; (this was heavily hacked by sajewers)


!ButtonRAM      = $18
!ButtonValue    = %00100000
!OpenSFX        = $31
!OpenSFXAddr    = $1DF9|!addr
!GroundTime     = $01
!MaxYSpeed      = $01

DestinationXPosition:
    dw $0078
DestinationYPosition:
    dw $00A8
DestinationType:
    db $02
DestinationSubmap:
    db $00


!FreeRAM        = $0F5E|!addr


!Flag           = !FreeRAM+0  ; 1 byte
!YSpeed         = !FreeRAM+1  ; 2 bytes
!GroundTimer    = !FreeRAM+3  ; 1 byte
!OptionsCounter = !FreeRAM+4  ; 1 byte
!MenuEntries    = !FreeRAM+5  ; !NumOptions+1 bytes

init:
    lda #$00
    sta !Flag
    rtl

main:
	PHB	;library calls do not actually set Data Bank
	PHK
	PLB
    lda !Flag
    asl
    tax
    jsr (.Pointers,x)
    lda !Flag
    beq .return
    stz $15             ;\
    stz $16             ;| Disable buttons.
    stz $17             ;|
    stz $18             ;/
.return
	PLB
    rtl

.Pointers:
    dw Normal
    dw Warp

Normal:
    lda $13D4|!addr
    ora $13D2|!addr
    ora $1B87|!addr
    bne .return
    lda $13D9|!addr
    beq .ok
    cmp #$03
    bne .return
.ok
    lda !ButtonRAM
    and #!ButtonValue
    beq .return
    lda #!OpenSFX
    sta !OpenSFXAddr
    lda !Flag
    inc
    sta !Flag
    jsr Warp
.return
    rts

Warp:
    stz $1DF7|!addr     ;\ Prevent vanilla from handling the warp.
    stz $1DF8|!addr     ;/


.switchmaps
    lda !MenuEntries,x
    tay
    lda DestinationSubmap,y
    sta $13C3|!addr
    ldx $0DB3|!addr
    sta $1F11|!addr,x
    txa
    asl
    tax
    lda DestinationType,y
    sta $1F13|!addr,x
    tya
    asl
    tay

    rep #$20
    ldx $0DD6|!addr
    lda DestinationXPosition,y
    and #$01FF
    sta $1F17|!addr,x
    lsr #4
    sta $1F1F|!addr,x
    lda DestinationYPosition,y
    and #$01FF
    sta $1F19|!addr,x
    lsr #4
    sta $1F21|!addr,x
    sep #$20
    stz $0DD5|!addr
    lda #$0F            ;\ Load OW gamemode.
    sta $0100|!addr     ;/
    rts
