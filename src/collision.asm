;-----------------------------------------------
; Check if tile type is 2
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
	or a
	jr z, player_check_collision_left_continue
	inc b
player_check_collision_left_continue:
	ld a, c
	cp #ff
	jp z, player_exit_room_left
	push bc
		call get_room_tile_type
	pop bc
	cp 2
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
	cp 8 - PLAYER_COLLISION_UP_LEEWAY  ; 5
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
	inc c
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_right_continue
	inc b
player_check_collision_right_continue:
	ld a, (current_room__width)
	cp c
	jp z, player_exit_room_right	
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
	cp 8 - PLAYER_COLLISION_UP_LEEWAY  ; 5
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
	ld a, (player_x)
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	jr c, player_check_collision_down_inc_continue
	inc c  ; if >= PLAYER_COLLISION_BOX_WIDTH, c+=1
player_check_collision_down_inc_continue:
	ld a, (current_room__height)
	cp b
	jp z, player_exit_room_down
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
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	jr nc, player_check_collision_down_inc_continue2
	inc c  ; if < PLAYER_COLLISION_BOX_WIDTH, c+=1
	jp player_check_collision_down_inc_continue3
player_check_collision_down_inc_continue2:
	cp (8 - PLAYER_COLLISION_BOX_WIDTH)
	jr c, player_check_collision_down_inc_continue3
	inc c  ; if >= (8 - PLAYER_COLLISION_BOX_WIDTH), c+=1
player_check_collision_down_inc_continue3:
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
	ld a, (player_x)
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	jr c, player_check_collision_up_continue
	inc c  ; if >= PLAYER_COLLISION_BOX_WIDTH, c+=1
player_check_collision_up_continue:
	ld a, b
	cp #ff
	jp z, player_exit_room_up
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret z
	; collision with the head-right:
	ld a, (player_x)
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	jr nc, player_check_collision_up_continue2
	inc c  ; if < PLAYER_COLLISION_BOX_WIDTH, c+=1
	jp player_check_collision_up_continue3
player_check_collision_up_continue2:
	cp (8 - PLAYER_COLLISION_BOX_WIDTH)
	jr c, player_check_collision_down_inc_continue3
	inc c  ; if >= (8 - PLAYER_COLLISION_BOX_WIDTH), c+=1
player_check_collision_up_continue3:
	call get_room_tile_type
	cp 2
	ret


;-----------------------------------------------
; Check if tile type is 5/6/7/8 (if pixel coordinate is 0 only) (incrementing y by 1 pixel)
; output:
; - z: rope
; - nz: no rope
; - a: 0, if (player_x + 1) tile below is rope
;      1, if (player_x + 1) + 1 tile below is rope
;	   2, if (player_X + 1) tile below is a ladder && (player_X + 1) + 1 as well
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
	inc b
	push bc
		call get_room_tile_type
	pop bc
	cp 5
	jr z, check_player_on_top_of_rope_0
	cp 6
	jr z, check_player_on_top_of_rope_0
	cp 7
	jr z, check_player_maybe_on_top_of_ladder
	cp 8
	jr z, check_player_maybe_on_top_of_ladder	
check_player_on_top_of_rope_right:
	inc c
	call get_room_tile_type
	cp 5
	jr z, check_player_on_top_of_rope_1
	cp 6
	jr z, check_player_on_top_of_rope_1
	ret
check_player_on_top_of_rope_0:
	xor a  ; z, a = 0
	ret
check_player_on_top_of_rope_1:
	ld a, 1
	ret
check_player_maybe_on_top_of_ladder:
	inc c
	call get_room_tile_type
	cp 7
	jr z, check_player_on_top_of_ladder
	cp 8
	ret nz
check_player_on_top_of_ladder:
	ld a, 2
	ret


;-----------------------------------------------
; input:
; - c: tile x
; - b: tile y
; output:
; - a: tile collision type
get_room_tile_type:
	ld a, (current_room__width)
	cp 64
	jr z, get_room_tile_type_width64
get_room_tile_type_width32:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 32
	jp get_room_tile_type_continue
get_room_tile_type_width64:
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 64
get_room_tile_type_continue:
	ld b, 0
	add hl, bc
	ld bc, current_room__tile_map
	add hl, bc
	ld a, (hl)

	; get collision type:
	ld hl, tile_collision_types_pyramid
	ADD_HL_A
	ld a, (hl)
	ret


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

		; convert c, b to coordinstes in "chunks" (c/=16, b/=12)
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

		; convert c, b to coordinstes in "screens" (c/=32, b/=24)
		sra c
		sra c
		sra c
		sra c
		sra c

		ld a, b
		ld b, 0
get_room_ids_current_room_ptr_div24_loop:
		sub 24
		jr c, get_room_ids_current_room_ptr_continue5
		inc b
		jr get_room_ids_current_room_ptr_div24_loop
get_room_ids_current_room_ptr_continue5:

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
	call check_collision_with_next_chunk_left
	ret z  ; collision	
	call get_room_ids_current_room_ptr
	dec hl
	ld e, (hl)  ; next roomID
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
	add a, -2
	ld (player_x + 1), a
	xor a
	ld (player_x), a
	jp state_play_from_loaded_room


;-----------------------------------------------
player_exit_room_right:
	call check_collision_with_next_chunk_right
	ret z  ; collision
	call get_room_ids_current_room_ptr
	inc hl
	ld e, (hl)  ; next roomID
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
	call check_collision_with_next_chunk_up
	ret z  ; collision		
	call get_room_ids_current_room_ptr
	ld a, (current_area__width)
	ld d, 0
	ld e, a
	or a
	sbc hl, de
	ld e, (hl)  ; next roomID
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
player_exit_room_down:
	call check_collision_with_next_chunk_down
	ret z  ; collision		
	call get_room_ids_current_room_ptr
	ld a, (current_area__width)
	ld d, 0
	ld e, a
	add hl, de
	ld e, (hl)  ; next roomID
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
	ret


;-----------------------------------------------
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
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3
    db 4, 4, 4, 4, 5, 5, 5, 6, 1, 1, 1, 1, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 0, 0, 8, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 0, 0, 0, 5, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2


;-----------------------------------------------
chunk_edgecollisions_pyramid:
	include "autogenerated/pyramid-chunk-edgecollisions.asm"

