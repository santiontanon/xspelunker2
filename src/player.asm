;-----------------------------------------------
player_fall_speed_table:
    db 1, 0, 1, 0
    db 1, 1, 1, 1
    db 2, 1, 2, 1
    db 2, 2, 3, 3, 4, #ff  ; 50Hz


player_jump_speed_table:
	db 4, 4, 4, 4, 3, 3, 2, 2  ; 26
	db 2, 2, 2, 1, 2, 1, 2, 1  ; 13 -> 39
	db 1, 1, 1  ; 3 -> 42
	db 1, 0, 1, 0  ; 2 -> 44
	db 0, #ff  ; 44 total jump height / 50Hz


;-----------------------------------------------
player_update:
	ld a, (player_state)
	ld hl, player_update_state_fn_table
	and #fe  ; lowest bit is direction (0: right, 1: left)
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex hl, de
	jp hl


;-----------------------------------------------
player_update_update_sprite_position:
	ld de, sprite_attribute_table
	ld bc, sprite_attribute_table + 4

	ld a, (player_y + 1)
	ld hl, room_scroll_y
	sub (hl)
	add a, a
	add a, a
	add a, a
	ld hl, player_y
	add a, (hl)
	dec a  ; sprites y in the VDP is off by 1 pixel

	ld (de), a
	ld (bc), a
	inc de
	inc bc

	ld a, (player_x + 1)
	ld hl, room_scroll_x
	sub (hl)
	add a, a
	add a, a
	add a, a
	ld hl, player_x
	add a, (hl)

	ld (de), a
	ld (bc), a
	ret


player_update_state_fn_table:
	dw player_update_state_idle
	dw player_update_state_walking
	dw player_update_state_falling
	dw player_update_state_jumping


;-----------------------------------------------
player_update_switch_to_idle:
	ld a, (player_state)
	and #01
	ld (player_state), a

player_update_state_idle:
	; check for walk:
	ld a, (keyboard_line_state)
	bit 7, a
	jr z, player_update_switch_to_walking_right
	bit 4, a
	jr z, player_update_switch_to_walking_left
	; check for jump
	ld a, (keyboard_line_state + 2)
	bit 2, a
	jp z, player_update_switch_to_jumping

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling

	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	rrca
	and #01
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_walking_left:
	ld a, PLAYER_STATE_WALKING + 1
	ld (player_state), a
	jp player_update_state_walking

player_update_switch_to_walking_right:
	ld a, PLAYER_STATE_WALKING
	ld (player_state), a

player_update_state_walking:
	; check for jump
	ld a, (keyboard_line_state + 2)
	bit 2, a
	jp z, player_update_switch_to_jumping

	; check for idle:
	ld a, (keyboard_line_state)
	bit 7, a
	jr z, player_update_state_walking_right
	bit 4, a
	jr z, player_update_state_walking_left
	jp player_update_switch_to_idle

player_update_state_walking_right:
	; check for falling:
	call player_check_collision_down_inc
	jr nz, player_update_switch_to_falling

	call player_update_move_one_pixel_right_considering_collisions
	jr player_update_state_walking_continue

player_update_state_walking_left:
	; check for falling:
	call player_check_collision_down_inc
	jr nz, player_update_switch_to_falling

	call player_update_move_one_pixel_left_considering_collisions

player_update_state_walking_continue:
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #01
	add a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_falling:
	xor a
	ld (player_state_timer), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_FALLING
	ld (player_state), a
	jr player_update_state_falling_post_collision_check


player_update_state_falling:
	; check if we need to switch to idle:
	call player_check_collision_down_inc
	jp z, player_update_switch_to_idle

player_update_state_falling_post_collision_check:
	; movement left/right:
	ld a, (keyboard_line_state)
	bit 7, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit 4, a
	call z, player_update_move_one_pixel_left_considering_collisions

	; move down:
	ld a, (player_state_timer)
	ld e, a
	inc e
	ld hl, player_fall_speed_table
	ADD_HL_A
	ld a, (hl)
	cp #ff
	jr nz, player_update_state_falling_speed_determined
	dec e
	dec hl
	ld a, (hl)
player_update_state_falling_speed_determined:
	ld b, a
	or a
	ld a, e
	ld (player_state_timer), a
	jr z, player_update_state_falling_speed_loop_done
player_update_state_falling_speed_loop:
	push bc
		call player_update_move_one_pixel_down
		call player_check_collision_down_inc
	pop bc
	jr z, player_update_state_falling_speed_loop_done
	djnz player_update_state_falling_speed_loop
player_update_state_falling_speed_loop_done:
	ld a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_jumping:
	xor a
	ld (player_state_timer), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_JUMPING
	ld (player_state), a

player_update_state_jumping:
	; movement left/right:
	ld a, (keyboard_line_state)
	bit 7, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit 4, a
	call z, player_update_move_one_pixel_left_considering_collisions

	; move up:
	ld a, (player_state_timer)
	inc a
	ld (player_state_timer), a
	ld hl, player_jump_speed_table - 1
	ADD_HL_A
	ld a, (hl)
	cp #ff
	jp z, player_update_switch_to_falling
	ld b, a
	or a
	jr z, player_update_state_jumping_speed_loop_done
player_update_state_jumping_speed_loop:
	push bc
		call player_update_move_one_pixel_up_considering_collisions
	pop bc
	djnz player_update_state_jumping_speed_loop
player_update_state_jumping_speed_loop_done:

	ld a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_move_one_pixel_right_considering_collisions:
	ld a, (player_state)
	and #fe
	ld (player_state), a
	ld hl, player_x
	ld a, (hl)
	inc a
	ld (hl), a
	cp 8
	ret c
	and #07
	ld (hl), a
	inc hl
	inc (hl)
	call player_check_collision_horizontal
	ret nz
	; collision, cannot move:
	ld hl, player_x
	ld (hl), 7
	inc hl
	dec (hl)
	ret


;-----------------------------------------------
player_update_move_one_pixel_left_considering_collisions:
	ld a, (player_state)
	or #01
	ld (player_state), a
	ld hl, player_x
	ld a, (hl)
	dec a
	ld (hl), a
	inc a
	ret nz
	ld (hl), 7
	inc hl
	dec (hl)
	call player_check_collision_horizontal
	ret nz
	; collision, cannot move:
	ld hl, player_x
	ld (hl), 0
	inc hl
	inc (hl)
	ret


;-----------------------------------------------
player_update_move_one_pixel_down:
	ld hl, player_y
	ld a, (hl)
	inc a
	ld (hl), a
	cp 8
	ret c
	and #07
	ld (hl), a
	inc hl
	inc (hl)
	ret


;-----------------------------------------------
player_update_move_one_pixel_up_considering_collisions:
	ld hl, player_y
	ld a, (hl)
	dec a
	ld (hl), a
	inc a
	ret nz
	ld (hl), 7
	inc hl
	dec (hl)
	call player_check_collision_up
	ret nz
	; collision, cannot move:
	ld hl, player_y
	ld (hl), 0
	inc hl
	inc (hl)
	ret
