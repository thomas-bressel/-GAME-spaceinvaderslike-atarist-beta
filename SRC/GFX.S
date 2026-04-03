;===========================================================
; GFX.S - Drawing engine: tiles, sprites
; Depends : INC/HW_ST.I, INC/CONST.I, INC/STRUCT.I
; Data    : DATA/GFX/*.SPR, *.TIL, *.PAL
;===========================================================
; ----------------------------------------------------------
; GFX_INIT
; Initializes the graphics engine
; ----------------------------------------------------------
GFX_INIT:
	PUSHALL
	; load palette
	; load tileset
	POPALL
	rts

; ----------------------------------------------------------
; GFX_CLEAR_SCREEN
; Clears the drawing buffer
; ----------------------------------------------------------
GFX_CLEAR_SCREEN:
        PUSHALL
        move.l  SCR_ADDR_L,a1
        move.w  #SCR_WORDS-1,d7
.LOOP:
        clr.l   (a1)+
        dbf     d7,.LOOP
        POPALL
        rts

; ----------------------------------------------------------
; GFX_CLEAR_LINES
; Clears a range of full screen lines (160 bytes each) to zero
; d0 = first line (Y start)
; d1 = number of lines to clear
; ----------------------------------------------------------
GFX_CLEAR_LINES:
        PUSHALL
        move.l  SCR_ADDR_L,a1
        move.w  d0,d2
        move.w  d2,d3
        lsl.w   #7,d2
        lsl.w   #5,d3
        add.w   d3,d2
        add.w   d2,a1
        move.w  d1,d7
        mulu    #40,d7
        subq.w  #1,d7
.CLEAR_LOOP:
        clr.l   (a1)+
        dbf     d7,.CLEAR_LOOP
        POPALL
        rts

; ----------------------------------------------------------
; GFX_RESTORE_LINES
; Copies a range of lines from a RAW background buffer to screen
; a0 = RAW pixel data (32000 bytes, no header)
; d0 = first line (Y start)
; d1 = number of lines to copy
; ----------------------------------------------------------
GFX_RESTORE_LINES:
        PUSHALL
        ; offset in RAW = Y*160
        move.w  d0,d2
        move.w  d2,d3
        lsl.w   #7,d2
        lsl.w   #5,d3
        add.w   d3,d2                   ; d2 = Y*160
        ; source : RAW + offset
        add.w   d2,a0
        ; dest : SCR_ADDR + offset
        move.l  SCR_ADDR_L,a1
        add.w   d2,a1
        ; nb longs = lines * 40
        move.w  d1,d7
        mulu    #40,d7
        subq.w  #1,d7
.RESTORE_LOOP:
        move.l  (a0)+,(a1)+
        dbf     d7,.RESTORE_LOOP
        POPALL
        rts

; ----------------------------------------------------------
; GFX_RESTORE_RECT
; Copies a rectangle from a RAW background buffer to screen
; a0 = RAW pixel data (32000 bytes, no header)
; d0 = X in pixels (must be multiple of 16)
; d1 = Y first line
; d2 = width in pixels (must be multiple of 16)
; d3 = height in lines
; ----------------------------------------------------------
GFX_RESTORE_RECT:
        PUSHALL

        ; col offset = X/16*8 (bytes per column = 8)
        move.w  d0,d5
        lsr.w   #4,d5                   ; d5 = X/16
        lsl.w   #3,d5                   ; d5 = col*8 = byte offset in line

        ; row offset = Y*160
        move.w  d1,d6
        move.w  d6,d7
        lsl.w   #7,d6
        lsl.w   #5,d7
        add.w   d7,d6                   ; d6 = Y*160

        ; width in bytes per plane pair = W/16*8
        move.w  d2,d4
        lsr.w   #4,d4
        lsl.w   #3,d4                   ; d4 = width in bytes (per line)

        ; a0 source = RAW + Y*160 + col*8
        add.w   d6,a0
        add.w   d5,a0

        ; a1 dest = SCR_ADDR + Y*160 + col*8
        move.l  SCR_ADDR_L,a1
        add.w   d6,a1
        add.w   d5,a1

        ; skip = SCR_ROW_BYTES - width (to jump to next line)
        move.w  #SCR_ROW_BYTES,d6
        sub.w   d4,d6                   ; d6 = line skip (source and dest same)

        ; d3 = height counter
        subq.w  #1,d3

.RECT_LINE:
        ; copy d4 bytes from source to dest (d4 is multiple of 4)
        move.w  d4,d7
        lsr.w   #2,d7                   ; d7 = nb longs
        subq.w  #1,d7
.RECT_COL:
        move.l  (a0)+,(a1)+
        dbf     d7,.RECT_COL

        ; next line
        add.w   d6,a0
        add.w   d6,a1
        dbf     d3,.RECT_LINE

        POPALL
        rts

; ----------------------------------------------------------
; GFX_LOAD_PALETTE
; a0 = palette address (16 words format $0RGB)
; ----------------------------------------------------------
GFX_LOAD_PALETTE:
        PUSHALL
        movem.l (a0),d0-d7
        movem.l d0-d7,PAL_BASE
        POPALL
        rts

; ----------------------------------------------------------
; GFX_PALETTE_PI1
; Extracts and loads the palette directly from a PI1 file
; a0 = PI1 file address in memory
; Palette is at offset +2 in the PI1
; ----------------------------------------------------------
GFX_PALETTE_PI1:
        PUSHALL
        lea     2(a0),a0            ; skip header (resolution word)
        movem.l (a0),d0-d7          ; read 16 colors (32 bytes)
        movem.l d0-d7,PAL_BASE      ; load into hardware registers
        POPALL
        rts

; ----------------------------------------------------------
; GFX_SHOW_PI1
; Copies a full PI1 image (palette + pixels) to the screen
; a0 = PI1 file address in memory
; ----------------------------------------------------------
GFX_SHOW_PI1:
        PUSHALL
        bsr     GFX_PALETTE_PI1         ; load palette from PI1 (offset +2)
        lea     34(a0),a0               ; skip header (2) + palette (32)
        move.l  SCR_ADDR_L,a1          ; destination: current frame buffer
        move.w  #SCR_WORDS-1,d7        ; 8000 long words = 32000 bytes
.LOOP:
        move.l  (a0)+,(a1)+
        dbf     d7,.LOOP
        POPALL
        rts

; ----------------------------------------------------------
; GFX_DISPLAY_RAW
; Loads palette then copies RAW pixel data to screen
; a0 = RAW pixel data address
; a1 = PAL palette address (32 bytes)
; ----------------------------------------------------------
GFX_DISPLAY_RAW:
        PUSHALL
        move.l  a0,a2                   ; save RAW address
        move.l  a1,a0                   ; a1 = palette address -> a0 for GFX_LOAD_PALETTE
        bsr     GFX_LOAD_PALETTE
        move.l  a2,a0                   ; restore RAW address
        move.l  SCR_ADDR_L,a3          ; destination: current frame buffer
        move.w  #SCR_WORDS-1,d7        ; 8000 long words = 32000 bytes
.LOOP:
        move.l  (a0)+,(a3)+
        dbf     d7,.LOOP
        POPALL
        rts

; ----------------------------------------------------------
; GFX_SAVE_BG
; Saves the screen zone under a sprite into a buffer
; a0 = destination save buffer
; d0 = X position in pixels
; d1 = Y position in lines
; d2 = height in lines
; Saves 24 bytes per line (3 cols x 8 bytes) to cover preshift spill
; ----------------------------------------------------------
GFX_SAVE_BG:
        PUSHALL
        subq.w  #1,d2

        ; screen address = SCR_ADDR_L + Y*160 + (X/16)*8
        move.l  SCR_ADDR_L,a1
        move.w  d1,d3
        move.w  d3,d4
        lsl.w   #7,d3
        lsl.w   #5,d4
        add.w   d4,d3
        add.w   d3,a1
        move.w  d0,d3
        lsr.w   #4,d3
        lsl.w   #3,d3
        add.w   d3,a1

.SAVE_LINE:
        move.l  (a1),d3
        move.l  d3,(a0)+
        move.l  4(a1),d3
        move.l  d3,(a0)+
        move.l  8(a1),d3
        move.l  d3,(a0)+
        move.l  12(a1),d3
        move.l  d3,(a0)+
        move.l  16(a1),d3
        move.l  d3,(a0)+
        move.l  20(a1),d3
        move.l  d3,(a0)+
        add.l   #SCR_ROW_BYTES,a1
        dbf     d2,.SAVE_LINE

        POPALL
        rts

; ----------------------------------------------------------
; GFX_RESTORE_BG
; Restores the screen zone from a save buffer
; a0 = source save buffer
; d0 = X position in pixels
; d1 = Y position in lines
; d2 = height in lines
; ----------------------------------------------------------
GFX_RESTORE_BG:
        PUSHALL
        subq.w  #1,d2

        ; screen address = SCR_ADDR_L + Y*160 + (X/16)*8
        move.l  SCR_ADDR_L,a1
        move.w  d1,d3
        move.w  d3,d4
        lsl.w   #7,d3
        lsl.w   #5,d4
        add.w   d4,d3
        add.w   d3,a1
        move.w  d0,d3
        lsr.w   #4,d3
        lsl.w   #3,d3
        add.w   d3,a1

.RESTORE_LINE:
        move.l  (a0)+,d3
        move.l  d3,(a1)
        move.l  (a0)+,d3
        move.l  d3,4(a1)
        move.l  (a0)+,d3
        move.l  d3,8(a1)
        move.l  (a0)+,d3
        move.l  d3,12(a1)
        move.l  (a0)+,d3
        move.l  d3,16(a1)
        move.l  (a0)+,d3
        move.l  d3,20(a1)
        add.l   #SCR_ROW_BYTES,a1
        dbf     d2,.RESTORE_LINE

        POPALL
        rts

; ----------------------------------------------------------
; GFX_DRAW_SPRITE
; Draws a 16px-wide sprite at any pixel position using dynamic preshift
; a0 = pointer to sprite data (after global header, at SHIP_SPR_x offset)
; d0 = X position in pixels (0..304)
; d1 = Y position in lines  (0..183)
;
; .BIN format (global header + contiguous sprites) :
;   offset +0  : word  width in bytes (8 = 16px, 4 planes x 1 word)
;   offset +2  : word  height in lines (SPR_H)
;   offset +4  : 12 bytes reserved
;   offset +16 : sprite 0 : sprite block (SPR_BLOCK) + mask block (SPR_BLOCK)
;   offset +272: sprite 1 : ...
;
; a0 must point to the START of the sprite block (use SHIP_SPR_x offsets)
; height is fixed = SPR_H (read from constant, not from data)
;
; Technique : preshift = X AND 15
;   per plane : word -> high of long, zero/FFFF in low, lsr.l by preshift
;   -> high word = block1 (column X/16), low word = block2 (column X/16+1)
;   AND shifted mask to punch hole, OR shifted sprite to draw
;
; Registers (all saved/restored via PUSHALL/POPALL):
;   d0 = X pos            d1 = Y pos
;   d2 = scratch          d3 = fill mask long (fill:0000)
;   d4 = line counter     d5 = preshift (0..15)
;   d6 = sprite long      d7 = mask long
;   a0 = sprite ptr       a1 = mask ptr
;   a2 = block2 dst       a3 = block1 dst
; ----------------------------------------------------------
GFX_DRAW_SPRITE:
        PUSHALL

        ; line counter : height passed in d2, converted to dbf counter
        move.w  d2,d4
        subq.w  #1,d4
        ; save X pos value for a futur screen adress clac
        move.w  d0,d5
        ; preshift = X AND 15
        and.w   #%00001111,d5

        ; --- fill mask : top d5 bits of high word = 1, as long fill:0000 ---
        ; used with or.l to fix block1 mask without swap
        move.w  #$FFFF,d3
        ; preshifting d3 = %0011 1111 1111 1111
        lsr.w   d5,d3 
        ; invert bits = %1100 0000 0000 0000
        not.w   d3
        ; swap to get bits in high word
        swap    d3    ; %1100 0000 0000 0000 | %0000 0000 0000 0000
        clr.w   d3

        ; --- block1 screen address : SCR_ADDR + Y*160 + (X/16)*8 ---
        ; Y*160 = Y*128 + Y*32 (shifts only, no mulu)
        move.l  SCR_ADDR_L,a3
        ; d6 for sprite posY and d7 for mask posY
        move.w  d1,d6
        move.w  d6,d7
        ; adress calc
        lsl.w   #7,d6                   ; d6 = Y*128
        lsl.w   #5,d7                   ; d7 = Y*32
        add.w   d7,d6                   ; d6 = Y*160
        add.w   d6,a3
        move.w  d0,d6
        lsr.w   #4,d6                   ; d6 = X/16 (column index)
        lsl.w   #3,d6                   ; d6 = col*8
        add.w   d6,a3                   ; a3 = block1 start

        ; --- a1 = mask block : height * 8 bytes after sprite block ---
        move.l  a0,a1
        move.w  d2,d6
        mulu    #SPR_W_BYTES,d6
        add.l   d6,a1

.LINE_LOOP:
        move.l  a3,a2                   ; a3 = block1 screen start
        add.w   #8,a2                   ; a2 = block2 screen start

        REPT 4
        ; --- sprite (1 plan) ---
        ; lit 1 word sprite depuis BIN_SPRITE, place en mot haut du long
        ; mot bas = 0 (pas de pixels de debordement par defaut)
        ; lsr.l d5 : decale les 32 bits vers la droite de d5 positions
        ;   -> mot haut = pixels du sprite decales dans block1
        ;   -> mot bas  = pixels qui debordent dans block2
        ; d6 = [b1_spr | b2_spr]
        move.w  (a0)+,d6                ; lit 1 word sprite (16 pixels, 1 plan)
        swap    d6                      ; place en mot haut : d6 = [sprite | ???]
        clr.w   d6                      ; mot bas = 0 : d6 = [sprite | 0000]
        lsr.l   d5,d6                   ; preshift : d6 = [b1_spr | b2_spr]

        ; --- masque (1 plan) ---
        ; lit 1 word masque depuis BIN_SPRITE, place en mot haut du long
        ; mot bas = $FFFF (fond conserve partout par defaut dans block2)
        ; lsr.l d5 : decale les 32 bits, des zeros parasites entrent a gauche
        ; or.l d3 : restaure les d5 bits de gauche a 1 (fond intact avant le sprite)
        ; d7 = [b1_msk | b2_msk]
        move.w  (a1)+,d7                ; lit 1 word masque (0=trou sprite, 1=fond conserve)
        swap    d7                      ; place en mot haut : d7 = [masque | ???]
        move.w  #$FFFF,d7               ; mot bas = $FFFF : d7 = [masque | FFFF]
        lsr.l   d5,d7                   ; preshift : zeros parasites entrent a gauche
        or.l    d3,d7                   ; corrige les d5 bits parasites en haut : d7 = [b1_msk | b2_msk]

        ; --- ecriture block1 (colonne gauche) ---
        ; and : perce le trou dans le fond a la forme du sprite
        ; or  : pose les pixels du sprite dans le trou
        move.w  d7,d2                   ; sauvegarde b2_msk (mot bas) avant swap
        swap    d7                      ; d7.w = b1_msk (mot haut)
        and.w   d7,(a3)                 ; fond AND masque -> trou a la forme du sprite
        move.w  d6,d7                   ; sauvegarde b2_spr (mot bas) avant swap
        swap    d6                      ; d6.w = b1_spr (mot haut)
        or.w    d6,(a3)+                ; fond_troue OR sprite -> sprite pose, a3 avance 2 octets

        ; --- ecriture block2 (colonne droite, pixels de debordement) ---
        and.w   d2,(a2)                 ; fond AND b2_msk -> trou pour les pixels qui debordent
        or.w    d7,(a2)+                ; fond_troue OR b2_spr -> pixels de debordement poses
        ENDR

        ; next line : a3 advanced 8 bytes by REPT, compensate to reach next line start
        ; a0 and a1 advance naturally (no skip needed, blocks are contiguous)
        add.l   #SCR_ROW_BYTES-8,a3

        dbf     d4,.LINE_LOOP

        POPALL
        rts

; ----------------------------------------------------------
; GFX data - binaries included from DATA/
; ----------------------------------------------------------

; ----------------------------------------------------------
; PI1 file structure (Degas Elite low resolution):
;   offset +0  : 2 bytes   resolution number (word)
;   offset +2  : 32 bytes  16-color palette (16 words $0RGB)
;   offset +34 : 32000 bytes  pixels in bitplanes
; ----------------------------------------------------------
BIN_PALETTE:    incbin  ../DATA/GFX/DAMIER.PAL
                even
BIN_RAW:        incbin  ../DATA/GFX/DAMIER.RAW
                even

PAL_TITLE:      incbin  ../DATA/GFX/TITLE.PAL
                even
RAW_TITLE:      incbin  ../DATA/GFX/TITLE.RAW
		even

PAL_NEXT:      incbin  ../DATA/GFX/NEXT.PAL
                even
RAW_NEXT:      incbin  ../DATA/GFX/NEXT.RAW
                even

PAL_READY:      incbin  ../DATA/GFX/READY.PAL
                even
RAW_READY:      incbin  ../DATA/GFX/READY.RAW
                even

PAL_LEVEL1:     incbin  ../DATA/GFX/DAMIER.PAL
                even
RAW_LEVEL1:     incbin  ../DATA/GFX/DAMIER.RAW
                even
PAL_GAMEOVER:   incbin  ../DATA/GFX/GAMEOVER.PAL
                even
RAW_GAMEOVER:   incbin  ../DATA/GFX/GAMEOVER.RAW
                even

BIN_SPRITE:     incbin  ../DATA/GFX/SHIP.BIN
                even
BIN_ENEMIES1:   incbin  ../DATA/GFX/ENEMIES1.BIN
                even
BIN_ENEMIES2:   incbin  ../DATA/GFX/ENEMIES2.BIN
                even
; BIN_PI1:      incbin  ../DATA/GFX/SCREEN.PI1   ; uncomment when PI1 file is ready
;               even
