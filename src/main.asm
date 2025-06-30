    include "constants.asm"
    include "assert.asm"


;-----------------------------------------------
; X-Spelunker 2

;-----------------------------------------------
; pages:
; 0: #4000 - #7fff: core code
; 1: #8000 - #bfff: pcg code
; 2: #8000 - #bfff: tile gfx, pyramid tiles
; 3: #8000 - #bfff: sprites, map, additional tiles, enemy tiles
; 4: #8000 - #bfff: jungle, pyramid chunks
; 5: #8000 - #bfff: text, additional states code (gameover, options, dialog, etc.)
; 6: #8000 - #bfff: bosses
; 7: #8000 - #bfff: tablets, letters + text2
; 8: #8000 - #bfff: enemies
; 9: #8000 - #bfff: jungle tiles


CORE_CODE_PAGE: equ 0
PCG_PAGE: equ 1
TILES_PAGE: equ 2
PYRAMID_TILES_PAGE: equ 2
SPRITES_PAGE: equ 3
MAP_PAGE: equ 3
ENEMY_TILES_PAGE: equ 3
CHUNKS_JUNGLE_PAGE: equ 4
CHUNKS_PYRAMID_PAGE: equ 4
TEXT_PAGE: equ 5
BOSS_PAGE: equ 6
CALENDAR_EVENTS_PAGE: equ 6
ENDING_PAGE: equ 6
TABLET_LETTER_PAGE: equ 7
ENEMIES_PAGE: equ 8
JUNGLE_TILES_PAGE: equ 9
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

;     jp state_braingames
    jp state_play


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
        ld bc, call_hl_in_page_c_8000 + (call_hl_in_page_c_8000_return - call_hl_in_page_c_8000)  ; 3 bytes
        push bc  ; push return address  ; 1 byte
        jp hl  ; 1 byte
call_hl_in_page_c_8000_return:
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
        ld de, call_hl_in_page_e_8000 + (call_hl_in_page_e_8000_return - call_hl_in_page_e_8000)  ; 3 bytes
        push de  ; push return address  ; 1 byte
        jp hl  ; 1 byte
call_hl_in_page_e_8000_return:
    ex af, af'  ; preserve the return af of the function we called
        pop af  ; 1 byte
        di  ; 1 byte
        ld (#7000), a  ; 3 bytes
        ld (current_megarom_page_in_8000), a  ; 3 bytes
        ei
    ex af, af'
    ret  ; 1 byte


;-----------------------------------------------
draw_sentence_to_vdp_from_another_page:
    ld a, (current_megarom_page_in_8000)  ; 3 bytes
    push af  ; 1 byte
        ld a, TEXT_PAGE
        di  ; 1 byte
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
    include "tile-animations.asm"
    include "scroll.asm"
    include "player.asm"
    include "sprite-objects.asm"
    include "trial-fns.asm"
    include "hud.asm"

    include "state-play.asm"

end_of_code:

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

end_of_page_0:
    ds #8000-$


;-----------------------------------------------
; PAGE 1:
; mdl:page 1
    org #8000
start_of_page_1:

    include "pcg-world.asm"
    include "pcg-areas.asm"
    include "pcg-rooms.asm"
    include "pcg-riddles.asm"
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

hardcoded_world_data:
    include "hardcoded-world.asm"
hardcoded_world_data_end:


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
    include "state-gameover.asm"
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
; PAGE 8: enemies
; mdl:page 8
    org #8000
start_of_page_8:

jungle_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-jungle.zx0"

pyramid_enemy_sprites_zx0:
    incbin "autogenerated/enemy-sprites-pyramid.zx0"

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


end_of_page_9:
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
; RAM:
; mdl:page 0
    org #c000   ; RAM goes to the 4th page
RAM:
buffer_4096: ds virtual 4096

text_draw_buffer: ds virtual 32*8

current_world__seed: ds virtual 4
current_world__area_data: ds virtual WORLD_AREA__SIZE * MAX_WORLD_AREAS
; each connection is 8 bytes: ; id1, id2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)
current_world__interarea_connections: ds virtual MAX_INTERAREA_CONNECTIONS * INTERAREA_CONNECTION_SIZE + 1  ; +1 byte for the #ff sentinel
current_world__chest_content: ds virtual MAX_CHESTS * 2 + 1  ; chest_tag, content_tag (+1 byte for the #ff sentinel)
current_world__tablet_content: ds virtual MAX_TABLETS * 3 + 1  ; tablet_tag, content_ptr (+1 byte for the #ff sentinel)
current_world__combination_solutions: ds virtual 4 * 8
current_world__trial_types: ds virtual 4
current_world__power_stone_numbers: ds virtual 5
current_world__maya_puzzle_riddles: ds virtual 3 * 2  ; 2 sentences of 3 bytes each
current_world__maya_puzzle2_combination1: ds virtual 4
current_world__maya_puzzle2_combination2: ds virtual 4
current_world__maya_puzzle3_nametable: ds virtual 10*3
current_world__maya_puzzle3_word: ds virtual 20


current_area__seed: ds virtual 4
current_area__id: ds virtual 1
current_area__width: ds virtual 1  ; in rooms
current_area__height: ds virtual 1  ; in rooms
current_area__room_ids: ds virtual MAX_AREA_SIZE
current_area__chunks_ids: ds virtual MAX_AREA_SIZE * 2 * 2
current_area__objects: ds virtual MAX_AREA_N_OBJECTS * AREA_OBJECT_STRUCT_SIZE
current_area__special_room_room_id_offset: ds virtual 1  ; used to identify the location of the calendar/teleporter room, for collisions
current_area__special_room_chunk_id_offset: ds virtual 1  ; used to identify the location of the calendar/teleporter room, for collisions

current_area__n_chunk_banks: ds virtual 1
current_area__chunks_page: ds virtual 1
current_area__chunk_fg_bank_ptrs: ds virtual 2
current_area__standard_chunk_pool_ptr: ds virtual 2
current_area__boss_chunk_pool_ptr: ds virtual 2
current_area__block_chunk_pool_ptr: ds virtual 2
current_area__combination_chunk_pool_ptr: ds virtual 2
current_area__chunk_flags_ptr: ds virtual 2
current_area__chunk_edgecollisions_ptr: ds virtual 2
current_area__standard_chunk_pool_size: ds virtual 1
current_area__standard_chunk_pool_first_id: ds virtual 1
current_area__boss_chunk_pool_size: ds virtual 1
current_area__boss_chunk_pool_first_id: ds virtual 1
current_area__block_chunk_pool_size: ds virtual 1
current_area__block_chunk_pool_first_id: ds virtual 1
current_area__combination_chunk_pool_size: ds virtual 1
current_area__combination_chunk_pool_first_id: ds virtual 1


current_room__id: ds virtual 1
current_room__x: ds virtual 1  ; coordinates within the area of the top-left room corner (in "screens")
current_room__y: ds virtual 1
current_room__width_in_screens: ds virtual 1
current_room__height_in_screens: ds virtual 1
current_room__width: ds virtual 1
current_room__height: ds virtual 1
current_room__tile_map: ds virtual MAX_ROOM_SIZE
current_room__max_scroll_x: ds virtual 1
current_room__max_scroll_y: ds virtual 1
    ; We separate the sprite objects into 4 groups: player, player bullets, enemies, and other objects
current_room__player_bullets: ds virtual MAX_ROOM_PLAYER_BULLETS * ROOM_OBJECT_STRUCT_SIZE
current_room__player_bullets_sentinel: ds virtual 1  ; set to #ff
current_room__sprite_enemies: ds virtual MAX_ROOM_SPRITE_ENEMIES * ROOM_OBJECT_STRUCT_SIZE
current_room__sprite_enemies_sentinel: ds virtual 1  ; set to #ff
current_room__sprite_objects: ds virtual MAX_ROOM_SPRITE_OBJECTS * ROOM_OBJECT_STRUCT_SIZE
current_room__sprite_objects_sentinel: ds virtual 1  ; set to #ff
current_room__tile_objects: ds virtual MAX_ROOM_TILE_OBJECTS * ROOM_TILE_OBJECT_STRUCT_SIZE
current_room__tile_objects_sentinel: ds virtual 1  ; set to #fe
current_room__trial_fn: ds virtual 2
current_room__tileset_page: ds virtual 1
current_room__tileset_ptr: ds virtual 2
current_room__animation_fn_ptr: ds virtual 2
current_room__collision_ptr: ds virtual 2
current_room__enemy_sprites_ptr: ds virtual 2
current_room__tileset_overrides_item_tiles: ds virtual 1


RAM_to_zero_on_game_start:

; rendering variables:
draw_room_row_offset: ds virtual 2
sprite_attribute_table: ds virtual MAX_SPRITES * 4  ; first 2 sprites are the player sprites, 3rd is player weapon
n_displayed_object_sprites: ds virtual 1
n_displayed_object_sprites_without_player_bullets: ds virtual 1
n_displayed_object_sprites_last_frame: ds virtual 1

room_desired_scroll_x: ds virtual 1
room_desired_scroll_y: ds virtual 1
room_scroll_x: ds virtual 1
room_scroll_y: ds virtual 1

; game state variables:

; for each possible unique object, we maintain its state:
; - 0: default state
; - 1: broken breakable wall, picked up item, opened lock/door
; the offset of a given object is its tag ID
global_state__objects: ds virtual N_UNIQUE_TAGS

; These are used to correct collisions in 'check_collision_with_next_chunk_left', etc.
; Specifically, if a wall/door is open, we overwrite the calculation of the method above. We keep this
; in this separate list, since we would have to re-generate a room to reconstruct this info from the
; 'global_object_state' list.
; area ID + 1, chunk, x1, y1, x2, y2
global_state__open_walls: ds virtual 6 * N_PATH_OPENING_TAGS

global_state__story: ds virtual 1
global_state__used_teleporter_before: ds virtual 1

global_state__power_calendar: ds virtual 6  ; 0: empty
                                            ; 1: inactive stone
                                            ; 2 - 7: one of the power stones 
global_state__n_power_stones_in_calendar: ds virtual 1  ; for convenience (it should be the number of elements in 'global_state__power_calendar' >= 2)
global_state__maya_riddle: ds virtual 1  ; 0: not solved, 1: solved first line, 2: solved
global_state__solved_final_riddle: ds virtual 1

player_x: ds virtual 2  ; 1st the pixel and 2nd byte is the tile coordinate
player_y: ds virtual 2  ; 1st the pixel and 2nd byte is the tile coordinate
player_state: ds virtual 1
player_state_timer: ds virtual 1
player_weapon_state_timer: ds virtual 1
player_requested_frame: ds virtual 1  ; the player frame we want to render
player_requested_weapon_sprite: ds virtual 3  ; sprite, x offs, y offs
player_weapon_swing_type: ds virtual 1
player_water_inertia_x: ds virtual 1
player_water_inertia_y: ds virtual 1
player_water_inertia_x_timer: ds virtual 1
player_water_inertia_y_timer: ds virtual 1
player_jump_is_cancelable: ds virtual 1  ; 1: if we can stop the jump by lifting the jump key.
                                         ; 0: the jump will proceed to maximum height without allowing player to stop it early (used for when coming out of the water).
player_jump_no_grab_timer: ds virtual 1  ; player can grab to ropes/ladders only if this is 0.
                                         ; This is used for when jumping off a ladder/rope, so that the player does not grab again immediately on the next frame.
player_push_block_timer: ds virtual 1
player_no_rope_or_ladder_this_frame: ds virtual 1  ; to prevent infinite loops in the player routine when holding to a ladder fails
player_combination_levers_state: ds virtual 8  ; to simplify combination lever checking
player_trial_completion_state: ds virtual 1

player_health: ds virtual 1
player_max_health: ds virtual 1
player_oxygen: ds virtual 1
player_inventory_weapons: ds virtual N_INVENTORY_WEAPON_TYPES
player_inventory_weapon_ammo: ds virtual 4
player_inventory_items: ds virtual N_INVENTORY_ITEM_TYPES
player_inventory_coins: ds virtual 1
player_inventory_n_small_keys: ds virtual 1
; player_inventory_map_pieces: ds virtual N_MAP_PIECES
player_current_item: ds virtual 1  ; 0 - 10 are weapons, 11 - 35 are inventory key items
player_immunity_timer: ds virtual 1  ; if != 0, nothing can hurt the player
player_can_double_jump: ds virtual 1

player_current_swing_hit_id: ds virtual 1
player_new_hit_id: ds virtual 1
player_weapon_hitbox_check_result: ds virtual 1  ; 1: no hit, 0: hit

tile_enemy_hit_fn_ptr: ds virtual 2
tile_enemy_ptr: ds virtual 2
tile_enemy_last_collision_id: ds virtual 1
tile_enemy_work_memory: ds virtual 64  ; - some large tile-based enemies need extra memory
                                       ; - only one is spawned per room at most. So, they can safely 
                                       ;   use this space without more than one enemy competing for it.

redraw_flags: ds virtual 1  ; bits:
                            ; - 0: room
                            ; - 1: hud
                            ; - 2: hud coins (re-renders the text into the tiles)
                            ; - 3: hud ammo  (re-renders the text into the tiles)
in_game_event_fn_ptr: ds virtual 2
in_game_event_fn_page: ds virtual 1
in_game_event_fn_arg: ds virtual 1
play_seashell_flag: ds virtual 1

; inventory state variables:
inventory_cursor_position_x: ds virtual 1
inventory_cursor_position_y: ds virtual 1

hud_redraw_timer: ds virtual 1  ; if this is 0, the hud is not drawn (when config_hud_type == 0)
hud_draw_buffer: ds virtual 64

keyboard_state:        ds virtual 1
keyboard_clicks:       ds virtual 1
keyboard_state_prev:   ds virtual 1

boss_door_exit_to_room: ds virtual 1
boss_door_exit_to_x: ds virtual 1
boss_door_exit_to_y: ds virtual 1

item_object_to_upload_to_vdp: ds virtual 2  ; 4 tiles will be copied
large_object_to_upload_to_vdp: ds virtual 2
large_object_to_upload_to_vdp_size: ds virtual 1  ; number of bytes to be copied
enemy_tiles_to_upload_to_vdp: ds virtual 2
enemy_tiles_to_upload_to_vdp_page: ds virtual 2

config_keyboard_special_case: ds virtual 1

RAM_to_zero_on_game_start_end:

; temporary variables:
temporary_variables: ds virtual 10
tmp_hud_drawing_hl: equ temporary_variables
tmp_hud_drawing_de: equ temporary_variables + 2
tmp_dialog_pointer_position: equ tmp_hud_drawing_hl
tmp_map_pointer_position: equ tmp_hud_drawing_hl
tmp_letter_line_width: equ tmp_hud_drawing_hl
tmp_letter_line_color: equ tmp_hud_drawing_hl + 1
tmp_puzzlebox_state: equ tmp_hud_drawing_hl
tmp_puzzlebox_pointer: equ tmp_hud_drawing_hl + 4
tmp_enemy_pcg_platform_loc_ptr: equ temporary_variables
tmp_enemy_pcg_water_loc_ptr: equ temporary_variables + 2
tmp_enemy_pcg_ceiling_loc_ptr: equ temporary_variables + 4
tmp_enemy_pcg_n_ceiling_locs: equ temporary_variables + 6
tmp_get_tile_object_behind_player_ptr: equ temporary_variables

config_hud_type: ds virtual 1  ; 0: minimal, 1: minimal always visible, 2: full
config_inventory_key_combo: ds virtual 1  ; 0: down+jump, 1: none
config_interact_with_down: ds virtual 1  ; 0: yes, 1: no
config_interact_with_up: ds virtual 1  ; 0: yes, 1: no
; each key is matrix row + bit mask
config_keyboard: ds virtual 2 * 8  ; RIGHT, DOWN, UP, LEFT, INTERACT, INVENTORY, JUMP, SPACE

; sound variables:
MUSIC_tempo:                        ds virtual 1
MUSIC_original_tempo:               ds virtual 1  ; tempo that was requested before adjusting it for 50/60Hz.
beginning_of_sound_variables_except_tempo:
current_music_ptr:                  ds virtual 2  ; ptr to the compressed song currently playing
MUSIC_play:                         ds virtual 1
MUSIC_tempo_counter:                ds virtual 1
MUSIC_instruments:                  ds virtual 3
MUSIC_channel3_instrument_buffer:   ds virtual 1  ; this stores the instrument of channel 3, which is special, since SFX might overwrite it
MUSIC_start_pointer:                ds virtual 2  
SFX_pointer:                        ds virtual 2
MUSIC_pointer:                      ds virtual 2
MUSIC_repeat_stack_ptr:             ds virtual 2
MUSIC_repeat_stack:                 ds virtual 4*3
MUSIC_instrument_envelope_ptr:      ds virtual 3*2
SFX_priority:                       ds virtual 1  ; the SFX from the game have more priority than those triggered by music
MUSIC_transpose:                    ds virtual 1
MUSIC_time_step_required:           ds virtual 1
end_of_sound_variables:


rng_seed1: ds virtual 2  ; state of the random number generator
rng_seed2: ds virtual 2

interrupt_cycle: ds virtual 1  ; incremented at each interrupt
game_cycle: ds virtual 1  ; incremented at each game loop cycle

dzx0t_last_offset_tmp:              ds virtual 2

start_of_interrupt_code_ram: ds virtual end_of_interrupt_code_rom - start_of_interrupt_code_rom

current_megarom_page_in_4000:       ds virtual 1
current_megarom_page_in_8000:       ds virtual 1

; CPU_turbo_r:  ds virtual 1 ; 0 no turbo-r, 1: turbo-r
isComputer50HzOr60Hz:  ds virtual 1  ; 0: 50Hz, 1: 60Hz
RAM_slot: ds virtual 1  ; slot where the game was inserted

end_of_ram:

stack: equ #f380
stack_size: equ 128

