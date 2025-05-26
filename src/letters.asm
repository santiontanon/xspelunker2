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
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE2
		ld a, 4+28
		ld de, NAMTBL2 + (2 + 3*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE3
		ld a, 2
		ld de, NAMTBL2 + (2 + 9*32)
		ld ix, CHRTBL2 + 256*8
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE4
		ld a, 2+28*5
		ld de, NAMTBL2 + (2 + 15*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE5
		ld a, 2
		ld de, NAMTBL2 + (2 + 17*32)
		ld ix, CHRTBL2 + 2*256*8
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE6
		ld a, 2 + 28*2
		ld de, NAMTBL2 + (2 + 20*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE7
		ld a, 2 + 28*3
		ld de, NAMTBL2 + (2 + 22*32)
		call display_elaine_letter_paragraph

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
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1B_LINE2
		ld a, FIRST_LETTER1B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 9*32)
		ld ix, CHRTBL2 + 8*256
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1B_LINE2
		ld a, FIRST_LETTER1B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 9*32)
		ld ix, CHRTBL2 + 8*256
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1B_LINE3
		ld a, FIRST_LETTER1B_USEABLE_TILE + 28*3
		ld de, NAMTBL2 + (2 + 13*32)
		call display_elaine_letter_paragraph

		ld a, 18
		ld (tmp_letter_line_width), a
		ld hl, TEXT_ELAINE_LETTER1B_LINE4
		ld a, FIRST_LETTER1B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 17*32)
		ld ix, CHRTBL2 + 2*8*256
		call display_elaine_letter_paragraph

		; annotations:
		ld a, 5
		ld (tmp_letter_line_width), a
		ld a, COLOR_LIGHT_RED * 16 + COLOR_WHITE
		ld (tmp_letter_line_color), a

		ld hl, TEXT_ELAINE_LETTER1B_LINE5
		ld a, FIRST_LETTER1B_USEABLE_TILE + 28*3
		ld de, NAMTBL2 + (19 + 2*32)
		ld ix, CHRTBL2
		call display_elaine_letter_paragraph
		ld hl, TEXT_ELAINE_LETTER1B_LINE6
		ld a, FIRST_LETTER1B_USEABLE_TILE + 28*3 + 5
		ld de, NAMTBL2 + (19 + 3*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1B_LINE7
		ld a, FIRST_LETTER1B_USEABLE_TILE + 28*3
		ld de, NAMTBL2 + (3 + 22*32)
		ld ix, CHRTBL2 + 256*8*2
		call display_elaine_letter_paragraph
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
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER2A_LINE2
		ld a, 4+28
		ld de, NAMTBL2 + (2 + 3*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER2A_LINE3
		ld a, 4+28*2
		ld de, NAMTBL2 + (2 + 5*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER2A_LINE4
		ld a, 2
		ld de, NAMTBL2 + (2 + 9*32)
		ld ix, CHRTBL2 + 256*8
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER2A_LINE5
		ld a, 2+28*2
		ld de, NAMTBL2 + (2 + 12*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE6
		ld a, 2
		ld de, NAMTBL2 + (2 + 16*32)
		ld ix, CHRTBL2 + 256*8*2
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER1A_LINE7
		ld a, 2 + 28
		ld de, NAMTBL2 + (2 + 18*32)
		call display_elaine_letter_paragraph

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
		call display_elaine_letter_paragraph

		ld a, 24
		ld (tmp_letter_line_width), a
		ld hl, TEXT_ELAINE_LETTER2B_LINE2A
		ld a, FIRST_LETTER2B_USEABLE_TILE + 2*28
		ld de, NAMTBL2 + (2 + 6*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER2B_LINE2B
		ld a, FIRST_LETTER2B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 8*32)
		ld ix, CHRTBL2 + 256*8
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER2B_LINE3
		ld a, FIRST_LETTER2B_USEABLE_TILE + 1*24
		ld de, NAMTBL2 + (2 + 10*32)
		call display_elaine_letter_paragraph

		ld hl, TEXT_ELAINE_LETTER2B_LINE4
		ld a, FIRST_LETTER2B_USEABLE_TILE
		ld de, NAMTBL2 + (2 + 17*32)
		ld ix, CHRTBL2 + 256*8*2
		call display_elaine_letter_paragraph
    call enable_VDP_output

	call wait_for_click

	xor a
	ld (keyboard_clicks), a

	ld hl, redraw_flags
	ld (hl), #ff
	ret


;-----------------------------------------------
; input:
; - hl: text
; - a: first tile to use
; - de: NAMTBL2 ptr
; - ix: base CHRTBL2 address (1st, 2nd or 3rd bank?)
display_elaine_letter_paragraph:
	push af
	push de
	push ix
		; copy text to buffer_4096:
		push hl
		pop ix
		ld hl, copy_ix_text_to_buffer_4096
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop ix
	pop de
	pop af
display_elaine_letter_paragraph_loop:
	push af
		push de
			push hl
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
			pop hl
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
display_elaine_letter_paragraph_name_table_loop:
		    out (c), a
		    inc a
		    djnz display_elaine_letter_paragraph_name_table_loop
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
	jp display_elaine_letter_paragraph_loop

