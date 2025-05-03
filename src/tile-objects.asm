;-----------------------------------------------
update_tile_objects:
	ld hl, current_room__tile_objects
update_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff
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
; input:
; - hl: ptr of the tile object to delete
delete_tile_object_in_hl:
	; copy:
	; - from: hl + ROOM_TILE_OBJECT_STRUCT_SIZE
	; - to: hl
	; - amount: (current_room__tile_objects_sentinel - (hl + ROOM_TILE_OBJECT_STRUCT_SIZE) + 1
	; to:
	ld e, l
	ld d, h
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	push hl
		ld c, l
		ld b, h
		ld hl, current_room__tile_objects_sentinel
		or a
		sbc hl, bc
		inc hl
		ld c, l
		ld b, h
	pop hl
	ldir
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
	; render the object:
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_BREAKABLE_WALL1
		jr z, room_render_tile_objects_loop_continue
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
		jr z, room_render_tile_objects_render_saving_background  ; type 0: saving background
		dec a
		jr z, room_render_tile_objects_render  ; type 1: rendering directly
room_render_tile_objects_loop_continue:
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp room_render_tile_objects_loop


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
	pop iy  ; recover the ptr to the object in iy
	push iy
		push bc
			ld c, ixl
			ld b, ixh
			call get_room_tile_ptr
		pop bc
		push ix
room_render_tile_objects_render_saving_background_loop_y:
			push ix
			push bc
			push hl
room_render_tile_objects_render_saving_background_loop_x:
				; check that:
				; - ixl < current_room__width
				; - ixl >= 0
				; - ixh < current_room__height
				ld a, (current_room__width)
				cp ixl
				jr z, room_render_tile_objects_render_saving_background_loop_x_continue
				jr c, room_render_tile_objects_render_saving_background_loop_x_continue
				ld a, ixl
				or a
				jp m, room_render_tile_objects_render_saving_background_loop_x_continue
				ld a, (current_room__height)
				cp ixh
				jr z, room_render_tile_objects_render_saving_background_loop_x_continue
				jr c, room_render_tile_objects_render_saving_background_loop_x_continue

				; save background:
				ld a, (hl)
				ld (iy + ROOM_TILE_OBJECT_STRUCT_BACKGROUND), a
				ld a, (de)
				ld (hl), a

room_render_tile_objects_render_saving_background_loop_x_continue:
				inc de
				inc hl
				inc iy
				inc ixl
				ld a, ixl
				or a
				jr nz, room_render_tile_objects_render_saving_background_loop_x_continue2
				; if ixl turned 0, it means the previous pointer was probably bad, so, we need to recompute it:
				push bc
					ld c, ixl
					ld b, ixh
					call get_room_tile_ptr					
				pop bc
room_render_tile_objects_render_saving_background_loop_x_continue2:
				dec c
				jr nz, room_render_tile_objects_render_saving_background_loop_x
			pop hl
			pop bc
			pop ix
			inc ixh
			ld a, (current_room__width)
			ADD_HL_A
			djnz room_render_tile_objects_render_saving_background_loop_y
		pop ix
		jp room_render_tile_objects_loop_continue


room_render_tile_objects_render:
		; Note, we do not need to take into account room bounds here, since this method
		; is for objects that are static, and hence will always be within screen bounds.
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
room_render_tile_objects_render_entry_point:
		; compute ptr where to draw:
		push bc
			ld c, ixl
			ld b, ixh
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
		jp room_render_tile_objects_loop_continue


;-----------------------------------------------
room_render_tile_objects_render_v_door:
	inc hl
	ld c, (hl)  ; x
	ld ixl, c
	inc hl
	ld b, (hl)  ; y
	ld ixh, b
	ld bc, #0301
	inc hl
	inc hl
	inc hl
	inc hl
	ld de, tile_object_v_door_gfx
	jp room_render_tile_objects_render_entry_point


room_render_tile_objects_render_h_door:
	inc hl
	ld c, (hl)  ; x
	ld ixl, c
	inc hl
	ld b, (hl)  ; y
	ld ixh, b
	ld bc, #0104
	inc hl
	inc hl
	inc hl
	inc hl
	ld de, tile_object_h_door_gfx
	jp room_render_tile_objects_render_entry_point


room_render_tile_objects_render_combination_lever:
	inc hl
	ld c, (hl)  ; x
	ld ixl, c
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld ixh, b
	ld bc, #0202
	ld a, (hl)
	add a, a
	add a, a
	ld de, tile_object_lever_left_object_gfx
	ADD_DE_A
	inc hl
	inc hl
	inc hl
	jp room_render_tile_objects_render_entry_point


;-----------------------------------------------
; restores the background that was removed by tile objects
room_undraw_tile_objects:
	ld hl, current_room__tile_objects_sentinel - ROOM_TILE_OBJECT_STRUCT_SIZE  ; ptr to the last object
	ld b, (current_room__tile_objects_sentinel - current_room__tile_objects)/ROOM_TILE_OBJECT_STRUCT_SIZE
room_undraw_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff
	jr z, room_undraw_tile_objects_loop_continue_no_pop
	; render the object:
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
		jr z, room_undraw_tile_objects_restore_background  ; type 0: we had saved the background
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


room_undraw_tile_objects_restore_background:
		; - hl: ptr to tile_object_gfx_table
		; - ixl, ixh: x, y of the object
		inc hl
		ld c, (hl)  ; width
		inc hl
		ld b, (hl)  ; height
		; compute ptr where to draw:
	pop iy  ; recover the ptr to the object in iy
	push iy
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
				ld a, (iy + ROOM_TILE_OBJECT_STRUCT_BACKGROUND)
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
		jp room_undraw_tile_objects_loop_continue


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
	push ix
	pop hl
	jp delete_tile_object_in_hl


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
	dw object_interaction_function_empty  ; TAG_TELEPORTER_ATLANTIS
	dw object_interaction_function_empty  ; TAG_TELEPORTER_MARS
	dw object_interaction_function_empty  ; TAG_TELEPORTER_MOON
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
	dw object_interaction_function_empty  ; TAG_BOSS1_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS2
	dw object_interaction_function_pickup_item  ; TAG_BOSS2_KEY
	dw object_interaction_function_empty  ; TAG_BOSS2_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS3
	dw object_interaction_function_pickup_item  ; TAG_BOSS3_KEY
	dw object_interaction_function_empty  ; TAG_BOSS3_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS4
	dw object_interaction_function_pickup_item  ; TAG_BOSS4_KEY
	dw object_interaction_function_empty  ; TAG_BOSS4_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS5
	dw object_interaction_function_pickup_item  ; TAG_BOSS5_KEY
	dw object_interaction_function_empty  ; TAG_BOSS5_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS6
	dw object_interaction_function_pickup_item  ; TAG_BOSS6_KEY
	dw object_interaction_function_empty  ; TAG_BOSS6_CHESTLOCK
	dw object_interaction_function_empty  ; TAG_BOSS7
	dw object_interaction_function_pickup_item  ; TAG_BOSS7_KEY
	dw object_interaction_function_empty  ; TAG_BOSS7_CHESTLOCK
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
	dw object_interaction_function_pickup_map_piece  ; TAG_MAP_PIECE8
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
	dw object_interaction_function_pickup_item  ; TAG_ITEM_HURAKAN
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
	dw object_interaction_function_empty  ; TAG_PUSHABLE_BLOCK
	dw object_interaction_function_empty  ; TAG_DOOR_VERTICAL
	dw object_interaction_function_empty  ; TAG_DOOR_HORIZONTAL
	dw object_interaction_function_empty  ; TAG_DOOR_BOSS


object_interaction_inventory_slot:
	db #ff, #ff, #ff, #ff, #ff  ; none, block puzzles
	db #ff, #ff, #ff, #ff  ; button doors
	db #ff, #ff, #ff, #ff  ; breakable walls
	db #ff, #ff, #ff, #ff, #ff, #ff  ; color locks
	db #ff, #ff, #ff, #ff  ; trial locks
	db #ff, #ff, #ff, #ff  ; combination locks
	db #ff, #ff, #ff, #ff  ; special locks
	db #ff, #ff, #ff, #ff, #ff, #ff  ; start, ending, midpoint, teleporters
	db #ff, #ff, #ff, #ff  ; buttons
	db 14, 15, 16, 17, 18, 19  ; color keys
	db #ff, #ff, #ff, #ff, #ff, #ff  ; color chests
	db #ff, #ff, #ff, #ff  ; trial clues
	db #ff, #ff, #ff, #ff  ; combination clues
	db 21, 22, 23, 24  ; key items
	db #ff, 0, #ff  ; boss1
	db #ff, 1, #ff  ; boss2
	db #ff, 2, #ff  ; boss3
	db #ff, 3, #ff  ; boss4
	db #ff, 4, #ff  ; boss5
	db #ff, 5, #ff  ; boss6
	db #ff, 6, #ff  ; boss7
	db 1, 2, 3  ; weapons
	db 4, 5, 6, 7  ; ranged weapons
	db 8, 9, 10  ; upgraded weapons
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; map pieces
	db #ff, #ff, #ff, #ff, #ff  ; hearts
	db #ff, #ff, #ff, #ff  ; riddle clues
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; story trivia
	db 25, 26, 27, 28, 29, 30  ; maya upgrade items
	db 31, 32  ; alien upgrade items
	db 20, 20, 20, 20  ; small keys
	db #ff, #ff, #ff, #ff  ; small key chests


;-----------------------------------------------
object_interaction_function_empty:
	ret


;-----------------------------------------------
object_interaction_function_pickup_item:
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
	ADD_HL_A
	ld (hl), 1

	ld hl, redraw_flags
	ld (hl), #ff

	push ix
		call room_undraw_tile_objects
	pop hl
	call delete_tile_object_in_hl
	jp room_render_tile_objects


;-----------------------------------------------
object_interaction_function_pickup_weapon:
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
	ld hl, player_inventory_n_small_keys
	inc (hl)
	ld hl, player_inventory_items + 20  ; small key
	ld (hl), 1
	jr object_interaction_function_pickup_small_key_continue


;-----------------------------------------------
object_interaction_function_pickup_map_piece:
	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority

	ld hl, player_inventory_map_pieces
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	sub (TAG_MAP_PIECE1 - 1)
	ADD_HL_A
	ld (hl), 1

	ld de, TEXT_MAP_PIECE_PICKUP
	jr object_interaction_function_pickup_map_piece_continue


;-----------------------------------------------
object_interaction_function_pickup_heart:
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
	add 25 - TAG_RED_CHEST
	ld c, a  ; c = desired key
	ld hl, player_current_item
	cp (hl)
	jr nz, object_interaction_function_chest_fail

	; lose key:
	ld (hl), 0  ; machete
	ld a, c
	sub 25  ; position of the first color key
	ld b, 0
	ld c, a
	ld hl, player_inventory_items + 14
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
	ld hl, player_inventory_items + 20  ; small key location
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
	jp room_render_tile_objects


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
	jp room_render_tile_objects


;-----------------------------------------------
object_interaction_function_open_small_lock:
	; check if the player has the proper key selected
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	add 25 - TAG_RED_LOCK
	ld c, a  ; c = desired key
	ld hl, player_current_item
	cp (hl)
	jr nz, object_interaction_function_chest_fail

	; lose key:
	ld (hl), 0  ; machete
	ld a, c
	sub 25  ; position of the first color key
	ld b, 0
	ld c, a
	ld hl, player_inventory_items + 14
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
	ld hl, SFX_door_open
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	ld (hl), #ff
	call room_undraw_tile_objects
	call find_room_door_object_ptr
	jp nz, room_render_tile_objects  ; no door
	push hl
	pop ix

	; Create an entry in "global_state__open_walls":
	ld hl, global_state__open_walls
room_mark_open_door_loop:
	ld a, (hl)
	or a
	jr z, room_mark_open_door_loop_end
	ld bc, 6
	add hl, bc
	jr room_mark_open_door_loop
room_mark_open_door_loop_end:
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
	ld (hl), a  ; chunk where this door is
	inc hl
	; get within-chunk coordinates:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	and #0f
	ld c, a  ; c = x % CHUNK_WIDTH
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
room_mark_open_door_chunk_y_loop:
	cp CHUNK_HEIGHT
	jr c, room_mark_open_door__continue
	sub CHUNK_HEIGHT
	jr room_mark_open_door_chunk_y_loop
room_mark_open_door__continue:
	ld b, a  ; b = y % CHUNK_HEIGHT
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_DOOR_VERTICAL
	jr z, room_mark_open_door__vertical
	ld e, 4
	ld d, 1
	jr room_mark_open_door__dimensions_set
room_mark_open_door__vertical:
	ld e, 1
	ld d, 3
room_mark_open_door__dimensions_set:
	ld (hl), e
	inc hl
	ld (hl), d

	; If it's a door down to an inter-area connection, replace by a ladder:
	cp TAG_DOOR_HORIZONTAL
	jr nz, room_mark_open_door__no_ladder_replacement
	; is it at the bottom of the room?
	ld a, (current_room__height)
	dec a
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jr nz, room_mark_open_door__no_ladder_replacement
	; is it an inter-area connection? (check if we are at the edge of the map, or there is no chunk below)
	ld a, (current_room__y)
	ld c, a
	ld a, (current_room__height_in_screens)
	add a, c
	ld c, a
	ld a, (current_area__height)
	cp c
	jr z, room_mark_open_door__inter_area_connection

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
	jr nz, room_mark_open_door__no_ladder_replacement

room_mark_open_door__inter_area_connection:
	; replace by a ladder:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	call get_room_tile_ptr
	ld (hl), 254  ; platform
	inc hl
	ld (hl), 168  ; ladder-left
	inc hl
	ld (hl), 136  ; ladder-right
	inc hl
	ld (hl), 254  ; platform

room_mark_open_door__no_ladder_replacement:
	; remove door:
	push ix
	pop hl
	call delete_tile_object_in_hl
	jp room_render_tile_objects


;-----------------------------------------------
object_interaction_function_open_ball_lock:
	ld a, 11 + 21  ; ball
	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_item_use_fail
	ld (hl), 0  ; machete
	ld hl, player_inventory_items + 21  ; ball
	ld (hl), 0
	jp object_interaction_function_open_small_lock_entry_point

object_interaction_function_open_idol_lock:
	ld a, 11 + 22  ; idol
	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_item_use_fail
	ld (hl), 0  ; machete
	ld hl, player_inventory_items + 22  ; idol
	ld (hl), 0
	jp object_interaction_function_open_small_lock_entry_point

object_interaction_function_open_gear_lock:
	ld a, 11 + 23  ; gear
	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_item_use_fail
	ld (hl), 0  ; machete
	ld hl, player_inventory_items + 23  ; gear
	ld (hl), 0
	jp object_interaction_function_open_small_lock_entry_point

object_interaction_function_open_astronaut_lock:
	ld a, 11 + 24  ; astronaut
	ld hl, player_current_item
	cp (hl)
	jp nz, object_interaction_function_item_use_fail
	ld (hl), 0  ; machete
	ld hl, player_inventory_items + 24  ; astronaut
	ld (hl), 0
	jp object_interaction_function_open_small_lock_entry_point


;-----------------------------------------------
object_interaction_function_tablet:
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

	ld c, TEXT_PAGE
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
	TILE_OBJECT_DATA 1, 2, 2, tile_object_4x4_object_gfx  ; TAG_TRIAL4_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_lever_up_object_gfx  ; TAG_COMBINATION1_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_lever_up_object_gfx  ; TAG_COMBINATION2_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_lever_up_object_gfx  ; TAG_COMBINATION3_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_lever_up_object_gfx  ; TAG_COMBINATION4_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_BALL_LOCK
	TILE_OBJECT_DATA 1, 4, 3, tile_object_idol_lock_locked_gfx  ; TAG_IDOL_LOCK
	TILE_OBJECT_DATA 1, 4, 3, tile_object_gear_lock_locked_gfx  ; TAG_GEAR_LOCK
	TILE_OBJECT_DATA 1, 2, 2, tile_object_regular_object_gfx  ; TAG_ASTRONAUT_LOCK
REPT TAG_BUTTON1 - TAG_START  ; add filler
	TILE_OBJECT_DATA 2, 0, 0, 0
ENDR
; TAG_START: equ 31
; TAG_ENDING: equ 32
; TAG_MIDPOINT: equ 33
; TAG_TELEPORTER_ATLANTIS: equ 34
; TAG_TELEPORTER_MARS: equ 35
; TAG_TELEPORTER_MOON: equ 36
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
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_BOSS5_CHESTLOCK
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
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_MAP_PIECE8
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART1
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART2
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART3
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART4
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_HEART5
REPT TAG_ITEM_SANDALS - TAG_MAYA_RIDDLE_CLUE1  ; add filler
	TILE_OBJECT_DATA 2, 0, 0, 0
ENDR
; TAG_MAYA_RIDDLE_CLUE1: equ 109
; TAG_MAYA_RIDDLE_CLUE2: equ 110
; TAG_MAYA_RIDDLE_CLUE3: equ 111
; TAG_MAYA_RIDDLE_CLUE4: equ 112
; TAG_STORY_TRIVIA1: equ 113
; TAG_STORY_TRIVIA2: equ 114
; TAG_STORY_TRIVIA3: equ 115
; TAG_STORY_TRIVIA4: equ 116
; TAG_STORY_TRIVIA5: equ 117
; TAG_STORY_TRIVIA6: equ 118
; TAG_STORY_TRIVIA7: equ 119
; TAG_STORY_TRIVIA8: equ 120
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_SANDALS
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_GLOVES
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx  ; TAG_ITEM_HURAKAN
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

	TILE_OBJECT_DATA 0, 2, 2, tile_object_pushable_block_gfx  ; TAG_PUSHABLE_BLOCK
	TILE_OBJECT_DATA 1, 1, 3, tile_object_v_door_gfx  ; TAG_DOOR_VERTICAL
	TILE_OBJECT_DATA 1, 4, 1, tile_object_h_door_gfx  ; TAG_DOOR_HORIZONTAL
	TILE_OBJECT_DATA 1, 4, 4, tile_object_4x4_object_gfx  ; TAG_DOOR_BOSS
	

tile_object_regular_object_gfx:
	db FIRST_ITEM_TILE, FIRST_ITEM_TILE+1, FIRST_ITEM_TILE+2, FIRST_ITEM_TILE+3
tile_object_pushable_block_gfx:
	db 185, 187, 182, 184
tile_object_h_door_gfx:
	db 109, 110, 110, 111
tile_object_v_door_gfx:
	db 106, 107, 108
tile_object_idol_lock_locked_gfx:
tile_object_gear_lock_locked_gfx:
	db 48, 49, 50, 51
	db 52, 53, 54, 55
	db 56, 57, 58, 59
tile_object_lever_left_object_gfx:
	db 48, 53, 51, 52
tile_object_lever_up_object_gfx:
	db 50, 53, 51, 52
tile_object_lever_right_object_gfx:
	db 53, 49, 51, 52
tile_object_4x4_object_gfx:
	db 48, 49, 50, 51
	db 52, 53, 54, 55
	db 56, 57, 58, 59
	db 60, 61, 62, 63

