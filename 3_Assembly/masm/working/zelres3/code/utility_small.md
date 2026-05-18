# UTILITY_SMALL - Analysis

**Source:** `chunk_33.bin`  
**Size:** 0.6 KB  
**Functions:** 1  
**Note:** 16-bit x86 real mode. `CS:0x10C` = chunk loader, `0xFF00+` = game state globals.

> For Ghidra decompilation, open in Cutter: Architecture=x86, Bits=16, OS=dos

## Function List
```
0x00000000    1 8            fcn.00000000
```

## Strings
```
nth      paddr      vaddr len size section type   string                                                                                                                                                                                                                                                            
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  0 0x0000002d 0x0000002d  44   45         ibm037 PCDÃ´EI\a\auÃ½CGÂ¢HGÂ¢GÃ´GÃ´Ã®uÃ½DÃƒI\b\auÃ½CÃ´Ã£Â¢EÃ´Ã®Ã´Ã®uÃ½CÃ£H
  1 0x0000005b 0x0000005b  30   31         ibm037 aDÃ£IÃ£EGuÃ¾DÃ´QRbDGIGÃ´Ã®umCÃƒFÃ£umCF
  2 0x0000007b 0x0000007b  12   13         ibm037 umDÃ£EÃ£IGumDÃ¶
  3 0x00000089 0x00000089 257  258         ibm037 QÃ£Ã´urCÃ£urCÃ£urCÃ£urDIGurCGIurCÃ£urCÃ£urCEGurCÃ£urDÃ£urCÃ£urCÃ£urCGIurCEGurCÃ£urCIGurCÃ£urCÃ£urDÃ£urCÃ£urCÃ£urCÃ£urCGEurCÃ£urDÃ£urCÃ£urCGIurCÃ£urCÃ£urCÃ£urCÃ£urCÃ£urCÃ£urCEGurCÃ£urCIGurDÃ£urCÃ£urCÃ£urCGEurCÃ£urCÃ£urCÃ£urCÃ£urDGIurCÃ£urCIGurCÃ£urCÃ£urCEGumCFRQaÃ®umDGHQÃƒumCGQIÃƒumCGIGÂ¢Ã£uÃ½Ã²Ã³ÃµCRQaD
  4 0x000001b4 0x000001b4  21   22         ibm037 }JOGÂ¢FÃ£Ã´IÃ£EGuÃ½}JKEÃ´Ã£I
  5 0x000001d3 0x000001d3  12   13         ibm037 EÃƒuÃ½}JKCEÃ´Ã£Ã´
  6 0x0000022f 0x0000022f  18   18         ascii  Cavern of Cementar
```

## Function Disassembly

### Function 0x00000000
```asm
â”Œ fcn.00000000();
â”‚           0000:0000      imul  ax, word [bp + si], 0
â”‚           0000:0003      add   byte [di], bh
â”‚           ; DATA XREF from fcn.00000000 @ +0x20e
â””           0000:0005      ret   0x49
```
