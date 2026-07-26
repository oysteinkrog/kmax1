@echo off
rem %~dp0 is this script's own folder, unlike %cd% which is wherever the
rem caller happened to be. OPENSCADPATH must point at the repo root for the
rem bundled libraries (MCAD, scad-utils, thing_libutils) to resolve.
set OPENSCADPATH=%~dp0
"C:\Program Files\OpenSCAD (Nightly)\openscad.com" %*
