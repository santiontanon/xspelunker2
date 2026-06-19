boss5_charybdis_difficulty_setting__easy:
	db 32, 16  ; boss hp, vat hp
	db 64, #0f, #3f, 32, 16  ; idle time, walk mask, bullet-time-mask, attack-delay, claw-attack-speed
	db #03  ; flying claw speed mask
boss5_charybdis_difficulty_setting__normal:
	db 48, 16  ; boss hp, vat hp
	db 64, #07, #1f, 28, 14  ; idle time, walk mask, bullet-time-mask, attack-delay
	db #01  ; flying claw speed mask
boss5_charybdis_difficulty_setting__hard:
	db 64, 24  ; boss hp, vat hp
	db 64, #07, #0f, 24, 12  ; idle time, walk mask, bullet-time-mask, attack-delay
	db #01  ; flying claw speed mask
boss5_charybdis_difficulty_setting__hardest:
	db 80, 32  ; boss hp, vat hp
	db 64, #03, #0f, 20, 10  ; idle time, walk mask, bullet-time-mask, attack-delay
	db #00  ; flying claw speed mask

BOSS_5_CHARYBDIS_HP_OFFSET: equ 0
BOSS_5_CHARYBDIS_IDLE_TIME_OFFSET: equ 2
BOSS_5_CHARYBDIS_WALK_MASK: equ 3
BOSS_5_CHARYBDIS_BULLET_TIME_MASK: equ 4
BOSS_5_CHARYBDIS_ATTACK_DELAY: equ 5
BOSS_5_CHARYBDIS_CLAW_ATTACK_SPEED: equ 6
BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK: equ 7


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
	ld a, (boss__settings + BOSS_5_CHARYBDIS_IDLE_TIME_OFFSET)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp c
	jr nz, update_boss5_behavior_1_state_1_continue
	xor a
	ld (boss__state), a
	ret
update_boss5_behavior_1_state_1_continue:
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

	ld a, (boss__settings + BOSS_5_CHARYBDIS_WALK_MASK)
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
	jr nz, update_boss5_behavior_1_state_2_not_done
	xor a
	ld (boss__state), a
	ret
update_boss5_behavior_1_state_2_not_done:
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

	ld a, (boss__settings + BOSS_5_CHARYBDIS_WALK_MASK)
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
	jr nz, update_boss5_behavior_1_state_3_not_done
	xor a
	ld (boss__state), a
	ret
update_boss5_behavior_1_state_3_not_done:
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
	ld a, (boss__settings + BOSS_5_CHARYBDIS_ATTACK_DELAY)
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
	ld a, (boss__5_top_state)
	ld c, 7  ; max height with island 0
	or a
	jr z, update_boss5_behavior_1_state_5_limit_set
	ld c, 4
update_boss5_behavior_1_state_5_limit_set:
	ld hl, boss__y
	ld a, (hl)
	cp c  ; max height of the jump
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
		ld a, (hl)
		or a
		jr z, update_boss5_behavior_1_state_6_first_jump
		dec a
		jr z, update_boss5_behavior_1_state_6_second_jump
update_boss5_behavior_1_state_6_third_jump
		; switch to charybdis2 tileset, and to behavior 2 as soon as boss lands
		ld (hl), 3  ; vat
		; minimize the transition glitch:
		halt
		call update_boss5_draw_charybdis
		ld hl, draw_room_with_hud
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
		ld hl, boss_5_tiles_charybdis2_zx0
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

		jr update_boss5_behavior_1_state_6_jump_effect_set
update_boss5_behavior_1_state_6_second_jump:
		ld (hl), 2  ; crack the island
		jr update_boss5_behavior_1_state_6_jump_effect_set
update_boss5_behavior_1_state_6_first_jump:
		ld (hl), 1  ; remove poseidon statue
update_boss5_behavior_1_state_6_jump_effect_set:
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
	call update_boss5_draw_charybdis
	ld a, (boss__5_top_state)
	cp 3  ; vat
	ret nz
	; if the boss is showing the "vat", switch to behavior 2
	dec a
	ld (boss__behavior), a
	ret


;-----------------------------------------------
update_boss5_behavior_2:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_2_state_0
	dec a
	jp z, update_boss5_behavior_1_state_1  ; idle
	dec a
	jp z, update_boss5_behavior_1_state_2  ; left
	dec a
	jp z, update_boss5_behavior_1_state_3  ; right
	dec a
	jp z, update_boss5_behavior_2_state_4  ; left-claw-attack
	dec a
	jp z, update_boss5_behavior_2_state_5  ; right-claw-attack
	dec a
	jp z, update_boss5_behavior_2_state_6  ; left-flying-claw rising
	dec a
	jp z, update_boss5_behavior_2_state_7  ; left-flying-claw left1
	dec a
	jp z, update_boss5_behavior_2_state_8  ; left-flying-claw right1
	dec a
	jp z, update_boss5_behavior_2_state_9  ; left-flying-claw lowering1
	dec a
	jp z, update_boss5_behavior_2_state_10  ; left-flying-claw left2
	dec a
	jp z, update_boss5_behavior_2_state_11  ; left-flying-claw right2
	dec a
	jp z, update_boss5_behavior_2_state_12  ; left-flying-claw lowering2
	dec a
	jp z, update_boss5_behavior_2_state_13  ; right-flying-claw rising
	dec a
	jp z, update_boss5_behavior_2_state_14  ; right-flying-claw left1
	dec a
	jp z, update_boss5_behavior_2_state_15  ; right-flying-claw right1
	dec a
	jp z, update_boss5_behavior_2_state_16  ; right-flying-claw lowering1
	dec a
	jp z, update_boss5_behavior_2_state_17  ; right-flying-claw left2
	dec a
	jp z, update_boss5_behavior_2_state_18  ; right-flying-claw right2
	dec a
	jp z, update_boss5_behavior_2_state_19  ; right-flying-claw lowering2
	ret

update_boss5_behavior_2_state_0:
	; check for claw attack:
	; if player is on top of the island, chance of jump attack:
	ld a, (player_y + 1)
	cp 14
	jr nc, update_boss5_behavior_2_state_0_no_claw_attack
	ld a, (player_x + 1)
	ld c, a
	ld a, (boss__x)
	inc a
	cp c
	jr nc, update_boss5_behavior_2_state_0_no_claw_attack
	add a, 4
	cp c
	jr c, update_boss5_behavior_2_state_0_no_left_claw_attack
	; left-claw attack
	xor a
	ld (boss__state_timer), a
	ld a, 4
	ld (boss__state), a
	jp update_boss5_behavior_2_state_4
update_boss5_behavior_2_state_0_no_left_claw_attack:
	add a, 5
	cp c
	jr nc, update_boss5_behavior_2_state_0_no_claw_attack
	add a, 4
	cp c
	jr c, update_boss5_behavior_2_state_0_no_claw_attack
	; right-claw attack:
	xor a
	ld (boss__state_timer), a
	ld a, 5
	ld (boss__state), a
	jp update_boss5_behavior_2_state_5
update_boss5_behavior_2_state_0_no_claw_attack:
	; switch:
	ld c, 5
	call random_modulo
	inc a
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	jp update_boss5_behavior_2

update_boss5_behavior_2_state_4:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	; left-claw attack:
	ld a, (boss__settings + BOSS_5_CHARYBDIS_CLAW_ATTACK_SPEED)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	or a
	jp z, boss5_tile_attributes_patch_from_charybdis2_to_3
	sub c
	ret c
	jr z, update_boss5_behavior_2_state_4_frame1
	sub c
	ret c
	jr z, update_boss5_behavior_2_state_4_frame2
	sub c
	ret c
	jr z, update_boss5_behavior_2_state_4_maybe_dettach
	sub c
	ret c
	jr z, update_boss5_behavior_2_state_4_frame1
	sub c
	ret c
	; done:
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ld (boss__5_charybdis_left_claw_state), a
update_boss5_behavior_2_state_4_walk_tileset:
	call update_boss5_draw_charybdis
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	jp boss5_tile_attributes_patch_from_charybdis3_to_2
update_boss5_behavior_2_state_4_frame1:
	ld a, 2
	ld (boss__5_charybdis_left_claw_state), a
	jp update_boss5_draw_charybdis
update_boss5_behavior_2_state_4_frame2:
	ld a, 3
	ld (boss__5_charybdis_left_claw_state), a
	jp update_boss5_draw_charybdis
update_boss5_behavior_2_state_4_maybe_dettach:
	call random_a
	and #03
	ret nz
	; dettach left claw!
	ld a, 6
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	inc a
	ld (boss__5_charybdis_flying_claw_state), a
	ld a, (boss__x)
	add a, 2
	ld (boss__5_charybdis_flying_claw_x), a
	ld a, 12
	ld (boss__5_charybdis_flying_claw_y), a
	ld a, 6  ; stump up
	ld (boss__5_charybdis_left_claw_state), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_5:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	; right-claw attack:
	ld a, (boss__settings + BOSS_5_CHARYBDIS_CLAW_ATTACK_SPEED)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	or a
	jp z, boss5_tile_attributes_patch_from_charybdis2_to_3
	sub c
	ret c
	jr z, update_boss5_behavior_2_state_5_frame1
	sub c
	ret c
	jr z, update_boss5_behavior_2_state_5_frame2
	sub c
	ret c
	jr z, update_boss5_behavior_2_state_5_maybe_dettach
	sub c
	ret c
	jr z, update_boss5_behavior_2_state_5_frame1
	sub c
	ret c
	; done:
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ld (boss__5_charybdis_right_claw_state), a
	jr update_boss5_behavior_2_state_4_walk_tileset
update_boss5_behavior_2_state_5_frame1:
	ld a, 2
	ld (boss__5_charybdis_right_claw_state), a
	jp update_boss5_draw_charybdis
update_boss5_behavior_2_state_5_frame2:
	ld a, 3
	ld (boss__5_charybdis_right_claw_state), a
	jp update_boss5_draw_charybdis
update_boss5_behavior_2_state_5_maybe_dettach:
	; dettach the right claw!
	ld a, 13
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	inc a
	ld (boss__5_charybdis_flying_claw_state), a
	ld a, (boss__x)
	add a, 11
	ld (boss__5_charybdis_flying_claw_x), a
	ld a, 12
	ld (boss__5_charybdis_flying_claw_y), a
	ld a, 6  ; stump up
	ld (boss__5_charybdis_right_claw_state), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_6:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_left_stump_control

update_boss5_behavior_2_state_6_continue:
	; left flying claw (rising):
	ld a, (boss__settings + BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_charybdis_flying_claw_y)
	dec a
	ld (boss__5_charybdis_flying_claw_y), a
	cp 7
	jp nz, update_boss5_draw_charybdis
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_7:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_left_stump_control

update_boss5_behavior_2_state_7_continue:
	; left flying claw (left1):
	ld a, (boss__settings + BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_charybdis_flying_claw_state)
	inc a
	and #01
	add a, 2
	ld (boss__5_charybdis_flying_claw_state), a	
	ld a, (boss__5_charybdis_flying_claw_x)
	dec a
	ld (boss__5_charybdis_flying_claw_x), a
	cp 1
	jp nz, update_boss5_draw_charybdis
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_8:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_left_stump_control

update_boss5_behavior_2_state_8_continue:
	; left flying claw (right1):
	ld a, (boss__settings + BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_charybdis_flying_claw_state)
	inc a
	and #01
	add a, 4
	ld (boss__5_charybdis_flying_claw_state), a		
	ld a, (boss__5_charybdis_flying_claw_x)
	inc a
	ld (boss__5_charybdis_flying_claw_x), a
	cp 26
	jp nz, update_boss5_draw_charybdis
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_9:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_left_stump_control

update_boss5_behavior_2_state_9_continue:
	; left flying claw (down1):
	ld a, (boss__settings + BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, 28
	ld (boss__5_charybdis_flying_claw_x), a  ; make the claw be in the right most
	ld a, 1
	ld (boss__5_charybdis_flying_claw_state), a		
	ld a, (boss__5_charybdis_flying_claw_y)
	inc a
	ld (boss__5_charybdis_flying_claw_y), a
	cp 11
	jp nz, update_boss5_draw_charybdis
	ld a, 27
	ld (boss__5_charybdis_flying_claw_x), a  ; move it back a bit
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_10:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_left_stump_control

	; left flying claw (left2):
	jp update_boss5_behavior_2_state_7_continue

update_boss5_behavior_2_state_11:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_left_stump_control

	; left flying claw (right2):
	ld a, (boss__settings + BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_charybdis_flying_claw_state)
	inc a
	and #01
	add a, 4
	ld (boss__5_charybdis_flying_claw_state), a		
	ld a, (boss__x)
	add a, 2
	ld c, a
	ld a, (boss__5_charybdis_flying_claw_x)
	inc a
	ld (boss__5_charybdis_flying_claw_x), a
	cp c
	jp nz, update_boss5_draw_charybdis
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_12:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	ld a, 6
	ld (boss__5_charybdis_left_claw_state), a

	; left flying claw (down2):
	ld a, (boss__settings + BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, 1
	ld (boss__5_charybdis_flying_claw_state), a
	ld a, (boss__5_charybdis_flying_claw_y)
	inc a
	ld (boss__5_charybdis_flying_claw_y), a
	cp 13
	jp nz, update_boss5_draw_charybdis
	ld hl, boss__state
	ld (hl), 4  ; back to left claw attack, to retract the claw
	ld a, (boss__settings + BOSS_5_CHARYBDIS_CLAW_ATTACK_SPEED)
	add a, a
	add a, a
	ld (boss__state_timer), a
	xor a
	ld (boss__5_charybdis_flying_claw_state), a
	ld a, 3
	ld (boss__5_charybdis_left_claw_state), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_13:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_right_stump_control

	; right flying claw (up):
	jp update_boss5_behavior_2_state_6_continue

update_boss5_behavior_2_state_14:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_right_stump_control

	; right flying claw (left1):
	jp update_boss5_behavior_2_state_7_continue

update_boss5_behavior_2_state_15:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_right_stump_control

	; right flying claw (right1):
	jp update_boss5_behavior_2_state_8_continue

update_boss5_behavior_2_state_16:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_right_stump_control

	; right flying claw (down1):
	jp update_boss5_behavior_2_state_9_continue

update_boss5_behavior_2_state_17:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_right_stump_control

	; right flying claw (left2):
	jp update_boss5_behavior_2_state_7_continue

update_boss5_behavior_2_state_18:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	call update_boss5_behavior_2_right_stump_control

	; right flying claw (right2):
	ld a, (boss__settings + BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, (boss__5_charybdis_flying_claw_state)
	inc a
	and #01
	add a, 4
	ld (boss__5_charybdis_flying_claw_state), a	
	ld a, (boss__x)
	add a, 11
	ld c, a
	ld a, (boss__5_charybdis_flying_claw_x)
	inc a
	ld (boss__5_charybdis_flying_claw_x), a
	cp c
	jp nz, update_boss5_draw_charybdis
	ld hl, boss__state
	inc (hl)
	xor a
	ld (boss__state_timer), a
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_state_19:
	call update_boss5_charybdis_maybe_fire_eye_bullet
	ld a, 6
	ld (boss__5_charybdis_right_claw_state), a

	; right flying claw (down2):
	ld a, (boss__settings + BOSS_5_CHARYBDIS_FLYING_CLAW_SPEED_MASK)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and c
	ret nz
	ld a, 1
	ld (boss__5_charybdis_flying_claw_state), a	
	ld a, (boss__5_charybdis_flying_claw_y)
	inc a
	ld (boss__5_charybdis_flying_claw_y), a
	cp 13
	jp nz, update_boss5_draw_charybdis
	ld hl, boss__state
	ld (hl), 5  ; back to right claw attack, to retract the claw
	ld a, (boss__settings + BOSS_5_CHARYBDIS_CLAW_ATTACK_SPEED)
	add a, a
	add a, a
	ld (boss__state_timer), a
	xor a
	ld (boss__5_charybdis_flying_claw_state), a
	ld a, 3
	ld (boss__5_charybdis_right_claw_state), a	
	jp update_boss5_draw_charybdis

update_boss5_behavior_2_left_stump_control:
	; alternate between states 5 and 6
	ld a, (boss__state_timer)
	and #0f
	ret nz
	ld a, (boss__5_charybdis_left_claw_state)
	and #01
	add a, 5
	ld (boss__5_charybdis_left_claw_state), a

	; chance of firing a laser:
	call random_a
	and #01
	ret nz
	ld a, (boss__x)
	add a, 5
	ld c, a
	ld a, (boss__y)
	inc a
	ld b, a
	ld a, (boss__5_charybdis_left_claw_state)
	ld e, a  ; maybe 5 (right up)
	cp 5
	jp z, update_boss5_behavior_2_fire_laser
	inc e  ; 7 (up)
	dec c
	dec c
	jp update_boss5_behavior_2_fire_laser

update_boss5_behavior_2_right_stump_control:
	ld a, (boss__state_timer)
	and #0f
	ret nz
	ld a, (boss__5_charybdis_right_claw_state)
	and #01
	add a, 5
	ld (boss__5_charybdis_right_claw_state), a

	; chance of firing a laser:
	; chance of firing a laser:
	call random_a
	and #01
	ret nz
	ld a, (boss__x)
	add a, 10
	ld c, a
	ld a, (boss__y)
	inc a
	ld b, a
	ld a, (boss__5_charybdis_right_claw_state)
	ld e, 1  ; (left-up)
	cp 5
	jp z, update_boss5_behavior_2_fire_laser
	ld e, 7  ; (up)
	inc c
	inc c
	jp update_boss5_behavior_2_fire_laser


;-----------------------------------------------
; input:
; - c, b: x, y
; - e: direction
update_boss5_behavior_2_fire_laser:
	push bc
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), ENEMY_BULLET_LASER  ; enemy type
	inc hl
	ld (hl), 0  ; pixel x
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0  ; pixel y
	inc hl
	ld (hl), b  ; tile y
	inc hl
	; 1: left-up, 0: left, 2: left-down
	; 5: right-up, 4: right, 6: left-down
	; 7: up
	ld (hl), e  ; state / direction
	ld hl, SFX_raygun
	jp play_SFX_with_high_priority


;-----------------------------------------------
update_boss5_behavior_3:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_3_state_0  ; explosions
	dec a
	jp z, update_boss5_behavior_3_state_1  ; boss dead, spawn next boss
	dec a
	jp z, update_boss5_behavior_3_state_2  ; scylla rising
	ret

update_boss5_behavior_3_state_0:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	or a
	jr nz, update_boss5_behavior_3_state_0_continue
	; first frame, check if there is a flying claw:
	ld a, (boss__5_charybdis_flying_claw_state)
	or a
	jr z, update_boss5_behavior_3_state_0_continue
	; spawn explosion for flying claw:
	ld bc, (boss__5_charybdis_flying_claw_x)
	inc c
	call spawn_explosion
	xor a
	ld (boss__5_charybdis_flying_claw_state), a
	call update_boss5_draw_charybdis
	xor a
update_boss5_behavior_3_state_0_continue:
	cp 64
	jr z, update_boss5_behavior_3_state_0_done
	and #03
	ret nz
	; spawn explosions at a random place:
	ld de, (boss__x)
	ld c, 14
	call random_modulo
	add a, e
	dec a
	ld e, a  ; explosion x
	ld c, 3
	call random_modulo
	neg
	add a, d
	ld b, a
	ld c, e
	call spawn_explosion	

	ld de, (boss__x)
	ld c, 14
	call random_modulo
	add a, e
	dec a
	ld e, a  ; explosion x
	ld c, 3
	call random_modulo
	neg
	add a, d
	ld b, a
	ld c, e
	jp spawn_explosion

update_boss5_behavior_3_state_0_done:
	ld a, 1
	ld (boss__state), a
	ld hl, current_room__tile_map + 64*24
	ld de, current_room__tile_map
	ld bc, 32*24
	ldir
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	ret


update_boss5_behavior_3_state_1:
	; do we need to spawn scylla?
	ld a, (boss__5_variant)
	cp 3
	jr z, update_boss5_behavior_3_state_1_spawn_scylla
	ld a, 6
	ld (boss__behavior), a
	ret
update_boss5_behavior_3_state_1_spawn_scylla:
	; clear the wall underneath
	ld hl, current_room__tile_map + 64*24 + 21*32 + 2
	ld bc, 28-1
	ld a, 129  ; water
	call clear_memory_a
	ld hl, current_room__tile_map + 64*24 + 22*32 + 2
	ld bc, 28-1
	ld a, 129  ; water
	call clear_memory_a
	ld hl, current_room__tile_map + 64*24 + 23*32 + 2
	ld bc, 28-1
	ld a, 129  ; water
	call clear_memory_a
	ld de, current_room__tile_map
	ld hl, current_room__tile_map + 64*24
	ld bc, 32*24
	ldir
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	call update_boss5_behavior_init_scylla
	ld bc, #1e0d  ; (13, 30), initial coordinates of scylla (with the island appearing from below too)
	ld (boss__x), bc

	; update the collision table:
	ld hl, tile_collision_types_boss5_island
	ld (current_room__collision_ptr), hl
	ld a, (current_room__collision_ptr_page)
	ld de, current_room__collision_table
	ld bc, 256
	call ldir_from_page_a

	ld a, 2
	ld (boss__state), a
	ret

update_boss5_behavior_3_state_2:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and #0f
	ret nz
	; scylla rising:
	ld hl, boss__y
	dec (hl)
	call update_boss5_draw_scylla
	; push the player up if on the island:
	call boss5_maybe_push_player_up
	ld a, (boss__y)
	cp 16
	ret nz

	; Bring boss name (using sprites)
	ld ix, boss5_name_initial_sprite_attributes_scylla
	push ix
		ld de, boss5_name_y_table
		ld hl, update_boss_behavior_bring_name_down_ix
		ld c, BOSS_PAGE
		call call_hl_in_page_c_8000
		ld b, 100
		call wait_b_halts_skippable
	pop ix
	; Remove boss name (using sprites)
	ld de, boss5_name_y_table + 23
	ld hl, update_boss_behavior_bring_name_up_ix
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
	ld a, 4
	ld (boss__behavior), a
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret


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
	dw boss5_frame_left_claw_rising
	dw boss5_frame_left_claw_up
	dw boss5_frame_left_stump
	dw boss5_frame_left_stump_rising
	dw boss5_frame_left_stump_up

; 0: base, 1: closed, 2: rising, 3: up, 4: stump base, 5: stump: rising, 6: stump up
update_boss5_draw_charybdis_right_claw_table:
	dw boss5_frame_right_claw1
	dw boss5_frame_right_claw2
	dw boss5_frame_right_claw_rising
	dw boss5_frame_right_claw_up
	dw boss5_frame_right_stump
	dw boss5_frame_right_stump_rising
	dw boss5_frame_right_stump_up

update_boss5_draw_charybdis_top_table
	dw boss5_frame_island_0
	dw boss5_frame_island_1
	dw boss5_frame_island_2
	dw boss5_frame_charybdis_vat
	dw boss5_frame_charybdis_brain

update_boss5_draw_charybdis_flying_claw_table:
	dw boss5_frame_flying_claw_up
	dw boss5_frame_flying_claw_left1
	dw boss5_frame_flying_claw_left2
	dw boss5_frame_flying_claw_right1
	dw boss5_frame_flying_claw_right2


;-----------------------------------------------
; coordinate is the top-left of the 16x5 body 
update_boss5_draw_charybdis:
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

	; previous flying claw?
	ld hl, (boss__5_charybdis_flying_claw_clear_ptr)
	ld a, h
	or l
	jr z, update_boss5_draw_charybdis_no_flying_claw_clear
	push hl
	pop ix
	ld hl, draw_boss_frame_clear_previous_frame_ix_de
	ld de, #0405  ; large enough for all flying claw frames
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
update_boss5_draw_charybdis_no_flying_claw_clear:

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

	; draw top (island / vat / brain):
	ld bc, 4 - 6 * 32
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

	; draw claws:
	push hl
		ld bc, 3 * 32 - 2
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
; 		ld bc, 6
		ld bc, 7
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

		; draw flying claws:
		ld a, (boss__5_charybdis_flying_claw_state)
		or a
		jr z, update_boss5_draw_charybdis_no_flying_claws
		dec a
		add a, a
		ld hl, update_boss5_draw_charybdis_flying_claw_table
		ADD_HL_A
		ld c, (hl)
		inc hl
		ld b, (hl)
		ld ixl, c
		ld ixh, b
		ld bc, (boss__5_charybdis_flying_claw_x)
		call get_room_tile_ptr
		ld (boss__5_charybdis_flying_claw_clear_ptr), hl	
		ex de, hl  ; hl = ptr where the boss is to be drawn	
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_2_without_clearing_ix
		call call_hl_in_page_c_8000
update_boss5_draw_charybdis_no_flying_claws:
	pop hl
	; make it big enough to clear the claws:
	dec hl
	dec hl
	ld (boss__clear_bbox_2), hl
	ld bc, #070c
	ld (boss__clear_bbox_2 + 2), bc
	ret


;-----------------------------------------------
update_boss5_charybdis_maybe_fire_eye_bullet:
	ld a, (boss__settings + BOSS_5_CHARYBDIS_BULLET_TIME_MASK)
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
; - ix: ptr of the tile we hit
player_weapon_hitbox_check_boss__boss5_charybdis_hit:
	ld a, (boss__behavior)
	cp 3
	ret z
	ld a, (boss__5_top_state)
	cp 3
	jr c, player_weapon_hitbox_check_boss__boss5_hit_shield

	ld a, e
	cp 14*16+5  ; first brain/vat tile
	jr c, player_weapon_hitbox_check_boss__boss5_hit_shield
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
	jr z, player_weapon_hitbox_check_boss__boss5_charybdis_hit_break_vat
	; boss is dead:
	call stop_music
	ld a, 3
	ld (boss__behavior), a
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret
player_weapon_hitbox_check_boss__boss5_charybdis_hit_break_vat:
	inc a
	ld (boss__5_top_state), a
	ld a, (boss__settings + BOSS_5_CHARYBDIS_HP_OFFSET)  ; brain HP
	ld h, 0
	ld l, a
	ld (boss__hp), hl
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	call update_boss5_draw_charybdis
	ld bc, (boss__x)
	dec b
	dec b
	dec b
	ld a, 6
	add a, c
	ld c, a
	call spawn_big_explosion
	ld hl, SFX_explosion_low_pitch
	jp play_SFX_with_high_priority

player_weapon_hitbox_check_boss__boss5_hit_shield:
	ld hl, SFX_shield
	call play_SFX_with_high_priority
	xor a
	ld (player_weapon_hitbox_check_result), a  ; mark a hit
	ld a, (boss__last_collision_id2)
	ld (boss__last_collision_id1), a
	ld a, iyl
	ld (boss__last_collision_id2), a
	ret
