; pixi\pixi.exe -d -k -w -l list.txt SMW-taptap.smc
; type pixi\sprites\taptap\taptap.asm.wla > SMW-taptap.cpu.sym

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Tap-Tap the Red-Nose (SMW2)
; By Roy
; Original idea from Nintendo
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-------------------;
; DEFINES           ;
;-------------------;

prot gfx

!CANSPINJUMPONTAP = $00 ; Change to $01 if you want to disable this.

!ScreenShake = 0



!SECONDARYSPRITESTATE = !C2
!SPRITESTATE = !14C8
!FEETVERTDIR = !1504
!INAIRFLAG = !1510
!BODYVERTDIR = !151C
!TIME2ROLLNSTUMBLE = !1528
!TEMPDIR = !1534	
!XSPEEDTIMER = !154C
!TURNTIMER = !1558
!NOHURT = !1564
!WAITBEFOREJMPANDDEATH = !1570
!DIR = !157C
!GRNDCHK = !1588
!SOMETIMER = !15AC
!GFXPTR = !1602
!OTHERSTUFF = !160E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc     
                    %SubHorzPos()
                    TYA
                    STA !DIR,x
                    STZ !INAIRFLAG,x                   
                    RTL                 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc                                   
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR SPRITE_CODE_START   ;  |
                    PLB                     ;  |
                    RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sprite Main Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ImgPtr: db $0C,$0D,$0E,$0F,$10,$11,$12,$13,$0C,$0D,$0E,$0F,$10,$11,$12,$13

BodVert: db $00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01,$01,$01

FeetVert: db $01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01

SPRITE_CODE_START:  JSR TAPTAP_GRAPHICS             ; Run GFX routine
                    LDA !SPRITESTATE,x
		    CMP #$08
		    BNE OKReturn
		    LDA $9D
		    BNE OKReturn
                    

            LDA !SECONDARYSPRITESTATE,x
            CMP #$02 ; taptap is dying; don't despawn
            BEQ +
            %SubOffScreen()
            +
                    
		    LDA !WAITBEFOREJMPANDDEATH,x
		    BEQ OKNoDecrement
		    DEC !WAITBEFOREJMPANDDEATH,x

		    OKNoDecrement:
		    LDA !SECONDARYSPRITESTATE,x
                    PHX
                    ASL A
                    TAX
                    JMP (SpritePtr,x)

SpritePtr:          dw TapTapNotTrollnJmp ; #$00
                    dw TapTapNotTrollnJmp ; #$01
                    dw TapTapIsDyingJmp   ; #$02
                    dw Rollit             ; #$03
                    dw Stumbleda          ; #$04
                    dw TapTapStill        ; #$05
                    dw Rollita            ; #$06

TapTapStill:        PLX
                    LDA $14
                    AND #$07
                    TAY
                    LDA AboutToFall,y
                    STA !GFXPTR,x
                    LDA AboutToFallXSp,y
                    STA !B6,x
                    STZ !AA,x
                    JSR SprSprInteraction
                    DEC !TIME2ROLLNSTUMBLE,x
                    BPL RejoiceSt
                    STZ !B6,x
                    STZ !SECONDARYSPRITESTATE,x
                    STZ !INAIRFLAG,x
                    STZ !GFXPTR,x
                    BRA RejoiceSt

Stumbleda:          PLX
                    JSR Stumbled
                    BRA RejoiceSt

Rollita:            PLX
                    JSR Roll
                    BRA RejoiceSt

Rollit:             PLX
                    JSR Roll
		    JSR UrOnGround

RejoiceSt:          JSL $01802A
                    JSR MarSprInteraction
                    JSR Map16Chk
OKReturn:           RTS

TapTapNotTrollnJmp: PLX
                    JSR TurnIfApplicable 
                    JSR JumpHeh
                    JSR DancingOnTheCeiling
                    JSR UrOnGround
                    JSR XSpeed
					JSL $01802A
                    JSR Map16Chk
                    JSR MarSprInteraction
                    JMP SprSprInteraction ; (JSR,RTS)
         	    
TapTapIsDyingJmp:   PLX
                    JMP TapTapIsDying

AboutToFall: 	    db $1B,$1C,$1D,$1E,$1F,$1E,$1D,$1C

AboutToFallXSp:     db $F0,$F8,$00,$08,$10,$08,$00,$F8

;--------------------------------;
; Roll over the ground laughing  ;
;--------------------------------;

Roll:               LDA !TIME2ROLLNSTUMBLE,x
                    BMI IncInstead
                    DEC !TIME2ROLLNSTUMBLE,x
                    BEQ StopIt
                    LDA !TIME2ROLLNSTUMBLE,x
                    BRA ReRoll

IncInstead:         DEC !TIME2ROLLNSTUMBLE,x
                    LDA !TIME2ROLLNSTUMBLE,x
                    CMP #$C0
                    BEQ StopIt
                    EOR #$FF

ReRoll:             AND #$1E
                    LSR A
                    TAY
                    LDA.w ImgPtr,y
                    STA !GFXPTR,x
                    LDA.w BodVert,y
                    STA !BODYVERTDIR,x
                    STA !DIR,x
                    LDA.w FeetVert,y
                    STA !FEETVERTDIR,x  
                    RTS

NoStop:             LDA !TEMPDIR,x
                    BNE E0Haha
                    LDA #$30
                    BRA Storeha

E0Haha:             LDA #$DF

Storeha:            STA !TIME2ROLLNSTUMBLE,x
                    RTS

StopIt:             LDA !GRNDCHK,x
                    AND #$04
                    BEQ NoStop
                    LDA #$04
                    STA !SECONDARYSPRITESTATE,x
                    LDA #$48
                    STA !TIME2ROLLNSTUMBLE,x
                    STZ !B6,x
                    STZ !FEETVERTDIR,x
                    %SubHorzPos()
                    TYA
                    STA !DIR,x
                    STZ !BODYVERTDIR,x            
				LDA #$15
				STA !GFXPTR,x
                    RTS
;----;
; ce ;
;----;

DancingOnTheCeiling:
LDA !GRNDCHK,x
AND #$08
BEQ +
LDA #$1C
STA !AA,x
+
RTS

;-------------------------------;
; Ground code etciojdsoij       ;
;-------------------------------;

ExtraDisp1:
db $07,$F9
ExtraDisp2:
db $00,$FF

DiffSt:
LDA !B6,x
CMP #$80
ROL A
AND #$01
EOR #$01
STA !DIR,x
TAY
LDA !E4,x
CLC
ADC ExtraDisp1,y
STA !E4,x
LDA !14E0,x
ADC ExtraDisp2,y
STA !14E0,x
LDA #$05
STA !SECONDARYSPRITESTATE,x
LDA #$7F
STA !TIME2ROLLNSTUMBLE,x
STZ !FEETVERTDIR,x
STZ !BODYVERTDIR,x
RTS

UrOnGround:
LDA !GRNDCHK,x
AND #$04
BEQ NotOnGroundde
LDA #$01
STA !INAIRFLAG,x
RTS

NotOnGroundde:
LDA !INAIRFLAG,x
BEQ OKNoShit
LDA !GRNDCHK,x
AND #$08
BNE OnCeiling
LDA !SECONDARYSPRITESTATE,x
CMP #$03
BEQ DiffSt

OnCeiling:
LDA !WAITBEFOREJMPANDDEATH,x
BEQ StoreDizShit
CMP #$01
BEQ ItsMagnifying
CMP #$2F
BEQ DifYSpeed
BRA NoDizShit

DifYSpeed:
LDA #$C0
STA !AA,x
BRA NoDifAtAll

StoreDizShit:
LDA #$30
STA !WAITBEFOREJMPANDDEATH,x

NoDizShit:
STZ !AA,x

NoDifAtAll:
STZ !B6,x
STZ !GFXPTR,x
BRA OKNoShit

ItsMagnifying:
JSR AbsolutelyMagnificent
STZ !INAIRFLAG,x

OKNoShit:
RTS

;--------------------------;
;YMovement code and whatnot;
;--------------------------;

OKReturn3:          LDA !SECONDARYSPRITESTATE,x
                    BEQ OKRETURSNN
                    LDA !SOMETIMER,x
                    LSR A
                    LSR A
                    TAY
                    LDA JmpFrmToShw,y
                    STA !GFXPTR,x
                    STZ !INAIRFLAG,x

OKRETURSNN:
		    RTS

JmpFrmToShw: db $0A,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0B,$0A

TapXSpeed: db $12,$EE,$18,$E8,$1D,$E3,$21,$DF,$25,$DB,$29,$D7,$2C,$D4,$2F,$D1

AbsolutelyWtf:
LDA !GFXPTR,x
ORA !TURNTIMER,x
BNE OKRETURSNN
%SubHorzPos()
REP #$20
LDA $0E
CLC
ADC #$0040
CMP #$0080
SEP #$20
BCS OKRETURSNN
LDA #$30
STA !WAITBEFOREJMPANDDEATH,x
STZ !B6,x
STZ !GFXPTR,x
RTS

JumpHeh:
LDA !GRNDCHK,x
AND #$04
BEQ OKReturn3
LDA !SECONDARYSPRITESTATE,x
BNE SpecialState
LDA !WAITBEFOREJMPANDDEATH,x
BEQ AbsolutelyWtf
CMP #$01
BEQ AbsolutelyMagnificent
CMP #$0C
BCS OKRETURNN
LDA #$1A
STA !GFXPTR,x
RTS

AbsolutelyMagnificent:
%SubHorzPos()
REP #$20
LDA $0E
BPL NormalStuffZ
EOR #$FFFF

NormalStuffZ:
CMP #$00E0
BCC OkNoShitGoingOn
LDA #$00E0

OkNoShitGoingOn:
AND #$00E0
LSR #4
SEP #$20
CLC
ADC !DIR,x
TAY
LDA TapXSpeed,y
STA !B6,x
LDA #$A8
STA !AA,x
INC !SECONDARYSPRITESTATE,x
LDA #$08
STA $1DFC|!Base2
LDA #$2C
STA !SOMETIMER,x
LDA #$0A
STA !GFXPTR,x

OKRETURNN:
RTS

SpecialState:
if !ScreenShake
LDA #$0F
STA $1887|!Base2
endif
LDA #$09
STA $1DFC|!Base2
STZ !SECONDARYSPRITESTATE,x
STZ !GFXPTR,x
RTS

;--------------------------;
;XMovement code and whatnot;
;--------------------------;

WalkFrameToShow:
db $00,$00,$09,$08,$07,$07,$06,$06,$06,$05,$04,$03,$00,$00,$00,$00

WalkSpeedToHave:
db $00,$FE,$F0,$F0,$F0,$F0,$00,$00,$FE,$F0,$F0,$F0,$00,$00,$00,$00

XSpeed:
LDA !TURNTIMER,x
ORA !WAITBEFOREJMPANDDEATH,x
BNE IsTurningAround
LDA !GRNDCHK,x
AND #$04
BEQ IsTurningAround
LDA !XSPEEDTIMER,x
BEQ ActivateSpeedAgain
ASL A
BMI NoXSpeed
LSR #3
TAY
LDA WalkFrameToShow,y
STA !GFXPTR,x
LDA WalkSpeedToHave,y
LDY !DIR,x
BNE DontXORSpd
EOR #$FF
INC A

DontXORSpd:
STA !B6,x
LDA !XSPEEDTIMER,x
AND #$1F
CMP #$01
BNE IsTurningAround
LDA #$0F
STA $1887|!Base2
LDA #$09
STA $1DFC|!Base2

IsTurningAround:
RTS

ActivateSpeedAgain:
LDA #$50
STA !XSPEEDTIMER,x
RTS

NoXSpeed:
STZ !B6,x
RTS

;--------------------------;
; Tap-Tap is stumbled code ;
;--------------------------;

SoManiethImg:
db $00,$18,$17,$16

AhImg:
db $15,$15,$19,$15,$15,$15,$15

VertDir:
db $00,$01,$01,$01

Stumbled:
LDA !TIME2ROLLNSTUMBLE,x
BEQ OKReturnthenheh
DEC !TIME2ROLLNSTUMBLE,x
CMP #$10
BEQ Jump
BCC NotYet
SEC
SBC #$10
LSR A
LSR A
LSR A
TAY
LDA AhImg,y
STA !GFXPTR,x
RTS

OKReturnthenheh:
STZ !SECONDARYSPRITESTATE,x
STZ !GFXPTR,x
RTS

NotYet:
LSR A
LSR A
TAY
LDA SoManiethImg,y
STA !GFXPTR,x
LDA VertDir,y
STA !FEETVERTDIR,x
RTS

Jump:
LDA #$E4
STA !AA,x
STZ !INAIRFLAG,x
RTS

;--------------------------;
; Turning Around Code etc  ;
;--------------------------;

FrameToShow:         db $00,$01,$01,$02,$02,$01,$01,$00

TurnIfApplicable:    LDA !GRNDCHK,x
                     AND #$04
                     BEQ HasSpeed
	             LDA !WAITBEFOREJMPANDDEATH,x
                     BNE HasSpeed
                     LDA !XSPEEDTIMER,x
                     BEQ HasNoSpeed
                     ASL A
                     BPL HasSpeed

HasNoSpeed:          STZ !B6,x
                     LDA !TURNTIMER,x
                     BNE TurnAroundMode
                     %SubHorzPos()
					TYA
                     CMP !DIR,x
                     BNE TurnAroundModeActiv
					STA !DIR,x
		     RTS

TurnAroundModeActiv: LDA #$1F
                     STA !TURNTIMER,x
                     RTS

TurnAroundMode:      CMP #$10
                     BNE DontXOREither
                     PHA
                     LDA !DIR,x
                     EOR #$01
                     STA !DIR,x
                     PLA

DontXOREither:       LSR #2
                     TAY
                     LDA FrameToShow,y
                     STA !GFXPTR,x

HasSpeed:            RTS

;--------------------------;
; Check Map16 (lava tiles) ;
;--------------------------;

Map16Chk:
LDA !E4,x           ; Get X low position of sprite
STA $02             ; store into $02
LDA !14E0,X         ;
STA $03	
LDA !D8,x           ; Get y low position of sprite
CLC
ADC #$10
STA $00             ; Store into $00
LDA !14D4,x         ; Get y hi
ADC #$00
STA $01             ; Store into $01

LDA $00                   
AND #$F0                
STA $06                   
LDA $02                   
LSR #4
PHA                       
ORA $06                   
PHA                       
LDA $5B    
AND #$01                
BEQ CODE_01D977           
PLA                       
LDX $01                   
CLC                       
ADC.l $00BA80,X       
STA $05                   
LDA.l $00BABC,X       
ADC $03                   
STA $06                   
BRA CODE_01D989           

CODE_01D977:
PLA                       
LDX $03                   
CLC                       
ADC.l $00BA60,X       

STA $05                   
LDA.l $00BA9C,X       
ADC $01                   
STA $06                   

CODE_01D989:
LDA.b #!BankA>>16
STA $07                   
LDX $15E9|!Base2               ; X = Sprite index 
LDA [$05]                 
STA $1693|!Base2               
INC $07                   
PLY
LDA [$05]     
XBA
LDA $1693|!Base2
LDY #$1E

Map16Loop:
REP #$20
CMP LavaTiles,y
SEP #$20
BEQ KillTapTap
DEY
DEY
BPL Map16Loop
RTS

KillTapTap:
LDA !1686,x
ORA #$80
STA !1686,x
LDA #$02
STA !SECONDARYSPRITESTATE,x
LDA #$14
STA !GFXPTR,x
LDA #$FF
STA !WAITBEFOREJMPANDDEATH,x
STZ !BODYVERTDIR,x
STZ !FEETVERTDIR,x
RTS

LavaTiles:
dw $0004,$0005,$0159,$015A,$015B,$01D2,$01D3,$01D4,$01D5,$01D6,$01D7,$01FB,$01FC,$01FD,$01FE,$01FF

;---------------------------;
; Sprite <-> Sprite Interact;
;---------------------------;

SprSprInteraction:  LDY #!SprSize-1

SprLp:              LDA !SPRITESTATE,y
                    CMP #$09
                    BCC NoState
                    CMP #$0C
                    BCC State
NoState:            DEY
                    BPL SprLp
NoInt:		    	RTS

State:              PHY
                    PHX
                    TYX
                    JSL $03B6E5
                    PLX
                    JSR GetSpriteClipping
                    JSL $03B72B
                    PLY
                    BCC NoInt
                    PHY
                    PHX
                    TYX
                    STZ !SPRITESTATE,x
                    LDA !E4,x
                    STA $9A
                    LDA !14E0,x
                    STA $9B
                    LDA !D8,x
                    STA $98
                    LDA !14D4,x
                    STA $99
                    PHB
                    LDA #$02
                    PHA
                    PLB
                    LDA #$FF
                    JSL $028663
                    PLB
                    PLX
                    PLY
					LDA #$EF
                    PHA
                    LDA !DIR,x
                    STA !TEMPDIR,x
                    BNE OkayHehs
                    PLA
                    LDA #$20
                    BRA NotDS

OkayHehs:           PLA

NotDS:              STA !TIME2ROLLNSTUMBLE,x
                    LDA.w !B6,y
                    BPL NoDizzz
                    EOR #$FF
                    INC A
                    CMP #$20
                    BCC OKNotFast
                    LDA #$1F

OKNotFast:          LSR #2
                    TAY
                    LDA XSpeed2,y
                    EOR #$FF
                    INC A
                    BRA NoDizz

NoDizzz:            CMP #$20
                    BCC OKNOTFAST2
                    LDA #$1F

OKNOTFAST2:         LSR #2
                    TAY
                    LDA XSpeed2,y

NoDizz:             STA !B6,x
                    LDA !SECONDARYSPRITESTATE,x
                    CMP #$05
                    BEQ OtherSituation
                    LDA #$03
                    STA !SECONDARYSPRITESTATE,x
                    RTS

OtherSituation:     LDA #$06
                    STA !SECONDARYSPRITESTATE,x
                    RTS

XSpeed2:            db $01,$05,$09,$0D,$11,$15,$19,$1D

;--------------------------;
; Mario <-> Sprite interact;
;--------------------------;

MarSprInteraction:  JSL $03B664
		    JSR GetSpriteClipping
		    JSL $03B72B
		    BCC OKReturn2
		    LDA $140D|!Base2
                    ORA $187A|!Base2
                    BEQ HurtHimThen
                    LDA #!CANSPINJUMPONTAP
                    BNE HurtHimThen
                    LDA $7D
                    CMP #$10
                    BMI HurtHimThen
                    JSL $01AA33
                    JSL $01AB99
                    LDA #$02
                    STA $1DF9|!Base2
                    LDA #$10
                    STA !NOHURT,x
                    BRA OKReturn2

HurtHimThen:	    LDA !NOHURT,x
                    BNE OKReturn2
                    LDA $187A|!Base2
                    BNE OnYoshi
                    JSL $00F5B7
OKReturn2:          RTS

OnYoshi:            PHX
                    LDX $18E2|!Base2
                    LDA #$10
                    STA !163E-1,x
                    LDA #$03
                    STA $1DFA|!Base2
                    LDA #$13
                    STA $1DFC|!Base2
                    LDA #$02
                    STA !C2-1,x
                    STZ $187A|!Base2
                    STZ $0DC1|!Base2
                    LDA #$C0
                    STA $7D
                    STZ $7B
                    LDY !157C-1,x
                    PHX
		    TYX
                    LDA YoshiSpeed,x
                    PLX
                    STA !B6-1,x
                    STZ !1594-1,x
                    STZ !151C-1,x
                    STZ $18AE|!Base2
                    LDA #$30
                    STA $1497|!Base2
                    PLX
                    RTS                    

YoshiSpeed: db $18,$E8

;--------------------------;
; Sprite Clipping Routine  ;
; Mostly borrowed from SMW ;
;--------------------------;

GetSpriteClipping:
PHY
PHX
TXY
LDA !1662,x
AND #$3F
TAX
LDA.w !E4,y
SEC
SBC #$0C		; Starting X pos of sprite clipping = sprite center position - $0C ($0C pixels to the left)
STA $04
LDA !14E0,y
SBC #$00
STA $0A
LDA #$2C                ; Width of sprite clipping
STA $06
LDA.w !D8,y
SEC
SBC #$2C                ; Starting Y pos of sprite clipping = sprite center position - $2C ($2C pixels above)
STA $05
LDA !14D4,y
SBC #$00
STA $0B
LDA #$38                ; Height of sprite clipping
STA $07
PLX
PLY
RTS

;-----------;
; TT dies   ;
;-----------;

TapTapIsDying:
LDA $13
AND #$01
BNE OKTHENNOT
INC !WAITBEFOREJMPANDDEATH,x

OKTHENNOT:
LDA !WAITBEFOREJMPANDDEATH,x
BEQ Erase
STZ !B6,x
JSR YSpeedDeterm
JSR GenerateSomeSmoke
JSL $01802A
JMP Graphico ; (JSR,RTS)

Erase:
STZ !SPRITESTATE,x
LDA #$FF
STA $1493|!Base2
INC $13C6|!Base2
LDA #$03
STA $1DFB|!Base2
Roteb:
RTS

YSpeedDeterm:
LDA !WAITBEFOREJMPANDDEATH,x
LSR #3
TAY
LDA YSpeedPer8Frms,y
STA !AA,x
RTS

GenerateSomeSmoke:
LDA !WAITBEFOREJMPANDDEATH,x
AND #$0F
BEQ NotSoA
CMP #$03
BEQ NotSoB
CMP #$09
BEQ NotSoC
CMP #$0E
BNE Roteb
LDY #$00
BRA NotSoD

NotSoA:
LDY #$01
BRA NotSoD

NotSoB:
LDY #$02
BRA NotSoD

NotSoC:
LDY #$03

NotSoD:
LDA #$17
STA $1DFC|!Base2

SetShooterSmoke:
LDA !14E0,x
XBA
PHY
TYA
ASL A
TAY
LDA !E4,x
REP #$20
CLC
ADC XDisp,y
PHA
SEC
SBC $1A
CMP #$0100
PLA
SEP #$20
PLY
BCS NoGen
STA $00
LDA !14D4,x
XBA
LDA !WAITBEFOREJMPANDDEATH,x
LSR #4
PHY
ASL A
TAY
LDA !D8,x
REP #$20
SEC
SBC StayAboveLava,y
PHA
SEC
SBC $1C
CMP #$0100
PLA
SEP #$20
PLY
BCS NoGen
STA $17C4|!Base2,y
LDA #$17
STA $17CC|!Base2,y
LDA $00
STA $17C8|!Base2,y
LDA #$01
STA $17C0|!Base2,y
NoGen:
RTS

Graphico:
LDA !WAITBEFOREJMPANDDEATH,x
LSR #3
TAY
LDA Lolz,y
STA !GFXPTR,x
RTS

XDisp:
dw $FFEA,$FFF8,$0006,$0014

StayAboveLava:
dw $003B,$0038,$0034,$002C,$0026,$0026,$0020,$001A,$001C,$0022,$0025,$0024,$0024,$0018,$000A,$FFFE

YSpeedPer8Frms:
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$02,$00,$00,$FF
db $FE,$FD,$FC,$FD,$FE,$00,$00,$02,$04,$06,$06,$06,$06,$06,$06,$06

Lolz:
db $14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14,$14
db $15,$14,$15,$15,$14,$15,$15,$15,$15,$14,$14,$15,$15,$15,$15,$14

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GFX Routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		!TEMP_FOR_TILE = $04

TAPTAP_HORZ_DISP:  db $DC,$EC,$08,$18,$E8,$F8,$E8,$F8,$08,$18,$08,$18,$E8,$F8,$E8,$F8,$08,$18,$08,$18
                   db $EC,$DC,$18,$08,$18,$08,$18,$08,$F8,$E8,$F8,$E8,$18,$08,$18,$08,$F8,$E8,$F8,$E8
TAPTAP_VERT_DISP:  db $07,$07,$07,$07,$CF,$CF,$DF,$DF,$CF,$CF,$DF,$DF,$EF,$EF,$FF,$FF,$EF,$EF,$FF,$FF
                   db $07,$07,$07,$07,$FF,$FF,$EF,$EF,$FF,$FF,$EF,$EF,$DF,$DF,$CF,$CF,$DF,$DF,$CF,$CF
EXTRA_ADJUSTMENT:  db $00,$00,$00,$02,$04,$02,$00,$02,$04,$02,$00,$00,$00,$00,$00,$00
                   db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$FE,$0D,$0D,$0D,$0D,$0D
TAPTAP_TILEMAP:    db $80,$82,$80,$82,$0C,$0E,$2C,$2E,$08,$0A,$28,$2A,$04,$06,$24,$26,$00,$02,$20,$22
TileTable:         db $00,$01,$10,$11 ; 0
                   db $02,$01,$10,$11 ; 1
                   db $20,$21,$10,$11 ; 2
                   db $00,$01,$10,$11 ; 3
		   db $00,$01,$10,$11 ; 4
                   db $00,$01,$10,$11 ; 5
                   db $00,$01,$10,$11 ; 6
                   db $00,$01,$10,$11 ; 7
                   db $00,$01,$10,$11 ; 8
                   db $00,$01,$10,$11 ; 9
                   db $00,$01,$10,$11 ; A
                   db $00,$01,$10,$11 ; B
                   db $03,$12,$13,$22 ; C
                   db $23,$30,$31,$32 ; D
                   db $33,$40,$41,$42 ; E
                   db $43,$50,$53,$60 ; F
                   db $51,$52,$61,$62 ; 10
                   db $63,$70,$73,$80 ; 11
                   db $71,$72,$81,$82 ; 12
                   db $83,$90,$91,$92 ; 13
                   db $03,$12,$13,$22 ; 14
                   db $93,$A0,$A1,$A2 ; 15
		   db $00,$01,$10,$11 ; 16
		   db $00,$01,$10,$11 ; 17
		   db $00,$01,$10,$11 ; 18
                   db $03,$12,$13,$22 ; 19
		   db $00,$01,$10,$11 ; 1A
                   db $93,$A0,$A1,$A2 ; 1B
                   db $93,$A0,$A1,$A2 ; 1C
                   db $93,$A0,$A1,$A2 ; 1D
                   db $93,$A0,$A1,$A2 ; 1E
                   db $93,$A0,$A1,$A2 ; 1F
FEET_HORZ_DISP:    db $FD,$0D,$F4,$04,$04,$F4,$0D,$FD ; 0
                   db $03,$13,$EF,$FF,$FF,$EF,$13,$03 ; 1
                   db $07,$17,$EB,$FB,$FB,$EB,$17,$07 ; 2
                   db $FF,$0F,$F1,$01,$01,$F1,$0F,$FF ; 3
                   db $02,$12,$EC,$FC,$FC,$EC,$12,$02 ; 4
                   db $05,$15,$E8,$F8,$F8,$E8,$15,$05 ; 5
                   db $08,$18,$E6,$F6,$F6,$E6,$18,$08 ; 6
                   db $03,$13,$EC,$FC,$FC,$EC,$13,$03 ; 7
                   db $FF,$0F,$EF,$FF,$FF,$EF,$0F,$FF ; 8
                   db $FD,$0D,$F4,$04,$04,$F4,$0D,$FD ; 9
                   db $FD,$0D,$F4,$04,$04,$F4,$0D,$FD ; A
                   db $05,$05,$FC,$FC,$FC,$FC,$05,$05 ; B
                   db $F1,$F1,$EA,$EA,$0C,$0C,$15,$15 ; C
                   db $F2,$F2,$EB,$EB,$06,$06,$0F,$0F ; D
                   db $03,$03,$FC,$FC,$FD,$FD,$06,$06 ; E
		   db $01,$11,$FE,$0E,$FD,$ED,$01,$F1 ; F
                   db $02,$12,$02,$12,$FD,$ED,$FD,$ED ; 10
                   db $08,$18,$0B,$1B,$F5,$E5,$F3,$E3 ; 11
                   db $E6,$F6,$E3,$F3,$19,$09,$1D,$0D ; 12
                   db $EE,$EE,$E9,$E9,$0E,$0E,$15,$15 ; 13
                   db $EE,$EE,$E9,$E9,$0E,$0E,$15,$15 ; 14
                   db $EE,$EE,$E9,$E9,$0E,$0E,$15,$15 ; 15
                   db $0E,$0E,$15,$15,$EE,$EE,$E9,$E9 ; 16
                   db $09,$09,$10,$10,$F3,$F3,$EE,$EE ; 17
                   db $FF,$0F,$FA,$0A,$07,$F7,$02,$F2 ; 18
                   db $EE,$EE,$E9,$E9,$0E,$0E,$15,$15 ; 19
		   db $FD,$0D,$F4,$04,$04,$F4,$0D,$FD ; 1A
		   db $03,$03,$EA,$EA,$FD,$FD,$16,$16 ; 1B
		   db $05,$05,$EC,$EC,$FF,$FF,$18,$18 ; 1C
		   db $07,$07,$EE,$EE,$01,$01,$1A,$1A ; 1D
		   db $09,$09,$F0,$F0,$03,$03,$1C,$1C ; 1E
		   db $0B,$0B,$F2,$F2,$05,$05,$1E,$1E ; 1F
FEET_VERT_DISP:    db $00,$00,$00,$00,$00,$00,$00,$00 ; 0
                   db $00,$00,$00,$00,$00,$00,$00,$00 ; 1
                   db $00,$00,$00,$00,$00,$00,$00,$00 ; 2
	           db $00,$00,$FC,$FC,$00,$00,$FC,$FC ; 3
                   db $00,$00,$F8,$F8,$00,$00,$F8,$F8 ; 4
                   db $00,$00,$FC,$FC,$00,$00,$FC,$FC ; 5
                   db $00,$00,$00,$00,$00,$00,$00,$00 ; 6
                   db $FC,$FC,$00,$00,$FC,$FC,$00,$00 ; 7
                   db $F8,$F8,$00,$00,$F8,$F8,$00,$00 ; 8
                   db $FC,$FC,$00,$00,$FC,$FC,$00,$00 ; 9
		   db $00,$00,$00,$00,$00,$00,$00,$00 ; A
		   db $00,$10,$00,$10,$00,$10,$00,$10 ; B
                   db $D2,$E2,$D2,$E2,$FC,$EC,$FC,$EC ; C
                   db $D2,$E2,$D0,$E0,$00,$F0,$04,$F4 ; D
                   db $D0,$E0,$CC,$DC,$01,$F1,$05,$F5 ; E
                   db $D8,$D8,$D4,$D4,$F6,$F6,$FE,$FE ; F
                   db $DC,$DC,$D4,$D4,$F3,$F3,$FC,$FC ; 10
                   db $E0,$E0,$D9,$D9,$EE,$EE,$F7,$F7 ; 11
                   db $E5,$E5,$EE,$EE,$E4,$E4,$E1,$E1 ; 12
                   db $D7,$E7,$DB,$EB,$F6,$E6,$F4,$E4 ; 13
                   db $EC,$FC,$EC,$FC,$EC,$FC,$EC,$FC ; 14
                   db $EC,$FC,$EC,$FC,$EC,$FC,$EC,$FC ; 15
                   db $FC,$EC,$FC,$EC,$FC,$EC,$FC,$EC ; 16
                   db $00,$F0,$00,$F0,$00,$F0,$00,$F0 ; 17
                   db $FA,$FA,$FA,$FA,$FA,$FA,$FA,$FA ; 18
                   db $EC,$FC,$EC,$FC,$EC,$FC,$EC,$FC ; 19
		   db $00,$00,$00,$00,$00,$00,$00,$00 ; 1A
		   db $F5,$05,$E1,$F1,$F5,$05,$E1,$F1 ; 1B
		   db $F5,$05,$E1,$F1,$F5,$05,$E1,$F1 ; 1C
		   db $F5,$05,$E1,$F1,$F5,$05,$E1,$F1 ; 1D
		   db $F5,$05,$E1,$F1,$F5,$05,$E1,$F1 ; 1E
		   db $F5,$05,$E1,$F1,$F5,$05,$E1,$F1 ; 1F
FEET_TILEMAP:      db $00,$02,$00,$02 ; 0
                   db $00,$02,$00,$02 ; 1
                   db $00,$02,$00,$02 ; 2
		   db $00,$02,$00,$02 ; 3
		   db $00,$02,$00,$02 ; 4
		   db $00,$02,$00,$02 ; 5
		   db $00,$02,$00,$02 ; 6
		   db $00,$02,$00,$02 ; 7
		   db $00,$02,$00,$02 ; 8
		   db $00,$02,$00,$02 ; 9
		   db $04,$06,$04,$06 ; A
		   db $0C,$2C,$0C,$2C ; B
                   db $20,$22,$20,$22 ; C
		   db $0E,$2E,$0E,$2E ; D
		   db $0C,$2C,$0C,$2C ; E
                   db $08,$0A,$08,$0A ; F
		   db $04,$06,$04,$06 ; 10
		   db $00,$02,$00,$02 ; 11
                   db $28,$2A,$28,$2A ; 12
		   db $24,$26,$24,$26 ; 13
                   db $20,$22,$20,$22 ; 14
                   db $20,$22,$20,$22 ; 15
                   db $20,$22,$20,$22 ; 16
                   db $24,$26,$24,$26 ; 17
                   db $28,$2A,$28,$2A ; 18
                   db $20,$22,$20,$22 ; 19
                   db $00,$02,$00,$02 ; 1A
		   db $0E,$2E,$0E,$2E ; 1B
		   db $0E,$2E,$0E,$2E ; 1C
		   db $0E,$2E,$0E,$2E ; 1D
		   db $0E,$2E,$0E,$2E ; 1E
		   db $0E,$2E,$0E,$2E ; 1F

RETURNY:            PLX
                    RTS

TAPTAP_GRAPHICS:    %GetDrawInfo()       ;A:87BF X:0007 Y:0000 D:0000 DB:03 S:01ED P:envMXdiZCHC:1102 VC:066 00 FL:665 
                    LDA !GFXPTR,x
                    STA $07
                    ASL #3
                    STA $03
                    LSR A
                    PHX
                    TAX
                    LDA TileTable,x 
                    JSR GETSLOT
		    BEQ RETURNY
                    LDA TileTable+1,x
                    JSR GETSLOT
                    BEQ RETURNY
                    LDA TileTable+2,x
                    JSR GETSLOT
                    BEQ RETURNY
                    LDA TileTable+3,x
                    JSR GETSLOT
                    BEQ RETURNY
                    STA !TEMP_FOR_TILE
                    PLX
                    LDA !FEETVERTDIR,x
                    STA $08
                    LDA !BODYVERTDIR,x
                    STA $06
                    LDA !DIR,x
		    EOR #$01
                    STA $05
                    LSR A
                    ROR #2
                    STA $02 ; dir * $40
                    PHX                     ; /

                    LDX #$00                ; run loop 4 times, cuz 4 tiles per frame

LOOP_START_2:       PHX
                    CPX #$04
                    BCS NoFeetJmp
                    PHX
                    LDX $15E9|!Base2
                    LDA !SECONDARYSPRITESTATE,x
                    PLX
                    CMP #$03
                    BEQ NormalHeh
                    CMP #$06
                    BEQ NormalHeh
                    LDA $02
                    REP 4 : LSR
                    PHA
                    LDA $08
                    ASL #2
                    EOR $01,s
                    PHA
                    TXA
                    CLC
                    ADC $01,s
                    CLC
                    ADC $03
                    TAX
                    PLA
                    BRA TreFiori1

NoFeetJmp:          JMP NoFeet

NormalHeh:          LDA $08
                    ASL A
                    ASL A
                    PHA
                    TXA
                    CLC
                    ADC $01,s
                    CLC
                    ADC $03
                    TAX

TreFiori1:          PLA
                    LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
                    CLC                     ; |
                    ADC FEET_HORZ_DISP,x ; |
                    STA $0300|!Base2,y             ; /
                    LDA $01                 ; |
                    CLC                     ; | tile y position = sprite y location ($01) + til e displacement
                    ADC FEET_VERT_DISP,x ; |
                    STA $0301|!Base2,y             ; /
                    PLX
                    PHX
                    LDA $03
                    LSR A
                    PHX
                    PHA
                    TXA
                    CLC
                    ADC $01,s
                    TAX
                    PLA
                    LDA FEET_TILEMAP,x   ; |
                    STA $0302|!Base2,y             ; /
                    PLX
                    PHX
                    LDA $08
                    ROR #3
                    PHA
                    LDA $08
                    ROR #2
                    CLC
                    ADC $01,s
                    PHA
		    LDX $15E9|!Base2
		    LDA !15F6,x
                    CLC
                    ADC $01,s
                    PLX
                    PLX
		    PLX
                    ORA $64
                    PHY
                    PHX
                    LDX $15E9|!Base2
                    LDY !SECONDARYSPRITESTATE,x
                    PLX
                    CPY #$03
                    BEQ TreFiori2
                    CPY #$06
                    BEQ TreFiori2
                    EOR $02

TreFiori2:          PLY
                    PHY
                    PHX
                    LDX $15E9|!Base2
                    LDY !SECONDARYSPRITESTATE,x
                    PLX
                    CPY #$02
                    BNE Prior1
                    AND #$CF

Prior1:		    PLY
                    STA $0303|!Base2,y             ; store tile properties
                    BRA ITIPMYHATTOTHENEWCONSTITUTION

NoFeet:             LDA $05
                    ASL A
                    ASL A
                    CLC
                    ADC $05
                    ASL A
                    ASL A
                    PHA
                    TXA
                    CLC
                    ADC $01,s
                    TAX
                    PLA
                    LDA $00                 ; \ tile x position = sprite x location ($00) + tile displacement
                    CLC                     ; |
                    ADC TAPTAP_HORZ_DISP,x ; |
                    STA $0300|!Base2,y             ; /
                    PLX
                    PHX
                    LDA $06
                    ASL A
                    ASL A
                    CLC
                    ADC $06
                    ASL A
                    ASL A
                    PHA
                    TXA
		    CLC
		    ADC $01,s
                    TAX
                    PLA
                    LDA $01                 ; |
                    CLC                     ; | tile y position = sprite y location ($01) + til e displacement
                    ADC TAPTAP_VERT_DISP,x ; |
                    LDX $07
                    SEC
                    SBC EXTRA_ADJUSTMENT,x
                    STA $0301|!Base2,y             ; /
                    PLX
                    PHX
                    LDA TAPTAP_TILEMAP,x   ; |
	      	    CLC
		    ADC !TEMP_FOR_TILE
                    STA $0302|!Base2,y             ; /
                    PHX
                    LDA $06
                    ROR #2
                    PHA
		    LDX $15E9|!Base2
		    LDA !15F6,x
                    CLC
                    ADC $01,s
                    PLX
		    PLX
                    ORA $64
                    ORA $02
                    PHY
                    PHX
                    LDX $15E9|!Base2
                    LDY !SECONDARYSPRITESTATE,x
                    PLX
                    CPY #$02
                    BNE Prior2
                    AND #$CF

Prior2:		    PLY
                    STA $0303|!Base2,y             ; store tile properties

ITIPMYHATTOTHENEWCONSTITUTION:
                    PLX                     ; \ pull, current tile
                    PHY
                    TYA
                    LSR A
                    LSR A
                    TAY
                    LDA #$02
                    STA $0460|!Base2,y
                    PLY
                    INY #4
                    INX                     ; | go to next tile of frame and loop
                    CPX #$14
                    BCC LOOP_START_2JMP     ; /

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ why 02? (460 = 2) all 16x16 tiles
                    LDA #$13                ; | A = number of tiles drawn - 1
                    JSL $01B7B3
                    RTS                     ; return

LOOP_START_2JMP:    JMP LOOP_START_2

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Dynamic sprite routine
; Programmed mainly by SMKDan
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!Temp = $09
!Timers = $0B

!SlotPointer = $0660|!Base2			;16bit pointer for source GFX
!SlotBank = $0662|!Base2			;bank
!SlotDestination = $0663|!Base2			;VRAM address
!SlotsUsed = $06FE|!Base2			;how many slots have been used

!MAXSLOTS = $04			;maximum selected slots

GETSLOT:
get_dynamic_slot:
	PHY		;preserve OAM index
	PHA		;preserve frame
	LDA !SlotsUsed	;test if slotsused == maximum allowed
	CMP #!MAXSLOTS
	BNE +
		
	PLA
	PLY
	LDA #$00	;zero on no free slots
	RTS

+	PLA		;pop frame
	REP #$20	;16bit A
	AND.w #$00FF	;wipe high
	XBA		;<< 8
	LSR A		;>> 1 = << 7
	STA !Temp	;back to scratch
	LDA.w #gfx	;Get 16bit address
	CLC
	ADC !Temp	;add frame offset	
	STA !SlotPointer	;store to pointer to be used at transfer time
	SEP #$20	;8bit store
	LDA.b #gfx/$10000
	STA !SlotBank	;store bank to 24bit pointer

	PHX		;This is how I made your boi a routine
	LDX !SlotsUsed		;calculate VRAM address + tile number
	LDA.L SlotsTable,X	;get tile# in VRAM
	PLX
	PHA		;preserve for eventual pull
	SEC
	SBC #$C0	;starts at C0h, they start at C0 in tilemap
	REP #$20	;16bit math
	AND.w #$00FF	;wipe high byte
	ASL A		;multiply by 32, since 32 bytes/16 words equates to 1 32bytes tile
	ASL A
	ASL A
	ASL A
	ASL A
if !SA1 == 1
	CLC : ADC #$8000         ;add 8000, base address of buffer: !DSX_BUFFER = $418000 from sa1.asm
else
	CLC : ADC #$0B44         ;add 0B44, base address of buffer: !dsx_buffer = $7F0B44 from dsx.asm
endif
	STA !SlotDestination	;destination address in the buffer
	SEP #$20
	STZ !Timers
	
;;;;;;;;;;;;;;;;
;Tansfer routine
;;;;;;;;;;;;;;;;

;DMA ROM -> RAM ROUTINE

if !SA1 == 1
;set destination RAM address
	REP #$20
	LDY #$C4
	STY $2230                ; DMA settings
	LDA.w !SlotDestination
	STA $2235	;16bit RAM dest

;first line
	LDA !SlotPointer
	STA $2232	;low 16bits
	LDY !SlotBank
	STY $2234	;bank
	LDY #$80	;128 bytes
	STZ $2238
	STY $2238
	LDY #$41
	STY $2237
	
	LDY $318C
	BEQ $FB
	LDY #$00
	STY $318C
	STY $2230	;transfer

;lines afterwards
-	LDY #$C4
	STY $2230
	LDA.w !SlotDestination	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SlotDestination	;updated base
	STA $2235	;updated RAM address

	LDA !SlotPointer	;update source address
	CLC
	ADC #$0200	;512 bytes, next row
	STA !SlotPointer
	STA $2232	;low 16bits
	LDY !SlotBank
	STY $2234	;bank
	LDY #$80
	STZ $2238
	STY $2238
	LDY #$41
	STY $2237
	
	LDY $318C
	BEQ $FB
	LDY #$00
	STY $318C
	STY $2230	;transfer
	LDY !Timers
	CPY #$02
	BEQ +
	INC !Timers
	BRA -
+
else
;common DMA settings
	REP #$20
	STZ $4300	;1 reg only
	LDY #$80	;to 2180, RAM write/read
	STY $4301
	
;set destination RAM address
	LDA !SlotDestination
	STA $2181	;16bit RAM dest
	LDY #$7F
	STY $2183	;set 7F as bank

	LDA !SlotPointer
	STA $4302	;low 16bits
	LDY !SlotBank
	STY $4304	;bank
	LDY #$80	;128 bytes
	STY $4305
	LDY #$01
	STY $420B	;transfer

;second line
-	LDA !SlotDestination	;update buffer dest
	CLC
	ADC #$0200	;512 byte rule for sprites
	STA !SlotDestination	;updated base
	STA $2181	;updated RAM address

	LDA !SlotPointer	;update source address
	CLC
	ADC #$0200	;512 bytes, next row
	STA !SlotPointer
	STA $4302	;low 16bits
	LDY !SlotBank
	STY $4304	;bank
	LDY #$80
	STY $4305
	LDY #$01
	STY $420B	;transfer
	LDY !Timers
	CPY #$02
	BEQ +
	INC !Timers
	BRA -
+
endif
	
	SEP #$20	;8bit A	
	INC !SlotsUsed	;one extra slot has been used

	PLA		;return starting tile number
	PLY
	RTS

SlotsTable:			;avaliable slots.  Any more transfers and it's overflowing by a dangerous amount.
	db $CC,$C8,$C4,$C0		


incbin taptap.bin -> gfx
