# UTILITY_TINY - Analysis

**Source:** `chunk_37.bin`  
**Size:** 0.8 KB  
**Functions:** 1  
**Note:** 16-bit x86 real mode. `CS:0x10C` = chunk loader, `0xFF00+` = game state globals.

> For Ghidra decompilation, open in Cutter: Architecture=x86, Bits=16, OS=dos

## Function List
```
0x00000000    2 14           fcn.00000000
```

## Strings
```
nth      paddr      vaddr len size section type   string                                                                                                
--------------------------------------------------------------------------------------------------------------------------------------------------------
  0 0x0000006c 0x0000006c   5    6         ibm037 Â¿cCDE
  1 0x000000af 0x000000af  15   16         ibm037 Ã¤EÂ¿cÃ³Ãµ}CD\DGIÃ´I
  2 0x000000c1 0x000000c1  13   14         ibm037 Ã¶HEDÂ¿fCD\I$IÃ¶
  3 0x000000ff 0x000000ff 100  101         ibm037 Ã²Ã¶EDEDEDÂ¿kCÃ¤Â¿kCEDÂ¿kC\DÂ¿kCE\Â¿kCÃ¤Â¿kC\DÂ¿kC\DÂ¿kC\DÂ¿kCEDÂ¿kC\DÂ¿kC\DÂ¿kCEDÂ¿kCDGÂ¿kCEDÂ¿kCE\Â¿kC\DÂ¿kCEGÂ¿kCEGÂ¿kCE
  4 0x00000164 0x00000164   9   10         ibm037 Â¿kCGIÂ¿kCE
  5 0x00000173 0x00000173 101  102         ibm037 Â¿kCDHÂ¿kCE\Â¿kCEDÂ¿kC\DÂ¿kCEDÂ¿kCEDÂ¿kC\DÂ¿kCEDÂ¿kCE\Â¿kC\DÂ¿kCÃ¤Â¿kCÃ¤Â¿kCEDÂ¿kCEDÂ¿kC\DÂ¿kCEDÂ¿kCE\Â¿kCEDÂ¿kCEDÂ¿kCEDÂ¿cÃ³
  6 0x000001fe 0x000001fe  16   17         ibm037 g.IHÃ«ED\Ã„Â¿cKLMÃ¶I
  7 0x000002c4 0x000002c4  16   16         ascii  Cavern of Tesoro
```

## Function Disassembly

### Function 0x00000000
```asm
â”Œ fcn.00000000(int16_t arg3, int16_t arg4);
â”‚           ; arg int16_t arg3 @ bx
â”‚           ; arg int16_t arg4 @ cx
â”‚           0000:0000      inc   byte [bp + si]
â”‚           0000:0002      add   byte [bx + si], al                    ; arg3
â”‚           0000:0004      rol   dl, 1
â”‚           0000:0006      dec   cx                                    ; arg4
â”‚           0000:0007      add   byte [bx - 0x3e], ch                  ; arg3
â”‚       â”Œâ”€< 0000:000a      jno   0xffffffce
â””      â”Œâ”€â”€< 0000:000c      jae   0xffffffd0
```
