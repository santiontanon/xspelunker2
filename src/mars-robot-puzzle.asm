;-----------------------------------------------
mars_robot_puzzle_spawn_room:
	call clear_screen_left_to_right
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

	jp state_play_from_loaded_room


;-----------------------------------------------
mars_robot_puzzle_back_to_boss_room:
	ld a, 5
	ld (boss__current_boss_number), a
	call stop_music

	call clear_screen_left_to_right
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
tile_collision_types_mars_robot_puzzle:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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

