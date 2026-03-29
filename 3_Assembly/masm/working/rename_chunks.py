#!/usr/bin/env python3
"""
Rename Zeliard tasm/working data chunk files to 8.3 format.
Convention: X##PPPPP.bin where X=zelres number, ##=2-digit chunk, PPPPP=5-char purpose.
Total name before extension = exactly 8 chars.
"""

import os
import sys

BASE = "C:/Projects/Zeliard/3_Assembly/tasm/working"

# Mapping: (subdir, old_name) -> new_name
# old_name is relative to the data/ folder
RENAMES = {
    # ---- zelres1 ----
    ("zelres1/data", "font.bin"):        "112FONTS.bin",
    ("zelres1/data", "image_13.grp"):    "113IMG13.bin",
    ("zelres1/data", "nec.grp"):         "114NECGP.bin",
    ("zelres1/data", "hou.grp"):         "115HOUGP.bin",
    ("zelres1/data", "sprites.bin"):     "116SPRTS.bin",
    ("zelres1/data", "dmaou.grp"):       "117DMAOU.bin",
    ("zelres1/data", "zopn.msd"):        "118ZOPNS.bin",
    ("zelres1/data", "ttl1.grp"):        "119TTL1G.bin",
    ("zelres1/data", "ttl2.grp"):        "120TTL2G.bin",
    ("zelres1/data", "ttl3.grp"):        "121TTL3G.bin",
    ("zelres1/data", "image_22.grp"):    "122IMG22.bin",
    ("zelres1/data", "waku.grp"):        "123WAKUG.bin",
    ("zelres1/data", "ame.grp"):         "125AMEGP.bin",
    ("zelres1/data", "hime.grp"):        "126HIMEG.bin",
    ("zelres1/data", "isi.grp"):         "127ISIGG.bin",
    ("zelres1/data", "oui.grp"):         "128OUIGP.bin",
    ("zelres1/data", "sei.grp"):         "129SEIGP.bin",
    ("zelres1/data", "yuu1.grp"):        "131YUU1G.bin",
    ("zelres1/data", "yuu2.grp"):        "132YUU2G.bin",
    ("zelres1/data", "yuu3.grp"):        "133YUU3G.bin",
    ("zelres1/data", "yuu4.grp"):        "134YUU4G.bin",
    ("zelres1/data", "yuup.grp"):        "135YUUPG.bin",
    ("zelres1/data", "maop.grp"):        "136MAOPG.bin",
    ("zelres1/data", "image_36.grp"):    "137SCENE.bin",
    # image_37.grp -> DELETE (duplicate of anim_table.bin = chunk_38)
    ("zelres1/data", "anim_table.bin"):  "138ANIMT.bin",
    ("zelres1/data", "zend.msd"):        "139ZENMS.bin",

    # ---- zelres2 ----
    # ("zelres2/data", "driver_table.bin"): "211DRVTB.bin",  # FIXED: was misclassified; now 211OMOYP.asm in code/
    ("zelres2/data", "sprites_18.bin"):   "218SPRTS.bin",
    ("zelres2/data", "sprites_19.bin"):   "219SPRTS.bin",
    ("zelres2/data", "sprites_20.bin"):   "220SPRTS.bin",
    ("zelres2/data", "sprites_21.bin"):   "221SPRTS.bin",
    ("zelres2/data", "sprites_22.bin"):   "222SPRTS.bin",
    ("zelres2/data", "sprites_23.bin"):   "223SPRTS.bin",
    ("zelres2/data", "sprites_24.bin"):   "224SPRTS.bin",
    ("zelres2/data", "sprites_25.bin"):   "225SPRTS.bin",
    ("zelres2/data", "sprites_26.bin"):   "226SPRTS.bin",
    ("zelres2/data", "waku.grp"):         "227WAKUG.bin",
    ("zelres2/data", "sei.grp"):          "228SEIGP.bin",
    ("zelres2/data", "yuup.grp"):         "229YUUPG.bin",
    ("zelres2/data", "seip.grp"):         "230SEIPG.bin",
    ("zelres2/data", "himp.grp"):         "231HIMPG.bin",
    ("zelres2/data", "new1.grp"):         "232NEW1G.bin",
    ("zelres2/data", "new2.grp"):         "233NEW2G.bin",
    ("zelres2/data", "ne80.grp"):         "234NE80G.bin",
    ("zelres2/data", "ne81.grp"):         "235NE81G.bin",
    ("zelres2/data", "dialogue.bin"):     "237DIALG.bin",
    ("zelres2/data", "npc_nec40.bin"):    "240NPCNC.bin",
    ("zelres2/data", "npc_dlg41.bin"):    "241NPCDL.bin",
    ("zelres2/data", "npc_nec42.bin"):    "242NPCNC.bin",
    ("zelres2/data", "npc_nec43.bin"):    "243NPCNC.bin",
    ("zelres2/data", "npc_nec44.bin"):    "244NPCNC.bin",
    ("zelres2/data", "npc_nec45.bin"):    "245NPCNC.bin",
    ("zelres2/data", "mgt1.msd"):         "246MGT1S.bin",
    ("zelres2/data", "mgt2.msd"):         "247MGT2S.bin",
    ("zelres2/data", "ugm1.msd"):         "248UGM1S.bin",
    ("zelres2/data", "ugm2.msd"):         "249UGM2S.bin",
    ("zelres2/data", "chunk_51.bin"):     "251SPRTL.bin",
    ("zelres2/data", "roka.grp"):         "252ROKAG.bin",
    ("zelres2/data", "image53.grp"):      "253IMG53.bin",
    ("zelres2/data", "dchr.grp"):         "254DCHRG.bin",
    ("zelres2/data", "encnt.grp"):        "255ENCNT.bin",
    ("zelres2/data", "image56.grp"):      "256IMG56.bin",

    # ---- zelres3 ----
    ("zelres3/data", "map_caverns.bin"):        "301MAPCA.bin",
    ("zelres3/data", "map_boss1_crab.bin"):     "302MAPBC.bin",
    ("zelres3/data", "map_deeper_caverns.bin"): "303MAPDC.bin",
    ("zelres3/data", "map_forest.bin"):         "304MAPFO.bin",
    ("zelres3/data", "map_boss2_octopus.bin"):  "305MAPBO.bin",
    ("zelres3/data", "map_boss3_chicken.bin"):  "306MAPBK.bin",
    ("zelres3/data", "map_ice_caverns.bin"):    "307MAPIC.bin",
    ("zelres3/data", "map_graveyard.bin"):      "308MAPGY.bin",
    ("zelres3/data", "map_gold_caverns.bin"):   "309MAPGC.bin",
    ("zelres3/data", "map_flame_caverns.bin"):  "310MAPFC.bin",
    ("zelres3/data", "map_muralla_town.bin"):   "311MAPMT.bin",
    ("zelres3/data", "map_satono_town.bin"):    "312MAPST.bin",
    ("zelres3/data", "map_bosque_town.bin"):    "313MAPBT.bin",
    ("zelres3/data", "map_helada_town.bin"):    "315MAPHT.bin",
    ("zelres3/data", "map_boss4_arena.bin"):    "317MAPA4.bin",
    ("zelres3/data", "map_boss5_arena.bin"):    "318MAPA5.bin",
    ("zelres3/data", "map_boss6_arena.bin"):    "319MAPA6.bin",
    ("zelres3/data", "dialogue_area1.bin"):     "321DLGA1.bin",
    ("zelres3/data", "dialogue_area2.bin"):     "323DLGA2.bin",
    ("zelres3/data", "dialogue_area3.bin"):     "324DLGA3.bin",
    ("zelres3/data", "dialogue_area4.bin"):     "325DLGA4.bin",
    ("zelres3/data", "dialogue_area5.bin"):     "327DLGA5.bin",
    ("zelres3/data", "dialogue_area6.bin"):     "328DLGA6.bin",
    ("zelres3/data", "dialogue_area7.bin"):     "329DLGA7.bin",
    ("zelres3/data", "dialogue_area8.bin"):     "330DLGA8.bin",
    ("zelres3/data", "dialogue_merchant.bin"):  "336DLGMR.bin",
    ("zelres3/data", "dialogue_extra.bin"):     "338DLGEX.bin",
    ("zelres3/data", "ending_sequence.bin"):    "339ENDNG.bin",
    ("zelres3/data", "lvl_code40.bin"):         "340LVLCD.bin",
    ("zelres3/data", "hut_code.bin"):           "341HUTCD.bin",
    ("zelres3/data", "calien.bin"):             "342ALIEN.bin",
    ("zelres3/data", "tilemap43.bin"):          "343TILMP.bin",
    ("zelres3/data", "tilemap44.bin"):          "344TILMP.bin",
    ("zelres3/data", "lvl_code45.bin"):         "345LVLCD.bin",
    ("zelres3/data", "lvl_code46.bin"):         "346LVLCD.bin",
    ("zelres3/data", "finalcvn.bin"):           "347FNLCV.bin",
    ("zelres3/data", "absorcvn.bin"):           "348ABSCV.bin",
    ("zelres3/data", "jashiin1.bin"):           "349JASH1.bin",
    ("zelres3/data", "jashiin2.bin"):           "350JASH2.bin",
    ("zelres3/data", "tileani.bin"):            "351TILAN.bin",
    ("zelres3/data", "tilepal.bin"):            "352TILPL.bin",
    ("zelres3/data", "dman.grp"):               "353DMANG.bin",
    ("zelres3/data", "sprite54.grp"):           "354SPRG5.bin",
    ("zelres3/data", "vgareg55.bin"):           "355VGARC.bin",
    ("zelres3/data", "enp1.grp"):               "357ENP1G.bin",
    ("zelres3/data", "enp2.grp"):               "358ENP2G.bin",
    ("zelres3/data", "enp3.grp"):               "359ENP3G.bin",
    ("zelres3/data", "enp4.grp"):               "360ENP4G.bin",
    ("zelres3/data", "enp5.grp"):               "361ENP5G.bin",
    ("zelres3/data", "enp6.grp"):               "362ENP6G.bin",
    ("zelres3/data", "enp7.grp"):               "363ENP7G.bin",
    ("zelres3/data", "enp8.grp"):               "364ENP8G.bin",
    ("zelres3/data", "crab.grp"):               "365CRABG.bin",
    ("zelres3/data", "tako.grp"):               "366TAKOG.bin",
    ("zelres3/data", "tori.grp"):               "367TORIC.bin",
    ("zelres3/data", "zela.grp"):               "368ZELAG.bin",
    ("zelres3/data", "meda.grp"):               "369MEDAG.bin",
    ("zelres3/data", "lega.grp"):               "370LEGAG.bin",
    ("zelres3/data", "drgn.grp"):               "371DRGNG.bin",
    ("zelres3/data", "akma.grp"):               "372AKMAG.bin",
    ("zelres3/data", "mao1.grp"):               "373MAO1G.bin",
    ("zelres3/data", "mpp1.grp"):               "374MPP1G.bin",
    ("zelres3/data", "mpp2.grp"):               "375MPP2G.bin",
    ("zelres3/data", "mpp3.grp"):               "376MPP3G.bin",
    ("zelres3/data", "mpp4.grp"):               "377MPP4G.bin",
    ("zelres3/data", "mpp5.grp"):               "378MPP5G.bin",
    ("zelres3/data", "mpp6.grp"):               "379MPP6G.bin",
    ("zelres3/data", "mpp7.grp"):               "380MPP7G.bin",
    ("zelres3/data", "mpp8.grp"):               "381MPP8G.bin",
    ("zelres3/data", "mpp9.grp"):               "382MPP9G.bin",
    ("zelres3/data", "mppa.grp"):               "383MPPAG.bin",
    ("zelres3/data", "mppb.grp"):               "384MPPBG.bin",
    ("zelres3/data", "mus1.msd"):               "385MUS1S.bin",
    ("zelres3/data", "mus2.msd"):               "386MUS2S.bin",
    ("zelres3/data", "mus3.msd"):               "387MUS3S.bin",
    ("zelres3/data", "mus4.msd"):               "388MUS4S.bin",
    ("zelres3/data", "mus5.msd"):               "389MUS5S.bin",
    ("zelres3/data", "mus6.msd"):               "390MUS6S.bin",
    ("zelres3/data", "mus7.msd"):               "391MUS7S.bin",
    ("zelres3/data", "mus8.msd"):               "392MUS8S.bin",
    ("zelres3/data", "mbos.msd"):               "393MBOSS.bin",
    ("zelres3/data", "mfan.msd"):               "394MFANS.bin",
    ("zelres3/data", "mmao.msd"):               "395MMAOS.bin",
}

# Files to delete (duplicates)
DELETES = [
    ("zelres1/data", "image_37.grp"),
]

errors = []
renamed = []
skipped = []
deleted = []

# Validate all target names are exactly 8 chars before extension
print("=== Validating target names ===")
bad_names = []
for (subdir, old), new in RENAMES.items():
    stem = new.rsplit('.', 1)[0]
    if len(stem) != 8:
        bad_names.append(f"  BAD: {new!r} -> stem={stem!r} len={len(stem)}")
if bad_names:
    print("ERRORS - these target names are not 8 chars:")
    for b in bad_names:
        print(b)
    sys.exit(1)
else:
    print(f"  All {len(RENAMES)} target names validated as 8 chars. OK.")

print()

# Process deletes
print("=== Deletions ===")
for (subdir, fname) in DELETES:
    src = os.path.join(BASE, subdir, fname)
    if os.path.exists(src):
        os.remove(src)
        deleted.append(f"  DELETED: {subdir}/{fname}")
        print(f"  DELETED: {subdir}/{fname}")
    else:
        msg = f"  SKIP (not found): {subdir}/{fname}"
        skipped.append(msg)
        print(msg)

print()

# Process renames
print("=== Renames ===")
for (subdir, old), new in RENAMES.items():
    src = os.path.join(BASE, subdir, old)
    dst = os.path.join(BASE, subdir, new)
    if not os.path.exists(src):
        msg = f"  SKIP (src not found): {subdir}/{old}"
        skipped.append(msg)
        print(msg)
        continue
    if os.path.exists(dst):
        # Same file on case-insensitive FS? Check if it's a no-op rename
        if os.path.abspath(src).lower() == os.path.abspath(dst).lower() and src != dst:
            # Just rename via temp to be safe, but in practice new names differ enough
            pass
        else:
            msg = f"  SKIP (dst exists): {subdir}/{old} -> {new}"
            skipped.append(msg)
            print(msg)
            continue
    os.rename(src, dst)
    renamed.append(f"  {subdir}/{old}  ->  {new}")
    print(f"  {subdir}/{old}  ->  {new}")

print()
print("=== Summary ===")
print(f"  Renamed:  {len(renamed)}")
print(f"  Deleted:  {len(deleted)}")
print(f"  Skipped:  {len(skipped)}")
if skipped:
    print("  Skipped details:")
    for s in skipped:
        print(s)
if errors:
    print("  Errors:")
    for e in errors:
        print(e)
