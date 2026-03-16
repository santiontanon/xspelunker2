boss5_charybdis_difficulty_setting__easy:
	dw 32  ; boss hp
	db 64, #0f, #1f, 32  ; idle time, walk mask, bullet-time-mask, attack-delay
boss5_charybdis_difficulty_setting__normal:
	dw 48  ; boss hp
	db 64, #07, #1f, 28  ; idle time, walk mask, bullet-time-mask, attack-delay
boss5_charybdis_difficulty_setting__hard:
	dw 64  ; boss hp
	db 64, #07, #0f, 24  ; idle time, walk mask, bullet-time-mask, attack-delay
boss5_charybdis_difficulty_setting__hardest:
	dw 80  ; boss hp
	db 64, #03, #0f, 20  ; idle time, walk mask, bullet-time-mask, attack-delay

BOSS_5_CHARYBDIS_HP_OFFSET: equ 0
BOSS_5_CHARYBDIS_IDLE_TIME_OFFSET: equ 2
BOSS_5_CHARYBDIS_WALK_MASK: equ 3
BOSS_5_CHARYBDIS_BULLET_TIME_MASK: equ 4
BOSS_5_CHARYBDIS_ATTACK_DELAY: equ 5


;-----------------------------------------------
update_boss5_behavior_1:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_1_state_0
	dec a
	jr z, update_boss5_behavior_1_state_1  ; idle
	dec a
	jp z, update_boss5_behavior_1_state_2  ; left
	dec a
	jp z, update_boss5_behavior_1_state_3  ; right
	dec a
	jp z, update_boss5_behavior_1_state_4  ; jump (waiting)
	dec a
	jp z, update_boss5_behavior_1_state_5  ; jump (going up)
	dec a
	jp z, update_boss5_behavior_1_state_6  ; jump (hit the top)
	dec a
	jp z, update_boss5_behavior_1_state_7  ; jump (going down)
	; ...
	ret

update_boss5_behavior_1_state_0:
	; switch:
	; if player is on top of the island, chance of jump attack:
	ld a, (player_y + 1)
	cp 14
	jr nc, update_boss5_behavior_1_state_0_no_jump
	ld a, (player_x + 1)
	ld c, a
	ld a, (boss__x)
	add a, 3
	cp c
	jr nc, update_boss5_behavior_1_state_0_no_jump
	add a, 9
	cp c
	jr c, update_boss5_behavior_1_state_0_no_jump
	; player is on top of the island, chance of jumping
	call random_a
	and #01
	jr z, update_boss5_behavior_1_state_0_no_jump
	ld a, 4
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	jr update_boss5_behavior_1
update_boss5_behavior_1_state_0_no_jump:
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

	ld a, (boss__state_timer)
	and #03
	jr nz, update_boss5_behavior_1_state_1_no_claw_movement
	call random_a
	and #03
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

	call update_boss5_charybdis_maybe_fire_eye_bullet
	ld a, (boss__5_needs_redraw)
	or a
	ret z
	jp update_boss5_draw_charybdis

update_boss5_behavior_1_state_2:
	; walk left:
	call update_boss5_charybdis_maybe_fire_eye_bullet

	ld a, (boss__5_settings + BOSS_5_CHARYBDIS_WALK_MASK)
	ld c, a
	inc a
	add a, a
	add a, c
	inc a
	ld b, a  ; end of step time (mask + 1) * 3
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp b
	jp z, update_boss5_behavior_1_state_0
	and c
	ret nz
	ld hl, boss__x
	ld a, (hl)
	cp 2  ; minimum boss x
	jr z, update_boss5_behavior_1_state_2_change_direction
update_boss5_behavior_1_state_2_step:
	dec (hl)
	ld hl, boss__5_charybdis_leg_state
	ld a, (hl)
	dec a
	cp #ff
	jr nz, update_boss5_behavior_1_state_2_continue
	ld a, 2
update_boss5_behavior_1_state_2_continue:
	ld (hl), a
	call update_boss5_draw_charybdis
	jp boss5_maybe_push_player_left
update_boss5_behavior_1_state_2_change_direction:
	ld a, 3
	ld (boss__state), a
	jr update_boss5_behavior_1_state_3_step


update_boss5_behavior_1_state_3:
	; walk right:
	call update_boss5_charybdis_maybe_fire_eye_bullet

	ld a, (boss__5_settings + BOSS_5_CHARYBDIS_WALK_MASK)
	ld c, a
	inc a
	add a, a
	add a, c
	inc a
	ld b, a  ; end of step time (mask + 1) * 3
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp b
	jp z, update_boss5_behavior_1_state_0
	and c
	ret nz
	ld hl, boss__x
	ld a, (hl)
	cp 14  ; maximum boss x
	jr z, update_boss5_behavior_1_state_3_change_direction
update_boss5_behavior_1_state_3_step:
	inc (hl)
	ld hl, boss__5_charybdis_leg_state
	ld a, (hl)
	inc a
	cp 3
	jr nz, update_boss5_behavior_1_state_3_continue
	xor a
update_boss5_behavior_1_state_3_continue:
	ld (hl), a
	call update_boss5_draw_charybdis
	jp boss5_maybe_push_player_right
update_boss5_behavior_1_state_3_change_direction:
	ld a, 2
	ld (boss__state), a
	jr update_boss5_behavior_1_state_2_step


update_boss5_behavior_1_state_4:
	ld a, (boss__5_settings + BOSS_5_CHARYBDIS_ATTACK_DELAY)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp c
	ret nz
	ld (hl), 0
	ld a, 5
	ld (boss__state), a
	ret

update_boss5_behavior_1_state_5:
	; jump:
	ld a, 3
	ld (boss__5_charybdis_leg_state), a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and #03
	ret nz
	ld hl, boss__y
	ld a, (hl)
	cp 7  ; max height of the jump
	jr z, update_boss5_behavior_1_state_5_done
	dec (hl)
	call update_boss5_draw_charybdis
	jp boss5_maybe_push_player_up
update_boss5_behavior_1_state_5_done:
	xor a
	ld (boss__state_timer), a
	ld a, 6
	ld (boss__state), a
	ld hl, SFX_explosion_low_pitch
	jp play_SFX_with_high_priority


update_boss5_behavior_1_state_6:
	; jump hit the ceiling:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp 16
	jr nz, update_boss5_behavior_1_state_6_continue
	xor a
	ld (boss__state_timer), a
	ld a, 7
	ld (boss__state), a
	ret
update_boss5_behavior_1_state_6_continue:
	or a
	jr nz, update_boss5_behavior_1_state_6_continue2
	; first cycle, change the island type:
	push af
		ld hl, boss__5_top_state
		ld (hl), 1  ; remove poseidon statue
		call update_boss5_draw_charybdis
	pop af
update_boss5_behavior_1_state_6_continue2:
	and #03
	ret nz

	; spawn an explosion:
	ld c, 3
	call random_modulo
	ld c, a
	ld a, (boss__x)
	add a, c
	add a, 6
	ld c, a
	call random_a
	and #01
	inc a
	ld b, a
	jp spawn_explosion

update_boss5_behavior_1_state_7:
	; fall back down:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and #07
	ret nz
	ld hl, boss__y
	ld a, (hl)
	cp 15  ; landing position
	jr z, update_boss5_behavior_1_state_7_done
	inc (hl)
	jp update_boss5_draw_charybdis
update_boss5_behavior_1_state_7_done:
	inc (hl)
	xor a
	ld (boss__5_charybdis_leg_state), a
	ld (boss__state_timer), a
	ld a, 0
	ld (boss__state), a
	ld hl, SFX_watersplash_soft
	call play_SFX_with_high_priority
	jp update_boss5_draw_charybdis


;-----------------------------------------------
; 0, 1, 2: walk, 3: jump
update_boss5_draw_charybdis_body_table:
	dw boss5_frame_charybdis_body_0
	dw boss5_frame_charybdis_body_1
	dw boss5_frame_charybdis_body_2
	dw boss5_frame_charybdis_body_jump

; 0: base, 1: closed, 2: rising, 3: up, 4: stump base, 5: stump: rising, 6: stump up
update_boss5_draw_charybdis_left_claw_table:
	dw boss5_frame_left_claw1
	dw boss5_frame_left_claw2
	; ...

; 0: base, 1: closed, 2: rising, 3: up, 4: stump base, 5: stump: rising, 6: stump up
update_boss5_draw_charybdis_right_claw_table:
	dw boss5_frame_right_claw1
	dw boss5_frame_right_claw2
	; ...

update_boss5_draw_charybdis_top_table
	dw boss5_frame_island_0
	dw boss5_frame_island_1
	dw boss5_frame_island_2
	dw boss5_frame_charybdis_vat
	dw boss5_frame_charybdis_brain


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
		ld a, (boss__5_charybdis_leg_state)
		add a, a
		ld hl, update_boss5_draw_charybdis_body_table
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
; 	ld (boss__clear_bbox_1), hl
; 	ld bc, #0510
; 	ld (boss__clear_bbox_1 + 2), bc

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
			ld a, (boss__5_charybdis_left_claw_state)
			add a, a
			ld hl, update_boss5_draw_charybdis_left_claw_table
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
		ld bc, 6
		add hl, bc
		ex de, hl
		ld a, (boss__5_charybdis_right_claw_state)
		add a, a
		ld hl, update_boss5_draw_charybdis_right_claw_table
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

	; draw top (island / vat / brain):
	ld bc, 4 - 32 * 6
	add hl, bc
	push hl
		ex de, hl
		ld a, (boss__5_top_state)
		add a, a
		ld hl, update_boss5_draw_charybdis_top_table
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

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	ret


;-----------------------------------------------
update_boss5_charybdis_maybe_fire_eye_bullet:
	ld a, (boss__5_settings + BOSS_5_CHARYBDIS_BULLET_TIME_MASK)
	ld c, a
	call random_a
	and c
	ret nz
	ld bc, (boss__x)
	inc b
	ld a, 5
	add a, c
	ld e, a  ; left eye
	call random_a
	and #01
	jr z, update_boss5_charybdis_maybe_fire_eye_bullet_left_eye
	inc e
	inc e
	inc e
update_boss5_charybdis_maybe_fire_eye_bullet_left_eye:
	ld ix, #0004
	; - c, b: tile coordinate from where the bullet is fired
	; - ixl, ixh: pixel offset	
	ld hl, boss_fire_directional_bullet_towards_player_e_b
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
	ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BULLET_IGNORING_WALLS
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
