;SimpleHP
;Lord Ruby

;A simple HP system, providing a framework for level code to make use of.
;Depends on SA-1.
;Note that AddmusicK's death music hex edit is rendered ineffective. See defines. 

;;;Usage:
;To activate, set bit 7 of HP settings in _every sublevel_. Initialize the HP byte to the starting value, but only once per level, as it carries over between sublevels; I suggest checking for whether to initialize or not by checking if the HP byte is zero, as the default byte is cleared when loading the overworld. 
;HP is decreased when hurt, and increased when getting a powerup. Demo is killed when hurt at 1 HP. You're free to manipulate the HP byte whenever, but note that Demo doesn't automatically die when it's set to zero. HP isn't capped in the powerup code, so cap it for values above the maximum in the level main routine. 
;Advanced feature: Powerup result byte. The powerup result byte is modified to a non-negative value whenever HP changes. If hurt, it's set to 7F. When getting a powerup, it's set to the powerup status (19) Demo would be set to if the HP system wouldn't be enabled, for values 01-03; if it wouldn't change, it's set to 00. Additionally, it's set to FF (a negative value, as HP isn't changed) when cape flight is cancelled from being hit by an enemy. Note that bit 6 is set whenever the hurt routine is triggered (even if cancelled because of cape flight), and bit 7 is unset whenever HP changes, for BIT usage. By checking for values/bits (and then resetting to a default value, probably 00 or some negative value depending on the desired trigger) in the level main routine, this can be used to trigger custom hurt/powerup code. 
;Advanced experimental feature: Custom death code. Set bit 6 of HP settings (again, for every applicable sublevel; does not need the HP system to be active*) to activate. Jumps to the address in the death code pointer, so upload a long label there. End the custom code with RTL (or JML back to some place in the default code, I guess). Can be used for a retry system?
;*If not also using HP, the default HP settings byte is cleared every time the player is hurt, so the bit needs to be set again every time. In that case, check for it (or just always set it) every frame, like with capping HP. 

;;;Defines:
sa1rom
;;RAM Bytes:
;HP settings. Highly recommended to be kept to 788A (188A).
!HPSettings = $788A
;Note: The highest two bits of HP settings are always claimed (rest of the byte is free). The following addresses are only claimed when one of those two bits are set. 
;HP byte. A RAM byte that is cleared on overworld load, but not level load (or otherwise in levels) is recommended. 
!HPByte = $58
;Powerup result. A non-negative value is stored here when HP is changed (see usage).
!PowerupResult = $7C
;Custom death code pointer. Indirectly long-jumped to, so needs three free bytes of space. 
!DeathPointer = $6DDB   ;(0DDB)
;;Values:
;Death music. Because this patch ruins AddmusicK's hex edit to prevent it from playing with custom death code.
!DeathMusic = #$01
;Hurt and heal sound effects. 
!HitSFXA = $0C
!HitSFXB = $00
!HealSFXA = $00
!HealSFXB = $0B
;Stun time. 
!StunTime = $11

;;;Hijacks
;Hurt
org $00F5D5
autoclean JML Hurt_main

;Death
org $00F60C
JML Death
NOP

;Get powerup
org $01C540
JML GetPowerup_main
ReturnRTS:
RTS

;;;Code
freedata
Death:
    BIT !HPSettings
    BVC Hurt_deathrestore   ;Bit 6 of settings unset, use default behavior
    .custom:
    JML [!DeathPointer]     ;Jumps to custom code. Since the hurt routine is RTL already, end the custom code with RTL.

Hurt:
.restore:
    LDA $19                         ;Set up accumulator: Powerup status
    BEQ .hurtdeath                  ;If small, kill Demo
JML $00F5D9

.main:
    BIT !HPSettings            ;o:nv
    BPL .restore               ;i:n ;Bit 7 of settings unset, use default behavior
    LDA $19 : CMP #$02 : BEQ .cape  ;Cape check
    .hit:
    DEC !HPByte                ;o:nz;Decrease HP
    BNE .effects               ;i: z;If HP was just 1, kill
    ;Default death:
    .hurtdeath:
    LDA #$90 : STA $7D              ;Set Demo Y speed, as the hijack is just after this
    BVS Death_custom           ;i: v;Bit 6 of settings set, custom death behavior
    .deathrestore:                  ;(Putting one of these here saves a BRA)
    LDA !DeathMusic : STA $7DFB     ;Set death music. Note: Overwrites AddmusicK's hex edit. 
    LDA #$FF                        ;Some music thing
JML $00F611
    
.cape:
    LDA $7407 : BEQ .hit            ;Flying check
    LDA #$0F  : STA $7DF9           ;Hurt while flying sound effect
    LDA #$01  : STA $740D           ;Set spin jump
    LDA #$30  : STA $7497           ;Invincibility frames (about 3/4 of a second)
    STZ $7407                       ;Cape status
    LDA #$FF  : STA !PowerupResult  ;Store FF to powerup result on cape flight cancel. 
RTL
    
.effects:
    ;Sound effects
    if !HitSFXA
        LDA #!HitSFXA : STA $7DF9   ;A
    endif
    if !HitSFXB
        LDA #!HitSFXB : STA $7DFC   ;B
    endif
    
    LDY #$03 : STY $71              ;Set cape animation (freeze with invisible Demo; hurt breaks?). (Also, loop index.)
    ;Sparkles:
-   LDA $77C0,y : BEQ +             ;Check if smoke slot is open
    DEY : BPL -                     ;Loop with next slot
    LDY $7863   : DEY               ;If none are open, get the oldest one (and overwrite it)
    BPL ++ : LDY #$03               ;(Wrap in 00-03 range)
++  STY $7863                       ;Store youngest slot
+   LDA #$05 : STA $77C0,y          ;Sparkle effect
    LDA #$1B : STA $77CC,y          ;Timer
    LDA $96                         ;Demo Y
    CLC : ADC #$08                  ;Offset Y by 8
    STA $77C4,y                     ;Sparkle Y
    LDA $94  : STA $77C8,y          ;Sparkle X from Demo
    ;Cape animation timers:
    LDA #!StunTime
    STA $7496                       ;Animation timer
    STA $9D                         ;Pause sprites
    
    STZ $7407                       ;Cape status
    LDA #$7F : STA $7497            ;Invincibility frames (about 2 seconds)
    STA !PowerupResult              ;Also store 7F to powerup result on hurt
RTL
    
GetPowerup:
.restore:
    LDA $C510,y                     ;Load new item box item from table (data bank should still be 01)
    BEQ +
    JML $01C545                     ;Item
+   JML $01C54D                     ;No item

.main:
    BIT !HPSettings : BPL .restore  ;Bit 7 of settings unset, use default behavior
    LDA $C524,y                     ;Load new powerup status from table (data bank should still be 01)
    CMP #$05 : BEQ .restore         ;1-up, use default behavior
    CMP #$02 : BEQ .restore         ;Star, use default behavior
    CMP #$01 : BEQ +            ;o:c;Nothing, store 0
    INC
    BCC ++                      ;i:c;Mushroom, store 1
    DEC                             ;Else, cape or flower, store 2 and 3 respectively
+   DEC
++  STA !PowerupResult              ;Doesn't change powerup, but stores the result (kinda, see usage) for level code to use.

    ;Sound effects
    if !HealSFXA
        LDA #!HealSFXA : STA $7DF9  ;A
    endif
    if !HealSFXB
        LDA #!HealSFXB : STA $7DFC  ;B
    endif
    
    ;Points
    LDA $32B0,x : BNE +             ;Miscellaneous sprite table (SA-1 1534). Only give points when not blinking and falling. 
    LDA #$04                        ;1000 points
    JSL $02ACE5                     ;Give points
    
+   INC !HPByte                     ;HP. Note: Uncapped, do that in level code. 
JML ReturnRTS
