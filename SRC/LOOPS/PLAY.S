;===========================================================
; LOOPS/PLAY.S - STATE_PLAY logic
; Called once per frame from MAIN_LOOP
;===========================================================

; ----------------------------------------------------------
; PLAY_INIT_STATE
; Called once when entering STATE_PLAY
; ----------------------------------------------------------
PLAY_INIT_STATE:
        ; load palette and display background once
        lea     RAW_LEVEL1,a0
        lea     PAL_LEVEL1,a1
        jsr     GFX_DISPLAY_RAW

        ; init and draw enemies, snapshot initial GRID_Y
        jsr     ENEMIES_INIT
        jsr     ENEMIES_DRAW
        jsr     ENEMIES_SAVE_BG

        ; save background under initial ship position
        lea     SHIP_BG_SAV,a0
        move.w  SHIP_X_CUR,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_SAVE_BG

        ; draw ship at initial position (neutral sprite)
        lea     BIN_SPRITE+SHIP_SPR,a0
        move.w  SHIP_X_CUR,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_DRAW_SPRITE

        move.w  SHIP_X_CUR,SHIP_X_PREV
        move.w  #1,PLAY_INIT_DONE
        rts

; ----------------------------------------------------------
; BCL_PLAY
; Called every frame
; ----------------------------------------------------------
BCL_PLAY:
        tst.w   PLAY_INIT_DONE
        bne     .SKIP_INIT
        jsr     PLAY_INIT_STATE
.SKIP_INIT:
        ; --- enemies : move, restore bg, redraw (first : bullet captures bg with enemies drawn) ---
        move.w  #$0700,PAL_BASE             ; DBG : ENEMIES = RED
        jsr     ENEMIES_UPDATE

        ; --- ship : move, restore/save/draw ---
        move.w  #$0070,PAL_BASE             ; DBG : SHIP = GREEN
        jsr     SHIP_UPDATE

        ; --- bullet : fire, move, restore/save/draw ---
        move.w  #$0007,PAL_BASE             ; DBG : BULLET = BLUE
        jsr     BULLET_UPDATE

        ; --- handle kill (KEY_K) -> STATE_DEATH ---
        cmp.b   #KEY_K,KEY_CUR
        bne     .NO_KILL
        move.w  #STATE_DEATH,GAME_STATE
.NO_KILL:
        rts
