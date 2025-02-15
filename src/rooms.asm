;-----------------------------------------------
; input:
; - c, b: x, y of the top-left corner (in tiles)
draw_room:
	ld hl, NAMTBL2
	call SETWRT

	; e, d = layout coordinates: c/32, (b/24)
	ld a, c
	rlca
	rlca
	rlca
	and #07
	ld e, a
	ld d, 0
	ld a, b
	sub 24
	jr c, draw_room_layout_coordinates_computed
	ld b, a
	inc d
	sub 24
	jr c, draw_room_layout_coordinates_computed
	ld b, a
	inc d
	sub 24
	jr c, draw_room_layout_coordinates_computed
	ld b, a
	inc d
draw_room_layout_coordinates_computed:

	; here c, b are coordinates within the room:
	ld a, c
	and #1f
	ld c, a

	; render 32 - c from the first room, and c from the second room:
	ld a, 32
	sub c
	ld ixl, a
	ld ixh, c
	push bc

		; e = layout coordinates: e + d * 4:
		ld a, d
		add a, a
		add a, a
		add a, e
		ld e, a
		ld d, 0
		ld hl, current_room__layout
		add hl, de
		ld a, (hl)  ; a = room ID (must be > 0)
		dec a
		inc hl
		ld e, (hl)  ; e = room immediately to the right (if any)
		dec e

		; draw_room_row_offset: (e - a) * 32 * 24
		push af
			sub e
			neg
			ld h, a
			ld l, 0
			add hl, hl
			ld b, a
			ld c, 0
			add hl, bc
			ld bc, -32
			add hl, bc
			ld (draw_room_row_offset), hl
		pop af

		; ptr to the room in 'current_room__tile_map': current_room__tile_map + a * 32 * 24:
		ld l, 0
		ld h, a
		add hl, hl
		ld b, a
		ld c, 0
		add hl, bc
		ld bc, current_room__tile_map
		add hl, bc
	pop bc

	; c, b: coordinates within the room:
	push hl
		ld h, 0
		ld l, b
		add hl, hl
		add hl, hl
		add hl, hl
		add hl, hl
		add hl, hl
		ld b, 0
		add hl, bc
	pop bc
	add hl, bc
	; hl = ptr to start rendering from

    ld a, (VDP.DW)
    ld c, a
    ld b, 24
draw_room_row_loop:
	push bc
		ld b, ixl
draw_room_column_loop1:
		outi
		jp nz, draw_room_column_loop1
		ld a, ixh
		or a
		jr z, draw_room_column_loop2_done
		ld b, a
		ld de, (draw_room_row_offset)
		add hl, de
draw_room_column_loop2:
		outi
		jp nz, draw_room_column_loop2
		or a
		ld de, (draw_room_row_offset)
		sbc hl, de
draw_room_column_loop2_done:
	pop bc
	djnz draw_room_row_loop
	ret
