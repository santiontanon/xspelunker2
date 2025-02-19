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
update_animations:
	ld a, (interrupt_cycle)
	and #07
	ret nz
	ld hl, current_room__tile_animations
update_animations_loop:
	; Each animation is 4 bytes long: type, x, y, width
	ld a, (hl)
	or a
	ret z  ; no more animations
	dec a
	jr z, update_animations_torch
update_animations_water:  ; cycles between: 129, 130, 131, 200
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #03
	cp 3
	jr nz, update_animations_water_continue
	ld a, 71  ; so that we get 200
update_animations_water_continue:
	add a, 129
	jp update_animations_torch_continue2

update_animations_torch:  ; cycles between: 98, 99, 100, 99
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #03
	cp 3
	jr nz, update_animations_torch_continue
	ld a, 1
update_animations_torch_continue:
	add a, 98
update_animations_torch_continue2:
	ld d, a
	inc hl
	ld c, (hl)
	inc hl
	ld b, (hl)
	inc hl
	ld e, (hl)
	inc hl
	push hl
		call get_room_tile_ptr
update_animations_row_loop:
		ld (hl), d
		inc hl
		dec e
		jr nz, update_animations_row_loop
	pop hl
	jp update_animations_loop


;-----------------------------------------------
update_animations_in_vdp:
	; - on cycle 0 we will just update the animations
	; - on cycle 4 we will upload to VDP
	ld a, (interrupt_cycle)
	and #07
	or a
	jp z, update_animations
	cp 4
	ret nz
	; upload animations to VDP:
	ld hl, current_room__tile_animations
update_animations_in_vdp_loop:
	; Each animation is 4 bytes long: type, x, y, width
	ld a, (hl)
	or a
	ret z  ; no more animations
	inc hl
	ld c, (hl)  ; x
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld e, (hl)  ; width
	inc hl
	push hl
		; check if we are within screen bounds:
		ld hl, room_scroll_y
		ld a, b
		sub (hl)
		jp m, update_animations_in_vdp_loop_skip
		cp 24
		jp p, update_animations_in_vdp_loop_skip
		; there overlap in y:

		; copy:
		; - from ixl: max(c, room_scroll_x)
		; - to ixh: min(c + e, room_scroll_x + 32)		
		dec hl  ; room_scroll_x
		ld a, c
		sub (hl)
		jr c, update_animations_in_vdp_loop_max_is_room_scroll_x
		ld a, c
		jp update_animations_in_vdp_loop_max_computed
update_animations_in_vdp_loop_max_is_room_scroll_x:
		ld a, (hl)
update_animations_in_vdp_loop_max_computed:
		ld ixl, a  ; from

		ld a, (hl)
		add a, 32
		ld d, a  ; d = (room_scroll_x) + 32
		ld a, c
		add a, e
		sub d
		jr nc, update_animations_in_vdp_loop_min_is_room_scroll_x
		add a, d
		jp update_animations_in_vdp_loop_min_computed
update_animations_in_vdp_loop_min_is_room_scroll_x:
		ld a, (hl)
		add a, 32
update_animations_in_vdp_loop_min_computed:
		ld ixh, a  ; to

		; we should have that ixl < ixh
		sub ixl
		jr z, update_animations_in_vdp_loop_skip
		jr c, update_animations_in_vdp_loop_skip

	    ; in case the start coordinate was left of the left-edge:
	    push af

			; copy "a" (in stack) bytes from "ixl" to "ixh":
			; - c, b: room tile coordinates
			; - ixl, ixh: room x coordinates of the area to copy
			ld c, ixl
			push bc
				call get_room_tile_ptr  ; hl: ptr to copy from
			pop bc
			push hl
				; ptr to copy to: (b - (room_scroll_y)) * 32 + NAMTBL2 + (ixl - room_scroll_x)
				ld hl, room_scroll_x
				ld c, (hl)
				inc hl
				ld a, b
				sub (hl)
				ld l, a
				ld h, 0
				add hl, hl
				add hl, hl
				add hl, hl
				add hl, hl
				add hl, hl
				ld a, ixl
				sub c
				ld b, 0
				ld c, a
				add hl, bc
				ld bc, NAMTBL2
				add hl, bc
				ex de, hl
			pop hl
		pop af
		ld b, 0
		ld c, a
		call fast_LDIRVM
update_animations_in_vdp_loop_skip:
	pop hl
	jp update_animations_in_vdp_loop
