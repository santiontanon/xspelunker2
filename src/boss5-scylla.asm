;-----------------------------------------------
BOSS_5_SCYLLA_THREAD_V_TILE: equ 211
BOSS_5_SCYLLA_THREAD_V_TILE_START: equ 217
BOSS_5_SCYLLA_THREAD_V_WIDE_TILE_START: equ 218
BOSS_5_SCYLLA_THREAD_H_TILE: equ 213
BOSS_5_SCYLLA_THREAD_L_HINGE: equ 223
BOSS_5_SCYLLA_THREAD_R_HINGE: equ 212


;-----------------------------------------------
boss5_scylla_difficulty_setting__easy:
	db 48, 24, 40  ; boss hp, vat hp, tentacle hp
	db 64, #0f, BOSS_BULLET_PATTERN_EASY1, 32  ; idle time, swim speed mask, bullet pattern
	db #03, #03  ; bubble firing mask, dettached arm attack mask
boss5_scylla_difficulty_setting__normal:
	db 64, 32, 64  ; boss hp, vat hp, tentacle hp
	db 64, #07, BOSS_BULLET_PATTERN_MEDIUM1, 28  ; idle time, swim speed mask, bullet pattern
	db #01, #01  ; bubble firing mask, dettached arm attack mask
boss5_scylla_difficulty_setting__hard:
	db 80, 40, 80  ; boss hp, vat hp, tentacle hp
	db 64, #07, BOSS_BULLET_PATTERN_HARD1, 24  ; idle time, swim speed mask, bullet pattern
	db #01, #01  ; bubble firing mask, dettached arm attack mask
boss5_scylla_difficulty_setting__hardest:
	db 96, 48, 96  ; boss hp, vat hp, tentacle hp
	db 64, #03, BOSS_BULLET_PATTERN_HARDEST1, 20  ; idle time, swim speed mask, bullet pattern
	db #01, #00  ; bubble firing mask, dettached arm attack mask

BOSS_5_SCYLLA_HP_OFFSET: equ 0
BOSS_5_SCYLLA_TENTACLE_HP_OFFSET: equ 2
BOSS_5_SCYLLA_IDLE_TIME_OFFSET: equ 3
BOSS_5_SCYLLA_SWIM_MASK: equ 4
BOSS_5_SCYLLA_BULLET_ATTACK_PATTERN_OFFSET: equ 5
BOSS_5_SCYLLA_ATTACK_DELAY: equ 6
BOSS_5_SCYLLA_BUBBLE_MASK: equ 7
BOSS_5_SCYLLA_DETTACHED_SPEED_MASK: equ 8


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
	ld a, (boss__settings + BOSS_5_SCYLLA_IDLE_TIME_OFFSET)
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
update_boss5_behavior_4_state_1_entry_point2:  ; arm control and firing
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_control_forward_arm
update_boss5_behavior_4_state_1_entry_point3:  ; firing
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control

	ld a, (boss__5_needs_redraw)
	or a
	ret z
	jp update_boss5_draw_scylla


update_boss5_behavior_4_state_2:
	; swim left:
	ld a, (boss__settings + BOSS_5_SCYLLA_SWIM_MASK)	
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
	ld a, (boss__settings + BOSS_5_SCYLLA_SWIM_MASK)	
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
	ld a, (boss__settings + BOSS_5_SCYLLA_ATTACK_DELAY)
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
	ret c
	; if the boss is showing the "vat", switch to behavior 5
	ld a, 5
	ld (boss__behavior), a
	ret


;-----------------------------------------------
update_boss5_scylla_eye_mouth_control:
	; blink/mouth:
	ld a, (boss__state_timer)
	and #0f
	ret nz
	ld a, (boss__5_scylla_body_state)
	cp 2  ; mouth open already?
	jr z, update_boss5_scylla_eye_mouth_control_ignore_mouth  ; if mouth was open, we will close it next time, so, just ignore
	; chance of opening the mouth
	ld a, (boss__settings + BOSS_5_SCYLLA_BUBBLE_MASK)
	ld c, a
	call random_a
	and c
	jr nz, update_boss5_scylla_eye_mouth_control_ignore_mouth
	; open mouth
	call update_boss5_scylla_fire_mouth_bubbles
	ld c, 2
	jr update_boss5_scylla_eye_mouth_control_eyes_open
update_boss5_scylla_eye_mouth_control_ignore_mouth:
	call random_a
	and #03
	ld c, 0
	jr nz, update_boss5_scylla_eye_mouth_control_eyes_open
	inc c
update_boss5_scylla_eye_mouth_control_eyes_open:
	ld a, (boss__5_scylla_body_state)
	cp c
	ret z
	ld a, c
	ld (boss__5_scylla_body_state), a
	ld a, 1
	ld (boss__5_needs_redraw), a
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
	jp z, update_boss5_behavior_5_state_1  ; idle
	dec a
	jp z, update_boss5_behavior_5_state_2  ; swim left
	dec a
	jp z, update_boss5_behavior_5_state_3  ; swim right

	; vertical dettachable tip attack:
	dec a
	jp z, update_boss5_behavior_5_state_4  ; left-arm vertical attack rising
	dec a
	jp z, update_boss5_behavior_5_state_5  ; left-arm vertical attack lowering
	dec a
	jp z, update_boss5_behavior_5_state_6  ; front-arm vertical attack rising
	dec a
	jp z, update_boss5_behavior_5_state_7  ; front-arm vertical attack lowering
	dec a
	jp z, update_boss5_behavior_5_state_8  ; right-arm vertical attack rising
	dec a
	jp z, update_boss5_behavior_5_state_9  ; right-arm vertical attack lowering

	; horizontal dettachable tip attack:
	dec a
	jp z, update_boss5_behavior_5_state_10  ; front-arm left attack rising
	dec a
	jp z, update_boss5_behavior_5_state_11  ; front-arm left attack advancing horizontally
	dec a
	jp z, update_boss5_behavior_5_state_12  ; front-arm left attack reeling-back horizontally
	dec a
	jp z, update_boss5_behavior_5_state_13  ; front-arm left attack lowering
	dec a
	jp z, update_boss5_behavior_5_state_14  ; front-arm right attack rising
	dec a
	jp z, update_boss5_behavior_5_state_15  ; front-arm right attack advancing horizontally
	dec a
	jp z, update_boss5_behavior_5_state_16  ; front-arm right attack reeling-back horizontally
	dec a
	jp z, update_boss5_behavior_5_state_17  ; front-arm right attack lowering
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

update_boss5_behavior_5_state_1:
	call update_boss5_behavior_4_state_1
update_boss5_behavior_5_state_1_check_arm_attack:
	ld a, (player_y + 1)
	cp 14
	ret nc  ; player is too low in the screen

	; check for left-arm vertical attack:
	ld a, (boss__5_scylla_arms_hp)  ; left arm
	or a
	jr z, update_boss5_behavior_5_state_1_check_arm_attack_not_left
	ld a, (boss__5_scylla_arms_state + 1)  ; left arm
	or a  ; most rised position
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_not_left
	; left-arm is in position:
	ld a, (boss__x)
	sub a, 3
	ld c, a
	ld a, (player_x + 1)
	cp c
	jr c, update_boss5_behavior_5_state_1_check_arm_attack_not_left
	add a, -5
	cp c
	jr nc, update_boss5_behavior_5_state_1_check_arm_attack_not_left
	; player is in position, chance of attacking:
	call random_a
	and #0f
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_not_left
	; left arm vertical attack!!!
	ld a, 4
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_5_state_1_check_arm_attack_not_left:

	; Check for front-arm vertical or horizontal attack:
	ld a, (boss__5_scylla_arms_hp + 1)  ; front arm
	or a
	jr z, update_boss5_behavior_5_state_1_check_arm_attack_not_front
	ld a, (boss__5_scylla_arms_state + 2)  ; front arm
	or a  ; most rised position left
	jr z, update_boss5_behavior_5_state_1_check_arm_attack_maybe_front
	cp 10  ; most rised position right
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_not_front
update_boss5_behavior_5_state_1_check_arm_attack_maybe_front:
	; front-arm is in position:
	ld a, (boss__x)
	add a, -3
	ld c, a
	ld a, (player_x + 1)
	cp c
	jr c, update_boss5_behavior_5_state_1_check_arm_attack_not_front_up
	add a, -12
	cp c
	jr nc, update_boss5_behavior_5_state_1_check_arm_attack_not_front_up
	; player is in position, chance of attacking:
	call random_a
	and #1f  ; lower chance for the front arm, as it has a wide area
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_not_front
	; front arm vertical attack!!!
	ld a, 6
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_5_state_1_check_arm_attack_not_front_up:
	; check for a horizontal attack:
	ld a, (boss__5_scylla_arms_state + 2)  ; front arm
	or a
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_maybe_right
	; check if player is sufficiently to the left:
	ld a, (boss__x)
	cp 9
	jr c, update_boss5_behavior_5_state_1_check_arm_attack_not_front  ; boss is too to the left
	ld c, a
	ld a, (player_x + 1)
	cp c
	jr nc, update_boss5_behavior_5_state_1_check_arm_attack_not_front  ; player is not on the left
	; player is in position, chance of attacking:
	call random_a
	and #3f
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_not_front
	; front arm horizontal-left attack!!!
	ld a, 10
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_5_state_1_check_arm_attack_maybe_right:
	; check if player is sufficiently to the right:
	ld a, (boss__x)
	cp 17
	jr nc, update_boss5_behavior_5_state_1_check_arm_attack_not_front  ; boss is too to the right
	ld c, a
	ld a, (player_x + 1)
	cp c
	jr c, update_boss5_behavior_5_state_1_check_arm_attack_not_front  ; player is not on the left
	; player is in position, chance of attacking:
	call random_a
	and #3f
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_not_front
	; front arm horizontal-right attack!!!
	ld a, 14
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret

update_boss5_behavior_5_state_1_check_arm_attack_not_front:

	; check for right-arm vertical attack:
	ld a, (boss__5_scylla_arms_hp + 2)  ; right arm
	or a
	jr z, update_boss5_behavior_5_state_1_check_arm_attack_not_right
	ld a, (boss__5_scylla_arms_state + 3)  ; right arm
	cp 5  ; most rised position
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_not_right
	; left-arm is in position:
	ld a, (boss__x)
	add a, 5
	ld c, a
	ld a, (player_x + 1)
	cp c
	jr c, update_boss5_behavior_5_state_1_check_arm_attack_not_right
	add a, -5
	cp c
	jr nc, update_boss5_behavior_5_state_1_check_arm_attack_not_right
	; player is in position, chance of attacking:
	call random_a
	and #0f
	jr nz, update_boss5_behavior_5_state_1_check_arm_attack_not_right
	; right arm vertical attack!!!
	ld a, 8
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	; ret
update_boss5_behavior_5_state_1_check_arm_attack_not_right:
	ret

update_boss5_behavior_5_state_2:
	call update_boss5_behavior_4_state_2
	jp update_boss5_behavior_5_state_1_check_arm_attack

update_boss5_behavior_5_state_3:
	call update_boss5_behavior_4_state_3
	jp update_boss5_behavior_5_state_1_check_arm_attack

update_boss5_behavior_5_state_4:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_control_forward_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
update_boss5_behavior_5_state_4_entry_point:
	ld a, (boss__settings + BOSS_5_SCYLLA_DETTACHED_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_scylla_arms_attack_state)
	inc a
	ld (boss__5_scylla_arms_attack_state), a
	push af
		call update_boss5_draw_scylla
	pop af
	cp 10
	ret nz
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	ret

update_boss5_behavior_5_state_5:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_control_forward_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
update_boss5_behavior_5_state_5_entry_point:
	ld a, (boss__settings + BOSS_5_SCYLLA_DETTACHED_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_scylla_arms_attack_state)
	dec a
	ld (boss__5_scylla_arms_attack_state), a
	push af
		call update_boss5_draw_scylla
	pop af
	or a
	ret nz
	ld (boss__state), a
	ld (boss__state_timer), a
	ret

update_boss5_behavior_5_state_6:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
	jp update_boss5_behavior_5_state_4_entry_point

update_boss5_behavior_5_state_7:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
	jp update_boss5_behavior_5_state_5_entry_point	

update_boss5_behavior_5_state_8:
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_forward_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
	jp update_boss5_behavior_5_state_4_entry_point

update_boss5_behavior_5_state_9:
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_forward_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
	jp update_boss5_behavior_5_state_5_entry_point


update_boss5_behavior_5_state_10:
update_boss5_behavior_5_state_14:
	; front-arm left attack rising
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
update_boss5_behavior_5_state_10_entry_point:
	ld a, (boss__settings + BOSS_5_SCYLLA_DETTACHED_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_scylla_arms_attack_state)
	cp 3
	jr nz, update_boss5_behavior_5_state_10_continue
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	jp update_boss5_draw_scylla
update_boss5_behavior_5_state_10_continue:
	inc a
	ld (boss__5_scylla_arms_attack_state), a
	jp update_boss5_draw_scylla

update_boss5_behavior_5_state_11:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
	; front-arm left attack advancing horizontally
	ld a, (boss__settings + BOSS_5_SCYLLA_DETTACHED_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__x)
	sub 4
	ld c, a  ; reach until the left wall
	ld a, (boss__5_scylla_arms_attack_state2)
	cp c
	jr nz, update_boss5_behavior_5_state_11_continue
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	jp update_boss5_draw_scylla
update_boss5_behavior_5_state_11_continue:
	inc a
	ld (boss__5_scylla_arms_attack_state2), a
	jp update_boss5_draw_scylla

update_boss5_behavior_5_state_12:
update_boss5_behavior_5_state_16:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
	; front-arm left attack reeling-back horizontally
	ld a, (boss__settings + BOSS_5_SCYLLA_DETTACHED_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_scylla_arms_attack_state2)
	or a
	jr nz, update_boss5_behavior_5_state_12_continue
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_5_state_12_continue:
	dec a
	ld (boss__5_scylla_arms_attack_state2), a
	jp update_boss5_draw_scylla

update_boss5_behavior_5_state_13:
update_boss5_behavior_5_state_17:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
	; front-arm left attack lowering
	ld a, (boss__settings + BOSS_5_SCYLLA_DETTACHED_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_scylla_arms_attack_state)
	or a
	jr nz, update_boss5_behavior_5_state_13_continue
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_5_state_13_continue:
	dec a
	ld (boss__5_scylla_arms_attack_state), a
	jp update_boss5_draw_scylla


update_boss5_behavior_5_state_15:
	call update_boss5_scylla_control_back_arms
	call update_boss5_scylla_control_left_arm
	call update_boss5_scylla_control_right_arm
	call update_boss5_scylla_maybe_fire_eye_bullet
	call update_boss5_scylla_eye_mouth_control
	; front-arm right attack advancing horizontally
	ld a, (boss__settings + BOSS_5_SCYLLA_DETTACHED_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__x)
	sub 22
	neg
	ld c, a  ; reach until the right wall
	ld a, (boss__5_scylla_arms_attack_state2)
	cp c
	jr nz, update_boss5_behavior_5_state_15_continue
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_5_state_15_continue:
	inc a
	ld (boss__5_scylla_arms_attack_state2), a
	jp update_boss5_draw_scylla


;-----------------------------------------------
; Scylla dying
update_boss5_behavior_6:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_6_state_0  ; explosions
	dec a
	jp z, update_boss5_behavior_6_state_1  ; boss dead, spawn rewards
	ret

update_boss5_behavior_6_state_0:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	or a
	jr nz, update_boss5_behavior_6_state_0_continue
	; first frame, remove any dettached attacks
	ld (boss__5_scylla_arms_attack_state), a
	ld (boss__5_scylla_arms_attack_state2), a
update_boss5_behavior_6_state_0_continue:
	cp 64
	jr z, update_boss5_behavior_6_state_0_done
	and #03
	ret nz
	; spawn explosions at a random place:
	ld de, (boss__x)
	ld c, 6
	call random_modulo
	add a, e
	dec a
	ld e, a  ; explosion x
	ld c, 6
	call random_modulo
	add a, d
	add a, -3
	ld b, a
	ld c, e
	call spawn_explosion	

	ld de, (boss__x)
	ld c, 6
	call random_modulo
	add a, e
	dec a
	ld e, a  ; explosion x
	ld c, 6
	call random_modulo
	add a, d
	add a, -3
	ld b, a
	ld c, e
	jp spawn_explosion

update_boss5_behavior_6_state_0_done:
	ld a, 1
	ld (boss__state), a
	ld hl, current_room__tile_map + 64*24
	ld de, current_room__tile_map
	ld bc, 32*24
	ldir
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	ret


update_boss5_behavior_6_state_1:
	; mark the boss as defeated and spawn rewards:
	xor a
	ld (boss__active), a
	ld a, TAG_BOSS5_CHESTLOCK
	ld (boss__mark_defeated_after_exiting_door), a

	; mark for stats:
	ld a, (boss__5_variant)
	cp 3
	jr nz, update_boss5_behavior_6_state_1_not_both
	dec a  ; "both" shoult be 2, and not 3
update_boss5_behavior_6_state_1_not_both:
	add a, 16
	ld b, a
	ld c, BOSS_PAGE
	ld hl, add_killed_boss_to_stats
	call call_hl_in_page_c_8000

	ld hl, boss__state
	inc (hl)

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	

	; 0: charybdis, 1: scylla, 2: death, 3: both
	ld a, (boss__5_variant)
	or a
	jr z, update_boss5_behavior_6_state_1_charybdis_eye
	dec a
	jr z, update_boss5_behavior_6_state_1_scylla_eye
update_boss5_behavior_6_state_1_both_eyes:
	ld b, TAG_CHARYBDIS_EYE
	ld hl, 11 + 12*256
	call update_boss5_behavior_6_state_1_spawn_item
	ld b, TAG_SCYLLA_EYE
	ld hl, 19 + 12*256
	call update_boss5_behavior_6_state_1_spawn_item

update_boss5_behavior_6_state_1_continue:
	; spawn rewards:
	ld b, 4  ; boss number (boss 5)
	ld de, 15 + 8*256  ; - e, d: x, y coordinates to spawn the stone
	ld hl, boss_spawn_power_stone_b
	ld c, BOSS_PAGE
	jp call_hl_in_page_c_8000

update_boss5_behavior_6_state_1_charybdis_eye:
	ld b, TAG_CHARYBDIS_EYE
	ld hl, 11 + 12*256
	call update_boss5_behavior_6_state_1_spawn_item
	jr update_boss5_behavior_6_state_1_continue

update_boss5_behavior_6_state_1_scylla_eye:
	ld b, TAG_SCYLLA_EYE
	ld hl, 19 + 12*256
	call update_boss5_behavior_6_state_1_spawn_item
	jr update_boss5_behavior_6_state_1_continue

update_boss5_behavior_6_state_1_spawn_item:
	push hl
	push bc
		ld hl, ptr_to_new_tile_object
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
		push hl
		pop iy
	pop bc
	pop hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 0
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), b  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), l  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), h  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
	ret


;-----------------------------------------------
update_boss5_scylla_maybe_fire_eye_bullet:
	ld a, (boss__5_scylla_body_state)
	cp 1
	ret z  ; no firing when eyes are closed
	ld a, (boss__settings + BOSS_5_SCYLLA_BULLET_ATTACK_PATTERN_OFFSET)
	call boss_bullet_pattern_cycle
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
	ld a, (boss__5_scylla_arms_attack_clear)
	or a
	jr z, update_boss5_draw_scylla_clear_done
	ld hl, current_room__tile_map
	ADD_HL_A
	ld e, l
	ld d, h
	ld bc, 64*24
	add hl, bc
	ld a, 16
	ld bc, 32
update_boss5_draw_scylla_clear_column_loop:
	ex af, af'
		ld a, (hl)
		ld (de), a
	ex af, af'
	add hl, bc
	ex de, hl
		add hl, bc
	ex de, hl
	dec a
	jr nz, update_boss5_draw_scylla_clear_column_loop
	xor a
	ld (boss__5_scylla_arms_attack_clear), a
	ld a, (boss__5_scylla_arms_attack_clear2)
	or a
	jr z, update_boss5_draw_scylla_clear_done
	ld c, 0
	ld b, a
	call get_room_tile_ptr
	ld e, l
	ld d, h
	ld bc, 64*24
	add hl, bc
	ld bc, 32
	ldir
	xor a
	ld (boss__5_scylla_arms_attack_clear), a	

update_boss5_draw_scylla_clear_done:

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

		; draw arm attack:
		ld a, (boss__5_scylla_arms_attack_state)
		or a
		jp z, update_boss5_draw_scylla_arm_attack_done
		; we have an extending arm attack, draw it:
		ld a, (boss__state)
		cp 6  ; left-arm
		jr c, update_boss5_draw_scylla_arm_attack_left_arm  ; states: 4, 5
		cp 8  ; front-arm
		jr c, update_boss5_draw_scylla_arm_attack_front_arm  ; states: 6, 7
		cp 10  ; right-arm
		jr c, update_boss5_draw_scylla_arm_attack_right_arm  ; states: 8, 9
		cp 14  ; front-arm left attack
		jp c, update_boss5_draw_scylla_arm_attack_front_arm_h_left  ; states: 10, 11, 12, 13
		cp 18  ; front-arm right attack
		jp c, update_boss5_draw_scylla_arm_attack_front_arm_h_right  ; states: 14, 15, 16, 17
		jp update_boss5_draw_scylla_arm_attack_done

update_boss5_draw_scylla_arm_attack_left_arm:
		ld a, (boss__5_scylla_arms_hp)  ; left arm
		or a
		jp z, update_boss5_draw_scylla_arm_attack_done

		; draw tip:
		; determine x, y position: boss x, y + (-2, -5)
		ld bc, (boss__x)
		dec c
		dec c
update_boss5_draw_scylla_arm_attack_left_arm_entry_point:		
		ld a, (boss__5_scylla_arms_attack_state)
		neg
		add a, b
		add a, -5
		ld b, a
update_boss5_draw_scylla_arm_attack_left_arm_entry_point2:
		ld a, c
		ld (boss__5_scylla_arms_attack_clear), a  ; which column to clear
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn	
		ld ix, boss5_frame_scylla_dettached_tip_up
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_1_without_clearing_ix
		push de
			call call_hl_in_page_c_8000
		pop hl
		ld bc, 32*3
		add hl, bc
		ld a, (boss__5_scylla_arms_attack_state)
		ld bc, 32
update_boss5_draw_scylla_arm_attack_left_arm_loop:
		ld (hl), BOSS_5_SCYLLA_THREAD_V_TILE
		dec a
		jr z, update_boss5_draw_scylla_arm_attack_left_arm_loop_done
		add hl, bc
		jr update_boss5_draw_scylla_arm_attack_left_arm_loop
update_boss5_draw_scylla_arm_attack_left_arm_loop_done:
		ld (hl), BOSS_5_SCYLLA_THREAD_V_TILE_START
		jp update_boss5_draw_scylla_arm_attack_done

update_boss5_draw_scylla_arm_attack_front_arm:
		ld a, (boss__5_scylla_arms_hp + 1)  ; front arm
		or a
		jp z, update_boss5_draw_scylla_arm_attack_done

		; draw tip:
		; determine x, y position: boss x, y + (-2, -5)
		ld bc, (boss__x)
		ld a, (boss__5_scylla_arms_state + 2)
		or a  ; boss_x - 1 or boss_x + 6
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_left
		ld a, c
		add a, 6
		ld c, a
		jr update_boss5_draw_scylla_arm_attack_front_arm_x_set
update_boss5_draw_scylla_arm_attack_front_arm_left:
		dec c
update_boss5_draw_scylla_arm_attack_front_arm_x_set:
		ld a, (boss__5_scylla_arms_attack_state)
		neg
		add a, b
		add a, -4
		ld b, a
		jr update_boss5_draw_scylla_arm_attack_left_arm_entry_point2

update_boss5_draw_scylla_arm_attack_right_arm:
		ld a, (boss__5_scylla_arms_hp + 2)  ; right arm
		or a
		jp z, update_boss5_draw_scylla_arm_attack_done

		; draw tip:
		; determine x, y position: boss x, y + (-2, -5)
		ld bc, (boss__x)
		ld a, c
		add a, 7
		ld c, a
		jr update_boss5_draw_scylla_arm_attack_left_arm_entry_point

update_boss5_draw_scylla_arm_attack_front_arm_h_left:
		; front arm, horizontal attack
		ld a, (boss__5_scylla_arms_hp + 1)  ; front arm
		or a
		jp z, update_boss5_draw_scylla_arm_attack_done

		ld a, (boss__state)
		cp 11
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_left_bent
		cp 12
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_left_bent
		; states 10, 13:
		ld bc, (boss__x)
		dec c
		ld a, (boss__5_scylla_arms_attack_state)
		neg
		add a, b
		add a, -4
		ld b, a
update_boss5_draw_scylla_arm_attack_front_arm_h_left_entry_point:
		ld a, c
		ld (boss__5_scylla_arms_attack_clear), a  ; which column to clear
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn	
		ld ix, boss5_frame_scylla_dettached_big_tip_up
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_1_without_clearing_ix
		push de
			call call_hl_in_page_c_8000
		pop hl
		ld bc, 32*4
		add hl, bc
		ld a, (boss__5_scylla_arms_attack_state)
		ld bc, 32
update_boss5_draw_scylla_arm_attack_front_arm_h_left_loop:
		ld (hl), BOSS_5_SCYLLA_THREAD_V_TILE
		dec a
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_left_loop_done
		add hl, bc
		jr update_boss5_draw_scylla_arm_attack_front_arm_h_left_loop
update_boss5_draw_scylla_arm_attack_front_arm_h_left_loop_done:
		ld (hl), BOSS_5_SCYLLA_THREAD_V_WIDE_TILE_START
		jp update_boss5_draw_scylla_arm_attack_done

update_boss5_draw_scylla_arm_attack_front_arm_h_left_bent:
		; states 11, 12:
		; compute coordinate of the tip:
		ld bc, (boss__x)
		dec c
		ld a, c
		ld (boss__5_scylla_arms_attack_clear), a  ; which column to clear
		ld a, (boss__5_scylla_arms_attack_state2)
		neg
		add a, c
		add a, -3
		ld c, a
		dec b
		dec b
		dec b
		dec b
		ld a, b
		ld (boss__5_scylla_arms_attack_clear2), a  ; which row to clear
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn	
		ld ix, boss5_frame_scylla_dettached_tip_left
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_1_without_clearing_ix
		push de
			call call_hl_in_page_c_8000
		pop hl
		inc hl
		inc hl
		inc hl
		ld a, (boss__5_scylla_arms_attack_state2)
		or a
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_left_bent_loop_done
update_boss5_draw_scylla_arm_attack_front_arm_h_left_bent_loop:
		ld (hl), BOSS_5_SCYLLA_THREAD_H_TILE
		dec a
		inc hl
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_left_bent_loop_done
		jr update_boss5_draw_scylla_arm_attack_front_arm_h_left_bent_loop
update_boss5_draw_scylla_arm_attack_front_arm_h_left_bent_loop_done:
		ld (hl), BOSS_5_SCYLLA_THREAD_L_HINGE
		ld bc, 32
		add hl, bc
		ld (hl), BOSS_5_SCYLLA_THREAD_V_TILE
		add hl, bc
		ld (hl), BOSS_5_SCYLLA_THREAD_V_TILE
		add hl, bc
		ld (hl), BOSS_5_SCYLLA_THREAD_V_WIDE_TILE_START
		jr update_boss5_draw_scylla_arm_attack_done

update_boss5_draw_scylla_arm_attack_front_arm_h_right:
		; front arm, horizontal attack right
		ld a, (boss__5_scylla_arms_hp + 1)  ; front arm
		or a
		jp z, update_boss5_draw_scylla_arm_attack_done

		ld a, (boss__state)
		cp 15
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_right_bent
		cp 16
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_right_bent
		; states 14, 17:
		ld bc, (boss__x)
		ld a, 6
		add a, c
		ld c, a
		ld a, (boss__5_scylla_arms_attack_state)
		neg
		add a, b
		add a, -4
		ld b, a
		jp update_boss5_draw_scylla_arm_attack_front_arm_h_left_entry_point

update_boss5_draw_scylla_arm_attack_front_arm_h_right_bent:
		; states 15, 16:
		; compute coordinate of the tip:
		ld bc, (boss__x)
		ld a, 6
		add a, c
		ld c, a
		ld (boss__5_scylla_arms_attack_clear), a  ; which column to clear
		ld a, (boss__5_scylla_arms_attack_state2)
		add a, c
		inc a
		ld c, a
		dec b
		dec b
		dec b
		dec b
		ld a, b
		ld (boss__5_scylla_arms_attack_clear2), a  ; which row to clear
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn	
		ld ix, boss5_frame_scylla_dettached_tip_right
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_1_without_clearing_ix
		push de
			call call_hl_in_page_c_8000
		pop hl
		dec hl
		ld a, (boss__5_scylla_arms_attack_state2)
		or a
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_right_bent_loop_done
update_boss5_draw_scylla_arm_attack_front_arm_h_right_bent_loop:
		ld (hl), BOSS_5_SCYLLA_THREAD_H_TILE
		dec a
		dec hl
		jr z, update_boss5_draw_scylla_arm_attack_front_arm_h_right_bent_loop_done
		jr update_boss5_draw_scylla_arm_attack_front_arm_h_right_bent_loop
update_boss5_draw_scylla_arm_attack_front_arm_h_right_bent_loop_done:
		ld (hl), BOSS_5_SCYLLA_THREAD_R_HINGE
		ld bc, 32
		add hl, bc
		ld (hl), BOSS_5_SCYLLA_THREAD_V_TILE
		add hl, bc
		ld (hl), BOSS_5_SCYLLA_THREAD_V_TILE
		add hl, bc
		ld (hl), BOSS_5_SCYLLA_THREAD_V_WIDE_TILE_START
		; jr update_boss5_draw_scylla_arm_attack_done

update_boss5_draw_scylla_arm_attack_done:
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
	call stop_music
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
	ld a, (boss__settings + BOSS_5_SCYLLA_HP_OFFSET)  ; brain HP
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
	sub iyh
	jr nc, player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_continue
	xor a
player_weapon_hitbox_check_boss__boss5_scylla_hit__left_tentacle_hit_continue:
	ld (hl), a
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
	ld hl, boss__last_collision_id_3
	ld de, boss__last_collision_id_4
	ldd
	ldd
	ldd
	ld a, iyl
	ld (boss__last_collision_id_1), a
	ret

player_weapon_hitbox_check_boss__boss5_scylla_hit__right_tentacle_hit:
	ld hl, boss__5_scylla_arms_hp + 2
	ld a, (hl)
	or a
	jp z, player_weapon_hitbox_check_boss__boss5_hit_shield  ; arm already destroyed
	sub iyh
	jr nc, player_weapon_hitbox_check_boss__boss5_scylla_hit__right_tentacle_hit_continue
	xor a
player_weapon_hitbox_check_boss__boss5_scylla_hit__right_tentacle_hit_continue:
	ld (hl), a
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
	sub iyh
	jr nc, player_weapon_hitbox_check_boss__boss5_scylla_hit__front_tentacle_hit_continue
	xor a
player_weapon_hitbox_check_boss__boss5_scylla_hit__front_tentacle_hit_continue:
	ld (hl), a
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

