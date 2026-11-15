;-----------------------------------------------
BOSS_6_HP_OFFSET: equ 0
BOSS_6_HP_PHASE2_OFFSET: equ 2
BOSS_6_HP_PHASE3_OFFSET: equ 4
BOSS_6_WAIT_TIME_OFFSET: equ 6
BOSS_6_EYE_BULLET_ATTACK_PATTERN_OFFSET: equ 7
BOSS_6_MOUTH_ATTACK_MASK: equ 8
BOSS_6_MOUTH_ATTACK_N_STONES: equ 9
BOSS_6_EYE_TURRET_ATTACK_MASK: equ 8  ; same as BOSS_6_MOUTH_ATTACK_MASK
BOSS_6_EYE_TURRET_BULLET_MASK: equ 10
BOSS_6_EYE_PUNCH_ATTACK_MASK: equ 8  ; same as BOSS_6_MOUTH_ATTACK_MASK
BOSS_6_MAX_DRONES_OFFSET: equ 11


;-----------------------------------------------
boss6_frame_ptrs:
	dw boss6_frame_0_face_off
	dw boss6_frame_0_face_off_mouth_open
	dw boss6_frame_0_face_on
	dw boss6_frame_0_face_on_mouth_open
	dw boss6_frame_0_face_robot
	dw boss6_frame_0_face_robot_mouth_open

boss6_eye_frame_ptrs:
	dw boss6_eye_frame_0
	dw boss6_eye_frame_1  ; eye appearing
	dw boss6_eye_frame_2  ; eye appearing 2
	dw boss6_eye_frame_3  ; eye
	dw boss6_eye_frame_4  ; turret appearing 1
	dw boss6_eye_frame_5  ; turret appearing 2
	dw boss6_eye_frame_6  ; turret appearing 3
	dw boss6_eye_frame_7  ; turret
	dw boss6_eye_frame_8  ; turret up
	dw boss6_eye_frame_9  ; turret down

boss6_face_turret_frame_ptrs:
	dw boss6_face_turret_frame_0
	dw boss6_face_turret_frame_0
	dw boss6_face_turret_frame_1
	dw boss6_face_turret_frame_2


;-----------------------------------------------
; Boss phases:
; - phase 1: until boss reaches ~75% health
; - phase 2: until boss reaches ~33% health
; - phase 3: until boss reaches 0% health
boss6_difficulty_setting__easy:
	dw 320, 240, 128  ; boss hp, and thresholds for phase 2 and 3
	db 32, BOSS_BULLET_PATTERN_EASY2, #7f, 2  ; wait time, bullet pattern, mouth attack mask, n stones
	db #0f, 1 ; eye turret mask / eye turret bullet mask, max drones

boss6_difficulty_setting__normal:
; 	dw 32, 240, 108  ; boss hp, and thresholds for phase 2 and 3 (DEBUG)
	dw 480, 320, 160  ; boss hp, and thresholds for phase 2 and 3
	db 32, BOSS_BULLET_PATTERN_MEDIUM2, #3f, 3  ; wait time, bullet pattern, mouth attack mask, n stones
	db #07, 2 ; eye turret mask / eye turret bullet mask, max drones

boss6_difficulty_setting__hard:
	dw 640, 480, 224  ; boss hp, and thresholds for phase 2 and 3
	db 28, BOSS_BULLET_PATTERN_HARD2, #1f, 4  ; wait time, bullet pattern, mouth attack mask, n stones
	db #07, 2 ; eye turret mask / eye turret bullet mask, max drones

boss6_difficulty_setting__hardest:
	dw 768, 512, 256  ; boss hp, and thresholds for phase 2 and 3
	db 24, BOSS_BULLET_PATTERN_HARDEST2, #1f, 5  ; wait time, bullet pattern, mouth attack mask, n stones
	db #03, 3 ; eye turret mask / eye turret bullet mask, max drones


;-----------------------------------------------
update_boss6_behavior:
	ld hl, boss__hit_timer
	ld a, (hl)
	or a
	jr z, update_boss6_behavior_continue
	dec (hl)
update_boss6_behavior_continue:
	ld a, (boss__active)
	or a
	ret z

	ld a, (boss__behavior)
	or a
	jp z, update_boss6_behavior_0  ; before boss is spawned
	dec a
	jp z, update_boss6_behavior_1  ; phase 1
	dec a
	jp z, update_boss6_behavior_2  ; phase 2
	dec a
	jp z, update_boss6_behavior_3  ; phase 3
	jp update_boss6_behavior_4  ; death


;-----------------------------------------------
update_boss6_behavior_0:
	ld a, (boss__state)
	or a
	jr nz, update_boss6_behavior_0_wait_for_player
update_boss6_behavior_init:
	ld a, (current_world__difficulty)
	ld hl, boss6_difficulty_setting__easy
	or a
	jr z, update_boss6_behavior_init_continue
	ld hl, boss6_difficulty_setting__normal
	dec a
	jr z, update_boss6_behavior_init_continue
	dec a
	ld hl, boss6_difficulty_setting__hard
	jr z, update_boss6_behavior_init_continue
	ld hl, boss6_difficulty_setting__hardest
update_boss6_behavior_init_continue:
	ld de, boss__settings
	ld bc, 12
	ldir

	ld a, 22
	ld (boss__x), a
	ld a, 7
	ld (boss__y), a
	xor a
	ld (boss__x2), a
	ld (boss__y2), a
	ld (boss__6_eye_frame), a
	ld (boss__6_face_turret_frame), a
	ld hl, (boss__settings + BOSS_6_HP_OFFSET)
	ld (boss__hp), hl
	ld hl, player_weapon_hitbox_check_boss__boss6_hit
	ld (boss__hit_fn), hl
	ld a, BOSS_6_PAGE
	ld (boss__hit_fn_page), a
	ld a, 1
	ld (boss__state), a
	ret

update_boss6_behavior_0_wait_for_player:
	; condition for the boss to trigger:

	ld a, (player_x + 1)  ; tile x
	cp 20
	ret c

	; appear!
	xor a
	ld (boss__state), a
	inc a
	ld (boss__behavior), a

	; close door & passage down:
	ld a, 106
	ld (current_room__tile_map + 18*32), a
	ld (current_room__tile_map + 18*32 + 64*24), a
	ld a, 107
	ld (current_room__tile_map + 19*32), a
	ld (current_room__tile_map + 19*32 + 64*24), a
	ld a, 108
	ld (current_room__tile_map + 20*32), a
	ld (current_room__tile_map + 20*32 + 64*24), a
	ld a, 99
	ld (current_room__tile_map + 2 + 21*32 + 64*24), a
	ld a, 253
	ld (current_room__tile_map + 3 + 21*32 + 64*24), a
	ld a, 98
	ld (current_room__tile_map + 4 + 21*32 + 64*24), a
	ld a, 97
	ld (current_room__tile_map + 5 + 21*32 + 64*24), a
	ld hl, current_room__tile_map + 7 + 22*32 + 64*24
	ld de, current_room__tile_map + 1 + 22*32 + 64*24
	ld bc, 6
	ldir
	ld hl, current_room__tile_map + 7 + 23*32 + 64*24
	ld de, current_room__tile_map + 1 + 23*32 + 64*24
	ld bc, 6
	ldir
	ld hl, current_room__tile_map + 21*32 + 64*24
	ld de, current_room__tile_map + 21*32
	ld bc, 32*3
	ldir
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000

	; clear the breakable wall in case it was still there:
	ld hl, current_room__tile_objects
	ld (hl), #ff

	ld hl, SFX_door_open
	call play_SFX_with_high_priority
	ld b, 50
	call wait_b_halts

	; mouth opens:
	ld a, 1  ; mouth open
	call update_boss6_draw_boss_frame
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000

	; scream:
	ld hl, SFX_roar
	call play_SFX_with_high_priority
	ld b, 100
	call wait_b_halts

	xor a  ; mouth closed
	call update_boss6_draw_boss_frame
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000

	; eyes lit up:
	ld a, 1
	ld (boss__6_eye_frame), a
	xor a
	call update_boss6_draw_boss_frame
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ld b, 10
	call wait_b_halts

	ld a, 2
	ld (boss__6_eye_frame), a
	xor a
	call update_boss6_draw_boss_frame
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ld b, 10
	call wait_b_halts

	ld a, 3
	ld (boss__6_eye_frame), a
	xor a
	call update_boss6_draw_boss_frame
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ld b, 30
	call wait_b_halts

	ld ix, boss6_name_initial_sprite_attributes
	ld de, boss6_name_y_table
	ld hl, update_boss_behavior_bring_name_down_ix
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	ld b, 200
	call wait_b_halts_skippable
	ld ix, boss6_name_initial_sprite_attributes
	ld de, boss6_name_y_table + 23
	ld hl, update_boss_behavior_bring_name_up_ix
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	; start tile animations:
	ld hl, update_animations_in_vdp_boss6
	ld (current_room__animation_fn_ptr), hl

	; draw with all the lights active:
	ld a, 2
	call update_boss6_draw_boss_frame
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	jp call_hl_in_page_c_8000



;-----------------------------------------------
; phase 1:
update_boss6_behavior_1:
	; states:
	; - 0: fire bullets through eyes
	; - 1: mouth open: parabolic stones (then back to 0)
	; - 2: eye turning into a turret (then goes to 3)
	; - 3: firing lasers through eye turret
	; - 4: eye coming back (then back to 0)
	ld a, (boss__state)
	or a
	jr z, update_boss6_behavior_1_state_0
	dec a
	jp z, update_boss6_behavior_1_state_1
	dec a
	jp z, update_boss6_behavior_1_state_2
	dec a
	jp z, update_boss6_behavior_1_state_3
	dec a
	jp z, update_boss6_behavior_1_state_4
	ret

update_boss6_behavior_1_state_0:	
	; check if we need to transition to phase 2:
	ld bc, (boss__settings + BOSS_6_HP_PHASE2_OFFSET)
	ld hl, (boss__hp)
	or a
	sbc hl, bc
	jp c, update_boss6_start_behavior_2
; 	jp update_boss6_start_behavior_2  ; DEBUG!!

update_boss6_behavior_1_state_0_entry_point:
	; this part is shared phase 1 and phase 2
	; mouth attack?
	ld a, (boss__settings + BOSS_6_MOUTH_ATTACK_MASK)
	ld c, a
	call random_a
	and c
	jr z, update_boss6_behavior_1_to_state_1
	ld a, (boss__settings + BOSS_6_EYE_TURRET_ATTACK_MASK)
	ld c, a
	call random_a
	and c
	jp z, update_boss6_behavior_1_to_state_2
update_boss6_behavior_1_state_0_maybe_fire_bullet:

	; only update the face turret in behavior 3:
	ld a, (boss__behavior)
	cp 3
	jr nz, update_boss6_behavior_1_state_0_no_face_turret
	; face turret tracks player:
	ld a, (player_y + 1)
	ld c, 2
	cp 9
	jr c, update_boss6_behavior_1_state_0_turret_angle_set
	cp 14
	ld c, 1
	jr c, update_boss6_behavior_1_state_0_turret_angle_set
	ld c, 3
update_boss6_behavior_1_state_0_turret_angle_set:
	ld a, (boss__6_face_turret_frame)
	cp c
	jr z, update_boss6_behavior_1_state_0_turret_frame_set
	ld a, c
	ld (boss__6_face_turret_frame), a
	call update_boss6_draw_boss_frame_eye
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
update_boss6_behavior_1_state_0_turret_frame_set:
	; face turret chance of firing:
	ld a, (game_cycle)
	and #3e
	jr nz, update_boss6_behavior_1_state_0_no_face_turret

	ld hl, #0505
	call update_boss6_behavior_1_state_3_turret_fire_laser_hl_set

update_boss6_behavior_1_state_0_no_face_turret:

	; fire bullets through eyes
	ld a, (boss__settings + BOSS_6_EYE_BULLET_ATTACK_PATTERN_OFFSET)
	call boss_bullet_pattern_cycle
	ret nz
	ld hl, #0305
	ld bc, (boss__x)
	add hl, bc
	ld e, l
	ld b, h
	ld ix, #0200
	; - c, b: tile coordinate from where the bullet is fired
	; - ixl, ixh: pixel offset	
	ld hl, boss_fire_directional_bullet_towards_player_e_b
	ld c, BOSS_PAGE
	jp call_hl_in_page_c_8000

update_boss6_behavior_1_to_state_1:
	xor a
	ld (boss__state_timer), a
	inc a
	ld (boss__state), a
update_boss6_behavior_1_state_1:
	; mouth open: parabolic stones (then back to 0)
	ld a, (boss__state_timer)
	or a
	jr nz, update_boss6_behavior_1_state_1_continue
	ld a, 3  ; open mouth
	call update_boss6_draw_boss_frame
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
update_boss6_behavior_1_state_1_continue:
	ld hl, boss__state_timer
	inc (hl)	
	ld a, (boss__settings + BOSS_6_WAIT_TIME_OFFSET)
	ld c, a
	add a, a
	cp (hl)
	jr z, update_boss6_behavior_1_state_1_continue_done
	ld a, (hl)
	sub c
	jr c, update_boss6_behavior_1_state_0_maybe_fire_bullet
	; throw one stone each 4 cycles:
	ld c, a
	and #03
	jp nz, update_boss6_behavior_1_state_0_maybe_fire_bullet
	ld a, c
	rrca
	rrca
	and #3f
	ld c, a
	ld a, (boss__settings + BOSS_6_MOUTH_ATTACK_N_STONES)
	cp c
	jp z, update_boss6_behavior_1_state_0_maybe_fire_bullet
	jp c, update_boss6_behavior_1_state_0_maybe_fire_bullet
	jr update_boss6_behavior_1_state_1_attack

update_boss6_behavior_1_state_1_continue_done:
	ld a, 2  ; closed mouth
	call update_boss6_draw_boss_frame
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
update_boss6_behavior_1_state_back_to_0:
	; back to state 0:
	xor a
	ld (boss__state_timer), a
	ld (boss__state), a
	ret

update_boss6_behavior_1_state_1_attack:
	; shoot parabolic stones through mouth:
	call ptr_to_new_sprite_enemy
	ret nz
	push hl
	pop ix
	ld (hl), 0  ; ID
	inc hl
	ld (hl), ENEMY_BOSS6_STONE
	inc hl
	ld (hl), 0  ; pixel X
	inc hl
	ld (hl), 22  ; tile X
	inc hl
	ld (hl), 0  ; pixel Y
	inc hl
	ld (hl), 17  ; tile Y
	inc hl
	ld (hl), 0  ; state
	inc hl
	call random_a
	and #07
	ld (hl), a  ; state timer (start with slightly different initial speed)
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld (hl), 4  ; health
	inc hl
	inc hl
	ld c, 3
	call random_modulo
	add a, -3
	ld (hl), a  ; extra 1 (speed x): -1, -2 or -3 randomly
	ld hl, SFX_door_open
	call play_SFX_with_high_priority
	xor a  ; ret z
	ret


; eye frames to make the turret appear:
update_boss6_behavior_1_state_2_table:
	db 2, 1, 0, 4, 5, 6, 7

update_boss6_behavior_1_to_state_2:
	xor a
	ld (boss__state_timer), a
	ld a, 2
	ld (boss__state), a
update_boss6_behavior_1_state_2:
	; eye turning into a turret (then goes to 3)
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	ld c, a
	and #03
	ret nz
	ld a, c
	rrca
	rrca
	and #3f
	cp 7
	jr z, update_boss6_behavior_1_to_state_3
	ld hl, update_boss6_behavior_1_state_2_table
	ADD_HL_A
	ld a, (hl)
	ld (boss__6_eye_frame), a
	call update_boss6_draw_boss_frame_eye
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret

update_boss6_behavior_1_to_state_3:
	xor a
	ld (boss__state_timer), a
	ld a, 3
	ld (boss__state), a
update_boss6_behavior_1_state_3:
	; firing lasers through eye turret
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp 64
	jp z, update_boss6_behavior_1_to_state_4
	; turret tracks player:
	ld a, (player_y + 1)
	ld c, 8
	cp 8
	jr c, update_boss6_behavior_1_state_3_turret_angle_set
	cp 13
	ld c, 7
	jr c, update_boss6_behavior_1_state_3_turret_angle_set
	ld c, 9
update_boss6_behavior_1_state_3_turret_angle_set:
	ld a, (boss__6_eye_frame)
	cp c
	jr z, update_boss6_behavior_1_state_3_turret_frame_set
	ld a, c
	ld (boss__6_eye_frame), a
	call update_boss6_draw_boss_frame_eye
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
update_boss6_behavior_1_state_3_turret_frame_set:
	ld a, (boss__settings + BOSS_6_EYE_TURRET_BULLET_MASK)
	ld c, a
	ld a, (boss__state_timer)
	dec a  ; since we pre-incremented it
	and c
	ret nz
	; fire a directional laser:
	ld hl, #0305
update_boss6_behavior_1_state_3_turret_fire_laser_hl_set:
	ld bc, (boss__x)
	add hl, bc
	ld e, l
	ld b, h
	ld ix, 0
	ld hl, boss_fire_directional_bullet_towards_player_e_b
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
	ret nz
	ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BOSS6_LASER
	; determine the sprite to use (to do this, we just call the bresenham algorithm, and check how
	; much does the bullet move in y in one step):
	ld (ix + ROOM_OBJECT_STRUCT_BRESENHAM_STATE), 0
	ld e, 8
	ld hl, update_enemy_bullet_bresenham_e_steps
	ld c, ENEMIES_PAGE
	call call_hl_in_page_c_8000
	ld (ix + ROOM_OBJECT_STRUCT_BRESENHAM_STATE), 0
	ld a, b  ; movement in y (from -8 to 8)
	; mapping:
	; - 6+: (FIRST_ENEMY_SPRITE_PATTERN + 9) * 4
	; - 5, 4: (FIRST_ENEMY_SPRITE_PATTERN + 10) * 4
	; - 3, 2: (FIRST_ENEMY_SPRITE_PATTERN + 11) * 4
	; - 1, 0, -1: (FIRST_ENEMY_SPRITE_PATTERN + 12) * 4
	; - -2, -3: (FIRST_ENEMY_SPRITE_PATTERN + 13) * 4
	; - -4+: (FIRST_ENEMY_SPRITE_PATTERN + 14) * 4
	ld c, (FIRST_ENEMY_SPRITE_PATTERN + 9) * 4
	cp 6
	jp p, update_boss6_behavior_1_state_3_turret_sprite_set
	ld c, (FIRST_ENEMY_SPRITE_PATTERN + 10) * 4
	cp 4
	jp p, update_boss6_behavior_1_state_3_turret_sprite_set
	ld c, (FIRST_ENEMY_SPRITE_PATTERN + 11) * 4
	cp 2
	jp p, update_boss6_behavior_1_state_3_turret_sprite_set
	ld c, (FIRST_ENEMY_SPRITE_PATTERN + 12) * 4
	cp -1
	jp p, update_boss6_behavior_1_state_3_turret_sprite_set
	ld c, (FIRST_ENEMY_SPRITE_PATTERN + 13) * 4
	cp -3
	jp p, update_boss6_behavior_1_state_3_turret_sprite_set
	ld c, (FIRST_ENEMY_SPRITE_PATTERN + 14) * 4
update_boss6_behavior_1_state_3_turret_sprite_set:
	ld (ix + ROOM_OBJECT_STRUCT_EXTRA1), c  ; sprite to use
	ld hl, SFX_raygun
	jp play_SFX_with_high_priority


update_boss6_behavior_1_state_4_table:
	db 6, 5, 4, 0, 1, 2, 3

update_boss6_behavior_1_to_state_4:
	xor a
	ld (boss__state_timer), a
	ld a, 4
	ld (boss__state), a
update_boss6_behavior_1_state_4:
	; eye coming back (then back to 0)
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	ld c, a
	and #03
	ret nz
	ld a, c
	rrca
	rrca
	and #3f
	cp 7
	jp z, update_boss6_behavior_1_state_back_to_0
	ld hl, update_boss6_behavior_1_state_4_table
	ADD_HL_A
	ld a, (hl)
	ld (boss__6_eye_frame), a
	call update_boss6_draw_boss_frame_eye
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret


;-----------------------------------------------
; phase 2:
update_boss6_start_behavior_2:
	; enter phase 2:
	ld a, 7
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ld a, 2
	ld (boss__behavior), a
	; reset hp:
	ld hl, (boss__settings + BOSS_6_HP_PHASE2_OFFSET)
	ld (boss__hp), hl	
	ret

update_boss6_behavior_2:
	; states:
	; - 0: fire bullets through eyes
	; - 1: mouth open: parabolic stones (then back to 0)
	; - 2: eye turning into a turret (then goes to 3)
	; - 3: firing lasers through eye turret
	; - 4: eye coming back (then back to 0)
	; - 5: punch down
	; - 6: punch up
	; - 7: roof being destroyed (starting phase 2)
	ld a, (boss__state)
	or a
	jp z, update_boss6_behavior_2_state_0
	dec a
	jp z, update_boss6_behavior_1_state_1
	dec a
	jp z, update_boss6_behavior_1_state_2
	dec a
	jp z, update_boss6_behavior_1_state_3
	dec a
	jp z, update_boss6_behavior_1_state_4
	dec a
	jp z, update_boss6_behavior_2_state_5
	dec a
	jp z, update_boss6_behavior_2_state_6
	dec a
	jp z, update_boss6_behavior_2_state_7
	ret

update_boss6_behavior_2_state_0:
	; check if we need to transition to phase 3:
	ld bc, (boss__settings + BOSS_6_HP_PHASE3_OFFSET)
	ld hl, (boss__hp)
	or a
	sbc hl, bc
	jp c, update_boss6_start_behavior_3
; 	jp update_boss6_start_behavior_3  ; DEBUG!!

	; punch attack?
	ld a, (boss__settings + BOSS_6_EYE_PUNCH_ATTACK_MASK)
	ld c, a
	call random_a
	and c
	jr z, update_boss6_behavior_2_to_state_5
	; jr update_boss6_behavior_2_to_state_5  ; DEBUG!
	jp update_boss6_behavior_1_state_0_entry_point


update_boss6_behavior_2_to_state_5:
	xor a
	ld (boss__state_timer), a
	ld a, 5
	ld (boss__state), a
	; pick punch location:
	ld a, (player_x + 1)
	dec a
	cp 18
	jr c, update_boss6_behavior_2_to_state_5_continue
	ld a, 18
update_boss6_behavior_2_to_state_5_continue:
	ld (boss__x2), a
	ld a, -1
	ld (boss__y2), a
	; draw fist at top:
	call update_boss6__draw_punch
update_boss6_behavior_2_state_5:
	; punch attack down:
	ld a, (boss__settings + BOSS_6_WAIT_TIME_OFFSET)
	ld c, a
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	sub c
	jp c, update_boss6_behavior_1_state_0_maybe_fire_bullet  ; still waiting
	ld hl, boss__y2
	inc (hl)
	call update_boss6__draw_punch
	ld a, (boss__y2)
	cp 17
	jp nz, update_boss6_behavior_1_state_0_maybe_fire_bullet
	xor a
	ld (boss__state_timer), a
	ld a, 6
	ld (boss__state), a
	ld bc, (boss__x2)
	ld b, 19
	call spawn_4tile_appart_dust
	ld hl, SFX_explosion_low_pitch
	call play_SFX_with_high_priority
	jp update_boss6_behavior_1_state_0_maybe_fire_bullet

update_boss6_behavior_2_state_6:
	; punch attack up
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	cp 16
	jp c, update_boss6_behavior_1_state_0_maybe_fire_bullet  ; punch stays a bit
	and #01
	jp nz, update_boss6_behavior_1_state_0_maybe_fire_bullet
	ld hl, boss__y2
	dec (hl)
	call update_boss6__draw_punch
	ld a, (boss__y2)
	cp -4
	jp nz, update_boss6_behavior_1_state_0_maybe_fire_bullet
	xor a
	ld (boss__state_timer), a
	ld (boss__state), a
	jp update_boss6_behavior_1_state_0_maybe_fire_bullet


update_boss6_behavior_2_state_7:
	; entering phase 2 (roof being destroyed):
	; from coordinate 1 - 23 of the ceiling must be destroyed
	ld a, (boss__state_timer)
	or a
	jr nz, update_boss6_behavior_2_state_7_continue
	; roar:
	ld a, 3  ; mouth open
	call update_boss6_draw_boss_frame
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000

	ld hl, SFX_roar
	call play_SFX_with_high_priority

	ld b, 100
	call wait_b_halts

	ld a, 2  ; mouth closed
	call update_boss6_draw_boss_frame
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)		
update_boss6_behavior_2_state_7_continue:
	ld hl, boss__state_timer
	ld a, (hl)
	ld c, a
	inc (hl)
	and #07
	ret nz
	ld a, c
	rrca
	rrca
	rrca
	and #1f
	cp 11
	jr nz, update_boss6_behavior_2_state_7_continue2
	; one with breaking the ceiling!
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret
update_boss6_behavior_2_state_7_continue2:
	add a, a
	inc a  ; a = x coordinate of the roof part we are destroying in this frame
	; - clear map from [a, 0] - [a + 2, 3]
	; - spawn a rock with 0 x velocity at [a*8, 8]
	ld c, a
	push bc
		ld hl, current_room__tile_map
		ADD_HL_A
		ld (hl), 0
		inc hl
		ld (hl), 0
		ld bc, 31
		add hl, bc
		ld (hl), 0
		inc hl
		ld (hl), 0
		ld bc, 31
		add hl, bc
		ld (hl), 0
		inc hl
		ld (hl), 0
		ld hl, current_room__tile_map
		ld de, current_room__tile_map + 64*24
		ld bc, 32*3
		ldir
		ld hl, redraw_flags
		set ROOM_REDRAW_FLAG_BIT, (hl)		

		ld hl, SFX_explosion_low_pitch
		call play_SFX_with_high_priority
		; spawn a falling stone:
		call ptr_to_new_sprite_enemy
	pop bc
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), ENEMY_BOSS6_STONE
	inc hl
	ld (hl), 0  ; pixel X
	inc hl
	ld (hl), c  ; tile X
	inc hl
	ld (hl), 0  ; pixel Y
	inc hl
	ld (hl), 0  ; tile Y
	inc hl
	ld (hl), 0  ; state
	inc hl
	call random_a
	and #03
	add a, 12
	add a, a
	ld (hl), a  ; state timer (start with slightly different initial speed)
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld (hl), 4  ; health
	inc hl
	inc hl
	ld (hl), 0  ; extra 1 (speed x)

	; reset hp continuously so that boss does not take damage during the transition:
	ld hl, (boss__settings + BOSS_6_HP_PHASE2_OFFSET)
	ld (boss__hp), hl	
	ret


;-----------------------------------------------
; phase 3:
update_boss6_start_behavior_3:
	; enter phase 3:
	ld a, 7
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ld a, 3
	ld (boss__behavior), a
	; reset hp:
	ld hl, (boss__settings + BOSS_6_HP_PHASE3_OFFSET)
	ld (boss__hp), hl
	ret

update_boss6_behavior_3:
	; states:
	; - 0: base fire bullets through eyes / turrets
	; - 1: mouth open: parabolic stones or drones (then back to 0)
	; - 2: eye turning into a turret (then goes to 3)
	; - 3: firing lasers through eye turret
	; - 4: eye coming back (then back to 0)
	; - 5: punch down
	; - 6: punch up
	; - 7: top part of face being destroyed
	ld a, (boss__state)
	or a
	jp z, update_boss6_behavior_3_state_0
	dec a
	jp z, update_boss6_behavior_3_state_1
	dec a
	jp z, update_boss6_behavior_1_state_2
	dec a
	jp z, update_boss6_behavior_1_state_3
	dec a
	jp z, update_boss6_behavior_1_state_4
	dec a
	jp z, update_boss6_behavior_2_state_5
	dec a
	jp z, update_boss6_behavior_2_state_6
	dec a
	jp z, update_boss6_behavior_3_state_7
	ret

update_boss6_behavior_3_state_0:
	; is boss dead?
	ld hl, (boss__hp)
	ld a, h
	or l
	jp z, update_boss6_start_behavior_4

	; punch attack?
	ld a, (boss__settings + BOSS_6_EYE_PUNCH_ATTACK_MASK)
	ld c, a
	call random_a
	and c
	jp z, update_boss6_behavior_2_to_state_5
	; mouth attack?
	ld a, (boss__settings + BOSS_6_MOUTH_ATTACK_MASK)
	ld c, a
	call random_a
	and c
	jr z, update_boss6_behavior_3_to_state_1
	; eye turret?
	ld a, (boss__settings + BOSS_6_EYE_TURRET_ATTACK_MASK)
	ld c, a
	call random_a
	and c
	jp z, update_boss6_behavior_1_to_state_2

	jp update_boss6_behavior_1_state_0_maybe_fire_bullet

update_boss6_behavior_3_to_state_1:
	xor a
	ld (boss__state_timer), a
	inc a
	ld (boss__state), a
update_boss6_behavior_3_state_1:
	; mouth open: parabolic stones (then back to 0)
	ld a, (boss__state_timer)
	or a
	jr nz, update_boss6_behavior_3_state_1_continue
	ld a, 5  ; open mouth
	call update_boss6_draw_boss_frame
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
update_boss6_behavior_3_state_1_continue:
	ld hl, boss__state_timer
	inc (hl)	
	ld a, (boss__settings + BOSS_6_WAIT_TIME_OFFSET)
	ld c, a
	add a, a
	cp (hl)
	jr z, update_boss6_behavior_3_state_1_continue_done
	ld a, (hl)
	sub c
	jp c, update_boss6_behavior_1_state_0_maybe_fire_bullet
	; throw one stone each 4 cycles:
	ld c, a
	and #03
	jp nz, update_boss6_behavior_1_state_0_maybe_fire_bullet
	ld a, c
	rrca
	rrca
	and #3f
	ld c, a
	ld a, (boss__settings + BOSS_6_MOUTH_ATTACK_N_STONES)
	cp c
	jp z, update_boss6_behavior_1_state_0_maybe_fire_bullet
	jp c, update_boss6_behavior_1_state_0_maybe_fire_bullet	
	; chance of spawning drones (if there are less than 2):
	call update_boss6_count_drones  ; c = number of drones
	ld a, (boss__settings + BOSS_6_MAX_DRONES_OFFSET)
	cp c
	jp z, update_boss6_behavior_1_state_1_attack  ; max number of drones reached
	call random_a
	and #03
	jp nz, update_boss6_behavior_1_state_1_attack
	; spawn a drone instead of a rock
	call update_boss6_behavior_1_state_1_attack
	ret nz
	ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BOSS6_DRONE_STONE
	ret
update_boss6_behavior_3_state_1_continue_done:
	ld a, 4  ; closed mouth
	call update_boss6_draw_boss_frame
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	jp update_boss6_behavior_1_state_back_to_0


update_boss6_count_drones:
	; find # of bats:
	ld c, 0
	ld ix, current_room__sprite_enemies
	ld de, ROOM_OBJECT_STRUCT_SIZE
update_boss6_count_drones_loop:
	ld a, (ix)
	inc a  ; cp #ff
	ret z
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	add ix, de
	cp ENEMY_MARS_DRONE2
	jr nz, update_boss6_count_drones_loop
	inc c
	jr update_boss6_count_drones_loop


update_boss6_behavior_3_state_7_table:
	; coordinates of the dust: x, y, width
	db 26, 7, 4
	db 25, 8, 5
	db 25, 9, 5
	db 25, 10, 5
	db 24, 11, 6
	db 24, 12, 6
	db 25, 13, 5
	db 26, 14, 3
	db 26, 15, 2
	db 26, 16, 1
update_boss6_behavior_3_state_7_table_end:


update_boss6_behavior_3_state_7:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	and #03
	jr nz, update_boss6_behavior_3_state_7_continue

	; reset hp continuously:
	ld hl, (boss__settings + BOSS_6_HP_PHASE3_OFFSET)
	ld (boss__hp), hl

	; spawn an explosion:
	ld bc, #0819
	call random_a
	and #03
	add a, c
	ld c, a
	call random_a
	and #07
	add a, b
	ld b, a
	call spawn_explosion
update_boss6_behavior_3_state_7_continue:
	; draw transition dust:
	ld a, (boss__state_timer)
	and #03
	ret nz	

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	ld a, (boss__state_timer)
	cp 8*10
	jr z, update_boss6_behavior_3_state_7_done
	rrca
	rrca
	rrca
	and #0f
	push af
		ld c, a
		add a, a
		add a, c
		ld hl, update_boss6_behavior_3_state_7_table
		ADD_HL_A
		ld c, (hl)
		inc hl
		ld b, (hl)
		inc hl
		push hl
			call get_room_tile_ptr
			ex de, hl
		pop hl
		ld a, 224  ; first dust tile
		ld (de), a
		inc de
		ld b, (hl)
update_boss6_behavior_3_state_7_dust_loop:
		ld a, (boss__state_timer)
		rrca
		rrca
		add a, b
		and #01
		add a, 225
		ld (de), a
		inc de
		djnz update_boss6_behavior_3_state_7_dust_loop
		ld a, 227
		ld (de), a
	pop af
	or a
	ret z
	dec a 
	push af
		add a, 7
		ld b, a
		ld c, 23
		call get_room_tile_ptr
		ex de, hl
	pop af
	; start drawing the robotic face: (row "a")
	ld hl, BOSS6_NAMETABLE_HEAD_ROBOT
	add a, a
	add a, a
	add a, a
	ADD_HL_A
	ld a, BOSS_PAGE
	ld bc, 8
	call ldir_from_page_a
	ld h, d
	ld l, e
	ld bc, 2*32*24
	add hl, bc
	ldi  ; clear the right most tile
	ret

update_boss6_behavior_3_state_7_done:
	; done
	ld a, 4  ; robotic face (mouth closed)
	call update_boss6_draw_boss_frame
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ld hl, update_animations_in_vdp_boss6b
	ld (current_room__animation_fn_ptr), hl	
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret


;-----------------------------------------------
; death
update_boss6_start_behavior_4:
	; enter phase 3:
	call stop_music
	ld hl, 0
	ld (current_room__music_ptr), hl

	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ld a, 4
	ld (boss__behavior), a
	ret

update_boss6_behavior_4:
	ld a, (boss__state)
	or a
	jr z, update_boss6_behavior_4_state_0  ; explosions
	dec a
	jp z, update_boss6_behavior_4_state_1  ; wait
	dec a
	jp z, update_boss6_behavior_4_state_2  ; done
	ret

update_boss6_behavior_4_state_2:
	ld a, 3
	ld (boss__state), a

	ld de, #1109  ; e, d: x, y coordinates
	ld b, 5  ; boss number (boss 6)
	ld hl, boss_spawn_power_stone_b
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	xor a
	ld (boss__active), a
	ld a, TAG_BOSS6_CHESTLOCK
	ld (boss__mark_defeated_after_exiting_door), a

	; mark for stats:
	ld b, 19  ; mars moai
	ld c, BOSS_PAGE
	ld hl, add_killed_boss_to_stats
	jp call_hl_in_page_c_8000


update_boss6_behavior_4_state_0:
	ld hl, boss__state_timer
	ld a, (hl)
	cp 80
	jr nz, update_boss6_behavior_4_state_0_continue
	xor a
	ld (boss__state_timer), a
	inc a
	ld (boss__state), a

	; restore the background:
	ld hl, current_room__tile_map + 2*32*24
	ld de, current_room__tile_map
	ld bc, 32*24
	ldir

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret
update_boss6_behavior_4_state_0_continue:
	inc (hl)
	and #03
	ret nz
	; spawn an explosion:
	ld c, 13
	call random_modulo
	add a, 8
	ld b, a
	call random_a
	and #03
	add a, 25
	ld c, a
	jp spawn_explosion

update_boss6_behavior_4_state_1:
	ld hl, boss__state_timer
	inc (hl)
	ld a, (hl)
	cp 20
	ret nz
	ld (hl), 0
	ld hl, boss__state
	inc (hl)
	ret


;-----------------------------------------------
; this is called from bosses.asm when the room is created to draw the first boss frame.
update_boss6_draw_boss_first_frame:
	ld a, 22
	ld (boss__x), a
	ld a, 7
	ld (boss__y), a
	xor a
	ld (boss__x2), a
	ld (boss__y2), a
	xor a
	jr update_boss6_draw_boss_frame_not_clearing


;-----------------------------------------------
; input:
; - a: frame to draw
update_boss6_draw_boss_frame:
	push af
		ld hl, draw_boss_frame_clear_previous_frame_1
		ld c, BOSS_PAGE
		call call_hl_in_page_c_8000
	pop af
update_boss6_draw_boss_frame_not_clearing:
	ld hl, boss6_frame_ptrs
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
		ld hl, redraw_flags
		set ROOM_REDRAW_FLAG_BIT, (hl)

		; compute draw pointer:
		ld bc, (boss__x)
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn
	pop ix
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_1_without_clearing_ix
	call call_hl_in_page_c_8000

update_boss6_draw_boss_frame_eye:
	ld a, (boss__6_eye_frame)
	or a
	jr z, update_boss6_draw_boss_frame_face_turret
	; draw eye frame:
	ld hl, boss6_eye_frame_ptrs
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
		ld hl, #0305
		ld bc, (boss__x)
		add hl, bc
		ld c, l
		ld b, h
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn
	pop ix
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_internal_ix
	call call_hl_in_page_c_8000

update_boss6_draw_boss_frame_face_turret:
	ld a, (boss__6_face_turret_frame)
	or a
	ret z
	; draw face turret frame:
	ld hl, boss6_face_turret_frame_ptrs
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
		ld hl, #0505
		ld bc, (boss__x)
		add hl, bc
		ld c, l
		ld b, h
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn
	pop ix
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_internal_ix
	jp call_hl_in_page_c_8000


;-----------------------------------------------
update_boss6__draw_punch:
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	

	; clear vertical of the punch:
	ld bc, (boss__x2)
	ld b, 0
	call get_room_tile_ptr
	push hl
	pop ix
	ld de, #1504
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_clear_previous_frame_ix_de
	call call_hl_in_page_c_8000

	; draw the fist:
	ld bc, (boss__x2)
	call get_room_tile_ptr
	push hl
		ex de, hl
		ld b, 4
		ld iyl, 4
		ld ix, BOSS6_NAMETABLE_FIST
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_part_ix_iyl
		call call_hl_in_page_c_8000

	; draw the arm:
	pop de
	inc de
	ld a, (boss__y2)
update_boss6__draw_punch_loop:
	or a
	ret z
	ret m
	sub 4
	ex de, hl
		ld bc, -32*4
		add hl, bc
	ex de, hl
	push af
	push de
		ld b, 4
		ld iyl, 2
		ld ix, BOSS6_NAMETABLE_ARM
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_part_ix_iyl
		call call_hl_in_page_c_8000
	pop de
	pop af
	jr update_boss6__draw_punch_loop


;-----------------------------------------------
; input:
; - e: tile number that was hit
; - iyh: damage to deal
; - iyl: collision ID
; - ix: ptr of the tile we hit
player_weapon_hitbox_check_boss__boss6_hit:
	ld a, (boss__behavior)
	or a
	ret z

	; hit the main body:
	ld a, e
	cp 222  ; first punch tile
	jp c, player_weapon_hitbox_check_boss__boss6_hit_body
	ld hl, SFX_shield
	call play_SFX_with_high_priority
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
player_weapon_hitbox_check_boss__boss6_hit_body:
	ld hl, player_weapon_hitbox_check_boss__lose_hp
	ld c, BOSS_PAGE
	jp call_hl_in_page_c_8000	

