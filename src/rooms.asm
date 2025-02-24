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


;-----------------------------------------------
; input:
; - c: x
; - b: y
get_room_tile_ptr:
	ld a, (current_room__width)
	cp 64
	jr z, get_room_tile_ptr_width64
get_room_tile_ptr_width32:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 32
	jp get_room_tile_ptr_continue
get_room_tile_ptr_width64:
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 64
get_room_tile_ptr_continue:
	ld b, 0
	add hl, bc
	ld bc, current_room__tile_map
	add hl, bc
	ret


;-----------------------------------------------
update_animations_in_vdp:
	ld a, (interrupt_cycle)
	and #07
	ret nz
	SETMEGAROMPAGE_8000 TILES_PAGE
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #03
	jr z, update_animations_in_vdp_frame0
	dec a
	jr z, update_animations_in_vdp_frame1
	dec a
	jr z, update_animations_in_vdp_frame2
update_animations_in_vdp_frame3:
	ld hl, animations_pyramid_bin + 16*3
	jr update_animations_in_vdp_frame_continue
update_animations_in_vdp_frame0:
	ld hl, animations_pyramid_bin
update_animations_in_vdp_frame_continue:
	ld b, 3
	ld de, CHRTBL2 + (6*16 + 2)*8
update_animations_in_vdp_frame_loop:
	push bc
	push hl
		push de
			push hl
				push de
					ld b, 16
					call fast_small_LDIRVM
				pop hl
				ld de, CLRTBL2 - CHRTBL2
				add hl, de
				ex de, hl
			pop hl
			ld bc, 64
			add hl, bc
			ld b, 16
			call fast_small_LDIRVM
		pop hl
		ld bc, 256*8
		add hl, bc
		ex de, hl
	pop hl
	pop bc
	djnz update_animations_in_vdp_frame_loop
	ret
update_animations_in_vdp_frame1:
	ld hl, animations_pyramid_bin + 16*1
	jr update_animations_in_vdp_frame_continue
update_animations_in_vdp_frame2:
	ld hl, animations_pyramid_bin + 16*2
	jr update_animations_in_vdp_frame_continue

