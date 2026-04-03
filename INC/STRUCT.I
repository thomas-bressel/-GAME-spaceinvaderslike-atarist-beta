;===========================================================
; STRUCT.I - Data structure offsets
; Contains only EQU directives - no bytes generated
; Usage : move.w SPR_POS_X(a0),d0
;===========================================================
; -------------------------------------------------------
; SPRITE structure (size: 12 bytes)
; -------------------------------------------------------
; Usage:
;   lea     my_sprite,a0
;   move.w  SPR_POS_X(a0),d0    ; read X position
;   move.w  #5,SPR_VEL_X(a0)    ; write X velocity
; -------------------------------------------------------
SPR_POS_X       equ     0       ; X position        (word)
SPR_POS_Y       equ     2       ; Y position        (word)
SPR_VEL_X       equ     4       ; X velocity        (word)
SPR_VEL_Y       equ     6       ; Y velocity        (word)
SPR_FRAME       equ     8       ; current frame     (word)
SPR_FLAGS       equ     10      ; state flags       (word)
SPR_STRUCT_SIZE	equ     12      ; structure size    (for arrays)

; -------------------------------------------------------
; TILE structure (size: 4 bytes)
; -------------------------------------------------------
TIL_INDEX       equ     0       ; index in tileset      (word)
TIL_FLAGS       equ     2       ; flags (solid, etc.)   (word)
TIL_SIZE      	equ     4
