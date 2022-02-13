; Remember to edit the actual level names in ExtendedLevelNames_config.asm

if read1($00FFD5) == $23
	sa1rom
	!bank = $000000
else
	lorom
	!bank = $800000
endif

table table.txt

org $03BB30|!bank
 ASL
org $03BB37|!bank
autoclean JML levelNameHack

freecode

assert read1($048E81) == $22,"Before using this patch you need to edit the level names in Lunar Magic at least once, as this patch needs the ASM provided by that."

levelNameHack:
 TAX
 LDA $837B
 TAY
 CLC
 ADC #$0026
 STA $02
 CLC
 ADC #$0004
 CLC
 ADC #$0026
 STA $00
 CLC
 ADC #$0004
 STA $837B
 LDA #$2500
 STA $837F,y
 LDA #$6B50
 STA $837D,y
 SEP #$20
-   JSR +
 CPY $02
 BCC -
 REP #$20
 LDA #$2500
 STA $8383,y
 LDA #$8B50
 STA $8381,y
 INY
 INY
 INY
 INY
 SEP #$20
-   JSR +
 CPY $00
 BCC -

 JML $03BB69|!bank
+ LDA.l NameData,x
 STA $8381,y
 LDA #$39
 STA $8382,y
 INY
 INY
 INX
 RTS

incsrc ExtendedLevelNames_config.asm