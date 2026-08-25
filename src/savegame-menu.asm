;-----------------------------------------------
savegame_menu:
	call clear_screen_left_to_right
	call disable_VDP_output
		ld hl, dialog_sprites_bin
		ld de, SPRTBL2
		ld bc, dialog_sprites_bin_end - dialog_sprites_bin
		call fast_LDIRVM_from_sprites_page

		call savegame_menu_draw

		xor a
		ld (tmp_dialog_pointer_position), a
	call enable_VDP_output

savegame_menu_loop:
	halt
	call update_keyboard_buffers
	call savegame_menu_update_pointer_sprite
	call savegame_menu_draw_pointer_sprite
	jr savegame_menu_loop

savegame_menu_loop_done:
	ld a, (savegame_menu_called_from)
	or a
	jr nz, savegame_menu_loop_done_from_title
	ld hl, state_inventory_from_savegame
	ld a, TEXT_PAGE
	jp jp_to_hl_in_page_a_8000
savegame_menu_loop_done_from_title:
    ld hl, state_braingames
    ld a, BRAINGAMES_PAGE
    jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
savegame_area_names:
	dw TEXT_AREA0_NAME
	dw TEXT_AREA1_NAME
	dw TEXT_AREA2_NAME
	dw TEXT_AREA3_NAME
	dw TEXT_AREA4_NAME
	dw TEXT_AREA5_NAME
	dw TEXT_AREA6_NAME
	dw TEXT_AREA7_NAME
	dw TEXT_AREA8_NAME
	dw TEXT_AREA9_NAME
	dw TEXT_AREA10_NAME
	dw TEXT_AREA11_NAME


savegame_menu_draw:
	ld hl, savegame_tiles_zx0
	ld c, SAVEGAME_MENU_PAGE
	call decompress_tiles_to_all_banks

savegame_menu_draw_tiles_set:
	ld hl, savegame_nametable_zx0
	ld de, buffer_4096
	call dzx0

	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	call fast_LDIRVM

	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_OPTIONS1, CHRTBL2 + (2*256 + 32) * 8, 16*COLOR_WHITE, 4	

	call copy_savegames_to_RAM 

	; is it safe to save games?
	call savegame_menu_allow_save_p
	jr z, savegame_menu_draw_save_allowed
	; grey out "save" button:
	ld hl, savegame_menu_draw_unsafe_save_table
	ld de, NAMTBL2 + 7 + 6*32
	ld bc, 3
	call fast_LDIRVM
	ld hl, savegame_menu_draw_unsafe_save_table
	ld de, NAMTBL2 + 7 + 9*32
	ld bc, 3
	call fast_LDIRVM
	ld hl, savegame_menu_draw_unsafe_save_table
	ld de, NAMTBL2 + 7 + 12*32
	ld bc, 3
	call fast_LDIRVM
savegame_menu_draw_save_allowed:

	; determine which savegames are full:
	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE
	ld ix, CHRTBL2 + (256 + 128)*8
	ld iy, NAMTBL2 + 3 + 11*32
	call savegame_menu_draw_entry

	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE + SAVE_GAME_SIZE
	ld ix, CHRTBL2 + (256 + 80)*8
	ld iy, NAMTBL2 + 3 + 8*32
	call savegame_menu_draw_entry

	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE + SAVE_GAME_SIZE * 2
	ld ix, CHRTBL2 + 32*8
	ld iy, NAMTBL2 + 3 + 5*32
savegame_menu_draw_entry:
	; - hl: ptr to savegame
	; - ix: ptr to CHRTBL2
	; - iy: ptr to NAMTBL2
	ld a, (hl)
	or a
	jr z, savegame_menu_draw_entry_full
savegame_menu_draw_entry_empty:
	ex de, hl
		push iy
		pop hl
		ld bc, 32
		add hl, bc
	ex de, hl
	ld hl, savegame_menu_draw_entry_empty_table
	ld bc, 3
	jp fast_LDIRVM

savegame_menu_draw_entry_full:
	; Draw a preview of the savegame:
	; area name:
	push ix
	push iy
	push hl
		ld bc, SAVEGAME_CURRENT_AREA_ID_OFFSET
		add hl, bc
		ld a, (hl)
		ld hl, savegame_area_names
		add a, a
		ADD_HL_A
		ld a, (hl)
		inc hl
		ld h, (hl)
		ld l, a

		push ix
		pop de
		ld iy, #8000 + 16*COLOR_WHITE
		ld b, 16
		call draw_sentence_to_vdp_from_another_page
	pop hl
	pop iy
	pop ix

	; time played:
	push ix
	push iy
	push hl
		push ix
			ld de, TEXT_GAMEOVER_STATS_9
			ld hl, copy_text_from_another_page
			ld c, TEXT_PAGE3
			call call_hl_in_page_c_8000
		pop hl
		ld bc, 16*8
		add hl, bc
		ex de, hl
		ld hl, buffer_4096
		ld iy, #8000 + 16*COLOR_DARK_YELLOW
		ld b, 4
		call draw_sentence_to_vdp_from_another_page
	pop hl
	pop iy
	pop ix

	push ix
	push iy
	push hl
		call savegame_menu_time_string
	pop hl
	pop iy
	pop ix

	push ix
	push iy
	push hl
		push ix
		pop hl
		ld bc, 19*8
		add hl, bc
		ex de, hl
		ld hl, buffer_4096
		ld iy, #8000 + 16*COLOR_WHITE
		ld b, 8
		call draw_sentence_to_vdp_from_another_page
	pop hl
	pop iy
	pop ix

	; health:
	push hl
	push ix
	push iy
		ex de, hl
			push iy
			pop hl
			ld bc, 32 * 2 + 10
			add hl, bc
		ex de, hl
		call draw_savegame_menu_player_health
	pop iy
	pop ix
	pop hl

	; coins:
	jp draw_savegame_menu_coins


savegame_menu_draw_entry_empty_table:
	db 17, 18, 19

savegame_menu_draw_unsafe_save_table:
	db 14, 15, 16


;-----------------------------------------------
savegame_menu_update_pointer_sprite:
	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a  ; space
	jr nz, savegame_menu_update_pointer_sprite_click
	bit KEY_UP_BIT, a
	jp nz, savegame_menu_update_pointer_sprite_up
	bit KEY_DOWN_BIT, a
	jp nz, savegame_menu_update_pointer_sprite_down
	bit KEY_LEFT_BIT, a
	jp nz, savegame_menu_update_pointer_sprite_left
	bit KEY_RIGHT_BIT, a
	jp nz, savegame_menu_update_pointer_sprite_right
	ret


savegame_menu_update_pointer_sprite_click:
	ld a, (tmp_dialog_pointer_position)
	or a
	jp z, savegame_menu_loop_done
	dec a
	jp z, savegame_menu_loop_load_1
	dec a
	jp z, savegame_menu_loop_load_2
	dec a
	jp z, savegame_menu_loop_load_3
	dec a
	jp z, savegame_menu_loop_save_1
	dec a
	jp z, savegame_menu_loop_save_2
	dec a
	jp z, savegame_menu_loop_save_3
	ret


savegame_menu_update_pointer_sprite_up:
	ld a, (tmp_dialog_pointer_position)
	cp 3
	ret z
	cp 6
	ret z
	inc a
savegame_menu_update_pointer_sprite_up_continue:
	ld (tmp_dialog_pointer_position), a
	ld hl, SFX_ui_move
	jp play_SFX_with_high_priority


savegame_menu_update_pointer_sprite_down:
	ld a, (tmp_dialog_pointer_position)
	or a
	ret z
	cp 4
	jr z, savegame_menu_update_pointer_sprite_down_to_back
	dec a
	jr savegame_menu_update_pointer_sprite_up_continue
savegame_menu_update_pointer_sprite_down_to_back:
	xor a
	jr savegame_menu_update_pointer_sprite_up_continue


savegame_menu_update_pointer_sprite_left:
	ld a, (tmp_dialog_pointer_position)
	or 4
	ret c
	sub 3
	jr savegame_menu_update_pointer_sprite_up_continue


savegame_menu_update_pointer_sprite_right:
	ld a, (tmp_dialog_pointer_position)
	or a
	ret z
	cp 4
	ret nc
	add a, 3
	jr savegame_menu_update_pointer_sprite_up_continue


;-----------------------------------------------
savegame_menu_draw_pointer_sprite_table:
	db 3*8 - 4, 17*8
	db 2*8, 12*8
	db 2*8, 9*8
	db 2*8, 6*8
	db 6*8, 12*8
	db 6*8, 9*8
	db 6*8, 6*8


savegame_menu_draw_pointer_sprite:
	; positions:
	; - 0: back
	; - 1, 2, 3: laod slots 1, 2, 3
	; - 4, 5, 6: save slots 1, 2, 3
	ld a, (tmp_dialog_pointer_position)
	add a, a
	ld hl, savegame_menu_draw_pointer_sprite_table
	ADD_HL_A
	ld c, (hl)
	inc hl
	ld b, (hl)

	ld hl, buffer_4096
	ld (hl), b
	inc hl
	ld (hl), c
	inc hl
	ld (hl), 0  ; sprite number
	inc hl
	ld (hl), COLOR_WHITE
	ld hl, buffer_4096
	ld de, SPRATR2
	ld b, 4
	jp fast_small_LDIRVM


;-----------------------------------------------
; save game structure:
; - #ff / #00 -> empty / used: 1 byte
; - current_world__name: 16 bytes
; - current_world__seed: 4 bytes
; - RAM_to_zero_on_game_start -> RAM_to_zero_on_game_start_end: 982 bytes
savegame_menu_loop_load_1:
	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE
savegame_menu_loop_load_1_continue:
	ld a, (hl)
	cp #ff
	ret z  ; no save game here
	push hl
		call savegame_menu_confirm_dialogue
	pop hl
	ret nz

	push hl
		call stop_music
		call clear_all_the_sprites
		call copy_savegames_to_RAM
	pop hl

	; get world seed and name and generate world:
	push hl
		inc hl
		ld de, current_world__name
		ld bc, 16
		ldir
		ld de, current_world__seed
		ld bc, 4
		ldir

		ld hl, gamestart_compute_difficulty
		ld c, GAMESTART_PAGE
		call call_hl_in_page_c_8000

		; do we need to spawn the forge?
		ld hl, gamestart_compute_random_seed_spawn_forge_p		
		ld c, GAMESTART_PAGE
		call call_hl_in_page_c_8000

		ld hl, pcg_generate_world
		ld c, PCG_PAGE_WORLD
		call call_hl_in_page_c_8000
		; 	jr z, savegame_menu_loop_load_1_continue_succeeded  ; no need to check this, as it cannot fail

		; get the savegame info again:
		call copy_savegames_to_RAM
	pop hl
	ld bc, 21
	add hl, bc
	ld de, current_area__id
	ldi
	ld de, current_room__id
	ldi
	ld de, RAM_to_zero_on_game_start
	ld bc, RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start
	ldir

	; get area id/room id and generate it:
	ld a, (current_area__id)
	ld e, a
	ld hl, pcg_generate_area
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000

	ld a, (current_room__id)
	ld e, a
	ld hl, pcg_generate_room
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000

	; remove all sprite enemies:
	ld hl, current_room__sprite_enemies
	ld bc, MAX_ROOM_SPRITE_ENEMIES * ROOM_OBJECT_STRUCT_SIZE - 1
	ld a, #ff
	call clear_memory_a

	; remove all tile enemies:
	call savegame_menu_remove_tile_enemies

	; back to game:
	call clear_screen_left_to_right
	call disable_VDP_output
	jp state_play_from_loaded_room


savegame_menu_loop_load_2:
	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE + SAVE_GAME_SIZE
	jp savegame_menu_loop_load_1_continue


savegame_menu_loop_load_3:
	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE + SAVE_GAME_SIZE * 2
	jp savegame_menu_loop_load_1_continue


;-----------------------------------------------
savegame_menu_loop_save_1:
	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE
savegame_menu_loop_save_1_continue:
	push hl
		call savegame_menu_allow_save_p
		jr nz, savegame_menu_loop_save_1_continue_cannot
		call savegame_menu_confirm_dialogue
	pop hl
	ret nz
	push hl
		call copy_flash_routines_to_RAM
		call clear_all_the_sprites
	pop de		
	call flash_save_game_to_slot
	jp nc, savegame_menu_draw
	; fail!
	ld de, TEXT_NO_FLASHROM
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE4
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096, CHRTBL2 + (2*256 + 44) * 8, 16*COLOR_WHITE, 24
	call wait_for_click
	jp savegame_menu_draw


savegame_menu_loop_save_1_continue_cannot:
	pop hl
; 	ld a, (.....)
; 	or a
; 	jr nz, savegame_menu_loop_save_1_continue_cannot_flashrom
	ld a, (savegame_menu_called_from)
	or a
	jr z, savegame_menu_loop_save_1_continue_cannot_in_game
	ld de, TEXT_CANNOT_SAVE_TITLE
	jr savegame_menu_loop_save_1_continue_cannot_continue
; savegame_menu_loop_save_1_continue_cannot_flashrom:
; 	ld de, TEXT_NO_FLASHROM
; 	jr savegame_menu_loop_save_1_continue_cannot_continue
savegame_menu_loop_save_1_continue_cannot_in_game:
	ld de, TEXT_CANNOT_SAVE
savegame_menu_loop_save_1_continue_cannot_continue:
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE4
	call call_hl_in_page_c_8000

	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096, CHRTBL2 + (2*256 + 44) * 8, 16*COLOR_WHITE, 24
	call wait_for_click
	jp savegame_menu_draw


savegame_menu_loop_save_2:
	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE + SAVE_GAME_SIZE
	jr savegame_menu_loop_save_1_continue


savegame_menu_loop_save_3:
	ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE + SAVE_GAME_SIZE * 2
	jr savegame_menu_loop_save_1_continue


;-----------------------------------------------
; output:
; - z: yes
; - nz: no
savegame_menu_confirm_dialogue:
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_ARE_YOU_SURE, CHRTBL2 + (2*256 + 51) * 8, 16*COLOR_WHITE, 8
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_YES, CHRTBL2 + (2*256 + 68) * 8, 16*COLOR_WHITE, 4
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_NO, CHRTBL2 + (2*256 + 72) * 8, 16*COLOR_WHITE, 4

	ld a, 19 * 8 - 1
	ld (tmp_dialog_options_position), a
	ld hl, state_yesno_dialog_mainloop
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld hl, CHRTBL2 + (2*256 + 48) * 8
	ld bc, 28*8
	xor a
	call fast_FILVRM

	ld a, (tmp_dialog_pointer_position)
	or a
	ret


;-----------------------------------------------
; input:
; - hl: ptr to savegame
savegame_menu_time_string:
	ld bc, SAVEGAME_TIME_OFFSET + 3
	add hl, bc
	ld a, (hl)  ; hours
	cp #ff
	jp z, savegame_menu_time_string_max
	ld ix, buffer_4096 + 1
	ld c, 0  ; number of characters
	ld e, 100
	call savegame_menu_time_string_add_digit
	ld e, 10
	call savegame_menu_time_string_add_digit
	ld e, 1
	call savegame_menu_time_string_add_digit
	ld (ix), 122  ; h
	inc ix
	inc c

	dec hl
	ld a, (hl)  ; minutes
	ld e, 10
	call savegame_menu_time_string_add_digit
	ld e, 1
	call savegame_menu_time_string_add_digit
	ld (ix), 130  ; m
	inc ix
	inc c

	dec hl
	ld a, (hl)  ; seconds
	ld e, 10
	call savegame_menu_time_string_add_digit
	ld e, 1
	call savegame_menu_time_string_add_digit
	ld (ix), 143  ; s
	inc c

	ld a, c
	ld (buffer_4096), a  ; length
	ret

savegame_menu_time_string_max:
	; max
	ld de, TEXT_MAX_TIME
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	jp call_hl_in_page_c_8000


text_numbers_savegame_menu:  ; we copy it here since 'text_numbers' is in another page
    db 22, 24, 26, 28, 30, 32, 35, 37, 39, 41

savegame_menu_time_string_add_digit:
	ld b, 0  ; new digit
savegame_menu_time_string_add_digit_loop:
	cp e
	jr c, savegame_menu_time_string_add_digit_loop_done
	sub e
	inc b
	jr savegame_menu_time_string_add_digit_loop
savegame_menu_time_string_add_digit_loop_done:
	push af
	push hl
		ld a, b
		ld hl, text_numbers_savegame_menu
		ADD_HL_A
		ld a, (hl)
		ld (ix), a
		inc ix
		inc c  ; number of digits
	pop hl
	pop af
	ret


;-----------------------------------------------
; input:
; - hl: ptr to savegame
; - de: ptr to NAMTBL2
draw_savegame_menu_player_health:
	push hl
		ld bc, SAVEGAME_PLAYER_MAX_HEALTH_OFFSET
		add hl, bc
		ld a, (hl)  ; player_max_health
	pop hl
	ld bc, SAVEGAME_PLAYER_HEALTH_OFFSET
	add hl, bc
	rrca
	rrca
	and #3f
	ld b, a  ; number of hearts to display
	ld a, (hl)  ; player_health
	ld c, a  ; remaining health to display
	ex de, hl
draw_savegame_menu_player_health_loop:
	ld e, 4
	ld a, c
	cp 4
	jr nc, draw_savegame_menu_player_health_loop_continue
	ld e, a
draw_savegame_menu_player_health_loop_continue:
	ld a, c
	sub e
	ld c, a
	push bc
	push de
	push hl
		ld a, e
		add a, 20  ; first heart tile
		call WRTVRM
	pop hl		
	pop de
	pop bc
	inc hl
	djnz draw_savegame_menu_player_health_loop
	ret


;-----------------------------------------------
; input:
; - hl: ptr to savegame
; - ix: ptr to CHRTBL2
; - iy: ptr to NAMTBL2
draw_savegame_menu_coins:
	push ix
		push hl
			ex de, hl
			push iy
			pop hl
			ld bc, 32 * 2 + 19
			add hl, bc
			ld a, 25  ; coin
			call WRTVRM
		pop hl
		ld bc, SAVEGAME_PLAYER_COINS_OFFSET
		add hl, bc
		ld a, (hl)  ; player_max_health
		ld ixl, a
	pop hl
	ld bc, (32 + 11) * 8
	add hl, bc
	ex de, hl
	ld b, 4
	ld c, TEXT_PAGE
	ld hl, draw_inventory_number_ixl
	ld iy, #8000 + COLOR_WHITE * 16
	jp call_hl_in_page_c_8000


;-----------------------------------------------
; Checks if there are enemies nearby, or if we are not in a room where savegames are allowed (e.g. boss rooms)
; output:
; - z: allow saving the game
; - nz: do not allow saving the game
savegame_menu_allow_save_p:
	ld a, (savegame_menu_called_from)
	or a
	ret nz
	ld a, (boss__in_boss_room)
	or a
	ret nz
	ld a, (boss__active)
	or a
	ret nz
	ld a, (current_room__sprite_enemies)
	cp #ff
	ret nz  ; there is an enemy!
	; tile enemies:
	ld ix, current_room__tile_objects
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
savegame_menu_allow_save_p_loop:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)  ; ID
	cp #ff
	ret z
	cp #fe
	ret z
	cp TAG_ENEMY_CARNIVORE_PLANT
	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_BEE_HIVE
	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_ANT_COLONY
	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_ANT_COLONY2
	jr z, savegame_menu_allow_save_p_fail
	; these cannot be hit:
; 	cp TAG_ENEMY_IMP_GENERATOR
; 	jr z, savegame_menu_allow_save_p_fail
; 	cp TAG_ENEMY_IMP_GENERATOR2
; 	jr z, savegame_menu_allow_save_p_fail
; 	cp TAG_ENEMY_FIREBALL_GENERATOR
; 	jr z, savegame_menu_allow_save_p_fail
;   cp TAG_ENEMY_LAVA_GENERATOR
; 	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_STONE_OWL
	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_SENTINEL
	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_UFO
	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_MARS_WALKER_RIGHT
	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_MARS_WALKER_LEFT
	jr z, savegame_menu_allow_save_p_fail
	cp TAG_ENEMY_MOON_LARGE_MUSHROOM
	jr z, savegame_menu_allow_save_p_fail

	add ix, bc
	jr savegame_menu_allow_save_p_loop
savegame_menu_allow_save_p_fail:
	or 1
	ret


;-----------------------------------------------
savegame_menu_remove_tile_enemies:
	ld ix, current_room__tile_objects
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
savegame_menu_remove_tile_enemies_loop:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	cp #ff
	ret z
	cp #fe
	ret z
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_ENEMY_CARNIVORE_PLANT
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_BEE_HIVE
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_ANT_COLONY
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_ANT_COLONY2
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	; these cannot be hit:
; 	cp TAG_ENEMY_IMP_GENERATOR
; 	jr z, savegame_menu_remove_tile_enemies_loop_delete
; 	cp TAG_ENEMY_IMP_GENERATOR2
; 	jr z, savegame_menu_remove_tile_enemies_loop_delete
; 	cp TAG_ENEMY_FIREBALL_GENERATOR
; 	jr z, savegame_menu_remove_tile_enemies_loop_delete
;   cp TAG_ENEMY_LAVA_GENERATOR
; 	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_STONE_OWL
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_SENTINEL
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_UFO
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_MARS_WALKER_RIGHT
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_MARS_WALKER_LEFT
	jr z, savegame_menu_remove_tile_enemies_loop_delete
	cp TAG_ENEMY_MOON_LARGE_MUSHROOM
	jr z, savegame_menu_remove_tile_enemies_loop_delete	
	add ix, bc
	jr savegame_menu_remove_tile_enemies_loop
	ret
savegame_menu_remove_tile_enemies_loop_delete:
	push ix
	push bc
		ld hl, delete_tile_object_in_ix
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop bc
	pop ix
	jr savegame_menu_remove_tile_enemies_loop
