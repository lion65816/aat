;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;Unidirectional Bullet Bill Generator (only generates bullet bills from one side of the screen).
;
;Extra Bit - if set, the bullets will generate from the right side of the screen, otherwise they'll generate from the left side.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Aimed = 0                          ;by default, all bullets will take a random Y-position, like the original generator. If this is set, the bullets will target mario's y-position.

!SoundEf = $09                      ;Bullet Bill Shoot
!SoundBank = $1DFC|!Base2

!SpriteNumber = $1C                 ;Bullet Bill (1C)
!IsCustom = CLC                     ;CLC - vanilla sprite, SEC - custom

!Timer = $3F                        ;How long it takes to generate bullet. Can use these values: $01, $03, $07, $0F, $1F, $3F, $7F or $FF

!XSpeed = 0                         ;generally useless, unless the spawned sprite does not set it's x-speed automatically during its normal state (this can be used for e.g. Eerie)

;THE DEFINE BELOW CAN BE EDITED!!
;If you're using a vanilla bullet bill or a disassembly, it uses "!C2,x" (without quotation marks ofc) for it's movement direction. For most other sprites, it should be "!157C,x"
!DirectionTable = !C2,X

XOffsetLo:
            db $E0,$10              ;

XOffsetHi:
            db $FF,$01              ;Offsets

Print "INIT ",pc
Print "MAIN ",pc
PHB
PHK
PLB
JSR GenBills
PLB
RTL

ReturnCloser:
RTS

GenBills:
LDA $9D                             ;\in SMW, 9D check for generators is before pointers, which is why I missed this out
BNE ReturnCloser                    ;/

LDA $14                             ;\
AND #!Timer                         ;|Return every (user-defined number) Frames
BNE ReturnCloser                    ;/

;positions are to be set later
if !XSpeed
  LDY #!XSpeed                      ;
  LDA $18B9|!addr                   ;generator's extra bit
  AND #$40                          ;
  BNE .SpeedRight                   ;apply appropriate speed
  
  LDY #-!XSpeed

.SpeedRight 
  STY $02
else
  STZ $02                           ;no x-speed
endif

STZ $03                             ;no y-speed

LDA #!SprSize-2
STA $04                             ;amount of sprite slots to loop through

LDA #!SpriteNumber		;Set Sprite number
!IsCustom
%SpawnSpriteSafe()
BCS ReturnCloser

LDA #!SoundEf                       ;\sound
STA !SoundBank                      ;/

TYX                                 ;
LDA #$08                            ;\Status = Normal
STA !14C8,x                         ;/

if !Aimed
;aim at mario's
  LDA $96
  CLC : ADC #$10                    ;specifically, where the body is (or small mario)
  STA !D8,x
  
  LDA $97
  ADC #$00
  STA !14D4,x
else
  JSL $01ACF9|!BankB		;Random Number
  AND #$7F                          ;\
  ADC #$20                          ;|
  ADC $1C                           ;|
  AND #$F0                          ;|Set sprite's Y Position
  STA !D8,x                         ;|
                                    ;|
  LDA $1D                           ;|
  ADC #$00                          ;|
  STA !14D4,x                       ;/
endif

LDY #$00                            ;
LDA $18B9|!addr                     ;generator's extra bit
AND #$40                            ;check if should spawn from the right side of the screen or the left
BNE .ShootFromRight                 ;
INY                                 ;

.ShootFromRight
LDA $1A                             ;\
CLC                                 ;|
ADC XOffsetLo,y                     ;|
STA !E4,x                           ;/Place it near screen boundaries

LDA $1B                             ;\Set it's X position (high byte)
ADC XOffsetHi,y                     ;|
STA !14E0,x                         ;|
TYA                                 ;/
STA !DirectionTable                 ;go the direction

;additional code if necessary

Return:
RTS                                 ;