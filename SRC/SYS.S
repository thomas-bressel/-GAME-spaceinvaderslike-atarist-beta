;===========================================================
; SYS.S - System calls (TRAP GEMDOS/XBIOS)
; All TOS interactions are here
; The rest of the code never has inline TRAPs
;===========================================================
; ----------------------------------------------------------
; SYS_SUPERVISOR
; Switches to supervisor mode and saves the return pointer
; ----------------------------------------------------------
SYS_SUPERVISOR:
        move.l  SYS_USP_L,d0       ; 0 = not yet in supervisor mode
        move.l  d0,-(sp)
        move.w  #_Super,-(sp)
        trap    #GEMDOS
        add.w   #6,sp
        move.l  d0,SYS_USP_L       ; save user stack pointer
        rts

; ----------------------------------------------------------
; SYS_SAVE_SCREEN
; Saves the original TOS screen address for restore on exit
; and sets SCR_ADDR_L to that address (direct drawing target)
; ----------------------------------------------------------
SYS_SAVE_SCREEN:
        move.l  _LOGBASE,d0
        move.l  d0,SYS_SCR_ADDR_L
        move.l  d0,SCR_ADDR_L
        rts

; ----------------------------------------------------------
; SYS_SAVE_PALETTE
; Saves the 16 GEM color registers
; ----------------------------------------------------------
SYS_SAVE_PALETTE:
        PUSHALL
        movem.l PAL_BASE,d0-d7
        movem.l d0-d7,SYS_GEM_PAL
        POPALL
        rts

; ----------------------------------------------------------
; SYS_RESTORE_PALETTE
; Restores the saved GEM palette
; ----------------------------------------------------------
SYS_RESTORE_PALETTE:
        PUSHALL
        movem.l SYS_GEM_PAL,d0-d7
        movem.l d0-d7,PAL_BASE
        POPALL
        rts

; ----------------------------------------------------------
; SYS_SAVE_RESOL
; Saves the current resolution
; ----------------------------------------------------------
SYS_SAVE_RESOL:
        move.b  SCREEN_RES,SYS_RESOL_B
        rts

; ----------------------------------------------------------
; SYS_RESTORE_RESOL
; Restores resolution + screen address in a single Setscreen call
; logbase = original screen address, resol = saved resolution
; ----------------------------------------------------------
SYS_RESTORE_RESOL:
        moveq   #0,d0
        move.b  SYS_RESOL_B,d0         ; saved resolution (0,1,2)
        move.w  d0,-(sp)               ; resolution
        move.l  SYS_SCR_ADDR_L,-(sp)  ; physical screen address
        move.l  SYS_SCR_ADDR_L,-(sp)  ; logical screen address
        move.w  #_Setscreen,-(sp)
        trap    #XBIOS
        add.w   #12,sp
        rts

; ----------------------------------------------------------
; SYS_LOW_RESOL
; Switches to low resolution (320x200 16 colors)
; ----------------------------------------------------------
SYS_LOW_RESOL:
        move.b  #LOW_RES,SCREEN_RES
        rts

; ----------------------------------------------------------
; SYS_CLEAR_SCREEN
; Clears the current screen (sets everything to 0 = black)
; Modifies : d7/a1 (saved)
; ----------------------------------------------------------
SYS_CLEAR_SCREEN:
        PUSHALL
        move.l  SCR_ADDR_L,a1
        move.w  #SCR_WORDS-1,d7
.LOOP:
        clr.l   (a1)+
        dbf     d7,.LOOP
        POPALL
        rts

; ----------------------------------------------------------
; SYS_MOUSE_OFF
; Hides the mouse via Line-A and disables the IKBD
; ----------------------------------------------------------
SYS_MOUSE_OFF:
        dc.w    $A00A               ; Line-A : hide cursor
        move.b  #$12,IKBD_DATA      ; disable mouse movements
        rts

; ----------------------------------------------------------
; SYS_MOUSE_ON
; Shows the mouse again
; ----------------------------------------------------------
SYS_MOUSE_ON:
        dc.w    $A009               ; Line-A : show cursor
        move.b  #$08,IKBD_DATA      ; re-enable mouse movements
        rts

; ----------------------------------------------------------
; SYS_QUIT
; Returns control to TOS  never returns
; ----------------------------------------------------------
SYS_QUIT:
        move.w  #_Pterm0,-(sp)
        trap    #GEMDOS
