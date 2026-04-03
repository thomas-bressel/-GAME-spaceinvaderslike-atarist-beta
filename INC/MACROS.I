;===========================================================
; MACROS.I - Assembler macros
; Contains only MACRO/ENDM directives — no bytes generated
;===========================================================
; -------------------------------------------------------
; PUSHALL / POPALL
; Saves and restores all registers
; Usage : PUSHALL at the beginning of a routine, POPALL before rts
; -------------------------------------------------------
PUSHALL         MACRO
                movem.l d0-d7/a0-a6,-(sp)
                ENDM
POPALL          MACRO
                movem.l (sp)+,d0-d7/a0-a6
                ENDM

; -------------------------------------------------------
; WAITVBL
; Waits for the next VBL via TOS counter $466
; Modifies : d0
; -------------------------------------------------------
WAITVBL         MACRO
                move.l  _frclock,d0
.loop:
                cmp.l   _frclock,d0
                beq     .loop
                ENDM
