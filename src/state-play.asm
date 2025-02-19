;-----------------------------------------------
state_play:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	call disable_VDP_output
		ld hl, RAM_to_zero_on_game_start
		ld bc, RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start
		call clear_memory

		; initial player position:
		ld hl, #0e00
		ld (player_x), hl
		ld hl, #0800
		ld (player_y), hl

		; get room data:
		SETMEGAROMPAGE_8000 MAP_DATA_PAGE
		ld hl, hardcoded_room_data
		ld de, current_room__width
		ld bc, hardcoded_room_data_end - hardcoded_room_data
		ldir

state_play_from_inventory:
		; setup tiles:
		ld a, TILES_PAGE
		ld hl, tiles_pyramid_zx0
		call setup_game_tiles

		; init sprite attribute table:
		ld hl, sprite_attribute_table + 2
		ld (hl), 0
		inc hl
		ld (hl), COLOR_DARK_YELLOW
		ld hl, sprite_attribute_table + 2 + 4
		ld (hl), 4
		inc hl
		ld (hl), COLOR_DARK_RED

		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000
		call maybe_recenter_scroll
		call draw_room

	call enable_VDP_output

	xor a
state_play_loop:
	; game update:
	call update_keyboard_buffers
	call player_update
	call maybe_recenter_scroll
	call update_scroll

	halt
	; game redraw:
	ld hl, upload_sprites_to_vdp
	ld c, SPRITES_PAGE
	call call_hl_in_page_c_8000
	ld a, (redraw_whole_room_flag)
	or a
	jr nz, state_play_loop_room_redraw
	call update_animations_in_vdp
	jr state_play_loop
state_play_loop_room_redraw:
	call update_animations  ; this does not upload anything to the vdp
	call draw_room
	jr state_play_loop

