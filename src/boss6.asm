;-----------------------------------------------
BOSS_6_HP_OFFSET: equ 0
BOSS_6_WAIT_TIME_OFFSET: equ 2
BOSS_6_EYE_BULLET_TIME_MASK: equ 3
BOSS_6_MOUTH_ATTACK_MASK: equ 4
BOSS_6_MOUTH_ATTACK_N_STONES: equ 5
BOSS_6_EYE_TURRET_ATTACK_MASK: equ 6
BOSS_6_EYE_TURRET_BULLET_MASK: equ 7


;-----------------------------------------------
boss6_frame_ptrs:
	dw boss6_frame_0_face_off
	dw boss6_frame_0_face_off_mouth_open
	dw boss6_frame_0_face_on
	dw boss6_frame_0_face_on_mouth_open

boss6_eye_frame_ptrs:
	dw boss6_eye_frame_0
	dw boss6_eye_frame_1  ; eye appearing
	dw boss6_eye_frame_2  ; eye
	dw boss6_eye_frame_3  ; turret appearing 1
	dw boss6_eye_frame_4  ; turret appearing 2
	dw boss6_eye_frame_5  ; turret appearing 3
	dw boss6_eye_frame_6  ; turret
	dw boss6_eye_frame_7  ; turret up
	dw boss6_eye_frame_8  ; turret down


;-----------------------------------------------
boss6_difficulty_setting__easy:
	dw 196  ; boss hp
	db 32, #1f, #7f, 2  ; wait time, bullet time mask, mouth attack mask, n stones
	db #7f, #0f ; eye turret mask, eye turret bullet mask

boss6_difficulty_setting__normal:
	dw 320  ; boss hp
	db 32, #0f, #3f, 3  ; wait time, bullet time mask, mouth attack mask, n stones
	db #3f, #07 ; eye turret mask, eye turret bullet mask

boss6_difficulty_setting__hard:
	dw 448  ; boss hp
	db 28, #0f, #1f, 4  ; wait time, bullet time mask, mouth attack mask, n stones
	db #1f, #07 ; eye turret mask, eye turret bullet mask

boss6_difficulty_setting__hardest:
	dw 512  ; boss hp
	db 24, #07, #1f, 5  ; wait time, bullet time mask, mouth attack mask, n stones
	db #1f, #03 ; eye turret mask, eye turret bullet mask


;-----------------------------------------------
update_boss6_behavior:
	; check if we need to draw an overlay of the "damage face" when the boss is hit:
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
	; fire bullets through eyes
	ld a, (boss__settings + BOSS_6_EYE_BULLET_TIME_MASK)
	ld c, a
	call random_a
	and c
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
	jr nz, update_boss6_behavior_1_state_0_maybe_fire_bullet
	ld a, c
	rrca
	rrca
	and #3f
	ld c, a
	ld a, (boss__settings + BOSS_6_MOUTH_ATTACK_N_STONES)
	cp c
	jr z, update_boss6_behavior_1_state_0_maybe_fire_bullet
	jr c, update_boss6_behavior_1_state_0_maybe_fire_bullet
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
	jp play_SFX_with_high_priority


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
	ld a, 2
	call update_boss6_draw_boss_frame
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
	jr z, update_boss6_behavior_1_to_state_4

	; ...
	ret


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
	ld a, 2
	call update_boss6_draw_boss_frame
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret


;-----------------------------------------------
; phase 2:
update_boss6_behavior_2:
	; ...
	ret


;-----------------------------------------------
; phase 3:
update_boss6_behavior_3:
	; ...
	ret


;-----------------------------------------------
; death
update_boss6_behavior_4:
	ld a, (boss__state)
	or a
	jr z, update_boss6_behavior_4_state_0  ; remove head and spawn explosions
	dec a
	jp z, update_boss6_behavior_4_state_1  ; wait

update_boss6_behavior_4_state_2:
	ld de, #1313  ; e, d: x, y coordinates
	ld a, 5  ; boss number (boss 6)
	call boss_spawn_power_stone

	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000

	xor a
	ld (boss__active), a

	; mark for stats:
	ld b, 6  ; mars moai
	jp add_killed_boss_to_stats


update_boss6_behavior_4_state_0:
	; remove head:
	; ld a, 1
	; ld (boss__state), a	
	; ...
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000

	; spawn explosions:
	; ld a, (boss__x)
	; add a, 2
	; ld c, a
	; ld b, 13
	; jp spawn_big_explosion

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
update_boss6_draw_boss_firsst_frame:
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

	ld a, (boss__6_eye_frame)
	or a
	ret z
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
	jp call_hl_in_page_c_8000


;-----------------------------------------------
; input:
; - e: tile number that was hit
; - iyh: damage to deal
; - iyl: collision ID
; - ix: ptr of the tile we hit
player_weapon_hitbox_check_boss__boss6_hit:
	ld a, iyl
	ld (boss__last_collision_id), a

	; hit the main body:
; 	ld a, e
; 	cp 4 * 16 + 12  ; first non head tile
; 	jp c, player_weapon_hitbox_check_boss__lose_hp  ; hit the head
; 	ld hl, SFX_shield
; 	jp play_SFX_with_high_priority
	ld hl, player_weapon_hitbox_check_boss__lose_hp
	ld c, BOSS_PAGE
	jp call_hl_in_page_c_8000	

