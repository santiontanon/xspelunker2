;-----------------------------------------------
savegame_menu:
	call clear_screen_left_to_right
	call set_bitmap_mode

	; ...

	call wait_for_click

	ld hl, state_inventory_from_savegame
	ld a, TEXT_PAGE
	jp jp_to_hl_in_page_a_8000
