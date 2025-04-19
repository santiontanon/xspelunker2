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

player_hurt_speed_table:
	db 2, 2, 1, 1, 1, 0, 1, 0
	db 0, 0, 0, 0, 0, 0, 0, 0, #ff


;-----------------------------------------------
player_update:
	; first thing is to check for collision with hazards (e.g. spikes):
	ld hl, player_immunity_timer
	ld a, (hl)
	or a
	jr nz, player_update_immune
	ld a, (player_health)
	or a
	jr z, player_update_continue
	ld e, 3  ; hazard
	call player_check_collision_idle_with_e
	call z, player_hit_hazard
	jr player_update_continue
player_update_immune:
	dec (hl)
player_update_continue:
	xor a
	ld (player_no_rope_or_ladder_this_frame), a
player_update_from_ladder_fail:

	; go to the inventory from any state:
	ld a, (keyboard_clicks)
	bit KEY_INVENTORY_BIT, a
	jr z, player_update_no_inventory
	SETMEGAROMPAGE_8000 TEXT_PAGE
	jp state_inventory
player_update_no_inventory:

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
player_hit_hazard:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_HURT
	ld (player_state), a
	xor a
	ld (player_state_timer), a	

player_lose_health:
	ld a, PLAYER_IMMUNITY_TIME
	ld (player_immunity_timer), a

	ld a, HUD_MAX_TIME
	ld (hud_redraw_timer), a
	ld hl, redraw_flags
	set HUD_REDRAW_FLAG_BIT, (hl)

	ld hl, player_health
	dec (hl)
	ld a, (hl)
	or a
	jr nz, player_hit_hazard_continue
	; player is dead:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_DEAD
	ld (player_state), a
player_hit_hazard_continue:
	ld hl, SFX_playerhit
	jp play_SFX_with_high_priority


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

	ld a, (config_hud_type)
	cp 2  ; full hud
	ld a, ixh
	jr nz, player_update_update_sprite_position_no_full_hud
	add a, 16  ; move sprites 16 pixels down
	ld ixh, a
player_update_update_sprite_position_no_full_hud:

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
	jr player_update_update_sprite_check_flashing

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

player_update_update_sprite_check_flashing:
	ld a, (player_immunity_timer)
	or a
	jr z, player_update_update_sprite_weapon
	; flashing:
	ld a, (interrupt_cycle)
	bit 2, a
	jr z, player_update_update_sprite_weapon
	; erase the player sprite:
	xor a
	ld (de), a
	ld (bc), a
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
	ld a, (player_current_item)
	cp 2  ; macuahuitl
	jr z, player_update_update_sprite_weapon_macuahuitl
	cp 8  ; obsidian knive
	jr z, player_update_update_sprite_weapon_obsidian_knive
	cp 9  ; fire hammer
	jr z, player_update_update_sprite_weapon_fire_hammer
	cp 10  ; ice macuahuitl
	jr z, player_update_update_sprite_weapon_ice_macuahuitl
	ld a, iyl
	or COLOR_GREY
	ld (bc), a  ; color / early clock bit
	ret
player_update_update_sprite_weapon_obsidian_knive:
player_update_update_sprite_weapon_ice_macuahuitl:
	ld a, iyl
	or COLOR_BLUE
	ld (bc), a  ; color / early clock bit
	ret
player_update_update_sprite_weapon_fire_hammer:
	ld a, iyl
	or COLOR_RED
	ld (bc), a  ; color / early clock bit
	ret
player_update_update_sprite_weapon_macuahuitl:
	ld a, iyl
	or COLOR_LIGHT_RED
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
	dw player_update_state_directional_weapon
	dw player_update_state_directional_weapon_jumping
	dw player_update_state_directional_weapon_falling
	dw player_update_state_directional_weapon_crouching
	dw player_update_state_hurt
	dw player_update_state_dead


;-----------------------------------------------
player_update_switch_to_idle:
	ld hl, player_requested_weapon_sprite
	ld (hl), #ff  ; no weapon sprite
	ld a, (player_state)
	and #01
	ld (player_state), a

player_update_state_idle:
	; check for walk/crouch:
	ld a, (keyboard_state)
	bit KEY_RIGHT_BIT, a
	jr z, player_update_switch_to_walking_right
	bit KEY_LEFT_BIT, a
	jr z, player_update_switch_to_walking_left

	bit KEY_DOWN_BIT, a
	jp z, player_update_switch_to_crouching

	; check for rope/ladder climb:
	bit KEY_UP_BIT, a
	jp nz, player_update_state_idle_no_rope
	ld a, (player_no_rope_or_ladder_this_frame)
	or a
	jr nz, player_update_state_idle_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_idle_no_rope:
	; check for weapon:
	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a
	jp z, player_update_state_idle_no_weapon_swing
	ld a, (player_current_item)
	cp 12  ; first non-weapon
	jp c, player_update_switch_to_weapon_swing
	call player_update_interact
player_update_state_idle_no_weapon_swing:

	; check for jump
	ld a, (keyboard_clicks)
	bit KEY_JUMP_BIT, a
	jp nz, player_update_switch_to_jumping

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling

	; check for interact:
	ld a, (keyboard_clicks)
	bit KEY_INTERACT_BIT, a
	call nz, player_update_interact

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
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jp nz, player_update_state_walking_no_rope
	ld a, (player_no_rope_or_ladder_this_frame)
	or a
	jr nz, player_update_state_walking_no_rope	
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_walking_no_rope:

	; check for weapon:
	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a
	jp z, player_update_state_walking_no_weapon_swing
	ld a, (player_current_item)
	cp 12  ; first non-weapon
	jp c, player_update_switch_to_weapon_swing
	call player_update_interact
player_update_state_walking_no_weapon_swing:

	; check for jump
	ld a, (keyboard_clicks)
	bit KEY_JUMP_BIT, a
	jp nz, player_update_switch_to_jumping

	; check for interact:
	ld a, (keyboard_clicks)
	bit KEY_INTERACT_BIT, a
	call nz, player_update_interact

	; check for idle:
	ld a, (keyboard_state)
	bit KEY_RIGHT_BIT, a
	jr z, player_update_state_walking_right
	bit KEY_LEFT_BIT, a
	jr z, player_update_state_walking_left
	jp player_update_switch_to_idle

player_update_state_walking_right:
	; check for crawling:
	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
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
	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
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
	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a
	jp z, player_update_state_falling_no_weapon_swing
	ld a, (player_current_item)
	cp 12  ; first non-weapon
	jp c, player_update_switch_to_weapon_swing_falling
	call player_update_interact
player_update_state_falling_no_weapon_swing:

	; movement left/right:
	ld a, (keyboard_state)
	bit KEY_RIGHT_BIT, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit KEY_LEFT_BIT, a
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
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
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
	ld a, HUD_MAX_TIME
	ld (hud_redraw_timer), a
	ld hl, redraw_flags
	set HUD_REDRAW_FLAG_BIT, (hl)

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
	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
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
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jp nz, player_update_state_jumping_no_rope
	call check_player_on_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder
player_update_state_jumping_no_rope:

	; check for weapon:
	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a
	jp z, player_update_state_jumping_no_weapon_swing
	ld a, (player_current_item)
	cp 12  ; first non-weapon
	jp c, player_update_switch_to_weapon_swing_jumping
	call player_update_interact
player_update_state_jumping_no_weapon_swing:

	; movement left/right:
	ld a, (keyboard_state)
	bit KEY_RIGHT_BIT, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit KEY_LEFT_BIT, a
	call z, player_update_move_one_pixel_left_considering_collisions

	ld a, (player_jump_is_cancelable)
	or a
	jr z, player_update_state_jumping_cannot_cancel
	; did the player release the jump key?
	; check for jump
	ld a, (keyboard_state)
	bit KEY_JUMP_BIT, a
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
	; check for interact:
	ld a, (config_interact_with_down)
	or a
	call z, player_update_interact

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
	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a
	jp z, player_update_state_crouching_no_weapon_swing
	ld a, (player_current_item)
	cp 12  ; first non-weapon
	jp c, player_update_switch_to_weapon_swing_crouching
	call player_update_interact
player_update_state_crouching_no_weapon_swing:

	; check for inventory:
	ld a, (config_inventory_key_combo)
	or a
	jr nz, player_update_state_crouching_no_combo_for_inventory
	ld a, (keyboard_clicks)
	bit KEY_JUMP_BIT, a
	jp z, player_update_state_crouching_no_combo_for_inventory
	SETMEGAROMPAGE_8000 TEXT_PAGE
	jp state_inventory
player_update_state_crouching_no_combo_for_inventory:

	; check for crawl:
	ld a, (keyboard_state)
	bit KEY_RIGHT_BIT, a
	jr z, player_update_switch_to_crawling_right_from_crouching
	bit KEY_LEFT_BIT, a
	jr z, player_update_switch_to_crawling_left_from_crouching

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling

	; check for interact:
	ld a, (keyboard_clicks)
	bit KEY_INTERACT_BIT, a
	call nz, player_update_interact

	; check for idle:
	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
	jr z, player_update_state_crouching_still_crouching
	; check if there would be collision if we get up:
	call player_check_collision_idle
	jp nz, player_update_switch_to_idle
player_update_state_crouching_still_crouching:
	; See if we are on top of a rope/ladder:
	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
	jr nz, player_update_state_crouching_no_down  ; this could happen if player is not pressing down but with a collision on top preventing getting up
	call check_player_on_top_of_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder_from_platform
player_update_state_crouching_no_down:

	ld a, 4
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_crawling_left:
	; check for interact:
	ld a, (config_interact_with_down)
	or a
	call z, player_update_interact
player_update_switch_to_crawling_left_from_crouching:
	ld a, PLAYER_STATE_CRAWLING + 1
	ld (player_state), a
	jp player_update_state_crawling

player_update_switch_to_crawling_right:
	; check for interact:
	ld a, (config_interact_with_down)
	or a
	call z, player_update_interact
player_update_switch_to_crawling_right_from_crouching:
	ld a, PLAYER_STATE_CRAWLING
	ld (player_state), a

player_update_state_crawling:
	; check for weapon swing:
	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a
	jp z, player_update_state_crawling_no_weapon_swing
	ld a, (player_current_item)
	cp 12  ; first non-weapon
	jp c, player_update_switch_to_weapon_swing_crouching
	call player_update_interact
player_update_state_crawling_no_weapon_swing:

	; check for inventory:
	ld a, (keyboard_clicks)
	bit KEY_JUMP_BIT, a
	jp z, player_update_state_crawling_no_inventory
	SETMEGAROMPAGE_8000 TEXT_PAGE
	jp state_inventory
player_update_state_crawling_no_inventory:
	
	; check for interact:
	ld a, (keyboard_clicks)
	bit KEY_INTERACT_BIT, a
	call nz, player_update_interact

	; check for crouch:
	ld a, (keyboard_state)
	bit KEY_RIGHT_BIT, a
	jr z, player_update_state_crawling_right
	bit KEY_LEFT_BIT, a
	jr z, player_update_state_crawling_left
	jp player_update_switch_to_crouching

player_update_state_crawling_right:
	; check for back to walking:
	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
	jr z, player_update_state_crawling_right_still_crawling
	call player_check_collision_idle
	jp nz, player_update_switch_to_walking_right
player_update_state_crawling_right_still_crawling:

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
	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
	jr z, player_update_state_crawling_left_still_crawling
	call player_check_collision_idle
	jp nz, player_update_switch_to_walking_left
player_update_state_crawling_left_still_crawling:

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling

	; move at half speed:
	ld a, (interrupt_cycle)
	and #01
	call z, player_update_move_one_pixel_left_considering_collisions

player_update_state_crawling_continue:

	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
	jr nz, player_update_state_crawling_no_down  ; this could happen if player is not pressing down but with a collision on top preventing getting up
	; if we are still here, player is still crouching, see if we are on top of a rope/ladder:
	call check_player_on_top_of_rope_or_ladder
	jp z, player_update_switch_to_rope_or_ladder_from_platform
player_update_state_crawling_no_down:

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
	ld a, (keyboard_state)
	jr z, player_update_state_rope_skip_movement
	bit KEY_DOWN_BIT, a
	push af
		jr nz, player_update_state_rope_continue
		call player_update_move_one_pixel_down_considering_collisions
		jr z, player_update_state_rope_switch_to_idle_pop
player_update_state_rope_continue:
	pop af
	bit KEY_UP_BIT, a  ; up
	push af
		call z, player_update_move_one_pixel_up_considering_collisions
	pop af
player_update_state_rope_skip_movement:
	bit KEY_LEFT_BIT, a  ; left
	jr nz, player_update_state_rope_continue2
	push af
		ld a, (player_state)
		or #01
		ld (player_state), a
	pop af
player_update_state_rope_continue2:
	bit KEY_RIGHT_BIT, a  ; right
	jr nz, player_update_state_rope_continue3
	ld a, (player_state)
	and #fe
	ld (player_state), a
player_update_state_rope_continue3:

	; check for jump
	ld a, (keyboard_clicks)
	bit KEY_JUMP_BIT, a
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
	ld a, (keyboard_state)
	jr z, player_update_state_ladder_skip_movement
	bit KEY_DOWN_BIT, a  ; down
	push af
		jr nz, player_update_state_ladder_continue
		call player_update_move_one_pixel_down_considering_collisions
		jr z, player_update_state_ladder_switch_to_idle_pop
player_update_state_ladder_continue:
	pop af
	bit KEY_UP_BIT, a  ; up
	push af
		call z, player_update_move_one_pixel_up_considering_collisions
	pop af
player_update_state_ladder_skip_movement:

	; check for jump
	ld a, (keyboard_clicks)
	bit KEY_JUMP_BIT, a
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

	ld a, PLAYER_MAX_OXYGEN
	ld (player_oxygen), a
	ld a, HUD_MAX_TIME
	ld (hud_redraw_timer), a
	ld hl, redraw_flags
	set HUD_REDRAW_FLAG_BIT, (hl)

player_update_state_swimming:
	ld a, (interrupt_cycle)
	and #0f
	jr nz, player_update_state_swimming_oxygen_done
	ld a, (player_oxygen)
	or a
	jr z, player_update_state_swimming_oxygen_zero
	dec a
	ld (player_oxygen), a
	jr player_update_state_swimming_oxygen_non_zero
player_update_state_swimming_oxygen_zero:
	ld a, (player_immunity_timer)
	or a
	call z, player_lose_health
player_update_state_swimming_oxygen_non_zero:
	ld a, HUD_MAX_TIME
	ld (hud_redraw_timer), a
	ld hl, redraw_flags
	set HUD_REDRAW_FLAG_BIT, (hl)
player_update_state_swimming_oxygen_done:

	ld a, (interrupt_cycle)
	and #01
	jp z, player_update_state_swimming_no_player_control
	; player control:
	ld a, (keyboard_state)
	ld hl, player_water_inertia_x
	bit KEY_LEFT_BIT, a
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
	ld a, (keyboard_state)
player_update_state_swimming_no_left:

	bit KEY_RIGHT_BIT, a
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
	ld a, (keyboard_state)
player_update_state_swimming_no_right:

	bit KEY_UP_BIT, a
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
	ld a, (keyboard_state)
player_update_state_swimming_no_up:

	bit KEY_DOWN_BIT, a
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
	call get_next_hit_id
	ld (player_current_swing_hit_id), a
	call player_update_determine_weapon_swing_type
	jp nz, player_update_switch_to_directional_weapon
player_update_switch_to_idle_keep_weapon:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_WEAPON_SWING
	ld (player_state), a

player_update_state_weapon_swing:
	ld hl, player_weapon_state_timer
	ld a, (hl)
	or a
	jp z,player_update_switch_to_idle
	dec (hl)
	jp player_update_weapon_sprite_request


;-----------------------------------------------
player_update_switch_to_weapon_swing_jumping:
	call get_next_hit_id
	ld (player_current_swing_hit_id), a
	call player_update_determine_weapon_swing_type_jumping
	jp nz, player_update_switch_to_directional_weapon_jumping
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
	ld a, (keyboard_state)
	bit KEY_RIGHT_BIT, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit KEY_LEFT_BIT, a
	call z, player_update_move_one_pixel_left_considering_collisions

	ld a, (player_jump_is_cancelable)
	or a
	jr z, player_update_state_weapon_swing_jumping_cannot_cancel
	; did the player release the jump key?
	; check for jump
	ld a, (keyboard_state)
	bit KEY_JUMP_BIT, a
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
	or a
	jr z, player_update_state_weapon_swing_jumping_swing_done
	dec (hl)

	jp player_update_weapon_sprite_request

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
	call get_next_hit_id
	ld (player_current_swing_hit_id), a
	call player_update_determine_weapon_swing_type_jumping
	jp nz, player_update_switch_to_directional_weapon_falling
player_update_switch_to_weapon_swing_falling_continue:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_WEAPON_SWING_FALLING
	ld (player_state), a

player_update_state_weapon_swing_falling:
	; movement left/right:
	ld a, (keyboard_state)
	bit KEY_RIGHT_BIT, a
	push af
		call z, player_update_move_one_pixel_right_considering_collisions
	pop af
	bit KEY_LEFT_BIT, a
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
	or a
	jr z, player_update_state_weapon_swing_falling_swing_done
	dec (hl)

	jp player_update_weapon_sprite_request

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
	call get_next_hit_id
	ld (player_current_swing_hit_id), a
	call player_update_determine_weapon_swing_type_crouching
	jp nz, player_update_switch_to_directional_weapon_crouching
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_WEAPON_SWING_CROUCHING
	ld (player_state), a

player_update_state_weapon_swing_crouching:
	ld hl, player_weapon_state_timer
	ld a, (hl)
	or a
	jp z,player_update_switch_to_crouching_from_weapon
	dec (hl)

	jp player_update_weapon_sprite_request


;-----------------------------------------------
player_update_switch_to_directional_weapon:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_DIRECTIONAL_WEAPON
	ld (player_state), a
player_update_state_directional_weapon:
	; check for weapon:
	ld a, (keyboard_state)
	bit KEY_WEAPON_BIT, a
	jp z, player_update_state_directional_weapon_still_holding_fire
	call player_update_fire_directional_bullet
	jp player_update_switch_to_idle
player_update_state_directional_weapon_still_holding_fire:
	bit KEY_DOWN_BIT, a
	jp z, player_update_switch_to_directional_weapon_crouching

	; check for change of direction:
	ld a, (keyboard_clicks)
	bit KEY_LEFT_BIT, a  ; left
	jp z, player_update_state_directional_weapon_no_left
	ld a, (player_state)
	or 1
	ld (player_state), a
player_update_state_directional_weapon_no_left:
	ld a, (keyboard_clicks)
	bit KEY_RIGHT_BIT, a  ; right
	jp z, player_update_state_directional_weapon_no_right
	ld a, (player_state)
	and #fe
	ld (player_state), a
player_update_state_directional_weapon_no_right:

	; check for jump
	ld a, (keyboard_clicks)
	bit KEY_JUMP_BIT, a
	jp nz, player_update_switch_to_directional_weapon_jumping_from_idle

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling_with_directional

	ld a, (player_current_item)
	cp 3  ; shield
	jr z, player_update_state_directional_weapon_shield

	; regular directional weapons:
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jr nz, player_update_state_directional_weapon_no_up
	bit KEY_LEFT_BIT, a
	jr z, player_update_state_directional_weapon_diagonal_up
	bit KEY_RIGHT_BIT, a
	jr z, player_update_state_directional_weapon_diagonal_up
	; pointing the weapon up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_UP
	ld (player_weapon_swing_type), a
	ld a, 29
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_diagonal_up:
	; pointing the weapon diagonal-up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_FW_UP
	ld (player_weapon_swing_type), a
	ld a, 28
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_no_up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_FW
	ld (player_weapon_swing_type), a
	ld a, 27
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_directional_weapon_shield:
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jr nz, player_update_state_directional_weapon_shield_no_up
	; pointing the shield up:
	ld a, PLAYER_WEAPON_SHIELD_UP
	ld (player_weapon_swing_type), a
	ld a, 22
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_shield_no_up:
	ld a, PLAYER_WEAPON_SHIELD_FORWARD
	ld (player_weapon_swing_type), a
	ld a, 21
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_directional_weapon_jumping_from_idle:
	ld a, 1
	ld (player_jump_is_cancelable), a
	ld hl, SFX_jump
	call play_SFX_with_high_priority
	xor a
	ld (player_state_timer), a
player_update_switch_to_directional_weapon_jumping:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_DIRECTIONAL_WEAPON_JUMPING
	ld (player_state), a
player_update_state_directional_weapon_jumping:
	ld a, (player_jump_no_grab_timer)
	or a
	jr z, player_update_state_directional_weapon_jumping_continue
	dec a
	ld (player_jump_no_grab_timer), a
player_update_state_directional_weapon_jumping_continue:

	; check for change of direction:
	ld a, (keyboard_clicks)
	bit KEY_LEFT_BIT, a  ; left
	jp z, player_update_state_directional_weapon_jumping_no_left
	ld a, (player_state)
	or 1
	ld (player_state), a
player_update_state_directional_weapon_jumping_no_left:
	ld a, (keyboard_clicks)
	bit KEY_RIGHT_BIT, a  ; right
	jp z, player_update_state_directional_weapon_jumping_no_right
	ld a, (player_state)
	and #fe
	ld (player_state), a
player_update_state_directional_weapon_jumping_no_right:

	ld a, (player_jump_is_cancelable)
	or a
	jr z, player_update_state_directional_weapon_jumping_cannot_cancel
	; did the player release the jump key?
	; check for jump
	ld a, (keyboard_state)
	bit KEY_JUMP_BIT, a
	call nz, player_update_stop_jumping
player_update_state_directional_weapon_jumping_cannot_cancel:

	; move up:
	ld a, (player_state_timer)
	inc a
	ld (player_state_timer), a
	ld hl, player_jump_speed_table - 1
	ADD_HL_A
	ld a, (hl)
	cp #ff
	jp z, player_update_switch_to_falling_with_directional
	ld b, a
	or a
	jr z, player_update_state_directional_weapon_jumping_loop_done
player_update_state_directional_weapon_jumping_speed_loop:
	push bc
		call player_update_move_one_pixel_up_considering_collisions
	pop bc
	djnz player_update_state_directional_weapon_jumping_speed_loop
player_update_state_directional_weapon_jumping_loop_done:

	; weapon release?
	ld a, (keyboard_state)
	bit KEY_WEAPON_BIT, a
	jp nz, player_update_state_directional_weapon_jumping_done

	ld a, (player_current_item)
	cp 3  ; shield
	jr z, player_update_state_directional_weapon_jumping_shield

	; regular directional weapons:
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jr nz, player_update_state_directional_weapon_jumping_no_up
	bit KEY_LEFT_BIT, a
	jr z, player_update_state_directional_weapon_jumping_diagonal_up
	bit KEY_RIGHT_BIT, a
	jr z, player_update_state_directional_weapon_jumping_diagonal_up
	; pointing the weapon up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_UP
	ld (player_weapon_swing_type), a
	ld a, 29
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_jumping_diagonal_up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_FW_UP
	ld (player_weapon_swing_type), a
	ld a, 28
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_jumping_no_up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_FW
	ld (player_weapon_swing_type), a
	ld a, 27
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_directional_weapon_jumping_shield:
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jr nz, player_update_state_directional_weapon_jumping_shield_no_up
	; pointing the shield up:
	ld a, PLAYER_WEAPON_SHIELD_UP
	ld (player_weapon_swing_type), a
	ld a, 24
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_jumping_shield_no_up:
	ld a, PLAYER_WEAPON_SHIELD_FORWARD
	ld (player_weapon_swing_type), a
	ld a, 23
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_directional_weapon_jumping_done:
	; fire a bullet (depending on the weapon):
	call player_update_fire_directional_bullet
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_JUMPING
	ld (player_state), a
	ld a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_falling_with_directional:
	xor a
	ld (player_state_timer), a
player_update_switch_to_directional_weapon_falling:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_DIRECTIONAL_WEAPON_FALLING
	ld (player_state), a
player_update_state_directional_weapon_falling:

	ld a, (player_jump_no_grab_timer)
	or a
	jr z, player_update_state_directional_weapon_falling_continue
	dec a
	ld (player_jump_no_grab_timer), a
player_update_state_directional_weapon_falling_continue:

	; check for change of direction:
	ld a, (keyboard_clicks)
	bit KEY_LEFT_BIT, a  ; left
	jp z, player_update_state_directional_weapon_falling_no_left
	ld a, (player_state)
	or 1
	ld (player_state), a
player_update_state_directional_weapon_falling_no_left:
	ld a, (keyboard_clicks)
	bit KEY_RIGHT_BIT, a  ; right
	jp z, player_update_state_directional_weapon_falling_no_right
	ld a, (player_state)
	and #fe
	ld (player_state), a
player_update_state_directional_weapon_falling_no_right:

	; check if we need to switch to idle:
	call player_check_collision_down_inc  ; a = tile type
	jp z, player_update_switch_to_directional_weapon

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
	jr nz, player_update_state_directional_weapon_falling_speed_determined
	dec e
	dec hl
	ld a, (hl)
player_update_state_directional_weapon_falling_speed_determined:
	ld b, a
	or a
	ld a, e
	ld (player_state_timer), a
	jr z, player_update_state_directional_weapon_falling_speed_loop_done
player_update_state_directional_weapon_falling_speed_loop:
	push bc
		call player_update_move_one_pixel_down_considering_collisions
	pop bc
	jr z, player_update_state_directional_weapon_falling_speed_loop_done
	djnz player_update_state_directional_weapon_falling_speed_loop
player_update_state_directional_weapon_falling_speed_loop_done:

	; weapon release?
	ld a, (keyboard_state)
	bit KEY_WEAPON_BIT, a
	jp nz, player_update_state_directional_weapon_falling_done

	ld a, (player_current_item)
	cp 3  ; shield
	jr z, player_update_state_directional_weapon_falling_shield

	; regular directional weapons:
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jr nz, player_update_state_directional_weapon_falling_no_up
	bit KEY_LEFT_BIT, a
	jr z, player_update_state_directional_weapon_falling_diagonal_up
	bit KEY_RIGHT_BIT, a
	jr z, player_update_state_directional_weapon_falling_diagonal_up
	; pointing the weapon up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_UP
	ld (player_weapon_swing_type), a
	ld a, 29
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_falling_diagonal_up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_FW_UP
	ld (player_weapon_swing_type), a
	ld a, 28
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_falling_no_up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_FW
	ld (player_weapon_swing_type), a
	ld a, 27
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_directional_weapon_falling_shield:
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jr nz, player_update_state_directional_weapon_falling_shield_no_up	
	; pointing the shield up:
	ld a, PLAYER_WEAPON_SHIELD_UP
	ld (player_weapon_swing_type), a
	ld a, 24
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_falling_shield_no_up:
	ld a, PLAYER_WEAPON_SHIELD_FORWARD
	ld (player_weapon_swing_type), a
	ld a, 23
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_directional_weapon_falling_done:
	; fire a bullet (depending on the weapon):
	call player_update_fire_directional_bullet
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_FALLING
	ld (player_state), a
	ld a, 2
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_directional_weapon_crouching:
	ld a, (player_state)
	and #01
	add a, PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING
	ld (player_state), a
player_update_state_directional_weapon_crouching:
	ld a, (keyboard_state)
	bit KEY_WEAPON_BIT, a
	jp z, player_update_state_directional_weapon_crouching_still_holding_fire
	call player_update_fire_directional_bullet
	jp player_update_switch_to_crouching
player_update_state_directional_weapon_crouching_still_holding_fire:

	; check for inventory:
	ld a, (keyboard_clicks)
	bit KEY_JUMP_BIT, a
	jp z, player_update_state_directional_weapon_crouching_no_inventory
	SETMEGAROMPAGE_8000 TEXT_PAGE
	jp state_inventory
player_update_state_directional_weapon_crouching_no_inventory:

	; check for change of direction:
	ld a, (keyboard_clicks)
	bit KEY_LEFT_BIT, a  ; left
	jp z, player_update_state_directional_weapon_crouching_no_left
	ld a, (player_state)
	or 1
	ld (player_state), a
player_update_state_directional_weapon_crouching_no_left:
	ld a, (keyboard_clicks)
	bit KEY_RIGHT_BIT, a  ; right
	jp z, player_update_state_directional_weapon_crouching_no_right
	ld a, (player_state)
	and #fe
	ld (player_state), a
player_update_state_directional_weapon_crouching_no_right:	

	; check for falling:
	call player_check_collision_down_inc
	jp nz, player_update_switch_to_falling_with_directional

	; check for idle:
	ld a, (keyboard_state)
	bit KEY_DOWN_BIT, a
	jr z, player_update_state_directional_weapon_crouching_still_crouching
	call player_check_collision_idle
	jp nz, player_update_switch_to_directional_weapon
player_update_state_directional_weapon_crouching_still_crouching:

	ld a, (player_current_item)
	cp 3  ; shield
	jr z, player_update_state_directional_weapon_crouching_shield

	; regular directional weapons:
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jr nz, player_update_state_directional_weapon_crouching_no_up
	ld a, PLAYER_WEAPON_DIRECTIONAL_FW_UP
	ld (player_weapon_swing_type), a
	ld a, 31
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_crouching_no_up:
	ld a, PLAYER_WEAPON_DIRECTIONAL_FW
	ld (player_weapon_swing_type), a
	ld a, 30
	ld (player_requested_frame), a
	jp player_update_update_sprite_position

player_update_state_directional_weapon_crouching_shield:
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a
	jr nz, player_update_state_directional_weapon_crouching_shield_no_up
	; pointing the shield up:
	ld a, 26
	ld (player_requested_frame), a
	jp player_update_update_sprite_position
player_update_state_directional_weapon_crouching_shield_no_up:
	ld a, 25
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_state_hurt:
	ld a, PLAYER_IMMUNITY_TIME
	ld (player_immunity_timer), a  ; keep renewing this timer, until player recovers

	ld a, (player_state)
	and #01
	jr nz, player_update_state_hurt_left
	call player_update_move_one_pixel_left_considering_collisions_no_direction_change
	jr player_update_state_hurt_continue
player_update_state_hurt_left:
	call player_update_move_one_pixel_right_considering_collisions_no_direction_change
player_update_state_hurt_continue:

	; move up:
	ld a, (player_state_timer)
	inc a
	ld (player_state_timer), a
	ld hl, player_hurt_speed_table - 1
	ADD_HL_A
	ld a, (hl)
	cp #ff
	jp z, player_update_switch_to_falling
	ld b, a
	or a
	jr z, player_update_state_hurt_speed_loop_done
player_update_state_hurt_speed_loop:
	push bc
		call player_update_move_one_pixel_up_considering_collisions
	pop bc
	djnz player_update_state_hurt_speed_loop
player_update_state_hurt_speed_loop_done:
	ld a, 32
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_state_dead:
	SETMEGAROMPAGE_8000 TEXT_PAGE  ; in case we jump to game over
	ld hl, player_state_timer
	inc (hl)
	ld a, (hl)
	cp 100
	jp z, state_game_over
	ld a, 33
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_interact:
	; see if there is an interactuable object nearby:
	call get_tile_object_behind_player
	ret z  ; no tile object behind
	jp interact_with_tile_object


;-----------------------------------------------
player_update_fire_directional_bullet:
	ld a, (player_current_item)
	cp 3  ; shield
	ret z

	; check if we have enough bullets:
	sub 4
	ld hl, player_inventory_weapon_ammo
	ADD_HL_A
	ld a, (hl)  ; a = number of bullets left
	or a
	jp z, player_update_fire_directional_bullet_no_bullets
	dec (hl)

	ld a, HUD_MAX_TIME
	ld (hud_redraw_timer), a
	ld hl, redraw_flags
	set HUD_REDRAW_FLAG_BIT, (hl)
	set WEAPON_REDRAW_FLAG_BIT, (hl)

	call ptr_to_new_sprite_object_player_bullet
	ret nz
	push hl
	pop ix  ; transfer the pointer to ix for later
	ld a, (player_current_item)
	sub 4
	push hl
		ld hl, player_weapon_duration_table
		ADD_HL_A
		ld a, (hl)
	pop hl
	push af
		ld a, (player_current_item)
		add a, SPRITE_OBJECT_TYPE_PLAYER_BULLET_STONE - 4  ; 4 is the first weapon that fires bullets
		ld (hl), a
		inc hl
		ld de, player_x
		ex de, hl
		ldi  ; pixel x
		ldi  ; tile x
		ldi  ; pixel y
		ldi  ; tile y
		ex de, hl	
	pop af
	ld (hl), a  ; state (frames left)
	inc hl
	; is player looking left or right?
	ld a, (player_state)
	and #01
	add a, a
	dec a
	neg
	ld c, a  ; c = -1 if looking left, 1 is looking right

	ld a, (player_current_item)
	cp 4  ; sling
	jr z, player_update_fire_directional_bullet_parabollic
	cp 6  ; atlatl
	jr z, player_update_fire_directional_bullet_parabollic
player_update_fire_directional_bullet_straight:
	ld a, (player_weapon_swing_type)
	cp PLAYER_WEAPON_DIRECTIONAL_FW
	jr z, player_update_fire_directional_bullet_fw_straight
	cp PLAYER_WEAPON_DIRECTIONAL_FW_UP
	jr z, player_update_fire_directional_bullet_fw_up_straight
player_update_fire_directional_bullet_up_straight:
	ld (hl), 0  ; speed x
	inc hl
	ld (hl), -4  ; speed y
	ld bc, #0000  ; start offset: 0, 0
	jp player_update_fire_directional_bullet_speed_set
player_update_fire_directional_bullet_fw_straight:
	ld a, c
	add a, a
	add a, a
	ld (hl), a  ; speed x
	inc hl
	ld (hl), 0  ; speed y
	ld b, 0
	ld c, a  ; start offset: 4, 6  or -4, 6 (depending on player facing)
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING
	jr nz, player_update_fire_directional_bullet_speed_set
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
; 	ld b, 8
	jr player_update_fire_directional_bullet_speed_set
player_update_fire_directional_bullet_fw_up_straight:
	ld a, c
	add a, a
	add a, c
	ld (hl), a  ; speed x (3 or -3)
	inc hl
	ld (hl), -3  ; speed y
	ld b, 4
	add a, c
	ld c, a  ; start offset: 4, 4  or -4, 4 (depending on player facing)
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING
	jr nz, player_update_fire_directional_bullet_speed_set
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld b, 4
	jp player_update_fire_directional_bullet_speed_set

player_update_fire_directional_bullet_parabollic:
	ld a, (player_weapon_swing_type)
	cp PLAYER_WEAPON_DIRECTIONAL_FW
	jr z, player_update_fire_directional_bullet_fw
	cp PLAYER_WEAPON_DIRECTIONAL_FW_UP
	jr z, player_update_fire_directional_bullet_fw_up
player_update_fire_directional_bullet_up:
	ld (hl), 0  ; speed x
	inc hl
	ld (hl), -6  ; speed y
	ld bc, #0000  ; start offset: 0, 0
	jr player_update_fire_directional_bullet_speed_set
player_update_fire_directional_bullet_fw:
	ld a, c
	add a, a
	add a, a
	ld (hl), a  ; speed x
	inc hl
	ld (hl), -2  ; speed y
	ld c, a	
	ld b, 8  ; start offset: 4, 8  or -4, 8 (depending on player facing)
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING
	jr nz, player_update_fire_directional_bullet_speed_set
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld b, 4
	jr player_update_fire_directional_bullet_speed_set
player_update_fire_directional_bullet_fw_up:
	ld a, c
	add a, a
	add a, c
	ld (hl), a  ; speed x (3 or -3)
	inc hl
	ld (hl), -4  ; speed y
	add a, c
	ld c, a  ; start offset: 4, 4  or -4, 4 (depending on player facing)
	ld b, 4
	ld a, (player_current_item)
	cp 4  ; sling
	jr z, player_update_fire_directional_bullet_fw_up_continue
	ld a, c
	add a, a
	sub 8
	ld c, a
	jr player_update_fire_directional_bullet_speed_set
player_update_fire_directional_bullet_fw_up_continue:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING
	jr nz, player_update_fire_directional_bullet_speed_set
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld b, 8
player_update_fire_directional_bullet_speed_set:
	inc hl
	call get_next_hit_id
	ld (hl), a
	call update_sprite_objects_move_object
	; move it one more time, so that the bullet starts a bit separated from the player:
	ld c, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	call update_sprite_objects_move_object	

	ld a, (player_current_item)
	cp 7
	jr z, player_update_fire_directional_bullet_sfx_raygun
	ld hl, SFX_weapon_swing
	jp play_SFX_with_high_priority
player_update_fire_directional_bullet_sfx_raygun:
	ld hl, SFX_raygun
	jp play_SFX_with_high_priority

player_update_fire_directional_bullet_no_bullets:
	ld hl, SFX_ui_wrong
	jp play_SFX_with_high_priority

;-----------------------------------------------
player_weapon_duration_table:
	db 64, 24, 64, 64


;-----------------------------------------------
; called if player is idle or walking
; output:
; - z: melee weapon
; - nz: directional weapon
player_update_determine_weapon_swing_type:
	; Determine the type of swing:
	ld a, (player_current_item)
	or a
	jr z, player_update_determine_weapon_swing_type_machete
	cp 1
	jr z, player_update_determine_weapon_swing_type_hammer
	cp 2
	jr z, player_update_determine_weapon_swing_type_macuahuitl
	cp 8
	jr z, player_update_determine_weapon_swing_type_machete
	cp 9
	jr z, player_update_determine_weapon_swing_type_hammer
	cp 10
	jr z, player_update_determine_weapon_swing_type_macuahuitl
	; directional weapons
	or 1  ; nz
	ret
player_update_determine_weapon_swing_type_macuahuitl:
	ld a, 18
	ld (player_weapon_state_timer), a
	ld a, PLAYER_WEAPON_SWING_MACUAHUITL1
	jr player_update_determine_weapon_swing_type_determined
player_update_determine_weapon_swing_type_hammer:
	ld a, 32
	ld (player_weapon_state_timer), a
	ld a, PLAYER_WEAPON_SWING_HAMMER1
	jr player_update_determine_weapon_swing_type_determined
player_update_determine_weapon_swing_type_machete:
	ld hl, SFX_weapon_swing
	call play_SFX_with_high_priority
	ld a, 8
	ld (player_weapon_state_timer), a
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a  ; up
	jr z, player_update_determine_weapon_swing_type_machete_up
	; swing machete forward:
	ld a, PLAYER_WEAPON_SWING_MACHETE_FORWARD
	jr player_update_determine_weapon_swing_type_determined
player_update_determine_weapon_swing_type_machete_up:
	ld a, PLAYER_WEAPON_SWING_MACHETE_UP
player_update_determine_weapon_swing_type_determined:
	ld (player_weapon_swing_type), a
	xor a  ; z
	ret


;-----------------------------------------------
; player is jumping or falling
; output:
; - z: melee weapon
; - nz: directional weapon
player_update_determine_weapon_swing_type_jumping:
	; Determine the type of swing:
	ld a, (player_current_item)
	or a
	jr z, player_update_determine_weapon_swing_type_jumping_machete
	cp 8
	jr z, player_update_determine_weapon_swing_type_jumping_machete
	cp 1
	jr z, player_update_determine_weapon_swing_type_jumping_hammer
	cp 9
	jr z, player_update_determine_weapon_swing_type_jumping_hammer
	cp 2
	jr z, player_update_determine_weapon_swing_type_jumping_macuahuitl
	cp 10
	jr z, player_update_determine_weapon_swing_type_jumping_macuahuitl
	; directional weapons
	or 1  ; nz
	ret
player_update_determine_weapon_swing_type_jumping_macuahuitl:
	ld a, 18
	ld (player_weapon_state_timer), a
	ld a, PLAYER_WEAPON_SWING_MACUAHUITL1
	jr player_update_determine_weapon_swing_type_jumping_determined
player_update_determine_weapon_swing_type_jumping_hammer:
	ld a, 32
	ld (player_weapon_state_timer), a
	ld a, PLAYER_WEAPON_SWING_HAMMER1
	jr player_update_determine_weapon_swing_type_jumping_determined
player_update_determine_weapon_swing_type_jumping_machete:
	ld hl, SFX_weapon_swing
	call play_SFX_with_high_priority
	ld a, 8
	ld (player_weapon_state_timer), a
	ld a, (keyboard_state)
	bit KEY_UP_BIT, a  ; up
	jr z, player_update_determine_weapon_swing_type_jumping_machete_up
	bit KEY_DOWN_BIT, a  ; down
	jr z, player_update_determine_weapon_swing_type_jumping_machete_down
	; swing machete forward:
	ld a, PLAYER_WEAPON_SWING_MACHETE_FORWARD
	jr player_update_determine_weapon_swing_type_jumping_determined
player_update_determine_weapon_swing_type_jumping_machete_down:
	ld a, PLAYER_WEAPON_SWING_MACHETE_DOWN
	jr player_update_determine_weapon_swing_type_jumping_determined
player_update_determine_weapon_swing_type_jumping_machete_up:
	ld a, PLAYER_WEAPON_SWING_MACHETE_UP
player_update_determine_weapon_swing_type_jumping_determined:
	ld (player_weapon_swing_type), a
	xor a  ; z
	ret


;-----------------------------------------------
; output:
; - z: melee weapon
; - nz: directional weapon
player_update_determine_weapon_swing_type_crouching:
	; Determine the type of swing:
	ld a, (player_current_item)
	or a
	jr z, player_update_determine_weapon_swing_type_crouching_machete
	cp 8
	jr z, player_update_determine_weapon_swing_type_crouching_machete
	cp 1
	jr z, player_update_determine_weapon_swing_type_crouhcing_hammer
	cp 9
	jr z, player_update_determine_weapon_swing_type_crouhcing_hammer
	cp 2
	jr z, player_update_determine_weapon_swing_type_crouhcing_macuahuitl
	cp 10
	jr z, player_update_determine_weapon_swing_type_crouhcing_macuahuitl
	; directional weapons
	or 1  ; nz
	ret
player_update_determine_weapon_swing_type_crouhcing_macuahuitl:
	ld a, 18
	ld (player_weapon_state_timer), a
	ld a, PLAYER_WEAPON_SWING_MACUAHUITL1
	jr player_update_determine_weapon_swing_type_crouching_determined
player_update_determine_weapon_swing_type_crouhcing_hammer:
	ld a, 32
	ld (player_weapon_state_timer), a
	ld a, PLAYER_WEAPON_SWING_HAMMER1
	jr player_update_determine_weapon_swing_type_crouching_determined
player_update_determine_weapon_swing_type_crouching_machete:
	ld hl, SFX_weapon_swing
	call play_SFX_with_high_priority
	ld a, 8
	ld (player_weapon_state_timer), a
	ld a, PLAYER_WEAPON_SWING_MACHETE_CROUCHING
player_update_determine_weapon_swing_type_crouching_determined:
	ld (player_weapon_swing_type), a
	xor a  ; z
	ret


;-----------------------------------------------
player_update_weapon_sprite_request:
	; animation frames:
	ld a, (player_weapon_swing_type)
	cp PLAYER_WEAPON_SWING_HAMMER1
	jp z, player_update_weapon_sprite_request_hammer1
	cp PLAYER_WEAPON_SWING_HAMMER2
	jp z, player_update_weapon_sprite_request_hammer2
	cp PLAYER_WEAPON_SWING_MACUAHUITL1
	jp z, player_update_weapon_sprite_request_macuahuitl1
player_update_weapon_sprite_request_continue:
	; damage:
	ld a, (player_current_item)
	ld hl, player_weapon_damages
	ADD_HL_A
	ld a, (hl)
	ld iyh, a

	; weapon sprite setup:
	ld a, (player_weapon_swing_type)
	ld c, a
	add a, a
	add a, a
	add a, a
	sub c  ; a *= 7
	ld hl, weapon_sprite_swing_table
	ADD_HL_A
	ld de, player_requested_weapon_sprite
	ldi  ; weapon sprite
	ld a, (player_state)
	and #01
	jr z, player_update_weapon_sprite_request_right
	inc hl
	ldi
	jr player_update_weapon_sprite_request_x_set
player_update_weapon_sprite_request_right:
	ldi
	inc hl
player_update_weapon_sprite_request_x_set:
	ldi
	ld a, (hl)
	ld (player_requested_frame), a

	; check if the weapon has hit something:
	ld a, (player_current_swing_hit_id)
	ld iyl, a
	; compute the hit box:
	; - ((player_x) + (de - 1)) / 8 + (player_x + 1)
	; - ((player_y) + (de)) / 8 + (player_y + 1)
	dec de
	ld a, (de)  ; y offset
	ld b, a
	ld a, (player_y)
	add a, b
	sra a
	sra a
	sra a
	ld b, a
	ld a, (player_y + 1)
	add a, b
	ld b, a

	dec de
	ld a, (de)  ; x offset
	ld c, a
	ld a, (player_x)
	add a, c
	sra a
	sra a
	sra a
	ld c, a
	ld a, (player_x + 1)
	add a, c
	ld d, b  
	ld e, a  ; e, d: hit box start

	inc hl
	ld a, (hl)  ; hitbox width
	or a 
	jp z, player_update_update_sprite_position  ; no weapon hitbox
	add a, e
	ld c, a
	inc hl
	ld a, (hl)  ; hitbox height
	add a, d
	ld l, c
	ld h, a
	call player_weapon_hitbox_check

	jp player_update_update_sprite_position

player_update_weapon_sprite_request_hammer1:
	ld a, (player_weapon_state_timer)
	cp 18
	jr nz, player_update_weapon_sprite_request_continue
	ld hl, SFX_weapon_swing_slow
	call play_SFX_with_high_priority
	ld a, PLAYER_WEAPON_SWING_HAMMER2
	ld (player_weapon_swing_type), a
	jp player_update_weapon_sprite_request_continue
player_update_weapon_sprite_request_hammer2:
	ld a, (player_weapon_state_timer)
	cp 10
	jp nz, player_update_weapon_sprite_request_continue
	ld a, PLAYER_WEAPON_SWING_HAMMER3
	ld (player_weapon_swing_type), a
	jp player_update_weapon_sprite_request_continue
player_update_weapon_sprite_request_macuahuitl1:
	ld a, (player_weapon_state_timer)
	cp 10
	jp nz, player_update_weapon_sprite_request_continue
	ld hl, SFX_weapon_swing
	call play_SFX_with_high_priority
	ld a, PLAYER_WEAPON_SWING_MACUAHUITL2
	ld (player_weapon_swing_type), a
	jp player_update_weapon_sprite_request_continue


weapon_sprite_swing_table:
	; weapon sprite, x offset right, x offset left, y offset, player frame, hitbox width, hitbox height (in tiles)
	db 0,   16, -16,   5, 14,  1,  1  ; machete forward
	db 1,    4,  -4,  -7, 15,  1,  1  ; machete up
	db 0,   16, -16,  10, 17,  1,  1  ; machete crouching
	db 2,    4,  -4,  16, 16,  1,  1  ; machete down
	db 3,   -7,   7,  -2, 15,  1,  1  ; hammer1
	db 4,    0,   0,  -8, 18,  2,  1  ; hammer2
	db 5,   16, -16,   0, 19,  2,  3  ; hammer3 (hits down)
	db #ff,  0,   0,   5, 20,  0,  0  ; macuahuitl1
	db 6,   15, -15,   5, 14,  2,  1  ; macuahuitl2

player_weapon_damages:
	db 1, 3, 2, 0   ; machete, hammer, macuahuitl, shield
	db 0, 0, 0, 0   ; throwing weapons
	db 2, 5, 3      ; upgraded machete, hammer, macuahuitl


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
			call room_undraw_tile_objects
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
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

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
player_update_move_one_pixel_right_considering_collisions_no_direction_change:
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
player_update_move_one_pixel_left_considering_collisions_no_direction_change:
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


;-----------------------------------------------
get_next_hit_id:
	ld a, (player_new_hit_id)
	inc a
	ld (player_new_hit_id), a
	cp #ff
	ret nz
	xor a
	ld (player_new_hit_id), a
	ret


;-----------------------------------------------
; Checks if a player weapon has hit an enemy or object.
; input:
; - de, hl: collision box (in tile coordinates: from [e, d] to [l, h])
; - iyl: collision ID
; - iyh: weapon damage
player_weapon_hitbox_check:
	push ix
		; iterate over the list of tile objects, to see if we hit a breakable wall:
		ld ix, current_room__tile_objects
player_weapon_hitbox_check_tile_object_loop:
		ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
		cp #ff
		jr z, player_weapon_hitbox_check_tile_object_loop_done
		ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
		cp TAG_BREAKABLE_WALL1
		jr z, player_weapon_hitbox_check_tile_object_loop_breakable_wall
		cp TAG_BREAKABLE_WALL2
		jr z, player_weapon_hitbox_check_tile_object_loop_breakable_wall
		cp TAG_BREAKABLE_WALL3
		jr z, player_weapon_hitbox_check_tile_object_loop_breakable_wall
		cp TAG_BREAKABLE_WALL4
		jr nz, player_weapon_hitbox_check_tile_object_loop_continue

player_weapon_hitbox_check_tile_object_loop_breakable_wall:
		; breakable wall, check for collision:
		ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
		cp l
		jr nc, player_weapon_hitbox_check_tile_object_loop_continue
		add a, (ix + ROOM_TILE_OBJECT_STRUCT_WIDTH)
		cp e
		jr c, player_weapon_hitbox_check_tile_object_loop_continue
		ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
		cp h
		jr nc, player_weapon_hitbox_check_tile_object_loop_continue
		add a, (ix + ROOM_TILE_OBJECT_STRUCT_HEIGHT)
		cp d
		jr c, player_weapon_hitbox_check_tile_object_loop_continue

		; check collision ID:
		ld a, iyl
		cp (ix + ROOM_TILE_OBJECT_STRUCT_LAST_HIT_ID)
		jr z, player_weapon_hitbox_check_tile_object_loop_continue

		; collision! Here:
		; - a = collidion ID
		; - iyh: damage to deal
		push hl
		push de
			call breakable_wall_hit_by_player
		pop de
		pop hl

player_weapon_hitbox_check_tile_object_loop_continue:
		ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
		add ix, bc
		jr player_weapon_hitbox_check_tile_object_loop
player_weapon_hitbox_check_tile_object_loop_done:

		; iterate over the list of enemies to see if we hit any:
		; ...
	pop ix
	ret

