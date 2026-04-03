;===========================================================
; LOOPS/TITLE.S - STATE_TITLE logic
; Called once per frame from MAIN_LOOP
;===========================================================

; ----------------------------------------------------------
; TITLE_INIT_STATE
; Called once when entering STATE_TITLE
; ----------------------------------------------------------
TITLE_INIT_STATE:
        lea     RAW_TITLE,a0
        lea     PAL_TITLE,a1
        jsr     GFX_DISPLAY_RAW
        move.w  #1,TITLE_INIT_DONE
        rts

; ----------------------------------------------------------
; BCL_TITLE
; Called every frame
; ----------------------------------------------------------
BCL_TITLE:
        tst.w   TITLE_INIT_DONE
        bne     .SKIP_INIT
        jsr     TITLE_INIT_STATE

        ; draw ship at initial position (neutral sprite)
        lea     BIN_SPRITE+SHIP_SPR,a0
        move.w  SHIP_X_CUR,d0
        move.w  #0,d1
        move.w  #SPR_H,d2
        jsr     GFX_DRAW_SPRITE

.SKIP_INIT:
        rts
