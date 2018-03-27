;license:MIT 
;(c) 2018 by qkumba 

!to "build/ONBEYOND.SYSTEM",plain
*=$2000

jmp init
!byte $ee,$ee,64
!fill 64

filetype=$f5
auxtype=$8000 ;really $80xx

        ;get prefix, if any
init
        lda     $bf30
        sta     c5_parms+1
-       jsr     $bf00
op_c7
        !byte   $c7
        !word   c7_parms
        ldx     $200
        bne     +

        ;if not, get volume name

        jsr     $bf00
        !byte   $c5
        !word   c5_parms
        ldx     $201
        inx
        txa
        and     #$0f
        sta     $200
        lda     #$2f
        sta     $201

        ;set that as prefix

        dec     op_c7
        bne     -
+       lda     #$2f
        cmp     $200,x
        beq     +
        inc     $200
        sta     $201,x

        ;get attributes for passed file

+       jsr     $bf00
        !byte   $c4
        !word   c4_parms
        bcc     +
quit    jsr     $bf00
        !byte   $65
        !word   quit_parms
+       lda     c4_parms+4
        cmp     #filetype
        bne     quit
        lda     c4_parms+6
        cmp     #>auxtype
        bne     quit

        ;select interpreter by auxtype
        ;1, 2, 3, 4, 5, "$55" (special case)

        lda     c4_parms+5
        beq     quit
        cmp     #$55
        beq     +
        cmp     #6
        bcs     quit
        dec     filename
        ora     #$30
        sta     version
+

        ;get volume name

         inc     c5_parms+3
         lda    #$81
         sta    c5_parms+2
        jsr     $bf00
        !byte   $c5
        !word   c5_parms
        ldx     $381
        inx
        txa
        and     #$0f
        sta     $380
        lda     #$2f
        sta     $381

        ;use that for intepreter location

        jsr     $bf00
        !byte   $c6
        !word   c6_parms

        ;open/read/close

        jsr     $bf00
        !byte   $c8
        !word   c8_parms
        lda     c8_parms+5
        sta     ca_parms+1
        jsr     $bf00
        !byte   $ca
        !word   ca_parms
        jsr     $bf00
        !byte   $cc
        !word   cc_parms

        ;set prefix to passed file

        jsr     $bf00
        !byte   $c6
        !word   c7_parms

        ;run interpreter

        jmp     $3000

c7_parms
cc_parms
        !byte   1
        !word   $200

c5_parms
        !byte   2
        !byte   0
        !word   $201
        !byte   $d1

c6_parms
        !byte   1
        !word   $380

c4_parms
        !byte   $0a
        !word   $2006
        !text   "qkumba was here"

c8_parms
        !byte   3
        !word   filename
        !word   $800
        !byte   0

quit_parms
ca_parms
        !byte   4
        !byte   $ff
        !word   $3000
        !word   $ffff
        !word   $ffff

filename
        !byte   (filename_e-filename)-1
        !text   "LIB/ONBEYONDZ"
version !text   "5U"
filename_e

!byte $D3,$C1,$CE,$A0,$C9,$CE,$C3,$AE
