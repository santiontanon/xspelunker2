;-----------------------------------------------
ending_C:
    ld sp, stack
	
	; ...

	ld hl, state_game_over	
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_B:
    ld sp, stack
	
	; ...

	ld hl, state_game_over	
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_A:
    ld sp, stack
	
	; ...

	ld hl, state_game_over	
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000
