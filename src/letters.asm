;-----------------------------------------------
display_elaine_letter1:
	call disable_VDP_output
	    call clear_all_the_sprites
		xor a
		ld hl, NAMTBL2
		ld bc, 768
		call fast_FILVRM

		ld hl, elaine_letter1_tiles_zx0
		ld c, TILES_PAGE
		call decompress_tiles_to_all_banks

		ld hl, elaine_letter1_nametable_zx0
		ld de, buffer_4096
		ld c, TILES_PAGE
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
		; copy text to buffer_4096:
		ld de, buffer_4096
		ld c, (hl)
		ld b, 0
		inc bc
		ldir
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
					ld iyl, 29*8  ; 28 = letter space for text
				    call max_length_of_sentence_in_one_line
				pop ix
				pop hl
				ld c, (hl)  ; we save the old length
				ld (hl), a  ; write the length of the first line

				push bc
				push hl
					call clear_text_rendering_buffer
				pop hl
				pop bc
			pop de  ; recover ; CHRTBL2 ptr
			push bc
				; draw the first line:
				ld iy, #800f
				ld b, 28
				call draw_sentence_to_vdp
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
			pop af

			ld b, 28
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


			; code from the inventory part to draw multiline paragraphs:
			;     ; limit the sentence to that width and draw it:
			;     ld c, (hl)   ; we save the old length
			;     ld (hl), a
			;     push bc
			;     push hl
			;     	push hl
			;     	push de
			; 	    	call clear_text_rendering_buffer
			; 	    pop de
			; 	    pop hl
			;         ; draw the first part of the sentence:
			;         ld iy, #80f0
			;         ld b, 17
			;         push de
			; 			call draw_sentence_to_vdp
			; 		pop de
			;     pop hl
			;     pop bc
			;     ld a, c
			;     sub (hl)  ; length left
			;     ret z  ; if we have drawn the whole sentence, we are done
			;     push de
			; 	    ld c, (hl)  ; c: length of the segment we just drew, 
			; 	    ld e, a  ; e: remaining length
			; 	    ld (hl), e
			; 	    push bc
			; 	        ld b, 0
			; 	        add hl, bc  ; we advance hl to the remainder of the sentence
			; 	        inc hl  ; skip the space we were splitting on
			; 	        ld c, e  ; move the sentence to the left
			; 	        ld de, buffer_4096 + 1
			; 	        ldir
			; 	    pop bc
			; 	pop hl
			; 	; next line:
			; 	ld de, 32*8
			; 	add hl, de
			; 	ex de, hl



