;-----------------------------------------------
rebuild_global_state__open_walls__table1:
	db TAG_BUTTON1, TAG_BUTTON2, TAG_BUTTON3, TAG_BUTTON4
	db TAG_RED_LOCK, TAG_GREEN_LOCK, TAG_BLUE_LOCK, TAG_YELLOW_LOCK, TAG_WHITE_LOCK, TAG_PURPLE_LOCK
	db TAG_TRIAL1_LOCK, TAG_TRIAL2_LOCK, TAG_TRIAL3_LOCK, TAG_TRIAL4_LOCK
	db TAG_COMBINATION1_LOCK, TAG_COMBINATION2_LOCK, TAG_COMBINATION3_LOCK, TAG_COMBINATION4_LOCK
	db TAG_BALL_LOCK, TAG_IDOL_LOCK, TAG_GEAR_LOCK, TAG_ASTRONAUT_LOCK
	db TAG_BUTTON1, TAG_BUTTON2, TAG_BUTTON3, TAG_BUTTON4
rebuild_global_state__open_walls__table1_end:


rebuild_global_state__open_walls__table2:
	db TAG_BREAKABLE_WALL1, TAG_BREAKABLE_WALL2, TAG_BREAKABLE_WALL3, TAG_BREAKABLE_WALL4
rebuild_global_state__open_walls__table2_end:


;-----------------------------------------------
rebuild_global_state__open_walls:
	; reset:
	ld hl, global_state__open_walls
	ld bc, 6 * N_PATH_OPENING_TAGS - 1
	call clear_memory

	; tags that can affect "global_state__open_walls":
	; door: (call "room_mark_open_door")
	;  - TAG_BUTTON1, ..., TAG_BUTTON4
	;  - TAG_RED_LOCK, ..., TAG_PURPLE_LOCK
	;  - TAG_TRIAL1_LOCK, ..., TAG_TRIAL4_LOCK
	;  - TAG_COMBINATION1_LOCK, ..., TAG_COMBINATION1_LOCK
	;  - TAG_BALL_LOCK, ..., TAG_ASTRONAUT_LOCK
	; breakable walls: (call "room_remove_breakable_wall")
	;  - TAG_BREAKABLE_WALL1, ..., TAG_BREAKABLE_WALL4

	; iterate through those tags and if anyone is active, mark the door/wall as open:
	ld ix, rebuild_global_state__open_walls__table1
	ld b, rebuild_global_state__open_walls__table1_end - rebuild_global_state__open_walls__table1
rebuild_global_state__open_walls__door_loop:
		ld hl, global_state__objects
		ld a, (ix)
		ld c, a
		ADD_HL_A
		ld a, (hl)
		or a
		jr z, rebuild_global_state__open_walls__door_loop_continue
		ld (hl), 0  ; temporarily mark it as closed (so that the room will generate the door)
		push hl
		push ix
		push bc
			; door is open, mark it!
			; - find which area it is in and generate it:
			ld a, (ix)  ; item ID
			call rebuild_global_state__open_walls__locate_item_area
			jr nz, rebuild_global_state__open_walls__door_loop_next  ; should never happen
			ld hl, pcg_generate_area
			ld c, PCG_PAGE
			call call_hl_in_page_c_8000
		pop bc
		ld a, c  ; recover the item ID
		push bc

			; - find which room it is in and generate it:
			call rebuild_global_state__open_walls__locate_item_room
			jr nz, rebuild_global_state__open_walls__door_loop_next  ; should never happen
			ld hl, pcg_generate_room
			ld c, PCG_PAGE
			call call_hl_in_page_c_8000

			; - find door object
			ld hl, find_room_door_object_ptr
			ld c, TILES_PAGE
			call call_hl_in_page_c_8000
			jp nz, rebuild_global_state__open_walls__door_loop_next  ; no door
			push hl
			pop ix

			; Create an entry in "global_state__open_walls":
			ld hl, room_mark_open_door
			ld c, PCG_PAGE
			call call_hl_in_page_c_8000

rebuild_global_state__open_walls__door_loop_next:
		pop bc
		pop ix
		pop hl
		ld (hl), 1  ; mark it again as open
rebuild_global_state__open_walls__door_loop_continue:
		inc ix
	djnz rebuild_global_state__open_walls__door_loop


	ld ix, rebuild_global_state__open_walls__table2
	ld b, rebuild_global_state__open_walls__table2_end - rebuild_global_state__open_walls__table2
rebuild_global_state__open_walls__wall_loop:
		ld hl, global_state__objects
		ld a, (ix)
		ld c, a
		ADD_HL_A
		ld a, (hl)
		or a
		jr z, rebuild_global_state__open_walls__wall_loop_continue
		ld (hl), 0  ; temporarily mark it as closed (so that the room will generate the wall)
		push ix
		push bc
			; breakable wall is open, mark it!
			; - find which area it is in and generate it:
			ld a, (ix)  ; item ID
			call rebuild_global_state__open_walls__locate_item_area
			jr nz, rebuild_global_state__open_walls__wall_loop_next  ; should never happen
			ld hl, pcg_generate_area
			ld c, PCG_PAGE
			call call_hl_in_page_c_8000
		pop bc
		ld a, c  ; recover the item ID
		push bc

			; - find which room it is in and generate it:
			call rebuild_global_state__open_walls__locate_item_room
			jr nz, rebuild_global_state__open_walls__door_loop_next  ; should never happen
			ld hl, pcg_generate_room
			ld c, PCG_PAGE
			call call_hl_in_page_c_8000

			; - find breakable wall object
			call find_room_breakable_wall_object_ptr
			jp nz, rebuild_global_state__open_walls__door_loop_next  ; no breakable wall
			push hl
			pop ix

			; Create an entry in "global_state__open_walls":
			ld hl, room_remove_breakable_wall
			ld c, TILES_PAGE
			call call_hl_in_page_c_8000
rebuild_global_state__open_walls__wall_loop_next:
		pop bc
		pop ix

rebuild_global_state__open_walls__wall_loop_continue:
		inc ix
	djnz rebuild_global_state__open_walls__wall_loop

	; handle TAG_MIDPOINT:
	ld a, (global_state__objects + TAG_MIDPOINT)
	or a
	ret z
	xor a
	ld (global_state__objects + TAG_MIDPOINT), a

	ld e, 5  ; fire shaft
	ld hl, pcg_generate_area
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000

	; find which room it is in and generate it:
	ld a, TAG_MIDPOINT
	call rebuild_global_state__open_walls__locate_item_room
	ret nz  ; should never happen
	ld hl, pcg_generate_room
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000

	ld hl, pcg_generate_room__open_midpoint_door
	ld c, PCG_PAGE
	jp call_hl_in_page_c_8000
	ret


;-----------------------------------------------
; input:
; - a: item to look for
; output:
; - e: area ID
; - z: found
; - nz: not found
rebuild_global_state__open_walls__locate_item_area:
	ld b, MAX_WORLD_AREAS
	ld hl, current_world__area_data + 4 + 1 + 1 + 1 + MAX_AREA_SIZE * 2
rebuild_global_state__open_walls__locate_item_area_loop:
	push hl
	push bc
		ld b, MAX_AREA_N_TAGS
rebuild_global_state__open_walls__locate_item_area_item_loop
		cp (hl)
		jr z, rebuild_global_state__open_walls__locate_item_area_found
		inc hl
		inc hl
		inc hl
		djnz rebuild_global_state__open_walls__locate_item_area_item_loop
	pop bc
	pop hl
	ld de, WORLD_AREA__SIZE
	add hl, de
	djnz rebuild_global_state__open_walls__locate_item_area_loop
	or 1  ; nz
	ret

rebuild_global_state__open_walls__locate_item_area_found:
	pop bc
	pop hl
	ld a, MAX_WORLD_AREAS
	sub b
	ld e, a
	xor a  ; z
	ret


;-----------------------------------------------
; input:
; - a: item to look for
; output:
; - e: room ID
; - z: found
; - nz: not found
rebuild_global_state__open_walls__locate_item_room:
	ld hl, current_area__objects
	ld b, MAX_AREA_N_OBJECTS
rebuild_global_state__open_walls__locate_item_room_loop:
	cp (hl)
	jr z, rebuild_global_state__open_walls__locate_item_room_found
	ld de, AREA_OBJECT_STRUCT_SIZE
	add hl, de
	djnz rebuild_global_state__open_walls__locate_item_room_loop
	or 1  ; nz
	ret

rebuild_global_state__open_walls__locate_item_room_found:
	inc hl
	ld a, (hl)  ; offset
	; convert offset from chunk coordinates to room coordinates:
	ld hl, covert_chunk_offset_to_room_offset
  	ld c, PCG_PAGE
  	ld e, a
	call call_hl_in_page_c_8000
    ld c, e
	ld hl, current_area__room_ids
	add hl, bc
	ld e, (hl)  ; room ID
	xor a  ; z
	ret


;-----------------------------------------------
; output:
; - z: door found
; - nz: door not found
; - hl: door ptr
find_room_breakable_wall_object_ptr:
	ld hl, current_room__tile_objects
	; : ds virtual MAX_ROOM_TILE_OBJECTS * ROOM_TILE_OBJECT_STRUCT_SIZE
find_room_breakable_wall_object_ptr_loop:
	ld a, (hl)
	cp #ff
	jr z, find_room_breakable_wall_object_ptr_not_found
	cp #fe
	jr z, find_room_breakable_wall_object_ptr_not_found
	inc hl
	ld a, (hl)  ; type
	dec hl
	cp TAG_BREAKABLE_WALL1
	ret z
	cp TAG_BREAKABLE_WALL2
	ret z
	cp TAG_BREAKABLE_WALL3
	ret z
	cp TAG_BREAKABLE_WALL4
	ret z
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jr find_room_breakable_wall_object_ptr_loop
find_room_breakable_wall_object_ptr_not_found:
	or 1
	ret
