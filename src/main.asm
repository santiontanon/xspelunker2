    include "constants.asm"
    include "assert.asm"

stack: equ #f380
stack_size: equ 128

;-----------------------------------------------
; X-Spelunker 2

;-----------------------------------------------
; pages:
; 0: #4000 - #7fff: core code
; 1: #8000 - #bfff: pcg code (area, room, enemies), brain games
; 2: #8000 - #bfff: tile gfx, pyramid tiles
; 3: #8000 - #bfff: sprites, map, additional tiles, enemy tiles
; 4: #8000 - #bfff: jungle, pyramid chunks
; 5: #8000 - #bfff: text, additional states code (gameover, options, dialog, etc.)
; 6: #8000 - #bfff: bosses, calendar events
; 7: #8000 - #bfff: tablets, letters, text2
; 8: #8000 - #bfff: enemies
; 9: #8000 - #bfff: jungle tiles, npc interactions
; 10: #8000 - #bfff: text3
; 11: #8000 - #bfff: pcg code (world), story, gamestart


CORE_CODE_PAGE: equ 0
PCG_PAGE: equ 1
PCG_PAGE_WORLD: equ 11
BRAINGAMES_PAGE: equ 1
TITLE_PAGE: equ 1
GAMESTART_PAGE: equ 11
STORY_PAGE: equ 11
GAME_OVER_PAGE: equ 1
TILES_PAGE: equ 2
TILE_ANIMATIONS_PAGE: equ 2
PYRAMID_TILES_PAGE: equ 2
SPRITES_PAGE: equ 3
MAP_PAGE: equ 3
ENEMY_TILES_PAGE: equ 3
CHUNKS_JUNGLE_PAGE: equ 4
CHUNKS_PYRAMID_PAGE: equ 4
TEXT_PAGE: equ 5
TEXT_PAGE3: equ 10
BOSS_PAGE: equ 6
CALENDAR_EVENTS_PAGE: equ 6
ENDING_PAGE: equ 6
TABLET_LETTER_PAGE: equ 7
ENEMIES_PAGE: equ 8
JUNGLE_TILES_PAGE: equ 9
NPCS_PAGE: equ 9
AREA_COLLISION_TABLES_PAGE: equ 1
MUSIC_PAGE: equ 0  ; ???


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

    SETMEGAROMPAGE_8000 TEXT_PAGE
    call state_options_reset

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
jp_to_hl_in_page_a_8000:
    di  ; 1 byte
    ld (current_megarom_page_in_8000), a  ; 3 bytes
    ld (#7000), a  ; 3 bytes
    ei  ; 1 byte
jp_to_hl:
    jp hl  ; 1 byte


;-----------------------------------------------
; input:
; - hl: target address
; - c: target page
; jp_to_hl_in_page_c_8000:
;     di  ; 1 byte
;     push af
;         ld a, c
;         ld (current_megarom_page_in_8000), a  ; 3 bytes
;         ld (#7000), a  ; 3 bytes
;     pop af
;     ei  ; 1 byte
;     jp hl  ; 1 byte


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
    include "sfx.asm"
    include "collision.asm"
    include "rooms.asm"
    include "scroll.asm"
    include "player.asm"
    include "sprite-objects.asm"
    include "trial-fns.asm"
    include "hud.asm"

    include "state-play.asm"

end_of_code:


current_world__name_rom:
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

braingames_tiles_zx0:
    incbin "autogenerated/braingames.zx0"

title_tiles_zx0:
    incbin "autogenerated/title-tiles.zx0"
title_sprites_zx0:
    incbin "autogenerated/title-sprites.zx0"
title_nametable:
    incbin "autogenerated/title-nametable.bin"

    include "state-braingames.asm"
    include "state-title.asm"
    include "state-gameover.asm"

    include "pcg-areas.asm"
    include "pcg-rooms.asm"
    include "pcg-enemies.asm"
    include "pcg-prettify.asm"

    include "autogenerated/jungle-chunk-tags.asm"
    include "autogenerated/pyramid-chunk-tags.asm"

    ; pyramid chunks:
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


    include "area-collision-tables.asm"


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

end_of_page_1:
    ds #c000-$


;-----------------------------------------------
; PAGE 2: 
; mdl:page 2
    org #8000
start_of_page_2:

tiles_hud_zx0:
    incbin "autogenerated/tiles-hud.zx0"

tiles_pyramid_zx0:
    incbin "autogenerated/tiles-pyramid.zx0"
tiles_calendar_zx0:
    incbin "autogenerated/tiles-calendar.zx0"
tiles_teleporter_zx0:
    incbin "autogenerated/tiles-teleporter.zx0"

animations_jungle_bin:
    incbin "autogenerated/animations-jungle.bin"
animations_pyramid_bin:
    incbin "autogenerated/animations-pyramid.bin"

inventory_tiles_bank0_zx0:
    incbin "autogenerated/inventory-tiles-bank0.zx0"
inventory_tiles_bank1_zx0:
    incbin "autogenerated/inventory-tiles-bank1.zx0"
inventory_tiles_bank2_zx0:
    incbin "autogenerated/inventory-tiles-bank2.zx0"
inventory_tiles_nametable_zx0:
    incbin "autogenerated/inventory-nametable.zx0"

object_tiles_zx0:
    incbin "autogenerated/tiles-objects.zx0"
object_large_tiles_zx0:
    incbin "autogenerated/tiles-large-objects.zx0"

tablet_maya_riddle_tiles_zx0:
    incbin "autogenerated/tablet-maya-tiles.zx0"


    include "tile-objects.asm"
    include "tile-enemies.asm"
    include "tile-animations.asm"

end_of_page_2:
    ds #c000-$    


;-----------------------------------------------
; PAGE 3: sprites, map, letter/tablet tiles
; mdl:page 3
    org #8000
start_of_page_3:


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
teleporter_room_zx0:
    incbin "autogenerated/teleporter-room.zx0"

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
    include "state-interarea.asm"
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

boss_room_1_zx0:
    incbin "autogenerated/boss-room-1.zx0"

boss_1_tiles_zx0:
    incbin "autogenerated/boss1-tiles.zx0"

    include "bosses.asm"

    include "calendar-room-events.asm"
    include "state-ending.asm"


end_of_page_6:
    ds #c000-$


;-----------------------------------------------
; PAGE 7: tablets, letters
; mdl:page 7
    org #8000
start_of_page_7:

    include "autogenerated/text-data-page7.asm"

tablet_calendar_tiles_zx0:
    incbin "autogenerated/calendar-tablet-tiles.zx0"
tablet_calendar_nametable_zx0:
    incbin "autogenerated/calendar-tablet-nametable.zx0"
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

puzzlebox_tiles_zx0:
    incbin "autogenerated/puzzlebox-tiles.zx0"
puzzlebox_nametable_zx0:
    incbin "autogenerated/puzzlebox-nametable.zx0"

tablet_maya_syllable_tiles_zx0:
    incbin "autogenerated/tablet-maya-syllables-tiles.zx0"

tablet_trivia_tiles_zx0:
    incbin "autogenerated/tablet-trivia-tiles.zx0"

    include "tablets.asm"
    include "letters.asm"
    include "puzzlebox.asm"


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
    incbin "autogenerated/enemy-sprites-debug.zx0"
ELSE
jungle_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-jungle.zx0"

pyramid_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-pyramid.zx0"
ENDIF

jungle_start_npc_sprites_zx0:
    incbin "autogenerated/npc-sprites-start.zx0"

boss1_sprites_zx0:
    incbin "autogenerated/boss1-sprites.zx0"

    include "enemies.asm"


end_of_page_8:
    ds #c000-$



;-----------------------------------------------
; PAGE 9: jungle tiles
; mdl:page 9
    org #8000
start_of_page_9:

tiles_jungle_zx0:
    incbin "autogenerated/tiles-jungle.zx0"

shop_tiles_zx0:
    incbin "autogenerated/shop-tiles.zx0"

    include "npcs.asm"


end_of_page_9:
    ds #c000-$



;-----------------------------------------------
; PAGE 10: text2
; mdl:page 10
    org #8000
start_of_page_10:

    include "autogenerated/text-data-page10.asm"

;-----------------------------------------------
; input:
; - de: ptr to text to copy
copy_text_from_textpage3:
    ld hl, buffer_4096
    ex de, hl
    ld c, (hl)
    inc c
    ld b, 0
    ldir
    ret


end_of_page_10:
    ds #c000-$


;-----------------------------------------------
; PAGE 10: pcg (world)
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

    include "state-gamestart.asm"


end_of_page_11:
    ds (#c000-$) - (puzzle3_msg_data3_end-puzzle3_msg_data3)

puzzle3_msg_data3:
    db #4c,#6f,#6f,#6b,#20,#61,#74,#20,#79,#6f,#75,#2c,#20,#70,#65,#65
    db #6b,#69,#6e,#67,#20,#61,#74,#20,#74,#68,#65,#20,#52,#4f,#4d,#2e
    db #20,#54,#68,#65,#72,#65,#20,#6d,#69,#67,#68,#74,#20,#62,#65,#20
    db #73,#6f,#6d,#65,#74,#68,#69,#6e,#67,#2e,#20,#42,#75,#74,#20,#79
    db #6f,#75,#20,#68,#61,#76,#65,#20,#74,#6f,#20,#73,#65,#61,#72,#63
    db #68,#2e,#2e,#2e
puzzle3_msg_data3_end:


    include "ram.asm"
