;-----------------------------------------------
pcg_generate_room__boss_9_internal:
    ; name table:
    ld hl, boss_9_room_zx0
    ld de, current_room__tile_map
    ld c, BOSS_9_ROOM_PAGE
    call dzx0_from_page_c

    ; tile sets, collisions, and animation ptrs:
    ld bc, boss_9_tiles_zx0
    ld (current_room__tileset_ptr), bc
    ld a, BOSS_9_ROOM_PAGE
    ld (current_room__collision_ptr_page), a
    ld bc, tile_collision_types_boss9_idle
    ld (current_room__collision_ptr), bc
    ld a, BOSS_9_ROOM_PAGE
    ld (current_room__tileset_page), a
    ld hl, animations_caves_boss9_bin
    ld (current_room__animation_fn_ptr), hl
    ld a, 1
    ld (current_room__tileset_overrides_item_tiles), a

    ld hl, pcg_generate_room__calendar_open_walls
    ld c, PCG_PAGE
    call call_hl_in_page_c_8000

    ld iy, (tmp_pcg_room__next_tile_object_ptr)
    ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
    ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 1
    ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_BOSS9_EYE_LEFT
    ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 14
    ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 11
    ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0
    add iy, de
    ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 2
    ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_BOSS9_EYE_RIGHT
    ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 16
    ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 11
    ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0
    add iy, de
    ld (tmp_pcg_room__next_tile_object_ptr), iy
    ld a, (global_state__objects + TAG_BOSS_9_ROOM)
    cp #03
    ret nz
    ; spawn panel:
    ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 3
    ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_BOSS9_PANEL
    ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 15
    ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 20
    ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0
    add iy, de
    ld (tmp_pcg_room__next_tile_object_ptr), iy
    ret


;-----------------------------------------------
object_interaction_function_boss9_eye_left_internal:
    ld a, (player_current_item)
    cp N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_CHARYBDIS_EYE
    jr nz, object_interaction_function_boss9_eye_fail

    ld hl, global_state__objects + TAG_BOSS_9_ROOM
    set 0, (hl)

    ; lose eye:
    ld a, (player_last_weapon)
    ld (player_current_item), a
    ld hl, player_inventory_items + INVENTORY_ITEM_CHARYBDIS_EYE
    ld (hl), 0

object_interaction_function_boss9_eye_left_internal_entry_point:
    ld hl, SFX_secret
    call play_SFX_with_high_priority

    ld hl, room_undraw_tile_objects
    ld c, TILES_PAGE
    call call_hl_in_page_c_8000

    ; see if panel needs to be open:
    ld a, (global_state__objects + TAG_BOSS_9_ROOM)
    cp #03
    jr nz, object_interaction_function_boss9_eye_left_internal_continue
    ; spawn panel:
    ld hl, ptr_to_new_tile_object
    ld c, TILES_PAGE
    call call_hl_in_page_c_8000
    jr nz, object_interaction_function_boss9_eye_left_internal_continue
    ld (hl), 3  ; ID
    inc hl
    ld (hl), TAG_BOSS9_PANEL  ; type
    inc hl
    ld (hl), 15  ; tile x
    inc hl
    ld (hl), 20  ; tile y
    inc hl
    ld (hl), 0  ; state (number of coins/live/arrows, etc.)

object_interaction_function_boss9_eye_left_internal_continue:
    ld hl, redraw_flags
    ld (hl), #ff

    ld hl, room_render_tile_objects
    ld c, TILES_PAGE
    jp call_hl_in_page_c_8000


object_interaction_function_boss9_eye_right_internal:
    ld a, (player_current_item)
    cp N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_SCYLLA_EYE
    jr nz, object_interaction_function_boss9_eye_fail

    ld hl, global_state__objects + TAG_BOSS_9_ROOM
    set 1, (hl)

    ; lose eye:
    ld a, (player_last_weapon)
    ld (player_current_item), a
    ld hl, player_inventory_items + INVENTORY_ITEM_SCYLLA_EYE
    ld (hl), 0

    jr object_interaction_function_boss9_eye_left_internal_entry_point


object_interaction_function_boss9_eye_fail:
    ld hl, SFX_ui_wrong
    call play_SFX_with_high_priority
    ld de, TEXT_WRONG_ITEM
    ld hl, display_in_game_message
    ld c, TEXT_PAGE
    push ix
        call call_hl_in_page_c_8000
    pop ix
    ret


;-----------------------------------------------
object_interaction_function_boss9_panel_internal:
    call boss9_panel_draw_box
    ld hl, TEXT_BOSS9_PANEL1
    ld de, CHRTBL2 + 256*8 + 4*16*8 
    call boss9_panel_draw_box_text
    ld hl, TEXT_BOSS9_PANEL2
    ld de, CHRTBL2 + 256*8 + 5*16*8 
    call boss9_panel_draw_box_text
    ld hl, TEXT_BACK_PAGE4
    ld de, CHRTBL2 + 256*8 + 6*16*8 
    call boss9_panel_draw_box_text

    ld hl, dialog_sprites_bin
    ld de, SPRTBL2 + 62*32  ; overwrite the last enemy sprites (which play no role in this room)
    ld bc, dialog_sprites_bin_end - dialog_sprites_bin
    call fast_LDIRVM_from_sprites_page    

    ; interaction loop with panel 1:    
    xor a
    ld (tmp_dialog_pointer_position), a
object_interaction_function_boss9_panel_internal_loop:
    halt
    call object_interaction_function_boss9_panel_internal_update_pointer_sprite
;     call mars_robot_puzzle_interaction_panel1_update_display
    call update_keyboard_buffers

    ld a, (keyboard_clicks)
    bit KEY_WEAPON_BIT, a  ; space
    jp nz, object_interaction_function_boss9_panel_internal_loop_space
    bit KEY_UP_BIT, a
    jp nz, object_interaction_function_boss9_panel_internal_up
    bit KEY_DOWN_BIT, a
    jp nz, object_interaction_function_boss9_panel_internal_down
    jr object_interaction_function_boss9_panel_internal_loop

object_interaction_function_boss9_panel_internal_up:
    ld hl, tmp_dialog_pointer_position
    ld a, (hl)
    or a
    jp z, object_interaction_function_boss9_panel_internal_loop
    dec (hl)
    ld hl, SFX_ui_move
    call play_SFX_with_high_priority
    jp object_interaction_function_boss9_panel_internal_loop

object_interaction_function_boss9_panel_internal_down:
    ld hl, tmp_dialog_pointer_position
    ld a, (hl)
    cp 2
    jp z, object_interaction_function_boss9_panel_internal_loop
    inc (hl)
    ld hl, SFX_ui_move
    call play_SFX_with_high_priority
    jp object_interaction_function_boss9_panel_internal_loop


object_interaction_function_boss9_panel_internal_loop_space:
    ld a, (tmp_dialog_pointer_position)
    or a
    ; ...
    dec a
    jr z, object_interaction_function_boss9_panel_internal_loop_space_clue
    call clear_all_the_sprites
    jp boss9_panel_clear_box


object_interaction_function_boss9_panel_internal_loop_space_clue:
    call clear_all_the_sprites
    ld de, TEXT_BOSS9_PANEL_CLUE
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    jp call_hl_in_page_c_8000


;-----------------------------------------------
object_interaction_function_boss9_panel_internal_update_pointer_sprite:
    ld hl, buffer_4096
    ld a, (tmp_dialog_pointer_position)
    ld bc, #4896
    add a, a
    add a, a
    add a, a
    add a, b
    ld b, a
    ld (hl), b
    inc hl
    ld (hl), c
    inc hl
    ld (hl), 62*4  ; sprite
    inc hl
    ld c, COLOR_WHITE
    ld a, (interrupt_cycle)
    bit 3, a
    jr z, object_interaction_function_boss9_panel_internal_update_pointer_sprite_color_set
    ld c, COLOR_TRANSPARENT
object_interaction_function_boss9_panel_internal_update_pointer_sprite_color_set:
    ld (hl), c
    ld hl, buffer_4096
    ld de, SPRATR2 + 31*4
    ld b, 4
    jp fast_small_LDIRVM


;-----------------------------------------------
boss9_panel_draw_box_text:
    push de
        ex de, hl
        ld hl, copy_text_from_another_page
        ld c, TEXT_PAGE4
        call call_hl_in_page_c_8000
        ld hl, buffer_4096
        ld iy, #80f0
        ld b, 10
    pop de
    jp draw_sentence_to_vdp_from_another_page


;-----------------------------------------------
boss9_panel_draw_box:
    ; clear sprites that are in the message area (y < 56)
    ld hl, sprite_attribute_table
    ld a, (n_displayed_object_sprites)
    add a, FIRST_OBJECT_SPRITE
    ld b, a
boss9_panel_draw_box_loop:
    ld a, (hl)  ; y
    cp 48
    jr c, boss9_panel_draw_box_loop_next
    cp 120
    jr nc, boss9_panel_draw_box_loop_next
    ld (hl), 200  ; move out of the screen
boss9_panel_draw_box_loop_next:
    inc hl
    inc hl
    inc hl
    inc hl
    djnz boss9_panel_draw_box_loop

    ld hl, sprite_attribute_table
    ld de, SPRATR2
    ld a, (n_displayed_object_sprites)
    add a, FIRST_OBJECT_SPRITE
    add a, a
    add a, a
    ld b, a
    call fast_small_LDIRVM      

    ; save the content below:
    ld hl, NAMTBL2 + 256
    ld de, current_room__tile_map + 1024  ; this is a small room, so that area is free
    ld bc, 256
    call LDIRMV

    ; clear nametable:
    xor a
    ld hl, NAMTBL2 + 256
    ld bc, 8*32
    call fast_FILVRM

    ; set up the zoom tiles:
    ld hl, boss_9_panel_tiles_zx0
    ld de, buffer_4096
    call dzx0
    ld hl, buffer_4096
    ld de, CHRTBL2 + 256*8
    ld bc, 256*8
    call fast_LDIRVM
    ld hl, buffer_4096 + 256*8
    ld de, CLRTBL2 + 256*8
    ld bc, 256*8
    call fast_LDIRVM

    ld hl, boss_9_panel_nametable
    ld de, NAMTBL2 + 8*32
    ld bc, 8*32
    jp fast_LDIRVM


;-----------------------------------------------
boss9_panel_clear_box:
    ; restore the tiles:
    ld hl, CLRTBL2 + 256*8
    ld bc, 256*8
    xor a
    call fast_FILVRM

    ; restore content below:
    ld hl, current_room__tile_map + 1024
    ld de, NAMTBL2 + 256
    ld bc, 256
    call fast_LDIRVM

    call setup_game_tiles

    ld hl, redraw_flags
    ld (hl), #ff
    ret


;-----------------------------------------------
tile_collision_types_boss9_idle:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
    db 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    db 2, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
