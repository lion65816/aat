;===============================================================================
; Gift sprite
; by Koba
;
; Input:
; Insert sprite number in Extension byte 1.
; Insert 1 in Extension byte 2 for custom sprite.
; Can be kicked back by blue koopas if thrown or kicked (thought that was a cute touch to keep from blue blocks).
;
; Example of usage:
; 02 00 00 00 = spawns sprite 2.
; 02 01 00 00 = spawns custom sprite 2.
;===============================================================================

;===============================================================================
; Comment:
; Special shout out to JUMP Team, the birthday sublevel in YUMP 2
; Kudos to fucking RussianMan for demystifying this shit with his throw block disassembly yeehaw
; Forgive me I'm mentally defective
;
; I could be drawing shitty bara or garbage male macro/micro rn lmao 凸(`△´＋)
; but alas... i cannot make a level without tryharding in asm a bit
; I'm terrible at art anyway
;
; k, i did like two main ow levels (Demo in the Sky, Wolfenstein) but they're pretty bad lol
;===============================================================================

;===============================================================================
; Defines, these exist to make the code easier to read for normal people who
; don't code in goddamned assembly asdkljasdkljlasdj
;===============================================================================

; ROM Addresses
    !UpdateXYwGravity = $01802A|!bank

; RAM Addresses
    !SpriteBlocked = !1588
    !VerticalSpeed = !AA
    !SpriteXPosLo = !E4
    !SpriteXPosHi = !14E0
    !SpriteYPosLo = !D8
    !SpriteYPosHi = !14D4
    !CurrentInteractBlockXLo = $9A
    !CurrentInteractBlockXHi = $9B
    !CurrentInteractBlockYLo = $98
    !CurrentInteractBlockYHi = $99
    !LayerBeingProcessed = $1933|!addr

; Sprite blocked table values.
    !IsOnFloor = #$04
    !IsUnderCeiling = #$08
    !IsBlockedOnSides = #$03
    !HitLayer2FromBelow = #$20

; Vertical Speed Values.
    !FallSpeed = #$10

; Center Interaction Values.
    !SetToCenterX = #$08
    !SetToCenterY = #$F0
    
; Layer 1 or 2 value AND gate filter.
    !Layer1OrLayer2 = #$01

;===============================================================================
; init and main who crares
;===============================================================================

print "INIT ",pc
    RTL

; what is the deal with russianman doing so many x but they can now explode or leave a fire trail sprites?
; are they really that useful for level design (stand. /and/ kazio [sic]) for people to be requesting so many?
; absolutely no offense, i just think it's funny
    
; This is where it goes after doing the initialization routine, as it usually spawns in carriable form.
print "CARRIABLE",pc
    PHB : PHK : PLB
    JSR SpriteCode
    PLB
    RTL

; This is where it goes once the gift is kicked.
; i was gonna reference kick the can from one of the psx ddrs but i actually don't like that song lol so
print "KICKED",pc
    PHB : PHK : PLB
    JSR KickedCode
    PLB
    RTL

; tiger YAMATO — Hold on me [ParaParaParadise 2nd Mix] - YouTube
; This is where it goes once Ma- Demo grabs onto it with her gross leg nubs (do they have suction cups? i dont care about canon)
Print "CARRIED",pc
    PHB : PHK : PLB
    JSR CarriedCode
    PLB
    RTL

;===============================================================================
; !!!!!!!!!!!!!!!!!!!!!!!
; NORMAL PHASE, CARRIABLE
; !!!!!!!!!!!!!!!!!!!!!!!
;===============================================================================

SpriteCode:
    LDA !SpritesLocked              ; Is the game pausing due to getting a mushroom or whatever?
    BEQ .continue                   ; If not (SpritesLocked = 0), then continue.
    JMP .GraphicsRoutine            ; Otherwise, just draw graphics.

.continue
    JSR HandleStun                  ; Run the stun handling routine.
    
; Excuse me for swiping your label names here and there, Russ, they're just simple and clean (partially accidental reference).
    
    JSR !UpdateXYwGravity           ; Update position, while accounting for gravity.
    
    LDA !SpriteBlocked,x            ; \ Is sprite blocked below it?
    AND !IsOnFloor                  ; / In other words, is it on a platform?
    BEQ .notOnFloor                 ; If not (return 0 on bit 2), then skip ahead.
    
    JSR HandleGroundBounce          ; Handle the Ground bouncing routine over yonder if it is.
    
.notOnFloor
    LDA !SpriteBlocked,x            ; \ Is sprite blocked above it?
    AND !IsUnderCeiling             ; / In other words, is there a ceiling directly above it?
    BEQ .notUnderCeiling            ; If not (return 0 on bit 3), then skip ahead. 

    LDA !FallSpeed                  ; Set fall speed to rebound from ceiling.
    STA !VerticalSpeed,x

    LDA !SpriteBlocked,x            ; \ Is sprite blocked on its sides.
    AND !IsBlockedOnSides           ; / In other words, is there a wall anywhere directly next to it?
    BNE .notUnderCeiling            ; If so  (return 1 on bit 0 or 1), then skip ahead.
    
;=========
    
; Center interaction point on block.
; Takes the Sprite's X position + 8 pixels and the sprite's Y position,
; sent through an AND gate with F0, which only allows values 0 through F
; and mirrors it to 98 through 9B, which process the collision point
; currently being processed for block interaction with the player.
    
    LDA !SpriteXPosLo,x
    CLC : ADC !SetToCenterX
    STA !CurrentInteractBlockXLo
    
    LDA !SpriteXPosHi,x
    ADC #$00
    STA !CurrentInteractBlockXHi
    
    LDA !SpriteYPosLo,x
    AND !SetToCenterY
    STA !CurrentInteractBlockYLo
    
    LDA !SpriteYPosHi,x
    STA !CurrentInteractBlockYHi
    
;=========
    
; Process layer 2
    
    LDA !SpriteBlocked,x
    AND !HitLayer2FromBelow
    ASL #3  ;<--- if hit from below, $20 is shifted into the carry flag by this,
    ROL     ;<--- and this shifts it from the carry flag to $01.
    AND !Layer1OrLayer2
    STA !LayerBeingProcessed    ; Checks which Layer is currently being processed depending on current value,
                                ; 1 if Layer 2
                                ; 0 if Layer 1


;===============================================================================
; !!!!!!!!!!!!
; KICKED PHASE
; !!!!!!!!!!!!
;===============================================================================

;===============================================================================
; !!!!!!!!!!!!!!!!!!!
; BEING CARRIED PHASE
; !!!!!!!!!!!!!!!!!!!
;===============================================================================

; I wanna look at bara art...