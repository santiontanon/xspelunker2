;-----------------------------------------------
; player_fall_speed_table:
;     db 1, 0, 1, 0
;     db 1, 1, 1, 1
;     db 2, 1, 2, 1
;     db 2, 2, 3, 3, 4, #ff  ; a bit floaty for 50Hz


; player_jump_speed_table:
; 	db 4, 4, 4, 4, 3, 3, 2, 2  ; 26 / 8
; 	db 2, 2, 2, 1, 2, 1, 2, 1  ; 13 / 8
; 	db 1, 1, 1  ; 3 / 3
; 	db 1, 0, 1, 0  ; 2 / 4
; 	db 0, #ff  ; 44 total jump height in 23 frames / a bit floaty for 50Hz


; When unit testing, we only want to import some parts of this file:
IF COLLISION_UNIT_TESTING == 0

player_fall_speed_table:
    db 1, 0, 1, 1, 2, 1
    db 2, 2, 3, 3, 4, #ff  ; good for 50Hz

PLAYER_JUMP_STOP_INDEX: equ 12  ; when we release the jump key, we will move to this index in the
								; jump speed table, if we are not already past that
player_jump_speed_table:
	db 6, 6, 6, 4, 4, 3, 3, 2
	db 2, 1, 2, 1, 1, 0, 1, 0, 0, 0, #ff  ; 1 / 3  ; 42 total jump height in 18 frames / good for 50Hz


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
	dw player_update_state_crouch
	dw player_update_state_crawling


;-----------------------------------------------
player_update_switch_to_idle:
	ld a, (player_state)
	and #01
	ld (player_state), a

player_update_state_idle:
	; check for walk/crouch:
	ld a, (keyboard_line_state)
	bit 7, a
	jr z, player_update_switch_to_walking_right
	bit 4, a
	jr z, player_update_switch_to_walking_left
	bit 6, a
	jp z, player_update_switch_to_crouch
	
	; check for jump
	ld a, (keyboard_line_clicks + 2)
	bit 2, a
	jp nz, player_update_switch_to_jumping

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
	ld a, (keyboard_line_clicks + 2)
	bit 2, a
	jp nz, player_update_switch_to_jumping

	; check for idle:
	ld a, (keyboard_line_state)
	bit 7, a
	jr z, player_update_state_walking_right
	bit 4, a
	jr z, player_update_state_walking_left
	jp player_update_switch_to_idle

player_update_state_walking_right:
	; check for crawling:
	ld a, (keyboard_line_state)
	bit 6, a
	jp z, player_update_switch_to_crawling_right

	; check for falling:
	call player_check_collision_down_inc
	jr nz, player_update_switch_to_falling

	call player_update_move_one_pixel_right_considering_collisions
	jr player_update_state_walking_continue

player_update_state_walking_left:
	; check for crawling:
	ld a, (keyboard_line_state)
	bit 6, a
	jp z, player_update_switch_to_crawling_left

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

player_update_state_falling:
	; movement left/right:
	ld a, (keyboard_line_state)
	bit 7, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit 4, a
	call z, player_update_move_one_pixel_left_considering_collisions

	; check if we need to switch to idle:
	call player_check_collision_down_inc
	jp z, player_update_switch_to_idle

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
	ld hl, SFX_jump
	call play_SFX_with_high_priority
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

	; did the player release the jump key?
	; check for jump
	ld a, (keyboard_line_state + 2)
	bit 2, a
	call nz, player_update_stop_jumping

	; move up:
	ld a, (player_state_timer)
	inc a
	ld (player_state_timer), a
player_update_stop_jumping_continue:
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

player_update_stop_jumping:
	ld a, (player_state_timer)
	cp PLAYER_JUMP_STOP_INDEX
	ret nc
	ld a, PLAYER_JUMP_STOP_INDEX
	ld (player_state_timer), a
	ret


;-----------------------------------------------
player_update_switch_to_crouch:
	; recenter scroll:
	call maybe_recenter_scroll_recenter_x
	call maybe_recenter_scroll_recenter_y

	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_CROUCH
	ld (player_state), a

player_update_state_crouch:
	; check for crawl:
	ld a, (keyboard_line_state)
	bit 7, a
	jr z, player_update_switch_to_crawling_right
	bit 4, a
	jr z, player_update_switch_to_crawling_left

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling

	; check for idle:
	ld a, (keyboard_line_state)
	bit 6, a
	jp nz, player_update_switch_to_idle

	ld a, 4
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_crawling_left:
	ld a, PLAYER_STATE_CRAWLING + 1
	ld (player_state), a
	jp player_update_state_crawling

player_update_switch_to_crawling_right:
	ld a, PLAYER_STATE_CRAWLING
	ld (player_state), a

player_update_state_crawling:
	; check for crouch:
	ld a, (keyboard_line_state)
	bit 7, a
	jr z, player_update_state_crawling_right
	bit 4, a
	jr z, player_update_state_crawling_left
	jp player_update_switch_to_crouch

player_update_state_crawling_right:
	; check for back to walking:
	ld a, (keyboard_line_state)
	bit 6, a
	jp nz, player_update_switch_to_walking_right

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling

	; move at half speed:
	ld a, (interrupt_cycle)
	and #01
	call z, player_update_move_one_pixel_right_considering_collisions
	jr player_update_state_crawling_continue

player_update_state_crawling_left:
	; check for back to walking:
	ld a, (keyboard_line_state)
	bit 6, a
	jp nz, player_update_switch_to_walking_left

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling

	; move at half speed:
	ld a, (interrupt_cycle)
	and #01
	call z, player_update_move_one_pixel_left_considering_collisions

player_update_state_crawling_continue:
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #01
	add a, 4
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


ENDIF


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
	jr c, player_update_move_one_pixel_right_considering_collisions_continue
	and #07
	ld (hl), a
	inc hl
	inc (hl)
player_update_move_one_pixel_right_considering_collisions_continue:
	cp 8 - PLAYER_COLLISION_BOX_WIDTH
	ret nz
	call player_check_collision_right
	ret nz
	; collision, cannot move:
	ld hl, player_x
	ld (hl), (8 - PLAYER_COLLISION_BOX_WIDTH) - 1
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
	jr nz, player_update_move_one_pixel_left_considering_collisions_continue
	ld (hl), 7
	inc hl
	dec (hl)
player_update_move_one_pixel_left_considering_collisions_continue:
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	ret nz
	call player_check_collision_left
	ret nz
	; collision, cannot move:
	ld hl, player_x
	ld (hl), PLAYER_COLLISION_BOX_WIDTH + 1
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
	; collision "up" has a "PLAYER_COLLISION_UP_LEEWAY" pixel leeway,
	; so we check collisions when going from "8 - PLAYER_COLLISION_UP_LEEWAY"
	; to "8 - PLAYER_COLLISION_UP_LEEWAY - 1" in "player_y":
	ld hl, player_y
	ld a, (hl)
	dec a
	ld (hl), a
	inc a
	jr nz, player_update_move_one_pixel_up_considering_collisions_continue
	ld (hl), 7
	inc hl
	dec (hl)
	ret
player_update_move_one_pixel_up_considering_collisions_continue:
	cp 8 - PLAYER_COLLISION_UP_LEEWAY
	ret nz
	call player_check_collision_up
	ret nz
	; collision, cannot move:
	ld hl, player_y
	ld (hl), 8 - PLAYER_COLLISION_UP_LEEWAY
	ret
