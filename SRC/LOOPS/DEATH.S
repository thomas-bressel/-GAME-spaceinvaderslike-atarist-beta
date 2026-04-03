;===========================================================
; LOOPS/DEATH.S - STATE_DEATH logic
; Called once per frame from MAIN_LOOP
;===========================================================

; ----------------------------------------------------------
; DEATH_INIT_STATE
; Called once when entering STATE_DEATH
; ----------------------------------------------------------
DEATH_INIT_STATE:
        move.w  #DEATH_DELAY,STATE_TIMER    ; timer: total death anim duration
        clr.w   DEATH_FRAME                 ; start at explosion frame 0
        clr.w   BULLET_ACTIVE               ; cancel any bullet in flight
        move.w  #1,DEATH_INIT_DONE
        rts

; ----------------------------------------------------------
; BCL_DEATH
; Called every frame
; ----------------------------------------------------------
BCL_DEATH:
        tst.w   DEATH_INIT_DONE
        bne     .SKIP_INIT
        jsr     DEATH_INIT_STATE
.SKIP_INIT:
        ; --- draw explosion frame ---
        ; frame changes every 10 frames (DEATH_DELAY/5 = 10)
        move.w  STATE_TIMER,d0
        divu    #10,d0
        swap    d0                          ; remainder in high word -> low after swap
        tst.w   d0                          ; remainder = 0 -> change frame
        bne     .DRAW_EXP

        ; advance frame (0..4)
        move.w  DEATH_FRAME,d0
        addq.w  #1,d0
        cmp.w   #5,d0
        blt     .SET_FRAME
        move.w  #4,d0                       ; stay on last frame
.SET_FRAME:
        move.w  d0,DEATH_FRAME

.DRAW_EXP:
        ; restore bg at ship position first
        lea     SHIP_BG_SAV,a0
        move.w  SHIP_X_CUR,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_RESTORE_BG

        ; save bg at ship position
        lea     SHIP_BG_SAV,a0
        move.w  SHIP_X_CUR,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_SAVE_BG

        ; compute sprite offset : SHIP_SPR_EXP0 + DEATH_FRAME * SPR_SIZE
        lea     BIN_SPRITE+SHIP_SPR_EXP0,a0
        move.w  DEATH_FRAME,d0
        beq     .DO_DRAW                    ; frame 0 -> already at EXP0
        move.w  d0,d1
        mulu    #SPR_SIZE,d1
        add.l   d1,a0
.DO_DRAW:
        move.w  SHIP_X_CUR,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_DRAW_SPRITE

        ; --- decrement timer ---
        subq.w  #1,STATE_TIMER
        bne     .DONE

        ; timer expired -> restore background, decrement lives, transition
        lea     SHIP_BG_SAV,a0
        move.w  SHIP_X_CUR,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_RESTORE_BG
        move.w  #0,DEATH_INIT_DONE
        move.w  #0,PLAY_INIT_DONE           ; force PLAY re-init on next entry
        subq.w  #1,GAME_LIVES_W
        tst.w   GAME_LIVES_W
        bgt     .GO_READY
        move.w  #STATE_GAMEOVER,GAME_STATE
        bra     .DONE
.GO_READY:
        move.w  #STATE_READY,GAME_STATE
.DONE:
        rts
