;-----------------------------------------------
; output:
; - z: we could find a new ptr
; - nz: no ptrs available
; - hl: ptr if one was available
ptr_to_new_tile_object:
	ld hl, current_room__tile_objects
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
ptr_to_new_tile_object_loop:
	ld a, (hl)
	inc a  ; cp #ff
	ret z
	inc a  ; cp #fe
	jr z, ptr_to_new_tile_object_reached_sentinel
	add hl, de
	jp ptr_to_new_tile_object_loop
ptr_to_new_tile_object_reached_sentinel:
	or 1
	ret


;-----------------------------------------------
; input:
; - c, b: x, y tile coordinates
; spawn_tile_object_5_coins:
; 	ld e, 5
; 	jr spawn_tile_object_e_coins
spawn_tile_object_1_coin:
	ld e, 1
spawn_tile_object_e_coins:
	push bc
	push de
		call room_undraw_tile_objects
	pop de
	pop bc
	ld d, TAG_COIN
spawn_tile_object_continue:
	push de
		call ptr_to_new_tile_object
	pop de
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), d  ; type
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), e  ; state (number of coins/live/arrows, etc.)
	jp room_render_tile_objects


spawn_tile_object_corn:
	push bc
		call room_undraw_tile_objects
	pop bc
	ld d, TAG_CORN
	ld e, 4
	jp spawn_tile_object_continue


spawn_tile_object_5_stones:
	push bc
		call room_undraw_tile_objects
	pop bc
	ld d, TAG_STONES
	ld e, 5
	jp spawn_tile_object_continue


spawn_tile_object_5_darts:
	push bc
		call room_undraw_tile_objects
	pop bc
	ld d, TAG_DARTS
	ld e, 5
	jp spawn_tile_object_continue


spawn_tile_object_5_spears:
	push bc
		call room_undraw_tile_objects
	pop bc
	ld d, TAG_SPEARS
	ld e, 5
	jp spawn_tile_object_continue


spawn_tile_object_battery:
	push bc
		call room_undraw_tile_objects
	pop bc
	ld d, TAG_BATTERY
	ld e, 5
	jp spawn_tile_object_continue


;-----------------------------------------------
update_tile_objects:
	ld hl, current_room__tile_objects
update_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff
	ret z
	cp #fe
	ret z
	; render the object:
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_PUSHABLE_BLOCK
		jr z, update_tile_objects_pushable_block
		cp TAG_BUTTON1
		jp z, update_tile_objects_button
		cp TAG_BUTTON2
		jp z, update_tile_objects_button
		cp TAG_BUTTON3
		jp z, update_tile_objects_button
		cp TAG_BUTTON4
		jp z, update_tile_objects_button
		cp TAG_CALENDAR_STONE_CENTER
		jp z, update_tile_objects_calendar_stone_center
		cp TAG_ENEMY_CARNIVORE_PLANT
		jp z, update_tile_objects_enemy_carnivore_plant
		cp TAG_ENEMY_BEE_HIVE
		jp z, update_tile_objects_enemy_bee_hive
		cp TAG_ENEMY_ANT_COLONY
		jp z, update_tile_objects_enemy_ant_colony
		cp TAG_ENEMY_ANT_COLONY2
		jp z, update_tile_objects_enemy_ant_colony2
		cp TAG_ENEMY_IMP_GENERATOR
		jp z, update_tile_objects_enemy_imp_generator
		cp TAG_ENEMY_IMP_GENERATOR2
		jp z, update_tile_objects_enemy_imp_generator2
		cp TAG_ENEMY_FIREBALL_GENERATOR
		jp z, update_tile_objects_enemy_fireball_generator
		cp TAG_ENEMY_LAVA_GENERATOR
		jp z, update_tile_objects_enemy_lava_generator
		cp TAG_ENEMY_STONE_OWL
		jp z, update_tile_objects_enemy_stone_owl
		cp TAG_ENEMY_SENTINEL
		jp z, update_tile_objects_enemy_sentinel
		cp TAG_LOST_VENDOR
		jp z, update_tile_objects_lost_vendor
update_tile_objects_loop_continue:
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp update_tile_objects_loop


;-----------------------------------------------
; input:
; - hl: ptr to object + 1
update_tile_objects_pushable_block:
	inc hl
	ld c, (hl)  ; x
	inc hl
	ld b, (hl)  ; y
	push hl
		inc b
		inc b
		push bc
			call get_room_tile_type
		pop bc
		; blocks collide with:
		;   1: platform (you can jump through)
		;   2: wall
		;   6: rope-platform-top
		;   8: ladder-platform-top
		dec a  ; 1
		jr z, update_tile_objects_pushable_block_collision
		dec a  ; 2
		jr z, update_tile_objects_pushable_block_collision
		cp 6 - 2  ; 6
		jr z, update_tile_objects_pushable_block_collision
		cp 8 - 2  ; 8
		jr z, update_tile_objects_pushable_block_collision

		inc c
		call get_room_tile_type
		dec a  ; 1
		jr z, update_tile_objects_pushable_block_collision
		dec a  ; 2
		jr z, update_tile_objects_pushable_block_collision
		cp 6 - 2  ; 6
		jr z, update_tile_objects_pushable_block_collision
		cp 8 - 2  ; 8
		jr z, update_tile_objects_pushable_block_collision

		; block should fall!
		ld c, TILES_PAGE
		ld hl, room_undraw_tile_objects
		call call_hl_in_page_c_8000
	pop hl
	ld a, (hl)  ; block y
	inc a
	ld (hl), a
	inc hl
	ld (hl), 1  ; state: falling

	; see if we are out of screen bounds:
	ld b, a
	ld a, (current_room__height)	
	cp b
	jr z, update_tile_objects_pushable_block_remove

	; See if we hit the player:
	dec hl
	ld b, (hl)
	dec hl
	ld c, (hl)  ; c, b: block coordinates
	ld a, (player_x + 1)
	cp c
	jr c, update_tile_objects_pushable_block_no_player_hit
	inc c
	inc c
	cp c
	jr nc, update_tile_objects_pushable_block_no_player_hit
	ld a, (player_y + 1)
	inc b
	cp b
	jr nz, update_tile_objects_pushable_block_no_player_hit

	; move the player on top of the block, to prevent getting trapped:
	sub 2
	ld (player_y + 1), a
	call player_hit_hazard

update_tile_objects_pushable_block_no_player_hit:
	call room_render_tile_objects

	; force redraw:
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	jp update_tile_objects_loop_continue

update_tile_objects_pushable_block_collision:
	pop hl
	dec hl
	ld c, (hl)  ; x
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld a, (hl)
	or a
	jp z, update_tile_objects_loop_continue
	; block just fell on top of something:
	ld (hl), 0  ; state: still
	call spawn_pushing_block_dust
	jp update_tile_objects_loop_continue


update_tile_objects_pushable_block_remove:
	dec hl
	dec hl
	dec hl
	dec hl
update_tile_objects_delete_object:
	push hl
		call delete_tile_object_in_hl

		call room_render_tile_objects
		; force redraw:
		ld hl, redraw_flags
		set ROOM_REDRAW_FLAG_BIT, (hl)
	pop hl
	pop af  ; we do an extra pop, since we are skipping the one at update_tile_objects_loop_continue
	jp update_tile_objects_loop


;-----------------------------------------------
update_tile_objects_button:
		ld e, a  ; save the object type
		ld a, (player_x + 1)
		ld c, a
		ld a, (player_y + 1)
		ld b, a
		inc hl
		ld a, (hl)  ; x
		inc hl
		cp c
		jr z, update_tile_objects_button_x_ok
		dec c
		cp c
		jr nz, update_tile_objects_button_next
	update_tile_objects_button_x_ok:
		ld a, (hl)  ; y
		cp b
		jr nz, update_tile_objects_button_next
		; player is on top:

		; see if it's already pressed:
		ld hl, global_state__objects
		ld d, 0
		add hl, de
		ld a, (hl)
		or a
		jr nz, update_tile_objects_button_next  ; it was already pressed

		; press button, and open the door:
		ld (hl), 1

		; 'e' contains the object type
		ld hl, set_item_object_to_upload_to_vdp
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

		ld hl, redraw_flags
		ld (hl), #ff

	pop ix  ; recover object ptr

	; update door state:
	ld hl, global_state__objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	add TAG_BUTTON_DOOR1 - TAG_BUTTON1
	ADD_HL_A
	ld (hl), 1  ; lock is open

	jp object_interaction_function_open_small_lock_entry_point

update_tile_objects_button_next:
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp update_tile_objects_loop


;-----------------------------------------------
update_tile_objects_calendar_stone_center:
	; just force redrawing, since this object has an animation:
	ld a, (global_state__n_power_stones_in_calendar)
	cp 5
	jp c, update_tile_objects_loop_continue

update_tile_objects_loop_force_redraw_and_continue
	call room_undraw_tile_objects
	call room_render_tile_objects
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	jp update_tile_objects_loop_continue


;-----------------------------------------------
update_tile_objects_lost_vendor:
	ld a, (global_state__story)
	cp STORY_STATE__FOUND_LOST_VENDOR
	jp z, update_tile_objects_delete_object
	push hl
	pop ix
	dec ix
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	or a
	jp nz, update_tile_objects_loop_continue
	; spawn sprite object:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 1
	call ptr_to_new_sprite_object
	jp nz, update_tile_objects_loop_continue
	ld (hl), 0  ; ID
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_LOST_VENDOR
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld (hl), a
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	ld (hl), a
	jp update_tile_objects_loop_continue


;-----------------------------------------------
delete_tile_object_in_ix:
	push ix
	pop hl
	; jr delete_tile_object_in_hl


;-----------------------------------------------
; input:
; - hl: ptr of the tile object to delete
delete_tile_object_in_hl:
	; copy:
	; - from: hl + ROOM_TILE_OBJECT_STRUCT_SIZE
	; - to: hl
	; - amount: (current_room__tile_objects_sentinel - (hl + ROOM_TILE_OBJECT_STRUCT_SIZE)
	; to:
	ld (hl), #ff  ; only really needed for the last object, but just in case
	ld e, l
	ld d, h
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	push hl
		ld c, l
		ld b, h
		ld hl, current_room__tile_objects_sentinel  ; + 1 to at least copy the sentinel for the last element
		or a
		sbc hl, bc
		ld c, l
		ld b, h
	pop hl
	ld a, b  ; not needed, as we will always at least copy 1 byte
	or c
	ret z
	ldir
	; delete the last object:
	ld hl, current_room__tile_objects + ((MAX_ROOM_TILE_OBJECTS - 1) * ROOM_TILE_OBJECT_STRUCT_SIZE)
	ld (hl), #ff
	ret


;-----------------------------------------------
; Replaces background tiles by those corresponding to the current object, and stores the previous background
; in the tile object background buffer
room_render_tile_objects:
	ld hl, current_room__tile_objects
room_render_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff
	ret z
	cp #fe
	ret z
	; render the object:
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_BREAKABLE_WALL1
		jp z, room_render_tile_objects_loop_continue
		cp TAG_BREAKABLE_WALL2
		jr z, room_render_tile_objects_loop_continue
		cp TAG_BREAKABLE_WALL3
		jr z, room_render_tile_objects_loop_continue
		cp TAG_BREAKABLE_WALL4
		jr z, room_render_tile_objects_loop_continue
		cp TAG_DOOR_VERTICAL
		jp z, room_render_tile_objects_render_v_door
		cp TAG_DOOR_HORIZONTAL
		jp z, room_render_tile_objects_render_h_door
		cp TAG_COMBINATION1_LOCK
		jp z, room_render_tile_objects_render_combination_lever
		cp TAG_COMBINATION2_LOCK
		jp z, room_render_tile_objects_render_combination_lever
		cp TAG_COMBINATION3_LOCK
		jp z, room_render_tile_objects_render_combination_lever
		cp TAG_COMBINATION4_LOCK
		jp z, room_render_tile_objects_render_combination_lever
		cp TAG_CALENDAR_SOCKET
		jp z, room_render_tile_objects_render_calendar_socket
		cp TAG_CALENDAR_STONE_CENTER
		jp z, room_render_tile_objects_render_calendar_stone_center
		cp TAG_ENEMY_CARNIVORE_PLANT
		jp z, room_render_tile_objects_render_enemy_carnivore_plant
		cp TAG_ENEMY_LAVA_GENERATOR
		jp z, room_render_tile_objects_render_enemy_lava_generator
		cp TAG_ENEMY_STONE_OWL
		jp z, room_render_tile_objects_render_enemy_stone_owl
		cp TAG_ENEMY_SENTINEL
		jp z, room_render_tile_objects_render_enemy_sentinel
		cp TAG_POSEIDON_LEVER
		jp z, room_render_tile_objects_render_combination_lever
		cp TAG_POSEIDON_BOSS_DISPLAY
		jp z, room_render_tile_objects_render_poseidon_boss_display
		inc hl
		ld c, (hl)  ; x
		ld iyl, c
		inc hl
		ld b, (hl)  ; y
		ld iyh, b

		ld l, a
		ld h, 0
		add hl, hl
		add hl, hl
		ADD_HL_A  ; hl = a * 5
		ld bc, tile_object_gfx_table
		add hl, bc
		ld a, (hl)
		or a
		jr nz, room_render_tile_objects_loop_continue2
	pop ix  ; recover the ptr to the object
	push ix
		ld bc, ROOM_TILE_OBJECT_STRUCT_BACKGROUND
		add ix, bc  ; ix = ptr to background buffer
		call room_render_tile_objects_render_saving_background  ; type 0: saving background
		jp room_render_tile_objects_loop_continue
room_render_tile_objects_loop_continue2:
		dec a
		jr nz, room_render_tile_objects_loop_continue
		call room_render_tile_objects_render  ; type 1: rendering directly
room_render_tile_objects_loop_continue:
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp room_render_tile_objects_loop


;-----------------------------------------------
; input:
; - ix: ptr to the background buffer
; - hl: ptr to tile_object_gfx_table: type, width, height, ptr to gfx
; - iyl, iyh: x, y of the object
room_render_tile_objects_render_saving_background:
	; - hl: ptr to tile_object_gfx_table
	; - ixl, ixh: x, y of the object
	inc hl
	ld c, (hl)  ; width
	inc hl
	ld b, (hl)  ; height
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)  ; de = ptr to the graphics
	; compute ptr where to draw:
	push bc
		ld c, iyl
		ld b, iyh
		call get_room_tile_ptr
	pop bc
	push iy
room_render_tile_objects_render_saving_background_loop_y:
		push iy
		push bc
		push hl
room_render_tile_objects_render_saving_background_loop_x:
			; check that:
			; - iyl < current_room__width
			; - iyl >= 0
			; - iyh < current_room__height
			ld a, (current_room__width)
			cp iyl
			jr z, room_render_tile_objects_render_saving_background_loop_x_continue
			jr c, room_render_tile_objects_render_saving_background_loop_x_continue
			ld a, iyl
			or a
			jp m, room_render_tile_objects_render_saving_background_loop_x_continue
			ld a, (current_room__height)
			cp iyh
			jr z, room_render_tile_objects_render_saving_background_loop_x_continue
			jr c, room_render_tile_objects_render_saving_background_loop_x_continue

			; save background:
			ld a, (hl)
			ld (ix), a
			ld a, (de)
			or a
			jr z, room_render_tile_objects_render_saving_background_loop_x_continue
			ld (hl), a
room_render_tile_objects_render_saving_background_loop_x_continue:
			inc de
			inc hl
			inc ix
			inc iyl
			ld a, iyl
			or a
			jr nz, room_render_tile_objects_render_saving_background_loop_x_continue2
			; if ixl turned 0, it means the previous pointer was probably bad, so, we need to recompute it:
			push bc
				ld c, iyl
				ld b, iyh
				call get_room_tile_ptr					
			pop bc
room_render_tile_objects_render_saving_background_loop_x_continue2:
			dec c
			jr nz, room_render_tile_objects_render_saving_background_loop_x
		pop hl
		pop bc
		pop iy
		inc iyh
		ld a, (current_room__width)
		ADD_HL_A
		djnz room_render_tile_objects_render_saving_background_loop_y
	pop iy
	ret


;-----------------------------------------------
; input:
; - hl: ptr to tile_object_gfx_table
; - iyl, iyh: x, y of the object
room_render_tile_objects_render:
	; Note, we do not need to take into account room bounds here, since this method
	; is for objects that are static, and hence will always be within screen bounds.
	inc hl
	ld c, (hl)  ; width
	inc hl
	ld b, (hl)  ; height
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)  ; de = ptr to the graphics
room_render_tile_objects_render_entry_point:
	; compute ptr where to draw:
	push bc
		ld c, iyl
		ld b, iyh
		call get_room_tile_ptr
	pop bc
room_render_tile_objects_render_loop_y:
	push bc
	push hl
room_render_tile_objects_render_loop_x:
		ld a, (de)
		ld (hl), a
		inc de
		inc hl
		dec c
		jr nz, room_render_tile_objects_render_loop_x
	pop hl
	pop bc
	ld a, (current_room__width)
	ADD_HL_A
	djnz room_render_tile_objects_render_loop_y
	ret


;-----------------------------------------------
room_render_tile_objects_render_v_door:
	inc hl
	ld c, (hl)  ; x
	ld iyl, c
	inc hl
	ld b, (hl)  ; y
	ld iyh, b
	ld bc, #0301
	inc hl
	inc hl
	inc hl
	inc hl
	ld de, tile_object_v_door_gfx
room_render_tile_objects_render_entry_point_jp:
	call room_render_tile_objects_render_entry_point
	jp room_render_tile_objects_loop_continue


room_render_tile_objects_render_h_door:
	inc hl
	ld c, (hl)  ; x
	ld iyl, c
	inc hl
	ld b, (hl)  ; y
	ld iyh, b
	ld bc, #0104
	inc hl
	inc hl
	inc hl
	inc hl
	ld de, tile_object_h_door_gfx
	jp room_render_tile_objects_render_entry_point_jp


room_render_tile_objects_render_combination_lever:
	inc hl
	ld c, (hl)  ; x
	ld iyl, c
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld iyh, b
	ld bc, #0202
	ld a, (hl)
	add a, a
	add a, a
	ld de, tile_object_lever_left_object_gfx
	ADD_DE_A
	inc hl
	inc hl
	inc hl
	jp room_render_tile_objects_render_entry_point_jp


room_render_tile_objects_render_calendar_socket:
	inc hl
	ld c, (hl)  ; x
	ld iyl, c
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld iyh, b
	ld bc, #0202
	ld a, (hl)  ; state
	cp 2
	jr c, room_render_tile_objects_render_calendar_socket_continue
	ld a, 2
room_render_tile_objects_render_calendar_socket_continue:
	add a, a
	add a, a
	ld de, tile_object_calendar_socket_gfx
	ADD_DE_A
	inc hl
	inc hl
	inc hl
	jp room_render_tile_objects_render_entry_point_jp


room_render_tile_objects_render_calendar_stone_center:
	inc hl
	ld c, (hl)  ; x
	ld iyl, c
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld iyh, b
	ld bc, #0202
	inc hl
	inc hl
	inc hl
	ld de, tile_object_calendar_stone_center_gfx
	ld a, (global_state__n_power_stones_in_calendar)
	cp 5
	jp c, room_render_tile_objects_render_entry_point_jp
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	rrca
	and #03
	jp z, room_render_tile_objects_render_entry_point_jp
	ld de, tile_object_calendar_stone_center_frame3_gfx
	cp 2
	jp z, room_render_tile_objects_render_entry_point_jp
	ld de, tile_object_calendar_stone_center_frame2_gfx
	jp room_render_tile_objects_render_entry_point_jp


room_render_tile_objects_render_poseidon_boss_display:
	inc hl
	ld c, (hl)  ; x
	ld iyl, c
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld iyh, b
	ld bc, #0202
	ld a, (hl)
	add a, a
	add a, a
	ld de, tile_object_poseidon_boss_display_object_gfx
	ADD_DE_A
	inc hl
	inc hl
	inc hl
	jp room_render_tile_objects_render_entry_point_jp


;-----------------------------------------------
; restores the background that was removed by tile objects
room_undraw_tile_objects:
	ld hl, current_room__tile_objects_sentinel - ROOM_TILE_OBJECT_STRUCT_SIZE  ; ptr to the last object
	ld b, (current_room__tile_objects_sentinel - current_room__tile_objects)/ROOM_TILE_OBJECT_STRUCT_SIZE
room_undraw_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff  ; no object in this spot
	jr z, room_undraw_tile_objects_loop_continue_no_pop
; 	cp #fe  ; sentinel
; 	jr z, room_undraw_tile_objects_loop_continue_no_pop
	; undraw the object:
	push bc
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_BREAKABLE_WALL1
		jr z, room_undraw_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL2
		jr z, room_undraw_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL3
		jr z, room_undraw_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL4
		jr z, room_undraw_tile_objects_loop_continue		
		cp TAG_ENEMY_CARNIVORE_PLANT
		jp z, room_render_tile_objects_undraw_enemy_carnivore_plant		
		cp TAG_ENEMY_LAVA_GENERATOR
		jp z, room_render_tile_objects_undraw_enemy_lava_generator
		cp TAG_ENEMY_STONE_OWL
		jp z, room_render_tile_objects_undraw_enemy_stone_owl
		cp TAG_ENEMY_SENTINEL
		jp z, room_render_tile_objects_undraw_enemy_sentinel
		inc hl
		ld c, (hl)  ; x
		ld ixl, c
		inc hl
		ld b, (hl)  ; y
		ld ixh, b

		ld l, a
		ld h, 0
		add hl, hl
		add hl, hl
		ADD_HL_A  ; hl = a * 5
		ld bc, tile_object_gfx_table
		add hl, bc
		ld a, (hl)
		or a
		jr nz, room_undraw_tile_objects_loop_continue2
	pop iy
	push iy
		ld bc, ROOM_TILE_OBJECT_STRUCT_BACKGROUND
		add iy, bc
		call room_undraw_tile_objects_restore_background  ; type 0: we had saved the background
		jr room_undraw_tile_objects_loop_continue
room_undraw_tile_objects_loop_continue2:
		dec a
		jr z, room_undraw_tile_objects_delete_object  ; type 1: we just replace with 0s
room_undraw_tile_objects_loop_continue:
	pop hl
	pop bc
room_undraw_tile_objects_loop_continue_no_pop:
	ld de, -ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, de
	djnz room_undraw_tile_objects_loop
	ret


;-----------------------------------------------
; input:
; - iy: ptr to background buffer
; - hl: ptr to tile_object_gfx_table: type, width, height
; - ixl, ixh: x, y of the object
room_undraw_tile_objects_restore_background:
	inc hl
	ld c, (hl)  ; width
	inc hl
	ld b, (hl)  ; height
	; compute ptr where to draw:
	push bc
		ld c, ixl
		ld b, ixh
		call get_room_tile_ptr
	pop bc
	push ix
room_undraw_tile_objects_restore_background_loop_y:
		push ix
		push bc
		push hl
room_undraw_tile_objects_restore_background_loop_x:
			; check that:
			; - ixl < current_room__width
			; - ixl >= 0
			; - ixh < current_room__height
			ld a, (current_room__width)
			cp ixl
			jr z, room_undraw_tile_objects_restore_background_loop_x_continue
			jr c, room_undraw_tile_objects_restore_background_loop_x_continue
			ld a, ixl
			or a
			jp m, room_undraw_tile_objects_restore_background_loop_x_continue
			ld a, (current_room__height)
			cp ixh
			jr z, room_undraw_tile_objects_restore_background_loop_x_continue
			jr c, room_undraw_tile_objects_restore_background_loop_x_continue

			; restore background:
			ld a, (iy)
			ld (hl), a
room_undraw_tile_objects_restore_background_loop_x_continue
			inc hl
			inc iy
			inc ixl
			ld a, ixl
			or a
			jr nz, room_undraw_tile_objects_restore_background_loop_x_continue2
			; if ixl turned 0, it means the previous pointer was probably bad, so, we need to recompute it:
			push bc
				ld c, ixl
				ld b, ixh
				call get_room_tile_ptr					
			pop bc
room_undraw_tile_objects_restore_background_loop_x_continue2:

			dec c
			jr nz, room_undraw_tile_objects_restore_background_loop_x
		pop hl
		pop bc
		pop ix
		inc ixh
		ld a, (current_room__width)
		ADD_HL_A
		djnz room_undraw_tile_objects_restore_background_loop_y
	pop ix
	ret


room_undraw_tile_objects_delete_object:
		; Note, we do not need to take into account room bounds here, since this method
		; is for objects that are static, and hence will always be within screen bounds.
		; - hl: ptr to tile_object_gfx_table
		; - ixl, ixh: x, y of the object
		inc hl
		ld c, (hl)  ; width
		inc hl
		ld b, (hl)  ; height
		; compute ptr where to delete:
		push bc
			ld c, ixl
			ld b, ixh
			call get_room_tile_ptr
		pop bc
room_undraw_tile_objects_delete_object_loop_y:
		push bc
		push hl
room_undraw_tile_objects_delete_object_loop_x:
			; restore background:
			ld (hl), 0
			inc hl
			dec c
			jr nz, room_undraw_tile_objects_delete_object_loop_x
		pop hl
		pop bc
		ld a, (current_room__width)
		ADD_HL_A
		djnz room_undraw_tile_objects_delete_object_loop_y
		jp room_undraw_tile_objects_loop_continue


;-----------------------------------------------
; input:
; - ix: ptr to the object
room_remove_breakable_wall:
	; mark its deletion in the global state:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld (hl), 1  ; mark the object as deleted

	; Create an entry in "global_state__open_walls":
	ld hl, global_state__open_walls
room_remove_breakable_wall_open_wall_loop:
	ld a, (hl)
	or a
	jr z, room_remove_breakable_wall_open_wall_loop_end
	ld bc, 6
	add hl, bc
	jr room_remove_breakable_wall_open_wall_loop
room_remove_breakable_wall_open_wall_loop_end:
	ld a, (current_area__id)
	inc a  ; so that we don't have a 0
	ld (hl), a
	inc hl
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	push hl
	push ix
		call get_chunk_ids_current_room_ptr
		ld bc, -current_area__chunks_ids
		add hl, bc
		ld a, l
	pop ix
	pop hl
	ld (hl), a  ; chunk where this wall is
	inc hl

	; get within-chunk coordinates:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	and #0f
	ld c, a  ; c = x % CHUNK_WIDTH
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
room_remove_breakable_wall_continue_within_chunk_y_loop:
	cp CHUNK_HEIGHT
	jr c, room_remove_breakable_wall_continue
	sub CHUNK_HEIGHT
	jr room_remove_breakable_wall_continue_within_chunk_y_loop
room_remove_breakable_wall_continue:
	ld b, a  ; b = y % CHUNK_HEIGHT
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_WIDTH)
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_HEIGHT)
	ld (hl), e
	inc hl
	ld (hl), d
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	call room_remove_breakable_wall_restore_background
	call room_maybe_spawn_ladder_after_opening_wall
	push ix
	pop hl
	jp delete_tile_object_in_hl


;-----------------------------------------------
; input:
; - c, b: x, y in tile coordinates
; output:
; - nz: found a tile object with saved background in those coordinates
; - z: no tile object found to get the background
; - a: if a tile object was found, a has the tile behind it
get_tile_behind_tile_object:
	ld ix, current_room__tile_objects
get_tile_behind_tile_object_loop:
	ld a, (ix)  ; ID
	cp #ff
	ret z
	cp #fe
	ret z

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	ADD_HL_A  ; hl = a * 5
	ld de, tile_object_gfx_table
	add hl, de
	ld a, (hl)
	or a
	jr nz, get_tile_behind_tile_object_loop_next
    ; type 0: saving background
    ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
    cp c
    jr z, get_tile_behind_tile_object_loop_check_y
    inc a
    cp c
    jr z, get_tile_behind_tile_object_loop_check_y
    jr get_tile_behind_tile_object_loop_next
get_tile_behind_tile_object_loop_check_y:
    ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
    cp b
    jr z, get_tile_behind_tile_object_loop_coordinate_match
    inc a
    cp b
    jr z, get_tile_behind_tile_object_loop_coordinate_match
    jr get_tile_behind_tile_object_loop_next
get_tile_behind_tile_object_loop_coordinate_match:
	ld a, b
	sub (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	add a, a
	add a, c
	sub (ix + ROOM_TILE_OBJECT_STRUCT_X)
	add a, ROOM_TILE_OBJECT_STRUCT_BACKGROUND
	push ix
	pop hl
	ADD_HL_A
	ld a, (hl)  ; tile in the background buffer
	cp FIRST_REGULAR_ITEM_TILE
	ret c  ; we found the background tile!
	cp LAST_REGULAR_ITEM_TILE
	jr nc, get_tile_behind_tile_object_found  ; we cannot directly "ret", since we might have "z"
	; the saved background tile is another item, continue
get_tile_behind_tile_object_loop_next:
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	add ix, de
	jr get_tile_behind_tile_object_loop
get_tile_behind_tile_object_found:
	or a  ; this ensures "nz", since a >= LAST_REGULAR_ITEM_TILE
	ret


;-----------------------------------------------
; input:
; - ix: ptr to object
interact_with_tile_object:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld hl, object_interaction_function_ptrs
	ld b, 0
	ld c, a
	add hl, bc
	add hl, bc
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

object_interaction_function_ptrs:
REPT TAG_RED_LOCK
	dw object_interaction_function_empty
ENDR
	dw object_interaction_function_open_small_lock  ; TAG_RED_LOCK
	dw object_interaction_function_open_small_lock  ; TAG_GREEN_LOCK
	dw object_interaction_function_open_small_lock  ; TAG_BLUE_LOCK
	dw object_interaction_function_open_small_lock  ; TAG_YELLOW_LOCK
	dw object_interaction_function_open_small_lock  ; TAG_WHITE_LOCK
	dw object_interaction_function_open_small_lock  ; TAG_PURPLE_LOCK
	dw object_interaction_function_inspect_god  ; TAG_TRIAL1_LOCK
	dw object_interaction_function_inspect_god  ; TAG_TRIAL2_LOCK
	dw object_interaction_function_inspect_god  ; TAG_TRIAL3_LOCK
	dw object_interaction_function_inspect_god  ; TAG_TRIAL4_LOCK
	dw object_interaction_function_combination_lever  ; TAG_COMBINATION1_LOCK
	dw object_interaction_function_combination_lever  ; TAG_COMBINATION2_LOCK
	dw object_interaction_function_combination_lever  ; TAG_COMBINATION3_LOCK
	dw object_interaction_function_combination_lever  ; TAG_COMBINATION4_LOCK
	dw object_interaction_function_open_ball_lock  ; TAG_BALL_LOCK
	dw object_interaction_function_open_idol_lock  ; TAG_IDOL_LOCK
	dw object_interaction_function_open_gear_lock  ; TAG_GEAR_LOCK
	dw object_interaction_function_open_astronaut_lock  ; TAG_ASTRONAUT_LOCK
	dw object_interaction_function_empty  ; TAG_START
	dw object_interaction_function_empty  ; TAG_ENDING
	dw object_interaction_function_empty  ; TAG_MIDPOINT
	dw object_interaction_function_teleporter_atlantis  ; TAG_TELEPORTER_ATLANTIS
	dw object_interaction_function_teleporter_mars  ; TAG_TELEPORTER_MARS
	dw object_interaction_function_teleporter_moon  ; TAG_TELEPORTER_MOON
	dw object_interaction_function_empty  ; TAG_BUTTON1
	dw object_interaction_function_empty  ; TAG_BUTTON2
	dw object_interaction_function_empty  ; TAG_BUTTON3
	dw object_interaction_function_empty  ; TAG_BUTTON4
	dw object_interaction_function_pickup_item  ; TAG_RED_KEY
	dw object_interaction_function_pickup_item  ; TAG_GREEN_KEY
	dw object_interaction_function_pickup_item  ; TAG_BLUE_KEY
	dw object_interaction_function_pickup_item  ; TAG_YELLOW_KEY
	dw object_interaction_function_pickup_item  ; TAG_WHITE_KEY
	dw object_interaction_function_pickup_item  ; TAG_PURPLE_KEY
	dw object_interaction_function_chest  ; TAG_RED_CHEST
	dw object_interaction_function_chest  ; TAG_GREEN_CHEST
	dw object_interaction_function_chest  ; TAG_BLUE_CHEST
	dw object_interaction_function_chest  ; TAG_YELLOW_CHEST
	dw object_interaction_function_chest  ; TAG_WHITE_CHEST
	dw object_interaction_function_chest  ; TAG_PURPLE_CHEST
	dw object_interaction_function_tablet  ; TAG_TRIAL1_CLUE
	dw object_interaction_function_tablet  ; TAG_TRIAL2_CLUE
	dw object_interaction_function_tablet  ; TAG_TRIAL3_CLUE
	dw object_interaction_function_tablet  ; TAG_TRIAL4_CLUE
	dw object_interaction_function_tablet  ; TAG_COMBINATION1_CLUE
	dw object_interaction_function_tablet  ; TAG_COMBINATION2_CLUE
	dw object_interaction_function_tablet  ; TAG_COMBINATION3_CLUE
	dw object_interaction_function_tablet  ; TAG_COMBINATION4_CLUE
	dw object_interaction_function_pickup_item  ; TAG_BALL_KEY
	dw object_interaction_function_pickup_item  ; TAG_IDOL_KEY
	dw object_interaction_function_pickup_item  ; TAG_GEAR_KEY
	dw object_interaction_function_pickup_item  ; TAG_ASTRONAUT_KEY
	dw object_interaction_function_empty  ; TAG_BOSS1
	dw object_interaction_function_pickup_item  ; TAG_BOSS1_KEY
	dw object_interaction_function_open_boss_lock  ; TAG_BOSS1_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS2
	dw object_interaction_function_pickup_item  ; TAG_BOSS2_KEY
	dw object_interaction_function_open_boss_lock  ; TAG_BOSS2_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS3
	dw object_interaction_function_pickup_item  ; TAG_BOSS3_KEY
	dw object_interaction_function_open_boss_lock  ; TAG_BOSS3_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS4
	dw object_interaction_function_pickup_item  ; TAG_BOSS4_KEY
	dw object_interaction_function_open_boss_lock  ; TAG_BOSS4_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS5
	dw object_interaction_function_pickup_item  ; TAG_BOSS5_KEY
	dw object_interaction_function_atlantis_hidden_lock  ; TAG_BOSS5_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS6
	dw object_interaction_function_pickup_item  ; TAG_BOSS6_KEY
	dw object_interaction_function_open_boss_lock  ; TAG_BOSS6_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS7
	dw object_interaction_function_pickup_item  ; TAG_BOSS7_KEY
	dw object_interaction_function_open_boss_lock  ; TAG_BOSS7_CHESTLOCK
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_HAMMER
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_MACUAHUITL
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_SHIELD
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_SLING
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_BLOWGUN
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_ATLATL
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_RAYGUN
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_OBSIDIAN_KNIVE
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_FIRE_HAMMER
	dw object_interaction_function_pickup_weapon  ; TAG_WEAPON_ICE_MACUAHUITL
	dw object_interaction_function_pickup_map_piece  ; TAG_MAP_PIECE1
	dw object_interaction_function_pickup_map_piece  ; TAG_MAP_PIECE2
	dw object_interaction_function_pickup_map_piece  ; TAG_MAP_PIECE3
	dw object_interaction_function_pickup_map_piece  ; TAG_MAP_PIECE4
	dw object_interaction_function_pickup_map_piece  ; TAG_MAP_PIECE5
	dw object_interaction_function_pickup_map_piece  ; TAG_MAP_PIECE6
	dw object_interaction_function_pickup_map_piece  ; TAG_MAP_PIECE7
	dw object_interaction_function_pickup_heart  ; TAG_HEART1
	dw object_interaction_function_pickup_heart  ; TAG_HEART2
	dw object_interaction_function_pickup_heart  ; TAG_HEART3
	dw object_interaction_function_pickup_heart  ; TAG_HEART4
	dw object_interaction_function_pickup_heart  ; TAG_HEART5
	dw object_interaction_function_tablet  ; TAG_MAYA_RIDDLE_CLUE1
	dw object_interaction_function_tablet  ; TAG_MAYA_RIDDLE_CLUE2
	dw object_interaction_function_tablet  ; TAG_MAYA_RIDDLE_CLUE3
	dw object_interaction_function_tablet  ; TAG_MAYA_RIDDLE_CLUE4
	dw object_interaction_function_tablet  ; TAG_STORY_TRIVIA1
	dw object_interaction_function_tablet  ; TAG_STORY_TRIVIA2
	dw object_interaction_function_tablet  ; TAG_STORY_TRIVIA3
	dw object_interaction_function_tablet  ; TAG_STORY_TRIVIA4
	dw object_interaction_function_tablet  ; TAG_STORY_TRIVIA5
	dw object_interaction_function_tablet  ; TAG_STORY_TRIVIA6
	dw object_interaction_function_tablet  ; TAG_STORY_TRIVIA7
	dw object_interaction_function_tablet  ; TAG_STORY_TRIVIA8
	dw object_interaction_function_pickup_item  ; TAG_ITEM_SANDALS
	dw object_interaction_function_pickup_item  ; TAG_ITEM_GLOVES
	dw object_interaction_function_pickup_item  ; TAG_ITEM_WARRIOR_HAT
	dw object_interaction_function_pickup_item  ; TAG_ITEM_ARMOR
	dw object_interaction_function_pickup_item  ; TAG_ITEM_CHAAC
	dw object_interaction_function_pickup_item  ; TAG_ITEM_SEASHELL
	dw object_interaction_function_pickup_item  ; TAG_ITEM_BELT
	dw object_interaction_function_pickup_item  ; TAG_ITEM_ICE_CAPE
	dw object_interaction_function_pickup_small_key  ; TAG_SMALL_KEY1
	dw object_interaction_function_pickup_small_key  ; TAG_SMALL_KEY2
	dw object_interaction_function_pickup_small_key  ; TAG_SMALL_KEY3
	dw object_interaction_function_pickup_small_key  ; TAG_SMALL_KEY4
	dw object_interaction_function_small_chest  ; TAG_SMALL_KEY_CHEST1
	dw object_interaction_function_small_chest  ; TAG_SMALL_KEY_CHEST2
	dw object_interaction_function_small_chest  ; TAG_SMALL_KEY_CHEST3
	dw object_interaction_function_small_chest  ; TAG_SMALL_KEY_CHEST4
	dw object_interaction_function_teleporter  ; TAG_TELEPORTER1
	dw object_interaction_function_teleporter  ; TAG_TELEPORTER2
	dw object_interaction_function_teleporter  ; TAG_TELEPORTER3
	dw object_interaction_function_teleporter  ; TAG_TELEPORTER4
	dw object_interaction_function_teleporter  ; TAG_TELEPORTER5
	dw object_interaction_function_teleporter  ; TAG_TELEPORTER6
	dw object_interaction_function_teleporter  ; TAG_TELEPORTER7
	dw object_interaction_function_teleporter  ; TAG_TELEPORTER8
	dw object_interaction_function_tablet  ; TAG_CALENDAR_NAME_CLUE
	dw object_interaction_function_lost_vendor  ; TAG_LOST_VENDOR
	dw object_interaction_function_tablet  ; TAG_XIBALBA_STORY1
	dw object_interaction_function_tablet  ; TAG_XIBALBA_STORY2
	dw object_interaction_function_tablet  ; TAG_XIBALBA_STORY3
	dw object_interaction_function_tablet  ; TAG_XIBALBA_STORY4
	dw object_interaction_function_tablet  ; TAG_XIBALBA_STORY5
	dw object_interaction_function_tablet  ; TAG_XIBALBA_LORDS1
	dw object_interaction_function_tablet  ; TAG_XIBALBA_LORDS2
	dw object_interaction_function_tablet  ; TAG_XIBALBA_LORDS3
	dw object_interaction_function_tablet  ; TAG_XIBALBA_LORDS4
	dw object_interaction_function_tablet  ; TAG_XIBALBA_LORDS5
	dw object_interaction_function_tablet  ; TAG_XIBALBA_LORDS6
	dw object_interaction_function_tablet  ; TAG_XIBALBA_LORDS7
	dw object_interaction_function_tablet  ; TAG_XIBALBA_CLUE
	dw object_interaction_function_tablet  ; TAG_ATLANTIS_TABLET1
	dw object_interaction_function_tablet  ; TAG_ATLANTIS_TABLET2
	dw object_interaction_function_tablet  ; TAG_ATLANTIS_TABLET3
	dw object_interaction_function_tablet  ; TAG_ATLANTIS_TABLET4
	dw object_interaction_function_tablet  ; TAG_ATLANTIS_TABLET5
	dw object_interaction_function_empty  ; TAG_PUSHABLE_BLOCK
	dw object_interaction_function_empty  ; TAG_DOOR_VERTICAL
	dw object_interaction_function_empty  ; TAG_DOOR_HORIZONTAL
	dw object_interaction_function_boss_door  ; TAG_DOOR_BOSS
	dw object_interaction_function_power_stone  ; TAG_POWER_STONE
	dw object_interaction_function_tablet  ; TAG_CALENDAR_TABLET
	dw object_interaction_function_calendar_socket  ; TAG_CALENDAR_SOCKET
	dw object_interaction_function_empty  ; TAG_HALF_POWER_STONE
	dw object_interaction_function_calendar_center  ; TAG_CALENDAR_STONE_CENTER
	dw object_interaction_function_tablet  ; TAG_MAYA_PUZZLE_TABLET
	dw object_interaction_function_teleporter_atlantis  ; TAG_TELEPORTER_ATLANTIS_TO_MOON
	dw object_interaction_function_pickup_puzzlebox_mars  ; TAG_PUZZLEBOX_MARS
	dw object_interaction_function_pickup_puzzlebox_moon  ; TAG_PUZZLEBOX_MOON
	dw object_interaction_function_pickup_charybdis_eye  ; TAG_CHARYBDIS_EYE
	dw object_interaction_function_pickup_scylla_eye  ; TAG_SCYLLA_EYE
	dw object_interaction_function_pickup_coins  ; TAG_COIN
	dw object_interaction_function_pickup_corn  ; TAG_CORN
	dw object_interaction_function_pickup_stones  ; TAG_STONES
	dw object_interaction_function_pickup_darts  ; TAG_DARTS
	dw object_interaction_function_pickup_spears  ; TAG_SPEARS
	dw object_interaction_function_pickup_battery  ; TAG_BATTERY
	dw object_interaction_function_tablet  ; TAG_XIBALBA_BOSS_TABLET
	dw object_interaction_function_tablet  ; TAG_XIBALBA_BOSS_GRAVE
	dw object_interaction_function_pickup_item_boss4  ; TAG_GOLDEN_KEY
	dw object_interaction_function_pickup_item_boss4  ; TAG_SKULL_CHARM
	dw object_interaction_function_poseidon_lever  ; TAG_POSEIDON_LEVER
	dw object_interaction_function_poseidon_boss_display  ; TAG_POSEIDON_BOSS_DISPLAY
	dw object_interaction_function_shopkeeper  ; TAG_NPC_SHOPKEEPER
	dw object_interaction_function_shop  ; TAG_NPC_SHOP
	dw object_interaction_function_empty  ; TAG_DYNAMITE
	dw object_interaction_function_shopkeeper2  ; TAG_NPC_SHOPKEEPER2
	dw object_interaction_function_empty  ; TAG_ENEMY_CARNIVORE_PLANT
	dw object_interaction_function_empty  ; TAG_ENEMY_BEE_HIVE
	dw object_interaction_function_empty  ; TAG_ENEMY_ANT_COLONY
	dw object_interaction_function_empty  ; TAG_ENEMY_ANT_COLONY2
	dw object_interaction_function_empty  ; TAG_ENEMY_IMP_GENERATOR
	dw object_interaction_function_empty  ; TAG_ENEMY_IMP_GENERATOR2
	dw object_interaction_function_empty  ; TAG_ENEMY_FIREBALL_GENERATOR
	dw object_interaction_function_empty  ; TAG_ENEMY_LAVA_GENERATOR
	dw object_interaction_function_empty  ; TAG_ENEMY_STONE_OWL
	dw object_interaction_function_empty  ; TAG_ENEMY_SENTINEL

object_interaction_inventory_slot:
	db #ff, #ff, #ff, #ff, #ff  ; none, block puzzles: 0
	db #ff, #ff, #ff, #ff  ; button doors: 5
	db #ff, #ff, #ff, #ff  ; breakable walls: 9
	db #ff, #ff, #ff, #ff, #ff, #ff  ; color locks: 13
	db #ff, #ff, #ff, #ff  ; trial locks: 19
	db #ff, #ff, #ff, #ff  ; combination locks: 23
	db #ff, #ff, #ff, #ff  ; special locks: 27
	db #ff, #ff, #ff, #ff, #ff, #ff  ; start, ending, midpoint, teleporters: 31
	db #ff, #ff, #ff, #ff  ; buttons: 37
	db 13, 14, 15, 16, 17, 18  ; color keys: 41
	db #ff, #ff, #ff, #ff, #ff, #ff  ; color chests: 47
	db #ff, #ff, #ff, #ff  ; trial clues: 53
	db #ff, #ff, #ff, #ff  ; combination clues: 57
	db 21, 22, 23, 24  ; key items: 61
	db #ff, 0, #ff  ; boss1: 65
	db #ff, 1, #ff  ; boss2: 68
	db #ff, 2, #ff  ; boss3: 71
	db #ff, 3, #ff  ; boss4: 74
	db #ff, 4, #ff  ; boss5: 77
	db #ff, 5, #ff  ; boss6: 80
	db #ff, 6, #ff  ; boss7: 83
	db 1, 2, 3  ; weapons: 86
	db 4, 5, 6, 7  ; ranged weapons: 89
	db 8, 9, 10  ; upgraded weapons: 93
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; map pieces: 96
	db #ff, #ff, #ff, #ff, #ff  ; hearts: 103
	db #ff, #ff, #ff, #ff  ; riddle clues: 108
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; story trivia: 112
	db INVENTORY_ITEM_SANDALS, INVENTORY_ITEM_GLOVES, INVENTORY_ITEM_WARRIOR_HAT, INVENTORY_ITEM_COTTON_ARMOR, INVENTORY_ITEM_CHAAC_BLESSING, INVENTORY_ITEM_SEASHELL  ; maya upgrade items: 120
	db INVENTORY_ITEM_ANTIGRAV_BELT, INVENTORY_ITEM_ICE_CAPE  ; alien upgrade items: 126
	db INVENTORY_ITEM_SMALL_KEY, INVENTORY_ITEM_SMALL_KEY, INVENTORY_ITEM_SMALL_KEY, INVENTORY_ITEM_SMALL_KEY  ; small keys: 128
	db #ff, #ff, #ff, #ff  ; small key chests: 132
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; teleporters: 136
	db #ff  ; calendar name clue: 144
	db #ff  ; lost vendor: 145
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; xibalba tablets: 146
	db #ff  ; pushable block: 159
	db #ff, #ff , #ff ; doors: 160
	db #ff  ; power stone: 163
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; calendar tablet: 164, up to puxxlebox moon: 171
	db #ff, #ff, #ff, #ff, #ff, #ff  ; consumables: 172
	db #ff, #ff  ; xibalba boss tablet/grave: 178
	db INVENTORY_ITEM_GOLDEN_KEY, INVENTORY_ITEM_SKULL_CHARM  ; golden key / skull charm: 180, 181


;-----------------------------------------------
object_interaction_function_empty:
	ret


;-----------------------------------------------
object_interaction_function_poseidon_boss_display:
	ld hl, object_interaction_function_poseidon_boss_display_internal
	ld c, BOSS_5_PAGE
	jp call_hl_in_page_c_8000


;-----------------------------------------------
object_interaction_function_poseidon_lever:
	; just change the boss state, which will trigger the rest of the events
	ld a, 2
	ld (boss__state), a
	ret


;-----------------------------------------------
object_interaction_function_pickup_item_boss4:
	call object_interaction_function_pickup_item
	ld hl, update_boss4_behavior_3_state_4_not_pair
	ld c, BOSS_4_PAGE
	jp call_hl_in_page_c_8000


object_interaction_function_pickup_item:
	; update stats:
	ld hl, stats__n_items_collected
	inc (hl)

	; add to inventory:
	ld hl, object_interaction_inventory_slot
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld a, (hl)
	cp N_INVENTORY_ITEM_TYPES
	ret nc  ; should never happen

	; add to inventory:
	ld hl, player_inventory_items
	ADD_HL_A	
	ld (hl), 1

object_interaction_function_pickup_weapon_continue:
object_interaction_function_pickup_small_key_continue:
	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority

object_interaction_function_pickup_heart_continue:
	; mark as taken:
	ld hl, global_state__objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_PUSHABLE_BLOCK
	jr nc, object_interaction_function_delete_object  ; objects after this tag do not have state
	ADD_HL_A
	ld (hl), 1

object_interaction_function_delete_object:
	ld hl, redraw_flags
	ld (hl), #ff

	push ix
		call room_undraw_tile_objects
	pop hl
	call delete_tile_object_in_hl
	jp room_render_tile_objects


;-----------------------------------------------
object_interaction_function_pickup_weapon:
	; update stats:
	ld hl, stats__n_weapons_collected
	inc (hl)

	; add to inventory:
	ld hl, object_interaction_inventory_slot
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld a, (hl)
	cp N_INVENTORY_WEAPON_TYPES
	ret nc  ; should never happen

	; add to inventory:
	ld hl, player_inventory_weapons
	ld b, 0
	ld c, a
	add hl, bc
	ld (hl), 1

	; add some small amount of ammo:
	sub 4
	jr c, object_interaction_function_pickup_weapon_continue
	cp 4
	jr nc, object_interaction_function_pickup_weapon_continue
	ld hl, player_inventory_weapon_ammo
	ld c, a
	add hl, bc
	ld (hl), 5

	jr object_interaction_function_pickup_weapon_continue


;-----------------------------------------------
object_interaction_function_pickup_small_key:
	; update stats:
	ld hl, stats__n_items_collected
	inc (hl)

	ld hl, player_inventory_n_small_keys
	inc (hl)
	ld hl, player_inventory_items + INVENTORY_ITEM_SMALL_KEY  ; small key
	ld (hl), 1
	jr object_interaction_function_pickup_small_key_continue


;-----------------------------------------------
object_interaction_function_pickup_map_piece:
	; update stats:
	ld hl, stats__n_maps_collected
	inc (hl)

	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority

; 	ld hl, player_inventory_map_pieces
; 	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
; 	sub (TAG_MAP_PIECE1 - 1)
; 	ADD_HL_A
; 	ld (hl), 1

	ld de, TEXT_MAP_PIECE_PICKUP
	jr object_interaction_function_pickup_map_piece_continue


;-----------------------------------------------
object_interaction_function_pickup_heart:
	; update stats:
	ld hl, stats__n_items_collected
	inc (hl)

	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority

	ld a, (player_max_health)
	add a, 4
	ld (player_max_health), a
	ld (player_health), a

	call draw_room_with_hud  ; update the hud just to show the updated health

	ld de, TEXT_HEART_PICKUP
object_interaction_function_pickup_map_piece_continue:
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix

	jp object_interaction_function_pickup_heart_continue


;-----------------------------------------------
object_interaction_function_chest:
	; check if the player has the proper key selected
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	add (N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_COLOR_KEY1) - TAG_RED_CHEST
	ld c, a  ; c = desired key
	ld hl, player_current_item
	cp (hl)
	jr nz, object_interaction_function_chest_fail

	; lose key:
	ld (hl), 0  ; machete
	ld a, c
	sub N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_COLOR_KEY1  ; position of the first color key
	ld b, 0
	ld c, a
	ld hl, player_inventory_items + INVENTORY_ITEM_COLOR_KEY1
	add hl, bc  ; key location
	ld (hl), 0
	jp object_interaction_function_small_chest_continue


;-----------------------------------------------
object_interaction_function_small_chest:
	; check if the player has "small key" selected
	ld hl, player_current_item
	ld a, (hl)
	cp 31  ; small key
	jr nz, object_interaction_function_small_chest_fail

	; lose small key:
	ld (hl), 0  ; machete
	ld hl, player_inventory_n_small_keys
	dec (hl)
	ld a, (hl)
	or a
	jr nz, object_interaction_function_small_chest_continue
	ld hl, player_inventory_items + INVENTORY_ITEM_SMALL_KEY  ; small key location
	ld (hl), 0
object_interaction_function_small_chest_continue:
	; update chest state:
	ld hl, global_state__objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld (hl), 1  ; chest is open
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld hl, get_chest_content
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000

	ld (ix + ROOM_TILE_OBJECT_STRUCT_TYPE), e
	ld (ix + ROOM_TILE_OBJECT_STRUCT_ID), e

	ld hl, set_item_object_to_upload_to_vdp
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000

	ld hl, SFX_ui_select
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	ld (hl), #ff
	call room_undraw_tile_objects
	jp room_render_tile_objects

object_interaction_function_chest_fail:
object_interaction_function_small_chest_fail:
object_interaction_function_open_boss_lock_fail:
	ld hl, SFX_ui_wrong
	call play_SFX_with_high_priority

	ld de, TEXT_WRONG_KEY
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
; 	jp room_render_tile_objects
	ret


object_interaction_function_item_use_fail:
	ld hl, SFX_ui_wrong
	call play_SFX_with_high_priority

	ld de, TEXT_WRONG_ITEM
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
; 	jp room_render_tile_objects
	ret


;-----------------------------------------------
object_interaction_function_open_small_lock:
	; check if the player has the proper key selected
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	add (N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_COLOR_KEY1) - TAG_RED_LOCK
	ld c, a  ; c = desired key
	ld hl, player_current_item
	cp (hl)
	jr nz, object_interaction_function_chest_fail

	; lose key:
	ld (hl), 0  ; machete
	ld a, c
	sub N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_COLOR_KEY1  ; position of the first color key
	ld b, 0
	ld c, a
	ld hl, player_inventory_items + INVENTORY_ITEM_COLOR_KEY1
	add hl, bc  ; key location
	ld (hl), 0

object_interaction_function_open_small_lock_entry_point:
	; update lock state:
	ld hl, global_state__objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld (hl), 1  ; lock is open

	; update the lock gfx (we call both, since one of them would be the correct one):
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld hl, set_item_object_to_upload_to_vdp
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000	
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld hl, set_large_object_to_upload_to_vdp
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000	

object_interaction_function_open_combination_lock_entry_point:
	ld hl, SFX_secret
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	ld (hl), #ff
	call room_undraw_tile_objects
	call find_room_door_object_ptr
	jp nz, room_render_tile_objects  ; no door
	push hl
	pop ix

	; Create an entry in "global_state__open_walls":
	ld hl, room_mark_open_door
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000

	; If it's a door down to an inter-area connection, replace by a ladder:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_DOOR_HORIZONTAL
	call z, room_maybe_spawn_ladder_after_opening_door
	; remove door:
	push ix
	pop hl
	call delete_tile_object_in_hl
	jp room_render_tile_objects


;-----------------------------------------------
; input:
; - ix: ptr to an object (either a door or a breakable wall)
room_maybe_spawn_ladder_after_opening_door:
	; is it at the bottom of the room?
	ld a, (current_room__height)
	dec a
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	ret nz
	jr room_maybe_spawn_ladder_after_opening_door_or_wall

room_maybe_spawn_ladder_after_opening_wall:
	ld a, (current_room__height)
	sub (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	sub (ix + ROOM_TILE_OBJECT_STRUCT_HEIGHT)
	ret nz

room_maybe_spawn_ladder_after_opening_door_or_wall:
	; is it an inter-area connection? (check if we are at the edge of the map, or there is no chunk below)
	ld a, (current_room__y)
	ld c, a
	ld a, (current_room__height_in_screens)
	add a, c
	ld c, a
	ld a, (current_area__height)
	cp c
	jr z, room_maybe_spawn_ladder_after_opening_door_or_wall__inter_area_connection

	; see if there is a chunk below:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	call get_player_chunk_coordinates
	inc b  ; chunk below
	ld e, PCG_PAGE
	ld hl, get_chunk_id_from_coordinates
	call call_hl_in_page_e_8000
	ld a, (hl)
	cp #ff
	ret nz

room_maybe_spawn_ladder_after_opening_door_or_wall__inter_area_connection:
	; replace by a ladder:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld a, (current_room__height)
	dec a
	ld b, a
	call get_room_tile_ptr
	ld (hl), 254  ; platform
	inc hl
	ld (hl), 168  ; ladder-left
	inc hl
	ld (hl), 136  ; ladder-right
	inc hl
	ld (hl), 254  ; platform
	ret


;-----------------------------------------------
object_interaction_function_open_ball_lock:
	ld a, N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_BALL  ; ball
	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_item_use_fail
	ld (hl), 0  ; machete
	ld hl, player_inventory_items + INVENTORY_ITEM_BALL  ; ball
	ld (hl), 0
	jp object_interaction_function_open_small_lock_entry_point

object_interaction_function_open_idol_lock:
	ld a, N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_IDOL  ; idol
	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_item_use_fail
	ld (hl), 0  ; machete
	ld hl, player_inventory_items + INVENTORY_ITEM_IDOL  ; idol
	ld (hl), 0
	jp object_interaction_function_open_small_lock_entry_point

object_interaction_function_open_gear_lock:
	ld a, N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_GEAR  ; gear
	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_item_use_fail
	ld (hl), 0  ; machete
	ld hl, player_inventory_items + INVENTORY_ITEM_GEAR  ; gear
	ld (hl), 0
	jp object_interaction_function_open_small_lock_entry_point

object_interaction_function_open_astronaut_lock:
	ld a, N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_CLAY_DOLL  ; astronaut
	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_item_use_fail
	ld (hl), 0  ; machete
	ld hl, player_inventory_items + INVENTORY_ITEM_CLAY_DOLL  ; astronaut
	ld (hl), 0
	jp object_interaction_function_open_small_lock_entry_point


;-----------------------------------------------
object_interaction_function_tablet:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_CALENDAR_TABLET
	jr nz, object_interaction_function_tablet_not_calendar
	; if there are aliens around:
	ld a, (current_room__sprite_enemies)
	cp #ff
	ld de, calendar_tablet_fn
	jr z, object_interaction_function_tablet_ptr_set
	; there are aliens
	ld de, TEXT_CALENDAR_INTERACT_WITH_ALIENS
	jp object_interaction_function_calendar_socket_continue
object_interaction_function_tablet_not_calendar:
	cp TAG_MAYA_PUZZLE_TABLET
	jr nz, object_interaction_function_tablet_not_maya_puzzle
	ld de, maya_puzzle_tablet_fn
	jr object_interaction_function_tablet_ptr_set
object_interaction_function_tablet_not_maya_puzzle:
	cp TAG_XIBALBA_STORY1
	jr c, object_interaction_function_tablet_not_xibalba_tablet
	cp TAG_XIBALBA_CLUE + 1
	jr nc, object_interaction_function_tablet_not_xibalba_tablet
	ld de, xibalba_tablet_fn
	jr object_interaction_function_tablet_ptr_set
object_interaction_function_tablet_not_xibalba_tablet:
	cp TAG_ATLANTIS_TABLET1
	jr c, object_interaction_function_tablet_not_atlantis_tablet
	cp TAG_ATLANTIS_TABLET5 + 1
	jr nc, object_interaction_function_tablet_not_atlantis_tablet
	ld de, atlantis_tablet_fn
	jr object_interaction_function_tablet_ptr_set
object_interaction_function_tablet_not_atlantis_tablet:
	cp TAG_XIBALBA_BOSS_TABLET
	jr nz, object_interaction_function_tablet_not_xibalba_boss_tablet
	ld de, xibalba_boss_tablet_fn
	jr object_interaction_function_tablet_ptr_set
object_interaction_function_tablet_not_xibalba_boss_tablet
	cp TAG_XIBALBA_BOSS_GRAVE
	jr nz, object_interaction_function_tablet_not_xibalba_boss_grave
	ld de, xibalba_boss_grave_fn
	jr object_interaction_function_tablet_ptr_set
object_interaction_function_tablet_not_xibalba_boss_grave
	; Determine tablet content:
	ld hl, current_world__tablet_content
object_interaction_function_tablet_loop:
	ld a, (hl)
	cp (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	jr z, object_interaction_function_tablet_found
	inc hl
	inc hl
	inc hl
	jr object_interaction_function_tablet_loop
object_interaction_function_tablet_found:
	inc hl
	ld e, (hl)
	inc hl
	ld d, (hl)

object_interaction_function_tablet_ptr_set:
	ld c, TABLET_LETTER_PAGE
	ld hl, display_tablet
	jp call_hl_in_page_c_8000


;-----------------------------------------------
object_interaction_function_combination_lever:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	inc a
	cp 3
	jr nz, object_interaction_function_combination_lever_continue
	xor a
object_interaction_function_combination_lever_continue:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), a

	; mark combination state:
	ld hl, player_combination_levers_state
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	dec c
	ld b, 0
	add hl, bc
	ld (hl), a

	; check if the combination is the correct one:
	ld hl, global_state__objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld a, (hl)
	or a
	jr nz, object_interaction_function_combination_lever_already_open
	push hl
		ld hl, current_world__combination_solutions
		ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
		sub TAG_COMBINATION1_LOCK
		add a, a
		add a, a
		add a, a
		ADD_HL_A
		ld de, player_combination_levers_state
		ld b, 8
object_interaction_function_combination_lever_loop:
		ld a, (de)
		cp (hl)
		jr nz, object_interaction_function_combination_lever_incorrect
		inc hl
		inc de
		djnz object_interaction_function_combination_lever_loop
	pop hl
	ld (hl), 1  ; mark as open
	jp object_interaction_function_open_combination_lock_entry_point

object_interaction_function_combination_lever_incorrect:
	pop hl

object_interaction_function_combination_lever_already_open:
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	call room_undraw_tile_objects
	jp room_render_tile_objects


;-----------------------------------------------
object_interaction_function_inspect_god:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	sub TAG_TRIAL1_LOCK
	jr z, object_interaction_function_inspect_god1
	dec a
	jr z, object_interaction_function_inspect_god2
	dec a
	jr z, object_interaction_function_inspect_god3
	ld de, TEXT_TRIAL_GOD4
	jr object_interaction_function_inspect_god_continue
object_interaction_function_inspect_god1:
	ld de, TEXT_TRIAL_GOD1
	jr object_interaction_function_inspect_god_continue
object_interaction_function_inspect_god2:
	ld de, TEXT_TRIAL_GOD2
	jr object_interaction_function_inspect_god_continue
object_interaction_function_inspect_god3:
	ld de, TEXT_TRIAL_GOD3
	jr object_interaction_function_inspect_god_continue
object_interaction_function_inspect_god_continue:
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
	ret


;-----------------------------------------------
object_interaction_function_open_boss_lock:
	; check if the player has the proper key selected
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld c, 11
	sub TAG_BOSS1_CHESTLOCK
object_interaction_function_open_boss_lock_key_id_loop:
	cp 3
	jr c, object_interaction_function_open_boss_lock_key_id_computed_done
	inc c
	sub 3
	jr object_interaction_function_open_boss_lock_key_id_loop
object_interaction_function_open_boss_lock_key_id_computed_done:
	; c = desired key
	ld a, c

	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_open_boss_lock_fail

	; lose key:
	ld (hl), 0  ; machete
	ld a, c
	sub 11
	ld c, a
	ld b, 0
	ld hl, player_inventory_items
	add hl, bc  ; key location
	ld (hl), 0

	; update lock state:
	ld hl, global_state__objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld (hl), 1  ; lock is open

	; open boss door:
	ld hl, SFX_secret
	call play_SFX_with_high_priority
	ld b, 30
	call wait_b_halts

	ld hl, buffer_4096 + (48 + 16) * 16  ; boss door frame 1
	ld a, (current_area__id)
	cp 9  ; atlantis
	jr nz, object_interaction_function_open_boss_lock_continue1
	ld hl, buffer_4096 + (202 + 16) * 16  ; boss door frame 1 atlantis
object_interaction_function_open_boss_lock_continue1:
	ld (large_object_to_upload_to_vdp), hl
	ld a, 16*8
	ld (large_object_to_upload_to_vdp_size), a
	call state_play_upload_object_tiles_to_vdp_if_necessary
	ld hl, SFX_explosion
	call play_SFX_with_high_priority

	ld b, 30
	call wait_b_halts

	ld hl, buffer_4096 + (48 + 32) * 16  ; boss door frame 2
	ld a, (current_area__id)
	cp 9  ; atlantis
	jr nz, object_interaction_function_open_boss_lock_continue2
	ld hl, buffer_4096 + (202 + 32) * 16  ; boss door frame 2 atlantis
object_interaction_function_open_boss_lock_continue2:
	ld (large_object_to_upload_to_vdp), hl
	ld a, 16*8
	ld (large_object_to_upload_to_vdp_size), a
	call state_play_upload_object_tiles_to_vdp_if_necessary
	ld hl, SFX_explosion
	call play_SFX_with_high_priority

	xor a
	ld (keyboard_clicks), a

	ld hl, redraw_flags
	ld (hl), #ff
	call room_undraw_tile_objects	
	jp room_render_tile_objects  ; no door


;-----------------------------------------------
object_interaction_function_boss_door:
	ld c, BOSS_PAGE
	ld hl, enter_boss_door
	jp call_hl_in_page_c_8000


;-----------------------------------------------
object_interaction_function_power_stone:
	ld c, BOSS_PAGE
	ld hl, pick_up_boss_power_stone
	jp call_hl_in_page_c_8000


; object_interaction_function_half_power_stone:
; 	ld c, BOSS_PAGE
; 	ld hl, pick_up_boss_half_power_stone
; 	jp call_hl_in_page_c_8000


object_interaction_function_pickup_puzzlebox_mars:
	; update stats:
	ld hl, stats__n_items_collected
	inc (hl)

	ld c, BOSS_PAGE
	ld hl, pick_up_boss_puzzlebox_mars
	jp call_hl_in_page_c_8000

object_interaction_function_pickup_puzzlebox_moon:
	; update stats:
	ld hl, stats__n_items_collected
	inc (hl)

	ld c, BOSS_PAGE
	ld hl, pick_up_boss_puzzlebox_moon
	jp call_hl_in_page_c_8000


object_interaction_function_pickup_charybdis_eye:
	; update stats:
	ld hl, stats__n_items_collected
	inc (hl)

	ld c, BOSS_PAGE
	ld hl, pick_up_boss_charybdis_eye
	jp call_hl_in_page_c_8000

object_interaction_function_pickup_scylla_eye:
	; update stats:
	ld hl, stats__n_items_collected
	inc (hl)

	ld c, BOSS_PAGE
	ld hl, pick_up_boss_scylla_eye
	jp call_hl_in_page_c_8000


;-----------------------------------------------
object_interaction_function_calendar_socket:
	; if there are aliens in the room, do not let you interact:
	ld a, (current_room__sprite_enemies)
	cp #ff
	jr z, object_interaction_function_calendar_socket_no_aliens
	; there are still aliens:
	ld de, TEXT_CALENDAR_INTERACT_WITH_ALIENS
	jp object_interaction_function_calendar_socket_continue

object_interaction_function_calendar_socket_no_aliens:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	or a
	jr z, object_interaction_function_calendar_socket_empty
	cp 1
	jp z, object_interaction_function_calendar_socket_inactive

	; it has a stone:
	push ix
		ld ix, TEXT_INSPECT_POWER_STONE_FROM_CALENDAR
		sub 2
		ld e, a  ; stone number
		ld hl, display_power_stone_closeup
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop ix

	; restore in-game gfx:
	ld hl, redraw_flags
	ld (hl), #ff
	xor a
	ld hl, NAMTBL2
	ld bc, 768
	call fast_FILVRM
	ld a, (current_room__tileset_page)
	ld c, a
	ld hl, (current_room__tileset_ptr)
	jp setup_game_tiles

object_interaction_function_calendar_socket_empty:
	ld a, (global_state__story)
	cp STORY_STATE__GOT_LETTER1
	jr c, object_interaction_function_calendar_socket_empty_before_letter1
	; empty socket after letter 1:
	cp STORY_STATE__GOT_LETTER2
	jr c, object_interaction_function_calendar_socket_empty_before_letter2
object_interaction_function_calendar_socket_try_to_place:
	; try to place stone:
	ld a, (player_current_item)
	sub N_INVENTORY_WEAPON_TYPES + 7  ; first power stone (11 weapons + 7 boss keys)
	jr c, object_interaction_function_calendar_socket_incorrect_item
	cp 6
	jr nc, object_interaction_function_calendar_socket_incorrect_item
	; place a stone:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	ld b, 0
	ld hl, global_state__power_calendar
	add hl, bc
	add a, 2  ; +2, since 0 is "no stone" and 1 is "inactive stone".
	ld (hl), a
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), a

	; lose it from the inventory:
	ld hl, player_current_item
	ld a, (player_current_item)
	ld (hl), 0  ; machete
	sub N_INVENTORY_WEAPON_TYPES
	ld c, a
	ld b, 0
	ld hl, player_inventory_items
	add hl, bc
	ld (hl), 0

	; redraw the room:
	ld hl, SFX_secret
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	ld (hl), #ff
	call room_undraw_tile_objects
	call room_render_tile_objects

	ld hl, global_state__n_power_stones_in_calendar
	inc (hl)
	ld a, (hl)
	cp 1 
	jr z, object_interaction_function_calendar_socket_1st_stone
	cp 3
	jr z, object_interaction_function_calendar_socket_3rd_stone
	cp 5 
	jr z, object_interaction_function_calendar_socket_5th_stone
	cp 6
	jr z, object_interaction_function_calendar_socket_6th_stone
	ret

object_interaction_function_calendar_socket_incorrect_item:
	ld de, TEXT_WRONG_ITEM
	jr object_interaction_function_calendar_socket_continue

object_interaction_function_calendar_socket_empty_before_letter2:
	; only place the first 2 stones:
	ld a, (global_state__n_power_stones_in_calendar)
	cp 2
	jr c, object_interaction_function_calendar_socket_try_to_place
	ld de, TEXT_CALENDAR_SOCKET_REFUSE_TO_PLACE
	jr object_interaction_function_calendar_socket_continue

object_interaction_function_calendar_socket_empty_before_letter1:
	ld de, TEXT_CALENDAR_SOCKET_EMPTY
	jr object_interaction_function_calendar_socket_continue

object_interaction_function_calendar_socket_inactive:
	ld a, (global_state__n_power_stones_in_calendar)
	cp 5
	jr z, object_interaction_function_calendar_socket_try_to_place
	ld de, TEXT_CALENDAR_SOCKET_INACTIVE_STONE
object_interaction_function_calendar_socket_continue:
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
	ret

object_interaction_function_calendar_socket_1st_stone:
	ld a, STORY_STATE__PLACED_FIRST_POWER_STONE
	ld (global_state__story), a
	push ix
		ld de, TEXT_PLACE_FIRST_POWER_STONE
		ld hl, display_in_game_message
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop ix
	ret

object_interaction_function_calendar_socket_3rd_stone:
	push ix
		ld de, TEXT_PLACE_THIRD_POWER_STONE
		ld hl, display_in_game_message
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop ix
	ret

object_interaction_function_calendar_socket_5th_stone:
	push ix
		ld de, TEXT_PLACE_FIFTH_POWER_STONE
		ld hl, display_in_game_message
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop ix
	ret

object_interaction_function_calendar_socket_6th_stone:
	push ix
		ld de, TEXT_PLACE_SIXTH_POWER_STONE
		ld hl, display_in_game_message
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
		ld de, TEXT_PLACE_SIXTH_POWER_STONE2
		ld hl, display_in_game_message
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop ix
	ret


;-----------------------------------------------
object_interaction_function_calendar_center:
	ld a, (global_state__n_power_stones_in_calendar)
	cp 5
	ret c
; 	ld a, (global_state__story)
; 	cp STORY_STATE__FIGHTING_ALIENS
; 	ret z
; 	cp STORY_STATE__DEFEATED_ALIENS
; 	jr z, object_interaction_function_calendar_center_continue2
	ld hl, object_interaction_function_calendar_center_in_text_page
	ld a, TEXT_PAGE
	jp jp_to_hl_in_page_a_8000

; object_interaction_function_calendar_center_continue2:
; 	; trigger ending:
; 	ld hl, calendar_stone_center_trigger_ending_event_fn
; 	ld (in_game_event_fn_ptr), hl
; 	ld a, CALENDAR_EVENTS_PAGE
; 	ld (in_game_event_fn_page), a
; 	ret


;-----------------------------------------------
object_interaction_function_teleporter:
	ld a, (global_state__n_power_stones_in_calendar)
	or a
	ret z  ; no power stones in calendar yet, teleporters are off
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld d, 0
	ld hl, global_state__objects
	add hl, de
	ld a, (hl)
	or a
	jr z, object_interaction_function_teleporter_was_off

	; teleporter was already activated, teleport!
	ld hl, global_state__used_teleporter_before
	ld a, (hl)
	or a
	jr nz, object_interaction_function_teleporter_not_first_time
	ld de, TEXT_FIRST_TELEPORTATION1
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
object_interaction_function_teleporter_not_first_time:

	ld hl, display_map_from_teleporter
	ld c, MAP_PAGE
	call call_hl_in_page_c_8000
	
	jp state_play_from_loaded_room
object_interaction_function_teleporter_was_off:
	; activate teleporter:
	ld (hl), 1

	ld hl, SFX_activate_teleporter
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	ld (hl), #ff

	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld hl, set_large_object_to_upload_to_vdp
	ld c, PCG_PAGE
	jp call_hl_in_page_c_8000


;-----------------------------------------------
object_interaction_function_teleporter_atlantis:
	ld a, (global_state__maya_riddle)
	cp 2
	ret nz  ; teleporters to mars/moon are still off
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	or a
	jr z, object_interaction_function_teleporter_atlantis_to_mars
object_interaction_function_teleporter_atlantis_to_moon:
	ld bc, 11*256 + TAG_TELEPORTER_MOON
	jr object_interaction_function_teleport_to_area_object
object_interaction_function_teleporter_atlantis_to_mars:
	ld bc, 10*256 + TAG_TELEPORTER_MARS
	jr object_interaction_function_teleport_to_area_object


;-----------------------------------------------
object_interaction_function_teleporter_mars:
	ld bc, 9*256 + TAG_TELEPORTER_ATLANTIS
	jr object_interaction_function_teleport_to_area_object


;-----------------------------------------------
object_interaction_function_teleporter_moon:
	ld bc, 9*256 + TAG_TELEPORTER_ATLANTIS_TO_MOON
	; jr object_interaction_function_teleport_to_area_object


;-----------------------------------------------
; input:
; - b: area
; - c: teleporter object ID
object_interaction_function_teleport_to_area_object:
	; teleport:
	push bc
		ld e, b
		ld hl, interarea_exit_screen
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop bc

	ld a, b
	cp 9
	jr nz, object_interaction_function_teleport_to_area_object_continue
	; teleporting to Atlantis, this is a special case, we need to go to the teleporter room:
	ld a, c
	ld e, TELEPORTER_ROOM_ID
	push af
		jr object_interaction_function_teleport_to_area_object_room_id_set
object_interaction_function_teleport_to_area_object_continue:

	; get the room where the teleporter is:
	ld hl, current_area__objects
	ld a, c
	push af
		ld bc, AREA_OBJECT_STRUCT_SIZE
object_interaction_function_teleport_to_area_object_find_room_loop:
		cp (hl)
		jr z, object_interaction_function_teleport_to_area_object_find_room_loop_found
		add hl, bc
		jr object_interaction_function_teleport_to_area_object_find_room_loop
object_interaction_function_teleport_to_area_object_find_room_loop_found:
		inc hl
		ld a, (hl)  ; teleporter offset
		; convert offset from chunk coordinates to room coordinates:
		ld hl, covert_chunk_offset_to_room_offset
      	ld c, PCG_PAGE
      	ld e, a
    	call call_hl_in_page_c_8000
	    ld c, e
		ld hl, current_area__room_ids
		add hl, bc
		ld e, (hl)  ; room ID
object_interaction_function_teleport_to_area_object_room_id_set:
		; clear the enemy respawn table:
		push de
			ld hl, current_room__initial_enemy_ids_end
			ld bc, (current_room__initial_enemy_ids_end - current_room__initial_enemy_ids) - 1
			ld a, #ff
			call clear_memory_a
		pop de

		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af

	; find teleporter object, and set player in its position:
	ld e, a
	ld hl, find_tile_object_ptr
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	push hl
	pop ix
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	inc a
	ld (player_x + 1), a
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc a
	ld (player_y + 1), a
	ld a, 6
	ld (player_x), a
	xor a
	ld (player_y), a
	ld (player_state_timer), a
	ld a, PLAYER_STATE_TELEPORT_IN
	ld (player_state), a
	ld a, 31  ; immune while teleporting
	ld (player_immunity_timer), a
	jp state_play_from_loaded_room


;-----------------------------------------------
object_interaction_function_pickup_coins:
	; update stats:
	ld hl, (stats__n_coins_collected)
	inc hl
	ld (stats__n_coins_collected), hl

	; gain coins:
	ld a, (player_inventory_coins)
	add a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)  ; number of coins
	jr nc, object_interaction_function_pickup_coins_continue
	ld a, 255  ; max coins
object_interaction_function_pickup_coins_continue:
	ld (player_inventory_coins), a
object_interaction_function_pickup_coins_entry_point:

	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	ld (hl), #ff

	push ix
		call room_undraw_tile_objects
	pop hl
	call delete_tile_object_in_hl
	jp room_render_tile_objects


;-----------------------------------------------
object_interaction_function_pickup_corn:
	; gain corn:
	ld a, (player_max_health)
	ld c, a
	ld a, (player_health)
	add a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)  ; amount to heal
	cp c
	jr c, object_interaction_function_pickup_corn_continue
	ld a, c
object_interaction_function_pickup_corn_continue:
	ld (player_health), a
	jp object_interaction_function_pickup_coins_entry_point


;-----------------------------------------------
object_interaction_function_pickup_stones:
	ld c, 99
	ld a, (player_inventory_weapon_ammo)
	add a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)  ; # of stones
	cp c
	jr c, object_interaction_function_pickup_stones_continue
	ld a, c
object_interaction_function_pickup_stones_continue:
	ld (player_inventory_weapon_ammo), a
	jp object_interaction_function_pickup_coins_entry_point


;-----------------------------------------------
object_interaction_function_pickup_darts:
	ld c, 99
	ld a, (player_inventory_weapon_ammo + 1)
	add a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)  ; # of stones
	cp c
	jr c, object_interaction_function_pickup_darts_continue
	ld a, c
object_interaction_function_pickup_darts_continue:
	ld (player_inventory_weapon_ammo + 1), a
	jp object_interaction_function_pickup_coins_entry_point


;-----------------------------------------------
object_interaction_function_pickup_spears:
	ld c, 99
	ld a, (player_inventory_weapon_ammo + 2)
	add a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)  ; # of stones
	cp c
	jr c, object_interaction_function_pickup_spears_continue
	ld a, c
object_interaction_function_pickup_spears_continue:
	ld (player_inventory_weapon_ammo + 2), a
	jp object_interaction_function_pickup_coins_entry_point


;-----------------------------------------------
object_interaction_function_pickup_battery:
	ld c, 99
	ld a, (player_inventory_weapon_ammo + 3)
	add a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)  ; # of stones
	cp c
	jr c, object_interaction_function_pickup_battery_continue
	ld a, c
object_interaction_function_pickup_battery_continue:
	ld (player_inventory_weapon_ammo + 3), a
	jp object_interaction_function_pickup_coins_entry_point


;-----------------------------------------------
object_interaction_function_shopkeeper:
	ld hl, object_interaction_function_shopkeeper_internal
	ld c, NPCS_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
	ret


;-----------------------------------------------
object_interaction_function_lost_vendor:
	ld hl, object_interaction_function_lost_vendor_internal
	ld c, NPCS_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
	ret


;-----------------------------------------------
object_interaction_function_shopkeeper2:
	ld hl, object_interaction_function_shopkeeper2_internal
	ld c, NPCS_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
	ret


;-----------------------------------------------
object_interaction_function_shop:
	ld hl, object_interaction_function_shop_internal
	ld c, NPCS_PAGE
	push ix
		call call_hl_in_page_c_8000
	pop ix
	ret


;-----------------------------------------------
object_interaction_function_atlantis_hidden_lock:
	; check if we are using boss 5 key:
	ld a, (player_current_item)
	cp N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_BOSS5_KEY
	jr nz, object_interaction_function_atlantis_hidden_lock_fail

	; check that we are interacting with the correct hidden lock:
	ld a, (current_world__atlantis_boss_statue)
	cp (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	jr nz, object_interaction_function_atlantis_hidden_lock_fail

	; correct key, correct lock:
	ld c, 11
	ld a, TAG_BOSS5_CHESTLOCK - TAG_BOSS1_CHESTLOCK
	jp object_interaction_function_open_boss_lock_key_id_loop

object_interaction_function_atlantis_hidden_lock_fail:
	; spawn spikes (and add function to remove them):
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	add a, a
	ld hl, object_interaction_function_atlantis_hidden_lock_tbl2
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, object_interaction_function_atlantis_hidden_lock_tbl1
	ld bc, 2
	ldir

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	ld hl, atlantis_hidden_lock_spikes_event_fn
	ld (in_game_event_fn_ptr), hl
	ld a, TILES_PAGE
	ld (in_game_event_fn_page), a
	ld a, 15  ; time for spikes to be displayed
	ld (in_game_event_fn_arg), a

	ld hl, SFX_ui_wrong
	jp play_SFX_with_high_priority

; spikes gfx
object_interaction_function_atlantis_hidden_lock_tbl1:
	db 8*16 + 2, 252

; spike location
object_interaction_function_atlantis_hidden_lock_tbl2:
	dw current_room__tile_map + 6 + 11*32
	dw current_room__tile_map + 11 + 11*32
	dw current_room__tile_map + 19 + 11*32
	dw current_room__tile_map + 24 + 11*32

; tiles to restore when removing spikes:
object_interaction_function_atlantis_hidden_lock_tbl3:
	db 0, 202
	db 0, 202
	db 203, 0
	db 203, 0

atlantis_hidden_lock_spikes_event_fn:
	ld hl, in_game_event_fn_arg
	ld a, (hl)
	dec (hl)
	or a
	jr z, atlantis_hidden_lock_spikes_event_fn_continue
	; keep the spikes in the screen:
	ld hl, atlantis_hidden_lock_spikes_event_fn
	ld (in_game_event_fn_ptr), hl
	ret
atlantis_hidden_lock_spikes_event_fn_continue:
	; undraw the spikes:
	ld b, 4
	ld hl, object_interaction_function_atlantis_hidden_lock_tbl3
atlantis_hidden_lock_spikes_event_fn_loop:
	push bc
		ld a, 4
		sub b
		add a, a
		push hl
			ld hl, object_interaction_function_atlantis_hidden_lock_tbl2
			ADD_HL_A
			ld e, (hl)
			inc hl
			ld d, (hl)
			ld bc, 2
		pop hl
		ldir
	pop bc
	djnz atlantis_hidden_lock_spikes_event_fn_loop
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	ret


;-----------------------------------------------
; output:
; - z: door found
; - nz: door not found
; - hl: door ptr
find_room_door_object_ptr:
	ld hl, current_room__tile_objects
	; : ds virtual MAX_ROOM_TILE_OBJECTS * ROOM_TILE_OBJECT_STRUCT_SIZE
find_room_door_object_ptr_loop:
	ld a, (hl)
	cp #ff
	jr z, find_room_door_object_ptr_not_found
	cp #fe
	jr z, find_room_door_object_ptr_not_found
	inc hl
	ld a, (hl)  ; type
	dec hl
	cp TAG_DOOR_VERTICAL
	ret z
	cp TAG_DOOR_HORIZONTAL
	ret z
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jr find_room_door_object_ptr_loop
find_room_door_object_ptr_not_found:
	or 1
	ret


;-----------------------------------------------
; input:
; - e: type
; output:
; - z: object found
; - nz: object not found
; - hl: object ptr
find_tile_object_ptr:
	ld hl, current_room__tile_objects
	; : ds virtual MAX_ROOM_TILE_OBJECTS * ROOM_TILE_OBJECT_STRUCT_SIZE
find_tile_object_ptr_loop:
	ld a, (hl)
	cp #ff
	jr z, find_tile_object_ptr_not_found
	cp #fe
	jr z, find_tile_object_ptr_not_found
	inc hl
	ld a, (hl)  ; type
	dec hl
	cp e
	ret z
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jr find_tile_object_ptr_loop
find_tile_object_ptr_not_found:
	or 1
	ret

;-----------------------------------------------
; types:
; - 0: save background, then render
; - 1: render directly
; - 2: do not render
TILE_OBJECT_DATA: macro type, dx, dy, gfx_ptr
	db type, dx, dy
	dw gfx_ptr
endm


tile_object_gfx_table:
REPT TAG_RED_LOCK  ; add filler
	TILE_OBJECT_DATA 2, 0, 0, 0
ENDR
; TAG_NONE: equ 0
; TAG_BLOCK_PUZZLE1: equ 1
; TAG_BLOCK_PUZZLE2: equ 2
; TAG_BLOCK_PUZZLE3: equ 3
; TAG_BLOCK_PUZZLE4: equ 4
; TAG_BUTTON_DOOR1: equ 5
; TAG_BUTTON_DOOR2: equ 6
; TAG_BUTTON_DOOR3: equ 7
; TAG_BUTTON_DOOR4: equ 8
; TAG_BREAKABLE_WALL1: equ 9
; TAG_BREAKABLE_WALL2: equ 10
; TAG_BREAKABLE_WALL3: equ 11
; TAG_BREAKABLE_WALL4: equ 12
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_RED_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_GREEN_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_BLUE_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_YELLOW_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_WHITE_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_PURPLE_LOCK
	TILE_OBJECT_DATA 1, 4, 4, tile_object_4x4_object_gfx  ; TAG_TRIAL1_LOCK
	TILE_OBJECT_DATA 1, 4, 4, tile_object_4x4_object_gfx  ; TAG_TRIAL2_LOCK
	TILE_OBJECT_DATA 1, 4, 4, tile_object_4x4_object_gfx  ; TAG_TRIAL3_LOCK
	TILE_OBJECT_DATA 1, 4, 4, tile_object_4x4_object_gfx  ; TAG_TRIAL4_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_lever_up_object_gfx  ; TAG_COMBINATION1_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_lever_up_object_gfx  ; TAG_COMBINATION2_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_lever_up_object_gfx  ; TAG_COMBINATION3_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_lever_up_object_gfx  ; TAG_COMBINATION4_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_BALL_LOCK
	TILE_OBJECT_DATA 1, 4, 3, tile_object_idol_lock_locked_gfx  ; TAG_IDOL_LOCK
	TILE_OBJECT_DATA 1, 4, 3, tile_object_gear_lock_locked_gfx  ; TAG_GEAR_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_ASTRONAUT_LOCK
REPT TAG_TELEPORTER_ATLANTIS - TAG_START  ; add filler
	TILE_OBJECT_DATA 2, 0, 0, 0
ENDR
; TAG_START: equ 31
; TAG_ENDING: equ 32
; TAG_MIDPOINT: equ 33
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER_ATLANTIS
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER_MARS
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER_MOON
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BUTTON1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BUTTON2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BUTTON3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BUTTON4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_RED_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_GREEN_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BLUE_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_YELLOW_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WHITE_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_PURPLE_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_RED_CHEST
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_GREEN_CHEST
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BLUE_CHEST
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_YELLOW_CHEST
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WHITE_CHEST
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_PURPLE_CHEST
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_TRIAL1_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_TRIAL2_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_TRIAL3_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_TRIAL4_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_COMBINATION1_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_COMBINATION2_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_COMBINATION3_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_COMBINATION4_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BALL_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_IDOL_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_GEAR_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ASTRONAUT_KEY
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_BOSS1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS1_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS1_CHESTLOCK
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_BOSS2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS2_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS2_CHESTLOCK
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_BOSS3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS3_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS3_CHESTLOCK
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_BOSS4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS4_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS4_CHESTLOCK
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_BOSS5
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS5_KEY
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_BOSS5_CHESTLOCK  ; the atlantis ones are hidden
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_BOSS6
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS6_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS6_CHESTLOCK
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_BOSS7
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS7_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS7_CHESTLOCK
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_HAMMER
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_MACUAHUITL
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_SHIELD
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_SLING
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_BLOWGUN
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_ATLATL
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_RAYGUN
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_OBSIDIAN_KNIVE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_FIRE_HAMMER
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_WEAPON_ICE_MACUAHUITL
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAP_PIECE1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAP_PIECE2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAP_PIECE3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAP_PIECE4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAP_PIECE5
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAP_PIECE6
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAP_PIECE7
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART5
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAYA_RIDDLE_CLUE1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAYA_RIDDLE_CLUE2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAYA_RIDDLE_CLUE3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAYA_RIDDLE_CLUE4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_STORY_TRIVIA1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_STORY_TRIVIA2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_STORY_TRIVIA3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_STORY_TRIVIA4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_STORY_TRIVIA5
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_STORY_TRIVIA6
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_STORY_TRIVIA7
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_STORY_TRIVIA8
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_SANDALS
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_GLOVES
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_WARRIOR_HAT
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_ARMOR
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_CHAAC
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_SEASHELL
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_BELT
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_ICE_CAPE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SMALL_KEY1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SMALL_KEY2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SMALL_KEY3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SMALL_KEY4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SMALL_KEY_CHEST1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SMALL_KEY_CHEST2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SMALL_KEY_CHEST3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SMALL_KEY_CHEST4
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER1
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER2
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER3
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER4
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER5
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER6
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER7
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER8
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_CALENDAR_NAME_CLUE
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_LOST_VENDOR
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_STORY1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_STORY2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_STORY3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_STORY4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_STORY5
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_LORDS1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_LORDS2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_LORDS3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_LORDS4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_LORDS5
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_LORDS6
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_LORDS7
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_CLUE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ATLANTIS_TABLET1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ATLANTIS_TABLET2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ATLANTIS_TABLET3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ATLANTIS_TABLET4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ATLANTIS_TABLET5

	TILE_OBJECT_DATA 0, 2, 2, tile_object_pushable_block_gfx  ; TAG_PUSHABLE_BLOCK
	TILE_OBJECT_DATA 1, 1, 3, tile_object_v_door_gfx  ; TAG_DOOR_VERTICAL
	TILE_OBJECT_DATA 1, 4, 1, tile_object_h_door_gfx  ; TAG_DOOR_HORIZONTAL
	TILE_OBJECT_DATA 1, 4, 4, tile_object_4x4_object_gfx  ; TAG_DOOR_BOSS
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_POWER_STONE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_CALENDAR_TABLET
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_CALENDAR_SOCKET
	TILE_OBJECT_DATA 0, 2, 2, tile_object_half_power_stone_gfx  ; TAG_HALF_POWER_STONE
	TILE_OBJECT_DATA 1, 2, 2, tile_object_calendar_stone_center_gfx  ; TAG_CALENDAR_STONE_CENTER
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAYA_PUZZLE_TABLET
	TILE_OBJECT_DATA 1, 4, 3, tile_object_teleporter_gfx  ; TAG_TELEPORTER_ATLANTIS_TO_MOON
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_PUZZLEBOX_MARS
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_PUZZLEBOX_MOON
	TILE_OBJECT_DATA 0, 2, 2, tile_object_charybdis_eye_gfx  ; TAG_CHARYBDIS_EYE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_scylla_eye_gfx  ; TAG_SCYLLA_EYE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_coin_gfx  ; TAG_COIN
	TILE_OBJECT_DATA 0, 2, 2, tile_object_corn_gfx  ; TAG_CORN
	TILE_OBJECT_DATA 0, 2, 2, tile_object_stones_gfx  ; TAG_STONES
	TILE_OBJECT_DATA 0, 2, 2, tile_object_darts_gfx  ; TAG_DARTS
	TILE_OBJECT_DATA 0, 2, 2, tile_object_spears_gfx  ; TAG_SPEARS
	TILE_OBJECT_DATA 0, 2, 2, tile_object_battery_gfx  ; TAG_BATTERY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_XIBALBA_BOSS_TABLET
	TILE_OBJECT_DATA 1, 2, 3, tile_object_xibalba_boss_graves_gfx  ; TAG_XIBALBA_BOSS_GRAVE
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_GOLDEN_KEY
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_SKULL_CHARM	
	TILE_OBJECT_DATA 2, 2, 2, 0  ; TAG_POSEIDON_LEVER	
	TILE_OBJECT_DATA 2, 2, 2, 0  ; TAG_POSEIDON_BOSS_DISPLAY
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_NPC_SHOPKEEPER
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_NPC_SHOP
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_DYNAMITE
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_NPC_SHOPLEEPER2
	TILE_OBJECT_DATA 1, 4, 4, tile_object_carnivore_plant  ; TAG_ENEMY_CARNIVORE_PLANT
	TILE_OBJECT_DATA 0, 2, 2, tile_object_bee_hive  ; TAG_ENEMY_BEE_HIVE
	TILE_OBJECT_DATA 1, 3, 2, tile_object_ant_colony  ; TAG_ENEMY_ANT_COLONY
	TILE_OBJECT_DATA 1, 3, 2, tile_object_ant_colony  ; TAG_ENEMY_ANT_COLONY2
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_ENEMY_IMP_GENERATOR
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_ENEMY_IMP_GENERATOR2
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_ENEMY_FIREBALL_GENERATOR
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_ENEMY_LAVA_GENERATOR
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_ENEMY_STONE_OWL
	TILE_OBJECT_DATA 2, 0, 0, 0  ; TAG_ENEMY_SENTINEL


tile_object_regular_object_gfx:
	db FIRST_ITEM_TILE, FIRST_ITEM_TILE+1, FIRST_ITEM_TILE+2, FIRST_ITEM_TILE+3
tile_object_pushable_block_gfx:
	db 185, 187, 182, 184
tile_object_h_door_gfx:
	db 109, 110, 110, 111
tile_object_v_door_gfx:
	db 106, 107, 108
tile_object_teleporter_gfx:
tile_object_idol_lock_locked_gfx:
tile_object_gear_lock_locked_gfx:
	db 48, 49, 50, 51
	db 52, 53, 54, 55
	db 56, 57, 58, 59
tile_object_lever_left_object_gfx:
	db 48, 0, 51, 52
tile_object_lever_up_object_gfx:
	db 50, 0, 51, 52
tile_object_lever_right_object_gfx:
	db 0, 49, 51, 52
tile_object_4x4_object_gfx:
	db 48, 49, 50, 51
	db 52, 53, 54, 55
	db 56, 57, 58, 59
	db 60, 61, 62, 63
tile_object_calendar_socket_gfx:
	db 190, 191, 206, 207
	db 222, 223, 238, 239
	db 220, 221, 236, 237
tile_object_half_power_stone_gfx:
	db 0, 0, FIRST_ITEM_TILE+2, FIRST_ITEM_TILE+3

tile_object_calendar_stone_center_gfx:
	db 147, 148, 180, 181
tile_object_calendar_stone_center_frame2_gfx:
	db 116, 117, 118, 119
tile_object_calendar_stone_center_frame3_gfx:
	db 213, 229, 120, 121

tile_object_coin_gfx:
	db 0, 0, 6, 0
tile_object_corn_gfx:
	db 32, 33, 34, 35
tile_object_stones_gfx:
	db 0, 0, 36, 37
tile_object_darts_gfx:
	db 0, 0, 40, 41
tile_object_spears_gfx:
	db 0, 0, 38, 39
tile_object_battery_gfx:
	db 42, 0, 43, 0


tile_object_bee_hive:
	db 64, 65
	db 66, 67

tile_object_ant_colony:
	db 0, 68, 0
	db 69, 70, 71

tile_object_xibalba_boss_graves_gfx:
	db 203, 204
	db 219, 220
	db 235, 236

tile_object_poseidon_boss_display_object_gfx:
	db 60, 61, 62, 63  ; charybdis
	db 53, 57, 62, 63  ; scylla
	db 53, 54, 55, 56  ; death
	db 53, 57, 58, 59  ; both

tile_object_charybdis_eye_gfx:
tile_object_scylla_eye_gfx:
	db 228, 227
	db 226, 225

