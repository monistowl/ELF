# Extensible Lab Framework

Collection of useful MATLAB object classes for psychophysiology research.

See ELF_demo.mlx for a quick introduction.

If the demo mindware file gives you nonsensical ECG, open up the file at +ELF/@Physio/readMw.m

Line 80 should look something like
HEADER_LENGTH_OFFSET = 9;

...Change that number to 0, then 1, then 2, &c. until the ECG looks right. Try 4 for Windows or 8 for OSX first.

This ugly hack will be fixed shortly.
