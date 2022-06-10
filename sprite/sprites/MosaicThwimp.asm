;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Mosaic Thwimp
; by Mandew
;
; Mosaic Thwimp will go a direction until it hits a wall,
; then it will wait,
; then it will turn around and repeat process.
;
; Extra bit: yes
;  If set, goes up and down instead of left and right.
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; DEFINES

!Speed = $10		;
!TimeToWait = $18	; both costumizable

; GRAPHICS

!Tile = $A2

; SPRITE TABLES

!SpriteYSpeed = !AA
!SpriteXSpeed = !B6
!SpriteBehavior	= !C2
!SpriteStatus = !14C8
!SpriteStunTimer = !1528
!SpriteObjectsStatus = !1588
!SpriteSlopeStatus = !15B8
!SpriteYPosLo = !D8
!SpriteYPosHi = !14D4
!ExtraBits = !7FAB10
!HorizontalDirection = !157C

; ENGINE

!LockFlag = $9D

; ROUTINES
!MarioInteract = $01A7DC
!UpdateYPos = $01801A
!UpdateXPos = $018022
!ObjectsInteract = $019138

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CODE START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


print "INIT ",pc
	LDA #$01
	STA !HorizontalDirection,x
	RTL
print "MAIN ",pc
	PHB
	PHK
	PLB                     
	JSR MainCode 
	PLB
	RTL

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Return:
	LDA #$01                ;x movement related
	JSL $018042	; I don't know what this is for, but it sounds important
	RTS

MainCode:
	JSR DrawGFX

	LDA !SpriteStatus,x
	CMP #$08
	BNE Return
	LDA !LockFlag
	BNE Return

    LDA #$00
	%SubOffScreen()
	JSL !MarioInteract
	JSL !UpdateYPos
	JSL !UpdateXPos
	JSL !ObjectsInteract

	LDA !SpriteBehavior,x
	BEQ GoWhicheverWay

	JSR WaitForTime	
	LDA #$01                ;x movement related
	JSL $018042	; I don't know what this is for, but it sounds important
	RTS

GoWhicheverWay:
	LDA !ExtraBits,x
	AND #$04
	BNE UpDown

LeftRight:
	JSR MosaicLR
	LDA #$01                ;x movement related
	JSL $018042	; I don't know what this is for, but it sounds important
	RTS

UpDown:
	JSR MosaicUD
	LDA #$01                ;x movement related
	JSL $018042	; I don't know what this is for, but it sounds important
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;


WaitForTime:
	LDA !SpriteStunTimer,x
	DEC
	STA !SpriteStunTimer,x
	BNE ReturnWait
	STZ !SpriteBehavior,x
	LDA !HorizontalDirection,x
	EOR #$01
	STA !HorizontalDirection,x

ReturnWait:
	RTS


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LRSpeeds:
	db !Speed,256-!Speed

MosaicLR:
	LDY !HorizontalDirection,x
	LDA LRSpeeds,y
	STA !SpriteXSpeed,x

	CPY #$00
	BNE CheckRight

CheckLeft:
	LDA !SpriteObjectsStatus,x
	AND #$01
	BEQ ReturnLR
	BRA StopLR

CheckRight:
	LDA !SpriteObjectsStatus,x
	AND #$02
	BEQ ReturnLR
StopLR:
	JSR StopTime
ReturnLR:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

UDSpeeds:
	db !Speed,256-!Speed

MosaicUD:
	LDY !HorizontalDirection,x
	LDA UDSpeeds,y
	STA !SpriteYSpeed,x

	CPY #$00
	BNE CheckDown

CheckUp:
	LDA !SpriteObjectsStatus,x
	AND #$04
	BEQ ReturnUD
	BRA StopUD

CheckDown:
	LDA !SpriteObjectsStatus,x
	AND #$08
	BEQ ReturnUD
StopUD:
	JSR StopTime
ReturnUD:
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

StopTime:
	STZ !SpriteXSpeed,x
	STZ !SpriteYSpeed,x
	INC !SpriteBehavior,x
	LDA #!TimeToWait
	STA !SpriteStunTimer,x
	RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; GENERIC GRAPHICS ROUTINE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawGFX:            %GetDrawInfo() 
                   
                    LDA $00                 ; set x position of the tile
                    STA $0300|!Base2,y

                    LDA $01                 ; set y position of the tile
                    STA $0301|!Base2,y

                    LDA #!Tile
                    STA $0302|!Base2,y

                    LDA !15F6,x             ; get sprite palette info
                    ORA $64                 ; add in the priority bits from the level settings
                    STA $0303|!Base2,y             ; set properties

                    LDY #$00                ; #$02 means the tiles are 16x16
                    LDA #$00                ; This means we drew one tile
                    JSL $01B7B3
                    RTS