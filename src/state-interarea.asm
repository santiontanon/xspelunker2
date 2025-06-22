;-----------------------------------------------
area_names:
	dw TEXT_AREA0_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA1_NAME, CHRTBL2 + (10*32 + 6) * 8
	dw TEXT_AREA2_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA3_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA4_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA5_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA6_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA7_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA8_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA9_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA10_NAME, CHRTBL2 + (10*32 + 10) * 8
	dw TEXT_AREA11_NAME, CHRTBL2 + (10*32 + 10) * 8


;-----------------------------------------------
; input:
; - e: target area ID
; - hl: ptr to room x, room y, direction of entrance
interarea_exit:
	call interarea_exit_screen

	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

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


;-----------------------------------------------
interarea_exit_screen:
	ld a, (current_megarom_page_in_8000)
	push af
		ld a, e
		push hl
			push af
				; clear the screen:
				call clear_screen_left_to_right
				call set_bitmap_mode
			pop af
			push af
				ld hl, area_names
				add a, a
				add a, a
				ADD_HL_A
				ld e, (hl)
				inc hl
				ld d, (hl)  ; de: name of the area we are entering
				inc hl
				ld c, (hl)
				inc hl
				ld b, (hl)  ; bc: name table position where to render (since each require a different centering position)
				push bc

					SETMEGAROMPAGE_8000 TEXT_PAGE

					; print "entering [area name]":
					ld ix, TEXT_ENTERING
					call text_concatenate_strings
				pop de  ; position to render text

				ld hl, buffer_4096
				ld iy, #80f0
				ld b, 20
				call draw_sentence_to_vdp_clearing_text_buffer

				ld hl, TEXT_LOADING_AREA
				ld de, CHRTBL2 + (16*32 + 10)*8
				ld iy, #80f0
				ld b, 16
				call draw_sentence_to_vdp_clearing_text_buffer
			pop af
		pop hl
		push hl
			; generate new area:
			ld hl, pcg_generate_area
			ld e, a  ; area to generate
			ld c, PCG_PAGE
			call call_hl_in_page_c_8000

			xor a
			ld hl, NAMTBL2 + 16*32 + 8
			ld bc, 20
			call fast_FILVRM		

			ld b, 250
			call wait_b_halts_skippable

			call clear_screen_left_to_right
		pop hl
	pop af
	SETMEGAROMPAGE_8000_A  ; restore the page
	ret
