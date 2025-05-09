;-----------------------------------------------
update_animations_in_vdp_pyramid:
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


;-----------------------------------------------
update_animations_in_vdp_calendar:
	ld a, (interrupt_cycle)
	and #07
	ret nz
	SETMEGAROMPAGE_8000 TILES_PAGE
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #03
	jr z, update_animations_in_vdp_calendar_frame0
	dec a
	jr z, update_animations_in_vdp_calendar_frame1
	dec a
	jr z, update_animations_in_vdp_calendar_frame2
update_animations_in_vdp_calendar_frame3:
	ld hl, animations_pyramid_bin + 16*3
	jr update_animations_in_vdp_calendar_frame_continue
update_animations_in_vdp_calendar_frame0:
	ld hl, animations_pyramid_bin
update_animations_in_vdp_calendar_frame_continue:
	ld b, 3
	ld de, CHRTBL2 + (6*16 + 2)*8
update_animations_in_vdp_calendar_frame_loop:
	push bc
	push hl
		push de
			push hl
				push de
					ld b, 8
					call fast_small_LDIRVM
				pop hl
				ld de, CLRTBL2 - CHRTBL2
				add hl, de
				ex de, hl
			pop hl
			ld bc, 64
			add hl, bc
			ld b, 8
			call fast_small_LDIRVM
		pop hl
		ld bc, 256*8
		add hl, bc
		ex de, hl
	pop hl
	pop bc
	djnz update_animations_in_vdp_calendar_frame_loop
	ret
update_animations_in_vdp_calendar_frame1:
	ld hl, animations_pyramid_bin + 16*1
	jr update_animations_in_vdp_calendar_frame_continue
update_animations_in_vdp_calendar_frame2:
	ld hl, animations_pyramid_bin + 16*2
	jr update_animations_in_vdp_calendar_frame_continue
