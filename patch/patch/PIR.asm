;Chdata: There where some problems with this I had trying to get it to work with other patches even though this hacked almost nothing else to do with anything.
;For example a JSL label that was treated as 3 bytes instead of 4 for some reason.
;Pirahna Plant Fix Patch #1 was also pointed to some random spot that was said to be unused data but I don't trust that so I added it in with this patch so it goes to freespace too.
;Also this should be more compatible with other patches now. ^^
;Origionally made by BMF54123

!base1 = $0000
!base2 = $0000
!9E = $9E

if read1($00FFD5) == $23
sa1rom
!base1 = $3000
!base2 = $6000
!9E = $3200
endif

org $00D26A
autoclean JML PIR
NOP #2
NopNop:

org $018E8D
autoclean JML PIRAHNA
NOP
NOP
NOP
NOP
NOP
NOP
NoNop:

freedata ; this one doesn't change the data bank register, so it uses the RAM mirrors from another bank, so I might as well toss it into banks 40+
PIRAHNA:
LDA !9E,x
CMP #$1A
BEQ IsClassic
LDA $030B|!base2,y
AND #$F1
ORA #$0B		;#$0A These values remap Classic and Upside Down piranhas to the first GFX page if you change it to this
STA $030B|!base2,y
JML NoNop

IsClassic:
LDA $0307|!base2,y
AND #$F1
ORA #$0B		;#$0A The advantage is that you can now have the pirahnas globally at the expensive of flopping fish.
STA $0307|!base2,y		;Suggestion is: Remap Note Blocks to The other flopping fish tile
JML NoNop

PIR:
STZ $13F9|!base2
STZ $1419|!base2
LDA $1497|!base2
BNE NoNew
INC $1497|!base2
NoNew:
JML NopNop

print "I'm psychic, I knew that you would patch this."
print "-Chdata-"