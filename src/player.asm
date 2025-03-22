; When unit testing, we only want to import some parts of this file:
IF COLLISION_UNIT_TESTING == 0


;-----------------------------------------------
; Jump tables
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
	xor a
	ld (player_no_rope_or_ladder_this_frame), a
player_update_from_ladder_fail:
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
	ld ixh, a

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
	cp 16  ; also set early clock bit when we are close to the edge, for the weapon
	jr c, player_update_update_sprite_position_early_clock_bit
	cp 256 - (8 - PLAYER_COLLISION_WIDTH/2)
	jr c, player_update_update_sprite_position_no_early_clock_bit
player_update_update_sprite_position_early_clock_bit:
	add a, 32
	ld (de), a
	ld (bc), a
	ld ixl, a  ; we save 'x' for the weapon sprite

	inc de
	inc bc
	inc de
	inc bc

	ld a, COLOR_DARK_YELLOW | #80
	ld (de), a
	ld a, COLOR_DARK_RED | #80
	ld (bc), a
	ld iyl, #80
	jr player_update_update_sprite_weapon

player_update_update_sprite_position_no_early_clock_bit:
	ld (de), a
	ld (bc), a
	ld ixl, a  ; we save 'x' for the weapon sprite

	inc de
	inc bc
	inc de
	inc bc

	ld a, COLOR_DARK_YELLOW
	ld (de), a
	ld a, COLOR_DARK_RED
	ld (bc), a
	ld iyl, 0

player_update_update_sprite_weapon:
	inc bc  ; bc now points to the weapon sprite attributes
	ld a, (player_requested_weapon_sprite)
	cp #ff
	jr z, player_update_update_sprite_weapon_no_weapon
	ld a, (player_requested_weapon_sprite + 2)
	add a, ixh  ; y of the player sprite
	ld (bc), a  ; y
	inc bc
	ld a, (player_requested_weapon_sprite + 1)
	add a, ixl
	ld (bc), a  ; x
	inc bc
	inc bc
	ld a, iyl
	or COLOR_WHITE
	ld (bc), a  ; color / early clock bit
	ret


player_update_update_sprite_weapon_no_weapon:
	ld a, 200  ; outside of the screen
	ld (bc), a
	ret


player_update_state_fn_table:
	dw player_update_state_idle
	dw player_update_state_walking
	dw player_update_state_falling
	dw player_update_state_jumping
	dw player_update_state_crouching
	dw player_update_state_crawling
	dw player_update_state_rope
	dw player_update_state_ladder
	dw player_update_state_swimming	
	dw player_update_state_weapon_swing
	dw player_update_state_weapon_swing_jumping
	dw player_update_state_weapon_swing_falling
	dw player_update_state_weapon_swing_crouching


;-----------------------------------------------
player_update_switch_to_idle:
	ld hl, player_requested_weapon_sprite
	ld (hl), #ff  ; no weapon sprite
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

; 	ld a, (keyboard_line_clicks)
; 	bit 6, a
; 	jp nz, player_update_switch_to_crouching
	bit 6, a
	jp z, player_update_switch_to_crouching

	; check for rope/ladder climb:
	bit 5, a
	jp nz, player_update_state_idle_no_rope
	ld a, (player_no_rope_or_ladder_this_frame)
	or a
	jr nz, player_update_state_idle_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_idle_no_rope:
	; check for weapon:
	ld a, (keyboard_line_clicks)
	bit 0, a
	jp nz, player_update_switch_to_weapon_swing

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
	xor a
	ld (player_push_block_timer), a
	ld a, PLAYER_STATE_WALKING + 1
	ld (player_state), a
	jp player_update_state_walking

player_update_switch_to_walking_right:
	xor a
	ld (player_push_block_timer), a
	ld a, PLAYER_STATE_WALKING
	ld (player_state), a

player_update_state_walking:
	; check for rope climb:
	ld a, (keyboard_line_state)
	bit 5, a
	jp nz, player_update_state_walking_no_rope
	ld a, (player_no_rope_or_ladder_this_frame)
	or a
	jr nz, player_update_state_walking_no_rope	
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_walking_no_rope:

	; check for weapon:
	ld a, (keyboard_line_clicks)
	bit 0, a
	jp nz, player_update_switch_to_weapon_swing

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
	jr nz, player_update_state_walking_continue
	; collision: check if player is pushing a block:
	call player_pushing_right
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
	jr nz, player_update_state_walking_continue
	; collision: check if player is pushing a block:
	call player_pushing_left

player_update_state_walking_continue:
	ld a, (player_push_block_timer)
	or a
	jr nz, player_update_state_walking_continue_pushing
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #01
	add a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_walking_continue_pushing:
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	rrca
	and #01
	add a, 12
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
	; check for weapon:
	ld a, (keyboard_line_clicks)
	bit 0, a
	jp nz, player_update_switch_to_weapon_swing_falling

	; movement left/right:
	ld a, (keyboard_line_state)
	bit 7, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit 4, a
	call z, player_update_move_one_pixel_left_considering_collisions

	ld a, (player_no_rope_or_ladder_this_frame)
	or a
	jr nz, player_update_state_falling_no_rope
	ld a, (player_jump_no_grab_timer)
	or a
	jr z, player_update_state_falling_check_rope_or_ladder
	dec a
	ld (player_jump_no_grab_timer), a
	jp player_update_state_falling_no_rope
player_update_state_falling_check_rope_or_ladder:
	; check for rope climb:
	ld a, (keyboard_line_state)
	bit 5, a  ; up
	jp nz, player_update_state_falling_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_falling_no_rope:

	; check if we need to switch to idle:
	call player_check_collision_down_inc  ; a = tile type
	jp z, player_update_switch_to_idle

	; check if we need to swicth to swimming:
	call player_in_water
	jp z, player_update_switch_to_swimming_from_falling

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
player_update_switch_to_jumping_from_swimming:
	xor a
	ld (player_jump_no_grab_timer), a
	ld (player_jump_is_cancelable), a
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	call spawn_water_splash
	ld a, 3 ; skip the first jump states, to make the jump shorter
	ld (player_state_timer), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_JUMPING
	ld (player_state), a
	jp player_update_state_jumping  ; skip the rope check, to avoid an infinite loop

player_update_switch_to_jumping_from_rope_or_ladder:
	ld a, 10  ; do not graph to another ladder/rope for a few frames
	ld (player_jump_no_grab_timer), a
	ld a, 1
	ld (player_jump_is_cancelable), a
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
	ld a, 1
	ld (player_jump_is_cancelable), a
	ld hl, SFX_jump
	call play_SFX_with_high_priority
	xor a
	ld (player_jump_no_grab_timer), a
	ld (player_state_timer), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_JUMPING
	ld (player_state), a

player_update_state_jumping:
	; check for rope climb:
	ld a, (player_no_rope_or_ladder_this_frame)
	or a
	jr nz, player_update_state_jumping_no_rope
	ld a, (player_jump_no_grab_timer)
	or a
	jr z, player_update_state_jumping_check_rope_or_ladder
	dec a
	ld (player_jump_no_grab_timer), a
	jp player_update_state_jumping_no_rope
player_update_state_jumping_check_rope_or_ladder:
	ld a, (keyboard_line_state)
	bit 5, a  ; up
	jp nz, player_update_state_jumping_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_jumping_no_rope:

	; check for weapon:
	ld a, (keyboard_line_clicks)
	bit 0, a
	jp nz, player_update_switch_to_weapon_swing_jumping

	; movement left/right:
	ld a, (keyboard_line_state)
	bit 7, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit 4, a
	call z, player_update_move_one_pixel_left_considering_collisions

	ld a, (player_jump_is_cancelable)
	or a
	jr z, player_update_state_jumping_cannot_cancel
	; did the player release the jump key?
	; check for jump
	ld a, (keyboard_line_state + 2)
	bit 2, a
	call nz, player_update_stop_jumping
player_update_state_jumping_cannot_cancel:

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

player_update_stop_jumping:
	ld a, (player_state_timer)
	cp PLAYER_JUMP_STOP_INDEX
	ret nc
	ld a, PLAYER_JUMP_STOP_INDEX
	ld (player_state_timer), a
	ret


;-----------------------------------------------
player_update_switch_to_crouching:
	; recenter scroll:
	call maybe_recenter_scroll_recenter_x
	call maybe_recenter_scroll_recenter_y
player_update_switch_to_crouching_from_weapon:
	ld a, #ff
	ld (player_requested_weapon_sprite), a

	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_CROUCHING
	ld (player_state), a

player_update_state_crouching:
	; check for weapon swing:
	ld a, (keyboard_line_clicks + 0)
	bit 0, a
	jp nz, player_update_switch_to_weapon_swing_crouching

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
	; check for weapon swing:
	ld a, (keyboard_line_clicks)
	bit 0, a
	jp nz, player_update_switch_to_weapon_swing_crouching

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
	jp player_update_switch_to_crouching

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
; input:
; - a: 0 for rope, 2 for ladder
; - c: coordinate where the rope/ladder was found
player_update_switch_to_rope_or_ladder_from_platform:
	push af
		ld a, (player_y + 1)
		inc a
		ld (player_y + 1), a
	pop af
player_update_switch_to_rope_or_ladder:
	cp 2
	jr z, player_update_switch_to_ladder
	ld a, c
	ld (player_x + 1), a
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
	jp nz, player_update_switch_to_jumping_from_rope_or_ladder

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
; input:
; - c: tile coordinate of the ladder 
player_update_switch_to_ladder:
	; check that player will not collide with anything when moving to the ladder (pushable block is the only option):
	push bc
		ld a, (player_y + 1)
		ld b, a
		inc b
		ld a, (player_y)
		or a
		jr z, player_update_switch_to_ladder_collision_check_continue
		inc b
player_update_switch_to_ladder_collision_check_continue:
		push bc
			call get_room_tile_type
		pop bc
		cp 2
		jr z, player_update_switch_to_ladder_failed
		cp 7
		jr z, player_update_switch_to_ladder_collision_check_continue2
		cp 8
		jr nz, player_update_switch_to_ladder_failed
player_update_switch_to_ladder_collision_check_continue2:
		inc c
		call get_room_tile_type
		cp 2
		jr z, player_update_switch_to_ladder_failed
	pop bc

	ld a, c
	ld (player_x + 1), a
	ld a, PLAYER_PIXEL_X_ON_LADDER
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
	jp nz, player_update_switch_to_jumping_from_rope_or_ladder

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

player_update_switch_to_ladder_failed:
	pop bc
	ld a, 1
	ld (player_no_rope_or_ladder_this_frame), a
	jp player_update_from_ladder_fail


;-----------------------------------------------
player_update_switch_to_swimming_from_falling:
	ld a, #ff
	ld (player_requested_weapon_sprite), a
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	call spawn_water_splash
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_SWIMMING
	ld (player_state), a

	xor a
	ld (player_water_inertia_x), a
	ld (player_water_inertia_x_timer), a
	ld (player_water_inertia_y_timer), a
	ld a, 1  ; max inertia down
	ld (player_water_inertia_y), a

player_update_state_swimming:
	ld a, (interrupt_cycle)
	and #01
	jp z, player_update_state_swimming_no_player_control
	; player control:
	ld a, (keyboard_line_state)  ; RIGHT, DOWN, UP, LEFT, DEL, INS, HOME, SPACE
	ld hl, player_water_inertia_x
	bit 4, a
	jr nz, player_update_state_swimming_no_left
	; left:
	ld a, (player_water_inertia_x)
	or a
	jr z, player_update_state_swimming_left_reset_inertia
	cp -1
	jr z, player_update_state_swimming_left_done
	cp PLAYER_MAX_SWIMMING_INERTIA_TIME
	jr z, player_update_state_swimming_left_reset_inertia
	inc a
	ld (player_water_inertia_x), a
	jp player_update_state_swimming_left_done
player_update_state_swimming_left_reset_inertia:
	ld a, -PLAYER_MAX_SWIMMING_INERTIA_TIME
	ld (player_water_inertia_x), a
player_update_state_swimming_left_done:
	ld a, (keyboard_line_state)
player_update_state_swimming_no_left:

	bit 7, a
	jr nz, player_update_state_swimming_no_right
	; right:
	ld a, (player_water_inertia_x)
	or a
	jr z, player_update_state_swimming_right_reset_inertia
	cp 1
	jr z, player_update_state_swimming_right_done
	cp -PLAYER_MAX_SWIMMING_INERTIA_TIME
	jr z, player_update_state_swimming_right_reset_inertia
	dec a
	ld (player_water_inertia_x), a
	jp player_update_state_swimming_right_done
player_update_state_swimming_right_reset_inertia:
	ld a, PLAYER_MAX_SWIMMING_INERTIA_TIME
	ld (player_water_inertia_x), a
player_update_state_swimming_right_done:
	ld a, (keyboard_line_state)
player_update_state_swimming_no_right:

	bit 5, a
	jr nz, player_update_state_swimming_no_up
	; up:
	ld a, (player_water_inertia_y)
	or a
	jr z, player_update_state_swimming_up_reset_inertia
	cp -1
	jr z, player_update_state_swimming_up_done
	cp PLAYER_MAX_SWIMMING_INERTIA_TIME
	jr z, player_update_state_swimming_up_reset_inertia
	inc a
	ld (player_water_inertia_y), a
	jp player_update_state_swimming_up_done
player_update_state_swimming_up_reset_inertia:
	ld a, -PLAYER_MAX_SWIMMING_INERTIA_TIME
	ld (player_water_inertia_y), a
player_update_state_swimming_up_done:
	ld a, (keyboard_line_state)
player_update_state_swimming_no_up:

	bit 6, a
	jr nz, player_update_state_swimming_no_down
	; down:
	ld a, (player_water_inertia_y)
	or a
	jr z, player_update_state_swimming_down_reset_inertia
	cp 1
	jr z, player_update_state_swimming_down_done
	cp -PLAYER_MAX_SWIMMING_INERTIA_TIME
	jr z, player_update_state_swimming_down_reset_inertia
	dec a
	ld (player_water_inertia_y), a
	jp player_update_state_swimming_down_done
player_update_state_swimming_down_reset_inertia:
	ld a, PLAYER_MAX_SWIMMING_INERTIA_TIME
	ld (player_water_inertia_y), a
player_update_state_swimming_down_done:
player_update_state_swimming_no_down:

player_update_state_swimming_no_player_control:

	; update inertia x:
	ld a, (player_water_inertia_x)
	or a
	jr z, player_update_state_swimming_inertia_x_done
	jp m, player_update_state_swimming_inertia_x_negative
	ld c, a
	ld hl, player_water_inertia_x_timer
	ld a, (hl)
	cp c
	inc (hl)
	jr c, player_update_state_swimming_inertia_x_done
	push hl
		call player_update_move_one_pixel_right_considering_collisions
	pop hl
	ld (hl), 0  ; reset timer
	ld hl, player_water_inertia_x
	ld a, (hl)
	cp PLAYER_MAX_SWIMMING_INERTIA_TIME  ; max inertia slowness
	jr z, player_update_state_swimming_clear_inertia_x
	inc (hl)  ; make inertia slower
	jp player_update_state_swimming_inertia_x_done
player_update_state_swimming_clear_inertia_x:
	ld (hl), 0
	jp player_update_state_swimming_inertia_x_done
player_update_state_swimming_inertia_x_negative:
	neg
	ld c, a
	ld hl, player_water_inertia_x_timer
	ld a, (hl)
	inc (hl)
	cp c
	jr c, player_update_state_swimming_inertia_x_done
	push hl
		call player_update_move_one_pixel_left_considering_collisions
	pop hl
	ld (hl), 0  ; reset timer
	ld hl, player_water_inertia_x
	ld a, (hl)
	cp -PLAYER_MAX_SWIMMING_INERTIA_TIME  ; max inertia slowness
	jr z, player_update_state_swimming_clear_inertia_x
	dec (hl)  ; make inertia slower
player_update_state_swimming_inertia_x_done:

	; update inertia y:
	ld a, (player_water_inertia_y)
	or a
	jr z, player_update_state_swimming_inertia_y_done
	jp m, player_update_state_swimming_inertia_y_negative
	ld c, a
	ld hl, player_water_inertia_y_timer
	ld a, (hl)
	inc (hl)
	cp c
	jr c, player_update_state_swimming_inertia_y_done
	push hl
		call player_update_move_one_pixel_down_considering_collisions
	pop hl
	ld (hl), 0  ; reset timer
	ld hl, player_water_inertia_y
	ld a, (hl)
	cp PLAYER_MAX_SWIMMING_INERTIA_TIME  ; max inertia slowness
	jr z, player_update_state_swimming_clear_inertia_y
	inc (hl)  ; make inertia slower
	jp player_update_state_swimming_inertia_y_done
player_update_state_swimming_clear_inertia_y:
	ld (hl), 0
	jp player_update_state_swimming_inertia_y_done
player_update_state_swimming_inertia_y_negative:
	neg
	ld c, a
	ld hl, player_water_inertia_y_timer
	ld a, (hl)
	inc (hl)
	cp c
	jr c, player_update_state_swimming_inertia_y_done
	push hl
		call player_update_move_one_pixel_up_considering_collisions
	pop hl
	ld (hl), 0  ; reset timer
	ld hl, player_water_inertia_y
	ld a, (hl)
	cp -PLAYER_MAX_SWIMMING_INERTIA_TIME  ; max inertia slowness
	jr z, player_update_state_swimming_clear_inertia_y
	dec (hl)  ; make inertia slower
player_update_state_swimming_inertia_y_done:

	; check if we are exiting the water:
	call player_in_water
	jp nz, player_update_switch_to_jumping_from_swimming

	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	rrca
	and #01
	add a, 10
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_weapon_swing:
	ld hl, SFX_weapon_swing
	call play_SFX_with_high_priority
	xor a
	ld (player_weapon_state_timer), a
player_update_switch_to_idle_keep_weapon:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_WEAPON_SWING
	ld (player_state), a

player_update_state_weapon_swing:
	ld hl, player_weapon_state_timer
	ld a, (hl)
	cp 8
	jp z,player_update_switch_to_idle
	inc (hl)

	; weapon sprite setup:
	ld hl, player_requested_weapon_sprite
	ld (hl), 0  ; weapon sprite
	inc hl
	ld a, (player_state)
	and #01
	jr z, player_update_state_weapon_swing_right
	ld (hl), -16  ; x offset
	jr player_update_state_weapon_swing_x_set
player_update_state_weapon_swing_right:
	ld (hl), 16  ; x offset
player_update_state_weapon_swing_x_set:
	inc hl
	ld (hl), 0  ; y offset

	ld a, 14
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_weapon_swing_jumping:
	ld hl, SFX_weapon_swing
	call play_SFX_with_high_priority
	xor a
	ld (player_weapon_state_timer), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_WEAPON_SWING_JUMPING
	ld (player_state), a

player_update_state_weapon_swing_jumping:
	ld a, (player_jump_no_grab_timer)
	or a
	jr z, player_update_state_weapon_swing_jumping_continue
	dec a
	ld (player_jump_no_grab_timer), a
player_update_state_weapon_swing_jumping_continue:
	; movement left/right:
	ld a, (keyboard_line_state)
	bit 7, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit 4, a
	call z, player_update_move_one_pixel_left_considering_collisions

	ld a, (player_jump_is_cancelable)
	or a
	jr z, player_update_state_weapon_swing_jumping_cannot_cancel
	; did the player release the jump key?
	; check for jump
	ld a, (keyboard_line_state + 2)
	bit 2, a
	call nz, player_update_stop_jumping
player_update_state_weapon_swing_jumping_cannot_cancel:

	; move up:
	ld a, (player_state_timer)
	inc a
	ld (player_state_timer), a
	ld hl, player_jump_speed_table - 1
	ADD_HL_A
	ld a, (hl)
	cp #ff
	jp z, player_update_switch_to_weapon_swing_falling_from_jumping
	ld b, a
	or a
	jr z, player_update_state_weapon_swing_jumping_speed_loop_done
player_update_state_weapon_swing_jumping_speed_loop:
	push bc
		call player_update_move_one_pixel_up_considering_collisions
	pop bc
	djnz player_update_state_weapon_swing_jumping_speed_loop
player_update_state_weapon_swing_jumping_speed_loop_done:

	ld hl, player_weapon_state_timer
	ld a, (hl)
	cp 8
	jr z, player_update_state_weapon_swing_jumping_swing_done
	inc (hl)

	; weapon sprite setup:
	ld hl, player_requested_weapon_sprite
	ld (hl), 0  ; weapon sprite
	inc hl
	ld a, (player_state)
	and #01
	jr z, player_update_state_weapon_swing_jumping_right
	ld (hl), -16  ; x offset
	jr player_update_state_weapon_swing_jumping_x_set
player_update_state_weapon_swing_jumping_right:
	ld (hl), 16  ; x offset
player_update_state_weapon_swing_jumping_x_set:
	inc hl
	ld (hl), 0  ; y offset

	ld a, 14
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_weapon_swing_jumping_swing_done:
	ld a, #ff
	ld (player_requested_weapon_sprite), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_JUMPING
	ld (player_state), a
	ld a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_weapon_swing_falling_from_jumping:
	xor a
	ld (player_state_timer), a
	jr player_update_switch_to_weapon_swing_falling_continue

player_update_switch_to_weapon_swing_falling:
	ld hl, SFX_weapon_swing
	call play_SFX_with_high_priority
	xor a
	ld (player_weapon_state_timer), a
player_update_switch_to_weapon_swing_falling_continue:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_WEAPON_SWING_FALLING
	ld (player_state), a

player_update_state_weapon_swing_falling:
	; movement left/right:
	ld a, (keyboard_line_state)
	bit 7, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit 4, a
	call z, player_update_move_one_pixel_left_considering_collisions

	ld a, (player_jump_no_grab_timer)
	or a
	jr z, player_update_state_weapon_swing_falling_continue
	dec a
	ld (player_jump_no_grab_timer), a
player_update_state_weapon_swing_falling_continue:

	; check if we need to switch to idle:
	call player_check_collision_down_inc  ; a = tile type
	jp z, player_update_switch_to_idle_keep_weapon

	; check if we need to swicth to swimming:
	call player_in_water
	jp z, player_update_switch_to_swimming_from_falling

	; move down:
	ld a, (player_state_timer)
	ld e, a
	inc e
	ld hl, player_fall_speed_table
	ADD_HL_A
	ld a, (hl)
	cp #ff
	jr nz, player_update_state_weapon_swing_falling_speed_determined
	dec e
	dec hl
	ld a, (hl)
player_update_state_weapon_swing_falling_speed_determined:
	ld b, a
	or a
	ld a, e
	ld (player_state_timer), a
	jr z, player_update_state_weapon_swing_falling_speed_loop_done
player_update_state_weapon_swing_falling_speed_loop:
	push bc
		call player_update_move_one_pixel_down_considering_collisions
	pop bc
	jr z, player_update_state_weapon_swing_falling_speed_loop_done
	djnz player_update_state_weapon_swing_falling_speed_loop
player_update_state_weapon_swing_falling_speed_loop_done:

	ld hl, player_weapon_state_timer
	ld a, (hl)
	cp 8
	jr z, player_update_state_weapon_swing_falling_swing_done
	inc (hl)

	; weapon sprite setup:
	ld hl, player_requested_weapon_sprite
	ld (hl), 0  ; weapon sprite
	inc hl
	ld a, (player_state)
	and #01
	jr z, player_update_state_weapon_swing_falling_right
	ld (hl), -16  ; x offset
	jr player_update_state_weapon_swing_falling_x_set
player_update_state_weapon_swing_falling_right:
	ld (hl), 16  ; x offset
player_update_state_weapon_swing_falling_x_set:
	inc hl
	ld (hl), 0  ; y offset

	ld a, 14
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_weapon_swing_falling_swing_done:
	ld a, #ff
	ld (player_requested_weapon_sprite), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_FALLING
	ld (player_state), a
	ld a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position



;-----------------------------------------------
player_update_switch_to_weapon_swing_crouching:
	ld hl, SFX_weapon_swing
	call play_SFX_with_high_priority
	xor a
	ld (player_weapon_state_timer), a
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_WEAPON_SWING_CROUCHING
	ld (player_state), a

player_update_state_weapon_swing_crouching:
	ld hl, player_weapon_state_timer
	ld a, (hl)
	cp 8
	jp z,player_update_switch_to_crouching_from_weapon
	inc (hl)

	; weapon sprite setup:
	ld hl, player_requested_weapon_sprite
	ld (hl), 0  ; weapon sprite
	inc hl
	ld a, (player_state)
	and #01
	jr z, player_update_state_weapon_swing_crouching_right
	ld (hl), -16  ; x offset
	jr player_update_state_weapon_swing_crouching_x_set
player_update_state_weapon_swing_crouching_right:
	ld (hl), 16  ; x offset
player_update_state_weapon_swing_crouching_x_set:
	inc hl
	ld (hl), 5  ; y offset

	ld a, 17
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_pushing_right:
	; check if there is a pushable block to the right
	ld a, (player_x + 1)
	inc a  ; the block should be to the right of the player
	ld e, a
	ld a, (player_y + 1)
	ld d, a
	ld hl, current_room__tile_objects
player_pushing_right_loop:
	ld a, (hl)  ; ID
	cp #ff
	jr z, player_pushing_right_no_block
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_PUSHABLE_BLOCK
		jp nz, player_pushing_right_loop_continue_pop
		; pushable block, see if it's the thing blocking the player's way:
		inc hl
		ld a, (hl)  ; x
		cp e
		jr nz, player_pushing_right_loop_continue_pop
		inc hl
		ld a, (hl)  ; y
		cp d
		jr nz, player_pushing_right_loop_continue_pop
	pop ix
	ld c, 1  ; pushing to the right
	jp player_pushing_block_found

player_pushing_right_loop_continue_pop:
	pop hl

	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp player_pushing_right_loop

player_pushing_right_no_block:
	xor a
	ld (player_push_block_timer), a
	ret


;-----------------------------------------------
player_pushing_left:
	; check if there is a pushable block to the left
	ld a, (player_x + 1)
	dec a
	dec a  ; the block should be to the left of the player
	ld e, a
	ld a, (player_y + 1)
	ld d, a
	ld hl, current_room__tile_objects
player_pushing_left_loop:
	ld a, (hl)  ; ID
	cp #ff
	jr z, player_pushing_left_no_block
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_PUSHABLE_BLOCK
		jp nz, player_pushing_left_loop_continue_pop
		; pushable block, see if it's the thing blocking the player's way:
		inc hl
		ld a, (hl)  ; x
		cp e
		jr nz, player_pushing_left_loop_continue_pop
		inc hl
		ld a, (hl)  ; y
		cp d
		jr nz, player_pushing_left_loop_continue_pop
		; we are pushing this block!
	pop ix
	ld c, -1  ; pushing left
	jp player_pushing_block_found

player_pushing_left_loop_continue_pop:
	pop hl

	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp player_pushing_left_loop

player_pushing_left_no_block:
	xor a
	ld (player_push_block_timer), a
	ret


;-----------------------------------------------
; input:
; - ix: ptr to object
; - c: direction to push (-1 left, 1 right)
player_pushing_block_found:
	ld a, (player_push_block_timer)
	inc a
	ld (player_push_block_timer), a
	cp PLAYER_PUSHING_TIME
	ret nz

	; check if the block would collide with something in the new position:
	push bc
		ld a, c  ; direction to push		
		ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
		ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
		or a
		jp p, player_pushing_block_found_right
		dec c  ; left
		jr player_pushing_block_found_continue
player_pushing_block_found_right:
		inc c  ; right
		inc c
player_pushing_block_found_continue:
		ld a, c
		or a
		jp m, player_pushing_block_found_no_collision
		ld a, (current_room__width)
		cp c
		jp z, player_pushing_block_found_no_collision
		jp c, player_pushing_block_found_no_collision

		; blocks collide with:
		;   1: platform (you can jump through)
		;   2: wall
		;   6: rope-platform-top
		;   8: ladder-platform-top
		push bc
			call get_room_tile_type
		pop bc
		dec a  ; 1
		jr z, player_pushing_block_found_collision
		dec a  ; 2
		jr z, player_pushing_block_found_collision
		cp 6 - 2  ; 6
		jr z, player_pushing_block_found_collision
		cp 8 - 2  ; 8
		jr z, player_pushing_block_found_collision

		inc b  ; check the tile below (blocks are 2 tiles tall)
		call get_room_tile_type
		dec a  ; 1
		jr z, player_pushing_block_found_collision
		dec a  ; 2
		jr z, player_pushing_block_found_collision
		cp 6 - 2  ; 6
		jr z, player_pushing_block_found_collision
		cp 8 - 2  ; 8
		jr z, player_pushing_block_found_collision

player_pushing_block_found_no_collision:
		; push block:
		push ix
			call room_remove_tile_objects
		pop ix
	pop bc
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)  ; block x
	add a, c
	ld (ix + ROOM_TILE_OBJECT_STRUCT_X), a

	; check if the object was pushed out of the room:
	cp -2
	jr z, player_pushing_block_found_out_of_screen
	ld c, a
	ld a, (current_room__width)
	cp c
	jr z, player_pushing_block_found_out_of_screen
player_pushing_block_found_continue2:
	call room_render_tile_objects
	; force redraw:
	xor a
	ld (player_push_block_timer), a
	inc a
	ld (redraw_whole_room_flag), a

	ld hl, SFX_push_object
	jp play_SFX_with_high_priority

player_pushing_block_found_collision:
	ld a, 1  ; 1 and not 0, so that the animation is not interrupted
	ld (player_push_block_timer), a
	pop bc
	ret

player_pushing_block_found_out_of_screen:
	push ix
	pop hl
	call delete_tile_object_in_hl
	jr player_pushing_block_found_continue2


; Anothing above this line is not imported when doing collision unit testing
ENDIF


;-----------------------------------------------
; output:
; - z: collision
; - nz: no collision
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
	ret  ; we must have "nz" here, since "inc (hl)" can never make that value 0
player_update_move_one_pixel_right_considering_collisions_continue:
	cp (8 - PLAYER_COLLISION_WIDTH) + 1
	ret nz  ; we do not need to check for collision
	call player_check_collision_right
	ret nz  ; no collision
	; collision, cannot move:
	ld hl, player_x
	ld (hl), 8 - PLAYER_COLLISION_WIDTH
	ret  ; we must have "z" here, as a result of 'player_check_collision_right'


;-----------------------------------------------
; output:
; - z: collision
; - nz: no collision
player_update_move_one_pixel_left_considering_collisions:
	ld a, (player_state)
	or #01
	ld (player_state), a
	ld hl, player_x
	ld a, (hl)
	dec a
	ld (hl), a
	inc a
	ret nz  ; we do not need to check for collision
	ld (hl), 7
	inc hl
	dec (hl)
	call player_check_collision_left
	ret nz  ; no collision
	; collision, cannot move:
	ld hl, player_x
	ld (hl), 0
	inc hl
	inc (hl)
	xor a  ; to indicate collision
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
