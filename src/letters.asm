;-----------------------------------------------
display_elaine_letter1:
	; page 1:
	call disable_VDP_output
		ld a, 28
		ld (tmp_letter_line_width), a
		ld a, #0f
		ld (tmp_letter_line_color), a

	    call clear_all_the_sprites
		xor a
		ld hl, NAMTBL2
		ld bc, 768
		call fast_FILVRM

		ld hl, elaine_letter1_tiles_zx0
		ld c, TABLET_LETTER_PAGE
		call decompress_tiles_to_all_banks

		ld hl, elaine_letter1_nametable_zx0
		ld de, buffer_4096
		ld c, TABLET_LETTER_PAGE
		call dzx0_from_page_c

		ld hl, buffer_4096
		ld de, NAMTBL2
		ld bc, 768
		call fast_LDIRVM

		ld hl, TEXT_ELAINE_LETTER1A_LINE1
		ld a, 4
		ld de, NAMTBL2 + (2 + 1*32)
		ld ix, CHRTBL2
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE2
		ld a, 4+28
		ld de, NAMTBL2 + (2 + 3*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE3
		ld a, 2
		ld de, NAMTBL2 + (2 + 9*32)
		ld ix, CHRTBL2 + 256*8
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE4
		ld a, 2+28*5
		ld de, NAMTBL2 + (2 + 15*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE5
		ld a, 2
		ld de, NAMTBL2 + (2 + 17*32)
		ld ix, CHRTBL2 + 2*256*8
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE6
		ld a, 2 + 28*2
		ld de, NAMTBL2 + (2 + 20*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE7
		ld a, 2 + 28*3
		ld de, NAMTBL2 + (2 + 22*32)
		call display_paragraph

    call enable_VDP_output

	call wait_for_click

	; page 2:
	call disable_VDP_output

FIRST_LETTER1B_USEABLE_TILE: equ 60

		ld hl, elaine_letter1b_tiles_zx0
		ld c, TABLET_LETTER_PAGE
		call decompress_tiles_to_all_banks

		ld hl, elaine_letter1b_nametable_zx0
		ld de, buffer_4096
		ld c, TABLET_LETTER_PAGE
		call dzx0_from_page_c

		ld hl, buffer_4096
		ld de, NAMTBL2
		ld bc, 768
		call fast_LDIRVM

		ld hl, TEXT_ELAINE_LETTER1B_LINE1
		ld a, FIRST_LETTER1B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 5*32)
		ld ix, CHRTBL2
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1B_LINE2
		ld a, FIRST_LETTER1B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 9*32)
		ld ix, CHRTBL2 + 8*256
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1B_LINE2
		ld a, FIRST_LETTER1B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 9*32)
		ld ix, CHRTBL2 + 8*256
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1B_LINE3
		ld a, FIRST_LETTER1B_USEABLE_TILE + 28*3
		ld de, NAMTBL2 + (2 + 13*32)
		call display_paragraph

		ld a, 18
		ld (tmp_letter_line_width), a
		ld hl, TEXT_ELAINE_LETTER1B_LINE4
		ld a, FIRST_LETTER1B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 17*32)
		ld ix, CHRTBL2 + 2*8*256
		call display_paragraph

		; annotations:
		ld a, 5
		ld (tmp_letter_line_width), a
		ld a, COLOR_LIGHT_RED * 16 + COLOR_WHITE
		ld (tmp_letter_line_color), a

		ld hl, TEXT_ELAINE_LETTER1B_LINE5
		ld a, FIRST_LETTER1B_USEABLE_TILE + 28*3
		ld de, NAMTBL2 + (19 + 2*32)
		ld ix, CHRTBL2
		call display_paragraph
		ld hl, TEXT_ELAINE_LETTER1B_LINE6
		ld a, FIRST_LETTER1B_USEABLE_TILE + 28*3 + 5
		ld de, NAMTBL2 + (19 + 3*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1B_LINE7
		ld a, FIRST_LETTER1B_USEABLE_TILE + 28*3
		ld de, NAMTBL2 + (3 + 22*32)
		ld ix, CHRTBL2 + 256*8*2
		call display_paragraph
    call enable_VDP_output

	call wait_for_click

	xor a
	ld (keyboard_clicks), a

	ld hl, redraw_flags
	ld (hl), #ff
	ret


;-----------------------------------------------
display_elaine_letter2:
	; page 1:
	call disable_VDP_output
		ld a, 28
		ld (tmp_letter_line_width), a
		ld a, #0f
		ld (tmp_letter_line_color), a

	    call clear_all_the_sprites
		xor a
		ld hl, NAMTBL2
		ld bc, 768
		call fast_FILVRM

		ld hl, elaine_letter1_tiles_zx0
		ld c, TABLET_LETTER_PAGE
		call decompress_tiles_to_all_banks

		ld hl, elaine_letter1_nametable_zx0
		ld de, buffer_4096
		ld c, TABLET_LETTER_PAGE
		call dzx0_from_page_c

		ld hl, buffer_4096
		ld de, NAMTBL2
		ld bc, 768
		call fast_LDIRVM

		ld hl, TEXT_ELAINE_LETTER2A_LINE1
		ld a, 4
		ld de, NAMTBL2 + (2 + 1*32)
		ld ix, CHRTBL2
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER2A_LINE2
		ld a, 4+28
		ld de, NAMTBL2 + (2 + 3*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER2A_LINE3
		ld a, 4+28*2
		ld de, NAMTBL2 + (2 + 5*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER2A_LINE4
		ld a, 2
		ld de, NAMTBL2 + (2 + 9*32)
		ld ix, CHRTBL2 + 256*8
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER2A_LINE5
		ld a, 2+28*2
		ld de, NAMTBL2 + (2 + 12*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE6
		ld a, 2
		ld de, NAMTBL2 + (2 + 16*32)
		ld ix, CHRTBL2 + 256*8*2
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE7
		ld a, 2 + 28
		ld de, NAMTBL2 + (2 + 18*32)
		call display_paragraph

    call enable_VDP_output

	call wait_for_click

	; page 2:
	call disable_VDP_output

FIRST_LETTER2B_USEABLE_TILE: equ 67

		ld hl, elaine_letter2b_tiles_zx0
		ld c, TABLET_LETTER_PAGE
		call decompress_tiles_to_all_banks

		ld hl, elaine_letter2b_nametable_zx0
		ld de, buffer_4096
		ld c, TABLET_LETTER_PAGE
		call dzx0_from_page_c

		ld hl, buffer_4096
		ld de, NAMTBL2
		ld bc, 768
		call fast_LDIRVM

		ld hl, TEXT_ELAINE_LETTER2B_LINE1
		ld a, FIRST_LETTER2B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 3*32)
		ld ix, CHRTBL2
		call display_paragraph

		ld a, 24
		ld (tmp_letter_line_width), a
		ld hl, TEXT_ELAINE_LETTER2B_LINE2A
		ld a, FIRST_LETTER2B_USEABLE_TILE + 2*28
		ld de, NAMTBL2 + (2 + 6*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER2B_LINE2B
		ld a, FIRST_LETTER2B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 8*32)
		ld ix, CHRTBL2 + 256*8
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER2B_LINE3
		ld a, FIRST_LETTER2B_USEABLE_TILE + 1*24
		ld de, NAMTBL2 + (2 + 10*32)
		call display_paragraph

		ld hl, TEXT_ELAINE_LETTER2B_LINE4
		ld a, FIRST_LETTER2B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 17*32)
		ld ix, CHRTBL2 + 256*8*2
		call display_paragraph
    call enable_VDP_output

	call wait_for_click

	xor a
	ld (keyboard_clicks), a

	ld hl, redraw_flags
	ld (hl), #ff
	ret


;-----------------------------------------------
; input:
; - hl: text (iy for 'display_paragraph_text_page3')
; - a: first tile to use (b for 'display_paragraph_text_page3')
; - de: NAMTBL2 ptr
; - ix: base CHRTBL2 address (1st, 2nd or 3rd bank?)
; - (tmp_letter_line_width)
; - (tmp_letter_line_color)
display_paragraph_text_page3:
	ld a, b
	push af
	push de
	push ix
		; copy text to buffer_4096:
		push iy
		pop de
		ld c, TEXT_PAGE3
		ld hl, copy_text_from_textpage3
		jr display_paragraph_continue
display_paragraph_page7:
	push af
	push de
	push ix
		; copy text to buffer_4096:
		push hl
		pop ix
		ld c, TABLET_LETTER_PAGE
		ld hl, copy_ix_text_page7_to_buffer_4096
		jr display_paragraph_continue
display_paragraph:
	push af
	push de
	push ix
		; copy text to buffer_4096:
		push hl
		pop ix
		ld c, TEXT_PAGE
		ld hl, copy_ix_text_to_buffer_4096
display_paragraph_continue:
		call call_hl_in_page_c_8000
	pop ix
	pop de
	pop af
display_paragraph_loop:
	push af
		push de
			; compute CHRTBL2 ptr: CHRTBL2 + c*8
			ld l, a
			ld h, 0
			add hl, hl
			add hl, hl
			add hl, hl
			push ix
			pop de
			add hl, de
			ex de, hl
			push de  ; CHRTBL2 ptr
				; determine the first line:
			    ld hl, buffer_4096
			    push hl
			    push ix
			    	ld a, (tmp_letter_line_width)
			    	add a, a
			    	add a, a
			    	add a, a
					ld iyl, a
					ld ix, buffer_4096
					ld hl, max_length_of_sentence_in_one_line_ix
					ld c, TEXT_PAGE
				    call call_hl_in_page_c_8000
				    ld a, ixl
				pop ix
				pop hl
				ld c, (hl)  ; we save the old length
				ld (hl), a  ; write the length of the first line
			pop de  ; recover ; CHRTBL2 ptr
			push bc
				; draw the first line:
				ld a, (tmp_letter_line_width)
				ld b, a
				ld a, (tmp_letter_line_color)
				ld iyl, a
				ld iyh, #80
				call draw_sentence_to_vdp_from_another_page
			pop bc
		pop hl
	pop af
	push hl
		push bc
			push af
				; Write name table:
				call SETWRT
		        ld a, (VDP.DW)
		        ld c, a

				ld a, (tmp_letter_line_width)
				ld b, a
			pop af
display_paragraph_name_table_loop:
		    out (c), a
		    inc a
		    djnz display_paragraph_name_table_loop
		pop bc
		ld e, a
		ld hl, buffer_4096
		ld a, c
		sub (hl)
	pop hl
	ret z  ; we are done
	push hl
		push de  ; save the next tile to use
			ld hl, buffer_4096
		    ld c, (hl)  ; c: length of the segment we just drew
		    ld (hl), a
	        ld b, 0
	        add hl, bc  ; we advance hl to the remainder of the sentence
	        inc hl  ; skip the space we were splitting on
	        ld c, a  ; move the sentence to the left
	        ld de, buffer_4096 + 1
	        ldir
		pop de  ; recover the next tile to use
		ld a, e
	pop hl  ; recover ptr to the name table
	ld bc, 32
	add hl, bc
	ex de, hl
	jp display_paragraph_loop



;-----------------------------------------------
; This is here just because I did not want to give additional clues about what it does.
interact_special_case:
	ld de, TEXT_TALK
	ld hl, display_in_game_message_draw_message
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000
	call getcharacter_nonwaiting_reset

	ld hl, buffer_4096 + 2048
	ld bc, 20 + 1 - 1
	call clear_memory
interact_special_case_loop:
	halt
	call interact_special_case_draw
	call getcharacter_nonwaiting
	cp 27
	jr z, interact_special_case_loop_end
	cp 13
	jr z, interact_special_case_loop_end
	cp 8
	jp z, interact_special_case_loop_bs
	or a
	jp nz, interact_special_case_loop_general
	jr interact_special_case_loop
interact_special_case_loop_end:

	xor a
	ld (keyboard_clicks), a

	; restore tiles in middle bank:
	ld hl, CLRTBL2 + (256 + 16*6)*8
	ld bc, (256-16*6)*8
	; xor a
	call fast_FILVRM

	; restore content below:
	ld hl, buffer_4096 + 1024
	ld de, NAMTBL2 + 256
	ld bc, 256
	call fast_LDIRVM

	ld hl, redraw_flags
	ld (hl), #ff

	ld a, (current_area__id)
	cp 3
	jr nz, interact_special_case_fail
	ld a, (current_room__id)
	cp CALENDAR_ROOM_ID
	jr nz, interact_special_case_fail
	ld a, (global_state__solved_final_riddle)
	or a
	jr nz, interact_special_case_fail
	ld a, (global_state__n_power_stones_in_calendar)
	cp 6
	jr nz, interact_special_case_fail

	ld a, (player_x + 1)
	cp 14
	jr c, interact_special_case_fail
	cp 18
	jr nc, interact_special_case_fail
	ld a, (player_y + 1)
	cp 12
	jr nz, interact_special_case_fail

	; check word:
	ld hl, buffer_4096 + 2048
	ld de, current_world__maya_puzzle3_word
interact_special_case_check_loop:
	ld a, (de)
	cp (hl)
	jr nz, interact_special_case_fail
	or a
	jr z, interact_special_case_success
	inc hl
	inc de
	jr interact_special_case_check_loop

interact_special_case_success:
	ld a, 1
	ld (global_state__solved_final_riddle), a
	ld de, TEXT_TALK_SUCCESS1
	jr interact_special_case_success_continue

interact_special_case_fail:
	ld de, TEXT_TALK_FAIL
interact_special_case_success_continue:
	push de
		ld a, (current_room__tileset_page)
		ld c, a
		ld hl, (current_room__tileset_ptr)
		call setup_game_tiles_only_biome
	pop de
	ld hl, display_in_game_message
	ld a, TEXT_PAGE
	jp jp_to_hl_in_page_a_8000


interact_special_case_loop_bs:
	ld a, (buffer_4096 + 2048 + 20)
	or a
	jp z, interact_special_case_loop
	dec a
	ld (buffer_4096 + 2048 + 20), a
	ld hl, buffer_4096 + 2048
	ADD_HL_A
	ld (hl), 0
	jp interact_special_case_loop

interact_special_case_loop_general:
	cp #27
	jr z, interact_special_case_loop_general_in
	cp #61
	jp c, interact_special_case_loop
	cp #7b
	jp nc, interact_special_case_loop
interact_special_case_loop_general_in:
	push af
		ld a, (buffer_4096 + 2048 + 20)
		inc a
		cp 20
		jr nz, interact_special_case_loop_general_in_continue
		dec a
interact_special_case_loop_general_in_continue:
		ld (buffer_4096 + 2048 + 20), a
		dec a
		ld hl, buffer_4096 + 2048
		ADD_HL_A
	pop af
	ld (hl), a
	jp interact_special_case_loop


interact_special_case_draw:
	ld de, buffer_4096 + 2048 + 21
	xor a
	ld (de), a

	ld hl, buffer_4096 + 2048
interact_special_case_draw_loop:
	ld a, (hl)
	or a
	jr z, interact_special_case_draw_done

	push hl
		cp #27
		jr z, interact_special_case_draw_loop_q
		
		sub #61
		ld hl, interact_special_case_table
		ADD_HL_A
		ld a, (hl)
		ld ixl, a
		jr interact_special_case_draw_loop_ix_set
interact_special_case_draw_loop_q:
		ld ixl, 9
interact_special_case_draw_loop_ix_set:
		ld hl, buffer_4096 + 2048 + 21
		ld a, (hl)
		inc (hl)
		inc hl
		ADD_HL_A
		ld a, ixl
		ld (hl), a
	pop hl
	inc hl
	jr interact_special_case_draw_loop
interact_special_case_draw_done:
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096 + 2048 + 21, CHRTBL2 + (10+14*32)*8, #f0, 20
	ret

interact_special_case_table:
	db 108, 110, 112, 114, 116, 118, 120, 122
	db 124, 125, 127, 129, 130, 133, 135, 137
	db 139, 141, 143, 145, 147, 149, 152, 155
	db 158, 160

