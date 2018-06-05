; "Elite" C64 disassembly / "Elite DX", cc0 2018, see LICENSE.txt
; "Elite" is copyright / trademark David Braben & Ian Bell, All Rights Reserved
; <github.com/Kroc/EliteDX>
;===============================================================================

; "gma6.prg"

; these bytes are not encrypted!!! (they're the background-fill)
; the linker will exclude these from the binary of the data-to-be-encrypted.
; when the code is re-linked with the encrypted blob, these bytes are appended

.segment        "GMA6_JUNK"

        .byte   $ff, $00, $ff, $00, $ff, $00, $ff, $00                  ;$CCD8
        .byte   $ff                                                     ;$CCE0

;$CCE1