;-----------------------------------------------
state_game_over:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	call clear_screen_left_to_right

	call set_bitmap_mode

	; SETMEGAROMPAGE_8000 TEXT_PAGE  ; not needed, as this is in the text page
	ld hl, TEXT_GAME_OVER
	ld de, CHRTBL2 + (10*32+13)*8
	ld iy, #80f0
	ld b, 6
	call draw_sentence_to_vdp_clearing_text_buffer

	call wait_for_click

	call clear_screen_left_to_right

	jp state_play
