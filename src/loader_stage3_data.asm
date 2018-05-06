; "Elite" C64 disassembly / "Elite DX", cc0 2018, see LICENSE.txt
; "Elite" is copyright / trademark David Braben & Ian Bell, All Rights Reserved
; <github.com/Kroc/EliteDX>
;===============================================================================

.zeropage

ZP_COPY_TO      := $18
ZP_COPY_FROM    := $1a

;-------------------------------------------------------------------------------

.data                                                                   ;$75e4
        ; relocate part of the binary payload in "gma4.prg"
        ; (copy $4000-$5600 to $0700-$1D00)

        ldx # $16               ; size of block-copy -- 22 x 256 = 5'632 bytes
        lda #< $0700
        sta ZP_COPY_TO+0
        lda #> $0700
        sta ZP_COPY_TO+1
        lda #< $4000
        sta ZP_COPY_FROM+0
        lda #> $4000
        jsr copy_bytes

        ;-----------------------------------------------------------------------

        ; disable interrupts:
        ; (we'll be configuring screen & sprites)
        sei
    
        ; change the C64's memory layout:
        ; bits 0-2 of the processor port ($01) control the memory banks,
        ; a value of of %xxxxx100 turns off the BASIC & KERNAL ROMS and
        ; places the character ROM/RAM into $D000-$DFFF 
        lda $01                 ; get the current processor port value
        and # %11111000         ; reset bottom 3 bits and keep top 5 the same 
        ora # %00000100         ; set BASIC & KERNAL to RAM, Character ROM on
        sta $01

        ; relocate part of the binary payload in "gma4.prg" --
        ; copy $5600-$7F00 to $D000-$F900 -- note that includes this code!
        ; since Character ROM has been enabled, this means that $5600-$6600
        ; represents a font!

        ldx # $29               ; size of block-copy -- 41 x 256 = 10'496 bytes
        lda #< $d000
        sta ZP_COPY_TO+0
        lda #> $d000
        sta ZP_COPY_TO+1
        lda # $00
        sta ZP_COPY_FROM+0
        lda # $56
        jsr copy_bytes

        ; switch the character ROM/RAM off:
        lda $01             ; get the current processor port value
        and # %11111000     ; reset bottom 3 bits and keep the top 7 the same 
        ora # %00000101     ; switch I/O on, BASIC & KERNAL ROM off
        sta $01

        lda $dd02           ; read Port A ($DD00) data-direction register
        ora # $03           ; set bits 0/1 to read/write, all others read-only
        sta $dd02

        ; set the VIC-II to get screen / sprite data from the zone $0000-$3FFF

        lda $dd00           ; read the serial bus / VIC-II bank state
        and # %11111100     ; keep existing value except bits 0-1 (VIC bank)
        ora # $02           ; set bits 0-1 to %11: bank 0, $0000-$3FFF
        sta $dd00

        ; enable interrupts and non-maskable interrupts generated by the A/B
        ; system timers. the bottom two bits control CIA timers A & B, and
        ; writes to $DC0D control normal interrupts, and writes to $DD0D
        ; control non-maskable interrupts
        lda # %00000011
        sta $dc0d           ; interrupt control / status register
        sta $dd0d           ; non-maskable interrupt control / status register

        ; non-standard value??
        lda # %10000001
        sta $d018

        ; border colour black
        lda # $00
        sta $d020
        ; background colour black
        lda # $00
        sta $d021

        ; set up the bitmap screen:
        ; - bit 0-2: raster scroll (default value)
        ; - bit   3: 25 rows
        ; - bit   4: screen on
        ; - bit   5: bitmap mode on
        ; - bit 6-7: extended mode off / raster interrupt off
        lda # %00111011
        sta $d011

        ; further screen setup:
        ; - bit 0-2: horizontal scroll (0)
        ; - bit   3: 38 columns (borders inset)
        ; - bit   4: multi-color mode off
        lda # %11000000
        sta $d016

        ; disable all sprites
        lda # $00
        sta $d015

        ; set sprite 2 colour to brown
        lda # $09
        sta $d029
        ; set sprite 3 colour to medium-grey
        lda # $0c
        sta $d02a
        ; set sprite 4 colour to blue
        lda # $06
        sta $d02b
        ; set sprite 5 colour to white
        lda # $01
        sta $d02c
        ; set sprite 6 colour to green
        lda # $05
        sta $d02d
        ; set sprite 7 colour to brown
        lda # $09
        sta $d02e

        ; set sprite multi-colour 1 to orange
        lda # $08
        sta $d025
        ; set sprite multi-colour 2 to yellow
        lda # $07
        sta $d026

        ; set all sprites to single-colour
        lda # $00
        sta $d01c

        ; set all sprites to double-width, double-height
        lda # $ff
        sta $d017           ; sprite double-height register
        sta $d01d           ; sprite double-width register

        ; set sprites X 8th bit to 0; i.e all X-positions are < 256
        lda # $00
        sta $d010

        ; roughly centre sprite 0 on screen
        ldx # 161
        ldy # 101
        stx $d000           ; sprite 0 x-position
        sty $d001           ; sprite 0 y-position
        
        lda # 18
        ldy # 12
        sta $d002           ; sprite 1 x-position
        sty $d003           ; sprite 1 y-position
        asl a               ; double x-position (=36)
        sta $d004           ; sprite 2 x-position
        sty $d005           ; sprite 2 y-position
        asl a               ; double x-position (=72)
        sta $d006           ; sprite 3 x-position
        sty $d007           ; sprite 3 y-position
        asl a               ; double x-position (=144)
        sta $d008           ; sprite 4 x-position
        sty $d009           ; sprite 4 y-position
        lda # 14
        sta $d00a           ; sprite 5 x-position
        sty $d00b           ; sprite 5 y-position
        asl a               ; double x-position (=28)
        sta $d00c           ; sprite 6 x-position
        sty $d00d           ; sprite 6 y-position
        asl a               ; double x-position (=56)
        sta $d00e           ; sprite 7 x-position
        sty $d00f           ; sprite 7 y-position

        ; set sprite priority: only sprite 1 is behind screen
        lda # %0000010
        sta $d01b

        ; erase $4000-$6000:
        ;-----------------------------------------------------------------------

        lda # $00
        sta ZP_COPY_TO+0
        tay 
        ldx #> $4000

_76d8:  stx ZP_COPY_TO+1
:       sta (ZP_COPY_TO), y
        iny 
        bne :-
        ldx ZP_COPY_TO+1
        inx 
        cpx # $60
        bne _76d8

        ; erase $6000-$6800
        ;-----------------------------------------------------------------------

        lda # $10
_76e8:  stx ZP_COPY_TO+1
:       sta (ZP_COPY_TO), y
        iny 
        bne :-
        ldx ZP_COPY_TO+1
        inx 
        cpx # $68
        bne _76e8

        ; copy 279 bytes of data to $66d0-$67E7
        ;-----------------------------------------------------------------------

        lda #< $66d0
        sta ZP_COPY_TO+0
        lda #> $66d0
        sta ZP_COPY_TO+1
        lda #< _783a
        sta ZP_COPY_FROM+0
        lda #> _783a
        jsr _7827

        ; todo: what the hell is this madness?
        ;-----------------------------------------------------------------------

        ; $00 $00 $00 $70 $10 $10 $10 $10
        ; $10 $10 $10 $10 $10 $10 $10 $10
        ; $10 $10 $10 $10 $10 $10 $10 $10
        ; $10 $10 $10 $10 $10 $10 $10 $10
        ; $10 $10 $10 $10 $70 $00 $00 $00
        ; ...

        ; copy 
        lda #< $6000
        sta ZP_COPY_TO+0
        lda #> $6000
        sta ZP_COPY_TO+1

        ldx # $19

_7711:  lda # $70
        ldy # $24               ; write $70 to $6024
        sta (ZP_COPY_TO), y
        ldy # $03               ; write $70 to $6003
        sta (ZP_COPY_TO), y
        dey

        ; write $00 to $6000-$6002 !?
        lda # $00
:       sta (ZP_COPY_TO), y
        dey 
        bpl :-

        ldy # $25
        sta (ZP_COPY_TO), y     ; write $00 to $6025
        iny 
        sta (ZP_COPY_TO), y     ; and $6026
        iny 
        sta (ZP_COPY_TO), y     ; and $6027
    
        ; add 40 to the low-address (i.e. make $6028)
        lda ZP_COPY_TO+0
        clc 
        adc # $28
        sta ZP_COPY_TO+0
        bcc :+
        inc ZP_COPY_TO+1
:       dex                     ; note that X was loaded with $19 a while back
        bne _7711

        ;-----------------------------------------------------------------------

        lda #< $6400
        sta ZP_COPY_TO+0
        lda #> $6400
        sta ZP_COPY_TO+1

        ldx # $12

_7745:  lda # $70
        ldy # $24
        sta (ZP_COPY_TO),y
        ldy # $03
        sta (ZP_COPY_TO),y
        dey 
        lda # $00

_7752:  sta (ZP_COPY_TO),y
        dey 
        bpl _7752
        ldy # $25
        sta (ZP_COPY_TO),y
        iny 
        sta (ZP_COPY_TO),y
        iny 
        sta (ZP_COPY_TO),y
        lda ZP_COPY_TO+0
        clc 
        adc # $28
        sta ZP_COPY_TO+0
        bcc _776c
        inc ZP_COPY_TO+1
_776c:
        dex 
        bne _7745

        ;-----------------------------------------------------------------------

        ; write $70 from $63e4 to $63c4
        lda # $70
        ldy # $1f
:       sta $63c4, y            ; = $63c4+$1f=$63e3
        dey 
        bpl :-

        ; set $d800-$dc00 (colour RAM) to black
        lda # $00
        sta ZP_COPY_TO+0
        tay 
        ldx #> $d800
        stx ZP_COPY_TO+1

        ldx # $04               ; 4 x 256 = 1'024 bytes
_7784:  sta (ZP_COPY_TO), y
        iny 
        bne _7784
        inc ZP_COPY_TO+1
        dex 
        bne _7784

        ;-----------------------------------------------------------------------
        ; copy 279? bytes from $795a to $d0da
        ; sprite images??

        lda #< $dad0
        sta ZP_COPY_TO+0
        lda #> $dad0
        sta ZP_COPY_TO+1
        lda #< $795a
        sta ZP_COPY_FROM+0
        lda #> $795a
        jsr _7827

        ; write $07 to $d802-$d824

        ldy # $22
        lda # $07
_77a3:  sta $d802,y
        dey 
        bne _77a3

        lda # $a0
        sta $63f8
        sta $67f8
        lda # $a4
        sta $63f9
        sta $67f9
        lda # $a5
        sta $63fa
        sta $67fa
        sta $63fc
        sta $67fc
        sta $63fe
        sta $67fe
        lda # $a6
        sta $63fb
        sta $67fb
        sta $63fd
        sta $67fd
        sta $63ff
        sta $67ff

        ;-----------------------------------------------------------------------

        lda $01             ; get processor port state
        and # %11111000     ; retain everything except bits 0-2 
        ora # %00000110     ; turn KERNAL ROM on?
        sta $01

        ;-----------------------------------------------------------------------

        ; copy $7d7a-$867a to $ef90-$f890 (under the KERNAL ROM)

        cli                 ; enable interrupts 
        ldx # $09           ; size of copy - 9 x 256 = 2'304 bytes
        lda #< $ef90
        sta ZP_COPY_TO+0
        lda #> $ef90
        sta ZP_COPY_TO+1
        lda #< $7d7a
        sta ZP_COPY_FROM+0
        lda #> $7d7a
        jsr copy_bytes

        ;-----------------------------------------------------------------------

        ; copy $7A7A-$7B79 to $6800-$68FF

        ldy # $00
_77ff:  lda $7a7a, y
        sta $6800, y
        dey 
        bne _77ff

        ; copy $7B7A-$7C79 to $6900-$69FF
_7808:  lda $7b7a, y
        sta $6900, y
        dey 
        bne _7808

        ; NOTE: this memory address has been modified to say `jmp $038a`
        ; (part of 'loader_stage1.asm')
        jmp $ce0e




.proc   copy_bytes                                                      ;$7814
        ;=======================================================================
        ; copies bytes from one address to another in 256 byte blocks
        ;
        ; $18/$19 = pointer to address to copy to
        ;     $1a = low-byte of address to copy from
        ;       A = high-byte of address to copy from (gets placed into $1b)
        ;       X = number of 265-byte blocks to copy

        sta ZP_COPY_FROM+1
        ldy # $00

:       lda (ZP_COPY_FROM), y                                           ;$7818
        sta (ZP_COPY_TO), y
        dey 
        bne :-
        inc ZP_COPY_FROM+1
        inc ZP_COPY_TO+1
        dex 
        bne :-
        rts

.endproc

.proc   _7827                                                           ;$7827
        ;=======================================================================
        ; copy 256-bytes using current parameters
        ldx # $01
        jsr copy_bytes

        ; copy a further 22 bytes
        ldy # $17
        ldx # $01
:       lda (ZP_COPY_FROM), y                                           ;$7830
        sta (ZP_COPY_TO), y
        dey 
        bpl :-
        ldx # $00
        rts
.
endproc

;===============================================================================

; this is the decrypted version of the data in "gma4.prg"
; note: the first 279 bytes are copied via _7827 above

_783a:
        .byte   $00, $00, $00, $07, $17, $17, $74, $74
        .byte   $74, $74, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $67, $27, $27, $27
        .byte   $27, $27, $37, $37, $07, $00, $00, $00
        .byte   $00, $00, $00, $07, $17, $17, $24, $24
        .byte   $24, $24, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $67, $67, $67, $67, $23, $23
        .byte   $23, $23, $37, $37, $07, $00, $00, $00
        .byte   $00, $00, $00, $07, $37, $37, $29, $29
        .byte   $29, $29, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $67, $27, $23, $23
        .byte   $23, $23, $37, $37, $07, $00, $00, $00
        .byte   $00, $00, $00, $07, $37, $37, $28, $28
        .byte   $28, $28, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $24, $24
        .byte   $24, $24, $17, $17, $07, $00, $00, $00
        .byte   $00, $00, $00, $07, $37, $37, $2a, $2a
        .byte   $2a, $2a, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $24, $24
        .byte   $24, $24, $17, $17, $07, $00, $00, $00
        .byte   $00, $00, $00, $07, $37, $37, $2d, $2d
        .byte   $2d, $2d, $27, $07, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $07, $27, $24, $24
        .byte   $24, $24, $17, $17, $07, $00, $00, $00
        .byte   $00, $00, $00, $07, $c7, $c7, $07, $07
        .byte   $07, $07, $27, $07, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $27, $27, $27, $27
        .byte   $27, $27, $27, $27, $07, $27, $24, $24
        .byte   $24, $24, $17, $17, $07, $00, $00, $00
        .byte   $60, $d3, $66, $1d, $a0, $40, $b3, $d3
        .byte   $00, $00, $00, $00, $05, $05, $05, $05
        .byte   $05, $05, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $05, $05, $05, $05, $05, $05
        .byte   $05, $05, $05, $05, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $05, $05, $05, $05
        .byte   $05, $05, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $05, $05, $05, $05, $05, $05
        .byte   $05, $05, $05, $05, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $05, $05, $05, $05
        .byte   $05, $05, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $05, $05, $05, $05, $05, $05
        .byte   $05, $05, $05, $05, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $05, $05, $05, $05
        .byte   $05, $05, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $05, $05, $05, $05, $05
        .byte   $05, $05, $05, $05, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $05, $05, $05, $05
        .byte   $05, $05, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $05, $05
        .byte   $05, $05, $05, $05, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $05, $05, $05, $05
        .byte   $05, $05, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $05, $05
        .byte   $05, $05, $05, $05, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $0f, $0f, $07, $07
        .byte   $07, $07, $0d, $0d, $0d, $0d, $0d, $0d
        .byte   $0d, $03, $03, $03, $03, $03, $0d, $0d
        .byte   $0d, $0d, $0d, $0d, $0d, $0d, $07, $07
        .byte   $07, $07, $05, $05, $00, $00, $00, $00
        .byte   $8d, $18, $8f, $50, $46, $7e, $a4, $f4
        .byte   $00, $00, $00, $00, $00, $00, $00, $10
        .byte   $00, $00, $10, $00, $00, $10, $00, $00
        .byte   $10, $00, $00, $10, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $3e, $00
        .byte   $f8, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $10, $00, $00, $10, $00
        .byte   $00, $10, $00, $00, $10, $00, $00, $10
        .byte   $00, $00, $00, $00, $00, $00, $00, $3a
        .byte   $00, $00, $00, $00, $00, $00, $00, $10
        .byte   $00, $00, $10, $00, $00, $10, $00, $07
        .byte   $ff, $c0, $04, $00, $40, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $04, $00, $40, $07, $ff, $c0
        .byte   $00, $10, $00, $00, $10, $00, $00, $10
        .byte   $00, $00, $00, $00, $00, $00, $00, $31
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $fe, $00, $00, $44, $00, $00
        .byte   $28, $00, $00, $10, $00, $30, $00, $18
        .byte   $28, $00, $28, $24, $00, $48, $22, $00
        .byte   $88, $24, $00, $48, $28, $00, $28, $30
        .byte   $00, $18, $00, $10, $00, $00, $28, $00
        .byte   $00, $44, $00, $00, $fe, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $45
        .byte   $3f, $ff, $f8, $20, $10, $08, $20, $38
        .byte   $08, $08, $10, $20, $c4, $38, $46, $82
        .byte   $10, $82, $81, $39, $02, $80, $10, $02
        .byte   $80, $7c, $02, $a6, $44, $ca, $fc, $10
        .byte   $7e, $a6, $44, $ca, $80, $7c, $02, $80
        .byte   $10, $02, $81, $39, $02, $82, $10, $82
        .byte   $c4, $38, $46, $08, $10, $20, $20, $38
        .byte   $08, $20, $10, $08, $3f, $ff, $f8, $a3
        .byte   $00, $00, $00, $00, $43, $00, $10, $c8
        .byte   $80, $04, $31, $c0, $13, $04, $c8, $08
        .byte   $2c, $24, $59, $2d, $cc, $13, $56, $38
        .byte   $ca, $6e, $16, $0e, $6d, $8b, $20, $db
        .byte   $98, $06, $cb, $b0, $23, $a9, $8a, $8e
        .byte   $6d, $8b, $13, $24, $c8, $33, $2d, $94
        .byte   $08, $63, $88, $18, $04, $20, $18, $c2
        .byte   $0c, $00, $c8, $80, $00, $06, $00, $44
        .byte   $00, $2a, $00, $08, $aa, $80, $0a, $99
        .byte   $a0, $2a, $aa, $a8, $0a, $aa, $aa, $26
        .byte   $a6, $a8, $aa, $6a, $aa, $2a, $aa, $98
        .byte   $aa, $aa, $aa, $aa, $aa, $aa, $2a, $aa
        .byte   $a8, $ab, $ea, $fa, $af, $fb, $fe, $af
        .byte   $bb, $ee, $ab, $ea, $fa, $2a, $aa, $a8
        .byte   $0a, $aa, $a0, $02, $aa, $80, $00, $96
        .byte   $00, $00, $14, $00, $00, $00, $00, $44
        .byte   $00, $00, $00, $00, $00, $00, $00, $0a
        .byte   $00, $0a, $2a, $80, $2a, $a6, $a0, $2a
        .byte   $aa, $a8, $aa, $6a, $a8, $2a, $aa, $a8
        .byte   $aa, $aa, $aa, $aa, $aa, $aa, $2a, $aa
        .byte   $a8, $ab, $ea, $fa, $af, $fb, $fe, $ae
        .byte   $fb, $be, $ab, $ea, $fa, $2a, $aa, $a8
        .byte   $0a, $aa, $a0, $01, $aa, $40, $00, $96
        .byte   $00, $00, $14, $00, $00, $00, $00, $54
        .byte   $38, $35, $25, $67, $fa, $b5, $a5, $a2
        .byte   $22, $c1, $df, $eb, $77, $ce, $f4, $07
        .byte   $37, $cf, $33, $4d, $a5, $89, $76, $cd
        .byte   $6d, $69, $8d, $56, $cd, $94, $98, $f6
        .byte   $b8, $ce, $14, $13, $d1, $98, $ce, $b1
        .byte   $77, $ce, $f4, $1c, $b1, $40, $68, $30
        .byte   $87, $cd, $a9, $90, $b2, $08, $c1, $db
        .byte   $cf, $33, $49, $80, $6b, $ca, $3a, $cf
        .byte   $33, $8d, $49, $ea, $53, $29, $2c, $2f
        .byte   $87, $c4, $a0, $70, $96, $90, $b3, $38
        .byte   $b9, $53, $9a, $91, $ae, $2e, $70, $f8
        .byte   $c8, $1b, $7c, $a1, $d1, $37, $2b, $4c
        .byte   $97, $f3, $4f, $73, $ad, $d2, $39, $71
        .byte   $4d, $ee, $f5, $d3, $4f, $e7, $c7, $f5
        .byte   $fe, $05, $d3, $4f, $68, $88, $35, $f9
        .byte   $00, $d3, $4f, $27, $4a, $38, $f6, $fd
        .byte   $d6, $26, $cb, $1b, $bc, $ed, $0b, $33
        .byte   $e9, $f0, $d3, $4f, $62, $85, $38, $f1
        .byte   $f8, $d3, $4f, $30, $56, $3b, $05, $0c
        .byte   $d3, $4f, $68, $90, $98, $cb, $b7, $34
        .byte   $ed, $01, $08, $d3, $4f, $07, $2f, $3d
        .byte   $d1, $d8, $d3, $4f, $62, $83, $36, $db
        .byte   $e2, $db, $2b, $07, $71, $1a, $93, $4f
        .byte   $f8, $34, $d4, $33, $6f, $51, $ce, $d5
        .byte   $ea, $66, $8d, $af, $37, $04, $2b, $fe
        .byte   $d7, $03, $2a, $f7, $d0, $06, $0d, $db
        .byte   $ad, $a5, $2f, $ce, $a4, $2e, $ce, $a3
        .byte   $4d, $06, $60, $d2, $5b, $bc, $9d, $13
        .byte   $4f, $a8, $cd, $3a, $f7, $1e, $3e, $17
        .byte   $f4, $fb, $dd, $b2, $4c, $97, $35, $ea
        .byte   $45, $c9, $e9, $b0, $2f, $8b, $12, $f7
        .byte   $b6, $8b, $ab, $45, $c9, $e9, $b0, $06
        .byte   $bb, $0b, $36, $e2, $b7, $ab, $cf, $e3
        .byte   $ea, $d9, $29, $a2, $f1, $8f, $b5, $d3
        .byte   $8a, $ce, $f1, $8f, $75, $c4, $14, $0b
        .byte   $56, $0a, $e0, $2b, $35, $e6, $bc, $0c
        .byte   $30, $ea, $44, $96, $1b, $ae, $8a, $ea
        .byte   $0b, $0c, $86, $44, $96, $38, $2c, $36
        .byte   $d3, $4f, $29, $50, $d3, $05, $45, $c9
        .byte   $e9, $b0, $e9, $19, $b5, $0b, $fb, $b9
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $aa, $00, $15, $10, $15, $10, $10, $00
        .byte   $aa, $00, $14, $10, $14, $04, $14, $00
        .byte   $55, $00, $00, $00, $00, $00, $00, $ff
        .byte   $55, $00, $00, $00, $00, $00, $00, $ff
        .byte   $55, $00, $00, $00, $00, $00, $00, $ff
        .byte   $55, $00, $00, $00, $00, $00, $00, $ff
        .byte   $aa, $96, $98, $a0, $80, $80, $80, $80
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $00, $00, $00, $00, $00, $00, $00
        .byte   $aa, $96, $98, $a0, $a0, $a0, $a0, $80
        .byte   $aa, $04, $00, $14, $00, $14, $00, $14
        .byte   $aa, $96, $26, $2a, $0a, $0a, $02, $02
        .byte   $aa, $00, $00, $00, $00, $00, $33, $ff
        .byte   $aa, $00, $00, $00, $00, $00, $33, $ff
        .byte   $aa, $00, $00, $00, $00, $00, $33, $ff
        .byte   $aa, $00, $00, $00, $00, $00, $33, $ff
        .byte   $aa, $00, $14, $10, $14, $04, $14, $00
        .byte   $aa, $00, $54, $44, $54, $40, $40, $00
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $15, $11, $11, $15, $11, $00, $00
        .byte   $00, $14, $10, $14, $04, $14, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $01, $14
        .byte   $00, $00, $00, $00, $00, $00, $14, $00
        .byte   $00, $00, $00, $00, $01, $50, $04, $00
        .byte   $00, $00, $00, $00, $14, $c0, $00, $00
        .byte   $00, $00, $00, $00, $45, $00, $00, $00
        .byte   $00, $00, $00, $00, $15, $00, $04, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $51, $00, $00, $00
        .byte   $00, $00, $00, $00, $10, $c4, $04, $00
        .byte   $00, $00, $00, $00, $00, $50, $01, $00
        .byte   $00, $00, $00, $00, $00, $00, $40, $05
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $80, $80, $84, $80, $80, $80, $80, $a0
        .byte   $00, $00, $41, $00, $00, $14, $00, $14
        .byte   $02, $02, $12, $02, $02, $02, $02, $02
        .byte   $00, $00, $00, $00, $00, $00, $0c, $ff
        .byte   $00, $00, $00, $00, $00, $00, $cc, $ff
        .byte   $c0, $c0, $00, $00, $00, $c0, $cc, $ff
        .byte   $00, $00, $00, $00, $00, $00, $cc, $ff
        .byte   $00, $00, $14, $11, $15, $14, $11, $00
        .byte   $00, $00, $10, $10, $10, $10, $14, $00
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $14, $10, $14, $10, $10, $00, $00
        .byte   $00, $44, $44, $44, $44, $10, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $c3, $ff
        .byte   $00, $00, $00, $00, $00, $00, $0c, $ff
        .byte   $00, $00, $00, $00, $00, $00, $30, $ff
        .byte   $00, $00, $00, $00, $00, $00, $c3, $ff
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $01, $04
        .byte   $00, $00, $00, $05, $10, $40, $00, $00
        .byte   $01, $14, $40, $04, $00, $00, $00, $00
        .byte   $00, $00, $00, $44, $00, $00, $00, $00
        .byte   $00, $00, $00, $44, $01, $00, $04, $00
        .byte   $10, $00, $40, $44, $00, $00, $00, $00
        .byte   $0c, $00, $00, $44, $00, $00, $00, $00
        .byte   $00, $00, $00, $c4, $00, $00, $0c, $00
        .byte   $04, $00, $04, $40, $04, $00, $04, $00
        .byte   $00, $00, $00, $44, $00, $00, $0c, $00
        .byte   $0c, $00, $00, $c4, $00, $00, $00, $00
        .byte   $01, $00, $00, $44, $00, $00, $00, $00
        .byte   $00, $00, $40, $04, $10, $00, $04, $00
        .byte   $00, $00, $00, $44, $00, $00, $00, $00
        .byte   $40, $05, $00, $44, $00, $00, $00, $00
        .byte   $00, $00, $40, $14, $01, $00, $00, $00
        .byte   $20, $20, $28, $08, $0a, $42, $10, $04
        .byte   $00, $14, $00, $14, $00, $aa, $00, $00
        .byte   $0a, $0a, $26, $26, $96, $aa, $02, $02
        .byte   $00, $00, $00, $00, $00, $00, $0c, $ff
        .byte   $00, $00, $00, $00, $00, $00, $30, $ff
        .byte   $c0, $c0, $00, $00, $00, $c0, $c3, $ff
        .byte   $00, $00, $00, $00, $00, $00, $0c, $ff
        .byte   $00, $14, $11, $11, $11, $14, $00, $00
        .byte   $00, $14, $10, $10, $10, $14, $00, $00
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $14, $10, $10, $10, $14, $00, $00
        .byte   $00, $54, $10, $10, $10, $10, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $c0, $ff
        .byte   $00, $00, $00, $00, $00, $00, $c0, $ff
        .byte   $00, $00, $00, $00, $00, $00, $c0, $ff
        .byte   $00, $00, $00, $00, $00, $00, $c0, $ff
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $10, $10, $40, $44, $00, $40, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $44, $00, $04, $00
        .byte   $10, $00, $40, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $04, $c0, $04, $00, $48, $2a, $04, $00
        .byte   $00, $c0, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $01, $00, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $40, $00, $44, $00, $04, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $00, $44, $00, $00, $00
        .byte   $04, $01, $01, $00, $44, $00, $00, $00
        .byte   $00, $00, $00, $40, $00, $40, $00, $40
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $01, $05, $01, $01, $05, $00, $00
        .byte   $00, $00, $00, $00, $00, $40, $00, $00
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $10, $10, $10, $10, $14, $00, $00
        .byte   $00, $54, $10, $10, $10, $10, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $c3, $ff
        .byte   $00, $00, $00, $00, $00, $00, $0c, $ff
        .byte   $00, $00, $00, $00, $00, $00, $30, $ff
        .byte   $00, $00, $00, $00, $00, $00, $c0, $ff
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $40, $10, $10, $04, $04, $01, $00, $00
        .byte   $00, $00, $00, $00, $00, $40, $44, $10
        .byte   $00, $00, $00, $00, $01, $00, $44, $00
        .byte   $10, $00, $40, $00, $00, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $04, $00, $04, $00, $04, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $01, $00, $00, $00, $00, $00, $44, $00
        .byte   $00, $00, $40, $00, $10, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $01
        .byte   $00, $01, $01, $05, $04, $10, $40, $00
        .byte   $40, $00, $00, $00, $00, $00, $00, $00
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $05, $00, $05, $04, $05, $00, $00, $00
        .byte   $40, $40, $40, $00, $40, $00, $00, $00
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $15, $11, $15, $11, $11, $00, $00
        .byte   $00, $10, $10, $10, $10, $14, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $c3, $ff
        .byte   $00, $00, $00, $00, $00, $00, $03, $ff
        .byte   $00, $00, $00, $00, $00, $00, $03, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $55, $55, $50, $50, $55, $55, $50, $50
        .byte   $04, $01, $00, $00, $00, $00, $00, $00
        .byte   $10, $40, $10, $01, $00, $00, $00, $00
        .byte   $00, $00, $00, $40, $14, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $50, $01, $00
        .byte   $00, $00, $00, $00, $00, $00, $44, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $51
        .byte   $00, $00, $00, $00, $00, $00, $00, $14
        .byte   $04, $00, $04, $00, $04, $00, $04, $45
        .byte   $00, $00, $00, $00, $00, $00, $00, $11
        .byte   $00, $00, $00, $00, $00, $00, $00, $44
        .byte   $00, $00, $00, $00, $00, $00, $11, $40
        .byte   $00, $00, $00, $00, $00, $05, $40, $00
        .byte   $00, $00, $00, $00, $14, $00, $00, $00
        .byte   $01, $00, $05, $50, $00, $00, $00, $00
        .byte   $04, $40, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $55, $55, $40, $40, $55, $55, $01, $01
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $05, $00, $05, $00, $05, $00, $00, $04
        .byte   $40, $40, $40, $40, $40, $00, $00, $00
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $02, $02, $02, $02, $02, $02, $02, $02
        .byte   $00, $00, $33, $15, $11, $00, $00, $aa
        .byte   $00, $00, $f0, $5c, $50, $00, $00, $aa
        .byte   $00, $54, $54, $54, $54, $54, $00, $aa
        .byte   $00, $54, $54, $54, $54, $54, $00, $aa
        .byte   $00, $54, $54, $54, $54, $54, $00, $aa
        .byte   $00, $54, $54, $54, $54, $54, $00, $aa
        .byte   $80, $80, $80, $80, $a0, $98, $96, $aa
        .byte   $55, $55, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $0f, $0c, $0f, $0c, $0f, $00, $aa
        .byte   $00, $cc, $0c, $0c, $0c, $cf, $00, $aa
        .byte   $00, $0c, $0c, $0c, $0c, $cc, $00, $aa
        .byte   $00, $fc, $30, $30, $30, $30, $00, $aa
        .byte   $00, $fc, $c0, $f0, $c0, $fc, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $aa
        .byte   $55, $55, $00, $00, $00, $00, $00, $aa
        .byte   $02, $02, $02, $02, $0a, $26, $96, $aa
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $00, $00, $00, $00, $00, $00, $00, $ff
        .byte   $04, $04, $04, $05, $00, $00, $00, $aa
        .byte   $00, $40, $40, $40, $40, $00, $00, $aa
        .byte   $80, $80, $80, $80, $80, $80, $80, $80
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $00, $00, $00, $00, $00, $00, $00, $00
        .byte   $f5

;_865b: