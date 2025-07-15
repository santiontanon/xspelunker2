tmp_pcg_world__floodfill_open_list: equ buffer_4096  ; 256 bytes (should be 256-aligned)
tmp_pcg_world__floodfill_open_list_bot: equ buffer_4096 + 256  ; w bytes
tmp_pcg_world__floodfill_open_list_top: equ tmp_pcg_world__floodfill_open_list_bot + 2  ; 2 bytes
tmp_pcg_world__tmp_ptr: equ tmp_pcg_world__floodfill_open_list_top + 2  ; 2 bytes
tmp_pcg_world__tags: equ tmp_pcg_world__tmp_ptr + 2  ; MAX_AREA_SIZE * MAX_WORLD_AREAS * 2 bytes  ; tags for all areas, at most 2 tags per room

pcg_generate_world_tmp_a0p1: equ tmp_pcg_world__tags + MAX_AREA_SIZE * MAX_WORLD_AREAS * 2
pcg_generate_world_tmp_a0p2: equ pcg_generate_world_tmp_a0p1 + 2
pcg_generate_world_tmp_a1p1: equ pcg_generate_world_tmp_a0p2 + 2
pcg_generate_world_tmp_a1p2: equ pcg_generate_world_tmp_a1p1 + 2
pcg_generate_world_tmp_a2p1: equ pcg_generate_world_tmp_a1p2 + 2
pcg_generate_world_tmp_a2p2: equ pcg_generate_world_tmp_a2p1 + 2

tmp_pcg_world__candidates_list: equ tmp_pcg_world__floodfill_open_list
tmp_pcg_world__candidates_list_size: equ tmp_pcg_world__candidates_list + 256

tmp_pcg_world__area_0_connections: equ current_world__area_data + 4 + 1 + 1 + 1
tmp_pcg_world__area_0_divisions: equ tmp_pcg_world__area_0_connections + MAX_AREA_SIZE
tmp_pcg_world__area_0_tags: equ tmp_pcg_world__area_0_divisions + MAX_AREA_SIZE
tmp_pcg_world__area_11_divisions: equ current_world__area_data + 4 + 1 + 1 + 1 + MAX_AREA_SIZE + WORLD_AREA__SIZE*11


;-----------------------------------------------
pcg__area_sizes:
	db 8, 2
	db 8, 8
	db 8, 8
	db 9, 3
	db 8, 8
	db 3, 3
	db 6, 8
	db 6, 8
	db 8, 8
	db 8, 8
	db 8, 8
	db 8, 8

; 0: follow layout exactly if provided
; 1: follow layout approximately
pcg__area_layout_fidelity:
	db 1
	db 1
	db 1
	db 0
	db 1
	db 0
	db 1
	db 1
	db 1
	db 1
	db 1
	db 1

pcg__area_layout_ptrs:
	dw pcg__full_layout
	dw pcg__temple_inscriptions_layout
	dw pcg__hidden_temple_layout
	dw pcg__confluence_layout
	dw pcg__inverted_pyramid_layout
	dw pcg__fireshaft_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout
	dw pcg__full_layout

pcg__temple_inscriptions_layout:
pcg__hidden_temple_layout:
	db 0, 0, 0, 1, 1, 0, 0, 0
	db 0, 0, 0, 1, 1, 0, 0, 0
	db 0, 0, 1, 1, 1, 1, 0, 0
	db 0, 0, 1, 1, 1, 1, 0, 0
	db 0, 1, 1, 1, 1, 1, 1, 0
	db 0, 1, 1, 1, 1, 1, 1, 0
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1

pcg__confluence_layout:
	db 1, 0, 0, 1, 1, 1, 0, 0, 1
	db 1, 1, 1, 1, 1, 1, 1, 1, 1
	db 0, 0, 0, 0, 1, 0, 0, 0, 0

pcg__inverted_pyramid_layout:
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 0, 1, 1, 1, 1, 1, 1, 0
	db 0, 1, 1, 1, 1, 1, 1, 0
	db 0, 0, 1, 1, 1, 1, 0, 0
	db 0, 0, 1, 1, 1, 1, 0, 0
	db 0, 0, 0, 1, 1, 0, 0, 0
	db 0, 0, 0, 1, 1, 0, 0, 0

pcg__fireshaft_layout:
	db 0, 1, 0
	db 1, 1, 1
	db 0, 1, 0

pcg__full_layout:  ; for those areas for which we do not want to have a predefined layout:
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1
	db 1, 1, 1, 1, 1, 1, 1, 1

pgc__n_divisions_per_area:
	db  6, 12, 12,  3
	db 12,  3, 12, 12
	db 12, 12, 12, 12  ; 120 + 2 divisions (+ 2 since there are 2 hardcoded divisions in the confluence)


;-----------------------------------------------
; input:
pcg_generate_world:
	ld hl, current_world__seed
	ld de, rng_seed1
	ldi
	ldi
	ldi
	ldi

;     out (#2c),a  ; DEBUG	
	call pcg_generate_world__init
	call pcg_generate_world__generate_area_layouts  ; uses the connections space to store the layout
	call pcg_generate_world__generate_divisions  ; fills divisionIDs 
	call pcg_generate_world__generate_area_connections  ; fills current_world__interarea_connections
	jr nz, pcg_generate_world_fail
	call pcg_generate_world__generate_spanning_tree  ; generates connections (each tree root to its parent)
	call pcg_generate_world__generate_mission  ; adds all the area tags to the divisions
	call pcg_generate_world__spawn_additional_objects  ; fills additional tags to some divisions
	call pcg_generate_world__generate_tag_data  ; generates the area tags, chest content and shop extra items from all the info above
;     out (#2d),a  ; DEBUG	

	; DEBUG:
; 	ld hl, hardcoded_area_data_0__divisionIDs
; 	ld de, tmp_pcg_world__area_0_divisions
; 	ld bc, MAX_AREA_SIZE
; 	call pcg_debug__arrays_equal
; 	ld hl, hardcoded_area_data_11__divisionIDs
; 	ld de, tmp_pcg_world__area_11_divisions
; 	ld bc, MAX_AREA_SIZE
; 	call pcg_debug__arrays_equal

	; for now just copy over the hardcoded data:
; 	ld hl, hardcoded_world_data
; 	ld de, current_world__area_data
; 	ld bc, hardcoded_world_data_end - hardcoded_world_data
; 	ldir

	jp pcg_generate_world__puzzles  ; tablet contents, combination puzzles, trial types, stone numbers 

pcg_generate_world_fail:
	di
	halt


; pcg_debug__arrays_equal:
; 	ld a, (de)
; 	cp (hl)
; 	jr nz, pcg_debug__arrays_equal_fail
; 	inc de
; 	inc hl
; 	dec bc
; 	ld a, c
; 	or b
; 	ret z
; 	jr pcg_debug__arrays_equal


; pcg_debug__arrays_equal_fail:
; 	di
; 	halt



;-----------------------------------------------
pcg_generate_world__init:
	; random seed:
	ld hl, rng_seed1
	ld de, current_world__seed
	ldi
	ldi
	ldi
	ldi
	ret


;-----------------------------------------------
; each world area is:
; - seed: 4 bytes
; - id: 1 byte
; - width, height: 1 + 1 bytes
; - connections: MAX_AREA_SIZE bytes
; - divisionIDs: MAX_AREA_SIZE bytes
; - tags: MAX_AREA_N_TAGS * 3
; This method fills:
; - seed, id, width, height
; - uses the connections space to store the layout (which will later be overwritten).
pcg_generate_world__generate_area_layouts:
	ld b, MAX_WORLD_AREAS
	ld de, current_world__area_data
pcg_generate_world__generate_area_layouts_loop:
	push bc
		push de
			ld ixl, e
			ld ixh, d  ; save the ptr to the current area in 'ix' for later use.

			; fill: seed, ID, width, height
			ld a, b
			sub MAX_WORLD_AREAS
			neg  ; a = area ID

			ld hl, rng_seed1
			ldi
			ldi
			ldi
			ldi

			ld (de), a  ; ID
			inc de

			ld hl, pcg__area_sizes
			add a, a
			ADD_HL_A
			ldi  ; width
			ldi  ; height

			; fill the layout in the "connections" space in "current_world__area_data"
			ld c, (ix + 4 + 1)  ; width
			ld b, (ix + 4 + 2)  ; height

			ld hl, pcg__area_layout_ptrs
			ld a, (ix + 4)  ; ID
			add a, a
			ADD_HL_A
			ld a, (hl)
			inc hl
			ld h, (hl)
			ld l, a

			push hl
				ld hl, pcg__area_layout_fidelity
				ld a, (ix + 4)  ; ID
				ADD_HL_A
				ld a, (hl)  ; fidelity
			pop hl
; 		    out (#2c),a  ; DEBUG	
			call pcg_generate_world__generate_area_layout
;     		out (#2d),a  ; DEBUG	
		pop hl
		ld bc, WORLD_AREA__SIZE
		add hl, bc
		ex de, hl
	pop bc
	djnz pcg_generate_world__generate_area_layouts_loop
	ret


;-----------------------------------------------
; input:
; - c, b: width, height
; - de: ptr to generate the layout to
; - hl: ptr to predefined layout
; - a: layout fidelity (0: copy, 1: approximate)
pcg_generate_world__generate_area_layout:
	; init to all #ff:
	push af
	push hl
	push de
	push bc
		ex de, hl
		ld bc, MAX_AREA_SIZE - 1
		ld a, #ff
		call clear_memory_a
	pop bc
	pop de
	pop hl
	pop af

	or a
	jr nz, pcg_generate_world__generate_area_layout_from_scratch
pcg_generate_world__generate_area_layout_copy:
	; copy the provided layout:
	ld iyl, 0  ; next room ID
pcg_generate_world__generate_area_layout_copy_y_loop:
	push bc
		ld b, c
pcg_generate_world__generate_area_layout_copy_x_loop:
		ld a, (hl)
		or a
		jr z, pcg_generate_world__generate_area_layout_copy_next
		; room:
		ld a, iyl
		inc iyl
		ld (de), a
pcg_generate_world__generate_area_layout_copy_next:
		inc hl
		inc de
		djnz pcg_generate_world__generate_area_layout_copy_x_loop
	pop bc
	djnz pcg_generate_world__generate_area_layout_copy_y_loop
	ret

pcg_generate_world__generate_area_layout_from_scratch:
	ld (tmp_pcg_world__tmp_ptr), hl  ; hl has a pointer to the reference layout
	ld iyl, 1  ; number of rooms
	ld ixl, c
	ld ixh, b  ; move width, height to ix, to leave bc free

	; compute how many rooms do we want:
	xor a
	srl b  ; b /= 2
	push bc
pcg_generate_world__generate_area_layout_from_scratch_loop1:
		add a, c
		djnz pcg_generate_world__generate_area_layout_from_scratch_loop1
		dec a  ; one less, since we already start with one
		ld iyh, a  ; target number of rooms
	pop bc

	srl c  ; c /= 2
	xor a
	call pcg_generate_world__generate_area_layout_set_room  ; set the first room in the middle of the map
pcg_generate_world__generate_area_layout_from_scratch_loop2:
	; c, b: random position in the map:
	ld c, ixh
	call random_modulo
	ld b, a
	ld c, ixl
	call random_modulo
	ld c, a
	call pcg_generate_world__layout_offset_from_c_b_ixl
	ld l, a
	ld h, 0
	add hl, de
	ld a, (hl)
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2
	; check if there is a room to the left:
	ld a, c
	or a
	jr z, pcg_generate_world__generate_area_layout_from_scratch_loop2_continue1  ; left-edge
	dec hl
	ld a, (hl)
	inc hl
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room
pcg_generate_world__generate_area_layout_from_scratch_loop2_continue1:
	; check if there is a room to the right:
	ld a, c
	inc a
	cp ixl
	jr z, pcg_generate_world__generate_area_layout_from_scratch_loop2_continue2  ; right-edge
	inc hl
	ld a, (hl)
	dec hl
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room	
pcg_generate_world__generate_area_layout_from_scratch_loop2_continue2:
	; check if there is a room above:
	ld a, b
	or a
	jr z, pcg_generate_world__generate_area_layout_from_scratch_loop2_continue3  ; top-edge
	push bc
		ld c, ixl
		ld b, 0
		or a
		sbc hl, bc
		ld a, (hl)
		add hl, bc
	pop bc
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room
pcg_generate_world__generate_area_layout_from_scratch_loop2_continue3:
	; check if there is a room below:
	ld a, b
	inc a
	cp ixh
	jr z, pcg_generate_world__generate_area_layout_from_scratch_loop2_continue4  ; bottom-edge
	push bc
		ld c, ixl
		ld b, 0
		add hl, bc
		ld a, (hl)
		or a
		sbc hl, bc
	pop bc
	cp #ff
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room
pcg_generate_world__generate_area_layout_from_scratch_loop2_continue4:
	jr pcg_generate_world__generate_area_layout_from_scratch_loop2
pcg_generate_world__generate_area_layout_from_scratch_loop2_maybe_add_room:
	; have a chance to reject the room if it does not follow the provided layout pattern:
	push bc
		or a  
		sbc hl, de
		ld bc, (tmp_pcg_world__tmp_ptr)
		add hl, bc  ; hl: ptr to the layout pattern
		ld a, (hl)
		or a
	pop bc
	jr nz, pcg_generate_world__generate_area_layout_from_scratch_loop2_add_room
	call random_a
	cp 243  ; acceptance threshold
	jr c, pcg_generate_world__generate_area_layout_from_scratch_loop2
pcg_generate_world__generate_area_layout_from_scratch_loop2_add_room:
	ld a, iyl
	call pcg_generate_world__generate_area_layout_set_room
	inc iyl
	dec iyh
	jp nz, pcg_generate_world__generate_area_layout_from_scratch_loop2
	ret


;-----------------------------------------------
; [de + c + b*ixl] = a
; input:
; - a: room ID
; - c, b: x, y, coordinates
; - ixl: width
; - de: ptr to map layout we are creating
pcg_generate_world__generate_area_layout_set_room:
	push af
		call pcg_generate_world__layout_offset_from_c_b_ixl
		ld l, a
		ld h, 0
		add hl, de
	pop af
	ld (hl), a
	ret


;-----------------------------------------------
pcg_generate_world__generate_divisions:
	; Initialize the division buffers to all 0s for places with rooms, and #ff for places without rooms:
	ld b, MAX_WORLD_AREAS
	ld hl, tmp_pcg_world__area_0_divisions
	ld de, tmp_pcg_world__area_0_connections  ; currently contains the room IDs
pcg_generate_world__generate_divisions_init_loop:
	push bc
		push hl
			push de
				ld b, MAX_AREA_SIZE
pcg_generate_world__generate_divisions_init_loop2:
				ld a, (de)
				cp #ff  ; if there is no room (#ff), write a #ff, otherwise, write a 0
				jr z, pcg_generate_world__generate_divisions_init_loop2_a_set
				xor a
pcg_generate_world__generate_divisions_init_loop2_a_set:
				ld (hl), a
				inc hl
				inc de
				djnz pcg_generate_world__generate_divisions_init_loop2
			pop hl
			ld bc, WORLD_AREA__SIZE
			add hl, bc
			ex de, hl
		pop hl
		add hl, bc
	pop bc
	djnz pcg_generate_world__generate_divisions_init_loop

	; Hardcoded divisions (confluence):
	ld hl, tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE * 3 + 3
	ld (hl), 1
	inc hl
	ld (hl), 1
	inc hl
	ld (hl), 1
	ld hl, tmp_pcg_world__area_0_divisions + WORLD_AREA__SIZE * 3 + 3 + 9
	ld (hl), 2
	inc hl
	ld (hl), 2
	inc hl
	ld (hl), 2

	ld iyl, 3  ; next division ID

	ld b, MAX_WORLD_AREAS
	ld hl, pgc__n_divisions_per_area
	ld ix, current_world__area_data
pcg_generate_world__generate_divisions_loop:
	push bc  ; mdl-watch: 'pcg_generate_world__generate_divisions_loop'
	push hl
		ld c, (ix + 4 + 1)  ; width
		ld b, (ix + 4 + 2)  ; height

		; size of the area in bytes: a = c * b
		xor a
pcg_generate_world__generate_divisions_loop_size_loop:
		add a, c
		djnz pcg_generate_world__generate_divisions_loop_size_loop
		ld c, a
		ld b, (hl)  ; b = target number of divisions in this area

		push bc
			push ix
			pop hl
			ld bc, 4 + 1 + 1 + 1 + MAX_AREA_SIZE
			add hl, bc  ; hl = ptr to the divisions
		pop bc

		; b: number of divisions to generate
		; c: area size
pcg_generate_world__generate_divisions_loop2:
		call random_modulo
		push hl  ; mdl-watch: 'division rng:', a
			ADD_HL_A
			ld a, (hl)
			or a
			jr nz, pcg_generate_world__generate_divisions_loop2_next
			ld a, iyl  ; mdl-watch: '  saving division', a
			ld (hl), a
			inc iyl
			dec b
pcg_generate_world__generate_divisions_loop2_next:
		pop hl
		ld a, b
		or a
		jr nz, pcg_generate_world__generate_divisions_loop2

		; flood fill:
		call pcg_generate_world__area_division_floodfill

		ld bc, WORLD_AREA__SIZE
		add ix, bc
	pop hl
	pop bc
	inc hl
	djnz pcg_generate_world__generate_divisions_loop
	ret


;-----------------------------------------------
; input:
; - ix: ptr to the current area info
; - hl: ptr to the current divisions (ix + 4 + 1 + 1 + 1 + MAX_AREA_SIZE)
pcg_generate_world__area_division_floodfill:
	; create the open list:
	ld c, (ix + 4 + 1)  ; width
	ld b, (ix + 4 + 2)  ; height
	ld de, tmp_pcg_world__floodfill_open_list  ; 256-aligned
	ld (tmp_pcg_world__floodfill_open_list_bot), de
	ld (tmp_pcg_world__tmp_ptr), hl  ; storing the beginning of the divisions area
pcg_generate_world__area_division_floodfill_open_list_loop_y:
	push bc
pcg_generate_world__area_division_floodfill_open_list_loop_x:
		ld a, (hl)
		or a  ; no division
		jr z, pcg_generate_world__area_division_floodfill_open_list_loop_x_next
		cp #ff  ; no room
		jr z, pcg_generate_world__area_division_floodfill_open_list_loop_x_next
		; we have a division seed:
		ld a, c
		sub (ix + 4 + 1)
		neg
		ld (de), a  ; x
		inc de
		ld a, b
		sub (ix + 4 + 2)
		neg
		ld (de), a  ; y
		inc de
		push hl
		push bc
			ld bc, (tmp_pcg_world__tmp_ptr)
			or a
			sbc hl, bc
			ld a, l
			ld (de), a  ; offset
			inc de
		pop bc
		pop hl
pcg_generate_world__area_division_floodfill_open_list_loop_x_next:
		inc hl
		dec c
		jr nz, pcg_generate_world__area_division_floodfill_open_list_loop_x
	pop bc
	djnz pcg_generate_world__area_division_floodfill_open_list_loop_y
	ld (tmp_pcg_world__floodfill_open_list_top), de

	; fill while the open list is not empty:
	; - we only update "e", since "de" points to a circular list of size 256, and we want to rotate back to the beginning
pcg_generate_world__area_division_floodfill_loop:
	ld de, (tmp_pcg_world__floodfill_open_list_bot)  ; next element of the list
	ld a, (de)
	ld c, a  ; x
	inc e
	ld a, (de)
	ld b, a  ; y
	inc e
	; Here: c = x, b = y
	ld a, c
	or a  ; x == 0?
	jr z, pcg_generate_world__area_division_floodfill_loop_no_left
	; check left:
	ld hl, (tmp_pcg_world__tmp_ptr)
	ld a, (de)  ; offset
	ADD_HL_A
	ld a, (hl)
	ex af, af'  ; save the division ID in a'
	dec hl
	ld a, (hl)
	or a  ; do we have a division ID there already?
	jr nz, pcg_generate_world__area_division_floodfill_loop_no_left
	ex af, af'
	dec c
	call pcg_generate_world__area_division_floodfill_push
	inc c
pcg_generate_world__area_division_floodfill_loop_no_left:
	ld a, c
	inc a
	cp (ix + 4 + 1)  ; x == width - 1?
	jr z, pcg_generate_world__area_division_floodfill_loop_no_right
	; check right:
	ld hl, (tmp_pcg_world__tmp_ptr)
	ld a, (de)  ; offset
	ADD_HL_A
	ld a, (hl)
	ex af, af'  ; save the division ID in a'
	inc hl
	ld a, (hl)
	or a  ; do we have a division ID there already?
	jr nz, pcg_generate_world__area_division_floodfill_loop_no_right
	ex af, af'
	inc c
	call pcg_generate_world__area_division_floodfill_push
	dec c
pcg_generate_world__area_division_floodfill_loop_no_right:
	ld a, b
	or a  ; y == 0?
	jr z, pcg_generate_world__area_division_floodfill_loop_no_up
	; check up:
	ld hl, (tmp_pcg_world__tmp_ptr)
	ld a, (de)  ; offset
	ADD_HL_A
	ld a, (hl)
	ex af, af'  ; save the division ID in a'
	push bc
		ld b, 0
		ld c, (ix + 4 + 1)  ; width
		or a
		sbc hl, bc
	pop bc
	ld a, (hl)
	or a  ; do we have a division ID there already?
	jr nz, pcg_generate_world__area_division_floodfill_loop_no_up
	ex af, af'
	dec b
	call pcg_generate_world__area_division_floodfill_push
	inc b
pcg_generate_world__area_division_floodfill_loop_no_up:
	ld a, b
	inc a
	cp (ix + 4 + 2)  ; y == height - 1?
	jr z, pcg_generate_world__area_division_floodfill_loop_no_down
	; check down:
	ld hl, (tmp_pcg_world__tmp_ptr)
	ld a, (de)  ; offset
	ADD_HL_A
	ld a, (hl)
	ex af, af'  ; save the division ID in a'
	push bc
		ld b, 0
		ld c, (ix + 4 + 1)  ; width
		add hl, bc
	pop bc
	ld a, (hl)
	or a  ; do we have a division ID there already?
	jr nz, pcg_generate_world__area_division_floodfill_loop_no_down
	ex af, af'
	inc b
	call pcg_generate_world__area_division_floodfill_push
	dec b
pcg_generate_world__area_division_floodfill_loop_no_down:
	inc e
	ld (tmp_pcg_world__floodfill_open_list_bot), de

	; list empty?
	ld hl, (tmp_pcg_world__floodfill_open_list_top)
	or a
	sbc hl, de
	jp nz, pcg_generate_world__area_division_floodfill_loop
	ret


pcg_generate_world__area_division_floodfill_push:
	; hl: ptr to the division we are filling
	; de: ptr to the open list
	; c, b: x, y
	ld (hl), a  ; update the division ID
	push de
		ld de, (tmp_pcg_world__floodfill_open_list_top)
		ld a, c
		ld (de), a  ; x
		inc e
		ld a, b
		ld (de), a  ; y
		inc e
		push bc
			ld bc, (tmp_pcg_world__tmp_ptr)
			or a
			sbc hl, bc
		pop bc
		ld a, l
		ld (de), a  ; offset
		inc e
		ld (tmp_pcg_world__floodfill_open_list_top), de
	pop de
	ret


;-----------------------------------------------
; output:
; - z: success
; - nz: failure
pcg_generate_world__generate_area_connections:
	; clear all the tags, as we will use them to prevent replication of inter-area connections:
	ld hl, tmp_pcg_world__tags
	ld bc, MAX_AREA_SIZE * MAX_WORLD_AREAS * 2 - 1
	call clear_memory

	ld hl, current_world__interarea_connections
	ld (tmp_pcg_world__tmp_ptr), hl	

	; a0p1:
	xor a
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	xor a
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; a0p2:
	xor a
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p2), bc
	xor a
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; swap a0p1/a0p2 so that a0p1.x < a0p2.x:
	ld bc, (pcg_generate_world_tmp_a0p1)
	ld de, (pcg_generate_world_tmp_a0p2)
	ld a, c
	cp e
	jr c, pcg_generate_world__generate_area_connections_no_a0p1_a0p2_swap
	ld (pcg_generate_world_tmp_a0p1), de
	ld (pcg_generate_world_tmp_a0p2), bc
pcg_generate_world__generate_area_connections_no_a0p1_a0p2_swap:

	; a1p1:
	ld a, 1
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a1p1), bc
	ld a, 1
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; create jungle -> temple of inscriptions connection:
	ld bc, (pcg_generate_world_tmp_a0p1)
	ld de, (pcg_generate_world_tmp_a1p1)
	ld iyl, 0
	ld iyh, 1
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a2p1:
	ld a, 2
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a2p1), bc
	ld a, 2
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; create jungle -> hidden temple connection:
	ld bc, (pcg_generate_world_tmp_a0p2)
	ld de, (pcg_generate_world_tmp_a2p1)
	ld iyl, 0
	ld iyh, 2
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a1p2:
	ld a, 1
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a1p1), bc
	ld a, 1
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; a2p2:
	ld a, 2
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a2p1), bc
	ld a, 2
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag
	
	; temple of inscriptions connection -> confluence:
	ld bc, (pcg_generate_world_tmp_a1p1)
	ld de, #0000
	ld iyl, 1
	ld iyh, 3
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; hidden temple connection -> confluence:
	ld bc, (pcg_generate_world_tmp_a2p1)
	ld de, #0008
	ld iyl, 2
	ld iyh, 3
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a4p1:
	ld a, 4
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 4
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag
	
	; confluence -> inverted pyramid:
	ld bc, #0204
	ld de, (pcg_generate_world_tmp_a0p1)
	ld iyl, 3
	ld iyh, 4
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a4p2:
	ld a, 4
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p2), bc
	ld a, 4
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag
	
	; inverted pyramid -> fire shaft:
	ld bc, (pcg_generate_world_tmp_a0p2)
	ld de, #0001
	ld iyl, 4
	ld iyh, 5
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	; a6p1:
	ld a, 6
	call pcg_generate_world__random_right_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 6
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; fire shaft -> caves west:
	ld bc, #0100
	ld de, (pcg_generate_world_tmp_a0p1)
	ld iyl, 5
	ld iyh, 6
	ld ixl, PCG_DIRECTION_LEFT
	ld ixh, PCG_DIRECTION_RIGHT
	call pcg_generate_world__generate_area_connections_add_connection

	; a7p1:
	ld a, 7
	call pcg_generate_world__random_left_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 7
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; fire shaft -> caves west:
	ld bc, #0102
	ld de, (pcg_generate_world_tmp_a0p1)
	ld iyl, 5
	ld iyh, 7
	ld ixl, PCG_DIRECTION_RIGHT
	ld ixh, PCG_DIRECTION_LEFT
	call pcg_generate_world__generate_area_connections_add_connection
    
	; a8p1:
	ld a, 8
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 8
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; fire shaft -> caves west:
	ld bc, #0201
	ld de, (pcg_generate_world_tmp_a0p1)
	ld iyl, 5
	ld iyh, 8
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection    

	; a7p3:
	ld a, 7
	call pcg_generate_world__random_right_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a0p1), bc
	ld a, 7
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; a9p1:
	ld a, 9
	call pcg_generate_world__random_bottom_left_most_point
	ret nz
	ld (pcg_generate_world_tmp_a1p1), bc
	ld a, 9
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; caves east -> atlantis:
	ld bc, (pcg_generate_world_tmp_a0p1)
	ld de, (pcg_generate_world_tmp_a1p1)
	ld iyl, 7
	ld iyh, 9
	ld ixl, PCG_DIRECTION_RIGHT
	ld ixh, PCG_DIRECTION_LEFT
	call pcg_generate_world__generate_area_connections_add_connection    

	; a8p2:
	ld a, 8
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a1p2), bc
	ld a, 8
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	call random_a
	and #01
	jr nz, pcg_generate_world__generate_area_connections_connection_to_east_caves	
pcg_generate_world__generate_area_connections_connection_to_west_caves:
	; a6p2:
	ld a, 6
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a2p2), bc
	ld a, 6
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; caves west -> xibalba:
	ld bc, (pcg_generate_world_tmp_a2p2)
	ld de, (pcg_generate_world_tmp_a1p2)
	ld iyl, 6
	ld iyh, 8
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
	call pcg_generate_world__generate_area_connections_add_connection

	jr pcg_generate_world__generate_area_connections_connection_to_caves_done
pcg_generate_world__generate_area_connections_connection_to_east_caves:
	; a7p2:
	ld a, 7
	call pcg_generate_world__random_bottom_most_point_tagless
	ret nz
	ld (pcg_generate_world_tmp_a2p2), bc
	ld a, 7
	ld b, 1  ; just some random tag value
	call pcg_generate_world__add_tag

	; caves west -> xibalba:
	ld bc, (pcg_generate_world_tmp_a2p2)
	ld de, (pcg_generate_world_tmp_a1p2)
	ld iyl, 7
	ld iyh, 8
	ld ixl, PCG_DIRECTION_DOWN
	ld ixh, PCG_DIRECTION_UP
pcg_generate_world__generate_area_connections_connection_to_caves_done:

	ld hl, (tmp_pcg_world__tmp_ptr)
	ld (hl), #ff  ; sentinel

	; clear the tags again:
	ld hl, tmp_pcg_world__tags
	ld bc, MAX_AREA_SIZE * MAX_WORLD_AREAS * 2 - 1
	call clear_memory

	xor a  ; z
	ret


;-----------------------------------------------
; input:
; - iyl: area 1
; - iyl: area 2
; - c, b: x1, y1
; - e, d: x2, y2
; - ixl: direction1
; - ixh: direction2
pcg_generate_world__generate_area_connections_add_connection:
	ld hl, (tmp_pcg_world__tmp_ptr)
	; - each connection is 8 bytes: areaID1, areaID2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)
	ld a, iyl
	ld (hl), a
	inc hl
	ld a, iyh
	ld (hl), a
	inc hl
	ld a, ixl
	call pcg_generate_world__generate_area_connections_add_connection_random_chunk
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld a, ixl
	ld (hl), a
	inc hl
	ld c, e
	ld b, d
	ld a, ixh
	call pcg_generate_world__generate_area_connections_add_connection_random_chunk
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld a, ixh
	ld (hl), a
	inc hl
	ld (tmp_pcg_world__tmp_ptr), hl
	ret


pcg_generate_world__generate_area_connections_add_connection_random_chunk:
	cp PCG_DIRECTION_LEFT
	jr z, pcg_generate_world__generate_area_connections_add_connection_random_chunk_left
	cp PCG_DIRECTION_UP
	jr z, pcg_generate_world__generate_area_connections_add_connection_random_chunk_up
	cp PCG_DIRECTION_RIGHT
	jr z, pcg_generate_world__generate_area_connections_add_connection_random_chunk_right
pcg_generate_world__generate_area_connections_add_connection_random_chunk_down:
	call random_a
	and #01
	add a, c
	add a, c
	ld c, a
	ld a, b
	add a, a
	inc a
	ld b, a
	ret
pcg_generate_world__generate_area_connections_add_connection_random_chunk_up:
	call random_a
	and #01
	add a, c
	add a, c
	ld c, a
	ld a, b
	add a, a
	ld b, a
	ret
pcg_generate_world__generate_area_connections_add_connection_random_chunk_left:
	ld a, c
	add a, c
	ld c, a
	call random_a
	and #01
	add a, b
	add a, b
	ld b, a
	ret
pcg_generate_world__generate_area_connections_add_connection_random_chunk_right:
	ld a, c
	add a, c
	inc a
	ld c, a
	call random_a
	and #01
	add a, b
	add a, b
	ld b, a
	ret


;-----------------------------------------------
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_bottom_most_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_bottom_most_point_tagless_ptrs_loop_done
pcg_generate_world__random_bottom_most_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_bottom_most_point_tagless_ptrs_loop
pcg_generate_world__random_bottom_most_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find candidates:
	ld iy, tmp_pcg_world__candidates_list
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_next
		; there is a room here:
		ld a, b
		cp 1  ; are we at the bottom
		jr z, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_continue
		; is there a room below?
		push bc
		push hl
			ld b, 0
			ld c, ixl
			add hl, bc
			ld a, (hl)
			inc a  ; cp #ff
		pop hl
		pop bc
		jr nz, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_next  ; not a bottom room
pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_continue:
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_next
		; add a candidate:
		ld a, c
		sub ixl
		neg
		ld (iy), a  ; x
		ld a, b
		sub ixh
		neg
		ld (iy + 1), a  ; y
		inc iy
		inc iy
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_bottom_most_point_tagless_candidates_loop_y

pcg_generate_world__random_bottom_most_point_tagless_sample:
	; choose one at random:
	ld a, (tmp_pcg_world__candidates_list_size)
	or a
	jr z, pcg_generate_world__random_bottom_most_point_tagless_fail
	ld c, a
	call random_modulo
	add a, a
	ld hl, tmp_pcg_world__candidates_list
	ADD_HL_A
	ld c, (hl)
	inc hl
	ld b, (hl)

	ld a, b
	or a
	ld a, c
	jr z, pcg_generate_world__random_bottom_most_point_tagless_candidates_final_loop_done
pcg_generate_world__random_bottom_most_point_tagless_candidates_final_loop:
	add a, ixl
	djnz pcg_generate_world__random_bottom_most_point_tagless_candidates_final_loop
pcg_generate_world__random_bottom_most_point_tagless_candidates_final_loop_done:
	ld b, (hl)  ; recover y
	ld l, a  ; l = offset (x + y * width)
	xor a  ; z
	ret
pcg_generate_world__random_bottom_most_point_tagless_fail:
	or 1
	ret


;-----------------------------------------------
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_top_most_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_top_most_point_tagless_ptrs_loop_done
pcg_generate_world__random_top_most_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_top_most_point_tagless_ptrs_loop
pcg_generate_world__random_top_most_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find candidates:
	ld iy, tmp_pcg_world__candidates_list
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_top_most_point_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_top_most_point_tagless_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_next
		; there is a room here:
		ld a, b
		cp ixh  ; are we at the top of the map?
		jr z, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_continue
		; is there a room above?
		push bc
		push hl
			ld b, 0
			ld c, ixl
			or a
			sbc hl, bc
			ld a, (hl)
			inc a  ; cp #ff
		pop hl
		pop bc
		jr nz, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_next  ; not a top room
pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_continue:
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_next
		; add a candidate:
		ld a, c
		sub ixl
		neg
		ld (iy), a  ; x
		ld a, b
		sub ixh
		neg
		ld (iy + 1), a  ; y
		inc iy
		inc iy
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_top_most_point_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_top_most_point_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_top_most_point_tagless_candidates_loop_y
	jp pcg_generate_world__random_bottom_most_point_tagless_sample


;-----------------------------------------------
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_left_most_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_left_most_point_tagless_ptrs_loop_done
pcg_generate_world__random_left_most_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_left_most_point_tagless_ptrs_loop
pcg_generate_world__random_left_most_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find candidates:
	ld iy, tmp_pcg_world__candidates_list
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_left_most_point_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_left_most_point_tagless_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next
		; there is a room here:
		ld a, c
		cp ixl  ; are we at the left-most of the map?
		jr z, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue
		; is there a room to the left
		dec hl
		ld a, (hl)
		inc hl
		inc a  ; cp #ff
		jr nz, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next  ; not a top room
pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_continue:
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next
		; add a candidate:
		ld a, c
		sub ixl
		neg
		ld (iy), a  ; x
		ld a, b
		sub ixh
		neg
		ld (iy + 1), a  ; y
		inc iy
		inc iy
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_left_most_point_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_left_most_point_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_left_most_point_tagless_candidates_loop_y
	jp pcg_generate_world__random_bottom_most_point_tagless_sample


;-----------------------------------------------
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_right_most_point_tagless:
	; get divisions and tags ptrs:
	; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld de, tmp_pcg_world__tags
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_right_most_point_tagless_ptrs_loop_done
pcg_generate_world__random_right_most_point_tagless_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	ex hl, de
		ld bc, MAX_AREA_SIZE * 2
		add hl, bc
	ex hl, de
	dec a
	jr nz, pcg_generate_world__random_right_most_point_tagless_ptrs_loop
pcg_generate_world__random_right_most_point_tagless_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - de: ptr to tags
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find candidates:
	ld iy, tmp_pcg_world__candidates_list
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_right_most_point_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_right_most_point_tagless_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_next
		; there is a room here:
		ld a, c
		cp 1  ; are we at the right-most of the map?
		jr z, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_continue
		; is there a room to the right
		inc hl
		ld a, (hl)
		dec hl
		inc a  ; cp #ff
		jr nz, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_next  ; not a top room
pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_continue:
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_next
		; add a candidate:
		ld a, c
		sub ixl
		neg
		ld (iy), a  ; x
		ld a, b
		sub ixh
		neg
		ld (iy + 1), a  ; y
		inc iy
		inc iy
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_right_most_point_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_right_most_point_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_right_most_point_tagless_candidates_loop_y
	jp pcg_generate_world__random_bottom_most_point_tagless_sample


;-----------------------------------------------:
; input:
; - a: target area
; output:
; - c, b: x, y coordinates of the point
; - l: offset (x + y * width)
; - z: found
; - nz: no point found
pcg_generate_world__random_bottom_left_most_point:
	; get divisions ptr:
	; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
	ld hl, current_world__area_data + 4 + 1
	or a
	jr z, pcg_generate_world__random_bottom_left_most_point_ptrs_loop_done
pcg_generate_world__random_bottom_left_most_point_ptrs_loop:
	ld bc, WORLD_AREA__SIZE
	add hl, bc
	dec a
	jr nz, pcg_generate_world__random_bottom_left_most_point_ptrs_loop
pcg_generate_world__random_bottom_left_most_point_ptrs_loop_done:
	ld c, (hl)
	inc hl
	ld b, (hl)
	push bc
		ld bc, MAX_AREA_SIZE + 1
		add hl, bc
	pop bc
	; Here:
	; - hl: ptr to divisions
	; - c, b: area width, height
	ld ixl, c
	ld ixh, b

	; find first match in every map row, and keep the last:
	ld iy, #0000
pcg_generate_world__random_bottom_left_most_point_candidates_loop_y:
	push bc
pcg_generate_world__random_bottom_left_most_point_candidates_loop_x:
		ld a, (hl)
		inc a  ; cp #ff
		jr z, pcg_generate_world__random_bottom_left_most_point_candidates_loop_x_next
		; there is a room here:
		ld a, c
		sub ixl
		neg
		ld iyl, a  ; x
		ld a, b
		sub ixh
		neg
		ld iyh, a  ; y
		; next row:
		ld b, 0
		add hl, bc
		jr pcg_generate_world__random_bottom_left_most_point_candidates_loop_y_next
pcg_generate_world__random_bottom_left_most_point_candidates_loop_x_next:
		inc hl
		dec c
		jr nz, pcg_generate_world__random_bottom_left_most_point_candidates_loop_x
pcg_generate_world__random_bottom_left_most_point_candidates_loop_y_next:
	pop bc
	djnz pcg_generate_world__random_bottom_left_most_point_candidates_loop_y
	ld c, iyl
	ld b, iyh

	ld a, b
	or a
	ld a, c
	jr z, pcg_generate_world__random_bottom_left_most_point_final_loop_done
pcg_generate_world__random_bottom_left_most_point_final_loop:
	add a, ixl
	djnz pcg_generate_world__random_bottom_left_most_point_final_loop
pcg_generate_world__random_bottom_left_most_point_final_loop_done:
	ld b, iyh
	ld l, a  ; l = offset (x + y * width)
	xor a  ; z
	ret


;-----------------------------------------------
; input:
; - a: area
; - b: tag
; - l: offset
; output:
; - z: success
; - nz: failure
pcg_generate_world__add_tag:
	ld c, l
	ld hl, tmp_pcg_world__tags
	or a
	jr z, pcg_generate_world__add_tag_loop_done
	ld de, MAX_AREA_SIZE * 2
pcg_generate_world__add_tag_loop:
	add hl, de
	dec a
	jr nz, pcg_generate_world__add_tag_loop
pcg_generate_world__add_tag_loop_done:
	push bc
		ld b, 0
		add hl, bc
		add hl, bc  ; we add it twice, since we can have two tags per room
	pop bc
	ld a, (hl)
	or a
	jr z, pcg_generate_world__add_tag_found_spot
	inc hl
	ld a, (hl)
	or a
	ret nz
pcg_generate_world__add_tag_found_spot:
	ld (hl), b
	ret  ; we will always have "z" here


;-----------------------------------------------
pcg_generate_world__generate_spanning_tree:
	ld hl, tmp_pcg_world__area_0_connections
	ld b, MAX_WORLD_AREAS
pcg_generate_world__generate_spanning_tree_loop:
	push bc
		push hl
			ld bc, MAX_AREA_SIZE - 1
			call clear_memory
		pop hl
		ld bc, WORLD_AREA__SIZE
		add hl, bc
	pop bc
	djnz pcg_generate_world__generate_spanning_tree_loop
	ret


;-----------------------------------------------
pcg_generate_world__generate_mission:
	; ...
	ret


;-----------------------------------------------
pcg_generate_world__spawn_additional_objects:
	; ...
	ret


;-----------------------------------------------
pcg_generate_world__generate_tag_data:
	ld hl, tmp_pcg_world__area_0_tags
	ld b, MAX_WORLD_AREAS

pcg_generate_world__generate_tag_data_loop:
	push bc
		push hl
			ld bc, MAX_AREA_N_TAGS * 3 - 1
			call clear_memory
		pop hl
		ld bc, WORLD_AREA__SIZE
		add hl, bc
	pop bc
	djnz pcg_generate_world__generate_tag_data_loop

	; chest content:
	ld hl, current_world__chest_content
	ld bc, MAX_CHESTS * 2
	ld a, #ff
	call clear_memory_a

	; extra shop items:
	ld hl, current_world__shop_extra_items
	ld (hl), 0
	inc hl
	ld (hl), 0
	ret


;-----------------------------------------------
pcg_generate_world__puzzles:
	; generate tablet contents:
	; ...

	; combination solutions:
	; ...

	; trial types:
	; ...

	; power stone numbers:
	; ...

	call pcg_generate_maya_puzzle_riddles
	jp pcg_generate_syllable_riddle


;-----------------------------------------------
pcg_generate_world__layout_offset_from_c_b_ixl:
	ld a, b
	or a
	jr z, pcg_generate_world__layout_offset_from_c_b_ixl_loop_done
	xor a
	push bc
pcg_generate_world__layout_offset_from_c_b_ixl_loop:
		add a, ixl
		djnz pcg_generate_world__layout_offset_from_c_b_ixl_loop
	pop bc
pcg_generate_world__layout_offset_from_c_b_ixl_loop_done:
	add a, c
	ret

