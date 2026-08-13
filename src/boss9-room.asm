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
    cp #07
    jr z, pcg_generate_room__boss_9_internal_boss_defeated
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
pcg_generate_room__boss_9_internal_boss_defeated:
    ; spawn panel:
    ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 3
    ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_BOSS9_ENTRANCE
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
;     ld hl, TEXT_BOSS9_PANEL1
;     ld de, CHRTBL2 + 256*8 + 4*16*8 
;     call boss9_panel_draw_box_text
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
    ; tmp_dialog_pointer_position:
    ; -  0,  1,  2,  3,  4,    5
    ; -  6,  7,  8,  9, 10,   11
    ; - 12, 13, 14, 15, 16,    -
    ld a, 5
    ld (tmp_dialog_pointer_position), a
    call object_interaction_function_boss9_panel_internal_update_display
object_interaction_function_boss9_panel_internal_loop:
    halt
    call object_interaction_function_boss9_panel_internal_update_pointer_sprite
    call update_keyboard_buffers

    ld a, (keyboard_clicks)
    bit KEY_WEAPON_BIT, a  ; space
    jp nz, object_interaction_function_boss9_panel_internal_loop_space
    bit KEY_UP_BIT, a
    jp nz, object_interaction_function_boss9_panel_internal_up
    bit KEY_DOWN_BIT, a
    jp nz, object_interaction_function_boss9_panel_internal_down
    bit KEY_LEFT_BIT, a
    jp nz, object_interaction_function_boss9_panel_internal_left
    bit KEY_RIGHT_BIT, a
    jp nz, object_interaction_function_boss9_panel_internal_right
    jr object_interaction_function_boss9_panel_internal_loop

object_interaction_function_boss9_panel_internal_up:
    ld hl, tmp_dialog_pointer_position
    ld a, (hl)
    sub 6
    jp c, object_interaction_function_boss9_panel_internal_loop
    ld (hl), a
    ld hl, SFX_ui_move
    call play_SFX_with_high_priority
    jp object_interaction_function_boss9_panel_internal_loop

object_interaction_function_boss9_panel_internal_down:
    ld hl, tmp_dialog_pointer_position
    ld a, (hl)
    cp 11
    jp nc, object_interaction_function_boss9_panel_internal_loop
    add a, 6
    ld (hl), a
    ld hl, SFX_ui_move
    call play_SFX_with_high_priority
    jp object_interaction_function_boss9_panel_internal_loop

object_interaction_function_boss9_panel_internal_left:
    ld hl, tmp_dialog_pointer_position
    ld a, (hl)
    or a
    jp z, object_interaction_function_boss9_panel_internal_loop
    cp 6
    jp z, object_interaction_function_boss9_panel_internal_loop
    cp 12
    jp z, object_interaction_function_boss9_panel_internal_loop
    dec (hl)
    ld hl, SFX_ui_move
    call play_SFX_with_high_priority
    jp object_interaction_function_boss9_panel_internal_loop

object_interaction_function_boss9_panel_internal_right:
    ld hl, tmp_dialog_pointer_position
    ld a, (hl)
    cp 5
    jp z, object_interaction_function_boss9_panel_internal_loop
    cp 11
    jp z, object_interaction_function_boss9_panel_internal_loop
    cp 16
    jp z, object_interaction_function_boss9_panel_internal_loop
    inc (hl)
    ld hl, SFX_ui_move
    call play_SFX_with_high_priority
    jp object_interaction_function_boss9_panel_internal_loop

object_interaction_function_boss9_panel_internal_loop_space:
    ld a, (tmp_dialog_pointer_position)
    cp 5
    jr z, object_interaction_function_boss9_panel_internal_loop_space_clue
    cp 11
    jr z, object_interaction_function_boss9_panel_internal_loop_space_back
    ; letters:
    cp 5
    jr c, object_interaction_function_boss9_panel_internal_loop_space_index_set
    dec a
    cp 10
    jr c, object_interaction_function_boss9_panel_internal_loop_space_index_set
    dec a
object_interaction_function_boss9_panel_internal_loop_space_index_set:
    ld b, 0
    ld c, a
    ld hl, global_state__boss9_panel
    add hl, bc
    ld a, (hl)
    inc a
    and #0f
    ld (hl), a
    call object_interaction_function_boss9_panel_internal_update_display
    ld hl, SFX_ui_move
    call play_SFX_with_high_priority

    ; check if the puzzle is solved:
    ld de, global_state__boss9_panel
    ld hl, object_interaction_function_boss9_panel_internal_table
    ld b, 15
object_interaction_function_boss9_panel_internal_loop_space_solution_loop:
    ld a, (de)
    cp (hl)
    jp nz, object_interaction_function_boss9_panel_internal_loop
    inc de
    inc hl
    djnz object_interaction_function_boss9_panel_internal_loop_space_solution_loop

    ld hl, SFX_secret
    call play_SFX_with_high_priority

    call clear_all_the_sprites
    ld de, TEXT_BOSS9_PANEL_SOLVED
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000
    jp start_boss9
;     ; ...
;     jr object_interaction_function_boss9_panel_internal_loop_space_back

object_interaction_function_boss9_panel_internal_table:
    db 10, 10, 14, 14, 14
    db 15, 10, 15, 1, 0
    db 0, 15, 14, 11, 0
    ; DEBUG:
;     db 0, 0, 0, 0, 1
;     db 0, 0, 0, 0, 0
;     db 0, 0, 0, 0, 0

object_interaction_function_boss9_panel_internal_loop_space_back:
    call clear_all_the_sprites
    jp boss9_panel_clear_box


object_interaction_function_boss9_panel_internal_loop_space_clue:
    call clear_all_the_sprites
    ld de, TEXT_BOSS9_PANEL_CLUE
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000
    jp object_interaction_function_boss9_panel_internal


;-----------------------------------------------
object_interaction_function_boss9_panel_internal_update_pointer_sprite:
    ; tmp_dialog_pointer_position:
    ; -  0,  1,  2,  3,  4,    5
    ; -  6,  7,  8,  9, 10,   11
    ; - 12, 13, 14, 15, 16,    -
    ld hl, buffer_4096
    ld a, (tmp_dialog_pointer_position)
    ld bc, #4816
    cp 11
    jr z, object_interaction_function_boss9_panel_internal_update_pointer_sprite_text2
    cp 5
    jr z, object_interaction_function_boss9_panel_internal_update_pointer_sprite_text1
    cp 6
    jr c, object_interaction_function_boss9_panel_internal_update_pointer_sprite_y_set
    sub 6
    ld b, #58
    cp 6
    jr c, object_interaction_function_boss9_panel_internal_update_pointer_sprite_y_set
    sub 6
    ld b, #68
object_interaction_function_boss9_panel_internal_update_pointer_sprite_y_set:
    add a, a
    add a, a
    add a, a
    add a, a
    add a, c
    ld c, a
    jr object_interaction_function_boss9_panel_internal_update_pointer_sprite_continue
object_interaction_function_boss9_panel_internal_update_pointer_sprite_text1:
    ld bc, #5096
    jr object_interaction_function_boss9_panel_internal_update_pointer_sprite_continue
object_interaction_function_boss9_panel_internal_update_pointer_sprite_text2:
    ld bc, #5896
    ; jr object_interaction_function_boss9_panel_internal_update_pointer_sprite_continue
object_interaction_function_boss9_panel_internal_update_pointer_sprite_continue:
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
object_interaction_function_boss9_panel_internal_update_display:
    ld ix, global_state__boss9_panel
    ld hl, NAMTBL2 + 4 + 9*32
    ld bc, #0305

object_interaction_function_boss9_panel_internal_update_display_loop_y:
    push bc
    push hl
        ld b, c
object_interaction_function_boss9_panel_internal_update_display_loop_x:
        push bc
        push hl
        push ix
            ld a, (ix)
            add a, 34
            ld b, 1
            call fast_small_FILVRM
        pop ix
        pop hl
        pop bc
        inc hl
        inc hl
        inc ix
    djnz object_interaction_function_boss9_panel_internal_update_display_loop_x
    pop hl
    pop bc
    ld de, 32 * 2
    add hl, de
    djnz object_interaction_function_boss9_panel_internal_update_display_loop_y
    ret


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
    ; clear the nametable (to prevent gfx glitches):
    ld hl, NAMTBL2 + 256
    ld bc, 256
    xor a
    call fast_FILVRM
    call setup_game_tiles
    ld hl, redraw_flags
    ld (hl), #ff
    ret


;-----------------------------------------------
object_interaction_function_boss9_entrance_internal:
    call stop_music

    ; place player at the center of the door
    ld a, 4
    ld (player_x), a
    xor a
    ld (player_y), a
    ld (player_state), a  ; idle, facing right
    ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
    ld (player_x + 1), a
    call player_update_update_sprite_position
    ld a, 0
    ld (player_requested_frame), a
    ld hl, upload_sprites_to_vdp
    ld c, SPRITES_PAGE
    call call_hl_in_page_c_8000

    ld hl, SFX_enter_door
    call play_SFX_with_high_priority

    ; enter animation:
    ld b, 16
object_interaction_function_boss9_entrance_internal_loop:
    halt
    ld a, (interrupt_cycle) 
    and #07
    jr nz, object_interaction_function_boss9_entrance_internal_loop

    push bc
        ld a, b
        rrca
        and #01
        add a, 2
        ld l, 0
        rrca
        rr l
        rrca
        rr l
        and #3f  ; hl = a * 64
        ld h, a
        ld bc, player_sprites_bin
        add hl, bc
        ex de, hl
        ld hl, copy_player_sprite_to_buffer
        ld c, SPRITES_PAGE
        call call_hl_in_page_c_8000
    pop bc
    push bc
        ; manipulate player sprite to appear as if it's entering:
        ld a, 16
        sub b
        ld e, a
        ld hl, enter_boss_door_shift_player_sprites_right_e
        ld c, BOSS_PAGE
        call call_hl_in_page_c_8000

        ld hl, buffer_4096
        ld de, SPRTBL2
        ld b, 64
        call fast_small_LDIRVM
    pop bc
    djnz object_interaction_function_boss9_entrance_internal_loop

    ; clear the screen:
    call clear_screen_left_to_right

    ld hl, pcg_generate_room_reset_state
    ld c, PCG_PAGE
    call call_hl_in_page_c_8000

    ld hl, yatzil_room_zx0
    ld c, BOSS_9_ROOM_PAGE  ; room page
    ld de, current_room__id
    call dzx0_from_page_c

    ld a, CAVES_TILES_PAGE
    ld (current_room__tileset_page), a
    ld de, tiles_caves_zx0
    ld (current_room__tileset_ptr), de
    ld hl, update_animations_in_vdp_caves
    ld (current_room__animation_fn_ptr), hl
    xor a
    ld (current_room__tileset_overrides_item_tiles), a  ; anything other than 0
    ld hl, tile_collision_types_caves
    ld (current_room__collision_ptr), hl  ; collision types
    ld a, AREA_COLLISION_TABLES_PAGE
    ld (current_room__collision_ptr_page), a
    ld a, ENEMY_SPRITES_PAGE
    ld (current_room__enemy_sprites_ptr_page), a
    ld hl, caves_enemy_sprites_zx0
    ld (current_room__enemy_sprites_ptr), hl
    ld hl, 0
    ld (large_object_to_upload_to_vdp), hl
    ld hl, music_tomb_bin
    ld (current_room__music_ptr), hl  ; no music in the boss room until the boss appears

    ; player position:
    ld bc, #0b01
    ld hl, player_x
    ld (hl), 0
    inc hl
    ld (hl), c
    inc hl
    ld (hl), 0
    inc hl
    ld (hl), b
    jp state_play_from_loaded_room


;-----------------------------------------------
exit_yatzil_room:
    call disable_VDP_output

    ; teleport outside (stored room/position before entering boss room):
    ld e, BOSS9_ROOM_ID
    ld hl, pcg_generate_room
    ld c, PCG_PAGE
    call call_hl_in_page_c_8000

    ld a, 15
    ld (player_x + 1), a
    ld a, 20
    ld (player_y + 1), a
    xor a
    ld (player_x), a
    ld (player_y), a
    jp state_play_from_loaded_room


;-----------------------------------------------
tile_collision_types_boss9_idle:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
    db 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0
    db 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1
    db 2, 2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


;-----------------------------------------------
tile_collision_types_boss9_boss:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1
    db 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0
    db 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 9
    db 2, 2, 9, 0, 0, 0, 0, 0, 0, 0, 0, 9, 9, 9, 9, 9
    db 2, 2, 9, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 9, 0
    db 2, 2, 0, 0, 0, 0, 0, 9, 9, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
