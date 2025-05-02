;-----------------------------------------------
trial_fn_ptrs:
	dw trial_fn_kneel
	dw trial_fn_jump_x3
	dw trial_fn_attack_left_right
	dw trial_fn_wait
	dw trial_fn_attack_down
	dw trial_fn_crawl_left_right
	dw trial_fn_left_right_x3
	dw trial_fn_attack_x5


;-----------------------------------------------
trial_fn_kneel:
	call trial_fn_in_front_of_god_p
	jr nz, trial_fn_reset
	
	ld a, (player_state)
	and #fe  ; filter direction
	cp PLAYER_STATE_CROUCHING
	jr nz, trial_fn_reset

trial_fn_trial_completed:
	; trial completed:
	ld hl, 0
	ld (current_room__trial_fn), hl

	ld hl, global_state__objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld (hl), 1
	jp object_interaction_function_open_combination_lock_entry_point

trial_fn_reset:
	xor a
	ld (player_trial_completion_state), a
	ret


;-----------------------------------------------
; states:
; - 0: waiting to be in front of god
; - 1: waiting for jump
; - 2: waiting for non-jump
; - 3: waiting for jump
; - 4: waiting for non-jump
; - 5: waiting for jump
; - 6: waiting for non-jump
; - 7: done
trial_fn_jump_x3:
	ld a, (player_trial_completion_state)
	or a
	jr z, trial_fn_jump_x3_state_0
	dec a
	jr z, trial_fn_jump_x3_state_1
	dec a
	jr z, trial_fn_jump_x3_state_2
	dec a
	jr z, trial_fn_jump_x3_state_3
	dec a
	jr z, trial_fn_jump_x3_state_4
	dec a
	jr z, trial_fn_jump_x3_state_5
	dec a
	jr z, trial_fn_jump_x3_state_6
	call trial_fn_in_front_of_god_p
	jr nz, trial_fn_reset
	jr trial_fn_trial_completed

trial_fn_jump_x3_state_0:
trial_fn_attack_left_right_state_0:
	call trial_fn_in_front_of_god_p
	jr z, trial_fn_jump_x3_advance
	jr trial_fn_reset

trial_fn_jump_x3_state_1:
trial_fn_jump_x3_state_3:
trial_fn_jump_x3_state_5:
	ld a, (player_state)
	and #fe  ; filter direction
	cp PLAYER_STATE_JUMPING
	jr z, trial_fn_jump_x3_advance
	cp PLAYER_STATE_FALLING
	jr z, trial_fn_jump_x3_advance

	call trial_fn_in_front_of_god_p
	jr nz, trial_fn_reset
	ret

trial_fn_jump_x3_state_2:
trial_fn_jump_x3_state_4:
trial_fn_jump_x3_state_6:
	ld a, (player_state)
	and #fe  ; filter direction
	cp PLAYER_STATE_JUMPING
	ret z
	cp PLAYER_STATE_FALLING
	ret z

trial_fn_jump_x3_advance:
	ld a, (player_trial_completion_state)
	inc a
	ld (player_trial_completion_state), a	
	ret


;-----------------------------------------------
; states:
; - 0: waiting to be in front of god
; - 1: waiting for attack left
; - 2: waiting for no attack
; - 3: waiting for attack right
; - 4: success
trial_fn_attack_left_right:
	ld a, (player_trial_completion_state)
	or a
	jr z, trial_fn_attack_left_right_state_0
	dec a
	jr z, trial_fn_attack_left_right_state_1
	dec a
	jr z, trial_fn_attack_left_right_state_2
	dec a
	jr z, trial_fn_attack_left_right_state_3
	call trial_fn_in_front_of_god_p
	jr nz, trial_fn_reset
	jr trial_fn_trial_completed

trial_fn_attack_left_right_state_1:
	ld a, (player_state)
	cp PLAYER_STATE_WEAPON_SWING + 1  ; attack left
	jr z, trial_fn_jump_x3_advance
	call trial_fn_in_front_of_god_p
	jr nz, trial_fn_reset
	ret

trial_fn_attack_left_right_state_2:
	ld a, (player_state)
	cp PLAYER_STATE_WEAPON_SWING + 1  ; attack left
	ret z
	call trial_fn_in_front_of_god_p
	jr nz, trial_fn_reset
	jr trial_fn_jump_x3_advance

trial_fn_attack_left_right_state_3:
	ld a, (player_state)
	cp PLAYER_STATE_WEAPON_SWING  ; attack right
	jr z, trial_fn_jump_x3_advance
	call trial_fn_in_front_of_god_p
	jp nz, trial_fn_reset
	ret


;-----------------------------------------------
trial_fn_wait:
	call trial_fn_in_front_of_god_p
	jp nz, trial_fn_reset
	ld a, (interrupt_cycle)
	and #0f
	ret nz
	ld a, (player_trial_completion_state)
	inc a
	cp 25
	jp z, trial_fn_trial_completed
	ld (player_trial_completion_state), a
	ret


;-----------------------------------------------
trial_fn_attack_down:
	call trial_fn_in_front_of_god_p
	jp nz, trial_fn_reset
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_WEAPON_SWING_FALLING
	jp nz, trial_fn_reset
	ld a, (player_weapon_swing_type)
	cp PLAYER_WEAPON_SWING_MACHETE_DOWN
	jp nz, trial_fn_reset
	jp trial_fn_trial_completed


;-----------------------------------------------
trial_fn_crawl_left_right:
	call trial_fn_in_front_of_god_p
	jp nz, trial_fn_reset
	ld a, (player_trial_completion_state)
	or a
	jr z, trial_fn_crawl_left_right_state_0
	ld a, (player_state)
	cp PLAYER_STATE_CRAWLING
	jp z, trial_fn_trial_completed
	and #fe
	cp PLAYER_STATE_CRAWLING
	ret z
	cp PLAYER_STATE_CROUCHING
	ret z
	cp PLAYER_STATE_IDLE
	ret z
	jp trial_fn_reset


trial_fn_crawl_left_right_state_0:
	ld a, (player_state)
	cp PLAYER_STATE_CRAWLING + 1
	jp z, trial_fn_jump_x3_advance
	and #fe
	cp PLAYER_STATE_CROUCHING
	ret z
	cp PLAYER_STATE_IDLE
	ret z
	jp trial_fn_reset


;-----------------------------------------------
trial_fn_left_right_x3:
	call trial_fn_in_front_of_god_p
	jp nz, trial_fn_reset
	ld a, (player_trial_completion_state)
	or a
	jr z, trial_fn_left_right_x3_state_0
	dec a
	jr z, trial_fn_left_right_x3_state_1
	dec a
	jr z, trial_fn_left_right_x3_state_2
	dec a
	jr z, trial_fn_left_right_x3_state_3
	dec a
	jr z, trial_fn_left_right_x3_state_4
	dec a
	jr z, trial_fn_left_right_x3_state_5
	jp trial_fn_trial_completed

trial_fn_left_right_x3_state_0:
trial_fn_left_right_x3_state_2:
trial_fn_left_right_x3_state_4:
	ld a, (player_state)
	cp PLAYER_STATE_WALKING + 1
	jp z, trial_fn_jump_x3_advance
	and #fe
	cp PLAYER_STATE_WALKING
	ret z
	cp PLAYER_STATE_IDLE
	ret z
	jp trial_fn_reset

trial_fn_left_right_x3_state_1:
trial_fn_left_right_x3_state_3:
trial_fn_left_right_x3_state_5:
	ld a, (player_state)
	cp PLAYER_STATE_WALKING
	jp z, trial_fn_jump_x3_advance
	and #fe
	cp PLAYER_STATE_WALKING
	ret z
	cp PLAYER_STATE_IDLE
	ret z
	jp trial_fn_reset



;-----------------------------------------------
trial_fn_attack_x5:
	call trial_fn_in_front_of_god_p
	jp nz, trial_fn_reset
	ld a, (player_trial_completion_state)
	cp 10
	jp z, trial_fn_trial_completed
	and 1
	jr z, trial_fn_attack_x5_even_states
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_IDLE
	jp z, trial_fn_jump_x3_advance
	cp PLAYER_STATE_WEAPON_SWING
	ret z
	jp trial_fn_reset

trial_fn_attack_x5_even_states:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_WEAPON_SWING
	jp z, trial_fn_jump_x3_advance
	cp PLAYER_STATE_IDLE
	ret z
	jp trial_fn_reset


;-----------------------------------------------
trial_fn_in_front_of_god_p:
	call get_tile_object_behind_player
	jr z, trial_fn_in_front_of_god_p_no_god
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_TRIAL1_LOCK
	ret z
	cp TAG_TRIAL2_LOCK
	ret z
	cp TAG_TRIAL3_LOCK
	ret z
	cp TAG_TRIAL4_LOCK
	ret
trial_fn_in_front_of_god_p_no_god:
	or 1
	ret

