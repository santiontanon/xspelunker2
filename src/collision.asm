;-----------------------------------------------
; output:
; - z: collision
; - nz: no collision
player_check_collision_idle:
	ld e, 2  ; wall
player_check_collision_idle_with_e:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_x + 1)
	ld c, a
	; collision with the feet:
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_idle_continue
	inc b
player_check_collision_idle_continue:
IF COLLISION_UNIT_TESTING == 0	
	ld a, c
	cp #ff
	jp z, player_exit_room_left
ENDIF
	push bc
	push de
		call get_room_tile_type
	pop de
	pop bc
	cp e
	ret z
	; collision with the head:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	jr c, player_check_collision_idle_continue2
	inc b
player_check_collision_idle_continue2:
	push de
		call get_room_tile_type
	pop de
	cp e
	ret
player_check_collision_idle_no_collision:
	or 1
	ret


;-----------------------------------------------
; output:
; - z: collision
; - nz: no collision
player_check_collision_left:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_x + 1)
	ld c, a
	; collision with the feet:
	inc b
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	jr c, player_check_collision_left_continue
	inc b
player_check_collision_left_continue:
IF COLLISION_UNIT_TESTING == 0	
	ld a, c
	cp #ff
	jp z, player_exit_room_left
ENDIF
	push bc
		call get_room_tile_type
	pop bc
	cp 2  ; wall
	ret z
	; if we are crawling, do not check head:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CRAWLING
	jr z, player_check_collision_left_no_collision	
	; collision with the head:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	jr c, player_check_collision_left_continue2
	inc b
player_check_collision_left_continue2:
	call get_room_tile_type
	cp 2
	ret
player_check_collision_left_no_collision:
	or 1
	ret


;-----------------------------------------------
; Check if tile type is 2
; output:
; - z: collision
; - nz: no collision
player_check_collision_right:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet:
	inc c
	inc b
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	jr c, player_check_collision_right_continue
	inc b
player_check_collision_right_continue:
IF COLLISION_UNIT_TESTING == 0	
	ld a, (current_room__width)
	cp c
	jp z, player_exit_room_right
ENDIF
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret z
	; if we are crawling, do not check head:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CRAWLING
	jr z, player_check_collision_right_no_collision
	; collision with the head:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	jr c, player_check_collision_right_continue2
	inc b
player_check_collision_right_continue2:
	call get_room_tile_type
	cp 2
	ret
player_check_collision_right_no_collision:
	or 1
	ret


;-----------------------------------------------
; Check if tile type is 1/2/6/8 (if pixel coordinate is 0 only) (incrementing y by 1 pixel)
; output:
; - z: collision
; - nz: no collision
player_check_collision_down_inc:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet-left:
	inc b
	inc b
IF COLLISION_UNIT_TESTING == 0	
	ld a, (current_room__height)
	cp b
	jp z, player_exit_room_down
ENDIF
	push bc
		call get_room_tile_type
	pop bc
	cp 2  ; wall
	ret z
	cp 6  ; rope-platform
	jr z, player_check_collision_down_inc_platform
	cp 6  ; ladder-platform
	jr z, player_check_collision_down_inc_platform
	dec a  ; platform
	jr nz, player_check_collision_down_inc_right
player_check_collision_down_inc_platform:
	; tile type is 1 (platform), check if pixel coordinate is 0, and in that case, it's a collision:
	ld a, (player_y)
	or a
	ret z
player_check_collision_down_inc_right:
	; collision with the feet-right:
	ld a, (player_x)
	cp (8 - PLAYER_COLLISION_WIDTH) + 1
	jr c, player_check_collision_down_inc_continue2
	inc c  ; if < PLAYER_COLLISION_BOX_WIDTH, c+=1
player_check_collision_down_inc_continue2:
	call get_room_tile_type
	cp 2
	ret z
	cp 6  ; rope-platform
	jr z, player_check_collision_down_inc_platform2
	cp 8  ; ladder-platform
	jr z, player_check_collision_down_inc_platform2
	dec a  ; platform
	ret nz
player_check_collision_down_inc_platform2:
	; tile type is 1 (platform), check if pixel coordinate is 0, and in that case, it's a collision:
	ld a, (player_y)
	or a
	ret


;-----------------------------------------------
player_check_collision_up:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the head-left:
IF COLLISION_UNIT_TESTING == 0	
	cp #ff
	jp z, player_exit_room_up
ENDIF
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret z
	; collision with the head-right:
	ld a, (player_x)
	cp (8 - PLAYER_COLLISION_WIDTH) + 1
	jr c, player_check_collision_up_continue2
	inc c  ; if < PLAYER_COLLISION_BOX_WIDTH, c+=1
player_check_collision_up_continue2:
	call get_room_tile_type
	cp 2
	ret


;-----------------------------------------------
; Check if tile type is 5/6/7/8 (if pixel coordinate is 0 only) (incrementing y by 1 pixel)
; output:
; - z: rope
; - nz: no rope
; - a: 0, if rope
;	   2, if ladder
; - c: tile coordinate where the rope/ladder was found
check_player_on_rope_or_ladder:  ; this checks for y + 1
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	jp check_player_on_top_of_rope_continue
check_player_on_top_of_rope_or_ladder:  ; this checks for y + 2
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet-left:
	inc b
check_player_on_top_of_rope_continue:
	ld a, (player_x)
	cp 7
	jr nz, check_player_on_top_of_rope_continue2
	inc c
check_player_on_top_of_rope_continue2:
	inc b
	push bc
		call get_room_tile_type
	pop bc
	cp 5
	jr z, check_player_on_top_of_rope
	cp 6
	jr z, check_player_on_top_of_rope
	cp 7
	jr z, check_player_maybe_on_top_of_ladder
	cp 8
	jr z, check_player_maybe_on_top_of_ladder	
	ret
check_player_on_top_of_rope:
	xor a  ; z, a = 0
	ret
check_player_maybe_on_top_of_ladder:
	inc c
	push bc
		call get_room_tile_type
	pop bc
	dec c
	cp 7
	jr z, check_player_on_top_of_ladder
	cp 8
	jr nz, check_player_on_top_of_ladder_right
check_player_on_top_of_ladder:
	ld a, 2
	ret
check_player_on_top_of_ladder_right:
	dec c
	xor a  ; set z
	ld a, 2
	ret



;-----------------------------------------------
; Check if tile type is 1/2/6/8 (if pixel coordinate is 0 only) (incrementing y by 1 pixel)
; output:
; - z: in water
; - nz: not in water
player_in_water:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	inc b
	call get_room_tile_type
	cp 4  ; water
	ret


;-----------------------------------------------
; input:
; - c: tile x
; - b: tile y
; output:
; - a: tile collision type
get_room_tile_type:
	ld a, (current_room__width)
	cp 32*2
	jr z, get_room_tile_type_width64
	cp 32*3
	jr z, get_room_tile_type_width96
	cp 32*4
	jr z, get_room_tile_type_width128
get_room_tile_type_width32:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0
	jp get_room_tile_type_width32_entry_point
get_room_tile_type_width96:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0

	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 32
	push de
		ld e, l
		ld d, h
		add hl, hl
		add hl, de  ; hl = y (96)
	pop de
	jp get_room_tile_type_continue
get_room_tile_type_width64:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0
	jp get_room_tile_type_width64_entry_point
get_room_tile_type_width128:
	ld l, b
	ld h, 0
	add hl, hl
get_room_tile_type_width64_entry_point:
	add hl, hl
get_room_tile_type_width32_entry_point:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 128
get_room_tile_type_continue:
	ld b, 0
	add hl, bc
	ld bc, current_room__tile_map
	add hl, bc
	ld a, (hl)
	or a
	ret z  ; 0 is directly no collision (we exit early, as the table below starts at 32)

	; get collision type:
	ld hl, (current_room__collision_ptr)
	ADD_HL_A
	ld a, (hl)
	ret


IF COLLISION_UNIT_TESTING == 0	

;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - c, b: player tile coordinates (limited to room dimensions)
crop_player_tile_coordinates_top_room_limits:
		; make sure c, b, are within the room:
		ld a, c
		cp #ff
		jr nz, crop_player_tile_coordinates_top_room_limits_continue1
		inc c
crop_player_tile_coordinates_top_room_limits_continue1:
		ld a, (current_room__width)
		cp c
		jr nz, crop_player_tile_coordinates_top_room_limits_continue2
		dec c
crop_player_tile_coordinates_top_room_limits_continue2:
		ld a, b
		cp #ff
		jr nz, crop_player_tile_coordinates_top_room_limits_continue3
		inc b
crop_player_tile_coordinates_top_room_limits_continue3:
		ld a, (current_room__height)
		cp b
		ret nz
		dec b
		ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - hl: ptr inside "current_area__chunks_ids" where the player currently is located
; - ixl: player_y % 12
get_chunk_ids_current_room_ptr:
	push bc
		call crop_player_tile_coordinates_top_room_limits

		; convert c, b to coordinates in "chunks" (c/=16, b/=12)
		sra c
		sra c
		sra c
		sra c

		ld a, b
		ld b, 0
get_chunk_ids_current_room_ptr_div24_loop:
		sub 12
		jr c, get_chunk_ids_current_room_ptr_continue5
		inc b
		jr get_chunk_ids_current_room_ptr_div24_loop
get_chunk_ids_current_room_ptr_continue5:
		add a, 12
		ld ixl, a  ; player_y % 12

		ld a, (current_area__width)
		add a, a
		ld hl, 0
		ld d, 0
		ld e, a
		ld a, (current_room__y)
		add a, a
		add a, b
		or a
		jr z, get_chunk_ids_current_room_ptr_continue
get_chunk_ids_current_room_ptr_loop:
		add hl, de
		dec a
		jr nz, get_chunk_ids_current_room_ptr_loop
get_chunk_ids_current_room_ptr_continue:

		ld a, (current_room__x)
		add a, a
		add a, c
		ld e, a
		add hl, de
		ld de, current_area__chunks_ids
		add hl, de
	pop bc
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - hl: ptr inside "current_area__room_ids" where the player currently is located
get_room_ids_current_room_ptr:
	push bc
		call crop_player_tile_coordinates_top_room_limits
		call get_player_room_coordinates

		ld a, (current_area__width)
		ld hl, 0
		ld d, 0
		ld e, a
		ld a, (current_room__y)
		add a, b
		or a
		jr z, get_room_ids_current_room_ptr_continue
get_room_ids_current_room_ptr_loop:
		add hl, de
		dec a
		jr nz, get_room_ids_current_room_ptr_loop
get_room_ids_current_room_ptr_continue:

		ld a, (current_room__x)
		add a, c
		ld e, a
		add hl, de
		ld de, current_area__room_ids
		add hl, de
	pop bc
	ret


;-----------------------------------------------
player_exit_room_left:
	call check_for_interarea_exit_left
	call check_collision_with_next_chunk_left
	ret z  ; collision	
	call get_room_ids_current_room_ptr
	dec hl
	ld e, (hl)  ; next roomID
	ld a, e
	cp #ff
	ret z
	push de
		call disable_VDP_output
	pop de
	ld a, (current_room__y)
	push af
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af
	; adjust "y" coordinate, based on the difference of current vs previous y coordinate:
	ld c, a
	ld a, (current_room__y)
	sub c
	neg
	add a, a
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, (player_y + 1)
	add a, c
	ld (player_y + 1), a

	ld a, (current_room__width)
	dec a
	ld (player_x + 1), a
	xor a
	ld (player_x), a
	jp state_play_from_loaded_room


;-----------------------------------------------
player_exit_room_right:
	call check_for_interarea_exit_right
	call check_collision_with_next_chunk_right
	ret z  ; collision
	call get_room_ids_current_room_ptr
	inc hl
	ld e, (hl)  ; next roomID
	ld a, e
	cp #ff
	ret z
	push de
		call disable_VDP_output
	pop de
	ld a, (current_room__y)
	push af	
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af
	; adjust "y" coordinate, based on the difference of current vs previous y coordinate:
	ld c, a
	ld a, (current_room__y)
	sub c
	neg
	add a, a
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, (player_y + 1)
	add a, c
	ld (player_y + 1), a

	xor a
	ld (player_x + 1), a
	ld (player_x), a
	jp state_play_from_loaded_room


;-----------------------------------------------
player_exit_room_up:
	call check_for_interarea_exit_up
	call check_collision_with_next_chunk_up
	ret z  ; collision		
	call get_room_ids_current_room_ptr
	ld a, (current_area__width)
	ld d, 0
	ld e, a
	or a
	sbc hl, de
	ld e, (hl)  ; next roomID
	ld a, e
	cp #ff
	ret z
	push de
		call disable_VDP_output
	pop de
	ld a, (current_room__x)
	push af
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af
	; adjust "x" coordinate, based on the difference of current vs previous x coordinate:
	ld c, a
	ld a, (current_room__x)
	sub c
	neg
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, (player_x + 1)
	add a, c
	ld (player_x + 1), a

	ld a, (current_room__height)
	add a, -2
	ld (player_y + 1), a
	xor a
	ld (player_y), a
	jp state_play_from_loaded_room


;-----------------------------------------------
; input:
; - c, b: player coordinates
player_exit_room_down:
	call check_for_interarea_exit_down
	call check_collision_with_next_chunk_down
	ret z  ; collision		
	call get_room_ids_current_room_ptr
	ld a, (current_area__width)
	ld d, 0
	ld e, a
	add hl, de
	ld e, (hl)  ; next roomID
	ld a, e
	cp #ff
	ret z
	push de
		call disable_VDP_output
	pop de
	ld a, (current_room__x)
	push af
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af
	; adjust "x" coordinate, based on the difference of current vs previous x coordinate:
	ld c, a
	ld a, (current_room__x)
	sub c
	neg
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, (player_x + 1)
	add a, c
	ld (player_x + 1), a

	xor a
	ld (player_y + 1), a
	ld (player_y), a
	jp state_play_from_loaded_room


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - z: collision
; - nz: no collision
check_collision_with_next_chunk_left:
	push bc
		call get_chunk_ids_current_room_ptr  ; ixl now has player_y % 12
	pop bc
	dec hl
	push hl
		ld a, (hl)  ; chunk ID
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		ld de, chunk_edgecollisions_pyramid + 2
		add hl, de
		ld e, (hl)  ; e = bitmask with collisions on the right edge of the chunk
		ld a, ixl
		sra a
		; check if the corresponding bit is on/off:
check_collision_with_next_chunk_left_loop:
		jr z, check_collision_with_next_chunk_left_bit_found
		rr e
		dec a
		jp 	check_collision_with_next_chunk_left_loop
check_collision_with_next_chunk_left_bit_found:
		ld a, e
		and #01
		xor #01  ; reverse the bit to get the flag we want
	pop hl
	ret nz
	; collision, check if a door or breakable wall was open:
	ld de, -current_area__chunks_ids
	add hl, de
	ld e, l  ; e = chunk we are looking at
	ld ixh, 1  ; entering from the right
	push bc  ; preserve player coordinates
		call check_collision_with_next_chunk_check_horizontal_open_wall
	pop bc
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - z: collision
; - nz: no collision
check_collision_with_next_chunk_right:
	push bc
		call get_chunk_ids_current_room_ptr  ; ixl now has player_y % 12
	pop bc
	inc hl
	push hl
		ld a, (hl)  ; chunk ID
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		ld de, chunk_edgecollisions_pyramid
		add hl, de
		ld e, (hl)  ; e = bitmask with collisions on the left edge of the chunk
		ld a, ixl
		sra a
		; check if the corresponding bit is on/off:
check_collision_with_next_chunk_right_loop:
		jr z, check_collision_with_next_chunk_right_bit_found
		rr e
		dec a
		jp 	check_collision_with_next_chunk_right_loop
check_collision_with_next_chunk_right_bit_found:
		ld a, e
		and #01
		xor #01  ; reverse the bit to get the flag we want
	pop hl
	ret nz
	; collision, check if a door or breakable wall was open:
	ld de, -current_area__chunks_ids
	add hl, de
	ld e, l  ; e = chunk we are looking at
	ld ixh, 0  ; entering from the left
	push bc  ; preserve player coordinates
		call check_collision_with_next_chunk_check_horizontal_open_wall
	pop bc
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - z: collision
; - nz: no collision
check_collision_with_next_chunk_up:
	push bc
		call get_chunk_ids_current_room_ptr  ; ixl now has player_y % 12
	pop bc
	ld a, (current_area__width)
	add a, a
	ld e, a
	ld d, 0
	or a
	sbc hl, de
	push hl
		ld a, (hl)  ; chunk ID
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		ld de, chunk_edgecollisions_pyramid + 3
		add hl, de
		ld e, (hl)  ; e = bitmask with collisions on the down edge of the chunk
		ld a, c
		and #0f
		sra a
		; check if the corresponding bit is on/off:
check_collision_with_next_chunk_up_loop:
		jr z, check_collision_with_next_chunk_up_bit_found
		rr e
		dec a
		jp 	check_collision_with_next_chunk_up_loop
check_collision_with_next_chunk_up_bit_found:
		ld a, e
		and #01
		xor #01  ; reverse the bit to get the flag we want
	pop hl
	ret nz
	; collision, check if a door or breakable wall was open:
	ld de, -current_area__chunks_ids
	add hl, de
	ld e, l  ; e = chunk we are looking at
	ld ixh, 1  ; entering from the below
	push bc  ; preserve player coordinates
		call check_collision_with_next_chunk_check_vertical_open_wall
	pop bc
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - z: collision
; - nz: no collision
check_collision_with_next_chunk_down:
	push bc
		call get_chunk_ids_current_room_ptr  ; ixl now has player_y % 12
	pop bc
	ld a, (current_area__width)
	add a, a
	ld e, a
	ld d, 0
	add hl, de
	push hl
		ld a, (hl)  ; chunk ID
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		ld de, chunk_edgecollisions_pyramid + 1
		add hl, de
		ld e, (hl)  ; e = bitmask with collisions on the up edge of the chunk
		ld a, c
		and #0f
		sra a
		; check if the corresponding bit is on/off:
check_collision_with_next_chunk_down_loop:
		jr z, check_collision_with_next_chunk_down_bit_found
		rr e
		dec a
		jp 	check_collision_with_next_chunk_down_loop
check_collision_with_next_chunk_down_bit_found:
		ld a, e
		and #01
		xor #01  ; reverse the bit to get the flag we want
	pop hl
	ret nz
	; collision, check if a door or breakable wall was open:
	ld de, -current_area__chunks_ids
	add hl, de
	ld e, l  ; e = chunk we are looking at
	ld ixh, 0  ; entering from the above
	push bc  ; preserve player coordinates
		call check_collision_with_next_chunk_check_vertical_open_wall
	pop bc
	ret


;-----------------------------------------------
; input:
; - ixl: within chunk tile y coordinate to check
; - ixh: 0 (from left), 1 (from right)
; - e: chunk we are looking at
check_collision_with_next_chunk_check_horizontal_open_wall:
	ld a, (current_area__id)
	inc a
	ld d, a  ; area ID + 1
	ld hl, global_state__open_walls
check_collision_with_next_chunk_check_horizontal_open_wall_loop:
	ld a, (hl)
	or a
	ret z  ; no more open walls to check
	cp d
	jr nz, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next6
	inc hl
	ld a, (hl)
	cp e
	jr nz, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next5
	inc hl
	ld a, ixh
	or a
	jr nz, check_collision_with_next_chunk_check_horizontal_open_wall_right
	ld a, (hl)
	or a  ; if it's not in the left, we are not interested
	jr nz, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next4
	inc hl
	ld a, (hl)
	cp ixl  ; y coordinate within this chunk
	jr nc, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next3
	inc hl  ; skip width
check_collision_with_next_chunk_check_horizontal_open_wall_right_continue:
	inc hl
	add a, (hl)  ; a = y + height
	cp ixl  ; y coordinate within this chunk
	jr z, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next1
	jr c, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next1
	; wall was open! no collision!
	or 1
	ret
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next6:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next5:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next4:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next3:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next2:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next1:
	inc hl
	jr check_collision_with_next_chunk_check_horizontal_open_wall_loop

check_collision_with_next_chunk_check_horizontal_open_wall_right:
	ld c, (hl)
	inc hl
	ld b, (hl)
	cp ixl  ; y coordinate within this chunk
	jr nc, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next3
	inc hl
	ld a, (hl)
	add a, c
	cp CHUNK_WIDTH - 1
	ld a, b  ; recover 'y' in a
	jr c, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next2
	jr check_collision_with_next_chunk_check_horizontal_open_wall_right_continue



;-----------------------------------------------
; input:
; - ixh: 0 (from above), 1 (from below)
; - e: chunk we are looking at
check_collision_with_next_chunk_check_vertical_open_wall:
	ld a, (player_x + 1)
	and #0f
	ld ixl, a  ; ixl = player tile coordinate within the chunk
	ld a, (current_area__id)
	inc a
	ld d, a  ; area ID + 1
	ld hl, global_state__open_walls
check_collision_with_next_chunk_check_vertical_open_wall_loop:
	ld a, (hl)
	or a
	ret z  ; no more open walls to check
	cp d
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_loop_next6
	inc hl
	ld a, (hl)
	cp e
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_loop_next5
	inc hl
	ld c, (hl)  ; x1
	ld a, c
	cp ixl  ; x coordinate within this chunk
	jr nc, check_collision_with_next_chunk_check_vertical_open_wall_loop_next4
	inc hl
	ld a, ixh
	or a
	ld a, (hl)  ; y1
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_down
	or a  ; if it's not in above, we are not interested
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_loop_next3
	inc hl
	ld a, c
	add a, (hl)
	cp ixl  ; x coordinate within this chunk
	jr z, check_collision_with_next_chunk_check_vertical_open_wall_loop_next2
	jr c, check_collision_with_next_chunk_check_vertical_open_wall_loop_next2
	; wall was open! no collision!
	or 1
	ret
check_collision_with_next_chunk_check_vertical_open_wall_loop_next6:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next5:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next4:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next3:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next2:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next1:
	inc hl
	jr check_collision_with_next_chunk_check_vertical_open_wall_loop

check_collision_with_next_chunk_check_vertical_open_wall_down:
	ld b, a  ; y1
	inc hl
	ld a, c
	add a, (hl)  ; width
	cp ixl  ; x coordinate within this chunk
	jr z, check_collision_with_next_chunk_check_vertical_open_wall_loop_next2
	jr c, check_collision_with_next_chunk_check_vertical_open_wall_loop_next2
	inc hl
	ld a, (hl)  ; height	
	add a, b
	cp CHUNK_HEIGHT
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_loop_next1
	; wall was open! no collision!
	or 1
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
get_player_room_coordinates:
	; convert c, b to coordinates in "screens" (c/=32, b/=24)
	sra c
	sra c
	sra c
	sra c
	sra c
	ld a, b
	ld b, 0
get_player_room_coordinates_div24_loop:
	sub 24
	ret c
	inc b
	jr get_player_room_coordinates_div24_loop


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
get_player_chunk_coordinates:
	; convert c, b to coordinates in "screens" (c/=16, b/=12)
	sra c
	sra c
	sra c
	sra c
	ld a, b
	ld b, 0
get_player_chunk_coordinates_div12_loop:
	sub 12
	ret c
	inc b
	jr get_player_chunk_coordinates_div12_loop


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
check_for_interarea_exit_left:
	ld d, PCG_DIRECTION_LEFT
	jp check_for_interarea_exit_d
check_for_interarea_exit_up:
	ld d, PCG_DIRECTION_UP
	jp check_for_interarea_exit_d
check_for_interarea_exit_right:
	ld d, PCG_DIRECTION_RIGHT
	jp check_for_interarea_exit_d
check_for_interarea_exit_down:
	ld d, PCG_DIRECTION_DOWN
check_for_interarea_exit_d:
	push bc
		call crop_player_tile_coordinates_top_room_limits
		call get_player_chunk_coordinates
		ld a, (current_room__x)
		add a, a
		add a, c
		ld c, a
		ld a, (current_room__y)
		add a, a
		add a, b
		ld b, a  ; c, b: room coordinate in the area

		ld a, (current_area__id)
		ld e, a
		; check if coordinates match any inter-area exit:
		ld hl, current_world__interarea_connections  ; id1, id2, x1, y1, direction1, x2, y2, direction2
check_for_interarea_exit_loop:
		ld a, (hl)  ; id1
		inc hl
		cp #ff  ; sentinel
		jr z, check_for_interarea_exit_done
		cp e
		jr nz, check_for_interarea_exit_no_area1
		inc hl
		ld a, (hl)  ; x1
		cp c
		jr nz, check_for_interarea_exit_no_x1
		inc hl
		ld a, (hl)  ; y1
		cp b
		jr nz, check_for_interarea_exit_no_y1
		inc hl
		ld a, (hl)  ; direction1
		cp d  ; compare with direction the player is exiting through
		jr nz, check_for_interarea_exit_no_direction1
		; match 1, we need to teleport to area 2!
; 	    ; only going up to another area up/down via ladders
; 		ld a, d
; 		cp PCG_DIRECTION_LEFT
; 		jr z, check_for_interarea_exit_exit1_ok
; 		cp PCG_DIRECTION_RIGHT
; 		jr z, check_for_interarea_exit_exit1_ok
; 		ld a, (player_state)
; 		and #fe
; 		cp PLAYER_STATE_LADDER
; 		jp nz, check_for_interarea_exit_done
; check_for_interarea_exit_exit1_ok:
		dec hl
		dec hl
		dec hl
		ld a, (hl)  ; id2
		inc hl
		inc hl
		inc hl
		inc hl
		jp interarea_exit  ; no need for "pop bc", since interarea_exit will reset the stack

check_for_interarea_exit_no_direction1:
		dec hl
check_for_interarea_exit_no_y1:
		dec hl
check_for_interarea_exit_no_x1:
		dec hl
check_for_interarea_exit_no_area1:
		ld a, (hl)  ; id2
		inc hl
		inc hl
		inc hl
		inc hl
		cp e
		jr nz, check_for_interarea_exit_no_area2
		ld a, (hl)  ; x2
		cp c
		jr nz, check_for_interarea_exit_no_x2
		inc hl
		ld a, (hl)  ; y2
		cp b
		jr nz, check_for_interarea_exit_no_y2
		inc hl
		ld a, (hl)  ; direction2
		cp d  ; compare with direction the player is exiting through
		jr nz, check_for_interarea_exit_no_direction2
		; match 2, we need to teleport to area 1!
	    ; only going up to another area up/down via ladders
; 		ld a, d
; 		cp PCG_DIRECTION_LEFT
; 		jr z, check_for_interarea_exit_exit2_ok
; 		cp PCG_DIRECTION_RIGHT
; 		jr z, check_for_interarea_exit_exit2_ok
; 		ld a, (player_state)
; 		and #fe
; 		cp PLAYER_STATE_LADDER
; 		jp nz, check_for_interarea_exit_done
; check_for_interarea_exit_exit2_ok:		
		ld bc, -7
		add hl, bc
		ld a, (hl)  ; id1
		inc hl
		inc hl
		jp interarea_exit  ; no need for "pop bc", since interarea_exit will reset the stack

check_for_interarea_exit_no_area2:
check_for_interarea_exit_no_x2:
		inc hl
check_for_interarea_exit_no_y2:		
		inc hl
check_for_interarea_exit_no_direction2:		
		inc hl
		jp check_for_interarea_exit_loop

check_for_interarea_exit_done:
	pop bc
	ret


ENDIF

;-----------------------------------------------
; the first 32 tiles canot appear in a level, so, we only define collision for the other 224 tiles

; 0: no collision
; 1: platform (you can jump through)
; 2: wall
; 3: hazard
; 4: water
; 5: rope
; 6: rope-platform-top
; 7: ladder
; 8: ladder-platform-top
tile_collision_types_pyramid:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 4, 0, 0, 0, 0, 8, 8, 2, 2, 2, 2, 2, 2
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2
    db 4, 0, 0, 5, 2, 2, 5, 6, 8, 1, 1, 1, 2, 3, 2, 2
    db 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 0, 2, 2, 2, 2, 2, 0, 7, 8, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2
    db 0, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 0, 2, 2, 7, 2, 2, 2, 3, 2, 1, 5


tile_collision_types_calendar:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2
    db 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 2, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 0, 2, 0, 7, 2, 0, 0, 0, 2, 0, 0


;-----------------------------------------------
chunk_edgecollisions_pyramid:
	include "autogenerated/pyramid-chunk-edgecollisions.asm"

