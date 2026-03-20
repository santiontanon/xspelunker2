boss5_scylla_difficulty_setting__easy:
	db 32, 16  ; boss hp, vat hp
	db 64  ; idle time
boss5_scylla_difficulty_setting__normal:
	db 48, 16  ; boss hp, vat hp
	db 64  ; idle time
boss5_scylla_difficulty_setting__hard:
	db 64, 24  ; boss hp, vat hp
	db 64  ; idle time
boss5_scylla_difficulty_setting__hardest:
	db 80, 32  ; boss hp, vat hp
	db 64  ; idle time

BOSS_5_SCYLLA_HP_OFFSET: equ 0


;-----------------------------------------------
; Scylla with island on top
update_boss5_behavior_4:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_4_state_0
	dec a
	jr z, update_boss5_behavior_4_state_1  ; idle
	dec a	
	; ...
	ret

update_boss5_behavior_4_state_0:
; 	; switch:
; 	; if player is on top of the island, chance of jump attack:
; 	ld a, (player_y + 1)
; 	cp 14
; 	jr nc, update_boss5_behavior_4_state_0_no_jump
; 	ld a, (player_x + 1)
; 	ld c, a
; 	ld a, (boss__x)
; 	add a, 3
; 	cp c
; 	jr nc, update_boss5_behavior_4_state_0_no_jump
; 	add a, 9
; 	cp c
; 	jr c, update_boss5_behavior_4_state_0_no_jump
; 	; player is on top of the island, chance of jumping
; 	call random_a
; 	and #01
; 	jr z, update_boss5_behavior_4_state_0_no_jump
; 	ld a, 4
; 	ld (boss__state), a
; 	xor a
; 	ld (boss__state_timer), a
; 	jr update_boss5_behavior_4
; update_boss5_behavior_4_state_0_no_jump:
; 	ld c, 3
; 	call random_modulo
; 	inc a
	ld a, 1
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	jr update_boss5_behavior_4

update_boss5_behavior_4_state_1:
	; idle:
	xor a
	ld (boss__5_needs_redraw), a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)

	; ...
	call update_boss5_scylla_control_back_arms
	; ...
	ld a, (boss__5_needs_redraw)
	or a
	ret z
	jp update_boss5_draw_scylla

update_boss5_scylla_control_back_arms:
	ld a, (boss__state_timer)
	and #07
	ret nz
	ld c, 3
	call random_modulo
	dec a
	ld c, a
	ld a, (boss__5_scylla_arms_state)
	add a, c
	ld c, 4
	call update_boss5_scylla_arm_state_limit
	ld (boss__5_scylla_arms_state), a
	ld a, 1
	ld (boss__5_needs_redraw), a
	ret

update_boss5_scylla_arm_state_limit:
	; c: limit
	cp c
	ret c
	cp 128
	jr c, update_boss5_scylla_arm_state_limit_down
	xor a
	ret
update_boss5_scylla_arm_state_limit_down:
	ld a, c
	dec a
	ret

;-----------------------------------------------
; Scylla with vat/brain
update_boss5_behavior_5:
	; ...
	ret


;-----------------------------------------------
; Scylla dying
update_boss5_behavior_6:
	; ...
	ret


;-----------------------------------------------
update_boss5_draw_scylla_lb_arm_table:
	dw boss5_frame_scylla_lb_arm_0
	dw boss5_frame_scylla_lb_arm_1
	dw boss5_frame_scylla_lb_arm_2
	dw boss5_frame_scylla_lb_arm_3


;-----------------------------------------------
; coordinate is the top-left of the 6x6 body 
update_boss5_draw_scylla:
	xor a
	ld (boss__5_needs_redraw), a
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	

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
	push hl
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
		push hl
			ld bc, + 1 * 32 - 8
			add hl, bc
			ex de, hl
			; back left arm:
			ld a, (boss__5_scylla_arms_state)
			add a, a
			ld hl, update_boss5_draw_scylla_lb_arm_table
			ADD_HL_A
			ld c, (hl)
			inc hl
			ld b, (hl)
			ld ixl, c
			ld ixh, b
			ld c, BOSS_PAGE
			ld hl, draw_boss_frame_1_without_clearing_ix
			call call_hl_in_page_c_8000
			; ...
		pop hl
	pop hl
	; bl arm: -8 in x and +7 down
	ld bc, -8
	add hl, bc
	ld (boss__clear_bbox_1), hl
	ld bc, #0d0e
	ld (boss__clear_bbox_1 + 2), bc
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

