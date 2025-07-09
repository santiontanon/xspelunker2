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


;-----------------------------------------------
; input:
pcg_generate_world:
	ld hl, current_world__seed
	ld de, rng_seed1
	ldi
	ldi
	ldi
	ldi

	call pcg_generate_world__init
	call pcg_generate_world__generate_area_layouts
	call pcg_generate_world__generate_divisions
	call pcg_generate_world__generate_area_connections
	call pcg_generate_world__generate_spanning_tree
	call pcg_generate_world__generate_mission
	call pcg_generate_world__spawn_additional_objects

	; for now just copy over the hardcoded data:
	ld hl, hardcoded_world_data
	ld de, current_world__area_data
	ld bc, hardcoded_world_data_end - hardcoded_world_data
	ldir

	jp pcg_generate_world__puzzles


;-----------------------------------------------
pcg_generate_world__init:
	; random seed:
	ld hl, rng_seed1
	ld de, current_world__seed
	ldi
	ldi
	ldi
	ldi
	; ...
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
; - uses the connections space to store the layout (which will later be overwritten) by
;   pcg_generate_world__generate_area_connections.
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
			call pcg_generate_world__generate_area_layout
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

; 		ld hl, (rng_seed1)
; 		ld de, (rng_seed2)  ; mdl-watch: "pcg_generate_world__generate_area_layout", c, b, hl, de
	pop bc
	pop de
	pop hl
	pop af

	or a
	jr nz, pcg_generate_world__generate_area_layout_from_scratch
pcg_generate_world__generate_area_layout_copy:
	; copy the provided layout:
	ld iyl, 0  ; next room ID  ; mdl-watch: "just copy layout"
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
	ret

pcg_generate_world__generate_area_layout_from_scratch:
	ld (tmp_pcg_world__tmp_ptr), hl  ; hl has a pointer to the reference layout
	ld iyl, 1  ; number of rooms  ; mdl-watch: "generate from scratch or approximately following a pattern"
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
	xor a  ; mdl-watch: "first room at ", c, b
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
	call random_a  ; mdl-watch: "chance of rejection..."
	cp 243  ; acceptance threshold
	jr c, pcg_generate_world__generate_area_layout_from_scratch_loop2
pcg_generate_world__generate_area_layout_from_scratch_loop2_add_room:
	ld a, iyl  ; mdl-watch: "adding room at: ", c, b
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
	; ...
	ret


;-----------------------------------------------
pcg_generate_world__generate_area_connections:
	; ...
	ret


;-----------------------------------------------
pcg_generate_world__generate_spanning_tree:
	; ...
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

