;-----------------------------------------------
; input:
; - de: ptr to tablet content fn
display_tablet:
	push de
		; clear the screen:
		call clear_all_the_sprites
		xor a
		ld hl, NAMTBL2
		ld bc, 768
		call fast_FILVRM

		; display base tablet:
		ld hl, tablet_tiles_zx0
		ld de, buffer_4096
		call dzx0

		ld hl, buffer_4096
		ld de, CHRTBL2
		ld bc, 256*8
		call fast_LDIRVM
		ld hl, buffer_4096 + 256*8
		ld de, CLRTBL2
		ld bc, 256*8
		call fast_LDIRVM

		ld hl, buffer_4096
		ld de, CHRTBL2 + 256*8
		ld bc, 256*8
		call fast_LDIRVM
		ld hl, buffer_4096 + 256*8
		ld de, CLRTBL2 + 256*8
		ld bc, 256*8
		call fast_LDIRVM

		ld hl, buffer_4096
		ld de, CHRTBL2 + 256*8*2
		ld bc, 256*8
		call fast_LDIRVM
		ld hl, buffer_4096 + 256*8
		ld de, CLRTBL2 + 256*8*2
		ld bc, 256*8
		call fast_LDIRVM	

		ld hl, tablet_nametable_zx0
		ld de, buffer_4096
		call dzx0

		ld hl, buffer_4096
		ld de, NAMTBL2
		ld bc, 768
		call fast_LDIRVM
	pop de

	; display the tablet content:
	ex hl, de
	ld bc, display_tablet_continue
	push bc
	jp (hl)
display_tablet_continue:

	call wait_for_click
	xor a
	ld (keyboard_clicks), a

	; restore in-game gfx:
	ld hl, redraw_flags
	ld (hl), #ff

	xor a
	ld hl, NAMTBL2
	ld bc, 768
	call fast_FILVRM

	ld a, (current_room__tileset_page)
	ld c, a
	ld hl, (current_room__tileset_ptr)
	jp setup_game_tiles


;-----------------------------------------------
combination_tablet_type_1_fn:
	ld hl, tablet_combination1_tiles_zx0
	jr combination_tablet_type_1_fn_continue

combination_tablet_type_2_fn:
	ld hl, tablet_combination2_tiles_zx0

combination_tablet_type_3_fn:
	ld hl, tablet_combination3_tiles_zx0
combination_tablet_type_1_fn_continue:
	call combination_tablet_load_extra_tiles

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	sub TAG_COMBINATION1_CLUE
	add a, a
	add a, a
	add a, a
	ld hl, current_world__combination_solutions
	ADD_HL_A  ; hl = ptr to the combination

	; draw the combination:
	ld b, 4
	ld de, NAMTBL2+9+7*32
combination_tablet_type_1_fn_loop1:
	push bc
		ld a, (hl)
		call combination_tablet_add_direction_symbol
		inc hl
		ex de, hl
			ld bc, 4
			add hl, bc
		ex de, hl
	pop bc
	djnz combination_tablet_type_1_fn_loop1

	ld b, 4
	ld de, NAMTBL2+9+12*32
combination_tablet_type_1_fn_loop2:
	push bc
		ld a, (hl)
		call combination_tablet_add_direction_symbol
		inc hl
		ex de, hl
			ld bc, 4
			add hl, bc
		ex de, hl
	pop bc
	djnz combination_tablet_type_1_fn_loop2
	ret


;-----------------------------------------------
; input:
; - de: name table ptr
; - a: direction
combination_tablet_add_direction_symbol:
	push hl
	push de
		ex de, hl
		or a
		jr z, combination_tablet_add_direction_symbol_left
		dec a
		jr z, combination_tablet_add_direction_symbol_up
combination_tablet_add_direction_symbol_right:
		ld e, 40
		jr combination_tablet_add_direction_symbol_continue
combination_tablet_add_direction_symbol_left:
		ld e, 32
		jr combination_tablet_add_direction_symbol_continue
combination_tablet_add_direction_symbol_up:
		ld e, 36
combination_tablet_add_direction_symbol_continue:
		ld a, e
		push hl
			ld b, 1
			call fast_FILVRM_small
		pop hl
		inc a
		inc hl
		push hl
			ld b, 1
			call fast_FILVRM_small
		pop hl
		inc a
		ld bc, 31
		add hl, bc
		push hl
			ld b, 1
			call fast_FILVRM_small
		pop hl
		inc a
		inc hl
		ld b, 1
		call fast_FILVRM_small
	pop de
	pop hl
	ret


;-----------------------------------------------
; input:
; - de: ptr to zx0-compressed extra tiles
combination_tablet_load_extra_tiles:
	ld de, buffer_4096
	call dzx0

	ld hl, buffer_4096
	ld de, CHRTBL2 + 32*8
	ld bc, 12*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 12*8
	ld de, CLRTBL2 + 32*8
	ld bc, 12*8
	call fast_LDIRVM

	ld hl, buffer_4096
	ld de, CHRTBL2 + 256*8 + 32*8
	ld bc, 12*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 12*8
	ld de, CLRTBL2 + 256*8 + 32*8
	ld bc, 12*8
	call fast_LDIRVM

	ld hl, buffer_4096
	ld de, CHRTBL2 + 256*8*2 + 32*8
	ld bc, 12*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 12*8
	ld de, CLRTBL2 + 256*8*2 + 32*8
	ld bc, 12*8
	jp fast_LDIRVM	


;-----------------------------------------------
combination_tablet_type_4_fn:
	ld hl, TEXT_COMBINATION_CLUE1
	ld de, CHRTBL2 + 48*8
	ld bc, NAMTBL2 + 10 + 7*32
	ld a, 48
	call combination_tablet_print_line_12

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	sub TAG_COMBINATION1_CLUE
	add a, a
	add a, a
	add a, a
	ld hl, current_world__combination_solutions
	ADD_HL_A  ; hl = ptr to the combination

	ld bc, NAMTBL2 + 10 + 8*32
	ld de, CHRTBL2 + 256*8 + 64*8
	ld a, 64
	ld iyl, 8
combination_tablet_type_4_fn_loop1:
	push iy
	push hl
		push bc
			push de
			push af
				ld a, (hl)
				or a
				jr z, combination_tablet_type_4_fn_left
				dec a
				jr z, combination_tablet_type_4_fn_up
combination_tablet_type_4_fn_right:
				ld hl, TEXT_COMBINATION_CLUE4
				jr combination_tablet_type_4_fn_continue
combination_tablet_type_4_fn_left:
				ld hl, TEXT_COMBINATION_CLUE2
				jr combination_tablet_type_4_fn_continue
combination_tablet_type_4_fn_up:
				ld hl, TEXT_COMBINATION_CLUE3
combination_tablet_type_4_fn_continue:
			pop af
			pop de
			push af
				push de
					call combination_tablet_print_line_12
				pop hl
				ld bc, 12*8
				add hl, bc
				ex de, hl
			pop af
		pop bc
		ld hl, 32
		add hl, bc
		ld c, l
		ld b, h
	pop hl
	pop iy
	inc hl
	add a, 12
	dec iyl
	jr nz, combination_tablet_type_4_fn_loop1
	ret



;-----------------------------------------------
trial_tablet_fn:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	sub TAG_TRIAL1_CLUE
	ld hl, current_world__trial_types
	ADD_HL_A
	ld a, (hl)  ; a = type of message to display
	
	ld hl, trial_tablet_messages
	add a, a
	ld c, a
	ld b, 0
	add hl, bc
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a  ; ptr to base message

	; concatenate message + god name:
	ld de, buffer_4096
	ld c, (hl)
	inc c
	ld b, 0
	ldir
	push de
		ld hl, trial_tablet_message_godnames
		ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
		sub TAG_TRIAL1_CLUE
		add a, a
		ld c, a
		ld b, 0
		add hl, bc
		ld a, (hl)
		inc hl
		ld h, (hl)
		ld l, a  ; ptr to god name
		ld a, (buffer_4096)
		add a, (hl)  ; length of god name
		ld (buffer_4096), a
	pop de
	ld b, 0
	ld c, (hl)
	inc hl
	ldir

	ld hl, buffer_4096

	ld bc, NAMTBL2 + 9 + 8*32
	ld (buffer_4096 + 1024), bc
	ld de, CHRTBL2 + (256 + 48)*8
	ld (buffer_4096 + 1026), de
	ld a, 48
	ld (buffer_4096 + 1028), a

	; Print splitting the line:
trial_tablet_fn_loop:
	push hl
		ld iyl, 12*8
		call max_length_of_sentence_in_one_line
	pop hl
	ld c, (hl)  ; original length
    push bc
    push hl
		ld (hl), a  ; max length
		ld bc, (buffer_4096 + 1024)
		ld de, (buffer_4096 + 1026)
		ld a, (buffer_4096 + 1028)
		call combination_tablet_print_line_12
	pop hl
	pop bc
    ld a, c
	sub (hl)  ; left-over length
	ret z
	ld c, (hl)
	ld b, 0
    add hl, bc  ; we advance hl to the remainder of the sentence
    ld (hl), a  ; left-over length
    push hl
    	; next line:
    	ld hl, (buffer_4096 + 1024)
    	ld bc, 32
    	add hl, bc
    	ld (buffer_4096 + 1024), hl
    	ld hl, (buffer_4096 + 1026)
    	ld bc, 12*8
    	add hl, bc
    	ld (buffer_4096 + 1026), hl
    	ld a, (buffer_4096 + 1028)
    	add a, 12
    	ld (buffer_4096 + 1028), a
    pop hl
	jr trial_tablet_fn_loop


trial_tablet_message_godnames:
	dw TEXT_TRIAL_CLUE_GODNAME1
	dw TEXT_TRIAL_CLUE_GODNAME2
	dw TEXT_TRIAL_CLUE_GODNAME3
	dw TEXT_TRIAL_CLUE_GODNAME4

trial_tablet_messages:
	dw TEXT_TRIAL_CLUE1
	dw TEXT_TRIAL_CLUE2
	dw TEXT_TRIAL_CLUE3
	dw TEXT_TRIAL_CLUE4
	dw TEXT_TRIAL_CLUE5
	dw TEXT_TRIAL_CLUE6
	dw TEXT_TRIAL_CLUE7
	dw TEXT_TRIAL_CLUE8


;-----------------------------------------------
; input:
; - bc: NAMTBL2 ptr
; - hl: text
; - de: CHRTBL2 ptr
; - a: first tile number
combination_tablet_print_line_12:
	push bc
	push af
		push de
		push hl
			call clear_text_rendering_buffer
		pop hl
		pop de
		ld iy, #800e
		ld b, 12
		call draw_sentence_to_vdp
	pop af
	pop hl
    push af
        call SETWRT
        ld a, (VDP.DW)
        ld c, a
    pop af
    ld b, 12
combination_tablet_print_line_12_loop:
    out (c), a
    inc a
    dec b
    jp nz, combination_tablet_print_line_12_loop
	ret
