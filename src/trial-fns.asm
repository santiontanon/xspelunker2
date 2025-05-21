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


;-----------------------------------------------
maya_puzzle_trial_fn:
	ld a, (global_state__maya_riddle)
	or a
	jr z, maya_puzzle_trial_fn_first_line
	ld ix, current_world__maya_puzzle_riddles + 3
	jr maya_puzzle_trial_fn_continue
maya_puzzle_trial_fn_first_line:
	ld ix, current_world__maya_puzzle_riddles
maya_puzzle_trial_fn_continue:
	ld a, (ix)
	cp 11
	jr z, maya_puzzle_trial_fn_ascend_special_case
	; if the player is not in place, don't even check:
	call maya_puzzle_trial_fn_check_player_is_in_location
	jr nz, maya_puzzle_trial_fn_action_player_invalidated
	call maya_puzzle_trial_fn_check_player_has_not_done_something_illegal
	jr z, maya_puzzle_trial_fn_action_player_invalidated

	; in "even" states, we are waiting for the action,
	; in "odd" states, we are waiting for the action to stop.
	ld a, (player_trial_completion_state)
	and #1
	jr nz, maya_puzzle_trial_fn_continue_odd
	; even states:
	call maya_puzzle_trial_fn_check_player_has_done_the_action
	ret nz
maya_puzzle_trial_fn_one_instance_done:
	ld a, (player_trial_completion_state)
	inc a
	ld (player_trial_completion_state), a
	ret

maya_puzzle_trial_fn_continue_odd:
	; check that the action has finished:
	call maya_puzzle_trial_fn_check_player_has_done_the_action
	ret z
	ld a, (player_trial_completion_state)
	inc a
	ld (player_trial_completion_state), a
	srl a
	cp (ix + 2)  ; number of times we need to repeat
	ret nz
	; trial line solved!
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority
	ld a, (global_state__maya_riddle)
	or a
	jr z, maya_puzzle_trial_fn_solved_first_line
	; full riddle solved!
	ld a, 2
	ld (global_state__maya_riddle), a
	ld hl, 0
	ld (current_room__trial_fn), hl
	; activate teleporters:
	ld hl, buffer_4096 + 190 * 16  ; teleporter activated by player
	ld (large_object_to_upload_to_vdp), hl
	ld a, 12*8
	ld (large_object_to_upload_to_vdp_size), a

	ld hl, redraw_flags
	set REUPLOAD_INGAME_OBJECT_TILES_FLAG_BIT, (hl)
	ret	

maya_puzzle_trial_fn_action_player_invalidated:
	xor a
	ld (player_trial_completion_state), a
	ret

maya_puzzle_trial_fn_solved_first_line:
	; a == 0 here
	ld (player_trial_completion_state), a
	inc a
	ld (global_state__maya_riddle), a
	ret


maya_puzzle_trial_fn_ascend_special_case:
	; ...
	; jp to 'maya_puzzle_trial_fn_one_instance_done' each time player climbs the ladder once
	ret


maya_puzzle_trial_fn_check_player_has_done_the_action:
	ld a, (ix)
	ld hl, maya_puzzle_trial_fn_action_table
maya_puzzle_trial_fn_check_player_has_done_the_action_entry_point:
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp hl


maya_puzzle_trial_fn_check_player_is_in_location:
	ld a, (ix + 1)
	ld hl, maya_puzzle_trial_fn_location_table
	jr maya_puzzle_trial_fn_check_player_has_done_the_action_entry_point


maya_puzzle_trial_fn_check_player_has_not_done_something_illegal:
	ld a, (ix)
	ld hl, maya_puzzle_trial_fn_illegal_table
	jr maya_puzzle_trial_fn_check_player_has_done_the_action_entry_point



maya_puzzle_trial_fn_action_table:
	dw maya_puzzle_trial_fn_strike
	dw maya_puzzle_trial_fn_strike_east
	dw maya_puzzle_trial_fn_strike_west
	dw maya_puzzle_trial_fn_sit
	dw maya_puzzle_trial_fn_sit_east
	dw maya_puzzle_trial_fn_sit_west
	dw maya_puzzle_trial_fn_blowgun
	dw maya_puzzle_trial_fn_blowgun_east
	dw maya_puzzle_trial_fn_blowgun_west
	dw maya_puzzle_trial_fn_standup_w_e
	dw maya_puzzle_trial_fn_standup_e_w

maya_puzzle_trial_fn_illegal_table:
	dw maya_puzzle_trial_fn_illegal_strike
	dw maya_puzzle_trial_fn_illegal_strike_east
	dw maya_puzzle_trial_fn_illegal_strike_west
	dw maya_puzzle_trial_fn_illegal_sit
	dw maya_puzzle_trial_fn_illegal_sit_east
	dw maya_puzzle_trial_fn_illegal_sit_west
	dw maya_puzzle_trial_fn_illegal_blowgun
	dw maya_puzzle_trial_fn_illegal_blowgun_east
	dw maya_puzzle_trial_fn_illegal_blowgun_west
	dw maya_puzzle_trial_fn_illegal_standup_w_e
	dw maya_puzzle_trial_fn_illegal_standup_e_w

maya_puzzle_trial_fn_location_table:
	dw maya_puzzle_trial_fn_location_here
	dw maya_puzzle_trial_fn_location_below_jaguar
	dw maya_puzzle_trial_fn_location_above_jaguar
	dw maya_puzzle_trial_fn_location_below_snake
	dw maya_puzzle_trial_fn_location_above_snake
	dw maya_puzzle_trial_fn_location_below_eagle
	dw maya_puzzle_trial_fn_location_above_eagle
	dw maya_puzzle_trial_fn_location_below_fish
	dw maya_puzzle_trial_fn_location_above_fish
	dw maya_puzzle_trial_fn_location_below_ladder

maya_puzzle_trial_fn_strike:
	ld a, (player_state)
	and #fe  ; remove direction
	cp PLAYER_STATE_WEAPON_SWING
	ret

maya_puzzle_trial_fn_strike_east:
	ld a, (player_state)
	cp PLAYER_STATE_WEAPON_SWING  ; right
	ret

maya_puzzle_trial_fn_strike_west:
	ld a, (player_state)
	cp PLAYER_STATE_WEAPON_SWING + 1 ; left
	ret

maya_puzzle_trial_fn_sit:
	ld a, (player_state)
	and #fe  ; remove direction
	cp PLAYER_STATE_CROUCHING
	ret

maya_puzzle_trial_fn_sit_east:
	ld a, (player_state)
	cp PLAYER_STATE_CROUCHING
	ret

maya_puzzle_trial_fn_sit_west:
	ld a, (player_state)
	cp PLAYER_STATE_CROUCHING + 1
	ret

maya_puzzle_trial_fn_blowgun:
	ld a, (player_state)
	and #fe  ; remove direction
	cp PLAYER_STATE_DIRECTIONAL_WEAPON
	ret nz
	ld a, (player_current_item)
	cp 5  ; blowgun
	ret

maya_puzzle_trial_fn_blowgun_east:
	ld a, (player_state)
	cp PLAYER_STATE_DIRECTIONAL_WEAPON
	ret nz
	ld a, (player_current_item)
	cp 5  ; blowgun
	ret

maya_puzzle_trial_fn_blowgun_west:
	ld a, (player_state)
	cp PLAYER_STATE_DIRECTIONAL_WEAPON + 1
	ret nz
	ld a, (player_current_item)
	cp 5  ; blowgun
	ret

maya_puzzle_trial_fn_standup_w_e:
	ld a, (player_state)
	and #01
	xor #01
	ret

maya_puzzle_trial_fn_standup_e_w:
	ld a, (player_state)
	and #01
	ret


maya_puzzle_trial_fn_illegal_strike:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_JUMPING
	ret z
	cp PLAYER_STATE_CROUCHING
	ret z
	cp PLAYER_STATE_CRAWLING
	ret

maya_puzzle_trial_fn_illegal_strike_east:
	ld a, (player_state)
	and #01
	xor #01  ; if player is facing west, illegal!
	ret z
	jr maya_puzzle_trial_fn_illegal_strike

maya_puzzle_trial_fn_illegal_strike_west:
	ld a, (player_state)
	and #01  ; if player is facing east, illegal!
	ret z
	jr maya_puzzle_trial_fn_illegal_strike

maya_puzzle_trial_fn_illegal_sit:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_WEAPON_SWING
	ret z
	cp PLAYER_STATE_JUMPING
	ret

maya_puzzle_trial_fn_illegal_sit_east:
	ld a, (player_state)
	and #01
	xor #01  ; if player is facing west, illegal!
	ret z
	jr maya_puzzle_trial_fn_illegal_sit

maya_puzzle_trial_fn_illegal_sit_west:
	ld a, (player_state)
	and #01  ; if player is facing east, illegal!
	ret z
	jr maya_puzzle_trial_fn_illegal_sit

maya_puzzle_trial_fn_illegal_blowgun:
	ld a, (player_current_item)
	cp 5  ; blowgun
	jr nz, maya_puzzle_trial_fn_illegal_blowgun_fail
	jr maya_puzzle_trial_fn_illegal_strike
maya_puzzle_trial_fn_illegal_blowgun_fail:
	xor a
	ret

maya_puzzle_trial_fn_illegal_blowgun_east:
	ld a, (player_current_item)
	cp 5  ; blowgun
	jr nz, maya_puzzle_trial_fn_illegal_blowgun_fail
	jr maya_puzzle_trial_fn_illegal_strike_east

maya_puzzle_trial_fn_illegal_blowgun_west:
	ld a, (player_current_item)
	cp 5  ; blowgun
	jr nz, maya_puzzle_trial_fn_illegal_blowgun_fail
	jr maya_puzzle_trial_fn_illegal_strike_west

maya_puzzle_trial_fn_illegal_standup_w_e:
maya_puzzle_trial_fn_illegal_standup_e_w:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_JUMPING
	ret z
	cp PLAYER_STATE_CROUCHING
	ret z
	cp PLAYER_STATE_CRAWLING
	ret z
	cp PLAYER_STATE_WEAPON_SWING
	ret


maya_puzzle_trial_fn_location_here:
	ld a, (player_y + 1)
	cp 9
	ret nz
	ld a, (player_x + 1)
	sub 14
maya_puzzle_trial_fn_location_entry_point:
	ret c
	cp 4
	jr nc, maya_puzzle_trial_fn_location_here_fail
	xor a  ; in place!
	ret
maya_puzzle_trial_fn_location_here_fail:
	or 1
	ret

maya_puzzle_trial_fn_location_below_jaguar:
	ld a, (player_y + 1)
	cp 6
	ret nz
	ld a, (player_x + 1)
	sub 10
	jr maya_puzzle_trial_fn_location_entry_point

maya_puzzle_trial_fn_location_above_jaguar:
	ld a, (player_y + 1)
	cp 2
	ret nz
	ld a, (player_x + 1)
	sub 10
	jr maya_puzzle_trial_fn_location_entry_point

maya_puzzle_trial_fn_location_below_snake:
	ld a, (player_y + 1)
	cp 13
	ret nz
	ld a, (player_x + 1)
	sub 2
	jr maya_puzzle_trial_fn_location_entry_point

maya_puzzle_trial_fn_location_above_snake:
	ld a, (player_y + 1)
	cp 9
	ret nz
	ld a, (player_x + 1)
	sub 2
	jr maya_puzzle_trial_fn_location_entry_point

maya_puzzle_trial_fn_location_below_eagle:
	ld a, (player_y + 1)
	cp 6
	ret nz
	ld a, (player_x + 1)
	sub 18
	jr maya_puzzle_trial_fn_location_entry_point

maya_puzzle_trial_fn_location_above_eagle:
	ld a, (player_y + 1)
	cp 2
	ret nz
	ld a, (player_x + 1)
	sub 18
	jr maya_puzzle_trial_fn_location_entry_point

maya_puzzle_trial_fn_location_below_fish:
	ld a, (player_y + 1)
	cp 13
	ret nz
	ld a, (player_x + 1)
	sub 26
	jr maya_puzzle_trial_fn_location_entry_point

maya_puzzle_trial_fn_location_above_fish:
	ld a, (player_y + 1)
	cp 9
	ret nz
	ld a, (player_x + 1)
	sub 26
	jr maya_puzzle_trial_fn_location_entry_point

maya_puzzle_trial_fn_location_below_ladder:
	ld a, (player_y + 1)
	cp 16
	ret nz
	ld a, (player_x + 1)
	sub 14
	jr maya_puzzle_trial_fn_location_entry_point
