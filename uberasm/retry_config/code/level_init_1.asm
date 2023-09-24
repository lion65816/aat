; Gamemode 11

init:
    ; Better safe than sorry.
    stz $13 : stz $14

    ; Reset layer 1 and 2 X positions.
    rep #$20
    stz $1A
    stz $1E
    sep #$20

    ; Reset the custom midway object counter.
    lda #$00 : sta !ram_cust_obj_num

    ; Don't trigger the prompt by accident, and reset the death flag.
    sta !ram_prompt_phase
    sta !ram_is_dying

    ; Check if we entered from the overworld.
    lda $141A|!addr : bne .skip

    ; The game sets $13BF a bit later so we need to do it ourselves
    ; (unless it's right after a "No Yoshi" cutscene).
    lda $71 : cmp #$0A : bne +
    %lda_13BF()
    bra ++
+   jsr shared_get_translevel
++  asl : tax

    ; Don't trigger Yoshi init.
    lda #$00 : sta !ram_is_respawning

    ; Reset hurry up flag.
    sta !ram_hurry_up

    ; Call the custom reset routine.
    phx : php
    phb : phk : plb
    jsr extra_reset
    plb
    plp : plx

    ; Set the destination from the level's checkpoint value.
    rep #$20
    lda !ram_checkpoint,x : sta !ram_respawn
    sep #$20

.skip:
    lda $13BF|!addr							;\ Load the translevel number.
    cmp #$36 : beq +						;| If not Level 112,
    cmp #$45 : beq +						;| or Level 121, 
    cmp #$54 : bne ++						;/ or Level 130, then run the regular Yoshi resets.
+
    lda !saved_yoshi_flag : bne +			;> If Yoshi retention flag already set, then return.
    lda $0DC1|!addr : sta !saved_yoshi_info	;> Else, store "player on Yoshi" information (includes the Yoshi's color).
    lda #$01 : sta !saved_yoshi_flag		;> Set the Yoshi retention flag.
    bra +
++
    ; Reset Yoshi, but only if respawning and not parked outside of a Castle/Ghost House.
    lda !ram_is_respawning : beq +
if not(!counterbreak_yoshi)
    lda $1B9B|!addr : bne +
endif
    stz $0DC1|!addr
+
    rtl
