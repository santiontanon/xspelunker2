    include "constants.asm"
    include "assert.asm"

stack: equ #f380
stack_size: equ 128

;-----------------------------------------------
; X-Spelunker 2

;-----------------------------------------------
; pages:
; 0: #4000 - #7fff: core code
; 1: #8000 - #bfff: pcg code (area, room)
; 2: #8000 - #bfff: tile gfx, pyramid tiles, in-game message
; 3: #8000 - #bfff: sprites, map, additional tiles, enemy tiles
; 4: #8000 - #bfff: jungle, pyramid chunks, calendar event explosion tiles
; 5: #8000 - #bfff: text, additional states code (options, dialog, etc.)
; 6: #8000 - #bfff: bosses general + 1, 2, 3, 5 code
; 7: #8000 - #bfff: tablets, letters, text2, interarea
; 8: #8000 - #bfff: enemies
; 9: #8000 - #bfff: npc interactions, edge collisions, xibalba chunks
; 10: #8000 - #bfff: text3
; 11: #8000 - #bfff: pcg code (world), story, gamestart, game over
; 12: #8000 - #bfff: bosses gfx, teleporter room
; 13: #8000 - #bfff: caves chunks, jungle tiles, xibalba tiles, atlantis tiles
; 14: #8000 - #bfff: inventory tiles, maya riddle tiles, puzzleboxes, boss 4, calendar events
; 15: #8000 - #bfff: music
; 16: #8000 - #bfff: atlantis chunks, pcg enemies, area collision tables, teleporter room tiles
; 17: #8000 - #bfff: boss 5, gameover/title/brain games states
; 18: #8000 - #bfff: endings
; 19: #8000 - #bfff: guard-statues, astronomy room, temple of poseidon, mars chunks, moon tiles
; 20: #8000 - #bfff: moon tiles/chunks, pcg-prettify, tile animations, more sprite enemies
; 21: #8000 - #bfff: forge puzzle, mars robot puzzle, calendar tablet, boss6
; 22: #8000 - #bfff: text4
; 23: #8000 - #bfff: firestone forge, shop tiles, boss 7
; 24: #8000 - #bfff: boss 8


CORE_CODE_PAGE: equ 0
BRAINGAMES_PAGE: equ 17
BRAINGAMES_TILES_PAGE: equ 3
TITLE_PAGE: equ 17
TITLE_TILES_PAGE: equ 3
GAMESTART_PAGE: equ 11
STORY_PAGE: equ 11
GAME_OVER_PAGE: equ 17
INTERAREA_PAGE: equ 7
TILES_PAGE: equ 2
TILES_HUD_PAGE: equ 17
TILES_MAYA_RIDDLE_PAGE: equ 14
TILES_INVENTORY_PAGE: equ 14
TILES_PUZZLEBOX_PAGE equ 14
TILES_CALENDAR_EXPLOSION_PAGE: equ 4
TILE_ANIMATIONS_PAGE: equ 20
SPRITES_PAGE: equ 3
MAP_PAGE: equ 3
ENEMY_TILES_PAGE: equ 3
ENEMY_SPRITES_PAGE: equ 8
XIBALBA_ENEMY_SPRITES_PAGE: equ 23
ATLANTIS_ENEMY_SPRITES_PAGE: equ 20
MARS_ENEMY_SPRITES_PAGE: equ 20
MOON_ENEMY_SPRITES_PAGE: equ 20
YES_NO_DIALOG_PAGE: equ 5
TEXT_PAGE: equ 5
TEXT_PAGE2: equ 7
TEXT_PAGE3: equ 10
TEXT_PAGE4: equ 22
BOSS_PAGE: equ 6
BOSS_1_ROOM_PAGE: equ 21
BOSS_2_ROOM_PAGE: equ 21
BOSS_3_ROOM_PAGE: equ 21
BOSS_4_ROOM_PAGE: equ 21
BOSS_5_ROOM_PAGE: equ 21
BOSS_4_PAGE: equ 14
BOSS_5_PAGE: equ 17
BOSS_6_PAGE: equ 21
BOSS_7_PAGE: equ 23
BOSS_8_PAGE: equ 24
BOSS_GFX_PAGE: equ 12
BOSS_SPRITES_PAGE: equ 12
CALENDAR_EVENTS_PAGE: equ 14  ; ambush code
CALENDAR_EVENTS_PAGE2: equ 13  ; elain scene code
ENDING_PAGE: equ 18
TABLET_LETTER_PAGE: equ 7
ENEMIES_PAGE: equ 8
SHOP_TILES_PAGE: equ 23
NPCS_PAGE: equ 9
AREA_COLLISION_TABLES_PAGE: equ 16
AREA_COLLISION_TABLE_FIRESTONE_FORGE_PAGE: equ 17
CHUNK_EDGECOLLISIONS_PAGE: equ 9
MUSIC_PAGE: equ 15
CALENDAR_TABLET_PAGE: equ 21

PCG_PAGE: equ 1
PCG_PAGE_PRETTIFY: equ 20
PCG_PAGE_WORLD: equ 11
PCG_PAGE_ENEMIES: equ 16

JUNGLE_TILES_PAGE: equ 13
PYRAMID_TILES_PAGE: equ 2
CAVES_TILES_PAGE: equ 13
XIBALBA_TILES_PAGE: equ 13
ATLANTIS_TILES_PAGE: equ 13
MARS_TILES_PAGE: equ 19
MOON_TILES_PAGE: equ 19
CHUNKS_JUNGLE_PAGE: equ 4
CHUNKS_PYRAMID_PAGE: equ 4
CHUNKS_CAVES_PAGE: equ 13
CHUNKS_XIBALBA_PAGE: equ 9
CHUNKS_ATLANTIS_PAGE: equ 16
CHUNKS_MARS_PAGE: equ 19
CHUNKS_MOON_PAGE: equ 20
TELEPORTER_ROOM_PAGE: equ 13
TELEPORTER_ROOM_TILES_PAGE: equ 16
TEMPLE_OF_POSEIDON_PAGE: equ 19
EIGHT_BRIDGE_ROOM_PAGE: equ 9
ASTRONOMY_ROOM_PAGE: equ 19
GUARD_STATUE_ROOM_PAGE: equ 19
FIRESTONE_FORGE_ROOM_PAGE: equ 23
FORGE_PUZZLE_PAGE: equ 21
MARS_ROBOT_PUZZLE_PAGE: equ 21


;-----------------------------------------------
; PAGE 0:
; mdl:page 0
    org #4000
start_of_page_0:

;-----------------------------------------------
    db "AB"     ; ROM signature
    dw Execute  ; start address
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
;-----------------------------------------------

;-----------------------------------------------
; Code that gets executed when the game starts
Execute:
    di
    ; init the stack:
    ld sp, stack
    ; reset some interrupts to make sure it runs in some MSX computers 
    ; with disk controllers installed in some interrupt handlers
    ld a, RET_OPCODE
    ld (HKEY), a
    ld (TIMI), a
    ei

    ; clear the whole RAM space to prevent any potential issues (not really necessary, but just in case):
    ld hl, RAM
    ld bc, (end_of_ram - RAM) - 1
    call clear_memory    

    call SETPAGES32K

    call CheckIf60Hz  ; note: this must be called before turning turbo mode on.
    ld (isComputer50HzOr60Hz), a ; 0: 50Hz, 1: 60Hz

    ; Silence, init keyboard, and clear config:
    xor a
    ld (CLIKSW), a
    ; Change background colors:
    ld (BAKCLR), a
    ld (BDRCLR), a
    call CHGCLR

    ld a, 2  ; Change screen mode
    call CHGMOD

    xor a
    ld (current_megarom_page_in_4000), a
    inc a
    ld (current_megarom_page_in_8000), a

    ; 16x16 sprites:
    ld bc, #e201  ; write #e2 in VDP register #01 (activate sprites, generate interrupts, 16x16 sprites with no magnification)
    call WRTVDP

    ld hl, start_of_interrupt_code_rom
    ld de, start_of_interrupt_code_ram
    ld bc, end_of_interrupt_code_rom - start_of_interrupt_code_rom
    ldir

    call stop_music
    call setup_custom_interrupt

    ; initial default random seed:
    ld hl, #aaaa
    ld (rng_seed1), hl
    ld hl, #bbbb
    ld (rng_seed2), hl

    ld hl, state_options_reset
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld hl, current_world__name_rom
    ld de, current_world__name
    ld bc, 16
    ldir

    ld hl, state_braingames
    ld a, BRAINGAMES_PAGE
    jp jp_to_hl_in_page_a_8000

;     ld hl, state_story
;     ld a, STORY_PAGE
;     jp jp_to_hl_in_page_a_8000

;     ld hl, ending_C
;     ld a, ENDING_PAGE
;     jp jp_to_hl_in_page_a_8000

;     ld hl, global_state__objects + TAG_FIRESTONE_FORGE
;     ld (hl), 1
;     ld hl, ending_C_plus
;     ld a, ENDING_PAGE
;     jp jp_to_hl_in_page_a_8000

;     ld hl, ending_B
;     ld a, ENDING_PAGE
;     jp jp_to_hl_in_page_a_8000

;     ld hl, global_state__objects + TAG_FIRESTONE_FORGE
;     ld (hl), 1
;     ld hl, ending_B_plus
;     ld a, ENDING_PAGE
;     jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
; Loads the interrupt hook for playing music:
setup_custom_interrupt:
    ld  a, JP_OPCODE  ; NEW HOOK SET
    di
        ld (TIMI), a
        ld hl, start_of_interrupt_code_ram
        ld (TIMI + 1), hl
    ei
    ret


;-----------------------------------------------
; 9 bytes total
; input:
; - hl: target address
; - a: target page
jp_to_hl_in_page_c_8000:
    ld a, c
jp_to_hl_in_page_a_8000:
    di  ; 1 byte
    ld (current_megarom_page_in_8000), a  ; 3 bytes
    ld (#7000), a  ; 3 bytes
    ei  ; 1 byte
jp_to_hl:
    jp hl  ; 1 byte


;-----------------------------------------------
; 28 bytes total
; input:
; - hl: target address
; - c: target page
call_hl_in_page_c_8000:
    ld a, (current_megarom_page_in_8000)  ; 3 bytes
    push af  ; 1 byte
        ld a, c  ; 1 byte
        di  ; 1 byte
        ld (#7000), a  ; 3 bytes
        ld (current_megarom_page_in_8000), a  ; 3 bytes
        ei  ; 1 byte
        call jp_to_hl
    ex af, af'  ; preserve the return af of the function we called
        pop af  ; 1 byte
        di  ; 1 byte
        ld (#7000), a  ; 3 bytes
        ld (current_megarom_page_in_8000), a  ; 3 bytes
        ei
    ex af, af'
    ret  ; 1 byte


;-----------------------------------------------
; 28 bytes total
; input:
; - hl: target address
; - e: target page
call_hl_in_page_e_8000:
    ld a, (current_megarom_page_in_8000)  ; 3 bytes
    push af  ; 1 byte
        ld a, e  ; 1 byte
        di  ; 1 byte
        ld (#7000), a  ; 3 bytes
        ld (current_megarom_page_in_8000), a  ; 3 bytes
        ei  ; 1 byte
        call jp_to_hl
    ex af, af'  ; preserve the return af of the function we called
        pop af  ; 1 byte
        di  ; 1 byte
        ld (#7000), a  ; 3 bytes
        ld (current_megarom_page_in_8000), a  ; 3 bytes
        ei
    ex af, af'
    ret  ; 1 byte


;-----------------------------------------------
; input:
; - de: ptr to text to copy
copy_text_from_another_page_to_ix:
    push ix
    pop hl
    jr copy_text_from_another_page_to_hl
copy_text_from_another_page:
    ld hl, buffer_4096
copy_text_from_another_page_to_hl:
    ex de, hl
    ld c, (hl)
    inc c
    ld b, 0
    ldir
    ret


;-----------------------------------------------
; input:
; - hl: sentence to draw (first byte is the length)
; - de: target VRAM address (ptr to CHRTBL2)
; - iyl: color (attribute byte)
; - iyh: pixel to start from (128 to start in pixel 0)
; - b: expected width in tiles
draw_sentence_to_vdp_from_another_page:
    ld a, (current_megarom_page_in_8000)  ; 3 bytes
    push af  ; 1 byte
        di  ; 1 byte
        ld a, TEXT_PAGE
        ld (#7000), a  ; 3 bytes
        ld (current_megarom_page_in_8000), a  ; 3 bytes
        ei  ; 1 byte
        call draw_sentence_to_vdp_clearing_text_buffer
    pop af
    di  ; 1 byte
    ld (#7000), a  ; 3 bytes
    ld (current_megarom_page_in_8000), a  ; 3 bytes
    ei  
    ret


    include "interrupt.asm"


;-----------------------------------------------
; additional assembler files source code:
    ; General utility:
    include "auxiliar.asm"
    include "dzx0.asm"
    include "gfx.asm"
    include "input.asm"
    include "sound.asm"
    include "collision.asm"
    include "rooms.asm"
    include "scroll.asm"
    include "player.asm"
    include "sprite-objects.asm"
    include "trial-fns.asm"
    include "hud.asm"

    include "state-play.asm"

    ; boss utility (here, so it can easily be used by all boasses)
    include "boss-bullet-patterns.asm"

end_of_code:


in_game_message_tiles:
    ds 32, 1
REPT 6*32, V
    db V+64
ENDR
    ds 32, 1


current_world__name_rom:
    ; 2XSPELUNKER
    db 29, 23, 18, 15
    db  4, 11, 20, 13
    db 10,  4, 17, 26
    db 26, 26, 26, 26


end_of_page_0:
    ds #8000-$


;-----------------------------------------------
; PAGE 1:
; mdl:page 1
    org #8000
start_of_page_1:

    include "pcg-areas.asm"
    include "pcg-rooms.asm"

    include "autogenerated/jungle-chunk-tags.asm"
    include "autogenerated/pyramid-chunk-tags.asm"
    include "autogenerated/caves-chunk-tags.asm"
    include "autogenerated/xibalba-chunk-tags.asm"
    include "autogenerated/atlantis-chunk-tags.asm"
    include "autogenerated/mars-chunk-tags.asm"
    include "autogenerated/moon-chunk-tags.asm"

pyramid_chunk_bg_bank_ptrs:
    dw pyramid_chunk_bg_bank_0_zx0

pyramid_chunk_fg_bank_ptrs:
    dw pyramid_chunk_fg_bank_0_zx0
    dw pyramid_chunk_fg_bank_1_zx0
    dw pyramid_chunk_fg_bank_2_zx0
    dw pyramid_chunk_fg_bank_3_zx0
    dw pyramid_chunk_fg_bank_4_zx0
    dw pyramid_chunk_fg_bank_5_zx0
    dw pyramid_chunk_fg_bank_6_zx0
    dw pyramid_chunk_fg_bank_7_zx0
    dw pyramid_chunk_fg_bank_8_zx0
    dw pyramid_chunk_fg_bank_9_zx0
    dw pyramid_chunk_fg_bank_10_zx0
    dw pyramid_chunk_fg_bank_11_zx0
    dw pyramid_chunk_fg_bank_12_zx0
pyramid_chunk_fg_bank_ptrs_end:

jungle_chunk_fg_bank_ptrs:
    dw jungle_chunk_fg_bank_0_zx0
    dw jungle_chunk_fg_bank_1_zx0
    dw jungle_chunk_fg_bank_2_zx0
    dw jungle_chunk_fg_bank_3_zx0
    dw jungle_chunk_fg_bank_4_zx0
    dw jungle_chunk_fg_bank_5_zx0
    dw jungle_chunk_fg_bank_6_zx0
    dw jungle_chunk_fg_bank_7_zx0
    dw jungle_chunk_fg_bank_8_zx0
    dw jungle_chunk_fg_bank_9_zx0
jungle_chunk_fg_bank_ptrs_end:

caves_chunk_bg_bank_ptrs:
    dw caves_chunk_bg_bank_0_zx0

caves_chunk_fg_bank_ptrs:
    dw caves_chunk_fg_bank_0_zx0
    dw caves_chunk_fg_bank_1_zx0
    dw caves_chunk_fg_bank_2_zx0
    dw caves_chunk_fg_bank_3_zx0
    dw caves_chunk_fg_bank_4_zx0
    dw caves_chunk_fg_bank_5_zx0
    dw caves_chunk_fg_bank_6_zx0
    dw caves_chunk_fg_bank_7_zx0
    dw caves_chunk_fg_bank_8_zx0
    dw caves_chunk_fg_bank_9_zx0
    dw caves_chunk_fg_bank_10_zx0
    dw caves_chunk_fg_bank_11_zx0
    dw caves_chunk_fg_bank_12_zx0
    dw caves_chunk_fg_bank_13_zx0
    dw caves_chunk_fg_bank_14_zx0
caves_chunk_fg_bank_ptrs_end:

xibalba_chunk_bg_bank_ptrs:
    dw xibalba_chunk_bg_bank_0_zx0

xibalba_chunk_fg_bank_ptrs:
    dw xibalba_chunk_fg_bank_0_zx0
    dw xibalba_chunk_fg_bank_1_zx0
    dw xibalba_chunk_fg_bank_2_zx0
    dw xibalba_chunk_fg_bank_3_zx0
    dw xibalba_chunk_fg_bank_4_zx0
    dw xibalba_chunk_fg_bank_5_zx0
    dw xibalba_chunk_fg_bank_6_zx0
    dw xibalba_chunk_fg_bank_7_zx0
    dw xibalba_chunk_fg_bank_8_zx0
    dw xibalba_chunk_fg_bank_9_zx0
    dw xibalba_chunk_fg_bank_10_zx0
    dw xibalba_chunk_fg_bank_11_zx0
    dw xibalba_chunk_fg_bank_12_zx0
xibalba_chunk_fg_bank_ptrs_end:

atlantis_chunk_bg_bank_ptrs:
    dw atlantis_chunk_bg_bank_0_zx0

atlantis_chunk_fg_bank_ptrs:
    dw atlantis_chunk_fg_bank_0_zx0
    dw atlantis_chunk_fg_bank_1_zx0
    dw atlantis_chunk_fg_bank_2_zx0
    dw atlantis_chunk_fg_bank_3_zx0
    dw atlantis_chunk_fg_bank_4_zx0
    dw atlantis_chunk_fg_bank_5_zx0
    dw atlantis_chunk_fg_bank_6_zx0
    dw atlantis_chunk_fg_bank_7_zx0
    dw atlantis_chunk_fg_bank_8_zx0
    dw atlantis_chunk_fg_bank_9_zx0
atlantis_chunk_fg_bank_ptrs_end:

mars_chunk_bg_bank_ptrs:
    dw mars_chunk_bg_bank_0_zx0

mars_chunk_fg_bank_ptrs:
    dw mars_chunk_fg_bank_0_zx0
    dw mars_chunk_fg_bank_1_zx0
    dw mars_chunk_fg_bank_2_zx0
    dw mars_chunk_fg_bank_3_zx0
    dw mars_chunk_fg_bank_4_zx0
    dw mars_chunk_fg_bank_5_zx0
    dw mars_chunk_fg_bank_6_zx0
    dw mars_chunk_fg_bank_7_zx0
    dw mars_chunk_fg_bank_8_zx0
    dw mars_chunk_fg_bank_9_zx0
    dw mars_chunk_fg_bank_10_zx0
mars_chunk_fg_bank_ptrs_end:

moon_chunk_bg_bank_ptrs:
    dw moon_chunk_bg_bank_0_zx0

moon_chunk_fg_bank_ptrs:
    dw moon_chunk_fg_bank_0_zx0
    dw moon_chunk_fg_bank_1_zx0
    dw moon_chunk_fg_bank_2_zx0
    dw moon_chunk_fg_bank_3_zx0
    dw moon_chunk_fg_bank_4_zx0
    dw moon_chunk_fg_bank_5_zx0
    dw moon_chunk_fg_bank_6_zx0
    dw moon_chunk_fg_bank_7_zx0
    dw moon_chunk_fg_bank_8_zx0
moon_chunk_fg_bank_ptrs_end:

end_of_page_1:
    ds #c000-$


;-----------------------------------------------
; PAGE 2: 
; mdl:page 2
    org #8000
start_of_page_2:

tiles_pyramid_zx0:
    incbin "autogenerated/tiles-pyramid.zx0"
tiles_calendar_zx0:
    incbin "autogenerated/tiles-calendar.zx0"

object_tiles_zx0:
    incbin "autogenerated/tiles-objects.zx0"
object_large_tiles_zx0:
    incbin "autogenerated/tiles-large-objects.zx0"
object_large_tiles2_zx0:
    incbin "autogenerated/tiles-large-objects2.zx0"

    include "tile-objects.asm"
    include "tile-enemies.asm"

puzzle3_msg_data1:
    db #48,#61,#76,#65,#20,#79,#6f,#75,#20,#66,#6f,#75,#6e,#64,#20,#77
    db #68,#61,#74,#20,#69,#73,#20,#74,#68,#61,#74,#20,#27,#74,#68,#69
    db #6e,#67,#27,#20,#79,#6f,#75,#20,#63,#61,#6e,#20,#64,#6f,#3f,#20
    db #52,#65,#64,#65,#66,#69,#6e,#65,#20,#74,#68,#65,#20,#66,#6f,#75
    db #72,#20,#61,#63,#74,#69,#6f,#6e,#20,#6b,#65,#79,#73,#20,#74,#6f
    db #20,#54,#2c,#20,#41,#2c,#20,#4c,#2c,#20,#4b,#2c,#20,#61,#6e,#64
    db #20,#69,#6e,#74,#65,#72,#61,#63,#74,#20,#69,#6e,#20,#74,#68,#65
    db #20,#61,#70,#70,#72,#6f,#70,#72,#69,#61,#74,#65,#20,#70,#6c,#61
    db #63,#65,#2e,#2e,#2e

end_of_page_2:
    ds #c000-$    


;-----------------------------------------------
; PAGE 3: sprites, map, letter/tablet tiles
; mdl:page 3
    org #8000
start_of_page_3:

braingames_tiles_zx0:
    incbin "autogenerated/braingames.zx0"
title_tiles_zx0:
    incbin "autogenerated/title-tiles.zx0"

IF COLLISION_DEBUG = 1
player_sprites_bin:
    incbin "autogenerated/player-sprites-debug.bin"
player_sprites_left_bin:
    incbin "autogenerated/player-sprites-debug-left.bin"
ELSE
player_sprites_bin:
    incbin "autogenerated/player-sprites.bin"
player_sprites_left_bin:
    incbin "autogenerated/player-sprites-left.bin"
ENDIF

player_weapon_sprites_bin:
    incbin "autogenerated/player-weapon-sprites.bin"
player_weapon_sprites_left_bin:
    incbin "autogenerated/player-weapon-sprites-left.bin"

pyramid_object_sprites_bin:
    incbin "autogenerated/pyramid-sprites.bin"
pyramid_object_sprites_bin_end:

dialog_sprites_bin:
    incbin "autogenerated/dialog-sprites.bin"
dialog_sprites_bin_end:

atlantis_sentinel_sprites_bin:
    incbin "autogenerated/enemy-sprites-atlantis-sentinel.bin"

    include "sprites.asm"

    include "map.asm"

map_tiles_bank1_zx0:
    incbin "autogenerated/map-tiles-unique-bank1.zx0"
map_tiles_bank2_zx0:
    incbin "autogenerated/map-tiles-unique-bank2.zx0"
map_tiles_bank3_zx0:
    incbin "autogenerated/map-tiles-unique-bank3.zx0"

map_nametable_piece0_zx0:
    incbin "autogenerated/map-nametable-0.zx0"
map_nametable_piece1_zx0:
    incbin "autogenerated/map-nametable-1.zx0"
map_nametable_piece2_zx0:
    incbin "autogenerated/map-nametable-2.zx0"
map_nametable_piece3_zx0:
    incbin "autogenerated/map-nametable-3.zx0"
map_nametable_piece4_zx0:
    incbin "autogenerated/map-nametable-4.zx0"
map_nametable_piece5_zx0:
    incbin "autogenerated/map-nametable-5.zx0"
map_nametable_piece6_zx0:
    incbin "autogenerated/map-nametable-6.zx0"
map_nametable_piece7_zx0:
    incbin "autogenerated/map-nametable-7.zx0"

power_stones_tiles_zx0:
    incbin "autogenerated/power-stone-tiles.zx0"
power_stones_nametable_zx0:
    incbin "autogenerated/power-stone-nametable.zx0"


enemy_carnivoreplant_tiles_zx0:
    incbin "autogenerated/enemy-carnivoreplant-tiles.zx0"

enemy_ant_colony_tiles_zx0:
enemy_bee_hive_tiles_zx0:
    incbin "autogenerated/enemy-ants-bees-tiles.zx0"

enemy_stone_owl_tiles_zx0:
    incbin "autogenerated/enemy-owl-tiles.zx0"

enemy_sentinel_tiles_zx0:
    incbin "autogenerated/enemy-sentinel-tiles.zx0"

mars_walker_tiles_right_zx0:
    incbin "autogenerated/enemy-walker-right-tiles.zx0"
mars_walker_tiles_left_zx0:
    incbin "autogenerated/enemy-walker-left-tiles.zx0"

moon_large_mushroom_tiles_zx0:
    incbin "autogenerated/enemy-big-mushroom-tiles.zx0"


start_room_zx0:
    incbin "autogenerated/start-room.zx0"


puzzle3_msg_data2:
; size in bytes: 220
    db #41,#68,#2c,#20,#79,#6f,#75,#20,#66,#6f,#75,#6e,#64,#20,#74,#68
    db #69,#73,#20,#6f,#6e,#65,#20,#74,#6f,#6f,#3f,#20,#57,#65,#6c,#6c
    db #2e,#2e,#2e,#20,#6c,#65,#74,#20,#6d,#65,#20,#74,#65,#6c,#6c,#20
    db #79,#6f,#75,#20,#61,#20,#73,#65,#63,#72,#65,#74,#2e,#20,#49,#6e
    db #20,#74,#68,#69,#73,#20,#67,#61,#6d,#65,#2c,#20,#74,#68,#65,#72
    db #65,#20,#69,#73,#20,#61,#20,#27,#74,#68,#69,#6e,#67,#27,#20,#79
    db #6f,#75,#20,#63,#61,#6e,#20,#64,#6f,#2e,#2e,#2e,#20,#61,#20,#77
    db #61,#79,#20,#74,#6f,#20,#27,#74,#61,#6c,#6b,#27,#20,#74,#6f,#20
    db #74,#68,#6f,#73,#65,#20,#77,#68,#6f,#20,#77,#6f,#75,#6c,#64,#20
    db #6c,#69,#73,#74,#65,#6e,#2e,#20,#42,#75,#74,#20,#79,#6f,#75,#20
    db #77,#69,#6c,#6c,#20,#68,#61,#76,#65,#20,#74,#6f,#20,#73,#65,#61
    db #72,#63,#68,#20,#73,#6f,#6d,#65,#20,#6d,#6f,#72,#65,#2e,#2e,#2e
    db #20,#6d,#61,#79,#62,#65,#20,#79,#6f,#75,#20,#66,#6f,#75,#6e,#64
    db #20,#69,#74,#20,#61,#6c,#72,#65,#61,#64,#79,#3f

end_of_page_3:
    ds #c000-$   


;-----------------------------------------------
; PAGE 4: jungle, pyramid chunks
; mdl:page 4
    org #8000
start_of_page_4:

jungle_chunk_fg_bank_0_zx0:
    incbin "autogenerated/chunks/jungle-fg-0.zx0"
jungle_chunk_fg_bank_1_zx0:
    incbin "autogenerated/chunks/jungle-fg-1.zx0"
jungle_chunk_fg_bank_2_zx0:
    incbin "autogenerated/chunks/jungle-fg-2.zx0"
jungle_chunk_fg_bank_3_zx0:
    incbin "autogenerated/chunks/jungle-fg-3.zx0"
jungle_chunk_fg_bank_4_zx0:
    incbin "autogenerated/chunks/jungle-fg-4.zx0"
jungle_chunk_fg_bank_5_zx0:
    incbin "autogenerated/chunks/jungle-fg-5.zx0"
jungle_chunk_fg_bank_6_zx0:
    incbin "autogenerated/chunks/jungle-fg-6.zx0"
jungle_chunk_fg_bank_7_zx0:
    incbin "autogenerated/chunks/jungle-fg-7.zx0"
jungle_chunk_fg_bank_8_zx0:
    incbin "autogenerated/chunks/jungle-fg-8.zx0"
jungle_chunk_fg_bank_9_zx0:
    incbin "autogenerated/chunks/jungle-fg-9.zx0"


pyramid_chunk_bg_bank_0_zx0:
    incbin "autogenerated/chunks/pyramid-bg-0.zx0"

pyramid_chunk_fg_bank_0_zx0:
    incbin "autogenerated/chunks/pyramid-fg-0.zx0"
pyramid_chunk_fg_bank_1_zx0:
    incbin "autogenerated/chunks/pyramid-fg-1.zx0"
pyramid_chunk_fg_bank_2_zx0:
    incbin "autogenerated/chunks/pyramid-fg-2.zx0"
pyramid_chunk_fg_bank_3_zx0:
    incbin "autogenerated/chunks/pyramid-fg-3.zx0"
pyramid_chunk_fg_bank_4_zx0:
    incbin "autogenerated/chunks/pyramid-fg-4.zx0"
pyramid_chunk_fg_bank_5_zx0:
    incbin "autogenerated/chunks/pyramid-fg-5.zx0"
pyramid_chunk_fg_bank_6_zx0:
    incbin "autogenerated/chunks/pyramid-fg-6.zx0"
pyramid_chunk_fg_bank_7_zx0:
    incbin "autogenerated/chunks/pyramid-fg-7.zx0"
pyramid_chunk_fg_bank_8_zx0:
    incbin "autogenerated/chunks/pyramid-fg-8.zx0"
pyramid_chunk_fg_bank_9_zx0:
    incbin "autogenerated/chunks/pyramid-fg-9.zx0"
pyramid_chunk_fg_bank_10_zx0:
    incbin "autogenerated/chunks/pyramid-fg-10.zx0"
pyramid_chunk_fg_bank_11_zx0:
    incbin "autogenerated/chunks/pyramid-fg-11.zx0"
pyramid_chunk_fg_bank_12_zx0:
    incbin "autogenerated/chunks/pyramid-fg-12.zx0"

calendar_room_zx0:
    incbin "autogenerated/calendar-room.zx0"

calendar_explosion_tiles_zx0:
    incbin "autogenerated/calendar-explosion-tiles.zx0"

end_of_page_4:
    ds #c000-$    


;-----------------------------------------------
; PAGE 5: TEXT, INVENTORY, MENUS
; mdl:page 5
    org #8000
start_of_page_5:

    include "autogenerated/text-data.asm"
    include "text.asm"

    include "state-inventory.asm"
    include "state-options.asm"
    include "state-yesno-dialog.asm"
    include "in-game-message.asm"

font_bin:
    incbin "autogenerated/font.bin"

text_numbers:
    db 22, 24, 26, 28, 30, 32, 35, 37, 39, 41

end_of_page_5:
    ds #c000-$


;-----------------------------------------------
; PAGE 6: bosses
; mdl:page 6
    org #8000
start_of_page_6:

    include "bosses.asm"
    include "boss1.asm"
    include "boss2.asm"
    include "boss3.asm"

    include "boss5-nametables.asm"  ; here since the drawing routines are in this page
                                    ; if moved, also move "player_weapon_hitbox_check_boss__boss5_scylla_hit_tentacle"
    include "boss6-nametables.asm"  ; here since the drawing routines are in this page
    include "boss7-nametables.asm"  ; here since the drawing routines are in this page


end_of_page_6:
    ds #c000-$


;-----------------------------------------------
; PAGE 7: tablets, letters
; mdl:page 7
    org #8000
start_of_page_7:

    include "autogenerated/text-data-page7.asm"

tablet_tiles_zx0:
    incbin "autogenerated/tablet-tiles.zx0"
tablet_nametable_zx0:
    incbin "autogenerated/tablet-nametable.zx0"

tablet_combination1_tiles_zx0:
    incbin "autogenerated/tablet-combination1-tiles.zx0"
tablet_combination2_tiles_zx0:
    incbin "autogenerated/tablet-combination2-tiles.zx0"
tablet_combination3_tiles_zx0:
    incbin "autogenerated/tablet-combination3-tiles.zx0"

tablet_maya1_tiles_zx0:
    incbin "autogenerated/tablet-maya1-tiles.zx0"
tablet_maya1_nametable_zx0:
    incbin "autogenerated/tablet-maya1-nametable.zx0"

tablet_maya2_tiles_zx0:
    incbin "autogenerated/tablet-maya2-tiles.zx0"
tablet_maya2_nametable_zx0:
    incbin "autogenerated/tablet-maya2-nametable.zx0"

tablet_maya3_tiles_zx0:
    incbin "autogenerated/tablet-maya3-tiles.zx0"
tablet_maya3_nametable_zx0:
    incbin "autogenerated/tablet-maya3-nametable.zx0"

tablet_maya4_tiles_zx0:
    incbin "autogenerated/tablet-maya4-tiles.zx0"
tablet_maya4_nametable_zx0:
    incbin "autogenerated/tablet-maya4-nametable.zx0"

tablet_maya5_tiles_zx0:
    incbin "autogenerated/tablet-maya5-tiles.zx0"
tablet_maya5_nametable_zx0:
    incbin "autogenerated/tablet-maya5-nametable.zx0"

tablet_maya6_tiles_zx0:
    incbin "autogenerated/tablet-maya6-tiles.zx0"
tablet_maya6_nametable_zx0:
    incbin "autogenerated/tablet-maya6-nametable.zx0"

tablet_maya7_tiles_zx0:
    incbin "autogenerated/tablet-maya7-tiles.zx0"
tablet_maya7_nametable_zx0:
    incbin "autogenerated/tablet-maya7-nametable.zx0"

elaine_letter1_tiles_zx0:
    incbin "autogenerated/elaine-letter1-tiles.zx0"
elaine_letter1_nametable_zx0:
    incbin "autogenerated/elaine-letter1a-nametable.zx0"

elaine_letter1b_tiles_zx0:
    incbin "autogenerated/elaine-letter1b-tiles.zx0"
elaine_letter1b_nametable_zx0:
    incbin "autogenerated/elaine-letter1b-nametable.zx0"

elaine_letter2b_tiles_zx0:
    incbin "autogenerated/elaine-letter2b-tiles.zx0"
elaine_letter2b_nametable_zx0:
    incbin "autogenerated/elaine-letter2b-nametable.zx0"

tablet_maya_syllable_tiles_zx0:
    incbin "autogenerated/tablet-maya-syllables-tiles.zx0"

tablet_trivia_tiles_zx0:
    incbin "autogenerated/tablet-trivia-tiles.zx0"

    include "tablets.asm"
    include "letters.asm"
    include "puzzlebox.asm"

    include "state-interarea.asm"


end_of_page_7:
    ds #c000-$


;-----------------------------------------------
; PAGE 8: enemies, npcs
; mdl:page 8
    org #8000
start_of_page_8:

IF COLLISION_DEBUG = 2
jungle_enemy_sprites_zx0:
pyramid_enemy_sprites_zx0:
caves_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-debug.zx0"
ELSE
jungle_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-jungle.zx0"

pyramid_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-pyramid.zx0"

calendar_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-calendar.zx0"

caves_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-caves.zx0"

ENDIF

jungle_start_npc_sprites_zx0:
    incbin "autogenerated/npc-sprites-start.zx0"

    include "enemies.asm"


end_of_page_8:
    ds #c000-$



;-----------------------------------------------
; PAGE 9: jungle tiles
; mdl:page 9
    org #8000
start_of_page_9:

    include "npcs.asm"


chunk_edgecollisions_jungle:
    include "autogenerated/jungle-chunk-edgecollisions.asm"
chunk_edgecollisions_pyramid:
    include "autogenerated/pyramid-chunk-edgecollisions.asm"
chunk_edgecollisions_caves:
    include "autogenerated/caves-chunk-edgecollisions.asm"
chunk_edgecollisions_xibalba:
    include "autogenerated/xibalba-chunk-edgecollisions.asm"
chunk_edgecollisions_atlantis:
    include "autogenerated/atlantis-chunk-edgecollisions.asm"
chunk_edgecollisions_mars:
    include "autogenerated/mars-chunk-edgecollisions.asm"
chunk_edgecollisions_moon:
    include "autogenerated/moon-chunk-edgecollisions.asm"


xibalba_chunk_bg_bank_0_zx0:
    incbin "autogenerated/chunks/xibalba-bg-0.zx0"

xibalba_chunk_fg_bank_0_zx0:
    incbin "autogenerated/chunks/xibalba-fg-0.zx0"
xibalba_chunk_fg_bank_1_zx0:
    incbin "autogenerated/chunks/xibalba-fg-1.zx0"
xibalba_chunk_fg_bank_2_zx0:
    incbin "autogenerated/chunks/xibalba-fg-2.zx0"
xibalba_chunk_fg_bank_3_zx0:
    incbin "autogenerated/chunks/xibalba-fg-3.zx0"
xibalba_chunk_fg_bank_4_zx0:
    incbin "autogenerated/chunks/xibalba-fg-4.zx0"
xibalba_chunk_fg_bank_5_zx0:
    incbin "autogenerated/chunks/xibalba-fg-5.zx0"
xibalba_chunk_fg_bank_6_zx0:
    incbin "autogenerated/chunks/xibalba-fg-6.zx0"
xibalba_chunk_fg_bank_7_zx0:
    incbin "autogenerated/chunks/xibalba-fg-7.zx0"
xibalba_chunk_fg_bank_8_zx0:
    incbin "autogenerated/chunks/xibalba-fg-8.zx0"
xibalba_chunk_fg_bank_9_zx0:
    incbin "autogenerated/chunks/xibalba-fg-9.zx0"
xibalba_chunk_fg_bank_10_zx0:
    incbin "autogenerated/chunks/xibalba-fg-10.zx0"
xibalba_chunk_fg_bank_11_zx0:
    incbin "autogenerated/chunks/xibalba-fg-11.zx0"
xibalba_chunk_fg_bank_12_zx0:
    incbin "autogenerated/chunks/xibalba-fg-12.zx0"

eight_bridge_room_zx0:
    incbin "autogenerated/8bridge-room.zx0"

end_of_page_9:
    ds #c000-$



;-----------------------------------------------
; PAGE 10: text2
; mdl:page 10
    org #8000
start_of_page_10:

    include "autogenerated/text-data-page10.asm"


end_of_page_10:
    ds #c000-$


;-----------------------------------------------
; PAGE 11: pcg (world)
; mdl:page 11
    org #8000
start_of_page_11:

    include "pcg-world.asm"
    include "pcg-riddles.asm"

IF INCLUDE_HARDCODED_WORLD_DATA = 1
hardcoded_world_data:
    include "unittests/hardcoded-world-seed0.asm"
hardcoded_world_data_end:
ENDIF

story_tiles_zx0:
    incbin "autogenerated/story-tiles.zx0"
story_sprites_zx0:
    incbin "autogenerated/story-sprites.zx0"
story_nametable:
    incbin "autogenerated/story-nametable.bin"
story_bubble_nametable:
    incbin "autogenerated/story-bubble-nametable.bin"
; story_nametable_frame1:
;     incbin "autogenerated/story-nametable-frame1.bin"
story_nametable_frame2:
    incbin "autogenerated/story-nametable-frame2.bin"
story_nametable_frame3:
    incbin "autogenerated/story-nametable-frame3.bin"
story_nametable_frame4:
    incbin "autogenerated/story-nametable-frame4.bin"
story_nametable_frame5:
    incbin "autogenerated/story-nametable-frame5.bin"
story_nametable_frame6:
    incbin "autogenerated/story-nametable-frame6.bin"
story_nametable_artifact1:
    incbin "autogenerated/story-nametable-artifact1.bin"
story_nametable_artifact2a:
    incbin "autogenerated/story-nametable-artifact2a.bin"
story_nametable_artifact2b:
    incbin "autogenerated/story-nametable-artifact2b.bin"
story_nametable_hand:
    incbin "autogenerated/story-nametable-hand.bin"

    include "state-story.asm"

gamestart_tiles_zx0:
    incbin "autogenerated/gamestart-tiles.zx0"
gamestart_nametable_zx0:
    incbin "autogenerated/gamestart-nametable.zx0"
state_gamestart_sprites_zx0:
    incbin "autogenerated/gamestart-sprites.zx0"

    include "state-gamestart.asm"


end_of_page_11:
    ds #c000-$


;-----------------------------------------------
; PAGE 12: bosses gfx
; mdl:page 12
    org #8000
start_of_page_12:

boss_1_tiles_zx0:
    incbin "autogenerated/boss1-tiles.zx0"

boss_2_tiles_zx0:
    incbin "autogenerated/boss2-tiles.zx0"
boss_2_tiles_right_zx0:
    incbin "autogenerated/boss2-tiles-right.zx0"
boss_2_tiles_flight_zx0:
    incbin "autogenerated/boss2-tiles-air.zx0"

boss_3_tiles_walk_zx0:
    incbin "autogenerated/boss3-tiles-walk.zx0"
boss_3_tiles_stomp_zx0:
    incbin "autogenerated/boss3-tiles-stomp.zx0"

boss_4_tiles_zx0:
    incbin "autogenerated/boss4-common-tiles.zx0"
boss4_tiles_rise_zx0:
    incbin "autogenerated/boss4-rise-tiles.zx0"
boss4_tiles_lord1_zx0:
    incbin "autogenerated/boss4-lord1-tiles.zx0"
boss4_tiles_lord2_zx0:
    incbin "autogenerated/boss4-lord2-tiles.zx0"
boss4_tiles_lord3_zx0:
    incbin "autogenerated/boss4-lord3-tiles.zx0"
boss4_tiles_lord4_zx0:
    incbin "autogenerated/boss4-lord4-tiles.zx0"
boss4_tiles_lord5_zx0:
    incbin "autogenerated/boss4-lord5-tiles.zx0"
boss4_tiles_lord6_zx0:
    incbin "autogenerated/boss4-lord6-tiles.zx0"
boss4_tiles_lord7_zx0:
    incbin "autogenerated/boss4-lord7-tiles.zx0"
boss4_tiles_lord8_zx0:
    incbin "autogenerated/boss4-lord8-tiles.zx0"
boss4_tiles_lord9_zx0:
    incbin "autogenerated/boss4-lord9-tiles.zx0"
boss4_tiles_lord10_zx0:
    incbin "autogenerated/boss4-lord10-tiles.zx0"
boss4_tiles_lord11_zx0:
    incbin "autogenerated/boss4-lord11-tiles.zx0"
boss4_tiles_lord12_zx0:
    incbin "autogenerated/boss4-lord12-tiles.zx0"

boss_5_tiles_charybdis1_zx0:
    incbin "autogenerated/boss5-tiles-charybdis1.zx0"

boss1_sprites_zx0:
    incbin "autogenerated/boss1-sprites.zx0"
boss2_sprites_zx0:
    incbin "autogenerated/boss2-sprites.zx0"
boss3_sprites_zx0:
    incbin "autogenerated/boss3-sprites.zx0"
boss4_sprites_zx0:
    incbin "autogenerated/boss4-sprites.zx0"
boss5_sprites_zx0:
    incbin "autogenerated/boss5-sprites.zx0"
boss6_sprites_zx0:
    incbin "autogenerated/boss6-sprites.zx0"
boss7_sprites_zx0:
    incbin "autogenerated/boss7-sprites.zx0"
boss8_sprites_zx0:
    incbin "autogenerated/boss8-sprites.zx0"


end_of_page_12:
    ds #c000-$    


;-----------------------------------------------
; PAGE 13: jungle, pyramid chunks
; mdl:page 13
    org #8000
start_of_page_13:

tiles_caves_zx0:
    incbin "autogenerated/tiles-caves.zx0"

caves_chunk_bg_bank_0_zx0:
    incbin "autogenerated/chunks/caves-bg-0.zx0"

caves_chunk_fg_bank_0_zx0:
    incbin "autogenerated/chunks/caves-fg-0.zx0"
caves_chunk_fg_bank_1_zx0:
    incbin "autogenerated/chunks/caves-fg-1.zx0"
caves_chunk_fg_bank_2_zx0:
    incbin "autogenerated/chunks/caves-fg-2.zx0"
caves_chunk_fg_bank_3_zx0:
    incbin "autogenerated/chunks/caves-fg-3.zx0"
caves_chunk_fg_bank_4_zx0:
    incbin "autogenerated/chunks/caves-fg-4.zx0"
caves_chunk_fg_bank_5_zx0:
    incbin "autogenerated/chunks/caves-fg-5.zx0"
caves_chunk_fg_bank_6_zx0:
    incbin "autogenerated/chunks/caves-fg-6.zx0"
caves_chunk_fg_bank_7_zx0:
    incbin "autogenerated/chunks/caves-fg-7.zx0"
caves_chunk_fg_bank_8_zx0:
    incbin "autogenerated/chunks/caves-fg-8.zx0"
caves_chunk_fg_bank_9_zx0:
    incbin "autogenerated/chunks/caves-fg-9.zx0"
caves_chunk_fg_bank_10_zx0:
    incbin "autogenerated/chunks/caves-fg-10.zx0"
caves_chunk_fg_bank_11_zx0:
    incbin "autogenerated/chunks/caves-fg-11.zx0"
caves_chunk_fg_bank_12_zx0:
    incbin "autogenerated/chunks/caves-fg-12.zx0"
caves_chunk_fg_bank_13_zx0:
    incbin "autogenerated/chunks/caves-fg-13.zx0"
caves_chunk_fg_bank_14_zx0:
    incbin "autogenerated/chunks/caves-fg-14.zx0"

tiles_jungle_zx0:
    incbin "autogenerated/tiles-jungle.zx0"

tiles_xibalba_zx0:
    incbin "autogenerated/tiles-xibalba.zx0"

tiles_atlantis_zx0:
    incbin "autogenerated/tiles-atlantis.zx0"

teleporter_room_zx0:
    incbin "autogenerated/teleporter-room.zx0"

    include "calendar-room-events2.asm"

end_of_page_13:
    ds (#c000-$) 


;-----------------------------------------------
; PAGE 14: inventory tiles, maya riddle tiles, puzzleboxes, boss 4
; mdl:page 14
    org #8000
start_of_page_14:

inventory_tiles_bank0_zx0:
    incbin "autogenerated/inventory-tiles-bank0.zx0"
inventory_tiles_bank1_zx0:
    incbin "autogenerated/inventory-tiles-bank1.zx0"
inventory_tiles_bank2_zx0:
    incbin "autogenerated/inventory-tiles-bank2.zx0"
inventory_tiles_nametable_zx0:
    incbin "autogenerated/inventory-nametable.zx0"


tablet_maya_riddle_tiles_zx0:
    incbin "autogenerated/tablet-maya-tiles.zx0"


puzzlebox_tiles_zx0:
    incbin "autogenerated/puzzlebox-tiles.zx0"
puzzlebox_nametable_zx0:
    incbin "autogenerated/puzzlebox-nametable.zx0"


    include "boss4.asm"

    include "calendar-room-events.asm"


end_of_page_14:
    ds #c000-$


;-----------------------------------------------
; PAGE 15: music
; mdl:page 15
    org #8000
start_of_page_15:

    include "sfx.asm"

music_jungle_bin:
    incbin "autogenerated/music/jungle.bin"

music_caves_bin:
    incbin "autogenerated/music/caves.bin"

music_pyramid_bin:
    incbin "autogenerated/music/pyramid.bin"

music_tomb_bin:
    incbin "autogenerated/music/tomb.bin"

music_intro1_bin:
    incbin "autogenerated/music/intro1.bin"

music_intro2_bin:
    incbin "autogenerated/music/intro2.bin"

music_credits_bin:
    incbin "autogenerated/music/credits.bin"

music_gameover_bin:
    incbin "autogenerated/music/gameover.bin"

music_boss_bin:
    incbin "autogenerated/music/boss.bin"

music_ending_aliens_bin:
    incbin "autogenerated/music/ending-aliens.bin"

music_beach_bin:
    incbin "autogenerated/music/beach.bin"

    include "sound-tables.asm"
    include "sound-internal.asm"

end_of_page_15:
    ds #c000-$


;-----------------------------------------------
; PAGE 16: atlantis chunks
; mdl:page 16
    org #8000
start_of_page_16:

atlantis_chunk_bg_bank_0_zx0:
    incbin "autogenerated/chunks/atlantis-bg-0.zx0"

atlantis_chunk_fg_bank_0_zx0:
    incbin "autogenerated/chunks/atlantis-fg-0.zx0"
atlantis_chunk_fg_bank_1_zx0:
    incbin "autogenerated/chunks/atlantis-fg-1.zx0"
atlantis_chunk_fg_bank_2_zx0:
    incbin "autogenerated/chunks/atlantis-fg-2.zx0"
atlantis_chunk_fg_bank_3_zx0:
    incbin "autogenerated/chunks/atlantis-fg-3.zx0"
atlantis_chunk_fg_bank_4_zx0:
    incbin "autogenerated/chunks/atlantis-fg-4.zx0"
atlantis_chunk_fg_bank_5_zx0:
    incbin "autogenerated/chunks/atlantis-fg-5.zx0"
atlantis_chunk_fg_bank_6_zx0:
    incbin "autogenerated/chunks/atlantis-fg-6.zx0"
atlantis_chunk_fg_bank_7_zx0:
    incbin "autogenerated/chunks/atlantis-fg-7.zx0"
atlantis_chunk_fg_bank_8_zx0:
    incbin "autogenerated/chunks/atlantis-fg-8.zx0"
atlantis_chunk_fg_bank_9_zx0:
    incbin "autogenerated/chunks/atlantis-fg-9.zx0"

tiles_teleporter_zx0:
    incbin "autogenerated/tiles-teleporter.zx0"

    include "pcg-enemies.asm"

    include "area-collision-tables.asm"


end_of_page_16:
    ds #c000-$


;-----------------------------------------------
; PAGE 17: boss 5
; mdl:page 17
    org #8000
start_of_page_17:

boss_5_tiles_charybdis2_zx0:
    incbin "autogenerated/boss5-tiles-charybdis2.zx0"
boss_5_tiles_charybdis3_zx0:
    incbin "autogenerated/boss5-tiles-charybdis3.zx0"
boss_5_tiles_scylla1_zx0:
    incbin "autogenerated/boss5-tiles-scylla1.zx0"
boss_5_tiles_scylla2_zx0:
    incbin "autogenerated/boss5-tiles-scylla2.zx0"

boss_5_tiles_charybdis2_patch_zx0:
    incbin "autogenerated/boss5-tiles-charybdis2-patch.zx0"
boss_5_tiles_charybdis3_patch_zx0:
    incbin "autogenerated/boss5-tiles-charybdis3-patch.zx0"

    include "boss5.asm"
    include "boss5-charybdis.asm"
    include "boss5-scylla.asm"

    include "state-braingames.asm"
    include "state-title.asm"    
    include "state-gameover.asm"    

tiles_hud_zx0:
    incbin "autogenerated/tiles-hud.zx0"

title_sprites_zx0:
    incbin "autogenerated/title-sprites.zx0"
title_nametable:
    incbin "autogenerated/title-nametable.bin"

    include "area-collision-tables-firestone-forge.asm"


end_of_page_17:
    ds #c000-$


;-----------------------------------------------
; PAGE 18: endings
; mdl:page 18
    org #8000
start_of_page_18:

ending_ufo_tiles_zx0:
    incbin "autogenerated/ending-ufo-tiles.zx0"
ending_ufo_nametables:
    incbin "autogenerated/ending-ufo-nametable.bin"
ending_ufo_sprites_zx0:
    incbin "autogenerated/ending-ufo-sprites.zx0"

ending_beach_tiles_zx0:
    incbin "autogenerated/ending-beach-tiles.zx0"
ending_beach_nametables:
    incbin "autogenerated/ending-beach-nametable.bin"
ending_beach_sprites_zx0:
    incbin "autogenerated/ending-beach-sprites.zx0"

ending_mayabanner_tiles_zx0:
    incbin "autogenerated/ending-mayabanner-tiles.zx0"
ending_mayabanner_nametable:
    incbin "autogenerated/ending-mayabanner-nametable.bin"

ending_enemy_intro_data0:  ; snakes
    incbin "autogenerated/ending-enemy-intro-data0.zx0"
ending_enemy_intro_data1:  ; fish
    incbin "autogenerated/ending-enemy-intro-data1.zx0"
ending_enemy_intro_data2:  ; bees
    incbin "autogenerated/ending-enemy-intro-data2.zx0"
ending_enemy_intro_data3:  ; frogs
    incbin "autogenerated/ending-enemy-intro-data3.zx0"
ending_enemy_intro_data4:  ; carnivore plant
    incbin "autogenerated/ending-enemy-intro-data4.zx0"
ending_enemy_intro_data5:  ; bats
    incbin "autogenerated/ending-enemy-intro-data5.zx0"
ending_enemy_intro_data6:  ; skeletons
    incbin "autogenerated/ending-enemy-intro-data6.zx0"
ending_enemy_intro_data7:  ; monkeys
    incbin "autogenerated/ending-enemy-intro-data7.zx0"
ending_enemy_intro_data8:  ; caves skeletons
    incbin "autogenerated/ending-enemy-intro-data8.zx0"
ending_enemy_intro_data9:  ; rockmen
    incbin "autogenerated/ending-enemy-intro-data9.zx0"
ending_enemy_intro_data10:  ; ants
    incbin "autogenerated/ending-enemy-intro-data10.zx0"
ending_enemy_intro_data11:  ; fire imps
    incbin "autogenerated/ending-enemy-intro-data11.zx0"
ending_enemy_intro_data12:  ; owl
    incbin "autogenerated/ending-enemy-intro-data12.zx0"
ending_enemy_intro_data13:  ; ghosts
    incbin "autogenerated/ending-enemy-intro-data13.zx0"
ending_enemy_intro_data14:  ; fishmen
    incbin "autogenerated/ending-enemy-intro-data14.zx0"
ending_enemy_intro_data15:  ; sentinel
    incbin "autogenerated/ending-enemy-intro-data15.zx0"
; mars/moon:
ending_enemy_intro_data16:  ; snails
    incbin "autogenerated/ending-enemy-intro-data16.zx0"
ending_enemy_intro_data17:  ; blobs
    incbin "autogenerated/ending-enemy-intro-data17.zx0"
ending_enemy_intro_data18:  ; walkers
    incbin "autogenerated/ending-enemy-intro-data18.zx0"
ending_enemy_intro_data19:  ; drones
    incbin "autogenerated/ending-enemy-intro-data19.zx0"
ending_enemy_intro_data20:  ; giant walker
    incbin "autogenerated/ending-enemy-intro-data20.zx0"
ending_enemy_intro_data21:  ; mushrooms
    incbin "autogenerated/ending-enemy-intro-data21.zx0"
ending_enemy_intro_data22:  ; giant mushroom
    incbin "autogenerated/ending-enemy-intro-data22.zx0"
ending_enemy_intro_data23:  ; aliens
    incbin "autogenerated/ending-enemy-intro-data23.zx0"

    include "state-ending.asm"


end_of_page_18:
    ds #c000-$


;-----------------------------------------------
; PAGE 19:
; mdl:page 19
    org #8000
start_of_page_19:

astronomy_room_zx0:
    incbin "autogenerated/astronomy-room.zx0"
astronomy_room_tiles_zx0:
    incbin "autogenerated/tiles-astronomy.zx0"

    include "astronomy-room.asm"

temple_of_poseidon_room_zx0:
    incbin "autogenerated/temple-of-poseidon.zx0"

guard_statue_tiles_zx0:
    incbin "autogenerated/tiles-guard-statue.zx0"
guard_statue_room1_zx0:
    incbin "autogenerated/guard-statue-room1.zx0"
guard_statue_room2_zx0:
    incbin "autogenerated/guard-statue-room2.zx0"
guard_statue_room3_zx0:
    incbin "autogenerated/guard-statue-room3.zx0"


tiles_mars_zx0:
    incbin "autogenerated/tiles-mars.zx0"

tiles_moon_zx0:
    incbin "autogenerated/tiles-moon.zx0"


mars_chunk_bg_bank_0_zx0:
    incbin "autogenerated/chunks/mars-bg-0.zx0"

mars_chunk_fg_bank_0_zx0:
    incbin "autogenerated/chunks/mars-fg-0.zx0"
mars_chunk_fg_bank_1_zx0:
    incbin "autogenerated/chunks/mars-fg-1.zx0"
mars_chunk_fg_bank_2_zx0:
    incbin "autogenerated/chunks/mars-fg-2.zx0"
mars_chunk_fg_bank_3_zx0:
    incbin "autogenerated/chunks/mars-fg-3.zx0"
mars_chunk_fg_bank_4_zx0:
    incbin "autogenerated/chunks/mars-fg-4.zx0"
mars_chunk_fg_bank_5_zx0:
    incbin "autogenerated/chunks/mars-fg-5.zx0"
mars_chunk_fg_bank_6_zx0:
    incbin "autogenerated/chunks/mars-fg-6.zx0"
mars_chunk_fg_bank_7_zx0:
    incbin "autogenerated/chunks/mars-fg-7.zx0"
mars_chunk_fg_bank_8_zx0:
    incbin "autogenerated/chunks/mars-fg-8.zx0"
mars_chunk_fg_bank_9_zx0:
    incbin "autogenerated/chunks/mars-fg-9.zx0"
mars_chunk_fg_bank_10_zx0:
    incbin "autogenerated/chunks/mars-fg-10.zx0"

end_of_page_19:
    ds #c000-$


;-----------------------------------------------
; PAGE 20:
; mdl:page 20
    org #8000
start_of_page_20:

    include "pcg-prettify.asm"

    include "tile-animations.asm"

IF COLLISION_DEBUG = 2
mars_enemy_sprites_zx0:
moon_enemy_sprites_zx0:
atlantis_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-debug.zx0"
ELSE
atlantis_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-atlantis.zx0"
mars_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-mars.zx0"
moon_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-moon.zx0"
ENDIF

moon_chunk_bg_bank_0_zx0:
    incbin "autogenerated/chunks/moon-bg-0.zx0"

moon_chunk_fg_bank_0_zx0:
    incbin "autogenerated/chunks/moon-fg-0.zx0"
moon_chunk_fg_bank_1_zx0:
    incbin "autogenerated/chunks/moon-fg-1.zx0"
moon_chunk_fg_bank_2_zx0:
    incbin "autogenerated/chunks/moon-fg-2.zx0"
moon_chunk_fg_bank_3_zx0:
    incbin "autogenerated/chunks/moon-fg-3.zx0"
moon_chunk_fg_bank_4_zx0:
    incbin "autogenerated/chunks/moon-fg-4.zx0"
moon_chunk_fg_bank_5_zx0:
    incbin "autogenerated/chunks/moon-fg-5.zx0"
moon_chunk_fg_bank_6_zx0:
    incbin "autogenerated/chunks/moon-fg-6.zx0"
moon_chunk_fg_bank_7_zx0:
    incbin "autogenerated/chunks/moon-fg-7.zx0"
moon_chunk_fg_bank_8_zx0:
    incbin "autogenerated/chunks/moon-fg-8.zx0"


end_of_page_20:
    ds #c000-$


;-----------------------------------------------
; PAGE 21:
; mdl:page 21
    org #8000
start_of_page_21:

firestone_forge_puzzle_tiles12_zx0:
    incbin "autogenerated/forge-puzzle-tiles12-tiles.zx0"
firestone_forge_puzzle_tiles3_zx0:
    incbin "autogenerated/forge-puzzle-tiles3-tiles.zx0"
firestone_forge_puzzle_nametables:
    incbin "autogenerated/forge-nametable.bin"

    include "forge-puzzle.asm"
    include "mars-robot-puzzle.asm"

mars_robot_puzzle_room_zx0:
    incbin "autogenerated/mars-robot-puzzle-room.zx0"
mars_robot_puzzle_room_tiles_zx0:
    incbin "autogenerated/mars-robot-puzzle-tiles.zx0"
mars_robot_puzzle_room_sprites_zx0:
    incbin "autogenerated/mars-robot-puzzle-sprites.zx0"
mars_robot_puzzle_room_zoom_tiles_zx0:
    incbin "autogenerated/mars-robot-puzzle-zoom-tiles.zx0"
mars_robot_puzzle_room_zoom_nametables:
    incbin "autogenerated/mars-robot-puzzle-zoom-nametables.bin"

tablet_calendar_tiles_zx0:
    incbin "autogenerated/calendar-tablet-tiles.zx0"
tablet_calendar_nametable_zx0:
    incbin "autogenerated/calendar-tablet-nametable.zx0"


boss_room_1_zx0:
    incbin "autogenerated/boss-room-1.zx0"
boss_room_2_zx0:
    incbin "autogenerated/boss-room-2.zx0"
boss_room_3_zx0:
    incbin "autogenerated/boss-room-3.zx0"
boss_room_4_zx0:
    incbin "autogenerated/boss-room-4.zx0"
boss_room_5_zx0:
    incbin "autogenerated/boss-room-5.zx0"


boss_room_6_zx0:
    incbin "autogenerated/boss-room-6.zx0"

boss_6_tiles_zx0:
    incbin "autogenerated/boss6-tiles.zx0"

    include "boss6.asm"


end_of_page_21:
    ds #c000-$


;-----------------------------------------------
; PAGE 22:
; mdl:page 22
    org #8000
start_of_page_22:

    include "autogenerated/text-data-page22.asm"


end_of_page_22:
    ds #c000-$


;-----------------------------------------------
; PAGE 23:
; mdl:page 23
    org #8000
start_of_page_23:

firestone_forge_room_zx0:
    incbin "autogenerated/firestone-forge-room.zx0"

firestone_forge_tiles_zx0:
    incbin "autogenerated/tiles-firestone-forge.zx0"

shop_tiles_zx0:
    incbin "autogenerated/shop-tiles.zx0"

xibalba_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-xibalba.zx0"

boss_room_7_zx0:
    incbin "autogenerated/boss-room-7.zx0"

boss_7_tiles_zx0:
    incbin "autogenerated/boss7-tiles.zx0"
boss_7_phase2_tiles_zx0:
    incbin "autogenerated/boss7-tiles-phase2.zx0"
boss_7_phase3_tiles_zx0:
    incbin "autogenerated/boss7-tiles-phase3.zx0"

    include "boss7.asm"


end_of_page_23:
    ds #c000-$


;-----------------------------------------------
; PAGE 24:
; mdl:page 24
    org #8000
start_of_page_24:

boss_room_8_zx0:
    incbin "autogenerated/boss-room-8.zx0"

boss_8_phase1_tiles_zx0:
    incbin "autogenerated/boss8-phase1-tiles.zx0"
boss_8_phase1b_12_tiles_zx0:
    incbin "autogenerated/boss8-phase1b-12-tiles.zx0"
boss_8_phase2_3_tiles_zx0:
    incbin "autogenerated/boss8-phase2-bank3-tiles.zx0"

tiles_calendar_teleporter_zx0:
    incbin "autogenerated/tiles-calendar-teleporter.zx0"

    include "boss8-nametables.asm"

    include "boss8.asm"
    include "boss8-auxiliar.asm"


end_of_page_24:
    ds (#c000-$) - (puzzle3_msg_data3_end-puzzle3_msg_data3)

puzzle3_msg_data3:
    db #4c,#6f,#6f,#6b,#20,#61,#74,#20,#79,#6f,#75,#2c,#20,#70,#65,#65
    db #6b,#69,#6e,#67,#20,#61,#74,#20,#74,#68,#65,#20,#52,#4f,#4d,#2e
    db #20,#54,#68,#65,#72,#65,#20,#6d,#69,#67,#68,#74,#20,#62,#65,#20
    db #73,#6f,#6d,#65,#74,#68,#69,#6e,#67,#2e,#20,#42,#75,#74,#20,#79
    db #6f,#75,#20,#68,#61,#76,#65,#20,#74,#6f,#20,#73,#65,#61,#72,#63
    db #68,#2e,#2e,#2e
puzzle3_msg_data3_end:


;-----------------------------------------------
    include "ram.asm"
