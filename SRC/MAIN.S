l;===========================================================
; MAIN.S - Entry point and main loop
;===========================================================
; Startup sequence:
;   1. Mshrink      - free unused memory
;   2. Supervisor   - hardware access
;   3. Save state   - palette, resolution, screen
;   4. Mouse off    - hide the mouse
;   5. Game init    - interrupts, music, gfx
;   6. Main loop
;   7. Clean exit   (reverse order of startup)
;===========================================================

        SECTION TEXT

        include ../INC/TOS.I
        include ../INC/HW_ST.I
        include ../INC/VECTORS.I
        include ../INC/CONST.I
        include ../INC/KEYS.I
        include ../INC/MACROS.I
        include ../INC/STRUCT.I

; ==========================================================
; STARTUP
; ==========================================================

; ----------------------------------------------------------
; 1. MSHRINK frees unused RAM back to TOS
;    Required if a player calls Malloc
; ----------------------------------------------------------
        
        move.l  4(sp),a5           ; a5 = basepage address
        move.l  bp_tlen(a5),d0     ; TEXT segment size
        add.l   bp_dlen(a5),d0     ; + DATA
        add.l   bp_blen(a5),d0     ; + BSS
        add.l   #$1000,d0          ; + stack (4KB)
        add.l   #$100,d0           ; + basepage (256 bytes)

        move.l  a5,d1
        add.l   d0,d1
        and.l   #-2,d1             ; word alignment required
        move.l  d1,sp              ; reposition the stack

        move.l  d0,-(sp)
        move.l  a5,-(sp)
        move.w  d0,-(sp)
        move.w  #_Mshrink,-(sp)
 	trap    #GEMDOS
 	lea     12(sp),sp

; ----------------------------------------------------------
; 2. SUPERVISOR MODE
; ----------------------------------------------------------
        bsr     SYS_SUPERVISOR

; ----------------------------------------------------------
; 3. SAVE STATE
; ----------------------------------------------------------
        bsr     SYS_SAVE_SCREEN     ; save original TOS screen address
        bsr     SYS_SAVE_PALETTE    ; GEM palette
        bsr     SYS_SAVE_RESOL      ; current resolution

; ----------------------------------------------------------
; 4. HIDE MOUSE + DISABLE KEY CLICK
; ----------------------------------------------------------
        bsr     SYS_MOUSE_OFF
        move.b  #%0110,CONTERM             ; disable key click

; ----------------------------------------------------------
; 5. GAME INIT
; ----------------------------------------------------------
        bsr     SYS_LOW_RESOL       ; switch to low resolution

; load RAW image with BIN_PALETTE
	lea     RAW_TITLE,a0
	lea	PAL_TITLE,a1
        bsr     GFX_DISPLAY_RAW

; or use PI1 (palette embedded)        
	 ;lea   BIN_PI1,a0          
         ;bsr   GFX_SHOW_PI1

; uncomment when SND.S is ready
        ; bsr   SND_INIT

; --- init game state and ship position ---
        move.w  #STATE_TITLE,GAME_STATE      ; start on title screen
        move.w  #SHIP_X_INIT,SHIP_X_CUR
        move.w  #SHIP_X_INIT,SHIP_X_PREV
        move.w  #LIVES_MAX,GAME_LIVES_W

; ==========================================================
; MAIN LOOP
; ==========================================================
MAIN_LOOP:
        WAITVBL                             ; wait for VBL

        move.b  IKBD_DATA,KEY_CUR           ; read keyboard once per frame

        jsr     DBG_RED                     ; CPU meter start : border RED
        jsr     DBG_STATE_SWITCH            ; DEBUG : F1-F6 switch game state

        ; --- state dispatcher ---
        move.w  GAME_STATE,d0
        cmp.w   #STATE_TITLE,d0
        beq     .ST_TITLE
        cmp.w   #STATE_READY,d0
        beq     .ST_READY
        cmp.w   #STATE_PLAY,d0
        beq     .ST_PLAY
        cmp.w   #STATE_DEATH,d0
        beq     .ST_DEATH
        cmp.w   #STATE_GAMEOVER,d0
        beq     .ST_GAMEOVER
        cmp.w   #STATE_NEXT_LVL,d0
        beq     .ST_NEXT_LVL
        bra     .ST_END

.ST_TITLE:
        jsr     BCL_TITLE
        bra     .ST_END
.ST_READY:
        jsr     BCL_READY
        bra     .ST_END
.ST_PLAY:
        jsr     BCL_PLAY
        bra     .ST_END
.ST_DEATH:
        jsr     BCL_DEATH
        bra     .ST_END
.ST_GAMEOVER:
        jsr     BCL_GAMEOVER
        bra     .ST_END
.ST_NEXT_LVL:
        jsr     BCL_NEXT_LVL
        bra     .ST_END
.ST_END:
        jsr     DBG_BLACK                   ; CPU meter end : border BLACK
	
        ; --- check ESCAPE key to quit ---
        cmp.b   #KEY_ESC,KEY_CUR
        bne     MAIN_LOOP

; ==========================================================
; EXIT - reverse order of startup
; ==========================================================
        ; bsr   SND_STOP            	; stop music
        move.b  #%0111,CONTERM          ; re-enable key click
        bsr     SYS_MOUSE_ON        	; show mouse
        bsr     SYS_RESTORE_PALETTE    	; restore GEM palette
        bsr     SYS_RESTORE_RESOL      	; restore resolution + screen address
        bsr     SYS_QUIT         	; Pterm does not return

; ----------------------------------------------------------
; INCLUDES - after main code, before data
; ----------------------------------------------------------
        include ../SRC/DEBUG.S
        include ../SRC/SYS.S
        include ../SRC/GFX.S
        include ../SRC/PHYS.S
        ; include ../SRC/SND.S
        include ../SRC/LOOPS/TITLE.S
        include ../SRC/LOOPS/READY.S
        include ../SRC/LOOPS/SHIP.S
        include ../SRC/LOOPS/BULLET.S
        include ../SRC/LOOPS/ENEMIES.S
        include ../SRC/LOOPS/PLAY.S
        include ../SRC/LOOPS/DEATH.S
        include ../SRC/LOOPS/GAMEOVER.S
        include ../SRC/LOOPS/NEXT_LVL.S


        SECTION DATA



        SECTION BSS

        include ../SRC/VARS.S
