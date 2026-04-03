;===========================================================
; LOOPS/READY.S - STATE_READY logic
; Called once per frame from MAIN_LOOP
;===========================================================

; ----------------------------------------------------------
; READY_INIT_STATE
; Called once when entering STATE_READY
; ----------------------------------------------------------
READY_INIT_STATE:
        move.w  #READY_DELAY,STATE_TIMER    ; reset timer first
        lea     RAW_READY,a0
        lea     PAL_READY,a1
        jsr     GFX_DISPLAY_RAW
        ; TODO : display "READY" text on top
        move.w  #0,PLAY_INIT_DONE           ; ensure PLAY re-inits on next entry
        move.w  #1,READY_INIT_DONE
        rts

; ----------------------------------------------------------
; BCL_READY
; Called every frame
; ----------------------------------------------------------
BCL_READY:
        tst.w   READY_INIT_DONE
        bne     .SKIP_INIT
        jsr     READY_INIT_STATE
        bra     .DONE               ; skip decrement on init frame
.SKIP_INIT:
        subq.w  #1,STATE_TIMER
        bne     .DONE
        ; timer expired -> STATE_PLAY
        move.w  #0,READY_INIT_DONE
        move.w  #STATE_PLAY,GAME_STATE
.DONE:
        rts
