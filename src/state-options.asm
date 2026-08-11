;-----------------------------------------------
state_options_reset:
	ld hl, config_options_rom
	ld de, config_hud_type
	ld bc, 5 + 8 * 2
	ldir
	ret


;-----------------------------------------------
state_options:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	call clear_screen_left_to_right
	call set_bitmap_mode

	ld hl, dialog_sprites_bin
	ld de, SPRTBL2
	ld bc, dialog_sprites_bin_end - dialog_sprites_bin
	call fast_LDIRVM_from_sprites_page

	call state_options_draw_text

	xor a
	ld (tmp_dialog_pointer_position), a
state_options_loop:
	halt
	call update_options_pointer_sprite
	call update_keyboard_buffers

	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a  ; space
	jr nz, state_options_loop_space
	bit KEY_DOWN_BIT, a  ; down
	jr nz, state_options_loop_down
	bit KEY_UP_BIT, a  ; up
	jr nz, state_options_loop_up
	jr state_options_loop
state_options_loop_end:
	call clear_screen_left_to_right
	call check_redefined_keys
	ld a, (options_called_from)
	or a
	jp z, state_inventory_from_options
	; called from title:
	ld hl, state_title
	ld a, TITLE_PAGE
	jp jp_to_hl_in_page_a_8000


state_options_loop_up:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	dec a
	ld (hl), a
	cp #ff
	jr nz, state_options_loop
	ld (hl), 13
	jr state_options_loop

state_options_loop_down:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	ld hl, tmp_dialog_pointer_position
	ld a, (hl)
	inc a
	ld (hl), a
	cp 14
	jr nz, state_options_loop
	ld (hl), 0
	jr state_options_loop

state_options_loop_space:
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority
	ld a, (tmp_dialog_pointer_position)
	or a
	jr z, state_options_loop_end
	dec a
	jr z, state_options_loop_space_hud
	dec a
	jr z, state_options_loop_space_inventory
	dec a
	jr z, state_options_loop_space_interact
	dec a
	jr z, state_options_loop_space_interact_up
	dec a
	jr z, state_options_loop_space_music

	; redefine key
	dec a
	call redefine_key
	call state_options_draw_text
	jr state_options_loop


state_options_loop_space_hud:
	ld a, (config_hud_type)
	inc a
	cp 3
	jr nz, state_options_loop_space_hud_continue
	xor a
state_options_loop_space_hud_continue
	ld (config_hud_type), a
	call state_options_draw_text
	jp state_options_loop


state_options_loop_space_inventory:
	ld a, (config_inventory_key_combo)
	xor #01
	ld (config_inventory_key_combo), a
	call state_options_draw_text
	jp state_options_loop


state_options_loop_space_interact:
	ld a, (config_interact_with_down)
	xor #01
	ld (config_interact_with_down), a
	call state_options_draw_text
	jp state_options_loop

state_options_loop_space_interact_up:
	ld a, (config_interact_with_up)
	xor #01
	ld (config_interact_with_up), a
	call state_options_draw_text
	jp state_options_loop

state_options_loop_space_music:
	ld a, (config_music_on)
	xor #01
	ld (config_music_on), a
	jr z, state_options_loop_space_music_on
state_options_loop_space_music_off:
	call stop_music
	jr state_options_loop_space_music_continue
state_options_loop_space_music_on:
	call play_current_room_music_if_needed
state_options_loop_space_music_continue:
	call state_options_draw_text
	jp state_options_loop


;-----------------------------------------------
; input:
; - a: input key index to redefine
redefine_key:
	; replace the key name by "TEXT_CHOOSE_KEY"
	; 1) get ptr to draw to: (state_options_text_table + (input_key_index + 1)*4)
	push af
		inc a
		add a, a
		add a, a
		ld e, a
		ld d, 0
		ld hl, state_options_text_table
		add hl, de
		ld e, (hl)
		inc hl
		ld d, (hl)
		ld hl, 10 * 8
		add hl, de
		ex de, hl

		ld hl, TEXT_CHOOSE_KEY
		ld iy, COLOR_RED * 16 + #08*256
		ld b, 10
		call draw_sentence_to_vdp_clearing_text_buffer

		; wait for no keys pressed:
redefine_key_wait_key_preloop:
		call read_complete_keyboard_matrix
		jr c, redefine_key_wait_key_preloop

		; wait for a key to be pressed:
redefine_key_wait_key_loop:
		halt
		call read_complete_keyboard_matrix
		jp nc, redefine_key_wait_key_loop

		; Here: 
		ld b, a
		; - b = keymatrixrow of the pressed key
		; - c = bit mask
	pop af

	; Write b and c to the appropriate place in the config_keyboard array:
	add a, a
	ld hl, config_keyboard
	ADD_HL_A
	ld (hl), b
	inc hl
	ld (hl), c
	ret


;-----------------------------------------------
; output:
; - carry: key is pressed
; - no carry: no key is pressed
; - a: keymatrix row where the key was pressed
; - c: bitmask of the pressed key
read_complete_keyboard_matrix:
	xor a
read_complete_keyboard_matrix_loop:
	push af
    	call SNSMAT
    	xor #ff  ; flip all bits
    	jr nz, read_complete_keyboard_matrix_some_key_pressed
    pop af
    inc a
    cp 11
    jr nz, read_complete_keyboard_matrix_loop
    or a  ; clear carry flag
    ret

read_complete_keyboard_matrix_some_key_pressed:
		; make sure we just have one key pressed:
		ld c, a
		ld a, 1
read_complete_keyboard_matrix_some_key_pressed_loop:
		srl c
		jr z, read_complete_keyboard_matrix_some_key_pressed_loop_done
		add a, a
		jr read_complete_keyboard_matrix_some_key_pressed_loop
read_complete_keyboard_matrix_some_key_pressed_loop_done:
		ld c, a
	pop af
	scf
	ret


;-----------------------------------------------
update_options_pointer_sprite:
	ld hl, buffer_4096
	ld a, (tmp_dialog_pointer_position)

	cp 6
	jr c, update_options_pointer_sprite_continue
	inc a
update_options_pointer_sprite_continue:
	or a
	jr z, update_options_pointer_sprite_continue2
	inc a
update_options_pointer_sprite_continue2:
	add a, a
	add a, a
	add a, a
	add a, 3 * 8
	ld (hl), a  ; y
	inc hl
	ld (hl), 52
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), COLOR_WHITE
	ld hl, buffer_4096
	ld de, SPRATR2
	ld b, 4
	jp fast_small_LDIRVM


;-----------------------------------------------
state_options_draw_text:
	ld hl, state_options_text_table
	ld b, 9
state_options_draw_text_loop:
	push bc
		ld e, (hl)
		inc hl
		ld d, (hl)
		inc hl
		ld c, (hl)
		inc hl
		ld b, (hl)
		inc hl
		push hl
			ld h, b
			ld l, c
			ld iy, #80f0
			ld b, 20
			call draw_sentence_to_vdp_clearing_text_buffer
		pop hl
	pop bc
	djnz state_options_draw_text_loop

	; hud option:
	ld de, CHRTBL2 + (5*32 + 8) * 8
	ld a, (config_hud_type)
	or a
	jr z, state_options_draw_text_hud0
	dec a
	jr z, state_options_draw_text_hud1
state_options_draw_text_hud2:
	ld hl, TEXT_OPTIONS2C
	jr state_options_draw_text_hud_set
state_options_draw_text_hud1:
	ld hl, TEXT_OPTIONS2B
	jr state_options_draw_text_hud_set
state_options_draw_text_hud0:
	ld hl, TEXT_OPTIONS2A
state_options_draw_text_hud_set:
	ld iy, #80f0
	ld b, 20
	call draw_sentence_to_vdp_clearing_text_buffer

	; inventory option:
	ld de, CHRTBL2 + (6*32 + 8) * 8
	ld a, (config_inventory_key_combo)
	or a
	jr z, state_options_draw_text_inventory0
state_options_draw_text_inventory1:
	ld hl, TEXT_OPTIONS3B
	jr state_options_draw_text_inventory_set
state_options_draw_text_inventory0:
	ld hl, TEXT_OPTIONS3A
state_options_draw_text_inventory_set:
	ld iy, #80f0
	ld b, 20
	call draw_sentence_to_vdp_clearing_text_buffer

	; interact down option:
	ld de, CHRTBL2 + (7*32 + 8) * 8
	ld a, (config_interact_with_down)
	or a
	jr z, state_options_draw_text_interact0
state_options_draw_text_interact1:
	ld hl, TEXT_OPTIONS4B
	jr state_options_draw_text_interact_set
state_options_draw_text_interact0:
	ld hl, TEXT_OPTIONS4A
state_options_draw_text_interact_set:
	ld iy, #80f0
	ld b, 20
	call draw_sentence_to_vdp_clearing_text_buffer

	; interact up option:
	ld de, CHRTBL2 + (8*32 + 8) * 8
	ld a, (config_interact_with_up)
	or a
	jr z, state_options_draw_text_interact_up0
state_options_draw_text_interact_up1:
	ld hl, TEXT_OPTIONS5B
	jr state_options_draw_text_interact_up_set
state_options_draw_text_interact_up0:
	ld hl, TEXT_OPTIONS5A
state_options_draw_text_interact_up_set:
	ld iy, #80f0
	ld b, 20
	call draw_sentence_to_vdp_clearing_text_buffer

	; music option:
	ld de, CHRTBL2 + (9*32 + 8) * 8
	ld a, (config_music_on)
	or a
	jr z, state_options_draw_text_music_on0
state_options_draw_text_music_on1:
	ld hl, TEXT_OPTIONS6B
	jr state_options_draw_text_music_on_set
state_options_draw_text_music_on0:
	ld hl, TEXT_OPTIONS6A
state_options_draw_text_music_on_set:
	ld iy, #80f0
	ld b, 20
	call draw_sentence_to_vdp_clearing_text_buffer

	; print keys:
	ld b, 8
	ld hl, config_keyboard
	ld de, CHRTBL2 + (11*32 + 18) * 8
state_options_draw_text_loop2:
	push bc
		ld c, (hl)
		inc hl
		ld b, (hl)
		inc hl
		push hl
			; config_keyboard_key_matrix_names + c * 8 * 2 + (bit in b) * 2
			xor a
state_options_draw_text_loop3:
			rr b
			jr c, state_options_draw_text_loop3_end
			inc a
			jr state_options_draw_text_loop3
state_options_draw_text_loop3_end:
			add a, a
			ld h, 0
			ld l, c
			add hl, hl
			add hl, hl
			add hl, hl
			add hl, hl
			ADD_HL_A
			ld bc, config_keyboard_key_matrix_names
			add hl, bc
			ld c, (hl)
			inc hl
			ld h, (hl)
			ld l, c

			ld iy, #80a0
			ld b, 8
			push de
				call draw_sentence_to_vdp_clearing_text_buffer			
			pop hl
			ld bc, 32*8
			add hl, bc
			ex de, hl
		pop hl
	pop bc
	djnz state_options_draw_text_loop2

	ret


;-----------------------------------------------
check_redefined_keys:
	ld hl, config_keyboard + 4*2
	ld de, check_redefined_keys_special_case_table
	ld b, 8
check_redefined_keys_loop:
	ld a, (de)
	cp (hl)
	jr nz, check_redefined_keys_default
	inc hl
	inc de
	djnz check_redefined_keys_loop
	ld a, 1
	ld (config_keyboard_special_case), a
	ret
check_redefined_keys_default:
	xor a
	ld (config_keyboard_special_case), a
	ret

check_redefined_keys_special_case_table:
	db 5, #02
	db 2, #40
	db 4, #02
	db 4, #01


;-----------------------------------------------
state_options_text_table:
	dw CHRTBL2 + (3*32 + 8) * 8, TEXT_OPTIONS1
	dw CHRTBL2 + (11*32 + 8) * 8, TEXT_KEYBOARD1
	dw CHRTBL2 + (12*32 + 8) * 8, TEXT_KEYBOARD2
	dw CHRTBL2 + (13*32 + 8) * 8, TEXT_KEYBOARD3
	dw CHRTBL2 + (14*32 + 8) * 8, TEXT_KEYBOARD4
	dw CHRTBL2 + (15*32 + 8) * 8, TEXT_KEYBOARD5
	dw CHRTBL2 + (16*32 + 8) * 8, TEXT_KEYBOARD6
	dw CHRTBL2 + (17*32 + 8) * 8, TEXT_KEYBOARD7
	dw CHRTBL2 + (18*32 + 8) * 8, TEXT_KEYBOARD8


;-----------------------------------------------
config_options_rom:
	db 2, 0, 1, 0, 0
config_keyboard_rom:
	db 8, #80  ; right: right
	db 8, #40  ; down: down
	db 8, #20  ; up: up
	db 8, #10  ; left: left
	db 5, #20  ; interact: x
	db 5, #80  ; inventory: z
	db 3, #01  ; jump: c
	db 8, #01  ; weapon: space

config_keyboard_key_matrix_names:
  dw TEXT_KEY_0_0, TEXT_KEY_0_1, TEXT_KEY_0_2, TEXT_KEY_0_3, TEXT_KEY_0_4, TEXT_KEY_0_5, TEXT_KEY_0_6, TEXT_KEY_0_7
  dw TEXT_KEY_1_0, TEXT_KEY_1_1, TEXT_KEY_1_2, TEXT_KEY_1_3, TEXT_KEY_1_4, TEXT_KEY_1_5, TEXT_KEY_1_6, TEXT_KEY_1_7
  dw TEXT_KEY_2_0, TEXT_KEY_2_1, TEXT_KEY_2_2, TEXT_KEY_2_3, TEXT_KEY_2_4, TEXT_KEY_2_5, TEXT_KEY_2_6, TEXT_KEY_2_7
  dw TEXT_KEY_3_0, TEXT_KEY_3_1, TEXT_KEY_3_2, TEXT_KEY_3_3, TEXT_KEY_3_4, TEXT_KEY_3_5, TEXT_KEY_3_6, TEXT_KEY_3_7
  dw TEXT_KEY_4_0, TEXT_KEY_4_1, TEXT_KEY_4_2, TEXT_KEY_4_3, TEXT_KEY_4_4, TEXT_KEY_4_5, TEXT_KEY_4_6, TEXT_KEY_4_7
  dw TEXT_KEY_5_0, TEXT_KEY_5_1, TEXT_KEY_5_2, TEXT_KEY_5_3, TEXT_KEY_5_4, TEXT_KEY_5_5, TEXT_KEY_5_6, TEXT_KEY_5_7
  dw TEXT_KEY_6_0, TEXT_KEY_6_1, TEXT_KEY_6_2, TEXT_KEY_6_3, TEXT_KEY_6_4, TEXT_KEY_6_5, TEXT_KEY_6_6, TEXT_KEY_6_7
  dw TEXT_KEY_7_0, TEXT_KEY_7_1, TEXT_KEY_7_2, TEXT_KEY_7_3, TEXT_KEY_7_4, TEXT_KEY_7_5, TEXT_KEY_7_6, TEXT_KEY_7_7
  dw TEXT_KEY_8_0, TEXT_KEY_8_1, TEXT_KEY_8_2, TEXT_KEY_8_3, TEXT_KEY_8_4, TEXT_KEY_8_5, TEXT_KEY_8_6, TEXT_KEY_8_7
  dw TEXT_KEY_9_0, TEXT_KEY_9_1, TEXT_KEY_9_2, TEXT_KEY_9_3, TEXT_KEY_9_4, TEXT_KEY_9_5, TEXT_KEY_9_6, TEXT_KEY_9_7
  dw TEXT_KEY_10_0, TEXT_KEY_10_1, TEXT_KEY_10_2, TEXT_KEY_10_3, TEXT_KEY_10_4, TEXT_KEY_10_5, TEXT_KEY_10_6, TEXT_KEY_10_7

