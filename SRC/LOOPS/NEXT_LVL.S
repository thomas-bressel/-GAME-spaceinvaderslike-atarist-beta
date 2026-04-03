;===========================================================
; LOOPS/NEXT_LVL.S - STATE_NEXT_LVL logic
; Called once per frame from MAIN_LOOP
;===========================================================

; ----------------------------------------------------------
; NEXT_LVL_INIT_STATE
; Called once when entering STATE_NEXT_LVL
; ----------------------------------------------------------
NEXT_LVL_INIT_STATE:
        move.w  #NEXT_LVL_DELAY,STATE_TIMER ; reset timer first
        lea     RAW_NEXT,a0
        lea     PAL_NEXT,a1
        jsr     GFX_DISPLAY_RAW
        ; TODO : increment level
        ; TODO : display "STAGE X" text on top
        move.w  #0,READY_INIT_DONE          ; ensure READY re-inits on next entry
        move.w  #1,NEXT_LVL_INIT_DONE
        rts

; ----------------------------------------------------------
; BCL_NEXT_LVL
; Called every frame
; ----------------------------------------------------------
BCL_NEXT_LVL:
        tst.w   NEXT_LVL_INIT_DONE
        bne     .SKIP_INIT
        jsr     NEXT_LVL_INIT_STATE
        bra     .DONE               ; skip decrement on init frame
.SKIP_INIT:
        subq.w  #1,STATE_TIMER
        bne     .DONE
        ; timer expired -> STATE_READY
        move.w  #0,NEXT_LVL_INIT_DONE
        move.w  #STATE_READY,GAME_STATE
.DONE:
        rts
