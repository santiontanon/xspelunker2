;-----------------------------------------------
; input:
; - ix: question text
; - hl: jump here if "yes" selected
; - de: jump here if "no" selected
state_yesno_dialog:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	push hl
	push de
		push ix
			call clear_screen_left_to_right
			call set_bitmap_mode

			SETMEGAROMPAGE_8000 SPRITES_PAGE
			ld hl, dialog_sprites_bin
			ld de, SPRTBL2
			ld bc, dialog_sprites_bin_end - dialog_sprites_bin
			call fast_LDIRVM

			SETMEGAROMPAGE_8000 TEXT_PAGE
			call clear_text_rendering_buffer
		pop hl
		ld de, CHRTBL2 + (10*32+12)*8
		ld iy, #80f0
		ld b, 8
		call draw_sentence_to_vdp

		call clear_text_rendering_buffer
		ld hl, TEXT_YES
		ld de, CHRTBL2 + (13*32+14)*8
		ld iy, #80f0
		ld b, 4
		call draw_sentence_to_vdp

		call clear_text_rendering_buffer
		ld hl, TEXT_NO
		ld de, CHRTBL2 + (14*32+14)*8
		ld iy, #80f0
		ld b, 4
		call draw_sentence_to_vdp

		ld a, 1  ; no
		ld (tmp_dialog_pointer_position), a
state_yesno_dialog_loop:
		halt
		call update_dialog_pointer_sprite
		call update_keyboard_buffers

		ld a, (keyboard_line_clicks)  ; RIGHT, DOWN, UP, LEFT, DEL, INS, HOME, SPACE
		bit 0, a  ; space
		jr nz, state_yesno_dialog_loop_end
		and #60  ; up or down
		jr z, state_yesno_dialog_loop
		ld a, (tmp_dialog_pointer_position)
		xor #01
		ld (tmp_dialog_pointer_position), a
		ld hl, SFX_ui_move
		call play_SFX_with_high_priority
		jr state_yesno_dialog_loop
state_yesno_dialog_loop_end:

		call clear_screen_left_to_right
	pop de
	pop hl
	ld a, (tmp_dialog_pointer_position)
	or a
	jr z, state_yesno_dialog_done
	ex de, hl  ; no pressed
state_yesno_dialog_done:
	jp hl


update_dialog_pointer_sprite:
	ld hl, buffer_4096
	ld a, (tmp_dialog_pointer_position)
	; y = 13*8 - 1 + a*8
	add a, a
	add a, a
	add a, a
	add a, 13 * 8 - 1
	ld (hl), a  ; y
	inc hl
	ld (hl), 96
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), COLOR_WHITE
	ld hl, buffer_4096
	ld de, SPRATR2
	ld b, 4
	jp fast_small_LDIRVM

