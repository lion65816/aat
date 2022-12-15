print "INIT",pc
print "MAIN",pc
    lda $1DFC|!addr : cmp #$04 : bne +
    lda #$35 : sta $1DFC|!addr
+   rtl
