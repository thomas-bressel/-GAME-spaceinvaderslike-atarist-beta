;===========================================================
; PI1RHEAD.S - Dev tool : removes header from a PI1 file
; Reads  TMP/PI1/DAMIER.PI1
; Writes DATA/GFX/DAMIER.RAW
; Standalone PRG - not part of the game
;
; PI1 file structure (Degas Elite low resolution) :
;   offset +0  : 2 bytes  resolution word
;   offset +2  : 32 bytes 16-color palette (16 words $0RGB)
;   offset +34 : 32000 bytes pixel data
;
; Build : assemble this file alone -> PI1RHEAD.PRG
;===========================================================
        SECTION TEXT

        include ../../INC/TOS.I
        include ../../INC/AES.I

;-----------------------------------------------------------
; ENTRY POINT
;-----------------------------------------------------------
        ; Reposition stack
        move.l  4(sp),a5
        lea     $100(a5),sp

        ; --- Init AESPB ---
        lea     AES_PB,a0
        lea     AES_CONTRL,a1
        move.l  a1,(a0)+
        lea     AES_GLOBAL,a1
        move.l  a1,(a0)+
        lea     AES_INTIN,a1
        move.l  a1,(a0)+
        lea     AES_INTOUT,a1
        move.l  a1,(a0)+
        lea     AES_ADDRIN,a1
        move.l  a1,(a0)+
        lea     AES_ADDROUT,a1
        move.l  a1,(a0)+

        ; --- appl_init (opcode 10) ---
        move.w  #_appl_init,AES_CONTRL+CONTRL_OP
        move.w  #0,AES_CONTRL+CONTRL_NIN
        move.w  #1,AES_CONTRL+CONTRL_NOUT
        move.w  #0,AES_CONTRL+CONTRL_NAIN
        move.w  #0,AES_CONTRL+CONTRL_NAOUT
        lea     AES_PB,a0
        move.l  a0,d1
        move.w  #AES_MAGIC,d0
        trap    #AES

        ; --- Process DAMIER.PI1 -> DAMIER.RAW ---
        lea     SRC_PI1+34,a0           ; pixel data at offset +34
        lea     PATH_DST_RAW,a1
        bsr     WRITE_RAW
        tst.w   d0
        bne     ERR

        lea     MSG_OK,a0
        bsr     FORM_ALERT
        bra     EXIT

ERR:
        lea     MSG_ERR,a0
        bsr     FORM_ALERT

EXIT:
        ; --- appl_exit (opcode 19) ---
        move.w  #_appl_exit,AES_CONTRL+CONTRL_OP
        move.w  #0,AES_CONTRL+CONTRL_NIN
        move.w  #1,AES_CONTRL+CONTRL_NOUT
        move.w  #0,AES_CONTRL+CONTRL_NAIN
        move.w  #0,AES_CONTRL+CONTRL_NAOUT
        lea     AES_PB,a0
        move.l  a0,d1
        move.w  #AES_MAGIC,d0
        trap    #AES

        move.w  #_Pterm0,-(sp)
        trap    #GEMDOS


;-----------------------------------------------------------
; FORM_ALERT (opcode 52)
; a0 = pointer to alert string '[icon][text][button]'
;      icon : 1=info  2=question  3=stop
;-----------------------------------------------------------
FORM_ALERT:
        move.w  #_form_alert,AES_CONTRL+CONTRL_OP
        move.w  #1,AES_CONTRL+CONTRL_NIN
        move.w  #1,AES_CONTRL+CONTRL_NOUT
        move.w  #1,AES_CONTRL+CONTRL_NAIN
        move.w  #0,AES_CONTRL+CONTRL_NAOUT
        move.w  #1,AES_INTIN
        move.l  a0,AES_ADDRIN
        lea     AES_PB,a0
        move.l  a0,d1
        move.w  #AES_MAGIC,d0
        trap    #AES
        rts


;-----------------------------------------------------------
; WRITE_RAW
; Writes 32000 bytes pixel data to a .RAW file
; a0 = pointer to pixel data (32000 bytes)
; a1 = pointer to dest path
; Returns d0 = 0 ok, -1 error
;-----------------------------------------------------------
WRITE_RAW:
        movem.l d1-d2/a0-a2,-(sp)

        move.w  #0,-(sp)
        move.l  a1,-(sp)
        move.w  #_Fcreate,-(sp)
        trap    #GEMDOS
        add.w   #8,sp
        tst.l   d0
        bmi     .ERR

        move.w  d0,HANDLE_OUT

        move.l  a0,-(sp)
        move.l  #32000,-(sp)
        move.w  HANDLE_OUT,-(sp)
        move.w  #_Fwrite,-(sp)
        trap    #GEMDOS
        lea     12(sp),sp

        move.w  HANDLE_OUT,-(sp)
        move.w  #_Fclose,-(sp)
        trap    #GEMDOS
        add.w   #4,sp

        moveq   #0,d0
        bra     .DONE
.ERR:
        moveq   #-1,d0
.DONE:
        movem.l (sp)+,d1-d2/a0-a2
        rts


;-----------------------------------------------------------
; DATA
;-----------------------------------------------------------
        SECTION DATA

PATH_DST_RAW:
        dc.b    'H:\DEVPAC3\SOURCES\ASMTARIS\SPACEINV\DATA\GFX\NEXT.RAW',0
        even

MSG_OK:
        dc.b    '[1][PI1RHEAD|.RAW written OK][OK]',0
MSG_ERR:
        dc.b    '[3][PI1RHEAD|Error writing .RAW][OK]',0
        even

SRC_PI1:
        incbin  '../../TMP/PI1/NEXT.PI1'
        even

;-----------------------------------------------------------
; BSS
;-----------------------------------------------------------
        SECTION BSS

HANDLE_OUT:     ds.w    1

AES_PB:         ds.l    6
AES_CONTRL:     ds.w    AES_CONTRL_SZ
AES_GLOBAL:     ds.w    AES_GLOBAL_SZ
AES_INTIN:      ds.w    AES_INTIN_SZ
AES_INTOUT:     ds.w    AES_INTOUT_SZ
AES_ADDRIN:     ds.l    AES_ADDRIN_SZ
AES_ADDROUT:    ds.l    AES_ADDROUT_SZ
