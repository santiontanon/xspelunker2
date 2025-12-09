;-----------------------------------------------
enemy_update_fn_table:
	dw update_enemy_snake
	dw update_enemy_snake_dasher
	dw update_enemy_snake_poison
	dw update_enemy_poison_bullet
	dw update_enemy_fish
	dw update_enemy_fish_jumper
	dw update_enemy_bat
	dw update_enemy_bat_aggressive
	dw update_enemy_bullet
	dw update_enemy_skeleton
	dw update_enemy_skeleton_thrower1
	dw update_enemy_skeleton_thrower2
	dw update_enemy_bone_bullet
	dw update_enemy_bone_parabola_bullet
	dw update_enemy_parabola_bullet
	dw update_enemy_frog
	dw update_enemy_frog_jumping
	dw update_enemy_frog_tongue
	dw update_enemy_bee
	dw update_enemy_monkey
	dw update_enemy_monkey_thrower


;-----------------------------------------------
update_sprite_enemies:
	; we do not need to initialize "n_displayed_object_sprites", since this is always called
	; after "update_sprite_objects"
	ld ix, current_room__sprite_enemies
update_sprite_enemies_loop:
	ld a, (ix)
	or a
	ret z
	cp #ff  ; sentinel
	ret z
	add a, a
	ld hl, enemy_update_fn_table - 2
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

update_sprite_enemies_loop_next:
	ld de, ROOM_OBJECT_STRUCT_SIZE
	add ix, de
	jp update_sprite_enemies_loop
update_sprite_enemies_loop_next_after_deletion:
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_snake:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_snake_right
	dec a
	jr z, update_enemy_snake_left
	; we cannever reach here ...

update_enemy_snake_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_snake_right_continue
update_enemy_snake_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	jr z, update_enemy_snake_right_continue
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_snake_switch_to_state_left
update_enemy_snake_right_continue:
	ld d, COLOR_DARK_YELLOW
update_enemy_snake_right_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 1) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_snake_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_snake_left_continue
update_enemy_snake_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	jr z, update_enemy_snake_left_continue
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_snake_switch_to_state_right
update_enemy_snake_left_continue:
	ld d, COLOR_DARK_YELLOW
update_enemy_snake_left_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 3) * 4 
	jp enemy_sprite_and_continue_animated


;-----------------------------------------------
update_enemy_snake_dasher:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_snake_dasher_right
	dec a
	jr z, update_enemy_snake_dasher_left
	dec a
	jp z, update_enemy_snake_dasher_dash_right
	dec a
	jp z, update_enemy_snake_dasher_dash_left
	; we cannever reach here ...

update_enemy_snake_dasher_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_snake_dasher_right_continue
update_enemy_snake_dasher_right:
	; dash?
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_snake_dasher_right_no_dash
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_snake_dasher_right_no_dash
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; dash right!
	jr update_enemy_snake_dasher_right_continue
update_enemy_snake_dasher_right_no_dash:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_snake_dasher_right_continue
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_snake_dasher_switch_to_state_left
update_enemy_snake_dasher_right_continue:
	ld d, COLOR_DARK_GREEN
	jp update_enemy_snake_right_continue_color_set

update_enemy_snake_dasher_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_snake_dasher_left_continue
update_enemy_snake_dasher_left:
	; dash?
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_snake_dasher_left_no_dash
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nc, update_enemy_snake_dasher_left_no_dash
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; dash left!
	jr update_enemy_snake_dasher_right_continue
update_enemy_snake_dasher_left_no_dash:	
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_snake_dasher_left_continue
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_snake_dasher_switch_to_state_right
update_enemy_snake_dasher_left_continue:
	ld d, COLOR_DARK_GREEN
	jp update_enemy_snake_left_continue_color_set

update_enemy_snake_dasher_dash_right:
	ld a, (current_world__difficulty_attack_warn_time)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jr z, update_enemy_snake_dasher_switch_to_state_left
	cp c
	jr nc, update_enemy_snake_dasher_right_continue
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_snake_dasher_right_continue
	call update_enemy_move_right_if_possible_platform
	jr update_enemy_snake_dasher_right_continue

update_enemy_snake_dasher_dash_left:
	ld a, (current_world__difficulty_attack_warn_time)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jp z, update_enemy_snake_dasher_switch_to_state_right
	cp c
	jr nc, update_enemy_snake_dasher_left_continue
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_snake_dasher_left_continue
	call update_enemy_move_left_if_possible_platform
	jr update_enemy_snake_dasher_left_continue


;-----------------------------------------------
update_enemy_snake_poison:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_snake_poison_right
	dec a
	jr z, update_enemy_snake_poison_left
	dec a
	jp z, update_enemy_snake_poison_spit_right
	dec a
	jp z, update_enemy_snake_poison_spit_left
	; we cannever reach here ...

update_enemy_snake_poison_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_snake_poison_right_continue
update_enemy_snake_poison_right:
	; spit?
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr c, update_enemy_snake_poison_right_no_spit
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_snake_poison_right_no_spit
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_snake_poison_right_no_spit
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; spit right!
	jr update_enemy_snake_poison_right_continue
update_enemy_snake_poison_right_no_spit:
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_snake_poison_switch_to_state_left
update_enemy_snake_poison_right_continue:
	ld d, COLOR_GREEN
	jp update_enemy_snake_right_continue_color_set

update_enemy_snake_poison_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_snake_poison_left_continue
update_enemy_snake_poison_left:
	; spit?
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr c, update_enemy_snake_poison_left_no_spit
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_snake_poison_left_no_spit
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nc, update_enemy_snake_poison_left_no_spit
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; spit left!
	jr update_enemy_snake_poison_left_continue
update_enemy_snake_poison_left_no_spit:	
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_snake_poison_switch_to_state_right
update_enemy_snake_poison_left_continue:
	ld d, COLOR_GREEN
	jp update_enemy_snake_left_continue_color_set

update_enemy_snake_poison_spit_right:
	ld a, (current_world__difficulty_attack_warn_time)
	add a, a
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp c  ; warn time * 2
	jr nz, update_enemy_snake_poison_spit_right_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
update_enemy_snake_poison_spit_right_continue:
	srl c
	cp c  ; warn time
	jr nz, update_enemy_snake_poison_spit_right_continue2
	; spit:
	call ptr_to_new_sprite_enemy
	jr nz, update_enemy_snake_poison_spit_right_continue2
	ld (hl), ENEMY_POISON_BULLET
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	inc a
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (hl), a
	inc hl
	ld (hl), 0  ; right

	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority	
update_enemy_snake_poison_spit_right_continue2:
	ld d, COLOR_GREEN
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 5) * 4 
	jp enemy_sprite_and_continue

update_enemy_snake_poison_spit_left:
	ld a, (current_world__difficulty_attack_warn_time)
	add a, a
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp c  ; warn time * 2
	jr nz, update_enemy_snake_poison_spit_left_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
update_enemy_snake_poison_spit_left_continue:
	srl c
	cp c  ; warn time
	jr nz, update_enemy_snake_poison_spit_left_continue2
	; spit:
	call ptr_to_new_sprite_enemy
	jr nz, update_enemy_snake_poison_spit_right_continue2
	ld (hl), ENEMY_POISON_BULLET
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	dec a
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (hl), a
	inc hl
	ld (hl), 1  ; left

	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
update_enemy_snake_poison_spit_left_continue2:
	ld d, COLOR_GREEN
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 6) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_poison_bullet:
	ld e, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr nz, update_enemy_poison_bullet_left

update_enemy_poison_bullet_right:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_move_right_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_GREEN
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4 
	jp enemy_sprite_and_continue

update_enemy_poison_bullet_left:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_move_left_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_GREEN
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_bone_bullet:
	ld e, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr nz, update_enemy_bone_bullet_left

update_enemy_bone_bullet_right:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_move_right_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4 
	jp enemy_sprite_and_continue_animated4

update_enemy_bone_bullet_left:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_move_left_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4 
	jp enemy_sprite_and_continue_animated4


;-----------------------------------------------
update_enemy_bone_parabola_bullet_table:
	db -3, -3, -2, -2, -1, -1,  0,  0
	db  0,  1,  1,  2,  2,  3,  3,  4


update_enemy_bone_parabola_bullet:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	; out of bounds?
	ld a, (current_room__width)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp c
	jp nc, update_enemy_delete
	ld a, (current_room__height)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp c
	jp nc, update_enemy_delete
	; parabola:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jr nz, update_enemy_bone_parabola_bullet_continue
	jp update_enemy_delete
	ld a, 64
update_enemy_bone_parabola_bullet_continue:
	srl a
	cp 16
	jr c, update_enemy_bone_parabola_bullet_continue2
	ld a, 15
update_enemy_bone_parabola_bullet_continue2:
	ld hl, update_enemy_bone_parabola_bullet_table
	ADD_HL_A
	ld b, (hl)
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr nz, update_enemy_bone_parabola_bullet_left

update_enemy_bone_parabola_bullet_right:
	ld c, 2
	call update_enemy_move_cb
	ld d, COLOR_DARK_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4 
	jp enemy_sprite_and_continue_animated4

update_enemy_bone_parabola_bullet_left:
	ld c, -2
	call update_enemy_move_cb
	ld d, COLOR_DARK_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4 
	jp enemy_sprite_and_continue_animated4


;-----------------------------------------------
update_enemy_parabola_bullet:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	; out of bounds?
	ld a, (current_room__width)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp c
	jp nc, update_enemy_delete
	ld a, (current_room__height)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp c
	jp nc, update_enemy_delete
	; parabola:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jr nz, update_enemy_parabola_bullet_continue
	jp update_enemy_delete
	ld a, 64
update_enemy_parabola_bullet_continue:
	srl a
	cp 16
	jr c, update_enemy_parabola_bullet_continue2
	ld a, 15
update_enemy_parabola_bullet_continue2:
	ld hl, update_enemy_bone_parabola_bullet_table
	ADD_HL_A
	ld b, (hl)
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld c, (ix + ROOM_OBJECT_STRUCT_STATE)
	call update_enemy_move_cb
	ld d, COLOR_DARK_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 0) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_fish:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_fish_right
	dec a
	jr z, update_enemy_fish_left
	; we cannever reach here ...

update_enemy_fish_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_fish_right_continue
update_enemy_fish_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_fish_right_continue
	call update_enemy_water_move_right_if_possible
	jr z, update_enemy_fish_switch_to_state_left
update_enemy_fish_right_continue:
	ld d, COLOR_PURPLE
update_enemy_fish_right_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 8) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_fish_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_fish_left_continue
update_enemy_fish_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_fish_left_continue
	call update_enemy_water_move_left_if_possible
	jr z, update_enemy_fish_switch_to_state_right
update_enemy_fish_left_continue:
	ld d, COLOR_PURPLE
update_enemy_fish_left_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 12) * 4 
	jp enemy_sprite_and_continue_animated


;-----------------------------------------------
fish_jumper_jump_table:  ; 42 steps 
	db          -5,-5,-5,-5,-5  ; -25 pixels
	db -4,-4,-4,-4,-3,-3,-3,-2  ; -27 pixels (total: -52)
	db -2,-1,-2,-1,-1,-1, 0, 0  ;  -8 pixels (total: -60)
	db  0, 0, 1, 1, 1, 2, 1, 2
	db  2, 3, 3, 3, 4, 4, 4, 4
	db  5, 5, 5, 5, 5

update_enemy_fish_jumper:
	ld e, 2  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_fish_jumper_right
	dec a
	jr z, update_enemy_fish_jumper_left
	dec a
	jr z, update_enemy_fish_jumper_right_jump_pre_splash
	dec a
	jp z, update_enemy_fish_jumper_left_jump_pre_splash
	dec a
	jp z, update_enemy_fish_jumper_right_jump
	dec a
	jp z, update_enemy_fish_jumper_left_jump
	; we cannever reach here ...

update_enemy_fish_jumper_right_switch_to_swim:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0	
update_enemy_fish_jumper_switch_to_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_fish_jumper_right_continue
update_enemy_fish_jumper_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jr z, update_enemy_fish_jumper_right_switch_to_jump
	call update_enemy_water_move_right_if_possible
	jr z, update_enemy_fish_jumper_switch_to_left
update_enemy_fish_jumper_right_continue:
	ld d, COLOR_RED
	jp update_enemy_fish_right_continue_color_set

update_enemy_fish_jumper_left_switch_to_swim:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0	
update_enemy_fish_jumper_switch_to_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
	jr update_enemy_fish_jumper_left_continue
update_enemy_fish_jumper_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jr z, update_enemy_fish_jumper_right_switch_to_jump
	call update_enemy_water_move_left_if_possible
	jr z, update_enemy_fish_jumper_switch_to_right
update_enemy_fish_jumper_left_continue:
	ld d, COLOR_RED
	jp update_enemy_fish_left_continue_color_set

update_enemy_fish_jumper_right_switch_to_jump:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_fish_jumper_right_jump_pre_splash:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 21
	jr c, update_enemy_fish_jumper_right_jump
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	push bc
		call get_room_tile_type
	pop bc
	cp 4  ; water
	jr nz, update_enemy_fish_jumper_right_jump
	dec b
	call spawn_water_splash
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 4 
update_enemy_fish_jumper_right_jump:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 42
	jr z, update_enemy_fish_jumper_right_switch_to_swim
	call update_enemy_fish_jumper_jump_table_update
	ld d, COLOR_RED
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 21
	jr nc, update_enemy_fish_jumper_right_jump_up
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 10) * 4 
	jr update_enemy_fish_jumper_right_sprite_set
update_enemy_fish_jumper_right_jump_up:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 11) * 4 
update_enemy_fish_jumper_right_sprite_set:
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	jp update_sprite_enemies_loop_next

update_enemy_fish_jumper_left_switch_to_jump:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_fish_jumper_left_jump_pre_splash:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 21
	jr c, update_enemy_fish_jumper_left_jump	
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	push bc
		call get_room_tile_type
	pop bc
	cp 4  ; water
	jr nz, update_enemy_fish_jumper_right_jump
	dec b
	call spawn_water_splash
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 5	
update_enemy_fish_jumper_left_jump:
	call update_enemy_fish_jumper_jump_table_update
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 42
	jp z, update_enemy_fish_jumper_left_switch_to_swim
	ld d, COLOR_RED
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 21
	jr nc, update_enemy_fish_jumper_left_jump_up
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 14) * 4 
	jr update_enemy_fish_jumper_left_sprite_set
update_enemy_fish_jumper_left_jump_up:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 15) * 4 
update_enemy_fish_jumper_left_sprite_set:
	jp enemy_sprite_and_continue

update_enemy_fish_jumper_jump_table_update:
	ld hl, fish_jumper_jump_table
	ADD_HL_A
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	add a, (hl)
	jp p, update_enemy_fish_jumper_jump_table_update_continue
	dec (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	add a, 8
update_enemy_fish_jumper_jump_table_update_continue:
	cp 8
	jr c, update_enemy_fish_jumper_jump_table_update_continue2
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	add a, -8
update_enemy_fish_jumper_jump_table_update_continue2:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), a
	ret


;-----------------------------------------------
update_enemy_bat_aggressive:
update_enemy_bat:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_bat_stay
	dec a
	jr z, update_enemy_bat_nw
	dec a
	jr z, update_enemy_bat_n
	dec a
	jr z, update_enemy_bat_ne
	dec a
	jr z, update_enemy_bat_e
	dec a
	jr z, update_enemy_bat_se
	dec a
	jr z, update_enemy_bat_s
	dec a
	jr z, update_enemy_bat_sw
	dec a
	jr z, update_enemy_bat_w
	dec a
	jr z, update_enemy_bat_hang

update_enemy_bat_nw:
	call update_enemy_move_left

update_enemy_bat_n:
	call update_enemy_move_up
	jr update_enemy_bat_stay_w

update_enemy_bat_ne:
	call update_enemy_move_up

update_enemy_bat_e:
	call update_enemy_move_right
	jr update_enemy_bat_stay

update_enemy_bat_se:
	call update_enemy_move_right

update_enemy_bat_s:
	call update_enemy_move_down
	jr update_enemy_bat_stay

update_enemy_bat_sw:
	call update_enemy_move_down

update_enemy_bat_w:
	call update_enemy_move_left

update_enemy_bat_stay_w:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #07
	call z, update_enemy_bat_stay_change_direction
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 18) * 4 
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_BAT_AGGRESSIVE
	jr z, update_enemy_bat_stay_w_purple
	ld d, COLOR_BLUE
	jp enemy_sprite_and_continue_animated
update_enemy_bat_stay_w_purple:
	ld d, COLOR_PURPLE
	jp enemy_sprite_and_continue_animated


update_enemy_bat_stay:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #07
	call z, update_enemy_bat_stay_change_direction
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 16) * 4 
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_BAT_AGGRESSIVE
	jr z, update_enemy_bat_stay_purple
	ld d, COLOR_BLUE
	jp enemy_sprite_and_continue_animated
update_enemy_bat_stay_purple:
	ld d, COLOR_PURPLE
	jp enemy_sprite_and_continue_animated

update_enemy_bat_hang:
	ld a, (current_world__difficulty_attack_warn_time)
	add a, a
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp c  ; warn time * 2
	jr nz, update_enemy_bat_hang_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 6  ; fly down
update_enemy_bat_hang_continue:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 20) * 4 
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_BAT_AGGRESSIVE
	jr z, update_enemy_bat_hang_purple
	ld d, COLOR_BLUE
	jp enemy_sprite_and_continue
update_enemy_bat_hang_purple:
	ld d, COLOR_PURPLE
	jp enemy_sprite_and_continue

update_enemy_bat_stay_change_direction:
	; see if we want to hang from ceiling:
	call update_enemy_bat_under_ceiling_p
	jr nz, update_enemy_bat_stay_change_direction_no_hang
	call random_a
	and #03
	jr nz, update_enemy_bat_stay_change_direction_no_hang
	; hang!
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 9
	pop af  ; simulate a ret
	jr update_enemy_bat_hang
update_enemy_bat_stay_change_direction_no_hang:	
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_BAT_AGGRESSIVE
	jr nz, update_enemy_bat_stay_change_direction_no_fire
	; chance to fire a bullet:
	call random_a
	and #1f
	jr nz, update_enemy_bat_stay_change_direction_no_fire
	call update_enemy_fire_directional_bullet_towards_player

update_enemy_bat_stay_change_direction_no_fire:
	; pick a state from 0, 1, 2, 3, 4, 5, 6, 7, 8
	call random_a
	and #07
	jr nz, update_enemy_bat_stay_change_direction_keep_direction
	ld c, 9
	call random_modulo
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
update_enemy_bat_stay_change_direction_keep_direction:

	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp 2
	jr nc, update_enemy_bat_stay_change_direction_check_right_edge
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	ld hl, update_enemy_bat_update_left_edge
	ADD_HL_A
	ld a, (hl)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a

update_enemy_bat_stay_change_direction_check_right_edge:
	ld a, (current_room__width)
	sub 4
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nc, update_enemy_bat_stay_change_direction_check_top_edge
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	ld hl, update_enemy_bat_update_right_edge
	ADD_HL_A
	ld a, (hl)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a

update_enemy_bat_stay_change_direction_check_top_edge:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp 2
	jr nc, update_enemy_bat_stay_change_direction_check_bottom_edge
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	ld hl, update_enemy_bat_update_top_edge
	ADD_HL_A
	ld a, (hl)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a

update_enemy_bat_stay_change_direction_check_bottom_edge:
	ld a, (current_room__height)
	sub 4
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ret nc
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	ld hl, update_enemy_bat_update_bottom_edge
	ADD_HL_A
	ld a, (hl)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ret

update_enemy_bat_under_ceiling_p:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	push bc
		call get_room_tile_type
	pop bc
	or a
	ret nz
	inc c
	push bc
		call get_room_tile_type
	pop bc
	or a
	ret nz
	dec b
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret nz
	dec c
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret


update_enemy_bat_update_left_edge:
	db 0, 3, 2, 3, 4, 5, 6, 5, 4

update_enemy_bat_update_right_edge:
	db 0, 1, 2, 1, 8, 7, 6, 7, 8

update_enemy_bat_update_top_edge
	db 0, 7, 6, 5, 4, 5, 6, 7, 8

update_enemy_bat_update_bottom_edge:
	db 0, 1, 2, 3, 4, 3, 2, 1, 8


;-----------------------------------------------
update_enemy_bullet:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	
	; move:
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	or a
    jp p,update_enemy_bullet_no_yspeed_flip
    neg
update_enemy_bullet_no_yspeed_flip:
    ld b, a  ; b = |speed y|
    ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
    or a
    jp p,update_enemy_bullet_no_xspeed_flip
    neg
update_enemy_bullet_no_xspeed_flip:
    ld c, a  ; c = |speed x|
    cp b
    jp c,update_enemy_bullet_y_is_bigger
    ; Bresenham for when the |speed x| > |speed y|
update_enemy_bullet_x_is_bigger:
    ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
    sub b  ; we subtract y difference from the error term 
    ld (ix + ROOM_OBJECT_STRUCT_STATE), a
    ld b, 0
    jp p, update_enemy_bullet_x_is_bigger_no_error_overflow
    ld b, 1
    add a, c
    ld (ix + ROOM_OBJECT_STRUCT_STATE), a
update_enemy_bullet_x_is_bigger_no_error_overflow:
    ld c, 1
    jp update_enemy_bullet_choose_quadrant

    ; Bresenham for when the |speed x| < |speed y|
update_enemy_bullet_y_is_bigger:
    ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
    sub c  ; we subtract y difference from the error term 
    ld (ix + ROOM_OBJECT_STRUCT_STATE), a
    ld c, 0
    jp p,update_enemy_bullet_y_is_bigger_no_error_overflow
    ld c, 1
    add a, b
    ld (ix + ROOM_OBJECT_STRUCT_STATE), a
update_enemy_bullet_y_is_bigger_no_error_overflow:
    ld b, 1

update_enemy_bullet_choose_quadrant:
	; here:
	; - b: number of steps we need to move in y (0 or 1)
	; - c: number of steps we need to move in x (0 or 1)
    ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
    or a
    jp p,update_enemy_bullet_no_yspeed_flip2
    ld a, b
    neg
    ld b, a
update_enemy_bullet_no_yspeed_flip2:
    ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
    or a
    jp p,update_enemy_bullet_no_xspeed_flip2
    ld a, c
    neg
    ld c, a
update_enemy_bullet_no_xspeed_flip2:

	; here:
	; - b: amount to move in y (-1, 0, or 1)
	; - c: amount to move in x (-1, 0, or 1)
	ld a, c
	or a
	jr z, update_enemy_bullet_x_done
	jp m, update_enemy_bullet_x_negative
	ld a, (current_world__difficulty_bullet_speed)
	push bc
		call update_enemy_move_right_if_possible_a_times
	pop bc
	jp z, update_enemy_delete
	jr update_enemy_bullet_x_done
update_enemy_bullet_x_negative:
	ld a, (current_world__difficulty_bullet_speed)
	push bc
		call update_enemy_move_left_if_possible_a_times
	pop bc
	jp z, update_enemy_delete
update_enemy_bullet_x_done:

	ld a, b
	or a
	jr z, update_enemy_bullet_y_done
	jp m, update_enemy_bullet_y_negative
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_move_down_if_possible_a_times
	jp z, update_enemy_delete
	jr update_enemy_bullet_y_done
update_enemy_bullet_y_negative:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_move_up_if_possible_a_times
	jp z, update_enemy_delete
update_enemy_bullet_y_done:

	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 0) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_skeleton:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_skeleton_right
	dec a
	jr z, update_enemy_skeleton_left
	dec a
	jr z, update_enemy_skeleton_idle
	; we cannever reach here ...

update_enemy_skeleton_switch_to_state_idle:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
update_enemy_skeleton_idle:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jr nz, update_enemy_skeleton_idle_continue
	call random_a
	and #01
	jr z, update_enemy_skeleton_switch_to_state_right
	jr update_enemy_skeleton_switch_to_state_left
update_enemy_skeleton_idle_continue:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 29) * 4 
	jp enemy_sprite_and_continue_animated_slow

update_enemy_skeleton_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_skeleton_right_continue
update_enemy_skeleton_right:
	call random_a
	and #3f
	jr z, update_enemy_skeleton_switch_to_state_idle
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	jr z, update_enemy_skeleton_right_continue
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_skeleton_switch_to_state_left
update_enemy_skeleton_right_continue:
	ld d, COLOR_WHITE
update_enemy_skeleton_right_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 21) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_skeleton_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_skeleton_left_continue
update_enemy_skeleton_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	jr z, update_enemy_skeleton_left_continue
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_skeleton_switch_to_state_right
update_enemy_skeleton_left_continue:
	ld d, COLOR_WHITE
update_enemy_skeleton_left_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 25) * 4 
	jp enemy_sprite_and_continue_animated


;-----------------------------------------------
update_enemy_skeleton_thrower1:
update_enemy_skeleton_thrower2:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_skeleton_thrower_right
	dec a
	jr z, update_enemy_skeleton_thrower_left
	dec a
	jp z, update_enemy_skeleton_thrower_throw_right
	dec a
	jp z, update_enemy_skeleton_thrower_throw_left
	; we cannever reach here ...

update_enemy_skeleton_thrower_switch_to_state_right_from_throw:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_skeleton_thrower_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_skeleton_thrower_right_continue
update_enemy_skeleton_thrower_right:
	; throw?
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr c, update_enemy_skeleton_thrower_right_no_throw
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_skeleton_thrower_right_no_throw
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER2
	jr z, update_enemy_skeleton_thrower_right_throw
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_skeleton_thrower_right_no_throw
update_enemy_skeleton_thrower_right_throw:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; throw right!
	jr update_enemy_skeleton_thrower_right_continue
update_enemy_skeleton_thrower_right_no_throw:
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_skeleton_thrower_switch_to_state_left
update_enemy_skeleton_thrower_right_continue:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 21) * 4
	ld d, COLOR_YELLOW
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER1
	jp z, enemy_sprite_and_continue_animated
	ld d, COLOR_DARK_YELLOW
	jp enemy_sprite_and_continue_animated

update_enemy_skeleton_thrower_switch_to_state_left_from_throw:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_skeleton_thrower_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_skeleton_thrower_left_continue
update_enemy_skeleton_thrower_left:
	; throw?
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr c, update_enemy_skeleton_thrower_left_no_throw
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nc, update_enemy_skeleton_thrower_left_no_throw
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER2
	jr z, update_enemy_skeleton_thrower_left_throw
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_skeleton_thrower_left_no_throw
update_enemy_skeleton_thrower_left_throw:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; throw left!
	jr update_enemy_skeleton_thrower_left_continue
update_enemy_skeleton_thrower_left_no_throw:	
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_skeleton_thrower_switch_to_state_right
update_enemy_skeleton_thrower_left_continue:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 25) * 4
	ld d, COLOR_YELLOW
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER1
	jp z, enemy_sprite_and_continue_animated
	ld d, COLOR_DARK_YELLOW
	jp enemy_sprite_and_continue_animated

update_enemy_skeleton_thrower_throw_right:
	ld a, (current_world__difficulty_attack_warn_time)
	add a, a
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp c
	jp z, update_enemy_skeleton_thrower_switch_to_state_right_from_throw
	srl c
	cp c
	jr nz, update_enemy_skeleton_thrower_throw_right_continue2
	; throw:
	call ptr_to_new_sprite_enemy
	jr nz, update_enemy_skeleton_thrower_throw_right_continue2
	ld (hl), ENEMY_BONE_BULLET
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER1
	jr z, update_enemy_skeleton_thrower_throw_right_continue
	ld (hl), ENEMY_BONE_PARABOLA_BULLET
update_enemy_skeleton_thrower_throw_right_continue:
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	inc a
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (hl), a
	inc hl
	ld (hl), 0  ; right
	inc hl
	ld (hl), 0  ; state timer

	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority	
update_enemy_skeleton_thrower_throw_right_continue2:
	ld d, COLOR_YELLOW
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER1
	jp z, update_enemy_skeleton_thrower_throw_right_continue3
	ld d, COLOR_DARK_YELLOW
update_enemy_skeleton_thrower_throw_right_continue3:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 23) * 4
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 16
	jp c, enemy_sprite_and_continue
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 24) * 4
	jp enemy_sprite_and_continue

update_enemy_skeleton_thrower_throw_left:
	ld a, (current_world__difficulty_attack_warn_time)
	add a, a
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp c
	jp z, update_enemy_skeleton_thrower_switch_to_state_left_from_throw
	srl c
	cp c
	jr nz, update_enemy_skeleton_thrower_throw_left_continue2
	; throw:
	call ptr_to_new_sprite_enemy
	jr nz, update_enemy_skeleton_thrower_throw_right_continue2
	ld (hl), ENEMY_BONE_BULLET
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER1
	jr z, update_enemy_skeleton_thrower_throw_left_continue
	ld (hl), ENEMY_BONE_PARABOLA_BULLET
update_enemy_skeleton_thrower_throw_left_continue:
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	dec a
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	ld (hl), a
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (hl), a
	inc hl
	ld (hl), 1  ; left
	inc hl
	ld (hl), 0  ; state timer

	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
update_enemy_skeleton_thrower_throw_left_continue2:
	ld d, COLOR_YELLOW
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER1
	jp z, update_enemy_skeleton_thrower_throw_left_continue3
	ld d, COLOR_DARK_YELLOW
update_enemy_skeleton_thrower_throw_left_continue3:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 27) * 4
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 16
	jp c, enemy_sprite_and_continue
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 28) * 4
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_frog:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_frog_right
	dec a
	jr z, update_enemy_frog_left
	; we cannever reach here ...

update_enemy_frog_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_frog_right_continue
update_enemy_frog_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	bit 3, a
	jr z, update_enemy_frog_right_continue
	and #01
	jr z, update_enemy_frog_right_continue
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_frog_switch_to_state_left
update_enemy_frog_right_continue:
	ld d, COLOR_GREEN
update_enemy_frog_right_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 16) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_frog_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_frog_left_continue
update_enemy_frog_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	bit 3, a
	jr z, update_enemy_frog_left_continue
	and #01
	jr z, update_enemy_frog_left_continue
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_frog_switch_to_state_right
update_enemy_frog_left_continue:
	ld d, COLOR_GREEN
update_enemy_frog_left_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 19) * 4 
	jp enemy_sprite_and_continue_animated


;-----------------------------------------------
update_enemy_frog_tongue:
	ld iyl, COLOR_PURPLE
	jp update_enemy_frog_jumping_color_set
update_enemy_frog_jumping:
	ld iyl, COLOR_DARK_GREEN
update_enemy_frog_jumping_color_set:
	ld e, 2  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
update_enemy_frog_jumping_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_frog_jumping_right
	dec a
	jr z, update_enemy_frog_jumping_left
	dec a
	jr z, update_enemy_frog_jumping_jump_right
	dec a
	jp z, update_enemy_frog_jumping_jump_left
	dec a
	jp z, update_enemy_frog_jumping_tongue_right
	dec a
	jp z, update_enemy_frog_jumping_tongue_left

update_enemy_frog_jumping_action_chance:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_FROG_TONGUE
	jr nz, update_enemy_frog_jumping_action_chance_no_tongue
	call random_a
	cp 96
	jr nc, update_enemy_frog_jumping_action_chance_no_tongue
	; tongue!
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	add a, 4
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	jr update_enemy_frog_jumping_continue

update_enemy_frog_jumping_action_chance_no_tongue:
	; chance to jump:
	call random_a
	and #03
	jr nz, update_enemy_frog_jumping_continue
	; jump!
	inc (ix + ROOM_OBJECT_STRUCT_STATE)
	inc (ix + ROOM_OBJECT_STRUCT_STATE)
	jr update_enemy_frog_jumping_continue

update_enemy_frog_jumping_switch_to_state_right_reset_time:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_frog_jumping_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_frog_jumping_right_continue
update_enemy_frog_jumping_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 36
	jr z, update_enemy_frog_jumping_action_chance
	bit 3, a
	jr z, update_enemy_frog_jumping_right_continue
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_frog_jumping_switch_to_state_left
update_enemy_frog_jumping_right_continue:
	ld d, iyl
update_enemy_frog_jumping_right_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 16) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_frog_jumping_switch_to_state_left_reset_time:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_frog_jumping_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_frog_jumping_left_continue
update_enemy_frog_jumping_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 36
	jr z, update_enemy_frog_jumping_action_chance
	bit 3, a
	jr z, update_enemy_frog_jumping_left_continue
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_frog_jumping_switch_to_state_right
update_enemy_frog_jumping_left_continue:
	ld d, iyl
update_enemy_frog_jumping_left_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 19) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_frog_jumping_jump_right:
	call update_enemy_frog_jumping_jump
	jr z, update_enemy_frog_jumping_switch_to_state_right_reset_time
	call update_enemy_move_right_if_possible
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 17) * 4 
	jp enemy_sprite_and_continue

update_enemy_frog_jumping_jump_left:
	call update_enemy_frog_jumping_jump
	jr z, update_enemy_frog_jumping_switch_to_state_left_reset_time
	call update_enemy_move_left_if_possible
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 20) * 4 
	jp enemy_sprite_and_continue

update_enemy_frog_jumping_tongue_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr z, update_enemy_frog_jumping_switch_to_state_right_reset_time
	cp 16
	jp c, update_enemy_frog_jumping_tongue_right_done
	cp 18
	jr c, update_enemy_frog_jumping_tongue_right2
	cp 20
	jr c, update_enemy_frog_jumping_tongue_right4
	cp 24
	jr c, update_enemy_frog_jumping_tongue_right3
	cp 28
	jr c, update_enemy_frog_jumping_tongue_right2
update_enemy_frog_jumping_tongue_right1:
	ld c, 16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 22) * 4 
	call get_sprite_object_sprite_coordinates
	jp nz, update_enemy_frog_jumping_tongue_right_done
	call add_sprite_to_this_frame
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc c
	ld e, 2
	call update_enemy_hurt_player_bc_2x1
	jr update_enemy_frog_jumping_tongue_right_done
update_enemy_frog_jumping_tongue_right2:
	ld c, 16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 23) * 4 
	call get_sprite_object_sprite_coordinates
	jr nz, update_enemy_frog_jumping_tongue_right_done
	call add_sprite_to_this_frame
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc c
	inc c
	ld e, 2
	call update_enemy_hurt_player_bc_2x1
	jr update_enemy_frog_jumping_tongue_right_done
update_enemy_frog_jumping_tongue_right3:
	ld c, 16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 24) * 4 
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	ld c, 32
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 22) * 4 
	call get_sprite_object_sprite_coordinates
	jr nz, update_enemy_frog_jumping_tongue_right_done
	call add_sprite_to_this_frame
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc c
	inc c
	inc c
	ld e, 2
	call update_enemy_hurt_player_bc_2x1
	jr update_enemy_frog_jumping_tongue_right_done
update_enemy_frog_jumping_tongue_right4:
	ld c, 16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 24) * 4 
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	ld c, 32
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 23) * 4 
	call get_sprite_object_sprite_coordinates
	jr nz, update_enemy_frog_jumping_tongue_right_done
	call add_sprite_to_this_frame
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc c
	inc c
	inc c
	inc c
	ld e, 2
	call update_enemy_hurt_player_bc_2x1
update_enemy_frog_jumping_tongue_right_done:
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 18) * 4 
	jp enemy_sprite_and_continue

update_enemy_frog_jumping_tongue_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jp z, update_enemy_frog_jumping_switch_to_state_left_reset_time
	cp 16
	jp c, update_enemy_frog_jumping_tongue_left_done
	cp 18
	jr c, update_enemy_frog_jumping_tongue_left2
	cp 20
	jr c, update_enemy_frog_jumping_tongue_left4
	cp 24
	jr c, update_enemy_frog_jumping_tongue_left3
	cp 28
	jr c, update_enemy_frog_jumping_tongue_left2
update_enemy_frog_jumping_tongue_left1:
	ld c, -16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 25) * 4 
	call get_sprite_object_sprite_coordinates
	jp nz, update_enemy_frog_jumping_tongue_left_done
	call add_sprite_to_this_frame
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	dec c
	ld e, 2
	call update_enemy_hurt_player_bc_2x1
	jr update_enemy_frog_jumping_tongue_left_done
update_enemy_frog_jumping_tongue_left2:
	ld c, -16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 26) * 4 
	call get_sprite_object_sprite_coordinates
	jp nz, update_enemy_frog_jumping_tongue_left_done
	call add_sprite_to_this_frame
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	dec c
	dec c
	ld e, 2
	call update_enemy_hurt_player_bc_2x1
	jr update_enemy_frog_jumping_tongue_left_done
update_enemy_frog_jumping_tongue_left3:
	ld c, -16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 24) * 4 
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	ld c, -32
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 25) * 4 
	call get_sprite_object_sprite_coordinates
	jp nz, update_enemy_frog_jumping_tongue_left_done
	call add_sprite_to_this_frame
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	dec c
	dec c
	dec c
	ld e, 2
	call update_enemy_hurt_player_bc_2x1
	jp update_enemy_frog_jumping_tongue_left_done
update_enemy_frog_jumping_tongue_left4:
	ld c, -16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 24) * 4 
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	ld c, -32
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 26) * 4 
	call get_sprite_object_sprite_coordinates
	jp nz, update_enemy_frog_jumping_tongue_left_done
	call add_sprite_to_this_frame
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	dec c
	dec c
	dec c
	dec c
	ld e, 2
	call update_enemy_hurt_player_bc_2x1
update_enemy_frog_jumping_tongue_left_done:
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 21) * 4 
	jp enemy_sprite_and_continue


; returns:
; - z: if frog has landed
; - nz: otherwise
update_enemy_frog_jumping_jump:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 31
	jr c, update_enemy_frog_jumping_jump_continue
	ld a, 31
update_enemy_frog_jumping_jump_continue:
	ld hl, frog_jump_table
	ADD_HL_A
	ld a, (hl)  ; amount to move
	or a
	ld b, a
	jr z, update_enemy_frog_jumping_jump_done
	jp m, update_enemy_frog_jumping_jump_raise
update_enemy_frog_jumping_jump_fall:
	push bc
		call update_enemy_move_down_if_possible
	pop bc
	ret z
	djnz update_enemy_frog_jumping_jump_fall
	or 1
	ret
update_enemy_frog_jumping_jump_raise:
	push bc
		call update_enemy_move_up_if_possible
	pop bc
	inc b
	jr nz, update_enemy_frog_jumping_jump_raise
update_enemy_frog_jumping_jump_done:
	or 1
	ret

monkey_jump_table:
frog_jump_table:  ; 32 steps 
	db -4,-4					;  -8 pixels
	db -4,-4,-4,-4,-3,-3,-3,-2  ; -27 pixels
	db -2,-1,-2,-1,-1,-1, 0, 0  ;  -8 pixels (total: -43)
	db  0, 0, 1, 1, 1, 2, 1, 2
	db  2, 3, 3, 3, 4, 4


;-----------------------------------------------
update_enemy_bee:
	ld e, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_bee_movement_done

	; move towards player:
	ld a, (player_x + 1)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_bee_left
	jr nz, update_enemy_bee_right
	; same tile:
	ld a, (player_x)
	cp (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	jr c, update_enemy_bee_left
	jr z, update_enemy_bee_y
update_enemy_bee_right:
	; right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), (FIRST_ENEMY_SPRITE_PATTERN + 27) * 4
	call update_enemy_move_right
	jr update_enemy_bee_y
update_enemy_bee_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), (FIRST_ENEMY_SPRITE_PATTERN + 29) * 4
	call update_enemy_move_left

update_enemy_bee_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr c, update_enemy_bee_up
	jr nz, update_enemy_bee_down
	; same tile:
	ld a, (player_y)
	cp (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	jr c, update_enemy_bee_up
	jr z, update_enemy_bee_movement_done
update_enemy_bee_down:
	; down:
	call update_enemy_move_down
	jr update_enemy_bee_movement_done
update_enemy_bee_up:
	call update_enemy_move_up

update_enemy_bee_movement_done:
	ld d, COLOR_DARK_YELLOW
	ld e, (ix + ROOM_OBJECT_STRUCT_STATE)
	jp enemy_sprite_and_continue_animated_fast


;-----------------------------------------------
update_enemy_monkey_thrower:
	ld iyl, COLOR_PURPLE
	ld e, 2  ; damage to deal
	jr update_enemy_monkey_continue
update_enemy_monkey:
	ld iyl, COLOR_DARK_BLUE
	ld e, 1  ; damage to deal
update_enemy_monkey_continue:
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_monkey_right
	dec a
	jr z, update_enemy_monkey_left
	dec a
	jp z, update_enemy_monkey_jump
	dec a
	jp z, update_enemy_monkey_jump
	dec a
	jp z, update_enemy_monkey_throw
	dec a
	jp z, update_enemy_monkey_throw
	; we cannever reach here ...

update_enemy_monkey_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_monkey_right_continue
update_enemy_monkey_right:
	call update_enemy_move_right_if_possible_platform
	jr z, update_enemy_monkey_switch_to_state_left
update_enemy_monkey_right_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	jr nz, update_enemy_monkey_right_continue2
	; chance of jumping/throwing
	call random_a
	and #7
	push af
		call z, update_enemy_monkey_switch_to_state_jump
	pop af
	dec a
	call z, update_enemy_monkey_switch_to_state_throw
update_enemy_monkey_right_continue2:
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_monkey_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_monkey_left_continue
update_enemy_monkey_left:
	call update_enemy_move_left_if_possible_platform
	jr z, update_enemy_monkey_switch_to_state_right
update_enemy_monkey_left_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	jr nz, update_enemy_monkey_left_continue2
	; chance of jumping/throwing
	call random_a
	and #7
	push af
		call z, update_enemy_monkey_switch_to_state_jump
	pop af
	dec a
	call z, update_enemy_monkey_switch_to_state_throw
update_enemy_monkey_left_continue2:	
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 35) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_monkey_switch_to_state_jump:
	; decide whether to jump up/down, and check if it's possible:
	call random_a
	and #01
	jr z, update_enemy_monkey_switch_to_state_jump_up
	; try to drop:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call get_room_tile_type
	cp 1  ; platform
	ret nz
	call update_enemy_move_down  ; move one pixel down directly to avoid the first collision
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 20  ; start directly falling
	jr update_enemy_monkey_switch_to_state_jump_continue
update_enemy_monkey_switch_to_state_jump_up:
	; try to jump up:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp 6
	ret c  ; if monkey is up into the room, do not jump up
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_monkey_switch_to_state_jump_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	add 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ret

update_enemy_monkey_jump:
	call update_enemy_frog_jumping_jump
	jr nz, update_enemy_monkey_jump_continue
	; switch to walking:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_monkey_jump_continue:
	ld d, iyl
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	add a, a
	add a, a
	add a, FIRST_ENEMY_SPRITE_PATTERN + 34
	add a, a
	add a, a
	ld e, a
	jp enemy_sprite_and_continue

update_enemy_monkey_switch_to_state_throw:
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_MONKEY_THROWER
	ret nz
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	add 4
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ret

update_enemy_monkey_throw:
	ld a, (current_world__difficulty_attack_warn_time)
	ld c, a
	srl c
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp c  ; watn time / 2
	jr nz, update_enemy_monkey_throw_continue
	; throw:
	call update_enemy_fire_directional_bullet_towards_player
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0	
update_enemy_monkey_throw_continue:
	ld d, iyl
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	add a, a
	add a, a
	add a, FIRST_ENEMY_SPRITE_PATTERN + 33
	add a, a
	add a, a
	ld e, a
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_move_cb:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	add a, c
	jp p, update_enemy_move_cb_positive_x
	dec (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, 8
update_enemy_move_cb_positive_x:
	cp 8
	jr c, update_enemy_move_cb_carry_x
	inc (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, -8
update_enemy_move_cb_carry_x:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), a

	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	add a, b
	jp p, update_enemy_move_cb_positive_y
	dec (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	add a, 8
update_enemy_move_cb_positive_y:
	cp 8
	jr c, update_enemy_move_cb_carry_y
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	add a, -8
update_enemy_move_cb_carry_y:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), a
	ret


;-----------------------------------------------
update_enemy_fire_directional_bullet_towards_player:
	; see if player is close enough:
	ld a, (player_x + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp 16 
	ret p
	cp -16
	ret m
	ld c, a
	ld a, (player_y + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp 16 
	ret p
	cp -16
	ret m
	ld b, a
	; fire a bullet:
	push bc
		call ptr_to_new_sprite_enemy
	pop bc
	ret nz
	ld (hl), ENEMY_BULLET
	inc hl
	ld (hl), 0  ; pixel X
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	inc hl
	ld (hl), a
	inc hl
	ld (hl), 4  ; pixel Y
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (hl), a
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), c  ; speed x
	inc hl
	ld (hl), b  ; speed y
	ld hl, SFX_enemy_bullet
	jp play_SFX_with_high_priority


;-----------------------------------------------
; input:
; - d: sprite color
; - e: sprite frame
enemy_sprite_and_continue_animated_slow:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rrca
	rrca
	and #04
	add a, e
	ld e, a
	jr enemy_sprite_and_continue


;-----------------------------------------------
; input:
; - d: sprite color
; - e: sprite frame
enemy_sprite_and_continue_animated4:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rlca
	and #0c
	add a, e
	ld e, a
	jp enemy_sprite_and_continue


;-----------------------------------------------
; input:
; - d: sprite color
; - e: sprite frame
enemy_sprite_and_continue_animated_fast:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	add a, a
	add a, a
	add a, e
	ld e, a
	jp enemy_sprite_and_continue


;-----------------------------------------------
; input:
; - d: sprite color
; - e: sprite frame
enemy_sprite_and_continue_animated:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rrca
	and #04
	add a, e
	ld e, a
	; jp enemy_sprite_and_continue


;-----------------------------------------------
; input:
; - d: sprite color
; - e: sprite frame
enemy_sprite_and_continue:
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_delete:
	call sprite_object_remove_object_enemy
	jp update_sprite_enemies_loop_next_after_deletion


;-----------------------------------------------
; input:
; - e: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player_shieldable_bullet:
	ld a, (player_current_item)
	cp 3  ; shield
	jp nz, update_enemy_hurt_player_1x1
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DIRECTIONAL_WEAPON
	jr z, update_enemy_hurt_player_shieldable_bullet_with_directional
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_JUMPING
	jr z, update_enemy_hurt_player_shieldable_bullet_with_directional
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_FALLING
	jr z, update_enemy_hurt_player_shieldable_bullet_with_directional
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING
	jp nz, update_enemy_hurt_player_1x1
update_enemy_hurt_player_shieldable_bullet_with_directional:
	; check if the player has the shield up and in the correct direction:
	ld a, (player_weapon_swing_type)
	cp PLAYER_WEAPON_SHIELD_UP
	jr z, update_enemy_hurt_player_shieldable_bullet_shield_up
	cp PLAYER_WEAPON_SHIELD_FORWARD
	jp nz, update_enemy_hurt_player_1x1
update_enemy_hurt_player_shieldable_bullet_shield_fw:
	ld a, (player_state)
	and #01
	jr z, update_enemy_hurt_player_shieldable_bullet_shield_right

update_enemy_hurt_player_shieldable_bullet_shield_left:
	ld a, (player_x + 1)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr z, update_enemy_hurt_player_shieldable_bullet_shield_left_y
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp nz, update_enemy_hurt_player_1x1
update_enemy_hurt_player_shieldable_bullet_shield_left_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	jp update_enemy_hurt_player_1x1

update_enemy_hurt_player_shieldable_bullet_shield_right:
	ld a, (player_x + 1)
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
; 	jr z, update_enemy_hurt_player_shieldable_bullet_shield_left_y
; 	inc a
; 	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp nz, update_enemy_hurt_player_1x1
update_enemy_hurt_player_shieldable_bullet_shield_right_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	jp update_enemy_hurt_player_1x1

update_enemy_hurt_player_shieldable_bullet_shield_up:
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr z, update_enemy_hurt_player_shieldable_bullet_shield_up_y
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ret nz
update_enemy_hurt_player_shieldable_bullet_shield_up_y:
	ld a, (player_y + 1)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	jp update_enemy_hurt_player_1x1

update_enemy_hurt_player_shieldable_bullet_shielded:
	ld hl, SFX_shield
	call play_SFX_with_high_priority
	xor a  ; hit
	ret


;-----------------------------------------------
; input:
; - c, b: enemy x, y tile coordinates
; - e: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player_bc_2x1:
	ld a, (player_immunity_timer)
	or a
	ret nz  ; player immune
	ld a, (player_x + 1)
	cp c
	jr z, update_enemy_hurt_player_bc_2x1_y
	dec a
	cp c
	ret nz
update_enemy_hurt_player_bc_2x1_y:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CROUCHING
	jr z, update_enemy_hurt_player_bc_2x1_y_short
	cp PLAYER_STATE_CRAWLING
	jr z, update_enemy_hurt_player_bc_2x1_y_short
	cp PLAYER_STATE_SWIMMING
	jr z, update_enemy_hurt_player_bc_2x1_y_short
	ld a, (player_y + 1)
	cp b
	jr z, update_enemy_hurt_player_bc_2x1_collision
update_enemy_hurt_player_bc_2x1_y_continue:
	inc a
	cp b
	ret nz
update_enemy_hurt_player_bc_2x1_collision:
	; player is hit!
	ld c, e
	call player_hit_damage_c
	xor a  ; hit
	ret

update_enemy_hurt_player_bc_2x1_y_short:
	ld a, (player_y + 1)
	jr update_enemy_hurt_player_bc_2x1_y_continue


;-----------------------------------------------
; input:
; - ix: enemy ptr
; - e: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player:
	ld a, (player_immunity_timer)
	or a
	ret nz  ; player immune
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DEAD
	ret z  ; player already dead
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld a, (player_x + 1)
	cp c
	jr z, update_enemy_hurt_player_y
	dec a
	cp c
	ret nz
update_enemy_hurt_player_y:
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CROUCHING
	jr z, update_enemy_hurt_player_y_short
	cp PLAYER_STATE_CRAWLING
	jr z, update_enemy_hurt_player_y_short
	cp PLAYER_STATE_SWIMMING
	jr z, update_enemy_hurt_player_y_short
	ld a, (player_y + 1)
	cp b
	jr z, update_enemy_hurt_player_collision
	inc a
update_enemy_hurt_player_y_continue:
	cp b
	jr z, update_enemy_hurt_player_collision
	dec a
	dec a
	cp b
	ret nz
update_enemy_hurt_player_collision:
	; player is hit!
	ld c, e
	call player_hit_damage_c
	xor a  ; hit
	ret

update_enemy_hurt_player_y_short:
	ld a, (player_y + 1)
	jr update_enemy_hurt_player_y_continue


;-----------------------------------------------
; input:
; - ix: enemy ptr
; - e: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player_1x1:
	ld a, (player_immunity_timer)
	or a
	ret nz  ; player immune
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DEAD
	ret z  ; player already dead
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld a, (player_x + 1)
	cp c
	jr z, update_enemy_hurt_player_1x1_y
	dec a
	cp c
	ret nz
update_enemy_hurt_player_1x1_y:
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CROUCHING
	jr z, update_enemy_hurt_player_1x1_y_short
	cp PLAYER_STATE_CRAWLING
	jr z, update_enemy_hurt_player_1x1_y_short
	cp PLAYER_STATE_SWIMMING
	jr z, update_enemy_hurt_player_1x1_y_short
	ld a, (player_y + 1)
	cp b  ; bullet_y == player_y?
	jr z, update_enemy_hurt_player_1x1_collision
update_enemy_hurt_player_1x1_y_continue:
	inc a
	cp b  ; bullet_y == player_y + 1?
	ret nz
update_enemy_hurt_player_1x1_collision:
	; player is hit!
	ld c, e
	call player_hit_damage_c
	xor a  ; hit
	ret

update_enemy_hurt_player_1x1_y_short:
	ld a, (player_y + 1)
	jr update_enemy_hurt_player_1x1_y_continue


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_move_right_if_possible_platform:
	call update_enemy_can_move_right_platform
	ret z
	jp update_enemy_move_right


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_move_right_if_possible:
	call update_enemy_can_move_right
	ret z
	; jp update_enemy_move_right


;-----------------------------------------------
; input:
; - ix: enemy ptr
update_enemy_move_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	inc a
	cp 8
	jr nz, update_enemy_move_right_continue
	inc (ix + ROOM_OBJECT_STRUCT_TILE_X)
	xor a
update_enemy_move_right_continue:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), a
	or 1  ; movement happened
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_move_left_if_possible_platform:
	call update_enemy_can_move_left_platform
	ret z
	jp update_enemy_move_left


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_move_left_if_possible:
	call update_enemy_can_move_left
	ret z
	; jp update_enemy_move_left


;-----------------------------------------------
; input:
; - ix: enemy ptr
update_enemy_move_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	dec a
	cp #ff
	jr nz, update_enemy_move_left_continue
	dec (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld a, 7
update_enemy_move_left_continue:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), a
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_move_up_if_possible:
	call update_enemy_can_move_up
	ret z
	; jp update_enemy_move_up


;-----------------------------------------------
; input:
; - ix: enemy ptr
update_enemy_move_up:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	dec a
	cp #ff
	jr nz, update_enemy_move_up_continue
	dec (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld a, 7
update_enemy_move_up_continue:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), a
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_move_down_if_possible:
	call update_enemy_can_move_down
	ret z
	; jp update_enemy_move_down


;-----------------------------------------------
; input:
; - ix: enemy ptr
update_enemy_move_down:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	inc a
	cp 8
	jr nz, update_enemy_move_down_continue
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	xor a
update_enemy_move_down_continue:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), a
	or 1  ; movement happened
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_can_move_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	inc b
	call general_check_collision_with_wall
	ret z

	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr z, update_enemy_can_move_right_can
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	inc b
	inc b
	jp general_check_collision
update_enemy_can_move_right_can:
update_enemy_can_move_left_can:
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_can_move_right_platform:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	inc b
	call general_check_collision_with_wall
	ret z
	; check if the platform ends:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	inc b
	inc b
	call general_check_collision
	jr nz, update_enemy_can_move_right_cannot
	or 1
	ret
update_enemy_can_move_right_cannot:
update_enemy_can_move_left_cannot:
	xor a
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_can_move_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
; 	dec c
	inc b
	call general_check_collision_with_wall
	ret z

	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr z, update_enemy_can_move_left_can
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	; dec c
	inc b
	inc b
	jp general_check_collision


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_can_move_left_platform:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
; 	dec c
	inc b
	call general_check_collision_with_wall
	ret z

	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
; 	dec c
	inc b
	inc b
	call general_check_collision
	jr nz, update_enemy_can_move_left_cannot
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_can_move_up:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	ret nz
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	jr nc, update_enemy_can_move_up_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call general_check_collision_with_wall
	ret z
update_enemy_can_move_up_continue:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	jp general_check_collision_with_wall


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_can_move_down:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	ret nz
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	jr nc, update_enemy_can_move_down_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call general_check_collision
	ret z
update_enemy_can_move_down_continue;
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc b
	inc b
	jp general_check_collision


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_water_move_right_if_possible:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	jr nz, update_enemy_water_move_right_if_possible_move
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	call general_check_collision
	ret z
update_enemy_water_move_right_if_possible_move:
	call update_enemy_move_right
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_water_move_left_if_possible:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	jr nz, update_enemy_water_move_left_if_possible_move
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec c
	call general_check_collision
	ret z
update_enemy_water_move_left_if_possible_move:
	call update_enemy_move_left
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_bullet_move_right_if_possible:
	ld a, (current_room__width)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ret z  ; screen edge
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	jr nz, update_enemy_bullet_move_right_if_possible_move
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	; inc c
	inc c
	inc b
	call general_check_collision
	ret z
update_enemy_bullet_move_right_if_possible_move:
	call update_enemy_move_right
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_bullet_move_left_if_possible:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ret z  ; screen edge
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	jr nz, update_enemy_bullet_move_left_if_possible_move
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec c
	inc b
	call general_check_collision
	ret z
update_enemy_bullet_move_left_if_possible_move:
	call update_enemy_move_left
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_bullet_move_down_if_possible:
	ld a, (current_room__height)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ret z  ; screen edge
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr nz, update_enemy_bullet_move_down_if_possible_move
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	call general_check_collision
	ret z
update_enemy_bullet_move_down_if_possible_move:
	call update_enemy_move_down
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_bullet_move_up_if_possible:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ret z  ; screen edge
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr nz, update_enemy_bullet_move_up_if_possible_move
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec b
	call general_check_collision
	ret z
update_enemy_bullet_move_up_if_possible_move:
	call update_enemy_move_up
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; - iyl: hit ID
; - iyh: damage to deal
enemy_hit:
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_POISON_BULLET
	ret z  ; we cannot damage bullets
	cp ENEMY_BULLET
	ret z  ; we cannot damage bullets
	cp ENEMY_PARABOLA_BULLET
	ret z  ; we cannot damage bullets
	ld a, iyl
	ld (ix + ROOM_OBJECT_STRUCT_LAST_HIT_ID), a
	ld a, (ix + ROOM_OBJECT_STRUCT_HEALTH)
	sub iyh
	jr z, enemy_hit_killed
	jr c, enemy_hit_killed
	ld (ix + ROOM_OBJECT_STRUCT_HEALTH), a
	ld hl, SFX_enemy_hit
	jp play_SFX_with_high_priority
enemy_hit_killed:
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	push af
		ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
		ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
		push bc
			call sprite_object_remove_object_enemy
		pop bc
		push bc
			call spawn_explosion
		pop bc
	pop af
	cp ENEMY_BONE_BULLET
	ret z  ; bones do not have drops
	cp ENEMY_BONE_PARABOLA_BULLET
	ret z  ; bones do not have drops
	; jp enemy_maybe_spawn_drop


;-----------------------------------------------
; input:
; - c, b: x, y coordinates of the drop
enemy_maybe_spawn_drop:
	; check that we are spawning over background:
	push bc
		call get_room_tile_type
	pop bc
	or a
	jr nz, enemy_maybe_spawn_drop_continue
	inc c
	push bc
		call get_room_tile_type
	pop bc
	dec c
	or a
	jr nz, enemy_maybe_spawn_drop_continue
	inc b
	push bc
		call get_room_tile_type
	pop bc
	dec b
	or a
	jr nz, enemy_maybe_spawn_drop_continue
	inc b
	inc c
	push bc
		call get_room_tile_type
	pop bc
	dec b
	dec c
	or a
	jr nz, enemy_maybe_spawn_drop_continue

	call random_a
	; item drop:
	cp 8 * 2
	ld hl, spawn_tile_object_1_coin
	jr c, enemy_maybe_spawn_drop_drop
	cp 16 * 2
	ld hl, spawn_tile_object_corn
	jr c, enemy_maybe_spawn_drop_drop
	cp 24 * 2
	ld hl, spawn_tile_object_2_stones
	jr c, enemy_maybe_spawn_drop_drop_stones
	cp 32 * 2
	ld hl, spawn_tile_object_2_darts
	jr c, enemy_maybe_spawn_drop_drop_darts
	cp 40 * 2
	ld hl, spawn_tile_object_2_spears
	jr c, enemy_maybe_spawn_drop_drop_spears
	cp 48 * 2
	ld hl, spawn_tile_object_battery
	jr c, enemy_maybe_spawn_drop_drop_battery
enemy_maybe_spawn_drop_continue:
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ld hl, SFX_enemy_kill
	jp play_SFX_with_high_priority

enemy_maybe_spawn_drop_drop:
	ld e, TILES_PAGE
	call call_hl_in_page_e_8000
	jr enemy_maybe_spawn_drop_continue

enemy_maybe_spawn_drop_drop_stones:
	ld a, (player_inventory_weapons+4)  ; do we have the sling?
	or a
	jr z, enemy_maybe_spawn_drop_continue
	jr enemy_maybe_spawn_drop_drop

enemy_maybe_spawn_drop_drop_darts:
	ld a, (player_inventory_weapons+5)  ; do we have the blowgun?
	or a
	jr z, enemy_maybe_spawn_drop_continue
	jr enemy_maybe_spawn_drop_drop

enemy_maybe_spawn_drop_drop_spears:
	ld a, (player_inventory_weapons+6)  ; do we have the atlatl
	or a
	jr z, enemy_maybe_spawn_drop_continue
	jr enemy_maybe_spawn_drop_drop

enemy_maybe_spawn_drop_drop_battery:
	ld a, (player_inventory_weapons+7)  ; do we have the raygun
	or a
	jr z, enemy_maybe_spawn_drop_continue
	jr enemy_maybe_spawn_drop_drop


;-----------------------------------------------
; input:
; - a: number of frames to move * 2
; output:
; - z: collision
; - nz: no collision
update_enemy_move_right_if_possible_a_times:
	srl a
	ld b, a
	jr nc, update_enemy_move_right_if_possible_a_times_continue
	ld a, (game_cycle)
	rrca
	rrca
	jr c, update_enemy_move_right_if_possible_a_times_continue
	inc b
update_enemy_move_right_if_possible_a_times_continue:
update_enemy_move_right_if_possible_a_times_loop:
	push bc
		call update_enemy_bullet_move_right_if_possible
	pop bc
	ret z
	djnz update_enemy_move_right_if_possible_a_times_loop
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - a: number of frames to move * 2
; output:
; - z: collision
; - nz: no collision
update_enemy_move_left_if_possible_a_times:
	srl a
	ld b, a
	jr nc, update_enemy_move_left_if_possible_a_times_continue
	ld a, (game_cycle)
	rrca
	rrca
	jr c, update_enemy_move_left_if_possible_a_times_continue
	inc b
update_enemy_move_left_if_possible_a_times_continue:
update_enemy_move_left_if_possible_a_times_loop:
	push bc
		call update_enemy_bullet_move_left_if_possible
	pop bc
	ret z
	djnz update_enemy_move_left_if_possible_a_times_loop
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - a: number of frames to move * 2
; output:
; - z: collision
; - nz: no collision
update_enemy_move_down_if_possible_a_times:
	srl a
	ld b, a
	jr nc, update_enemy_move_down_if_possible_a_times_continue
	ld a, (game_cycle)
	rrca
	rrca
	jr c, update_enemy_move_down_if_possible_a_times_continue
	inc b
update_enemy_move_down_if_possible_a_times_continue:
update_enemy_move_down_if_possible_a_times_loop:
	push bc
		call update_enemy_bullet_move_down_if_possible
	pop bc
	ret z
	djnz update_enemy_move_down_if_possible_a_times_loop
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - a: number of frames to move * 2
; output:
; - z: collision
; - nz: no collision
update_enemy_move_up_if_possible_a_times:
	srl a
	ld b, a
	jr nc, update_enemy_move_up_if_possible_a_times_continue
	ld a, (game_cycle)
	rrca
	rrca
	jr c, update_enemy_move_up_if_possible_a_times_continue
	inc b
update_enemy_move_up_if_possible_a_times_continue:
update_enemy_move_up_if_possible_a_times_loop:
	push bc
		call update_enemy_bullet_move_up_if_possible
	pop bc
	ret z
	djnz update_enemy_move_up_if_possible_a_times_loop
	or 1  ; nz
	ret

