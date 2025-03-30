;-----------------------------------------------
maybe_recenter_scroll_and_set_actual:
	ld a, (current_room__max_scroll_x)
	or a
	jr nz, maybe_recenter_scroll_and_set_actual_continue
	ld (room_desired_scroll_x), a
	ld (room_scroll_x), a
maybe_recenter_scroll_and_set_actual_continue:
	ld a, (current_room__max_scroll_y)
	or a
	jr nz, maybe_recenter_scroll_and_set_actual_continue2
	ld (room_desired_scroll_y), a
	ld (room_scroll_y), a
maybe_recenter_scroll_and_set_actual_continue2:
	call maybe_recenter_scroll
	ld hl, (room_desired_scroll_x)
	ld (room_scroll_x), hl
	ret


;-----------------------------------------------
maybe_recenter_scroll:
	ld bc, (room_desired_scroll_x)
	; horizontal:
	ld a, (player_x + 1)
	cp #ff
	jr nz, maybe_recenter_scroll_no_x_overflow
	xor a
maybe_recenter_scroll_no_x_overflow:
	sub c
	cp 24
	jr nc, maybe_recenter_scroll_recenter_x
	cp 8
	jr c, maybe_recenter_scroll_recenter_x
maybe_recenter_scroll_vertical:
	; vertical:
	ld a, (player_y + 1)
	cp #ff
	jr nz, maybe_recenter_scroll_no_y_overflow
	xor a
maybe_recenter_scroll_no_y_overflow:	
	sub b
	cp 17
	jr nc, maybe_recenter_scroll_recenter_y
	cp 6
	jr c, maybe_recenter_scroll_recenter_y
	ret

maybe_recenter_scroll_recenter_x:
	ld a, (current_room__max_scroll_x)
	ld e, a
	ld a, (player_x + 1)
	cp #ff
	jr nz, maybe_recenter_scroll_recenter_x_no_x_overflow
	xor a
maybe_recenter_scroll_recenter_x_no_x_overflow:	
	sub 15
	jr nc, maybe_recenter_scroll_recenter_x_continue
	xor a
maybe_recenter_scroll_recenter_x_continue:
	cp e
	jr c, maybe_recenter_scroll_recenter_x_continue2
	ld a, e
maybe_recenter_scroll_recenter_x_continue2:
	ld (room_desired_scroll_x), a
	jp maybe_recenter_scroll_vertical

maybe_recenter_scroll_recenter_y:
	ld a, (current_room__max_scroll_y)
	ld e, a
	ld a, (player_y + 1)
	cp #ff
	jr nz, maybe_recenter_scroll_recenter_y_no_y_overflow
	xor a
maybe_recenter_scroll_recenter_y_no_y_overflow:		
	sub 11
	jr nc, maybe_recenter_scroll_recenter_y_continue
	xor a
maybe_recenter_scroll_recenter_y_continue:
	cp e
	jr c, maybe_recenter_scroll_recenter_y_continue2
	ld a, e
maybe_recenter_scroll_recenter_y_continue2:
	ld (room_desired_scroll_y), a
	ret


;-----------------------------------------------
update_scroll:
	ld bc, (room_desired_scroll_x)
	ld de, (room_scroll_x)
	ld a, e
	cp c
	jr z, update_scroll_vertical
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	jp c, update_scroll_right
	dec e
	jp update_scroll_vertical
update_scroll_right:
	inc e
update_scroll_vertical:

	ld a, d
	cp b
	jr z, update_scroll_done
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	jp c, update_scroll_down
	dec d
	jp update_scroll_done
update_scroll_down:
	inc d

update_scroll_done:
	ld (room_scroll_x), de
	ret

