;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Goal Point Question Sphere, adapted by Davros (optimized by Blind Devil)
;;
;; Description: This sprite will cause the level to end when Mario comes in contact with
;; it.
;;
;; Uses first extra bit: YES (behavior depends on Extra Property Byte 2, more info below)
;;
;; Extra Property Byte 1 properties (configured through CFG):
;; > bit 0 = enable sparkles
;; > bit 1 = enable gravity for sprite (it falls on the ground like in SMB3)
;; > bit 2 = enable level end march
;;
;; Extra Property Byte 2 properties (configured through CFG):
;; > bit 0 = enable changing player's position on the overworld
;;
;; Extra Bit properties for when NOT using the above property:
;; > clear = sprite triggers normal exit
;; > set = sprite triggers secret exit
;;
;; Extra Bit properties for when *using* the above property:
;; > clear = warp player to coordinates set in destination 1
;; > set = warp player to coordinates set in destination 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Defines
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;TILEMAP
;What tile to use for the goal sphere. Tile is X-flipped by default.
	!Tilemap = $8A
;	!Tilemap = $8C

;LEVEL END MUSIC
;What song to play when the goal sphere is collected.
	!Music = $03
;	!Music = $0B

;OVERWORLD DESTINATION 1
;Where to warp the player in the overworld if warping property is on and extra bit is clear.
;To find out X and Y coordinates, you can take a look at OWCoordDiagram.png (URL in readme.txt).
;Submap values can be:
;$00=Main map, $01=Yoshi's Island, $02=Vanilla Dome, $03=Forest of Illusion,
;$04=Valley of Bowser, $05=Special World, $06=Star World.
	!OWSubmap1 = $01
	!OWXCoord1 = $0068
	!OWYCoord1 = $0078

;OVERWORLD DESTINATION 2
;Where to warp the player in the overworld if warping property is on and extra bit is set.
;To find out X and Y coordinates, you can take a look at OWCoordDiagram.png (URL in readme.txt).
;Submap values can be:
;$00=Main map, $01=Yoshi's Island, $02=Vanilla Dome, $03=Forest of Illusion,
;$04=Valley of Bowser, $05=Special World, $06=Star World.
	!OWSubmap2 = $04
	!OWXCoord2 = $0198
	!OWYCoord2 = $0058

;EVENT NUMBER
;What event should be triggered in the overworld if warping property is on.
;$FF means that no event will be run.
	!Event = $FF

;USE OW LEVEL SETTING FLAG FIX
;If you insert the UberASMTool code to fix the issue related to walking direction/level beaten
;flags, this should be set to 1. Otherwise, you can leave this as zero.
	!UseOWPropFix = 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite code JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    print "MAIN ",pc
                    PHB                     ; \
                    PHK                     ;  | main sprite function, just calls local subroutine
                    PLB                     ;  |
                    JSR SPRITE_CODE_START   ;  |
                    PLB                     ;  |
                    print "INIT ",pc        ;  |
                    RTL                     ; /

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SPRITE_CODE_START:
		JSR SUB_GFX             ; graphics routine

		LDA #$03
		%SubOffScreen()

                    LDA $9D                 ; \ if sprites locked, return
                    BNE RETURN              ; /

		LDA !7FAB28,x		;load extra property byte 1
		AND #$02		;check if bit is set
		BEQ NoGravity		;if not, don't enable gravity (sprite will float in midair).

                    LDA !1588,x             ; \ if on the ground, reset the turn counter
                    AND #$04                ;  |
                    BEQ IN_AIR              ; /
                    LDA #$10                ; \ y speed = 10
                    STA !AA,x               ; /

IN_AIR:             JSL $01802A|!BankB      ; update position based on speed values

NoGravity:
		LDA !7FAB28,x		;load extra property byte 1
		AND #$01		;check if bit is set
		BEQ NoSparkles		;if not, don't show sparkles.

		    JSR SET_SPARKLE_POS     ; sparkle position routine

NoSparkles:
                    JSL $01A7DC|!BankB      ; check for Mario/sprite contact (carry set = contact)
                    BCC RETURN              ; return if no contact
		    STZ !14C8,x             ; erase the sprite

		LDA !7FAB34,x		;load extra property byte 2
		AND #$01		;check if bit is set
		BNE Warping		;if set, branch to overworld warping routine.

                    LDA #$FF                ; \ set normal exit
                    STA $1493|!Base2        ; /
                    STA $0DDA|!Base2        ; set music

		LDA !7FAB28,x		;load extra property byte 1
		AND #$04		;check if bit is set
		BNE .Walk		;if yes, don't disable level end march.

		DEC $13C6|!Base2	;prevent player from doing the level end march.

.Walk
                    LDA !7FAB10,x           ; \ set secret exit if the extra bit is set
                    AND #$04                ;  |
                    BEQ .NO_SECRET_EXIT     ; /

                    LDA #$01                ; \ set secret exit
                    STA $141C|!Base2        ; /
                    
.NO_SECRET_EXIT     LDA #!Music             ; \ music to play during level end
                    STA $1DFB|!Base2        ; /
RETURN:             RTS                     ; return

;OW warping routine, adapted from Blind Devil's Cutscene Mode code.

Warping:
                    LDA !7FAB10,x	;load extra bits
                    AND #$04		;check if first extra bit is set
                    BNE .UseCoord2	;if set, warp to alternate coordinates.

		PHX			;preserve sprite index
		LDX $0DB3|!Base2	;load character in play into X
		LDA #!OWSubmap1		;load new submap
		STA $1F11|!Base2,x	;store into current submap for respective player
		LDX $0DD6|!Base2	;load OW character in play into X
		REP #$20		;16-bit A
		LDA #!OWXCoord1		;load new X coordinate
		STA $1F17|!Base2,x	;store it.
		LSR #4			;divide A by 2 four times
		STA $1F1F|!Base2,x	;store result into pointer to X position (to display correct level name).
		LDA #!OWYCoord1		;load new Y coordinate
		STA $1F19|!Base2,x	;store it.
		LSR #4			;divide A by 2 four times
		STA $1F21|!Base2,x	;store result into pointer to X position (to display correct level name).
		BRA SetEvent

.UseCoord2
		PHX			;preserve sprite index
		LDX $0DB3|!Base2	;load character in play into X
		LDA #!OWSubmap2		;load new submap
		STA $1F11|!Base2,x	;store into current submap for respective player
		LDX $0DD6|!Base2	;load OW character in play into X
		REP #$20		;16-bit A
		LDA #!OWXCoord2		;load new X coordinate
		STA $1F17|!Base2,x	;store it.
		LSR #4			;divide A by 2 four times
		STA $1F1F|!Base2,x	;store result into pointer to X position (to display correct level name).
		LDA #!OWYCoord2		;load new Y coordinate
		STA $1F19|!Base2,x	;store it.
		LSR #4			;divide A by 2 four times
		STA $1F21|!Base2,x	;store result into pointer to X position (to display correct level name).

SetEvent:
		SEP #$20		;8-bit A
		PLX			;pull back sprite index
		LDA #!Event		; \ overworld event to run
		STA $1DEA|!Base2	; /

                    LDA #$FF                ; \ set normal exit
                    STA $1493|!Base2        ; /
                    STA $0DDA|!Base2        ; set music
if !UseOWPropFix
	STA $0DD4|!Base2		;this is some free RAM used in OWTilePropFix.asm - no need to change unless extremely necessary.
endif

		LDA !7FAB28,x		;load extra property byte 1
		AND #$04		;check if bit is set
		BNE .Walk		;if yes, don't disable level end march.

		DEC $13C6|!Base2	;prevent player from doing the level end march.

.Walk
		LDA #!Music             ; \ music to play during level end
		STA $1DFB|!Base2        ; /
		RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; set sparkle position routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SET_SPARKLE_POS:
		    LDA $13                 ; \ if the frame is set...
		    AND #$1F                ; /
		    ORA !186C,x             ; or the vertical sprite off screen flag is set...
		    BNE RETURN2             ; return
		    JSL $01ACF9|!BankB      ; \ set random routine
		    AND #$0F                ; /
		    CLC                     ;
		    LDY #$00                ; \ set x location (low and high byte)
		    ADC #$FC                ;  |
		    BPL SKIP                ;  |
		    DEY                     ;  |
SKIP:		    CLC                     ;  |
		    ADC !E4,x               ;  |
		    STA $02                 ;  |
		    TYA                     ;  |
		    ADC !14E0,x             ; /
		    PHA                     ; 
		    LDA $02                 ; \ set position in the screen
		    CMP $1A                 ;  |
		    PLA                     ;  |
		    SBC $1B                 ; /
		    BNE RETURN2             ; 
		    LDA $148E|!Base2        ; \ set y location (low byte) 
		    AND #$0F                ;  |
		    CLC                     ;  |
		    ADC #$FE                ;  |
		    ADC !D8,x               ;  |
		    STA $00                 ; /
		    LDA !14D4,x             ; \ set y location (high byte)
		    ADC #$00                ;  |
		    STA $01                 ; /
                    JSR DISPLAY_SPARKLE     ; display sparkle routine
RETURN2:	    RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display sparkle routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
DISPLAY_SPARKLE:    LDY #$0B                ; \ find a free slot to display effect
FINDFREE:           LDA $17F0|!Base2,y      ;  |
                    BEQ FOUNDONE            ;  |
                    DEY                     ;  |
                    BPL FINDFREE            ;  |
                    RTS                     ; / return if no slots open

FOUNDONE:           LDA #$05                ; \ set effect graphic to sparkle graphic
                    STA $17F0|!Base2,y      ; /
                    LDA #$00                ; \ set time to show sparkle
                    STA $1820|!Base2,y      ; /
                    LDA $00                 ; \ sparkle y position
                    STA $17FC|!Base2,y      ; /
                    LDA $02                 ; \ sparkle x position
                    STA $1808|!Base2,y      ; /
                    LDA #$17                ; \ load generator x position and store it for later
                    STA $1850|!Base2,y      ; /
                    RTS                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:
		%GetDrawInfo()

		    REP #$20
                    LDA $00                 ; \ tile x/y position
                    STA $0300|!Base2,y      ; /
		    SEP #$20
                    
                    LDA #!Tilemap           ; \ store tile
                    STA $0302|!Base2,y      ; / 
                    
                    PHX                     ;
                    LDX $15E9|!Base2        ;
                    LDA !15F6,x             ; get palette info
                    PLX                     ;
                    ORA #$40                ; flip tile
                    ORA $64                 ; add in tile priority of level
                    STA $0303|!Base2,y      ; store tile properties

                    LDY #$02                ; \ (460 &= 2) 16x16 tiles maintained
                    LDA #$00                ;  | A = number of tiles drawn - 1
                    JSL $01B7B3|!BankB      ; / don't draw if offscreen
                    RTS                     ; return