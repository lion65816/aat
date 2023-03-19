;=============================================================================;
; Sprite A9 - Reznor                                                          ;
; Original disassembly by yoshicookiezeus                                     ;
; Defines and customization by KevinM (v1.1)                                  ;
;                                                                             ;
; For usage and other information, see the readme.                            ;
; Don't edit this file!                                                       ;
;=============================================================================;

            incsrc "ReznorDefines.asm"  ; Change this if you change the name of the other file.

;===========================================================;
; Defines for RAM addresses and routines.                   ;
;===========================================================;

            !RAM_FrameCounter   = $13
            !RAM_FrameCounterB  = $14
            !RAM_MarioDirection = $76
            !RAM_MarioSpeedX    = $7B
            !RAM_MarioSpeedY    = $7D
            !RAM_MarioXPos      = $94
            !RAM_MarioXPosHi    = $95
            !RAM_MarioYPos      = $96
            !RAM_SpritesLocked  = $9D
            !RAM_SpriteNum      = !9E
            !RAM_SpriteSpeedY   = !AA
            !RAM_SpriteSpeedX   = !B6
            !RAM_SpriteState    = !C2
            !RAM_SpriteYLo      = !D8
            !RAM_SpriteXLo      = !E4
            !RAM_SpriteYHi      = !14D4
            !RAM_SpriteXHi      = !14E0
            !RAM_DisableInter   = !154C
            !RAM_SpriteDir      = !157C
            !RAM_SprObjStatus   = !1588
            !RAM_OffscreenHorz  = !15A0
            !RAM_SprOAMIndex    = !15EA
            !RAM_SpritePal      = !15F6
            !RAM_Tweaker1662    = !1662
            !RAM_ExSpriteNum    = $170B|!Base2
            !RAM_ExSpriteYLo    = $1715|!Base2
            !RAM_ExSpriteXLo    = $171F|!Base2
            !RAM_ExSpriteYHi    = $1729|!Base2
            !RAM_ExSpriteXHi    = $1733|!Base2
            !RAM_ExSprSpeedY    = $173D|!Base2
            !RAM_ExSprSpeedX    = $1747|!Base2
            !RAM_OffscreenVert  = $186C|!Base2
            !RAM_OnYoshi        = $187A|!Base2
            !OAM_DispX          = $0300|!Base2
            !OAM_DispY          = $0301|!Base2
            !OAM_Tile           = $0302|!Base2
            !OAM_Prop           = $0303|!Base2
            !OAM_Tile2DispX     = $0304|!Base2
            !OAM_Tile2DispY     = $0305|!Base2
            !OAM_Tile2          = $0306|!Base2
            !OAM_Tile2Prop      = $0307|!Base2
            
            !HPRam              = !1504 ; Sprite table used to keep track of Reznor HP.
            !DeadRezRam         = !1510 ; Sprite table used to store which Reznors are dead.
            !CurrentDamage      = !151C ; Store the damage taken by each Reznor during this frame.
            !ReznorNumber       = !1534 ; Each Reznor stores an increasing number to differentiate them

            !HurtMario          = $00F5B7|!BankB
            !InitCustSprTables  = $0187A7|!BankB
            !CheckMarioContact  = $01A7DC|!BankB
            !GetRandom          = $01ACF9|!BankB
            !MakeSolid          = $01B44F|!BankB
            !FinishOAMWrite     = $01B7B3|!BankB
            !SearchSprSlot      = $02A9E4|!BankB
            !KillNormalSprites  = $03A6C8|!BankB
            !GetSprClippingA    = $03B69F|!BankB
            !GetSprClippingB    = $03B6E5|!BankB
            !CheckSprContact    = $03B72B|!BankB
            !ResetSprTables     = $07F7D2|!BankB

;===========================================================;
; Defines cleanup                                           ;
;===========================================================;
!true  = 1
!false = 0

if !Switch == $14AF
    !Inverted = !true
else
    !Inverted = !false
endif

!SwitchSA1 = !Switch|!Base2
!CenterXPos16 = !CenterXPosHi*256+!CenterXPosLo
!CenterYPos16 = !CenterYPosHi*256+!CenterYPosLo
!CementXPos16 = !CementXPosHi*256+!CementXPosLo
!CementYPos16 = !CementYPosHi*256+!CementYPosLo

if !MinRadius > !MaxRadius
    !MinRadius = !MaxRadius
endif

if !UpdateDelay == $00
    !UpdateDelay = $01
endif

if !EndLevelTimer < $02
    !EndLevelTimer = $02
endif

if !DoorTimer < $02
    !DoorTimer = $02
endif

if !DivideSpeedBy < $01
    !DivideSpeedBy = $01
endif

;==============================================================================;
; sprite init JSL                                                              ;
;==============================================================================;
        print "INIT ",pc          
            LDA !ReznorCounter
            STA !ReznorNumber,x
            INC A
            STA !ReznorCounter
            STA !TotReznor

            LDA #!ReznorHP              ;\ Initialize Reznor's HP
            STA !HPRam,x                ;/

            STZ !DeadRezRam,x           ; Mark Reznor as alive
            STZ !CurrentDamage,x
            STZ !EndTimerRam
            STZ $13C6|!Base2            ; Fix bug when dying after winning with old retry patch.

        if !MinRadius != !MaxRadius
            STZ !FreeRam2
            LDA #!MinRadius             ;\ Store the initial radius value
            STA !RadiusRam              ;/
            LDA #!UpdateDelay           ;\ Initialize the radius update timer
            STA !RadiusTimer            ;/
        endif

        if !DivideSpeedBy != $01
            STZ !FreeRam
        endif

            LDA !ReznorNumber,x
            BNE +
            LDA #$04
            STA !RAM_SpriteState,x

        if !Mode7 == !true
            JSL $03DD7D|!BankB
        endif

        if !FireballRNG == !true
        +   JSL !GetRandom              ;\ set ??? to random number
        else                            ;|
        +   LDA #$00                    ;| (0 if the flag is clear).
        endif                           ;|
            STA !1570,x                 ;/
ReturnInit:
            RTL


;==============================================================================;
; Sprite main wrapper                                                          ;
;==============================================================================;
        print "MAIN ",pc
            PHB
            PHK
            PLB
            JSR ReznorMain
            PLB
            RTL


;=======================================================================;
; These values define the angles used to place the Reznors in a circle. ;
; The correct row will be chosen using the formula: n*(n-1)/2, where n  ;
; is the amount of Reznors loaded in the level.                         ;
;=======================================================================;
ReznorStartPosLo:
        db $80
        db $80,$80
        db $AA,$55,$00
        db $00,$80,$00,$80
        db $34,$9A,$CC,$66,$00
        db $56,$AB,$00,$AA,$55,$00
        db $25,$6E,$B7,$DB,$92,$49,$00
        db $C0,$80,$40,$00,$C0,$80,$40,$00

ReznorStartPosHi:
        db $01
        db $00,$01
        db $01,$00,$01
        db $00,$00,$01,$01
        db $00,$00,$01,$01,$01
        db $00,$00,$00,$01,$01,$01
        db $00,$00,$00,$01,$01,$01,$01
        db $00,$00,$00,$00,$01,$01,$01,$01

ReboundSpeedX:
        db !ReboundSpeedX

;==============================================================================;
; Sprite main code                                                             ;
;==============================================================================;
ReznorMain:
            INC $140F|!Base2        ; increase some sort of timer
            LDA !RAM_SpritesLocked  ;\ if sprites not locked,
            BEQ ReznorNotLocked     ;/ branch
            JMP DrawReznor

ReznorNotLocked:
            LDA !ReznorNumber,x
            BNE ReznorNoLevelEnd2

        if !BreakBridge == !true
            LDA !ReznorCounter
            CMP #!WhenCountLowerThan
            BCS +
            LDA #$04
            STA !151C+4
        +   JSL $03D70C|!BankB
        endif

ReznorSignCode:
        if !Mode7 == !true
            PHX
            LDA #$80                ;\ set center of rotation for Reznor sign
            STA $2A                 ;|
            STZ $2B                 ;/
            LDX #$00
            LDA #!CenterXPosLo      ;\ set x position of Reznor sign
            STA !RAM_SpriteXLo      ;|
            STZ !RAM_SpriteXHi      ;/
            LDA #!CenterYPosLo+$42  ;\ set y position of Reznor sign
            STA !RAM_SpriteYLo      ;|
            STZ !RAM_SpriteYHi      ;/
            LDA #$2C                ;\ mode 7 related?
            STA $1BA2|!Base2        ;/
            JSL $03DEDF|!BankB      ; apply sign position changes
            PLX
        endif
            
    if !StopWithSwitch == !true     ;\ If flag is set, check for the switch to be active
            LDA !SwitchSA1          ;| (or inactive) and don't rotate the sign if true.
        if !Reversed^!Inverted      ;|
            BNE Continue            ;|
        else                        ;|
            BEQ Continue            ;|
        endif                       ;|
    endif                           ;/

        if !DivideSpeedBy != $01    ;\ If flag is set, rotate the sign every other frame
            LDA !FreeRam            ;| by checking if !FreeRam is 0 or 1.
            BNE .skip               ;|
            INC !FreeRam            ;|
        endif                       ;/

            REP #$20                ; set 16-bit accumulator mode
            LDA $36                 ;\ rotate sign
            CLC                     ;|
            ADC #!SpeedMultiplier   ;/
            AND #$01FF              ;
            STA $36                 ;
            SEP #$20                ; set 8-bit accumulator mode

    if !DivideSpeedBy != $01
            BRA Continue
        .skip
            INC !FreeRam
            CMP #!DivideSpeedBy-1
            BNE +
            STZ !FreeRam
        +
    endif
            BRA Continue

ReznorNoLevelEnd2:
            BRA ReznorNoLevelEnd

Continue:            
            LDA !EndTimerRam        ;\ if level end timer not set,
            BEQ ReznorNoLevelEnd    ;/ branch
            DEC !EndTimerRam        ;\ if not time to end level,
            BNE ReznorNoLevelEnd    ;/ branch

            LDA !extra_bits,x       ;\ If the extra bit is not set...
            AND #$04                ;|
            BEQ EndLevel            ;/ ...make the level end.

MakeDoorMagicallyAppear:            ; Otherwise, make the door appear.
            LDA #$10                ;\ Play a sound effect for the door spawning.
            STA $1DF9|!Base2        ;/
            PHP                     ;|
            REP #$30                ;|
            LDA #!CementYPos16      ;\ Draw the cement tile.
            STA $98                 ;|
            LDA #!CementXPos16      ;|
            STA $9A                 ;|
            LDA #!CementTile        ;|
            %ChangeMap16()          ;/
            LDA #!CementYPos16      ;\ Draw the lower door tile.
            SEC : SBC #$0010        ;| (1 tile higher than the cement block)
            STA $98                 ;|
            LDA #!CementXPos16      ;|
            STA $9A                 ;|
            LDA #!DoorLowerTile     ;|
            %ChangeMap16()          ;/
            LDA #!CementYPos16      ;\ Draw the upper door tile.
            SEC : SBC #$0020        ;| (2 tiles higher than the cement block)
            STA $98                 ;|
            LDA #!CementXPos16      ;|
            STA $9A                 ;|
            LDA #!DoorUpperTile     ;|
            %ChangeMap16()          ;|
            PLP                     ;/
            RTS
EndLevel:
            DEC $13C6|!Base2        ; Make Mario freeze at level end.
            LDA #$FF                ;\ Set time before return to overworld
            STA $1493|!Base2        ;/
            LDA #!BossClearMusic    ;\ Play the "Boss clear" fanfare
            STA $1DFB|!Base2        ;/
            LDA #$FF                ;\ Fix music not restarting if dying after winning with old retry patch.
            STA $0DDA|!Base2        ;/
            RTS                     ; return

ReznorNoLevelEnd:
            LDA !14C8,x                 ;\ If sprite state is normal,
            CMP #$08                    ;|
            BEQ MainCode                ;/ branch to sprite main code
            JMP DrawReznor

MainCode:
    if !MinRadius != !MaxRadius         ; Changing circle radius code
        if !StopWithSwitch == !true     ;\ If flag is set, check for the switch
                LDA !SwitchSA1          ;| to be active (or inactive) and don't
            if !Reversed^!Inverted      ;| change the radius if true
                BNE GoOn                ;|
            else                        ;|
                BEQ GoOn                ;|
            endif                       ;|
        endif                           ;/

            LDA !RadiusTimer            ;\ If the update timer expired...
            BEQ UpdateRadius            ;| ...update the radius...
            DEC !RadiusTimer            ;| ...else decrease the timer...
            BRA GoOn                    ;/ ...and do nothing else
        UpdateRadius:
            LDA #!UpdateDelay           ;\ Reset the timer
            STA !RadiusTimer            ;/
            LDA !FreeRam2               ;\ See if you're increasing or decreasing...
            BEQ .increaseRadius         ;/
        .decreaseRadius
            DEC !RadiusRam              ; Decrease the radius by 1
            LDA !RadiusRam              ;\ If it reached the minimum...
            CMP #!MinRadius             ;|
            BNE GoOn                    ;|
            STZ !FreeRam2               ;/ ...next time we're increasing it.
        .increaseRadius
            INC !RadiusRam              ; Increase the radius by 1
            LDA !RadiusRam              ;\ If it reached the maximum...
            CMP #!MaxRadius             ;|
            BNE GoOn                    ;|
            INC !FreeRam2               ;/ ...next time we're decreasing it.
        GoOn:
    endif

Rotation:
            PHY
            LDA #$00                    ;\ Compute !TotReznor * (!TotReznor-1)
            LDY !TotReznor              ;|
        -   DEY                         ;|
            BEQ +                       ;|
            CLC : ADC !TotReznor        ;|
            BRA -                       ;/
        +   LSR                         ; Divide the result by 2.
            CLC : ADC !ReznorNumber,x   ; Choose the correct value from the correct row.
            TAY                         ; Transfer the value to Y.

            LDA $36                 ;\ Set up parameters for circle routines.
            CLC                     ;|
            ADC ReznorStartPosLo,y  ;|
            STA $04                 ;|
            LDA $37                 ;|
            ADC ReznorStartPosHi,y  ;|
            AND #$01                ;|
            STA $05                 ;|
        if !MinRadius == !MaxRadius ;|\ If the radius is constant...
            LDA #!MinRadius         ;|| ...just use the hardcoded value...
        else                        ;||
            LDA !RadiusRam          ;|| ...else, use the runtime value.
        endif                       ;|/
            STA $06                 ;/

        if !Mode7 == !true && !SA1 == 0
            %CircleXY()
        else
            %CircleX()              ;\ Get X and Y offset given angle and radius.
            %CircleY()              ;/
        endif
        
            PLY
            LDX $15E9|!Base2        ; get sprite index

            PHP                     ;\ Sum center positions with offsets.
            REP #$20                ;|
            LDA #!CenterXPos16      ;|
            CLC : ADC $07           ;|
        if !DoubleRadius == !true   ;|
            CLC : ADC $07           ;|
        endif                       ;|
            STA $00                 ;|
            LDA #!CenterYPos16      ;|
            CLC : ADC $09           ;|
        if !DoubleRadius == !true   ;|
            CLC : ADC $09           ;|
        endif                       ;|
            STA $02                 ;|
            PLP                     ;/

            LDA !RAM_SpriteXLo,x    ;\ Prevent Mario from sliding on the platform.
            SEC : SBC $00           ;|
            EOR #$FF                ;|
            INC A                   ;|
            STA !1528,x             ;/

            LDA $00                 ;\ Set new positions for the sprite.
            STA !RAM_SpriteXLo,x    ;|
            LDA $01                 ;|
            STA !RAM_SpriteXHi,x    ;|
            LDA $02                 ;|
            STA !RAM_SpriteYLo,x    ;|
            LDA $03                 ;|
            STA !RAM_SpriteYHi,x    ;/

            LDA !DeadRezRam,x           ;\ if Reznor is alive,
            BEQ ReznorAlive             ;/ branch
        if !AlsoKillPlatforms == !false ;\ else, if flag is not set...
            JSL !MakeSolid              ;| ...make the platform solid.
        endif                           ;/
            JMP DrawReznor

ReznorAlive:

if !SpriteDamage != $00
    CheckKickedSprite:
            PHY                     ; Store Y
            LDY #!SprSize-1         ; Initialize loop index.
    .loop                           ; Loop through every sprite
            LDA !14C8,y             ;\ If the sprite's status is "kicked"...
            CMP #$0A                ;|
            BEQ .checkContact       ;/ ...check for contact.
            CMP #$09                ;\ If the sprite's status is "stationary/carryable"...
            BEQ .checkContact       ;/ ...check for contact.
    .nextIteration
            DEY                     ;\ Go to the next sprite.
            BPL .loop               ;/
    .loopEnd
            PLY                     ; Restore Y.
            BRA .continue           ; Go on.
    .checkContact
            PHX
            TYX
            JSL !GetSprClippingB    ; Get sprite clipping B routine
            PLX
            JSL !GetSprClippingA    ; Get sprite clipping A routine
            JSL !CheckSprContact    ; Check for contact routine.
            BCC .nextIteration
    .contactFound
            LDA #$00                ;\ Destroy the other sprite.
            STA !14C8,y             ;/
            LDA #!SpriteDamage      ;\ Store the current damage.
            STA !CurrentDamage,x    ;/
            LDA #$0F                ;\ Set timer to damage Reznor.
            STA !1564,x             ;/
            BRA .loopEnd            ; We assume only one contact per frame.
    .continue
endif

            LDA !15AC,x             ;\ if turning,
            BNE NoSetRznrFireTime   ;/ branch

            INC !1570,x             ; increase firing timer
            LDA !1570,x             ;\ if not time to spit fire,
            CMP #!FireballDelay     ;|
            BNE NoSetRznrFireTime   ;/ branch
            STZ !1570,x             ;\ set time to show firing frame
            LDA #!ShootingAnimation ;|
            STA !1558,x             ;/

NoSetRznrFireTime:
            TXA                     ;\ if not time to turn
            ASL #4                  ;|
            ADC !RAM_FrameCounterB  ;|
            AND #$3F                ;|
            ORA !1558,x             ;| or if firing
            ORA !15AC,x             ;| or if already turning
            BNE NoSetRenrTurnTime   ;/ branch

            LDA !RAM_SpriteDir,x    ;\ make sprite face Mario
            PHA                     ;|
            %SubHorzPos()           ;|
            TYA                     ;|
            STA !RAM_SpriteDir,x    ;/
            PLA                     ;\ if sprite didn't turn,
            CMP !RAM_SpriteDir,x    ;|
            BEQ NoSetRenrTurnTime   ;/ branch
            LDA #$0A                ;\ set time to show turning frame
            STA !15AC,x             ;/

NoSetRenrTurnTime:
            LDA !RAM_DisableInter,x     ;\ if interaction disabled,
            BNE DrawReznor              ;/ branch
            JSL !CheckMarioContact      ; interact with Mario
            BCC DrawReznor              ; if no contact, branch

            LDA #$08                    ;\ disable interaction for a short while
            STA !RAM_DisableInter,x     ;/
            LDA !RAM_MarioYPos          ;\ if Mario hit Reznor,
            SEC                         ; |
            SBC !RAM_SpriteYLo,x        ; |
            CMP #$ED                    ; |
            BMI HitReznor               ;/ branch

            CMP #$F2                    ;\ if Mario hit side of Reznor platform,
            BMI HitPlatSide             ;/ branch
            LDA !RAM_MarioSpeedY        ;\ if Mario is moving downwards,
            BPL HitPlatSide             ;/ branch

HitPlatBottom:
            LDA #$29                    ;\ set new sprite clipping size
            STA !RAM_Tweaker1662,x      ;/
            LDA #$0F                    ;\ set platform bouncing timer
            STA !1564,x                 ;/
            LDA #!ReboundSpeedY         ;\ set new Mario y speed
            STA !RAM_MarioSpeedY        ;/
            LDA #$01                    ;\ play sound effect
            STA $1DF9|!Base2            ;/
            LDA #!MarioDamage           ;\ Store the damage that Reznor will take.
            STA !CurrentDamage,x        ;/
            BRA DrawReznor

HitPlatSide:
            %SubHorzPos()
            LDA ReboundSpeedX,y     ;\ set new Mario x speed
            STA !RAM_MarioSpeedX    ;/
            BRA DrawReznor

AnotherReturn:
            RTS

HitReznor:
            JSL !HurtMario          ; Hurt Mario

DrawReznor:
            STZ !1602,x             ; set normal frame
            LDA !RAM_SpriteDir,x    ;\ preserve sprite direction
            PHA                     ;/
            LDY !15AC,x             ;\ if Reznor isn't turning,
            BEQ ReznorNoTurning     ;/ branch
            CPY #$05                ;\ if time to turn,
            BCC ReznorTurning       ;/ branch
            EOR #$01                ;\ reverse sprite direction
            STA !RAM_SpriteDir,x    ;/

ReznorTurning:
            LDA #$02            ;\ set turning frame
            STA !1602,x         ;/

ReznorNoTurning:
    if !ShootFireballs == !true
            LDA !1558,x         ;\ if Reznor isn't firing,
            BEQ ReznorNoFiring  ;/ branch
            CMP #$20            ;\ if not time to shoot fireball,
            BNE ReznorFiring    ;/ branch
            JSR ReznorFireRt

ReznorFiring:
            LDA #$01            ;\ set firing frame
            STA !1602,x         ;/
    endif

ReznorNoFiring:
            JSR ReznorGfxRt
            PLA                         ;\ restore sprite direction
            STA !RAM_SpriteDir,x        ;/
            LDA !RAM_SpritesLocked      ;\ if sprites locked
            ORA !DeadRezRam,x           ;| or if Reznor killed,
            BNE AnotherReturn           ;/ branch
            LDA !1564,x                 ;\ if not time to kill Reznor,
            CMP #$0C                    ;|
            BNE AnotherReturn           ;/ branch

KillReznor:
            LDA !CurrentDamage,x        ; Get the current damage
            CMP !HPRam,x                ; Compare it with Reznor's HP
            BCC ._ApplyDamage           ; If Damage < HP, Reznor remains alive.

.actuallyKillReznor:
            STZ !CurrentDamage,x
            STZ !HPRam,x                ; Set the HP to 0
            LDA #$03                    ;\ play sound effect
            STA $1DF9|!Base2            ;/
            STZ !1558,x                 ; Clear firing timer
            INC !DeadRezRam,x           ; Mark Reznor as dead
            DEC !ReznorCounter          ; Decrease the count of alive Reznors

.CheckEndLevel:
            BNE AnotherLabel
            LDA !extra_bits,x
            AND #$04
            BEQ .SetEndLevelTimer
.SetDoorTimer
            LDA #!DoorTimer
            BRA +

._ApplyDamage
            BRA ApplyDamage

.SetEndLevelTimer
            LDA #!EndLevelTimer
        +   STA !EndTimerRam            ; Set level end/door timer.
            JSL !KillNormalSprites      ; Kill normal sprites
            PHY
            LDY #$07                    ;\ Clear extended sprite tables
        -   LDA #$00                    ;|
            STA !RAM_ExSpriteNum,y      ;|
            DEY                         ;|
            BPL -                       ;/
            PLY

AnotherLabel:
        if !AlsoKillPlatforms == !true
            LDA #$F8                    ;\ Spawn smoke where the platform was.
            STA $00                     ;|
            STZ $01                     ;|
            LDA #$15                    ;|
            STA $02                     ;|
            LDA #$01                    ;|
            %SpawnSmoke()               ;/
        endif

        if !QuickKill == !true
        if !AlsoKillPlatforms != !true  ;\ If !AlsoKillPlatform is !true, $00 and $02
            LDA #$F8                    ;| already have the correct values.
            STA $00                     ;|
            LDA #$15                    ;|
            STA $02                     ;|
        endif                           ;/
            LDA #$E8                    ;\ Spawn smoke where the Reznor was.
            STA $01                     ;|
            LDA #$01                    ;|
            %SpawnSmoke()               ;/
        else                            ; Spawn dead Reznor only if flag is clear
            JSL !SearchSprSlot          ; find free sprite slot for dead Reznor
            BMI .Return                 ; if no free slots, branch

            LDA #$02                    ;\ set sprite status of new sprite (killed)
            STA !14C8,y                 ;/
            LDA !new_sprite_num,x       ;\ set sprite number of new sprite (Reznor)
            PHX                         ;|
            TYX                         ;|
            STA !new_sprite_num,x       ;|
            PLX                         ;/
            LDA !RAM_SpriteXLo,x        ;\ set x position of new sprite
            STA !E4,y                   ;|
            LDA !RAM_SpriteXHi,x        ;|
            STA !RAM_SpriteXHi,y        ;/
            LDA !RAM_SpriteYLo,x        ;\ set y position of new sprite
            STA !D8,y                   ;|
            LDA !RAM_SpriteYHi,x        ;|
            STA !RAM_SpriteYHi,y        ;/

            PHX                         ; preserve sprite index
            TYX                         ;\ clear out sprite tables for new sprite
            JSL !ResetSprTables         ;/
            JSL !InitCustSprTables      ; Get table values for custom sprite
            LDA #$88                    ;\ mark sprite as initialized
            STA !extra_bits,x           ;/
            LDA #$C0                    ;\ set y speed for new sprite
            STA !RAM_SpriteSpeedY,x     ;/
            LDA #$FF
            STA !ReznorNumber,x
            PLX                         ; retrieve sprite index
        endif

.Return
            RTS

ApplyDamage:
            LDA !HPRam,x                ;\ HP <-- HP - Damage
            SEC : SBC !CurrentDamage,x  ;|
            STA !HPRam,x                ;/
            STZ !CurrentDamage,x
            LDA #$28                    ;\ Play the "stunned" sound effect.
            STA $1DFC|!Base2            ;/
            RTS                         ; Return

    if !ShootFireballs == !true         ; Keep this code only if fireballs are needed
ReznorFireRt:
            LDY #$07                    ;\ find free slot for extended sprite
        -   LDA !RAM_ExSpriteNum,y      ;|
            BEQ FoundRznrFireSlot       ;|
            DEY                         ;|
            BPL -                       ;/
            RTS                         ; if no free slots, return

FoundRznrFireSlot:
            LDA #$10                    ;\ play sound effect
            STA $1DF9|!Base2            ;/
            LDA #$02                    ;\ set sprite number of new extended sprite
            STA !RAM_ExSpriteNum,y      ;/
            
            LDA !RAM_SpriteXLo,x        ;\ Set x position of new extended sprite
            SEC : SBC #$08              ;|
            STA !RAM_ExSpriteXLo,y      ;|
            STA $00                     ;|
            LDA !RAM_SpriteXHi,x        ;|
            SBC #$00                    ;|
            STA !RAM_ExSpriteXHi,y      ;|
            STA $01                     ;/

            LDA !RAM_SpriteYLo,x        ;\ set y position of new extended sprite
            SEC : SBC #$14              ;|
            STA !RAM_ExSpriteYLo,y      ;|
            STA $02                     ;|
            LDA !RAM_SpriteYHi,x        ;|
            SBC #$00                    ;|
            STA !RAM_ExSpriteYHi,y      ;|
            STA $03                     ;/
            
            REP #$20                    ;\ Setup parameters for the aiming routine.
            LDA $00                     ;|
            SEC : SBC !RAM_MarioXPos    ;|
            STA $00                     ;|
            LDA $02                     ;|
            SEC : SBC !RAM_MarioYPos    ;|
            SBC #$0010                  ;| (aim at Mario's butt)
            STA $02                     ;|
            SEP #$20                    ;|
            LDA #!FireballSpeed         ;/

            %Aiming()

            LDA $00                     ;\ set new extended sprite x speed
            STA !RAM_ExSprSpeedX,y      ;/
            LDA $02                     ;\ set new extended sprite y speed
            STA !RAM_ExSprSpeedY,y      ;/
    endif
Return666:
            RTS             ; return

ReznorTileDispX:
            db $00,$F0,$00,$F0,$F0,$00,$F0,$00
ReznorTileDispY:
            db $E0,$E0,$F0,$F0

ReznorTiles:
            db $40,$42,$60,$62,$44,$46,$64,$66
            db $28,$28,$48,$48

ReznorPal:
            db $3F,$3F,$3F,$3F,$3F,$3F,$3F,$3F
            db $7F,$3F,$7F,$3F

ReznorGfxRt:
            LDA !DeadRezRam,x       ;\ if Reznor is dead,
        if !AlsoKillPlatforms == !false
            BNE DrawReznorPlats     ;/ branch
        else
            BNE Return666
        endif
            %GetDrawInfo()
            LDA !1602,x             ;\ $03 = frame index
            ASL #2                  ;|
            STA $03                 ;/
            LDA !RAM_SpriteDir,x    ;\ $02 = direction index
            ASL #2                  ;|
            STA $02                 ;/

            PHX                     ; preserve sprite index
            LDX #$03                ; set number of tiles to draw

RznrGfxLoopStart:
            PHX                     ; preserve tile index
            LDA $03                 ;\ if frame index is 8 (turning?),
            CMP #$08                ;|
            BCS +                   ;/ branch
            TXA                     ;\ add in direction index
            ORA $02                 ;|
            TAX                     ;/

        +   LDA $00                 ;\ set tile x position
            CLC                     ;|
            ADC ReznorTileDispX,x   ;|
            STA !OAM_DispX,y        ;/

            PLX                     ; retrieve tile index
            LDA $01                 ;\ set tile y position
            CLC                     ;|
            ADC ReznorTileDispY,x   ;|
            STA !OAM_DispY,y        ;/

            PHX                     ; preserve tile index
            TXA                     ;\ add in direction index
            ORA $03                 ;|
            TAX                     ;/
            LDA ReznorTiles,x       ;\ set tile number
            STA !OAM_Tile,y         ;/
            LDA ReznorPal,x         ;\ set tile properties
            CPX #$08                ;| if turning,
            BCS NoReznorGfxFlip     ;| branch
            LDX $02                 ;| if direction = 0,
            BNE NoReznorGfxFlip     ;| branch
            EOR #$40                ;| flip tile horizontally

NoReznorGfxFlip:
            STA !OAM_Prop,y         ;/

            PLX                     ; retrieve tile index
            INY #4                  ; Increase OAM index by four
            DEX                     ;\ if frames left to draw,
            BPL RznrGfxLoopStart    ;/ branch

            PLX                     ; retrieve sprite number

            LDY #$02                ; the tiles written were 16x16
            LDA #$03                ; we wrote four tiles
            JSL !FinishOAMWrite     ; finish OAM write

            LDA !14C8,x             ;\ if Reznor dead and falling from platform,
            CMP #$02                ;|
            BEQ Return039BE2        ;/ branch

DrawReznorPlats:
            LDA !RAM_SprOAMIndex,x      ;\ get new sprite OAM index
            CLC                         ;|
            ADC #$10                    ;|
            STA !RAM_SprOAMIndex,x      ;/
            %GetDrawInfo()

            LDA !1564,x                 ;\ $02 = platform y offset from bouncing
            LSR                         ;|
            PHY                         ;|
            TAY                         ;|
            LDA ReznorPlatDispY,y       ;|
            STA $02                     ;|
            PLY                         ;/

            LDA $00                     ;\ set tiles x position
            STA !OAM_Tile2DispX,y       ;|
            SEC : SBC #$10              ;|
            STA !OAM_DispX,y            ;/
            LDA $01                     ;\ set tiles y position
            SEC : SBC $02               ;|
            STA !OAM_DispY,y            ;|
            STA !OAM_Tile2DispY,y       ;/
            LDA #$4E                    ;\ set tiles number
            STA !OAM_Tile,y             ;|
            STA !OAM_Tile2,y            ;/
            LDA #$33                    ;\ set tiles properties
            STA !OAM_Prop,y             ;|
            ORA #$40                    ;| right tile should be flipped
            STA !OAM_Tile2Prop,y        ;/

            LDY #$02                    ; the tiles written were 16x16
            LDA #$01                    ; we wrote two tiles
            JSL !FinishOAMWrite         ; finish OAM write

Return039BE2:
            RTS

ReznorPlatDispY:
            db $00,$03,$04,$05,$05,$04,$03,$00
