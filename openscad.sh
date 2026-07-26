#!/bin/sh
# Launch the OpenSCAD GUI with this repo on OPENSCADPATH, so the bundled
# libraries (MCAD, scad-utils, thing_libutils) resolve.
#
# Works from Cygwin/MSYS (cygpath) and WSL (wslpath); both need a Windows-style
# path because the OpenSCAD binary is a Windows program. WSL additionally needs
# WSLENV so the variable survives the crossing into Win32.

if command -v wslpath >/dev/null 2>&1; then
    OPENSCADPATH=`wslpath -w .`
    export OPENSCADPATH WSLENV=OPENSCADPATH
    exec "/mnt/c/Program Files/OpenSCAD (Nightly)/openscad.com" "$@" &
else
    OPENSCADPATH=`cygpath -aw .` openscad-nightly "$@" &
fi
