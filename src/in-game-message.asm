in_game_message_border_tile_attributes:
	db #00, #00, #00, #ff, #ff, #00, #00, #00


;-----------------------------------------------
; input:
; - de: text to display
display_in_game_message_textpage2:
	; copy the text to buffer_4096:
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE2
	call call_hl_in_page_c_8000
	ld de, buffer_4096
	jr display_in_game_message


;-----------------------------------------------
; input:
; - de: text to display
display_in_game_message_textpage3:
	; copy the text to buffer_4096:
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	call call_hl_in_page_c_8000
	ld de, buffer_4096
	jr display_in_game_message


;-----------------------------------------------
; input:
; - de: text to display
display_in_game_message_textpage4:
	; copy the text to buffer_4096:
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE4
	call call_hl_in_page_c_8000
	ld de, buffer_4096
	; jp display_in_game_message


;-----------------------------------------------
; input:
; - de: text to display
display_in_game_message:
	call display_in_game_message_internal
	ld a, (current_room__tileset_page)
	ld c, a
	ld hl, (current_room__tileset_ptr)
	jp setup_game_tiles_only_biome


;-----------------------------------------------
; input:
; - de: text to display
display_in_game_message_internal:
	call display_in_game_message_draw_message

	call wait_for_click
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
	ret


;-----------------------------------------------
; input:
; - de: text to display
display_in_game_message_draw_message:
	; clear all the tiles in the bank:
	push de
		call display_in_game_message_draw_box
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
    ld de, CHRTBL2 + (12*32+2)*8
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
        ; draw the first part of the sentence:
        ld iy, #80f0
        ld b, 28
        push de
			call draw_sentence_to_vdp_clearing_text_buffer
		pop de
    pop hl
    pop bc
    ld a, c
    sub (hl)  ; length left
    ret z  ; if we have drawn the whole sentence, we are done
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
			ld hl, CHRTBL2 + 12 * 32 * 8
			ld b, 0
			ld c, a
			add hl, bc
		ex hl, de
		ld iy, #80f0
	pop bc
	inc b
	jp draw_sentence_to_vdp_clearing_text_buffer	


;-----------------------------------------------
display_in_game_message_draw_box:
	; clear sprites that are in the message area (y > 48, y < 120)
	ld hl, sprite_attribute_table
	ld a, (n_displayed_object_sprites)
	add a, FIRST_OBJECT_SPRITE
	ld b, a
display_in_game_message__clear_sprites_loop:
	ld a, (hl)  ; y
	cp 48
	jr c, display_in_game_message__clear_sprites_loop_next
	cp 120
	jr nc, display_in_game_message__clear_sprites_loop_next
	ld (hl), 200  ; move out of the screen
display_in_game_message__clear_sprites_loop_next:
	inc hl
	inc hl
	inc hl
	inc hl
	djnz display_in_game_message__clear_sprites_loop
	ld hl, sprite_attribute_table
	ld de, SPRATR2
	ld a, (n_displayed_object_sprites)
	add a, FIRST_OBJECT_SPRITE
	add a, a
	add a, a
	ld b, a
	call fast_small_LDIRVM		

	; save the content below:
	ld hl, NAMTBL2 + 256
	ld de, buffer_4096 + 1024
	ld bc, 256
	call LDIRMV

	; clear all biome tiles:
	ld hl, CLRTBL2 + (256 + 16*6)*8
	ld bc, (256 - 16*6)*8
	xor a
	call fast_FILVRM
	ld hl, CHRTBL2 + (256 + 16*6)*8
	ld bc, (256 - 16*6)*8
	xor a
	call fast_FILVRM
	ld hl, in_game_message_tiles
	ld de, NAMTBL2 + 256
	ld bc, 256
	call fast_LDIRVM

	; draw white lines on top and bottom of message:
	ld hl, in_game_message_border_tile_attributes
	ld de, CLRTBL2 + (256 + 97)*8 
	ld b, 8
	jp fast_small_LDIRVM

