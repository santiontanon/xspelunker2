;-----------------------------------------------
; NOTE: this code is never executed, only used for debugging/profiling PCG
IF DEBUG_PCG = 1
pcg_debug_start:
	; set random seed:
; 	ld hl, 0
	ld hl, #e73b
	ld (current_world__seed), hl
	ld hl, #5555
	ld (current_world__seed + 2), hl

    ld hl, current_world__name_rom
    ld de, current_world__name
    ld bc, 16
    ldir

	ld hl, gamestart_compute_difficulty
	ld c, GAMESTART_PAGE
	call call_hl_in_page_c_8000

	; generate world:
	ld hl, pcg_generate_world
	ld c, PCG_PAGE_WORLD
	call call_hl_in_page_c_8000
pcg_debug_end:
ENDIF


;-----------------------------------------------
state_play:
	call clear_screen_left_to_right
	call disable_VDP_output	
		ld hl, RAM_to_zero_on_game_start
		ld bc, (RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start) - 1
		call clear_memory

		ld hl, TEXT_ENDING_FAIL
		ld (stats__ending), hl

		ld hl, enemy_respawn_table
		ld bc, (enemy_respawn_table_end - enemy_respawn_table) - 1
		ld a, #ff
		call clear_memory_a

		ld hl, check_redefined_keys
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000

		ld a, 1  ; inactive stone
		ld (global_state__power_calendar), a
; 		ld a, 2 + 0  ; first power stone
; 		ld (global_state__power_calendar + 1), a
; 		inc a
; 		ld (global_state__power_calendar + 2), a
; 		inc a
; 		ld (global_state__power_calendar + 3), a
; 		inc a
; 		ld (global_state__power_calendar + 4), a
; 		inc a
; 		ld (global_state__power_calendar + 5), a
; 		ld a, 2
; 		ld (global_state__n_power_stones_in_calendar), a
; 		ld a, STORY_STATE__GOT_LETTER1
; 		ld a, STORY_STATE__PLACED_FIRST_POWER_STONE
; 		ld a, STORY_STATE__FOUND_LOST_VENDOR
; 		ld a, STORY_STATE__GOT_LETTER2
; 		ld a, STORY_STATE__DEFEATED_ALIENS
; 		ld (global_state__story), a
; 		ld a, 2  ; maya riddle solved
; 		ld (global_state__maya_riddle), a

		; debug:
		ld a, 1
; 		ld (player_inventory_items), a  ; first boss key
; 		ld (player_inventory_items+1), a  ; second boss key
; 		ld (player_inventory_items+2), a  ; third boss key
; 		ld (player_inventory_items+3), a  ; fourth boss key
; 		ld (player_inventory_items+4), a  ; fifth boss key
; 		ld (player_inventory_items+5), a  ; mars boss key
; 		ld (player_inventory_items+6), a  ; moon boss key
; 		ld (player_inventory_items+7), a  ; first stone
; 		ld (player_inventory_items+8), a  ; second stone
; 		ld (player_inventory_items+9), a  ; third stone
; 		ld (player_inventory_items+10), a
; 		ld (player_inventory_items+11), a  ; 5th stone
; 		ld (player_inventory_items+12), a  ; sixth stone
; 		ld (player_inventory_items+13), a
; 		ld (player_inventory_items+14), a
; 		ld (player_inventory_items+15), a
; 		ld (player_inventory_items+16), a
; 		ld (player_inventory_items+17), a
; 		ld (player_inventory_items+18), a
; 		ld (player_inventory_items+19), a  ; small keys
; 		ld (player_inventory_items+20), a
; 		ld (player_inventory_items+21), a
; 		ld (player_inventory_items+22), a
; 		ld (player_inventory_items+23), a  ; clay suit (last key item)
; 		ld (player_inventory_items+24), a  ; sandals
; 		ld (player_inventory_items+25), a  ; gloves
; 		ld (player_inventory_items+26), a  ; warrior hat
; 		ld (player_inventory_items+27), a  ; cotton armor
; 		ld (player_inventory_items+28), a  ; chaac blessing
; 		ld (player_inventory_items+29), a  ; seashell
; 		ld (player_inventory_items+30), a  ; antigrav belt
; 		ld (player_inventory_items+31), a  ; ice cape
; 		ld (player_inventory_items+32), a  ; letter 1
; 		ld (player_inventory_items+33), a  ; letter 2
		ld (player_inventory_items+34), a  ; map
; 		ld (player_inventory_items+35), a  ; half power stone 1
; 		ld (player_inventory_items+36), a  ; half power stone 2
; 		ld (player_inventory_items+INVENTORY_ITEM_PUZZLEBOX_MARS), a
; 		ld (player_inventory_items+INVENTORY_ITEM_PUZZLEBOX_MOON), a
; 		ld (player_inventory_items+INVENTORY_ITEM_GOLDEN_KEY), a
; 		ld (player_inventory_items+INVENTORY_ITEM_SKULL_CHARM), a
; 		ld (player_inventory_items+INVENTORY_ITEM_CHARYBDIS_EYE), a
; 		ld (player_inventory_items+INVENTORY_ITEM_SCYLLA_EYE), a
		ld (player_inventory_weapons), a  ; machete
; 		ld (player_inventory_weapons+1), a
; 		ld (player_inventory_weapons+2), a
; 		ld (player_inventory_weapons+3), a  ; shield
; 		ld (player_inventory_weapons+4), a  ; sling
; 		ld (player_inventory_weapons+5), a  ; blowgun
; 		ld (player_inventory_weapons+6), a
; 		ld (player_inventory_weapons+7), a
; 		ld (player_inventory_weapons+8), a
; 		ld (player_inventory_weapons+9), a
; 		ld (player_inventory_weapons+10), a
; 		ld a, 202
; 		ld (player_inventory_coins), a
; 		ld a, 80
; 		ld (player_inventory_weapon_ammo), a
; 		ld (player_inventory_weapon_ammo + 1), a
; 		ld (player_inventory_weapon_ammo + 2), a
; 		ld (player_inventory_weapon_ammo + 3), a
; 		ld a, 2
; 		ld (player_inventory_n_small_keys), a
		ld (global_state__objects + TAG_MAP_PIECE1), a
; 		ld (global_state__objects + TAG_MAP_PIECE2), a
; 		ld (global_state__objects + TAG_MAP_PIECE3), a
; 		ld (global_state__objects + TAG_MAP_PIECE4), a
; 		ld (global_state__objects + TAG_MAP_PIECE5), a
; 		ld (global_state__objects + TAG_TELEPORTER1), a
; 		ld (global_state__objects + TAG_TELEPORTER2), a
; 		ld (global_state__objects + TAG_TELEPORTER4), a
; 		ld (global_state__objects + TAG_TELEPORTER5), a

		ld a, PLAYER_INITIAL_MAX_HEALTH
; 		ld a, 6*4  ; debug
		ld hl, player_health
		ld (hl), a
		inc hl
		ld (hl), a  ; player_max_health
		ld a, PLAYER_MAX_OXYGEN
		ld (player_oxygen), a

		call state_play_world_name_conditions

		; DEBUG:
; 		ld hl, stats__bosses		
; 		ld (hl), 1  ; boss 1
; 		inc hl
; 		ld (hl), 7
; 		inc hl
; 		ld (hl), 9
; 		inc hl
; 		ld (hl), 2  ; boss 2
; 		call enable_VDP_output		
; 		ld hl, state_game_over
; 		ld a, GAME_OVER_PAGE
; 		jp jp_to_hl_in_page_a_8000

state_play_from_continue:
		; initial player position:
		ld hl, #0100
; 		ld hl, #0a00
; 		ld hl, #1000
; 		ld hl, #1800
; 		ld hl, #1c00
		ld (player_x), hl
		ld hl, #0b00
; 		ld hl, #0a00
; 		ld hl, #0600
		ld (player_y), hl
		ld a, #ff
		ld (player_requested_weapon_sprite), a

		; generate area:
		ld hl, pcg_generate_area
		ld e, 0  ; area to generate
; 		ld e, 1  ; area to generate
; 		ld e, 2  ; area to generate
; 		ld e, 3  ; area to generate
; 		ld e, 4  ; area to generate
; 		ld e, 6  ; area to generate
; 		ld e, 7  ; area to generate
; 		ld e, 8  ; xibalba
; 		ld e, 9  ; atlantis
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

		; generate room:
		ld e, START_ROOM_ID
; 		ld e, GUARDIAN_CAIMAN1_ROOM_ID
; 		ld e, GUARDIAN_CAIMAN2_ROOM_ID
; 		ld e, 18
; 		ld e, 16
; 		ld e, CALENDAR_ROOM_ID
; 		ld e, 2
; 		ld e, 3  ; <- third boss
; 		ld e, 17  ; <- fourth boss
; 		ld e, 0
; 		ld e, EIGHT_BRIDGE_ROOM_ID
; 		ld e, TELEPORTER_ROOM_ID
; 		ld e, TEMPLE_OF_POSEIDON_ID
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000

state_play_from_loaded_room:
		call clear_all_the_sprites
		ld c, TILES_PAGE
		ld hl, room_render_tile_objects
		call call_hl_in_page_c_8000

		ld a, (current_room__collision_ptr_page)
		ld hl, (current_room__collision_ptr)
		ld de, current_room__collision_table
		ld bc, 256
		call ldir_from_page_a

		ld hl, 0
		ld (room_desired_scroll_x), hl
		ld (room_scroll_x), hl

state_play_from_inventory:
		ld sp, stack  ; reset the stack, so we can jump here from wherever we want

		; recalculate scroll limits, which depend on the hud option, and also are needed for
		; predefined rooms (like boss rooms), for which these are not computed, as they do not
		; go through pcg:
		ld a, (current_room__height)
		sub 24
		ld (current_room__max_scroll_y), a
		ld a, (current_room__width)
		sub 32
		ld (current_room__max_scroll_x), a
		ld a, (config_hud_type)
		cp 2  ; full hud
		jr nz, state_play_from_inventory__no_full_hud
		ld a, (current_room__max_scroll_y)
		add a, 2
		ld (current_room__max_scroll_y), a
state_play_from_inventory__no_full_hud:

		; setup sprites:
		ld a, SPRITES_PAGE
		ld hl, pyramid_object_sprites_bin
		ld de, SPRTBL2 + 32 * FIRST_OBJECT_SPRITE_PATTERN  ; first three reserved for player / weapon
		ld bc, pyramid_object_sprites_bin_end - pyramid_object_sprites_bin
		call fast_LDIRVM_from_sprites_page

		ld hl, (current_room__enemy_sprites_ptr)
		ld de, buffer_4096
		ld c, ENEMIES_PAGE
		call dzx0_from_page_c
		ld hl, buffer_4096		
		ld de, SPRTBL2 + 32 * FIRST_ENEMY_SPRITE_PATTERN
		ld bc, (64 - FIRST_ENEMY_SPRITE_PATTERN) * 32
		call fast_LDIRVM

		; setup tiles:
		ld a, (current_room__tileset_page)
		ld c, a
		ld hl, (current_room__tileset_ptr)
		call setup_game_tiles
		call state_play_upload_object_tiles_to_vdp_if_necessary

		; special case for boss 4:
		ld a, (boss__active)
		or a
		jr z, state_play_from_inventory__no_boss_4
		ld a, (boss__current_boss_number)
		cp 3  ; xibalba lords
		jr nz, state_play_from_inventory__no_boss_4
		; load lord specific tiles:
		ld a, (boss__behavior)
		or a
		jr z, state_play_from_inventory__no_boss_4
		cp 2
		jr z, state_play_from_inventory__load_boss_4_tile_patches
		cp 3
		jr z, state_play_from_inventory__load_boss_4_tile_patches
		; behavior 1, only load them in state 2
		ld a, (boss__state)
		cp 10
		jr z, state_play_from_inventory__load_boss_4_tile_patches
		ld hl, update_boss4_load_xibalba_lord_rise_patch
		ld c, BOSS_4_PAGE
		call call_hl_in_page_c_8000
		jr state_play_from_inventory__no_boss_4
state_play_from_inventory__load_boss_4_tile_patches:
		ld hl, update_boss4_load_xibalba_lord_tile_patches
		ld c, BOSS_4_PAGE
		call call_hl_in_page_c_8000
state_play_from_inventory__no_boss_4:

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
		call update_scroll		
		call draw_room_with_hud
		call player_update_update_sprite_position
		xor a
		ld (n_displayed_object_sprites), a
		ld (n_displayed_object_sprites_without_player_bullets), a
		ld (n_displayed_object_sprites_last_frame), a
		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000

		call play_current_room_music_if_needed

	call enable_VDP_output

	ld a, #ff
	ld (game_cycle), a  ; so that we start with 0
	ld (player_requested_weapon_sprite), a
	xor a
	ld (n_displayed_object_sprites), a
	ld (n_displayed_object_sprites_without_player_bullets), a

	; Seashell effect:
	ld a, (player_inventory_items + INVENTORY_ITEM_SEASHELL)
	or a
	jr z, state_play_loop
	ld a, (play_seashell_flag)
	or a
	jr z, state_play_loop
	; player has the seashell, play if there is a breakable wall in the room:
	xor a
	ld (play_seashell_flag), a
	ld hl, SFX_secret
	call play_SFX_with_high_priority

state_play_loop:
	ld hl, (in_game_event_fn_ptr)
	ld a, h
	or a
	call nz, state_play_loop_event_fn
	; get the appropriate update function for this frame:
	call state_play__update_time  ; updates how long has the player been playing
	ld a, (game_cycle)
	inc a
	ld (game_cycle), a
	and #07
	add a, a
	add a, a
	ld hl, (state_play_update_agenda_tbl_ptr)
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
	ld a, TILE_ANIMATIONS_PAGE
	jp jp_to_hl_in_page_a_8000

state_play_loop_room_redraw:
	call state_play_rerender_room
	ld bc, state_play_loop  ; return address
	push bc
	ld hl, (current_room__animation_fn_ptr)
	ld a, TILE_ANIMATIONS_PAGE
	jp jp_to_hl_in_page_a_8000

state_play_loop_hud_redraw:
	call state_play_rerender_hud
	ld bc, state_play_loop  ; return address
	push bc
	ld hl, (current_room__animation_fn_ptr)
	ld a, TILE_ANIMATIONS_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
; input:
; - hl: previous value of (in_game_event_fn_ptr)
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
state_play_update_agenda_normal_play:
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


state_play_update_agenda_boss:
	jp state_play_update_agenda_cycle_even_0_boss
	db 0
	jp state_play_update_agenda_cycle_odd
	db 0
	jp state_play_update_agenda_cycle_even_boss
	db 0
	jp state_play_update_agenda_cycle_odd
	db 0
	jp state_play_update_agenda_cycle_even_boss
	db 0
	jp state_play_update_agenda_cycle_odd
	db 0
	jp state_play_update_agenda_cycle_even_boss
	db 0
	jp state_play_update_agenda_cycle_odd


state_play_update_agenda_cycle_even:  ; player + player bullets
	call update_keyboard_buffers
	call maybe_recenter_scroll
	call update_scroll
	call player_update
	call update_sprite_objects_player_bullets
	jp state_play_loop_continue

state_play_update_agenda_cycle_even_0:  ; player + player bullets + tile objects
	call update_keyboard_buffers
	call maybe_recenter_scroll
	call update_scroll
	call player_update
	call update_sprite_objects_player_bullets
	ld c, TILES_PAGE
	ld hl, update_tile_objects
	call call_hl_in_page_c_8000
	jp state_play_loop_continue

state_play_update_agenda_cycle_odd:  ; player + player bullets + sprite objects
	call update_keyboard_buffers
	call maybe_recenter_scroll
	call update_scroll
	call player_update
	call update_sprite_objects
	ld hl, update_sprite_enemies
	ld c, ENEMIES_PAGE
	call call_hl_in_page_c_8000
	ld a, (n_displayed_object_sprites)
	ld (n_displayed_object_sprites_without_player_bullets), a
	call update_sprite_objects_player_bullets
	jp state_play_loop_continue

state_play_update_agenda_cycle_even_boss:  ; player + player bullets + boss
	call update_keyboard_buffers
	call maybe_recenter_scroll
	call update_scroll
	call player_update
	call update_sprite_objects_player_bullets
	ld c, BOSS_PAGE
	ld hl, update_boss_behavior
	call call_hl_in_page_c_8000
	jp state_play_loop_continue

state_play_update_agenda_cycle_even_0_boss:  ; player + player bullets + tile objects + boss
	call update_keyboard_buffers
	call maybe_recenter_scroll
	call update_scroll
	call player_update
	call update_sprite_objects_player_bullets
	ld c, BOSS_PAGE
	ld hl, update_boss_behavior
	call call_hl_in_page_c_8000
	ld c, TILES_PAGE
	ld hl, update_tile_objects
	call call_hl_in_page_c_8000
	jp state_play_loop_continue


;-----------------------------------------------
name_condition_1:
	db #0c, #12, #17, #ff
name_condition_2:
	db #13, #11, #00, #0d, #12, #01, #00, #0b, #0b, #ff
name_condition_3:
	db #01, #11, #00, #08, #0d, #06, #00, #0c, #04, #12, #ff
name_condition_4:
	db #16, #04, #12, #13, #04, #0d, #07, #0e, #14, #12, #04, #ff
name_condition_5:
	db #0c, #00, #19, #04, #0e, #05, #06, #00, #0b, #08, #0e, #14, #12, #ff
state_play_world_name_conditions:
	ld hl, current_world__name
	ld de, name_condition_1
	call state_play_world_name_conditions_match
	jr z, state_play_world_name_conditions_match_1
	ld hl, current_world__name
	ld de, name_condition_2
	call state_play_world_name_conditions_match
	jr z, state_play_world_name_conditions_match_2
	ld de, name_condition_3
	call state_play_world_name_conditions_match
	jr z, state_play_world_name_conditions_match_3
	ld de, name_condition_4
	call state_play_world_name_conditions_match
	jr z, state_play_world_name_conditions_match_4
	ld de, name_condition_5
	call state_play_world_name_conditions_match
	jp z, state_play_world_name_conditions_match_5
	ret

state_play_world_name_conditions_match:
	ld b, 16
state_play_world_name_conditions_match_loop:
	ld a, (de)
	inc a
	ret z
	dec a
	cp (hl)
	ret nz
	inc hl
	inc de
	djnz state_play_world_name_conditions_match_loop
	xor a  ; match
	ret

state_play_world_name_conditions_match_1:
	ld a, 200
	ld (player_inventory_coins), a
	ret

state_play_world_name_conditions_match_2:
	ld a, 1
	ld (player_inventory_weapons + 1), a
	ld (player_inventory_weapons + 2), a
	ld (player_inventory_weapons + 3), a
	ld (player_inventory_weapons + 4), a
	ld (player_inventory_weapons + 5), a
	ld (player_inventory_weapons + 6), a
	ld (player_inventory_weapons + 7), a
	ld a, 25
	ld (player_inventory_weapon_ammo), a
	ld (player_inventory_weapon_ammo + 1), a
	ld (player_inventory_weapon_ammo + 2), a
	ld (player_inventory_weapon_ammo + 3), a
	ret

state_play_world_name_conditions_match_3:
	ld a, 1
	ld (player_inventory_items + INVENTORY_ITEM_SANDALS), a
	ld (player_inventory_items + INVENTORY_ITEM_GLOVES), a
	ld (player_inventory_items + INVENTORY_ITEM_WARRIOR_HAT), a
	ld (player_inventory_items + INVENTORY_ITEM_COTTON_ARMOR), a
	ld (player_inventory_items + INVENTORY_ITEM_CHAAC_BLESSING), a
	ld (player_inventory_items + INVENTORY_ITEM_SEASHELL), a
	ld (player_inventory_items + INVENTORY_ITEM_ANTIGRAV_BELT), a
	ld (player_inventory_items + INVENTORY_ITEM_ICE_CAPE), a
	ld (global_state__objects + TAG_ITEM_SANDALS), a
	ld (global_state__objects + TAG_ITEM_GLOVES), a
	ld (global_state__objects + TAG_ITEM_WARRIOR_HAT), a
	ld (global_state__objects + TAG_ITEM_ARMOR), a
	ld (global_state__objects + TAG_ITEM_CHAAC), a
	ld (global_state__objects + TAG_ITEM_SEASHELL), a
	ld (global_state__objects + TAG_ITEM_BELT), a
	ld (global_state__objects + TAG_ITEM_ICE_CAPE), a
	ret

state_play_world_name_conditions_match_4:
	ld a, 1
	ld (global_state__objects + TAG_MAP_PIECE1), a
	ld (global_state__objects + TAG_MAP_PIECE2), a
	ld (global_state__objects + TAG_MAP_PIECE3), a
	ld (global_state__objects + TAG_MAP_PIECE4), a
	ld (global_state__objects + TAG_MAP_PIECE5), a
	ret

state_play_world_name_conditions_match_5:
	ld a, PLAYER_INITIAL_MAX_HEALTH + 4 * 5
	ld (player_max_health), a
	ld (player_health), a
	ld a, 1
	ld (global_state__objects + TAG_HEART1), a
	ld (global_state__objects + TAG_HEART2), a
	ld (global_state__objects + TAG_HEART3), a
	ld (global_state__objects + TAG_HEART4), a
	ld (global_state__objects + TAG_HEART5), a
	ret


;-----------------------------------------------
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
	; 18 - 23: 47  ; power stones
	; 24 - 29: a - 16  ; color keys,
	; 30: a = 37  ; small key
	; 31 - 34: a - 16  ; key items
	; 50: golden key
	cp N_INVENTORY_WEAPON_TYPES
	jr c, state_play_upload_object_tiles_to_vdp_if_necessary_weapon
	cp N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_POWER_STONE1
	jr c, state_play_upload_object_tiles_to_vdp_if_necessary_boss_key
	cp N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_COLOR_KEY1
	jr c, state_play_upload_object_tiles_to_vdp_if_necessary_power_stone
	cp N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_GOLDEN_KEY
	jr z, state_play_upload_object_tiles_to_vdp_if_necessary_golden_key
	cp N_INVENTORY_WEAPON_TYPES + INVENTORY_ITEM_SMALL_KEY
	jr c, state_play_upload_object_tiles_to_vdp_if_necessary_color_keys
	jr z, state_play_upload_object_tiles_to_vdp_if_necessary_small_key
	; key items
	add a, -17
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_color_keys:
	add a, -16
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_small_key:
	ld a, 37
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_golden_key:
	ld a, 62
	jr state_play_upload_object_tiles_to_vdp_if_necessary_selected_item_set
state_play_upload_object_tiles_to_vdp_if_necessary_power_stone:
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
	ld hl, (large_object_to_upload_to_vdp)
	ld a, h
	or a
	jr z, state_play_upload_enemy_tiles_to_vdp_if_necessary

	; check if we need to load object_large_tiles_zx0 or object_large_tiles2_zx0:
	; The way to indicate this is that the ptr set in "large_object_to_upload_to_vdp"
	; overflows the buffer_4096 space.
	ld hl, (large_object_to_upload_to_vdp)
	ld a, h
	cp #d0
	jr nc, state_play_upload_object_tiles_to_vdp_if_necessary_second_tilebank

state_play_upload_object_tiles_to_vdp_if_necessary_first_tilebank:
	ld hl, object_large_tiles_zx0
	ld de, buffer_4096
	ld c, TILES_PAGE
	call dzx0_from_page_c
	ld hl, (large_object_to_upload_to_vdp)
	jr state_play_upload_object_tiles_to_vdp_if_necessary_continue2

state_play_upload_object_tiles_to_vdp_if_necessary_second_tilebank:
	ld hl, object_large_tiles2_zx0
	ld de, buffer_4096
	ld c, TILES_PAGE
	call dzx0_from_page_c
	ld hl, (large_object_to_upload_to_vdp)
	ld a, h
	sub #10
	ld h, a

state_play_upload_object_tiles_to_vdp_if_necessary_continue2:
	; update in-game large object tiles:
	ld a, (large_object_to_upload_to_vdp_size)
	ld b, a
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
	call fast_small_LDIRVM

state_play_upload_enemy_tiles_to_vdp_if_necessary:
	ld hl, (enemy_tiles_to_upload_to_vdp)
	ld a, h
	or l
	ret z
	ld de, buffer_4096
	ld a, (enemy_tiles_to_upload_to_vdp_page)
	ld c, a
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld bc, 256
	push hl
	push bc
		ld de, CHRTBL2 + FIRST_ENEMY_TILE*8
		call fast_LDIRVM
	pop bc
	pop hl
	push hl
	push bc
		ld de, CHRTBL2 + FIRST_ENEMY_TILE*8 + 256*8
		call fast_LDIRVM
	pop bc
	pop hl
	push bc
		ld de, CHRTBL2 + FIRST_ENEMY_TILE*8 + 256*8*2
		call fast_LDIRVM
	pop bc
	ld hl, buffer_4096 + 32*8
	push hl
	push bc
		ld de, CLRTBL2 + FIRST_ENEMY_TILE*8
		call fast_LDIRVM
	pop bc
	pop hl
	push hl
	push bc
		ld de, CLRTBL2 + FIRST_ENEMY_TILE*8 + 256*8
		call fast_LDIRVM
	pop bc
	pop hl
	ld de, CLRTBL2 + FIRST_ENEMY_TILE*8 + 256*8*2
	jp fast_LDIRVM


;-----------------------------------------------
state_play__update_time:
	ld hl, stats__time
	inc (hl)  ; increment frames
	ld a, (isComputer50HzOr60Hz)
	or a
	jr z, state_play__update_time_50hz
state_play__update_time_60hz:
	ld a, (hl)
	cp 60
	ret nz
	jr state_play__update_time_60hz_continue
state_play__update_time_50hz:
	ld a, (hl)
	cp 50
	ret nz
state_play__update_time_60hz_continue
	ld (hl), 0
	inc hl
	inc (hl)  ; increment seconds
	ld a, (hl)
	cp 60
	ret nz
	ld (hl), 0
	inc hl
	inc (hl)  ; increment minutes
	ld a, (hl)
	cp 60
	ret nz
	ld (hl), 0
	inc hl
	ld a, (hl)
	inc a
	ret z  ; we are already at the maximum 255 hours
	inc (hl)  ; increment hours
	ret


;-----------------------------------------------
play_current_room_music_if_needed:
	ld a, (config_music_on)
	or a
	ret nz
	ld hl, (current_room__music_ptr)
	ld a, l
	or h
	jp z, stop_music
	ld bc, (MUSIC_currently_playing_music_ptr)
	or a
	sbc hl, bc
	jr nz, play_current_room_music_if_needed_start_song
	ld a, (current_room__music_tempo)
	ld c, a
	ld a, (MUSIC_original_tempo)
	jr nz, play_current_room_music_if_needed_start_song
	; we are already playing the song we want!
	ret
play_current_room_music_if_needed_start_song:
	ld hl, (current_room__music_ptr)
	ld a, (current_room__music_tempo)
	jp play_music_adjusting_tempo

