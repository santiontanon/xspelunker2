;-----------------------------------------------
state_play:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	ld hl, RAM_to_zero_on_game_start
	ld bc, RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start
	call clear_memory

	; setup tiles:
	ld a, TILES_PAGE
	ld hl, tiles_pyramid_zx0
	call setup_game_tiles

	; get room data:
	SETMEGAROMPAGE_8000 MAP_DATA_PAGE
	ld hl, hardcoded_room_data
	ld de, current_room__layout
	ld bc, hardcoded_room_data_end - hardcoded_room_data
	ldir

	; init sprite attribute table:
	ld hl, sprite_attribute_table + 2
	ld (hl), 0
	inc hl
	ld (hl), COLOR_DARK_YELLOW
	ld hl, sprite_attribute_table + 2 + 4
	ld (hl), 4
	inc hl
	ld (hl), COLOR_DARK_RED

	; initial player position:
	ld hl, #0e00
	ld (player_x), hl
	ld hl, #0800
	ld (player_y), hl

	xor a
state_play_loop:
	; game update:
	call update_keyboard_buffers
	call player_update

	halt
	; game redraw:
	ld hl, upload_sprites_to_vdp
	ld c, SPRITES_PAGE
	call call_hl_in_page_c_8000
	ld bc, #0000  ; c = x offset, b = y offset
	call draw_room
	jr state_play_loop


