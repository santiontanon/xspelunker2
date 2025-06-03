;-----------------------------------------------
state_play:
	call disable_VDP_output
		ld hl, RAM_to_zero_on_game_start
		ld bc, (RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start) - 1
		call clear_memory

		ld hl, check_redefined_keys
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000

		ld a, 1  ; inactive stone
		ld (global_state__power_calendar), a
		ld a, 2 + 0  ; first power stone
		ld (global_state__power_calendar + 1), a
		inc a
		ld (global_state__power_calendar + 2), a
		inc a
		ld (global_state__power_calendar + 3), a
		inc a
		ld (global_state__power_calendar + 4), a
; 		inc a
; 		ld (global_state__power_calendar + 5), a
		ld a, 4
		ld (global_state__n_power_stones_in_calendar), a
		ld a, STORY_STATE__GOT_LETTER2
		ld (global_state__story), a
		ld a, 2  ; maya riddle solved
		ld (global_state__maya_riddle), a

		; debug:
		ld a, 1
; 		ld (player_inventory_items), a
; 		ld (player_inventory_items+1), a
; 		ld (player_inventory_items+2), a
; 		ld (player_inventory_items+3), a
; 		ld (player_inventory_items+4), a
; 		ld (player_inventory_items+5), a  ; mars boss key
; 		ld (player_inventory_items+6), a  ; moon boss key
; 		ld (player_inventory_items+7), a  ; first stone
; 		ld (player_inventory_items+8), a  ; second stone
; 		ld (player_inventory_items+9), a  ; third stone
; 		ld (player_inventory_items+10), a
		ld (player_inventory_items+11), a  ; 5th stone
; 		ld (player_inventory_items+12), a  ; sixth stone
; 		ld (player_inventory_items+13), a  ; [UNUSED]
; 		ld (player_inventory_items+14), a
; 		ld (player_inventory_items+15), a
; 		ld (player_inventory_items+16), a
		ld (player_inventory_items+17), a
		ld (player_inventory_items+18), a
		ld (player_inventory_items+19), a
		ld (player_inventory_items+20), a  ; small keys
		ld (player_inventory_items+21), a
		ld (player_inventory_items+22), a
		ld (player_inventory_items+23), a
		ld (player_inventory_items+24), a  ; clay suit (last key item)
		ld (player_inventory_items+25), a
		ld (player_inventory_items+26), a
		ld (player_inventory_items+27), a
		ld (player_inventory_items+28), a
		ld (player_inventory_items+29), a
		ld (player_inventory_items+30), a
		ld (player_inventory_items+31), a
		ld (player_inventory_items+32), a
		ld (player_inventory_items+33), a
		ld (player_inventory_items+34), a
		ld (player_inventory_items+35), a  ; map
; 		ld (player_inventory_items+36), a  ; half power stone
		ld (player_inventory_items+INVENTORY_ITEM_PUZZLEBOX_MARS), a
		ld (player_inventory_items+INVENTORY_ITEM_PUZZLEBOX_MOON), a
		ld (player_inventory_weapons), a
		ld (player_inventory_weapons+1), a
; 		ld (player_inventory_weapons+2), a
; 		ld (player_inventory_weapons+3), a
		ld (player_inventory_weapons+4), a
		ld (player_inventory_weapons+5), a
; 		ld (player_inventory_weapons+6), a
; 		ld (player_inventory_weapons+7), a
; 		ld (player_inventory_weapons+8), a
; 		ld (player_inventory_weapons+9), a
; 		ld (player_inventory_weapons+10), a
; 		ld a, 123
; 		ld (player_inventory_coins), a
		ld a, 25
; 		ld (player_inventory_weapon_ammo), a
		ld (player_inventory_weapon_ammo + 1), a
; 		ld (player_inventory_weapon_ammo + 2), a
; 		ld (player_inventory_weapon_ammo + 3), a
		ld a, 1
		ld (player_inventory_n_small_keys), a
		ld (global_state__objects + TAG_MAP_PIECE1), a
		ld (global_state__objects + TAG_MAP_PIECE2), a
		ld (global_state__objects + TAG_MAP_PIECE3), a
		ld (global_state__objects + TAG_MAP_PIECE4), a
		ld (global_state__objects + TAG_MAP_PIECE5), a
; 		ld (global_state__objects + TAG_TELEPORTER1), a
		ld (global_state__objects + TAG_TELEPORTER4), a
		ld (global_state__objects + TAG_TELEPORTER5), a

		; initial player position:
; 		ld hl, #0a00
; 		ld hl, #1000
		ld hl, #1400
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
		ld e, 1  ; area to generate
; 		ld e, 3  ; area to generate
; 		ld e, 9  ; area to generate
; 		ld e, 2  ; area to generate
; 		ld e, 10  ; area to generate
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

		; generate room:
; 		ld e, 0
		ld e, 1
; 		ld e, CALENDAR_ROOM_ID
; 		ld e, TELEPORTER_ROOM_ID
; 		ld e, 24
; 		ld e, 14  ; 18  ; boss
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

		ld a, PLAYER_INITIAL_MAX_HEALTH
		ld hl, player_health
		ld (hl), a
		inc hl
		ld (hl), a  ; player_max_health
		ld a, PLAYER_MAX_OXYGEN
		ld (player_oxygen), a

state_play_from_loaded_room:
		call clear_all_the_sprites
		ld c, TILES_PAGE
		ld hl, room_render_tile_objects
		call call_hl_in_page_c_8000
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
		ld a, (current_room__tileset_page)
		ld c, a
		ld hl, (current_room__tileset_ptr)
		call setup_game_tiles
		call state_play_upload_object_tiles_to_vdp_if_necessary

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
	ld hl, (in_game_event_fn_ptr)
	ld a, h
	or a
	call nz, state_play_loop_event_fn
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
	ld a, (redraw_flags)
	bit REUPLOAD_INGAME_OBJECT_TILES_FLAG_BIT, a
	call nz, state_play_upload_object_tiles_to_vdp_if_necessary

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
	ld bc, state_play_loop  ; return address
	push bc
	ld hl, (current_room__animation_fn_ptr)
	jp (hl)

state_play_loop_room_redraw:
	call state_play_rerender_room
	ld bc, state_play_loop  ; return address
	push bc
	ld hl, (current_room__animation_fn_ptr)
	jp (hl)

state_play_loop_hud_redraw:
	call state_play_rerender_hud
	ld bc, state_play_loop  ; return address
	push bc
	ld hl, (current_room__animation_fn_ptr)
	jp (hl)


;-----------------------------------------------
state_play_loop_event_fn:
	ld de, 0
	ld (in_game_event_fn_ptr), de
	ld a, (in_game_event_fn_page)
	ld c, a
	jp call_hl_in_page_c_8000


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
	ld c, TILES_PAGE
	ld hl, update_tile_objects
	call call_hl_in_page_c_8000
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


state_play_upload_object_tiles_to_vdp_if_necessary:
	ld hl, redraw_flags
	ld a, (hl)
	and REUPLOAD_INGAME_OBJECT_TILES_FLAG_CLEAR_MASK
	ld (hl), a

	ld hl, object_tiles_zx0
	ld de, buffer_4096
	ld c, TILES_PAGE
	call dzx0_from_page_c

	; update hud weapon tiles:
	ld a, (player_current_item)
	; 0 - 10: a + 26  ; weapons
	; 11 - 17: a - 11 ; boss keys
	; 18 - 24: 47  ; idols
	; 25 - 30: a - 17  ; color keys,
	; 31: a = 37  ; small key
	; 32 - 35: a - 17  ; color keys, key items
	cp 11
	jr c, state_play_upload_object_tiles_to_vdp_if_necessary_weapon
	cp 18
	jr c, state_play_upload_object_tiles_to_vdp_if_necessary_boss_key
	cp 25
	jr c, state_play_upload_object_tiles_to_vdp_if_necessary_idol
	cp 31
	jr c, state_play_upload_object_tiles_to_vdp_if_necessary_color_keys
	jr z, state_play_upload_object_tiles_to_vdp_if_necessary_small_key
	; key items
	add a, -18
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_color_keys:
	add a, -17
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_small_key:
	ld a, 37
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_idol:
	ld a, 47
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_boss_key:
	add a, -11
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_weapon:
	add a, 26  ; index of machete in the object tiles
state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set:
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; * 64	
	ld bc, buffer_4096
	add hl, bc
	ld de, CHRTBL2 + 15*8
	ld b, 32
	call fast_small_LDIRVM
	ld de, CLRTBL2 + 15*8
	ld b, 32
	call fast_small_LDIRVM	

	; update in-game item object tiles:
	ld hl, (item_object_to_upload_to_vdp)
	ld a, h
	or a
	jr z, state_play_upload_object_tiles_to_vdp_if_necessary_continue
	push hl
		ld de, CHRTBL2 + FIRST_ITEM_TILE*8
		ld b, 32
		call fast_small_LDIRVM
	pop hl
	push hl
		ld de, CHRTBL2 + FIRST_ITEM_TILE*8 + 256*8
		ld b, 32
		call fast_small_LDIRVM
	pop hl
	push hl
		ld de, CHRTBL2 + FIRST_ITEM_TILE*8 + 256*8*2
		ld b, 32
		call fast_small_LDIRVM
	pop hl
	ld bc, 32
	add hl, bc
	push hl
		ld de, CLRTBL2 + FIRST_ITEM_TILE*8
		ld b, 32
		call fast_small_LDIRVM
	pop hl
	push hl
		ld de, CLRTBL2 + FIRST_ITEM_TILE*8 + 256*8
		ld b, 32
		call fast_small_LDIRVM
	pop hl
	ld de, CLRTBL2 + FIRST_ITEM_TILE*8 + 256*8*2
	ld b, 32
	call fast_small_LDIRVM

state_play_upload_object_tiles_to_vdp_if_necessary_continue:
	ld hl, object_large_tiles_zx0
	ld de, buffer_4096
	ld c, TILES_PAGE
	call dzx0_from_page_c

	; update in-game large object tiles:
	ld hl, (large_object_to_upload_to_vdp)
	ld a, (large_object_to_upload_to_vdp_size)
	ld b, a
	ld a, h
	or a
	ret z
	push hl
	push bc
		ld de, CHRTBL2 + FIRST_LARGE_ITEM_TILE*8
		call fast_small_LDIRVM
	pop bc
	pop hl
	push hl
	push bc
		ld de, CHRTBL2 + FIRST_LARGE_ITEM_TILE*8 + 256*8
		call fast_small_LDIRVM
	pop bc
	pop hl
	push hl
	push bc
		ld de, CHRTBL2 + FIRST_LARGE_ITEM_TILE*8 + 256*8*2
		call fast_small_LDIRVM
	pop bc
	pop hl
	ld c, b
	ld b, 0
	add hl, bc
	ld b, c
	push hl
	push bc
		ld de, CLRTBL2 + FIRST_LARGE_ITEM_TILE*8
		call fast_small_LDIRVM
	pop bc
	pop hl
	push hl
	push bc
		ld de, CLRTBL2 + FIRST_LARGE_ITEM_TILE*8 + 256*8
		call fast_small_LDIRVM
	pop bc
	pop hl
	ld de, CLRTBL2 + FIRST_LARGE_ITEM_TILE*8 + 256*8*2
	jp fast_small_LDIRVM

