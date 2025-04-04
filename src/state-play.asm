;-----------------------------------------------
state_play:
	call disable_VDP_output
		ld hl, RAM_to_zero_on_game_start
		ld bc, (RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start) - 1
		call clear_memory

		; initial player position:
		ld hl, #0a00
		ld (player_x), hl
		ld hl, #0a00
		ld (player_y), hl
		ld a, #ff
		ld (player_requested_weapon_sprite), a

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
; 		ld e, 0  ; breakable left (area 1)
		ld e, 9  ; breakable down (area 1)
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

		; debug:
		ld a, 1
; 		ld (player_inventory_items), a
; 		ld (player_inventory_items+1), a
; 		ld (player_inventory_items+2), a
; 		ld (player_inventory_items+3), a
; 		ld (player_inventory_items+4), a
; 		ld (player_inventory_items+5), a
; 		ld (player_inventory_items+6), a
; 		ld (player_inventory_items+7), a
; 		ld (player_inventory_items+8), a
; 		ld (player_inventory_items+9), a
; 		ld (player_inventory_items+10), a
; 		ld (player_inventory_items+11), a
; 		ld (player_inventory_items+12), a
; 		ld (player_inventory_items+13), a
; 		ld (player_inventory_items+14), a
; 		ld (player_inventory_items+15), a
; 		ld (player_inventory_items+16), a
; 		ld (player_inventory_items+17), a
; 		ld (player_inventory_items+18), a
; 		ld (player_inventory_items+19), a
; 		ld (player_inventory_items+20), a
; 		ld (player_inventory_items+21), a
; 		ld (player_inventory_items+22), a
; 		ld (player_inventory_items+23), a
; 		ld (player_inventory_items+24), a
; 		ld (player_inventory_items+25), a
; 		ld (player_inventory_items+26), a
; 		ld (player_inventory_items+27), a
; 		ld (player_inventory_items+28), a
; 		ld (player_inventory_items+29), a
; 		ld (player_inventory_items+30), a
; 		ld (player_inventory_items+31), a
; 		ld (player_inventory_items+32), a
; 		ld (player_inventory_items+33), a
; 		ld (player_inventory_items+34), a
		ld (player_inventory_items+35), a
		ld (player_inventory_weapons), a
		ld (player_inventory_weapons+1), a
		ld (player_inventory_weapons+2), a
		ld (player_inventory_weapons+3), a
		ld (player_inventory_weapons+4), a
		ld (player_inventory_weapons+5), a
		ld (player_inventory_weapons+6), a
		ld (player_inventory_weapons+7), a
; 		ld (player_inventory_weapons+8), a
; 		ld (player_inventory_weapons+9), a
; 		ld (player_inventory_weapons+10), a
; 		ld a, 123
; 		ld (player_inventory_coins), a
		ld a, 25
		ld (player_inventory_weapon_ammo), a
		ld (player_inventory_weapon_ammo + 1), a
		ld (player_inventory_weapon_ammo + 2), a
		ld (player_inventory_weapon_ammo + 3), a

		ld a, PLAYER_INITIAL_MAX_HEALTH
		ld hl, player_health
		ld (hl), a
		inc hl
		ld (hl), a  ; player_max_health
		ld a, PLAYER_MAX_OXYGEN
		ld (player_oxygen), a

state_play_from_loaded_room:
		call clear_all_the_sprites
		call room_render_tile_objects
state_play_from_inventory:
		ld sp, stack  ; reset the stack, so we can jump here from wherever we want

		; recalculate y scroll limits, which depend on the hud option:
		ld a, (current_room__height)
		sub 24
		ld (current_room__max_scroll_y), a
		ld a, (config_hud_type)
		cp 2  ; full hud
		jr nz, state_play_from_inventory__no_full_hud
		ld a, (current_room__max_scroll_y)
		add a, 2
		ld (current_room__max_scroll_y), a
state_play_from_inventory__no_full_hud:

		; setup sprites:
		SETMEGAROMPAGE_8000 SPRITES_PAGE
		ld hl, pyramid_object_sprites_bin
		ld de, SPRTBL2 + 32 * FIRST_OBJECT_SPRITE  ; first three reserved for player / weapon
		ld bc, pyramid_object_sprites_bin_end - pyramid_object_sprites_bin
		call fast_LDIRVM

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
		ld hl, sprite_attribute_table + 2 + 8
		ld (hl), 8

		ld a, HUD_MAX_TIME
		ld (hud_redraw_timer), a
		ld a, #ff  ; redraw everything the first time
		ld (redraw_flags), a

		call maybe_recenter_scroll_and_set_actual
		call draw_room_with_hud
		call player_update_update_sprite_position
		xor a
		ld (n_displayed_object_sprites), a
		ld (n_displayed_object_sprites_without_player_bullets), a
		ld (n_displayed_object_sprites_last_frame), a
		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000

	call enable_VDP_output

	ld a, #ff  ; so that we start with 0
	ld (game_cycle), a
	xor a
	ld (n_displayed_object_sprites), a
	ld (n_displayed_object_sprites_without_player_bullets), a

state_play_loop:
	; get the appropriate update function for this frame:
	ld a, (game_cycle)
	inc a
	and #07
	ld (game_cycle), a
	add a, a
	add a, a
	ld hl, state_play_update_agenda
	ADD_HL_A
	jp (hl)

state_play_loop_continue:
	halt
	; game redraw:
	ld hl, upload_sprites_to_vdp
	ld c, SPRITES_PAGE
	call call_hl_in_page_c_8000

	ld a, (config_hud_type)
	or a
	jr nz, state_play_loop_continue_hud_always_visible
	ld hl, hud_redraw_timer
	ld a, (hl)
	or a
	jr z, state_play_loop_continue_no_hud
	dec (hl)
	dec a
	jr z, state_play_loop_room_redraw  ; we need to redraw for sure
state_play_loop_continue_hud_always_visible:
state_play_loop_continue_no_hud:
	ld a, (redraw_flags)
	bit ROOM_REDRAW_FLAG_BIT, a
	jr nz, state_play_loop_room_redraw
	bit HUD_REDRAW_FLAG_BIT, a
	jr nz, state_play_loop_hud_redraw
	call update_animations_in_vdp
	jr state_play_loop
state_play_loop_room_redraw:
	call state_play_rerender_room
	call update_animations_in_vdp
	jr state_play_loop
state_play_loop_hud_redraw:
	call state_play_rerender_hud
	call update_animations_in_vdp
	jr state_play_loop


;-----------------------------------------------
state_play_rerender_room:
	ld a, (hud_redraw_timer)
	or a
	jp z, draw_room  ; no hud
	jp draw_room_with_hud

state_play_rerender_hud:
	ld a, (hud_redraw_timer)
	or a
	ret z
	jp draw_room_only_hud


;-----------------------------------------------
; Agenda:
; - We divide the cycles into blocks 8 cycles, and in each of those 8, we only update certain things
state_play_update_agenda:
	jp state_play_update_agenda_cycle_even_0
	db 0
	jp state_play_update_agenda_cycle_odd
	db 0
	jp state_play_update_agenda_cycle_even
	db 0
	jp state_play_update_agenda_cycle_odd
	db 0
	jp state_play_update_agenda_cycle_even
	db 0
	jp state_play_update_agenda_cycle_odd
	db 0
	jp state_play_update_agenda_cycle_even
	db 0
	jp state_play_update_agenda_cycle_odd


state_play_update_agenda_cycle_even:  ; player + player bullets
	call update_keyboard_buffers
	call player_update
	call update_sprite_objects_player_bullets
	call maybe_recenter_scroll
	call update_scroll
	jp state_play_loop_continue

state_play_update_agenda_cycle_even_0:  ; player + player bullets + tile objects
	call update_keyboard_buffers
	call player_update
	call update_sprite_objects_player_bullets
	call update_tile_objects
	call maybe_recenter_scroll
	call update_scroll
	jp state_play_loop_continue

state_play_update_agenda_cycle_odd:  ; player + player bullets + sprite objects
	call update_keyboard_buffers
	call player_update

	call update_sprite_objects
	ld a, (n_displayed_object_sprites)
	ld (n_displayed_object_sprites_without_player_bullets), a
	call update_sprite_objects_player_bullets
	call maybe_recenter_scroll
	call update_scroll
	jp state_play_loop_continue

