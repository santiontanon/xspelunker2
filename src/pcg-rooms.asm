;-----------------------------------------------
; Temporary variables (overlapping with the buffer):
tmp_pcg_room__current_target_chunk_bank_id: equ buffer_4096 + 4094
tmp_pcg_room__current_decompressed_chunk_bank_id: equ tmp_pcg_room__current_target_chunk_bank_id - 1
tmp_pcg_room__next_object_ptr: equ tmp_pcg_room__current_decompressed_chunk_bank_id - 2
tmp_pcg_room__next_tile_object_ptr: equ tmp_pcg_room__next_object_ptr - 2
tmp_pcg_room__chunk_x: equ tmp_pcg_room__next_tile_object_ptr - 1
tmp_pcg_room__chunk_y: equ tmp_pcg_room__chunk_x - 1


;-----------------------------------------------
area_default_tileset_ptrs:
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; jungle
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; pyramid 1
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; pyramid 2
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; confluence
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; pyramid 3
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; fire shaft
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; pacific caves
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; atlantic caves
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; fire temple
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; atlantis
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; mars
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid, tile_collision_types_pyramid - 32  ; moon


;-----------------------------------------------
pcg_generate_room_reset_state:
	ld hl, area_default_tileset_ptrs
	ld a, (current_area__id)
	add a, a
	ld c, a
	add a, a
	add a, c  ; a * 6
	ADD_HL_A
	ld de, current_room__tileset_ptr
	ldi
	ldi  ; current_room__tileset_ptr
	ldi
	ldi  ; current_room__animation_fn_ptr
	ldi
	ldi  ; current_room__collision_ptr
	ld a, TILES_PAGE
	ld (current_room__tileset_page), a
	xor a
	ld (current_room__tileset_overrides_item_tiles), a

	ld hl, player_combination_levers_state
	ld bc, 8 - 1
	ld a, 1
	call clear_memory_a

	ld hl, current_room__objects
	ld (tmp_pcg_room__next_object_ptr), hl
	ld bc, MAX_ROOM_OBJECTS * ROOM_OBJECT_STRUCT_SIZE - 1
	xor a
	ld (player_trial_completion_state), a
	ld (current_room__objects_sentinel), a
	ld (current_room__player_bullets_sentinel), a
	call clear_memory_a

	ld hl, current_room__player_bullets
	ld bc, MAX_ROOM_PLAYER_BULLETS * ROOM_OBJECT_STRUCT_SIZE - 1
	call clear_memory

	ld hl, current_room__tile_objects
	ld (tmp_pcg_room__next_tile_object_ptr), hl
	ld bc, MAX_ROOM_TILE_OBJECTS * ROOM_TILE_OBJECT_STRUCT_SIZE - 1
	ld a, #ff
	ld (current_room__tile_objects_sentinel), a
	jp clear_memory_a


;-----------------------------------------------
; This method fills in the "current_room" data structure by generating a room
; using the information in "current_area". 
; input:
; - e: room ID
pcg_generate_room:
	ld a, e
	ld (current_room__id), a

	ld hl, 0
	ld (item_object_to_upload_to_vdp), hl
	ld (large_object_to_upload_to_vdp), hl
	ld (current_room__trial_fn), hl

	push de
		call pcg_generate_room_reset_state
	pop de	

	; Find x1, y1, x2, y2 of the room in the room IDs map:
	ld ix, #0000  ; x1, y1  (we will store "width - x" and "height - y" since it's easier)
	ld iy, #ffff  ; x2, y2
	ld hl, current_area__room_ids
	ld bc, (current_area__width)  ; c = width, b = height
pcg_generate_room__xy_loop_y:
	push bc
pcg_generate_room__xy_loop_x:
		ld a, e  ; room ID
		cp (hl)
		jr nz, pcg_generate_room__xy_loop_x_skip
		; x1 = max(x1, c)
		ld a, ixl
		cp c
		jr nc, pcg_generate_room__xy_loop_x_skip_x1  ; jump if c <= ixl
		ld ixl, c
pcg_generate_room__xy_loop_x_skip_x1:
		; y1 = max(y1, b)
		ld a, ixh
		cp b
		jr nc, pcg_generate_room__xy_loop_x_skip_y1  ; jump if b <= ixh
		ld ixh, b
pcg_generate_room__xy_loop_x_skip_y1:
		; x2 = min(x2, c)
		ld a, iyl
		cp c
		jr c, pcg_generate_room__xy_loop_x_skip_x2  ; jump if c > iyl
		ld iyl, c
pcg_generate_room__xy_loop_x_skip_x2:
		; y2 = min(y2, b)
		ld a, iyh
		cp b
		jr c, pcg_generate_room__xy_loop_x_skip_y2  ; jump if b > iyh
		ld iyh, b
pcg_generate_room__xy_loop_x_skip_y2:
pcg_generate_room__xy_loop_x_skip:
		inc hl
		dec c
		jr nz, pcg_generate_room__xy_loop_x
	pop bc
	djnz pcg_generate_room__xy_loop_y

	; room coordinates:
	ld a, (current_area__width)
	sub ixl
	ld (current_room__x), a
	ld a, (current_area__height)
	sub ixh
	ld (current_room__y), a

	; Compute the room width/height, and scroll limits:
	; width = ((ixl - iyl) + 1) * 32
	; height = ((ixh - iyh) + 1) * 24
	; max_scroll_x = width - 32
	; max_scroll_y = height - 24
	ld a, ixl
	sub iyl
	inc a
	ld iyl, a  ; iyl now has width in "screens"
	ld (current_room__width_in_screens), a
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a  ; a * 32
	ld (current_room__width), a
	sub 32
	ld (current_room__max_scroll_x), a
	ld a, ixh
	sub iyh
	inc a
	ld iyh, a  ; iyl now has height in "screens"
	ld (current_room__height_in_screens), a
	add a, a
	add a, a
	add a, a
	ld d, a
	add a, a
	add a, d  ; a * 24
	ld (current_room__height), a

	; Get the room seed (from the area seed, generate as many numbers as the room ID):
	ld hl, (current_area__seed)
	ld (rng_seed1), hl
	ld hl, (current_area__seed + 2)
	ld (rng_seed2), hl
	ld b, e  ; roomID
	ld a, b
	or a
	jr z, pcg_generate_room__seed_generated
pcg_generate_room__seed_loop:
	call random_a
	djnz pcg_generate_room__seed_loop
pcg_generate_room__seed_generated:

	; Init the tile map:
	ld hl, current_room__tile_map
	ld bc, MAX_ROOM_SIZE - 1
	call clear_memory

	; check if it's a special room:
	ld a, (current_room__id)
	cp CALENDAR_ROOM_ID
	jp z, pcg_generate_room__calendar	

	; Add background chunks randomly:
	; here:
	; - iyl/iyh have the width/height of the room in "screens"
	; - ixl/ixh have the x1, y1 coordinates of the room
	; hl = current_area__chunks_ids + (width - ixl) * 2 + (height - ixh) * 2 * width * 2
	ld a, (current_area__height)
	sub ixh
	add a, a
	add a, a  ; a = (height - ixh) * 2 * 2
	ld d, 0
	ld e, a
	ld hl, 0
	ld a, (current_area__width)
	; hl *= a
	ld b, a
pcg_generate_room__fb_chunk_ptr_loop:
	add hl, de
	djnz pcg_generate_room__fb_chunk_ptr_loop
	ld a, (current_area__width)
	sub ixl
	add a, a
	ADD_HL_A
	ld de, current_area__chunks_ids
	add hl, de  ; hl = current_area__chunks_ids + (width - ixl) * 2 + (height - ixh) * 2 * width

	push hl
	push ix
	push iy
		call pcg_generate_room_background_pyramid
	pop iy
	pop ix
	pop hl

	; Iterate over the foreground chunk IDs, and copy the proper chunks to the proper places:
	; here:
	; - iyl/iyh have the width/height of the room in "screens"
	; - ixl/ixh have the x1, y1 coordinates of the room
	ld a, #ff
	ld (tmp_pcg_room__current_decompressed_chunk_bank_id), a
	ld b, (pyramid_chunk_fg_bank_ptrs_end - pyramid_chunk_fg_bank_ptrs) / 2  ; number of banks
pcg_generate_room__fg_loop_bank_id:
	push bc
	push hl
		ld a, b
		dec a
		add a, a
		add a, a
		add a, a
		add a, a
		ld (tmp_pcg_room__current_target_chunk_bank_id), a  ; we will only consider chunks in this bank in this iteration

		ld b, iyh
		rl b
		ld c, iyl
		rl c
pcg_generate_room__fg_loop_y:
		push bc
		push hl
			ld a, (tmp_pcg_room__current_target_chunk_bank_id)
			ld e, a
pcg_generate_room__fg_loop_x:
			ld a, (hl)
			and #f0
			cp e
			jp nz, pcg_generate_room__fg_loop_x_skip
			ld a, (hl)
			push hl
				push bc
					ld hl, pyramid_chunk_fg_bank_ptrs
					call pcg_get_chunk_ptr
				pop bc
				push bc
					push hl
						; - hl: ptr to chunk
						; - iyl/iyh: room width/height in screens.
						; - c/b: x, y coordinates where to add this chunk in the current room.			
						call pcg_generate_room_copy_chunk_to_room
					pop hl
					; Instantiate pushable-blocks:
					ld bc, CHUNK_WIDTH * CHUNK_HEIGHT
					add hl, bc
				pop bc  ; we recover the x, y coordinates of the chunk
				push bc
					; Coordinates of the top-left of this chunk are: (iyl*2 - c)*16 + location.x, (iyh*2 - b)*12 + location.y
					ld a, iyl
					add a, a
					sub c
					add a, a
					add a, a
					add a, a
					add a, a  ; * 16
					ld (tmp_pcg_room__chunk_x), a
					ld a, iyh
					add a, a
					sub b
					add a, a
					add a, a
					ld c, a
					add a, a
					add a, c  ; * 12
					ld (tmp_pcg_room__chunk_y), a

					; Here hl = ptr to the "locations" marked in the chunk
					; We iterate over all of them looking for instances of "pushable-block":
					; each location is: type, x, y, dx, dy
pcg_generate_room__fg_chunk_object_loop:
					ld a, (hl)
					or a
					jr z, pcg_generate_room__fg_chunk_object_loop_done
					cp CHUNK_LOCATION_PUSHABLE_BLOCK
					jr nz, pcg_generate_room__fg_chunk_object_loop_next
					; it's a pushable block, spawn it:
					push hl
					push de
						ld de, (tmp_pcg_room__next_tile_object_ptr)
						xor a  ; pushable blocks have ID 0
						ld (de), a  ; ID
						inc de
						ld a, TAG_PUSHABLE_BLOCK
						ld (de), a  ; type
						inc de
						inc hl
						ld a, (tmp_pcg_room__chunk_x)
						add a, (hl)  ; x relative to this chunk
						ld (de), a  ; x
						inc de
						inc hl
						ld a, (tmp_pcg_room__chunk_y)
						add a, (hl)  ; y relative to this chunk
						ld (de), a  ; y
						inc de
						xor a
						ld (de), a  ; state
						ex de, hl
							ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE - 4  ; "- 4", since we already did 4 "inc de"
							add hl, bc
						ex de, hl
						ld (tmp_pcg_room__next_tile_object_ptr), de
					pop de
					pop hl
pcg_generate_room__fg_chunk_object_loop_next:
					ld bc, 5
					add hl, bc
					jr pcg_generate_room__fg_chunk_object_loop
pcg_generate_room__fg_chunk_object_loop_done:
				pop bc
			pop hl
			ld a, (tmp_pcg_room__current_target_chunk_bank_id)
			ld e, a			
pcg_generate_room__fg_loop_x_skip:
			inc hl
			dec c
			jr nz, pcg_generate_room__fg_loop_x
		pop hl
		ld a, (current_area__width)
		add a, a  ; next row
		ADD_HL_A
		pop bc
		dec b
		jp nz, pcg_generate_room__fg_loop_y
	pop hl
	pop bc
	dec b
	jp nz, pcg_generate_room__fg_loop_bank_id

	; Auto-fill ladders/ropes/etc. and randomize tiles:
	call pcg_generate_room__prettyfy_pyramid

	; Instantiate 'current_area__objects':
	ld ix, current_area__objects
pcg_generate_room__object_loop:
	ld a, (ix)
	cp #ff
	jp z, pcg_generate_room__object_loop_end
	; see if the object is in this room:
	ld a, (ix + AREA_OBJECT_STRUCT_OFFSET)
	call area_object_offset_to_x_y_in_chunks
	; convert coordinates to in-room coordinates:
	ld de, (current_room__x)  ; e = current_room__x, d = current_room__y
	or a
	rl d  ; in chunks
	rl e  ; in chunks
	ld a, c
	sub e
	jp c, pcg_generate_room__object_loop_next  ; out of bounds left 
	ld c, a  ; c = (object chunk x) - (room chunk x)
	ld a, (current_room__width_in_screens)
	add a, a  ; in chunks
	cp c  ; if a <= c, out of bounds
	jp z, pcg_generate_room__object_loop_next  ; out of bounds right 
	jp c, pcg_generate_room__object_loop_next  ; out of bounds right 
	ld a, b
	sub d
	jp c, pcg_generate_room__object_loop_next  ; out of bounds top 
	ld b, a
	ld a, (current_room__height_in_screens)
	add a, a  ; in chunks
	cp b  ; if a <= b, out of bounds
	jp z, pcg_generate_room__object_loop_next  ; out of bounds bottom 
	jp c, pcg_generate_room__object_loop_next  ; out of bounds bottom 

	; object is in this room:
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	cp TAG_BREAKABLE_WALL1
	jp z, pcg_generate_room__object_breakable_wall
	cp TAG_BREAKABLE_WALL2
	jp z, pcg_generate_room__object_breakable_wall
	cp TAG_BREAKABLE_WALL3
	jp z, pcg_generate_room__object_breakable_wall
	cp TAG_BREAKABLE_WALL4
	jp z, pcg_generate_room__object_breakable_wall
	push ix
		ld ixl, a
		call pcg_generate_area__choose_chunks_is_chest_tag_p
		ld a, ixl
	pop ix
	jp z, pcg_generate_room__object_chest
	push ix
		ld ixl, a
		call pcg_generate_area__choose_chunks_is_item_tag_p
		ld a, ixl
	pop ix
	jp z, pcg_generate_room__object_regular_item
	push ix
		ld ixl, a
		call pcg_generate_area__choose_chunks_is_small_lock_tag_p
		ld a, ixl
	pop ix
	jp z, pcg_generate_room__object_small_lock
	push ix
		ld ixl, a
		call pcg_generate_area__choose_chunks_is_boss_tag_p
		ld a, ixl
	pop ix
	jp z, pcg_generate_room__object_boss_lock

	cp TAG_IDOL_LOCK
	jp z, pcg_generate_room__object_idol_lock
	cp TAG_GEAR_LOCK
	jp z, pcg_generate_room__object_gear_lock

	cp TAG_BUTTON_DOOR1
	jp z, pcg_generate_room__object_button_door
	cp TAG_BUTTON_DOOR2
	jp z, pcg_generate_room__object_button_door
	cp TAG_BUTTON_DOOR3
	jp z, pcg_generate_room__object_button_door
	cp TAG_BUTTON_DOOR4
	jp z, pcg_generate_room__object_button_door

	cp TAG_COMBINATION1_LOCK
	jp z, pcg_generate_room__object_combination_lock
	cp TAG_COMBINATION2_LOCK
	jp z, pcg_generate_room__object_combination_lock
	cp TAG_COMBINATION3_LOCK
	jp z, pcg_generate_room__object_combination_lock
	cp TAG_COMBINATION4_LOCK
	jp z, pcg_generate_room__object_combination_lock

	cp TAG_TRIAL1_LOCK
	jp z, pcg_generate_room__object_trial_lock
	cp TAG_TRIAL2_LOCK
	jp z, pcg_generate_room__object_trial_lock
	cp TAG_TRIAL3_LOCK
	jp z, pcg_generate_room__object_trial_lock
	cp TAG_TRIAL4_LOCK
	jp z, pcg_generate_room__object_trial_lock

	cp TAG_TELEPORTER1
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER2
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER3
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER4
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER5
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER6
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER7
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER8
	jp z, pcg_generate_room__object_teleporter

	; ...

pcg_generate_room__object_loop_next:
	ld bc, AREA_OBJECT_STRUCT_SIZE
	add ix, bc
	jp pcg_generate_room__object_loop
pcg_generate_room__object_loop_end:
	ret


;-----------------------------------------------
; input:
; - ix: ptr to the area object
; - c, b: x, y of where to spawn the object (in chunks)
pcg_generate_room__object_breakable_wall:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		ld a, (ix + AREA_OBJECT_STRUCT_EXTRA)  ; get the direction of the wall
		cp PCG_DIRECTION_LEFT
		jr z, pcg_generate_room__object_breakable_wall_left
		cp PCG_DIRECTION_UP
		jr z, pcg_generate_room__object_breakable_wall_up
		cp PCG_DIRECTION_RIGHT
		jr z, pcg_generate_room__object_breakable_wall_right
pcg_generate_room__object_breakable_wall_down:
		ld e, CHUNK_LOCATION_BREAKABLE_DOWN
		jr pcg_generate_room__object_breakable_wall_mask_set
pcg_generate_room__object_breakable_wall_right:
		ld e, CHUNK_LOCATION_BREAKABLE_RIGHT
		jr pcg_generate_room__object_breakable_wall_mask_set
pcg_generate_room__object_breakable_wall_up:
		ld e, CHUNK_LOCATION_BREAKABLE_UP
		jr pcg_generate_room__object_breakable_wall_mask_set
pcg_generate_room__object_breakable_wall_left:
		ld e, CHUNK_LOCATION_BREAKABLE_LEFT
pcg_generate_room__object_breakable_wall_mask_set:

		; select one chunk location for a breakable wall that matches the direction constraint:
		call sample_chunk_location  ; de: ptr to the location
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	call pcg_generate_room__compute_object_coordinates
	inc de
	ld a, (de)  ; width
	ld l, a
	inc de
	ld a, (de)  ; height
	ld e, l
	ld d, a  ; here: c, b: x, y coordinates, e, d: width, height

	; check if the wall was already destroyed:
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_breakable_wall_continue
	; wall was already destroyed:
	call room_remove_breakable_wall_restore_background
	jp pcg_generate_room__object_loop_next


pcg_generate_room__object_breakable_wall_continue:	
	; spawn the breakable wall object:
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld a, (ix + AREA_OBJECT_STRUCT_ID)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; ID
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), a  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 8  ; state (hitpoints)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_WIDTH), e  ; width
	ld (iy + ROOM_TILE_OBJECT_STRUCT_HEIGHT), d  ; height
	ld (iy + ROOM_TILE_OBJECT_STRUCT_LAST_HIT_ID), #ff  ; can be hit by anything
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	jp pcg_generate_room__object_loop_next


;-----------------------------------------------
; - ix: ptr to the area object
; - c, b: x, y of where to spawn the object (in chunks)
pcg_generate_room__object_chest:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_ITEM
		call sample_chunk_location  ; de: ptr to the location
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	; compute object coordinates:
	call pcg_generate_room__compute_object_coordinates
	; here: c, b: x, y coordinates

	; check if chest was already open:
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_regular_item_continue
	; chest was already open, see if the item was picked up
	ld d, (ix + AREA_OBJECT_STRUCT_TYPE)
	call get_chest_content  ; e = chest content
	ld hl, global_state__objects
	ld d, 0
	add hl, de
	ld a, (hl)
	or a
	jp nz, pcg_generate_room__object_loop_next  ; chest inside object was already picked up
	ld d, e
	jp pcg_generate_room__object_regular_item_continue_de_set


;-----------------------------------------------
; - ix: ptr to the area object
; - c, b: x, y of where to spawn the object (in chunks)
pcg_generate_room__object_regular_item:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_ITEM
		call sample_chunk_location  ; de: ptr to the location
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	; compute object coordinates:
	call pcg_generate_room__compute_object_coordinates
	; here: c, b: x, y coordinates

	; check if the item was already picked up (except buttons):
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	cp TAG_BUTTON1
	jr z, pcg_generate_room__object_regular_item_continue
	cp TAG_BUTTON2
	jr z, pcg_generate_room__object_regular_item_continue
	cp TAG_BUTTON3
	jr z, pcg_generate_room__object_regular_item_continue
	cp TAG_BUTTON4
	jr z, pcg_generate_room__object_regular_item_continue
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_regular_item_continue
	; item was already picked up:
	jp pcg_generate_room__object_loop_next

pcg_generate_room__object_regular_item_continue:	
	; spawn the object:
	ld d, (ix + AREA_OBJECT_STRUCT_ID)
	ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
pcg_generate_room__object_regular_item_continue_de_set:
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
	call set_item_object_to_upload_to_vdp

	jp pcg_generate_room__object_loop_next


;-----------------------------------------------
; - ix: ptr to the area object
; - c, b: x, y of where to spawn the object (in chunks)
pcg_generate_room__object_small_lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	push bc
		push hl
			; compute object coordinates:
			call pcg_generate_room__compute_object_coordinates
			; here: c, b: x, y coordinates

			; spawn the lock:
			ld d, (ix + AREA_OBJECT_STRUCT_ID)
			ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld iy, (tmp_pcg_room__next_tile_object_ptr)
			ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
			ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
			ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
			ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
			ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
			ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
			add iy, bc
			ld (tmp_pcg_room__next_tile_object_ptr), iy

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			call set_item_object_to_upload_to_vdp
		pop hl  ; chunk ptr

pcg_generate_room__object_small_lock_spawn_door:
		ld a, (ix + AREA_OBJECT_STRUCT_EXTRA)  ; a = direction
		ld e, CHUNK_LOCATION_DOOR_LEFT
		cp PCG_DIRECTION_LEFT
		jr z, pcg_generate_room__object_small_lock_direction_set
		ld e, CHUNK_LOCATION_DOOR_UP
		cp PCG_DIRECTION_UP
		jr z, pcg_generate_room__object_small_lock_direction_set
		ld e, CHUNK_LOCATION_DOOR_RIGHT
		cp PCG_DIRECTION_RIGHT
		jr z, pcg_generate_room__object_small_lock_direction_set
		ld e, CHUNK_LOCATION_DOOR_DOWN
pcg_generate_room__object_small_lock_direction_set:
		call sample_chunk_location  ; de: ptr to the location

		ASSERT_D_NOT_EQ 0

	pop bc  ; coordinates in chunks

pcg_generate_room__object_small_lock_spawn_door_no_ladder_replacement:
	; Clear the background behind the door:
	call pcg_generate_room__compute_object_coordinates
	inc de
	ex de, hl
	ld e, (hl)  ; width
	inc hl
	ld d, (hl)  ; height
	push bc
		call room_remove_breakable_wall_restore_background  ; this clears the space
	pop bc

	; check if the lock has already been open
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp nz, pcg_generate_room__maybe_replace_door_by_ladder  ; item was already open, do not spawn door

	; spawn the door:
	ld a, (ix + AREA_OBJECT_STRUCT_EXTRA)  ; a = direction
	ld e, TAG_DOOR_VERTICAL
	cp PCG_DIRECTION_LEFT
	jr z, pcg_generate_room__object_small_lock_direction_set2
	ld e, TAG_DOOR_HORIZONTAL
	cp PCG_DIRECTION_UP
	jr z, pcg_generate_room__object_small_lock_direction_set2
	ld e, TAG_DOOR_VERTICAL
	cp PCG_DIRECTION_RIGHT
	jr z, pcg_generate_room__object_small_lock_direction_set2_right

	; down:
	ld e, TAG_DOOR_HORIZONTAL
	ld a, (current_room__height)
	dec a
	ld b, a  ; put the door at the bottom of the room
pcg_generate_room__object_small_lock_direction_set2:

	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 0  ; doors have ID 0
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	jp pcg_generate_room__object_loop_next

pcg_generate_room__object_small_lock_direction_set2_right:
	ld a, (current_room__width)
	dec a
	ld d, c  ; save the current 'x', in case it's not a "right" door
	ld c, a  ; put the door at the right-edge of the room
	jr pcg_generate_room__object_small_lock_direction_set2


;-----------------------------------------------
pcg_generate_room__maybe_replace_door_by_ladder:
	; c, b: x, y of the door object
	; If it's a door down to an inter-area connection, replace by a ladder:
	ld a, (ix + AREA_OBJECT_STRUCT_EXTRA)  ; a = direction
	cp PCG_DIRECTION_DOWN
	jp nz, pcg_generate_room__object_loop_next
	; is it an inter-area connection? (check if we are at the edge of the map, or there is no chunk below)
	push bc
		ld a, (current_room__y)
		ld c, a
		ld a, (current_room__height_in_screens)
		add a, c
		ld c, a
		ld a, (current_area__height)
		cp c
	pop bc
	jr z, pcg_generate_room__maybe_replace_door_by_ladder_inter_area_connection
	push bc
		; see if there is a chunk below:
		call get_player_chunk_coordinates
		inc b  ; chunk below
		ld e, PCG_PAGE
		ld hl, get_chunk_id_from_coordinates
		call call_hl_in_page_e_8000
		ld a, (hl)
		cp #ff
	pop bc
	jp nz, pcg_generate_room__object_loop_next

pcg_generate_room__maybe_replace_door_by_ladder_inter_area_connection:
	; replace by a ladder:
	ld a, (current_room__height)
	dec a
	ld b, a  ; put the door at the bottom of the room
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
pcg_generate_room__object_idol_lock:
pcg_generate_room__object_gear_lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_BIG_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	push bc
		push hl
			; compute object coordinates:
			call pcg_generate_room__compute_object_coordinates
			; here: c, b: x, y coordinates

			; spawn the lock:
			ld d, (ix + AREA_OBJECT_STRUCT_ID)
			ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld iy, (tmp_pcg_room__next_tile_object_ptr)
			ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
			ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
			ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
			ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
			ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
			ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
			add iy, bc
			ld (tmp_pcg_room__next_tile_object_ptr), iy

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			call set_large_object_to_upload_to_vdp
		pop hl  ; chunk ptr

		jp pcg_generate_room__object_small_lock_spawn_door


;-----------------------------------------------
pcg_generate_room__object_teleporter:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_BIG_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	; compute object coordinates:
	call pcg_generate_room__compute_object_coordinates
	; here: c, b: x, y coordinates

	; spawn the teleporter:
	ld d, (ix + AREA_OBJECT_STRUCT_ID)
	ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
	jp set_large_object_to_upload_to_vdp


;-----------------------------------------------
pcg_generate_room__object_button_door:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		jp pcg_generate_room__object_small_lock_spawn_door


;-----------------------------------------------
pcg_generate_room__object_combination_lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
	pop bc
	push hl
		push bc
			; spawn the levers:
			ld iyl, 1  ; first ID 
			ld bc, CHUNK_WIDTH * CHUNK_HEIGHT
			add hl, bc
pcg_generate_room__object_combination_lock_loop:
			ld a, (hl)
			or a
			jr z, pcg_generate_room__object_combination_lock_loop_end
			cp CHUNK_LOCATION_ITEM
			jr nz, pcg_generate_room__object_combination_lock_loop_next
		pop bc  ; recover the chunk coordinates
		push bc
			push hl
				ex de, hl
				call pcg_generate_room__compute_object_coordinates
				; spawn a lever object:
				ld a, iyl
				push iy
					ld iy, (tmp_pcg_room__next_tile_object_ptr)
					ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; ID
					ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
					ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
					ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
					ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
					ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 1  ; state
					ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
					add iy, bc
					ld (tmp_pcg_room__next_tile_object_ptr), iy
				pop iy
				inc iyl
			pop hl
pcg_generate_room__object_combination_lock_loop_next:
			inc hl
			inc hl
			inc hl
			inc hl
			inc hl
			jr pcg_generate_room__object_combination_lock_loop
pcg_generate_room__object_combination_lock_loop_end:

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			ld e, TAG_COMBINATION1_LOCK
			call set_large_object_to_upload_to_vdp

		pop bc
	pop hl
	push bc
		jp pcg_generate_room__object_small_lock_spawn_door


;-----------------------------------------------
pcg_generate_room__object_trial_lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_4X4_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	push bc
		push hl
			; compute object coordinates:
			call pcg_generate_room__compute_object_coordinates
			; here: c, b: x, y coordinates

			; spawn the lock:
			ld d, (ix + AREA_OBJECT_STRUCT_ID)
			ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld iy, (tmp_pcg_room__next_tile_object_ptr)
			ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
			ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
			ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
			ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
			ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
			ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
			add iy, bc
			ld (tmp_pcg_room__next_tile_object_ptr), iy

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			call set_large_object_to_upload_to_vdp

			; check if the lock has already been open
			ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld hl, global_state__objects
			ADD_HL_A
			ld a, (hl)
			or a
			jp nz, pcg_generate_room__object_trial_lock_continue  ; item was already open, no need to set a trial fn

			ld hl, current_world__trial_types
			ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
			sub TAG_TRIAL1_LOCK
			ADD_HL_A
			ld a, (hl)
			add a, a
			ld hl, trial_fn_ptrs
			ADD_HL_A
			ld a, (hl)
			inc hl
			ld h, (hl)
			ld l, a
			ld (current_room__trial_fn), hl

pcg_generate_room__object_trial_lock_continue:

		pop hl  ; chunk ptr

		jp pcg_generate_room__object_small_lock_spawn_door


;-----------------------------------------------
pcg_generate_room__object_boss_lock:
	; spawn the lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, pyramid_chunk_fg_bank_ptrs
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	push bc
		push hl
			; compute object coordinates:
			call pcg_generate_room__compute_object_coordinates
			; here: c, b: x, y coordinates

			; spawn the lock:
			ld d, (ix + AREA_OBJECT_STRUCT_ID)
			ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld iy, (tmp_pcg_room__next_tile_object_ptr)
			ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
			ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
			ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
			ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
			ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
			ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
			add iy, bc
			ld (tmp_pcg_room__next_tile_object_ptr), iy

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			call set_item_object_to_upload_to_vdp
		pop hl  ; chunk ptr

		; spawn the boss door:
		ld e, CHUNK_LOCATION_4X4_ITEM
		call sample_chunk_location  ; de: ptr to the location
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	cp 2  ; boss killed
	jp z, pcg_generate_room__object_loop_next

	; compute object coordinates:
	call pcg_generate_room__compute_object_coordinates
	; here: c, b: x, y coordinates

	; spawn the lock:
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; ID (boss doors have as ID the type of the corresponding lock)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_DOOR_BOSS  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; set which object gfx to up load vdp:
	ld e, TAG_DOOR_BOSS
	call set_large_object_to_upload_to_vdp

	; check if the lock has already been open
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_loop_next  ; door was already open

	; change door image to open:
	ld hl, buffer_4096 + (48 + 32) * 16  ; boss door frame 2
	ld (large_object_to_upload_to_vdp), hl

	jp pcg_generate_room__object_loop_next


;-----------------------------------------------
; - a = (random % 8) % l
pcg_generate_room__sample_door_position_chunk_sample:
	call random_a
	and #07
pcg_generate_room__sample_door_position_chunk_sample_loop:
	cp l
	ret c
	sub l
	jr pcg_generate_room__sample_door_position_chunk_sample_loop


;-----------------------------------------------
; input:
; - de: ptr to a chunk location
; - c, b: x, y of where to spawn the object (in chunks)
; output:
; - c, b: x, y coordinates
pcg_generate_room__compute_object_coordinates:
	inc de  ; skip type
	; x = c * CHUNK_WIDTH + (de)
	ld a, c
	add a, a
	add a, a
	add a, a
	add a, a  ; assumes CHUNK_WIDTH = 16
	ld c, a
	ld a, (de)  ; x
	add a, c
	ld c, a
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), a  ; x
	inc de
	; y = b * CHUNK_HEIGHT + (de)
	ld a, b
	add a, a
	add a, a
	ld b, a
	add a, a
	add a, b  ; assumes CHUNK_HEIGHT = 12
	ld b, a
	ld a, (de)  ; y
	add a, b
	ld b, a
	ret


;-----------------------------------------------
; input:
; - hl: ptr to chunk
; - e: location type
; output:
; - de: ptr to the selected location
sample_chunk_location:
	ld a, e
	ld bc, CHUNK_WIDTH * CHUNK_HEIGHT
	add hl, bc
	ld b, MAX_CHUNK_LOCATIONS
	ld de, 0
sample_chunk_location_loop:
	cp (hl)
	jr nz, sample_chunk_location_loop_next
	push af
		ld a, d
		or a
		jr z, sample_chunk_location_select
		call random_a
		and #01
		jr z, sample_chunk_location_skip
sample_chunk_location_select:
		ld d, h
		ld e, l
sample_chunk_location_skip:
	pop af
sample_chunk_location_loop_next:
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	djnz sample_chunk_location_loop
	ret


;-----------------------------------------------
; input:
; - c, b: x, y of where to spawn the object (in chunks)
get_chunk_id_from_coordinates:
	ld a, (current_room__x)
	add a, a
	add a, c
	ld c, a
	ld a, (current_room__y)
	add a, a
	add a, b
	ld b, a

	; chunk id = (current_area__chunks_ids + c + b * (current_area__width) * 2)
	ld a, (current_area__width)
	add a, a
	ld e, a
	ld d, 0
	ld hl, 0
	ld a, b
	or a
	jr z, get_chunk_id_from_coordinates_loop_done
get_chunk_id_from_coordinates_loop:
	add hl, de
	djnz get_chunk_id_from_coordinates_loop
get_chunk_id_from_coordinates_loop_done:
	ld b, 0
	add hl, bc
	ld bc, current_area__chunks_ids
	add hl, bc
	ld a, (hl)
	ret


;-----------------------------------------------
; This method:
; - completes ropes, ladders, dragon/face blocks
; - randomizes brick tiles
pcg_generate_room__prettyfy_pyramid:
	; Part 1: reconstruct ropes/ladders/faces/dragon:
	ld hl, current_room__tile_map
	ld bc, (current_room__width)
	ld a, (current_room__width)
	ld e, a
	ld d, 0	
pcg_generate_room__prettyfy_pyramid_loop_y:
	push bc
		ld b, c
		ld c, 15*16 + 6
pcg_generate_room__prettyfy_pyramid_loop_x:
		ld a, (hl)
		sub c
		jr c, pcg_generate_room__prettyfy_pyramid_loop_x_continue
		jr z, pcg_generate_room__prettyfy_pyramid_bricks_randomize
		dec a
		jr z, pcg_generate_room__prettyfy_pyramid_rubble_randomize
		dec a
		jp z, pcg_generate_room__prettyfy_pyramid_ladder
		dec a
		jp z, pcg_generate_room__prettyfy_pyramid_face1
		dec a
		jp z, pcg_generate_room__prettyfy_pyramid_face2
		dec a
		jp z, pcg_generate_room__prettyfy_pyramid_dragon_head
		dec a
		jr z, pcg_generate_room__prettyfy_pyramid_spike_tip_randomize
		dec a
		jr z, pcg_generate_room__prettyfy_pyramid_thin_bricks_randomize
		dec a
		jr z, pcg_generate_room__prettyfy_pyramid_platform_randomize
		jp pcg_generate_room__prettyfy_pyramid_rope
pcg_generate_room__prettyfy_pyramid_loop_x_continue:
		inc hl
		djnz pcg_generate_room__prettyfy_pyramid_loop_x
	pop bc
	djnz pcg_generate_room__prettyfy_pyramid_loop_y
	ret

pcg_generate_room__prettyfy_pyramid_spike_tip_randomize:
	call random_a
	and #01
	jr z, pcg_generate_room__prettyfy_pyramid_spike_tip_randomize_continue
	ld (hl), 8*16 + 13
pcg_generate_room__prettyfy_pyramid_spike_tip_randomize_continue:
	call random_a
	and #01
	add a, 8*16 + 4
	add hl, de
	ld (hl), a
	sbc hl, de
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_platform_randomize:
	call random_a
	and #01
	jp z, pcg_generate_room__prettyfy_pyramid_loop_x_continue
	ld (hl), 8*16 + 9
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_thin_bricks_randomize:
	call random_a
	and #03
	sub 2
	jp c, pcg_generate_room__prettyfy_pyramid_loop_x_continue
	add a, 8*16 + 14
	ld (hl), a
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_rubble_randomize:
	call random_a
	and #03
	jp z, pcg_generate_room__prettyfy_pyramid_loop_x_continue
	add a, 10*16 + 0
	ld (hl), a
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_bricks_randomize:
	call random_a
	cp 96
	jr nc, pcg_generate_room__prettyfy_pyramid_bricks_randomize_continue
	; ld (hl), 9*16 + 5
	add hl, de
	ld (hl), 9*16 + 8
	sbc hl, de
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue
pcg_generate_room__prettyfy_pyramid_bricks_randomize_continue:
	cp 160
	jr nc, pcg_generate_room__prettyfy_pyramid_bricks_randomize_continue2
	ld (hl), 9*16 + 6
	add hl, de
	ld (hl), 9*16 + 8
	sbc hl, de
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue
pcg_generate_room__prettyfy_pyramid_bricks_randomize_continue2:
	ld (hl), 9*16 + 11
	add hl, de
	ld (hl), 9*16 + 7
	sbc hl, de
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue


pcg_generate_room__prettyfy_pyramid_rope:
	push hl
	push bc
		ld bc, current_room__tile_map
pcg_generate_room__prettyfy_pyramid_rope_loop:
		or a
		sbc hl, de  ; go one row up
; 		or a
		sbc hl, bc  ; check if we are out of the map
		jr c, pcg_generate_room__prettyfy_pyramid_rope_done
		add hl, bc
		ld a, (hl)
		cp 9*16 + 7  ; brick
		jr z, pcg_generate_room__prettyfy_pyramid_rope_done
		cp 9*16 + 8  ; brick
		jr z, pcg_generate_room__prettyfy_pyramid_rope_done
		cp 8*16+15  ; thin brick
		jr z, pcg_generate_room__prettyfy_pyramid_rope_done
		cp 8*16+14  ; thin brick
		jr z, pcg_generate_room__prettyfy_pyramid_rope_done
		cp 15*16+13  ; thin brick
		jr z, pcg_generate_room__prettyfy_pyramid_rope_done
		cp 8*16 + 7  ; top rope piece
		jr z, pcg_generate_room__prettyfy_pyramid_rope_done
pcg_generate_room__prettyfy_pyramid_rope_keep_going:
		call random_a
		and #03
		jp nz, pcg_generate_room__prettyfy_pyramid_rope_keep_going2
		ld (hl), 8*16 + 3  ; rope knot
		jr pcg_generate_room__prettyfy_pyramid_rope_loop
pcg_generate_room__prettyfy_pyramid_rope_keep_going2:
		ld (hl), 8*16 + 6  ; rope
		jr pcg_generate_room__prettyfy_pyramid_rope_loop
pcg_generate_room__prettyfy_pyramid_rope_done:
	pop bc
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_ladder:
	push hl
	push bc
		ld bc, current_room__tile_map
pcg_generate_room__prettyfy_pyramid_ladder_loop:
		or a
		sbc hl, de  ; go one row up
		or a
		sbc hl, bc  ; check if we are out of the map
		jr c, pcg_generate_room__prettyfy_pyramid_ladder_done
		add hl, bc
		ld a, (hl)
		or a
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 6*16 + 8  ; ladder top-left
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_done
		cp 6*16 + 9  ; ladder top-right
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_done
		cp 7*16 + 12  ; ladder top-left
		jr c, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 8*16 + 1  ; torch
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 8*16 + 2  ; background
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 9*16 + 5  ; background
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 10*16 + 0  ; background
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 10*16 + 6  ; background
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 11*16 + 12  ; background
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 12*16 + 0  ; background
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 12*16 + 8  ; background
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		cp 15*16 + 5  ; background
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		and #f0
		cp #60  ; row 6 contains tiles only present on background tiles
		jr nz, pcg_generate_room__prettyfy_pyramid_ladder_done
pcg_generate_room__prettyfy_pyramid_ladder_keep_going:
		ld (hl), 15*16 + 8  ; ladder-left
		inc hl
		ld (hl), 10*16 + 7  ; ladder-right
		dec hl
		jr pcg_generate_room__prettyfy_pyramid_ladder_loop
pcg_generate_room__prettyfy_pyramid_ladder_done:
	pop bc
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_face1:
	push hl
		inc hl
		ld (hl), 12*16 + 1
		inc hl
		ld (hl), 12*16 + 2
		add hl, de
		ld (hl), 13*16 + 2
		dec hl
		ld (hl), 13*16 + 1
		dec hl
		ld (hl), 13*16 + 0
		add hl, de
		ld (hl), 14*16 + 0
		inc hl
		ld (hl), 14*16 + 1
		inc hl
		ld (hl), 14*16 + 2
		add hl, de
		ld (hl), 15*16 + 2
		dec hl
		ld (hl), 15*16 + 1
		dec hl
		ld (hl), 15*16 + 0
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_face2:
	push hl
		inc hl
		ld (hl), 12*16 + 9
		inc hl
		ld (hl), 12*16 + 10
		inc hl
		ld (hl), 12*16 + 11
		add hl, de
		ld (hl), 13*16 + 11
		dec hl
		ld (hl), 13*16 + 10
		dec hl
		ld (hl), 13*16 + 9
		dec hl
		ld (hl), 13*16 + 8
		add hl, de
		ld (hl), 14*16 + 8
		inc hl
		ld (hl), 14*16 + 9
		inc hl
		ld (hl), 14*16 + 10
		inc hl
		ld (hl), 14*16 + 11
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_dragon_head:
	push hl
		inc hl
		ld (hl), 11*16 + 13
		inc hl
		ld (hl), 11*16 + 14
		inc hl
		ld (hl), 11*16 + 15
		add hl, de
		ld (hl), 12*16 + 15
		dec hl
		ld (hl), 12*16 + 14
		dec hl
		ld (hl), 12*16 + 13
		dec hl
		ld (hl), 12*16 + 12
		add hl, de
		ld (hl), 13*16 + 12
		inc hl
		ld (hl), 13*16 + 13
		inc hl
		ld (hl), 13*16 + 14
		inc hl
		ld (hl), 13*16 + 15
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue


;-----------------------------------------------
; input:
; - hl: ptr to the fg chunk types
pcg_generate_room_background_pyramid:
	xor a
	ld (tmp_pcg_room__current_target_chunk_bank_id), a	
	ld a, #ff
	ld (tmp_pcg_room__current_decompressed_chunk_bank_id), a	
	ld b, iyh
	sla b  ; width in "chunks"
	ld c, iyl
	sla c  ; height in "chunks"
pcg_generate_room__bg_loop_y:
	push bc
	push hl
pcg_generate_room__bg_loop_x:
		call pcg_generate_room_get_fg_chunk_flags
		and CHUNK_FLAG_BOSS_MASK
		jr nz, pcg_generate_room__bg_loop_empty_chunk
		; pick a background chunk:
		call random_a
		and #03
		jr nz, pcg_generate_room__bg_loop_empty_chunk
		; 0.25 chance of having a non-emtpy chunk:
		call random_a
		and #01

		push bc
			ld hl, pyramid_chunk_bg_bank_ptrs
			call pcg_get_chunk_ptr  ; hl = ptr of the chunk to copy
		pop bc
		push bc
			call pcg_generate_room_copy_chunk_to_room_overwrite
		pop bc
pcg_generate_room__bg_loop_empty_chunk:
		inc hl
		dec c
		jr nz, pcg_generate_room__bg_loop_x
	pop hl
	pop bc
	ld a, (current_area__width)
	add a, a
	ld d, 0
	ld e, a
	add hl, de
	djnz pcg_generate_room__bg_loop_y
	ret


;-----------------------------------------------
; input: 
; - hl: ptr to fg chunk type
; output:
; - a: flags
pcg_generate_room_get_fg_chunk_flags:
	push hl
	push bc
		ld a, (hl)
		ld hl, pyramid_chunk_flags
		ld c, a
		ld b, 0
		add hl, bc  ; each chunk has 5 bytes
		add hl, bc
		add hl, bc
		add hl, bc
		add hl, bc
		inc hl
		ld a, (hl)
	pop bc
	pop hl
	ret


;-----------------------------------------------
pcg_generate_room_copy_chunk_to_room_set_ptrs:
	; - Coordinates will be: (iyl*2 - c), (iyh*2 - b)
	; - Address to start the copy is thus:
	;     current_room__tile_map + (iyh*2 - b) * iyl * 32 * 12 + (iyl*2 - c) * 16
	push hl
		ld a, iyh
		add a, a
		sub b
		ld e, a
		ld d, 0
		ld l, e
		ld h, d  ; hl, de = (iyh*2 - b)
		ld a, iyl
pcg_generate_room_copy_chunk_to_room_loop1:
		dec a
		jr z, pcg_generate_room_copy_chunk_to_room_continue
		add hl, de
		jp pcg_generate_room_copy_chunk_to_room_loop1
pcg_generate_room_copy_chunk_to_room_continue:
		; hl = ((iyh*2 - b) * iyl

		ld d, l
		ld e, 0
		ld h, l
		ld l, e
		srl d
		rr e
		add hl, de  ; hl *= 32 * 12

		ld a, iyl
		add a, a
		sub c
		add a, a
		add a, a
		add a, a
		add a, a
		ld e, a
		ld d, 0
		add hl, de  ; hl = (iyh*2 - b) * iyl * 32 + (iyl*2 - c) * 16

		ld de, current_room__tile_map
		add hl, de
		ex de, hl  ; de = current_room__tile_map + (iyh*2 - b) * iyl * 32 + (iyl*2 - c) * 16
	pop hl
	ret


;-----------------------------------------------
; This method only copies those tiles that are != 0.
; input:
; - hl: ptr to chunk
; - iyl/iyh: room width/height in screens.
; - c/b: x, y coordinates where to add this chunk in the current room.
pcg_generate_room_copy_chunk_to_room:
	call pcg_generate_room_copy_chunk_to_room_set_ptrs
	ld b, CHUNK_HEIGHT
	ld c, CHUNK_WIDTH
pcg_generate_room_copy_chunk_to_room_loop_y:
	push bc
		xor a
		ld b, a
pcg_generate_room_copy_chunk_to_room_loop_x:
		cp (hl)
		jp z, pcg_generate_room_copy_chunk_to_room_loop_x_skip
		ldi
		jp pe, pcg_generate_room_copy_chunk_to_room_loop_x
		jp pcg_generate_room_copy_chunk_to_room_loop_x_continue
pcg_generate_room_copy_chunk_to_room_loop_x_skip:
		inc hl
		inc de
		dec c
		jp nz, pcg_generate_room_copy_chunk_to_room_loop_x
pcg_generate_room_copy_chunk_to_room_loop_x_continue:
		ld a, (current_room__width)
		sub CHUNK_WIDTH
		ld c, a  ; b is already 0 here
		ex de, hl
			add hl, bc
		ex de, hl
	pop bc
	djnz pcg_generate_room_copy_chunk_to_room_loop_y
	ret


;-----------------------------------------------
; This method only copies all tiles (unlike the above)
; input:
; - hl: ptr to chunk
; - iyl/iyh: room width/height in screens.
; - c/b: x, y coordinates where to add this chunk in the current room.
pcg_generate_room_copy_chunk_to_room_overwrite:
	call pcg_generate_room_copy_chunk_to_room_set_ptrs
	ld b, CHUNK_HEIGHT
pcg_generate_room_copy_chunk_to_room_overwrite_loop_y:
	push bc
REPT CHUNK_WIDTH
		ldi
ENDR
		ld a, (current_room__width)
		sub CHUNK_WIDTH
		ld b, 0
		ld c, a
		ex de, hl
			add hl, bc
		ex de, hl
	pop bc
	djnz pcg_generate_room_copy_chunk_to_room_overwrite_loop_y
	ret


;-----------------------------------------------
; input:
; - a: chunk number
; - hl: pointer to bank pointers
; output:
; - hl: ptr to chunk
pcg_get_chunk_ptr:
	push af
		; 8 chunks per bank:
		rrca
		rrca
		rrca
		and #1e
		ld de, (tmp_pcg_room__current_decompressed_chunk_bank_id)  ; e = tmp_pcg_room__current_decompressed_chunk_bank_id
		cp e
		jr z, pcg_get_chunk_ptr_already_loaded
		ld (tmp_pcg_room__current_decompressed_chunk_bank_id), a  ; store the current chunk bank (*2)
		ADD_HL_A
		ld e, (hl)
		inc hl
		ld h, (hl)
		ld l, e
		ld c, CHUNKS_PYRAMID_PAGE
		ld de, buffer_4096
		call dzx0_from_page_c
pcg_get_chunk_ptr_already_loaded:
	pop af
	; hl = buffer_4096 + a * CHUNK_SIZE
	ld hl, buffer_4096
	and #0f
	ret z
	ld b, a
	ld de, CHUNK_SIZE
pcg_get_chunk_ptr_loop:
	add hl, de
	djnz pcg_get_chunk_ptr_loop
	ret


;-----------------------------------------------
; input:
; - a: offset (x+y*width)
; output:
; - c, b: x, y in chunk coordinates
area_object_offset_to_x_y_in_chunks:
	push af
		ld a, (current_area__width)
		add a, a
		ld e, a  ; width in chunks
	pop af
	ld b, 0
area_object_offset_to_x_y_in_chunks_loop:
	cp e
	jr c, area_object_offset_to_x_y_in_chunks_loop_done
	sub e
	inc b
	jp area_object_offset_to_x_y_in_chunks_loop
area_object_offset_to_x_y_in_chunks_loop_done:
	ld c, a
	ret


;-----------------------------------------------
; input:
; - d: chest object ID
; output:
; - z: not found
; - nz: found
; - e: object ID
get_chest_content:
	ld hl, current_world__chest_content
get_chest_content_loop:
	ld a, (hl)
	cp #ff
	ret z
	cp d
	jr z, get_chest_content_found
	inc hl
	inc hl
	jr get_chest_content_loop

get_chest_content_found:
	inc hl
	ld e, (hl)
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - e: item ID
set_item_object_to_upload_to_vdp:
	; check for open locks:
	ld a, e
	cp TAG_BALL_LOCK
	jr z, set_item_object_to_upload_to_vdp_ball_lock
	cp TAG_ASTRONAUT_LOCK
	jr z, set_item_object_to_upload_to_vdp_astronaut_lock
	cp TAG_BUTTON1
	jr z, set_item_object_to_upload_to_vdp_button
	cp TAG_BUTTON2
	jr z, set_item_object_to_upload_to_vdp_button
	cp TAG_BUTTON3
	jr z, set_item_object_to_upload_to_vdp_button
	cp TAG_BUTTON4
	jr z, set_item_object_to_upload_to_vdp_button
	ld hl, object_tiles_start_ptrs
	ld d, 0
	add hl, de
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
set_item_object_to_upload_to_vdp_continue:
	ld (item_object_to_upload_to_vdp), hl
	ret

set_item_object_to_upload_to_vdp_ball_lock:
	ld hl, buffer_4096 + 54 * 64  ; ball lock (locked)
	ld a, (global_state__objects + TAG_BALL_LOCK)
	or a
	jr z, set_item_object_to_upload_to_vdp_continue
	ld hl, buffer_4096 + 55 * 64  ; ball lock (unlocked)
	jr set_item_object_to_upload_to_vdp_continue

set_item_object_to_upload_to_vdp_astronaut_lock:
	ld hl, buffer_4096 + 56 * 64  ; astronaut lock (locked)
	ld a, (global_state__objects + TAG_ASTRONAUT_LOCK)
	or a
	jr z, set_item_object_to_upload_to_vdp_continue
	ld hl, buffer_4096 + 57 * 64  ; astronaut lock (unlocked)
	jr set_item_object_to_upload_to_vdp_continue

set_item_object_to_upload_to_vdp_button:
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	ld hl, buffer_4096 + 58 * 64  ; button (not pressed)
	jr z, set_item_object_to_upload_to_vdp_continue
	ld hl, buffer_4096 + 59 * 64  ; button (pressed)
	jr set_item_object_to_upload_to_vdp_continue


;-----------------------------------------------
; input:
; - e: item ID
set_large_object_to_upload_to_vdp:
	ld a, e
	cp TAG_COMBINATION1_LOCK
	jr z, set_large_object_to_upload_to_vdp_combination_lock
	cp TAG_IDOL_LOCK
	jr z, set_large_object_to_upload_to_vdp_idol_lock
	cp TAG_GEAR_LOCK
	jr z, set_large_object_to_upload_to_vdp_gear_lock
	cp TAG_TRIAL1_LOCK
	jr z, set_large_object_to_upload_to_vdp_trial1_lock
	cp TAG_TRIAL2_LOCK
	jr z, set_large_object_to_upload_to_vdp_trial2_lock
	cp TAG_TRIAL3_LOCK
	jr z, set_large_object_to_upload_to_vdp_trial3_lock
	cp TAG_TRIAL4_LOCK
	jr z, set_large_object_to_upload_to_vdp_trial4_lock
	cp TAG_DOOR_BOSS
	jr z, set_large_object_to_upload_to_vdp_boss_door
	; teleporters:
	ld a, (global_state__story)
	cp STORY_STATE__PLACED_FIRST_POWER_STONE
	jr c, set_large_object_to_upload_to_vdp__teleporter_off
	ld e, 12*8
	ld hl, buffer_4096 + 178 * 16  ; teleporter on
	jr set_large_object_to_upload_to_vdp_ptr_set	
set_large_object_to_upload_to_vdp__teleporter_off:
	ld e, 12*8
	ld hl, buffer_4096 + 166 * 16  ; teleporter off
	jr set_large_object_to_upload_to_vdp_ptr_set	
set_large_object_to_upload_to_vdp_boss_door:
	ld e, 16*8
	ld hl, buffer_4096 + 48 * 16  ; boss door
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_trial1_lock:
	ld e, 16*8
	ld hl, buffer_4096 + 102 * 16  ; god 1 image
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_trial2_lock:
	ld e, 16*8
	ld hl, buffer_4096 + 118 * 16  ; god 2 image
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_trial3_lock:
	ld e, 16*8
	ld hl, buffer_4096 + 134 * 16  ; god 3 image
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_trial4_lock:
	ld e, 16*8
	ld hl, buffer_4096 + 150 * 16  ; god 4 image
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_combination_lock:
	ld e, 6*8
	ld hl, buffer_4096 + 96 * 16  ; lever
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_idol_lock:
	ld hl, buffer_4096 + 0 * 16
	ld e, 12*8
	ld a, (global_state__objects + TAG_IDOL_LOCK)
	or a
	jr z, set_large_object_to_upload_to_vdp_ptr_set
	ld hl, buffer_4096 + 12 * 16
	jr set_large_object_to_upload_to_vdp_ptr_set

set_large_object_to_upload_to_vdp_gear_lock:
	ld hl, buffer_4096 + 24 * 16
	ld e, 12*8
	ld a, (global_state__objects + TAG_GEAR_LOCK)
	or a
	jr z, set_large_object_to_upload_to_vdp_ptr_set
	ld hl, buffer_4096 + 36 * 16
set_large_object_to_upload_to_vdp_ptr_set:
	ld (large_object_to_upload_to_vdp), hl
	ld a, e
	ld (large_object_to_upload_to_vdp_size), a
	ret


;-----------------------------------------------
object_tiles_start_ptrs:
REPT TAG_RED_LOCK
	dw buffer_4096
ENDR
	dw buffer_4096 + 48 * 64  ; TAG_RED_LOCK
	dw buffer_4096 + 49 * 64  ; TAG_GREEN_LOCK
	dw buffer_4096 + 50 * 64  ; TAG_BLUE_LOCK
	dw buffer_4096 + 51 * 64  ; TAG_YELLOW_LOCK
	dw buffer_4096 + 52 * 64  ; TAG_WHITE_LOCK
	dw buffer_4096 + 53 * 64  ; TAG_PURPLE_LOCK
REPT TAG_BALL_LOCK - TAG_TRIAL1_LOCK
	dw buffer_4096
ENDR
	dw buffer_4096 + 54 * 64  ; TAG_BALL_LOCK: equ 27
	dw buffer_4096  ; TAG_IDOL_LOCK: equ 28
	dw buffer_4096  ; TAG_GEAR_LOCK: equ 29
	dw buffer_4096 + 56 * 64  ; TAG_ASTRONAUT_LOCK: equ 30
REPT TAG_BUTTON1 - TAG_START
	dw buffer_4096
ENDR
; TAG_START: equ 31
; TAG_ENDING: equ 32
; TAG_MIDPOINT: equ 33
; TAG_TELEPORTER_ATLANTIS: equ 34
; TAG_TELEPORTER_MARS: equ 35
; TAG_TELEPORTER_MOON: equ 36
	dw buffer_4096 + 58 * 64  ; TAG_BUTTON1
	dw buffer_4096 + 58 * 64  ; TAG_BUTTON2
	dw buffer_4096 + 58 * 64  ; TAG_BUTTON3
	dw buffer_4096 + 58 * 64  ; TAG_BUTTON4
	dw buffer_4096 + 8 * 64  ; TAG_RED_KEY
	dw buffer_4096 + 9 * 64  ; TAG_GREEN_KEY
	dw buffer_4096 + 10 * 64  ; TAG_BLUE_KEY
	dw buffer_4096 + 11 * 64  ; TAG_YELLOW_KEY
	dw buffer_4096 + 12 * 64  ; TAG_WHITE_KEY
	dw buffer_4096 + 13 * 64  ; TAG_PURPLE_KEY
	dw buffer_4096 + 41 * 64  ; TAG_RED_CHEST
	dw buffer_4096 + 42 * 64  ; TAG_GREEN_CHEST
	dw buffer_4096 + 43 * 64  ; TAG_BLUE_CHEST
	dw buffer_4096 + 44 * 64  ; TAG_YELLOW_CHEST
	dw buffer_4096 + 45 * 64  ; TAG_WHITE_CHEST
	dw buffer_4096 + 46 * 64  ; TAG_PURPLE_CHEST
	dw buffer_4096 + 60 * 64  ; TAG_TRIAL1_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_TRIAL2_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_TRIAL3_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_TRIAL4_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_COMBINATION1_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_COMBINATION2_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_COMBINATION3_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_COMBINATION4_CLUE
	dw buffer_4096 + 14 * 64  ; TAG_BALL_KEY
	dw buffer_4096 + 15 * 64  ; TAG_IDOL_KEY
	dw buffer_4096 + 16 * 64  ; TAG_GEAR_KEY
	dw buffer_4096 + 17 * 64  ; TAG_ASTRONAUT_KEY
	dw buffer_4096  ; TAG_BOSS1
	dw buffer_4096 + 0 * 64  ; TAG_BOSS1_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS1_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS2
	dw buffer_4096 + 1 * 64  ; TAG_BOSS2_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS2_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS3
	dw buffer_4096 + 2 * 64  ; TAG_BOSS3_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS3_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS4
	dw buffer_4096 + 3 * 64  ; TAG_BOSS4_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS4_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS5
	dw buffer_4096 + 4 * 64  ; TAG_BOSS5_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS5_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS6
	dw buffer_4096 + 5 * 64  ; TAG_BOSS6_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS6_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS7
	dw buffer_4096 + 6 * 64  ; TAG_BOSS7_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS7_CHESTLOCK
	dw buffer_4096 + 27 * 64  ; TAG_WEAPON_HAMMER
	dw buffer_4096 + 28 * 64  ; TAG_WEAPON_MACUAHUITL
	dw buffer_4096 + 29 * 64  ; TAG_WEAPON_SHIELD
	dw buffer_4096 + 30 * 64  ; TAG_WEAPON_SLING
	dw buffer_4096 + 31 * 64  ; TAG_WEAPON_BLOWGUN
	dw buffer_4096 + 32 * 64  ; TAG_WEAPON_ATLATL
	dw buffer_4096 + 33 * 64  ; TAG_WEAPON_RAYGUN
	dw buffer_4096 + 34 * 64  ; TAG_WEAPON_OBSIDIAN_KNIVE
	dw buffer_4096 + 35 * 64  ; TAG_WEAPON_FIRE_HAMMER
	dw buffer_4096 + 36 * 64  ; TAG_WEAPON_ICE_MACUAHUITL
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE1
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE2
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE3
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE4
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE5
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE6
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE7
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE8
	dw buffer_4096 + 39 * 64  ; TAG_HEART1
	dw buffer_4096 + 39 * 64  ; TAG_HEART2
	dw buffer_4096 + 39 * 64  ; TAG_HEART3
	dw buffer_4096 + 39 * 64  ; TAG_HEART4
	dw buffer_4096 + 39 * 64  ; TAG_HEART5
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE1
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE2
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE3
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE4
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA1
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA2
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA3
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA4
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA5
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA6
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA7
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA8
	dw buffer_4096 + 18 * 64  ; TAG_ITEM_SANDALS
	dw buffer_4096 + 19 * 64  ; TAG_ITEM_GLOVES
	dw buffer_4096 + 20 * 64  ; TAG_ITEM_HURAKAN
	dw buffer_4096 + 21 * 64  ; TAG_ITEM_ARMOR
	dw buffer_4096 + 22 * 64  ; TAG_ITEM_CHAAC
	dw buffer_4096 + 23 * 64  ; TAG_ITEM_SEASHELL
	dw buffer_4096 + 24 * 64  ; TAG_ITEM_BELT
	dw buffer_4096 + 25 * 64  ; TAG_ITEM_ICE_CAPE
	dw buffer_4096 + 37 * 64  ; TAG_SMALL_KEY1
	dw buffer_4096 + 37 * 64  ; TAG_SMALL_KEY2
	dw buffer_4096 + 37 * 64  ; TAG_SMALL_KEY3
	dw buffer_4096 + 37 * 64  ; TAG_SMALL_KEY4
	dw buffer_4096 + 40 * 64  ; TAG_SMALL_KEY_CHEST1
	dw buffer_4096 + 40 * 64  ; TAG_SMALL_KEY_CHEST2
	dw buffer_4096 + 40 * 64  ; TAG_SMALL_KEY_CHEST3
	dw buffer_4096 + 40 * 64  ; TAG_SMALL_KEY_CHEST4
; REPT TAG_PUSHABLE_BLOCK - TAG_TELEPORTER1
; 	dw buffer_4096
; ENDR
; ; tags below can appear multiple times (and do not have state, they are reset every time you enter in a room):
; TAG_PUSHABLE_BLOCK: equ 137
; TAG_DOOR_VERTICAL: equ 138
; TAG_DOOR_HORIZONTAL: equ 139
; TAG_DOOR_BOSS: equ 140
; TAG_POWER_STONE: equ 141
; TAG_CALENDAR_TABLET: equ 142
; TAG_CALENDAR_SOCKET: equ 143
; TAG_HALF_POWER_STONE: equ 144


;-----------------------------------------------
pcg_generate_room__calendar:
	; name table:
	ld hl, calendar_room_zx0
	ld de, current_room__tile_map
	ld c, CHUNKS_PYRAMID_PAGE
	call dzx0_from_page_c

	; tile sets, collisions, and animation ptrs:
	ld bc, tiles_calendar_zx0
	ld (current_room__tileset_ptr), bc
	ld bc, tile_collision_types_calendar - 32
	ld (current_room__collision_ptr), bc
	ld a, TILES_PAGE
	ld (current_room__tileset_page), a
	ld a, 1
	ld (current_room__tileset_overrides_item_tiles), a

	; open the appropriate walls:
	ld a, (current_room__y)
	add a, a  ; y in chunks
	ld b, a
	ld a, (current_area__width)
	add a, a  ; width in chunks
	ld c, a
	ld a, b
	or a
	ld a, 0
	jr z, pcg_generate_room__calendar_ptr_loop_end
pcg_generate_room__calendar_ptr_loop:
	add a, c
	djnz pcg_generate_room__calendar_ptr_loop
pcg_generate_room__calendar_ptr_loop_end:
	ld c, a
	ld a, (current_room__x)
	add a, a
	add a, c
	ld hl, current_area__chunks_ids
	ADD_HL_A
	ld a, (hl)  ; top-left chunk ID
	push hl
		ld b, PCG_DIRECTION_LEFT
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue1
		ld bc, #0600
		ld de, #0402
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue1:
	pop hl
	inc hl
	ld a, (hl)  ; top-right chunk ID
	push hl
		ld b, PCG_DIRECTION_RIGHT
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue2
		ld bc, #061e
		ld de, #0402
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue2:
	pop hl
	ld a, (current_area__width)
	add a, a  ; width in chunks
	dec a
	ld e, a
	ld d, 0
	add hl, de
	ld a, (hl)  ; bottom-left chunk ID
	push hl
		ld b, PCG_DIRECTION_LEFT
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue3
		ld bc, #0e00
		ld de, #0402
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue3:
	pop hl
	ld a, (hl)  ; bottom-left chunk ID
	push hl
		ld b, PCG_DIRECTION_DOWN
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue4
		ld bc, #1604
		ld de, #0208
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue4:
	pop hl
	inc hl
	ld a, (hl)  ; bottom-right chunk ID
	push hl
		ld b, PCG_DIRECTION_DOWN
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue5
		ld bc, #1614
		ld de, #0208
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue5:
	pop hl
	ld a, (hl)  ; bottom-right chunk ID
	ld b, PCG_DIRECTION_RIGHT
	call pcg_generate_room__chunk_direction_open
	jr z, pcg_generate_room__calendar_continue6
	ld bc, #0e1e
	ld de, #0402
	call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue6:

	; spawn the tablets:
	ld hl, pcg_generate_room__calendar_objects
	ld b, 8
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld de, global_state__power_calendar - 2  ; -2, since we only have the state for the sockets (state of tablets does not matter)
pcg_generate_room__calendar_object_loop:
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; id
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), a  ; type
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), a  ; x
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), a  ; y
	ld a, (de)
	inc de
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), a  ; state
	push de
		ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
		add iy, de
	pop de
	djnz pcg_generate_room__calendar_object_loop
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; tablet gfx:
	ld hl, buffer_4096 + 60 * 64
	ld (item_object_to_upload_to_vdp), hl
	ret

pcg_generate_room__calendar_objects:
	db 0, TAG_CALENDAR_TABLET, 7, 15
	db 0, TAG_CALENDAR_TABLET, 23, 15
	db 0, TAG_CALENDAR_SOCKET, 14, 15  ; has a spent stone
	db 1, TAG_CALENDAR_SOCKET, 16, 15
	db 2, TAG_CALENDAR_SOCKET, 13, 12
	db 3, TAG_CALENDAR_SOCKET, 17, 12
	db 4, TAG_CALENDAR_SOCKET, 14, 9
	db 5, TAG_CALENDAR_SOCKET, 16, 9


;-----------------------------------------------
pcg_generate_room__calendar_turn_on_phase1:
	ld hl, CLRTBL2 + 72*8
	ld a, #48  ; blue + red
	ld b, 8
	call fast_FILVRM_small
	ld hl, CLRTBL2 + (256 + 72)*8
	ld a, #48  ; blue + red
	ld b, 8
	jp fast_FILVRM_small


;-----------------------------------------------
; input:
; - a: chunk ID
; - b: direction to check
; output:
; - z: closed
; - nz: open
pcg_generate_room__chunk_direction_open:
	ld h, 0
	ld l, a
	add hl, hl
	add hl, hl
	ld d, 0
	ld e, a
	add hl, de
	ld de, pyramid_chunk_flags
	add hl, de
	ld a, (hl)  ; top-left chunk type
	and b
	ret
