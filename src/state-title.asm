;-----------------------------------------------
state_title:
    ld sp, stack
	call clear_screen_left_to_right

	call disable_VDP_output
		call state_title_draw_title
		call state_title_draw_credits
	call enable_VDP_output

state_title_loop:
	halt
    call update_keyboard_buffers
    ld a, (keyboard_clicks)
    bit KEY_WEAPON_BIT, a
    jr nz, state_title_loop_end

	jr state_title_loop

state_title_loop_end:
	jp state_gamestart


;-----------------------------------------------
state_title_draw_title_sprite_table:
	; y, x, sprite, attribute + clock
	db 7*8 - 1, 5*8,  0, COLOR_DARK_BLUE
	db 7*8 - 1, 8*8, 4, COLOR_DARK_BLUE
	db 7*8 - 1, 14*8, 8, COLOR_DARK_BLUE
	db 7*8 - 1, 18*8, 12, COLOR_DARK_BLUE
	db 9*8 - 1, 5*8,  16, COLOR_DARK_BLUE
	db 9*8 - 1, 8*8, 20, COLOR_DARK_BLUE
	db 9*8 - 1, 18*8, 24, COLOR_DARK_BLUE
	db 9*8 - 1, 22*8, 28, COLOR_DARK_BLUE

state_title_draw_title:
	ld hl, title_tiles_zx0
	ld c, TITLE_PAGE
	call decompress_tiles_to_all_banks

	; name table:
	ld b, 11
	ld hl, title_nametable
	ld de, NAMTBL2 + 4 + 3*32
state_title_draw_title_loop:
	push bc
		push hl
			push de
				ld b, 24
				call fast_small_LDIRVM 
			pop hl
			ld bc, 32
			add hl, bc
			ex de, hl
		pop hl
		ld bc, 24
		add hl, bc
	pop bc
	djnz state_title_draw_title_loop

	; sprites:
	ld hl, title_sprites_zx0
	ld de, buffer_4096
	ld c, TITLE_PAGE
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, SPRTBL2
	ld bc, 8*32
	call fast_LDIRVM

	ld hl, state_title_draw_title_sprite_table
	ld de, SPRATR2
	ld b, 8*4
	jp fast_small_LDIRVM


;-----------------------------------------------
state_title_text_nametable:
	db 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234
	db 240, 241, 242, 243, 244, 245, 246, 247, 248, 249
state_title_draw_credits:
	ld hl, TEXT_CREDITS1
	ld de, CHRTBL2 + (256*2 + 224)*8
	ld iy, #80f0
	ld b, 11
	call draw_sentence_to_vdp_from_another_page

	ld hl, TEXT_CREDITS2
	ld de, CHRTBL2 + (256*2 + 240)*8
	ld iy, #80f0
	ld b, 10
	call draw_sentence_to_vdp_from_another_page

	ld hl, state_title_text_nametable
	ld de, NAMTBL2 + 23*32 + 21
	ld b, 11
	call fast_small_LDIRVM
	ld hl, state_title_text_nametable + 11
	ld de, NAMTBL2 + 23*32
	ld b, 10
	jp fast_small_LDIRVM
