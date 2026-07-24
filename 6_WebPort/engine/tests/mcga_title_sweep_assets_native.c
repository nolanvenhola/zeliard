#include "../load/grp.h"
#include "../render/mcga_render.h"
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static uint64_t fnv1a64(const uint8_t *data, size_t size) { uint64_t h=0xCBF29CE484222325ULL; for(size_t i=0;i<size;i++){h^=data[i];h*=0x100000001B3ULL;} return h; }
static uint8_t *read_file(const char *name, size_t *size) { FILE *f=fopen(name,"rb"); if(!f)return NULL; fseek(f,0,SEEK_END); long n=ftell(f); rewind(f); uint8_t *p=malloc((size_t)n); if(!p||fread(p,1,(size_t)n,f)!=(size_t)n){free(p);p=NULL;} fclose(f); *size=p?(size_t)n:0; return p; }
int main(void) {
    static const char *names[] = {"assets/ttl1.grp","assets/ttl3.grp","assets/ttl2.grp"};
    static const uint64_t expected[] = {0x1182E5A740AFAE7BULL,0xA4B31E6E705A1097ULL,0x1C44F974C82A1B19ULL,0xEAAF226D3A11E2ECULL};
    uint8_t driver[0x10000]={0}, game[0x10000]={0}, table[0x10000]={0}, work[0x10000]={0}, vga[0x10000]={0}; int ok=1;
    size_t n=0; uint8_t *opdmo=read_file("assets/100opdmo.bin",&n);
    if(!opdmo || n>0xA004u) ok=0; else { memcpy(game+0x5FFC,opdmo,n); memcpy(table+0x5FFC,opdmo,n); } free(opdmo);
    uint8_t *planes[3]={0}; size_t plane_sizes[3]={0};
    for(size_t i=0;i<3;i++){ uint8_t *raw=read_file(names[i],&n); planes[i]=raw?grp_decode_6de1_planes(raw,n,&plane_sizes[i]):NULL; free(raw); if(!planes[i]) ok=0; }
    ok &= zeliard_mcga_disp_drv_seg_3_seed(vga,sizeof(vga))==0;
    if(planes[0]) memcpy(game+0x9000,planes[0],plane_sizes[0]);
    ok &= zeliard_mcga_gfx_update_da_stage(driver,sizeof(driver),game,sizeof(game),work,sizeof(work),0,0x0B48,0x3180,0x9000,vga,sizeof(vga),16)==0;
    memset(work,0,sizeof(work));
    if(planes[1]) memcpy(game+0x9000,planes[1],plane_sizes[1]);
    ok &= zeliard_mcga_disp_render_a_full(driver,sizeof(driver),game,sizeof(game),work,sizeof(work),0,0x070F,0x4170,0x9000,vga,sizeof(vga))==0;
    printf("base=%016llx visible=%016llx\n",(unsigned long long)fnv1a64(vga,sizeof(vga)),(unsigned long long)fnv1a64(vga,0xFA00));
    if(planes[2]) memcpy(game+0x4000,planes[2],plane_sizes[2]);
    for(size_t i=0;i<3;i++) free(planes[i]);
    ok &= zeliard_mcga_disp_tilemap_render(table,sizeof(table),0x912B,game,sizeof(game),game,sizeof(game))==0;
    printf("work=%016llx table=%02x\n",(unsigned long long)fnv1a64(game,sizeof(game)),game[0x912B]);
    uint8_t al=0xC7, ah=0; size_t sample=0;
    for(int i=1;i<=100;i++){ ok &= zeliard_mcga_disp_tile_render(driver,sizeof(driver),game,sizeof(game),al,vga,sizeof(vga))==0; ok &= zeliard_mcga_disp_tile_render(driver,sizeof(driver),game,sizeof(game),ah,vga,sizeof(vga))==0; if(i==1||i==10||i==11||i==50||i==100){uint64_t h=fnv1a64(vga,sizeof(vga)); uint64_t visible=fnv1a64(vga,0xFA00); printf("sweep %d=%016llx visible=%016llx\n",i,(unsigned long long)h,(unsigned long long)visible); if(i!=11) ok &= h==expected[sample++];} al=(uint8_t)(al-2); ah=(uint8_t)(ah+2); }
    printf("VERDICT: %s: C full title handoff matches MASM checkpoints\n",ok?"PASS":"FAIL"); return ok?0:1;
}
