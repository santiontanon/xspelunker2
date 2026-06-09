MARS_ROBOT_PUZZLE_PANNEL1_CLOSED_NAMETABLE: equ mars_robot_puzzle_room_zoom_nametables + 25
MARS_ROBOT_PUZZLE_PANNEL2_CLOSED_NAMETABLE: equ mars_robot_puzzle_room_zoom_nametables + 25 + 14*6
MARS_ROBOT_PUZZLE_PANNEL3_CLOSED_NAMETABLE: equ mars_robot_puzzle_room_zoom_nametables + 25 + 14*12


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

	ld de, update_animations_in_vdp_none
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr z, mars_robot_puzzle_spawn_room_animations_ptr_set
	ld de, update_animations_in_vdp_mars_robot
mars_robot_puzzle_spawn_room_animations_ptr_set:
	ld (current_room__animation_fn_ptr), de
	ld hl, mars_robot_puzzle_room_tiles_zx0
	ld (current_room__tileset_ptr), hl
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
	ld iyl, COLOR_DARK_BLUE
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr z, update_sprite_objects_mars_robot_puzzle_room_internal_colors_set
	ld iyl, COLOR_WHITE

update_sprite_objects_mars_robot_puzzle_room_internal_colors_set:
	ld (ix + ROOM_OBJECT_STRUCT_TILE_X), 7
	ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), 12
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 0) * 4
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame

	ld (ix + ROOM_OBJECT_STRUCT_TILE_X), 12
	ld d, iyl
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
	cp 2
	jr z, mars_robot_puzzle_interaction_panel1
	cp 3
	jp z, mars_robot_puzzle_interaction_panel2
	cp 4
	jp z, mars_robot_puzzle_interaction_panel3

	; lock:
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr nz, mars_robot_puzzle_interaction_robot
	; robot is still turned off:
	ld a, (player_current_item)
	cp N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_GOLDEN_KEY
	jr z, mars_robot_puzzle_interaction_open_lock
	ld a, TILES_PAGE
	ld hl, object_interaction_function_chest_fail
	jp jp_to_hl_in_page_a_8000

;-----------------------------------------------
mars_robot_puzzle_interaction_open_lock:
	; the player used the correct key, turn the robot on:
	ld a, 1
	ld (global_state__objects + TAG_MARS_ROBOT_PUZZLE), a
	; lose the key:
	xor a
	ld (player_current_item), a  ; machete
	ld (player_inventory_items + INVENTORY_ITEM_GOLDEN_KEY), a

	ld hl, update_animations_in_vdp_mars_robot
	ld (current_room__animation_fn_ptr), hl

	ld hl, SFX_secret
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	ld (hl), #ff

	ld de, TEXT_MARS_ROBOT_TURN_ON
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	jp call_hl_in_page_c_8000


;-----------------------------------------------
mars_robot_puzzle_interaction_robot:
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr z, mars_robot_puzzle_interaction_robot_off
	; robot is on:
	ld de, TEXT_MARS_ROBOT_REQUEST
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	jp call_hl_in_page_c_8000	

mars_robot_puzzle_interaction_robot_off:
	ld de, TEXT_MARS_ROBOT_OFF_1
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	jp call_hl_in_page_c_8000


;-----------------------------------------------
mars_robot_puzzle_interaction_panel1:
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr nz, mars_robot_puzzle_interaction_panel1_on
mars_robot_puzzle_interaction_panel1_off:
	call mars_robot_puzzle_interaction_panel_draw_box
	; draw name table:
	ld hl, MARS_ROBOT_PUZZLE_PANNEL1_CLOSED_NAMETABLE
mars_robot_puzzle_interaction_panel1_off_entrypoint:
	ld de, NAMTBL2 + 9*32 + 8
	ld bc, #0607
	call mars_robot_puzzle_copy_nametable
	ld hl, TEXT_MARS_ROBOT_PANEL_OFF_1
	call mars_robot_puzzle_text_line1
	ld hl, TEXT_MARS_ROBOT_PANEL_OFF_2
	call mars_robot_puzzle_text_line2

	call wait_for_click
	jp mars_robot_puzzle_interaction_panel_clear_box

mars_robot_puzzle_interaction_panel1_on:
	; ...
	ret


;-----------------------------------------------
mars_robot_puzzle_interaction_panel2:
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr nz, mars_robot_puzzle_interaction_panel1_on
mars_robot_puzzle_interaction_panel2_off:
	call mars_robot_puzzle_interaction_panel_draw_box
	; draw name table:
	ld hl, MARS_ROBOT_PUZZLE_PANNEL2_CLOSED_NAMETABLE
	jr mars_robot_puzzle_interaction_panel1_off_entrypoint

mars_robot_puzzle_interaction_panel2_on:
	; ...
	ret


;-----------------------------------------------
mars_robot_puzzle_interaction_panel3:
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr nz, mars_robot_puzzle_interaction_panel1_on
mars_robot_puzzle_interaction_panel3_off:
	call mars_robot_puzzle_interaction_panel_draw_box
	; draw name table:
	ld hl, MARS_ROBOT_PUZZLE_PANNEL3_CLOSED_NAMETABLE
	jr mars_robot_puzzle_interaction_panel1_off_entrypoint

mars_robot_puzzle_interaction_panel3_on:
	; ...
	ret


;-----------------------------------------------
mars_robot_puzzle_interaction_panel_draw_box:
	; clear sprites that are in the message area (y < 56)
	ld hl, sprite_attribute_table
	ld a, (n_displayed_object_sprites)
	add a, FIRST_OBJECT_SPRITE
	ld b, a
mars_robot_puzzle_interaction_panel_draw_box_loop:
	ld a, (hl)  ; y
	cp 48
	jr c, mars_robot_puzzle_interaction_panel_draw_box_loop_next
	cp 120
	jr nc, mars_robot_puzzle_interaction_panel_draw_box_loop_next
	ld (hl), 200  ; move out of the screen
mars_robot_puzzle_interaction_panel_draw_box_loop_next:
	inc hl
	inc hl
	inc hl
	inc hl
	djnz mars_robot_puzzle_interaction_panel_draw_box_loop

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
	ld hl, mars_robot_puzzle_room_zoom_tiles_zx0
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

    ; set up the text area nametable:
    ld hl, buffer_4096
    ld a, 14*16
    ld b, 32
mars_robot_puzzle_interaction_panel_draw_box_loop2:
    ld (hl), a
    inc hl
    inc a
    djnz mars_robot_puzzle_interaction_panel_draw_box_loop2

    ld hl, buffer_4096
    ld de, NAMTBL2 + 11*32 + 16
    ld b, 16
    call fast_small_LDIRVM

    ld hl, buffer_4096 + 16
    ld de, NAMTBL2 + 12*32 + 16
    ld b, 16
    call fast_small_LDIRVM

    ; draw the lines at top/bottom:
    ld a, 1
	ld hl, NAMTBL2 + 8*32
	ld bc, 32
	call fast_FILVRM

    ld a, 1
	ld hl, NAMTBL2 + 15*32
	ld bc, 32
	jp fast_FILVRM


;-----------------------------------------------
mars_robot_puzzle_interaction_panel_clear_box:
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

	ld a, (current_room__tileset_page)
	ld c, a
	ld hl, (current_room__tileset_ptr)
	call setup_game_tiles

	ld hl, redraw_flags
	ld (hl), #ff
	ret


;-----------------------------------------------
; input:
; - hl: nametable
; - de: ptr to VDP
; - c, b: width, height
mars_robot_puzzle_copy_nametable:
mars_robot_puzzle_copy_nametable_loop_y:
	push bc
		push hl
			push de
				ld b, c
				call fast_small_LDIRVM
			pop hl
			ld bc, 32
			add hl, bc
			ex de, hl
		pop hl
	pop bc
	push bc
		ld b, 0
		add hl, bc
	pop bc
	djnz mars_robot_puzzle_copy_nametable_loop_y
	ret


;-----------------------------------------------
; input:
; - hl: text
mars_robot_puzzle_text_line1:
	ex de, hl
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE4
	call call_hl_in_page_c_8000
	ld de, CHRTBL2 + 256*8 + 14*16*8
	ld hl, buffer_4096
	ld iy, #80f0
	ld b, 16
	jp draw_sentence_to_vdp_from_another_page


;-----------------------------------------------
; input:
; - hl: text
mars_robot_puzzle_text_line2:
	ex de, hl
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE4
	call call_hl_in_page_c_8000
	ld de, CHRTBL2 + 256*8 + 15*16*8
	ld hl, buffer_4096
	ld iy, #80f0
	ld b, 16
	jp draw_sentence_to_vdp_from_another_page


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

