;===========================================================
; LOOPS/ENEMIES.S - Enemy grid init and display
; Called from BCL_PLAY
;===========================================================

; ----------------------------------------------------------
; ENEMIES_INIT
; Fills ENEMY_TABLE sequentially with types 1..26
; then cycles back. Sets grid position.
; ----------------------------------------------------------
ENEMIES_INIT:
        PUSHALL

        ; --- fill ENEMY_TABLE : type 1..26 cycling ---
        lea     ENEMY_TABLE,a0
        move.w  #ENM_COUNT-1,d7
        move.b  #1,d0                   ; start at type 1
.FILL:
        move.b  d0,(a0)+
        addq.b  #1,d0
        cmp.b   #ENM_TYPE_MAX+1,d0
        bne     .NO_WRAP
        move.b  #1,d0                   ; wrap back to type 1
.NO_WRAP:
        dbf     d7,.FILL

        ; --- init grid position and movement state ---
        move.w  #ENM_GRID_X_MIN,GRID_X
        move.w  #20,GRID_Y
        move.w  #1,GRID_DIR             ; start moving right
        move.w  #ENM_MOVE_DELAY,GRID_MOVE_TIMER
        move.w  #ENM_COUNT,GRID_ALIVE

        POPALL
        rts

; ----------------------------------------------------------
; ENEMIES_DRAW
; Draws all living enemies on screen
; Iterates col/row counters to avoid divu/mulu per enemy
; Registers :
;   a4 = enemy table ptr
;   d7 = loop counter
;   d3 = col counter (0..ENM_COLS-1)
;   d4 = row counter (0..ENM_ROWS-1)
;   d5 = current X
;   d6 = current Y
; ----------------------------------------------------------
ENEMIES_DRAW:
        PUSHALL

        lea     ENEMY_TABLE,a4
        move.w  #ENM_COUNT-1,d7

        clr.w   d3                      ; col = 0
        clr.w   d4                      ; row = 0
        move.w  GRID_X,d5               ; X = GRID_X
        move.w  GRID_Y,d6               ; Y = GRID_Y

.DRAW_LOOP:
        move.b  (a4)+,d0               ; d0 = type (0=dead)
        beq     .NEXT                   ; type 0 = dead, skip

        ; --- get sprite pointer ---
        and.w   #$00FF,d0
        cmp.w   #20,d0
        bgt     .USE_BIN2

        ; BIN_ENEMIES1 : type 1..20
        subq.w  #1,d0                   ; 0-based index
        mulu    #ENM_SIZE,d0
        lea     BIN_ENEMIES1+SPR_HDR,a0
        add.l   d0,a0
        bra     .DO_DRAW

.USE_BIN2:
        ; BIN_ENEMIES2 : type 21..26
        sub.w   #21,d0                  ; 0-based index in BIN2
        mulu    #ENM_SIZE,d0
        lea     BIN_ENEMIES2+SPR_HDR,a0
        add.l   d0,a0

.DO_DRAW:
        move.w  d5,d0                   ; d0 = X
        move.w  d6,d1                   ; d1 = Y
        move.w  #ENM_H,d2               ; d2 = height
        jsr     GFX_DRAW_SPRITE

.NEXT:
        ; --- advance col/X ---
        addq.w  #1,d3
        add.w   #ENM_STEP_X,d5
        cmp.w   #ENM_COLS,d3
        bne     .DRAW_LOOP_END

        ; --- end of row : reset col/X, advance row/Y ---
        clr.w   d3
        move.w  GRID_X,d5
        addq.w  #1,d4
        add.w   #ENM_STEP_Y,d6

.DRAW_LOOP_END:
        dbf     d7,.DRAW_LOOP

        POPALL
        rts

; ----------------------------------------------------------
; ENEMIES_SAVE_BG
; Snapshots GRID_Y so ENEMIES_UPDATE knows the old top position
; ----------------------------------------------------------
ENEMIES_SAVE_BG:
        move.w  GRID_Y,ENEMIES_BG_GRID_Y
        rts

; ----------------------------------------------------------
; ENEMIES_UPDATE
; Called every frame from BCL_PLAY.
; Decrements GRID_MOVE_TIMER. When it reaches zero :
;   - restores bg lines covering old+new grid zone
;   - calls PHYS_MOVE_GRID
;   - redraws the grid
;   - reloads timer (faster when fewer aliens alive)
; Also checks game over condition (grid reached player line).
; ----------------------------------------------------------
ENEMIES_UPDATE:
        PUSHALL

        ; --- decrement timer ---
        subq.w  #1,GRID_MOVE_TIMER
        bne     .NO_MOVE

        ; --- restore bg rect covering old grid zone ---
        ; X = ENM_GRID_X_MIN (grille commence toujours au bord gauche possible)
        ; width = ENM_GRID_W + ENM_MOVE_STEP*2 + 16 (marge déplacement + débordement sprite)
        ; Y = saved GRID_Y, height = full grid height
        clr.w   d0                      ; X = 0 (full width)
        move.w  ENEMIES_BG_GRID_Y,d1   ; Y
        move.w  #320,d2                 ; width = full screen width
        move.w  #(ENM_ROWS-1)*ENM_STEP_Y+ENM_H,d3  ; height
        lea     RAW_LEVEL1,a0
        jsr     GFX_RESTORE_RECT

        ; --- move grid ---
        jsr     PHYS_MOVE_GRID

        ; --- check game over : grid too low ---
        move.w  GRID_Y,d0
        cmp.w   #ENM_GAMEOVER_Y,d0
        blt     .NO_GAMEOVER
        move.w  #STATE_GAMEOVER,GAME_STATE
.NO_GAMEOVER:

        ; --- redraw grid and snapshot new GRID_Y ---
        jsr     ENEMIES_DRAW
        jsr     ENEMIES_SAVE_BG

        ; --- reload timer : faster as aliens die ---
        ; delay = max(ENM_MOVE_DELAY_MIN, GRID_ALIVE*ENM_MOVE_DELAY/ENM_COUNT)
        move.w  GRID_ALIVE,d0
        mulu    #ENM_MOVE_DELAY,d0
        divu    #ENM_COUNT,d0
        cmp.w   #ENM_MOVE_DELAY_MIN,d0
        bge     .SET_TIMER
        move.w  #ENM_MOVE_DELAY_MIN,d0
.SET_TIMER:
        move.w  d0,GRID_MOVE_TIMER

.NO_MOVE:
        POPALL
        rts
