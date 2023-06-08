; Color to change to
; Valid options: !Green, !Red, !Blue, !Yellow
!color = !Blue

; Change Yoshi's palette
; (when he touches the block when not ridden by Mario)
!yoshi_alone = 1

; Change Yoshi's palette
; (when Mario is riding him and touching the block)
!yoshi_riding = 1

; Change Baby Yoshi's palette
; (when he touches the block but not being carried by Mario)
!baby_yoshi_alone = 1

; Change Baby Yoshi's palette
; (when Mario is carrying him and touching the block)
!baby_yoshi_carried = 1

; Don't change from here
!Green  = $D
!Red    = $C
!Blue   = $B
!Yellow = $A

db $42

jmp mario : jmp mario : jmp mario
jmp sprite : jmp sprite
jmp return : jmp return
jmp mario : jmp mario : jmp mario

mario:
if !yoshi_riding
    lda $187A|!addr : beq return
    ldx $18DF|!addr : dex
    bra sprite_change
endif
    rtl
sprite:
if !yoshi_alone || !baby_yoshi_alone
    lda !9E,x
endif
if !yoshi_alone
    cmp #$35 : beq .change
endif
if !baby_yoshi_alone && !baby_yoshi_carried
    cmp #$2D : beq .change
else
    cmp #$2D : bne return
    lda !14C8,x : cmp #$0B
if !baby_yoshi_alone
    bne .change
endif
if !baby_yoshi_carried
    beq .change
endif
endif
    rtl
.change:
    lda !15F6,x : and #$F1 : ora.b #(!color-8)<<1 : sta !15F6,x
return:
    rtl

print "Changes Yoshi's palette to ",hex(!color)
