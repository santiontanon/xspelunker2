;-----------------------------------------------
savegame_menu:
	call clear_screen_left_to_right
	call disable_VDP_output
		ld hl, savegame_tiles_zx0
		ld c, SAVEGAME_MENU_PAGE
		call decompress_tiles_to_all_banks

		ld hl, savegame_nametable_zx0
		ld de, buffer_4096
		call dzx0

		ld hl, buffer_4096
		ld de, NAMTBL2
		ld bc, 768
		call fast_LDIRVM

		DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_OPTIONS1, CHRTBL2 + (2*256 + 32) * 8, 16*COLOR_WHITE, 4

	call enable_VDP_output

	; ...

	call wait_for_click

	ld hl, state_inventory_from_savegame
	ld a, TEXT_PAGE
	jp jp_to_hl_in_page_a_8000
