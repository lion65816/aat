; Overworld Yoshi and Switch Palace Palette Fixes

!yellow = $0C
!blue   = $09
!red    = $0A
!green  = $0B

function prop(pal) = (pal-8)*2

org $048CDF
	db prop(!yellow)

org $048CE1
	db prop(!blue)

org $048CE3
	db prop(!red)

org $048CE5
	db prop(!green)
	
org $00A0EB : db $20
	
if read1($00FFD5) == $23
    sa1rom
    !addr = $6000
    !bank = $000000
else
    lorom
    !addr = $0000
    !bank = $800000
endif

org $04F365
    autoclean jml set_props

freedata

set_props:
    phx
    ldx $13D2|!addr
    lda.l palette-1,x
    plx
    jml $04F36A|!bank

function prop(pal) = (pal-8)*2

palette:
    db prop(!yellow),prop(!blue),prop(!red),prop(!green)
