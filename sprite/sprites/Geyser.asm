;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;														   ;
; EXTRA BYTE CLEAR: Rises and then falls back down                                                                 ;
; EXTRA BYTE SET: Rises and does not fall back down                                                                ;
;														   ;
; Water/Sand Geyser                    										   ;
; By DigitalSine												   ;     
; Description: 													   ;
;														   ;
; A Jet of water/sand that shoots up from the ground, lifting or holding mario at its peak. Used best with the SM2 ;
; whale. The tile below needs to be specified for what map16 tile is spawned between the sprite and the ground it  ;
; shoots from. Ive included rudimentary graphics for the sand version. However if you use that uncomment the       ;
; tilemap table and comment the line above it.                   						   ;
;														   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!JetTile = $4100  ; > Tile to generate as the water jet. /// Must be 4 digits long ///

print "INIT ",pc
        LDA !D8,x                       ; \ Sprite Y Pos Lo 
        STA !160E,x                     ; / Store to Reset at end of cycle
        RTL

print "MAIN ",pc
        PHB
        PHK
        PLB
            JSR Geyser
        PLB
        RTL

XSpeeds:
        db $01,$FF
XTargets:
        db $0D,$F3
XDisp:
        db $F8,$08 
XProps:
        db $00,$40
Tilemap:
        db $A0,$A2,$A4,$A6,$A8,$A6  ; Water Tiles
        ;db $A0,$A2,$A4,$A6,$A8,$A6 ; Sand Tiles

Geyser:
        JSR Graphics                    ; \ Always run GFX
        LDA $9D                         ; |
        BEQ .NoStop                     ; | If sprites frozen..
        RTS                             ; | ..Return
        .NoStop:                        ; |
        %SubOffScreen()                 ; / 


        LDA !1602,x                     ; \ 
        BEQ .NoGFXUpdate                ; | If not moving, dont do graphics
        LDA $14                         ; |
        AND #$08                        ; | Only every 8th frame
        BNE .NoGFXUpdate                ; | Else
        INC !1602,x                     ; | Increment frame
        LDA !1602,x                     ; |
        CMP #$06                        ; | Unless its at last frame
        BCC .NoGFXUpdate                ; |
        LDA #$02                        ; | Then restart loop
        STA !1602,x                     ; |
        .NoGFXUpdate:                   ; /

        .Rising:                        ; \
        LDA !C2,x                       ; | State Counter
        CMP #$14                        ; | State 1 over?
        BCS .RiseAndFall                ; |
        LDA #$22                        ; | Set clipping
        STA !1662,x                     ; | 
        LDA #$01                        ; | Stay at 1
        STA !1602,x                     ; | Graphics index
        INC !C2,x                       ; | Update state counter
        LDA !AA,x                       ; |
        SEC : SBC #$02                  ; | Increase speed
        STA !AA,x                       ; |
        CMP #$B0                        ; | Upper Speed threshold
        BCS .SpUp                       ; |  
        JMP .NoSpeedUpdate              ; |
        .SpUp:                          ; |
        JMP .SpeedUpdate                ; /

        .RiseAndFall:                   ; \
        %BES(.Extra)                    ; |
        LDA !C2,x                       ; |
        CMP #$18                        ; | Still in state 2?
        BCS .Falling                    ; |
        .Extra:                         ; |
        LDA !C2,x                       ; |
        AND #$01                        ; | Every other frame
        TAY                             ; | Index for speed tables
        LDA #$08                        ; | Set clipping bigger
        STA !1662,x                     ; | 
        LDA !AA,x                       ; |
        CLC                             ; |
        ADC XSpeeds,y                   ; | Add speed
        STA !AA,x                       ; |
        CMP XTargets,y                  ; | Unless at Max.. 
        BNE .NotMax                     ; |
        INC !C2,x                       ; | ..Update state counter
        .NotMax:                        ; |
        JSR SpriteTileSwitch            ; | Go get Jet tile again
        LDA !D8,x                       ; |
        AND #$F0                        ; |
        CMP #$F0                        ; | Is sprite crossing the screen boundary?
        BNE .NotBoundary                ; |
        INC $99                         ; | If so offset the tiles Hi Byte
        .NotBoundary                    ; |
        LDA $98                         ; |
        CLC : ADC #$10                  ; | Put it below the sprite too
        STA $98                         ; |
        JSR GetJetTile                  ; | Then change Map16
        JMP .SpeedUpdate                ; /

        .Falling:                       ; \
        LDA !C2,x                       ; |
        CMP #$58                        ; | In state 3?
        BCS .NoMovement                 ; |
        CMP #$54                        ; | But dont erase the last Map16 tile
        BCS .NoMap16F                   ; |
        LDA #$22                        ; | Set clipping smaller
        STA !1662,x                     ; |       
        JSR SpriteTileSwitch            ; | Last time to go swap this
        REP #$20                        ; |
        LDA #$0025                      ; | But this time make it blank
        %ChangeMap16()                  ; |
        SEP #$20                        ; |
        .NoMap16F:                      ; |
        LDA #$01                        ; | Only show tile 1 again
        STA !1602,x                     ; |
        INC !C2,x                       ; | But still update state counter
        INC !AA,x                       ; | Decrease Speed
        LDA !AA,x                       ; |
        CMP #$30                        ; | Lower speed threshold
        BCS .NoSpeedUpdate              ; |
        JMP .SpeedUpdate                ; /

        .NoMovement:                    ; \
        STZ !1602,x                     ; | Show 0 tile (Blank)
        LDA !C2,x                       ; |
        CMP #$FF                        ; | Nearly finished loop?
        BEQ .Reset                      ; |
        INC !C2,x                       ; | If not keep updating counter
        BRA Return                      ; |    
        .Reset:                         ; |
        STZ !AA,x                       ; | Else zero speed
        STZ !C2,x                       ; | Zero counter for next sprite cycle
        LDA !160E,x                     ; | Reload Init Y Pos
        STA !D8,x                       ; / Store it, to keep heights consistent 

        .SpeedUpdate:                   ; \
        JSL $01801A|!BankB              ; | Updates Speed
        .NoSpeedUpdate:                 ; | Makes sprite solid
        JSL $01B44F|!BankB              ; /

Return:
        RTS

GetJetTile:
        REP #$20                        ; \
        LDA #!JetTile                   ; | 
        %ChangeMap16()                  ; |
        SEP #$20                        ; |
        RTS                             ; /

SpriteTileSwitch:
        LDA !D8,x                       ; \ Y Lo
        STA $98                         ; |
        LDA !14D4,x                     ; | Y Hi 
        STA $99                         ; |
        LDA !E4,x                       ; | X Lo
        STA $9A                         ; | 
        LDA !14E0,x                     ; | X Hi
        STA $9B                         ; |
        STZ $1933|!Base2                ; | Layer 1
        RTS                             ; /

Graphics:
        %GetDrawInfo()                  ; \ Do stuff
        LDA !15F6,x                     ; | Sprites YXPPCCCT
        STA $03                         ; | 
        LDA !1602,x                     ; | Also keep the graphics index
        STA $04                         ; |
        LDX #$01                        ; / Do this for 2 tiles
.Loop:
        LDA $00                         ; \
        CLC                             ; |
        ADC XDisp,x                     ; |
        STA $0300|!Base2,y              ; | X Position
        LDA $01                         ; |
        STA $0301|!Base2,y              ; | Y Position
        PHX                             ; | Preserve loop counter
        LDX $04                         ; | Use graphics index
        LDA Tilemap,x                   ; | To get the animations tiles
        PLX                             ; | Restore X
        STA $0302|!Base2,y              ; | Tile
        LDA XProps,x                    ; | Mirror or No?
        ORA $03                         ; |
        ORA $64                         ; |
        AND #$EF                        ; | Priority. Allow Map16 overdraw
        STA $0303|!Base2,y              ; |
        INY #4                          ; | Next OAM Slot
        DEX                             ; | Next Tile
        BPL .Loop                       ; | 
        LDX $15E9|!Base2                ; | Restore sprite index
        LDY #$02                        ; | 16x16 sprite 
        LDA #$01                        ; | Tiles to draw
        JSL $01B7B3|!BankB              ; | Do even more stuff
        RTS                             ; /

