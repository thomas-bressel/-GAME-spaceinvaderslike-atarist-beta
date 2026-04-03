;===========================================================
; HW_ST.I - Atari ST/STE hardware register addresses
; Contains only EQU directives no bytes generated
;===========================================================

; -------------------------------------------------------
; Hardware Video - screen address
; -------------------------------------------------------
SCREEN_ADR_H    equ     $FFFF8201   ; screen address high byte
SCREEN_ADR_M    equ     $FFFF8203   ; screen address middle byte
SCREEN_ADR_L    equ     $FFFF820D   ; screen address low byte (STE only)

; -------------------------------------------------------
; Hardware Video - sync and resolution
; -------------------------------------------------------
VIDEO_SYNC      equ     $FFFF820A   ; sync mode (bit0: 0=60Hz 1=50Hz)
SCREEN_RES      equ     $FFFF8260   ; resolution register

; -------------------------------------------------------
; Hardware Video - palette
; -------------------------------------------------------
PAL_BASE        equ     $FFFF8240   ; palette registers (16 words, $0RGB)

; -------------------------------------------------------
; Hardware Video - STE scroll/width
; -------------------------------------------------------
VIDEO_LINEWIDTH equ     $FFFF820F   ; extra words per scanline (STE)
VIDEO_HSCROLL   equ     $FFFF8265   ; horizontal pixel scroll 0..15 (STE)

; -------------------------------------------------------
; TOS system variables (RAM)
; -------------------------------------------------------
CONTERM         equ     $484        ; console config byte (bit0=keyclick, bit1=bell, bit2=cursor)

; -------------------------------------------------------
; Hardware IKBD (keyboard/joystick/mouse) - ACIA 6850
; -------------------------------------------------------
IKBD_CTRL       equ     $FFFFFC00   ; IKBD ACIA control register
IKBD_DATA       equ     $FFFFFC02   ; IKBD ACIA data register

; IKBD commands (write to IKBD_DATA)
IKBD_MOUSE_OFF  equ     $12         ; disable mouse reporting
IKBD_MOUSE_ON   equ     $08         ; enable mouse reporting
IKBD_JOY_OFF    equ     $1A         ; disable joystick reporting
IKBD_JOY_ON     equ     $14         ; enable joystick event reporting
IKBD_RESET      equ     $80         ; reset IKBD (follow with $01)

; -------------------------------------------------------
; Hardware MFP 68901 (timers, interrupts, serial)
; -------------------------------------------------------
MFP_BASE        equ     $FFFFFA00
MFP_GPIP        equ     $FFFFFA01   ; general purpose I/O
MFP_AER         equ     $FFFFFA03   ; active edge register
MFP_DDR         equ     $FFFFFA05   ; data direction register
MFP_IERA        equ     $FFFFFA07   ; interrupt enable A
MFP_IERB        equ     $FFFFFA09   ; interrupt enable B
MFP_IPRA        equ     $FFFFFA0B   ; interrupt pending A
MFP_IPRB        equ     $FFFFFA0D   ; interrupt pending B
MFP_ISRA        equ     $FFFFFA0F   ; interrupt in-service A
MFP_ISRB        equ     $FFFFFA11   ; interrupt in-service B
MFP_IMRA        equ     $FFFFFA13   ; interrupt mask A
MFP_IMRB        equ     $FFFFFA15   ; interrupt mask B
MFP_VR          equ     $FFFFFA17   ; vector register (base for MFP vectors)
MFP_TACR        equ     $FFFFFA19   ; timer A control
MFP_TBCR        equ     $FFFFFA1B   ; timer B control
MFP_TCDCR       equ     $FFFFFA1D   ; timer C/D control
MFP_TADR        equ     $FFFFFA1F   ; timer A data
MFP_TBDR        equ     $FFFFFA21   ; timer B data
MFP_TCDR        equ     $FFFFFA23   ; timer C data
MFP_TDDR        equ     $FFFFFA25   ; timer D data
MFP_SCR         equ     $FFFFFA27   ; sync character register
MFP_UCR         equ     $FFFFFA29   ; USART control register
MFP_RSR         equ     $FFFFFA2B   ; receiver status register
MFP_TSR         equ     $FFFFFA2D   ; transmitter status register
MFP_UDR         equ     $FFFFFA2F   ; USART data register

; MFP timer control values (prescaler)
MFP_STOP        equ     0           ; timer stopped
MFP_DIV4        equ     1           ; divide by 4
MFP_DIV10       equ     2           ; divide by 10
MFP_DIV16       equ     3           ; divide by 16
MFP_DIV50       equ     4           ; divide by 50
MFP_DIV64       equ     5           ; divide by 64
MFP_DIV100      equ     6           ; divide by 100
MFP_DIV200      equ     7           ; divide by 200
MFP_EVENT       equ     8           ; event count mode (timer A/B only)

; -------------------------------------------------------
; Hardware Sound YM2149
; -------------------------------------------------------
YM_SELECT       equ     $FFFF8800   ; register select (write)
YM_WRITE        equ     $FFFF8802   ; register write
YM_READ         equ     $FFFF8800   ; register read

; YM2149 register numbers (write to YM_SELECT then YM_WRITE)
YM_FREQ_A_L     equ     0           ; channel A frequency low  (8 bits)
YM_FREQ_A_H     equ     1           ; channel A frequency high (4 bits)
YM_FREQ_B_L     equ     2           ; channel B frequency low
YM_FREQ_B_H     equ     3           ; channel B frequency high
YM_FREQ_C_L     equ     4           ; channel C frequency low
YM_FREQ_C_H     equ     5           ; channel C frequency high
YM_NOISE_FREQ   equ     6           ; noise frequency (5 bits)
YM_MIXER        equ     7           ; mixer control (see bits below)
YM_VOL_A        equ     8           ; channel A volume / envelope flag
YM_VOL_B        equ     9           ; channel B volume / envelope flag
YM_VOL_C        equ     10          ; channel C volume / envelope flag
YM_ENV_FREQ_L   equ     11          ; envelope frequency low
YM_ENV_FREQ_H   equ     12          ; envelope frequency high
YM_ENV_SHAPE    equ     13          ; envelope shape (CONT/ATT/ALT/HOLD)
YM_PORT_A       equ     14          ; I/O port A (floppy drive select)
YM_PORT_B       equ     15          ; I/O port B (printer strobe etc.)

; YM_MIXER bits (0=enabled, 1=disabled)
YM_MIX_TONE_A   equ     $01         ; tone A
YM_MIX_TONE_B   equ     $02         ; tone B
YM_MIX_TONE_C   equ     $04         ; tone C
YM_MIX_NOISE_A  equ     $08         ; noise A
YM_MIX_NOISE_B  equ     $10         ; noise B
YM_MIX_NOISE_C  equ     $20         ; noise C
YM_MIX_PORTA_OUT equ    $40         ; port A = output
YM_MIX_PORTB_OUT equ    $80         ; port B = output

; YM_VOL bits
YM_VOL_ENV      equ     $10         ; bit4: use envelope instead of volume

; -------------------------------------------------------
; Hardware Blitter (STE only) - $FFFF8A00
; -------------------------------------------------------
BLT_SRC_X_INC   equ     $FFFF8A00   ; source X increment      (word, signed)
BLT_SRC_Y_INC   equ     $FFFF8A02   ; source Y increment      (word, signed)
BLT_SRC_ADDR    equ     $FFFF8A04   ; source address          (long)
BLT_HALFTONE    equ     $FFFF8A08   ; halftone pattern RAM    (16 words)
BLT_ENDMASK1    equ     $FFFF8A28   ; first word endmask
BLT_ENDMASK2    equ     $FFFF8A2A   ; middle words endmask
BLT_ENDMASK3    equ     $FFFF8A2C   ; last word endmask
BLT_DST_X_INC   equ     $FFFF8A2E   ; destination X increment (word, signed)
BLT_DST_Y_INC   equ     $FFFF8A30   ; destination Y increment (word, signed)
BLT_DST_ADDR    equ     $FFFF8A32   ; destination address     (long)
BLT_COUNT_X     equ     $FFFF8A36   ; X word count            (word)
BLT_COUNT_Y     equ     $FFFF8A38   ; Y line count            (word)
BLT_HOP         equ     $FFFF8A3A   ; halftone operation      (byte)
BLT_LOP         equ     $FFFF8A3B   ; logical operation       (byte)
BLT_CTRL        equ     $FFFF8A3C   ; control/status          (byte)
BLT_SKEW        equ     $FFFF8A3D   ; skew                    (byte)

; BLT_HOP values
BLT_HOP_ALL1    equ     0           ; all ones (ignore source)
BLT_HOP_HT      equ     1           ; halftone pattern only
BLT_HOP_SRC     equ     2           ; source only (most common)
BLT_HOP_SRC_HT  equ     3           ; source AND halftone

; BLT_LOP values (truth table: S=source, D=destination)
BLT_LOP_ZERO    equ     $00         ; 0
BLT_LOP_S_AND_D equ     $01         ; S AND D
BLT_LOP_S_NAND  equ     $02         ; S AND (NOT D)
BLT_LOP_SRC     equ     $03         ; S  (copy source)
BLT_LOP_NS_AND  equ     $04         ; (NOT S) AND D
BLT_LOP_DST     equ     $05         ; D  (no change)
BLT_LOP_XOR     equ     $06         ; S XOR D
BLT_LOP_OR      equ     $07         ; S OR D
BLT_LOP_NOR     equ     $08         ; NOT (S OR D)
BLT_LOP_XNOR    equ     $09         ; NOT (S XOR D)
BLT_LOP_NOT_D   equ     $0A         ; NOT D
BLT_LOP_S_OR_ND equ     $0B         ; S OR (NOT D)
BLT_LOP_NOT_S   equ     $0C         ; NOT S
BLT_LOP_NS_OR_D equ     $0D         ; (NOT S) OR D
BLT_LOP_NAND    equ     $0E         ; NOT (S AND D)
BLT_LOP_ONE     equ     $0F         ; all ones

; BLT_CTRL bits
BLT_BUSY        equ     $80         ; 1=blitter running — write 1 to start, poll to wait
BLT_HOG         equ     $40         ; 1=hog mode (blitter takes all bus cycles)
BLT_SMUDGE      equ     $20         ; 1=smudge mode (preload halftone on each line)

; BLT_SKEW bits
BLT_SKEW_NFSR   equ     $08         ; no final source read
BLT_SKEW_FXSR   equ     $04         ; force extra source read
BLT_SKEW_MASK   equ     $0F         ; skew value (bits 0-3)

; -------------------------------------------------------
; Hardware DMA Sound (STE only) - $FFFF8900
; -------------------------------------------------------
DMA_CTRL        equ     $FFFF8901   ; DMA sound control (byte)
DMA_START_H     equ     $FFFF8903   ; sample start address high byte
DMA_START_M     equ     $FFFF8905   ; sample start address mid byte
DMA_START_L     equ     $FFFF8907   ; sample start address low byte
DMA_COUNT_H     equ     $FFFF8909   ; current address high byte (read only)
DMA_COUNT_M     equ     $FFFF890B   ; current address mid byte  (read only)
DMA_COUNT_L     equ     $FFFF890D   ; current address low byte  (read only)
DMA_END_H       equ     $FFFF890F   ; sample end address high byte
DMA_END_M       equ     $FFFF8911   ; sample end address mid byte
DMA_END_L       equ     $FFFF8913   ; sample end address low byte
DMA_MODE        equ     $FFFF8921   ; sound mode register (byte)
DMA_MICROWIRE   equ     $FFFF8922   ; microwire data register  (word)
DMA_MICROMASK   equ     $FFFF8924   ; microwire mask register  (word)

; DMA_CTRL bits
DMA_PLAY        equ     $01         ; 1=play
DMA_LOOP        equ     $02         ; 1=loop sample
DMA_TIMER_A     equ     $04         ; 1=trigger MFP timer A at end of sample

; DMA_MODE bits
DMA_MONO        equ     $80         ; 1=mono, 0=stereo
DMA_6258HZ      equ     $00         ; sample rate 6258 Hz
DMA_12517HZ     equ     $01         ; sample rate 12517 Hz
DMA_25033HZ     equ     $02         ; sample rate 25033 Hz
DMA_50066HZ     equ     $03         ; sample rate 50066 Hz

; Microwire - LMC1992 mixer chip
MW_LMC_ADDR     equ     $0400       ; LMC1992 address prefix (bits 10..9 = 10)
MW_MASTER_VOL   equ     $0000       ; master volume  (0..40, step 2dB, 40=max)
MW_RIGHT_VOL    equ     $0001       ; right output   (0..20, step 2dB)
MW_LEFT_VOL     equ     $0002       ; left output    (0..20, step 2dB)
MW_TREBLE       equ     $0003       ; treble         (0..12, 6=flat)
MW_BASS         equ     $0004       ; bass           (0..12, 6=flat)
MW_MIXER_SRC    equ     $0005       ; input source   (0=YM only, 1=DMA only, 2=YM+DMA, 3=off)
