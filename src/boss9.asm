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
    ld hl, SFX_secret
    call play_SFX_with_high_priority

    ; ...
    
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
