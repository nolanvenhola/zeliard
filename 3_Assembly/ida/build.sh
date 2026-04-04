#!/bin/bash

dosbox-x -c "mount c .." \
         -c "c:" \
         -c "path C:\\tasm\tool\tasm5;%PATH%" \
         -c "cd ida" \
         -c "tasm /m9 fight.asm >log.txt" \
         -c "tlink fight.obj >>log.txt" \
         -c "tasm /m9 eai1.asm >>log.txt" \
         -c "tlink eai1.obj >>log.txt" \
         -c "tasm /m9 crab.asm >>log.txt" \
         -c "tlink crab.obj >>log.txt" \
         -c "exit"
python3 exe2bin.py FIGHT.EXE fight.bin 0x6000
python3 exe2bin.py EAI1.EXE eai1.bin 0xA000
python3 exe2bin.py CRAB.EXE crab.bin 0xA000
echo "fight.bin diffs:" >diff.txt
cmp -l ../../2_SAR/VFSExtractor/2/fight.bin fight.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}' >>diff.txt
echo "eai1.bin diffs:" >>diff.txt
cmp -l ../../2_SAR/VFSExtractor/3/eai1.bin eai1.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}' >>diff.txt
echo "crab.bin diffs:" >>diff.txt
cmp -l ../../2_SAR/VFSExtractor/3/crab.bin crab.bin | gawk '{printf "0x%08X: %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}' >>diff.txt
rm *.EXE *.MAP *.OBJ
