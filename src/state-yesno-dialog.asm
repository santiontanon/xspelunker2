;-----------------------------------------------
; input:
; - ix: question text
; - hl: jump here if "yes" selected
; - de: jump here if "no" selected
state_yesno_dialog_iy:
	push iy
	pop hl
state_yesno_dialog:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	push hl
	push de
		push ix
			call clear_screen_left_to_right
			call set_bitmap_mode
			ld hl, dialog_sprites_bin
			ld de, SPRTBL2
			ld bc, dialog_sprites_bin_end - dialog_sprites_bin
			call fast_LDIRVM_from_sprites_page
		pop hl
		ld a, 12 * 8 - 1
		ld (tmp_dialog_options_position), a
		call state_yesno_dialog_draw_text
		call state_yesno_dialog_mainloop
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
	ld a, (tmp_dialog_options_position)
	ld c, a
	ld a, (tmp_dialog_pointer_position)
	; y = 13*8 - 1 + a*8
	add a, a
	add a, a
	add a, a
	add a, c
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


;-----------------------------------------------
; input:
; - ix: question text
; - hl: jump here if "yes" selected
; - de: jump here if "no" selected
state_yesno_dialog_in_game:
	push hl
	push de
		push ix
			ld hl, dialog_sprites_bin
			ld de, SPRTBL2
			ld bc, dialog_sprites_bin_end - dialog_sprites_bin
			call fast_LDIRVM_from_sprites_page		
			ld c, TEXT_PAGE
			ld hl, display_in_game_message_draw_box
			call call_hl_in_page_c_8000
		pop hl

		ld de, CHRTBL2 + (12*32+8)*8
		ld iy, #80f0
		ld b, 16
		call draw_sentence_to_vdp_clearing_text_buffer

		ld hl, TEXT_YES
		ld de, CHRTBL2 + (14*32+14)*8
		ld iy, #80f0
		ld b, 4
		call draw_sentence_to_vdp_clearing_text_buffer

		ld hl, TEXT_NO
		ld de, CHRTBL2 + (15*32+14)*8
		ld iy, #80f0
		ld b, 4
		call draw_sentence_to_vdp_clearing_text_buffer

		ld a, 13 * 8 - 1
		ld (tmp_dialog_options_position), a
		call state_yesno_dialog_mainloop

		; clear arrow sprite:
		ld a, 200
		ld hl, SPRATR2
		ld b, 1
		call fast_small_FILVRM

		; restore tiles in middle bank:
		ld hl, CLRTBL2 + (256 + 16*6)*8
		ld bc, (256-16*6)*8
		xor a
		call fast_FILVRM

		; restore content below:
		ld hl, buffer_4096 + 1024
		ld de, NAMTBL2 + 256
		ld bc, 256
		call fast_LDIRVM

		ld hl, redraw_flags
		ld (hl), #ff

		call setup_game_tiles_only_biome
	pop de
	pop hl
	ld a, (tmp_dialog_pointer_position)
	or a
	jr z, state_yesno_dialog_in_game_done
	ex de, hl  ; no pressed
state_yesno_dialog_in_game_done:
	jp hl


;-----------------------------------------------
; input:
; - hl: text to render
state_yesno_dialog_draw_text:
	ld de, CHRTBL2 + (9*32+12)*8
	ld iy, #80f0
	ld b, 8
	call draw_sentence_to_vdp_clearing_text_buffer

	ld hl, TEXT_YES
	ld de, CHRTBL2 + (12*32+14)*8
	ld iy, #80f0
	ld b, 4
	call draw_sentence_to_vdp_clearing_text_buffer

	ld hl, TEXT_NO
	ld de, CHRTBL2 + (13*32+14)*8
	ld iy, #80f0
	ld b, 4
	jp draw_sentence_to_vdp_clearing_text_buffer


;-----------------------------------------------
state_yesno_dialog_mainloop_yes:
	xor a
	jr state_yesno_dialog_mainloop_continue
state_yesno_dialog_mainloop:
	ld a, 1  ; no
state_yesno_dialog_mainloop_continue:
	ld (tmp_dialog_pointer_position), a
state_yesno_dialog_loop:
	halt
	call update_dialog_pointer_sprite
	call update_keyboard_buffers

	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a  ; space
	jr nz, state_yesno_dialog_mainloop_done
	bit KEY_UP_BIT, a
	jr nz, state_yesno_dialog_change_option
	bit KEY_DOWN_BIT, a
	jr z, state_yesno_dialog_loop
state_yesno_dialog_change_option:
	ld a, (tmp_dialog_pointer_position)
	xor #01
	ld (tmp_dialog_pointer_position), a
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	jr state_yesno_dialog_loop
state_yesno_dialog_mainloop_done:
	xor a
	ld (keyboard_clicks), a
	ret


;-----------------------------------------------
; This method is here, since it's complicated to pass that many registers to a function call in another page
object_interaction_function_calendar_center_in_text_page:
	ld ix, TEXT_TOUCH_STONE_QUESTION
	ld hl, object_interaction_function_calendar_center_yes
	ld de, object_interaction_function_calendar_center_no
	jp state_yesno_dialog_in_game

object_interaction_function_calendar_center_yes:
	; trigger ending:
	ld hl, calendar_stone_center_trigger_ending_event_fn
	ld (in_game_event_fn_ptr), hl
	ld a, CALENDAR_EVENTS_PAGE
	ld (in_game_event_fn_page), a
	ret
object_interaction_function_calendar_center_no:
	ret

