;-----------------------------------------------
; input:
; - de: ptr to tablet content fn
display_tablet:
	call disable_VDP_output
	push de
		; clear the screen:
		call clear_all_the_sprites
		xor a
		ld hl, NAMTBL2
		ld bc, 768
		call fast_FILVRM

		; display base tablet:
		ld hl, tablet_tiles_zx0
		ld de, tablet_nametable_zx0
		ld c, TABLET_LETTER_PAGE
display_tablet_ptrs_set:
		push de
		push bc
			ld de, buffer_4096
			call dzx0_from_page_c

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

		pop bc
		pop hl
		ld de, buffer_4096
		call dzx0_from_page_c

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

	call enable_VDP_output

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
calendar_tablet_fn:
	pop bc  ; simulate a ret
	ld de, calendar_tablet_fn2
	push de
		ld hl, tablet_calendar_tiles_zx0
		ld de, tablet_calendar_nametable_zx0
		ld c, TABLET_LETTER_PAGE
		jp display_tablet_ptrs_set


;-----------------------------------------------
calendar_tablet_fn2:
	ld hl, TEXT_CALENDAR_TABLET1
	ld de, CHRTBL2 + 22*32*8 + 8
	ld iy, #80f0
	ld b, 32
	call draw_sentence_to_vdp_from_another_page
	ld hl, TEXT_CALENDAR_TABLET2
	ld de, CHRTBL2 + 23*32*8 + 2*8
	ld iy, #80f0
	ld b, 32
	jp draw_sentence_to_vdp_from_another_page


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
			call fast_small_FILVRM
		pop hl
		inc a
		inc hl
		push hl
			ld b, 1
			call fast_small_FILVRM
		pop hl
		inc a
		ld bc, 31
		add hl, bc
		push hl
			ld b, 1
			call fast_small_FILVRM
		pop hl
		inc a
		inc hl
		ld b, 1
		call fast_small_FILVRM
	pop de
	pop hl
	ret


;-----------------------------------------------
; input:
; - de: ptr to zx0-compressed extra tiles
combination_tablet_load_extra_tiles:
	ld de, buffer_4096
	ld c, TABLET_LETTER_PAGE
	call dzx0_from_page_c

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
	
	push ix
		ld hl, trial_tablet_messages
		add a, a
		ld c, a
		ld b, 0
		add hl, bc
		ld a, (hl)
		ld ixl, a
		inc hl
		ld a, (hl)
		ld ixh, a  ; ptr to base message
		ld hl, copy_ix_text_to_buffer_4096
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop ix

	; concatenate message + god name:
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
	pop de
	push de
		push hl
		pop ix
		ld hl, copy_ix_text_to_de
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop hl
	; update text length, and move the godname one position to the left (remove the length on that part of the sentence):
	ld a, (buffer_4096)
	add a, (hl)
	ld (buffer_4096), a
	ld c, (hl)
	ld d, h
	ld e, l
	inc hl
	ld b, 0
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
		push hl
		pop ix
		ld hl, max_length_of_sentence_in_one_line_ix
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
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
		ld iy, #800e
		ld b, 12
		call draw_sentence_to_vdp_from_another_page
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


;-----------------------------------------------
maya_puzzle_tablet_fn:
	call maya_puzzle_tablet_fn_load_extra_tiles

	; display the maya puzzle tiles:
	ld hl, NAMTBL2 + 8 + 7*32
	ld ix, current_world__maya_puzzle_riddles
	call maya_puzzle_tablet_fn_draw_line

	ld hl, NAMTBL2 + 8 + 15*32
	ld ix, current_world__maya_puzzle_riddles + 3
	; jp maya_puzzle_tablet_fn_draw_line
	; ret


;-----------------------------------------------
; input:
; - ix: ptr to the line
; - hl: nametable ptr where to start drawing
maya_puzzle_tablet_fn_draw_line:
	push hl
		ld hl, maya_puzzle_tablet_fn_draw_line_table1
		ld b, 0
		ld c, (ix)
		add hl, bc
		add hl, bc
		ld e, (hl)
		inc hl
		ld d, (hl)
	pop hl
	call maya_puzzle_tablet_fn_draw_line_concept
	push hl
		ld hl, maya_puzzle_tablet_fn_draw_line_table2
		ld b, 0
		ld c, (ix + 1)
		add hl, bc
		add hl, bc
		ld e, (hl)
		inc hl
		ld d, (hl)
	pop hl
	call maya_puzzle_tablet_fn_draw_line_concept
	push hl
		ld hl, maya_puzzle_tablet_fn_draw_line_table3
		ld b, 0
		ld c, (ix + 2)
		dec c
		dec c
		add hl, bc
		add hl, bc
		ld e, (hl)
		inc hl
		ld d, (hl)
	pop hl
	jp maya_puzzle_tablet_fn_draw_line_concept

maya_puzzle_tablet_fn_draw_line_concept:
	ld a, (de)  ; n characters to draw
	inc de
maya_puzzle_tablet_fn_draw_line_loop1:	
	push af
		; check if we need to jump to a new line:
		ld a, l
		ex de, hl
			add a, (hl)  ; add width
		ex de, hl
		and #1f  ; x coordinate
		cp 25
		jr c, maya_puzzle_tablet_fn_draw_line_loop1_continue
		; we need to go to the next line:
		ld a, l
		and #e0
		add a, 8
		ld l, a
		ld a, 128
		ADD_HL_A
maya_puzzle_tablet_fn_draw_line_loop1_continue:
		ld a, (de)  ; width
		inc de
		ld b, a
		ld a, (de)  ; first tile
		inc de
		push de
		push hl
		push bc
			ld e, a
			call maya_puzzle_tablet_fn_draw_glyph
		pop bc
		pop hl
		pop de
		ld c, b
		ld b, 0
		add hl, bc
	pop af
	dec a
	jr nz, maya_puzzle_tablet_fn_draw_line_loop1
	ret


maya_puzzle_tablet_fn_draw_line_table1:
	dw maya_puzzle_tablet_fn_draw_line_table_strike
	dw maya_puzzle_tablet_fn_draw_line_table_strike_east
	dw maya_puzzle_tablet_fn_draw_line_table_strike_west
	dw maya_puzzle_tablet_fn_draw_line_table_sit
	dw maya_puzzle_tablet_fn_draw_line_table_sit_east
	dw maya_puzzle_tablet_fn_draw_line_table_sit_west
	dw maya_puzzle_tablet_fn_draw_line_table_blowgun
	dw maya_puzzle_tablet_fn_draw_line_table_blowgun_east
	dw maya_puzzle_tablet_fn_draw_line_table_blowgun_west
	dw maya_puzzle_tablet_fn_draw_line_table_standup_we
	dw maya_puzzle_tablet_fn_draw_line_table_standup_ew
	dw maya_puzzle_tablet_fn_draw_line_table_ascend

maya_puzzle_tablet_fn_draw_line_table2:
	dw maya_puzzle_tablet_fn_draw_line_table_here
	dw maya_puzzle_tablet_fn_draw_line_table_below_jaguar
	dw maya_puzzle_tablet_fn_draw_line_table_above_jaguar
	dw maya_puzzle_tablet_fn_draw_line_table_below_snake
	dw maya_puzzle_tablet_fn_draw_line_table_above_snake
	dw maya_puzzle_tablet_fn_draw_line_table_below_eagle
	dw maya_puzzle_tablet_fn_draw_line_table_above_eagle
	dw maya_puzzle_tablet_fn_draw_line_table_below_fish
	dw maya_puzzle_tablet_fn_draw_line_table_above_fish
	dw maya_puzzle_tablet_fn_draw_line_table_below_ladder
	dw maya_puzzle_tablet_fn_draw_line_table_ladder

maya_puzzle_tablet_fn_draw_line_table3:
	dw maya_puzzle_tablet_fn_draw_line_table_number_2
	dw maya_puzzle_tablet_fn_draw_line_table_number_3
	dw maya_puzzle_tablet_fn_draw_line_table_number_4
	dw maya_puzzle_tablet_fn_draw_line_table_number_5
	dw maya_puzzle_tablet_fn_draw_line_table_number_6

maya_puzzle_tablet_fn_draw_line_table_strike:
	db 1, 3, 32
maya_puzzle_tablet_fn_draw_line_table_strike_east:
	db 2, 3, 32, 3, 80
maya_puzzle_tablet_fn_draw_line_table_strike_west:
	db 2, 3, 32, 2, 46
maya_puzzle_tablet_fn_draw_line_table_sit:
	db 1, 3, 35
maya_puzzle_tablet_fn_draw_line_table_sit_east:
	db 2, 3, 35, 3, 80
maya_puzzle_tablet_fn_draw_line_table_sit_west:
	db 2, 3, 35, 2, 46
maya_puzzle_tablet_fn_draw_line_table_blowgun:
	db 1, 2, 44
maya_puzzle_tablet_fn_draw_line_table_blowgun_east:
	db 2, 2, 44, 3, 80
maya_puzzle_tablet_fn_draw_line_table_blowgun_west:
	db 2, 2, 44, 2, 46
maya_puzzle_tablet_fn_draw_line_table_standup_we:
	db 4, 3, 41, 2, 46, 3, 41, 3, 80
maya_puzzle_tablet_fn_draw_line_table_standup_ew:
	db 4, 3, 41, 3, 80, 3, 41, 2, 46
maya_puzzle_tablet_fn_draw_line_table_ascend:
	db 1, 3, 38
maya_puzzle_tablet_fn_draw_line_table_here:
	db 1, 6, 86
maya_puzzle_tablet_fn_draw_line_table_below_jaguar:
	db 2, 5, 128, 3, 136
maya_puzzle_tablet_fn_draw_line_table_above_jaguar:
	db 2, 3, 83, 3, 136
maya_puzzle_tablet_fn_draw_line_table_below_snake:
	db 2, 5, 128, 3, 139
maya_puzzle_tablet_fn_draw_line_table_above_snake:
	db 2, 3, 83, 3, 139
maya_puzzle_tablet_fn_draw_line_table_below_eagle:
	db 2, 5, 128, 4, 176
maya_puzzle_tablet_fn_draw_line_table_above_eagle:
	db 2, 3, 83, 4, 176
maya_puzzle_tablet_fn_draw_line_table_below_fish:
	db 2, 5, 128, 3, 180
maya_puzzle_tablet_fn_draw_line_table_above_fish:
	db 2, 3, 83, 3, 180
maya_puzzle_tablet_fn_draw_line_table_below_ladder:
	db 2, 5, 128, 3, 133
maya_puzzle_tablet_fn_draw_line_table_ladder:
	db 1, 3, 133
maya_puzzle_tablet_fn_draw_line_table_number_2:
	db 1, 1, 184
maya_puzzle_tablet_fn_draw_line_table_number_3:
	db 1, 1, 185
maya_puzzle_tablet_fn_draw_line_table_number_4:
	db 1, 1, 186
maya_puzzle_tablet_fn_draw_line_table_number_5:
	db 1, 1, 187
maya_puzzle_tablet_fn_draw_line_table_number_6:
	db 2, 1, 183, 1, 187


;-----------------------------------------------
; input:
; - hl: ptr to name table where to draw
; - b: width
; - e: top-left tile
maya_puzzle_tablet_fn_draw_glyph:
	ld a, 3
maya_puzzle_tablet_fn_draw_glyph_loop_y:
	push af
	push bc
		push hl
			push bc
				call SETWRT
			pop bc
		    ld a, (VDP.DW)
		    ld c, a
		    push de
maya_puzzle_tablet_fn_draw_glyph_loop_x:
			    out (c), e
			    inc e
			    djnz maya_puzzle_tablet_fn_draw_glyph_loop_x
			pop de
			ld a, 16
			add a, e
			ld e, a 
		pop hl
		ld bc, 32
		add hl, bc
	pop bc
	pop af
	dec a
	jr nz, maya_puzzle_tablet_fn_draw_glyph_loop_y
	ret


;-----------------------------------------------
maya_puzzle_tablet_fn_load_extra_tiles:
	ld hl, tablet_maya_riddle_tiles_zx0
	ld c, TILES_MAYA_RIDDLE_PAGE
maya_puzzle_tablet_fn_load_extra_tiles_hl_set:
	ld de, buffer_4096
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, CHRTBL2 + 32*8
	ld bc, 192*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 192*8
	ld de, CLRTBL2 + 32*8
	ld bc, 192*8
	call fast_LDIRVM

	ld hl, buffer_4096
	ld de, CHRTBL2 + 256*8 + 32*8
	ld bc, 192*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 192*8
	ld de, CLRTBL2 + 256*8 + 32*8
	ld bc, 192*8
	call fast_LDIRVM

	ld hl, buffer_4096
	ld de, CHRTBL2 + 256*8*2 + 32*8
	ld bc, 192*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 192*8
	ld de, CLRTBL2 + 256*8*2 + 32*8
	ld bc, 192*8
	jp fast_LDIRVM	


;-----------------------------------------------
maya_clue1_tablet_fn:
	ld hl, tablet_maya1_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set

	ld hl, tablet_maya1_nametable_zx0
	ld de, buffer_4096
	ld c, TABLET_LETTER_PAGE
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	call fast_LDIRVM

	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_MAYA1_LINE1
	ld a, 91
	ld de, NAMTBL2 + (7 + 6*32)
	ld ix, CHRTBL2
	call display_paragraph	

	ld hl, TEXT_TABLET_MAYA1_LINE2
	ld a, 91
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph	

	ld a, 16
	ld (tmp_letter_line_width), a

	ld hl, TEXT_TABLET_MAYA1_LINE3
	ld a, 91 + 2*18
	ld de, NAMTBL2 + (7 + 15*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph	

	ld hl, TEXT_TABLET_MAYA1_LINE4
	ld a, 91
	ld de, NAMTBL2 + (7 + 16*32)
	ld ix, CHRTBL2 + 256*8*2
	call display_paragraph	

	ld a, 18
	ld (tmp_letter_line_width), a

	ld hl, TEXT_TABLET_MAYA1_LINE5
	ld a, 91 + 2*16
	ld de, NAMTBL2 + (7 + 19*32)
	call display_paragraph	

	ld a, 2
	ld (tmp_letter_line_width), a
	ld hl, TEXT_KE
	ld a, 91 + 2*16 + 18
	ld de, NAMTBL2 + (10 + 22*32)
	call display_paragraph	

	ld hl, TEXT_KI
	ld a, 91 + 2*16 + 18 + 2 
	ld de, NAMTBL2 + (16 + 23*32)
	call display_paragraph	

	ld hl, TEXT_SE
	ld a, 91 + 2*16 + 18 + 4 
	ld de, NAMTBL2 + (23 + 23*32)
	jp display_paragraph	


;-----------------------------------------------
maya_clue2_tablet_fn:
	ld hl, tablet_maya2_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set

	ld hl, tablet_maya2_nametable_zx0
	ld de, buffer_4096
	ld c, TABLET_LETTER_PAGE
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	call fast_LDIRVM

	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_MAYA2_LINE1
	ld a, 126
	ld de, NAMTBL2 + (7 + 6*32)
	ld ix, CHRTBL2
	call display_paragraph

	ld hl, TEXT_TABLET_MAYA2_LINE2
	ld a, 126
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 8*256
	jp display_paragraph


;-----------------------------------------------
maya_clue3_tablet_fn:
	ld hl, tablet_maya3_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set

	ld hl, tablet_maya3_nametable_zx0
	ld de, buffer_4096
	ld c, TABLET_LETTER_PAGE
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	call fast_LDIRVM

	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_MAYA3_LINE1
	ld a, 126
	ld de, NAMTBL2 + (7 + 5*32)
	ld ix, CHRTBL2
	call display_paragraph

	ld hl, TEXT_TABLET_MAYA3_LINE2
	ld a, 126
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 8*256
	jp display_paragraph	


;-----------------------------------------------
maya_clue4_tablet_fn:
	ld hl, tablet_maya4_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set

	ld hl, tablet_maya4_nametable_zx0
	ld de, buffer_4096
	ld c, TABLET_LETTER_PAGE
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	call fast_LDIRVM

	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_MAYA4_LINE1
	ld a, 60
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph

	ld a, 2
	ld (tmp_letter_line_width), a
	ld hl, TEXT_PE
	ld a, 60 + 18*3
	ld de, NAMTBL2 + (13 + 13*32)
	call display_paragraph

	ld hl, TEXT_LU
	ld a, 60 + 18*3 + 2
	ld de, NAMTBL2 + (22 + 13*32)
	call display_paragraph

	ld hl, TEXT_LE
	ld a, 60
	ld de, NAMTBL2 + (13 + 16*32)
	ld ix, CHRTBL2 + 256*8*2
	call display_paragraph

	ld hl, TEXT_NE
	ld a, 60 + 2
	ld de, NAMTBL2 + (22 + 16*32)
	ld ix, CHRTBL2 + 256*8*2
	jp display_paragraph


;-----------------------------------------------
maya_clue5_tablet_fn:
	ld hl, tablet_maya5_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set

	ld hl, tablet_maya5_nametable_zx0
	ld de, buffer_4096
	ld c, TABLET_LETTER_PAGE
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	call fast_LDIRVM

	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_MAYA5_LINE1
	ld a, 60  ; first tile to use
	ld de, NAMTBL2 + (7 + 6*32)
	ld ix, CHRTBL2
	call display_paragraph_page7

	ld hl, TEXT_TABLET_MAYA5_LINE2
	ld a, 60
	ld de, NAMTBL2 + (7 + 9*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph_page7

	ld hl, TEXT_TABLET_MAYA5_LINE3
	ld a, 150
	ld de, NAMTBL2 + (7 + 14*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph_page7

	; ...

	ret


;-----------------------------------------------
calendar_name_clue_tablet_fn:
	ld hl, tablet_maya_syllable_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set

	; render the word:
	ld hl, current_world__maya_puzzle3_nametable
	ld de, NAMTBL2 + 9*32 + 11
	ld b, 10
	call fast_small_LDIRVM

	ld hl, current_world__maya_puzzle3_nametable + 10
	ld de, NAMTBL2 + 10*32 + 11
	ld b, 10
	call fast_small_LDIRVM

	ld hl, current_world__maya_puzzle3_nametable + 20
	ld de, NAMTBL2 + 11*32 + 11
	ld b, 10
	call fast_small_LDIRVM


	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_CALENDAR_NAME_CLUE
	ld a, 176
	ld de, NAMTBL2 + (7 + 5*32)
	ld ix, CHRTBL2
	jp display_paragraph


; ------------------------------------------------
copy_ix_text_page7_to_buffer_4096:
	push ix
	pop hl
	ld de, buffer_4096
	ld c, (hl)
	ld b, 0
	inc c
	ldir
	ret


;-----------------------------------------------
story_trivia_tablet_number_1:
	db 32, 31, 31, 31
story_trivia_tablet_number_2:
	db 33, 31, 31, 31
story_trivia_tablet_number_3:
	db 32, 31, 33, 31
story_trivia_tablet_number_4:
	db 33, 31, 33, 31
story_trivia_tablet_number_5:
	db 34, 31, 34, 31
story_trivia_tablet_number_6:
	db 35, 34, 36, 34
story_trivia_tablet_number_7:
	db 32, 34, 37, 34
story_trivia_tablet_number_8:
	db 38, 34, 39, 34
story_trivia_tablet_number_9:
	db 33, 34, 33, 34
story_trivia_tablet_number_10:
	db 34, 34, 34, 34
story_trivia_tablet_number_11:
	db 35, 40, 36, 40
story_trivia_tablet_number_12:
	db 32, 40, 37, 40
story_trivia_tablet_number_13:
	db 38, 40, 39, 40
story_trivia_tablet_number_14:
	db 33, 40, 33, 40
story_trivia_tablet_number_15:
	db 34, 40, 34, 40


story_trivia_tablet_fn_story1:
	ld hl, tablet_trivia_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set

	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_TRIVIA1_1
	ld a, 48
	ld de, NAMTBL2 + (7 + 5*32)
	ld ix, CHRTBL2
	call display_paragraph_page7

	ld hl, TEXT_TABLET_TRIVIA1_2
	ld a, 48
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph_page7

	ld hl, TEXT_TABLET_TRIVIA1_3
	ld a, 48 + 18*4
	ld de, NAMTBL2 + (7 + 13*32)
	call display_paragraph_page7

	ld hl, TEXT_TABLET_TRIVIA1_4
	ld a, 48
	ld de, NAMTBL2 + (7 + 16*32)
	ld ix, CHRTBL2 + 256*8*2
	call display_paragraph_page7

	ld hl, story_trivia_tablet_number_1
	jp story_trivia_tablet_fn_story3_draw_numbers


story_trivia_tablet_fn_story2:
	ld hl, tablet_trivia_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set

	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_TRIVIA2_1
	ld a, 48
	ld de, NAMTBL2 + (7 + 5*32)
	ld ix, CHRTBL2
	call display_paragraph_page7

	ld hl, TEXT_TABLET_TRIVIA2_2
	ld a, 48
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph_page7

	ld hl, TEXT_TABLET_TRIVIA2_3
	ld a, 48 + 18*5
	ld de, NAMTBL2 + (7 + 13*32)
	call display_paragraph_page7

	ld hl, story_trivia_tablet_number_2
	jp story_trivia_tablet_fn_story3_draw_numbers


story_trivia_tablet_fn_story3:
	ld hl, TEXT_TABLET_TRIVIA3_2
	ld de, story_trivia_tablet_number_3
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA3_1
story_trivia_tablet_fn_story3_entrypoint:
			push hl
				ld hl, tablet_trivia_tiles_zx0
				ld c, TABLET_LETTER_PAGE
				call maya_puzzle_tablet_fn_load_extra_tiles_hl_set
			pop hl

			ld a, 18
			ld (tmp_letter_line_width), a
			ld a, COLOR_GREY
			ld (tmp_letter_line_color), a

			ld a, 48
			ld de, NAMTBL2 + (7 + 5*32)
			ld ix, CHRTBL2
			call display_paragraph_page7
		pop hl
		ld a, 48
		ld de, NAMTBL2 + (7 + 8*32)
		ld ix, CHRTBL2 + 256*8
		call display_paragraph_page7
	pop hl
story_trivia_tablet_fn_story3_draw_numbers:
	; draw numbers:
	ld a, h  ; in case we don't want to draw a number
	or a
	ret z
	push hl
		ld de, NAMTBL2 + 23 + 21*32
		ld b, 2
		call fast_small_LDIRVM 
	pop hl
	inc hl
	inc hl
	ld de, NAMTBL2 + 23 + 22*32
	ld b, 2
	jp fast_small_LDIRVM 


story_trivia_tablet_fn_story4:
	ld hl, TEXT_TABLET_TRIVIA4_2
	ld de, story_trivia_tablet_number_4
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA4_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story5:
	ld hl, TEXT_TABLET_TRIVIA5_2
	ld de, story_trivia_tablet_number_5
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA5_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story6:
	ld hl, TEXT_TABLET_TRIVIA6_2
	ld de, story_trivia_tablet_number_6
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA6_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story7:
	ld hl, TEXT_TABLET_TRIVIA7_2
	ld de, story_trivia_tablet_number_7
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA7_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story8:
	ld hl, TEXT_TABLET_TRIVIA8_2
	ld de, story_trivia_tablet_number_8
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA8_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story9:
	ld hl, TEXT_TABLET_TRIVIA9_2
	ld de, story_trivia_tablet_number_9
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA9_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story10:
	ld hl, TEXT_TABLET_TRIVIA10_2
	ld de, story_trivia_tablet_number_10
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA10_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story11:
	ld hl, TEXT_TABLET_TRIVIA11_2
	ld de, story_trivia_tablet_number_11
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA11_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story12:
	ld hl, TEXT_TABLET_TRIVIA12_2
	ld de, story_trivia_tablet_number_12
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA12_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story13:
	ld hl, TEXT_TABLET_TRIVIA13_2
	ld de, story_trivia_tablet_number_13
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA13_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story14:
	ld hl, TEXT_TABLET_TRIVIA14_2
	ld de, story_trivia_tablet_number_14
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA14_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_story15:
	ld hl, TEXT_TABLET_TRIVIA15_2
	ld de, story_trivia_tablet_number_15
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA15_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_clue1:
	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a

	ld hl, TEXT_TABLET_TRIVIA_CLUE1_1
	ld a, 32
	ld de, NAMTBL2 + (7 + 5*32)
	ld ix, CHRTBL2
	jp display_paragraph_page7


story_trivia_tablet_fn_clue2:
	ld hl, TEXT_TABLET_TRIVIA_CLUE2_2
	ld de, 0
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA_CLUE2_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_clue3:
	ld hl, TEXT_TABLET_TRIVIA_CLUE3_2
	ld de, 0
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA_CLUE3_1
			jp story_trivia_tablet_fn_story3_entrypoint


story_trivia_tablet_fn_clue4:
	ld hl, TEXT_TABLET_TRIVIA_CLUE4_2
	ld de, 0
	push de
		push hl
			ld hl, TEXT_TABLET_TRIVIA_CLUE4_1
			jp story_trivia_tablet_fn_story3_entrypoint


;-----------------------------------------------
xibalba_boss_grave_fn_tbl:
	dw TEXT_XIBALBA_BOSS_NAME_1
	dw TEXT_XIBALBA_BOSS_NAME_2
	dw TEXT_XIBALBA_BOSS_NAME_3
	dw TEXT_XIBALBA_BOSS_NAME_4
	dw TEXT_XIBALBA_BOSS_NAME_5
	dw TEXT_XIBALBA_BOSS_NAME_6
	dw TEXT_XIBALBA_BOSS_NAME_7
	dw TEXT_XIBALBA_BOSS_NAME_8
	dw TEXT_XIBALBA_BOSS_NAME_9
	dw TEXT_XIBALBA_BOSS_NAME_10
	dw TEXT_XIBALBA_BOSS_NAME_11
	dw TEXT_XIBALBA_BOSS_NAME_12

xibalba_boss_grave_fn:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	add a, a
	ld hl, xibalba_boss_grave_fn_tbl - 2  ; "-2" as "a" starts at 1
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld hl, 0
	jr xibalba_tablet_fn_continue


;-----------------------------------------------
xibalba_boss_tablet_fn:
	ld de, TEXT_XIBALBA_BOSS_TABLET_1
	ld hl, TEXT_XIBALBA_BOSS_TABLET_2
	jr xibalba_tablet_fn_continue


;-----------------------------------------------
xibalba_tablet_fn_tbl:
	dw TEXT_XIBALBA_STORY_TABLET_1_1, TEXT_XIBALBA_STORY_TABLET_1_2
	dw TEXT_XIBALBA_STORY_TABLET_2_1, TEXT_XIBALBA_STORY_TABLET_2_2
	dw TEXT_XIBALBA_STORY_TABLET_3_1, TEXT_XIBALBA_STORY_TABLET_3_2
	dw TEXT_XIBALBA_STORY_TABLET_4_1, TEXT_XIBALBA_STORY_TABLET_4_2
	dw TEXT_XIBALBA_STORY_TABLET_5_1, TEXT_XIBALBA_STORY_TABLET_5_2
	dw TEXT_XIBALBA_LORDS_TABLET_1_1, TEXT_XIBALBA_LORDS_TABLET_1_2
	dw TEXT_XIBALBA_LORDS_TABLET_2_1, TEXT_XIBALBA_LORDS_TABLET_2_2
	dw TEXT_XIBALBA_LORDS_TABLET_3_1, TEXT_XIBALBA_LORDS_TABLET_3_2
	dw TEXT_XIBALBA_LORDS_TABLET_4_1, TEXT_XIBALBA_LORDS_TABLET_4_2
	dw TEXT_XIBALBA_LORDS_TABLET_5_1, TEXT_XIBALBA_LORDS_TABLET_5_2
	dw TEXT_XIBALBA_LORDS_TABLET_6_1, TEXT_XIBALBA_LORDS_TABLET_6_2
	dw TEXT_XIBALBA_LORDS_TABLET_7_1, TEXT_XIBALBA_LORDS_TABLET_7_2
	dw TEXT_XIBALBA_CLUE_TABLET_1_1, TEXT_XIBALBA_CLUE_TABLET_1_2
	dw TEXT_XIBALBA_CLUE_TABLET_1_1, TEXT_XIBALBA_CLUE_TABLET_1_2

xibalba_tablet_fn:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	sub TAG_XIBALBA_STORY1
	add a, a
	add a, a
	ld hl, xibalba_tablet_fn_tbl
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
xibalba_tablet_fn_continue:
	push hl
		push de
			ld hl, tablet_trivia_tiles_zx0
			ld c, TABLET_LETTER_PAGE
			call maya_puzzle_tablet_fn_load_extra_tiles_hl_set
		pop iy
		ld a, 18
		ld (tmp_letter_line_width), a
		ld a, COLOR_GREY
		ld (tmp_letter_line_color), a
		ld b, 48
		ld de, NAMTBL2 + (7 + 5*32)
		ld ix, CHRTBL2
		call display_paragraph_text_page3
	pop iy
	ld a, iyl
	or iyh
	ret z
	ld b, 48
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 256*8
	jp display_paragraph_text_page3


;-----------------------------------------------
atlantis_tablet_fn_tbl:
	dw TEXT_ATLANTIS_TABLET_1_1, TEXT_ATLANTIS_TABLET_1_2
	dw TEXT_ATLANTIS_TABLET_2_1, TEXT_ATLANTIS_TABLET_2_2
	dw TEXT_ATLANTIS_TABLET_3_1, TEXT_ATLANTIS_TABLET_3_2
	dw TEXT_ATLANTIS_TABLET_4_1, TEXT_ATLANTIS_TABLET_4_2
	dw TEXT_ATLANTIS_TABLET_5_1, TEXT_ATLANTIS_TABLET_5_2

atlantis_tablet_fn_tbl2:
	db 24, 25, 23, 24, 25, 23, 24, 25
	db 26, 27, 23, 26, 27, 23, 26, 27


atlantis_tablet_fn:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	push af
		cp TAG_ATLANTIS_TABLET3
		jr c, atlantis_tablet_fn_do_not_draw_firestone
		ld hl, atlantis_tablet_fn_tbl2
		ld de, NAMTBL2 + 256*2 + 12
		ld b, 8
		call fast_small_LDIRVM
		ld hl, atlantis_tablet_fn_tbl2 + 8
		ld de, NAMTBL2 + 256*2 + 12 + 32
		ld b, 8
		call fast_small_LDIRVM
atlantis_tablet_fn_do_not_draw_firestone:
	pop af
	sub TAG_ATLANTIS_TABLET1
	add a, a
	add a, a
	ld hl, atlantis_tablet_fn_tbl
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
		push de
			ld hl, tablet_trivia_tiles_zx0
			ld c, TABLET_LETTER_PAGE
			call maya_puzzle_tablet_fn_load_extra_tiles_hl_set
		pop iy
		ld a, 18
		ld (tmp_letter_line_width), a
		ld a, COLOR_GREY
		ld (tmp_letter_line_color), a
		ld b, 48
		ld de, NAMTBL2 + (7 + 5*32)
		ld ix, CHRTBL2
		call display_paragraph_text_page3
	pop iy
	ld a, iyl
	or iyh
	ret z
	ld b, 48
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 256*8
	jp display_paragraph_text_page3


;-----------------------------------------------
astronomy_tablet1_fn:
	ld hl, tablet_trivia_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set
	ld iy, TEXT_ASTRONOMY_TABLET_1_1
	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a
	ld b, 48
	ld de, NAMTBL2 + (7 + 5*32)
	ld ix, CHRTBL2
	call display_paragraph_text_page3

	ld iy, TEXT_ASTRONOMY_TABLET_1_2
	ld b, 48
	ld de, NAMTBL2 + (7 + 8*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph_text_page3

	ld iy, TEXT_ASTRONOMY_TABLET_1_3
	ld b, 48
	ld de, NAMTBL2 + (7 + 16*32)
	ld ix, CHRTBL2 + 256*8*2
	jp display_paragraph_text_page3


;-----------------------------------------------
astronomy_tablet2_fn:
	ld hl, tablet_trivia_tiles_zx0
	ld c, TABLET_LETTER_PAGE
	call maya_puzzle_tablet_fn_load_extra_tiles_hl_set
	ld iy, TEXT_ASTRONOMY_TABLET_2_1
	ld a, 18
	ld (tmp_letter_line_width), a
	ld a, COLOR_GREY
	ld (tmp_letter_line_color), a
	ld b, 48
	ld de, NAMTBL2 + (7 + 5*32)
	ld ix, CHRTBL2
	call display_paragraph_text_page3

	ld iy, TEXT_ASTRONOMY_TABLET_2_2
	ld b, 48
	ld de, NAMTBL2 + (7 + 11*32)
	ld ix, CHRTBL2 + 256*8
	call display_paragraph_text_page3

	ld iy, TEXT_ASTRONOMY_TABLET_2_3
	ld b, 48
	ld de, NAMTBL2 + (7 + 16*32)
	ld ix, CHRTBL2 + 256*8*2
	jp display_paragraph_text_page3

