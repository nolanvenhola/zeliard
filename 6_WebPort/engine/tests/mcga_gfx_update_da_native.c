#include "../render/mcga_render.h"
#include <stdint.h>
#include <stdio.h>
static uint64_t h(const uint8_t *p,size_t n){uint64_t x=0xcbf29ce484222325ULL;for(size_t i=0;i<n;i++){x^=p[i];x*=0x100000001b3ULL;}return x;}
int main(void){uint8_t d[65536]={0},g[65536],w[65536]={0},v[65536];for(size_t i=0;i<65536;i++){g[i]=(uint8_t)(i*17u+29u);v[i]=(uint8_t)(i*37u+11u);}int ok=zeliard_mcga_gfx_update_da_stage(d,sizeof d,g,sizeof g,w,sizeof w,0,0x0b48,0x3180,0x9000,v,sizeof v,16)==0;uint64_t wh=h(w,sizeof w),vh=h(v,sizeof v);ok&=wh==0x2FB7EF45149BE3D5ULL&&vh==0xCC1FD8CE74E825F5ULL;printf("mcga_gfx_update_da: %s work=%016llx vga=%016llx\n",ok?"PASS":"FAIL",(unsigned long long)wh,(unsigned long long)vh);printf("VERDICT: %s: C CS:3032 matches MASM oracle\n",ok?"PASS":"FAIL");return ok?0:1;}
