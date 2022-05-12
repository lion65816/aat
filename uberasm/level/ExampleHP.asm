;Example implementation of SimpleHP
;Lord Ruby

;Depends on SA-1 (MaxTile)

;;;Defines
;;Sprite tiles, 000-1FF. Yes, full tile number, not low byte and high bit separately.
!EyeOpenUpperLeftTile = $1C0
!EyeClosedLeftTile = $1E0
;;Origin for the HP eyes, YYXX. Note that the top left corner of the screen is 0000.
!EyeOrigin = $2808
;;Level-specific HP settings
!InitHP = $02
!MaxHP = $03
;Be mindful that the graphics code provided here can break if the Y coordinate of the eye origin and max HP combined make the UI go too far below the bottom of the screen. But that's clearly something that should be avoided in the first place anyway.
;;Copy from simpleHP.asm:
!HPSettings = $788A
!HPByte = $58
!PowerupResult = $7C

;;;Code
init:
    LDA #$02 : STA $19          ;Cape
    STZ $6DC2                   ;Empty item box
    LDA #$80 : STA !HPSettings  ;Activate HP system. Remember to do this in every sublevel!
    LDA !HPByte  : BNE +        ;Only initialize HP when it's zero. This prevents HP resets at every warp to this sublevel. 
    LDA #!InitHP : STA !HPByte  ;Starting HP
+   RTL

main:
    LDA !HPByte : CMP #!MaxHP+1 : BCC +     ;Check if HP is above the maximum
    LDA #!MaxHP : STA !HPByte               ;Set to maximum
    
    ;Strictly speaking, everything after this point is optional. You can delete that and put an RTL here for very basic HP.
    ;But you probably do want to implement some kind of UI, at least.
    
    ;On hurt, cause a very slight stun and prevent flight
+   BIT !PowerupResult                      ;Check bits of SimpleHP's result byte
    BVC .draw : BMI .draw                   ;If bit 6 is set, but bit 7 isn't, Demo has been hurt, else, skip
    
    STZ $73E4                               ;Clear run timer (p-meter)
    STZ $749F                               ;Clear flight rise timer
    LDA $72 : CMP #$0C : BNE + : DEC $72    ;If air state is running jump/flying, set it to normal jump
    
+   STZ !PowerupResult                      ;Clear result byte to let Demo move again
    
    ;Draw HP UI (Sprite based, uses ExGFX803 in SP4 - but make your own graphics file as that one *will* be modified!)
    .draw:
    LDA $71 : CMP #$03 : CLC : BNE +    ;o:c;Check for get cape animation, which is repurposed as a hurt animation
    LDA $7496 : LSR #2                  ;o:c;Use animation timer to time blinks
+   LDA !HPByte                             ;HP
    ADC #$00                            ;i:c;If the last hit point was just lost, make it blink a little
    STA $00 : STZ $01                       ;Store HP to scratch ram $00, 8 to 16 bit
    
    LDY.b #$00+(!MaxHP*3)                   ;One eye per hit point, each eye needs three tiles
    REP #$30                                ;(As the index registers were 8-bit, this fills their high bytes with zeroes)
    LDA.w #$0000                            ;Maximum priority
    JSL $0084B0                             ;Request MaxTile slots (does not modify scratch ram at the time of writing)
    BCS Draw                                ;Carry clear: Failed to get OAM slots, abort.
    SEP #$30                                ;...should never happen, since this will be executed before sprites, but...
RTL
    
Draw:
    ;;;Main table
    LDX $3100                           ;Main index
    LDY.w #$0000+((!MaxHP-1)*2)         ;Loop index
    
-   TYA : LSR                           ;Half index to A
    CMP $00                         ;o:c;Compare with current HP. This keeps as many eyes open as Demo has HP.
    LDA BaseCoord,y                     ;Load base X and Y coordinates
    BCC .open                       ;i:c
    ;;Closed
    ;Coordinates
    ADC.w #$07FF : STA $400000,x        ;Left           ;Offsets:   Y: 8 (note that carry is set)
    ADC.w #$0008 : STA $400004,x        ;Middle         ;           Y: 8, X:  8
    ADC.w #$0008 : STA $400008,x        ;Right          ;           Y: 8, X: 16
    
    ;Tiles, properties
    LDA.w #$3000+!EyeClosedLeftTile     ;Highest priority, palette 0, no flip
    STA $400002,x                       ;Left
    LDA.w #$3001+!EyeClosedLeftTile     ;Highest priority, palette 0, no flip, one tile to the right
    STA $400006,x                       ;Middle
    LDA.w #$7000+!EyeClosedLeftTile     ;Highest priority, palette 0, X flip
        
    BRA +
    
    ;;Open
    .open:
    ;Coordinates
    STA $400000,x                       ;Left           ;Offsets:
    ADC.w #$0010 : STA $400004,x        ;Top right      ;                 X: 16
    ADC.w #$0800 : STA $400008,x        ;Bottom right   ;           Y: 8, X: 16
    
    ;Tiles, properties
    LDA.w #$3000+!EyeOpenUpperLeftTile  ;Highest priority, palette 0, no flip
    STA $400002,x                       ;Left
    LDA.w #$7000+!EyeOpenUpperLeftTile  ;Highest priority, palette 0, X flip
    STA $400006,x                       ;Top right
    LDA.w #$7010+!EyeOpenUpperLeftTile  ;Highest priority, palette 0, X flip, one tile below
    
+   STA $40000A,x                       ;Right/Bottom right
    ;Loop
    TXA : ADC.w #$000C : TAX            ;Increase slot by 3 (4 bytes per slot, so 12). 
    DEY #2 : BPL -                      ;Loop
    
    ;;;Additional bits
    LDX $3102                           ;Bit table index
    LDY.w #$0000+!MaxHP-1               ;Loop index
    
-   LDA.w #$0000 : STA $400001,x        ;Store zero to the second and third tiles
    CPY $00 : BCS + : LDA.w #$0002      ;Big for open eyes, small for closed eyes
+   STA $400000,x                       ;Store zero to second tile, relevant value to first tile
    
    INX #3 : DEY : BPL -                ;Loop
    
    SEP #$30
    ;Don't do this :(
;    LDA.b #$00+(!MaxHP*3)-1             ;8 additional tiles for 3 max HP
    ;Not outside sprite code
;    LDY #$FF                            ;Custom tile sizes
    ;Bad idea
;    JSL $0084B4                         ;Maxtile draw
    ;_;
RTL

BaseCoord: 
;This loop sets up the data table for coordinates
!counter #= !MaxHP
!tempcoordinate #= !EyeOrigin+((!MaxHP-1)*$1000)
while !counter > 0
    dw !tempcoordinate
    !tempcoordinate #= !tempcoordinate-$1000
    !counter #= !counter-1
endif
