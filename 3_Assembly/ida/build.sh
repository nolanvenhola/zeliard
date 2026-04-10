#!/bin/bash

# Make sure your dosbox-x.conf has the following, for max compilation speed:
# [cpu]
# core=dynamic
# cycles=max
# cputype=auto

cat << 'EOF' > build.bat
path D:\;%PATH%
tasm /m9 stick.asm >log.txt
tlink stick.obj >>log.txt
tasm /m9 gmmcga.asm >>log.txt
tlink gmmcga.obj >>log.txt
tasm /m9 gtmcga.asm >>log.txt
tlink gtmcga.obj >>log.txt
tasm /m9 gfmcga.asm >>log.txt
tlink gfmcga.obj >>log.txt
tasm /m9 ympd.asm >>log.txt
tlink ympd.obj >>log.txt
tasm /m9 ckpd.asm >>log.txt
tlink ckpd.obj >>log.txt
tasm /m9 town.asm >>log.txt
tlink town.obj >>log.txt
tasm /m9 fight.asm >>log.txt
tlink fight.obj >>log.txt
tasm /m9 eai1.asm >>log.txt
tlink eai1.obj >>log.txt
tasm /m9 crab.asm >>log.txt
tlink crab.obj >>log.txt
exit
EOF

rm *.bin

dosbox-x -c "mount c ." \
         -c "mount d ../tasm/tool/tasm5" \
         -c "c:" \
         -c "build.bat"

python3 exe2bin.py STICK.EXE stick.bin 0x100
python3 exe2bin.py GMMCGA.EXE gmmcga.bin 0x2000
python3 exe2bin.py GTMCGA.EXE gtmcga.bin 0x3000
python3 exe2bin.py GFMCGA.EXE gfmcga.bin 0x3000
python3 exe2bin.py YMPD.EXE ympd.bin 0x3300
python3 exe2bin.py CKPD.EXE ckpd.bin 0x3300
python3 exe2bin.py TOWN.EXE town.bin 0x6000
python3 exe2bin.py FIGHT.EXE fight.bin 0x6000
python3 exe2bin.py EAI1.EXE eai1.bin 0xA000
python3 exe2bin.py CRAB.EXE crab.bin 0xA000

echo "stick.bin diffs:" >diff.txt
{ cmp -l ../../1_OriginalGame/stick.bin stick.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "gmmcga.bin diffs:" >>diff.txt
{ cmp -l ../../1_OriginalGame/gmmcga.bin gmmcga.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "gtmcga.bin diffs:" >>diff.txt
{ cmp -l ../../2_SAR/VFSExtractor/1/gtmcga.bin gtmcga.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "gfmcga.bin diffs:" >>diff.txt
{ cmp -l ../../2_SAR/VFSExtractor/2/gfmcga.bin gfmcga.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "ympd.bin diffs:" >>diff.txt
{ cmp -l ../../2_SAR/VFSExtractor/2/ympd.bin ympd.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "ckpd.bin diffs:" >>diff.txt
{ cmp -l ../../2_SAR/VFSExtractor/2/ckpd.bin ckpd.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "town.bin diffs:" >>diff.txt
{ cmp -l ../../2_SAR/VFSExtractor/1/town.bin town.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "fight.bin diffs:" >>diff.txt
{ cmp -l ../../2_SAR/VFSExtractor/2/fight.bin fight.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "eai1.bin diffs:" >>diff.txt
{ cmp -l ../../2_SAR/VFSExtractor/3/eai1.bin eai1.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
echo "crab.bin diffs:" >>diff.txt
{ cmp -l ../../2_SAR/VFSExtractor/3/crab.bin crab.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}'; } >>diff.txt 2>&1
rm *.EXE *.MAP *.OBJ build.bat
