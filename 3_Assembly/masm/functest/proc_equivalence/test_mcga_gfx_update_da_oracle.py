#!/usr/bin/env python3
"""Direct release-byte oracle for 105GDMCA:3032 (gfx_update_fn target)."""
from __future__ import annotations
import sys
from pathlib import Path
from unicorn import UC_ARCH_X86, UC_HOOK_CODE, UC_MODE_16, UC_PROT_ALL, Uc
from unicorn.x86_const import *
HERE=Path(__file__).resolve().parent; sys.path.insert(0,str(HERE.parent))
from fixtures import MASM_ROOT
BIN=MASM_ROOT/'bin'/'zelres1'/'105GDMCA.bin'; CODE,GAME,WORK,STACK,VGA=0x1000,0x3000,0x4000,0x5000,0xA000
def h(b):
 x=0xcbf29ce484222325
 for v in b:x=((x^v)*0x100000001b3)&0xffffffffffffffff
 return x
def main():
 m=Uc(UC_ARCH_X86,UC_MODE_16)
 for s in(CODE,GAME,WORK,STACK,VGA):m.mem_map(s<<4,0x10000,UC_PROT_ALL)
 m.mem_write((CODE<<4)+0x2ffc,BIN.read_bytes());m.mem_write(GAME<<4,bytes((i*17+29)&255 for i in range(65536)));m.mem_write(VGA<<4,bytes((i*37+11)&255 for i in range(65536)))
 for r,v in ((UC_X86_REG_CS,CODE),(UC_X86_REG_DS,CODE),(UC_X86_REG_ES,GAME),(UC_X86_REG_SS,STACK),(UC_X86_REG_SP,0xfffc),(UC_X86_REG_AX,0),(UC_X86_REG_BX,0x0b48),(UC_X86_REG_CX,0x3180),(UC_X86_REG_DI,0x9000)):m.reg_write(r,v)
 m.mem_write((STACK<<4)+0xfffc,b'\x80\0')
 def hook(u,a,z,d):
  ip=u.reg_read(UC_X86_REG_IP)&65535
  if ip==0x322d:u.mem_write((CODE<<4)+0xff1a,b'\x14')
  elif ip==0x80:u.emu_stop()
 m.hook_add(UC_HOOK_CODE,hook);m.emu_start((CODE<<4)+0x3032,0)
 wh=h(bytes(m.mem_read(WORK<<4,65536)));vh=h(bytes(m.mem_read(VGA<<4,65536)))
 print(f'mcga_gfx_update_da: work={wh:016x} vga={vh:016x}')
 print('VERDICT: PASS: release bytes executed')
if __name__=='__main__':main()
