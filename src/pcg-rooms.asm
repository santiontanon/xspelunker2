;-----------------------------------------------
; This method fills in the "current_room" data structure by generating a room
; using the information in "current_area". 
; input:
; - e: room ID
pcg_generate_room:
	ld a, e
	ld (current_room__id), a

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
	add a, a
	add a, a
	add a, a
	ld d, a
	add a, a
	add a, d  ; a * 24
	ld (current_room__height), a
	sub 24
	ld (current_room__max_scroll_y), a

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
	call random
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


	ld b, iyh
	rl b
	ld c, iyl
	rl c
pcg_generate_room__fg_loop_y:
	push bc
	push hl
pcg_generate_room__fg_loop_x:
		ld a, (hl)
		push hl
			ld hl, pyramid_chunk_fg_bank_ptrs
			push bc
			push iy
				call pcg_get_chunk_ptr
			pop iy
			pop bc
			push bc
				; - hl: ptr to chunk
				; - iyl/iyh: room width/height in screens.
				; - c/b: x, y coordinates where to add this chunk in the current room.			
				call pcg_generate_room_copy_chunk_to_room
			pop bc
		pop hl
		inc hl
		dec c
		jr nz, pcg_generate_room__fg_loop_x
	pop hl
	ld a, (current_area__width)
	add a, a  ; next row
	ADD_HL_A
	pop bc
	djnz pcg_generate_room__fg_loop_y

	; Auto-fill ladders/ropes/etc. and randomize tiles:
	call pcg_generate_room__prettyfy_pyramid

	; Identify animations and create the list of animations automatically:
	ld hl, current_room__tile_animations
	ld bc, 4 * MAX_ROOM_ANIMATIONS  ; we do not "-1" here, to clear the sentinel "0" afterwards too
	call clear_memory

	jp pcg_generate_room__find_animations_pyramid
; 	ret


;-----------------------------------------------
; This method:
; - completes ropes, ladders, dragon/face blocks
; - randomizes brick tiles
pcg_generate_room__prettyfy_pyramid:
	; Part 1: reconstruct ropes/ladders/faces/dragon:
	ld hl, current_room__tile_map
	ld bc, (current_room__width)
pcg_generate_room__prettyfy_pyramid_loop_y:
	push bc
pcg_generate_room__prettyfy_pyramid_loop_x:
		push bc
			ld a, (hl)
			; ropes:
			cp 8*16 + 5
			jp z, pcg_generate_room__prettyfy_pyramid_rope
			; ladders:
			cp 10*16 + 6
			jp z, pcg_generate_room__prettyfy_pyramid_ladder
			; face 1:
			cp 12*16 + 0
			jp z, pcg_generate_room__prettyfy_pyramid_face1
			; face 2:
			cp 13*16 + 8
			jp z, pcg_generate_room__prettyfy_pyramid_face2
			; dragon head:
			cp 12*16 + 12
			jp z, pcg_generate_room__prettyfy_pyramid_dragon_head
pcg_generate_room__prettyfy_pyramid_loop_x_continue:
			inc hl
		pop bc
		dec c
		jp nz, pcg_generate_room__prettyfy_pyramid_loop_x
	pop bc
	djnz pcg_generate_room__prettyfy_pyramid_loop_y

	; Part 2: randomize tiles:
	ld hl, current_room__tile_map
	ld bc, (current_room__width)
pcg_generate_room__prettyfy_pyramid_loop2_y:
	push bc
pcg_generate_room__prettyfy_pyramid_loop2_x:
		push bc
			ld a, (hl)
			; ropes:
			cp 8*16 + 6
			jp z, pcg_generate_room__prettyfy_pyramid_rope_randomize
			; spikes:
			cp 7*16 + 12
			jp z, pcg_generate_room__prettyfy_pyramid_spike_tip_randomize
			cp 7*16 + 14
			jp z, pcg_generate_room__prettyfy_pyramid_spike_bottom_randomize
			cp 8*16 + 8
			jp z, pcg_generate_room__prettyfy_pyramid_platform_randomize
			cp 9*16 + 13
			jp z, pcg_generate_room__prettyfy_pyramid_thin_bricks_randomize
			cp 10*16 + 0
			jp z, pcg_generate_room__prettyfy_pyramid_rubble_randomize
			cp 9*16 + 5
			jp z, pcg_generate_room__prettyfy_pyramid_bricks_randomize

pcg_generate_room__prettyfy_pyramid_loop2_x_continue:
			inc hl
		pop bc
		dec c
		jp nz, pcg_generate_room__prettyfy_pyramid_loop2_x
	pop bc
	djnz pcg_generate_room__prettyfy_pyramid_loop2_y	
	ret

pcg_generate_room__prettyfy_pyramid_rope:
	push hl
		ld a, (current_room__width)
		ld e, a
		ld d, 0
		ld bc, current_room__tile_map
pcg_generate_room__prettyfy_pyramid_rope_loop:
		or a
		sbc hl, de  ; go one row up
		or a
		sbc hl, bc  ; check if we are out of the map
		jr c, pcg_generate_room__prettyfy_pyramid_rope_done
		add hl, bc
		ld a, (hl)
		or a
		jr z, pcg_generate_room__prettyfy_pyramid_rope_keep_going
		cp 5*16 + 8  ; torch
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		and #f0
		cp #60  ; row 6 contains tiles only present on background tiles
		jr nz, pcg_generate_room__prettyfy_pyramid_rope_done
pcg_generate_room__prettyfy_pyramid_rope_keep_going:
		ld (hl), 8*16 + 6  ; rope
		jr pcg_generate_room__prettyfy_pyramid_rope_loop
pcg_generate_room__prettyfy_pyramid_rope_done:
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_ladder:
	push hl
		ld a, (current_room__width)
		ld e, a
		ld d, 0
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
		cp 5*16 + 8  ; torch
		jr z, pcg_generate_room__prettyfy_pyramid_ladder_keep_going
		and #f0
		cp #60  ; row 6 contains tiles only present on background tiles
		jr nz, pcg_generate_room__prettyfy_pyramid_ladder_done
pcg_generate_room__prettyfy_pyramid_ladder_keep_going:
		ld (hl), 10*16 + 6  ; ladder-left
		inc hl
		ld (hl), 10*16 + 7  ; ladder-right
		dec hl
		jr pcg_generate_room__prettyfy_pyramid_ladder_loop
pcg_generate_room__prettyfy_pyramid_ladder_done:
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_face1:
	push hl
		inc hl
		ld (hl), 12*16 + 1
		inc hl
		ld (hl), 12*16 + 2
		ld a, (current_room__width)
		add a, -2
		ld e, a
		ld d, 0
		add hl, de
		ld (hl), 13*16 + 0
		inc hl
		ld (hl), 13*16 + 1
		inc hl
		ld (hl), 13*16 + 2
		add hl, de
		ld (hl), 14*16 + 0
		inc hl
		ld (hl), 14*16 + 1
		inc hl
		ld (hl), 14*16 + 2
		add hl, de
		ld (hl), 15*16 + 0
		inc hl
		ld (hl), 15*16 + 1
		inc hl
		ld (hl), 15*16 + 2
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_face2:
	push hl
		inc hl
		ld (hl), 13*16 + 9
		inc hl
		ld (hl), 13*16 + 10
		inc hl
		ld (hl), 13*16 + 11
		ld a, (current_room__width)
		add a, -3
		ld e, a
		ld d, 0
		add hl, de
		ld (hl), 14*16 + 8
		inc hl
		ld (hl), 14*16 + 9
		inc hl
		ld (hl), 14*16 + 10
		inc hl
		ld (hl), 14*16 + 11
		add hl, de
		ld (hl), 15*16 + 8
		inc hl
		ld (hl), 15*16 + 9
		inc hl
		ld (hl), 15*16 + 10
		inc hl
		ld (hl), 15*16 + 11
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_dragon_head:
	push hl
		inc hl
		ld (hl), 12*16 + 13
		inc hl
		ld (hl), 12*16 + 14
		inc hl
		ld (hl), 12*16 + 15
		ld a, (current_room__width)
		add a, -3
		ld e, a
		ld d, 0
		add hl, de
		ld (hl), 13*16 + 12
		inc hl
		ld (hl), 13*16 + 13
		inc hl
		ld (hl), 13*16 + 14
		inc hl
		ld (hl), 13*16 + 15
		add hl, de
		ld (hl), 14*16 + 12
		inc hl
		ld (hl), 14*16 + 13
		inc hl
		ld (hl), 14*16 + 14
		inc hl
		ld (hl), 14*16 + 15
	pop hl
	jp pcg_generate_room__prettyfy_pyramid_loop_x_continue

pcg_generate_room__prettyfy_pyramid_rope_randomize:
	call random_a
	and #03
	jp nz, pcg_generate_room__prettyfy_pyramid_loop2_x_continue
	ld (hl), 8*16 + 4
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue

pcg_generate_room__prettyfy_pyramid_spike_tip_randomize:
	call random_a
	and #01
	add a, 7*16 + 12
	ld (hl), a
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue

pcg_generate_room__prettyfy_pyramid_spike_bottom_randomize:
	call random_a
	and #01
	add a, 7*16 + 14
	ld (hl), a
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue

pcg_generate_room__prettyfy_pyramid_platform_randomize:
	call random_a
	and #01
	add a, 8*16 + 8
	ld (hl), a
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue

pcg_generate_room__prettyfy_pyramid_thin_bricks_randomize:
	call random_a
	and #03
	cp 3
	jr nz, pcg_generate_room__prettyfy_pyramid_thin_bricks_randomize_continue
	ld a, 2
pcg_generate_room__prettyfy_pyramid_thin_bricks_randomize_continue:
	add a, 9*16 + 13
	ld (hl), a
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue

pcg_generate_room__prettyfy_pyramid_rubble_randomize:
	call random_a
	and #03
	add a, 10*16 + 0
	ld (hl), a
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue


pcg_generate_room__prettyfy_pyramid_bricks_randomize:
	ld a, (current_room__width)
	ld e, a
	ld d, 0
	call random_a
	and #07
	cp 3
	jr nc, pcg_generate_room__prettyfy_pyramid_bricks_randomize_continue
	; ld (hl), 9*16 + 5
	add hl, de
	ld (hl), 9*16 + 8
	or a
	sbc hl, de
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue
pcg_generate_room__prettyfy_pyramid_bricks_randomize_continue:
	cp 5
	jr nc, pcg_generate_room__prettyfy_pyramid_bricks_randomize_continue2
	ld (hl), 9*16 + 6
	add hl, de
	ld (hl), 9*16 + 8
	or a
	sbc hl, de
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue
pcg_generate_room__prettyfy_pyramid_bricks_randomize_continue2:
	ld (hl), 9*16 + 11
	add hl, de
	ld (hl), 9*16 + 7
	or a
	sbc hl, de
	jp pcg_generate_room__prettyfy_pyramid_loop2_x_continue


;-----------------------------------------------
pcg_generate_room__find_animations_pyramid:
	ld iyl, 0  ; number of animations found so far
	ld hl, current_room__tile_map
	ld ix, current_room__tile_animations
	ld bc, (current_room__width)
pcg_generate_room__find_animations_pyramid_loop_y:
	push bc
pcg_generate_room__find_animations_pyramid_loop_x:
		ld a, (hl)
		inc hl
		cp 6*16 + 2
		jp z, pcg_generate_room__find_animations_pyramid_torch
		cp 6*16 + 3
		jp z, pcg_generate_room__find_animations_pyramid_torch
		cp 6*16 + 4
		jp z, pcg_generate_room__find_animations_pyramid_torch
		cp 6*16 + 4
		jp z, pcg_generate_room__find_animations_pyramid_torch

		cp 8*16 + 1
		jp z, pcg_generate_room__find_animations_pyramid_water
		cp 8*16 + 2
		jp z, pcg_generate_room__find_animations_pyramid_water
		cp 8*16 + 3
		jp z, pcg_generate_room__find_animations_pyramid_water
		cp 200
		jp z, pcg_generate_room__find_animations_pyramid_water
pcg_generate_room__find_animations_pyramid_loop_x_continue:
		; check if we have reached the maximum number of animations:
		ld a, iyl
		cp MAX_ROOM_ANIMATIONS
		ret z
		dec c
		jr nz, pcg_generate_room__find_animations_pyramid_loop_x
	pop bc
	djnz pcg_generate_room__find_animations_pyramid_loop_y
	ret

pcg_generate_room__find_animations_pyramid_torch:
	ld (ix), 1  ; animation_type = 1
	ld a, (current_room__width)
	sub c
	ld (ix + 1), a
	ld a, (current_room__height)
	sub b
	ld (ix + 2), a
	ld (ix + 3), 1  ; torches always have width 1
	inc ix
	inc ix
	inc ix
	inc ix
	inc iyl
	jp pcg_generate_room__find_animations_pyramid_loop_x_continue

pcg_generate_room__find_animations_pyramid_water:
	ld (ix), 2  ; animation_type = 2
	ld a, (current_room__width)
	sub c
	ld (ix + 1), a
	ld a, (current_room__height)
	sub b
	ld (ix + 2), a
	ld (ix + 3), 1

	; see if we want to merge this animation with the previous water one:
	ld a, iyl
	or a
	jr z, pcg_generate_room__find_animations_pyramid_water_skip_merge
	ld a, (ix - 4)
	cp 2  ; was the previous animation also water?
	jr nz, pcg_generate_room__find_animations_pyramid_water_skip_merge
	ld a, (ix + 2)
	cp (ix - 2)
	jr nz, pcg_generate_room__find_animations_pyramid_water_skip_merge
	ld a, (ix - 3)
	add a, (ix - 1)
	cp (ix + 1)
	jr nz, pcg_generate_room__find_animations_pyramid_water_skip_merge
	; contiguous animation, merge them:
	inc (ix - 1)
	jp pcg_generate_room__find_animations_pyramid_loop_x_continue
pcg_generate_room__find_animations_pyramid_water_skip_merge:
	inc ix
	inc ix
	inc ix
	inc ix
	jp pcg_generate_room__find_animations_pyramid_loop_x_continue


;-----------------------------------------------
; input:
; - hl: ptr to the fg chunk types
pcg_generate_room_background_pyramid:
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
			call pcg_generate_room_copy_chunk_to_room
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
		ld a, (hl)
		ld hl, pyramid_chunk_flags
		add a, a
		ADD_HL_A
		ld a, (hl)
	pop hl
	ret


;-----------------------------------------------
; This method only copies those tiles that are != 0.
; input:
; - hl: ptr to chunk
; - iyl/iyh: room width/height in screens.
; - c/b: x, y coordinates where to add this chunk in the current room.
pcg_generate_room_copy_chunk_to_room:
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
		jr pcg_generate_room_copy_chunk_to_room_loop1
pcg_generate_room_copy_chunk_to_room_continue:
		; hl = ((iyh*2 - b) * iyl
		add hl, hl
		add hl, hl
		add hl, hl
		add hl, hl
		add hl, hl  ; hl = ((iyh*2 - b) * iyl * 32

		add hl, hl
		add hl, hl
		push hl
			add hl, hl
		pop de
		add hl, de  ; * 12

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
	ld b, CHUNK_HEIGHT
	ld c, CHUNK_WIDTH
pcg_generate_room_copy_chunk_to_room_loop_y:
	push bc
		push de
pcg_generate_room_copy_chunk_to_room_loop_x:
			ld a, (hl)
			or a
			jr z, pcg_generate_room_copy_chunk_to_room_loop_x_skip
			ld (de), a
pcg_generate_room_copy_chunk_to_room_loop_x_skip:
			inc hl
			inc de
			dec c
			jr nz, pcg_generate_room_copy_chunk_to_room_loop_x
		pop de
		ld a, (current_room__width)
		ld b, 0
		ld c, a
		ex de, hl
			add hl, bc
		ex de, hl
	pop bc
	djnz pcg_generate_room_copy_chunk_to_room_loop_y
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
		ADD_HL_A
		ld e, (hl)
		inc hl
		ld h, (hl)
		ld l, e
		ld c, CHUNKS_PYRAMID_PAGE
		ld de, buffer_4096
		call dzx0_from_page_c
	pop af
	; hl = buffer_4096 + a * CHUNK_SIZE
	ld hl, buffer_4096
	and #0f
	ret z
	ld bc, CHUNK_SIZE
pcg_get_chunk_ptr_loop:
	add hl, bc
	dec a
	jr nz, pcg_get_chunk_ptr_loop
	ret


;-----------------------------------------------
pyramid_chunk_flags:
	include "autogenerated/pyramid-chunk-tags.asm"

