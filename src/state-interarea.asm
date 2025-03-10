;-----------------------------------------------
; input:
; - a: target area ID
; - hl: ptr to room x, room y, direction of entrance
interarea_exit:
	push af
		call disable_VDP_output
	pop af
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want
	push hl
		; generate new area:
		ld hl, pcg_generate_area
		ld e, a  ; area to generate
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop hl

	; get room ID we are teleporting to:
	ld c, (hl)  ; x (in chunks)
	srl c  ; x in rooms
	inc hl
	ld b, (hl)  ; y (in chunks)
	srl b  ; y in rooms
	inc hl
	push hl
		; ptr = current_area__room_ids + y * (current_area__width) + x
		ld a, (current_area__width)
		ld e, a
		ld d, 0
		ld hl, 0
		ld a, b
		or a
		jr z, interarea_exit_room_ptr_loop_done
interarea_exit_room_ptr_loop:
		add hl, de
		djnz interarea_exit_room_ptr_loop
interarea_exit_room_ptr_loop_done:
		ld e, c
		add hl, de
		ld de, current_area__room_ids
		add hl, de
		ld e, (hl)  ; room we are teleporting to
	pop hl
	ld a, (hl)  ; direction
	cp PCG_DIRECTION_LEFT
	jp z, interarea_exit_left
	cp PCG_DIRECTION_UP
	jp z, interarea_exit_up
	cp PCG_DIRECTION_RIGHT
	jp z, interarea_exit_right

interarea_exit_down:
	; player enters from below
	push hl
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop hl
	; adjust x, y coordinates, based on the chunk we are going to:
	ld a, (current_room__x)
	add a, a
	dec hl
	dec hl
	sub (hl)  ; target x in chunks
	neg
	; target x is now: a * 16 + 7 (which is where the ladder connecting the two areas will be)
	add a, a  ; * 2
	add a, a  ; * 4
	add a, a  ; * 8
	add a, a  ; * 16
	add a, 7
	ld (player_x + 1), a
	ld a, PLAYER_PIXEL_X_ON_LADDER
	ld (player_x), a  ; center the player on the ladder
	ld a, PLAYER_STATE_LADDER
	ld (player_state), a
	ld a, (current_room__height)
	add a, -2
	ld (player_y + 1), a
	xor a
	ld (player_y), a
	jp state_play_from_loaded_room

interarea_exit_left:
	; player enters from the left
	push hl
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop hl
	; adjust x, y coordinates, based on the chunk we are going to:
	ld a, (current_room__y)
	add a, a
	dec hl
	sub (hl)  ; target y in chunks
	neg
	; target y is now: a * 12 + 8 (which is where the ladder connecting the two areas will be)
	add a, a  ; * 2
	add a, a  ; * 4
	ld c, a
	add a, a  ; * 8
	add a, c  ; * 12
	add a, 8
	ld (player_y + 1), a
	xor a
	ld (player_x + 1), a
	ld (player_y), a
	ld (player_x), a
	ld a, PLAYER_STATE_IDLE
	ld (player_state), a
	jp state_play_from_loaded_room

interarea_exit_up:
	; player enters from above
	push hl
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop hl
	; adjust x, y coordinates, based on the chunk we are going to:
	ld a, (current_room__x)
	add a, a
	dec hl
	dec hl
	sub (hl)  ; target x in chunks
	neg
	; target x is now: a * 16 + 7 (which is where the ladder connecting the two areas will be)
	add a, a  ; * 2
	add a, a  ; * 4
	add a, a  ; * 8
	add a, a  ; * 16
	add a, 7
	ld (player_x + 1), a
	ld a, PLAYER_PIXEL_X_ON_LADDER
	ld (player_x), a  ; center the player on the ladder
	ld a, PLAYER_STATE_LADDER
	ld (player_state), a	
	xor a
	ld (player_y + 1), a
	ld (player_y), a
	jp state_play_from_loaded_room

interarea_exit_right:
	; player enters from the right
	push hl
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop hl
	; adjust x, y coordinates, based on the chunk we are going to:
	ld a, (current_room__y)
	add a, a
	dec hl
	sub (hl)  ; target y in chunks
	neg
	; target y is now: a * 12 + 8 (which is where the ladder connecting the two areas will be)
	add a, a  ; * 2
	add a, a  ; * 4
	ld c, a
	add a, a  ; * 8
	add a, c  ; * 12
	add a, 8
	ld (player_y + 1), a
	ld a, (current_room__width)
	dec a
	ld (player_x + 1), a
	xor a
	ld (player_y), a
	ld (player_x), a
	ld a, PLAYER_STATE_IDLE + 1  ; looking left
	ld (player_state), a
	jp state_play_from_loaded_room
