;-----------------------------------------------
state_play:
	call disable_VDP_output
		ld hl, RAM_to_zero_on_game_start
		ld bc, RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start
		call clear_memory

		; initial player position:
		ld hl, #0800
		ld (player_x), hl
		ld hl, #0500
		ld (player_y), hl

		; get area data:
		SETMEGAROMPAGE_8000 MAP_DATA_PAGE
		ld hl, hardcoded_area_data
		ld de, current_area__seed
		ld bc, hardcoded_area_data_end - hardcoded_area_data
		ldir

		; call PCG to generate the current room from the current area:
; 		ld e, 0
		ld e, 7  ; room ID
; 		ld e, 24
; 		ld e, 26  ; room ID (boss)
; 		ld e, 28  ; room ID
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		out (#2c), a
		call call_hl_in_page_c_8000
		out (#2d), a

		; get room data:
; 		SETMEGAROMPAGE_8000 MAP_DATA_PAGE
; 		ld hl, hardcoded_room_data
; 		ld de, current_room__width
; 		ld bc, hardcoded_room_data_end - hardcoded_room_data
; 		ldir

state_play_from_inventory:
state_play_from_loaded_room:
		ld sp, stack  ; reset the stack, so we can jump here from wherever we want

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
		call maybe_recenter_scroll_and_set_actual
		call draw_room
		call player_update_update_sprite_position
		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000

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
	call draw_room
	call update_animations_in_vdp
	jr state_play_loop

