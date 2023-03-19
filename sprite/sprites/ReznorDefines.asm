;========================================================================================;
; REZNOR DEFINES                                                                         ;
; You can edit these as you need.                                                        ;
; Keep this file in the same folder as CustomReznor.asm (and don't change its name!).    ;
;                                                                                        ;
; When editing position values, keep in mind that $10 is equal to a 16x16 tile length.   ;
; Also, the "Lo" values define the position within a level screen, while the "Hi" values ;
; define the screen number (the "Right" subscreen in vertical levels corresponds to      ;
; XPosHi = $01, while the "Bottom" in horizontal levels corresponds to YPosHi = $01).    ;
;========================================================================================;

!QuickKill          =   !false  ; false = when killed, a dead falling Reznor is spawned (vanilla behavior)
                                ;  true = when killed, Reznor simply disappears. Use this if with the other
                                ; option the game lags or you get dead floating Reznors.

!AlsoKillPlatforms  =   !true   ; false = when killed, the platform below the dead Reznor keeps rotating and it is solid (vanilla behavior).
                                ;  true = when killed, the platform below the dead Reznor disappears as well.

; Change these values when the extra bit is set. The door is always spawned above the cement block.
!DoorTimer          =   $30     ; When all Reznors are dead, how much time to wait before spawning the door? (must be at least $02)
!CementXPosLo       =   $80     ;\ X and Y position of the cement block that spawns.
!CementYPosLo       =   $80     ;|
!CementXPosHi       =   $00     ;|
!CementYPosHi       =   $00     ;/

; Change these values when the extra bit is not set.
!EndLevelTimer      =   $90     ; When all Reznors are dead, how much time to wait before ending the level? (must be at least $02)
!BossClearMusic     =   $03     ; $03 if using AddmusicK, $0B if not.

!ReznorHP           =   $01     ; Hit points of Reznor.
!MarioDamage        =   $01     ; How many HP are subtracted when Mario hits the platform under Reznor.
!SpriteDamage       =   $00     ; How many HP are subtracted when a kicked sprite hits Reznor.
                                ; Note that Reznor's hitbox includes the platform!

!SpeedMultiplier    =   $0002   ; $0000 = Reznors don't move
                                ; $0001 = normal speed
                                ; $0002,... = normal speed is multiplied by the value you set
                                ; $FFFF = normal speed but the rotation is counterclockwise.
                                ; $FFFE,... = normal speed is multiplied and the rotation is counterclockwise.

!DivideSpeedBy      =   $01     ; This sets how many frames pass between each position update, effectively dividing
                                ; the rotation speed. Use it to have a more granular control of the rotation speed.
                                ; $00 or $01 will just keep the speed as set in !SpeedMultiplier.
                                ; Note that high value of this will make the Reznors look "laggy".

!CenterXPosLo       =   $F0     ;\ X and Y position of the center of rotation.
!CenterYPosLo       =   $80     ;| Note that the position in which they're placed in LM defines when they
!CenterXPosHi       =   $00     ;| will spawn, and then they'll be placed at the position defined here.
!CenterYPosHi       =   $00     ;/

; Radius defines. Values can go from $00 to $7F (from $80 to $FF are negative).
; Keep !MinRadius  equal to !MaxRadius if you want the circle to have a constant
; radius (equal to that value). If they're different, the circle radius will change
; from !MinRadius to !MaxRadius and viceversa, with an increase/decrease of 1
; every !UpdateDelay frames. Obviously you want to have !MinRadius smaller than !MaxRadius.
; !UpdateDelay is relevant only if !MinRadius and !MaxRadius are different.
!MinRadius          =   $42
!MaxRadius          =   $42
!UpdateDelay        =   $0A
!DoubleRadius       =   !false  ; If you want even higher radius values.

!ReboundSpeedX      =   $20,$E0 ; X speed that Mario gets when touching the grey platforms from the sides.
!ReboundSpeedY      =   $10     ; Y speed that Mario gets when hitting the platform from below.

!ShootFireballs     =   !true   ; false = Reznors never shoot. 
                                ;  true = Reznors shoot fireballs.

!FireballSpeed      =   $30     ; How fast are the fireballs? 

!FireballDelay      =   $CF     ; This value sets the number of frames between the shots of each Reznor.
                                ; Lower values = more frequent shots (lower value allowed is $21).
                                ; Note that the first shot always takes a longer time than this.

!ShootingAnimation  =   $40     ; This value sets for how many frames Reznor will keep his mouth open
                                ; after shooting a fireball ($40 is the normal value).
                                ; In practice this value should be lower than !FireballDelay
                                ; (or the Reznors will keep their mouths always open)
                                ; and greater than $20 (otherwise Reznor will never shoot at all).

!FireballRNG        =   !true   ; false = no RNG, which means all the Reznors will always shoot simultaneously
                                ;  true = normal behavior


!StopWithSwitch     =   !false  ; false = normal behavior
                                ;  true = Reznor will stop rotating when a specific switch is inactive
                                ; (or active, if you change !Reversed). The kind of switch is given by !Switch.

!Switch             =   $14AF   ; This sets which switch will control Reznor.
                                ; Possible values:
                                ;    $14AD = Blue P-Switch, $14AE = Silver P-Switch
                                ;    $14AF = ON/OFF Switch
                                ;    $1F27 = Green Switch, $1F28 = Yellow Switch
                                ;    $1F29 = Blue Switch, $1F2A = Red Switch

!Reversed           =   !false  ; Reverse the switch condition? (so if in one case Reznors move with the
                                ; switch active, in the other case they move with the switch inactive).


;======================================================================================;
; BREAK BRIDGE ROUTINE DEFINES                                                         ;
; These control if to use the vanilla bridge breaking routine and when to call it.     ;
; Note that the routine itself cannot be changed without an external patch.            ;
;======================================================================================;

!BreakBridge        =   !false  ; Whether to call the bridge breaking routine.
!WhenCountLowerThan =   $03     ; When the alive Reznors count is strictly lower than this, the routine will be called.


;======================================================================================;
; FREERAM DEFINES                                                                      ;
; These are the freeram addresses used by the sprite (they all are 1 byte).            ;
; Edit them if you have some freeram conflict with another sprite/patch/whatever.      ;
;======================================================================================;

!ReznorCounter      =   $7C         ; Always used. Must be an address which is reset on level load.
!TotReznor          = $0DA1|!Base2  ; Always used.
!EndTimerRam        = $13E6|!Base2  ; Always used.
!FreeRam            = $0DD4|!Base2  ; Only used if !DivideSpeedBy is greater than $01.
!FreeRam2           = $13C8|!Base2  ;\ Only used if !MinRadius is different from !MaxRadius.
!RadiusRam          = $15E8|!Base2  ;|
!RadiusTimer        = $0D9C|!Base2  ;/


;======================================================================================;
; OTHER DEFINES                                                                        ;
; It's unlikely that you'll need to edit these.                                        ;
;======================================================================================;

!Mode7              = !false    ; Set to !true only if you want to use Reznor with mode 7, which is the
                                ; special mode used when the level header is 09 to show the rotating spinning sign.
                                ; Note that the sign properties are already set by Reznor's properties.

!DoorUpperTile      = $001F     ;\ Map16 values for door and cement tiles.
!DoorLowerTile      = $0020     ;|
!CementTile         = $0130     ;/
