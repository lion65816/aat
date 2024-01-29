;=====================================================
; Castle Destruction Cutscenes Custom Palettes v1.0
; by KevinM
;
; This patch allows you to set a custom palette for each of the
; 7 vanilla castle destruction sequences.
; The process is fairly simple, all you need to do is export the
; palette files from LM and insert an entry in the "castle_cutscene_palettes_settings.asm" file
; (more info in that file). Don't edit this file!
; Note: if you don't set a palette for a specific cutscene, it will use the vanilla palette.
;=====================================================

if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !dp = $3000
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !dp = $0000
    !addr = $0000
    !bank = $800000
endif

; Hijack.
org $0094DA
    autoclean jsl palettes
    bra $00

freecode

; Macro for user friendliness.
macro set_palette(num,file)
    ; If the cutscene is the correct one, load the palette.
    lda $13C6|!addr : cmp.b #<num> : beq ?load

    ; Otherwise, go to the next macro/return.
    jmp ?skip

?load:
    ; Set the current palette address to $00-$02 and jump to the routine.
    rep #$20
    lda.w #?gfx : sta $00
    sep #$20
    lda.b #?gfx>>16 : sta $02
    jmp load_palette

?gfx:
    incbin <file>

?skip:
endmacro

; Actual code.
palettes:
    ; Everything is handled by the macros :)
    incsrc castle_cutscene_palettes_settings.asm
.orig:
    ; Call the original routines and return.
    ; We use a double jsl-to-rts to save some time and space.
    phk                 ;\ Return address.
    pea.w (+)-1         ;/
    pea.w $0084CF-1     ; RTL
    pea.w $00922F-1     ; $0703->CGRAM routine
    jml $00ABED|!bank   ; ROM->$0703 routine
+   rtl

; Routine to load a palette from ROM.
; Input: $00-$02 - Address to the palette data.
; It skips the middleman ($0703) and just uses DMA directly.
load_palette:
    ; Upload to the start of CGRAM.
    stz $2121

    rep #$20

    ; Upload to $2122, increment mode, one register write once.
    lda #$2200 : sta $4320

    ; Set source address low-high byte.
    lda $00 : sta $4322

    ; Set source address bank byte.
    ldx $02 : stx $4324

    ; Set size (512 bytes).
    lda #$0200 : sta $4325

    ; Start DMA.
    ldx #$04 : stx $420B

    ; Now set the back area color.
    rep #$10
    ldy #$0200
    lda [$00],y : sta $0701|!addr
    sep #$30
    rtl
