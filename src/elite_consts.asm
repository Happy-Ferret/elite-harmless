; "Elite" C64 disassembly / "Elite DX", cc0 2018, see LICENSE.txt
; "Elite" is copyright / trademark David Braben & Ian Bell, All Rights Reserved
; <github.com/Kroc/EliteDX>
;===============================================================================

.define ELITE_SEED      $4a, $5a, $48, $02, $53, $B7

; the BBC micro used a 256-px wide screen mode, but the C64 has a 320-px wide
; screen. therefore the C64 only draws in a 256-px wide centered 'screen'.
; the dimensions of this viewport are given here:

ELITE_VIEWPORT_WIDTH    = 256
ELITE_VIEWPORT_HEIGHT   = 144
