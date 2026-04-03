;===========================================================
; LOOPS/SHIP.S - Player ship update
; Called once per frame from BCL_PLAY
;===========================================================

; ----------------------------------------------------------
; SHIP_UPDATE
; Moves ship, restores/saves/draws background and sprite
; ----------------------------------------------------------
SHIP_UPDATE:
        ; --- move ship ---
        jsr     PHYS_MOVE_SHIP

        ; --- restore background at previous position ---
        lea     SHIP_BG_SAV,a0
        move.w  SHIP_X_PREV,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_RESTORE_BG

        ; --- save background at new position ---
        lea     SHIP_BG_SAV,a0
        move.w  SHIP_X_CUR,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_SAVE_BG

        ; --- draw ship (sprite depends on direction) ---
        lea     BIN_SPRITE,a0
        cmp.b   #KEY_LEFT,KEY_CUR
        beq     .SPR_LEFT
        cmp.b   #KEY_RIGHT,KEY_CUR
        beq     .SPR_RIGHT
        add.l   #SHIP_SPR,a0
        bra     .SPR_DRAW
.SPR_LEFT:
        add.l   #SHIP_SPR_L,a0
        bra     .SPR_DRAW
.SPR_RIGHT:
        add.l   #SHIP_SPR_R,a0
.SPR_DRAW:
        move.w  SHIP_X_CUR,d0
        move.w  #180,d1
        move.w  #SPR_H,d2
        jsr     GFX_DRAW_SPRITE

        ; --- update previous position ---
        move.w  SHIP_X_CUR,SHIP_X_PREV
        rts
