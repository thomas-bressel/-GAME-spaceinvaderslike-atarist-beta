;===========================================================
; DEBUG.S - Development tools
; EXCLUDE FROM FINAL BUILD - do not include in MAIN.S
; for the release
;===========================================================
; To enable : uncomment in MAIN.S:
;   include SRC\DEBUG.S
; To disable : comment the line
;===========================================================
; ----------------------------------------------------------
; DBG_BORDER_COLOR
; Colors the screen border to visualize CPU time
; d0 = color ($0RGB)
; Useful to measure time spent inside a routine
; ----------------------------------------------------------
DBG_BORDER_COLOR:
	move.w  d0,PAL_BASE         ; color 0 = border in low res
	rts

; ----------------------------------------------------------
; DBG_RED / DBG_GREEN / DBG_BLACK
; Shortcuts to mark code sections
; ----------------------------------------------------------
DBG_RED:
	move.w  #$0700,PAL_BASE
	rts

DBG_GREEN:
	move.w  #$0070,PAL_BASE
	rts

DBG_BLACK:
	move.w  #$0000,PAL_BASE
	rts

; ----------------------------------------------------------
; DBG_STATE_SWITCH
; F1-F6 keys switch GAME_STATE for testing
; F1 = STATE_TITLE  F2 = STATE_READY   F3 = STATE_PLAY
; F4 = STATE_DEATH  F5 = STATE_GAMEOVER F6 = STATE_NEXT_LVL
; Modifies : d0
; ----------------------------------------------------------
DBG_STATE_SWITCH:
        cmp.b   #KEY_F1,KEY_CUR
        bne     .F2
        move.w  #0,TITLE_INIT_DONE
        move.w  #STATE_TITLE,GAME_STATE
        rts
.F2:    cmp.b   #KEY_F2,KEY_CUR
        bne     .F3
        move.w  #0,READY_INIT_DONE
        move.w  #0,STATE_TIMER
        move.w  #STATE_READY,GAME_STATE
        rts
.F3:    cmp.b   #KEY_F3,KEY_CUR
        bne     .F4
        move.w  #0,PLAY_INIT_DONE
        move.w  #STATE_PLAY,GAME_STATE
        rts
.F4:    cmp.b   #KEY_F4,KEY_CUR
        bne     .F5
        move.w  #0,DEATH_INIT_DONE
        move.w  #0,STATE_TIMER
        move.w  #STATE_DEATH,GAME_STATE
        rts
.F5:    cmp.b   #KEY_F5,KEY_CUR
        bne     .F6
        move.w  #0,GAMEOVER_INIT_DONE
        move.w  #STATE_GAMEOVER,GAME_STATE
        rts
.F6:    cmp.b   #KEY_F6,KEY_CUR
        bne     .DONE
        move.w  #0,NEXT_LVL_INIT_DONE
        move.w  #0,STATE_TIMER
        move.w  #STATE_NEXT_LVL,GAME_STATE
.DONE:  rts
