# Elite Memory Map #

          .              .
          :               :
          +---------------+
    $0300 | ?             |   Some heap space?
          |---------------|
    $0400 |               |   variable space
          |               |   (extact details incomplete)
          |               |
          |---------------|
    $0700 | TEXT_FLIGHT   |   compressed text
          |               |
          |               |
          |               |
          |---------------|
    $0B00 | DATA_FONT     |   font graphics
          |               |
          |               |
          |-------------  |
    $0E00 | TEXT_DOCKED   |   compressed text
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |---------------|
    $1D00 | CODE_1D00     |   variable space
          |---------------|
    $1D21 | CODE_GMA5     |   loader stage 5 decryption routine (left behind)
          |---------------|
    $1D81 | CODE_1D81     |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |---------------|
    $250C | TEXT_TOKENS   |
    $254C | TEXT_PAIRS    |
          |---------------|
    $25A6 | DATA_SAVE     |
    $2600 | DATA_2600     |
          |---------------|
    $27A3 | CODE_27A3     |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |---------------|
    $3EAC | TEXT_PDESC    |
          +---------------+

          +---------------+
    $4000 |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
    $5000 |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |---------------|
    $6000 |               |
          |               |
          |               |
          |               |
          |---------------|
    $6400 |               |
          |               |
          |               |
          |               |
          |---------------|
    $6800 | GFX_SPRITES   |
          |               |
          +---------------+

          +---------------+
    $6A00 | CODE_6A00     |
          |               |
          |               |
          |               |
          |               |
          |               |
    $7000 |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
    $8000 |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
    $9000 |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
    $A000 |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
    $B000 |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |---------------|
    $B70E | DATA_B70E     |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
    $C000 |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
          |               |
    $CCD7 +---------------+


$D000..$EF90    SHIP MODELS:
                3D vector data for the various ships / objects in the game

$EF90..$F890    HUD IMAGE (COPY):
                copied from $7D7A..$867A by GMA4.PRG.
                this appears to be a backup-copy of the HUD.
                this is probably used for keeping the radar intact when
                erasing and drawing the poles on the radar; could sprite
                multiplexing be used to avoid this?

$F900..         ?
