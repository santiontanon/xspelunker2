    include "constants.asm"
    include "assert.asm"

COLLISION_UNIT_TESTING: equ 0


;-----------------------------------------------
; X-Spelunker 2

;-----------------------------------------------
; pages:
; 0: #4000 - #7fff: core code
; 1: #8000 - #bfff: pcg code
; 2: #8000 - #bfff: tile gfx
; 3: #4000 - #7fff: map data (hardcoded)
; 4: #8000 - #bfff: sprites + sprite code (in this page, so that it has access to sprite data)
; 5: #8000 - #bfff: pyramic chunks
; 6: #8000 - #bfff: 
; 7: #8000 - #bfff: music


CORE_CODE_PAGE: equ 0
PCG_PAGE: equ 1
TILES_PAGE: equ 2
MAP_DATA_PAGE: equ 3
SPRITES_PAGE: equ 4
CHUNKS_PYRAMID_PAGE: equ 5
MUSIC_PAGE: equ 7


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
    ld (rng_seed2), hl

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
; jp_to_hl_in_page_a_8000_rom_:
;     di  ; 1 byte
;     ld (current_megarom_page_in_8000), a  ; 3 bytes
; jp_to_hl_in_page_a_8000_rom_mapper_page_to_update_8000:
;     ld (#7000), a  ; 3 bytes
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
        ld bc, call_hl_in_page_c_8000 + (call_hl_in_page_c_8000_return - call_hl_in_page_c_8000)  ; 3 bytes
        push bc  ; push return address  ; 1 byte
        jp hl  ; 1 byte
call_hl_in_page_c_8000_return:
    pop af  ; 1 byte
    di  ; 1 byte
    ld (#7000), a  ; 3 bytes
    ld (current_megarom_page_in_8000), a  ; 3 bytes
    ei
    ret  ; 1 byte


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
;     include "text.asm"

;     include "state-braingames.asm"
;     include "state-gamestart.asm"
    include "state-play.asm"
    include "state-inventory.asm"

end_of_code:

end_of_page_0:
    ds #8000-$


;-----------------------------------------------
; PAGE 1:
; mdl:page 1
    org #8000
start_of_page_1:

    include "pcg-rooms.asm"

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

end_of_page_1:
    ds #c000-$


;-----------------------------------------------
; PAGE 2: 
; mdl:page 2
    org #8000
start_of_page_2:

tiles_pyramid_zx0:
    incbin "autogenerated/tiles-pyramid.zx0"

animations_pyramid_bin:
    incbin "autogenerated/animations-pyramid.bin"

end_of_page_2:
    ds #c000-$    


;-----------------------------------------------
; PAGE 3: 
; mdl:page 3
    org #8000
start_of_page_3:

; hardcoded_room_data:
;     include "hardcoded-room.asm"
; hardcoded_room_data_end:

hardcoded_area_data:
    include "hardcoded-room.asm"
hardcoded_area_data_end:

end_of_page_3:
    ds #c000-$   


;-----------------------------------------------
; PAGE 4: sprites
; mdl:page 4
    org #8000
start_of_page_4:

player_sprites_bin:
    incbin "autogenerated/player-sprites.bin"
player_sprites_left_bin:
    incbin "autogenerated/player-sprites-left.bin"

    include "sprites.asm"

end_of_page_4:
    ds #c000-$    


;-----------------------------------------------
; PAGE 5: sprites and other gfx
; mdl:page 5
    org #8000
start_of_page_5:

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


end_of_page_5:
    ds #c000-$    




;-----------------------------------------------
; PAGE 6: scene rendeing
; mdl:page 6
    org #8000
start_of_page_6:

end_of_page_6:
    ds #c000-$    




;-----------------------------------------------
; PAGE 7: text
; mdl:page 7
    org #8000
start_of_page_7:

end_of_page_7:
    ds #c000-$    


;-----------------------------------------------
; RAM:
; mdl:page 0
    org #c000   ; RAM goes to the 4th page
RAM:
buffer_4096: ds virtual 4096

; Temporary variables (overlapping with the buffer):
tmp__pcg_current_target_chunk_bank_id: equ buffer_4096 + 4094
tmp__pcg_current_decompressed_chunk_bank_id: equ buffer_4096 + 4095

current_area__seed: ds virtual 4
current_area__width: ds virtual 1
current_area__height: ds virtual 1
current_area__room_ids: ds virtual MAX_AREA_WIDTH * MAX_AREA_HEIGHT
current_area__chunks_ids: ds virtual MAX_AREA_WIDTH * 2 * MAX_AREA_HEIGHT * 2

current_room__id: ds virtual 1
current_room__x: ds virtual 1  ; coordinates within the area of the top-left room corner
current_room__y: ds virtual 1
current_room__width: ds virtual 1
current_room__height: ds virtual 1
current_room__tile_map: ds virtual MAX_ROOM_SIZE
current_room__max_scroll_x: ds virtual 1
current_room__max_scroll_y: ds virtual 1
current_room__objects: ds virtual MAX_ROOM_OBJECTS * ROOM_OBJECT_STRUCT_SIZE

; rendering vairables:
draw_room_row_offset: ds virtual 2

sprite_attribute_table: ds virtual MAX_SPRITES * 4  ; first 2 sprites are the player sprites

RAM_to_zero_on_game_start:

room_desired_scroll_x: ds virtual 1
room_desired_scroll_y: ds virtual 1
room_scroll_x: ds virtual 1
room_scroll_y: ds virtual 1

keyboard_line_state:        ds virtual 1  ; interleaved bytes state/clicks
keyboard_line_clicks:       ds virtual 3
keyboard_line_state_prev:   ds virtual 2

; game state variables:
player_x: ds virtual 2  ; 2nd byte is the tile coordinate, and 1st the pixel
player_y: ds virtual 2  ; 2nd byte is the tile coordinate, and 1st the pixel
player_state: ds virtual 1
player_state_timer: ds virtual 1
player_requested_frame: ds virtual 1  ; the player frame we want to render

redraw_whole_room_flag: ds virtual 1

RAM_to_zero_on_game_start_end:


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

dzx0t_last_offset_tmp:              ds virtual 2

start_of_interrupt_code_ram: ds virtual end_of_interrupt_code_rom - start_of_interrupt_code_rom

current_megarom_page_in_4000:       ds virtual 1
current_megarom_page_in_8000:       ds virtual 1

; CPU_turbo_r:  ds virtual 1 ; 0 no turbo-r, 1: turbo-r
isComputer50HzOr60Hz:  ds virtual 1  ; 0: 50Hz, 1: 60Hz
RAM_slot: ds virtual 1  ; slot where the game was inserted

; jp_to_hl_in_page_a_8000: ds virtual 9
; call_hl_in_page_c_8000: ds virtual 28

end_of_ram:

stack: equ #f380
stack_size: equ 128

