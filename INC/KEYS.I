;===========================================================
; KEYS.I - IKBD keyboard scancodes (Atari ST)
; Contains only EQU directives no bytes generated
;===========================================================

; -------------------------------------------------------
; Function keys
; -------------------------------------------------------
KEY_ESC         equ     $01
KEY_F1          equ     $3B
KEY_F2          equ     $3C
KEY_F3          equ     $3D
KEY_F4          equ     $3E
KEY_F5          equ     $3F
KEY_F6          equ     $40
KEY_F7          equ     $41
KEY_F8          equ     $42
KEY_F9          equ     $43
KEY_F10         equ     $44

; -------------------------------------------------------
; Navigation
; -------------------------------------------------------
KEY_UP          equ     $48
KEY_DOWN        equ     $50
KEY_LEFT        equ     $4B
KEY_RIGHT       equ     $4D
KEY_HELP        equ     $62
KEY_UNDO        equ     $61
KEY_INSERT      equ     $52
KEY_DELETE      equ     $53
KEY_HOME        equ     $47
KEY_CLRHOME     equ     $47

; -------------------------------------------------------
; Common keys
; -------------------------------------------------------
KEY_RETURN      equ     $1C
KEY_SPACE       equ     $39
KEY_BACKSPACE   equ     $0E
KEY_TAB         equ     $0F
KEY_CAPSLOCK    equ     $3A
KEY_F           equ     $21
KEY_K           equ     $25

; -------------------------------------------------------
; Modifiers
; -------------------------------------------------------
KEY_LSHIFT      equ     $2A
KEY_RSHIFT      equ     $36
KEY_CTRL        equ     $1D
KEY_ALT         equ     $38

; -------------------------------------------------------
; Numpad
; -------------------------------------------------------
KEY_NUM0        equ     $70
KEY_NUM1        equ     $6D
KEY_NUM2        equ     $6E
KEY_NUM3        equ     $6F
KEY_NUM4        equ     $6A
KEY_NUM5        equ     $6B
KEY_NUM6        equ     $6C
KEY_NUM7        equ     $67
KEY_NUM8        equ     $68
KEY_NUM9        equ     $69
KEY_NUMMUL      equ     $65
KEY_NUMDIV      equ     $65
KEY_NUMADD      equ     $4E
KEY_NUMSUB      equ     $4A
KEY_NUMENTER    equ     $72
