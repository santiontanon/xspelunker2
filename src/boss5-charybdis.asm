;-----------------------------------------------
; coordinate is the top-left of the 16x5 body 
update_boss5_draw_charybdis:
	; clear previous frame:
	ld hl, draw_boss_frame_clear_previous_frame_1
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
	ld hl, draw_boss_frame_clear_previous_frame_2
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	ld bc, (boss__x)
	call get_room_tile_ptr
	ex de, hl  ; hl = ptr where the boss is to be drawn	
	; draw body:
	push de
		ld ix, boss5_frame_charybdis_body_0
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_1_without_clearing_ix
		call call_hl_in_page_c_8000
	pop hl
	ld (boss__clear_bbox_1), hl
	ld bc, #0510
	ld (boss__clear_bbox_1 + 2), bc

	; draw top:
	push hl
		ld bc, 4 - 32 * 6
		add hl, bc
		push hl
			ex de, hl
			ld ix, boss5_frame_island_0
			ld c, BOSS_PAGE
			ld hl, draw_boss_frame_2_without_clearing_ix
			call call_hl_in_page_c_8000
		pop hl
		ld (boss__clear_bbox_2), hl
		ld bc, #0708
		ld (boss__clear_bbox_2 + 2), bc
	pop hl

	; draw claws:
	; ...
	ret
