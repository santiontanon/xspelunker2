;-----------------------------------------------
calendar_stone_room_enter_event_fn:
	ld a, (global_state__story)
	cp STORY_STATE__ENTERED_RUINS
	jr z, calendar_stone_room_enter_event_fn_first_time
	cp STORY_STATE__GOT_LETTER1
	jr z, calendar_stone_room_enter_event_fn_after_letter1
	ret

calendar_stone_room_enter_event_fn_first_time:
	; found calendar stone for the first time:
	ld de, TEXT_FIND_CALENDAR_STONE1
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld de, TEXT_FIND_CALENDAR_STONE2
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld a, STORY_STATE__FOUND_CALENDAR
	ld (global_state__story), a
	ret

calendar_stone_room_enter_event_fn_after_letter1:
	ld de, TEXT_CALENDAR_AFTER_LETTER1
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld a, STORY_STATE__CALENDAR_AFTER_LETTER1
	ld (global_state__story), a
	ret


;-----------------------------------------------
calendar_stone_center_trigger_battle_event_fn:
	ld de, TEXT_CALENDAR_CENTER_MSG1
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	; block the walls around:
	ld hl, calendar_room_zx0
	ld c, CHUNKS_PYRAMID_PAGE
	ld de, buffer_4096
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, current_room__tile_map
	call calendar_stone_center_trigger_battle_event_fn_copy_room_column

	ld hl, buffer_4096 + 28
	ld de, current_room__tile_map + 28
	call calendar_stone_center_trigger_battle_event_fn_copy_room_column

	ld hl, buffer_4096 + 32*22
	ld de, current_room__tile_map + +32*22
	ld bc, 32*2
	ldir

	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
	ld hl, SFX_explosion
	call play_SFX_with_high_priority
	ld b, 25
	call wait_b_halts


	; open the ceiling:
	ld hl, current_room__tile_map + 4
	call calendar_stone_center_trigger_battle_event_fn_open_ceiling_hole

	ld hl, current_room__tile_map + 14
	call calendar_stone_center_trigger_battle_event_fn_open_ceiling_hole

	ld hl, current_room__tile_map + 24
	call calendar_stone_center_trigger_battle_event_fn_open_ceiling_hole

	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
	ld hl, SFX_explosion
	call play_SFX_with_high_priority
	ld b, 25
	call wait_b_halts


	; set 'in_game_event_fn_ptr' and 'in_game_event_fn_page' for ending battle:
	; ...

	ld a, STORY_STATE__FIGHTING_ALIENS
	ld (global_state__story), a

	ld hl, calendar_stone_center_battle_event_fn
	ld (in_game_event_fn_ptr), hl
	ld a, CALENDAR_EVENTS_PAGE
	ld (in_game_event_fn_page), a
	xor a
	ld (keyboard_clicks), a
	ret


;-----------------------------------------------
calendar_stone_center_trigger_battle_event_fn_copy_room_column:
	ld b, 24
calendar_stone_center_trigger_battle_event_fn_copy_room_column_loop:
	push bc
		push hl
			push de
				ld bc, 4
				ldir
			pop hl
			ld bc, 32
			add hl, bc
			ex de, hl
		pop hl
		add hl, bc
	pop bc
	djnz calendar_stone_center_trigger_battle_event_fn_copy_room_column_loop
	ret


;-----------------------------------------------
calendar_stone_center_trigger_battle_event_fn_open_ceiling_hole:
	ld b, 4
calendar_stone_center_trigger_battle_event_fn_open_ceiling_hole_loop:
	push bc
		push hl
			ld bc, 3
			call clear_memory
		pop hl
		ld bc, 32
		add hl, bc
	pop bc
	djnz calendar_stone_center_trigger_battle_event_fn_open_ceiling_hole_loop
	ret


;-----------------------------------------------
calendar_stone_center_battle_event_fn:
	; spawn aliens:
	; ...

	; end battle message:
	ld de, TEXT_CALENDAR_CENTER_MSG2
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld a, STORY_STATE__DEFEATED_ALIENS
	ld (global_state__story), a
	ret


;-----------------------------------------------
calendar_stone_center_trigger_ending_event_fn:
	; player interacted with the calendar stone after the alien battle:
	ld de, TEXT_CALENDAR_CENTER_MSG3
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld hl, calendar_stone_center_trigger_ending_event_fn2
	ld (in_game_event_fn_ptr), hl
	ld a, CALENDAR_EVENTS_PAGE
	ld (in_game_event_fn_page), a
	xor a
	ld (keyboard_clicks), a
	ret	

calendar_stone_center_trigger_ending_event_fn2:
	; copy the room tiles somewhere else:
	ld hl, current_room__tile_map
	ld de, buffer_4096
	ld bc, 32*24
	ldir

	; remove the brick platforms:
	ld hl, buffer_4096 + 14 + 11*32
	ld de, buffer_4096 + 32*24
	call calendar_stone__remove_bricks

	ld hl, buffer_4096 + 14 + 14*32
	ld de, buffer_4096 + 32*24 + 4
	call calendar_stone__remove_bricks

	; remove the brick platforms:
	ld hl, buffer_4096 + 14 + 14*32
	ld d, h
	ld e, l
	inc de
	ld (hl), 59  ; blue
	ldi
	ldi
	ldi

	ld b, 13
calendar_stone_center_trigger_ending_event_fn_loop:
	ld a, 14
	sub b
	push bc
		call draw_lowered_calendar_stone
		xor a
		call draw_lowered_calendar_stone_dust
		; redraw the room:
		ld hl, draw_room_with_hud
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
		ld hl, SFX_explosion
		call play_SFX_with_high_priority
		ld b, 12
		call wait_b_halts
		ld a, 1
		call draw_lowered_calendar_stone_dust
		; redraw the room:
		ld hl, draw_room_with_hud
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
		ld b, 12
		call wait_b_halts
	pop bc
	djnz calendar_stone_center_trigger_ending_event_fn_loop

	; clear the dust:
	ld hl, current_room__tile_map + 16*32 + 8
	ld bc, 15
	call clear_memory
	; redraw the room:
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
	ld b, 25
	call wait_b_halts

	; remove the power stone and center tile objects 
	ld e, TAG_CALENDAR_STONE_CENTER
	ld hl, find_tile_object_ptr
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	push hl
	pop ix
	ld hl, delete_tile_object_in_ix
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000

	ld b, 6
calendar_stone_center_trigger_ending_event_fn_loop2:
	push bc
		ld e, TAG_CALENDAR_SOCKET
		ld hl, find_tile_object_ptr
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
		push hl
		pop ix
		ld hl, delete_tile_object_in_ix
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop bc
	djnz calendar_stone_center_trigger_ending_event_fn_loop2

	; Continue ending sequence:
	; ...

	ld a, (global_state__n_power_stones_in_calendar)
	cp 5
	ld hl, ending_C
	jr z, calendar_stone_center_trigger_ending_event_fn_ending
	ld hl, ending_B
	ld a, (global_state__solved_final_riddle)
	or a
	jr z, calendar_stone_center_trigger_ending_event_fn_ending
	ld hl, ending_A
calendar_stone_center_trigger_ending_event_fn_ending:
	ld a, ENDING_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
; input:
; - a: 0 or 1
draw_lowered_calendar_stone_dust:
	add 254
	ld hl, current_room__tile_map + 16*32 + 8
	ld b, 16
draw_lowered_calendar_stone_dust_loop:
	ld (hl), a
	xor #01
	inc hl
	djnz draw_lowered_calendar_stone_dust_loop
	ret


;-----------------------------------------------
calendar_stone__remove_bricks:
	ld b, 4
calendar_stone__remove_bricks_loop:
	ld a, (hl)
	ld (de), a
	ld (hl), 59  ; blue
	inc hl
	inc de
	djnz calendar_stone__remove_bricks_loop
	ret


;-----------------------------------------------
draw_lowered_calendar_stone:
	; - a: number of tiles to lower it
	; 1) draw 'a' empty rows:
	or a
	ret z
	push af
		ld hl, current_room__tile_map + 4*32+8
draw_lowered_calendar_stone_loop1:
		push hl
			ld d, h
			ld e, l
			inc de
			ld (hl), 0
			ld bc, 15
			ldir
		pop hl
		ld bc, 32
		add hl, bc
		dec a
		jr nz, draw_lowered_calendar_stone_loop1
	pop af

	; 2) copy the calendar part:
	neg
	add a, 13
	jr z, draw_lowered_calendar_stone_loop2_done
	ex de, hl
	ld hl, buffer_4096 + 4*32+8
draw_lowered_calendar_stone_loop2:
	push hl
		push de
			ld bc, 16
			ldir
		pop hl
		ld bc, 32
		add hl, bc
		ex de, hl
	pop hl
	add hl, bc
	dec a
	jr nz, draw_lowered_calendar_stone_loop2
draw_lowered_calendar_stone_loop2_done:
	; 3) restore the brick platforms:
	ld hl, buffer_4096 + 32*24
	ld de, current_room__tile_map + 14 + 11*32
	ld bc, 4
	ldir
	ld hl, buffer_4096 + 32*24 + 4
	ld de, current_room__tile_map + 14 + 14*32
	ld bc, 4
	ldir
	ret
