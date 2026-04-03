;===========================================================
; TOS.I - OS call numbers and system variables
; Contains only EQU directives - no bytes generated
;===========================================================

; -------------------------------------------------------
; TRAP numbers
; -------------------------------------------------------
GEMDOS          equ     1
BIOS            equ     13
XBIOS           equ     14

; -------------------------------------------------------
; GEMDOS functions
; -------------------------------------------------------
_Pterm0         equ     0       ; terminate process (exit code 0)
_Cconin         equ     1       ; read char from console (wait)
_Cconout        equ     2       ; write char to console
_Cauxin         equ     3       ; read char from aux port
_Cauxout        equ     4       ; write char to aux port
_Cprnout        equ     5       ; write char to printer
_Crawio         equ     6       ; raw console I/O
_Crawcin        equ     7       ; raw console input (no echo)
_Cnecin         equ     8       ; read char, no echo
_Cconws         equ     9       ; write string to console
_Cconrs         equ     $0A     ; read string from console
_Cconis         equ     $0B     ; check if char available
_Dsetdrv        equ     $0E     ; set default drive
_Cconout2       equ     $10     ; check output status
_Dgetdrv        equ     $19     ; get default drive
_Fsetdta        equ     $1A     ; set disk transfer address
_Super          equ     $20     ; enter/exit supervisor mode
_Tgetdate       equ     $2A     ; get system date
_Tsetdate       equ     $2B     ; set system date
_Tgettime       equ     $2C     ; get system time
_Tsettime       equ     $2D     ; set system time
_Fgetdta        equ     $2F     ; get disk transfer address
_Sversion       equ     $30     ; get OS version
_Ptermres       equ     $31     ; terminate and stay resident
_Dfree          equ     $36     ; get disk free space
_Dcreate        equ     $39     ; create directory
_Ddelete        equ     $3A     ; delete directory
_Dsetpath       equ     $3B     ; set current directory
_Fcreate        equ     $3C     ; create/truncate file
_Fopen          equ     $3D     ; open file
_Fclose         equ     $3E     ; close file
_Fread          equ     $3F     ; read from file
_Fwrite         equ     $40     ; write to file
_Fdelete        equ     $41     ; delete file
_Fseek          equ     $42     ; seek in file
_Fattrib        equ     $43     ; get/set file attributes
_Fdup           equ     $45     ; duplicate file handle
_Fforce         equ     $46     ; force file handle
_Dgetpath       equ     $47     ; get current directory
_Malloc         equ     $48     ; allocate memory
_Mfree          equ     $49     ; free memory
_Mshrink        equ     $4A     ; shrink allocated memory block
_Pexec          equ     $4B     ; load and execute program
_Pterm          equ     $4C     ; terminate process with exit code
_Fsfirst        equ     $4E     ; find first matching file
_Fsnext         equ     $4F     ; find next matching file
_Frename        equ     $56     ; rename file
_Fdatime        equ     $57     ; get/set file date and time

; -------------------------------------------------------
; BIOS functions
; -------------------------------------------------------
_Getmpb         equ     0       ; get memory parameter block
_Bconstat       equ     1       ; input status for device
_Bconin         equ     2       ; read char from device
_Bconout        equ     3       ; write char to device
_Rwabs          equ     4       ; read/write absolute sectors
_Setexc         equ     5       ; set exception vector
_Tickcal        equ     6       ; get timer calibration
_Getbpb         equ     7       ; get BIOS parameter block
_Bcostat        equ     8       ; output status for device
_Mediach        equ     9       ; media change detect
_Drvmap         equ     10      ; get drive map
_Kbshift        equ     11      ; get/set keyboard shift state

; BIOS device numbers
BIOS_PRT        equ     0       ; printer
BIOS_AUX        equ     1       ; serial port
BIOS_CON        equ     2       ; console (screen + keyboard)
BIOS_MIDI       equ     3       ; MIDI
BIOS_IKBD       equ     4       ; IKBD (keyboard controller)
BIOS_RAW        equ     5       ; raw console (no cursor)

; -------------------------------------------------------
; XBIOS functions
; -------------------------------------------------------
_Initmous       equ     0       ; initialize mouse
_Ssbrk          equ     1       ; set system break
_Physbase       equ     2       ; get physical screen base
_Logbase        equ     3       ; get logical screen base
_Getrez         equ     4       ; get current resolution
_Setscreen      equ     5       ; set screen base and resolution
_Setpalette     equ     6       ; set full palette
_Setcolor       equ     7       ; set one palette entry
_Floprd         equ     8       ; floppy read
_Flopwr         equ     9       ; floppy write
_Bioskeys       equ     11      ; get BIOS key codes
_Midiws         equ     12      ; write to MIDI
_Mfpint         equ     13      ; set MFP interrupt
_Iorec          equ     14      ; get I/O record pointer
_Rsconf         equ     15      ; configure RS-232
_Keytbl         equ     16      ; get/set keyboard tables
_Random         equ     17      ; get pseudo-random number
_Protobt        equ     18      ; create boot sector
_Flopver        equ     19      ; floppy verify
_Scrdmp         equ     20      ; screen dump
_Cursconf       equ     21      ; configure cursor
_Settime        equ     22      ; set system time (XBIOS)
_Gettime        equ     23      ; get system time (XBIOS)
_Bioskeys2      equ     24      ; set BIOS key repeat
_Jdisint        equ     26      ; disable interrupt
_Jenabint       equ     27      ; enable interrupt
_Giaccess       equ     28      ; access GI chip (YM2149 port)
_Offgibit       equ     29      ; clear GI bit
_Ongibit        equ     30      ; set GI bit
_Xbtimer        equ     31      ; set timer
_Dosound        equ     32      ; play sound
_Setprt         equ     33      ; set printer config
_Kbdvbase       equ     34      ; get keyboard vectors
_Kbrate         equ     35      ; set key repeat rate
_Prtblk         equ     36      ; print block
_Vsync          equ     37      ; wait for VBL
_Supexec        equ     38      ; execute in supervisor mode
_Puntaes        equ     39      ; remove AES from memory

; -------------------------------------------------------
; XBIOS resolution values
; -------------------------------------------------------
LOW_RES         equ     0       ; 320x200 16 colors
MID_RES         equ     1       ; 640x200 4 colors
HI_RES          equ     2       ; 640x400 monochrome

; -------------------------------------------------------
; Basepage offsets
; -------------------------------------------------------
bp_tlen         equ     $0C     ; TEXT segment size
bp_dlen         equ     $14     ; DATA segment size
bp_blen         equ     $1C     ; BSS segment size

; -------------------------------------------------------
; TOS system variables
; -------------------------------------------------------
_frclock        equ     $466    ; VBL counter (long)
_vbclock        equ     $462    ; alternate VBL counter
_vbl_list       equ     $4CE    ; start of VBL queue
_vbl_slot1      equ     $4D2    ; slot 1 of VBL queue
_vbl_count      equ     $462    ; VBL counter (word)
_vbl_queue      equ     $4CE    ; VBL handler list (8 longword slots)
_membot         equ     $432    ; bottom of free RAM
_memtop         equ     $436    ; top of free RAM
_phystop        equ     $43E    ; top of physical RAM
_LOGBASE        equ     $44E    ; logical screen address
_PHYSBASE       equ     $44C    ; physical screen address
_coloron        equ     $45A    ; color flag
_linea_ptr      equ     $28E    ; Line-A variable pointer
_sysbase        equ     $4F2    ; TOS base address
_timer_ms       equ     $4BA    ; 200Hz system timer (long)
