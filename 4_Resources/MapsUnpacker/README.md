Compile:
```
tasm zelunpack.asm
tlink /t/x zelunpack.obj
```
This extractor assumes that .mdt file to extract is loaded at offset dta
The simplest way to achieve this, is just paste *.mdt binary to the compiled *.com of this extractor
```
COPY /B zelunpack.com + mp10.mdt unpack_mp10.com
```
Then run 
```
unpack_mp10.com
```
