; ColorYoshi by spooonsss
; This sprite sets the color of Yoshi and reverts to a vanilla Yoshi.
; Use this when you want to place a not-green grown Yoshi in your level.
; Color is set by first Extra Byte:
; 04 = Yellow
; 06 = Blue
; 08 = Red
; 0A = Green
; or use "Custom Collections of Sprites" in Lunar Magic which have extra byte already set.
; Note that this sprite will display as yellow in Lunar Magic, even for red and blue types

macro localJSL(dest, rtlop, db)
    assert read1(((<db>)<<16)+(<rtlop>)) == $6B, "rtl op should point to a rtl"
    PHB			;first save our own DB
    PHK			;first form 24bit return address
    PEA.w ?return-1
    PEA.w <rtlop>-1		;second comes 16bit return address
    PEA.w <db><<8|<db>	;change db to desired value
    PLB
    PLB
    JML <dest>
?return:
    PLB			;restore our own DB
endmacro


print "INIT ",pc
init:
    ; set palette
    LDA !15F6,x
    ORA !extra_byte_1,x
    STA !15F6,x

    ; make sprite not custom
    LDA !extra_bits,x
    AND #($FF-!CustomBit)
    STA !extra_bits,x

    ; yoshi init
    %localJSL($0183E0|!BankB, $9D66, $01|!Bank8)

    RTL

print "MAIN ",pc
main:
    ; should be unreachable. erase ourself
    STZ !sprite_status,x
    RTL
