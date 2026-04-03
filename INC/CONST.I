;===========================================================
; CONST.I - Game constants
; Contains only EQU directives - no bytes generated
; No hardware addresses here -> see HW_ST.I
;===========================================================
; -------------------------------------------------------
; Screen
; -------------------------------------------------------
SCR_W         equ     320         	; width in pixels
SCR_H         equ     200         	; height in pixels
SCR_BYTES    equ     32000       	; screen size in bytes (320*200/8*2)
SCR_WORDS      equ     8000        	; screen size in words

; -------------------------------------------------------
; Sprites
; -------------------------------------------------------
SPR_W_BYTES     equ     8               ; sprite width in bytes (16px = 4 planes x 1 word)
SPR_H           equ     16              ; sprite height in lines
SPR_HDR         equ     16              ; header size in bytes (global, once per BIN file)
SPR_BLOCK       equ     128             ; one block (sprite or mask) = 128 bytes (8*16)
MSK_BLOCK       equ     SPR_BLOCK       ; offset to mask block from start of sprite block
SPR_SIZE        equ     256             ; one sprite entry = sprite+mask = 256 bytes (128+128)
SCR_ROW_BYTES   equ     160             ; screen row width in bytes

; -------------------------------------------------------
; SHIP.BIN sprite indices (offsets from BIN_SPRITE)
; 1 global header (SPR_HDR bytes), then sprites contiguous
; -------------------------------------------------------
SHIP_SPR        equ     SPR_HDR                 ; neutral (no key)
SHIP_SPR_R      equ     SHIP_SPR+SPR_SIZE       ; moving right
SHIP_SPR_L      equ     SHIP_SPR_R+SPR_SIZE     ; moving left
SHIP_SPR_FIRE   equ     SHIP_SPR_L+SPR_SIZE     ; bullet
SHIP_SPR_EXP0   equ     SHIP_SPR_FIRE+SPR_SIZE  ; explosion frame 0
SHIP_SPR_EXP1   equ     SHIP_SPR_EXP0+SPR_SIZE  ; explosion frame 1
SHIP_SPR_EXP2   equ     SHIP_SPR_EXP1+SPR_SIZE  ; explosion frame 2
SHIP_SPR_EXP3   equ     SHIP_SPR_EXP2+SPR_SIZE  ; explosion frame 3
SHIP_SPR_EXP4   equ     SHIP_SPR_EXP3+SPR_SIZE  ; explosion frame 4

; -------------------------------------------------------
; Enemies sprites
; -------------------------------------------------------
ENM_H           equ     10              ; enemy sprite height in lines
ENM_BLOCK       equ     80              ; one block = 10*8 = 80 bytes
ENM_SIZE        equ     160             ; sprite + mask = 160 bytes

; ENEMIES1.BIN : types 1..20  (type 0 = dead/empty)
; ENEMIES2.BIN : types 21..31 + explosion frames 27..31
ENM_TYPE_MAX    equ     26              ; max living type
ENM_EXP_0       equ     27             ; explosion frame 0
ENM_EXP_1       equ     28             ; explosion frame 1
ENM_EXP_2       equ     29             ; explosion frame 2
ENM_EXP_3       equ     30             ; explosion frame 3
ENM_EXP_4       equ     31             ; explosion frame 4

; -------------------------------------------------------
; Enemy grid
; -------------------------------------------------------
ENM_COLS        equ     8               ; columns
ENM_ROWS        equ     1               ; rows
ENM_COUNT       equ     ENM_COLS*ENM_ROWS           ; total enemies
ENM_STEP_X      equ     24              ; horizontal spacing in pixels
ENM_STEP_Y      equ     16              ; vertical spacing in lines
ENM_GRID_W      equ     ENM_COLS*ENM_STEP_X         ; grid width in pixels
ENM_GRID_X_MIN  equ     8               ; left bound
ENM_GRID_X_MAX  equ     SCR_W-ENM_GRID_W-16         ; right bound
ENM_MOVE_STEP   equ     2               ; pixels per move
ENM_DROP_STEP   equ     8               ; lines to drop when hitting a border
ENM_MOVE_DELAY  equ     10              ; initial frames between grid moves
ENM_MOVE_DELAY_MIN equ  4               ; minimum frames between grid moves
ENM_GAMEOVER_Y  equ     160             ; Y line triggering game over

; -------------------------------------------------------
; Tiles
; -------------------------------------------------------
TILE_W          equ     16          ; tile width in pixels
TILE_H          equ     16          ; tile height in pixels
TILE_BYTES     equ     128         ; tile size in bytes (16*16/8*4 bitplanes)

; -------------------------------------------------------
; Game -  adjust to your project
; -------------------------------------------------------
LIVES_MAX         equ     3
SCORE_MAX         equ     99999
NB_SPRITES_MAX    equ     16

; -------------------------------------------------------
; Ship horizontal position in pixels
; X (pixels) = column * 16  must always be a multiple of 16
; Screen = 320px = 20 columns (col 0..19)
; Sprite = 32px = 2 columns wide
; -------------------------------------------------------
SHIP_X_MIN        equ     0           ; col 0  -> X = 0
SHIP_X_MAX        equ     288         ; col 18 -> X = 288 (320 - 32)
SHIP_X_STEP       equ     3           ; pixels per frame
SHIP_X_INIT       equ     143         ; col 9  -> X = 144 (center)

; -------------------------------------------------------
; State timers (frames at 50Hz)
; -------------------------------------------------------
READY_DELAY         equ     50          ; 1 second
NEXT_LVL_DELAY      equ     50          ; 1 second
DEATH_DELAY         equ     50          ; 1 second

; -------------------------------------------------------
; Game states (GAME_STATE)
; -------------------------------------------------------
STATE_TITLE         equ     1
STATE_READY         equ     2
STATE_PLAY          equ     3
STATE_DEATH         equ     4
STATE_GAMEOVER      equ     5
STATE_NEXT_LVL      equ     6
