;===========================================================
; SND.S - Music player and sound effects
; Depends : INC/HW_ST.I
; Called from VBL must be short and side-effect free
;===========================================================
; SNDH convention:
;   MUSIC+0  = init
;   MUSIC+4  = deinit
;   MUSIC+8  = frame (called each VBL)
;===========================================================
; ----------------------------------------------------------
; SND_INIT
; Initializes the player called once at startup
; ----------------------------------------------------------
SND_INIT:
        PUSHALL
        bsr     MUSIC+0
        POPALL
        rts

; ----------------------------------------------------------
; SND_STOP
; Stops the player called at exit
; ----------------------------------------------------------
SND_STOP:
        PUSHALL
        bsr     MUSIC+4
        POPALL
        rts

; ----------------------------------------------------------
; SND_FRAME
; Called each VBL plays one frame of music
; ----------------------------------------------------------
SND_FRAME:
        bsr     MUSIC+8
        rts

; ----------------------------------------------------------
; Data the embedded SNDH file
; ----------------------------------------------------------
MUSIC:
        even
        ; incbin  DATA\SND\MUSIC.SND    ; uncomment to include
        even
