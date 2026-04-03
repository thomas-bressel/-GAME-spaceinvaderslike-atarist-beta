;===========================================================
; LOOPS/GAMEOVER.S - STATE_GAMEOVER logic
; Called once per frame from MAIN_LOOP
;===========================================================

; ----------------------------------------------------------
; GAMEOVER_INIT_STATE
; Called once when entering STATE_GAMEOVER
; ----------------------------------------------------------
GAMEOVER_INIT_STATE:
        lea     RAW_GAMEOVER,a0
        lea     PAL_GAMEOVER,a1
        jsr     GFX_DISPLAY_RAW
        move.w  #100,STATE_TIMER            ; 2 seconds at 50Hz
        move.w  #1,GAMEOVER_INIT_DONE
        rts

; ----------------------------------------------------------
; BCL_GAMEOVER
; Called every frame
; ----------------------------------------------------------
BCL_GAMEOVER:
        tst.w   GAMEOVER_INIT_DONE
        bne     .SKIP_INIT
        jsr     GAMEOVER_INIT_STATE
.SKIP_INIT:
        ; 2 second timer then back to STATE_TITLE
        subq.w  #1,STATE_TIMER
        bne     .DONE
        move.w  #0,GAMEOVER_INIT_DONE
        move.w  #0,TITLE_INIT_DONE          ; force TITLE re-init
        move.w  #LIVES_MAX,GAME_LIVES_W     ; reset lives
        move.w  #STATE_TITLE,GAME_STATE
.DONE:
        rts
