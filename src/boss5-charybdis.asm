boss5_charybdis_difficulty_setting__easy:
	dw 32  ; boss hp
	db 64  ; idle time
boss5_charybdis_difficulty_setting__normal:
	dw 48  ; boss hp
	db 64  ; idle time
boss5_charybdis_difficulty_setting__hard:
	dw 64  ; boss hp
	db 64  ; idle time
boss5_charybdis_difficulty_setting__hardest:
	dw 80  ; boss hp
	db 64  ; idle time

BOSS_5_CHARYBDIS_HP_OFFSET: equ 0
BOSS_5_CHARYBDIS_IDLE_TIME_OFFSET: equ 2


;-----------------------------------------------
update_boss5_behavior_1:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_1_state_0
	dec a
	jr z, update_boss5_behavior_1_state_1
	dec a
	jr z, update_boss5_behavior_1_state_2
	dec a
	jr z, update_boss5_behavior_1_state_3
	; ...
	ret

update_boss5_behavior_1_state_0:
	; switch:
	ld c, 3
	call random_modulo
	inc a
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	jr update_boss5_behavior_1

update_boss5_behavior_1_state_1:
	; idle:
	ld a, (boss__5_settings + BOSS_5_CHARYBDIS_IDLE_TIME_OFFSET)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp c
	jr z, update_boss5_behavior_1_state_0

	and #07
	jr nz, update_boss5_behavior_1_state_1_no_mouth_movement
	ld hl, boss__5_charybdis_mouth_state
	ld a, (hl)
	xor #01
	ld (hl), a
	ld a, 1
	ld (boss__5_needs_redraw), a
update_boss5_behavior_1_state_1_no_mouth_movement:

	call random_a
	and #07
	jr nz, update_boss5_behavior_1_state_1_no_claw_movement
	ld hl, boss__5_charybdis_left_claw_state
	ld a, (hl)
	xor #01
	ld (hl), a
	ld hl, boss__5_charybdis_right_claw_state
	ld a, (hl)
	xor #01
	ld (hl), a
	ld a, 1
	ld (boss__5_needs_redraw), a	
update_boss5_behavior_1_state_1_no_claw_movement:
	ld a, (boss__5_needs_redraw)
	or a
	ret z
	jp update_boss5_draw_charybdis

update_boss5_behavior_1_state_2:
	; walk left:
	; ...
	jr update_boss5_behavior_1_state_0

update_boss5_behavior_1_state_3:
	; walk right:
	; ...
	jr update_boss5_behavior_1_state_0


;-----------------------------------------------
; coordinate is the top-left of the 16x5 body 
update_boss5_draw_charybdis:
	xor a
	ld (boss__5_needs_redraw), a
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

	; mouth:
	ld a, (boss__5_charybdis_mouth_state)
	or a
	jr z, update_boss5_draw_charybdis_no_mouth
	push hl
		ld bc, 7 + 2*32
		add hl, bc
		ex de, hl
		ld ix, boss5_frame_mouth
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_2_without_clearing_ix
		call call_hl_in_page_c_8000
	pop hl
update_boss5_draw_charybdis_no_mouth:

	; draw claws:
	push hl
		ld bc, 3 + 2*32
		add hl, bc
		push hl
			ex de, hl
			ld ix, boss5_frame_left_claw1
			ld c, BOSS_PAGE
			ld hl, draw_boss_frame_2_without_clearing_ix
			call call_hl_in_page_c_8000
		pop hl
		ld bc, 6
		add hl, bc
		ex de, hl
		ld ix, boss5_frame_right_claw1
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_2_without_clearing_ix
		call call_hl_in_page_c_8000
	pop hl

	; draw top:
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

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	ret


;-----------------------------------------------
; input:
; - e: tile number that was hit
; - iyh: damage to deal
; - iyl: collision ID
player_weapon_hitbox_check_boss__boss5_charybdis_hit:
	ld a, (boss__behavior)
	cp 0
	jr nz, player_weapon_hitbox_check_boss__boss5_hit_shield
	; ...
	; hit the main body:
; 	ld hl, player_weapon_hitbox_check_boss__lose_hp
; 	ld c, BOSS_PAGE
; 	call call_hl_in_page_c_8000	
; 	ret

player_weapon_hitbox_check_boss__boss5_hit_shield:
	ld hl, SFX_shield
	call play_SFX_with_high_priority
	xor a
	ld (player_weapon_hitbox_check_result), a  ; mark a hit
	ld a, iyl
	ld (boss__last_collision_id), a
	ret
