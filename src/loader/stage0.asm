; "Elite" C64 disassembly / "Elite DX", cc0 2018, see LICENSE.txt
; "Elite" is copyright / trademark David Braben & Ian Bell, All Rights Reserved
; <github.com/Kroc/EliteDX>
;===============================================================================

.include        "c64.asm"

; this file is the code for "firebird.prg", the first stage in loading,
; it's what gets loaded by the normal C64 KERNAL. the program is designed to
; hijack BASIC via the BASIC vectors located at $0300+, this means that the
; program starts automatically without a BASIC bootstrap or `RUN`

; interesting tidbit: the `,1` in `LOAD"*",8,1` tells the C64 to use the
; load address given by the program, in this case $02A7. if the user uses
; `LOAD"*",8` instead, the program will be placed in the BASIC area -- $0801
; onwards -- which obviously breaks this program's attempt at hijacking the
; BASIC vectors. a BASIC bootstrap picks up this scenario and copies the
; program to the intended load address before executing it

; the BASIC bootstrap needs to be stored at the beginning of the program,
; canonically $02A7, but needs to be address as loaded in $0801. the linker
; configuration handles this ("build/firebird.cfg")

.segment        "BOOTSTRAP"

        ; the C64 BASIC binary format is described here:
        ; <https://www.c64-wiki.com/wiki/BASIC_token> 

        .word   @end            ; pointer to next line
        .word   1               ; BASIC line-number
        
        .byte   $9e             ; "SYS"

        ; convert the address of the machine language routine, that comes after
        ; this BASIC program, to PETSCII decimals. this trick taken from CC65's
        ; "exehdr.s" file by Ullrich von Bassewitz
        .byte   <(((@copy /  1000) .mod 10) + '0')
        .byte   <(((@copy /   100) .mod 10) + '0')
        .byte   <(((@copy /    10) .mod 10) + '0')
        .byte   <(((@copy /     1) .mod 10) + '0')

        .byte   0               ; end of line
        
        ; end of program
@end:   .word   $0000
        
        ;-----------------------------------------------------------------------

.import __MAIN_START__          ; get the load address of the program
.import __BOOTSTRAP_RUN__       ; and, as seen by BASIC, i.e. $0801

; get the size of the segments to be able to calculate the size
; of the whole program (see linker script "build/firebird.cfg")
.import __BOOTSTRAP_SIZE__, __CODE_SIZE__, __VECTORS_SIZE__

@copy:                                                                  ;$080D
        ; the length of FIREBIRD.PRG (sans PRG header)
        size = __BOOTSTRAP_SIZE__ + __CODE_SIZE__ + __VECTORS_SIZE__

        ; note that these are 16-bit data types and the `ldx` is limited to
        ; 8-bit values so we have to coerce the result to 8-bits using the
        ; lower-byte `<`. this means that the total program size CANNOT
        ; exceed 255 bytes
.assert (size < 255), error, "Program exceeds 255 bytes!"
        ldx # <size

:       lda __BOOTSTRAP_RUN__, x        ; copy from $0801..
        sta __MAIN_START__, x           ; to $02A7..
        dex 
        bpl :-

        jmp start

;===============================================================================

.code

filename:                                                               ;$02c1
        .byte   "gm*"           ; $47, $4D, $2A (PETSCII)

start:                                                                  ;$02c1
        ; call Kernel SETMSG, "Set system error display switch at
        ; memory address $009D". A = the switch value.
        ; i.e. disable error messages?
        lda # $00
        jsr KERNAL_SETMSG

        ; set file parameters:
        lda # $02               ; logical file number
        ldx # $08               ; device number == drive 8
        ldy # $ff               ; "secondary address"
                                ; (i.e. use the PRG load address)
        jsr KERNAL_SETLFS

        ; set file name
        lda # $03               ; length of file name
        ldx #< filename         ; pointer to name address (lo)
        ldy #> filename         ; pointer to name address (hi)
        jsr KERNAL_SETNAM

        ; load file:
        ; note that the "secondary address" has been set as non-zero,
        ; telling the drive to use the load address present in the PRG file
        lda # $00               ; = LOAD
        jsr KERANL_LOAD
    
        ; change the address of STOP key routine from $F6ED,
        ; to $FFED: the SCREEN routine which returns row/col count
        ; i.e. does nothing of use -- this effectively disables the STOP key
        lda # $ff
        sta $0329

        .repeat 24
        nop
        .endrepeat

        jmp $0334

;===============================================================================

.segment        "VECTORS"

; these are various vectors for BASIC -- the loader hijacks these to cause
; the loader to start immediately withtout the need for a BASIC bootstrap

        ;$0300/1    execution address of warm reset, displaying optional BASIC
        ;           error message and entering BASIC idle loop. default: $E38B
.addr   start
        ;$0302/3    execution address of BASIC idle loop. default: $A483
.addr   start
        ;$0304/5    execution address of BASIC line tokenizater routine.
        ;           default: $A57C
.addr   start
        ;$0306/7    execution address of BASIC token decoder routine.
        ;           default: $A71A
.addr   start
        ;$0308/9    execution address of BASIC instruction executor routine.
        ;           default: $A7E4
.addr   start
        ;$030A/B    execution address of routine reading next item of BASIC
        ;           expression. default: $AE86
.addr   start
