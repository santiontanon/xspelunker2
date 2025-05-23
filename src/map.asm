;-----------------------------------------------
display_map_closeup:
	call display_map_draw_map_internal
	call wait_for_click
	xor a
	ld (keyboard_clicks), a

	ld hl, redraw_flags
	ld (hl), #ff
	ret


;-----------------------------------------------
map_teleporter_sprite_coordinates:
	db 24, 70  ; y, x (jungle)
	db 48, 40  ; inscriptions
	db 48, 112  ; hidden
	db 96, 76  ; inverted
	db 128, 46  ; caves left
	db 132, 111  ; caves right
	db 172, 76  ; fire
	db 152, 196  ; atlantis

map_teleporter_areas:
	db 0, 1, 2, 4, 6, 7, 8, 9


;-----------------------------------------------
display_map_from_teleporter:
	call display_map_draw_map_internal

	ld hl, dialog_sprites_bin
	ld de, SPRTBL2
	ld bc, dialog_sprites_bin_end - dialog_sprites_bin
	call fast_LDIRVM_from_sprites_page

	; draw markers for already active teleporters:
	ld hl, map_teleporter_sprite_coordinates
	ld de, buffer_4096
	ld b, 8
	ld ix, global_state__objects + TAG_TELEPORTER1
display_map_from_teleporter_sprite_position_loop:
	ld a, (ix)
	inc ix
	or a
	jr z, display_map_from_teleporter_sprite_position_loop_not_active
	ldi  ; y
	ldi  ; x
	ld a, 4
	ld (de), a
	inc de
	ld a, COLOR_WHITE
	ld (de), a
	inc de
	jr display_map_from_teleporter_sprite_position_loop_continue
display_map_from_teleporter_sprite_position_loop_not_active:
	ld a, 200
	ld (de), a
	inc de
	ld (de), a
	inc de
	ld (de), a
	inc de
	ld (de), a
	inc de
	inc hl
	inc hl
display_map_from_teleporter_sprite_position_loop_continue:
	djnz display_map_from_teleporter_sprite_position_loop

	; determine which teleporter are we on right now:
	ld hl, map_teleporter_areas
	ld a, (current_area__id)
	ld c, 0
display_map_from_teleporter_determine_teleporter_loop:
	cp (hl)
	jr z, display_map_from_teleporter_determine_teleporter_loop_end
	inc c
	inc hl
	jr display_map_from_teleporter_determine_teleporter_loop
display_map_from_teleporter_determine_teleporter_loop_end:
	ld a, c
	ld (tmp_map_pointer_position), a
	; set arrow sprite:
	ld hl, map_teleporter_sprite_coordinates
	ld b, 0
	add hl, bc
	add hl, bc
	ld a, (hl)  ; y
	inc a
	ld (de), a
	inc hl
	inc de
	ld a, (hl)  ; x
	sub 10
	ld (de), a
	inc de
	xor a  ; arrow sprite
	ld (de), a
	inc de
	ld a, COLOR_WHITE
	ld (de), a

	ld hl, buffer_4096
	ld de, SPRATR2
	ld b, 4*9
	call fast_small_LDIRVM

	; select an active teleporter:
display_map_from_teleporter_loop:
	halt
	call display_map_from_teleporter_update_sprites
	call update_keyboard_buffers

	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a
	jr nz, display_map_from_teleporter_loop_end
	bit KEY_JUMP_BIT, a
	jr nz, display_map_from_teleporter_loop_end
	bit KEY_INTERACT_BIT, a
	jr nz, display_map_from_teleporter_loop_end
	bit KEY_DOWN_BIT, a
	jp nz, display_map_from_teleporter_loop_next
	bit KEY_UP_BIT, a
	jp nz, display_map_from_teleporter_loop_prev
	bit KEY_LEFT_BIT, a
	jp nz, display_map_from_teleporter_loop_prev
	bit KEY_RIGHT_BIT, a
	jp nz, display_map_from_teleporter_loop_next
	jr display_map_from_teleporter_loop
display_map_from_teleporter_loop_end:

	xor a
	ld (keyboard_clicks), a

	ld hl, redraw_flags
	ld (hl), #ff

	ld b, 0
	ld c, a
	ld hl, map_teleporter_areas
	add hl, bc
	ld b, (hl)  ; area ID
	ld a, (tmp_map_pointer_position)
	add a, TAG_TELEPORTER1
	ld c, a  ; teleporter object ID

	ld hl, object_interaction_function_teleport_to_area_object
	ld a, TILES_PAGE
	jp jp_to_hl_in_page_a_8000

; 	; teleport:
; 	call disable_VDP_output
; 	ld a, (tmp_map_pointer_position)
; 	; load the area:
; 	push af
; 		ld b, 0
; 		ld c, a
; 		ld hl, map_teleporter_areas
; 		add hl, bc

; 		ld e, (hl)
; 		ld hl, pcg_generate_area
; 		ld c, PCG_PAGE
; 		call call_hl_in_page_c_8000
; 	pop af

; 	; get the room where the teleporter is:
; 	ld hl, current_area__objects
; 	add a, TAG_TELEPORTER1
; 	push af
; 		ld bc, AREA_OBJECT_STRUCT_SIZE
; display_map_from_teleporter_find_room_loop:
; 		cp (hl)
; 		jr z, display_map_from_teleporter_find_room_loop_found
; 		add hl, bc
; 		jr display_map_from_teleporter_find_room_loop
; display_map_from_teleporter_find_room_loop_found:
; 		inc hl
; 		ld a, (hl)  ; teleporter offset
; 		; convert offset from chunk coordinates to room coordinates:
; 		ld hl, covert_chunk_offset_to_room_offset
;       ld c, PCG_PAGE
;       ld e, a
;       call call_hl_in_page_c_8000
;       ld c, e
; 		ld hl, current_area__room_ids
; 		add hl, bc
; 		ld e, (hl)  ; room ID
; 		ld hl, pcg_generate_room
; 		ld c, PCG_PAGE
; 		call call_hl_in_page_c_8000
; 	pop af

; 	; find teleporter object, and set player in its position:
; 	ld e, a
; 	ld hl, find_tile_object_ptr
; 	ld c, TILES_PAGE
; 	call call_hl_in_page_c_8000
; 	push hl
; 	pop ix
; 	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
; 	inc a
; 	ld (player_x + 1), a
; 	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
; 	inc a
; 	ld (player_y + 1), a
; 	ld a, 6
; 	ld (player_x), a
; 	xor a
; 	ld (player_y), a
; 	ld (player_state_timer), a
; 	ld a, PLAYER_STATE_TELEPORT_IN
; 	ld (player_state), a
; 	ld a, 31  ; immune while teleporting
; 	ld (player_immunity_timer), a
	
; 	jp state_play_from_loaded_room


display_map_from_teleporter_color_cycle:
	db COLOR_WHITE, COLOR_LIGHT_BLUE, COLOR_BLUE, COLOR_DARK_BLUE
	db COLOR_DARK_BLUE, COLOR_BLUE, COLOR_LIGHT_BLUE, COLOR_WHITE

display_map_from_teleporter_update_sprites:
	; teleporter color animation:
	ld hl, SPRATR2 + 3
	ld b, 8
display_map_from_teleporter_update_sprites_loop:
	push bc
		push hl
			ld a, (interrupt_cycle)
			rrca
			rrca
			rrca
			and #07
			ld hl, display_map_from_teleporter_color_cycle
			ADD_HL_A
			ld a, (hl)
		pop hl
		push hl
			ld bc, 1
			call fast_FILVRM
		pop hl
		inc hl
		inc hl
		inc hl
		inc hl
	pop bc
	djnz display_map_from_teleporter_update_sprites_loop

	ld a, (interrupt_cycle)
	and #10
	jr z, display_map_from_teleporter_update_sprites_arrow_color_dark
	ld a, COLOR_WHITE
	jr display_map_from_teleporter_update_sprites_arrow_color_set
display_map_from_teleporter_update_sprites_arrow_color_dark:
	ld a, COLOR_BLUE
display_map_from_teleporter_update_sprites_arrow_color_set:
	ld hl, SPRATR2 + 8*4 + 3
	ld bc, 1
	call fast_FILVRM
	ret


display_map_from_teleporter_loop_next:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority

	ld a, (tmp_map_pointer_position)
	inc a
	and #07
	ld c, a
display_map_from_teleporter_loop_next_loop:
	ld hl, global_state__objects + TAG_TELEPORTER1
	ld b, 0
	add hl, bc
	ld a, (hl)
	or a
	jr nz, display_map_from_teleporter_loop_next_found
	ld a, c
	inc a
	and #07
	ld c, a
	jp display_map_from_teleporter_loop_next_loop
display_map_from_teleporter_loop_next_found:
	ld a, c
	ld (tmp_map_pointer_position), a
	ld hl, map_teleporter_sprite_coordinates
	add hl, bc
	add hl, bc
	ld a, (hl)  ; y
	inc a
	ld (buffer_4096 + 8*4), a
	inc hl
	ld a, (hl)  ; x
	sub 10
	ld (buffer_4096 + 8*4 + 1), a
	ld hl, buffer_4096 + 8*4
	ld de, SPRATR2 + 8*4
	ld b, 2
	call fast_small_LDIRVM
	jp display_map_from_teleporter_loop


display_map_from_teleporter_loop_prev:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority

	ld a, (tmp_map_pointer_position)
	dec a
	and #07
	ld c, a
display_map_from_teleporter_loop_prev_loop:
	ld hl, global_state__objects + TAG_TELEPORTER1
	ld b, 0
	add hl, bc
	ld a, (hl)
	or a
	jr nz, display_map_from_teleporter_loop_next_found
	ld a, c
	dec a
	and #07
	ld c, a
	jp display_map_from_teleporter_loop_prev_loop


;-----------------------------------------------
display_map_draw_map_internal:
	call disable_VDP_output
	    call clear_all_the_sprites
		xor a
		ld hl, NAMTBL2
		ld bc, 768
		call fast_FILVRM

		ld hl, map_tiles_bank1_zx0
		ld de, buffer_4096
		ld c, MAP_PAGE
		call dzx0_from_page_c

		ld hl, buffer_4096
		ld de, CHRTBL2
		ld bc, 256*8
		call fast_LDIRVM
		ld hl, buffer_4096 + 256*8
		ld de, CLRTBL2
		ld bc, 256*8
		call fast_LDIRVM

		ld hl, map_tiles_bank2_zx0
		ld de, buffer_4096
		ld c, MAP_PAGE
		call dzx0_from_page_c

		ld hl, buffer_4096
		ld de, CHRTBL2 + 256*8
		ld bc, 256*8
		call fast_LDIRVM
		ld hl, buffer_4096 + 256*8
		ld de, CLRTBL2 + 256*8
		ld bc, 256*8
		call fast_LDIRVM

		ld hl, map_tiles_bank3_zx0
		ld de, buffer_4096
		ld c, MAP_PAGE
		call dzx0_from_page_c

		ld hl, buffer_4096
		ld de, CHRTBL2 + 256*8*2
		ld bc, 256*8
		call fast_LDIRVM
		ld hl, buffer_4096 + 256*8
		ld de, CLRTBL2 + 256*8*2
		ld bc, 256*8
		call fast_LDIRVM	

		; draw the map pieces:
		; piece 0 is at 0, 0, size 32, 13
		ld hl, map_nametable_piece0_zx0
		ld de, NAMTBL2
		ld bc, #0d20
		call display_map_closeup_piece

		; piece 1 is at 10, 30, size 9, 5
		ld hl, map_nametable_piece1_zx0
		ld de, NAMTBL2 + 4*32 + 10
		ld bc, #0509
		ld a, (global_state__objects + TAG_MAP_PIECE1)
		or a
		call nz, display_map_closeup_piece

		; piece 2 is at 0, 9, size 19, 6
		ld hl, map_nametable_piece2_zx0
		ld de, NAMTBL2 + 9*32
		ld bc, #0613
		ld a, (global_state__objects + TAG_MAP_PIECE2)
		or a
		call nz, display_map_closeup_piece

		; piece 3 is at 0, 14, size 19, 10
		ld hl, map_nametable_piece3_zx0
		ld de, NAMTBL2 + 14*32
		ld bc, #0a13
		ld a, (global_state__objects + TAG_MAP_PIECE3)
		or a
		call nz, display_map_closeup_piece

		; piece 4 is at 5, 19, size 14, 5 
		ld hl, map_nametable_piece4_zx0
		ld de, NAMTBL2 + 19*32 + 5
		ld bc, #050e
		ld a, (global_state__objects + TAG_MAP_PIECE4)
		or a
		call nz, display_map_closeup_piece

		; piece 5 is at 19, 13, size 13, 11 
		ld hl, map_nametable_piece5_zx0
		ld de, NAMTBL2 + 13*32 + 19
		ld bc, #0b0d
		ld a, (global_state__objects + TAG_MAP_PIECE5)
		or a
		call nz, display_map_closeup_piece

		; piece 6 is at 19, 0, size 6, 10
		ld hl, map_nametable_piece6_zx0
		ld de, NAMTBL2 + 0*32 + 20
		ld bc, #0a06
		ld a, (global_state__objects + TAG_MAP_PIECE6)
		or a
		call nz, display_map_closeup_piece

		; piece 7 is at 25, 0, size 6, 10
		ld hl, map_nametable_piece7_zx0
		ld de, NAMTBL2 + 0*32 + 26
		ld bc, #0a06
		ld a, (global_state__objects + TAG_MAP_PIECE7)
		or a
		call nz, display_map_closeup_piece

    jp enable_VDP_output


;-----------------------------------------------
; input:
; - de: ptr in the name table to start drawing
; - c, b: width, height
display_map_closeup_piece:
	push de
	push bc
		ld de, buffer_4096
		ld c, MAP_PAGE
		call dzx0_from_page_c
	pop bc
	pop de
	ld hl, buffer_4096
display_map_closeup_piece_y_loop:
	push bc
		push bc
		push hl
			push de
				ld b, c
				call fast_small_LDIRVM_not_0
			pop hl
			ld bc, 32
			add hl, bc
			ld d, h
			ld e, l  ; next address to write to
		pop hl
		pop bc
		ld b, 0
		add hl, bc
	pop bc
	dec b
	jr nz, display_map_closeup_piece_y_loop
	ret


;-----------------------------------------------
; like 'fast_small_LDIRVM', except that it does not copy the 0s
fast_small_LDIRVM_not_0:
    ex de,hl    ; this is wasteful, but it's to maintain the order of parameters of the original LDIRVM...
                ; For things that require real speed, this function should not be used anyway,
                ; but use specialized loops.
    push de
        call SETWRT
    pop hl
    ; get the VDP write register:
    ld a, (VDP.DW)
    ld c, a
fast_small_LDIRVM_not_0_loop:
    ld a, (hl)
    inc hl
    or a
    jr z, fast_small_LDIRVM_not_0_loop_skip
    out (c), a
	dec b
    jp nz, fast_small_LDIRVM_not_0_loop
    ret

fast_small_LDIRVM_not_0_loop_skip:
	in a, (c)
	dec b
    jp nz, fast_small_LDIRVM_not_0_loop
    ret

