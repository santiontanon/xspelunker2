boss5_scylla_difficulty_setting__easy:
	db 32, 16, 32  ; boss hp, vat hp, tentacle hp
	db 64, #0f, #3f, 32  ; idle time, swim speed mask, bullet-time-mask
	db #03  ; bubble firing mask
boss5_scylla_difficulty_setting__normal:
	db 48, 16, 48  ; boss hp, vat hp, tentacle hp
	db 64, #07, #1f, 28  ; idle time, swim speed mask, bullet-time-mask
	db #01  ; bubble firing mask
boss5_scylla_difficulty_setting__hard:
	db 64, 24, 64  ; boss hp, vat hp, tentacle hp
	db 64, #07, #0f, 24  ; idle time, swim speed mask, bullet-time-mask
	db #01  ; bubble firing mask
boss5_scylla_difficulty_setting__hardest:
	db 80, 32, 80  ; boss hp, vat hp, tentacle hp
	db 64, #03, #0f, 20  ; idle time, swim speed mask, bullet-time-mask
	db #01  ; bubble firing mask

BOSS_5_SCYLLA_HP_OFFSET: equ 0
BOSS_5_SCYLLA_TENTACLE_HP_OFFSET: equ 2
BOSS_5_SCYLLA_IDLE_TIME_OFFSET: equ 3
BOSS_5_SCYLLA_SWIM_MASK: equ 4
BOSS_5_SCYLLA_BULLET_TIME_MASK: equ 5
BOSS_5_SCYLLA_ATTACK_DELAY: equ 6
BOSS_5_SCYLLA_BUBBLE_MASK: equ 7


;-----------------------------------------------
; Scylla with island on top
update_boss5_behavior_4:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_4_state_0
	dec a
	jr z, update_boss5_behavior_4_state_1  ; idle
	dec a
	jp z, update_boss5_behavior_4_state_2  ; swim left
	dec a
	jp z, update_boss5_behavior_4_state_3  ; swim right
	dec a
	jp z, update_boss5_behavior_4_state_4  ; jump (waiting)
	dec a
	jp z, update_boss5_behavior_4_state_5  ; jump (going up)
	dec a
	jp z, update_boss5_behavior_4_state_6  ; jump (hit the top)
	dec a
	jp z, update_boss5_behavior_4_state_7  ; jump (going down)
	ret

update_boss5_behavior_4_state_0:
	; switch:
	; if player is on top of the island, chance of jump attack:
	ld a, (player_y + 1)
	cp 14
	jr nc, update_boss5_behavior_4_state_0_no_jump
	ld a, (player_x + 1)
	ld c, a
	ld a, (boss__x)
	dec a
	cp c
	jr nc, update_boss5_behavior_4_state_0_no_jump
	add a, 9
	cp c
	jr c, update_boss5_behavior_4_state_0_no_jump
	; player is on top of the island, chance of jumping
	call random_a
	and #01
	jr z, update_boss5_behavior_4_state_0_no_jump
	ld a, 4
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	jr update_boss5_behavior_4
update_boss5_behavior_4_state_0_no_jump:
	ld c, 3
	call random_modulo
	inc a
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	jr update_boss5_behavior_4

update_boss5_behavior_4_state_1:
	; idle:
	ld a, (boss__5_settings + BOSS_5_SCYLLA_IDLE_TIME_OFFSET)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp c
	jr nz, update_boss5_behavior_4_state_1_entry_point
update_boss5_behavior_4_state_1_done:
	xor a
	ld (boss__state), a
	ret
update_boss5_behavior_4_state_1_entry_point:
	xor a
	ld (boss__5_needs_redraw), a
update_boss5_behavior_4_state_1_entry_point2:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_control_forward_arm
	call update_boss5_scylla_maybe_fire_eye_bullet

	; blink/mouth:
	ld a, (boss__state_timer)
	and #0f
	jr nz, update_boss5_behavior_4_state_1_continue
	ld a, (boss__5_scylla_body_state)
	cp 2  ; mouth open already?
	jr z, update_boss5_behavior_4_state_1_ignore_mouth  ; if mouth was open, we will close it next time, so, just ignore
	; chance of opening the mouth
	ld a, (boss__5_settings + BOSS_5_SCYLLA_BUBBLE_MASK)
	ld c, a
	call random_a
	and c
	jr nz, update_boss5_behavior_4_state_1_ignore_mouth
	; open mouth
	call update_boss5_scylla_fire_mouth_bubbles
	ld c, 2
	jr update_boss5_behavior_4_state_1_eyes_open
update_boss5_behavior_4_state_1_ignore_mouth:
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


update_boss5_behavior_4_state_2:
	; swim left:
	ld a, (boss__5_settings + BOSS_5_SCYLLA_SWIM_MASK)	
	ld c, a
	add a, a
	add a, a
	ld b, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp b
	jp z, update_boss5_behavior_4_state_1_done
	and c
	jp nz, update_boss5_behavior_4_state_1_entry_point
	ld a, (boss__x)
	cp 5  ; minimum x coordinate
	jp z, update_boss5_behavior_4_state_1_done
	dec a
	ld (boss__x), a
	call update_boss5_draw_scylla
	call boss5_maybe_push_player_left
	jp update_boss5_behavior_4_state_1_entry_point2  ; the rest of behavior is like "idle"


update_boss5_behavior_4_state_3:
	; swim right:
	ld a, (boss__5_settings + BOSS_5_SCYLLA_SWIM_MASK)	
	ld c, a
	add a, a
	add a, a
	ld b, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp b
	jp z, update_boss5_behavior_4_state_1_done
	and c
	jp nz, update_boss5_behavior_4_state_1_entry_point
	ld a, (boss__x)
	cp 21  ; maximum x coordinate
	jp z, update_boss5_behavior_4_state_1_done
	inc a
	ld (boss__x), a
	call update_boss5_draw_scylla
	call boss5_maybe_push_player_right
	jp update_boss5_behavior_4_state_1_entry_point2  ; the rest of behavior is like "idle"


update_boss5_behavior_4_state_4:
	ld a, (boss__5_settings + BOSS_5_SCYLLA_ATTACK_DELAY)
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

update_boss5_behavior_4_state_5:
	; jump:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and #03
	ret nz
	; stretch the arms:
	; arms should go to positions:
	; - 3, 5, 5, 0, 0
	ld hl, boss__5_scylla_arms_state
	ld a, (hl)
	cp 3
	jr z, update_boss5_behavior_4_state_5_lb_arm_ok
	inc (hl)
update_boss5_behavior_4_state_5_lb_arm_ok:
	inc hl
	ld a, (hl)
	cp 5
	jr z, update_boss5_behavior_4_state_5_l_arm_ok
	inc (hl)
update_boss5_behavior_4_state_5_l_arm_ok:
	inc hl
	ld a, (hl)
	cp 5
	jr z, update_boss5_behavior_4_state_5_f_arm_ok
	jr c, update_boss5_behavior_4_state_5_f_arm_left
	dec (hl)
	jr update_boss5_behavior_4_state_5_f_arm_ok
update_boss5_behavior_4_state_5_f_arm_left:
	inc (hl)
update_boss5_behavior_4_state_5_f_arm_ok:
	inc hl
	ld a, (hl)
	or a
	jr z, update_boss5_behavior_4_state_5_r_arm_ok
	dec (hl)
update_boss5_behavior_4_state_5_r_arm_ok:
	inc hl
	ld a, (hl)
	or a
	jr z, update_boss5_behavior_4_state_5_rb_arm_ok
	dec (hl)
update_boss5_behavior_4_state_5_rb_arm_ok:

	ld a, (boss__5_top_state)
	ld c, 7  ; max height with island 0
	or a
	jr z, update_boss5_behavior_4_state_5_limit_set
	ld c, 4
update_boss5_behavior_4_state_5_limit_set:
	ld hl, boss__y
	ld a, (hl)
	cp c  ; max height of the jump
	jr z, update_boss5_behavior_4_state_5_done
	dec (hl)
	call update_boss5_draw_scylla
	jp boss5_maybe_push_player_up
update_boss5_behavior_4_state_5_done:
	xor a
	ld (boss__state_timer), a
	ld a, 6
	ld (boss__state), a
	ld hl, SFX_explosion_low_pitch
	jp play_SFX_with_high_priority


update_boss5_behavior_4_state_6:
	; jump hit the ceiling:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp 16
	jr nz, update_boss5_behavior_4_state_6_continue
	xor a
	ld (boss__state_timer), a
	ld a, 7
	ld (boss__state), a
	ret
update_boss5_behavior_4_state_6_continue:
	or a
	jr nz, update_boss5_behavior_4_state_6_continue2
	; first cycle, change the island type:
	push af
		ld hl, boss__5_top_state
		ld a, (hl)
		or a
		jr z, update_boss5_behavior_4_state_6_first_jump
		dec a
		jr z, update_boss5_behavior_4_state_6_second_jump
update_boss5_behavior_4_state_6_third_jump
		; switch to scylla2 tileset, and to behavior 5 as soon as boss lands
		ld (hl), 3  ; vat
		; minimize the transition glitch:
		halt
		call update_boss5_draw_scylla
		ld hl, draw_room_with_hud
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
		ld hl, boss_5_tiles_scylla2_zx0
		ld (current_room__tileset_ptr), hl
		ld a, BOSS_5_PAGE
		ld (current_room__tileset_page), a
		ld c, BOSS_5_PAGE
		call setup_game_tiles_only_biome

		; update the collision table:
		ld hl, tile_collision_types_boss5
		ld (current_room__collision_ptr), hl
		ld a, (current_room__collision_ptr_page)
		ld de, current_room__collision_table
		ld bc, 256
		call ldir_from_page_a

		jr update_boss5_behavior_4_state_6_jump_effect_set
update_boss5_behavior_4_state_6_second_jump:
		ld (hl), 2  ; crack the island
		jr update_boss5_behavior_4_state_6_jump_effect_set
update_boss5_behavior_4_state_6_first_jump:
		ld (hl), 1  ; remove poseidon statue
update_boss5_behavior_4_state_6_jump_effect_set:
		call update_boss5_draw_scylla
	pop af
update_boss5_behavior_4_state_6_continue2:
	and #03
	ret nz

	; spawn an explosion:
	ld c, 5
	call random_modulo
	ld c, a
	ld a, (boss__x)
	add a, c
	ld c, a
	call random_a
	and #01
	inc a
	ld b, a
	jp spawn_explosion

update_boss5_behavior_4_state_7:
	; fall back down:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and #07
	ret nz
	ld hl, boss__y
	ld a, (hl)
	cp 15  ; landing position
	jr z, update_boss5_behavior_4_state_7_done
	inc (hl)
	jp update_boss5_draw_scylla
update_boss5_behavior_4_state_7_done:
	inc (hl)
	ld (boss__state_timer), a
	ld a, 0
	ld (boss__state), a	
	ld hl, SFX_watersplash_soft
	call play_SFX_with_high_priority
	call update_boss5_draw_scylla
	ld a, (boss__5_top_state)
	cp 3  ; vat
	ret nz
	; if the boss is showing the "vat", switch to behavior 5
	ld a, 5
	ld (boss__behavior), a
	ret


;-----------------------------------------------
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


;-----------------------------------------------
update_boss5_scylla_control_left_arm:
	ld hl, boss__5_scylla_arms_inertia + 0
	ld de, boss__5_scylla_arms_state + 1
	ld c, 6
	jr update_boss5_scylla_control_arm_generic


;-----------------------------------------------
update_boss5_scylla_control_right_arm:
	ld hl, boss__5_scylla_arms_inertia + 2
	ld de, boss__5_scylla_arms_state + 3
	ld c, 6
	jr update_boss5_scylla_control_arm_generic


;-----------------------------------------------
update_boss5_scylla_control_forward_arm:
	ld hl, boss__5_scylla_arms_inertia + 1
	ld de, boss__5_scylla_arms_state + 2
	ld c, 11


;-----------------------------------------------
; input:
; - hl: ptr to inertia
; - de: ptr to arm state
; - c: limit
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


;-----------------------------------------------
; input:
; - a: desired arm position
; - c: limit
; output:
; - a: arm position within the limt 
update_boss5_scylla_arm_state_limit:
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
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_5_state_0
	dec a
	jp z, update_boss5_behavior_4_state_1  ; idle
	dec a
	jp z, update_boss5_behavior_4_state_2  ; swim left
	dec a
	jp z, update_boss5_behavior_4_state_3  ; swim right
	; ...
	ret

update_boss5_behavior_5_state_0:
	; switch:
	ld c, 3
	call random_modulo
	inc a
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	jr update_boss5_behavior_5


;-----------------------------------------------
; Scylla dying
update_boss5_behavior_6:
	; ...
	ret


;-----------------------------------------------
update_boss5_scylla_maybe_fire_eye_bullet:
	ld a, (boss__5_scylla_body_state)
	cp 1
	ret z  ; no firing when eyes are closed
	ld a, (boss__5_settings + BOSS_5_SCYLLA_BULLET_TIME_MASK)
	ld c, a
	call random_a
	and c
	ret nz
	ld bc, (boss__x)
	inc b
	ld e, c  ; left eye
	call random_a
	and #01
	jr z, update_boss5_scylla_maybe_fire_eye_bullet_left_eye
	inc e
	inc e
	inc e
	inc e
update_boss5_scylla_maybe_fire_eye_bullet_left_eye:
	ld ix, #0004
	; - c, b: tile coordinate from where the bullet is fired
	; - ixl, ixh: pixel offset	
	ld hl, boss_fire_directional_bullet_towards_player_e_b
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
	ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BULLET_IGNORING_WALLS
	ret


;-----------------------------------------------
update_boss5_scylla_fire_mouth_bubbles:
	; fire two bubbles
	call update_boss5_scylla_fire_mouth_bubble
update_boss5_scylla_fire_mouth_bubble:
	ld bc, (boss__x)
	inc b
	inc b
	inc b
	inc b
	inc c
	; - c, b: tile coordinate from where the bullet is fired
	push bc
		call ptr_to_new_sprite_enemy
	pop bc
	ret nz
	ld (hl), 0
	inc hl
	ld (hl), ENEMY_BULLET_BUBBLE
	inc hl
	ld (hl), 4  ; pixel x
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0  ; pixel y
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld c, 5
	call random_modulo
	sub 2
	ld (hl), a  ; x speed
	inc hl
	ld (hl), 0  ; state timer
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
		ld a, (boss__5_scylla_arms_hp)
		or a
		jr z, update_boss5_draw_scylla_left_arm_done
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
update_boss5_draw_scylla_left_arm_done:
		ld a, (boss__5_scylla_arms_hp + 2)
		or a
		jr z, update_boss5_draw_scylla_right_arm_done
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
update_boss5_draw_scylla_right_arm_done:
		ld a, (boss__5_scylla_arms_hp + 1)
		or a
		jr z, update_boss5_draw_scylla_front_arm_done
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
update_boss5_draw_scylla_front_arm_done:
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
	ld bc, #1310
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
; - ix: ptr of the tile we hit
player_weapon_hitbox_check_boss__boss5_scylla_hit:
	ld a, (boss__behavior)
	cp 6
	ret z

	ld a, e
	cp 14*16+5  ; first brain/vat tile
	jr c, player_weapon_hitbox_check_boss__boss5_scylla_hit_not_brain
	ld a, (boss__5_top_state)
	cp 3
	jp c, player_weapon_hitbox_check_boss__boss5_hit_shield
	; hit the brain/vat:
	ld hl, player_weapon_hitbox_check_boss__lose_hp
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000	
	ld hl, (boss__hp)
	ld a, h
	or l
	ret nz
	; HP reached 0:
	ld a, (boss__5_top_state)
	cp 3
	jr z, player_weapon_hitbox_check_boss__boss5_scylla_hit_break_vat
	; boss is dead:
	ld a, 6
	ld (boss__behavior), a
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret
player_weapon_hitbox_check_boss__boss5_scylla_hit_break_vat:
	inc a
	ld (boss__5_top_state), a
	ld a, (boss__5_settings + BOSS_5_SCYLLA_HP_OFFSET)  ; brain HP
	ld h, 0
	ld l, a
	ld (boss__hp), hl
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	call update_boss5_draw_scylla
	ld bc, (boss__x)
	dec b
	dec b
	dec b
	inc a
	add a, c
	ld c, a
	call spawn_big_explosion
	ld hl, SFX_explosion_low_pitch
	jp play_SFX_with_high_priority

player_weapon_hitbox_check_boss__boss5_scylla_hit_not_brain:
	; check if a tentacle was hit:
	; - ix: ptr of the tile we hit
	push ix
	pop hl
	ld bc, current_room__tile_map
	or a
	sbc hl, bc
	; - obtain screen coordinates (in (e, d):
	ld a, l
	and #1f
	ld e, a  ; x coordinate
	add hl, hl
	add hl, hl
	add hl, hl
	ld d, h  ; y coordinate
	; here (e, d) has the coordinates of the tile that was hit

	; left tentacle: drawn at (-4, -5) from the main body
	push de
		ld a, (boss__x)
		add a, -4
		sub e
		neg
		ld e, a  ; coordinate relative to this tentacle
		ld a, (boss__y)
		add a, -5
		sub d
		neg
		ld d, a  ; coordinate relative to this tentacle
		ld a, (boss__5_scylla_arms_state + 1)
		ld hl, update_boss5_draw_scylla_l_arm_table
		add a, a
		ADD_HL_A
		ld a, (hl)
		ld ixl, a
		inc hl
		ld a, (hl)
		ld ixh, a  ; ix: ptr to the name table 
		ld hl, player_weapon_hitbox_check_boss__boss5_scylla_hit_tentacle
		ld c, BOSS_PAGE
		call call_hl_in_page_c_8000
	pop de
	jr z, player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit

	; front tentacle:
	push de
		ld a, (boss__x)
		add a, -5
		sub e
		neg
		ld e, a  ; coordinate relative to this tentacle
		ld a, (boss__y)
		add a, -4
		sub d
		neg
		ld d, a  ; coordinate relative to this tentacle
		ld a, (boss__5_scylla_arms_state + 2)
		ld hl, update_boss5_draw_scylla_f_arm_table
		add a, a
		ADD_HL_A
		ld a, (hl)
		ld ixl, a
		inc hl
		ld a, (hl)
		ld ixh, a  ; ix: ptr to the name table 
		ld hl, player_weapon_hitbox_check_boss__boss5_scylla_hit_tentacle
		ld c, BOSS_PAGE
		call call_hl_in_page_c_8000
	pop de
	jp z, player_weapon_hitbox_check_boss__boss5_scylla_hit__front_tentacle_hit

	; right tentacle:
	ld a, (boss__x)
	add a, 4
	sub e
	neg
	ld e, a  ; coordinate relative to this tentacle
	ld a, (boss__y)
	add a, -5
	sub d
	neg
	ld d, a  ; coordinate relative to this tentacle
	ld a, (boss__5_scylla_arms_state + 3)
	ld hl, update_boss5_draw_scylla_r_arm_table
	add a, a
	ADD_HL_A
	ld a, (hl)
	ld ixl, a
	inc hl
	ld a, (hl)
	ld ixh, a  ; ix: ptr to the name table 
	ld hl, player_weapon_hitbox_check_boss__boss5_scylla_hit_tentacle
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
	jr z, player_weapon_hitbox_check_boss__boss5_scylla_hit__right_tentacle_hit
	jp player_weapon_hitbox_check_boss__boss5_hit_shield

player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit:
	ld hl, boss__5_scylla_arms_hp
	ld a, (hl)
	or a
	jp z, player_weapon_hitbox_check_boss__boss5_hit_shield  ; arm already destroyed
	dec (hl)
	ld a, (hl)
	or a
	jr nz, player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_entry_point
	; arm destroyed!
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	call update_boss5_draw_scylla
	ld bc, (boss__x)
	inc b
	inc b
	call spawn_big_explosion
	ld hl, SFX_explosion_low_pitch
	call play_SFX_with_high_priority
	jr player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_entry_point2
player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_entry_point:
	ld hl, SFX_enemy_hit
	call play_SFX_with_high_priority
player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_entry_point2:
	xor a
	ld (player_weapon_hitbox_check_result), a  ; mark a hit
	ld a, iyl
	ld (boss__last_collision_id), a
	ret

player_weapon_hitbox_check_boss__boss5_scylla_hit__right_tentacle_hit:
	ld hl, boss__5_scylla_arms_hp + 2
	ld a, (hl)
	or a
	jp z, player_weapon_hitbox_check_boss__boss5_hit_shield  ; arm already destroyed
	dec (hl)
	ld a, (hl)
	or a
	jr nz, player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_entry_point
	; arm destroyed!
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	call update_boss5_draw_scylla
	ld bc, (boss__x)
	inc b
	inc b
	inc c
	inc c
	call spawn_big_explosion
	ld hl, SFX_explosion_low_pitch
	call play_SFX_with_high_priority
	jp player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_entry_point2

player_weapon_hitbox_check_boss__boss5_scylla_hit__front_tentacle_hit:
	ld hl, boss__5_scylla_arms_hp + 1
	ld a, (hl)
	or a
	jp z, player_weapon_hitbox_check_boss__boss5_hit_shield  ; arm already destroyed
	dec (hl)
	ld a, (hl)
	or a
	jr nz, player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_entry_point
	; arm destroyed!
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	call update_boss5_draw_scylla
	ld bc, (boss__x)
	inc b
	inc b
	inc c
	call spawn_big_explosion
	ld hl, SFX_explosion_low_pitch
	call play_SFX_with_high_priority
	jp player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_entry_point2

