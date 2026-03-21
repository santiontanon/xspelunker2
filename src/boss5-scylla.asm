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

	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_control_forward_arm

	; blink:
	ld a, (boss__state_timer)
	and #1f
	jr nz, update_boss5_behavior_4_state_1_continue
	call random_a
	and #03
	ld c, 0
	jr nz, update_boss5_behavior_4_state_1_eyes_open
	inc c
update_boss5_behavior_4_state_1_eyes_open:
	ld a, (boss__5_scylla_body_state)
	cp c
	jr z, update_boss5_behavior_4_state_1_continue
	ld a, c
	ld (boss__5_scylla_body_state), a
	ld a, 1
	ld (boss__5_needs_redraw), a
update_boss5_behavior_4_state_1_continue:
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

	ld c, 3
	call random_modulo
	dec a
	ld c, a
	ld a, (boss__5_scylla_arms_state + 4)
	add a, c
	ld c, 4
	call update_boss5_scylla_arm_state_limit
	ld (boss__5_scylla_arms_state + 4), a

	ld a, 1
	ld (boss__5_needs_redraw), a
	ret

update_boss5_scylla_control_left_arm:
	ld hl, boss__5_scylla_arms_inertia + 0
	ld de, boss__5_scylla_arms_state + 1
	ld c, 6
	jr update_boss5_scylla_control_arm_generic

update_boss5_scylla_control_right_arm:
	ld hl, boss__5_scylla_arms_inertia + 2
	ld de, boss__5_scylla_arms_state + 3
	ld c, 6
	jr update_boss5_scylla_control_arm_generic

update_boss5_scylla_control_forward_arm:
	ld hl, boss__5_scylla_arms_inertia + 1
	ld de, boss__5_scylla_arms_state + 2
	ld c, 11

update_boss5_scylla_control_arm_generic:
	ld a, (boss__state_timer)
	and #07
	ret nz

	; change the inertia?
	call random_a
	and #03
	jr nz, update_boss5_scylla_control_arm_generic_inertia_set
	; inertia change:
	; chance to move towards player:
	call random_a
	and #01
	jr nz, update_boss5_scylla_control_arm_generic_ignore_player
	ld a, (boss__x)
	ld b, a
	ld a, (player_y + 1)
	cp 14
	jr nc, update_boss5_scylla_control_arm_generic_ignore_player
	inc b
	ld a, (player_x + 1)
	cp b
	jr nc, update_boss5_scylla_control_arm_generic_player_not_left
	; player left:
	ld (hl), -1
	jr update_boss5_scylla_control_arm_generic_inertia_set
update_boss5_scylla_control_arm_generic_player_not_left:
	inc b
	inc b
	inc b
	inc b
	cp b
	jr c, update_boss5_scylla_control_arm_generic_ignore_player
	; player right:
	ld (hl), 1
	jr update_boss5_scylla_control_arm_generic_inertia_set
update_boss5_scylla_control_arm_generic_ignore_player:
	push bc
		ld c, 3
		call random_modulo
	pop bc
	dec a
	ld (hl), a	 ; inertia
update_boss5_scylla_control_arm_generic_inertia_set:
	ld a, (de)  ; state
	add a, (hl)  ; inertia
	call update_boss5_scylla_arm_state_limit  ; 'c' is the limit here
	ld (de), a
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
update_boss5_draw_scylla_top_table
	dw boss5_frame_island_0
	dw boss5_frame_island_1
	dw boss5_frame_island_2
	dw boss5_frame_scylla_vat
	dw boss5_frame_scylla_brain

update_boss5_draw_scylla_body_table:
	dw boss5_frame_scylla_body_0  ; base
	dw boss5_frame_scylla_body_1  ; eyes closed
	dw boss5_frame_scylla_body_2  ; mouth open

update_boss5_draw_scylla_lb_arm_table:
	dw boss5_frame_scylla_lb_arm_0
	dw boss5_frame_scylla_lb_arm_1
	dw boss5_frame_scylla_lb_arm_2
	dw boss5_frame_scylla_lb_arm_3

update_boss5_draw_scylla_rb_arm_table:
	dw boss5_frame_scylla_rb_arm_0
	dw boss5_frame_scylla_rb_arm_1
	dw boss5_frame_scylla_rb_arm_2
	dw boss5_frame_scylla_rb_arm_3

update_boss5_draw_scylla_l_arm_table:
	dw boss5_frame_scylla_l_arm_0
	dw boss5_frame_scylla_l_arm_1
	dw boss5_frame_scylla_l_arm_2
	dw boss5_frame_scylla_l_arm_3
	dw boss5_frame_scylla_l_arm_4
	dw boss5_frame_scylla_l_arm_5

update_boss5_draw_scylla_r_arm_table:
	dw boss5_frame_scylla_r_arm_0
	dw boss5_frame_scylla_r_arm_1
	dw boss5_frame_scylla_r_arm_2
	dw boss5_frame_scylla_r_arm_3
	dw boss5_frame_scylla_r_arm_4
	dw boss5_frame_scylla_r_arm_5

update_boss5_draw_scylla_f_arm_table:
	dw boss5_frame_scylla_f_arm_0
	dw boss5_frame_scylla_f_arm_1
	dw boss5_frame_scylla_f_arm_2
	dw boss5_frame_scylla_f_arm_3
	dw boss5_frame_scylla_f_arm_4
	dw boss5_frame_scylla_f_arm_5
	dw boss5_frame_scylla_f_arm_6
	dw boss5_frame_scylla_f_arm_7
	dw boss5_frame_scylla_f_arm_8
	dw boss5_frame_scylla_f_arm_9
	dw boss5_frame_scylla_f_arm_10


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
		ld a, (boss__5_scylla_body_state)
		add a, a
		ld hl, update_boss5_draw_scylla_body_table
		ADD_HL_A
		ld c, (hl)
		inc hl
		ld b, (hl)
		ld ixl, c
		ld ixh, b
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
				ld a, (boss__5_top_state)
				add a, a
				ld hl, update_boss5_draw_scylla_top_table
				ADD_HL_A
				ld c, (hl)
				inc hl
				ld b, (hl)
				ld ixl, c
				ld ixh, b
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
			; back left arm:
			ld bc, 1 * 32 - 5
			add hl, bc
			ex de, hl
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
		pop hl
		push hl
			; back right arm:
			ld bc, 1 * 32 + 5
			add hl, bc
			ex de, hl
			ld a, (boss__5_scylla_arms_state + 4)
			add a, a
			ld hl, update_boss5_draw_scylla_rb_arm_table
			ADD_HL_A
			ld c, (hl)
			inc hl
			ld b, (hl)
			ld ixl, c
			ld ixh, b
			ld c, BOSS_PAGE
			ld hl, draw_boss_frame_1_without_clearing_ix
			call call_hl_in_page_c_8000
		pop hl
		push hl
			; left arm:
			ld bc, - (5 * 32 + 4)
			add hl, bc
			ex de, hl
			ld a, (boss__5_scylla_arms_state + 1)
			add a, a
			ld hl, update_boss5_draw_scylla_l_arm_table
			ADD_HL_A
			ld c, (hl)
			inc hl
			ld b, (hl)
			ld ixl, c
			ld ixh, b
			ld c, BOSS_PAGE
			ld hl, draw_boss_frame_1_without_clearing_ix
			call call_hl_in_page_c_8000
		pop hl
		push hl
			; right arm:
			ld bc, - (5 * 32 - 4)
			add hl, bc
			ex de, hl
			ld a, (boss__5_scylla_arms_state + 3)
			add a, a
			ld hl, update_boss5_draw_scylla_r_arm_table
			ADD_HL_A
			ld c, (hl)
			inc hl
			ld b, (hl)
			ld ixl, c
			ld ixh, b
			ld c, BOSS_PAGE
			ld hl, draw_boss_frame_1_without_clearing_ix
			call call_hl_in_page_c_8000
		pop hl
		push hl
			; forward arm:
			ld bc, - (4 * 32 + 5)
			add hl, bc
			ex de, hl
			ld a, (boss__5_scylla_arms_state + 2)
			add a, a
			ld hl, update_boss5_draw_scylla_f_arm_table
			ADD_HL_A
			ld c, (hl)
			inc hl
			ld b, (hl)
			ld ixl, c
			ld ixh, b
			ld c, BOSS_PAGE
			ld hl, draw_boss_frame_1_without_clearing_ix
			call call_hl_in_page_c_8000
		pop hl
	pop hl
	; bl arm: -5 left and +7 down
	; br arm: +9 in x
	; l arm: -5 left, -5 up
	; f arm: -5 left
	ld a, (boss__behavior)
	or a
	jr z, update_boss5_draw_scylla_appearing
	ld bc, - (5*32 + 5)
	add hl, bc
	ld (boss__clear_bbox_1), hl
	ld bc, #1210
	ld (boss__clear_bbox_1 + 2), bc
	ret
update_boss5_draw_scylla_appearing:
	ld bc, - (3*32 + 5)
	add hl, bc
	ld (boss__clear_bbox_1), hl
	ld bc, #1010
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

