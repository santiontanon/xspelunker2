;-----------------------------------------------
BOSS_7_HP_OFFSET: equ 0
BOSS_7_WAIT_TIME_OFFSET: equ 2
BOSS_7_EYE_BULLET_ATTACK_MASK: equ 3
BOSS_7_POISON_ATTACK_MASK: equ 4
BOSS_7_N_POISON_SPITS: equ 5


;-----------------------------------------------
boss7_phase1_frame_ptrs:
	; appearing:
	dw boss7_phase1_frame_1
	dw boss7_phase1_frame_2
	dw boss7_phase1_frame_3
	dw boss7_phase1_frame_4
	dw boss7_phase1_frame_5
	; out:
	dw boss7_phase1_frame_6
	dw boss7_phase1_frame_7
	; out up:
	dw boss7_phase1_frame_8
	dw boss7_phase1_frame_9


;-----------------------------------------------
boss7_difficulty_setting__easy:
	dw 192  ; boss hp
	db 32, #1f, #0f, 2  ; wait time, bullet attack mask, poison attack mask, n spits

boss7_difficulty_setting__normal:
	dw 320  ; boss hp
	db 32, #0f, #07, 3  ; wait time, bullet attack mask, poison attack mask, n spits

boss7_difficulty_setting__hard:
	dw 416  ; boss hp
	db 28, #0f, #07, 4  ; wait time, bullet attack mask, poison attack mask, n spits

boss7_difficulty_setting__hardest:
	dw 512  ; boss hp
	db 24, #07, #03, 4  ; wait time, bullet attack mask, poison attack mask, n spits


;-----------------------------------------------
update_boss7_behavior:
	ld hl, boss__hit_timer
	ld a, (hl)
	or a
	jr z, update_boss7_behavior_continue
	dec (hl)
update_boss7_behavior_continue:
	ld a, (boss__active)
	or a
	ret z

	ld a, (boss__behavior)
	or a
	jp z, update_boss7_behavior_0  ; before boss is spawned
	dec a
	jp z, update_boss7_behavior_1  ; phase 1
	dec a
	jp z, update_boss7_behavior_2  ; phase 2
	dec a
	jp z, update_boss7_behavior_3  ; phase 3
	jp update_boss7_behavior_4  ; death


;-----------------------------------------------
update_boss7_behavior_0:
	ld a, (boss__state)
	or a
	jr nz, update_boss7_behavior_0_wait_for_player

update_boss7_behavior_init:
	ld a, (current_world__difficulty)
	ld hl, boss7_difficulty_setting__easy
	or a
	jr z, update_boss7_behavior_init_continue
	ld hl, boss7_difficulty_setting__normal
	dec a
	jr z, update_boss7_behavior_init_continue
	dec a
	ld hl, boss7_difficulty_setting__hard
	jr z, update_boss7_behavior_init_continue
	ld hl, boss7_difficulty_setting__hardest
update_boss7_behavior_init_continue:
	ld de, boss__settings
	ld bc, 12
	ldir

	ld a, 54
	ld (boss__x), a
	ld a, 4
	ld (boss__y), a
	ld a, 50
	ld (boss__x2), a
	ld a, 6
	ld (boss__y2), a
	ld hl, (boss__settings + BOSS_7_HP_OFFSET)
	ld (boss__hp), hl
	ld hl, player_weapon_hitbox_check_boss__boss7_hit
	ld (boss__hit_fn), hl
	ld a, BOSS_7_PAGE
	ld (boss__hit_fn_page), a
	ld a, 1
	ld (boss__state), a

	; draw the statue:
	xor a
	call update_boss7_draw_phase1_boss_frame

update_boss7_behavior_0_wait_for_player:
	; condition for the boss to trigger:
	ld a, (player_x + 1)  ; tile x
	cp 52
	ret c
	ld a, (player_y + 1)  ; tile y
	cp 16
	ret c

	; message 1:
	ld de, TEXT_MOON_BOSS_1
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	; appear!
	xor a
	ld (boss__state), a
	inc a
	ld (boss__behavior), a

	; snake face appears:
	ld b, 6  ; 6 frames animation of appearing
update_boss7_behavior_0_wait_for_player_appearing_loop:
	push bc
		ld a, b
		neg
		add a, 7
		call update_boss7_draw_phase1_boss_frame
		ld hl, draw_room_with_hud
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000

		ld b, 20
		call wait_b_halts
	pop bc
	djnz update_boss7_behavior_0_wait_for_player_appearing_loop

	ld b, 20
	call wait_b_halts

	; message 1:
	ld de, TEXT_MOON_BOSS_2
	ld hl, display_in_game_message_textpage4
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	ld ix, boss7_name_initial_sprite_attributes
	ld de, boss7_name_y_table
	ld hl, update_boss_behavior_bring_name_down_ix
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	ld b, 200
	call wait_b_halts_skippable
	ld ix, boss7_name_initial_sprite_attributes
	ld de, boss7_name_y_table + 23
	ld hl, update_boss_behavior_bring_name_up_ix
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	; start tile animations:
; 	ld hl, update_animations_in_vdp_boss7
; 	ld (current_room__animation_fn_ptr), hl
	ret



;-----------------------------------------------
; phase 1:
update_boss7_behavior_1:
	; states:
	; - 0: head out, frame 6 (chance of eye bullet, chance of spit)
	; - 1: head out, frame 8 (chance of eye bullet, chance of spit)
	; - 2: hiding inside statue (back to 0 after a bit, only if player is closeby, bullets get fired from the statue mouth)
	; - 3: spit attack, frame 7
	; - 4: spit attack, frame 9
	ld a, (boss__state)
	or a
	jr z, update_boss7_behavior_1_state_0
	dec a
	jp z, update_boss7_behavior_1_state_1
	dec a
	jp z, update_boss7_behavior_1_state_2
	dec a
	jp z, update_boss7_behavior_1_state_3
	dec a
	jp z, update_boss7_behavior_1_state_4
	ret

update_boss7_behavior_1_state_0:
	call update_boss7_behavior_1_maybe_fire_bullet
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	or a
	push af
		jr nz, update_boss7_behavior_1_state_0_continue
		ld a, 6
		call update_boss7_draw_phase1_boss_frame
update_boss7_behavior_1_state_0_continue:
	pop af
	and #07
	cp #07
	ret nz
	ld a, (boss__settings + BOSS_7_POISON_ATTACK_MASK)
	ld b, a
	call random_a
	ld c, a
	and b
	jp z, update_boss7_behavior_1_to_state_3
	ld a, c
	and #03
	ret nz
	ld a, c
	rrca
	rrca
	and #07
	jr z, update_boss7_behavior_1_to_state_2
	ld a, 1
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret

update_boss7_behavior_1_state_1:
	call update_boss7_behavior_1_maybe_fire_bullet
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	or a
	push af
		jr nz, update_boss7_behavior_1_state_1_continue
		ld a, 8
		call update_boss7_draw_phase1_boss_frame
update_boss7_behavior_1_state_1_continue:
	pop af
	and #07
	cp #07
	ret nz
	ld a, (boss__settings + BOSS_7_POISON_ATTACK_MASK)
	ld b, a
	call random_a
	ld c, a
	and b
	jp z, update_boss7_behavior_1_to_state_4
	ld a, c
	and #03
	ret nz
	ld a, c
	rrca
	rrca
	and #07
	jr z, update_boss7_behavior_1_to_state_2
update_boss7_behavior_1_to_state_0:
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret

update_boss7_behavior_1_to_state_2:
	ld a, 2
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
update_boss7_behavior_1_state_2:
	; hide inside statue, steps:
	; - 0: frame 6
	; - 1: frame 5
	; - 2: frame 4
	; - 3: frame 3
	; - 4: frame 2
	; - 5: frame 1
	; - 6 - 15: hidden
	; - 16: if player is far, go back to 15
	; - 17: frame 1
	; - 18: frame 2
	; - 19: frame 3
	; - 20: frame 4
	; - 21: frame 5
	; - 22: go to state 0
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	ld c, a
	and #07
	ret nz
	ld a, c
	rrca
	rrca
	rrca
	and #1f
	cp 22
	jp z, update_boss7_behavior_1_to_state_0
	cp 16
	jr z, update_boss7_behavior_1_state_2_check_if_player_is_close
	ld c, 6
	or a
	jr z, update_boss7_behavior_1_state_2_frame_set
	dec c  ; c = 5
	cp 1
	jr z, update_boss7_behavior_1_state_2_frame_set
	cp 21
	jr z, update_boss7_behavior_1_state_2_frame_set
	dec c  ; c = 4
	cp 2
	jr z, update_boss7_behavior_1_state_2_frame_set
	cp 20
	jr z, update_boss7_behavior_1_state_2_frame_set
	dec c  ; c = 3
	cp 3
	jr z, update_boss7_behavior_1_state_2_frame_set
	cp 19
	jr z, update_boss7_behavior_1_state_2_frame_set
	dec c  ; c = 2
	cp 4
	jr z, update_boss7_behavior_1_state_2_frame_set
	cp 18
	jr z, update_boss7_behavior_1_state_2_frame_set
	dec c  ; c = 1
	cp 5
	jr z, update_boss7_behavior_1_state_2_frame_set
	cp 17
	jr z, update_boss7_behavior_1_state_2_frame_set
	ld c, 0
update_boss7_behavior_1_state_2_frame_set:
	ld a, c
	jp update_boss7_draw_phase1_boss_frame

update_boss7_behavior_1_state_2_check_if_player_is_close:
	ld a, (player_x + 1)
	cp 48
	ret nc
	; player is far, wait inside the statue:
	ld a, 15*8
	ld (boss__state_timer), a
	ret

update_boss7_behavior_1_to_state_3:
	ld a, (player_x + 1)
	cp 49
	ret nc  ; if player is too to the right, do not spit poison
	ld a, 3
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss7_behavior_1_state_3:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	or a
	push af
		ld a, 7
		call z, update_boss7_draw_phase1_boss_frame
		ld a, (boss__settings + BOSS_7_WAIT_TIME_OFFSET)
		ld c, a
	pop af
	; spit poison:
	ld de, #0933  ; 51, 9
update_boss7_behavior_1_state_3_spit_poison_de_set:
	sub c
	ret c
	ld c, a
	and #03  ; fire one poison spit each 4 frames
	ret nz
	ld a, c
	rrca
	rrca
	and #3f
	ld hl, boss__settings + BOSS_7_N_POISON_SPITS
	cp (hl)
	jp z, update_boss7_behavior_1_to_state_0
	ld a, (player_x + 1)
	cp 49
	jp nc, update_boss7_behavior_1_to_state_0  ; if player is too to the right, do not spit poison

	ld b, d
	ld ix, #0000
	; - e, b: tile coordinate from where the bullet is fired
	; - ixl, ixh: pixel offset	
	ld hl, boss_fire_directional_bullet_towards_player_with_random_offset_e_b
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
	ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BOSS7_POISON_SPIT
	ret

update_boss7_behavior_1_to_state_4:
	ld a, 4
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss7_behavior_1_state_4:
	ld hl, boss__state_timer
	ld a, (hl)
	inc (hl)
	or a
	push af
		ld a, 9
		call z, update_boss7_draw_phase1_boss_frame
		ld a, (boss__settings + BOSS_7_WAIT_TIME_OFFSET)
		ld c, a
	pop af
	; spit poison:
	ld de, #0833  ; 51, 8
	jp update_boss7_behavior_1_state_3_spit_poison_de_set

update_boss7_behavior_1_maybe_fire_bullet:
	; fire bullets through eyes
	ld a, (boss__settings + BOSS_7_EYE_BULLET_ATTACK_MASK)
	ld c, a
	call random_a
	and c
	ret nz
	ld hl, #0201
	ld bc, (boss__x2)
	add hl, bc
	ld e, l
	ld b, h
	ld ix, #0004
	; - c, b: tile coordinate from where the bullet is fired
	; - ixl, ixh: pixel offset	
	ld hl, boss_fire_directional_bullet_towards_player_with_random_offset_e_b
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000
	ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BULLET_IGNORING_WALLS
	ret


;-----------------------------------------------
; phase 2:
update_boss7_behavior_2:
	; states:
	; ...
; 	ld a, (boss__state)
; 	or a
; 	jr z, update_boss7_behavior_2_state_0
; 	dec a
; 	jp z, update_boss7_behavior_2_state_1
	; ...
	ret


;-----------------------------------------------
; phase 3:
update_boss7_behavior_3:
	; states:
	; ...
; 	ld a, (boss__state)
; 	or a
; 	jr z, update_boss7_behavior_3_state_0
; 	dec a
; 	jp z, update_boss7_behavior_3_state_1
	; ...
	ret


;-----------------------------------------------
; death:
update_boss7_behavior_4:
	; states:
	; ...
; 	ld a, (boss__state)
; 	or a
; 	jr z, update_boss7_behavior_4_state_0
; 	dec a
; 	jp z, update_boss7_behavior_4_state_1
	; ...
	ret


;-----------------------------------------------
; input:
; - a: snake frame to draw
update_boss7_draw_phase1_boss_frame:
	; in phase 1:
	; - frame 1 is the statue
	; - frame 2 is the snake
	push af
		ld hl, draw_boss_frame_clear_previous_frame_1
		ld c, BOSS_PAGE
		call call_hl_in_page_c_8000

		ld hl, draw_boss_frame_clear_previous_frame_2
		ld c, BOSS_PAGE
		call call_hl_in_page_c_8000

		; draw statue:
		ld hl, redraw_flags
		set ROOM_REDRAW_FLAG_BIT, (hl)

		; compute draw pointer:
		ld bc, (boss__x)
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn
		ld ix, boss7_statue_frame_1
		ld c, BOSS_PAGE
		ld hl, draw_boss_frame_1_without_clearing_ix
		call call_hl_in_page_c_8000
	pop af
	; draw snake:
	or a
	ret z
	dec a
	add a, a
	ld hl, boss7_phase1_frame_ptrs
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
		ld bc, (boss__x2)
		call get_room_tile_ptr
		ex de, hl  ; hl = ptr where the boss is to be drawn
	pop ix
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_2_without_clearing_ix
	jp call_hl_in_page_c_8000


;-----------------------------------------------
; input:
; - e: tile number that was hit
; - iyh: damage to deal
; - iyl: collision ID
; - ix: ptr of the tile we hit
player_weapon_hitbox_check_boss__boss7_hit:
	ld a, (boss__behavior)
	or a
	ret z

	; check if we have hit the face or tail:
	; ...
player_weapon_hitbox_check_boss__boss7_hit_vulnerable_spot:
	ld hl, player_weapon_hitbox_check_boss__lose_hp
	ld c, BOSS_PAGE
	jp call_hl_in_page_c_8000	

