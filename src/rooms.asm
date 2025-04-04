;-----------------------------------------------
draw_room_only_hud
	call draw_room_compute_ptrs
	ld b, 2
	jr draw_room_with_hud_entry_point


;-----------------------------------------------
; When the hud is not "full" (it only has small parts), we draw it on top of the room itself,
; and then transfer those tiles to the VDP to make things faster.
draw_room_with_hud:
	call draw_room_compute_ptrs

	ld b, 24
draw_room_with_hud_entry_point:
	push bc
		; hl = ptr from where to draw
		; de = room width - 32
		; copy the room content underneath the hud:
		ld (tmp_hud_drawing_hl), hl
		ld (tmp_hud_drawing_de), de
		ld b, d
		ld c, e
		ld de, hud_draw_buffer
		push bc
			ld bc, 32
			ldir
		pop bc
		add hl, bc
		ld bc, 32
		ldir

		; Draw the hud:
		ld a, (config_hud_type)
		cp 2
		jr nz, draw_room_with_hud_minimal
		call draw_hud_full

		ld hl, NAMTBL2 + 32*2  ; when the hud is full, we draw the room 2 rows lower
		call SETWRT
	pop bc
	dec b  ; with full hud, we draw 2 less rows of map
	dec b
	ret z  ; if we are only drawing the hud, we are done
	push bc
		jr draw_room_with_hud_drawn
draw_room_with_hud_minimal:
		call draw_hud_minimal

		ld hl, NAMTBL2
		call SETWRT
draw_room_with_hud_drawn:

		ld hl, (tmp_hud_drawing_hl)
		ld de, (tmp_hud_drawing_de)
	pop bc  ; number of rows to draw
	; Draw the room:
    ld a, (VDP.DW)
    ld c, a
draw_room_with_hud_row_loop:
	push bc
		ld b, 32
draw_room_with_hud_column_loop:
		outi
		jp nz, draw_room_with_hud_column_loop
		add hl, de
	pop bc
	djnz draw_room_with_hud_row_loop

	; Restore the content below the hud:
	ld bc, (tmp_hud_drawing_de)
	ld de, (tmp_hud_drawing_hl)
	ld hl, hud_draw_buffer
	push bc
		ld bc, 32
		ldir
	pop bc
	ex de, hl
		add hl, bc
	ex de, hl
	ld bc, 32
	ldir

	xor a
	ld (redraw_flags), a
	ret


;-----------------------------------------------
draw_room:
	ld hl, NAMTBL2
	call SETWRT

	call draw_room_compute_ptrs

	; hl = ptr from where to draw
	; de = room width - 32
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

	xor a
	ld (redraw_flags), a	
	ret


;-----------------------------------------------
; output:
; - hl = ptr from where to draw
; - de = room width - 32
draw_room_compute_ptrs:
	; start drawing from: current_room__tile_map + (room_scroll_x) + (room_scroll_y) * width
	; if the width is not 32 or 64, we know that room_scroll_y == 0 anyway
	ld bc, (room_scroll_x)  ; c = x offset, b = y offset
	ld a, (current_room__width)
	ld h, 0
	ld l, a
	ld de, -32
	add hl, de
	ex de, hl  ; de = offset we need to add to copy the next row
	cp 64
	jr z, draw_room_width64
	cp 96
	jr z, draw_room_width96
	cp 128
	jr z, draw_room_width128
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
draw_room_width96:
	ld bc, (room_scroll_x)  ; b: room_scroll_y, c: room_scroll_x
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	push de
		ld e, l
		ld d, h
		add hl, hl
		add hl, de  ; hl = y * 96
	pop de
	ld b, 0
	add hl, bc  ; add room_scroll_x
	jp draw_room_continue
draw_room_width64:
	ld bc, (room_scroll_x)
	ld l, b
	ld h, 0
	jp draw_room_width64_entrypoint
draw_room_width128:
	ld bc, (room_scroll_x)  ; b: room_scroll_y, c: room_scroll_x
	ld l, b
	ld h, 0
	add hl, hl
draw_room_width64_entrypoint:
	add hl, hl
draw_room_width32_entrypoint:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 128
	ld b, 0
	add hl, bc
draw_room_continue:
	ld bc, current_room__tile_map
	add hl, bc
	ret


;-----------------------------------------------
; input:
; - c: x
; - b: y
get_room_tile_ptr:
	ld a, (current_room__width)
	cp 64
	jr z, get_room_tile_ptr_width64
	cp 96
	jr z, get_room_tile_ptr_width96
	cp 128
	jr z, get_room_tile_ptr_width128
get_room_tile_ptr_width32:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0
	jr get_room_tile_ptr_width32_entry_point
get_room_tile_ptr_width96:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0
	ld a, c  ; preserve c
	ld c, b
	ld b, 0
	add hl, hl
	add hl, bc  ; hl = y * 3
	ld c, a
	jr get_room_tile_ptr_width96_entry_point
get_room_tile_ptr_width128:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0
	add hl, hl
	jr get_room_tile_ptr_width128_entry_point
get_room_tile_ptr_width64:
	ld l, b
	ld h, 0
get_room_tile_ptr_width128_entry_point:
	add hl, hl
get_room_tile_ptr_width32_entry_point:
get_room_tile_ptr_width96_entry_point:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 128
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

