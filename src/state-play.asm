;-----------------------------------------------
state_play:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	call disable_VDP_output
		ld hl, RAM_to_zero_on_game_start
		ld bc, RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start
		call clear_memory

		; setup tiles:
		ld a, TILES_PAGE
		ld hl, tiles_pyramid_zx0
		call setup_game_tiles

		; get room data:
		SETMEGAROMPAGE_8000 MAP_DATA_PAGE
		ld hl, hardcoded_room_data
		ld de, current_room__width
		ld bc, hardcoded_room_data_end - hardcoded_room_data
		ldir

		; init sprite attribute table:
		ld hl, sprite_attribute_table + 2
		ld (hl), 0
		inc hl
		ld (hl), COLOR_DARK_YELLOW
		ld hl, sprite_attribute_table + 2 + 4
		ld (hl), 4
		inc hl
		ld (hl), COLOR_DARK_RED

		; initial player position:
		ld hl, #0e00
		ld (player_x), hl
		ld hl, #0800
		ld (player_y), hl

		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000
		call maybe_recenter_scroll
		call draw_room

	call enable_VDP_output

	xor a
state_play_loop:
	; game update:
	call update_keyboard_buffers
	call player_update
	call maybe_recenter_scroll
	call update_scroll

	halt
	; game redraw:
	ld hl, upload_sprites_to_vdp
	ld c, SPRITES_PAGE
	call call_hl_in_page_c_8000
	ld a, (redraw_whole_room_flag)
	or a
	call nz, draw_room
	jr state_play_loop


;-----------------------------------------------
maybe_recenter_scroll:
	ld bc, (room_desired_scroll_x)
	; horizontal:
	ld a, (player_x + 1)
	sub c
	cp 24
	jr nc, maybe_recenter_scroll_recenter_x
	cp 8
	jr c, maybe_recenter_scroll_recenter_x
maybe_recenter_scroll_vertical:
	; vertical:
	ld a, (player_y + 1)
	sub b
	cp 18
	jr nc, maybe_recenter_scroll_recenter_y
	cp 6
	jr c, maybe_recenter_scroll_recenter_y
	ret

maybe_recenter_scroll_recenter_x:
; 	ld a, (current_room__scroll_type)
; 	or a
; 	jr nz, maybe_recenter_scroll_recenter_x_axis_method
maybe_recenter_scroll_recenter_x_rectangle_method:
	ld a, (current_room__max_scroll_x)
	ld e, a
	ld a, (player_x + 1)
	sub 15
	jr nc, maybe_recenter_scroll_recenter_x_rectangle_method_continue
	xor a
maybe_recenter_scroll_recenter_x_rectangle_method_continue:
	cp e
	jr c, maybe_recenter_scroll_recenter_x_rectangle_method_continue2
	ld a, e
maybe_recenter_scroll_recenter_x_rectangle_method_continue2:
	ld (room_desired_scroll_x), a
	jp maybe_recenter_scroll_vertical

; maybe_recenter_scroll_recenter_x_axis_method:
; 	; if y == current_room__scroll_horizontal_rail -> we can just scroll with the rectangle method
; 	ld a, (current_room__scroll_horizontal_rail)
; 	ld e, a
; 	ld a, (room_desired_scroll_y)
; 	cp e
; 	jr z, maybe_recenter_scroll_recenter_x_rectangle_method

; 	; ...

; 	jp maybe_recenter_scroll_vertical

maybe_recenter_scroll_recenter_y:
; 	ld a, (current_room__scroll_type)
; 	or a
; 	jr nz, maybe_recenter_scroll_recenter_y_axis_method
maybe_recenter_scroll_recenter_y_rectangle_method:
	ld a, (current_room__max_scroll_y)
	ld e, a
	ld a, (player_y + 1)
	sub 11
	jr nc, maybe_recenter_scroll_recenter_y_rectangle_method_continue
	xor a
maybe_recenter_scroll_recenter_y_rectangle_method_continue:
	cp e
	jr c, maybe_recenter_scroll_recenter_y_rectangle_method_continue2
	ld a, e
maybe_recenter_scroll_recenter_y_rectangle_method_continue2:
	ld (room_desired_scroll_y), a
	ret

; maybe_recenter_scroll_recenter_y_axis_method:
; 	; if x == current_room__scroll_vertical_rail -> we can just scroll with the rectangle method
; 	ld a, (current_room__scroll_vertical_rail)
; 	ld e, a
; 	ld a, (room_desired_scroll_x)
; 	cp e
; 	jr z, maybe_recenter_scroll_recenter_y_rectangle_method

; 	; ...

; 	ret


;-----------------------------------------------
update_scroll:
	ld bc, (room_desired_scroll_x)
	ld de, (room_scroll_x)
	ld a, e
	cp c
	jr z, update_scroll_vertical
	ld a, 1
	ld (redraw_whole_room_flag), a
	jp c, update_scroll_right
	dec e
	jp update_scroll_vertical
update_scroll_right:
	inc e
update_scroll_vertical:

	ld a, d
	cp b
	jr z, update_scroll_done
	ld a, 1
	ld (redraw_whole_room_flag), a
	jp c, update_scroll_down
	dec d
	jp update_scroll_done
update_scroll_down:
	inc d

update_scroll_done:
	ld (room_scroll_x), de
	ret

