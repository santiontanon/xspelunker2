;-----------------------------------------------
state_title:
    ld sp, stack
	call clear_screen_left_to_right

	call disable_VDP_output
		call state_title_draw_title
		call state_title_draw_credits
	call enable_VDP_output

	ld bc, 0  ; timer for the blinking text
state_title_loop:
	halt
	push bc
		call state_title_draw_space_to_start
	    call update_keyboard_buffers
	pop bc
	; Check using the redefined keys (weapon and interact)
    ld a, (keyboard_clicks)
    bit KEY_WEAPON_BIT, a
    jr nz, state_title_loop_end
    bit KEY_INTERACT_BIT, a
    jr nz, state_title_loop_options

    ; chedk SPACE and X directly, in case they were redefined away
    push bc
	    ld a, 8
	    call SNSMAT
	    bit 0, a
	pop bc
    jr z, state_title_loop_end
    push bc
	    ld a, 5
	    call SNSMAT
	    bit 5, a
	pop bc
    jr z, state_title_loop_options

    inc bc
    ld a, b
    cp 2
    jr z, state_title_loop_story

	jr state_title_loop

state_title_loop_end:
	ld hl, state_gamestart
	ld a, GAMESTART_PAGE
	jp jp_to_hl_in_page_a_8000

state_title_loop_story:
	ld hl, state_story
	ld a, STORY_PAGE
	jp jp_to_hl_in_page_a_8000

state_title_loop_options:
	ld a, 1
	ld (options_called_from), a
	ld hl, state_options
	ld a, TEXT_PAGE
	jp jp_to_hl_in_page_a_8000


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
state_title_text_nametable1:
	db 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234  ; brain games
state_title_text_nametable2:
	db 245, 246, 247, 248, 249, 250, 251, 252, 253, 254  ; santiago ontanon
state_title_text_nametable3:
	db 235, 236, 237, 238, 239, 240, 241, 242, 243, 244  ; space to start


;-----------------------------------------------
state_title_draw_credits:
	ld hl, TEXT_CREDITS1
	ld de, CHRTBL2 + (256*2 + 224)*8
	ld iy, #80f0
	ld b, 11
	call draw_sentence_to_vdp_from_another_page

	ld hl, TEXT_CREDITS2
	ld de, CHRTBL2 + (256*2 + 245)*8
	ld iy, #80f0
	ld b, 10
	call draw_sentence_to_vdp_from_another_page

	ld hl, state_title_text_nametable1
	ld de, NAMTBL2 + 23*32 + 21
	ld b, 11
	call fast_small_LDIRVM
	ld hl, state_title_text_nametable2
	ld de, NAMTBL2 + 23*32
	ld b, 10
	jp fast_small_LDIRVM


;-----------------------------------------------
; input:
; - c: timer
state_title_draw_space_to_start:
	ld a, c
	and #08
	jr z, state_title_draw_space_to_start_clear
	ld a, c
	and #40
	jr z, state_title_draw_space_to_start_options
	; draw text:
	ld hl, TEXT_START2
	jr state_title_draw_space_to_start_continue
state_title_draw_space_to_start_options:
	ld hl, TEXT_START1
state_title_draw_space_to_start_continue:
	ld de, CHRTBL2 + (256*2 + 235)*8
	ld iy, #80f0
	ld b, 10
	call draw_sentence_to_vdp_from_another_page

	ld hl, state_title_text_nametable3
	ld de, NAMTBL2 + 17*32 + 12
	ld b, 10
	jp fast_small_LDIRVM

state_title_draw_space_to_start_clear:
	; clear text:
	ld hl, CLRTBL2 + (256*2 + 235) * 8
	ld b, 10*8
	xor a
	jp fast_small_FILVRM
