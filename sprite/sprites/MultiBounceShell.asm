
; Multi bounce shell 
; by NaroGugul
;
; + extra byte stuff and 5-9 bounces option by KevinM

; Number of bounces from 1 to 9 or infinite;
; Will destroy itself after the last bounce;
; If extra bit is set it will spawn in kicked state going towards the player direction;
; Uses custom exgfx tile for the 5-9 and "infinite" symbols (just a slightly modified GFX20.bin file. SP4 of Banzai Bill tileset).
; Use in SP4. Should be renamed before inserting. Remap it to fit your needs.

; Extra Byte 1: determines the number of bounces.
;   $0A+ = infinite bounces, $09-$02 = $09-$02 bounces, $00-$01 = 1 bounce.
;
; Extra Byte 2: X speed to spawn the kicked shell with (normal speed is $30).
;   Only used with the extra bit set.

;========================================================================================================================================================================================================================
;=== DEFINES ============================================================================================================================================================================================================
;========================================================================================================================================================================================================================

; 1,2,3,4,5,6,7,8,9,infinite ... 2nd page by default
NumberTiles:
    db $B6,$B5,$B4,$B3,$A7,$A6,$A5,$A4,$A3,$B7

; Normal shell tiles ... 1st page by default
ShellTiles:
    db $8C,$8A,$8E,$8A

; $40 = flip x, $00 = do not flip x
ShellTilesFlip:
    db $00,$40,$00,$00

; SFX when it poofs after the last bounce.
!PoofSFX     = $08
!PoofSFXAddr = $1DF9|!addr

; SFX when it spawns kicked.
!KickSFX     = $03
!KickSFXAddr = $1DF9|!addr

;========================================================================================================================================================================================================================
;=== INIT/MAIN ==========================================================================================================================================================================================================
;========================================================================================================================================================================================================================

print "INIT ",pc
    LDA #$09
    STA !14C8,x
    lda !extra_byte_1,x
    BEQ +++
    CMP #$01
    BCS ++
    LDA #$04
    STA !9E,x
    RTL
++  
    lda !extra_byte_1,x
    CMP #$0A
    BCC +
    LDA #$0A
+ 
    DEC A
+++
    STA !1504,x
    
    
    LDA #$01
    STA !1510,x

    LDA !7FAB10,x
    AND #$04        ; extra bit set
    BEQ ++++
    
    LDA #$02
    STA !1510,x
    
++++
RTL




print "MAIN ",pc
    PHB : PHK : PLB
    JSR MainCode
    PLB
RTL

    

MainCode:
    JSR GRAPHICS
    LDA $9D
    BNE Return
    %SubOffScreen()

    JSR BEHAVIOR
    JSR ANIMATION

    Return:
RTS


;========================================================================================================================================================================================================================
;=== BEHAVIOR ===========================================================================================================================================================================================================
;========================================================================================================================================================================================================================

BEHAVIOR:
    ;.INYOSHISTONGUE
        LDA !15D0,x
        BEQ +
        LDA #$01
        STA !1510,x
    +
    ;.EXTRABITSET:
        LDA !1510,x
        CMP #$02
        BNE +++
        DEC !1510,x
        
        %SubHorzPos()
        lda !extra_byte_2,x
        cpy #$00 : beq +
        eor #$FF : inc
+       sta !B6,x
        
        LDA #$0A
        STA !14C8,x
        LDA #!KickSFX           ; Sound effect.
        STA !KickSFXAddr                 
        +++
    
    ;.STUFF
        LDA !14C8,x
        CMP #$0A
        BNE +
        STZ !1510,x 
        +
        CMP #$09
        BNE .RTS_BEHAVIOR
        
        LDA !1510,x
        BNE .RTS_BEHAVIOR
        
        LDA !1504,x
        CMP #$09
        BEQ ++
        CMP #$00
        BEQ .DESTROY
            DEC !1504,x
        ++
            LDA #$0A
            STA !14C8,x

    .RTS_BEHAVIOR:
RTS

    .DESTROY
        LDA #$04                
        STA !14C8,x             
        LDA #$1F
        STA !1540,x
        JSL $07FC3B|!BankB
        LDA #!PoofSFX
        STA !PoofSFXAddr
RTS
;========================================================================================================================================================================================================================
;=== ANIMATION ===========================================================================================================================================================================================================
;========================================================================================================================================================================================================================

ANIMATION:
        LDA !14C8,x
        CMP #$0A
        BNE +
        LDA $14                 ; Every X frames...
        AND #$03                
        BNE .RTS_ANIMATION
        LDA !1570,x
        CMP #$03
        BEQ +
        INC !1570,x
        BRA .RTS_ANIMATION
    +
        STZ !1570,x
    .RTS_ANIMATION:
RTS

;========================================================================================================================================================================================================================
;=== GRAPHICS ===========================================================================================================================================================================================================
;========================================================================================================================================================================================================================

GRAPHICS:
    %GetDrawInfo()
        LDA !15F6,x
        STA $0F

        TYA
        STA $0A 
        LSR #2
        STA $0B
    
;   .NUMBERTILE:    
        LDY $0A
        
        LDA $00
        STA $0300|!Base2,y      ; X position

        LDA $01
        STA $0301|!Base2,y      ; Y position
        
        LDA !1504,x
        TAX
        
        LDA NumberTiles,x
        STA $0302|!Base2,y      ; Tile number
        LDA $0F                 ; $15F6,x
        ORA #$01                ; 2nd gfx page.. comment this line out for 1st page
        ORA $64
        STA $0303|!Base2,y      ; Properties
        
        INY #4                  ; Increment Y 4 times
        STY $0A
        
        LDY $0B
        LDA #$00                ; #$02 = 16x16 tile. #$00 = 8x8 tile.
        STA $0460|!Base2,y      ; OAM (Tile size)
            
        INY
        STY $0B

        
;   .SHELLTILE:
        LDY $0A
        
        LDA $00
        STA $0300|!Base2,y      ; X position

        LDA $01
        STA $0301|!Base2,y      ; Y position
        
        LDX $15E9|!Base2
        LDA !1570,x
        TAX
        LDA ShellTiles,x
        STA $0302|!Base2,y      ; Tile number
        LDA $0F                 ; $15F6,x
        ORA ShellTilesFlip,x
        ORA $64
        STA $0303|!Base2,y      ; Properties

        LDY $0B
        LDA #$02                ; $02 = 16x16 tile. $00 = 8x8 tile.
        STA $0460|!Base2,y      ; OAM (Tile size)
        
;   .FINISH 
        LDA #$01                ; n of tiles to draw - 1
        LDX $15E9|!Base2
        LDY #$FF    
        JSL $01B7B3|!BankB

    .RTS_GRAPHICS:
RTS
