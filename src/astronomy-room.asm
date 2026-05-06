;-----------------------------------------------
astronomy_room__enter:
	; clear the screen:
	call clear_screen_left_to_right
	ld hl, astronomy_room_zx0
	ld de, current_room__id
	call dzx0
	ld a, ASTRONOMY_ROOM_PAGE
	ld (current_room__tileset_page), a
	ld de, astronomy_room_tiles_zx0
	ld (current_room__tileset_ptr), de
	ld hl, update_animations_in_vdp_none
	ld (current_room__animation_fn_ptr), hl
	ld bc, tile_collision_types_astronomy_room
	ld (current_room__collision_ptr), bc  ; collision types
	ld a, AREA_COLLISION_TABLES_PAGE
	ld (current_room__collision_ptr_page), a
	ld hl, 0
	ld (large_object_to_upload_to_vdp), hl
	ld (current_room__music_ptr), hl  ; no music in the astronomy room for now
	ld a, 1
	ld (current_room__tileset_overrides_item_tiles), a

	; player position:
	ld bc, #0d1e  ; 30, 13
	ld hl, player_x
	ld (hl), 0
	inc hl
	ld (hl), c
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), b

	ld hl, global_state__first_time_flags
	bit 1, (hl)
	jp nz, state_play_from_loaded_room
	; first time:
	set 1, (hl)
	ld hl, event__astronomy_room_first_time_message
	ld (in_game_event_fn_ptr), hl
	ld a, ASTRONOMY_ROOM_PAGE
	ld (in_game_event_fn_page), a

	; spawn the tablet / teleporters:
	; tablet gfx:
	ld hl, buffer_4096 + 60 * 64
	ld (item_object_to_upload_to_vdp), hl

	ld a, 1
	ld (global_state__objects + TAG_TELEPORTER9), a

	ld b, (astronomy_room__enter_objects_start_end - astronomy_room__enter_objects_start) / 3
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	ld hl, astronomy_room__enter_objects_start
	ld iy, current_room__tile_objects
	ld c, 1  ; id
astronomy_room__enter_objects_loop:
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), c  ; id
	inc c
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), a
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), a  ; tile x
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), a  ; tile y
	add iy, de
	djnz astronomy_room__enter_objects_loop
	jp state_play_from_loaded_room


astronomy_room__enter_objects_start:
	db TAG_ASTRONOMY_TABLET1, 10, 20
	db TAG_ASTRONOMY_TABLET1, 18, 20
	db TAG_ASTRONOMY_TABLET2, 22, 20
	db TAG_TELEPORTER9, 4, 19
	db TAG_WORLD_TELEPORTER, 13, 18
astronomy_room__enter_objects_start_end:


;-----------------------------------------------
event__astronomy_room_first_time_message:
	ld de, TEXT_ASTRONOMY_ENTER
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	jp call_hl_in_page_c_8000


;-----------------------------------------------
astronomy_room__leave:
	ld e, EIGHT_BRIDGE_ROOM_ID
	ld hl, pcg_generate_room
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000
	xor a
	ld (player_x + 1), a
	ld (player_x), a
	jp state_play_from_loaded_room	
