;===========================================================
; VECTORS.I - 68000 exception vector addresses
; Contains only EQU directives - no bytes generated
; Usage: move.l #my_handler,VEC_VBLANK
;===========================================================

; -------------------------------------------------------
; CPU exception vectors
; -------------------------------------------------------
VEC_RESET_SP    equ     $000000     ; initial stack pointer
VEC_RESET_PC    equ     $000004     ; initial program counter
VEC_BUS_ERR     equ     $000008     ; bus error
VEC_ADDR_ERR    equ     $00000C     ; address error
VEC_ILLEGAL     equ     $000010     ; illegal instruction
VEC_DIV_ZERO    equ     $000014     ; divide by zero
VEC_CHK         equ     $000018     ; CHK instruction
VEC_TRAPV       equ     $00001C     ; TRAPV instruction
VEC_PRIV        equ     $000020     ; privilege violation
VEC_TRACE       equ     $000024     ; trace
VEC_LINE_A      equ     $000028     ; Line-A emulator
VEC_LINE_F      equ     $00002C     ; Line-F emulator

; -------------------------------------------------------
; Interrupt vectors
; -------------------------------------------------------
VEC_SPURIOUS    equ     $000060     ; spurious interrupt
VEC_AUTO_L1     equ     $000064     ; autovector level 1
VEC_AUTO_L2     equ     $000068     ; autovector level 2 (HBlank via MFP timer B)
VEC_HBLANK      equ     $000068     ; horizontal blank (alias)
VEC_AUTO_L3     equ     $00006C     ; autovector level 3
VEC_AUTO_L4     equ     $000070     ; autovector level 4 (VBlank)
VEC_VBLANK      equ     $000070     ; vertical blank (alias)
VEC_AUTO_L5     equ     $000074     ; autovector level 5
VEC_AUTO_L6     equ     $000078     ; autovector level 6
VEC_AUTO_L7     equ     $00007C     ; autovector level 7 (NMI)

; -------------------------------------------------------
; TRAP vectors
; -------------------------------------------------------
VEC_TRAP0       equ     $000080     ; TRAP #0
VEC_TRAP1       equ     $000084     ; TRAP #1  (GEMDOS)
VEC_TRAP2       equ     $000088     ; TRAP #2
VEC_TRAP3       equ     $00008C     ; TRAP #3
VEC_TRAP4       equ     $000090     ; TRAP #4
VEC_TRAP5       equ     $000094     ; TRAP #5
VEC_TRAP6       equ     $000098     ; TRAP #6
VEC_TRAP7       equ     $00009C     ; TRAP #7
VEC_TRAP8       equ     $0000A0     ; TRAP #8
VEC_TRAP9       equ     $0000A4     ; TRAP #9
VEC_TRAP10      equ     $0000A8     ; TRAP #10
VEC_TRAP11      equ     $0000AC     ; TRAP #11
VEC_TRAP12      equ     $0000B0     ; TRAP #12
VEC_TRAP13      equ     $0000B4     ; TRAP #13 (BIOS)
VEC_TRAP14      equ     $0000B8     ; TRAP #14 (XBIOS)
VEC_TRAP15      equ     $0000BC     ; TRAP #15

; -------------------------------------------------------
; MFP interrupt vectors (base $100, 16 vectors)
; -------------------------------------------------------
VEC_MFP_BASE    equ     $000100     ; MFP vector base
VEC_MFP_IO_BUSY equ     $000100     ; centronics busy
VEC_MFP_DCD     equ     $000104     ; RS-232 DCD
VEC_MFP_CTS     equ     $000108     ; RS-232 CTS
VEC_MFP_GPU     equ     $00010C     ; blitter done (GPU)
VEC_MFP_TIMER_D equ     $000110     ; timer D (RS-232 baud)
VEC_MFP_TIMER_C equ     $000114     ; timer C (200Hz system)
VEC_MFP_IKBD    equ     $000118     ; IKBD / MIDI receive
VEC_MFP_FDC     equ     $00011C     ; FDC / ACSI
VEC_MFP_TIMER_B equ     $000120     ; timer B (HBlank)
VEC_MFP_TX_ERR  equ     $000124     ; RS-232 transmit error
VEC_MFP_TX_DONE equ     $000128     ; RS-232 transmit done
VEC_MFP_RX_ERR  equ     $00012C     ; RS-232 receive error
VEC_MFP_RX_DONE equ     $000130     ; RS-232 receive done
VEC_MFP_TIMER_A equ     $000134     ; timer A (HBlank alt / DMA end)
VEC_MFP_RI      equ     $000138     ; RS-232 ring indicator
VEC_MFP_MONO    equ     $00013C     ; monochrome detect
