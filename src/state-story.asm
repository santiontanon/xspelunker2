;-----------------------------------------------
state_story:
    ld sp, stack
	call clear_screen_left_to_right

	; ...

	ld hl, state_braingames
	ld a, BRAINGAMES_PAGE
	jp jp_to_hl_in_page_a_8000
