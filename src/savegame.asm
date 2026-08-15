;-----------------------------------------------
savegame_menu:
	call clear_screen_left_to_right
	call disable_VDP_output
		ld hl, dialog_sprites_bin
		ld de, SPRTBL2
		ld bc, dialog_sprites_bin_end - dialog_sprites_bin
		call fast_LDIRVM_from_sprites_page

		ld hl, savegame_tiles_zx0
		ld c, SAVEGAME_MENU_PAGE
		call decompress_tiles_to_all_banks

		ld hl, savegame_nametable_zx0
		ld de, buffer_4096
		call dzx0

		ld hl, buffer_4096
		ld de, NAMTBL2
		ld bc, 768
		call fast_LDIRVM

		DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_OPTIONS1, CHRTBL2 + (2*256 + 32) * 8, 16*COLOR_WHITE, 4

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
	ld hl, state_inventory_from_savegame
	ld a, TEXT_PAGE
	jp jp_to_hl_in_page_a_8000


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
	; ...
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
	db 3*8 - 2, 17*8
	db 1*8, 13*8
	db 1*8, 10*8
	db 1*8, 7*8
	db 5*8, 13*8
	db 5*8, 10*8
	db 5*8, 7*8


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

