;===========================================================
; AES.I - GEM Application Environment Services
; Interface trap #2 pour Atari ST
;
; Usage :
;   - Remplir les arrays AES (CONTRL, INTIN, ADDRIN...)
;   - Pointer AESPB vers ces arrays
;   - Charger l'adresse de AESPB dans d1
;   - Charger #AES_MAGIC dans d0
;   - trap #2
;===========================================================

; -------------------------------------------------------
; Numero de trap et code magique AES
; -------------------------------------------------------
AES             equ     2               ; trap #AES
AES_MAGIC       equ     $C8             ; valeur dans d0 avant trap #AES

; -------------------------------------------------------
; Opcodes AES
; -------------------------------------------------------
_appl_init      equ     10              ; initialise l'application AES
_appl_exit      equ     19              ; quitte l'AES
_form_alert     equ     52              ; boite d'alerte

; -------------------------------------------------------
; Offsets dans le tableau CONTRL (en bytes, words)
; -------------------------------------------------------
; CONTRL est un tableau de 5 words :
;   CONTRL+0 : opcode de la fonction
;   CONTRL+2 : nb de words dans INTIN utilises
;   CONTRL+4 : nb de words dans INTOUT retournes
;   CONTRL+6 : nb de longs dans ADDRIN utilises
;   CONTRL+8 : nb de longs dans ADDROUT retournes
CONTRL_OP       equ     0
CONTRL_NIN      equ     2
CONTRL_NOUT     equ     4
CONTRL_NAIN     equ     6
CONTRL_NAOUT    equ     8

; -------------------------------------------------------
; AESPB - bloc de 6 pointeurs longs (24 bytes)
; a declarer en BSS et initialiser avant le premier appel
;
;   AESPB+0  : ptr -> CONTRL  (5 words)
;   AESPB+4  : ptr -> GLOBAL  (15 words, rempli par appl_init)
;   AESPB+8  : ptr -> INTIN   (16 words max)
;   AESPB+12 : ptr -> INTOUT  (10 words max)
;   AESPB+16 : ptr -> ADDRIN  (8 longs max)
;   AESPB+20 : ptr -> ADDROUT (2 longs max)
; -------------------------------------------------------

; -------------------------------------------------------
; Tailles des arrays (en elements)
; -------------------------------------------------------
AES_CONTRL_SZ   equ     5               ; words
AES_GLOBAL_SZ   equ     15              ; words
AES_INTIN_SZ    equ     16              ; words
AES_INTOUT_SZ   equ     10              ; words
AES_ADDRIN_SZ   equ     8               ; longs
AES_ADDROUT_SZ  equ     2               ; longs

; -------------------------------------------------------
; Icones pour form_alert (1er champ de la chaine)
; [n][message][bouton]
; -------------------------------------------------------
ALERT_NONE      equ     0               ; pas d'icone
ALERT_EXCL      equ     1               ; point d'exclamation
ALERT_QUEST     equ     2               ; point d'interrogation
ALERT_STOP      equ     3               ; stop
ALERT_INFO      equ     4               ; information
