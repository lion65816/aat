;===============================================================================;
; This patch fixes a couple weird interactions that happen when riding Yoshi:   ;
; - Getting damaged by a kicked throw block                                     ;
; - Getting damaged by Dry Bones/Bony Beetles in the crumbled state             ;
; - Getting damaged by stationary Bowser Statues                                ;
; - Getting damaged by Boo Blocks in block state                                ;
;===============================================================================;

if read1($00FFD5) == $23
    sa1rom
    !sa1 = 1
    !addr = $6000
    !bank = $000000
else
    lorom
    !sa1 = 0
    !addr = $0000
    !bank = $800000
endif

macro define_sprite_table(name, addr, addr_sa1)
    if !sa1 == 0
        !<name> = <addr>
    else
        !<name> = <addr_sa1>
    endif
endmacro

%define_sprite_table("9E", $9E, $3200)
%define_sprite_table("C2", $C2, $D8)
%define_sprite_table("1534", $1534, $32B0)
%define_sprite_table("167A", $167A, $7616)

org $01F651 : autoclean jml Main

freedata

Main:
    lda.w !9E,y         ;\ Don't interact with throw blocks
    cmp #$53            ;|
    beq .skip           ;/
    cmp #$BC            ;\ If Bowser Statue, check if it's stationary
    beq .statue         ;/
    cmp #$AF            ;\ If Boo Block, check if it's in block state
    beq .booblock       ;/
    cmp #$30            ;\ If not Dry Bone/Bony Beetle, continue
    bcc .continue       ;|
    cmp #$33            ;|
    bcs .continue       ;/
.bones
    lda !1534,y         ;\ Don't interact if in collapsed state
    bne .skip           ;/
.continue
    lda !167A,y         ;\ Original code
    and #$02            ;|
    jml $01F656|!bank   ;/
.booblock
    lda.w !C2,y         ;\ If it's stationary, don't interact
    beq .continue       ;|
    bra .skip           ;/
.statue
    lda.w !C2,y         ;\ If it's a jumping statue, interact
    cmp #$02            ;|
    beq .continue       ;/
.skip
    jml $01F661|!bank
