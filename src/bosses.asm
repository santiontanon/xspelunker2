;-----------------------------------------------
; input:
; - ix: boss door object
enter_boss_door:
	; check if the door is open:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	ret z  ; closed

	; save where to teleport out:
	ld a, (current_room__id)
	ld (boss_door_exit_to_room), a
	ld a, (player_x + 1)
	ld (boss_door_exit_to_x), a
	ld a, (player_y + 1)
	ld (boss_door_exit_to_y), a

	; get boss number:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	ld c, 0
	sub TAG_BOSS1_CHESTLOCK
enter_boss_door_divide_by_3_loop:
	cp 3
	jr c, enter_boss_door_divide_by_3_loop_done
	inc c
	sub 3
	jr enter_boss_door_divide_by_3_loop
enter_boss_door_divide_by_3_loop_done:

	push bc
		; place player at the center of the door
		ld a, 4
		ld (player_x), a
		xor a
		ld (player_y), a
		ld (player_state), a  ; idle, facing right
		ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
		inc a
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
enter_boss_door_loop:
		halt
		ld a, (interrupt_cycle)	
		and #07
		jr nz, enter_boss_door_loop

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
			call enter_boss_door_shift_player_sprites_right

			ld hl, buffer_4096
			ld de, SPRTBL2
			ld b, 64
			call fast_small_LDIRVM
		pop bc
		djnz enter_boss_door_loop

		; clear the screen:
		call clear_screen_left_to_right
	pop bc
	push bc
		; choose which room to load, player position, etc based on the boss number:
		; - c: boss number
		; ...

		ld c, PCG_PAGE
		ld hl, pcg_generate_room_reset_state
		call call_hl_in_page_c_8000

		; setup boss area/room:
		ld hl, boss_room_1_zx0
		ld de, current_room__id
		call dzx0

		ld c, PCG_PAGE
		ld hl, pcg_generate_room__prettify_pyramid
		call call_hl_in_page_c_8000

		ld a, BOSS_PAGE
		ld (current_room__tileset_page), a
		ld hl, boss_1_tiles_zx0
		ld (current_room__tileset_ptr), hl
		ld hl, update_animations_in_vdp_none
		ld (current_room__animation_fn_ptr), hl
		ld hl, tile_collision_types_boss1
		ld (current_room__collision_ptr), hl
		ld a, BOSS_PAGE
		ld (current_room__collision_ptr_page), a
		ld hl, boss1_sprites_zx0
		ld (current_room__enemy_sprites_ptr), hl
		ld hl, 0
		ld (large_object_to_upload_to_vdp), hl
		xor a
		ld (boss__behavior), a
		ld (boss__state), a
		ld (boss__state_timer), a
		inc a
		ld (current_room__tileset_overrides_item_tiles), a

		ld hl, state_play_update_agenda_boss
		ld (state_play_update_agenda_tbl_ptr), hl

		; player position:
		ld hl, player_x
		ld (hl), 0
		inc hl
		ld (hl), 3
		inc hl
		ld (hl), 0
		inc hl
		ld (hl), 20

		; make a copy of the boss room so that we can restore the background as the boss moves:
		ld hl, current_room__tile_map
		ld de, current_room__tile_map + 32*24*2
		ld bc, 32*24*2
		ldir
		; clear the bbox:
		ld hl, boss__clear_bbox + 2
		ld (hl), 0
		inc hl
		ld (hl), 0
	pop bc

; enter_boss_door_loop__spawn_stone:
; 	; DEBUG: spawn power stone
; 	; - c: boss number
; 	ld a, c
; 	ld b, TAG_POWER_STONE
; 	ld hl, buffer_4096 + 47 * 64  ; power stone
; 	cp 5  ; 6th and 7th bosses drop half stones
; 	jr c, enter_boss_door__spawn_item_set
; 	ld hl, buffer_4096 + 61 * 64  ; puzzlebox
; 	ld b, TAG_PUZZLEBOX_MARS
; 	cp 5
; 	jr z, enter_boss_door__spawn_item_set
; 	ld b, TAG_PUZZLEBOX_MOON
; enter_boss_door__spawn_item_set:
; 	ld iy, (tmp_pcg_room__next_tile_object_ptr)
; 	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), c  ; ID is the boss number
; 	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), b  ; type
; 	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 15  ; x
; 	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 20  ; y
; 	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
; 	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
; 	add iy, bc
; 	ld (tmp_pcg_room__next_tile_object_ptr), iy

; 	; set which object gfx to up load vdp:
; 	ld (item_object_to_upload_to_vdp), hl

	jp state_play_from_loaded_room


;-----------------------------------------------
; input:
; - a: number of pixels to shift
enter_boss_door_shift_player_sprites_right:
	or a
	ret z
enter_boss_door_shift_player_sprites_right_loop:
	push af
		call enter_boss_door_shift_player_sprites_right_1pixel
	pop af
	dec a
	jr nz, enter_boss_door_shift_player_sprites_right_loop
	ret

enter_boss_door_shift_player_sprites_right_1pixel:
	ld b, 16
	ld hl, buffer_4096
	ld de, buffer_4096 + 16
enter_boss_door_shift_player_sprites_right_1pixel_loop:
	or a
	rr (hl)
	ex de, hl
	rr (hl)
	ex de, hl
	inc hl
	inc de
	djnz enter_boss_door_shift_player_sprites_right_1pixel_loop

	ld b, 16
	ld hl, buffer_4096 + 32
	ld de, buffer_4096 + 48
enter_boss_door_shift_player_sprites_right_1pixel_loop2:
	or a
	rr (hl)
	ex de, hl
	rr (hl)
	ex de, hl
	inc hl
	inc de
	djnz enter_boss_door_shift_player_sprites_right_1pixel_loop2
	ret


;-----------------------------------------------
; input:
; - ix: power stone object
pick_up_boss_power_stone:
	; add to inventory:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	add a, 7
	ld hl, player_inventory_items
	ADD_HL_A
	ld (hl), 1

	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	push af

		; message:
		ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
		ld de, TEXT_FIRST_POWER_STONE
		or a
		jr z, pick_up_boss_power_stone_continue
		ld de, TEXT_OTHER_POWER_STONES
pick_up_boss_power_stone_continue:
		ld c, TEXT_PAGE
		ld hl, display_in_game_message
		call call_hl_in_page_c_8000

		call disable_VDP_output

		; teleport outside (store room/position before entering boss room):
		ld a, (boss_door_exit_to_room)
		ld e, a
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

		ld a, (boss_door_exit_to_x)
		ld (player_x + 1), a
		ld a, (boss_door_exit_to_y)
		ld (player_y + 1), a

	; set event to close the door:
	pop af
	ld (in_game_event_fn_arg), a
	ld hl, event__exit_boss_door
	ld (in_game_event_fn_ptr), hl
	ld a, BOSS_PAGE
	ld (in_game_event_fn_page), a

	jp state_play_from_loaded_room


;-----------------------------------------------
; pick_up_boss_half_power_stone:
pick_up_boss_puzzlebox_mars:
	ld hl, player_inventory_items + INVENTORY_ITEM_PUZZLEBOX_MARS
	ld (hl), 1
	jr pick_up_boss_puzzlebox_continue
pick_up_boss_puzzlebox_moon:
	ld hl, player_inventory_items + INVENTORY_ITEM_PUZZLEBOX_MOON
	ld (hl), 1
pick_up_boss_puzzlebox_continue:
	; set event to close the door:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	push af

		ld hl, SFX_item_pickup
		call play_SFX_with_high_priority

		ld de, TEXT_FOUND_PUZZLEBOX
		jr pick_up_boss_power_stone_continue

	; message:
; 	ld de, TEXT_FOUND_HALF_POWER_STONE  ; TEXT_FOUND_SECOND_HALF_POWER_STONE
; 	jr pick_up_boss_power_stone_continue

; pick_up_boss_second_half_power_stone:
; 	ld (hl), 0  ; remove the half stone
; 	ld hl, player_inventory_items + 7 + 5
; 	ld (hl), 1  ; gain a full power stone
; 	; message:
; 	ld de, TEXT_FOUND_SECOND_HALF_POWER_STONE
; 	jr pick_up_boss_power_stone_continue


;-----------------------------------------------
event__exit_boss_door:
	; update boss state as killed (so that boss door does not spawn any more):
	ld a, (in_game_event_fn_arg)
	ld c, a
	add a, a
	add a, c
	add a, TAG_BOSS1_CHESTLOCK
	ld hl, global_state__objects
	ADD_HL_A
	ld (hl), 2

	; animation of the door disappearing:
	ld hl, SFX_explosion
	call play_SFX_with_high_priority

	ld b, 4
event__exit_boss_door_loop:
	push bc
		ld b, 30
		call wait_b_halts

		ld hl, CHRTBL2 + FIRST_LARGE_ITEM_TILE*8
		call shift_boss_door_down
		ld hl, CHRTBL2 + (256+FIRST_LARGE_ITEM_TILE)*8
		call shift_boss_door_down
		ld hl, CHRTBL2 + (512+FIRST_LARGE_ITEM_TILE)*8
		call shift_boss_door_down
		ld hl, SFX_explosion
		call play_SFX_with_high_priority
	pop bc
	djnz event__exit_boss_door_loop

	; find the door tile object:
event__exit_boss_door_remove_door_object:
	ld c, TILES_PAGE
	ld hl, room_undraw_tile_objects
	call call_hl_in_page_c_8000

	call find_boss_door_object_ptr
	jr nz, event__exit_boss_door_no_door_to_remove  ; not found (should never happen)
	ld c, TILES_PAGE
	ld hl, delete_tile_object_in_ix
	call call_hl_in_page_c_8000

event__exit_boss_door_no_door_to_remove:
	ld c, TILES_PAGE
	ld hl, room_render_tile_objects
	jp call_hl_in_page_c_8000


;-----------------------------------------------
; output:
; - z: door found
; - nz: door not found
; - hl: door ptr
find_boss_door_object_ptr:
	ld ix, current_room__tile_objects
find_boss_door_object_ptr_loop:
	ld a, (ix)
	cp #fe  ; sentinel in tile objects is #fe
	jr z, find_boss_door_object_ptr_not_found
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)  ; type
	cp TAG_DOOR_BOSS
	ret z
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add ix, bc
	jr find_boss_door_object_ptr_loop
find_boss_door_object_ptr_not_found:
	or 1
	ret


;-----------------------------------------------
shift_boss_door_down:
	push hl
		ld de, buffer_4096
		ld bc, 12*8
		call LDIRMV
	pop hl
	push hl
		ld bc, 4*8
		add hl, bc
		ex de, hl
		ld hl, buffer_4096
		ld bc, 12*8
		call fast_LDIRVM
	pop hl
	ld bc, 4*8
	jp fast_FILVRM


;-----------------------------------------------
; input:
; - de: ptr to draw to
; - hl: ptr to frame struct
draw_boss_frame:
	push hl
	push de
		call draw_boss_frame_clear_previous_frame
	pop de
	pop hl

	ld a, (hl)  ; number of frame parts
	inc hl
	or a
	ret z
	ld b, a
	push de
draw_boss_frame_loop:
		push bc
			push de
				ld c, (hl)  ; x offset
				inc hl
				ld b, 0
				ex de, hl
					add hl, bc  ; add x offset
				ex de, hl
				ld a, (current_room__width)
				ld c, a
				ld a, (hl)  ; y offset
				inc hl
				or a
				jr z, draw_boss_frame_loop_continue
				ex de, hl
draw_boss_frame_loop_y_offset_loop:
					add hl, bc
					dec a
					jr nz, draw_boss_frame_loop_y_offset_loop
				ex de, hl
draw_boss_frame_loop_continue:
				ld c, (hl)  ; width
				inc hl
				ld b, (hl)  ; height
				inc hl
				push hl
					ld a, (hl)
					inc hl
					ld h, (hl)
					ld l, a
					call draw_boss_frame_part
				pop hl
			pop de
			inc hl
			inc hl
		pop bc
		djnz draw_boss_frame_loop
		; set clear bbox:
		ld c, (hl)
		inc hl
		ld b, (hl)  ; bc is the offset wrt original draw pointer
		inc hl
		ld de, boss__clear_bbox + 2
		push bc
			ldi
			ldi
		pop bc
	pop hl
	add hl, bc
	ld (boss__clear_bbox), hl
	ret


;-----------------------------------------------
draw_boss_frame_clear_previous_frame:
		; clear the previous frame
		ld bc, (boss__clear_bbox + 2)
		ld a, c
		or b
		ret z
		ld hl, (boss__clear_bbox)
		ld e, l
		ld d, h
		push bc
			ld bc, boss__room_bg_buffer - current_room__tile_map
			add hl, bc
		pop bc
		; here:
		; - hl: points to the bg buffer
		; - de: points to the room part we want to clear
draw_boss_frame_clear_previous_frame_y_loop:
	push bc
		ld b, 0

		; if "de" < current_room__tile_map, skip row  ->  draw_boss_frame_clear_previous_frame_y_loop_skip
		ex de, hl
		push bc
		push hl
			ld bc, current_room__tile_map
			or a  ; clear carry flag
			sbc hl, bc
		pop hl
		pop bc
		ex de, hl
		jr c, draw_boss_frame_clear_previous_frame_y_loop_skip

		push hl
		push de
			ldir
		pop de
		pop hl
draw_boss_frame_clear_previous_frame_y_loop_skip:
		ld a, (current_room__width)
		ld c, a
		add hl, bc
		ex de, hl
			add hl, bc
		ex de, hl
	pop bc
	djnz draw_boss_frame_clear_previous_frame_y_loop
	ret


;-----------------------------------------------
; input:
; - hl: frame ptr
; - de: destination ptr
; - c, b: width, height
draw_boss_frame_part:
draw_boss_frame_part_loop_y:
	push bc
		push de
			; if "de" < current_room__tile_map, skip row  ->  draw_boss_frame_part_loop_y_skip
			ex de, hl
			push bc
			push hl
				ld bc, current_room__tile_map
				or a  ; clear carry flag
				sbc hl, bc
			pop hl
			pop bc
			ex de, hl
			jr c, draw_boss_frame_part_loop_y_skip

			ld b, c
draw_boss_frame_part_loop_x:
			ld a, (hl)
			or a
			jr z, draw_boss_frame_part_loop_x_skip
			ld (de), a
draw_boss_frame_part_loop_x_skip:
			inc hl
			inc de
			djnz draw_boss_frame_part_loop_x
draw_boss_frame_part_loop_y_skip2:
		pop de
		ex de, hl
		ld a, (current_room__width)
		; ld b, 0
		ld c, a
		add hl, bc
		ex de, hl
	pop bc
	djnz draw_boss_frame_part_loop_y
	ret
draw_boss_frame_part_loop_y_skip:
			; advance 'hl':
			ld b, 0
			add hl, bc
			jr draw_boss_frame_part_loop_y_skip2


;-----------------------------------------------
; input:
; - c, b: tile coordinate from where the bullet is fired
; - ixl, ixh: pixel offset
boss_fire_directional_bullet_towards_player_with_random_offset:
	; see if player is close enough:
	ld a, (player_x + 1)
	sub c
	ld e, a
	ld a, (player_y + 1)
	sub b
	ld d, a
	push bc
		ld c, 3
		call random_modulo
		dec a
		add a, e
		ld e, a
		ld c, 3
		call random_modulo
		dec a
		add a, d
		ld d, a
		jr boss_fire_directional_bullet_towards_player_continue


;-----------------------------------------------
; input:
; - c, b: tile coordinate from where the bullet is fired
; - ixl, ixh: pixel offset
boss_fire_directional_bullet_towards_player:
	; see if player is close enough:
	ld a, (player_x + 1)
	sub c
	ld e, a
	ld a, (player_y + 1)
	sub b
	ld d, a
	push bc
boss_fire_directional_bullet_towards_player_continue:	
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ret nz
	ld (hl), ENEMY_BULLET
	inc hl
	ld a, ixl
	ld (hl), a  ; pixel X
	inc hl
	ld (hl), c  ; tile X
	inc hl
	ld a, ixh
	ld (hl), a  ; pixel Y
	inc hl
	ld (hl), b  ; tile Y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), e  ; speed x
	inc hl
	ld (hl), d  ; speed y
	ld hl, SFX_enemy_bullet
	jp play_SFX_with_high_priority


;-----------------------------------------------
update_boss_behavior:
	ld a, (current_area__id)
	cp 1
	jp z, update_boss1_behavior


	; ...
	ret



;-----------------------------------------------
tile_collision_types_boss1:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 0, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 3, 3, 3
    db 0, 0, 3, 3, 0, 0, 0, 0, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 0, 3, 5, 2, 2, 5, 6, 3, 1, 1, 1, 2, 3, 2, 2
    db 3, 3, 3, 3, 3, 3, 2, 2, 2, 3, 2, 2, 3, 3, 3, 3
    db 3, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3
    db 3, 3, 3, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 3, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 3, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3
    db 3, 3, 3, 2, 2, 3, 2, 2, 3, 3, 3, 3, 3, 2, 1, 5
