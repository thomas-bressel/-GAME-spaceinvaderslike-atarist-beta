;===========================================================
; PHYS.S - Movement and collisions
; Depends : INC/CONST.I, INC/STRUCT.I
; No hardware addresses here - hardware-blind
;===========================================================

; ----------------------------------------------------------
; PHYS_MOVE_SHIP
; Reads keyboard, computes new ship X, clamps to screen
; Updates SHIP_X_CUR
; Uses : d0 (scratch)
; ----------------------------------------------------------
PHYS_MOVE_SHIP:
        PUSHALL
        cmp.b   #KEY_LEFT,KEY_CUR
        beq     .LEFT
        cmp.b   #KEY_RIGHT,KEY_CUR
        beq     .RIGHT
        bra     .DONE
.LEFT:
        move.w  SHIP_X_CUR,d0
        sub.w   #SHIP_X_STEP,d0
        cmp.w   #SHIP_X_MIN,d0
        bge     .APPLY
        move.w  #SHIP_X_MIN,d0
        bra     .APPLY
.RIGHT:
        move.w  SHIP_X_CUR,d0
        add.w   #SHIP_X_STEP,d0
        cmp.w   #SHIP_X_MAX,d0
        ble     .APPLY
        move.w  #SHIP_X_MAX,d0
.APPLY:
        move.w  d0,SHIP_X_CUR
.DONE:
        POPALL
        rts

; ----------------------------------------------------------
; PHYS_MOVE_BULLET
; Moves active bullet up by 6 pixels
; If bullet goes past top (Y < 0) : deactivates it
; Updates BULLET_Y, BULLET_Y_PREV, BULLET_ACTIVE
; Returns : d0 = 0 bullet still active, 1 = bullet deactivated
; ----------------------------------------------------------
PHYS_MOVE_BULLET:
        move.w  BULLET_Y,d0
        sub.w   #6,d0
        bmi     .OUT
        move.w  d0,BULLET_Y
        clr.w   d0                      ; return 0 : bullet still active
        rts
.OUT:
        clr.w   BULLET_ACTIVE
        moveq   #1,d0                   ; return 1 : bullet deactivated
        rts

; ----------------------------------------------------------
; PHYS_MOVE_GRID
; Moves the enemy grid one step horizontally.
; If a border is reached : drops the grid down and reverses direction.
; Updates GRID_X, GRID_Y, GRID_DIR.
; Returns : d0 = 0 normal move, 1 = border hit (drop occurred)
; ----------------------------------------------------------
PHYS_MOVE_GRID:
        PUSHALL

        move.w  GRID_DIR,d0             ; d0 = direction (+1 or -1)
        move.w  GRID_X,d1               ; d1 = current X

        ; apply horizontal step
        muls    #ENM_MOVE_STEP,d0       ; d0 = signed delta
        add.w   d0,d1                   ; d1 = new X

        ; check left border
        cmp.w   #ENM_GRID_X_MIN,d1
        blt     .HIT_BORDER

        ; check right border
        cmp.w   #ENM_GRID_X_MAX,d1
        bgt     .HIT_BORDER

        ; no border : apply new X
        move.w  d1,GRID_X
        moveq   #0,d0                   ; return 0 : normal move
        bra     .DONE

.HIT_BORDER:
        ; clamp X to border
        move.w  GRID_DIR,d0
        tst.w   d0
        bmi     .CLAMP_LEFT
        move.w  #ENM_GRID_X_MAX,GRID_X
        bra     .DROP
.CLAMP_LEFT:
        move.w  #ENM_GRID_X_MIN,GRID_X
.DROP:
        ; drop grid down
        move.w  GRID_Y,d1
        add.w   #ENM_DROP_STEP,d1
        move.w  d1,GRID_Y

        ; reverse direction
        neg.w   GRID_DIR

        moveq   #1,d0                   ; return 1 : border hit

.DONE:
        POPALL
        rts

; ----------------------------------------------------------
; PHYS_UPDATE
; Updates all sprites (position, velocity)
; a0 = sprite array address
; d7 = number of sprites - 1
; ----------------------------------------------------------
PHYS_UPDATE:
        PUSHALL
        ; move.w  SPR_POS_X(a0),d0
        ; add.w   SPR_VEL_X(a0),d0
        ; move.w  d0,SPR_POS_X(a0)
        POPALL
        rts

; ----------------------------------------------------------
; PHYS_COLLISION
; Bounding box collision test between two sprites
; a0 = sprite 1, a1 = sprite 2
; Return : d0 = 0 no collision, 1 = collision
; ----------------------------------------------------------
PHYS_COLLISION:
        PUSHALL
        ; ... collision code ...
        POPALL
        rts
