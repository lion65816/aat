main:
    ; If not just before level ends, return
    lda $1493|!addr : beq .return
    cmp #$03 : bcs .return
    
    ; Keep level end timer constant to prevent exiting early
    lda #$02 : sta $1493|!addr
    
    ; Use bank 00 for following routines
    phb
    lda.b #$00|!bank8 : pha : plb

    ; Apply screen fadeout
    phk : pea.w (+)-1
    pea.w $00A59B-1
    jml $009F6F|!bank
+   
    ; If screen fadeout didn't end, return
    lda $0100|!addr : cmp #$14 : beq +

    ; Reset level end timer
    stz $1493|!addr

    ; Otherwise, do level end stuff that is normally skipped
    ; in vertical levels (secret exit check, bonus game check, etc.)
    phk : pea.w (+)-1
    pea.w $00A59B-1
    jml $00C9D1|!bank
+   
    plb
.return:
    rtl
