;===========================================================
; LOOPS/BULLET.S - Player bullet update
; Called once per frame from BCL_PLAY
;===========================================================
; ----------------------------------------------------------
; BULLET_UPDATE
; Handles fire key, spawn, move, restore/save/draw bullet
; ----------------------------------------------------------
BULLET_UPDATE:
        ; --- handle fire ---
        cmp.b   #KEY_F,KEY_CUR
        bne     .KEY_F_UP
        tst.w   BULLET_KEY_LOCK
        bne     .NO_FIRE                    ; F held, already fired
        tst.w   BULLET_ACTIVE
        bne     .NO_FIRE                    ; already a bullet on screen
        ; spawn bullet at ship center
        move.w  SHIP_X_CUR,d0               ; bullet X = ship X (both 16px wide)
        move.w  d0,BULLET_X
        move.w  #172,BULLET_Y               ; just above ship (ship at Y=180)
        move.w  #172,BULLET_Y_PREV
        lea     BULLET_BG_SAV,a0
        move.w  BULLET_X,d0
        move.w  BULLET_Y,d1
        move.w  #SPR_H,d2
        jsr     GFX_SAVE_BG
        lea     BIN_SPRITE+SHIP_SPR_FIRE,a0
        move.w  BULLET_X,d0
        move.w  BULLET_Y,d1
        move.w  #SPR_H,d2
        jsr     GFX_DRAW_SPRITE
        move.w  #1,BULLET_ACTIVE
        move.w  #1,BULLET_KEY_LOCK          ; lock until F released
        bra     .NO_BULLET                  ; skip move on spawn frame

.KEY_F_UP:
        clr.w   BULLET_KEY_LOCK             ; F not pressed, unlock
.NO_FIRE:
        ; --- move bullet ---
        tst.w   BULLET_ACTIVE
        beq     .NO_BULLET

        ; restore bg at previous position
        lea     BULLET_BG_SAV,a0
        move.w  BULLET_X,d0
        move.w  BULLET_Y_PREV,d1
        move.w  #SPR_H,d2
        jsr     GFX_RESTORE_BG

        ; move bullet up
        jsr     PHYS_MOVE_BULLET
        tst.w   d0
        bne     .NO_BULLET                  ; bullet deactivated, skip draw

        ; save bg at new pos
        lea     BULLET_BG_SAV,a0
        move.w  BULLET_X,d0
        move.w  BULLET_Y,d1
        move.w  #SPR_H,d2
        jsr     GFX_SAVE_BG

        ; draw bullet
        lea     BIN_SPRITE+SHIP_SPR_FIRE,a0
        move.w  BULLET_X,d0
        move.w  BULLET_Y,d1
        move.w  #SPR_H,d2
        jsr     GFX_DRAW_SPRITE

        ; update prev after draw
        move.w  BULLET_Y,BULLET_Y_PREV

.NO_BULLET:
        rts
