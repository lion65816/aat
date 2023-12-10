;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This file is where you put the BW-RAM addresses that will be saved
;; to BW-RAM and their default values.
;; 
;; How to add a BW-RAM address to save.
;; 1) Select which things you want to save in a save file, for example,
;; Mario and Luigi coins, lives, powerup, item box and yoshi color.
;; 
;; 2) Go to bw_ram_table and add the BW-RAM address AND the amount of
;; bytes to save:
;;
;;		dl $400DB4 : dw $000A
;; 
;; Like SRAM Plus, you need to be sure that those RAM addresses aren't
;; cleared automatically when loading a save file.
;; 
;; 3) Then go to bw_ram_defaults and put the default values of your
;; BW-RAM address when loading a new file. Make sure that the default
;; values are in the same order as bw_ram_table to not get weird values
;; when loading a save file.
;; 
;; There is a maximum amount of bytes that you can save per save file
;; and that value is 2370 bytes.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

bw_ram_table:
;Put save ram addresses here, not after .end.
    dl $406000 : dw $0060
    dl $401F2F : dw $000C
	dl $40A660 : dw $0300	; $40A660 = !FreeRAM_SA1
.end
		
bw_ram_defaults:
;Format: db $xx,$xx,$xx...
;^valid sizes: db (byte), dw (word, meaning 2 bytes: $xxxx), and dl
;(long, 3-bytes: $xxxxxx). The $ (dollar) symbol isn't mandatory,
;just represents hexadecimal type of value.

	; initial midway state, $C0=192 bytes
    
    fillbyte $00 : fill $0060
    
    db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	db $C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00,$C0,$00
	
	dl $7FAD79 : dw 1	;>!Freeram_KeyCounter
	dl $7FAD49 : dw 16	;>!Freeram_MemoryFlagRAM
	;[...]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default values for how many keys you picked up.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	db $00		;>$7FAD79, Key counter $0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Default values for the MBCM16 blocks when you start up your new file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	db %00000000		;>$7FAD49 (byte $0) Flags $0 to $7 (Group $0)
	db %00000000		;>$7FAD4A (byte $1) Flags $8 to $F (Group $0)
	db %00000000		;>$7FAD4B (byte $2) Flags $10 to $17 (Group $0)
	db %00000000		;>$7FAD4C (byte $3) Flags $18 to $1F (Group $0)
	db %00000000		;>$7FAD4D (byte $4) Flags $20 to $27 (Group $0)
	db %00000000		;>$7FAD4E (byte $5) Flags $28 to $2F (Group $0)
	db %00000000		;>$7FAD4F (byte $6) Flags $30 to $37 (Group $0)
	db %00000000		;>$7FAD50 (byte $7) Flags $38 to $3F (Group $0)
	db %00000000		;>$7FAD51 (byte $8) Flags $40 to $47 (Group $0)
	db %00000000		;>$7FAD52 (byte $9) Flags $48 to $4F (Group $0)
	db %00000000		;>$7FAD53 (byte $A) Flags $50 to $57 (Group $0)
	db %00000000		;>$7FAD54 (byte $B) Flags $58 to $5F (Group $0)
	db %00000000		;>$7FAD55 (byte $C) Flags $60 to $67 (Group $0)
	db %00000000		;>$7FAD56 (byte $D) Flags $68 to $6F (Group $0)
	db %00000000		;>$7FAD57 (byte $E) Flags $70 to $77 (Group $0)
	db %00000000		;>$7FAD58 (byte $F) Flags $78 to $7F (Group $0)