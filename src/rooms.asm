;-----------------------------------------------
draw_room:
	xor a
	ld (redraw_whole_room_flag), a
	ld bc, (room_scroll_x)  ; c = x offset, b = y offset

	ld hl, NAMTBL2
	call SETWRT

	; start drawing from: current_room__tile_map + (room_scroll_x) + (room_scroll_y) * width
	; if the width is not 32 or 64, we know that room_scroll_y == 0 anyway
	ld a, (current_room__width)
	ld h, 0
	ld l, a
	ld de, -32
	add hl, de
	ex de, hl  ; de = offset we need to add to copy the next row
	cp 64
	jr z, draw_room_width64
draw_room_width32:
	; in this case, we know room_scroll_x == 0
	ld a, (room_scroll_y)
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 32
	jp draw_room_continue
draw_room_width64:
	ld bc, (room_scroll_x)
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 64
	ld b, 0
	add hl, bc
draw_room_continue:
	ld bc, current_room__tile_map
	add hl, bc

	; hl = ptr from where to draw
	; de = room width
    ld a, (VDP.DW)
    ld c, a
    ld b, 24
draw_room_row_loop:
	push bc
		ld b, 32
draw_room_column_loop:
		outi
		jp nz, draw_room_column_loop
		add hl, de
	pop bc
	djnz draw_room_row_loop
	ret



; 	; - e, d: layout coordinates
; 	; - c, b: coordinates within the room:
; 	call global_position_to_layout_and_room_coordinates

; 	; render 32 - c from the first room, and c from the second room:
; 	ld a, 32
; 	sub c
; 	ld ixl, a
; 	ld ixh, c
; 	push bc

; 		; e = layout coordinates: e + d * 4:
; 		ld a, d
; 		add a, a
; 		add a, a
; 		add a, e
; 		ld e, a
; 		ld d, 0
; 		ld hl, current_room__layout
; 		add hl, de
; 		ld a, (hl)  ; a = room ID
; 		dec a
; 		inc hl
; 		ld e, (hl)  ; e = room immediately to the right (if any)
; 		dec e

; 		; draw_room_row_offset: (e - a) * 32 * 24
; 		push af
; 			sub e
; 			neg
; 			ld h, a
; 			ld l, 0
; 			add hl, hl
; 			ld b, a
; 			ld c, 0
; 			add hl, bc
; 			ld bc, -32
; 			add hl, bc
; 			ld (draw_room_row_offset), hl
; 		pop af

; 		; ptr to the room in 'current_room__tile_map': current_room__tile_map + a * 32 * 24:
; 		ld l, 0
; 		ld h, a
; 		add hl, hl
; 		ld b, a
; 		ld c, 0
; 		add hl, bc
; 		ld bc, current_room__tile_map
; 		add hl, bc
; 	pop bc

; 	; c, b: coordinates within the room:
; 	push hl
; 		ld h, 0
; 		ld l, b
; 		add hl, hl
; 		add hl, hl
; 		add hl, hl
; 		add hl, hl
; 		add hl, hl
; 		ld b, 0
; 		add hl, bc
; 	pop bc
; 	add hl, bc
; 	; hl = ptr to start rendering from

;     ld a, (VDP.DW)
;     ld c, a
;     ld b, 24
; draw_room_row_loop:
; 	push bc
; 		ld b, ixl
; draw_room_column_loop1:
; 		outi
; 		jp nz, draw_room_column_loop1
; 		ld a, ixh
; 		or a
; 		jr z, draw_room_column_loop2_done
; 		ld b, a
; 		ld de, (draw_room_row_offset)
; 		add hl, de
; draw_room_column_loop2:
; 		outi
; 		jp nz, draw_room_column_loop2
; 		or a
; 		ld de, (draw_room_row_offset)
; 		sbc hl, de
; draw_room_column_loop2_done:
; 	pop bc
; 	djnz draw_room_row_loop
; 	ret

