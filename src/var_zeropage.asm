; "Elite" C64 disassembly / "Elite DX", cc0 2018, see LICENSE.txt
; "Elite" is copyright / trademark David Braben & Ian Bell, All Rights Reserved
; <github.com/Kroc/EliteDX>
;===============================================================================

; "var_zeropage.asm" -- special variables in the Zero Page;
; 256 bytes of slightly faster memory

; note that $00 & $01 are hard-wired to the CPU, so can't be used

;-------------------------------------------------------------------------------

; "goat soup" is the algorithm for generating planet descriptions.
; its seed is taken from the last four bytes of the main seed 
ZP_GOATSOUP             = $02
ZP_GOATSOUP_pt1         = $02
ZP_GOATSOUP_pt2         = $03
ZP_GOATSOUP_pt3         = $04
ZP_GOATSOUP_pt4         = $05

ZP_TEMP_VAR             = $06   ; a temporary single byte
ZP_TEMP_ADDR            = $07   ; a temporary word / addr
ZP_TEMP_ADDR_LO         = $07
ZP_TEMP_ADDR_HI         = $08

;-------------------------------------------------------------------------------

; Elite has a number of 'slots' for 3D-objects currently in play;
; e.g. ships, asteroids, space stations and other such polygon-objects
;
; huge thanks to "DrBeeb" for documenting the data structure on the Elite Wiki
; http://wiki.alioth.net/index.php/Classic_Elite_entity_states
;
.struct PolyObject                                                      ;offset
        ; NOTE: these are not addresses, but they are 24-bit
        ;SPEED: do we need 24 bits for this? Can we get away with 16?
        ;       surely +/- 32'767 is enough distance relative to the player?
        xpos            .faraddr                                        ;+$00
        ypos            .faraddr                                        ;+$03
        zpos            .faraddr                                        ;+$06

        ; a 3x3 rotation matrix?
        ; TODO: I don't know how best to name these yet
        m0x0            .word                                           ;+$09
        m0x1            .word                                           ;+$0B
        m0x2            .word                                           ;+$0D
        m1x0            .word                                           ;+$0F
        m1x1            .word                                           ;+$11
        m1x2            .word                                           ;+$13
        m2x0            .word                                           ;+$15
        m2x1            .word                                           ;+$17
        m2x2            .word                                           ;+$19

        ; a pointer to already processed vertex data
        vertexData      .addr                                           ;+$1B

        speed           .byte                                           ;+$1D
        acceleration    .byte                                           ;+$1E
        energy          .byte                                           ;+$1F
        roll            .byte                                           ;+$20
        pitch           .byte                                           ;+$21

        ; A.I. state
        attack          .byte                                           ;+$22
        behaviour       .byte                                           ;+$23
        state           .byte                                           ;+$24
.endstruct

ZP_POLYOBJ              = $09
ZP_POLYOBJ_XPOS         = $09
ZP_POLYOBJ_XPOS_pt1     = $09
ZP_POLYOBJ_XPOS_pt2     = $0A
ZP_POLYOBJ_XPOS_pt3     = $0B
ZP_POLYOBJ_YPOS         = $0C
ZP_POLYOBJ_YPOS_pt1     = $0C
ZP_POLYOBJ_YPOS_pt2     = $0D
ZP_POLYOBJ_YPOS_pt3     = $0E
ZP_POLYOBJ_ZPOS         = $0F
ZP_POLYOBJ_ZPOS_pt1     = $0F
ZP_POLYOBJ_ZPOS_pt2     = $10
ZP_POLYOBJ_ZPOS_pt3     = $11

ZP_POLYOBJ_M0x0         = $12
ZP_POLYOBJ_M0x0_LO      = $12
ZP_POLYOBJ_M0x0_HI      = $13
ZP_POLYOBJ_M0x1         = $14
ZP_POLYOBJ_M0x1_LO      = $14
ZP_POLYOBJ_M0x1_HI      = $15
ZP_POLYOBJ_M0x2         = $16
ZP_POLYOBJ_M0x2_LO      = $16
ZP_POLYOBJ_M0x2_HI      = $17
ZP_POLYOBJ_M1x0         = $18
ZP_POLYOBJ_M1x0_LO      = $18
ZP_POLYOBJ_M1x0_HI      = $19
ZP_POLYOBJ_M1x1         = $1A
ZP_POLYOBJ_M1x1_LO      = $1A
ZP_POLYOBJ_M1x1_HI      = $1B
ZP_POLYOBJ_M1x2         = $1C
ZP_POLYOBJ_M1x2_LO      = $1C
ZP_POLYOBJ_M1x2_HI      = $1D
ZP_POLYOBJ_M2x0         = $1E
ZP_POLYOBJ_M2x0_LO      = $1E
ZP_POLYOBJ_M2x0_HI      = $1F
ZP_POLYOBJ_M2x1         = $20
ZP_POLYOBJ_M2x1_LO      = $20
ZP_POLYOBJ_M2x1_HI      = $21
ZP_POLYOBJ_M2x2         = $22
ZP_POLYOBJ_M2x2_LO      = $22
ZP_POLYOBJ_M2x2_HI      = $23

ZP_POLYOBJ_VERTX        = $24
ZP_POLYOBJ_VERTX_LO     = $24
ZP_POLYOBJ_VERTX_HI     = $25

;-------------------------------------------------------------------------------

ZP_ROTX                 = $26   ; rotate-X counter? "roll"
ZP_ROTZ                 = $27   ; rotate-Z counter? "pitch"

ZP_MISSILE_STATE        = $28   ; BBC says "display/exploding state|missiles"??

;                       = $29   ; something to do with A.I.

;                       = $2A   ; another temporary address?
;                       = $2B

ZP_VAR_P                = $2E   ; a common variable called "P"
ZP_VAR_P1               = $2E
ZP_VAR_P2               = $2F
ZP_VAR_P3               = $30

;-------------------------------------------------------------------------------

ZP_CURSOR_COL           = $31
ZP_CURSOR_ROW           = $33

;-------------------------------------------------------------------------------

VAR_X                   = $6b   ; a common "X" variable
VAR_Y                   = $6c   ; a common "Y" variable

ZP_SEED                 = $7f
ZP_SEED_pt1             = $7f
ZP_SEED_pt2             = $80
ZP_SEED_pt3             = $81
ZP_SEED_pt4             = $82
ZP_SEED_pt5             = $83
ZP_SEED_pt6             = $84

PLAYER_SPEED            = $96

VAR_Z                   = $a1   ; a common "Z" variable
