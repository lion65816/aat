;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; SMB3 Lakitu, by Davros (optimized by Blind Devil)
;;
;; Description: This sprite follows Mario throwing sprites. 
;; 
;; Uses first extra bit: YES
;; If the extra bit is set it will throw a custom sprite.
;;
;; Extra Property Byte 1:
;; bit 0 = sprite will have hitpoints.
;;
;; Extra Byte (Extension) 1 = spawned sprite number (if behavior is on).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Tilemap defines:
!Head1 = $EA		;moving frame 1
!Head2 = $E8		;moving frame 2
!Head3 = $C6		;spawning sprite
!Cloud1 = $C8		;cloud tile (normal)
!Cloud2 = $C8		;cloud tile (boss hit)

;Cloud palette
!CloudPal = $02		;cloud palette/properties, YXPPCCCT format

;Sprite speeds and acceleration
ACCEL_X:
db $01,$FF		;right, left

X_SPEED:
db $10,$F0		;right, left

;Spawned sprites
!UseExtension = 0	;if this is 1, the spawned sprite number will use the Extension value in LM

!NormSpr = $2B
!CustSpr = $BE

;Spawned sprite speeds
X_THROW_SPEED:
db $10,$F0		;right, left

!SpawnYSpeed = $F0	;Y speed

;Other defines:
!TimeToShow = $22	;time to display the sprite before it is thrown
TIME_TILL_THROW:
db $90,$90		;spawning intervals

;Boss defines:
!HurtSFX = $28		;SFX to play when the lakitu boss is hurt
!HurtPort = $1DFC	;port used for above SFX

!Hitpoints = $03	;amount of HP for the lakitu boss
!StunTimer = $28	;how long lakitu will be stunned after being hit
!DisableScroll = 1	;if 1, horizontal/vertical scroll is disabled when this sprite appears
!BossMusic = $05	;if non-zero, music will change to this value when this sprite appears
!EndLevel = 1		;if 1, sprite will trigger level ending when defeated
!EndMusic = $0B		;music to play when level end is triggered

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "INIT ",pc
		    LDA TIME_TILL_THROW
		    STA !1558,x

		    LDA !7FAB28,x	    ;load extra property 1
		    AND #$01		    ;check if bit 0 is set
		    BEQ +		    ;if not set, skip ahead.

if !BossMusic != $00
                    LDA #!BossMusic         ; \ start the boss music
                    STA $1DFB|!Base2        ; /
endif

if !DisableScroll
                    STZ $1411|!Base2        ; no horizontal scroll
                    STZ $1412|!Base2        ; no vertical scroll
endif

+
                    RTL

                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR SPRITE_CODE_START   ;  |
                    PLB                     ;  |
                    RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

KILLED_X_SPEED:     db $F0,$10

RETURN:             RTS

SPRITE_CODE_START:  JSR SUB_GFX             ; graphics routine

		    LDA !7FAB28,x	    ;load extra property 1
		    AND #$01		    ;check if bit 0 is set
		    BEQ +		    ;if not set, skip ahead.

		    JSR PROCESS_CACHED_HIT

if !EndLevel
                    LDA $1493|!Base2
                    BNE RETURN
                    LDA $13C6|!Base2
                    BNE RETURN
endif

                    LDA !14C8,x             ; \ 
		    BNE ALIVE

if !EndLevel
	            DEC $13C6|!Base2        ; prevent Mario from walking at the level end
		    LDA #$FF                ; \ set goal
		    STA $1493|!Base2        ; /
		    LDA #!EndMusic          ; \ set ending music
		    STA $1DFB|!Base2        ; /
                    RTS                     ; return
endif

+
                    LDA !14C8,x             ; \
ALIVE:
                    CMP #$08                ;  | if status != 8, return
                    BNE RETURN              ; /
                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

		    LDA #$00
		    %SubOffScreen()

		    LDA !7FAB28,x	    ;load extra property 1
		    AND #$01		    ;check if bit 0 is set
		    BNE IsBoss		    ;if set, branck to boss code.
		    JMP NotBoss		    ;else jump - not a boss.
IsBoss:
                    INC !1570,x             ;increment number of frames the sprite has been on screen

	            LDA !C2,x               ; \ if the sprite state is set
	            BEQ NORMAL_STATE        ; /
	            LDA !1570,x             ; \ calculate which frame to show:
                    LSR #3                  ;  | 
                    AND #$01                ;  | update every 16 cycles if normal
	            CLC                     ;  |
	            ADC #$04                ;  |
                    STA !1602,x             ; / write frame to show

	            LDA !1564,x		    ; If the sprite has been hit, set the stunned image
	            BEQ RESTORE

	            INC !1540,x             ; increase timer
	            STZ !B6,x               ; no x speed
	            JMP NO_Y_SPEED
	
RESTORE:            STZ !C2,x               ; restore sprite state
	
NORMAL_STATE:       LDA !1540,x             ; \ if the timer is set...
	            BEQ DONE_DEC            ; /
	            DEC !1540,x             ; decrease timer

DONE_DEC:           LDA !151C,x
                    AND #$01
                    BEQ LABEL3
                    LDA !1570,x             ; \ calculate which frame to show:
                    LSR #3                  ;  | 
                    AND #$01                ;  | update every 16 cycles if normal
LABEL3:             STA !1602,x             ; / write frame to show

                    LDA $14                 ; \ make tilemap animated
                    LSR #3                  ;  |
                    CLC                     ;  |
                    ADC $15E9|!Base2        ;  |
                    AND #$01                ;  |
                    STA !1602,x             ; /
		    BRA ThrowHandle

NotBoss:
                    LDA $14                 ; \ make tilemap animated
                    LSR #3                  ;  |
                    CLC                     ;  |
                    ADC $15E9|!Base2        ;  |
                    AND #$01                ;  |
                    STA !1602,x             ; /      

ThrowHandle:
                    LDA !1558,x             ; \ if time until throw < !TimeToShow
                    CMP #!TimeToShow        ;  |
                    BCS NO_THROW            ; / 
                    LDA $14                 ; \ 
                    LSR                     ;  |
                    CLC                     ;  |
                    ADC $15E9|!Base2        ;  |
                    AND #$01                ;  |
                    STA !1602,x  	    ;  |
                    INC !1602,x             ;  | change image
                    INC !1602,x             ; /

                    LDA !1558,x             ; \ throw sprites if it's time
                    BNE NO_RESET3           ;  |
                    LDY !C2,x		    ;  |
                    LDA TIME_TILL_THROW,y   ;  | set the timer
                    STA !1558,x		    ; /
NO_RESET3:
	            CMP #$01                ; \ call the sprite routine if the timer is 
                    BNE NO_THROW            ; / about to turn out
                    LDA !C2,x               ; \ handle multiple throws
                    EOR #$01                ;  |
                    STA !C2,x               ; /

		    STZ $00		    ;no X displacement
		    STZ $01		    ;no Y displacement

		    LDY !157C,x		    ;load sprite direction into Y
		    LDA X_THROW_SPEED,y	    ;get X speed from table according to index
		    STA $02		    ;store to scratch RAM.

		    LDA #!SpawnYSpeed	    ;load Y speed
		    STA $03		    ;store to scratch RAM.

if !UseExtension == 0
                    LDA !7FAB10,x	    ; \ throw custom sprite if the extra bit is set
                    AND #$04                ;  |
                    BNE CUSTOM_SPRITE       ; /

		    LDA #!NormSpr
		    CLC
		    BRA Spawn

CUSTOM_SPRITE:
		    LDA #!CustSpr
		    SEC
else
		    LDA !7FAB40,x	    ;load extra byte (extension) 1
		    PHA			    ;preserve onto stack

                    LDA !7FAB10,x	    ; \ throw custom sprite if the extra bit is set
                    AND #$04                ;  |
                    BNE CUSTOM_SPRITE       ; /

		    PLA			    ;restore extension value from stack
		    CLC
		    BRA Spawn

CUSTOM_SPRITE:
		    PLA
		    SEC
endif

Spawn:
		    %SpawnSprite()

NO_THROW:	    JSL $01803A|!BankB

		    %SubHorzPos()	    ; \ always face Mario
		    TYA                     ;  |
		    STA !157C,x             ; /

		    LDA $14                 ; \ calculate frame
		    AND #$03                ;  |
		    BNE HORZ_SPEED          ; /
		    LDA !B6,x               ; \ compare x speed
		    CMP X_SPEED,y           ;  |
		    BEQ HORZ_SPEED          ;  |
		    CLC                     ;  |
		    ADC ACCEL_X,y           ;  | set up acceleration
		    STA !B6,x               ; /

HORZ_SPEED:	    LDA !B6,x
		    PHA
		    LDA $17BD|!BankB
		    ASL #3
		    CLC
		    ADC !B6,x
		    STA !B6,x
		    JSL $018022|!BankB
		    PLA
		    STA !B6,x

NO_Y_SPEED:
	            STZ !AA,x               ; no y speed
		    JSL $01802A|!BankB      ; update position based on speed values

NO_CONTACT:	    JSL $018032|!BankB      ; interact with sprites

		    LDA !7FAB28,x	    ;load extra property 1
		    AND #$01		    ;check if bit 0 is set
		    BEQ +		    ;if not set, skip ahead.

		    LDA !1FE2,x		    ;load sprite stunned timer
		    BNE +		    ;if not zero, disable contact.

		    JSR SPRITE_INTERACT	    ;thrown sprite hitpoints routine

+
		    JSL $01A7DC|!BankB      ; check for Mario/sprite contact (carry set = contact)
                    BCC RETURN_24           ; return if no contact

                    %SubVertPos()	    ; 
                    LDA $0E                 ; \ if Mario isn't above sprite, and there's vertical contact...
                    CMP #$E6                ;  |     ... sprite wins
                    BPL SPRITE_WINS         ; /
                    LDA $7D                 ; \ if Mario speed is upward, return
                    BMI RETURN_24           ; /

		    LDA !7FAB28,x
		    AND #$01
		    BNE BossHurt
                  
		    LDA $140D|!Base2        ; \ if Mario is spin jumping, goto SPIN_KILL		    
		    BNE SPIN_KILL           ; /

SPRITE_WINS:        LDA !154C,x             ; \ if riding sprite...
                    ORA !15D0,x             ;  |   ...or sprite being eaten...
                    BNE RETURN_24           ; /   ...return
                    LDA $1490|!Base2        ; \ if Mario star timer > 0, goto HAS_STAR 
                    BNE HAS_STAR            ; / NOTE: branch to RETURN_24 to disable star killing
		    JSL $00F5B7|!BankB      ; hurt Mario                  
RETURN_24:          RTS                     ; final return
         
SPIN_KILL:          JSR SUB_STOMP_PTS       ; give Mario points
                    JSL $01AA33|!BankB      ; set Mario speed, NOTE: remove call to not bounce off sprite
                    JSL $01AB99|!BankB      ; display contact graphic
                    LDA #$04                ; \ status = 4 (being killed by spin jump)
                    STA !14C8,x             ; /   
                    LDA #$1F                ; \ set spin jump animation timer
                    STA !1540,x             ; /
                    JSL $07FC3B|!BankB      ; show star animation
                    LDA #$08                ; \ play sound effect
                    STA $1DF9|!Base2        ; /
                    RTS                     ; return

BossHurt:
                    LDA $1490|!Base2        ; \ if Mario star timer > 0 ...
                    BNE HAS_STAR            ; /    ... goto HAS_STAR
                    LDA !154C,x             ; \ if sprite invincibility timer > 0 ...
                    BNE RETURN_24           ; /    ... goto NO_CONTACT
                    LDA #$08                ; \ sprite invincibility timer = $08
                    STA !154C,x             ; /
                    LDA $7D                 ; \  if Mario's y speed is upwards
                    BMI SPRITE_WINS         ; /  sprite wins.

		    LDA !1FE2,x		    ;load sprite stunned timer
		    ORA !1564,x		    ;OR with stunned pose timer
		    BNE RETURN_24	    ;if not zero, disable contact.
	            JSR SUB_STOMP_PTS       ; give Mario points
                    JSL $01AA33|!BankB      ; set Mario speed
                    JSL $01AB99|!BankB      ; display contact graphic
		    LDA #!HurtSFX           ; \ Play sound effect 
                    STA !HurtPort|!Base2    ; /
	            LDA #$01		    ; \ Set stunned state
	            STA !C2,x               ; /
	            LDA #$20		    ; \ Set stunned timer
	            STA !1564,x             ; /
                    INC !1534,x             ; increment sprite hit counter
                    LDA !1534,x             ; \ if sprite hit counter
                    CMP #!Hitpoints         ;  |   
                    BCC SMUSH_SPRITE        ; /

	            LDA #$04                ; \ write frame to show
                    STA !1602,x             ; / 
                    LDA #$02                ; \ set sprite status   
                    STA !14C8,x             ; /
                    STZ !B6,x               ; no x speed
                    LDA #$10                ; \ set y speed
                    STA !AA,x               ; /
                    RTS                     ; return

HAS_STAR:
                    LDA KILLED_X_SPEED,y    ; \ set x speed based on direction
                    STA !B6,x               ; /
		    %Star()
		    RTS                     ; final return

SMUSH_SPRITE:       LDA #!StunTimer         ; \ time to show smushed sprite
                    STA !1FE2,x             ; /
                    LDA !157C,x             ; \ change direction
                    EOR #$01                ;  |            
                    STA !157C,x             ; /
                    RTS                     ; return

SPRITE_INTERACT:    LDY #!SprSize-1         ; sprite is being kicked
INTERACT_LOOP:      LDA !14C8,y             ; \ if the sprite status is..
	            CMP #$09                ;  | ...shell-like
	            BCS PROCESS_SPRITE      ; /
NEXT_SPRITE:        DEY
	            BPL INTERACT_LOOP
	            RTS

PROCESS_SPRITE:     PHX                       
                    TYX                       
                    JSL $03B6E5|!BankB      ; get sprite clipping B routine   
                    PLX                       
                    JSL $03B69F|!BankB      ; get sprite clipping A routine  
                    JSL $03B72B|!BankB      ; check for contact routine
	            BCC NEXT_SPRITE

	            PHX
	            TYX
	
	            JSL $01AB72|!BankB      ; show sprite contact gfx routine

	            LDA #$02		    ; \ Kill thrown sprite
	            STA !14C8,x             ; /
	
	            LDA #$D0                ; \ Set killed Y speed
                    STA !AA,x               ; /
	
	            LDY #$00		    ; Set killed X speed
	            LDA !B6,x
	            BPL SET_SPEED
	            INY 

SET_SPEED:	    LDA KILLED_X_SPEED,y
	            STA !B6,x

NO_KILL:            PLX

HANDLE_HIT:
		    LDA #!HurtSFX           ; \ Play sound effect 
                    STA !HurtPort|!Base2    ; /

	            LDA #$01		    ; \ Set stunned state
	            STA !C2,x               ; /
	
	            LDA #!StunTimer	    ; \ Set stunned timer
	            STA !1564,x             ; /
		
	            INC !1534,x	            ; Increase hit counter and... 
	            LDA !1534,x	            ; \ Check if the sprite has been hit X times
	            CMP #!Hitpoints         ; /
	            BCC RETURN3

	            LDA #$02		    ; \ Kill sprite
	            STA !14C8,x             ; /

	            LDA #$D0		    ; \ Set killed Y speed
                    STA !AA,X               ; /
	            TYA			    ; Set killed X speed
	            EOR #$01
	            TAY
	            LDA KILLED_X_SPEED,y
	            STA !B6,x

	            LDA #$04                ; \ write frame to show
                    STA !1602,x             ; / 
RETURN3:            RTS

PROCESS_CACHED_HIT:
		    LDA !1534,x
	            BPL RETURN3
	            AND #$7F
	            STA !1534,x
	            BRA HANDLE_HIT

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

VERT_DISP:          db $00,$10
TILEMAP:            db !Head1,!Cloud1,!Head2,!Cloud1,!Head3,!Cloud1,!Head3,!Cloud1,!Head2,!Cloud2,!Head2,!Cloud2

SUB_GFX:            %GetDrawInfo()          ; after: Y = index to sprite tile map ($300)
                                            ;      $00 = sprite x position relative to screen boarder 
                                            ;      $01 = sprite y position relative to screen boarder  

		    LDA !15F6,x		    ;load palette/properties from CFG
		    STA $05		    ;store to scratch RAM.
		    AND #$F1		    ;clear palette bits
		    ORA #!CloudPal	    ;set user-defined palette bits
		    STA $06		    ;store to scratch RAM.

                    LDA !1602,x             ; \
                    ASL                     ;  | $03 = index to frame start (frame to show * 2 tile per frame)
                    STA $03                 ; /
                    LDA !157C,x             ; \ $02 = sprite direction
                    STA $02                 ; /
                    PHX                     ; push sprite index
                 
                    LDX #$01                ; loop counter = (number of tiles per frame) - 1
LOOP_START:         PHX                     ; push current tile number
                    TXA                     ; \ X = index to horizontal displacement
                    ORA $03                 ; / get index of tile (index to first tile of frame + current tile number)
		    TAX

                    LDA $00                 ; \ tile x position = sprite x location ($00)
                    STA $0300|!Base2,y      ; /

		    PHX
		    TXA
		    AND #$01
		    TAX
                    LDA $01                 ; \ tile y position = sprite y location ($01) + tile displacement
                    CLC                     ;  |
                    ADC VERT_DISP,x         ;  |
                    STA $0301|!Base2,y      ; /
		    PLX

                    LDA TILEMAP,x           ; \ store tile
                    STA $0302|!Base2,y      ; / 

		    PHX
		    TXA
		    AND #$01
		    BEQ GetHeadProp

		    LDA $06
		    BRA StoreProp

GetHeadProp:
		    LDA $05
StoreProp:
                    ORA $64                 ;  | put in level properties
                    STA $0303|!Base2,y      ; / store tile properties
		    PLX

                    PLX                     ; \ pull, X = current tile of the frame we're drawing
                    INY                     ;  | increase index to sprite tile map ($300)...
                    INY                     ;  |    ...we wrote 1 16x16 tile...
                    INY                     ;  |    ...sprite OAM is 8x8...
                    INY                     ;  |    ...so increment 4 times
                    DEX                     ;  | go to next tile of frame and loop
                    BPL LOOP_START          ; / 

                    PLX                     ; pull, X = sprite index
                    LDY #$02                ; \ 460 &= 2 16x16 tiles maintained
                    LDA #$01                ;  | A = number of tiles drawn - 1
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; points routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

STAR_SOUNDS:        db $00,$13,$14,$15,$16,$17,$18,$19

SUB_STOMP_PTS:      PHY                     ; 
                    LDA $1697|!Base2        ; \
                    CLC                     ;  | 
                    ADC !1626,x             ; / some enemies give higher pts/1ups quicker??
                    INC $1697|!Base2        ; increase consecutive enemies stomped
                    TAY                     ;
                    INY                     ;
                    CPY #$08                ; \ if consecutive enemies stomped >= 8 ...
                    BCS +	            ; /    ... don't play sound from table
                    LDA STAR_SOUNDS,y       ; \ play sound effect
		    BRA ++
+
		    LDA #$02		    ;sound effect for 8+ stomps
++
                    STA $1DF9|!Base2        ; /
          	    TYA                     ; \
                    CMP #$08                ;  | if consecutive enemies stomped >= 8, reset to 8
                    BCC NO_RESET            ;  |
                    LDA #$08                ; /
NO_RESET:           JSL $02ACE5|!BankB      ; give mario points
                    PLY                     ;
                    RTS                     ; return