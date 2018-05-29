# "Elite" C64 disassembly / "Elite DX", cc0 2018, see LICENSE.txt
# "Elite" is copyright / trademark David Braben & Ian Bell, All Rights Reserved
# <github.com/Kroc/EliteDX>
#===============================================================================

"""\
A script to 'encrypt' (scramble would be a better word), a binary for inclusion in the original GMA86 loader.

The 'encryption' is done by simply adding one byte to the next and saving the resultant byte. for example, the following original data:

    $4c, $32, $24, $00, $03, $60, $6b, $a9, ...

is encoded by adding $4c and $32 = $7e, then $32 + $24, $24 + $00, and so on giving: (values > $ff just wrap-around)

    $7e, $56, $24, $03, $63, $cb, $14, ...

"""

import argparse

parser = argparse.ArgumentParser(description="A script to 'encrypt' (scramble would be a better word), a binary for inclusion in the original GMA86 loader.")

parser.add_argument("--prg",
    help="if present, ignore a PRG file header",
    action="store_true")
parser.add_argument("key", help="decryption key ,in hex")
parser.add_argument("infile", help="input file")
parser.add_argument("outfile", help="output file")

args = parser.parse_args()

infile = open(args.infile, "rb").read()

with open(args.outfile, "w") as outfile:
    # write out the assembly file header
    outfile.writelines("""\
; "Elite" C64 disassembly / "Elite DX", cc0 2018, see LICENSE.txt
; "Elite" is copyright / trademark David Braben & Ian Bell, All Rights Reserved
; <github.com/Kroc/EliteDX>
;===============================================================================
; this file is automatically generated by ecnrypt.py -- DO NOT MODIFY DIRECTLY
""")
    # which byte we're on (also, which byte we start from)
    byte = 0
    # we'll batch bytes up into groups of 8 per line
    count = 0
    
    # should we skip a PRG header?
    # (two bytes that specify load address)
    if args.prg: byte += 2

    # walk along the bytes in the input file:
    # the last byte in the encrypted data is where to subtract the decryption
    # key to get the last byte of actual data, then work backwards from there

    # the decryption key was probably produced from some running checksum
    # of the data, but I can't recreate this without knowing the algorithm

    for i in range(byte, len(infile) - 1):
        # should we start a new line?
        if count == 0:
            outfile.write("\n.byte   ")
        else:
            outfile.write(", ")
        
        # pair bytes together
        out = int(infile[i]) + int(infile[i+1])
        # ensure bytes wrap around
        if out > 255:
            out = out - 256

        # write to the output file
        outfile.write("$%0.2x" % out)

        count = (count + 1) % 8

    # pair the last data byte with the decryption key
    out = int(infile[len(infile) - 1]) + int(args.key, 16)
    if out > 255:
            out = out - 256

    # write the final byte (on its own line)
    outfile.write("\n\n")
    outfile.write(".byte   $%0.2x" % out)
    

