boss5_scylla_difficulty_setting__easy:
	dw 32  ; boss hp
	db 64  ; idle time
boss5_scylla_difficulty_setting__normal:
	dw 48  ; boss hp
	db 64  ; idle time
boss5_scylla_difficulty_setting__hard:
	dw 64  ; boss hp
	db 64  ; idle time
boss5_scylla_difficulty_setting__hardest:
	dw 80  ; boss hp
	db 64  ; idle time

BOSS_5_SCYLLA_HP_OFFSET: equ 0


;-----------------------------------------------
; coordinate is the top-left of the 6x6 body 
update_boss5_draw_scylla:
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
		ld ix, boss5_frame_scylla_body_0
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_1_without_clearing_ix
		call call_hl_in_page_c_8000
	pop hl
	ld (boss__clear_bbox_1), hl
	ld bc, #0606
	ld (boss__clear_bbox_1 + 2), bc

	; draw top:
	push hl
		ld bc, - (1 + 32 * 7)
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

	; draw arms:
	; ...
	ret


;-----------------------------------------------
; input:
; - e: tile number that was hit
; - iyh: damage to deal
; - iyl: collision ID
player_weapon_hitbox_check_boss__boss5_scylla_hit:
	ld a, (boss__behavior)
	cp 0
	jp nz, player_weapon_hitbox_check_boss__boss5_hit_shield
	; ...
	; hit the main body:
; 	ld hl, player_weapon_hitbox_check_boss__lose_hp
; 	ld c, BOSS_PAGE
; 	call call_hl_in_page_c_8000	
	jp player_weapon_hitbox_check_boss__boss5_hit_shield

