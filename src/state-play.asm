;-----------------------------------------------
state_play:
	call disable_VDP_output
		ld hl, RAM_to_zero_on_game_start
		ld bc, RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start
		call clear_memory

		SETMEGAROMPAGE_8000 SPRITES_PAGE
		ld hl, pyramid_object_sprites_bin
		ld de, SPRTBL2 + 32 * 2  ; first two reserved for player
		ld bc, pyramid_object_sprites_bin_end - pyramid_object_sprites_bin
		call fast_LDIRVM

		; initial player position:
		ld hl, #0800
		ld (player_x), hl
		ld hl, #0500
		ld (player_y), hl

		; set random seed:
		ld hl, #aaaa
		ld (current_world__seed), hl
		ld hl, #aaaa
		ld (current_world__seed + 2), hl

		; generate world:
		ld hl, pcg_generate_world
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

		; generate area:
		ld hl, pcg_generate_area
; 		ld e, 0  ; area to generate
; 		ld e, 5  ; area to generate
		ld e, 1  ; area to generate
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

		; generate room:
; 		ld e, 0
		ld e, 2
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000


state_play_from_loaded_room:
		call room_render_tile_objects
state_play_from_inventory:
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
		xor a
		ld (n_displayed_object_sprites_last_frame), a
		ld (n_displayed_object_sprites), a
		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000

	call enable_VDP_output

state_play_loop:
	; game update:
	xor a
	ld (n_displayed_object_sprites), a
	call update_keyboard_buffers
	call player_update
	call update_sprite_objects
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

