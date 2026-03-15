;-----------------------------------------------
update_boss5_behavior:
	ld hl, boss__hit_timer
	ld a, (hl)
	or a
	jr z, update_boss5_behavior_continue
	dec (hl)
update_boss5_behavior_continue:
	ld a, (boss__active)
	or a
	ret z

	; ...

	ld a, (boss__behavior)
	or a
	jp z, update_boss5_behavior_0  ; before boss is spawned (we don't even know if it's charybdis or scylla here)
	dec a
	jp z, update_boss5_behavior_1  ; charybdis with island on top
; 	dec a
; 	jp z, update_boss5_behavior_2  ; ...
; 	jp update_boss5_behavior_3  ; ...
	ret


;-----------------------------------------------
object_interaction_function_poseidon_boss_display_internal:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #1f
	jr z, object_interaction_function_poseidon_boss_display_internal_both
	and #07
	jr z, object_interaction_function_poseidon_boss_display_internal_skull
	and #01
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), a
object_interaction_function_poseidon_boss_display_internal_continue:
	ld c, TILES_PAGE
	ld hl, room_undraw_tile_objects
	call call_hl_in_page_c_8000
	ld c, TILES_PAGE
	ld hl, room_render_tile_objects
	jp call_hl_in_page_c_8000

object_interaction_function_poseidon_boss_display_internal_skull:
	ld hl, SFX_secret
	call play_SFX_with_high_priority
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 2
	jr object_interaction_function_poseidon_boss_display_internal_continue

object_interaction_function_poseidon_boss_display_internal_both:
	ld hl, SFX_secret
	call play_SFX_with_high_priority
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 3
	jr object_interaction_function_poseidon_boss_display_internal_continue



;-----------------------------------------------
update_boss5_behavior_0:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_0_state_0
	dec a
	; nothing to do on state 1
	dec a
	jr z, update_boss5_behavior_0_state_2  ; player activated the lever
	dec a
	jr z, update_boss5_behavior_0_state_3  ; water starts pouring in
	dec a
	jp z, update_boss5_behavior_0_state_4  ; water level / island rises
	dec a
	jp z, update_boss5_behavior_0_state_5  ; boss name comes down and combat starts
	dec a
	jp z, update_boss5_behavior_0_state_6  ; water stops pouring, and behavior 0 ends

	dec a
	jp z, update_boss5_behavior_0_state_7  ; water level rises (without the island), all the way to the top
	ret

update_boss5_behavior_0_state_0:
	; draw island:
	ld de, current_room__tile_map + 18*32 + 12
	ld ix, boss5_frame_island_0
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_1_without_clearing_ix
	call call_hl_in_page_c_8000

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	ld a, 1
	ld (boss__state), a
	ret

update_boss5_behavior_0_state_2:
	ld ix, current_room__tile_objects + ROOM_TILE_OBJECT_STRUCT_SIZE  ; we know the display is the second object
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	ld (boss__5_variant), a

	; the player just pressed the lever, remove the boss display and lever:
	ld hl, current_room__tile_map + 4*32 + (64*24)
	ld de, current_room__tile_map + 4*32
	ld bc, 6 * 32
	ldir

	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE * 2
	ld hl, current_room__tile_objects
	ld a, #ff
	call clear_memory_a

	; update the collision table:
	ld hl, tile_collision_types_boss5_island
	ld (current_room__collision_ptr), hl
	ld a, (current_room__collision_ptr_page)
	ld de, current_room__collision_table
	ld bc, 256
	call ldir_from_page_a

	ld hl, SFX_secret
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	ld a, 3
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret

update_boss5_behavior_0_state_3:
	; start pouring water:
	ld hl, boss__state_timer
	ld a, (hl)
	cp 17
	jp nz, update_boss5_behavior_0_state_3_continue
	xor a
	ld (boss__state_timer), a
	ld a, (boss__5_variant)
	or a
	jr z, update_boss5_behavior_0_state_3_charybdis
	dec a  ; cp 1
	jr z, update_boss5_behavior_0_state_3_scylla
	dec a  ; cp 2
	jp z, update_boss5_behavior_0_state_3_death
	; both bosses, initialize charybdis first
update_boss5_behavior_0_state_3_charybdis:
	; tileset:
	ld hl, 0
	ld (large_object_to_upload_to_vdp), hl
	ld hl, boss_5_tiles_charybdis1_zx0
	ld c, BOSS_GFX_PAGE
	call setup_game_tiles_only_biome
	ld bc, #1708  ; (8, 23), initial coordinates of charybdis
	ld (boss__x), bc
	xor a
	ld (boss__5_current_variant), a  ; charybdis
	ld hl, 0
	ld (boss__clear_bbox_1 + 2), hl
	ld (boss__clear_bbox_2 + 2), hl

	ld hl, (boss__5_settings + BOSS_5_CHARYBDIS_HP_OFFSET)
	ld (boss__hp), hl
	ld hl, player_weapon_hitbox_check_boss__boss5_charybdis_hit
	ld (boss__hit_fn), hl
	ld a, BOSS_5_PAGE
	ld (boss__hit_fn_page), a
	xor a
	ld (boss__hit_timer), a

	ld a, (current_world__difficulty)
	ld hl, boss5_charybdis_difficulty_setting__easy
	or a
	jr z, update_boss5_behavior_0_state_3_charybdis_continue
	ld hl, boss5_charybdis_difficulty_setting__normal
	dec a
	jr z, update_boss5_behavior_0_state_3_charybdis_continue
	dec a
	ld hl, boss5_charybdis_difficulty_setting__hard
	jr z, update_boss5_behavior_0_state_3_charybdis_continue
	ld hl, boss5_charybdis_difficulty_setting__hardest
update_boss5_behavior_0_state_3_charybdis_continue:
	ld de, boss__5_settings
	ld bc, boss5_charybdis_difficulty_setting__normal - boss5_charybdis_difficulty_setting__easy
	ldir

	xor a
	ld (boss__5_charybdis_mouth_state), a
	ld (boss__5_charybdis_left_claw_state), a
	ld (boss__5_charybdis_right_claw_state), a	
	; ...

	jr update_boss5_behavior_0_state_3_done
update_boss5_behavior_0_state_3_scylla
	; switch to the scylla tileset:
	ld hl, 0
	ld (large_object_to_upload_to_vdp), hl
	ld hl, boss_5_tiles_scylla1_zx0
	ld (current_room__tileset_ptr), hl
	ld a, BOSS_5_PAGE
	ld (current_room__tileset_page), a
	ld c, BOSS_5_PAGE
	call setup_game_tiles_only_biome
	ld bc, #180d  ; (13, 24), initial coordinates of scylla
	ld (boss__x), bc
	ld a, 1
	ld (boss__5_current_variant), a  ; scylla
	ld hl, 0
	ld (boss__clear_bbox_1 + 2), hl
	ld hl, current_room__tile_map + 23*32 + 12  ; clear the bottom of the island
	ld (boss__clear_bbox_2), hl
	ld hl, #0108
	ld (boss__clear_bbox_2 + 2), hl

	ld hl, (boss__5_settings + BOSS_5_SCYLLA_HP_OFFSET)
	ld (boss__hp), hl
	ld hl, player_weapon_hitbox_check_boss__boss5_scylla_hit
	ld (boss__hit_fn), hl
	ld a, BOSS_5_PAGE
	ld (boss__hit_fn_page), a
	xor a
	ld (boss__hit_timer), a

	ld a, (current_world__difficulty)
	ld hl, boss5_scylla_difficulty_setting__easy
	or a
	jr z, update_boss5_behavior_0_state_3_scylla_continue
	ld hl, boss5_scylla_difficulty_setting__normal
	dec a
	jr z, update_boss5_behavior_0_state_3_scylla_continue
	dec a
	ld hl, boss5_scylla_difficulty_setting__hard
	jr z, update_boss5_behavior_0_state_3_scylla_continue
	ld hl, boss5_scylla_difficulty_setting__hardest
update_boss5_behavior_0_state_3_scylla_continue:
	ld de, boss__5_settings
	ld bc, boss5_scylla_difficulty_setting__normal - boss5_scylla_difficulty_setting__easy
	ldir	
	; ...

update_boss5_behavior_0_state_3_done:
	ld a, 4
	ld (boss__state), a
	ret

update_boss5_behavior_0_state_3_death:
	ld a, 7
	ld (boss__state), a
	ret

update_boss5_behavior_0_state_3_continue:
	inc (hl)
	; hl = current_room__tile_map + (5 + a) * 32 + 6
	add a, 5
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, current_room__tile_map + 6
	add hl, bc
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	ld bc, 22 - 9
	add hl, bc
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret

update_boss5_behavior_0_state_4:
	; water level + island rises:
	ld hl, boss__state_timer
	ld a, (hl)
	cp 16 * 7
	jr nz, update_boss5_behavior_0_state_4_continue
	ld a, 5
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_0_state_4_continue:
	inc (hl)
	ld c, a
	and #0f
	ret nz
	ld a, c
	rrca
	rrca
	rrca
	rrca
	and #0f
	; hl = current_room__tile_map + (21 - a) * 32 + 2 + 64*24  ; we overwrite the second copy
	sub 21
	neg
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, current_room__tile_map + 2 + 64*24
	add hl, bc
	ld d, h
	ld e, l
	inc de
	ld (hl), 98  ; water top
	ld bc, 27
	ldir
REPT 5
	inc hl
	inc de
ENDR
	ld (hl), 129  ; water
	ld bc, 27
	ldir

	ld bc, - (64*24 + 32 + 27)
	add hl, bc
	ld d, h
	ld e, l
	ld bc, 64*24
	add hl, bc
	ld bc, 32 + 28
	ldir

	; draw the boss below:
	ld hl, boss__y
	dec (hl)
	ld a, (boss__5_current_variant)
	or a
	push af
		call z, update_boss5_draw_charybdis
	pop af
	call nz, update_boss5_draw_scylla

	; push the player up if on the island:
	call player_check_collision_idle
	jr nz, update_boss5_behavior_0_state_4_continue2
	cp 2  ; if it's with a wall, push player up
	ld hl, player_y + 1
	dec (hl)
update_boss5_behavior_0_state_4_continue2:

	; if it's charybdis, close the floor below with bricks: (118, 117)
	ld a, (boss__5_variant)
	cp 1
	jr z, update_boss5_behavior_0_state_4_not_charybdis
	ld b, 29
	ld a, (boss__state_timer)
	ld hl, current_room__tile_map + 64*24 + 23*32+1
	cp 16 * 4 + 1  ; 16 * 4 -> bottom row
	jr z, update_boss5_behavior_0_state_4_charybdis_preloop
	ld hl, current_room__tile_map + 64*24 + 22*32+2
	cp 16 * 5 + 1  ; 16 * 4 -> bottom row
	jr z, update_boss5_behavior_0_state_4_charybdis_preloop
	ld hl, current_room__tile_map + 64*24 + 21*32+1
	cp 16 * 6 + 1  ; 16 * 4 -> bottom row
	jr nz, update_boss5_behavior_0_state_4_not_charybdis
update_boss5_behavior_0_state_4_charybdis_preloop:
	push hl
update_boss5_behavior_0_state_4_charybdis_loop:
		ld a, b
		and #01
		xor #01
		add a, 117
		ld (hl), a
		inc hl
		djnz update_boss5_behavior_0_state_4_charybdis_loop
	pop hl
	ld d, h
	ld e, l
	ld bc, -64*24
	add hl, bc
	ex de, hl
	ld bc, 29
	ldir
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
update_boss5_behavior_0_state_4_not_charybdis:

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret

update_boss5_behavior_0_state_5:
	; Bring boss name (using sprites)
	ld ix, boss5_name_initial_sprite_attributes
	ld a, (boss__5_current_variant)
	or a
	jr z, update_boss5_behavior_0_state_5_continue
	ld ix, boss5_name_initial_sprite_attributes_scylla
update_boss5_behavior_0_state_5_continue:
	push ix
		ld de, boss5_name_y_table
		ld hl, update_boss_behavior_bring_name_down_ix
		ld c, BOSS_PAGE
		call call_hl_in_page_c_8000
		ld b, 100
		call wait_b_halts_skippable
	pop ix
	; Remove boss name (using sprites)
	ld de, boss5_name_y_table + 23
	ld hl, update_boss_behavior_bring_name_up_ix
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	ld a, 6
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret	

update_boss5_behavior_0_state_6:
	; water stops pouring:
	ld hl, boss__state_timer
	ld a, (hl)
	cp 10
	jr nz, update_boss5_behavior_0_state_6_continue
	ld a, 1
	ld (boss__behavior), a
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_0_state_6_continue:
	inc (hl)
	; hl = current_room__tile_map + (5 + a) * 32 + 6
	add a, 5
	ld l, a
	ld h, 0
	cp 5
	ld a, 154  ; bottom piece of the water sources
	jr z, update_boss5_behavior_0_state_6_continue2
	xor a
update_boss5_behavior_0_state_6_continue2:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, current_room__tile_map + 6
	add hl, bc
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	ld bc, 22 - 9
	add hl, bc
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret

update_boss5_behavior_0_state_7:
	; room fills with water to the top:
	ld hl, boss__state_timer
	ld a, (hl)
	cp 16 * 14
	jr nz, update_boss5_behavior_0_state_7_continue
	ld a, 8
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_0_state_7_continue:
	inc (hl)
	rrca
	rrca
	rrca
	rrca
	and #0f
	; hl = current_room__tile_map + (21 - a) * 32 + 2 + 64*24  ; we overwrite the second copy
	sub 21
	neg
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, current_room__tile_map + 2 + 64*24
	add hl, bc
	; after coordinate 13, the room is wider:
	cp 13
	jr nc, update_boss5_behavior_0_state_7_bottom_part
	; top part:
	dec hl
	ld bc, 29
	ld d, h
	ld e, l
	inc de
	ld (hl), 98  ; water top
	push bc
		ldir
	pop bc
REPT 3
	inc hl
	inc de
ENDR
	ld (hl), 129  ; water
	ldir
	ld bc, - (64*24 + 32 + 29)
	jr update_boss5_behavior_0_state_7_continue2
update_boss5_behavior_0_state_7_bottom_part:
	ld bc, 27
	
	ld d, h
	ld e, l
	inc de
	ld (hl), 98  ; water top
	push bc
		ldir
	pop bc
REPT 5
	inc hl
	inc de
ENDR
	ld (hl), 129  ; water
	ldir
	ld bc, - (64*24 + 32 + 27)
update_boss5_behavior_0_state_7_continue2:
	add hl, bc
	ld d, h
	ld e, l
	ld bc, 64*24
	add hl, bc
	ld bc, 32*2
	ldir

	; clear bottom of the island:
	ld hl, current_room__tile_map + 2 + 23*32
	ld a, 129
	ld bc, 27
	call clear_memory_a

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret


;-----------------------------------------------
boss5_tile_attributes_patch:
	ld hl, (current_room__tileset_ptr)
	ld bc, boss_5_tiles_charybdis1_zx0
	or a
	sbc hl, bc
	jr z, boss5_tile_attributes_patch_charybdis1
	ld hl, (current_room__tileset_ptr)
	ld bc, boss_5_tiles_charybdis1_zx0
	or a
	sbc hl, bc
	jr z, boss5_tile_attributes_patch_charybdis2
	ld hl, (current_room__tileset_ptr)
	ld bc, boss_5_tiles_charybdis1_zx0
	or a
	sbc hl, bc
	jr z, boss5_tile_attributes_patch_charybdis3
boss5_tile_attributes_patch_scylla:
    // scylla1/2: [48, 205] those that are boss	
	ld ixl, 205 - 48
boss5_tile_attributes_patch_scylla_continue:
	; we assume the tileset is already decompressed in buffer_4096
	ld iy, current_room__collision_table + 48
	ld hl, buffer_4096 + 208*8
boss5_tile_attributes_patch_loop:
	ld a, (iy)
	cp 9
	jr nz, boss5_tile_attributes_patch_loop_skip
	; process tile:
	push hl
		ld b, 8
boss5_tile_attributes_patch_loop2:
		ld a, (hl)
		and #0f
		jr nz, boss5_tile_attributes_patch_loop2_continue
		; black, replace by blue:
		ld a, (hl)
		and #f0
		or COLOR_DARK_BLUE
		ld (hl), a
boss5_tile_attributes_patch_loop2_continue:
		ld a, (hl)
		and #f0
		jr nz, boss5_tile_attributes_patch_loop2_continue2
		; black, replace by blue:
		ld a, (hl)
		and #0f
		or COLOR_DARK_BLUE * 16
		ld (hl), a
boss5_tile_attributes_patch_loop2_continue2:
		inc hl
		djnz boss5_tile_attributes_patch_loop2
	pop hl
boss5_tile_attributes_patch_loop_skip:
	inc iy
	ld bc, 8
	add hl, bc
	dec ixl
	jr nz, boss5_tile_attributes_patch_loop

	; upload to VDP:
	ld de, CLRTBL2 + 256*8*2 + 48*8
	ld hl, buffer_4096 + 208*8
	ld bc, 208*8
	jp fast_LDIRVM

boss5_tile_attributes_patch_charybdis1:
    // charybdis1/2: [48, 214] those that are boss
	ld ixl, 214 - 48
	jr boss5_tile_attributes_patch_scylla_continue
boss5_tile_attributes_patch_charybdis2:
    // charybdis1/2: [48, 214] those that are boss
	ld ixl, 214 - 48
	jr boss5_tile_attributes_patch_scylla_continue

boss5_tile_attributes_patch_charybdis3:
    // charybdis3: [48, 161] those that are boss
	ld ixl, 161 - 48
	jr boss5_tile_attributes_patch_scylla_continue

