MARS_ROBOT_PUZZLE_PANNEL1_CLOSED_NAMETABLE: equ mars_robot_puzzle_room_zoom_nametables + 25
MARS_ROBOT_PUZZLE_PANNEL2_CLOSED_NAMETABLE: equ mars_robot_puzzle_room_zoom_nametables + 25 + 14*6
MARS_ROBOT_PUZZLE_PANNEL3_CLOSED_NAMETABLE: equ mars_robot_puzzle_room_zoom_nametables + 25 + 14*12


; state:
; in (global_state__objects + TAG_MARS_ROBOT_PUZZLE):
; - xxxxxx00: robot off
; - xxxxxx01: robot on: fix status 0
; - xxxxxx10: robot on: button pressed with presure 300
; - xxxxxx11: robot fixed
; - xxxxx1xx: panel 1 open
; - xxxx1xxx: panel 2 open
; - xxx1xxxx: panel 3 open


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

	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	and #03
	cp #03
	jr nz, mars_robot_puzzle_spawn_room_not_fixed
	ld a, (player_inventory_items + INVENTORY_ITEM_PHASE_SHIFTER)
	or a
	jr nz, mars_robot_puzzle_spawn_room_not_fixed
	; spawn phase shifter:
	ld iy, current_room__tile_objects + ROOM_TILE_OBJECT_STRUCT_SIZE * 5
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 0
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_PHASE_SHIFTER
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 24  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 20  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
mars_robot_puzzle_spawn_room_not_fixed:

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
	ld (boss__last_collision_id_1), a
	ld (boss__last_collision_id_2), a
	ld (boss__last_collision_id_3), a
	ld (boss__last_collision_id_4), a
	ld (boss__6_eye_frame), a
	ld (boss__6_face_turret_frame), a
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

	ld hl, update_boss6_draw_boss_first_frame
	ld c, BOSS_6_PAGE
	call call_hl_in_page_c_8000	

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
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	and #03
	cp 3
	jp z, mars_robot_puzzle_interaction_puzzle_solved

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
mars_robot_puzzle_interaction_puzzle_solved:
	ld de, TEXT_MARS_ROBOT_SOLVED
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	jp call_hl_in_page_c_8000


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
	call mars_robot_puzzle_interaction_panel_draw_box

	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr nz, mars_robot_puzzle_interaction_panel1_on
mars_robot_puzzle_interaction_panel1_off:
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
	bit 2, a  ; is panel open?
	jr nz, mars_robot_puzzle_interaction_panel1_open
	or #04
	ld (global_state__objects + TAG_MARS_ROBOT_PUZZLE), a  ; mark panel 1 as open

	ld hl, MARS_ROBOT_PUZZLE_PANNEL1_CLOSED_NAMETABLE
	ld de, NAMTBL2 + 9*32 + 8
	ld bc, #0607
	call mars_robot_puzzle_copy_nametable
	ld hl, TEXT_MARS_ROBOT_PANEL_ON_1
	call mars_robot_puzzle_text_line1

	call wait_for_click

	ld hl, SFX_door_open
	call play_SFX_with_high_priority

mars_robot_puzzle_interaction_panel1_open:
	ld hl, MARS_ROBOT_PUZZLE_PANNEL1_CLOSED_NAMETABLE + 7*6
	ld de, NAMTBL2 + 9*32 + 8
	ld bc, #0607
	call mars_robot_puzzle_copy_nametable
	ld hl, TEXT_BACK_PAGE4
	call mars_robot_puzzle_text_line1

	; interaction loop with panel 1:	
	xor a
	ld (tmp_dialog_pointer_position), a
mars_robot_puzzle_interaction_panel1_loop:
	halt
	call mars_robot_puzzle_interaction_panel1_update_pointer_sprite
	call mars_robot_puzzle_interaction_panel1_update_display
	call update_keyboard_buffers

	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a  ; space
	jp nz, mars_robot_puzzle_interaction_panel1_loop_space
	bit KEY_UP_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel1_loop_up
	bit KEY_DOWN_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel1_loop_down
	bit KEY_LEFT_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel1_loop_left
	bit KEY_RIGHT_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel1_loop_right
	jr mars_robot_puzzle_interaction_panel1_loop

mars_robot_puzzle_interaction_panel1_update_pointer_sprite:
	ld hl, buffer_4096
	ld a, (tmp_dialog_pointer_position)
	dec a
	jr z, mars_robot_puzzle_interaction_panel1_update_pointer_sprite_up
	dec a
	jr z, mars_robot_puzzle_interaction_panel1_update_pointer_sprite_down
mars_robot_puzzle_interaction_panel1_update_pointer_sprite_back:
	ld bc, #5876
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 2) * 4
mars_robot_puzzle_interaction_panel1_update_pointer_sprite_continue:
	ld (hl), b
	inc hl
	ld (hl), c
	inc hl
	ld (hl), e
	inc hl
	ld c, COLOR_WHITE
	ld a, (interrupt_cycle)
	bit 3, a
	jr z, mars_robot_puzzle_interaction_panel1_update_pointer_sprite_color_set
	ld c, COLOR_TRANSPARENT
mars_robot_puzzle_interaction_panel1_update_pointer_sprite_color_set:
	ld (hl), c
	ld hl, buffer_4096
	ld de, SPRATR2
	ld b, 4
	jp fast_small_LDIRVM

mars_robot_puzzle_interaction_panel1_update_pointer_sprite_up:
	ld bc, #4a48
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 3) * 4
	jr mars_robot_puzzle_interaction_panel1_update_pointer_sprite_continue

mars_robot_puzzle_interaction_panel1_update_pointer_sprite_down:
	ld bc, #5248
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 4) * 4
	jr mars_robot_puzzle_interaction_panel1_update_pointer_sprite_continue


mars_robot_puzzle_interaction_panel1_update_display:
	; draw the current pressure in maya:
	ld a, (global_state__mars_robot)  ; current value of pressure
mars_robot_puzzle_interaction_panel1_update_display_continue:
	ld hl, buffer_4096  ; we will store the digits here
	ld c, 0  ; most significant digit (* 400)
	ld b, 0  ; second digit (* 20)
	cp 20
	jr c, mars_robot_puzzle_interaction_panel1_update_display_loop1_done
	ld c, 2
	ld b, 2  ; if msb is not empty, this diit also needs to be non-empty
mars_robot_puzzle_interaction_panel1_update_display_loop1:
	cp 20
	jr c, mars_robot_puzzle_interaction_panel1_update_display_loop1_done
	inc c
	sub 20
	jr mars_robot_puzzle_interaction_panel1_update_display_loop1
mars_robot_puzzle_interaction_panel1_update_display_loop1_done:
	ld (hl), c
	inc hl
	or a
	jr z, mars_robot_puzzle_interaction_panel1_update_display_loop1_b_set2
	add a, 2
	ld b, a
mars_robot_puzzle_interaction_panel1_update_display_loop1_b_set2:
	ld (hl), b  ; * 20
	inc hl
	ld (hl), 2  ; units are always 0
	ld a, (buffer_4096)
	ld hl, NAMTBL2 + 10*32 + 12
	ld bc, 1
	call fast_FILVRM
	ld a, (buffer_4096 + 1)
	ld hl, NAMTBL2 + 11*32 + 12
	ld bc, 1
	call fast_FILVRM
	ld a, (buffer_4096 + 2)
	ld hl, NAMTBL2 + 12*32 + 12
	ld bc, 1
	jp fast_FILVRM


mars_robot_puzzle_interaction_panel1_loop_up:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	cp 1
	jp z, mars_robot_puzzle_interaction_panel1_loop
	ld (hl), 1
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel1_loop

mars_robot_puzzle_interaction_panel1_loop_down:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	cp 2
	jp z, mars_robot_puzzle_interaction_panel1_loop
mars_robot_puzzle_interaction_panel1_loop_down_continue:
	ld (hl), 2
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel1_loop

mars_robot_puzzle_interaction_panel1_loop_left:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	cp 1
	jp z, mars_robot_puzzle_interaction_panel1_loop_down_continue
	ld (hl), 1
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel1_loop

mars_robot_puzzle_interaction_panel1_loop_right:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	or a
	jp z, mars_robot_puzzle_interaction_panel1_loop
	ld (hl), 0
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel1_loop

mars_robot_puzzle_interaction_panel1_loop_space:
	ld a, (tmp_dialog_pointer_position)
	or a
	jp z, mars_robot_puzzle_interaction_panel_clear_box
	dec a
	jp z, mars_robot_puzzle_interaction_panel1_loop_space_up
	; down:
	ld a, (global_state__mars_robot)
	or a
	jp z, mars_robot_puzzle_interaction_panel1_loop
	dec a
	ld (global_state__mars_robot), a
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel1_loop

mars_robot_puzzle_interaction_panel1_loop_space_up:
	; up:
	ld a, (global_state__mars_robot)
	cp 80
	jp z, mars_robot_puzzle_interaction_panel1_loop
	inc a
	ld (global_state__mars_robot), a
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel1_loop


;-----------------------------------------------
mars_robot_puzzle_interaction_panel2:
	call mars_robot_puzzle_interaction_panel_draw_box

	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr nz, mars_robot_puzzle_interaction_panel2_on
mars_robot_puzzle_interaction_panel2_off:
	; draw name table:
	ld hl, MARS_ROBOT_PUZZLE_PANNEL2_CLOSED_NAMETABLE
	jp mars_robot_puzzle_interaction_panel1_off_entrypoint

mars_robot_puzzle_interaction_panel2_on:
	bit 3, a  ; is panel open?
	jr nz, mars_robot_puzzle_interaction_panel2_open
	or #08
	ld (global_state__objects + TAG_MARS_ROBOT_PUZZLE), a  ; mark panel 2 as open

	ld hl, MARS_ROBOT_PUZZLE_PANNEL2_CLOSED_NAMETABLE
	ld de, NAMTBL2 + 9*32 + 8
	ld bc, #0607
	call mars_robot_puzzle_copy_nametable
	ld hl, TEXT_MARS_ROBOT_PANEL_ON_1
	call mars_robot_puzzle_text_line1
	
	call wait_for_click

	ld hl, SFX_door_open
	call play_SFX_with_high_priority

mars_robot_puzzle_interaction_panel2_open:
	ld hl, MARS_ROBOT_PUZZLE_PANNEL2_CLOSED_NAMETABLE + 7*6
	ld de, NAMTBL2 + 9*32 + 8
	ld bc, #0607
	call mars_robot_puzzle_copy_nametable
	ld hl, TEXT_BACK_PAGE4
	call mars_robot_puzzle_text_line1

	; interaction loop with panel 2:
	xor a
	ld (tmp_dialog_pointer_position), a
mars_robot_puzzle_interaction_panel2_loop:
	halt
	call mars_robot_puzzle_interaction_panel2_update_pointer_sprite
	call mars_robot_puzzle_interaction_panel2_update_display
	call update_keyboard_buffers

	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a  ; space
	jp nz, mars_robot_puzzle_interaction_panel2_loop_space
	bit KEY_UP_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel2_loop_up
	bit KEY_DOWN_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel2_loop_down
	bit KEY_LEFT_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel2_loop_left
	bit KEY_RIGHT_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel2_loop_right
	jr mars_robot_puzzle_interaction_panel2_loop

mars_robot_puzzle_interaction_panel2_update_pointer_sprite:
	ld hl, buffer_4096
	ld a, (tmp_dialog_pointer_position)
	dec a
	jr z, mars_robot_puzzle_interaction_panel2_update_pointer_sprite_up
	dec a
	jr z, mars_robot_puzzle_interaction_panel2_update_pointer_sprite_down
mars_robot_puzzle_interaction_panel2_update_pointer_sprite_back:
	ld bc, #5876
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 2) * 4
mars_robot_puzzle_interaction_panel2_update_pointer_sprite_continue:
	ld (hl), b
	inc hl
	ld (hl), c
	inc hl
	ld (hl), e
	inc hl
	ld c, COLOR_WHITE
	ld a, (interrupt_cycle)
	bit 3, a
	jr z, mars_robot_puzzle_interaction_panel2_update_pointer_sprite_color_set
	ld c, COLOR_TRANSPARENT
mars_robot_puzzle_interaction_panel2_update_pointer_sprite_color_set:
	ld (hl), c
	ld hl, buffer_4096
	ld de, SPRATR2
	ld b, 4
	jp fast_small_LDIRVM

mars_robot_puzzle_interaction_panel2_update_pointer_sprite_up:
	ld bc, #4d48
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 5) * 4
	jr mars_robot_puzzle_interaction_panel2_update_pointer_sprite_continue

mars_robot_puzzle_interaction_panel2_update_pointer_sprite_down:
	ld bc, #5a48
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 6) * 4
	jr mars_robot_puzzle_interaction_panel2_update_pointer_sprite_continue


mars_robot_puzzle_interaction_panel2_update_display:
	; draw the current pressure in maya:
	ld a, (global_state__mars_robot + 1)  ; current value of pressure
	jp mars_robot_puzzle_interaction_panel1_update_display_continue


mars_robot_puzzle_interaction_panel2_loop_up:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	cp 1
	jp z, mars_robot_puzzle_interaction_panel2_loop
	ld (hl), 1
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel2_loop

mars_robot_puzzle_interaction_panel2_loop_down:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	cp 2
	jp z, mars_robot_puzzle_interaction_panel2_loop
mars_robot_puzzle_interaction_panel2_loop_down_continue:
	ld (hl), 2
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel2_loop

mars_robot_puzzle_interaction_panel2_loop_left:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	cp 1
	jp z, mars_robot_puzzle_interaction_panel2_loop_down_continue
	ld (hl), 1
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel2_loop

mars_robot_puzzle_interaction_panel2_loop_right:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	or a
	jp z, mars_robot_puzzle_interaction_panel2_loop
	ld (hl), 0
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel2_loop

mars_robot_puzzle_interaction_panel2_loop_space:
	ld a, (tmp_dialog_pointer_position)
	or a
	jp z, mars_robot_puzzle_interaction_panel_clear_box
	dec a
	jp z, mars_robot_puzzle_interaction_panel2_loop_space_up
	; down:
	ld a, (global_state__mars_robot + 1)
	or a
	jp z, mars_robot_puzzle_interaction_panel2_loop
	dec a
	ld (global_state__mars_robot + 1), a
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel2_loop

mars_robot_puzzle_interaction_panel2_loop_space_up:
	; up:
	ld a, (global_state__mars_robot + 1)
	cp 80
	jp z, mars_robot_puzzle_interaction_panel2_loop
	inc a
	ld (global_state__mars_robot + 1), a
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel2_loop


;-----------------------------------------------
mars_robot_puzzle_interaction_panel3:
	call mars_robot_puzzle_interaction_panel_draw_box

	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	or a
	jr nz, mars_robot_puzzle_interaction_panel3_on
mars_robot_puzzle_interaction_panel3_off:
	; draw name table:
	ld hl, MARS_ROBOT_PUZZLE_PANNEL3_CLOSED_NAMETABLE
	jp mars_robot_puzzle_interaction_panel1_off_entrypoint

mars_robot_puzzle_interaction_panel3_on:
	bit 4, a  ; is panel open?
	jr nz, mars_robot_puzzle_interaction_panel3_open
	or #10
	ld (global_state__objects + TAG_MARS_ROBOT_PUZZLE), a  ; mark panel 3 as open

	ld hl, MARS_ROBOT_PUZZLE_PANNEL3_CLOSED_NAMETABLE
	ld de, NAMTBL2 + 9*32 + 8
	ld bc, #0607
	call mars_robot_puzzle_copy_nametable
	ld hl, TEXT_MARS_ROBOT_PANEL_ON_1
	call mars_robot_puzzle_text_line1
	
	call wait_for_click

	ld hl, SFX_door_open
	call play_SFX_with_high_priority

mars_robot_puzzle_interaction_panel3_open:
	ld hl, MARS_ROBOT_PUZZLE_PANNEL3_CLOSED_NAMETABLE + 7*6
	ld de, NAMTBL2 + 9*32 + 8
	ld bc, #0607
	call mars_robot_puzzle_copy_nametable
	ld hl, TEXT_BACK_PAGE4
	call mars_robot_puzzle_text_line1

	; interaction loop with panel 3:
	xor a
	ld (tmp_dialog_pointer_position), a
mars_robot_puzzle_interaction_panel3_loop:
	halt
	call mars_robot_puzzle_interaction_panel3_update_pointer_sprite
	call update_keyboard_buffers

	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a  ; space
	jp nz, mars_robot_puzzle_interaction_panel3_loop_space
	bit KEY_UP_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel3_loop_up
	bit KEY_DOWN_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel3_loop_down
	bit KEY_LEFT_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel3_loop_left
	bit KEY_RIGHT_BIT, a
	jp nz, mars_robot_puzzle_interaction_panel3_loop_right
	jr mars_robot_puzzle_interaction_panel3_loop

mars_robot_puzzle_interaction_panel3_update_pointer_sprite:
	ld hl, buffer_4096
	ld a, (tmp_dialog_pointer_position)
	dec a
	jr z, mars_robot_puzzle_interaction_panel3_update_pointer_sprite_button1
	dec a
	jr z, mars_robot_puzzle_interaction_panel3_update_pointer_sprite_button2
	dec a
	jr z, mars_robot_puzzle_interaction_panel3_update_pointer_sprite_button3
mars_robot_puzzle_interaction_panel3_update_pointer_sprite_back:
	ld bc, #5876
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 2) * 4
mars_robot_puzzle_interaction_panel3_update_pointer_sprite_continue:
	ld (hl), b
	inc hl
	ld (hl), c
	inc hl
	ld (hl), e
	inc hl
	ld c, COLOR_WHITE
	ld a, (interrupt_cycle)
	bit 3, a
	jr z, mars_robot_puzzle_interaction_panel3_update_pointer_sprite_color_set
	ld c, COLOR_TRANSPARENT
mars_robot_puzzle_interaction_panel3_update_pointer_sprite_color_set:
	ld (hl), c
	ld hl, buffer_4096
	ld de, SPRATR2
	ld b, 4
	jp fast_small_LDIRVM

mars_robot_puzzle_interaction_panel3_update_pointer_sprite_button1:
	ld bc, #4f40
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 2) * 4
	jr mars_robot_puzzle_interaction_panel3_update_pointer_sprite_continue

mars_robot_puzzle_interaction_panel3_update_pointer_sprite_button2:
	ld bc, #5740
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 2) * 4
	jr mars_robot_puzzle_interaction_panel3_update_pointer_sprite_continue

mars_robot_puzzle_interaction_panel3_update_pointer_sprite_button3:
	ld bc, #5f40
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 2) * 4
	jr mars_robot_puzzle_interaction_panel3_update_pointer_sprite_continue


mars_robot_puzzle_interaction_panel3_loop_up:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	cp 1
	jp z, mars_robot_puzzle_interaction_panel3_loop
	cp 3
	jp z, mars_robot_puzzle_interaction_panel3_loop_to_2
mars_robot_puzzle_interaction_panel3_loop_to_1:
	ld (hl), 1
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel3_loop

mars_robot_puzzle_interaction_panel3_loop_down:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	cp 3
	jp z, mars_robot_puzzle_interaction_panel3_loop
	cp 1
	jp z, mars_robot_puzzle_interaction_panel3_loop_to_2
mars_robot_puzzle_interaction_panel3_loop_to_3:
	ld (hl), 3
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel3_loop

mars_robot_puzzle_interaction_panel3_loop_left:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	or a
	jp nz, mars_robot_puzzle_interaction_panel3_loop
mars_robot_puzzle_interaction_panel3_loop_to_2:
	ld (hl), 2
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel3_loop

mars_robot_puzzle_interaction_panel3_loop_right:
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	or a
	jp z, mars_robot_puzzle_interaction_panel3_loop
	ld (hl), 0
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jp mars_robot_puzzle_interaction_panel3_loop

mars_robot_puzzle_interaction_panel3_loop_space:
	ld a, (tmp_dialog_pointer_position)
	or a
	jp z, mars_robot_puzzle_interaction_panel_clear_box

	ld hl, SFX_ui_select
	call play_SFX_with_high_priority

	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	and #03
	dec a
	jr nz, mars_robot_puzzle_interaction_panel3_loop_space_state_2
mars_robot_puzzle_interaction_panel3_loop_space_state_1:
	ld a, (tmp_dialog_pointer_position)
	cp 3
	jp nz, mars_robot_puzzle_interaction_panel3_loop  ; wrong
	ld a, (global_state__mars_robot)
	cp 15
	jp nz, mars_robot_puzzle_interaction_panel3_loop  ; wrong
	; correct button and pressure:
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	and #fc
	or #02
	ld (global_state__objects + TAG_MARS_ROBOT_PUZZLE), a
	jp mars_robot_puzzle_interaction_panel3_loop

mars_robot_puzzle_interaction_panel3_loop_space_state_2:
	ld a, (tmp_dialog_pointer_position)
	cp 2
	jp nz, mars_robot_puzzle_interaction_panel3_loop  ; wrong
	ld a, (global_state__mars_robot)
	cp 5
	jp nz, mars_robot_puzzle_interaction_panel3_loop_space_state_2_wrong  ; wrong
	ld a, (global_state__mars_robot + 1)
	cp 10
	jp nz, mars_robot_puzzle_interaction_panel3_loop_space_state_2_wrong  ; wrong
	; correct button and pressures:
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	and #fc
	or #03
	ld (global_state__objects + TAG_MARS_ROBOT_PUZZLE), a
	; puzzle solved!
	jp mars_robot_puzzle_interaction_panel3_solved
mars_robot_puzzle_interaction_panel3_loop_space_state_2_wrong:
	ld a, (global_state__objects + TAG_MARS_ROBOT_PUZZLE)
	and #fc
	or #01
	ld (global_state__objects + TAG_MARS_ROBOT_PUZZLE), a
	jp mars_robot_puzzle_interaction_panel3_loop


;-----------------------------------------------
mars_robot_puzzle_interaction_panel3_solved:
	ld hl, SFX_secret
	call play_SFX_with_high_priority

	ld a, 23
	ld hl, NAMTBL2 + 12*32 + 11
	ld bc, 1
	call fast_FILVRM
	ld b, 10
	call wait_b_halts

	ld a, 24
	ld hl, NAMTBL2 + 12*32 + 11
	ld bc, 1
	call fast_FILVRM
	ld b, 10
	call wait_b_halts

	ld a, 25
	ld hl, NAMTBL2 + 12*32 + 11
	ld bc, 1
	call fast_FILVRM
	ld b, 10
	call wait_b_halts

	ld hl, SFX_teleport
	call play_SFX_with_high_priority

	ld a, 26
	ld hl, NAMTBL2 + 12*32 + 11
	ld bc, 1
	call fast_FILVRM

	ld b, 100
	call wait_b_halts_skippable

	call mars_robot_puzzle_interaction_panel_clear_box

	ld de, TEXT_MARS_ROBOT_SOLVED_1
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld de, TEXT_MARS_ROBOT_SOLVED_2
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld de, TEXT_MARS_ROBOT_SOLVED_3
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld de, TEXT_MARS_ROBOT_SOLVED_4
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld de, TEXT_MARS_ROBOT_SOLVED_5
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld de, TEXT_MARS_ROBOT_SOLVED_6
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	; spawn phase shifter:
	ld hl, ptr_to_new_tile_object
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	push hl
	pop iy
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 0
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_PHASE_SHIFTER
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 24  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 20  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)

	; set which object gfx to up load vdp:
; 	ld hl, buffer_4096 + 67 * 64  ; phase shifter
; 	ld (item_object_to_upload_to_vdp), hl
; 	call state_play_upload_object_tiles_to_vdp_if_necessary

	ld hl, SFX_secret
	call play_SFX_with_high_priority

	; refresh the current tile objects:
	ld hl, room_undraw_tile_objects
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ld hl, room_render_tile_objects
	ld c, TILES_PAGE
	jp call_hl_in_page_c_8000	


;-----------------------------------------------
object_interaction_function_pickup_phase_shifter_internal:
	ld hl, player_inventory_items + INVENTORY_ITEM_PHASE_SHIFTER
	ld (hl), 1
	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	ld (hl), #ff
	push ix
		ld c, TILES_PAGE
		ld hl, room_undraw_tile_objects
		call call_hl_in_page_c_8000
	pop ix
	ld c, TILES_PAGE
	ld hl, delete_tile_object_in_ix
	call call_hl_in_page_c_8000
	ld c, TILES_PAGE
	ld hl, room_render_tile_objects
	jp call_hl_in_page_c_8000


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

