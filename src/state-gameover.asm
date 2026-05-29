;-----------------------------------------------
state_game_over_text_table:
	dw TEXT_GAME_OVER, CHRTBL2 + (3*32+13)*8, #80f0
	db 6, TEXT_PAGE
	dw TEXT_GAMEOVER_STATS_0, CHRTBL2 + (12*32+4)*8, #8050
	db 10, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_1, CHRTBL2 + (12*32+19)*8, #8050
	db 10, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_2, CHRTBL2 + (13*32+4)*8, #8050
	db 10, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_3, CHRTBL2 + (13*32+19)*8, #8050
	db 10, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_4, CHRTBL2 + (14*32+2)*8, #8050
	db 8, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_5, CHRTBL2 + (14*32+10)*8, #8050
	db 8, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_6, CHRTBL2 + (14*32+18)*8, #8050
	db 8, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_7, CHRTBL2 + (14*32+25)*8, #8050
	db 8, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_8, CHRTBL2 + (15*32+4)*8, #8050
	db 10, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_9, CHRTBL2 + (15*32+19)*8, #8050
	db 10, TEXT_PAGE3
	dw TEXT_GAMEOVER_STATS_10, CHRTBL2 + (16*32+19)*8, #8050
	db 10, TEXT_PAGE3
state_game_over_text_table_end:

state_game_over_text_table_continue:
	dw TEXT_CONTINUE, CHRTBL2 + (7*32+13)*8, #80f0
	db 6, TEXT_PAGE
	dw TEXT_YES, CHRTBL2 + (8*32+14)*8, #80f0
	db 4, TEXT_PAGE
	dw TEXT_NO, CHRTBL2 + (9*32+14)*8, #80f0
	db 4, TEXT_PAGE
state_game_over_text_table_continue_end


;-----------------------------------------------
state_game_over:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	call stop_music

	call clear_screen_left_to_right

	call set_bitmap_mode

	ld ix, state_game_over_text_table
	ld b, (state_game_over_text_table_end - state_game_over_text_table) / 8
	call state_game_over_print_text_table

	; print stats:
	call state_game_over_print_seed
	call state_game_over_print_difficulty
	call state_game_over_print_n_weapons
	call state_game_over_print_n_items
	call state_game_over_print_n_maps
	call state_game_over_print_n_coins
	call state_game_over_print_continued  ; whether the player continued or not
	call state_game_over_print_ending
	call state_game_over_print_time
	call state_game_over_print_achievements
	call state_game_over_print_bosses

	ld hl, (stats__ending)
	ld bc, TEXT_ENDING_FAIL
	or a
	sbc hl, bc
	jr z, state_game_over_ask_for_continue
	; player reached a good ending:
	ld b, 100
	call wait_b_halts
	xor a
	ld (keyboard_clicks), a
	call wait_for_click
	jr state_game_over_quit

state_game_over_ask_for_continue:
	ld hl, music_gameover_bin
	ld a, 5
	call play_music_adjusting_tempo

	ld b, 100
	call wait_b_halts

	ld ix, state_game_over_text_table_continue
	ld b, (state_game_over_text_table_continue_end - state_game_over_text_table_continue) / 8
	call state_game_over_print_text_table
	
	; continue yes/no:
	ld a, 8 * 8 - 1  ; y coordinate of the first option
	ld (tmp_dialog_options_position), a
	ld hl, dialog_sprites_bin
	ld de, SPRTBL2
	ld bc, dialog_sprites_bin_end - dialog_sprites_bin
	call fast_LDIRVM_from_sprites_page
	ld hl, state_yesno_dialog_mainloop
	ld c, YES_NO_DIALOG_PAGE
	call call_hl_in_page_c_8000
	ld a, (tmp_dialog_pointer_position)
	or a
	jr z, state_game_over_continue
	; jr state_game_over_quit

state_game_over_quit:
	call clear_screen_left_to_right

    ld hl, state_braingames
    ld a, BRAINGAMES_PAGE
    jp jp_to_hl_in_page_a_8000

state_game_over_continue:
	; update stats:
	ld a, 1
	ld (stats__continued), a

	call clear_screen_left_to_right
	ld hl, player_max_health
	ld a, (hl)
	dec hl
	ld (hl), a
	ld a, PLAYER_MAX_OXYGEN
	ld (player_oxygen), a

	ld hl, RAM_to_zero_on_continue
	ld bc, (RAM_to_zero_on_continue_end - RAM_to_zero_on_continue) - 1
	call clear_memory

	jp state_play_from_continue


;-----------------------------------------------
state_game_over_print_seed:
	ld hl, gamestart_generate_random_seed_string
	ld c, GAMESTART_PAGE
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO_OFFSET buffer_4096, CHRTBL2 + (13*32+10)*8, COLOR_DARK_YELLOW*16 + #08 * 256, 4
	ret


;-----------------------------------------------
state_game_over_print_difficulty:
	ld a, (current_world__difficulty)
	ld de, TEXT_DIFFICULTY_EASY
	or a
	jr z, state_game_over_print_difficulty_set
	ld de, TEXT_DIFFICULTY_NORMAL
	dec a
	jr z, state_game_over_print_difficulty_set
	ld de, TEXT_DIFFICULTY_HARD
	dec a
	jr z, state_game_over_print_difficulty_set
	ld de, TEXT_DIFFICULTY_HARDEST
state_game_over_print_difficulty_set:
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO_OFFSET buffer_4096, CHRTBL2 + (13*32+25)*8, COLOR_DARK_YELLOW*16 + #80 * 256, 6
	ret


;-----------------------------------------------
state_game_over_print_n_weapons:
	ld a, (stats__n_weapons_collected)
	ld ixl, a
	ld b, 2
	ld de, CHRTBL2 + (14*32+7)*8
	ld iy, COLOR_DARK_YELLOW*16 + #20 * 256
	ld hl, draw_inventory_number_ixl
	ld c, TEXT_PAGE
	jp call_hl_in_page_c_8000


;-----------------------------------------------
state_game_over_print_n_items:
	ld a, (stats__n_items_collected)
	ld ixl, a
	ld b, 2
	ld de, CHRTBL2 + (14*32+14)*8
	ld iy, COLOR_DARK_YELLOW*16 + #40 * 256
	ld hl, draw_inventory_number_ixl
	ld c, TEXT_PAGE
	jp call_hl_in_page_c_8000


;-----------------------------------------------
state_game_over_print_n_maps:
	ld a, (stats__n_maps_collected)
	ld ixl, a
	ld b, 2
	ld de, CHRTBL2 + (14*32+21)*8
	ld iy, COLOR_DARK_YELLOW*16 + #10 * 256
	ld hl, draw_inventory_number_ixl
	ld c, TEXT_PAGE
	jp call_hl_in_page_c_8000


;-----------------------------------------------
text_numbers_gameover:  ; we copy it here since 'text_numbers' is in another page
    db 22, 24, 26, 28, 30, 32, 35, 37, 39, 41

state_game_over_print_n_coins:
	ld hl, (stats__n_coins_collected)
	ld ix, buffer_4096 + 1
	ld c, 0  ; number of digits
	ld de, 10000
	call state_game_over_print_n_coins_add_digit
	ld de, 1000
	call state_game_over_print_n_coins_add_digit
	ld de, 100
	call state_game_over_print_n_coins_add_digit
	ld de, 10
	call state_game_over_print_n_coins_add_digit
	ld de, 1
	call state_game_over_print_n_coins_add_digit
	ld a, c
	or a
	jr nz, state_game_over_print_n_coins_continue
	; no digits, just add a 0:
	inc c
	ld (ix), 22  ; 0
state_game_over_print_n_coins_continue:
	ld a, c
	ld (buffer_4096), a  ; length
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO_OFFSET buffer_4096, CHRTBL2 + (14*32+28)*8, COLOR_DARK_YELLOW*16 + #08 * 256, 4
	ret


state_game_over_print_n_coins_add_digit:
	ld b, 0  ; new digit
state_game_over_print_n_coins_add_digit_loop:
	or a
	sbc hl, de
	jr c, state_game_over_print_n_coins_add_digit_loop_done
	inc b
	jr state_game_over_print_n_coins_add_digit_loop
state_game_over_print_n_coins_add_digit_loop_done:
	add hl, de
	ld a, b
	or c  ; any digit?  (of b == 0 and c == 0, we are still with the leading zeroes)
	ret z
	; add digit:

	push hl
		ld a, b
		ld hl, text_numbers_gameover
		ADD_HL_A
		ld a, (hl)
		ld (ix), a
		inc ix
		inc c  ; number of digits
	pop hl
	ret


;-----------------------------------------------
state_game_over_print_continued:
	ld hl, TEXT_NO
	ld a, (stats__continued)
	or a
	jr z, state_game_over_print_continued_continue
	ld hl, TEXT_YES
state_game_over_print_continued_continue:
	ld de, CHRTBL2 + (12*32+25)*8
	ld iy, COLOR_DARK_YELLOW*16 + #80 * 256
	ld b, 4
	jp draw_sentence_to_vdp_from_another_page	


;-----------------------------------------------
state_game_over_print_ending:
	ld de, (stats__ending)
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO_OFFSET buffer_4096, CHRTBL2 + (12*32+13)*8, COLOR_DARK_YELLOW*16 + #80 * 256, 4
	ret


;-----------------------------------------------
state_game_over_print_time:
	ld a, (stats__time + 3)  ; hours
	cp #ff
	jp z, state_game_over_print_time_max
	ld ix, buffer_4096 + 1
	ld c, 0  ; number of characters
	ld e, 100
	call state_game_over_print_time_add_digit
	ld e, 10
	call state_game_over_print_time_add_digit
	ld e, 1
	call state_game_over_print_time_add_digit
	ld (ix), 122  ; h
	inc ix
	inc c

	ld a, (stats__time + 2)  ; minutes
	ld e, 10
	call state_game_over_print_time_add_digit
	ld e, 1
	call state_game_over_print_time_add_digit
	ld (ix), 130  ; m
	inc ix
	inc c

	ld a, (stats__time + 1)  ; seconds
	ld e, 10
	call state_game_over_print_time_add_digit
	ld e, 1
	call state_game_over_print_time_add_digit
	ld (ix), 143  ; s
	inc c

	ld a, c
	ld (buffer_4096), a  ; length
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO_OFFSET buffer_4096, CHRTBL2 + (15*32+22)*8, COLOR_DARK_YELLOW*16 + #10 * 256, 7
	ret

state_game_over_print_time_max:
	; max
	ld de, TEXT_MAX_TIME
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO_OFFSET buffer_4096, CHRTBL2 + (15*32+22)*8, COLOR_DARK_YELLOW*16 + #10 * 256, 4
	ret


state_game_over_print_time_add_digit:
	ld b, 0  ; new digit
state_game_over_print_time_add_digit_loop:
	cp e
	jr c, state_game_over_print_time_add_digit_loop_done
	sub e
	inc b
	jr state_game_over_print_time_add_digit_loop
state_game_over_print_time_add_digit_loop_done:
	push af
		ld a, b
		ld hl, text_numbers_gameover
		ADD_HL_A
		ld a, (hl)
		ld (ix), a
		inc ix
		inc c  ; number of digits
	pop af
	ret


;-----------------------------------------------
state_game_over_print_achievements_table:
	dw TEXT_ACHIEVEMENT_NOMISS
	dw TEXT_ACHIEVEMENT_ANIMALS
	dw TEXT_ACHIEVEMENT_FORGE

state_game_over_print_achievements:
	ld hl, stats__achievements
	ld b, 4  ; max achievements
	ld de, CHRTBL2 + (17*32+20)*8
state_game_over_print_achievements_loop:
	ld a, (hl)
	or a
	ret z  ; no more achievements
	push hl
	push bc
		push de
			dec a
			add a, a
			ld hl, state_game_over_print_achievements_table
			ADD_HL_A
			ld e, (hl)
			inc hl
			ld d, (hl)
			ld hl, copy_text_from_another_page
			ld c, TEXT_PAGE3
			call call_hl_in_page_c_8000
		pop de  ; vdp address
		push de
			ld hl, buffer_4096
			ld iy, COLOR_DARK_YELLOW*16 + #80 * 256
			ld b, 8
			call draw_sentence_to_vdp_from_another_page
		pop hl
		ld bc, 32*8
		add hl, bc
		ex de, hl  ; next line
	pop bc
	pop hl
	inc hl
	djnz state_game_over_print_achievements_loop
	ret


;-----------------------------------------------
; input:
; - b: achievement ID for stats
add_achievement_to_stats:
	ld hl, stats__achievements
add_achievement_to_stats_loop:
	ld a, (hl)
	or a
	jr z, add_achievement_to_stats_spot_found
	inc hl
	jr add_achievement_to_stats_loop
add_achievement_to_stats_spot_found:
	ld (hl), b
	ret


;-----------------------------------------------
state_game_over_print_bosses_table:
	dw TEXT_BOSS_HURAKAN  ; 1
	dw TEXT_BOSS_CAMAZOTZ
	dw TEXT_BOSS_CABRAKAN
	dw TEXT_XIBALBA_BOSS_NAME_1  ; 4
	dw TEXT_XIBALBA_BOSS_NAME_2
	dw TEXT_XIBALBA_BOSS_NAME_3
	dw TEXT_XIBALBA_BOSS_NAME_4
	dw TEXT_XIBALBA_BOSS_NAME_5
	dw TEXT_XIBALBA_BOSS_NAME_6
	dw TEXT_XIBALBA_BOSS_NAME_7
	dw TEXT_XIBALBA_BOSS_NAME_8
	dw TEXT_XIBALBA_BOSS_NAME_9
	dw TEXT_XIBALBA_BOSS_NAME_10
	dw TEXT_XIBALBA_BOSS_NAME_11
	dw TEXT_XIBALBA_BOSS_NAME_12  ; 15
	dw TEXT_BOSS_CHARYBDIS  ; 16
	dw TEXT_BOSS_SCYLLA  ; 17
	dw TEXT_BOSS_CHARYBDIS_SCYLLA  ; 18

state_game_over_print_bosses:
	ld hl, stats__bosses
	ld b, 8  ; max bosses
	ld de, CHRTBL2 + (16*32+5)*8
state_game_over_print_bosses_loop:
	ld a, (hl)
	or a
	ret z  ; no more boss names
	; check if it's boss 4, which will have a composite name:
	cp 3
	jr c, state_game_over_print_bosses_loop_not_boss4
	cp 16
	jr nc, state_game_over_print_bosses_loop_not_boss4
	; boss 4: we need to concatenate the next 2 names:
	push bc
	push hl
		push de
			dec a
			add a, a
			ld hl, state_game_over_print_bosses_table
			ADD_HL_A
			ld e, (hl)
			inc hl
			ld d, (hl)
			ld hl, copy_text_from_another_page
			ld c, TEXT_PAGE3
			call call_hl_in_page_c_8000  ; copy the first name fo buffer_4096
			; de: ptr to after the name that was copied
			push de
			pop ix
		pop de
	pop hl
	inc hl
	push hl
		push de
			ld a, (hl)
			dec a
			add a, a
			ld hl, state_game_over_print_bosses_table
			ADD_HL_A
			ld e, (hl)
			inc hl
			ld d, (hl)
			ld hl, copy_text_from_another_page_to_ix
			ld c, TEXT_PAGE3
			call call_hl_in_page_c_8000  ; copy the first name fo buffer_4096
			ld a, (ix)  ; length of the second name
			ld hl, buffer_4096
			add a, (hl)
			ld (hl), a
			inc (hl)
			ld (ix), 179  ; '/'
			jr state_game_over_print_bosses_loop_not_boss4_continue
state_game_over_print_bosses_loop_not_boss4:
	push bc
	push hl
		push de
			dec a
			add a, a
			ld hl, state_game_over_print_bosses_table
			ADD_HL_A
			ld e, (hl)
			inc hl
			ld d, (hl)
			ld hl, copy_text_from_another_page
			ld c, TEXT_PAGE3
			call call_hl_in_page_c_8000
state_game_over_print_bosses_loop_not_boss4_continue:
		pop de  ; vdp address
		push de
			ld hl, buffer_4096
			ld iy, COLOR_DARK_YELLOW*16 + #80 * 256
			ld b, 14
			call draw_sentence_to_vdp_from_another_page
		pop hl
		ld bc, 32*8
		add hl, bc
		ex de, hl  ; next line
	pop hl
	pop bc
	inc hl
	dec b
	jp nz, state_game_over_print_bosses_loop
	ret


;-----------------------------------------------
state_game_over_print_text_table:
	push bc
		ld e, (ix)
		ld d, (ix + 1)
		ld c, (ix + 7)
		ld a, c
		cp TEXT_PAGE
		jr nz, state_game_over_print_text_table_page3
state_game_over_print_text_table_page1:
		ex de, hl
		jr state_game_over_print_text_table_page1_continue
state_game_over_print_text_table_page3:
		ld hl, copy_text_from_another_page
		call call_hl_in_page_c_8000
		ld hl, buffer_4096
state_game_over_print_text_table_page1_continue:
		ld e, (ix + 2)
		ld d, (ix + 3)
		ld a, (ix + 4)
		ld iyl, a
		ld a, (ix + 5)
		ld iyh, a
		ld b, (ix + 6)  ; text width
		push ix
			call draw_sentence_to_vdp_from_another_page	
		pop ix

		ld bc, 8
		add ix, bc
	pop bc
	djnz state_game_over_print_text_table
	ret