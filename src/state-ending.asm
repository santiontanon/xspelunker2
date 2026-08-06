;-----------------------------------------------
; Ending C data:
ending_C_UFO_captain_looking:
	db 78, 158, 0, COLOR_GREEN
	db 78 + 5, 158, 4, COLOR_WHITE

ending_C_UFO_captain_idle:
	db 78, 158, 8, COLOR_GREEN
	db 78 + 5, 158, 12, COLOR_WHITE

ending_C_UFO_captain_talking:
	db 78, 158, 16, COLOR_GREEN
	db 78 + 5, 158, 20, COLOR_WHITE

ending_C_UFO_captain_agitated:
	db 78, 158, 24, COLOR_GREEN
	db 78 + 5, 158, 28, COLOR_WHITE

ending_C_UFO_captain_agitated_talking:
	db 78, 158, 32, COLOR_GREEN
	db 78 + 5, 158, 36, COLOR_WHITE

ending_C_UFO_minion_idle:
	db 77, 88, 40, COLOR_GREEN
	db 77 + 5, 88, 44, COLOR_PURPLE

ending_C_UFO_minion_talking:
	db 77, 88, 56, COLOR_GREEN
	db 77 + 5, 88, 60, COLOR_PURPLE


ending_C_beach_unbrealla_sprites:
	db 63, 57, 0, COLOR_RED
	db 63, 57, 4, COLOR_BLACK
ending_C_beach_elaine_michael_sprites:
	db 79, 140, 8, COLOR_LIGHT_RED
	db 79, 143, 12, COLOR_DARK_YELLOW
	db 79, 170, 16, COLOR_DARK_YELLOW
	db 79, 173, 20, COLOR_DARK_RED

ending_C_beach_elaine_michael_sprites2:
	db 80, 140, 8, COLOR_LIGHT_RED
	db 80, 143, 12, COLOR_DARK_YELLOW
	db 80, 170, 16, COLOR_DARK_YELLOW
	db 80, 173, 20, COLOR_DARK_RED


;-----------------------------------------------
ending_C_plus:	
	ld hl, TEXT_ENDING_C_PLUS
	jr ending_C_continue
ending_C:
	ld hl, TEXT_ENDING_C
ending_C_continue:
    ld sp, stack
	ld (stats__ending), hl

	ld de, TEXT_CALENDAR_ACTIVATED_C_2
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000	

	ld de, TEXT_CALENDAR_ACTIVATED_C_3
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000	

	ld de, TEXT_CALENDAR_ACTIVATED_C_4
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000	

	ld de, TEXT_CALENDAR_ACTIVATED_C_5
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000	

	call clear_screen_left_to_right

	call ending_UFO_scene_approach_earth  ; aliens approach Earth, and captain calls for the invasion

	; Custom Ending C part of the UFO scene:	
	call ending_UFO_scene_minion_interrupts  ; alien minion approaches and tells the captain something is wrong
	ld hl, TEXT_ENDING_C_UFO_8
	ld b, 32
	call ending_UFO_scene_minion_talks
        
	ld hl, TEXT_ENDING_C_UFO_9
	ld b, 32
	call ending_UFO_scene_captain_talks_agitated

	ld hl, TEXT_ENDING_C_UFO_10
	ld b, 32
	call ending_UFO_scene_captain_talks

	ld hl, TEXT_ENDING_C_UFO_11
	ld b, 32
	call ending_UFO_scene_minion_talks
        
	ld hl, TEXT_ENDING_C_UFO_12
	ld b, 64
	call ending_UFO_scene_captain_talks_agitated

	ld b, 100
	call wait_b_halts_skippable

	call clear_screen_left_to_right
	call stop_music

	call ending_beach_scene_C  ; elaine and michael relax in the beach

	call clear_screen_left_to_right
	call stop_music

	ld ix, ending_C_text_page_ptrs
	ld iy, ending_C_enemy_intro_ptr_table
	ld a, (global_state__objects + TAG_FIRESTONE_FORGE)
	or a
	jr z, ending_C_continue2
	ld ix, ending_C_plus_text_page_ptrs
	ld iy, ending_C_plus_enemy_intro_ptr_table
ending_C_continue2:
	ld b, 3  ; # number of pages
	call ending_final_text_scene

ending_C_done:
	ld hl, state_game_over
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_B_plus:
	ld hl, TEXT_ENDING_B_PLUS
	jr ending_B_continue
ending_B:
	ld hl, TEXT_ENDING_B
ending_B_continue:
    ld sp, stack
	ld (stats__ending), hl

	ld de, TEXT_CALENDAR_ACTIVATED_C_2
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000	

	ld de, TEXT_CALENDAR_ACTIVATED_B_3
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000	

	ld de, TEXT_CALENDAR_ACTIVATED_B_4
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000	

	ld de, TEXT_CALENDAR_ACTIVATED_C_5
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000	

	call ending_B_UFO_scene

	call ending_beach_scene_B  ; elaine and michael relax in the beach

	call clear_screen_left_to_right
	call stop_music

	ld ix, ending_B_text_page_ptrs
	ld iy, ending_B_enemy_intro_ptr_table
	ld a, (global_state__objects + TAG_FIRESTONE_FORGE)
	or a
	jr z, ending_B_continue2
	ld ix, ending_B_plus_text_page_ptrs
	ld iy, ending_B_plus_enemy_intro_ptr_table
ending_B_continue2:
	ld b, 3  ; # number of pages
	call ending_final_text_scene

ending_B_done:
	ld hl, state_game_over
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_B_plus_prime:
	ld hl, TEXT_ENDING_B_PLUS_PRIME
	jr ending_B_prime_continue
ending_B_prime:
	ld hl, TEXT_ENDING_B_PRIME
ending_B_prime_continue:
    ld sp, stack
	ld (stats__ending), hl

	call ending_beach_scene_B  ; elaine and michael relax in the beach

	call clear_screen_left_to_right
	call stop_music

	ld ix, ending_B_prime_text_page_ptrs
	ld iy, ending_B_enemy_intro_ptr_table
	ld a, (global_state__objects + TAG_FIRESTONE_FORGE)
	or a
	jr z, ending_B_prime_continue2
	ld ix, ending_B_plus_prime_text_page_ptrs
	ld iy, ending_B_plus_enemy_intro_ptr_table
ending_B_prime_continue2:
	ld b, 3  ; # number of pages
	call ending_final_text_scene

ending_B_prime_done:
	ld hl, state_game_over
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_B_UFO_scene:
	call clear_screen_left_to_right

	call ending_UFO_scene_approach_earth  ; aliens approach Earth, and captain calls for the invasion

	; Custom Ending B part of the UFO scene:	
	call ending_UFO_scene_minion_interrupts  ; alien minion approaches and tells the captain something is wrong

	ld hl, TEXT_ENDING_B_UFO_8
	ld b, 32
	call ending_UFO_scene_minion_talks_page4
        
	ld hl, TEXT_ENDING_C_UFO_9
	ld b, 32
	call ending_UFO_scene_captain_talks_agitated

	ld hl, TEXT_ENDING_C_UFO_10
	ld b, 32
	call ending_UFO_scene_captain_talks

	ld hl, TEXT_ENDING_B_UFO_11
	ld b, 32
	call ending_UFO_scene_minion_talks_page4
        
	ld hl, TEXT_ENDING_B_UFO_12
	ld b, 64
	call ending_UFO_scene_captain_talks_agitated_page4

	ld hl, TEXT_ENDING_B_UFO_13
	ld b, 32
	call ending_UFO_scene_minion_talks_page4

	ld hl, TEXT_ENDING_B_UFO_14
	ld b, 64
	call ending_UFO_scene_captain_talks_agitated_page4

	ld hl, TEXT_ENDING_B_UFO_15
	ld b, 32
	call ending_UFO_scene_minion_talks_page4

	ld hl, TEXT_ENDING_B_UFO_16
	ld b, 16
	call ending_UFO_scene_captain_talks_agitated_page4

	ld hl, TEXT_ENDING_B_UFO_17
	ld b, 16
	call ending_UFO_scene_captain_talks_page4

	ld hl, TEXT_ENDING_B_UFO_18
	ld b, 16
	call ending_UFO_scene_captain_talks_agitated_page4

	; laser animation:
	ld hl, ending_ufo_nametables + 20*9 + 10*6 + 3*2
	ld de, NAMTBL2 + (4+3)*32 + 6+4
	ld bc, #0302
	call state_ending_copy_nametable
	ld b, 20
	call wait_b_halts

	ld hl, ending_ufo_nametables + 20*9 + 10*6 + 3*2 + 2*3
	ld de, NAMTBL2 + (4+3)*32 + 6+4
	ld bc, #0302
	call state_ending_copy_nametable
	ld b, 20
	call wait_b_halts

	ld hl, ending_ufo_nametables + 20*9 + 10*6 + 3*2 + 2*3 + 2*3
	ld de, NAMTBL2 + (4+3)*32 + 6+4
	ld bc, #0304
	call state_ending_copy_nametable
	ld b, 20
	call wait_b_halts

	ld hl, ending_ufo_nametables + 20*9 + 10*6 + 3*2 + 2*3 + 2*3 + 4*3
	ld de, NAMTBL2 + (4+3)*32 + 6+4
	ld bc, #0307
	call state_ending_copy_nametable
	ld b, 20
	call wait_b_halts

	; explosion (all red)
	ld b, 9
	ld hl, NAMTBL2 + (4)*32 + 6
ending_B_UFO_scene_explosion_loop:
	ld a, (ending_ufo_nametables + 20*9 + 10*6 + 3*2 + 2*3 + 2*3 + 4*3 + 18)  ; this is an all red tile
	push bc
		push hl
			ld bc, 20
			call fast_FILVRM
		pop hl
		ld bc, 32
		add hl, bc
	pop bc
	djnz ending_B_UFO_scene_explosion_loop
	call clear_all_the_sprites

	ld b, 100
	call wait_b_halts_skippable

	call clear_screen_left_to_right
	call stop_music
	ret


;-----------------------------------------------
; The aliens conquer earth.
ending_UFO_scene_conquer:
	call clear_screen_left_to_right

	call ending_UFO_scene_approach_earth  ; aliens approach Earth, and captain calls for the invasion

	; Custom Ending B part of the UFO scene:	
	call ending_UFO_scene_minion_interrupts_shared  ; alien minion approaches and tells the captain something is wrong

	ld hl, TEXT_ENDING_C_UFO_CONQUER_1
	ld b, 32
	call ending_UFO_scene_minion_talks_page4

	ld hl, TEXT_ENDING_C_UFO_CONQUER_2
	ld b, 32
	call ending_UFO_scene_captain_talks_page4

	call clear_screen_left_to_right
	jp stop_music


;-----------------------------------------------
ending_A_plus:
	ld hl, TEXT_ENDING_A_PLUS
	jr ending_A_continue
ending_A:
	ld hl, TEXT_ENDING_A
ending_A_continue:
    ld sp, stack
	ld (stats__ending), hl

	call stop_music

	call ending_A_calendar_scene_after_alien_boss
	
	call clear_screen_left_to_right
	call stop_music

	call ending_beach_scene_A  ; elaine and michael relax in the beach

	call clear_screen_left_to_right
	call stop_music

; 	ld ix, ending_A_text_page_ptrs
; 	ld iy, ending_A_enemy_intro_ptr_table
; 	ld a, (global_state__objects + TAG_FIRESTONE_FORGE)
; 	or a
; 	jr z, ending_A_continue2
; 	ld ix, ending_A_plus_text_page_ptrs
; 	ld iy, ending_A_plus_enemy_intro_ptr_table
; ending_A_continue2:
; 	ld b, 3  ; # number of pages
; 	call ending_final_text_scene

ending_A_done:
	ld hl, state_game_over	
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_A_calendar_scene_after_alien_boss:
	call disable_VDP_output	
		; load calendar room:
		ld e, CALENDAR_ROOM_ID
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	    ld a, TILES_CALENDAR_TELEPORTER_PAGE
	    ld (current_room__tileset_page), a
	    ld hl, tiles_calendar_teleporter_zx0
	    ld (current_room__tileset_ptr), hl
	    call state_play_setup_sprites

	    ld hl, ptr_to_new_tile_object
	    ld c, TILES_PAGE
	    call call_hl_in_page_c_8000

	    ld (hl), 0  ; ID
	    inc hl
	    ld (hl), TAG_TELEPORTER_MARS  ; type (any teleporter would do)
	    inc hl
	    ld (hl), 14  ; tile x
	    inc hl
	    ld (hl), 19  ; tile y
	    inc hl
	    ld (hl), 0  ; state

	    ld c, TILES_PAGE
	    ld hl, room_render_tile_objects
	    call call_hl_in_page_c_8000

	    ; we just sete the whole collision table to 2:
	    ld hl, current_room__collision_table
	    ld bc, 255
	    ld a, 2
	    call clear_memory_a

	    ld a, PLAYER_STATE_TELEPORT_IN
	    ld (player_state), a
	    xor a
	    ld (player_state_timer), a
	    ld a, 4
	    ld (player_x), a
	    ld a, 15
	    ld (player_x + 1), a
	    ld a, 20
	    ld (player_y + 1), a
	    ld a, 20  ; immune while teleporting
	    ld (player_immunity_timer), a

		ld hl, 0
		ld (room_desired_scroll_x), hl
		ld (room_scroll_x), hl

	    call setup_game_tiles
	    call state_play_upload_object_tiles_to_vdp_if_necessary
		ld a, #ff  ; redraw everything the first time
		ld (redraw_flags), a
		call maybe_recenter_scroll_and_set_actual
		call update_scroll
		call update_sprite_objects
		call player_update

	    call draw_room_with_hud
		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000
    call enable_VDP_output

    xor a
    ld (keyboard_clicks), a
    dec a  ; #ff
    ld (keyboard_state), a

    ; player teleports:
    ld b, 64
ending_A_calendar_scene_after_alien_boss_loop:
	push bc
		halt
		call update_scroll
		call player_update
		call update_sprite_objects
		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000
		ld hl, (current_room__animation_fn_ptr)
		ld c, TILE_ANIMATIONS_PAGE
		call call_hl_in_page_c_8000	
	pop bc
	djnz ending_A_calendar_scene_after_alien_boss_loop

    ld de, TEXT_ENDING_A_CALENDAR_1
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_ENDING_A_CALENDAR_2
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld b, 25
    call wait_b_halts_skippable

    ; turn calendar off:
    xor a
    ld (current_room__id), a  ; so that no tile modifications are applied, and calendar switches off
    call setup_game_tiles_only_biome

    ld hl, SFX_ui_wrong
    call play_SFX_with_high_priority

    ld b, 50
    call wait_b_halts_skippable

    ld de, TEXT_ENDING_A_CALENDAR_3
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_ENDING_A_CALENDAR_4
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld b, 50
    call wait_b_halts_skippable
	jp clear_screen_left_to_right


;-----------------------------------------------
ending_UFO_scene_approach_earth:

	ld hl, music_ending_aliens_bin
	ld a, 5
	call play_music_adjusting_tempo

	ld iy, TEXT_ENDING_C_UFO_0
	ld b, 1  ; first tile to use
	ld de, NAMTBL2 + 12*32 + 8
	ld ix, CHRTBL2 + 1*256*8
	ld a, 16
	ld (tmp_letter_line_width), a
	ld a, COLOR_WHITE * 16
	ld (tmp_letter_line_color), a
	ld hl, display_paragraph_text_page3
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	ld b, 200
	call wait_b_halts_skippable
	call clear_screen_left_to_right

	call disable_VDP_output
		ld hl, ending_ufo_tiles_zx0
		ld c, ENDING_PAGE
		call decompress_tiles_to_all_banks

		ld hl, ending_ufo_nametables
		ld de, NAMTBL2 + 4*32+6
		ld bc, #0914
		call state_ending_copy_nametable

		ld hl, ending_ufo_sprites_zx0
		ld de, buffer_4096
		call dzx0

		ld hl, buffer_4096
		ld de, SPRTBL2
		ld bc, 512
		call fast_LDIRVM

		ld hl, ending_C_UFO_captain_looking
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 
	call enable_VDP_output

	ld b, 50
	call wait_b_halts

	; make earth appear:
	ld b, 5
	ld de, NAMTBL2 + 9*32 + 11
ending_UFO_scene_approach_earth_loop:
	push bc
		; earth:
		ld c, 10
		ld a, 6
		sub b
		ld b, a
		ld hl, ending_ufo_nametables + 20*9
		push bc
			push de
				call state_ending_copy_nametable
			pop hl
			ld bc, 13 + 32
			add hl, bc
			ex de, hl
		pop bc
		; moon:
		dec b
		jr z, ending_UFO_scene_approach_earth_loop_continue2
		ld c, 2
		ld a, b
		cp 3
		jr c, ending_UFO_scene_approach_earth_loop_continue
		ld b, 3
ending_UFO_scene_approach_earth_loop_continue:
		ld hl, ending_ufo_nametables + 20*9 + 10*6
		push bc
		push de
			call state_ending_copy_nametable
		pop de
		pop bc
ending_UFO_scene_approach_earth_loop_continue2:
		ex de, hl
		ld bc, -(13 + 32 + 32)
		add hl, bc
		ex de, hl

		ld b, 25
		call wait_b_halts
	pop bc
	djnz ending_UFO_scene_approach_earth_loop

	; captain asks for the invasion:
	ld hl, TEXT_ENDING_C_UFO_1
	ld b, 32
	jp ending_UFO_scene_captain_talks_agitated


;-----------------------------------------------
ending_UFO_scene_minion_interrupts:
	call ending_UFO_scene_minion_interrupts_shared

	ld hl, TEXT_ENDING_C_UFO_6
	ld b, 32
	call ending_UFO_scene_minion_talks

	ld hl, TEXT_ENDING_C_UFO_7
	ld b, 32
	jp ending_UFO_scene_captain_talks_agitated


;-----------------------------------------------
ending_UFO_scene_minion_interrupts_shared:
	ld hl, ending_C_UFO_minion_idle
	ld de, buffer_4096
	ld bc, 8
	ldir

	ld b, 40
ending_UFO_scene_minion_interrupts_walk_loop:
	push bc
		ld a, 88
		sub b
		ld (buffer_4096 + 1), a
		ld (buffer_4096 + 1 + 4), a
		ld c, 40  ; idle
		bit 2, a
		jr nz, ending_UFO_scene_minion_interrupts_walk_loop_continue
		ld c, 48  ; walking
ending_UFO_scene_minion_interrupts_walk_loop_continue:
		ld a, c
		ld (buffer_4096 + 2), a
		add a, 4
		ld (buffer_4096 + 2 + 4), a
		ld hl, buffer_4096
		ld de, SPRATR2 + 4 * 2
		ld b, 8
		call fast_small_LDIRVM
		halt
		halt
	pop bc
	djnz ending_UFO_scene_minion_interrupts_walk_loop


	ld hl, TEXT_ENDING_C_UFO_2
	ld b, 32
	call ending_UFO_scene_minion_talks

	ld hl, TEXT_ENDING_C_UFO_3
	ld b, 32
	call ending_UFO_scene_captain_talks_agitated

	ld hl, TEXT_ENDING_C_UFO_4
	ld b, 32
	call ending_UFO_scene_minion_talks

	ld iy, TEXT_STORY10
	ld b, 1  ; first tile to use
	ld de, NAMTBL2 + 32*16 + 5
	ld ix, CHRTBL2 + 2*256*8
	ld a, COLOR_WHITE * 16
	ld (tmp_letter_line_color), a
	ld hl, display_paragraph_text_page3
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	ld b, 100
	call wait_b_halts_skippable
	call fast_small_LDIRVM 	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	call fast_FILVRM

	ld hl, TEXT_ENDING_C_UFO_5
	ld b, 32
	jp ending_UFO_scene_captain_talks


;-----------------------------------------------
; input:
; - hl: text
; - b: speech cycles to wait
ending_UFO_scene_captain_talks_page4:
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_WHITE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page4
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
	jr ending_UFO_scene_captain_talks_loop
ending_UFO_scene_captain_talks:
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_WHITE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page3
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
ending_UFO_scene_captain_talks_loop:
	push bc
		ld hl, ending_C_UFO_captain_idle
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 

		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_captain_talks_loop_skip
	push bc

		ld hl, ending_C_UFO_captain_talking
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 
		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_captain_talks_loop_skip
	djnz ending_UFO_scene_captain_talks_loop
ending_UFO_scene_captain_talks_loop_skip:
	ld hl, ending_C_UFO_captain_idle
	ld de, SPRATR2
	ld b, 8
	call fast_small_LDIRVM 	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	jp fast_FILVRM


;-----------------------------------------------
; input:
; - hl: text
; - b: speech cycles to wait
ending_UFO_scene_captain_talks_agitated_page4:
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_WHITE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page4
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
	jr ending_UFO_scene_captain_talks_agitated_loop
ending_UFO_scene_captain_talks_agitated:
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_WHITE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page3
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
ending_UFO_scene_captain_talks_agitated_loop:
	push bc
		ld hl, ending_C_UFO_captain_agitated
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 

		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_captain_talks_agitated_loop_skip
	push bc

		ld hl, ending_C_UFO_captain_agitated_talking
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 
		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_captain_talks_agitated_loop_skip
	djnz ending_UFO_scene_captain_talks_agitated_loop
ending_UFO_scene_captain_talks_agitated_loop_skip:
	ld hl, ending_C_UFO_captain_idle
	ld de, SPRATR2
	ld b, 8
	call fast_small_LDIRVM 	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	jp fast_FILVRM


;-----------------------------------------------
; input:
; - hl: text
; - b: speech cycles to wait
ending_UFO_scene_minion_talks_page4:
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_PURPLE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page4
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
	jr ending_UFO_scene_minion_talks_loop
ending_UFO_scene_minion_talks:
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_PURPLE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page3
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
ending_UFO_scene_minion_talks_loop:
	push bc
		ld hl, ending_C_UFO_minion_idle
		ld de, SPRATR2 + 4 * 2
		ld b, 8
		call fast_small_LDIRVM 

		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_minion_talks_loop_skip
	push bc

		ld hl, ending_C_UFO_minion_talking
		ld de, SPRATR2 + 4 * 2
		ld b, 8
		call fast_small_LDIRVM 
		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_minion_talks_loop_skip
	djnz ending_UFO_scene_minion_talks_loop
ending_UFO_scene_minion_talks_loop_skip:
	ld hl, ending_C_UFO_minion_idle
	ld de, SPRATR2 + 4 * 2
	ld b, 8
	call fast_small_LDIRVM 	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	jp fast_FILVRM


;-----------------------------------------------
ending_beach_scene_common:
	ld hl, music_beach_bin
	ld a, 8
	call play_music_adjusting_tempo

	ld iy, TEXT_ENDING_C_BEACH_0
	ld b, 1  ; first tile to use
	ld de, NAMTBL2 + 12*32 + 10
	ld ix, CHRTBL2 + 1*256*8
	ld a, 16
	ld (tmp_letter_line_width), a
	ld a, COLOR_WHITE * 16
	ld (tmp_letter_line_color), a
	ld hl, display_paragraph_text_page3
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	ld b, 200
	call wait_b_halts_skippable
	call clear_screen_left_to_right

	call disable_VDP_output
		ld hl, ending_beach_tiles_zx0
		ld c, ENDING_PAGE
		call decompress_tiles_to_all_banks

		ld hl, ending_beach_nametables
		ld de, NAMTBL2 + 4*32+6
		ld bc, #0814
		call state_ending_copy_nametable

		ld hl, ending_beach_sprites_zx0
		ld de, buffer_4096
		call dzx0

		ld hl, buffer_4096
		ld de, SPRTBL2
		ld bc, 192
		call fast_LDIRVM

		ld hl, ending_C_beach_unbrealla_sprites
		ld de, SPRATR2
		ld b, 6*4
		call fast_small_LDIRVM 
	call enable_VDP_output

	ld b, 2
	jp ending_beach_scene_C_wait_skippable


;-----------------------------------------------
ending_beach_scene_C:
	call ending_beach_scene_common

	ld hl, TEXT_ENDING_C_BEACH_1
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_2
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_3
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_4
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_5
	ld a, COLOR_WHITE * 16
	ld b, 7
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_AMBUSH_ELAINE_3
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_7
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_8
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld a, (global_state__objects + TAG_FIRESTONE_FORGE)
	or a
	jr nz, ending_beach_scene_C_plus_entry_point

	ld hl, TEXT_ENDING_C_BEACH_9
	ld a, COLOR_WHITE * 16
	ld b, 10
	jp ending_beach_scene_C_dialogue_line


;-----------------------------------------------
ending_beach_scene_C_plus_entry_point:
	ld hl, TEXT_ENDING_C_PLUS_BEACH_3
	ld a, COLOR_WHITE * 16
	ld b, 6
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_4
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_5
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_6
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_7
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_8
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_9
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_10
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_11
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_12
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_13
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_9
	ld a, COLOR_WHITE * 16
	ld b, 10
	jp ending_beach_scene_C_dialogue_line


;-----------------------------------------------
ending_beach_scene_B:
	call ending_beach_scene_common

	ld hl, TEXT_ENDING_C_BEACH_1
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_2
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_B_BEACH_3
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_B_BEACH_4
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_C_BEACH_5
	ld a, COLOR_WHITE * 16
	ld b, 7
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_AMBUSH_ELAINE_3
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_7
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_8
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld a, (global_state__objects + TAG_FIRESTONE_FORGE)
	or a
	jr nz, ending_beach_scene_B_plus_entry_point

	ld hl, TEXT_ENDING_B_BEACH_9
	ld a, COLOR_WHITE * 16
	ld b, 10
	jp ending_beach_scene_B_dialogue_line_page4


;-----------------------------------------------
ending_beach_scene_B_plus_entry_point:
	ld hl, TEXT_ENDING_C_PLUS_BEACH_3
	ld a, COLOR_WHITE * 16
	ld b, 6
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_4
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_5
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_6
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_7
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_8
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_9
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_10
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_11
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_12
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_13
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_B_PLUS_BEACH_9
	ld a, COLOR_WHITE * 16
	ld b, 10
	jp ending_beach_scene_B_dialogue_line_page4


;-----------------------------------------------
ending_beach_scene_A:
	call ending_beach_scene_common

	ld hl, TEXT_ENDING_C_BEACH_1
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_2
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_A_BEACH_1
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_A_BEACH_2
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_A_BEACH_3
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_A_BEACH_4
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_C_BEACH_7
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_A_BEACH_5
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_A_BEACH_6
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld a, (global_state__objects + TAG_FIRESTONE_FORGE)
	or a
	jr nz, ending_beach_scene_A_plus_entry_point

	ld hl, TEXT_ENDING_A_BEACH_7
	ld a, COLOR_WHITE * 16
	ld b, 10
	jp ending_beach_scene_B_dialogue_line_page4


;-----------------------------------------------
ending_beach_scene_A_plus_entry_point:
	ld hl, TEXT_ENDING_C_PLUS_BEACH_3
	ld a, COLOR_WHITE * 16
	ld b, 6
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_4
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_5
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_6
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_7
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_8
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_9
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_PLUS_BEACH_10
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_A_PLUS_BEACH_1
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_A_PLUS_BEACH_2
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_ENDING_A_PLUS_BEACH_3
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_B_dialogue_line_page4

	ld hl, TEXT_AMBUSH_ELAINE_3
	ld a, COLOR_WHITE * 16
	ld b, 8
	jp ending_beach_scene_C_dialogue_line


;-----------------------------------------------
; input:
; - b: wait animation cycles
ending_beach_scene_C_dialogue_line:
	ld (tmp_letter_line_color), a
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld hl, display_paragraph_text_page3
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
	call ending_beach_scene_C_wait_skippable	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	call fast_FILVRM
	ld b, 25
	jp wait_b_halts_skippable


;-----------------------------------------------
; input:
; - b: wait animation cycles
ending_beach_scene_B_dialogue_line_page4:
	ld (tmp_letter_line_color), a
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld hl, display_paragraph_text_page4
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
	call ending_beach_scene_C_wait_skippable	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	call fast_FILVRM
	ld b, 25
	jp wait_b_halts_skippable


;-----------------------------------------------
; input:
; - b: number of animation cycles
ending_beach_scene_C_wait_skippable:
	push bc
		call ending_beach_scene_C_frame2
		ld b, 50
		call wait_b_halts_skippable
		jr nz, ending_beach_scene_C_wait_skippable_skip
		call ending_beach_scene_C_frame1
		ld b, 50
		call wait_b_halts_skippable
		jr nz, ending_beach_scene_C_wait_skippable_skip
	pop bc
	djnz ending_beach_scene_C_wait_skippable
	ret
ending_beach_scene_C_wait_skippable_skip:
	pop bc
	jp ending_beach_scene_C_frame1  ; always end in frame 1


;-----------------------------------------------
ending_beach_scene_C_frame1:
	ld hl, ending_beach_nametables + 4*20+14
	ld de, NAMTBL2 + (4+4)*32 + (6+14)
	ld bc, #0103
	call state_ending_copy_nametable

	ld hl, ending_beach_nametables + 5*20+14
	ld de, NAMTBL2 + (4+5)*32 + (6+14)
	ld bc, #0103
	call state_ending_copy_nametable

	ld hl, ending_beach_nametables + 6*20+11
	ld de, NAMTBL2 + (4+6)*32 + (6+11)
	ld bc, #0107
	call state_ending_copy_nametable

	ld hl, ending_beach_nametables + 7*20+11
	ld de, NAMTBL2 + (4+7)*32 + (6+11)
	ld bc, #0107
	call state_ending_copy_nametable

	ld hl, ending_C_beach_elaine_michael_sprites
	ld de, SPRATR2 + 4*2
	ld b, 4*4
	jp fast_small_LDIRVM 


;-----------------------------------------------
ending_beach_scene_C_frame2:
	ld hl, ending_beach_nametables + 20*8
	ld de, NAMTBL2 + (4+4)*32 + (6+14)
	ld bc, #0203
	call state_ending_copy_nametable

	ld hl, ending_beach_nametables + 20*8 + 2*3
	ld de, NAMTBL2 + (4+6)*32 + (6+11)
	ld bc, #0207
	call state_ending_copy_nametable

	ld hl, ending_C_beach_elaine_michael_sprites2
	ld de, SPRATR2 + 4*2
	ld b, 4*4
	jp fast_small_LDIRVM 


;-----------------------------------------------
; input:
; - hl: nametable
; - de: ptr to VDP
; - c, b: width, height
state_ending_copy_nametable:
state_ending_copy_nametable_loop_y:
	push bc
		push hl
			push de
				ld b, c
				call fast_small_LDIRVM
			pop hl
			ld bc, 32
			add hl, bc
			ex de, hl
		pop hl
	pop bc
	push bc
		ld b, 0
		add hl, bc
	pop bc
	djnz state_ending_copy_nametable_loop_y
	ret


;-----------------------------------------------
ENDING_LINE_PAGE: MACRO a_line, a_page
	dw a_line
	db a_page
ENDM

ending_C_text_page_ptrs:
	dw ending_C_text_page_1
	dw ending_C_text_page_2
	dw ending_C_text_page_3

ending_C_plus_text_page_ptrs:
	dw ending_C_plus_text_page_1
	dw ending_C_text_page_2
	dw ending_C_text_page_3

ending_B_text_page_ptrs:
	dw ending_B_text_page_1
	dw ending_B_text_page_2
	dw ending_C_text_page_3

ending_B_plus_text_page_ptrs:
	dw ending_B_plus_text_page_1
	dw ending_B_text_page_2
	dw ending_C_text_page_3

ending_B_prime_text_page_ptrs:
	dw ending_B_prime_text_page_1
	dw ending_B_text_page_2
	dw ending_C_text_page_3

ending_B_plus_prime_text_page_ptrs:
	dw ending_B_plus_prime_text_page_1
	dw ending_B_text_page_2
	dw ending_C_text_page_3

ending_C_text_page_1:
	db 16
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_1, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_2, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_3, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_4, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_5, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_6, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_7, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_8, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_9, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_10, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_11, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_12, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_13, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_14, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_15, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_16, TEXT_PAGE3

ending_C_plus_text_page_1:
	db 16
	ENDING_LINE_PAGE TEXT_ENDING_C_PLUS_PAGE_1_1, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_2, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_3, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_4, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_5, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_6, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PLUS_PAGE_1_7, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PLUS_PAGE_1_8, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_9, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_10, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_11, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_12, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_13, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_14, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_15, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_1_16, TEXT_PAGE3

ending_B_text_page_1:
	db 16
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_1, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_2, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_3, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_4, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_5, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_6, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_7, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_8, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_9, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_10, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_11, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_12, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_13, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_14, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_15, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_16, TEXT_PAGE4

ending_B_plus_text_page_1:
	db 16
	ENDING_LINE_PAGE TEXT_ENDING_B_PLUS_PAGE_1_1, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_2, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_3, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_4, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_5, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_6, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_7, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PLUS_PAGE_1_8, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PLUS_PAGE_1_9, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PLUS_PAGE_1_10, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_11, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_12, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_13, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_14, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_15, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_16, TEXT_PAGE4

ending_B_prime_text_page_1:
	db 15
	ENDING_LINE_PAGE TEXT_ENDING_B_PRIME_PAGE_1_1, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_2, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_3, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_4, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_5, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PRIME_PAGE_1_6, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_7, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_8, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_9, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_10, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_11, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_12, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_13, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PRIME_PAGE_1_14, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PRIME_PAGE_1_15, TEXT_PAGE4

ending_B_plus_prime_text_page_1:
	db 15
	ENDING_LINE_PAGE TEXT_ENDING_B_PLUS_PRIME_PAGE_1_1, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_2, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_3, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_4, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_5, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PRIME_PAGE_1_6, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_7, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PLUS_PAGE_1_8, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PLUS_PAGE_1_9, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PLUS_PAGE_1_10, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_11, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_12, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_1_13, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PRIME_PAGE_1_14, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PRIME_PAGE_1_15, TEXT_PAGE4


ending_C_text_page_2:
	db 15
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_1, TEXT_PAGE3
	ENDING_LINE_PAGE 0, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_2, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_3, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_4, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_5, TEXT_PAGE3
	ENDING_LINE_PAGE 0, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_6, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_7, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_8, TEXT_PAGE3
	ENDING_LINE_PAGE 0, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_9, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_10, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_11, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_12, TEXT_PAGE3

ending_B_text_page_2:
	db 15
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_1, TEXT_PAGE3
	ENDING_LINE_PAGE 0, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_2_2, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_2_3, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_2_4, TEXT_PAGE4
	ENDING_LINE_PAGE TEXT_ENDING_B_PAGE_2_5, TEXT_PAGE4
	ENDING_LINE_PAGE 0, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_6, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_7, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_8, TEXT_PAGE3
	ENDING_LINE_PAGE 0, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_9, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_10, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_11, TEXT_PAGE3
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_2_12, TEXT_PAGE3

ending_C_text_page_3:
	db 1
	ENDING_LINE_PAGE TEXT_ENDING_C_PAGE_3_1, TEXT_PAGE3


ending_C_enemy_intro_ptr_table:
	dw ending_enemy_intro_data0  ; snakes
	dw ending_enemy_intro_data1  ; fish
	dw ending_enemy_intro_data2  ; bees
	dw ending_enemy_intro_data3  ; frogs
	dw ending_enemy_intro_data4  ; carnivore plant
	dw ending_enemy_intro_data5  ; bats
	dw ending_enemy_intro_data6  ; skeletons
	dw ending_enemy_intro_data7  ; monkeys
	dw ending_enemy_intro_data8  ; caves skeletons
	dw ending_enemy_intro_data9  ; rockmen
	dw ending_enemy_intro_data10  ; ants
	dw ending_enemy_intro_data11  ; fire imps
	dw ending_enemy_intro_data12  ; owl
	dw ending_enemy_intro_data13  ; fishmen
	dw ending_enemy_intro_data14  ; ghosts
	dw ending_enemy_intro_data15  ; sentinel
	dw ending_enemy_intro_data23  ; aliens
	dw 0  ; sentinel

ending_B_enemy_intro_ptr_table
ending_B_plus_enemy_intro_ptr_table
ending_C_plus_enemy_intro_ptr_table:
	dw ending_enemy_intro_data0  ; snakes
	dw ending_enemy_intro_data1  ; fish
	dw ending_enemy_intro_data2  ; bees
	dw ending_enemy_intro_data3  ; frogs
	dw ending_enemy_intro_data4  ; carnivore plant
	dw ending_enemy_intro_data5  ; bats
	dw ending_enemy_intro_data6  ; skeletons
	dw ending_enemy_intro_data7  ; monkeys
	dw ending_enemy_intro_data8  ; caves skeletons
	dw ending_enemy_intro_data9  ; rockmen
	dw ending_enemy_intro_data10  ; ants
	dw ending_enemy_intro_data11  ; fire imps
	dw ending_enemy_intro_data12  ; owl
	dw ending_enemy_intro_data13  ; fishmen
	dw ending_enemy_intro_data14  ; ghosts
	dw ending_enemy_intro_data15  ; sentinel
	dw ending_enemy_intro_data16  ; snails
	dw ending_enemy_intro_data17  ; blobs
	dw ending_enemy_intro_data18  ; walkers
	dw ending_enemy_intro_data19  ; drones
	dw ending_enemy_intro_data20  ; giant walker
	dw ending_enemy_intro_data21  ; mushrooms
	dw ending_enemy_intro_data22  ; giant mushroom
	dw ending_enemy_intro_data23  ; aliens
	dw 0  ; sentinel


;-----------------------------------------------
; input:
; - ix: ptr to page ptrs
; - b: number of pages
; - iy: ptr to enemy intro ptrs
ending_final_text_scene:
	push bc
		call disable_VDP_output

			ld hl, music_credits_bin
			ld a, 14
			call play_music_adjusting_tempo

			call set_bitmap_mode

			; set the 12 tiles of each row in the middle bank to 0
			ld hl, NAMTBL2 + 8*32
			ld b, 6
ending_final_text_scene_nametable_init_loop:
			push bc
				push hl
					ld bc, 12
					xor a
					call fast_FILVRM
				pop hl
				ld bc, 32
				add hl, bc
			pop bc
			djnz ending_final_text_scene_nametable_init_loop

			; Tiles will be organized like this:
			; bank 1:
			; - 0 - 76: banner tiles
			; - 128 - 256: parts used by text
			; bank 2:
			; - for every row of 32:
			;   - 0 - 12 are used by the enemy intro code
			;   - text uses tiles 12 - 32
			; bank 3:
			; - 0 - 128: parts used by text
			; - 128 - 204: banner tiles

			ld hl, ending_mayabanner_tiles_zx0
			ld de, buffer_4096
			call dzx0

			; bank 1:
			ld hl, buffer_4096
			ld de, CHRTBL2
			ld bc, 76*8
			call fast_LDIRVM
			ld hl, buffer_4096 + 256*8
			ld de, CLRTBL2
			ld bc, 76*8
			call fast_LDIRVM
			ld hl, ending_mayabanner_nametable
			ld de, NAMTBL2
			ld bc, 32*4
			call fast_LDIRVM

			; bank 3:
			ld hl, buffer_4096
			ld de, CHRTBL2 + 8 * (2*256+128)
			ld bc, 76*8
			call fast_LDIRVM
			ld hl, buffer_4096 + 256*8
			ld de, CLRTBL2 + 8 * (2*256+128)
			ld bc, 76*8
			call fast_LDIRVM
			ld hl, ending_mayabanner_nametable + 32*4
			ld de, NAMTBL2 + 32*20
			ld bc, 32*4
			call fast_LDIRVM

			xor a
			ld (ending__tmp_banner_state), a
			ld (ending__tmp_banner_top_offset), a
			ld (ending__tmp_banner_bottom_offset), a

			ld (ending__tmp_enemy_intro_table_ptr), iy
			xor a
			ld (ending__tmp_enemy_intro_table_next), a
			ld (ending__tmp_enemy_intro_state), a
			ld (ending__tmp_enemy_intro_state_timer), a
		call enable_VDP_output
	pop bc

	xor a
	ld (ending__tmp_text_page_number), a

ending_final_text_scene_loop:
	push ix
	push bc
ending_final_text_scene_pages_loop:
		push bc
		push ix
			; clear the text area:
			ld b, 16
			ld hl, CHRTBL2 + 8 * (4*32 + 12)
ending_final_text_scene_clear_text_area_loop1:
			push bc
				push hl
					ld bc, 20*8
					xor a
					call fast_FILVRM
				pop hl
				ld bc, 32*8
				add hl, bc
			pop bc
			djnz ending_final_text_scene_clear_text_area_loop1
			ld b, 16
			ld hl, CLRTBL2 + 8 * (4*32 + 12)
ending_final_text_scene_clear_text_area_loop2:
			push bc
				push hl
					ld bc, 20*8
					xor a
					call fast_FILVRM
				pop hl
				ld bc, 32*8
				add hl, bc
			pop bc
			djnz ending_final_text_scene_clear_text_area_loop2

			; Draw the text:
			ld a, (ix)
			ld b, (ix + 1)
			ld ixl, a
			ld ixh, b
			ld b, (ix)  ; number of sentences
			inc ix
			ld de, CHRTBL2 + 8 * (4*32 + 12)
ending_final_text_scene_sentences_loop:
			push bc
			push ix
				push de
					push de
						ld l, (ix)
						ld h, (ix + 1)
						ld a, l
						or h
					pop de
					jr z, ending_final_text_scene_sentences_loop_skip
					push de
						ex de, hl
						ld hl, copy_text_from_another_page
						ld c, (ix + 2)
						call call_hl_in_page_c_8000

						ld hl, clear_text_rendering_buffer
						ld c, TEXT_PAGE
						call call_hl_in_page_c_8000

						ld iyh, #80
						ld hl, draw_sentence_to_vdp_internal_from_buffer_4096
						ld c, TEXT_PAGE
						call call_hl_in_page_c_8000
					pop de  ; target VRAM address

					; Render character by character:
					ld b, 20
					ld hl, text_draw_buffer
ending_final_text_scene_character_loop:
					push bc
						push hl
							push de
								push de
									ld b, 8
									call fast_small_LDIRVM
								pop hl
								ld bc, CLRTBL2 - CHRTBL2
								add hl, bc

								; fade in:
								push hl
									ld a, COLOR_DARK_BLUE*16
									ld b, 8
									call fast_small_FILVRM
									call ending_final_text_scene_decoration_update_cycle
									jp z, ending_final_text_scene_skip_request
								pop hl
								push hl
									ld a, COLOR_BLUE*16
									ld b, 8
									call fast_small_FILVRM
									call ending_final_text_scene_decoration_update_cycle
									jp z, ending_final_text_scene_skip_request
								pop hl
								push hl
									ld a, COLOR_LIGHT_BLUE*16
									ld b, 8
									call fast_small_FILVRM
									call ending_final_text_scene_decoration_update_cycle
									jp z, ending_final_text_scene_skip_request
								pop hl
								push hl
									ld a, COLOR_WHITE*16
									ld b, 8
									call fast_small_FILVRM
									call ending_final_text_scene_decoration_update_cycle
									jp z, ending_final_text_scene_skip_request
								pop hl
							pop hl
							ld bc, 8
							add hl, bc
							ex de, hl
						pop hl
						ld bc, 8
						add hl, bc
					pop bc
					djnz ending_final_text_scene_character_loop
ending_final_text_scene_sentences_loop_skip:
				pop hl
				ld bc, 32*8
				add hl, bc
				ex hl, de
			pop ix
			pop bc
			inc ix  ; next line
			inc ix
			inc ix
			dec b
			jp nz, ending_final_text_scene_sentences_loop

			ld bc, 50*5  ; wait 5 seconds
ending_final_text_scene_wait_loop:
			push bc
				call ending_final_text_scene_decoration_update_cycle
			pop bc
			jp z, ending_final_text_scene_skip_request2
			dec bc
			ld a, b
			or c
			jr nz, ending_final_text_scene_wait_loop
		pop ix
		pop bc
ending_final_text_scene_pages_loop_next_page_request:
		inc ix  ; next page
		inc ix
		ld a, (ending__tmp_text_page_number)
		cp 2
		jr z, ending_final_text_scene_pages_loop_already_last_page
		inc a
ending_final_text_scene_pages_loop_already_last_page:
		ld (ending__tmp_text_page_number), a
		dec b
		jp nz, ending_final_text_scene_pages_loop
	pop bc
	pop ix
	jp ending_final_text_scene_loop

ending_final_text_scene_skip_request:
								pop hl
							pop de
						pop hl
					pop bc
				pop de
			pop ix
			pop bc
ending_final_text_scene_skip_request2
		pop ix
		pop bc
		jr ending_final_text_scene_pages_loop_next_page_request


;-----------------------------------------------
ending_final_text_scene_banner_scroll_cycle:
    call update_keyboard_buffers
    ld a, (keyboard_clicks)
    bit KEY_WEAPON_BIT, a
    jp nz, ending_final_text_scene_banner_scroll_cycle_skip_request

	halt
	ld hl, ending__tmp_banner_state
	inc (hl)
	ld a, (hl)
	cp 24
	ret c
	ld (hl), 0

	; scroll top banner to the left and bottom banner to the right:
	ld hl, ending__tmp_banner_top_offset
	inc (hl)
	ld hl, ending__tmp_banner_bottom_offset
	dec (hl)

	ld a, (ending__tmp_banner_top_offset)
	and #1f
	ld hl, ending_mayabanner_nametable
	call ending_final_text_scene_banner_scroll_synthesize_nametable
	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 32*4
	call fast_LDIRVM

	ld a, (ending__tmp_banner_bottom_offset)
	and #1f
	ld hl, ending_mayabanner_nametable + 4*32
	call ending_final_text_scene_banner_scroll_synthesize_nametable
	ld hl, buffer_4096
	ld de, NAMTBL2 + 32*20
	ld bc, 32*4
	call fast_LDIRVM
	or 1  ; no skip request
	ret

ending_final_text_scene_banner_scroll_cycle_skip_request:
	ld a, (ending__tmp_text_page_number)
	cp 2
	jp z, ending_C_done
	xor a  ; if we have not yet shown the last page, just request skip to the next page
	ret

ending_final_text_scene_banner_scroll_synthesize_nametable:
	ld de, buffer_4096
	ld b, 4
ending_final_text_scene_banner_scroll_synthesize_nametable_loop_y:
	push bc
		push hl
		push af
			ld b, 32
ending_final_text_scene_banner_scroll_synthesize_nametable_loop_x:
			push af
			push hl
				and #1f
				ADD_HL_A
				ld a, (hl)
				ld (de), a
				inc de
			pop hl
			pop af
			inc a		
			djnz ending_final_text_scene_banner_scroll_synthesize_nametable_loop_x
		pop af
		pop hl
		ld bc, 32
		add hl, bc
	pop bc
	djnz ending_final_text_scene_banner_scroll_synthesize_nametable_loop_y
	ret


;-----------------------------------------------
; returns:
; - z: player requested skip
; - nz: no skip request
ending_final_text_scene_decoration_update_cycle:
	call ending_final_text_scene_banner_scroll_cycle
	ret z  ; player requested skip
	call ending_final_text_scene_enemy_intro_cycle
	or 1  ; no skip request
	ret


;-----------------------------------------------
ending_final_text_scene_enemy_intro_cycle:
	ld a, (ending__tmp_enemy_intro_state)
	or a
	jp z, ending_final_text_scene_enemy_intro_cycle_load_data
	dec a
	jr z, ending_final_text_scene_enemy_intro_cycle_state_1  ; appearing
	dec a
	jp z, ending_final_text_scene_enemy_intro_cycle_state_2  ; showing
	dec a
	; jr z, ending_final_text_scene_enemy_intro_cycle_state_3  ; disappearing
	; ret
ending_final_text_scene_enemy_intro_cycle_state_3:
	; remove the text, and scroll the name table to the left:
	ld a, (ending__tmp_enemy_intro_state_timer)
	or a
	jr nz, ending_final_text_scene_enemy_intro_cycle_state_3_continue
	; clear text:
	ld hl, CLRTBL2 + 15*32*8
	ld bc, 12*8
	xor a
	call fast_FILVRM
	ld hl, CLRTBL2 + 16*32*8
	ld bc, 12*8
	xor a
	call fast_FILVRM
ending_final_text_scene_enemy_intro_cycle_state_3_continue:
	ld hl, ending__tmp_enemy_intro_state_timer
	ld a, (hl)
	inc (hl)
	rrca
	rrca
	rrca
	and #1f
	ld hl, NAMTBL2 + 8*32
	ADD_HL_A
	ld b, 6
ending_final_text_scene_enemy_intro_cycle_state_3_loop:
	push bc
		push hl
			xor a
			ld b, 1
			call fast_small_FILVRM
		pop hl
		ld bc, 32
		add hl, bc
	pop bc
	djnz ending_final_text_scene_enemy_intro_cycle_state_3_loop

	; when done, move to the next ptr in the enemy intro ptrs table:
	ld a, (ending__tmp_enemy_intro_state_timer)
	cp 80
	ret nz
	ld hl, ending__tmp_enemy_intro_table_next
	inc (hl)
	xor a
	ld (ending__tmp_enemy_intro_state), a
	ld (ending__tmp_enemy_intro_state_timer), a
	ret

ending_final_text_scene_enemy_intro_cycle_state_1:
	; scroll name table to the right:
	ld hl, ending__tmp_enemy_intro_state_timer
	inc (hl)
	ld a, (hl)
	rrca
	rrca
	rrca
	and #1f  ; a = x coordinate of the name table
	ret z
	ld c, a

	ld a, 10
	sub c
	ld hl, buffer_4096 + 2048
	ADD_HL_A
	ld de, NAMTBL2 + 8*32
	ld b, 6
ending_final_text_scene_enemy_intro_cycle_state_1_loop:
	push bc
		; copy "c" bytes to "de" from "hl"
		push hl
			push de
				ld b, c
				call fast_small_LDIRVM
			pop hl
			ld bc, 32
			add hl, bc
			ex de, hl
		pop hl
		ld bc, 10
		add hl, bc
	pop bc
	djnz ending_final_text_scene_enemy_intro_cycle_state_1_loop

	ld a, (ending__tmp_enemy_intro_state_timer)
	cp 80
	ret nz
ending_final_text_scene_enemy_intro_cycle_state_1_done:
	; when done, write the text:
	; temporarily save the text buffer, just in case we were in the middle of writing on the right:
	ld hl, text_draw_buffer
	ld de, buffer_4096 + 3*1024
	ld bc, 32*8
	ldir
	; line 1:
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096 + 2048 + 6*10, CHRTBL2 + 8*(256 + 7*32), COLOR_WHITE*16, 12
	; line 2:
	ld hl, buffer_4096 + 2048 + 6*10
	ld a, (hl)
	inc a
	ADD_HL_A
	ld a, (hl)
	or a
	jr z, ending_final_text_scene_enemy_intro_cycle_state_1_done_no_second_sentence
	ld de, CHRTBL2 + 8*(256 + 8*32)
	ld iy, #8000 + COLOR_WHITE*16
	ld b, 12
	call draw_sentence_to_vdp_from_another_page
ending_final_text_scene_enemy_intro_cycle_state_1_done_no_second_sentence:

	; restore text_draw_buffer:
	ld hl, buffer_4096 + 3*1024
	ld de, text_draw_buffer
	ld bc, 32*8
	ldir

	ld hl, ending__tmp_enemy_intro_state
	inc (hl)
	xor a
	ld (ending__tmp_enemy_intro_state_timer), a
	ret

ending_final_text_scene_enemy_intro_cycle_state_2:
	; wait a bit:
	ld hl, ending__tmp_enemy_intro_state_timer
	inc (hl)
	ld a, (hl)
	cp 200
	ret nz
	ld hl, ending__tmp_enemy_intro_state
	inc (hl)
	xor a
	ld (ending__tmp_enemy_intro_state_timer), a
	ret

ending_final_text_scene_enemy_intro_cycle_load_data:
	xor a
	ld (ending__tmp_enemy_intro_state_timer), a
	inc a
	ld (ending__tmp_enemy_intro_state), a
	; get the next ptr (and see if we need to cycle the table)
	ld a, (ending__tmp_enemy_intro_table_next)
	add a, a
	ld hl, (ending__tmp_enemy_intro_table_ptr)
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ld a, e
	or d
	jr nz, ending_final_text_scene_enemy_intro_cycle_load_data_ptr_set
	; we have reached the end of the table, loop back;
	xor a
	ld (ending__tmp_enemy_intro_table_next), a
	jr ending_final_text_scene_enemy_intro_cycle_load_data
ending_final_text_scene_enemy_intro_cycle_load_data_ptr_set:
	ld hl, buffer_4096
	ex de, hl
	call dzx0

	; decompressed data is:
    ; - name table: 10*6
    ; - text line 1 (length + data)
    ; - text line 2 (length + data)
    ; - number of tiles 1 * 8: n*8
    ; - VDP ptr 1 (2 bytes)
    ; - pattern data 1: n*8
    ; - color data 1: n*8
    ; - number of tiles 2: n*8
    ; - VDP ptr 2 (2 bytes)
    ; - pattern data 2: n*8
    ; - color data 2: n*8
    ; ...
    ; - 0

	; Upload the tiles to VDP, and nametable and text somewhere in buffer_4096 that will not be overwritten
	ld a, (buffer_4096 + 10*6)  ; text length
	add a, 60 + 1
	ld c, a
	ld b, 0
	ld hl, buffer_4096
	push hl
		add hl, bc
		ld a, (hl)  ; length of the second text
		inc a
		ADD_BC_A
	pop hl
	push hl
	push bc
		ld de, buffer_4096 + 2048  ; we copy the name table and text to buffer_4096 + 2048
		ldir
	pop bc
	pop ix
	add ix, bc
ending_final_text_scene_enemy_intro_cycle_load_data_tile_upload_loop:
	ld a, (ix)  ; n tiles
	or a
	ret z  ; we are done
	ld e, (ix + 1)
	ld d, (ix + 2)
	inc ix
	inc ix
	inc ix
	push ix
	pop hl
	; upload "a" tiles from "hl" to "de":
	ld b, 0
	ld c, a
	push bc
	push hl
		push de
			call fast_LDIRVM
		pop hl
		ld bc, CLRTBL2 - CHRTBL2
		add hl, bc
		ex de, hl
	pop hl
	pop bc
	add hl, bc
	push bc
		call fast_LDIRVM
	pop bc
	add ix, bc
	add ix, bc
	jr ending_final_text_scene_enemy_intro_cycle_load_data_tile_upload_loop

