; Temporary variables (overlapping with the buffer):
tmp_pcg_room__current_target_chunk_bank_id: equ buffer_4096 + 4094
tmp_pcg_room__current_decompressed_chunk_bank_id: equ tmp_pcg_room__current_target_chunk_bank_id - 1
tmp_pcg_room__next_object_ptr: equ tmp_pcg_room__current_decompressed_chunk_bank_id - 2
tmp_pcg_room__next_tile_object_ptr: equ tmp_pcg_room__next_object_ptr - 2
tmp_pcg_room__chunk_x: equ tmp_pcg_room__next_tile_object_ptr - 1
tmp_pcg_room__chunk_y: equ tmp_pcg_room__chunk_x - 1

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

	push de
		ld hl, current_room__objects
		ld (tmp_pcg_room__next_object_ptr), hl
		ld bc, MAX_ROOM_OBJECTS * ROOM_OBJECT_STRUCT_SIZE - 1
		xor a
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
		call clear_memory_a
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
	jr z, pcg_generate_room__object_loop_end
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
	jr c, pcg_generate_room__object_loop_next  ; out of bounds left 
	ld c, a  ; c = (object chunk x) - (room chunk x)
	ld a, (current_room__width_in_screens)
	add a, a  ; in chunks
	cp c  ; if a <= c, out of bounds
	jr z, pcg_generate_room__object_loop_next  ; out of bounds right 
	jr c, pcg_generate_room__object_loop_next  ; out of bounds right 
	ld a, b
	sub d
	jr c, pcg_generate_room__object_loop_next  ; out of bounds top 
	ld b, a
	ld a, (current_room__height_in_screens)
	add a, a  ; in chunks
	cp b  ; if a <= b, out of bounds
	jr z, pcg_generate_room__object_loop_next  ; out of bounds bottom 
	jr c, pcg_generate_room__object_loop_next  ; out of bounds bottom 

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
	cp TAG_BOSS1_KEY
	jp z, pcg_generate_room__object_regular_item

	; ...

pcg_generate_room__object_loop_next:
	ld bc, AREA_OBJECT_STRUCT_SIZE
	add ix, bc
	jr pcg_generate_room__object_loop
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
		cp PCG_DIRECTION_LEFT
		jr z, pcg_generate_room__object_breakable_wall_up
		cp PCG_DIRECTION_LEFT
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

	; compute object coordinates:
	inc de
	; x = c * CHUNK_WIDTH + (de)
	ld a, c
	add a, a
	add a, a
	add a, a
	add a, a  ; assumes CHUNK_WIDTH = 16
	ld c, a
	ld a, (de)
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
	ld a, (de)
	add a, b
	ld b, a
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
	inc de
	; x = c * CHUNK_WIDTH + (de)
	ld a, c
	add a, a
	add a, a
	add a, a
	add a, a  ; assumes CHUNK_WIDTH = 16
	ld c, a
	ld a, (de)
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
	ld a, (de)
	add a, b
	ld b, a  ; here: c, b: x, y coordinates

	; check if the item was already picked up:
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_regular_item_continue
	; item was already picked up:
	jp pcg_generate_room__object_loop_next

pcg_generate_room__object_regular_item_continue:	
	; spawn the breakable wall object:
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld a, (ix + AREA_OBJECT_STRUCT_ID)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; ID
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), a  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
	ld hl, object_tiles_start_ptrs
	ld b, 0
	ld c, a
	add hl, bc
	add hl, bc
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld (item_object_to_upload_to_vdp), hl

	jp pcg_generate_room__object_loop_next


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
object_tiles_start_ptrs:
REPT TAG_BOSS1_KEY
	dw buffer_4096 + 0 * 64
ENDR
	dw buffer_4096 + 0 * 64  ; TAG_BOSS1_KEY
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
; TAG_RED_LOCK: equ 13
; TAG_GREEN_LOCK: equ 14
; TAG_BLUE_LOCK: equ 15
; TAG_YELLOW_LOCK: equ 16
; TAG_WHITE_LOCK: equ 17
; TAG_PURPLE_LOCK: equ 18
; TAG_TRIAL1_LOCK: equ 19
; TAG_TRIAL2_LOCK: equ 20
; TAG_TRIAL3_LOCK: equ 21
; TAG_TRIAL4_LOCK: equ 22
; TAG_COMBINATION1_LOCK: equ 23
; TAG_COMBINATION2_LOCK: equ 24
; TAG_COMBINATION3_LOCK: equ 25
; TAG_COMBINATION4_LOCK: equ 26
; TAG_BALL_LOCK: equ 27
; TAG_IDOL_LOCK: equ 28
; TAG_GEAR_LOCK: equ 29
; TAG_ASTRONAUT_LOCK: equ 30
; TAG_START: equ 31
; TAG_ENDING: equ 32
; TAG_MIDPOINT: equ 33
; TAG_TELEPORTER_ATLANTIS: equ 34
; TAG_TELEPORTER_MARS: equ 35
; TAG_TELEPORTER_MOON: equ 36
; TAG_BUTTON1: equ 37
; TAG_BUTTON2: equ 38
; TAG_BUTTON3: equ 39
; TAG_BUTTON4: equ 40
; TAG_BREAKABLE_WALL1_KEY: equ 41
; TAG_BREAKABLE_WALL2_KEY: equ 42
; TAG_BREAKABLE_WALL3_KEY: equ 43
; TAG_BREAKABLE_WALL4_KEY: equ 44
; TAG_BLOCK_PUZZLE_KEY1: equ 45
; TAG_BLOCK_PUZZLE_KEY2: equ 46
; TAG_BLOCK_PUZZLE_KEY3: equ 47
; TAG_BLOCK_PUZZLE_KEY4: equ 48
; TAG_RED_KEY: equ 49
; TAG_GREEN_KEY: equ 50
; TAG_BLUE_KEY: equ 51
; TAG_YELLOW_KEY: equ 52
; TAG_WHITE_KEY: equ 53
; TAG_PURPLE_KEY: equ 54
; TAG_RED_CHEST: equ 55
; TAG_GREEN_CHEST: equ 56
; TAG_BLUE_CHEST: equ 57
; TAG_YELLOW_CHEST: equ 58
; TAG_WHITE_CHEST: equ 59
; TAG_PURPLE_CHEST: equ 60
; TAG_TRIAL1_CLUE: equ 61
; TAG_TRIAL2_CLUE: equ 62
; TAG_TRIAL3_CLUE: equ 63
; TAG_TRIAL4_CLUE: equ 64
; TAG_COMBINATION1_CLUE: equ 65
; TAG_COMBINATION2_CLUE: equ 66
; TAG_COMBINATION3_CLUE: equ 67
; TAG_COMBINATION4_CLUE: equ 68
; TAG_BALL_KEY: equ 69
; TAG_IDOL_KEY: equ 70
; TAG_GEAR_KEY: equ 71
; TAG_ASTRONAUT_KEY: equ 72
; TAG_BOSS1: equ 73
; TAG_BOSS1_KEY: equ 74
; TAG_BOSS1_CHESTLOCK: equ 75
; TAG_BOSS2: equ 76
; TAG_BOSS2_KEY: equ 77
; TAG_BOSS2_CHESTLOCK: equ 78
; TAG_BOSS3: equ 79
; TAG_BOSS3_KEY: equ 80
; TAG_BOSS3_CHESTLOCK: equ 81
; TAG_BOSS4: equ 82
; TAG_BOSS4_KEY: equ 83
; TAG_BOSS4_CHESTLOCK: equ 84
; TAG_BOSS5: equ 85
; TAG_BOSS5_KEY: equ 86
; TAG_BOSS5_CHESTLOCK: equ 87
; TAG_BOSS6: equ 88
; TAG_BOSS6_KEY: equ 89
; TAG_BOSS6_CHESTLOCK: equ 90
; TAG_BOSS7: equ 91
; TAG_BOSS7_KEY: equ 92
; TAG_BOSS7_CHESTLOCK: equ 93
; TAG_WEAPON_HAMMER: equ 94
; TAG_WEAPON_MACUAHUITL: equ 95
; TAG_WEAPON_SHIELD: equ 96
; TAG_WEAPON_SLING: equ 97
; TAG_WEAPON_BLOWGUN: equ 98
; TAG_WEAPON_ATLATL: equ 99
; TAG_WEAPON_RAYGUN: equ 100
; TAG_WEAPON_OBSIDIAN_KNIVE: equ 101
; TAG_WEAPON_FIRE_HAMMER: equ 102
; TAG_WEAPON_ICE_MACUAHUITL: equ 103
; TAG_MAP_PIECE1: equ 104
; TAG_MAP_PIECE2: equ 105
; TAG_MAP_PIECE3: equ 106
; TAG_MAP_PIECE4: equ 107
; TAG_MAP_PIECE5: equ 108
; TAG_MAP_PIECE6: equ 109
; TAG_MAP_PIECE7: equ 110
; TAG_MAP_PIECE8: equ 111
; TAG_HEART1: equ 112
; TAG_HEART2: equ 113
; TAG_HEART3: equ 114
; TAG_HEART4: equ 115
; TAG_HEART5: equ 116
; TAG_MAYA_RIDDLE_CLUE1: equ 117
; TAG_MAYA_RIDDLE_CLUE2: equ 118
; TAG_MAYA_RIDDLE_CLUE3: equ 119
; TAG_MAYA_RIDDLE_CLUE4: equ 120
; TAG_STORY_TRIVIA1: equ 121
; TAG_STORY_TRIVIA2: equ 122
; TAG_STORY_TRIVIA3: equ 123
; TAG_STORY_TRIVIA4: equ 124
; TAG_STORY_TRIVIA5: equ 125
; TAG_STORY_TRIVIA6: equ 126
; TAG_STORY_TRIVIA7: equ 127
; TAG_STORY_TRIVIA8: equ 128
; TAG_ITEM_SANDALS: equ 129
; TAG_ITEM_GLOVES: equ 130
; TAG_ITEM_HURAKAN: equ 131
; TAG_ITEM_ARMOR: equ 132
; TAG_ITEM_CHAAC: equ 133
; TAG_ITEM_SEASHELL: equ 134
; TAG_ITEM_BELT: equ 135
; TAG_ITEM_ICE_CAPE: equ 136
; TAG_SMALL_KEY1: equ 137
; TAG_SMALL_KEY2: equ 138
; TAG_SMALL_KEY3: equ 139
; TAG_SMALL_KEY4: equ 140
; TAG_SMALL_KEY_CHEST1: equ 141
; TAG_SMALL_KEY_CHEST2: equ 142
; TAG_SMALL_KEY_CHEST3: equ 143
; TAG_SMALL_KEY_CHEST4: equ 144
; ; tags above can ONLY appear once in the whole game
; N_UNIQUE_TAGS: equ 145
; ; tags below can appear multiple times (and do not have state, they are reset every time you enter in a room):
; TAG_PUSHABLE_BLOCK: equ 145	