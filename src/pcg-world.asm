PCG_WORLD_START_ADDRESS: equ $

	org #c000

tmp_pcg_world__floodfill_open_list: ds virtual 256  ; (should be 256-aligned)
tmp_pcg_world__floodfill_open_list_bot: ds virtual 2
tmp_pcg_world__floodfill_open_list_top: ds virtual 2

tmp_pcg_world__candidates_list: equ tmp_pcg_world__floodfill_open_list
tmp_pcg_world__candidates_list_top: equ tmp_pcg_world__floodfill_open_list_bot
tmp_pcg_world__candidates_list_size: equ tmp_pcg_world__floodfill_open_list_top

tmp_pcg_world__mst_open_list: equ tmp_pcg_world__candidates_list
tmp_pcg_world__mst_open_list_top: equ tmp_pcg_world__candidates_list_top
tmp_pcg_world__mst_open_list_size: equ tmp_pcg_world__candidates_list_size

tmp_pcg_world__tmp_ptr: ds virtual 2
tmp_pcg_world__tags: ds virtual MAX_AREA_SIZE * MAX_WORLD_AREAS * 2  ; tags for all areas, at most 2 tags per room

pcg_generate_world_tmp_a0p1: ds virtual 2
pcg_generate_world_tmp_a0p2: ds virtual 2
pcg_generate_world_tmp_a1p1: ds virtual 2
pcg_generate_world_tmp_a1p2: ds virtual 2
pcg_generate_world_tmp_a2p1: ds virtual 2
pcg_generate_world_tmp_a2p2: ds virtual 2

tmp_pcg_world__minimum_spanning_tree_top: ds virtual 2
tmp_pcg_world__minimum_spanning_tree_n_nodes: ds virtual 1
tmp_pcg_world__minimum_spanning_tree: ds virtual 128*MST_STRUCTURE_SIZE  ; (assume 128 divisions)
tmp_pcg_world__mst_neighbors_list: ds virtual 256
tmp_pcg_world__mst_neighbors_list_top: ds virtual 2
tmp_pcg_world__mst_neighbors_list_size: ds virtual 1
tmp_pcg_world__mst_divisions: ds virtual 128  ; assume 128 divisions, one byte per division with 0 or 1, "1" meaning the division is in the tree already.

tmp_pcg_world__mst_mars_start: ds virtual 2
tmp_pcg_world__mst_moon_start: ds virtual 2
tmp_pcg_world__mst_main_n_nodes: ds virtual 1
tmp_pcg_world__mst_mars_n_nodes: ds virtual 1
tmp_pcg_world__mst_moon_n_nodes: ds virtual 1

tmp_pcg_world__lock_directions: ds virtual 20 * 2  ; 40 bytes (assume at most 20 locks)
tmp_pcg_world__lock_directions_size: ds virtual 1

tmp_pcg_world__mission_start_node: ds virtual 2
tmp_pcg_world__mission_teleporter_atlantis_node: ds virtual 2
tmp_pcg_world__mission_teleporter_mars_node: ds virtual 2
tmp_pcg_world__mission_teleporter_moon_node: ds virtual 2
tmp_pcg_world__mission_boss1_node: ds virtual 2
tmp_pcg_world__mission_boss2_node: ds virtual 2
tmp_pcg_world__mission_boss3_node: ds virtual 2
tmp_pcg_world__mission_boss4_node: ds virtual 2
tmp_pcg_world__mission_boss5_node: ds virtual 2
tmp_pcg_world__mission_boss6_node: ds virtual 2
tmp_pcg_world__mission_boss7_node: ds virtual 2
tmp_pcg_world__mission_midpoint_node: ds virtual 2
tmp_pcg_world__mission_ending_node: ds virtual 2


IF $ > #d000
	ERROR "pcg-world.asm uses too much RAM in buffer_4096!"
ENDIF

	org current_room__tile_map

tmp_pcg_world__useable_nodes: ds virtual 128 * 2
tmp_pcg_world__useable_nodes_size: ds virtual 1
tmp_pcg_world__reachable_nodes: ds virtual 128 * 2
tmp_pcg_world__reachable_nodes_size: ds virtual 1

tmp_pcg_world__quest_spec_open_list: ds virtual QUEST_SPEC_STRUCTURE_SIZE * 32
tmp_pcg_world__quest_spec_open_list_size: ds virtual 1


IF $ > current_room__tile_map + MAX_ROOM_SIZE
	ERROR "pcg-world.asm uses too much RAM in current_room__tile_map!"
ENDIF

	org PCG_WORLD_START_ADDRESS

tmp_pcg_world__area_0_connections: equ current_world__area_data + 4 + 1 + 1 + 1
tmp_pcg_world__area_0_divisions: equ tmp_pcg_world__area_0_connections + MAX_AREA_SIZE
tmp_pcg_world__area_0_tags: equ tmp_pcg_world__area_0_divisions + MAX_AREA_SIZE
tmp_pcg_world__area_10_connections: equ current_world__area_data + 4 + 1 + 1 + 1 + WORLD_AREA__SIZE*10
tmp_pcg_world__area_11_connections: equ current_world__area_data + 4 + 1 + 1 + 1 + WORLD_AREA__SIZE*11
tmp_pcg_world__area_3_divisions: equ current_world__area_data + 4 + 1 + 1 + 1 + MAX_AREA_SIZE + WORLD_AREA__SIZE*3
tmp_pcg_world__area_5_divisions: equ current_world__area_data + 4 + 1 + 1 + 1 + MAX_AREA_SIZE + WORLD_AREA__SIZE*5
tmp_pcg_world__area_9_divisions: equ current_world__area_data + 4 + 1 + 1 + 1 + MAX_AREA_SIZE + WORLD_AREA__SIZE*9
tmp_pcg_world__area_10_divisions: equ current_world__area_data + 4 + 1 + 1 + 1 + MAX_AREA_SIZE + WORLD_AREA__SIZE*10
tmp_pcg_world__area_11_divisions: equ current_world__area_data + 4 + 1 + 1 + 1 + MAX_AREA_SIZE + WORLD_AREA__SIZE*11

; Minimum-spanning tree node structure (12 bytes):
MST_STRUCTURE_SIZE: equ 12
MST_DIVISION_ID: equ 0
MST_AREA_ID: equ 1
MST_X: equ 2
MST_Y: equ 3
MST_OFFSET: equ 4
MST_N_DESCENDANTS: equ 5
MST_TAG1: equ 6
MST_TAG2: equ 7
MST_PARENT_DIRECTION: equ 8
MST_PARENT_PTR: equ 9  ; 2 bytes
MST_DEPTH: equ 11

; Quest-spec structure:
QUEST_SPEC_STRUCTURE_SIZE: equ 9
QUEST_SPEC_START_DIV_PTR: equ 0
QUEST_SPEC_GOAL_DIV_PTR: equ 2
QUEST_SPEC_START_POINT_OFFSET: equ 4
QUEST_SPEC_GOAL_POINT_OFFSET: equ 5
QUEST_SPEC_START_TAG: equ 6
QUEST_SPEC_GOAL_TAG: equ 7
QUEST_SPEC_N_SUBQUESTS: equ 8


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
	jr nz, pcg_generate_world_fail
	call pcg_generate_world__generate_mission  ; adds all the area tags to the divisions
	jr nz, pcg_generate_world_fail
	call pcg_generate_world__spawn_additional_objects  ; fills additional tags to some divisions
	call pcg_generate_world__generate_tag_data  ; generates the area tags, chest content and shop extra items from all the info above
;     out (#2d),a  ; DEBUG	

	; DEBUG:
	ld hl, hardcoded_area_data_0__connections
	ld de, tmp_pcg_world__area_0_connections
	ld bc, MAX_AREA_SIZE * 2
	call pcg_debug__arrays_equal  ; mdl-watch: "checking area 0"
	ld hl, hardcoded_area_data_10__connections
	ld de, tmp_pcg_world__area_10_connections
	ld bc, MAX_AREA_SIZE * 2
	call pcg_debug__arrays_equal  ; mdl-watch: "checking area 10"
	ld hl, hardcoded_area_data_11__connections
	ld de, tmp_pcg_world__area_11_connections
	ld bc, MAX_AREA_SIZE * 2
	call pcg_debug__arrays_equal  ; mdl-watch: "checking area 11"

	; for now just copy over the hardcoded data:
; 	ld hl, hardcoded_world_data
; 	ld de, current_world__area_data
; 	ld bc, hardcoded_world_data_end - hardcoded_world_data
; 	ldir

	jp pcg_generate_world__puzzles  ; tablet contents, combination puzzles, trial types, stone numbers 

pcg_generate_world_fail:
	di
	halt


pcg_debug__arrays_equal:
	ld a, (de)
	cp (hl)
	jr nz, pcg_debug__arrays_equal_fail
	inc de
	inc hl
	dec bc
	ld a, c
	or b
	ret z
	jr pcg_debug__arrays_equal


pcg_debug__arrays_equal_fail:
	di  ; mdl-watch: "pcg_debug__arrays_equal_fail", bc
	halt



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
	push bc
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
		push hl
			ADD_HL_A
			ld a, (hl)
			or a
			jr nz, pcg_generate_world__generate_divisions_loop2_next
			ld a, iyl
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
	; clear all the connections:
	ld hl, tmp_pcg_world__area_0_connections
	ld b, MAX_WORLD_AREAS
pcg_generate_world__generate_spanning_tree_clear_loop:
	push bc
		push hl
			ld bc, MAX_AREA_SIZE - 1
			call clear_memory
		pop hl
		ld bc, WORLD_AREA__SIZE
		add hl, bc
	pop bc
	djnz pcg_generate_world__generate_spanning_tree_clear_loop

	ld hl, tmp_pcg_world__mst_divisions
	ld bc, 128 - 1
	call clear_memory

	; init the tree as empty:
	ld hl, tmp_pcg_world__minimum_spanning_tree
	ld (tmp_pcg_world__minimum_spanning_tree_top), hl
	xor a
	ld (tmp_pcg_world__minimum_spanning_tree_n_nodes), a

	; Minimum-Spanning Tree for the main map:
	; Sample the root point (a random left-most point in jungle):
	xor a
	call pcg_generate_world__random_left_most_point_tagless
	ret nz
	ld h, 0
	call pcg_generate_world__generate_spanning_tree_internal

	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	ld (tmp_pcg_world__mst_main_n_nodes), a
	ld hl, (tmp_pcg_world__minimum_spanning_tree_top)
	ld (tmp_pcg_world__mst_mars_start), hl

	; Minimum-Spanning Tree for Mars:
	ld a, 10
	call pcg_generate_world__random_left_most_point_tagless
	ret nz
	ld h, 10
	call pcg_generate_world__generate_spanning_tree_internal

	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld b, a
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	sub b
	ld (tmp_pcg_world__mst_mars_n_nodes), a

	ld hl, (tmp_pcg_world__minimum_spanning_tree_top)
	ld (tmp_pcg_world__mst_moon_start), hl

	; Minimum-Spanning Tree for Moon:
	ld a, 11
	call pcg_generate_world__random_left_most_point_tagless
	ret nz
	ld h, 11
	call pcg_generate_world__generate_spanning_tree_internal

	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld b, a
	ld a, (tmp_pcg_world__mst_mars_n_nodes)
	ld c, a
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	sub b
	sub c
	ld (tmp_pcg_world__mst_moon_n_nodes), a

	; Add connections:
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	ld b, a
	ld ix, tmp_pcg_world__minimum_spanning_tree
pcg_generate_world__generate_spanning_tree_connections_loop:
	ld a, (ix + MST_PARENT_PTR)
	ld iyl, a
	ld a, (ix + MST_PARENT_PTR + 1)
	ld iyh, a  ; iy = parent ptr
	or iyl  ; if no parent, skip
	jr z, pcg_generate_world__generate_spanning_tree_connections_loop_next
	ld a, (ix + MST_AREA_ID)
	cp (iy + MST_AREA_ID)  ; if it's an interarea connection, skip
	jr nz, pcg_generate_world__generate_spanning_tree_connections_loop_next
	; get connections ptr:
	push bc
		call pcg_generate_world__get_area_ptr
		ld bc, 5
		add hl, bc
		ld e, (hl)  ; e = area width
		inc hl
		inc hl  ; hl = ptr to connections
	pop bc
	ld a, (ix + MST_PARENT_DIRECTION)
	cp PCG_DIRECTION_LEFT
	jr z, pcg_generate_world__generate_spanning_tree_connections_loop_left
	cp PCG_DIRECTION_UP
	jr z, pcg_generate_world__generate_spanning_tree_connections_loop_up
	cp PCG_DIRECTION_RIGHT
	jr z, pcg_generate_world__generate_spanning_tree_connections_loop_right
pcg_generate_world__generate_spanning_tree_connections_loop_down:
	ld a, (ix + MST_OFFSET)
	ADD_HL_A
	ld a, (hl)
	or PCG_DIRECTION_DOWN
	ld (hl), a
	ld d, 0  ; 'e' has the width here
	add hl, de
	ld a, (hl)
	or PCG_DIRECTION_UP
	ld (hl), a
	jr pcg_generate_world__generate_spanning_tree_connections_loop_next
pcg_generate_world__generate_spanning_tree_connections_loop_left:
	ld a, (ix + MST_OFFSET)
	ADD_HL_A
	ld a, (hl)
	or PCG_DIRECTION_LEFT
	ld (hl), a
	dec hl
	ld a, (hl)
	or PCG_DIRECTION_RIGHT
	ld (hl), a
	jr pcg_generate_world__generate_spanning_tree_connections_loop_next
pcg_generate_world__generate_spanning_tree_connections_loop_up:
	ld a, (ix + MST_OFFSET)
	ADD_HL_A
	ld a, (hl)
	or PCG_DIRECTION_UP
	ld (hl), a
	ld d, 0  ; 'e' has the width here
	or a
	sbc hl, de
	ld a, (hl)
	or PCG_DIRECTION_DOWN
	ld (hl), a
	jr pcg_generate_world__generate_spanning_tree_connections_loop_next
pcg_generate_world__generate_spanning_tree_connections_loop_right:
	ld a, (ix + MST_OFFSET)
	ADD_HL_A
	ld a, (hl)
	or PCG_DIRECTION_RIGHT
	ld (hl), a
	inc hl
	ld a, (hl)
	or PCG_DIRECTION_LEFT
	ld (hl), a
pcg_generate_world__generate_spanning_tree_connections_loop_next:
	ld de, MST_STRUCTURE_SIZE
	add ix, de
	dec b
	jp nz, pcg_generate_world__generate_spanning_tree_connections_loop
	ret


;-----------------------------------------------
; input:
; - c, b: x, y of the starting point
; - l: offset of the starting point
; - h: area of the starting point
pcg_generate_world__generate_spanning_tree_internal:
	ld a, l
	ld ixl, a  ; offset
	ld ixh, 0  ; parent direction
	ld a, h  ; area ID
	ld de, 0  ; parent
	ld hl, (tmp_pcg_world__minimum_spanning_tree_top)
	push hl
		call pcg_generate_world__push_mst_node
	pop de

	; init the open list:
	ld hl, tmp_pcg_world__mst_open_list
	ld a, 1
	ld (tmp_pcg_world__mst_open_list_size), a
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (tmp_pcg_world__mst_open_list_top), hl

pcg_generate_world__generate_spanning_tree_loop:
	; pop one node from the open list at random:
	call pcg_generate_world__mst_random_pop_from_open  ; de = ptr to an MST node

	; get division neighbor points:
	push de
		call pcg_generate_world__mst_get_division_neighbor_points
	pop ix

	; iterate through them in a random order:
pcg_generate_world__generate_spanning_tree_neighbor_loop:
	ld a, (tmp_pcg_world__mst_neighbors_list_size)
	or a
	jr z, pcg_generate_world__generate_spanning_tree_neighbor_loop_done

	; select a child at random:
	; each child is 5 bytes:
	; - division ID
	; - area ID
	; - x, y
	; - direction
	ld c, a
	call random_modulo
	push af
		ld c, a
		add a, a
		add a, a
		add a, c
		ld hl, tmp_pcg_world__mst_neighbors_list
		ADD_HL_A  ; hl = ptr to the child we selected

		; check that the division ID it would hadd is not yet on the tree:
		ld a, (hl)  ; division ID
		push hl
			ld hl, tmp_pcg_world__mst_divisions
			ADD_HL_A
			ld a, (hl)
			or a
		pop hl
		jr nz, pcg_generate_world__generate_spanning_tree_neighbor_loop_next

		; add to the tree:
		push hl
		push ix
			ld e, ixl  ; ptr to parent
			ld d, ixh
			inc hl
			ld a, (hl)  ; area ID
			push af
				inc hl
				ld c, (hl)  ; x
				inc hl
				ld b, (hl)  ; y
				inc hl
				ld a, (hl)  ; direction
				ld ixh, a
				; compute offset:
			pop af
			push af
				call pcg_generate_world__layout_offset_from_c_b_area
				ld ixl, a  ; offset
			pop af

			; push the new node we will create into the open list:
			push hl
			push de
				ld hl, (tmp_pcg_world__mst_open_list_top)
				ld de, (tmp_pcg_world__minimum_spanning_tree_top)
				ld (hl), e
				inc hl
				ld (hl), d
				inc hl
				ld (tmp_pcg_world__mst_open_list_top), hl
				ld hl, tmp_pcg_world__mst_open_list_size
				inc (hl)
			pop de
			pop hl

			call pcg_generate_world__push_mst_node
		pop ix
		pop hl

pcg_generate_world__generate_spanning_tree_neighbor_loop_next:
		; remove the child ("hl") from the neighbors list:
		ld e, l
		ld d, h
		ld bc, 5
		add hl, bc
	pop af  ; we recover the index of this child
	ld c, a
	ld a, (tmp_pcg_world__mst_neighbors_list_size)
	sub c
	dec a
	jr z, pcg_generate_world__generate_spanning_tree_neighbor_loop_next_continue
	ld c, a
	add a, a
	add a, a
	add a, c
	ld b, 0
	ld c, a
	ldir
pcg_generate_world__generate_spanning_tree_neighbor_loop_next_continue:

	ld hl, tmp_pcg_world__mst_neighbors_list_size
	dec (hl)
	jr pcg_generate_world__generate_spanning_tree_neighbor_loop
pcg_generate_world__generate_spanning_tree_neighbor_loop_done:

	ld a, (tmp_pcg_world__mst_open_list_size)
	or a
	jp nz, pcg_generate_world__generate_spanning_tree_loop
	ret


;-----------------------------------------------
; Finds all the points that are neighbors to a given mst node, as candidates to be roots
; of children nodes of the given node (pointed to by "de").
; 
; input:
; - de: ptr to a mst node
pcg_generate_world__mst_get_division_neighbor_points:
	ld hl, tmp_pcg_world__mst_neighbors_list
	ld (tmp_pcg_world__mst_neighbors_list_top), hl
	xor a
	ld (tmp_pcg_world__mst_neighbors_list_size), a

	; get ptr to area:
	ld ixl, e
	ld ixh, d
	ld a, (ix + MST_AREA_ID)
	call pcg_generate_world__get_area_ptr  ; hl = area ptr

	; get area width/height, and ptr to division IDs:
	ld bc, 5
	add hl, bc
	ld c, (hl)  ; width
	inc hl
	ld b, (hl)  ; height
	ld de, MAX_AREA_SIZE + 1
	add hl, de  ; hl = divisionIDs ptr
	ld iyl, c  ; width
	ld iyh, b  ; height

	; Find neighbors on the current division:
pcg_generate_world__mst_get_division_neighbor_points_loop_y:
	push bc
pcg_generate_world__mst_get_division_neighbor_points_loop_x:
		ld a, (hl)
		cp #ff
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_next
		cp (ix + MST_DIVISION_ID)
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_next

		; check left:
		ld a, c
		cp iyl
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_left
		dec hl
		ld a, (hl)
		inc hl
		cp (ix + MST_DIVISION_ID)
		jr nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_left
		; found a neighbor:
		ld a, (hl)  ; division ID
		ld e, PCG_DIRECTION_LEFT
		jr pcg_generate_world__mst_get_division_neighbor_points_loop_add_neighbor
pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_left:

		; check right:
		ld a, c
		cp 1
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_right
		inc hl
		ld a, (hl)
		dec hl
		cp (ix + MST_DIVISION_ID)
		jr nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_right
		; found a neighbor:
		ld a, (hl)  ; division ID
		ld e, PCG_DIRECTION_RIGHT
		jr pcg_generate_world__mst_get_division_neighbor_points_loop_add_neighbor
pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_right:

		; check up:
		ld a, b
		cp iyh
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_up
		ld d, 0
		ld e, iyl
		or a
		sbc hl, de
		ld a, (hl)
		add hl, de
		cp (ix + MST_DIVISION_ID)
		jr nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_up
		; found a neighbor:
		ld a, (hl)  ; division ID
		ld e, PCG_DIRECTION_UP
		jr pcg_generate_world__mst_get_division_neighbor_points_loop_add_neighbor
pcg_generate_world__mst_get_division_neighbor_points_loop_x_skip_up:

		; check down:
		ld a, b
		cp 1
		jr z, pcg_generate_world__mst_get_division_neighbor_points_loop_x_next
		ld d, 0
		ld e, iyl
		add hl, de
		ld a, (hl)
		or a
		sbc hl, de
		cp (ix + MST_DIVISION_ID)
		jr nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x_next
		; found a neighbor:
		ld a, (hl)  ; division ID
		ld e, PCG_DIRECTION_DOWN

pcg_generate_world__mst_get_division_neighbor_points_loop_add_neighbor:
		push hl
			ld hl, (tmp_pcg_world__mst_neighbors_list_top)
			ld (hl), a  ; division ID
			inc hl
			ld a, (ix + MST_AREA_ID)
			ld (hl), a  ; area ID
			inc hl
			ld a, c
			sub iyl
			neg
			ld (hl), a  ; x
			inc hl
			ld a, b
			sub iyh
			neg
			ld (hl), a  ; y
			inc hl
			ld (hl), e  ; direction
			inc hl
			ld (tmp_pcg_world__mst_neighbors_list_top), hl
			ld hl, tmp_pcg_world__mst_neighbors_list_size
			inc (hl)
		pop hl
pcg_generate_world__mst_get_division_neighbor_points_loop_x_next:
		inc hl
		dec c
		jp nz, pcg_generate_world__mst_get_division_neighbor_points_loop_x
	pop bc
	dec b
	jp nz, pcg_generate_world__mst_get_division_neighbor_points_loop_y

	; Find neighbors through inter-area connections:
	; - here ix still has a pointer to the minimum-spanning-tree node
	ld a, (ix + MST_DIVISION_ID)
	ld iy, current_world__interarea_connections
pcg_generate_world__mst_get_division_connections_loop:
	ld a, (iy)
	cp #ff
	jp z, pcg_generate_world__mst_get_division_connections_loop_done
	; each connection is: areaID1, areaID2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)
	call pcg_generate_world__get_area_ptr
	ld bc, 5
	add hl, bc
	ld a, (hl)  ; width
	ld bc, 2 + MAX_AREA_SIZE
	add hl, bc  ; hl = ptr to division IDs
	push ix
		ld ixl, a
		ld c, (iy + 2)  ; x
		ld b, (iy + 3)  ; y
		srl c
		srl b
		call pcg_generate_world__layout_offset_from_c_b_ixl  ; a = offset
	pop ix
	ADD_HL_A
	ld a, (hl)  ; division ID of the first point of this connection
	cp (ix + MST_DIVISION_ID)
	jr nz, pcg_generate_world__mst_get_division_connections_loop_check_p2
	; add p2 as a neighbor:
	ld a, (iy + 1)  ; p2.area
	call pcg_generate_world__get_area_ptr
	ld bc, 5
	add hl, bc
	ld a, (hl)  ; width
	ld bc, 2 + MAX_AREA_SIZE
	add hl, bc  ; hl = ptr to division IDs
	push ix
		ld ixl, a
		ld c, (iy + 5)  ; x
		ld b, (iy + 6)  ; y
		srl c
		srl b
		call pcg_generate_world__layout_offset_from_c_b_ixl  ; a = offset
	pop ix
	ADD_HL_A
	ld a, (hl)  ; p2.division ID

	ld hl, (tmp_pcg_world__mst_neighbors_list_top)
	ld (hl), a  ; division ID
	inc hl
	ld a, (iy + 1)
	ld (hl), a  ; area ID
	inc hl
	ld a, (iy + 5)
	srl a	
	ld (hl), a  ; x
	inc hl
	ld a, (iy + 6)
	srl a	
	ld (hl), a  ; y
	inc hl
	ld a, (iy + 7)
	ld (hl), a  ; direction
	inc hl
	ld (tmp_pcg_world__mst_neighbors_list_top), hl
	ld hl, tmp_pcg_world__mst_neighbors_list_size
	inc (hl)
	jr pcg_generate_world__mst_get_division_connections_loop_next
pcg_generate_world__mst_get_division_connections_loop_check_p2:
	ld a, (iy + 1)
	call pcg_generate_world__get_area_ptr
	ld bc, 5
	add hl, bc
	ld a, (hl)  ; width
	ld bc, 2 + MAX_AREA_SIZE
	add hl, bc  ; hl = ptr to division IDs
	push ix
		ld ixl, a
		ld c, (iy + 5)  ; x
		ld b, (iy + 6)  ; y
		srl c
		srl b
		call pcg_generate_world__layout_offset_from_c_b_ixl  ; a = offset
	pop ix
	ADD_HL_A
	ld a, (hl)  ; division ID of the second point of this connection
	cp (ix + MST_DIVISION_ID)
	jr nz, pcg_generate_world__mst_get_division_connections_loop_next
	; add p1 as a neighbor:
	ld a, (iy)  ; p1.area
	call pcg_generate_world__get_area_ptr
	ld bc, 5
	add hl, bc
	ld a, (hl)  ; width
	ld bc, 2 + MAX_AREA_SIZE
	add hl, bc  ; hl = ptr to division IDs
	push ix
		ld ixl, a
		ld c, (iy + 2)  ; x
		ld b, (iy + 3)  ; y
		srl c
		srl b
		call pcg_generate_world__layout_offset_from_c_b_ixl  ; a = offset
	pop ix
	ADD_HL_A
	ld a, (hl)  ; p1.division ID

	ld hl, (tmp_pcg_world__mst_neighbors_list_top)
	ld (hl), a  ; division ID
	inc hl
	ld a, (iy + 0)
	ld (hl), a  ; area ID
	inc hl
	ld a, (iy + 2)
	srl a		
	ld (hl), a  ; x
	inc hl
	ld a, (iy + 3)
	srl a	
	ld (hl), a  ; y
	inc hl
	ld a, (iy + 4)
	ld (hl), a  ; direction
	inc hl
	ld (tmp_pcg_world__mst_neighbors_list_top), hl
	ld hl, tmp_pcg_world__mst_neighbors_list_size
	inc (hl)
pcg_generate_world__mst_get_division_connections_loop_next:
	ld bc, 8
	add iy, bc
	jp pcg_generate_world__mst_get_division_connections_loop
pcg_generate_world__mst_get_division_connections_loop_done:
	ret


;-----------------------------------------------
; output:
; - de: ptr to an mst node
pcg_generate_world__mst_random_pop_from_open:
	ld hl, tmp_pcg_world__mst_open_list_size
	ld a, (hl)
	dec (hl)

	ld hl, (tmp_pcg_world__mst_open_list_top)
	dec hl
	dec hl
	ld (tmp_pcg_world__mst_open_list_top), hl

	ld c, a
	call random_modulo
	ld hl, tmp_pcg_world__mst_open_list
	add a, a
	push af
		ADD_HL_A
		ld e, (hl)
		inc hl
		ld d, (hl)  ; de: ptr to note to pop
		ld a, (tmp_pcg_world__mst_open_list_size)
		add a, a
		ld c, a
	pop af
	push de
		; shift copy ("length - n" - 1) * 2 bytes, 2 bytes to the left
		ld e, l
		ld d, h
		dec de
		inc hl
		sub c
		jr z, pcg_generate_world__mst_random_pop_from_open_done
		neg
		ld b, 0
		ld c, a
		ldir
pcg_generate_world__mst_random_pop_from_open_done:
	pop de
	ret


;-----------------------------------------------
; Minimum-spanning tree node structure (10 bytes):
; input:
; - a: area ID
; - c, b: x, y
; - ixl: offset
; - ixh: direction
; - de: parent ptr
pcg_generate_world__push_mst_node:
	; get the division ID:
	ld hl, tmp_pcg_world__minimum_spanning_tree_n_nodes
	inc (hl)
	push af
		push bc
			ld hl, tmp_pcg_world__area_0_divisions
			or a
			jr z, pcg_generate_world__push_mst_node_ptr_loop_done
			ld bc, WORLD_AREA__SIZE
pcg_generate_world__push_mst_node_ptr_loop:
			add hl, bc
			dec a
			jr nz, pcg_generate_world__push_mst_node_ptr_loop
pcg_generate_world__push_mst_node_ptr_loop_done:
			ld b, 0
			ld c, ixl
			add hl, bc
			ld a, (hl)  ; division ID
		pop bc
		ld hl, (tmp_pcg_world__minimum_spanning_tree_top)
		ld (hl), a  ; division ID
		push hl
			ld hl, tmp_pcg_world__mst_divisions
			ADD_HL_A
			ld (hl), 1  ; mark the division as already being in the tree
		pop hl
		inc hl
	pop af
	ld (hl), a  ; area ID
	inc hl
	ld (hl), c  ; x
	inc hl
	ld (hl), c  ; y
	inc hl
	ld a, ixl
	ld (hl), a  ; offset
	inc hl
	ld (hl), 0  ; n descendants
	inc hl
	ld (hl), 0  ; tag 1
	inc hl
	ld (hl), 0  ; tag 2
	inc hl
	ld a, ixh
	ld (hl), a  ; direction
	inc hl
	ld (hl), e  ; parent ptr
	inc hl
	ld (hl), d
	inc hl
	ld a, e
	or d
	jr z, pcg_generate_world__push_mst_node_depth_set
	ex de, hl
	push bc
		ld bc, MST_DEPTH
		add hl, bc
		ld a, (hl)  ; parent depth
		inc a
		or a
		sbc hl, bc  ; restore the parent ptr
	pop bc
	ex de, hl
pcg_generate_world__push_mst_node_depth_set:
	ld (hl), a  ; depth
	inc hl
	ld (tmp_pcg_world__minimum_spanning_tree_top), hl

pcg_generate_world__push_mst_node_n_descendants_loop:
	ld a, e
	or d
	ret z  ; if parent is empty, we are done
	; otherwise, increase n_descendants by one:
	ld hl, MST_N_DESCENDANTS
	add hl, de
	inc (hl)
	ld de, 4
	add hl, de
	ld e, (hl)  ; get the next parent
	inc hl
	ld d, (hl)
	jr pcg_generate_world__push_mst_node_n_descendants_loop


;-----------------------------------------------
; output:
; - z: all ok
; - nz: some error happened
pcg_generate_world__generate_mission:
	ld hl, tmp_pcg_world__minimum_spanning_tree
	ld (tmp_pcg_world__mission_start_node), hl

	ld a, 9  ; atlantis
	call pcg_generate_world__random_top_most_point_tagless
	ret nz
	ld b, 0
	ld c, l
	ld hl, tmp_pcg_world__area_9_divisions
	add hl, bc
	ld a, (hl)  ; division ID
	call pcg_generate_world__get_mst_node_by_division_id
	ld (tmp_pcg_world__mission_teleporter_atlantis_node), hl
	ld a, TAG_TELEPORTER_ATLANTIS
	call pcg_generate_world__add_tag_to_random_point_in_mst_node_division
	ret nz

	ld hl, (tmp_pcg_world__mst_mars_start)
	ld (tmp_pcg_world__mission_teleporter_mars_node), hl
	ld a, TAG_TELEPORTER_MARS
	call pcg_generate_world__add_tag_to_random_point_in_mst_node_division
	ret nz

	ld hl, (tmp_pcg_world__mst_moon_start)
	ld (tmp_pcg_world__mission_teleporter_moon_node), hl
	ld a, TAG_TELEPORTER_MOON
	call pcg_generate_world__add_tag_to_random_point_in_mst_node_division
	ret nz

	; boss locations:
	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 1  ; temple of inscriptions
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss1_node), hl

	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 2  ; hidden temple
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss2_node), hl

	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 4  ; inverted pyramid
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss3_node), hl

	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 8  ; xibalba
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss4_node), hl

	ld ix, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__mst_main_n_nodes)
	ld c, 9  ; atlantis
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss5_node), hl

	ld ix, (tmp_pcg_world__mst_mars_start)
	ld a, (tmp_pcg_world__mst_mars_n_nodes)
	ld c, 10  ; mars
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss6_node), hl

	ld ix, (tmp_pcg_world__mst_moon_start)
	ld a, (tmp_pcg_world__mst_moon_n_nodes)
	ld c, 11  ; moon
	call pcg_generate_world__random_area_mst_node_only_leaves
	ret nz
	ld (tmp_pcg_world__mission_boss7_node), hl

	; midpoint:
	ld a, (tmp_pcg_world__area_5_divisions + 1)  ; division ID
	call pcg_generate_world__get_mst_node_by_division_id
	ld (tmp_pcg_world__mission_midpoint_node), hl
	ld c, TAG_MIDPOINT
	ld b, PCG_DIRECTION_DOWN
	call pcg_generate_world__add_lock_direction

	; ending:
	ld a, (tmp_pcg_world__area_3_divisions + 3)  ; division ID
	call pcg_generate_world__get_mst_node_by_division_id
	ld (tmp_pcg_world__mission_ending_node), hl

	; Generate quests:
	ld ix, tmp_pcg_world__minimum_spanning_tree  ; root
	ld iy, (tmp_pcg_world__mission_midpoint_node)  ; do not go past this point
	call pcg_generate_world__reachable_nodes

	ld hl, tmp_pcg_world__reachable_nodes
	ld de, tmp_pcg_world__useable_nodes
	ld bc, 128 * 2 + 1
	ldir  ; useable are the same as reachable at the beginning

	; add "midpoint" to the reachable list (not to the useable list)
	ld hl, tmp_pcg_world__reachable_nodes_size
	ld a, (hl)
	inc (hl)
	ld hl, tmp_pcg_world__reachable_nodes
	add a, a
	ADD_HL_A
	ld bc, (tmp_pcg_world__mission_midpoint_node)
	ld (hl), c
	inc hl
	ld (hl), b

	xor a
	ld (tmp_pcg_world__quest_spec_open_list), a
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_boss1_node, 3, #ff, #ff, TAG_NONE, TAG_BOSS1
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_boss2_node, 3, #ff, #ff, TAG_NONE, TAG_BOSS2
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_boss3_node, 3, #ff, #ff, TAG_NONE, TAG_BOSS3
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_midpoint_node, 2, #ff, #ff, TAG_START, TAG_MIDPOINT
	PCG_WORLD__PUSH_QUEST tmp_pcg_world__mission_start_node, tmp_pcg_world__mission_ending_node, 2, #ff, #ff, TAG_NONE, TAG_ENDING

	; ...

	; if (generateSubquests(w, tree, open, useable, reachable) == null) return false;

	; // path to midpoint:
	; QuestSpec q1b = new QuestSpec(boss1, midpoint, 0, null, null, null, null);
	; open = new ArrayList<>();
	; open.add(q1b);
	; if (generateSubquests(w, tree, open, useable, reachable) == null) return false

	; // for the bosses 4 and 5, create "current reachable area" (from midpoint on), and do the same
	; QuestSpec q4 = new QuestSpec(midpoint, boss4, n_subquests_per_boss, null, null, null, "boss4");
	; QuestSpec q5 = new QuestSpec(midpoint, boss5, n_subquests_per_boss, null, null, null, "boss5");
	; List<AreaDivision> blocks2 = new ArrayList<>();
	; useable = reachableArea(tree, midpoint, blocks2);
	; reachable = reachableArea(tree, start, blocks2);
	; open = new ArrayList<>();
	; open.add(q4);
	; open.add(q5);
	; if (generateSubquests(w, tree, open, useable, reachable) == null) return false

	; // for the bosses 6 and 7, create "current reachable area" from some point in areas 10 and 11, and do the same:
	; QuestSpec q6 = new QuestSpec(teleporter_mars, boss6, 2, null, null, null, "boss6");
	; List<AreaDivision> blocks3 = new ArrayList<>();
	; useable = reachableArea(marsSpanningTree, teleporter_mars, blocks3);
	; reachable = reachableArea(marsSpanningTree, teleporter_mars, blocks3);
	; open = new ArrayList<>();
	; open.add(q6);
	; if (generateSubquests(w, marsSpanningTree, open, useable, reachable) == null) return false

	; QuestSpec q7 = new QuestSpec(teleporter_mars, boss7, 2, null, null, null, "boss7");
	; List<AreaDivision> blocks4 = new ArrayList<>();
	; useable = reachableArea(moonSpanningTree, teleporter_moon, blocks4);
	; reachable = reachableArea(moonSpanningTree, teleporter_moon, blocks4);
	; open = new ArrayList<>();
	; open.add(q7);
	; if (generateSubquests(w, moonSpanningTree, open, useable, reachable) == null) return false

	xor a  ; z
	ret


;-----------------------------------------------
; point offset #ff is ignored
PCG_WORLD__PUSH_QUEST: macro start_node_ptr, goal_node_ptr, n_subquests, start_point_offset, goal_point_offset, start_tag, goal_tag
	ld hl, tmp_pcg_world__quest_spec_open_list_size
	ld a, (hl)
	inc (hl)
	ld hl, tmp_pcg_world__quest_spec_open_list
IF QUEST_SPEC_STRUCTURE_SIZE != 9
	ERROR "QUEST_SPEC_STRUCTURE_SIZE != 9!"
ENDIF
	ld c, a
	add a, a
	add a, a
	add a, a
	add a, c
	ADD_HL_A

	ld de, (start_node_ptr)
	ld (hl), e
	inc hl
	ld (hl), d

	ld de, (goal_node_ptr)
	ld (hl), e
	inc hl
	ld (hl), d
	inc hl
	ld (hl), start_point_offset
	inc hl
	ld (hl), goal_point_offset
	inc hl
	ld (hl), start_tag
	inc hl
	ld (hl), goal_tag
	inc hl
	ld (hl), n_subquests
	endm


;-----------------------------------------------
; input:
; - ix: start node
; - iy: block
pcg_generate_world__reachable_nodes:
	xor a
	ld (tmp_pcg_world__useable_nodes_size), a
	ld hl, tmp_pcg_world__minimum_spanning_tree
	ld a, (tmp_pcg_world__minimum_spanning_tree_n_nodes)
	ld b, a
pcg_generate_world__reachable_nodes_loop:
	; check if the node is a child of "ix", without going through "iy"
	push bc
		push hl
pcg_generate_world__reachable_nodes_loop_parent_loop:
			ld c, ixl
			ld b, ixh
			or a
			sbc hl, bc
			jr z, pcg_generate_world__reachable_nodes_match
			add hl, bc
			ld c, iyl
			ld b, iyh
			or a
			sbc hl, bc
			jr z, pcg_generate_world__reachable_nodes_block
			add hl, bc

			ld bc, MST_PARENT_PTR
			add hl, bc
			ld a, (hl)
			inc hl
			ld h, (hl)
			ld l, a
			or h
			jr z, pcg_generate_world__reachable_nodes_block  ; we reached the top without crossing the start node
			jr pcg_generate_world__reachable_nodes_loop_parent_loop

pcg_generate_world__reachable_nodes_block:
		pop hl
pcg_generate_world__reachable_nodes_loop_next:
		ld bc, MST_STRUCTURE_SIZE
		add hl, bc
	pop bc
	djnz pcg_generate_world__reachable_nodes_loop
	ret	

pcg_generate_world__reachable_nodes_match:
		pop hl

		; add node to rechable:
		ex de, hl
			ld hl, tmp_pcg_world__reachable_nodes_size
			ld a, (hl)
			inc (hl)
			ld hl, tmp_pcg_world__reachable_nodes
			add a, a
			ADD_HL_A
			ld (hl), e
			inc hl
			ld (hl), d
		ex de, hl
		ld a, (hl)  ; mdl-watch: "reachable", a
		jr pcg_generate_world__reachable_nodes_loop_next


;-----------------------------------------------
; input:
; - c: lock tag
; - b: direction
pcg_generate_world__add_lock_direction:
	ld hl, tmp_pcg_world__lock_directions_size
	ld a, (hl)
	inc (hl)
	ld hl, tmp_pcg_world__lock_directions
	add a, a
	ADD_HL_A
	ld (hl), c
	inc hl
	ld (hl), b
	ret


;-----------------------------------------------
; Selects a random leaf on the minimum spanning tree, favoring leaves that
; have a higher depth.
; input:
; - ix: MST root node ptr
; - a: MST size
; - c: target area
; output:
; - hl: ptr to mst node
; - z: found one
; - nz: not found
pcg_generate_world__random_area_mst_node_only_leaves:
	ld b, a
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
	ld iyl, 0  ; current best depth
pcg_generate_world__random_area_mst_node_only_leaves_loop:
	ld a, (ix + MST_N_DESCENDANTS)
	or a
	jr nz, pcg_generate_world__random_area_mst_node_only_leaves_loop_next
	; leaf:
	ld a, (ix + MST_AREA_ID)
	cp c
	jr nz, pcg_generate_world__random_area_mst_node_only_leaves_loop_next
	ld a, (ix + MST_DEPTH)
	cp iyl
	jr c, pcg_generate_world__random_area_mst_node_only_leaves_loop_next
	jr z, pcg_generate_world__random_area_mst_node_only_leaves_same_depth
	; we found a deeper leaf, reset the list:
	ld iyl, a  ; new depth
	xor a
	ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_area_mst_node_only_leaves_same_depth:
	; new leaf, add to the list:
	ld hl, tmp_pcg_world__candidates_list_size
	ld a, (hl)
	inc (hl)
	add a, a
	ld hl, tmp_pcg_world__candidates_list
	ADD_HL_A
	ld a, ixl
	ld (hl), a
	inc hl
	ld a, ixh
	ld (hl), a

pcg_generate_world__random_area_mst_node_only_leaves_loop_next:
	ld de, MST_STRUCTURE_SIZE
	add ix, de
	djnz pcg_generate_world__random_area_mst_node_only_leaves_loop

	ld a, (tmp_pcg_world__candidates_list_size)
	or a
	jr z, pcg_generate_world__random_area_mst_node_only_leaves_fail

	ld c, a
	call random_modulo
	ld hl, tmp_pcg_world__candidates_list
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	xor a  ; z
	ld a, (hl)
	ret
pcg_generate_world__random_area_mst_node_only_leaves_fail:
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - a: tag
; - hl: mst note
; output:
; - z: all ok
; - nz: tag could not be added (too many tags in the division)
pcg_generate_world__add_tag_to_random_point_in_mst_node_division:
	; pick a random note from the division:
	ld b, a  ; tag
	push bc
	push hl
		call pcg_generate_world__random_division_point_from_mst_node_tagless
	pop de
	pop bc
	ret nz  ; no point available

	; add tag to the point:
	push de
		inc de
		ld a, (de)  ; area ID (since MST_AREA_ID == 1)
		; here l = offset of the point sampled above
		call pcg_generate_world__add_tag
	pop hl
	ret nz  ; we cannot add the tag
	
	; add tag to mst node:
	ld de, MST_TAG1
	add hl, de
	ld 	a, (hl)
	or a
	jr nz, pcg_generate_world__add_tag_to_random_point_in_mst_node_division_continue
	ld (hl), b  ; tag
	xor a  ; z
	ret
pcg_generate_world__add_tag_to_random_point_in_mst_node_division_continue:
	inc hl
	ld 	a, (hl)
	or a
	ret nz  ; node already has 2 tags, which is the max!
	ld (hl), b  ; tag
	xor a  ; z
	ret


;-----------------------------------------------
; input:
; - hl: ptr to mst node
; output:
; - c, b: x, y
; - l: offset
pcg_generate_world__random_division_point_from_mst_node_tagless:
	ld a, (hl)  ; division ID
	inc hl
	push af
		ld a, (hl)  ; area ID
		dec hl

		; get divisions and tags ptrs:
		; - tags: tmp_pcg_world__tags + MAX_AREA_SIZE * 2 * a 
		; - divisions: current_world__area_data + WORLD_AREA__SIZE * a + 4 + 1 + 1 + 1 + MAX_AREA_SIZE
		ld de, tmp_pcg_world__tags
		ld hl, current_world__area_data + 4 + 1
		or a
		jr z, pcg_generate_world__random_division_point_from_mst_node_tagless_ptrs_loop_done
pcg_generate_world__random_division_point_from_mst_node_tagless_ptrs_loop:
		ld bc, WORLD_AREA__SIZE
		add hl, bc
		ex hl, de
			ld bc, MAX_AREA_SIZE * 2
			add hl, bc
		ex hl, de
		dec a
		jr nz, pcg_generate_world__random_division_point_from_mst_node_tagless_ptrs_loop
pcg_generate_world__random_division_point_from_mst_node_tagless_ptrs_loop_done:
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
		ld (tmp_pcg_world__candidates_list_top), iy
		xor a
		ld (tmp_pcg_world__candidates_list_size), a
	pop af  ; recover the target division ID
	ld iyl, a  ; division ID we are after
pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_y:
	push bc
pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x:
		ld a, (hl)
		cp iyl  ; matches the division ID?
		jr nz, pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x_next
		; potential candidate, just check if it's tagless:
		ld a, (de)
		or a
		jr nz, pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x_next
		; add a candidate:
		push hl
			ld hl, (tmp_pcg_world__candidates_list_top)
			ld a, c
			sub ixl
			neg
			ld (hl), a  ; x
			inc hl
			ld a, b
			sub ixh
			neg
			ld (hl), a  ; y
			inc hl
			ld (tmp_pcg_world__candidates_list_top), hl
		pop hl
		ld a, (tmp_pcg_world__candidates_list_size)
		inc a
		ld (tmp_pcg_world__candidates_list_size), a
pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x_next:
		inc hl
		inc de
		inc de
		dec c
		jr nz, pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_x
	pop bc
	djnz pcg_generate_world__random_division_point_from_mst_node_tagless_candidates_loop_y
	jp pcg_generate_world__random_bottom_most_point_tagless_sample


;-----------------------------------------------
; input:
; - a: division ID
; output:
; - hl: ptr to mst node
pcg_generate_world__get_mst_node_by_division_id:
	ld hl, tmp_pcg_world__minimum_spanning_tree
	ld bc, MST_STRUCTURE_SIZE
pcg_generate_world__get_mst_node_by_division_id_loop:
	cp (hl)  ; since MST_DIVISION_ID == 0, we can just cp (hl).
	ret z
	add hl, bc
	jr pcg_generate_world__get_mst_node_by_division_id_loop


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
; input:
; - a: area
; - c, b: x, y
; output:
; - a: offset
pcg_generate_world__layout_offset_from_c_b_area:
	push bc
		call pcg_generate_world__get_area_ptr
		ld bc, 5
		add hl, bc
		ld a, (hl)  ; width
		ld ixl, a
	pop bc
	; jp pcg_generate_world__layout_offset_from_c_b_ixl


;-----------------------------------------------
; input:
; - ixl: width
; - c, b: x, y
; output:
; - a: offset
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


;-----------------------------------------------
; input:
; - a: area ID
; output:
; - hl: area ptr
pcg_generate_world__get_area_ptr:
	ld hl, current_world__area_data
	or a
	ret z
	ld bc, WORLD_AREA__SIZE
pcg_generate_world__get_area_ptr_loop:
	add hl, bc
	dec a
	jr nz, pcg_generate_world__get_area_ptr_loop
	ret

