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
	sub 8 - PLAYER_COLLISION_WIDTH/2

	; set "early clock bit"?
	cp 256 - (8 - PLAYER_COLLISION_WIDTH/2)
	jr c, player_update_update_sprite_position_no_early_clok_bit
	add a, 32
	ld (de), a
	ld (bc), a

	inc de
	inc bc
	inc de
	inc bc

	ld a, COLOR_DARK_YELLOW | #80
	ld (de), a
	ld a, COLOR_DARK_RED | #80
	ld (bc), a
	ret

player_update_update_sprite_position_no_early_clok_bit:
	ld (de), a
	ld (bc), a

	inc de
	inc bc
	inc de
	inc bc

	ld a, COLOR_DARK_YELLOW
	ld (de), a
	ld a, COLOR_DARK_RED
	ld (bc), a
	ret


player_update_state_fn_table:
	dw player_update_state_idle
	dw player_update_state_walking
	dw player_update_state_falling
	dw player_update_state_jumping
	dw player_update_state_crouch
	dw player_update_state_crawling
	dw player_update_state_rope
	dw player_update_state_ladder


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

	ld a, (keyboard_line_clicks)
	bit 6, a
	jp nz, player_update_switch_to_crouch
	
	; check for rope/ladder climb:
	bit 5, a
	jp z, player_update_state_idle_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_idle_no_rope:

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
	; check for rope climb:
	ld a, (keyboard_line_state)
	bit 5, a
	jp nz, player_update_state_walking_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_walking_no_rope:

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

	; check for rope climb:
	ld a, (keyboard_line_state)
	bit 5, a  ; up
	jp nz, player_update_state_falling_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_falling_no_rope:

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
		call player_update_move_one_pixel_down_considering_collisions
	pop bc
	jr z, player_update_state_falling_speed_loop_done
	djnz player_update_state_falling_speed_loop
player_update_state_falling_speed_loop_done:
	ld a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_jumping_from_rope:
	ld a, (keyboard_line_state)
	bit 6, a  ; down
	jp z, player_update_switch_to_falling
	ld hl, SFX_jump
	call play_SFX_with_high_priority
	ld a, 4 ; skip the first jump states, to make the jump shorter
	ld (player_state_timer), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_JUMPING
	ld (player_state), a
	jp player_update_state_jumping_no_rope  ; skip the rope check, to avoid an infinite loop

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
	; check for rope climb:
	ld a, (keyboard_line_state)
	bit 5, a  ; up
	jp nz, player_update_state_jumping_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_jumping_no_rope:

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
	; check for inventory:
	ld a, (keyboard_line_clicks + 2)
	bit 2, a
	jp nz, state_inventory

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

	; if we are still here, player is still crouching, see if we are on top of a rope/ladder:
	call check_player_on_top_of_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder_from_platform

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
	; check for inventory:
	ld a, (keyboard_line_clicks + 2)
	bit 2, a
	jp nz, state_inventory
	
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

	; if we are still here, player is still crouching, see if we are on top of a rope/ladder:
	call check_player_on_top_of_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder_from_platform

	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #01
	add a, 4
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_rope_or_ladder_from_platform:
	push af
		ld a, (player_y + 1)
		inc a
		ld (player_y + 1), a
	pop af
player_update_switch_to_rope_or_ladder:
	cp 2
	jr z, player_update_switch_to_ladder
	; a - 1: amount we need to add to the tile coordinate to find the rope
; 	ld c, a
; 	dec c
; 	ld a, (player_x + 1)
; 	add a, c
; 	ld (player_x + 1), a
; 	ld a, 4
; 	ld (player_x), a
	ld a, 2
	ld (player_x), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_ROPE
	ld (player_state), a

player_update_state_rope:
	; move up and down:
	ld a, (interrupt_cycle)
	and #01
	ld a, (keyboard_line_state)
	jr z, player_update_state_rope_skip_movement
	bit 6, a  ; down
	push af
		jr nz, player_update_state_rope_continue
		call player_update_move_one_pixel_down_considering_collisions
		jr z, player_update_state_rope_switch_to_idle_pop
player_update_state_rope_continue:
	pop af
	bit 5, a  ; up
	push af
		call z, player_update_move_one_pixel_up_considering_collisions
	pop af
player_update_state_rope_skip_movement:
	bit 4, a  ; left
	jr nz, player_update_state_rope_continue2
	push af
		ld a, (player_state)
		or #01
		ld (player_state), a
	pop af
player_update_state_rope_continue2:
	bit 7, a  ; right
	jr nz, player_update_state_rope_continue3
	ld a, (player_state)
	and #fe
	ld (player_state), a
player_update_state_rope_continue3:

	; check for jump
	ld a, (keyboard_line_clicks + 2)
	bit 2, a
	jp nz, player_update_switch_to_jumping_from_rope

	call check_player_on_top_of_rope_or_ladder
	jr z, player_update_state_rope_continue4
	call check_player_on_rope_or_ladder
	jp nz, player_update_switch_to_idle
player_update_state_rope_continue4:

	ld a, (player_y)
	rrca
	rrca
	and #01
	add a, 6
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_rope_switch_to_idle_pop:
	pop af
	jp player_update_switch_to_idle


;-----------------------------------------------
player_update_switch_to_ladder:
; 	xor a
	ld a, 6
	ld (player_x), a  ; center the player on the ladder
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_LADDER
	ld (player_state), a

player_update_state_ladder:
	; move up and down:
	ld a, (interrupt_cycle)
	and #01
	ld a, (keyboard_line_state)
	jr z, player_update_state_ladder_skip_movement
	bit 6, a  ; down
	push af
		jr nz, player_update_state_ladder_continue
		call player_update_move_one_pixel_down_considering_collisions
		jr z, player_update_state_ladder_switch_to_idle_pop
player_update_state_ladder_continue:
	pop af
	bit 5, a  ; up
	push af
		call z, player_update_move_one_pixel_up_considering_collisions
	pop af
player_update_state_ladder_skip_movement:

	; check for jump
	ld a, (keyboard_line_clicks + 2)
	bit 2, a
	jp nz, player_update_switch_to_jumping_from_rope

	call check_player_on_top_of_rope_or_ladder
	jr z, player_update_state_ladder_continue2
	call check_player_on_rope_or_ladder
	jp nz, player_update_switch_to_idle
player_update_state_ladder_continue2:

	ld a, (player_y)
	rrca
	rrca
	and #01
	add a, 8
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_ladder_switch_to_idle_pop:
	pop af
	jp player_update_switch_to_idle

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
	jr nz, player_update_move_one_pixel_right_considering_collisions_continue
	ld (hl), 0
	inc hl
	inc (hl)
	ret
player_update_move_one_pixel_right_considering_collisions_continue:
	cp (8 - PLAYER_COLLISION_WIDTH) + 1
	ret nz
	call player_check_collision_right
	ret nz
	; collision, cannot move:
	ld hl, player_x
	ld (hl), 8 - PLAYER_COLLISION_WIDTH
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
	call player_check_collision_left
	ret nz
	; collision, cannot move:
	ld hl, player_x
	ld (hl), 0
	inc hl
	inc (hl)
	ret


;-----------------------------------------------
player_update_move_one_pixel_down_considering_collisions:
	call player_check_collision_down_inc
	ret z
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
	or 1  ; there was no collision
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
	cp PLAYER_COLLISION_UP_LEEWAY
	ret nz
	call player_check_collision_up
	ret nz
	; collision, cannot move:
	ld hl, player_y
	ld (hl), PLAYER_COLLISION_UP_LEEWAY
	ret
