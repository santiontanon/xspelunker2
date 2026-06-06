;-----------------------------------------------
mars_robot_puzzle_spawn_room:
	call disable_VDP_output
	ld c, PCG_PAGE
	ld hl, pcg_generate_room_reset_state
	call call_hl_in_page_c_8000

	ld hl, mars_robot_puzzle_room_zx0
	ld de, current_room__id
	call dzx0

	ld a, MARS_ROBOT_PUZZLE_PAGE
	ld (current_room__tileset_page), a
	ld (current_room__collision_ptr_page), a
	ld (current_room__enemy_sprites_ptr_page), a

	ld hl, mars_robot_puzzle_room_tiles_zx0
	ld (current_room__tileset_ptr), hl
	ld hl, update_animations_in_vdp_none
	ld (current_room__animation_fn_ptr), hl
	ld hl, tile_collision_types_mars_robot_puzzle
	ld (current_room__collision_ptr), hl  ; collision types
	ld hl, mars_robot_puzzle_room_sprites_zx0
	ld (current_room__enemy_sprites_ptr), hl
	ld hl, 0
	ld (large_object_to_upload_to_vdp), hl
	ld hl, music_tomb_bin
	ld (current_room__music_ptr), hl
	ld a, 16
	ld (current_room__music_tempo), a
	ld (current_room__tileset_overrides_item_tiles), a  ; anything other than 0

	ld hl, player_y
	ld (hl), 0
	inc hl
	ld (hl), 0

	; tile objects:
	ld iy, current_room__tile_objects
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 1  ; whole robot
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_MARS_ROBOT_PUZZLE
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 4
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 14
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0

	ld iy, current_room__tile_objects + ROOM_TILE_OBJECT_STRUCT_SIZE
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 2  ; panel 1
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_MARS_ROBOT_PUZZLE
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 6
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 18 - 1
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0

	ld iy, current_room__tile_objects + ROOM_TILE_OBJECT_STRUCT_SIZE * 2
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 3  ; panel 2
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_MARS_ROBOT_PUZZLE
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 11
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 9
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0

	ld iy, current_room__tile_objects + ROOM_TILE_OBJECT_STRUCT_SIZE * 3
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 4  ; panel 3
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_MARS_ROBOT_PUZZLE
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 8
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 18 - 1
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0

	ld iy, current_room__tile_objects + ROOM_TILE_OBJECT_STRUCT_SIZE * 4
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 5 ; key hole
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_MARS_ROBOT_PUZZLE
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 12
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 19
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0

	; sprite objects:
	call ptr_to_new_sprite_object
	jr nz, mars_robot_puzzle_spawn_room_continue  ; should never happen
	xor a
	ld (hl), a  ; ID
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_MARS_ROBOT_PUZZLE_ROOM
	inc hl
	ld (hl), a  ; coordinates do not matter, we just set them to 0
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a  ; state (frames left)
mars_robot_puzzle_spawn_room_continue:
	jp state_play_from_loaded_room


;-----------------------------------------------
mars_robot_puzzle_back_to_boss_room:
	ld a, 5
	ld (boss__current_boss_number), a
	call stop_music

	call disable_VDP_output
	ld c, PCG_PAGE
	ld hl, pcg_generate_room_reset_state
	call call_hl_in_page_c_8000
	ld a, 1
	ld (boss__in_boss_room), a
	ld ixl, BOSS_6_PAGE  ; tileset page
	ld ixh, BOSS_6_PAGE  ; room page
	ld hl, boss_room_6_zx0
	ld de, boss_6_tiles_zx0
	ld bc, tile_collision_types_boss6
	ld iy, boss6_sprites_zx0
	push bc
	push iy
		push de
		push ix
			ld c, ixh  ; room page
			ld de, current_room__id
			call dzx0_from_page_c
		pop ix
		pop de

		ld a, ixl
		ld (current_room__tileset_page), a
		ld (current_room__tileset_ptr), de
		ld hl, update_animations_in_vdp_none
		ld (current_room__animation_fn_ptr), hl
	pop iy
	pop bc
	ld (current_room__collision_ptr), bc  ; collision types
	ld a, BOSS_PAGE
	ld (current_room__collision_ptr_page), a
	ld a, BOSS_SPRITES_PAGE
	ld (current_room__enemy_sprites_ptr_page), a
	ld (current_room__enemy_sprites_ptr), iy
	ld hl, 0
	ld (large_object_to_upload_to_vdp), hl
	ld (current_room__music_ptr), hl  ; no music in the boss room until the boss appears
	inc hl
	ld (boss__hp), hl  ; make sure boss is not dead at the start
	xor a
	ld (boss__behavior), a
	ld (boss__state), a
	ld (boss__state_timer), a
	ld (boss__hit_timer), a	
	ld (boss__last_collision_id), a
	inc a  ; a = 1
	ld (boss__active), a
	ld (current_room__tileset_overrides_item_tiles), a

	; make a copy of the boss room so that we can restore the background as the boss moves:
	ld hl, current_room__tile_map
	ld de, current_room__tile_map + 32*24*2
	ld bc, 32*24*2
	ldir

	ld hl, state_play_update_agenda_boss
	ld (state_play_update_agenda_tbl_ptr), hl

	ld bc, #1502
	ld de, #0204
	call room_remove_breakable_wall_restore_background

	; player position:
	ld hl, player_y
	ld (hl), 0
	inc hl
	ld (hl), 22
	jp state_play_from_loaded_room


;-----------------------------------------------
update_sprite_objects_mars_robot_puzzle_room_internal:
	ld (ix + ROOM_OBJECT_STRUCT_TILE_X), 7
	ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), 12
	ld d, COLOR_DARK_BLUE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 0) * 4
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame

	ld (ix + ROOM_OBJECT_STRUCT_TILE_X), 12
	ld d, COLOR_DARK_BLUE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 1) * 4
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	xor a
	ret


;-----------------------------------------------
get_tile_object_behind_player_mars_robot_part_internal:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	ld hl, #070c  ; 1: robot: 12x7
	cp 1
	jr z, get_tile_object_behind_player_mars_robot_part_internal_continue
	ld hl, #0202  ; 5: key-hole, panel 2: 2x2
	cp 5
	jr z, get_tile_object_behind_player_mars_robot_part_internal_continue
	cp 3
	jr z, get_tile_object_behind_player_mars_robot_part_internal_continue
	ld hl, #0201  ; 2, 4: panels: 1x2
get_tile_object_behind_player_mars_robot_part_internal_continue:
	ld a, (player_x + 1)
	cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jp m, get_tile_object_behind_player_mars_robot_part_internal_fail
	sub l
	cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jp p, get_tile_object_behind_player_mars_robot_part_internal_fail
	ld a, (player_y + 1)
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jp m, get_tile_object_behind_player_mars_robot_part_internal_fail
	sub l
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jp p, get_tile_object_behind_player_mars_robot_part_internal_fail
get_tile_object_behind_player_mars_robot_part_internal_match:
	xor a  ; match!
	ret 
get_tile_object_behind_player_mars_robot_part_internal_fail:
	or 1  ; not found
	ret 


;-----------------------------------------------
mars_robot_puzzle_interaction:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	cp 1
	jr z, mars_robot_puzzle_interaction_robot
	; lock or panels:
	ld hl, SFX_ui_wrong
	call play_SFX_with_high_priority
	ret

mars_robot_puzzle_interaction_robot:
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority
	; ...
	ret


;-----------------------------------------------
tile_collision_types_mars_robot_puzzle:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 2, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 0, 0 

