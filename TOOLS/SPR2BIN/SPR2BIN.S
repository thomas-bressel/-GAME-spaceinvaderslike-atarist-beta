;===========================================================
; SPR2BIN.S - Dev tool : extract sprites from a PI1 file
; Reads TMP/PI1/SHIP.PI1 and writes DATA/GFX/SHIP.BIN
; Standalone PRG - not part of the game
;
; PI1 pixel data starts at offset +34 (after header)
; PI1 low res : 160 bytes per line, 200 lines
;
; Sprite layout in PI1 (16px columns, each slot = 8 bytes wide) :
; Sprite address = PI1_DATA + (SPR_Y * SPR_H * PI1_ROW)
;                              + (SPR_X * SPR_SLOT_W)
;
; Each sprite line = SPR_LINE_W bytes (4 planes x 1 word = 8 bytes for 16px)
; SPR_SLOT_W = slot width in PI1 = 8 bytes (= SPR_LINE_W for 16px sprites)
;
; Sprites are extracted left to right, written linearly to BIN
;
; Build : assemble this file alone -> SPR2BIN.PRG
;===========================================================
        SECTION TEXT

        include ../../INC/TOS.I
        include ../../INC/AES.I

;-----------------------------------------------------------
; CONSTANTS
;-----------------------------------------------------------
SPR_LINE_W      equ     8               ; bytes per sprite line (16px = 4 planes x 1 word)
SPR_SLOT_W      equ     8               ; slot width in PI1 (16px = 8 bytes)
SPR_H           equ     10              ; sprite height in lines
SPR_COUNT       equ     20              ; number of sprites to extract
SPR_X           equ     0               ; sprite grid column
SPR_Y           equ     0               ; sprite grid row
MASK_X          equ     0               ; mask grid column
MASK_Y          equ     1               ; mask grid row (just below the sprite)
PI1_ROW         equ     160             ; bytes per PI1 line

; offsets into pixel data (after 34-byte PI1 header)
SPR_OFFSET      equ     SPR_X*SPR_SLOT_W
MASK_OFFSET     equ     MASK_Y*SPR_H*PI1_ROW+MASK_X*SPR_SLOT_W

;-----------------------------------------------------------
; ENTRY POINT
;-----------------------------------------------------------
        ; Reposition stack
        move.l  4(sp),a5
        lea     $100(a5),sp

        ; --- Init AESPB ---
        ; AESPB is a block of 6 longword pointers that the AES expects
        ; before any trap #AES call. Each pointer targets one of the
        ; six parameter arrays : CONTRL, GLOBAL, INTIN, INTOUT, ADDRIN, ADDROUT
        ; We fill them once here at startup - they stay valid for the whole run
        lea     AES_PB,a0
        lea     AES_CONTRL,a1
        move.l  a1,(a0)+                ; ptr -> CONTRL  (5 words : opcode + sizes)
        lea     AES_GLOBAL,a1
        move.l  a1,(a0)+                ; ptr -> GLOBAL  (15 words : filled by appl_init)
        lea     AES_INTIN,a1
        move.l  a1,(a0)+                ; ptr -> INTIN   (integer input params)
        lea     AES_INTOUT,a1
        move.l  a1,(a0)+                ; ptr -> INTOUT  (integer return values)
        lea     AES_ADDRIN,a1
        move.l  a1,(a0)+                ; ptr -> ADDRIN  (pointer input params)
        lea     AES_ADDROUT,a1
        move.l  a1,(a0)+                ; ptr -> ADDROUT (pointer return values)

        ; --- appl_init (opcode 10) ---
        ; Must be the very first AES call.
        ; Registers the app with GEM and fills GLOBAL with system info.
        ; CONTRL[0] = opcode, [1] = nb intin, [2] = nb intout, [3] = nb addrin, [4] = nb addrout
        move.w  #_appl_init,AES_CONTRL+CONTRL_OP  ; function opcode
        move.w  #0,AES_CONTRL+CONTRL_NIN           ; no integer inputs
        move.w  #1,AES_CONTRL+CONTRL_NOUT          ; 1 integer output : app id
        move.w  #0,AES_CONTRL+CONTRL_NAIN          ; no pointer inputs
        move.w  #0,AES_CONTRL+CONTRL_NAOUT         ; no pointer outputs
        lea     AES_PB,a0
        move.l  a0,d1                               ; d1 = address of AESPB
        move.w  #AES_MAGIC,d0                       ; d0 = $C8 (AES magic number)
        trap    #AES                                 ; call GEM

        ; Create BIN file
        move.w  #0,-(sp)
        pea     PATH_BIN
        move.w  #_Fcreate,-(sp)
        trap    #GEMDOS
        add.w   #8,sp
        tst.l   d0
        bmi     ERR_CREATE
        move.w  d0,HANDLE_OUT

        ; Write header (16 bytes)
        move.w  #SPR_LINE_W,BIN_HEADER  ; bytes 0-1 : width in bytes
        move.w  #SPR_H,BIN_HEADER+2     ; bytes 2-3 : height
        pea     BIN_HEADER              ; buf
        move.l  #16,-(sp)               ; count
        move.w  HANDLE_OUT,-(sp)        ; handle
        move.w  #_Fwrite,-(sp)
        trap    #GEMDOS
        lea     12(sp),sp

        ; a0 = first sprite line in PI1
        ; a2 = first mask line in PI1
        lea     SHIP_PI1+34+SPR_OFFSET,a0
        lea     SHIP_PI1+34+MASK_OFFSET,a2

        ; d3 = sprite counter
        move.w  #SPR_COUNT-1,d3

LOOP_SPR:
        ; save sprite/mask start for next sprite advance
        move.l  a0,a1
        move.l  a2,a3

        ; --- pass 1 : write all sprite lines ---
        move.w  #SPR_H-1,d4
LOOP_SPR_LINES:
        move.l  a0,-(sp)
        move.l  #SPR_LINE_W,-(sp)
        move.w  HANDLE_OUT,-(sp)
        move.w  #_Fwrite,-(sp)
        trap    #GEMDOS
        lea     12(sp),sp
        add.l   #PI1_ROW,a0
        dbf     d4,LOOP_SPR_LINES

        ; --- pass 2 : write all mask lines ---
        move.w  #SPR_H-1,d4
LOOP_MSK_LINES:
        move.l  a2,-(sp)
        move.l  #SPR_LINE_W,-(sp)
        move.w  HANDLE_OUT,-(sp)
        move.w  #_Fwrite,-(sp)
        trap    #GEMDOS
        lea     12(sp),sp
        add.l   #PI1_ROW,a2
        dbf     d4,LOOP_MSK_LINES

        ; next sprite : advance SPR_SLOT_W bytes in X
        lea     SPR_SLOT_W(a1),a0
        lea     SPR_SLOT_W(a3),a2

        dbf     d3,LOOP_SPR

        ; Close file
        move.w  HANDLE_OUT,-(sp)
        move.w  #_Fclose,-(sp)
        trap    #GEMDOS
        add.w   #4,sp

        lea     MSG_OK,a0
        bsr     FORM_ALERT
        bra     EXIT

ERR_CREATE:
        lea     MSG_ERR,a0
        bsr     FORM_ALERT

EXIT:
        ; --- appl_exit (opcode 19) ---
        ; Must be the last AES call before Pterm0.
        ; Deregisters the app from GEM and releases its application slot.
        move.w  #_appl_exit,AES_CONTRL+CONTRL_OP  ; function opcode
        move.w  #0,AES_CONTRL+CONTRL_NIN           ; no integer inputs
        move.w  #1,AES_CONTRL+CONTRL_NOUT          ; 1 integer output : success flag
        move.w  #0,AES_CONTRL+CONTRL_NAIN          ; no pointer inputs
        move.w  #0,AES_CONTRL+CONTRL_NAOUT         ; no pointer outputs
        lea     AES_PB,a0
        move.l  a0,d1                               ; d1 = address of AESPB
        move.w  #AES_MAGIC,d0                       ; d0 = $C8 (AES magic number)
        trap    #AES                                 ; call GEM

        move.w  #_Pterm0,-(sp)
        trap    #GEMDOS


;-----------------------------------------------------------
; FORM_ALERT (opcode 52)
; Displays a GEM alert box with an icon, a message and an OK button.
; a0 = pointer to alert string, format : '[icon][text][button]'
;      icon : 1=info  2=question  3=stop
; Returns : intout[0] = index of button pressed (1-based)
;-----------------------------------------------------------
FORM_ALERT:
        ; --- form_alert (opcode 52) ---
        move.w  #_form_alert,AES_CONTRL+CONTRL_OP  ; function opcode
        move.w  #1,AES_CONTRL+CONTRL_NIN           ; 1 integer input  : default button index
        move.w  #1,AES_CONTRL+CONTRL_NOUT          ; 1 integer output : button pressed
        move.w  #1,AES_CONTRL+CONTRL_NAIN          ; 1 pointer input  : alert string
        move.w  #0,AES_CONTRL+CONTRL_NAOUT         ; no pointer outputs
        move.w  #1,AES_INTIN                        ; default button = 1 (leftmost)
        move.l  a0,AES_ADDRIN                       ; ptr to alert string -> addrin[0]
        lea     AES_PB,a0
        move.l  a0,d1                               ; d1 = address of AESPB
        move.w  #AES_MAGIC,d0                       ; d0 = $C8 (AES magic number)
        trap    #AES                                 ; call GEM
        rts


;-----------------------------------------------------------
; DATA
;-----------------------------------------------------------
        SECTION DATA

PATH_BIN:
        dc.b    'H:\DEVPAC3\SOURCES\ASMTARIS\SPACEINV\DATA\GFX\ENEMIES1.BIN',0

MSG_OK:
        dc.b    '[1][SPR2BIN|.BIN extrait !][OK]',0
MSG_ERR:
        dc.b    '[3][SPR2BIN|Erreur : .BIN][OK]',0

        even

SHIP_PI1:
        incbin  '../../TMP/PI1/ENEMIES.PI1'
        even

;-----------------------------------------------------------
; BSS
;-----------------------------------------------------------
        SECTION BSS

HANDLE_OUT:     ds.w    1
BIN_HEADER:     ds.b    16              ; header : SPR_W(w), SPR_H(w), 12 bytes reserved

AES_PB:         ds.l    6
AES_CONTRL:     ds.w    AES_CONTRL_SZ
AES_GLOBAL:     ds.w    AES_GLOBAL_SZ
AES_INTIN:      ds.w    AES_INTIN_SZ
AES_INTOUT:     ds.w    AES_INTOUT_SZ
AES_ADDRIN:     ds.l    AES_ADDRIN_SZ
AES_ADDROUT:    ds.l    AES_ADDROUT_SZ
