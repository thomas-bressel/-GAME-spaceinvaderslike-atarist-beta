;===========================================================
; VARS.S - Global variables (SECTION BSS only)
; Included in MAIN.S after SECTION BSS
; Suffixes: _B = byte, _W = word, _L = long
;===========================================================
; ----------------------------------------------------------
; System variables reserved for SYS.S
; ----------------------------------------------------------
SYS_USP_L:          ds.l    1           ; saved user stack pointer
SYS_OLD_IKBD_L:     ds.l    1           ; saved original IKBD vector
SYS_RESOL_B:        ds.b    1           ; saved GEM resolution
                    ds.b    1           ; alignment
SYS_GEM_PAL:        ds.l    8           ; saved GEM palette (16 words)

; ----------------------------------------------------------
; Screen
; ----------------------------------------------------------
SCR_ADDR_L:        ds.l    1           ; screen address (direct drawing target)
SYS_SCR_ADDR_L:    ds.l    1           ; original TOS screen address (for restore)

; ----------------------------------------------------------
; Game variables
; ----------------------------------------------------------
GAME_LIVES_W:      ds.w    1           ; current number of lives
GAME_SCORE_L:      ds.l    1           ; score
GAME_LEVEL_W:      ds.w    1           ; current level

; ----------------------------------------------------------
; Game state
; ----------------------------------------------------------
GAME_STATE:        ds.w    1           ; current state (STATE_*)

; ----------------------------------------------------------
; State init flags (0 = not init, 1 = init done)
; ----------------------------------------------------------
TITLE_INIT_DONE:    ds.w    1
READY_INIT_DONE:    ds.w    1
PLAY_INIT_DONE:     ds.w    1
DEATH_INIT_DONE:    ds.w    1
GAMEOVER_INIT_DONE: ds.w    1
NEXT_LVL_INIT_DONE: ds.w    1

; ----------------------------------------------------------
; State timer (countdown in frames)
; ----------------------------------------------------------
STATE_TIMER:        ds.w    1

; ----------------------------------------------------------
; Keyboard
; ----------------------------------------------------------
KEY_CUR:           ds.b    1           ; current key : read once per frame from IKBD_DATA
                   ds.b    1           ; alignment
KEY_SCAN:          ds.b    1           ; last scancode (single key, legacy)
KEY_STATE:         ds.b    128         ; key state table: 1=pressed, 0=released
                   even                ; realign after odd-size keyboard block

; ----------------------------------------------------------
; Ship position (pixels)
; ----------------------------------------------------------
SHIP_X_CUR:        ds.w    1           ; current X position
SHIP_X_PREV:       ds.w    1           ; previous X position (for bg restore)
SHIP_KEY_PREV:     ds.b    1           ; previous direction key (for sprite change detection)
                   ds.b    1           ; alignment

; ----------------------------------------------------------
; Sprite background save buffers (3 columns x SPR_H lines = 24*16 bytes)
; ----------------------------------------------------------
SHIP_BG_SAV:       ds.b    24*16       ; saved background under ship sprite
BULLET_BG_SAV:     ds.b    24*16       ; saved background under bullet sprite

; ----------------------------------------------------------
; Bullet (player shot)
; ----------------------------------------------------------
BULLET_ACTIVE:     ds.w    1           ; 0 = no bullet, 1 = active
BULLET_KEY_LOCK:   ds.w    1           ; 1 = F already processed, wait for release
BULLET_X:          ds.w    1           ; X position in pixels
BULLET_Y:          ds.w    1           ; Y position in lines
BULLET_Y_PREV:     ds.w    1           ; previous Y position (for bg restore)

; ----------------------------------------------------------
; Death / explosion
; ----------------------------------------------------------
DEATH_FRAME:       ds.w    1           ; current explosion frame (0..4)

; ----------------------------------------------------------
; Enemy grid
; ----------------------------------------------------------
GRID_X:            ds.w    1           ; X position of top-left enemy
GRID_Y:            ds.w    1           ; Y position of top-left enemy
GRID_DIR:          ds.w    1           ; movement direction : +1=right, -1=left
GRID_MOVE_TIMER:   ds.w    1           ; frames until next grid move
GRID_ALIVE:        ds.w    1           ; number of living enemies (drives speed)
ENEMY_TABLE:       ds.b    ENM_COUNT   ; 1 byte per enemy : 0=dead, 1..26=type
                   even                ; realign after odd-size table
ENEMIES_BG_SAV:    ds.b    ENM_COUNT*240 ; saved background : 24 bytes/line * ENM_H(10) lines * 55 enemies
ENEMIES_BG_GRID_X: ds.w    1             ; GRID_X at time of last SAVE_BG
ENEMIES_BG_GRID_Y: ds.w    1             ; GRID_Y at time of last SAVE_BG

