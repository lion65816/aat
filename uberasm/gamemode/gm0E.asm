; Press "R" on the Overworld to Switch Between Mario and Luigi
; By Bensalot 
;
;
; Set this code to Gamemode 0E in Uberasm
;
;*IMPORTANT* make sure to patch the lives.asm patch included or Luigi will have odd behavior when getting a game over.
;
; This will switch the player from Mario to and Luigi and back when Pressing the R button on the overworld during a Single Player
; game while leaving the 2 Player option in tact.
; It will take Mario's Score, Bonus Stars, Powerups, Yoshi's, and completely allows you to swap players without any odd behaviors
; like some of the other versions of "Switch Characters" codes.
; 
;*This will work with Smallhacker's Separate Player graphics patch to give Luigi separate graphics from Mario.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;*This next note will be obsolete pending approval of my update to smallhackers sep Luigi gfx patch. If you download version 3 of the patch, 
; don't worry about this next part.
;
;To fix an issue with Smallhacker's Separate Luigi gfx patch V2 or below (as in if you download Version 3, don't worry about this), 
;add this line after org $00A1DA autoclean JML Select (uncomment of course) in the separate Luigi GFX patch version 1 or 2. Don't add this if you download V3
;
;
; org $00A0B9
; autoclean JML Select3
;
; Then add this line between between the Title and Change sections (again, uncomment first)
;    Select3:
;	 JSR Change
;	 JSR Upload
;    GoBack:
;    LDX.W $0DB3|!addr     ;(smallhackers code doesn't implement the SA1 feature so you'll have to convert the rest on your own. 
;                          ;If you don't use SA1, just remove "|!addr" from this code.
;                          ;Again, I submitted an update to that patch so if you download V3 none of this will even matter.)
;	 JML $00A0BF
;
;****** This uberasm will work without these changes******  I only added this if you are using version 2 of smallhackers separate luigi gfx but I also 
;submitted a change to the patch on smwcentral that will make this note obsolete pending approval. 
;These lines simply fix an issue that patch has where the player graphics won't update on the overworld map when starting as Luigi 
;or continueing from a Game Over. And of course it will make the graphics update on the overworld when using this uberasm. However, if you don't want to 
; bother with this because it entertains you to see green Mario or Red Luigi for a split second or 2 on the overworld map, by all means, don't add this stuff.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	                            


main:

;checks
	LDA $0DB2|!addr             ; If 2 Player game skip
	BNE +
	LDA $18                     ; if  pressing L skip (unable to enter passed Castles and Fortresses without this)
	AND #$20
	BNE +
	LDA $18                     ; if not pressing R skip
	AND #$10
	BEQ +                  
	LDA $13D9|!addr             ; if not on a level tile skip
    CMP #$03                    
	BNE +
	
;fade out effect	
    LDA #$0F
    STA $0100|!addr

;sound effect
	LDA #$14                    ;Transform Sound (change this if you want, I just liked it)
	STA $1DFC|!addr

;swap players
	LDA $0DD6|!addr             ;Which character is in play. Used on the overworld.
	TAX                         ;Transfer index register X to Accumulator
	LDA $0DB3|!addr             ;Which character is in play. #$00 = Mario; #$01 = Luigi.
	EOR #$01 
	STA $0DB3|!addr             ;Which character is in play. #$00 = Mario; #$01 = Luigi. 
	ASL 
	ASL 
	STA $0DD6|!addr             ;Which character is in play. Used on the overworld.	
	TAY                         ;Transfer Accumulator to index register Y
	REP #$20                    ;Reset status bits
	BRA ++

+   BRA +

++	
;overworld position syncing
    LDA $1F17|!addr,x 
	STA $1F17|!addr,y
	LDA $1F19|!addr,x 
	STA $1F19|!addr,y
	LDA $1F1F|!addr,x             ;Pointer to Mario's overworld X position.
	STA $1F1F|!addr,y             ;Pointer to Mario's overworld X position.
	LDA $1F21|!addr,x             ;Pointer to Mario's overworld Y position.
	STA $1F21|!addr,y             ;Pointer to Mario's overworld Y position.
	SEP #$20

;fade in effect	
    LDA #$0B
    STA $0100|!addr

;bro check
    LDA $0DB3|!addr	              ;If Mario, go to Luigi code.
	BEQ Luigim
	
;animations	
    LDA $1F13|!addr 
    STA $1F15|!addr
	LDA $1F14|!addr 
    STA $1F16|!addr
	
;submap	
	LDA $1F11|!addr	              ;Current submap for Mario
    STA $1F12|!addr               ;Current submap for Luigi
	
;Points
    LDA $0F34|!addr
    STA $0F37|!addr		
    LDA $0F35|!addr
    STA $0F38|!addr		
	LDA $0F36|!addr
    STA $0F39|!addr
    LDA $0F48|!addr
	STA $0F49|!addr

BRA +

Luigim:

;animations
	LDA $1F15|!addr 
    STA $1F13|!addr
	LDA $1F16|!addr 
    STA $1F14|!addr

;submap	
	LDA $1F12|!addr             ;Current submap for Luigi. 
    STA $1F11|!addr             ;Current submap for Mario.

;Points	
    LDA $0F37|!addr      
    STA $0F34|!addr		
    LDA $0F38|!addr
    STA $0F35|!addr		
	LDA $0F39|!addr
    STA $0F36|!addr
    LDA $0F49|!addr
	STA $0F48|!addr	
+	    

    jsl author_display_main
    	LDA $0DB3|!addr 
	CMP #$00
	BNE .Iris
	LDA #$00
	STA $7FC0FC
	JML .Return
	
	
.Iris
	LDA #$01  ;Bit value
	STA $7FC0FC
.Return
	RTL


	
