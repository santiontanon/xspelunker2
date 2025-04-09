;-----------------------------------------------
; input:
; - de: text to display
display_in_game_message:
	; clear all the tiles in the bank:
	push de
		; save the content below:
    	ld hl, NAMTBL2 + 256
    	ld de, buffer_4096 + 1024
    	ld bc, 256
    	call LDIRMV

		ld hl, CLRTBL2 + 256*8
		ld bc, 256*8
		xor a
		call fast_FILVRM
		ld hl, CHRTBL2 + 256*8
		ld bc, 256*8
		xor a
		call fast_FILVRM
	    ld hl, NAMTBL2 + 256
    	call set_bitmap_name_table
	pop hl

	; draw text:
	push hl
		ld iyl, 28*8
		call max_length_of_sentence_in_one_line
	pop hl
	cp (hl)
	jr z, display_in_game_message_center

	; multi-line:
	ld de, buffer_4096
	ld a, (hl)
	add a, 2
	ld c, a
	ld b, 0
	ldir	
    ld de, CHRTBL2 + (10*32+2)*8
display_in_game_message_print_loop:
    ld hl, buffer_4096
    push de
    push hl
		ld iyl, 28*8
	    call max_length_of_sentence_in_one_line
    pop hl
	pop de    
    ; limit the sentence to that width and rraw it:
    ld c, (hl)   ; we save the old length
    ld (hl), a
    push bc
    push hl
    	push hl
    	push de
	    	call clear_text_rendering_buffer
	    pop de
	    pop hl
        ; draw the first part of the sentence:
        ld iy, #80f0
        ld b, 28
        push de
			call draw_sentence_to_vdp
		pop de
    pop hl
    pop bc
    ld a, c
    sub (hl)  ; length left
    jr z, display_in_game_message_continue  ; if we have drawn the whole sentence, we are done
    push de
	    ld c, (hl)  ; c: length of the segment we just drew, 
	    ld e, a  ; e: remaining length
	    ld (hl), e
	    push bc
	        ld b, 0
	        add hl, bc  ; we advance hl to the remainder of the sentence
	        inc hl  ; skip the space we were splitting on
	        ld c, e  ; move the sentence to the left
	        ld de, buffer_4096 + 1
	        ldir
	    pop bc
	pop hl
	; next line:
	ld de, 32*8
	add hl, de
	ex de, hl
    jr display_in_game_message_print_loop

display_in_game_message_center:
	push hl
		call clear_text_rendering_buffer
	pop hl
	push hl
		call text_string_width
	pop hl
	; start position is: 128 - a/2
	srl a
	srl a
	srl a
	ld b, a
	push bc
		srl a  ; (width/8)/2
		neg
		add a, 16  ; tile to start drawing
		add a, a
		add a, a
		add a, a
		ex hl, de
			ld hl, CHRTBL2 + 11 * 32 * 8
			ld b, 0
			ld c, a
		add hl, bc
		ex hl, de
		ld iy, #80f0
	pop bc
	inc b
	call draw_sentence_to_vdp	

display_in_game_message_continue:
	call wait_for_space

	; restore tiles in middle bank:
	ld hl, CLRTBL2 + 256*8
	ld bc, 256*8
	xor a
	call fast_FILVRM

	; restore content below:
	ld hl, buffer_4096 + 1024
	ld de, NAMTBL2 + 256
	ld bc, 256
	call fast_LDIRVM

	ld hl, redraw_flags
	ld (hl), #ff

	ld c, TILES_PAGE
	ld hl, tiles_pyramid_zx0
	call setup_game_tiles
; 	jp state_play_upload_object_tiles_to_vdp_if_necessary
	ret
