;-----------------------------------------------
enemy_update_fn_table:
	dw update_enemy_bullet
	dw update_enemy_poison_bullet
	dw update_enemy_parabola_bullet
	dw update_enemy_bullet_whirlwind  ; boss 1 attack
	dw update_enemy_bullet_lightning  ; boss 1/4 attack
	dw update_enemy_sonic_boom  ; boss 2 attack
	dw update_enemy_boss2_spikes ; boss 2 attack
	dw update_enemy_boss3_debris ; boss 3 attack
	dw update_enemy_bullet_fireball
	dw update_enemy_pus_drop  ; boss 4 attack
	dw update_enemy_blood_drop  ; boss 4 attack
	dw update_enemy_pus_ball  ; boss 4 attack
	dw update_enemy_blood_ball  ; boss 4 attack
	dw update_enemy_boss4_blades  ; boss 4 attack
	dw update_enemy_bullet_waterball
	dw update_enemy_laser  ; atlantis sentinel, and boss 5 attack
	dw update_enemy_bullet_ignoring_walls  ; ignores wall collisions
	dw update_enemy_bullet_bubble  ; boss 5 attack
	; enemies you can hit:
	dw update_enemy_snake  ; left-to-right
	dw update_enemy_snake_dasher  ; left-to-right + dash
	dw update_enemy_snake_poison  ; left-to-right + poison bullet
	dw update_enemy_fish  ; swim left-to-right
	dw update_enemy_fish_jumper  ; swim left-to-right + jump
	dw update_enemy_bat
	dw update_enemy_bat_aggressive
	dw update_enemy_skeleton
	dw update_enemy_skeleton_thrower1
	dw update_enemy_skeleton_thrower2
	dw update_enemy_bone_bullet
	dw update_enemy_bone_parabola_bullet
	dw update_enemy_frog
	dw update_enemy_frog_jumping
	dw update_enemy_frog_tongue
	dw update_enemy_bee
	dw update_enemy_monkey
	dw update_enemy_monkey_thrower
	dw update_enemy_skeleton_flame1
	dw update_enemy_skeleton_flame2
	dw update_enemy_rockman
	dw update_enemy_rockman2
	dw update_enemy_ant
	dw update_enemy_ant2
	dw update_enemy_skeleton_sleeper
	dw update_enemy_fire_imp
	dw update_enemy_fire_imp
	dw update_enemy_fireball
	dw update_enemy_skeleton_thrower1
	dw update_enemy_skeleton_thrower2
	dw update_enemy_ghost
	dw update_enemy_ghost2
	dw update_enemy_fishman
	dw update_enemy_fishman2
	dw update_enemy_sentinel_rock
	dw update_enemy_alien
	dw update_enemy_mars_snail1
	dw update_enemy_mars_snail2
	dw update_enemy_mars_blob1
	dw update_enemy_mars_blob2
	dw update_enemy_mars_drone1
	dw update_enemy_mars_drone2


;-----------------------------------------------
update_sprite_enemies:
	; we do not need to initialize "n_displayed_object_sprites", since this is always called
	; after "update_sprite_objects"
	ld ix, current_room__sprite_enemies
update_sprite_enemies_loop:
	ld a, (ix + ROOM_OBJECT_STRUCT_ID)
	cp #ff  ; empty object
	ret z
	cp #fe  ; sentinel
	ret z
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
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
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	call nz, update_enemy__patrol_left_right_platform
	ld d, COLOR_DARK_YELLOW
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	add a, a
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 1
 	add a, a
 	add a, a
 	ld e, a
	jp enemy_sprite_and_continue_animated


;-----------------------------------------------
update_enemy_snake_dasher:
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	call nz, update_enemy__patrol_left_right_platform
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_snake_dasher_right
	dec a
	jr z, update_enemy_snake_dasher_left
	dec a
	jp z, update_enemy_snake_dasher_dash_right
	dec a
	jp z, update_enemy_snake_dasher_dash_left
	; we cannever reach here.

update_enemy_snake_dasher_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_snake_dasher_right_continue
update_enemy_snake_dasher_right:
	; dash?
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_snake_dasher_right_continue
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_snake_dasher_right_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; dash right!
update_enemy_snake_dasher_right_continue:
	ld d, COLOR_DARK_GREEN
update_enemy_snake_right_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 1) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_snake_dasher_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_snake_dasher_left_continue
update_enemy_snake_dasher_left:
	; dash?
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_snake_dasher_left_continue
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nc, update_enemy_snake_dasher_left_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; dash left!
update_enemy_snake_dasher_left_continue:
	ld d, COLOR_DARK_GREEN
update_enemy_snake_left_continue_color_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 3) * 4 
	jp enemy_sprite_and_continue_animated

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
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	call update_enemy__patrol_left_right_platform
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_snake_poison_right
	dec a
	jr z, update_enemy_snake_poison_left
	dec a
	jp z, update_enemy_snake_poison_spit_right
	dec a
	jp z, update_enemy_snake_poison_spit_left
	; we cannever reach here.

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
update_enemy_snake_poison_right_no_spit:
	ld d, COLOR_GREEN
	jp update_enemy_snake_right_continue_color_set

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
update_enemy_snake_poison_left_no_spit:	
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
	ld (hl), 0  ; ID
	inc hl
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
	add a, 4
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
	ld (hl), 0  ; ID
	inc hl
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
	add a, 4
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
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr nz, update_enemy_poison_bullet_left

update_enemy_poison_bullet_right:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_bullet_move_right_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_GREEN
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4 
	jp enemy_sprite_and_continue

update_enemy_poison_bullet_left:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_bullet_move_left_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_GREEN
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_bone_bullet:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr nz, update_enemy_bone_bullet_left

update_enemy_bone_bullet_right:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_bullet_move_right_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4 
	jp enemy_sprite_and_continue_animated4

update_enemy_bone_bullet_left:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_bullet_move_left_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4 
	jp enemy_sprite_and_continue_animated4


;-----------------------------------------------
update_enemy_bone_parabola_bullet_table:
	db -3, -3, -2, -2, -1, -1,  0,  0
	db  0,  1,  1,  2,  2,  3,  3,  4


update_enemy_bone_parabola_bullet:
	ld iyh, 1  ; damage to deal
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
	ld iyh, 1  ; damage to deal
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
update_enemy_bullet_fireball:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)  ; if it's 0, flame has landed
	or a
	jr z, update_enemy_bullet_fireball_landed
	ld iyh, 2  ; damage to deal
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
	jr nz, update_enemy_bullet_fireball_continue
	jp update_enemy_delete
	ld a, 64
update_enemy_bullet_fireball_continue:
	srl a
	cp 14
	jr c, update_enemy_bullet_fireball_continue2
	ld a, 13
update_enemy_bullet_fireball_continue2:
	ld hl, update_enemy_bone_parabola_bullet_table + 2  ; "+2 to have less initial y speed"
	ADD_HL_A
	ld b, (hl)
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld c, (ix + ROOM_OBJECT_STRUCT_STATE)
	call update_enemy_move_cb_colliding_down
	jp z, update_enemy_bullet_fireball_land  ; collision down
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 3) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_bullet_fireball_land:
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_bullet_fireball_landed:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_bullet
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 160
	jp z, update_enemy_delete  ; timeout
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 5) * 4 
	jp enemy_sprite_and_continue_animated


;-----------------------------------------------
update_enemy_bullet_waterball:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)  ; if it's 0, water has landed
	or a
	jr z, update_enemy_bullet_waterball_landed
	ld iyh, 2  ; damage to deal
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
	jr nz, update_enemy_bullet_waterball_continue
	jp update_enemy_delete
	ld a, 64
update_enemy_bullet_waterball_continue:
	srl a
	cp 14
	jr c, update_enemy_bullet_waterball_continue2
	ld a, 13
update_enemy_bullet_waterball_continue2:
	ld hl, update_enemy_bone_parabola_bullet_table + 2  ; "+2 to have less initial y speed"
	ADD_HL_A
	ld b, (hl)
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld c, (ix + ROOM_OBJECT_STRUCT_STATE)
	call update_enemy_move_cb_colliding_down
	jp z, update_enemy_bullet_waterball_land  ; collision down
	ld d, COLOR_LIGHT_BLUE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 38) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_bullet_waterball_land:
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_bullet_waterball_landed:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_bullet
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jp z, update_enemy_delete  ; timeout
	ld d, COLOR_LIGHT_BLUE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 1) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_bullet_bubble:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)  ; if it's 128, water has hit the player
	cp 128
	jr z, update_enemy_bullet_bubble_hit_state
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_bullet_bubble_hit
	; out of bounds?
	ld a, (current_room__width)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp c
	jp nc, update_enemy_delete
	ld a, (current_room__height)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	or a
	jp z, update_enemy_delete
	; parabola:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jr nz, update_enemy_bullet_bubble_continue
	jp update_enemy_delete
	ld a, 64
update_enemy_bullet_bubble_continue:
	srl a
	cp 14
	jr c, update_enemy_bullet_bubble_continue2
	ld a, 13
update_enemy_bullet_bubble_continue2:
	ld hl, update_enemy_bone_parabola_bullet_table + 2  ; "+2 to have less initial y speed"
	ADD_HL_A
	ld b, (hl)
	ld a, b
	neg
	ld b, a  ; inverted parabolla
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld c, (ix + ROOM_OBJECT_STRUCT_STATE)
	call update_enemy_move_cb
	ld d, COLOR_LIGHT_BLUE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 11) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_bullet_bubble_hit:
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 128
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_bullet_bubble_hit_state:
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jp z, update_enemy_delete  ; timeout
	ld d, COLOR_LIGHT_BLUE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 13) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_fish:
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_fish_right
	dec a
	jr z, update_enemy_fish_left
	; we cannever reach here.

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
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
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
	; we cannever reach here.

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
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
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
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	
	ld a, (current_world__difficulty_bullet_speed)
	ld l, a
	call update_enemy_bullet_bresenham_l_steps
	; - b: amount to move in y
	; - c: amount to move in x
	call update_enemy_move_cb

	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call general_check_collision_with_wall
	jp z, update_enemy_delete

	; out of the screen?
	ld a, (current_room__width)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp z, update_enemy_delete
	jp c, update_enemy_delete

	ld a, (current_room__height)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jp z, update_enemy_delete
	jp c, update_enemy_delete

	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 0) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_bullet_ignoring_walls:
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete
	
	ld a, (current_world__difficulty_bullet_speed)
	ld l, a
	call update_enemy_bullet_bresenham_l_steps
	; - b: amount to move in y
	; - c: amount to move in x
	call update_enemy_move_cb

	; out of the screen?
	ld a, (current_room__width)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp z, update_enemy_delete
	jp c, update_enemy_delete

	ld a, (current_room__height)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jp z, update_enemy_delete
	jp c, update_enemy_delete

	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 0) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_skeleton:
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	cp 2
	jr z, update_enemy_skeleton_idle
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	call nz, update_enemy__patrol_left_right_platform

update_enemy_skeleton_walking:
	call random_a
	and #7f
	jr z, update_enemy_skeleton_switch_to_state_idle
update_enemy_skeleton_walking_continue:
	ld d, COLOR_WHITE
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	add a, a
 	add a, a
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 21
 	add a, a
 	add a, a
 	ld e, a
	jp enemy_sprite_and_continue_animated

update_enemy_skeleton_switch_to_state_idle:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
update_enemy_skeleton_idle:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jr c, update_enemy_skeleton_idle_continue
	call random_a
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0  ; right
	jr z, update_enemy_skeleton_walking_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_skeleton_walking_continue
update_enemy_skeleton_idle_continue:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 29) * 4 
	jp enemy_sprite_and_continue_animated_slow


;-----------------------------------------------
update_enemy_skeleton_thrower1:
update_enemy_skeleton_thrower2:
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	call update_enemy__patrol_left_right_platform
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_skeleton_thrower_right
	dec a
	jr z, update_enemy_skeleton_thrower_left
	dec a
	jp z, update_enemy_skeleton_thrower_throw_right
	dec a
	jp z, update_enemy_skeleton_thrower_throw_left
	; we cannever reach here.

update_enemy_skeleton_thrower_switch_to_state_right_from_throw:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_skeleton_thrower_right_continue
update_enemy_skeleton_thrower_right:
	; throw?
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr c, update_enemy_skeleton_thrower_right_continue
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_skeleton_thrower_right_continue
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER2
	jr z, update_enemy_skeleton_thrower_right_throw
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_skeleton_thrower_right_continue
update_enemy_skeleton_thrower_right_throw:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; throw right!
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
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	jr update_enemy_skeleton_thrower_left_continue
update_enemy_skeleton_thrower_left:
	; throw?
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr c, update_enemy_skeleton_thrower_left_continue
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nc, update_enemy_skeleton_thrower_left_continue
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_THROWER2
	jr z, update_enemy_skeleton_thrower_left_throw
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr nz, update_enemy_skeleton_thrower_left_continue
update_enemy_skeleton_thrower_left_throw:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; throw left!
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
	ld (hl), 0  ; ID
	inc hl
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
	inc hl
	inc hl
	ld (hl), 1  ; hitpoints

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
	ld (hl), 0  ; ID
	inc hl
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
	inc hl
	inc hl
	ld (hl), 1  ; hitpoints

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
update_enemy_skeleton_flame1:
update_enemy_skeleton_flame2:
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	sub 2
	jp z, update_enemy_skeleton_flame_spit_right
	dec a
	jp z, update_enemy_skeleton_flame_spit_left
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #01
	call nz, update_enemy__patrol_left_right_platform

update_enemy_skeleton_flame_walking:
	call random_a
	and #7f
	jr nz, update_enemy_skeleton_flame_walking_continue
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	add a, 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_skeleton_flame_walking_continue:
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	and #01
 	add a, a
 	add a, a
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 21
 	add a, a
 	add a, a
 	ld e, a
	ld d, COLOR_LIGHT_RED
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_FLAME1
	jp z, enemy_sprite_and_continue_animated
	ld d, COLOR_RED
	jp enemy_sprite_and_continue_animated
update_enemy_skeleton_flame_walking_continue2_second_frame:
	ld a, 4
	add a, e
	ld e, a
update_enemy_skeleton_flame_walking_continue2:
	ld d, COLOR_LIGHT_RED
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_FLAME1
	jp z, enemy_sprite_and_continue
	ld d, COLOR_RED
	jp enemy_sprite_and_continue

update_enemy_skeleton_flame_spit_right:
	ld d, 2  ; speed of the bullet
	ld iyl, 1  ; x tile offset of bullet
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 23) * 4 
update_enemy_skeleton_flame_spit_right_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 24
	jr z, update_enemy_skeleton_flame_spit_right_spit
	jr c, update_enemy_skeleton_flame_walking_continue2
	cp 48
	jr nz, update_enemy_skeleton_flame_walking_continue2_second_frame
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	add a, -2
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0	
	jr update_enemy_skeleton_flame_walking_continue2

update_enemy_skeleton_flame_spit_left:
	ld d, -2  ; speed of the bullet
	ld iyl, 0  ; x tile offset of bullet
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 27) * 4
	jr update_enemy_skeleton_flame_spit_right_continue

update_enemy_skeleton_flame_spit_right_spit:
	; spit fire:
	push de
		call ptr_to_new_sprite_enemy
	pop de
	jr nz, update_enemy_skeleton_flame_walking_continue2
	ld (hl), 0
	inc hl
	ld (hl), ENEMY_BULLET_FIREBALL
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	ld (hl), a  ; pixel x
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, iyl
	ld (hl), a
	inc hl
	ld (hl), 4  ; pixel y
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (hl), a
	inc hl
	ld (hl), d  ; x speed
	inc hl
	ld (hl), 0  ; state timer

	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_SKELETON_FLAME1
	jr z, update_enemy_skeleton_flame_spit_right_spit_continue
	ld a, d
	cp 2
	jr z, update_enemy_skeleton_flame_spit_right_spit_second_right
	cp -2
	jr z, update_enemy_skeleton_flame_spit_right_spit_second_left
update_enemy_skeleton_flame_spit_right_spit_continue:
	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
	jr update_enemy_skeleton_flame_walking_continue2
update_enemy_skeleton_flame_spit_right_spit_second_right:
	inc d
	jr update_enemy_skeleton_flame_spit_right_spit
update_enemy_skeleton_flame_spit_right_spit_second_left:
	inc d
	jr update_enemy_skeleton_flame_spit_right_spit


;-----------------------------------------------
update_enemy_rockman:
update_enemy_rockman2:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	cp 2
	jp z, update_enemy_rockman_stone
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #03
	call z, update_enemy__patrol_left_right_platform

update_enemy_rockman_walking:
	call random_a
	or a
	jr nz, update_enemy_rockman_walking_continue
	; turn to stone:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 1
	jr update_enemy_rockman_stone
update_enemy_rockman_walking_continue:
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	and #01
 	add a, a
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 36
 	add a, a
 	add a, a
 	ld e, a
	ld d, COLOR_GREY
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_ROCKMAN
	jp z, enemy_sprite_and_continue_animated
	ld d, COLOR_LIGHT_BLUE
	jp enemy_sprite_and_continue_animated

update_enemy_rockman_stone:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 35) * 4
	or a
	jr z, update_enemy_rockman_walk_again
	cp 32
	jr c, update_enemy_rockman_stone_continue
	cp 224
	jr nc, update_enemy_rockman_stone_continue
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4
 update_enemy_rockman_stone_continue:
	ld d, COLOR_GREY
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_ROCKMAN
	jp z, enemy_sprite_and_continue
	ld d, COLOR_LIGHT_BLUE
	jp enemy_sprite_and_continue

update_enemy_rockman_walk_again:
	call random_a
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_rockman_walking_continue


;-----------------------------------------------
update_enemy_frog:
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #09
	cp #09
	call z, update_enemy__patrol_left_right_platform
	ld d, COLOR_GREEN
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	ld c, a
 	add a, a
 	add a, c
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 16
 	add a, a
 	add a, a
 	ld e, a
	jp enemy_sprite_and_continue_animated


;-----------------------------------------------
update_enemy_frog_tongue:
	ld iyl, COLOR_PURPLE
	jp update_enemy_frog_jumping_color_set
update_enemy_frog_jumping:
	ld iyl, COLOR_DARK_GREEN
update_enemy_frog_jumping_color_set:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
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
	; water/lava?
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	call get_room_tile_type
	cp 4
	jp z, update_enemy_fall_to_water
	cp 10
	jp z, update_enemy_fall_to_lava	
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 17) * 4 
	jp enemy_sprite_and_continue

update_enemy_frog_jumping_jump_left:
	call update_enemy_frog_jumping_jump
	jr z, update_enemy_frog_jumping_switch_to_state_left_reset_time
	call update_enemy_move_left_if_possible
	; water/lava?
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	call get_room_tile_type
	cp 4
	jp z, update_enemy_fall_to_water
	cp 10
	jp z, update_enemy_fall_to_lava	
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 20) * 4 
	jp enemy_sprite_and_continue

update_enemy_frog_jumping_tongue_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jp z, update_enemy_frog_jumping_switch_to_state_right_reset_time
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
	ld bc, #0101
	ld iyh, 2
	call update_enemy_hurt_player_bc_2x1
	jr update_enemy_frog_jumping_tongue_right_done
update_enemy_frog_jumping_tongue_right2:
	ld c, 16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 23) * 4 
	call get_sprite_object_sprite_coordinates
	jr nz, update_enemy_frog_jumping_tongue_right_done
	call add_sprite_to_this_frame
	ld bc, #0102	
	ld iyh, 2
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
	ld bc, #0103
	ld iyh, 2
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
	ld bc, #0104
	ld iyh, 2
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
	ld bc, #01ff	
	ld iyh, 2
	call update_enemy_hurt_player_bc_2x1
	jr update_enemy_frog_jumping_tongue_left_done
update_enemy_frog_jumping_tongue_left2:
	ld c, -16
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 26) * 4 
	call get_sprite_object_sprite_coordinates
	jp nz, update_enemy_frog_jumping_tongue_left_done
	call add_sprite_to_this_frame
	ld bc, #01fe
	ld iyh, 2
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
	ld bc, #01fd	
	ld iyh, 2
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
	ld bc, #01fc	
	ld iyh, 2
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
	ld iyh, 1  ; damage to deal
	call update_enemy_hurt_player_2x2
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
	ld iyl, COLOR_RED
	ld iyh, 1  ; damage to deal
update_enemy_monkey_continue:
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	call update_enemy__patrol_left_right_platform
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_monkey_walking
	dec a
	jr z, update_enemy_monkey_walking
	dec a
	jp z, update_enemy_monkey_jump
	dec a
	jp z, update_enemy_monkey_jump
	jp update_enemy_monkey_throw

update_enemy_monkey_walking:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	jr nz, update_enemy_monkey_walking_continue
	; chance of jumping/throwing
	call random_a
	and #7
	jr z, update_enemy_monkey_switch_to_state_jump
update_enemy_monkey_walking_no_jump:
	call random_a
	and #7
	jr z, update_enemy_monkey_switch_to_state_throw
update_enemy_monkey_walking_continue:
	ld d, iyl
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	add a, a
	add a, a
	add a, FIRST_ENEMY_SPRITE_PATTERN + 31
	add a, a
	add a, a
	ld e, a
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
	jr nz, update_enemy_monkey_walking_no_jump
	call update_enemy_move_down  ; move one pixel down directly to avoid the first collision
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 20  ; start directly falling
	jr update_enemy_monkey_switch_to_state_jump_continue
update_enemy_monkey_switch_to_state_jump_up:
	; try to jump up:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp 6
	jr c, update_enemy_monkey_walking_no_jump  ; if monkey is up into the room, do not jump up
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_monkey_switch_to_state_jump_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	add 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a

update_enemy_monkey_jump:
	call update_enemy_frog_jumping_jump
	jr nz, update_enemy_monkey_jump_continue
	; switch to walking:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_monkey_jump_continue:
	; water/lava?
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	call get_room_tile_type
	cp 4
	jp z, update_enemy_fall_to_water
	cp 10
	jp z, update_enemy_fall_to_lava
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
	jr nz, update_enemy_monkey_walking_continue
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	add 4
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0

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
update_enemy_ant2:
	ld iyh, 2  ; damage to deal
	jr update_enemy_ant2_continue

update_enemy_ant:
	ld iyh, 1  ; damage to deal
update_enemy_ant2_continue:
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_ant_right
	dec a
	jr z, update_enemy_ant_left
	dec a
	jp z, update_enemy_ant_fall_right
	dec a
	jp z, update_enemy_ant_fall_left
	dec a
	jp z, update_enemy_ant_climb_right
	dec a
	jp z, update_enemy_ant_climb_left
	; we can mever reach here

update_enemy_ant_right:
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
 	and #01	
	call z, update_enemy_ant_move_right
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 1) * 4
update_enemy_ant_set_color_animated:
	ld d, COLOR_GREY
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_ANT
	jp z, enemy_sprite_and_continue_animated
	ld d, COLOR_PURPLE
	jp enemy_sprite_and_continue_animated

update_enemy_ant_left:
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
 	and #01	
 	call z, update_enemy_ant_move_left
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 29) * 4
	jr update_enemy_ant_set_color_animated

update_enemy_ant_fall_right:
	ld b, 2
	call update_enemy_frog_jumping_jump_fall
	jr nz, update_enemy_ant_fall_right_continue
	; check if we reached the bottom of the room:
	ld a, (current_room__height)
	dec a
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jp z, update_enemy_delete
	; land:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_ant_fall_right_continue:
	; water/lava?
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	call get_room_tile_type
	cp 4
	jp z, update_enemy_fall_to_water
	cp 10
	jp z, update_enemy_fall_to_lava
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 1) * 4
update_enemy_ant_set_color_no_animation:
	ld d, COLOR_GREY
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_ANT
	jp z, enemy_sprite_and_continue
	ld d, COLOR_PURPLE
	jp enemy_sprite_and_continue

update_enemy_ant_fall_left:
	ld b, 2
	call update_enemy_frog_jumping_jump_fall
	jr nz, update_enemy_ant_fall_left_continue
	; check if we reached the bottom of the room:
	ld a, (current_room__height)
	dec a
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jp z, update_enemy_delete
	; land:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_ant_fall_left_continue:
	; water/lava?
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	call get_room_tile_type
	cp 4
	jp z, update_enemy_fall_to_water
	cp 10
	jp z, update_enemy_fall_to_lava	
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 29) * 4
	jr update_enemy_ant_set_color_no_animation

update_enemy_ant_climb_right:
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
 	and #01	
 	call z, update_enemy_ant_climb_right_move_up
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4
	jp update_enemy_ant_set_color_animated

update_enemy_ant_climb_left:
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
 	and #01
 	call z, update_enemy_ant_climb_left_move_up
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 33) * 4
	jp update_enemy_ant_set_color_animated

update_enemy_ant_move_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	jp nz, update_enemy_move_right
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc b
	inc b
	push bc
		call get_room_tile_type
	pop bc
	cp 1  ; platform
	jr z, update_enemy_ant_move_right_no_fall
	cp 2  ; wall
	jr z, update_enemy_ant_move_right_no_fall
	cp 6  ; rope-platform-top
	jr z, update_enemy_ant_move_right_no_fall
	cp 8  ; ladder-platform-top
	jr z, update_enemy_ant_move_right_no_fall
	; fall:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; switch to fall
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ret
update_enemy_ant_move_right_no_fall:
	dec b
	inc c
	push bc
		call general_check_collision_with_wall
	pop bc
	jr z, update_enemy_ant_move_right_collision
	jp update_enemy_move_right
update_enemy_ant_move_right_collision:
	ld a, (current_room__width)
	dec a
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp z, update_enemy_delete
	; see if we can climb:
	dec c
	dec b
	call general_check_collision_with_wall
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; switch to left
	ret z   
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 4  ; switch to climb
	ret

update_enemy_ant_move_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	jp nz, update_enemy_move_left
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc b
	inc b
	push bc
		call get_room_tile_type
	pop bc
	cp 1  ; platform
	jr z, update_enemy_ant_move_left_no_fall
	cp 2  ; wall
	jr z, update_enemy_ant_move_left_no_fall
	cp 6  ; rope-platform-top
	jr z, update_enemy_ant_move_left_no_fall
	cp 8  ; ladder-platform-top
	jr z, update_enemy_ant_move_left_no_fall
	; fall:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; switch to fall
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ret
update_enemy_ant_move_left_no_fall:
	dec b
	dec c
	push bc
		call general_check_collision_with_wall
	pop bc
	jr z, update_enemy_ant_move_left_collision
	jp update_enemy_move_left
update_enemy_ant_move_left_collision:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	or a
	jp z, update_enemy_delete
	; see if we can climb:
	inc c
	dec b
	call general_check_collision_with_wall
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0  ; switch to right
	ret z   
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 5  ; switch to climb
	ret

update_enemy_ant_climb_right_move_up
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	cp 4
	jp nz, update_enemy_move_up
	; check if we hit the ceiling
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	push bc
		call general_check_collision_with_wall
	pop bc
	jp z, update_enemy_ant_climb_right_move_up_fall
	inc b
	inc c
	call general_check_collision_with_wall
	jp z, update_enemy_move_up
	; reached a ledge, go back to walking:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0  ; switch to walk right
	ld bc, #fc01  ; 1, -4
	jp update_enemy_move_cb
update_enemy_ant_climb_right_move_up_fall:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	or a
	jp z, update_enemy_delete
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; switch to fall left
	ret

update_enemy_ant_climb_left_move_up:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	cp 4
	jp nz, update_enemy_move_up
	; check if we hit the ceiling
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	push bc
		call general_check_collision_with_wall
	pop bc
	jp z, update_enemy_ant_climb_left_move_up_fall
	inc b
	dec c
	call general_check_collision_with_wall
	jp z, update_enemy_move_up
	; reached a ledge, go back to walking:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; switch to walk left
	ld bc, #fcff  ; -1, -4
	jp update_enemy_move_cb
update_enemy_ant_climb_left_move_up_fall:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	or a
	jp z, update_enemy_delete	
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; switch to fall right
	ret


;-----------------------------------------------
update_enemy_skeleton_sleeper:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	; 0, 1: walk right/left
	cp 2
	jr z, update_enemy_skeleton_sleeper_sleeping
	cp 3
	jp z, update_enemy_skeleton_sleeper_waking_up
	cp 4
	jp z, update_enemy_skeleton_sleeper_falling_asleep
	cp 5
	jp z, update_enemy_skeleton_sleeper_throw_right
	cp 6
	jp z, update_enemy_skeleton_sleeper_throw_left
	cp 7
	jp z, update_enemy_skeleton_sleeper_falling  ; boss 4 spawns them in the air
	call update_enemy__patrol_left_right_platform

update_enemy_skeleton_sleeper_walking:
	call random_a
	or a
	jp z, update_enemy_skeleton_sleeper_switch_to_falling_asleep
	and #3f
	jr nz, update_enemy_skeleton_sleeper_walking_continue
	; shoot:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	add a, 5
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	cp 5
	jp z, update_enemy_skeleton_sleeper_throw_right
	jp update_enemy_skeleton_sleeper_throw_left
update_enemy_skeleton_sleeper_walking_continue:
	ld d, COLOR_WHITE
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	add a, a
 	add a, a
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 21
 	add a, a
 	add a, a
 	ld e, a
	jp enemy_sprite_and_continue_animated

update_enemy_skeleton_sleeper_sleeping:
	; wake up if player makes noise nearby:
	ld a, (player_x + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp 8
	jp p, update_enemy_skeleton_sleeper_idle_continue
	cp -8
	jp m, update_enemy_skeleton_sleeper_idle_continue
	ld a, (player_y + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp 6 
	jp p, update_enemy_skeleton_sleeper_idle_continue
	cp -6
	jp m, update_enemy_skeleton_sleeper_idle_continue
	; player is close by:
	ld a, (player_state)
	and #fe
	or a  ; cp PLAYER_STATE_IDLE
	jr z, update_enemy_skeleton_sleeper_idle_continue
	cp PLAYER_STATE_CROUCHING
	jr z, update_enemy_skeleton_sleeper_idle_continue
	cp PLAYER_STATE_CRAWLING
	jr z, update_enemy_skeleton_sleeper_idle_continue
	; player was noisy, wake up:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_skeleton_sleeper_idle_continue:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 1) * 4 
	jp enemy_sprite_and_continue_animated_slow

update_enemy_skeleton_sleeper_waking_up:
	ld a, (current_world__difficulty_attack_warn_time)
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	jr nz, update_enemy_skeleton_sleeper_waking_up_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	ld a, (player_x + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nc, update_enemy_skeleton_sleeper_waking_up_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
update_enemy_skeleton_sleeper_waking_up_continue:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 29) * 4 
	jp enemy_sprite_and_continue_animated_slow

update_enemy_skeleton_sleeper_switch_to_falling_asleep:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 4
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_skeleton_sleeper_falling_asleep:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jr nz, update_enemy_skeleton_sleeper_falling_asleep_continue
	; sleep:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
update_enemy_skeleton_sleeper_falling_asleep_continue:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 29) * 4 
	jp enemy_sprite_and_continue_animated_slow

update_enemy_skeleton_sleeper_throw_right:
	ld a, (current_world__difficulty_attack_warn_time)
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	jr z, update_enemy_skeleton_sleeper_throw_right_done
	srl a
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	push af
		call z, update_enemy_skeleton_sleeper_throw_shoot
	pop af
	jr c, update_enemy_skeleton_sleeper_throw_right_continue2
update_enemy_skeleton_sleeper_throw_right_continue:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 23) * 4 
	jp enemy_sprite_and_continue
update_enemy_skeleton_sleeper_throw_right_done:
	; done:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
update_enemy_skeleton_sleeper_throw_right_continue2:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 24) * 4 
	jp enemy_sprite_and_continue

update_enemy_skeleton_sleeper_throw_left:
	ld a, (current_world__difficulty_attack_warn_time)
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	jr z, update_enemy_skeleton_sleeper_throw_left_done
	srl a
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	push af
		call z, update_enemy_skeleton_sleeper_throw_shoot
	pop af
	jr c, update_enemy_skeleton_sleeper_throw_left_continue2
update_enemy_skeleton_sleeper_throw_left_continue:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 27) * 4 
	jp enemy_sprite_and_continue
update_enemy_skeleton_sleeper_throw_left_done:
	; done:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
update_enemy_skeleton_sleeper_throw_left_continue2:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 28) * 4 
	jp enemy_sprite_and_continue

update_enemy_skeleton_sleeper_throw_shoot:
	call update_enemy_fire_directional_bullet_towards_player
	ld hl, SFX_enemy_bullet
	jp play_SFX_with_high_priority

update_enemy_skeleton_sleeper_falling:
	call update_enemy_move_down_if_possible
	call update_enemy_move_down_if_possible
	jr nz, update_enemy_skeleton_sleeper_falling_continue	
	; reached a floor:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
update_enemy_skeleton_sleeper_falling_continue:
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 1) * 4 
	jp enemy_sprite_and_continue_animated_slow


;-----------------------------------------------
update_enemy_fire_imp:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	ld iyh, COLOR_LIGHT_RED  ; imp 1
	cp ENEMY_FIRE_IMP2
	jr nz, update_enemy_fire_imp_continue
	ld iyh, COLOR_PURPLE  ; imp 2
update_enemy_fire_imp_continue:
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	; 0: fireball:
	; 1: dash preparation
	; 2: dash
	; 3: dash cool-down
	or a
	jp z, update_enemy_fire_imp_fireball
	dec a
	jr z, update_enemy_fire_imp_dash_prepare
	dec a
	jr z, update_enemy_fire_imp_dash
update_enemy_fire_imp_dash_cooldown:
	ld a, (current_world__difficulty_attack_warn_time)
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	jp nz, update_enemy_fire_imp_dash_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jp update_enemy_fire_imp_dash_continue

update_enemy_fire_imp_to_dash_cooldown:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_fire_imp_dash_cooldown

update_enemy_fire_imp_switch_to_dash_prepare:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	; set dash direction:
	ld a, (player_x + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld (ix + ROOM_OBJECT_STRUCT_EXTRA1), a
	ld a, (player_y + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (ix + ROOM_OBJECT_STRUCT_EXTRA2), a

update_enemy_fire_imp_dash_prepare:
	ld a, (current_world__difficulty_attack_warn_time)
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	jr nz, update_enemy_fire_imp_dash_continue
	; dash:
	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_BRESENHAM_STATE), 0

update_enemy_fire_imp_dash:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 48
	jr z, update_enemy_fire_imp_to_dash_cooldown
	ld a, (current_world__difficulty_bullet_speed)
	ld l, a
	call update_enemy_dash_step_internal
	ld bc, (current_room__width)
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp #ff
	jr z, update_enemy_fire_imp_dash_left_edge
	cp c
	jr z, update_enemy_fire_imp_dash_right_edge
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp #ff
	jr z, update_enemy_fire_imp_dash_top_edge
	cp b
	jr z, update_enemy_fire_imp_dash_bottom_edge

update_enemy_fire_imp_dash_continue:
	ld d, iyh
	ld a, (player_x + 1)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_fire_imp_body_left
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 8) * 4 
	jp enemy_sprite_and_continue_animated
update_enemy_fire_imp_body_left:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 10) * 4 
	jp enemy_sprite_and_continue_animated

update_enemy_fire_imp_dash_left_edge:
	ld (ix + ROOM_OBJECT_STRUCT_TILE_X), 0
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), 0
	jp update_enemy_fire_imp_to_dash_cooldown
update_enemy_fire_imp_dash_top_edge:
	ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), 0
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), 0
	jp update_enemy_fire_imp_to_dash_cooldown
update_enemy_fire_imp_dash_right_edge:
	dec c
	ld (ix + ROOM_OBJECT_STRUCT_TILE_X), c
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), 0
	jp update_enemy_fire_imp_to_dash_cooldown
update_enemy_fire_imp_dash_bottom_edge:
	dec b
	ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), b
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), 0
	jp update_enemy_fire_imp_to_dash_cooldown

update_enemy_fire_imp_fireball:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 200
	jp z, update_enemy_fire_imp_switch_to_dash_prepare
	and #03
	jr nz, update_enemy_fire_imp_movement_done

	; move towards player:
	ld a, (player_x + 1)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_fire_imp_left
	jr nz, update_enemy_fire_imp_right
	; same tile:
	ld a, (player_x)
	cp (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	jr c, update_enemy_fire_imp_left
	jr z, update_enemy_fire_imp_y
update_enemy_fire_imp_right:
	; right:
	call update_enemy_move_right
	jr update_enemy_fire_imp_y
update_enemy_fire_imp_left:
	call update_enemy_move_left

update_enemy_fire_imp_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr c, update_enemy_fire_imp_up
	jr nz, update_enemy_fire_imp_down
	; same tile:
	ld a, (player_y)
	cp (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	jr c, update_enemy_fire_imp_up
	jr z, update_enemy_fire_imp_movement_done
update_enemy_fire_imp_down:
	; down:
	call update_enemy_move_down
	jr update_enemy_fire_imp_movement_done
update_enemy_fire_imp_up:
	call update_enemy_move_up

update_enemy_fire_imp_movement_done:
	ld d, iyh
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 12) * 4 
	jp enemy_sprite_and_continue_animated4


;-----------------------------------------------
update_enemy_fireball_color_cycle:
	db COLOR_LIGHT_RED, COLOR_RED, COLOR_LIGHT_RED, COLOR_DARK_YELLOW
	db COLOR_WHITE, COLOR_DARK_YELLOW, COLOR_LIGHT_RED, COLOR_DARK_YELLOW

update_enemy_fireball:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 80
	jr z, update_enemy_fireball_explode
	cp 15
	jr nc, update_enemy_fireball_continue

	; rise:
	ld hl, frog_jump_table + 3
	ADD_HL_A
	ld a, (hl)  ; amount to move
	or a
	jr z, update_enemy_fireball_continue
	neg
	ld b, a
update_enemy_fireball_rise_loop:
	push bc
		call update_enemy_move_up
	pop bc
	djnz update_enemy_fireball_rise_loop

update_enemy_fireball_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #07
	ld hl, update_enemy_fireball_color_cycle
	ADD_HL_A
	ld d, (hl)
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 31) * 4 
	jp enemy_sprite_and_continue_animated4

update_enemy_fireball_explode:
	ld a, (current_world__difficulty_n_cluster_bullets)
	ld b, a
update_enemy_fireball_explode_loop:
	push bc
		; fire a bullet:
		call ptr_to_new_sprite_enemy
		jr nz, update_enemy_fireball_explode_loop_continue
		ld (hl), 0  ; ID
		inc hl
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
		call random_a
		and #1f
		sub 16
		ld (hl), a  ; speed x
		inc hl
		call random_a
		and #1f
		sub 16
		ld (hl), a  ; speed y
update_enemy_fireball_explode_loop_continue:
	pop bc
	djnz update_enemy_fireball_explode_loop
	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
	jp update_enemy_delete


;-----------------------------------------------
ghost_wave_table:
	db 0, 0, 0, 1, 1, 2, 1, 1, 0, 0, 0, -1, -1, -2, -1, -1


update_enemy_ghost:
	; states:
	; - 0: choose behavior
	; - 1: left
	; - 2: right
	; - 3: pause left (high probability of going to 7)
	; - 4: pause right (high probability of going to 7)
	; - 5: move to player slow
	; - 6: blink out (left)
	; - 7: blink out (right)
	; - 8: dash to player
	ld iyl, COLOR_GREY
	jr update_enemy_ghost_continue
update_enemy_ghost2:
	ld iyl, COLOR_WHITE
update_enemy_ghost_continue:
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)

	; no damage when blinking:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	cp 6
	jr z, update_enemy_ghost_state_switch
	cp 7
	jr z, update_enemy_ghost_state_switch
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2

update_enemy_ghost_state_switch:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_ghost_state_0
	dec a
	jr z, update_enemy_ghost_state_1
	dec a
	jr z, update_enemy_ghost_state_2
	dec a
	jp z, update_enemy_ghost_state_3
	dec a
	jp z, update_enemy_ghost_state_4
	dec a
	jp z, update_enemy_ghost_state_5
	dec a
	jp z, update_enemy_ghost_state_6
	dec a
	jp z, update_enemy_ghost_state_7
	dec a
	jp z, update_enemy_ghost_state_8
	; we should never get here
update_enemy_ghost_continue2_right:
	call update_enemy_ghost_wave
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 2) * 4  ; 2: right, 5: left
	jp enemy_sprite_and_continue_animated_slow

update_enemy_ghost_continue2_left:
	call update_enemy_ghost_wave
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 5) * 4  ; 2: right, 5: left
	jp enemy_sprite_and_continue_animated_slow

update_enemy_ghost_continue2_right_dash:
	call update_enemy_ghost_wave
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 4) * 4
	jp enemy_sprite_and_continue

update_enemy_ghost_continue2_left_dash:
	call update_enemy_ghost_wave
	ld d, iyl
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4
	jp enemy_sprite_and_continue

update_enemy_ghost_continue2_invisible:
	call update_enemy_ghost_wave
	jp update_sprite_enemies_loop_next

update_enemy_ghost_state_0:
	; choose state:
	ld c, 7  ; we cannot randomly go to dash (goes after 3/4)
	call random_modulo
	inc a
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_ghost_state_switch

update_enemy_ghost_state_1:
	; left:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp 2  ; ghosts do not reach the left-most of the screen
	jr c, update_enemy_ghost_state_0
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #03
	jr nz, update_enemy_ghost_continue2_left
	call update_enemy_move_left
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jr z, update_enemy_ghost_state_0
	jr update_enemy_ghost_continue2_left

update_enemy_ghost_state_2:
	; right:
	ld a, (current_room__width)
	sub 3
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	cp c  ; ghosts do not reach the right-most of the screen
	jr nc, update_enemy_ghost_state_0
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #03
	jr nz, update_enemy_ghost_continue2_right
	call update_enemy_move_right
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jr z, update_enemy_ghost_state_0
	jr update_enemy_ghost_continue2_right

update_enemy_ghost_state_3:
	; pause left:
	ld a, (current_world__difficulty_attack_warn_time)
	add a, a
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	jr nz, update_enemy_ghost_continue2_left
	call random_a
	and #03
	jr z, update_enemy_ghost_state_0
	; dash:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 8
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jp update_enemy_ghost_state_8

update_enemy_ghost_state_4:
	; pause right:
	ld a, (current_world__difficulty_attack_warn_time)
	add a, a
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	jp nz, update_enemy_ghost_continue2_right
	call random_a
	and #03
	jr z, update_enemy_ghost_state_0
	; dash:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 8
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jp update_enemy_ghost_state_8

update_enemy_ghost_state_5:
	; move to player slow:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #03
	jp nz, update_enemy_ghost_state_8_continue3
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	or a
	jr nz, update_enemy_ghost_state_5_continue
	call update_enemy_ghost_get_player_position
update_enemy_ghost_state_5_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jr z, update_enemy_ghost_state_8_done
	ld l, 1
	call update_enemy_dash_step_internal
	jp update_enemy_ghost_state_8_continue3

update_enemy_ghost_state_6:
update_enemy_ghost_state_7:
	; blink out (appear in another random position):
	; 0 -> warn time: blink
	; 64: teleport
	; (128 - watn time) -> 128: blink
	ld a, (current_world__difficulty_attack_warn_time)
	ld c, a
	ld a, 128
	sub c
	ld b, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 128
	jp z, update_enemy_ghost_state_0
	cp 64
	jr z, update_enemy_ghost_state_6_teleport
	cp c
	jr c, update_enemy_ghost_state_6_blink
	cp b
	jp c, update_enemy_ghost_continue2_invisible
update_enemy_ghost_state_6_blink:
	; blink:
	and #02
	jp z, update_enemy_ghost_continue2_invisible
update_enemy_ghost_state_6_show:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	cp 6
	jp z, update_enemy_ghost_continue2_left
	jp update_enemy_ghost_continue2_right
update_enemy_ghost_state_6_teleport:
	ld a, (current_room__width)
	sub 4
	ld c, a
	call random_modulo
	add a, 2
	ld (ix + ROOM_OBJECT_STRUCT_TILE_X), a
	ld a, (current_room__height)
	sub 4
	ld c, a
	call random_modulo
	add a, 2
	ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), a
	jp update_enemy_ghost_continue2_invisible

update_enemy_ghost_state_8:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	or a
	jr nz, update_enemy_ghost_state_8_continue
	; set target destination:
	call update_enemy_ghost_get_player_position
	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
update_enemy_ghost_state_8_continue:

	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jr nz, update_enemy_ghost_state_8_continue2
update_enemy_ghost_state_8_done:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; pause left
	ld a, (ix + ROOM_OBJECT_STRUCT_EXTRA1)  ; x direction of movement
	or a
	jp m, update_enemy_ghost_continue2_left
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 4  ; pause right
	jp update_enemy_ghost_continue2_right
update_enemy_ghost_state_8_continue2:
	ld l, 2
	call update_enemy_dash_step_internal
update_enemy_ghost_state_8_continue3:
	ld de, (current_room__width)
	dec e
	dec e
	dec d
	dec d
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	or a
	jr z, update_enemy_ghost_state_8_done
	cp e
	jr z, update_enemy_ghost_state_8_done
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	or a
	jr z, update_enemy_ghost_state_8_done
	cp d
	jr z, update_enemy_ghost_state_8_done
	ld a, (ix + ROOM_OBJECT_STRUCT_EXTRA1)  ; x direction of movement
	or a
	jp p, update_enemy_ghost_continue2_right_dash
	jp update_enemy_ghost_continue2_left_dash

update_enemy_ghost_get_player_position:
	ld a, (player_x + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld (ix + ROOM_OBJECT_STRUCT_EXTRA1), a
	ld a, (player_y + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (ix + ROOM_OBJECT_STRUCT_EXTRA2), a
	ld (ix + ROOM_OBJECT_STRUCT_BRESENHAM_STATE), 0
	ret

update_enemy_ghost_wave:
	; waving motion:
	ld a, (interrupt_cycle)
	and #06
	ret nz
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	add a, (ix + ROOM_OBJECT_STRUCT_ID)  ; offset, so that not all ghosts wave in sync
	and #0f
	ld hl, ghost_wave_table
	ADD_HL_A
	ld b, (hl)
	ld c, 0
	jp update_enemy_move_cb


;-----------------------------------------------
update_enemy_fishman:
	ld iyl, COLOR_GREEN
	jr update_enemy_fishman_continue
update_enemy_fishman2:
	ld iyl, COLOR_LIGHT_RED
update_enemy_fishman_continue:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2

	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	call update_enemy__patrol_left_right_platform
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	cp 2
	jp z, update_enemy_fishman_stairs_up
	cp 3
	jp z, update_enemy_fishman_stairs_down
	cp 4
	jp z, update_enemy_fishman_fire_right
	cp 5
	jp z, update_enemy_fishman_fire_left
	; it's patroling, check if we need stairs, or fire a bullet:
	call update_enemy_player_close_enough_16
	jr nz, 	update_enemy_fishman_continue2

	; check if the fishman needs to fire a bullet:
	; if (state == 0 && c > 0) || (state == 1 && c < 0)
	push bc
		xor a
		sub (ix + ROOM_OBJECT_STRUCT_STATE)  ; a = (state == 0 ? 0:#ff)
		xor c
	pop bc
	jp m, update_enemy_fishman_no_fire
	call random_a
	and #1f
	jr nz, update_enemy_fishman_no_fire
	; fire a bullet!
	ld a, 4
	add a, (ix + ROOM_OBJECT_STRUCT_STATE)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_fishman_continue2
update_enemy_fishman_no_fire:
	ld a, b
	or a
	jr z, update_enemy_fishman_no_stairs
	jp p, update_enemy_fishman_check_stairs_down
	; stairs up check:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call get_room_tile_type
	cp 7  ; ladder
	jr nz, update_enemy_fishman_no_stairs
	inc hl
	ld a, (hl)
	call get_collision_tile_type_of_a
	cp 7  ; ladder
	jr nz, update_enemy_fishman_no_stairs
	jp update_enemy_fishman_switch_to_stairs_up
	jr update_enemy_fishman_continue2

update_enemy_fishman_check_stairs_down:
	; stairs down check:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call get_room_tile_type
	cp 8  ; ladder top
	jr nz, update_enemy_fishman_no_stairs
	inc hl
	ld a, (hl)
	call get_collision_tile_type_of_a
	cp 8  ; ladder top
	jr nz, update_enemy_fishman_no_stairs
	jp update_enemy_fishman_switch_to_stairs_down
update_enemy_fishman_no_stairs:
update_enemy_fishman_continue2:
	ld d, iyl  ; color
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	or a
 	jr z, update_enemy_fishman_sprite_right
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 35) * 4  ; 16: right, 35: left, 19: stairs
 	jp enemy_sprite_and_continue_animated
 update_enemy_fishman_sprite_right:
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 16) * 4  ; 16: right, 35: left, 19: stairs
	jp enemy_sprite_and_continue_animated

update_enemy_fishman_switch_to_stairs_up:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), 0  ; center around the stairs
update_enemy_fishman_switch_to_stairs_up_from_stairs:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_fishman_stairs_up_continue
update_enemy_fishman_stairs_up:
	; go up one flight of stairs:
	; - until colliding (and then go down)
	; - or until reaching a platform (and then switch to patrol)
	call update_enemy_move_up_if_possible_stairs
	jr z, update_enemy_fishman_switch_to_stairs_down_from_stairs
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr nz, update_enemy_fishman_stairs_up_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call get_room_tile_type
	cp 8  ; top of stairs
	jr nz, update_enemy_fishman_stairs_up_continue
	; reached a floor, stop
	call random_a
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a  ; random left/right
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_fishman_stairs_up_continue:
	ld d, iyl  ; color
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 19) * 4  ; 16: right, 35: left, 19: stairs
 	jp enemy_sprite_and_continue_animated

update_enemy_fishman_switch_to_stairs_down:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), 0  ; center around the stairs
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
update_enemy_fishman_switch_to_stairs_down_from_stairs:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_fishman_stairs_down_continue
update_enemy_fishman_stairs_down:
	; go down one flight of stairs:
	; - until colliding or reaching the end of the stairs (and then go down)
	; - or until reaching a platform (and then switch to patrol)
	call update_enemy_move_down_if_possible_stairs
	jr z, update_enemy_fishman_switch_to_stairs_up_from_stairs
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr nz, update_enemy_fishman_stairs_down_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call get_room_tile_type
	; 1, 2, 8 -> done!
	cp 1
	jr z, update_enemy_fishman_stairs_down_done
	cp 2
	jr z, update_enemy_fishman_stairs_down_done
	cp 8  ; top of stairs
	jr nz, update_enemy_fishman_stairs_down_continue
update_enemy_fishman_stairs_down_done:
	; reached a floor, stop
	call random_a
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a  ; random left/right
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_fishman_stairs_down_continue:
	ld d, iyl  ; color
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 19) * 4  ; 16: right, 35: left, 19: stairs
 	jp enemy_sprite_and_continue_animated

update_enemy_fishman_fire_right:
	ld d, 2  ; speed of the bullet
	ld iyh, 1  ; x tile offset of bullet
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 18) * 4 
update_enemy_fishman_fire_right_continue:
	ld a, (current_world__difficulty_attack_warn_time)
	ld c, a
	add a, a
	ld b, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp c
	jr z, update_enemy_fishman_fire_right_spit
	cp b
	jr nz, update_enemy_fishman_fire_right_continue2
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	add a, -4
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0	
update_enemy_fishman_fire_right_continue2:
	ld d, iyl  ; color
 	jp enemy_sprite_and_continue

update_enemy_fishman_fire_left:
	ld d, -2  ; speed of the bullet
	ld iyh, 0  ; x tile offset of bullet
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 37) * 4
	jr update_enemy_fishman_fire_right_continue

update_enemy_fishman_fire_right_spit:
	; spit water:
	; - d: speed of the bullet
	push de
		call ptr_to_new_sprite_enemy
	pop de
	jr nz, update_enemy_fishman_fire_right_continue2
	ld (hl), 0
	inc hl
	ld (hl), ENEMY_BULLET_WATERBALL
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	ld (hl), a  ; pixel x
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, iyh
	ld (hl), a
	inc hl
	ld (hl), 4  ; pixel y
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (hl), a
	inc hl
	ld (hl), d  ; x speed
	inc hl
	ld (hl), 0  ; state timer

	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_FISHMAN
	jr z, update_enemy_fishman_fire_right_spit_continue
	ld a, d
	cp 2
	jr z, update_enemy_fishman_fire_right_spit_second_right
	cp -2
	jr z, update_enemy_fishman_fire_right_spit_second_left
update_enemy_fishman_fire_right_spit_continue:
	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
	jr update_enemy_fishman_fire_right_continue2
update_enemy_fishman_fire_right_spit_second_right:
	inc d
	jr update_enemy_fishman_fire_right_spit
update_enemy_fishman_fire_right_spit_second_left:
	dec d
	jr update_enemy_fishman_fire_right_spit


;-----------------------------------------------
update_enemy_sentinel_rock:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_bullet
	
	ld a, (current_world__difficulty_bullet_speed)
	ld l, a
	call update_enemy_bullet_bresenham_l_steps
	; - b: amount to move in y
	; - c: amount to move in x
	call update_enemy_move_cb

	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call general_check_collision_with_wall
	jp z, update_enemy_sentinel_rock_collision

	; out of the screen?
	ld a, (current_room__width)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp z, update_enemy_sentinel_rock_collision
	jp c, update_enemy_sentinel_rock_collision

	ld a, (current_room__height)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jp z, update_enemy_sentinel_rock_collision
	jp c, update_enemy_sentinel_rock_collision

	ld d, COLOR_BLUE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 29) * 4 
	jp enemy_sprite_and_continue
update_enemy_sentinel_rock_collision:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call spawn_explosion
	jp update_enemy_delete


;-----------------------------------------------
; ALIENS_FIRE_LASERS: equ 1  ; aliens fire lasers, which looks better, but causes more flickering
ALIENS_FIRE_LASERS: equ 0  ; aliens fire regular bullets, which causes less flickering
update_enemy_alien:
	ld iyh, 4  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	call update_enemy__patrol_left_right_platform
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	cp 14
	jr z, update_enemy_alien_falling
	or a
	jr z, update_enemy_alien_patroling
	dec a
	jr z, update_enemy_alien_patroling
	dec a
	jp z, update_enemy_alien_stairs_up
	dec a
	jp z, update_enemy_alien_stairs_down
	; shooting states: 4 - 13
	jp update_enemy_alien_shooting
update_enemy_alien_falling:
	call update_enemy_move_down_if_possible
	call update_enemy_move_down_if_possible
	jr nz, update_enemy_alien_falling_continue
	; reached a floor:
	call random_a
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_alien_falling_continue:
	ld a, FIRST_ENEMY_SPRITE_PATTERN + 13  ; shooting right:down sprite, reused for falling
	jp update_enemy_alien_shooting_continue3

update_enemy_alien_patroling:
	; it's patroling, check if we need stairs, or fire a bullet:
	; check if the alien needs to fire a bullet:
  	call random_a
  	and #1f
  	jp z, update_enemy_alien_switch_to_shoot

	; stairs up check:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call get_room_tile_type
	cp 7  ; ladder
	jr nz, update_enemy_alien_check_stairs_down
	inc hl
	ld a, (hl)
	call get_collision_tile_type_of_a
	cp 7  ; ladder
	jr nz, update_enemy_alien_check_stairs_down
	call random_a
	and #0f
	jp z, update_enemy_alien_switch_to_stairs_up

update_enemy_alien_check_stairs_down:
	; stairs down check:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call get_room_tile_type
	cp 8  ; ladder top
	jr nz, update_enemy_alien_no_stairs
	inc hl
	ld a, (hl)
	call get_collision_tile_type_of_a
	cp 8  ; ladder top
	jr nz, update_enemy_alien_no_stairs
	call random_a
	and #0f
	jp z, update_enemy_alien_switch_to_stairs_down
update_enemy_alien_no_stairs:
	; sprites: walk right: 1+3, 2+3, walk left: 4+6, 5+6
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	add a, a
 	add a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 1  ; 1 or 4 depending on the state
 	add a, a
 	add a, a
 	ld e, a
 	push af
		ld a, (interrupt_cycle)
		rrca
		rrca
		and #04
		add a, e
		ld e, a
		ld c, 0
		ld d, COLOR_PURPLE
		call get_sprite_object_sprite_coordinates
		call z, add_sprite_to_this_frame
		ld a, -4
		add a, b
		ld b, a
	pop af
	add a, 8
	ld e, a
	ld a, d
	and #80
	add a, COLOR_GREEN
	ld d, a
	call add_sprite_to_this_frame
	jp update_sprite_enemies_loop_next

update_enemy_alien_switch_to_stairs_up:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), 0  ; center around the stairs
update_enemy_alien_switch_to_stairs_up_from_stairs:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_alien_stairs_up_continue
update_enemy_alien_stairs_up:
	; go up one flight of stairs:
	; - until colliding (and then go down)
	; - or until reaching a platform (and then switch to patrol)
	call update_enemy_move_up_if_possible_stairs
	jr z, update_enemy_alien_switch_to_stairs_down_from_stairs
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr nz, update_enemy_alien_stairs_up_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call get_room_tile_type
	cp 8  ; top of stairs
	jr nz, update_enemy_alien_stairs_up_continue
	; reached a floor, stop
	call random_a
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a  ; random left/right
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_alien_stairs_up_continue:
	; sprites: stairs: 7+8, 9+10
	ld a, FIRST_ENEMY_SPRITE_PATTERN + 7
 	add a, a
 	add a, a
 	ld e, a
	ld a, (interrupt_cycle)
	rrca
	rrca
	and #04
	add a, e
	ld e, a
	ld c, 0
	ld d, COLOR_PURPLE
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	ld a, -4
	add a, b
	ld b, a

	ld a, 8
	add a, e
	ld e, a
	ld a, d
	and #80
	add a, COLOR_GREEN
	ld d, a
	call add_sprite_to_this_frame
	jp update_sprite_enemies_loop_next

update_enemy_alien_switch_to_stairs_down:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), 0  ; center around the stairs
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
update_enemy_alien_switch_to_stairs_down_from_stairs:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_alien_stairs_down_continue
update_enemy_alien_stairs_down:
	; go down one flight of stairs:
	; - until colliding or reaching the end of the stairs (and then go down)
	; - or until reaching a platform (and then switch to patrol)
	call update_enemy_move_down_if_possible_stairs
	jr z, update_enemy_alien_switch_to_stairs_up_from_stairs
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr nz, update_enemy_alien_stairs_down_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call get_room_tile_type
	; 1, 2, 8 -> done!
	cp 1
	jr z, update_enemy_alien_stairs_down_done
	cp 2
	jr z, update_enemy_alien_stairs_down_done
	cp 8  ; top of stairs
	jr nz, update_enemy_alien_stairs_down_continue
update_enemy_alien_stairs_down_done:
	; reached a floor, stop
	call random_a
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a  ; random left/right
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_alien_stairs_down_continue:
	jr update_enemy_alien_stairs_up_continue

update_enemy_alien_switch_to_shoot:
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_alien_switch_to_shoot_left
update_enemy_alien_switch_to_shoot_right:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_alien_switch_to_shoot_right_straight
	jr c, update_enemy_alien_switch_to_shoot_right_up
update_enemy_alien_switch_to_shoot_right_down:
	call update_enemy_alien_player_in_vertical_line
	jr z, update_enemy_alien_switch_to_shoot_right_down_down
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 5
	jr update_enemy_alien_shooting
update_enemy_alien_switch_to_shoot_right_down_down:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 4
	jr update_enemy_alien_shooting
update_enemy_alien_switch_to_shoot_right_straight:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 6
	jr update_enemy_alien_shooting
update_enemy_alien_switch_to_shoot_right_up:
	call update_enemy_alien_player_in_vertical_line
	jr z, update_enemy_alien_switch_to_shoot_right_up_up
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 7
	jr update_enemy_alien_shooting
update_enemy_alien_switch_to_shoot_right_up_up:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 8
	jr update_enemy_alien_shooting

update_enemy_alien_switch_to_shoot_left:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_alien_switch_to_shoot_left_straight
	jr c, update_enemy_alien_switch_to_shoot_left_up
update_enemy_alien_switch_to_shoot_left_down:
	call update_enemy_alien_player_in_vertical_line
	jr z, update_enemy_alien_switch_to_shoot_left_down_down
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 10
	jr update_enemy_alien_shooting
update_enemy_alien_switch_to_shoot_left_down_down:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 9
	jr update_enemy_alien_shooting
update_enemy_alien_switch_to_shoot_left_straight:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 11
	jr update_enemy_alien_shooting
update_enemy_alien_switch_to_shoot_left_up:
	call update_enemy_alien_player_in_vertical_line
	jr z, update_enemy_alien_switch_to_shoot_left_up_up
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 12
	jr update_enemy_alien_shooting
update_enemy_alien_switch_to_shoot_left_up_up:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 13
	; jr update_enemy_alien_shooting

update_enemy_alien_shooting:
	ld a, (current_world__difficulty_attack_warn_time)
	sra a  ; half the wait time
	cp (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	jr nz, update_enemy_alien_shooting_continue
IF ALIENS_FIRE_LASERS = 1
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	ld c, a
	sub 4
	ld hl, update_enemy_alien_shoot_state_to_direction_table
	ADD_HL_A
	ld e, (hl)
ENDIF
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld d, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
IF ALIENS_FIRE_LASERS = 1
	ld a, e
	; when firing diagonal up, start the laser one tile lower to align the sprites
	cp 1
	jr z, update_enemy_alien_shooting_shoot_diagonal_up
	cp 5
	jr nz, update_enemy_alien_shooting_shoot_all_set
update_enemy_alien_shooting_shoot_diagonal_up:
	inc b
update_enemy_alien_shooting_shoot_all_set:
ENDIF
	call update_enemy_alien_fire_laser

	call random_a
	and #01
	ld c, (ix + ROOM_OBJECT_STRUCT_STATE)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a  ; random left/right
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld a, c
	jr update_enemy_alien_shooting_continue2
update_enemy_alien_shooting_continue:
	; states: sprite = 13 + (state - 4) * 2
	; - 4: right:down
	; - 5: right:right-down
	; - 6: right:right
	; - 7: right:right-up
	; - 8: right:up
	; - 9: left:down
	; - 10: left:left-down
	; - 11: left:left
	; - 12: left:left-up
	; - 13: left:up
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 update_enemy_alien_shooting_continue2:
 	add a, -4
 	add a, a
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 11
 update_enemy_alien_shooting_continue3:
 	add a, a
 	add a, a
 	ld e, a
	ld c, 0
	ld d, COLOR_PURPLE
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	ld a, -4
	add a, b
	ld b, a

	ld a, 4
	add a, e
	ld e, a
	ld a, d
	and #80
	add a, COLOR_GREEN
	ld d, a
	call add_sprite_to_this_frame
	jp update_sprite_enemies_loop_next	

update_enemy_alien_player_in_vertical_line:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld a, (player_x + 1)
	dec a
	cp c
	ret z
	inc a
	cp c
	ret z
	inc a
	cp c
	ret

IF ALIENS_FIRE_LASERS = 1
update_enemy_alien_shoot_state_to_direction_table:
	db 8  ; down
	db 6  ; right down
	db 4  ; right
	db 5  ; right up
	db 7  ; up
	db 8  ; down
	db 2  ; left down
	db 0  ; left
	db 1  ; left up
	db 7  ; up
ENDIF


update_enemy_alien_fire_laser:
	; - c, b: x, y
	; - d: pixel x
	; - e: direction
IF ALIENS_FIRE_LASERS = 1
	push bc
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), ENEMY_BULLET_LASER  ; enemy type
	inc hl
	ld (hl), d  ; pixel x
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0  ; pixel y
	inc hl
	ld (hl), b  ; tile y
	inc hl
	; 1: left-up, 0: left, 2: left-down
	; 5: right-up, 4: right, 6: right-down
	; 7: up, 8: down
	ld (hl), e  ; state / direction
	ld hl, SFX_raygun
	jp play_SFX_with_high_priority
ELSE
	ld e, c
	ld hl, boss_fire_directional_bullet_towards_player_e_b
	ld c, BOSS_PAGE
	push de
	push ix
		ld ix, 0
		call call_hl_in_page_c_8000
		ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BULLET_IGNORING_WALLS
	pop ix
	pop de
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), d
	ret
ENDIF


;-----------------------------------------------
update_enemy_mars_snail2:
	ld iyl, COLOR_GREEN
	jr update_enemy_mars_snail1_continue
update_enemy_mars_snail1:
	ld iyl, COLOR_LIGHT_RED
update_enemy_mars_snail1_continue:
	ld iyh, 4  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #fe  ; filter direction
	cp 2
	jr z, update_enemy_mars_snail1_hidden
	cp 4
	jp z, update_enemy_mars_snail1_firing
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #03
	call z, update_enemy__patrol_left_right_platform

	call random_a
	or a
	jr z, update_enemy_mars_snail1_hide
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_MARS_SNAIL2
	jr nz, update_enemy_mars_snail1_walk_sprites
	; chance of firing:
	call random_a
	and #7f
	jr nz, update_enemy_mars_snail1_walk_sprites
	; switch to firing state:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	add a, 4
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_mars_snail1_walk_sprites:
	; walk:
	; 4: right: hidden, walk1, walk2 (first 3 carapace, second 3 body)
	; 10: left: hidde, walk1, walk2
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rrca
	rrca
	rrca
	and #01
	ld e, a
update_enemy_mars_snail1_walk_sprites_e_set:
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	and #01
 	add a, a
 	ld d, a
 	add a, a
 	add a, d  ; a * 6
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 3
 	add a, e
 	add a, a
 	add a, a
update_enemy_mars_snail1_render_sprite:
	ld d, COLOR_BLUE
 	ld e, a
 	ld c, 0
	call get_sprite_object_sprite_coordinates
	jp nz, update_sprite_enemies_loop_next
	call add_sprite_to_this_frame
	ld a, 12
	add a, e
	ld e, a
	ld a, d
	and #80
	add a, iyl
	ld d, a
	call add_sprite_to_this_frame
	jp update_sprite_enemies_loop_next

update_enemy_mars_snail1_hide:
	inc (ix + ROOM_OBJECT_STRUCT_STATE)
	inc (ix + ROOM_OBJECT_STRUCT_STATE)  ; hidden
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
update_enemy_mars_snail1_hidden:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 200  ; timer for coming out of the carapace
	jr z, update_enemy_mars_snail1_hide_end
 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
 	and #01
 	add a, a
 	ld d, a
 	add a, a
 	add a, d  ; a * 6
 	add a, FIRST_ENEMY_SPRITE_PATTERN + 2
 	add a, a
 	add a, a
 	jr update_enemy_mars_snail1_render_sprite
update_enemy_mars_snail1_hide_end:
update_enemy_mars_snail1_firing_end:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	jr update_enemy_mars_snail1_walk_sprites

update_enemy_mars_snail1_firing:
	ld a, (current_world__difficulty_attack_warn_time)
	ld c, a
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp c  ; timer for coming out of the carapace
	ld e, 0
	jr nz, update_enemy_mars_snail1_walk_sprites_e_set
	; spit a bubble:
	call ptr_to_new_sprite_enemy  ; hl: ptr to the bullet
	jr nz, update_enemy_mars_snail1_firing_end
	ld d, 2
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	xor #01
	ld iyh, a  ; x tile offset of bullet
	xor #01
	add a, a
	add a, a
	neg
	add a, d
	ld d, a  ; d: speed of the bullet
	ld (hl), 0
	inc hl
	ld (hl), ENEMY_BULLET_WATERBALL
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	ld (hl), a  ; pixel x
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, iyh
	ld (hl), a
	inc hl
	ld (hl), 4  ; pixel y
	inc hl
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld (hl), a
	inc hl
	ld (hl), d  ; x speed
	inc hl
	ld (hl), 0  ; state timer
	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
	jr update_enemy_mars_snail1_firing_end


;-----------------------------------------------
; states:
; - 0, 1: walk on ground
; - 2, 3: walk on ceiling
; - 4: switching to ceiling
; - 5: switching to ground
update_enemy_mars_blob2:
	ld iyl, COLOR_RED
	ld iyh, 4  ; damage to deal
	call update_enemy_hurt_player_2x2
	ld iyh, #01  ; speed mask
	jr update_enemy_mars_blob1_continue

update_enemy_mars_blob1:
	ld iyl, COLOR_GREEN	
	ld iyh, 4  ; damage to deal
	call update_enemy_hurt_player_2x2
	ld iyh, #03  ; speed mask

update_enemy_mars_blob1_continue:
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	cp 4
	jr z, update_enemy_mars_blob1_rising
	cp 5
	jp z, update_enemy_mars_blob1_falling
	and #fe
	jr z, update_enemy_mars_blob1_walk_on_ground
	cp 2
	jr z, update_enemy_mars_blob1_walk_on_ceiling

update_enemy_mars_blob1_walk_on_ground:
	; walking on ground:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and iyh
	call z, update_enemy__patrol_left_right_platform

	; if player is in the same vertical, big chance to jump:
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nz, update_enemy_mars_blob1_walk_on_ground_no_player
	call random_a
	and #07
	jr z, update_enemy_mars_blob1_walk_switch_to_ceiling

update_enemy_mars_blob1_walk_on_ground_no_player:
	; chance to switch from ground to ceiling:
	call random_a
	or a
	jr nz, update_enemy_mars_blob1_stay_on_ground
update_enemy_mars_blob1_walk_switch_to_ceiling:
	; switch to ceiling?
	call update_enemy_mars_blob_can_switch_to_ceiling_p
	jr nz, update_enemy_mars_blob1_stay_on_ground
	; switch to ceiling!
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 4
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_mars_blob1_rising
update_enemy_mars_blob1_stay_on_ground:
	; ground: 14, 15, 16
	; ceiling: 17, 18, 19
 	ld d, iyl  ; color
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 14) * 4
 	jp enemy_sprite_and_continue_animated

update_enemy_mars_blob1_walk_on_ceiling:
	; walking on ceiling:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and iyh
	call z, update_enemy__patrol_left_right_ceiling

	; if player is in the same vertical, big chance to drop:
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nz, update_enemy_mars_blob1_walk_on_ceiling_no_player
	call random_a
	and #07
	jr z, update_enemy_mars_blob1_walk_switch_to_ground

update_enemy_mars_blob1_walk_on_ceiling_no_player:
	; chance to switch from ceiling to ground:
	call random_a
	or a
	jr nz, update_enemy_mars_blob1_stay_on_ceiling
update_enemy_mars_blob1_walk_switch_to_ground:
	; switch to ground?
	call update_enemy_mars_blob_can_switch_to_ground_p
	jr nz, update_enemy_mars_blob1_stay_on_ceiling
	; switch to ceiling!
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 5
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	jr update_enemy_mars_blob1_falling
update_enemy_mars_blob1_stay_on_ceiling:
 	ld d, iyl  ; color
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 17) * 4
 	jp enemy_sprite_and_continue_animated

update_enemy_mars_blob1_rising:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 14) * 4
 	cp 16
 	jr c, update_enemy_mars_blob1_rising_draw
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 15) * 4
 	cp 18
 	jr c, update_enemy_mars_blob1_rising_draw
 	; rise:
	call update_enemy_bullet_move_up_if_possible
	call update_enemy_bullet_move_up_if_possible
	jp nz, update_enemy_mars_blob1_rising_continue
	; reached ceiling:
	call random_a
	and #01
	add a, 2
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	jr update_enemy_mars_blob1_stay_on_ceiling
update_enemy_mars_blob1_rising_continue:
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 16) * 4
update_enemy_mars_blob1_rising_draw:
 	ld d, iyl  ; color
 	jp enemy_sprite_and_continue

update_enemy_mars_blob1_falling:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 17) * 4
 	cp 16
 	jr c, update_enemy_mars_blob1_falling_draw
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 18) * 4
 	cp 18
 	jr c, update_enemy_mars_blob1_falling_draw
 	; fall:
	call update_enemy_move_down_if_possible
	call update_enemy_move_down_if_possible
	jp nz, update_enemy_mars_blob1_falling_continue
	; reached ground:
	call random_a
	and #01
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
	jp update_enemy_mars_blob1_stay_on_ground
update_enemy_mars_blob1_falling_continue:
 	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 19) * 4
update_enemy_mars_blob1_falling_draw:
 	ld d, iyl  ; color
 	jp enemy_sprite_and_continue


update_enemy_mars_blob_can_switch_to_ceiling_p:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld a, b
	or a
	jr z, update_enemy_mars_blob_can_switch_to_ceiling_p_fail
	push bc
		call get_room_tile_ptr
	pop bc
	ld a, (current_room__width)
	ld e, a
	ld d, 0
update_enemy_mars_blob_can_switch_to_ceiling_p_loop:
	or a
	sbc hl, de
	ld a, (hl)
	or a
	jr z, update_enemy_mars_blob_can_switch_to_ceiling_p_loop_continue
	call get_collision_tile_type_of_a
	or a
	jr z, update_enemy_mars_blob_can_switch_to_ceiling_p_loop_continue
	cp 1  ; we can skip platforms
	jr z, update_enemy_mars_blob_can_switch_to_ceiling_p_loop_continue
	cp 2  ; wall
	ret z  ; wall found!
	jr update_enemy_mars_blob_can_switch_to_ceiling_p_fail
update_enemy_mars_blob_can_switch_to_ceiling_p_loop_continue:
	djnz update_enemy_mars_blob_can_switch_to_ceiling_p_loop
update_enemy_mars_blob_can_switch_to_ceiling_p_fail:
	or 1  ; no ceiling above!
	ret


update_enemy_mars_blob_can_switch_to_ground_p:
	ld a, (current_room__height)
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	cp b
	jr z, update_enemy_mars_blob_can_switch_to_ground_p_fail
	push bc
		call get_room_tile_ptr
	pop bc
	ld a, (current_room__width)
	ld e, a
	ld d, 0
	ld a, (current_room__height)
	sub b
	ld b, a
update_enemy_mars_blob_can_switch_to_ground_p_loop:
	add hl, de
	ld a, (hl)
	or a
	jr z, update_enemy_mars_blob_can_switch_to_ground_p_loop_continue
	call get_collision_tile_type_of_a
	or a
	jr z, update_enemy_mars_blob_can_switch_to_ground_p_loop_continue
	cp 2  ; wall
	ret z  ; wall found!
	cp 1  ; platform
	ret z
	cp 6  ; rope top
	ret z
	cp 8  ; ladder top
	ret z
	jr update_enemy_mars_blob_can_switch_to_ground_p_fail
update_enemy_mars_blob_can_switch_to_ground_p_loop_continue:
	djnz update_enemy_mars_blob_can_switch_to_ground_p_loop
update_enemy_mars_blob_can_switch_to_ground_p_fail:
	or 1  ; no ceiling above!
	ret


update_enemy__patrol_left_right_ceiling:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #01
	jr z, update_enemy__patrol_left_right_ceiling_right
	dec a
	jr z, update_enemy__patrol_left_right_ceiling_left
	ret

update_enemy__patrol_left_right_ceiling_right:
	call update_enemy_move_right_if_possible_ceiling
	ret nz
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3  ; left
	ret

update_enemy__patrol_left_right_ceiling_left:
	call update_enemy_move_left_if_possible_ceiling
	ret nz
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; right
	ret


update_enemy_move_right_if_possible_ceiling:
	call update_enemy_can_move_right_ceiling
	ret z
	jp update_enemy_move_right


update_enemy_move_left_if_possible_ceiling:
	call update_enemy_can_move_left_ceiling
	ret z
	jp update_enemy_move_left


update_enemy_can_move_right_ceiling:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	call general_check_collision_with_wall
	ret z
	; check if the ceiling ends:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	dec b
	call general_check_collision
	jp nz, update_enemy_can_move_right_cannot
	or 1
	ret

update_enemy_can_move_left_ceiling:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call general_check_collision_with_wall
	ret z
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec b
	call general_check_collision
	jp nz, update_enemy_can_move_left_cannot
	or 1
	ret


;-----------------------------------------------
; states:
; - 0: flyong left
; - 1: flying right
; - 2: flying up
; - 3: flying down
update_enemy_mars_drone2:
	ld iyl, COLOR_RED
	jr update_enemy_mars_drone1_continue

update_enemy_mars_drone1:
	ld iyl, COLOR_LIGHT_BLUE
update_enemy_mars_drone1_continue:
	ld iyh, 4  ; damage to deal
	call update_enemy_hurt_player_2x2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_MARS_DRONE2
	jr nz, update_enemy_mars_drone1_continue2
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)  ; drone2 is faster, and hence, we increase its timer twice
update_enemy_mars_drone1_continue2:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_mars_drone1_left
	dec a
	jr z, update_enemy_mars_drone1_right
	dec a
	jr z, update_enemy_mars_drone1_up
update_enemy_mars_drone1_down:
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_MARS_DRONE2
	call z, update_enemy_move_down_if_possible  ; drone2 is faster
	call update_enemy_move_down_if_possible
	jr nz, update_enemy_mars_drone1_continue3
	jr update_enemy_mars_drone1_chance_direction

update_enemy_mars_drone1_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_MARS_DRONE2
	call z, update_enemy_move_left_if_possible  ; drone2 is faster
	call update_enemy_move_left_if_possible
	jr nz, update_enemy_mars_drone1_continue3
	jr update_enemy_mars_drone1_chance_direction

update_enemy_mars_drone1_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_MARS_DRONE2
	call z, update_enemy_move_right_if_possible  ; drone2 is faster
	call update_enemy_move_right_if_possible
	jr nz, update_enemy_mars_drone1_continue3
	jr update_enemy_mars_drone1_chance_direction

update_enemy_mars_drone1_up:
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_MARS_DRONE2
	call z, update_enemy_move_up_if_possible_tall  ; drone2 is faster
	call update_enemy_move_up_if_possible_tall
	jr nz, update_enemy_mars_drone1_continue3
	jr update_enemy_mars_drone1_chance_direction

update_enemy_mars_drone1_continue3:
	; chance to change direction:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1f
	jr nz, update_enemy_mars_drone1_movement_done
	call random_a
	and #03
	jr nz, update_enemy_mars_drone1_movement_done
update_enemy_mars_drone1_chance_direction:
	call random_a
	and #01
	jr z, update_enemy_mars_drone1_chance_direction_random
	; go to player:
	call random_a
	and #01
	jr z, update_enemy_mars_drone1_chance_direction_to_player_v
update_enemy_mars_drone1_chance_direction_to_player_h:
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr c, update_enemy_mars_drone1_chance_direction_to_player_h_left
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
	jr update_enemy_mars_drone1_movement_done
update_enemy_mars_drone1_chance_direction_to_player_h_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	jr update_enemy_mars_drone1_movement_done
update_enemy_mars_drone1_chance_direction_to_player_v:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr c, update_enemy_mars_drone1_chance_direction_to_player_v_up
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 3
	jr update_enemy_mars_drone1_movement_done
update_enemy_mars_drone1_chance_direction_to_player_v_up:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2
	jr update_enemy_mars_drone1_movement_done

update_enemy_mars_drone1_chance_direction_random:
	call random_a
	and #03
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a

update_enemy_mars_drone1_movement_done:
	; chance of firing:
	call update_enemy_player_close_enough_16
	jr nz, update_enemy_mars_drone1_sprites
	ld c, #1f
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_MARS_DRONE2
	jr z, update_enemy_mars_drone1_fire_chance_set
	ld c, #3f
update_enemy_mars_drone1_fire_chance_set:
	call random_a
	and c
	jr nz, update_enemy_mars_drone1_sprites
	call update_enemy_fire_directional_bullet_towards_player
update_enemy_mars_drone1_sprites:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rrca
	rrca
	and #07
	; sprites: 27 - 34
	add a, FIRST_ENEMY_SPRITE_PATTERN + 27
	add a, a
	add a, a
	ld e, a
	ld d, iyl  ; color
 	jp enemy_sprite_and_continue


;-----------------------------------------------
; return:
; - nz: delete
; - z: enemy still exists
update_sprite_objects_atlantis_sentinel_extras_internal:
	push ix
	pop iy
	ld hl, find_tile_enemy_ptr
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000  ; ix: ptr to sentinel
	ret nz

	; get desired x, y:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld (iy + ROOM_OBJECT_STRUCT_TILE_X), a
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	ld (iy + ROOM_OBJECT_STRUCT_TILE_Y), a
	ld (iy + ROOM_OBJECT_STRUCT_PIXEL_Y), 6

	; get the requested frame (and upload only if it's different from the current one):
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA2)  ; the frame we have
	add a, a
	ld hl, update_sprite_objects_atlantis_sentinel_extras_internal_tbl
	ADD_HL_A
	ld a, (hl)  ; desired x offset
	ld (iy + ROOM_OBJECT_STRUCT_PIXEL_X), a
	inc hl
	ld a, (hl)  ; desired sprite
	cp (iy + ROOM_OBJECT_STRUCT_STATE)
	jr z, update_sprite_objects_atlantis_sentinel_extras_internal_continue
	ld (iy + ROOM_OBJECT_STRUCT_STATE), a
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, atlantis_sentinel_sprites_bin
	add hl, bc
	ld de, SPRTBL2 + (FIRST_ENEMY_SPRITE_PATTERN + SENTINEL_DECORATION_SPRITE) * 32
	ld bc, 32
	call fast_LDIRVM_from_sprites_page
update_sprite_objects_atlantis_sentinel_extras_internal_continue:

	push iy
	pop ix
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + SENTINEL_DECORATION_SPRITE) * 4
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	xor a
	ret


; frame | sprite | x offset
; -------------------------
;     0        0          1
;     1        0          1
;     2        0          9
;     3        0          1
;     4        0          1
;     5        1          1
;     6        2          1
; -------------------------
;     7        3         -1
;     8        3         -1
;     9        3         -1
;    10        3         -1
;    11        3         -1
;    12        4         -1
;    13        5          7
update_sprite_objects_atlantis_sentinel_extras_internal_tbl:
	db 1, 0
	db 1, 0
	db 9, 0
	db 1, 0
	db 1, 0
	db 1, 1
	db 1, 2
	db -1, 3
	db -1, 3
	db -1, 3
	db -1, 3
	db -1, 3
	db -1, 4
	db 7, 5

;-----------------------------------------------
update_enemy_bullet_whirlwind:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
	jp z, update_enemy_delete

	inc (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	; < 8: 0
	; < 12: 1
	; < 16: 2
	; < 20: 3
	; otherwise: 4
	ld l, 0  ; speed of movement
	cp 8
	jr c, update_enemy_bullet_whirlwind_movement_done  ; no movement
	ld l, 2
	cp 12
	jr c, update_enemy_bullet_whirlwind_speed_set
	ld l, 4
	cp 16
	jr c, update_enemy_bullet_whirlwind_speed_set
	ld l, 6
	cp 20
	jr c, update_enemy_bullet_whirlwind_speed_set
	ld l, 8
update_enemy_bullet_whirlwind_speed_set:

	call update_enemy_bullet_bresenham_l_steps
	; - b: amount to move in y
	; - c: amount to move in x
	call update_enemy_move_cb

	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call general_check_collision_with_wall
	jp z, update_enemy_delete

	; out of the screen?
	ld a, (current_room__width)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp z, update_enemy_delete
	jp c, update_enemy_delete

	ld a, (current_room__height)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jp z, update_enemy_delete
	jp c, update_enemy_delete

update_enemy_bullet_whirlwind_movement_done:

	ld d, COLOR_WHITE
    ; animation of 6, 7, 8
	ld a, (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	call a_mod_3
	add a, FIRST_ENEMY_SPRITE_PATTERN + 5
	add a, a
	add a, a
	ld e, a  ; e = (FIRST_ENEMY_SPRITE_PATTERN + (state % 3)) * 4 
	; ld e, (FIRST_ENEMY_SPRITE_PATTERN + 6) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_bullet_lightning_colors:
	db COLOR_DARK_BLUE
	db COLOR_WHITE, COLOR_WHITE, COLOR_WHITE, COLOR_WHITE
	db COLOR_LIGHT_BLUE
	db COLOR_BLUE
	db COLOR_DARK_BLUE

update_enemy_bullet_lightning_piece_offsets:
	db 0, (FIRST_ENEMY_SPRITE_PATTERN + 8) * 4 
	db 0, (FIRST_ENEMY_SPRITE_PATTERN + 9) * 4 
	db 0, (FIRST_ENEMY_SPRITE_PATTERN + 10) * 4 
	db 8, (FIRST_ENEMY_SPRITE_PATTERN + 11) * 4 
	db -8, (FIRST_ENEMY_SPRITE_PATTERN + 12) * 4 

update_enemy_bullet_lightning:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_bullet_lightning_state_0
	dec a
	jr z, update_enemy_bullet_lightning_state_1
	dec a
	jr z, update_enemy_bullet_lightning_state_2
update_enemy_bullet_lightning_state_3:
	; just wait a certain amount of time
	ld a, (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	dec (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	or a
	jp nz, update_sprite_enemies_loop_next
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; next state
	ld (ix + ROOM_OBJECT_STRUCT_BULLET_STATE), 0
	jp update_sprite_enemies_loop_next

update_enemy_bullet_lightning_state_2:
	inc (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	cp 9
	jr nz, update_enemy_bullet_lightning_state_0_continue
	jp update_enemy_delete

update_enemy_bullet_lightning_state_1:
	inc (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	cp 16
	jp c, update_sprite_enemies_loop_next
	; move to where the player is:
	ld b, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)  ; player tile x
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_X)  ; player pixel x
	sub 5
	jr nc, update_enemy_bullet_lightning_state_1_continue
	dec b
	add a, 8
update_enemy_bullet_lightning_state_1_continue:
	ld (ix + ROOM_OBJECT_STRUCT_TILE_X), b
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), a
	ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), 20  ; ground height
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 2  ; next state
	ld (ix + ROOM_OBJECT_STRUCT_BULLET_STATE), 0
	jp update_sprite_enemies_loop_next

update_enemy_bullet_lightning_state_0:
	inc (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	cp 9
	jr nz, update_enemy_bullet_lightning_state_0_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; next state
	ld (ix + ROOM_OBJECT_STRUCT_BULLET_STATE), 0
	jp update_sprite_enemies_loop_next
update_enemy_bullet_lightning_state_0_continue:
	ld hl, SFX_explosion
	cp 3
	call z, play_SFX_with_high_priority
	ld hl, update_enemy_bullet_lightning_colors
	ld a, (ix + ROOM_OBJECT_STRUCT_BULLET_STATE)
	dec a
	ADD_HL_A
	ld d, (hl)
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 12) * 4 
	ld c, 0
	call get_sprite_object_sprite_coordinates
	jp nz, update_sprite_enemies_loop_next
	call add_sprite_to_this_frame

	push bc
	push de
		ld iyh, 4  ; damage to deal
		call update_enemy_hurt_player_2x2
	pop de
	pop bc

	; pick the next piece, fixing the random seed:
	ld hl, (rng_seed1)
	push hl
	ld hl, (rng_seed2)
	push hl
		ld hl, #0a0a
		ld (rng_seed1), hl
		ld h, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
		ld l, (ix + ROOM_OBJECT_STRUCT_TILE_X)
		ld (rng_seed2), hl
		push hl
update_enemy_bullet_lightning_loop:
			push bc
				ld c, 5
				call random_modulo
			pop bc
			ld iyl, a  ; next piece
			ld a, b
			sub 16
			jr c, update_enemy_bullet_lightning_done
			ld b, a
			ld hl, update_enemy_bullet_lightning_piece_offsets
			ld a, iyl
			add a, a
			ADD_HL_A
			ld a, c
			add a, (hl)  ; x offset of the next piece
			ld c, a

			ld a, (hl)  ; x offset of the next piece
			sra a
			sra a
			sra a
			add a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
			ld (ix + ROOM_OBJECT_STRUCT_TILE_X), a
			dec (ix + ROOM_OBJECT_STRUCT_TILE_Y)
			dec (ix + ROOM_OBJECT_STRUCT_TILE_Y)

			inc hl
			ld e, (hl)  ; sprite of the next piece

			call add_sprite_to_this_frame
			push bc
			push de
				ld iyh, 4  ; damage to deal
				call update_enemy_hurt_player_2x2
			pop de
			pop bc
			jr update_enemy_bullet_lightning_loop
update_enemy_bullet_lightning_done:
		pop hl 
		ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), h
		ld (ix + ROOM_OBJECT_STRUCT_TILE_X), l
	pop hl
	ld (rng_seed2), hl
	pop hl
	ld (rng_seed1), hl
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_sonic_boom:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
	jp z, update_enemy_delete
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_sonic_boom_right
	dec a
	jr z, update_enemy_sonic_boom_left
update_enemy_sonic_boom_down:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	add a, a
	call update_enemy_bullet_move_down_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 8) * 4 
	jp enemy_sprite_and_continue

update_enemy_sonic_boom_right:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	add a, a
	call update_enemy_bullet_move_right_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 9) * 4 
	jp enemy_sprite_and_continue

update_enemy_sonic_boom_left:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	add a, a
	call update_enemy_bullet_move_left_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_boss2_spikes:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	add a, a
	call update_enemy_bullet_move_down_if_possible_a_times
	jr z, update_enemy_boss2_spikes_bottom
	ld d, COLOR_WHITE
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 11) * 4 
	jp enemy_sprite_and_continue	
update_enemy_boss2_spikes_bottom:
	; leave the spikes in the floor:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld hl, 22
	call get_room_tile_ptr_hl_set
	ld (hl), 15*16 + 12
	inc hl
	ld (hl), 8*16 + 13
	ld bc, 32*2 - 1
	add hl, bc
	ld (hl), 8*16 + 4
	inc hl
	ld (hl), 8*16 + 5
	ld bc, 32*24*2 - (32*2 + 1)
	add hl, bc
	ld (hl), 15*16 + 12
	inc hl
	ld (hl), 8*16 + 13
	ld bc, 32*2 - 1
	add hl, bc
	ld (hl), 8*16 + 4
	inc hl
	ld (hl), 8*16 + 5
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)	
	jp update_enemy_delete


;-----------------------------------------------
update_enemy_boss3_debris:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete

	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	add a, a
	call update_enemy_bullet_move_down_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_WHITE
	ld e, (ix + ROOM_OBJECT_STRUCT_STATE)  ; (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_pus_drop:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete

	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	call update_enemy_bullet_move_down_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 39) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_blood_drop:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete

	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	call update_enemy_bullet_move_down_if_possible_a_times
	jp z, update_enemy_delete
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 39) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_pus_ball:
update_enemy_blood_ball:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_2x2
	jp z, update_enemy_delete
	
	ld a, (current_world__difficulty_bullet_speed)
	inc a  ; a bit faster than a normal bullet
	ld l, a
	call update_enemy_bullet_bresenham_l_steps
	; - b: amount to move in y
	; - c: amount to move in x
	call update_enemy_move_cb

	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call general_check_collision_with_wall
	jp z, update_enemy_delete

	; out of the screen?
	ld a, (current_room__width)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp z, update_enemy_delete
	jp c, update_enemy_delete

	ld a, (current_room__height)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jp z, update_enemy_delete
	jp c, update_enemy_delete

	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp ENEMY_BLOOD_BALL
	jr z, update_enemy_pus_ball_blood
	ld d, COLOR_YELLOW
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 34) * 4 
	jp enemy_sprite_and_continue_animated_fast
update_enemy_pus_ball_blood:
	ld d, COLOR_RED
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 34) * 4 
	jp enemy_sprite_and_continue_animated_fast


;-----------------------------------------------
update_enemy_boss4_blades:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete

	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #04
	jr z, update_enemy_boss4_blades_left
update_enemy_boss4_blades_right:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	call update_enemy_bullet_move_right_if_possible_a_times
	jp z, update_enemy_delete
	jr update_enemy_boss4_blades_continue
update_enemy_boss4_blades_left:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	call update_enemy_bullet_move_left_if_possible_a_times
	jp z, update_enemy_delete
update_enemy_boss4_blades_continue:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #03
	jr z, update_enemy_boss4_blades_movement_done
	dec a
	jp nz, update_enemy_boss4_blades_down
update_enemy_boss4_blades_up:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_bullet_move_up_if_possible_a_times
	jp z, update_enemy_delete	
	jr update_enemy_boss4_blades_movement_done
update_enemy_boss4_blades_down:
	ld a, (current_world__difficulty_bullet_speed)
	call update_enemy_bullet_move_down_if_possible_a_times
	jp z, update_enemy_delete	
update_enemy_boss4_blades_movement_done:
	ld d, COLOR_LIGHT_BLUE
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	call a_mod_3
	add a, FIRST_ENEMY_SPRITE_PATTERN + 31
	add a, a
	add a, a
	ld e, a  ; e = (FIRST_ENEMY_SPRITE_PATTERN + 31 + (state % 3)) * 4 
	jp enemy_sprite_and_continue


;-----------------------------------------------
update_enemy_laser:
	ld iyh, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable_bullet
	jp z, update_enemy_delete

	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_laser_left
	cp 1
	jr z, update_enemy_laser_left_up
	cp 4
	jr z, update_enemy_laser_right
	cp 5
	jr z, update_enemy_laser_right_up
	cp 7
	jr z, update_enemy_laser_up
update_enemy_laser_down:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	call update_enemy_bullet_move_down_if_possible_a_times
	jp z, update_enemy_delete
	ld e, 64  ; |
	jr update_enemy_laser_continue
update_enemy_laser_up:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	call update_enemy_bullet_move_up_if_possible_a_times
	jp z, update_enemy_delete
	ld e, 64  ; |
	jr update_enemy_laser_continue
update_enemy_laser_right:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	call update_enemy_bullet_move_right_if_possible_a_times
	jp z, update_enemy_delete
	ld e, 60  ; laser '-'
	jr update_enemy_laser_continue
update_enemy_laser_right_up:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	dec a
	call update_enemy_bullet_move_right_if_possible_a_times
	jp z, update_enemy_delete
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	dec a
	call update_enemy_bullet_move_up_if_possible_a_times
	jp z, update_enemy_delete
	ld e, 68  ; /
	jr update_enemy_laser_continue
update_enemy_laser_left_up:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	dec a
	call update_enemy_bullet_move_left_if_possible_a_times
	jp z, update_enemy_delete
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	dec a
	call update_enemy_bullet_move_up_if_possible_a_times
	jp z, update_enemy_delete
	ld e, 72  ; \ 
	jr update_enemy_laser_continue
update_enemy_laser_left:
	ld a, (current_world__difficulty_bullet_speed)
	add a, a
	call update_enemy_bullet_move_left_if_possible_a_times
	jp z, update_enemy_delete
	ld e, 60  ; laser '-'
update_enemy_laser_continue:
	ld d, COLOR_RED
	jp enemy_sprite_and_continue


;-----------------------------------------------
; output:
; - z: close (c, b: diff in x and y in tiles)
; - nz: far
update_enemy_player_close_enough_16:
	ld e, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld d, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
update_enemy_player_close_enough_16_ed:
	; see if player is close enough:
	ld a, (player_x + 1)
	sub e
	ld c, a
	cp 16 
	jp p, update_enemy_player_close_enough_16_fail
	cp -16
	jp m, update_enemy_player_close_enough_16_fail
	ld a, (player_y + 1)
	sub d
	ld b, a
	cp 16 
	jp p, update_enemy_player_close_enough_16_fail
	cp -16
	jp m, update_enemy_player_close_enough_16_fail
	xor a  ; success
	ret
update_enemy_player_close_enough_16_fail:
	or 1
	ret


;-----------------------------------------------
; Used by fire imps and ghosts
; - l: movement speed
update_enemy_dash_step_internal:
	; shift data in the struct temporarily, so we can reuse 'update_enemy_bullet_bresenham_iyl_steps':
	ld e, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
	ld d, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	ld c, (ix + ROOM_OBJECT_STRUCT_EXTRA1)
	ld b, (ix + ROOM_OBJECT_STRUCT_EXTRA2)
	ld (ix + ROOM_OBJECT_STRUCT_SPEED_X), c
	ld (ix + ROOM_OBJECT_STRUCT_SPEED_Y), b
	push de
		call update_enemy_bullet_bresenham_l_steps
	pop de
	ld (ix + ROOM_OBJECT_STRUCT_SPEED_X), e
	ld (ix + ROOM_OBJECT_STRUCT_SPEED_Y), d
	; - b: amount to move in y
	; - c: amount to move in x
	jp update_enemy_move_cb


;-----------------------------------------------
update_enemy_fall_to_water:
update_enemy_fall_to_lava:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	push ix
		call spawn_water_splash
	pop ix
	jp update_enemy_delete


;-----------------------------------------------
update_enemy__patrol_left_right_platform:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy__patrol_left_right_platform_right
	dec a
	jr z, update_enemy__patrol_left_right_platform_left
	ret

update_enemy__patrol_left_right_platform_right:
	call update_enemy_move_right_if_possible_platform
	ret nz
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
	ret

update_enemy__patrol_left_right_platform_left:
	call update_enemy_move_left_if_possible_platform
	ret nz
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
	ret


;-----------------------------------------------
; input:
; - ix: object ptr
; - c, b: offset in x and y to move
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

update_enemy_move_cb_y:
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
; input:
; - c, b: amount to move in x, y
; output:
; - z: collision
; - nz: no collision
update_enemy_move_cb_colliding_down:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	add a, c
	jp p, update_enemy_move_cb_colliding_down_positive_x
	dec (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, 8
update_enemy_move_cb_colliding_down_positive_x:
	cp 8
	jr c, update_enemy_move_cb_colliding_down_carry_x
	inc (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, -8
update_enemy_move_cb_colliding_down_carry_x:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), a

	ld a, b
	or a
	jr z, update_enemy_move_cb_colliding_down_no_vertical_move
	jp p, update_enemy_move_cb_colliding_down_moving_down  ; moving down
	call update_enemy_move_cb_y
update_enemy_move_cb_colliding_down_no_vertical_move:
	or 1  ; no collision
	ret
update_enemy_move_cb_colliding_down_moving_down:
	; moving down:
	push bc
		call update_enemy_move_down_if_possible
	pop bc
	ret z
	djnz update_enemy_move_cb_colliding_down_moving_down
	or 1  ; no collision
	ret


;-----------------------------------------------
update_enemy_fire_directional_bullet_towards_player:
	ld e, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld d, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
update_enemy_fire_directional_bullet_towards_player_at_e_d:
	call update_enemy_player_close_enough_16_ed  ; and put difference in c, b
	ret nz
	; fire a bullet:
	push bc
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), ENEMY_BULLET
update_enemy_fire_directional_bullet_towards_player_continue:
	inc hl
	ld (hl), 0  ; pixel X
	inc hl
	ld (hl), e  ; tile X
	inc hl
	ld (hl), 4  ; pixel Y
	inc hl
	ld (hl), d  ; tile Y
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
; 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (interrupt_cycle)
	rrca
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
; 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
; 	rlca
	ld a, (interrupt_cycle)
	and #0c
	add a, e
	ld e, a
	jp enemy_sprite_and_continue


;-----------------------------------------------
; input:
; - d: sprite color
; - e: sprite frame
enemy_sprite_and_continue_animated_fast:
; 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (interrupt_cycle)
	rrca
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
; 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
; 	rrca
	ld a, (interrupt_cycle)
	rrca
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
; - ix: pointer to enemy object
; - c, b: x, y, tile offset
; output:
; - z: collision
; - nz: no collision
update_enemy_player_collision_coarse_2x2:
	; dx = (player tile x) - (enemy x + c)
	ld a, (player_x + 1)  ; player tile coordinate
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	sub c
	; dx must be in [-2, 2]:
	cp -2
	jp m, update_enemy_player_collision_coarse_2x2_no_collision
	cp 3
	jp p, update_enemy_player_collision_coarse_2x2_no_collision

	; dx = (player tile x) - (enemy x + c)
	ld a, (player_y + 1)  ; player tile coordinate
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	sub b
	; dx must be in [-2, 2]:
	cp -2
	jp m, update_enemy_player_collision_coarse_2x2_no_collision
	cp 3
	jp p, update_enemy_player_collision_coarse_2x2_no_collision
	xor a  ; collision
	ret
update_enemy_player_collision_coarse_2x2_no_collision:
update_enemy_player_collision_pixel_level_no_collsion:
	or 1  ; no collision
	ret


;-----------------------------------------------
; input:
; - ix: pointer to enemy object
; - c, b: x, y, tile offset
; output:
; - z: collision
; - nz: no collision
update_enemy_player_collision_coarse_1x1:
	; dx = (player tile x) - (enemy x + c)
	ld a, (player_x + 1)  ; player tile coordinate
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	sub c
	; dx must be in [-1, 1]:
	cp -1
	jp m, update_enemy_player_collision_coarse_2x2_no_collision
	cp 2
	jp p, update_enemy_player_collision_coarse_2x2_no_collision

	; dx = (player tile x) - (enemy x + c)
	ld a, (player_y + 1)  ; player tile coordinate
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	sub b
	; dx must be in [-1, 1]:
	cp -1
	jp m, update_enemy_player_collision_coarse_2x2_no_collision
	cp 2
	jp p, update_enemy_player_collision_coarse_2x2_no_collision
	xor a  ; collision
	ret


;-----------------------------------------------
; input:
; - c, b: x1, y1 (in pixel coordinates, relative to player)
; - e, d: x2, y2 (in pixel coordinates, relative to player)
; output:
; - z: collision
; - nz: no collision
update_enemy_player_collision_pixel_level:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CROUCHING
	jr z, update_enemy_player_collision_pixel_level_short
	cp PLAYER_STATE_CRAWLING
	jr z, update_enemy_player_collision_pixel_level_short
	cp PLAYER_STATE_SWIMMING
	jr z, update_enemy_player_collision_pixel_level_short
	cp PLAYER_STATE_WEAPON_SWING_CROUCHING
	jr z, update_enemy_player_collision_pixel_level_short
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING
	jr z, update_enemy_player_collision_pixel_level_short
	; player bbox is: (6, 5) - (10, 16)  [offset by "8 - PLAYER_COLLISION_WIDTH/2"]
	ld a, c
	cp 10 - (8 - PLAYER_COLLISION_WIDTH/2)
	jp p, update_enemy_player_collision_pixel_level_no_collsion
	ld a, e
	cp 6 - (8 - PLAYER_COLLISION_WIDTH/2)
	jp m, update_enemy_player_collision_pixel_level_no_collsion
	ld a, b
	cp 16
	jp p, update_enemy_player_collision_pixel_level_no_collsion
	ld a, d
	cp 5
	jp m, update_enemy_player_collision_pixel_level_no_collsion
	xor a  ; collision!
	ret
update_enemy_player_collision_pixel_level_short:
	; player bbox is: (5, 10) - (11, 16)
	ld a, c
	cp 11 - (8 - PLAYER_COLLISION_WIDTH/2)
	jp p, update_enemy_player_collision_pixel_level_no_collsion
	ld a, e
	cp 5 - (8 - PLAYER_COLLISION_WIDTH/2)
	jp m, update_enemy_player_collision_pixel_level_no_collsion
	ld a, b
	cp 16
	jp p, update_enemy_player_collision_pixel_level_no_collsion
	ld a, d
	cp 11
	jp m, update_enemy_player_collision_pixel_level_no_collsion
	xor a  ; collision!
	ret


;-----------------------------------------------
; input:
; - iyh: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player_shieldable_bullet:
	ld a, (player_current_item)
	cp 3  ; shield
	jp nz, update_enemy_hurt_player_bullet
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DIRECTIONAL_WEAPON
	jr z, update_enemy_hurt_player_shieldable_bullet_with_directional
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_JUMPING
	jr z, update_enemy_hurt_player_shieldable_bullet_with_directional
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_FALLING
	jr z, update_enemy_hurt_player_shieldable_bullet_with_directional
	cp PLAYER_STATE_DIRECTIONAL_WEAPON_CROUCHING
	jp nz, update_enemy_hurt_player_bullet
update_enemy_hurt_player_shieldable_bullet_with_directional:
	; check if the player has the shield up and in the correct direction:
	ld a, (player_weapon_swing_type)
	cp PLAYER_WEAPON_SHIELD_UP
	jr z, update_enemy_hurt_player_shieldable_bullet_shield_up
	cp PLAYER_WEAPON_SHIELD_FORWARD
	jp nz, update_enemy_hurt_player_bullet
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
	jp nz, update_enemy_hurt_player_bullet
update_enemy_hurt_player_shieldable_bullet_shield_left_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	jp update_enemy_hurt_player_bullet

update_enemy_hurt_player_shieldable_bullet_shield_right:
	ld a, (player_x + 1)
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
; 	jr z, update_enemy_hurt_player_shieldable_bullet_shield_left_y
; 	inc a
; 	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp nz, update_enemy_hurt_player_bullet
update_enemy_hurt_player_shieldable_bullet_shield_right_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_bullet_shielded
	jp update_enemy_hurt_player_bullet

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
	jp update_enemy_hurt_player_bullet

update_enemy_hurt_player_shieldable_bullet_shielded:
	ld hl, SFX_shield
	call play_SFX_with_high_priority
	xor a  ; hit
	ret


;-----------------------------------------------
; input:
; - c, b: enemy x, y tile coordinates
; - iyh: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player_bc_2x1:
	ld a, (player_immunity_timer)
	or a
	ret nz  ; player immune
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DEAD
	ret z  ; player already dead
	call update_enemy_player_collision_coarse_2x2
	ret nz	

	; ix: ptr to enemy, c, b: left-right of bbox, e, d: width, height of bbox.
	; compute bullet pixel coordinates relative to player:
	ld a, (player_x + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	sub c
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, (player_x)
	add a, c
	sub (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	neg  ; a = left-most bullet pixel in player coordinates
	add a, 4
	ld c, a  ; x1
	add a, 8
	ld e, a  ; x2

	ld a, (player_y + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	sub b
	add a, a
	add a, a
	add a, a
	ld b, a
	ld a, (player_y)
	add a, b
	sub (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	neg  ; a = top-most bullet pixel in player coordinates
	add a, 4
	ld b, a  ; y1
	add a, 12
	ld d, a  ; y2
	call update_enemy_player_collision_pixel_level
	ret nz

	ld c, iyh
	call player_hit_damage_c
	xor a  ; hit
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; - iyh: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player_2x2:
	ld a, (player_immunity_timer)
	or a
	ret nz  ; player immune
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DEAD
	ret z  ; player already dead
	ld bc, 0
	call update_enemy_player_collision_coarse_2x2
	ret nz
update_enemy_hurt_player_2x2_coarse_passed:
	; ix: ptr to enemy, c, b: left-right of bbox, e, d: width, height of bbox.
	; compute bullet pixel coordinates relative to player:
	ld a, (player_x + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, (player_x)
	add a, c
	sub (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	neg  ; a = left-most bullet pixel in player coordinates
	add a, 4
	ld c, a  ; x1
	add a, 8
	ld e, a  ; x2

	ld a, (player_y + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	add a, a
	add a, a
	add a, a
	ld b, a
	ld a, (player_y)
	add a, b
	sub (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	neg  ; a = top-most bullet pixel in player coordinates
	add a, 4
	ld b, a  ; y1
	add a, 12
	ld d, a  ; y2
	call update_enemy_player_collision_pixel_level
	ret nz

	; player is hit!
	ld c, iyh  ; damage
	call player_hit_damage_c
	xor a  ; hit
	ret


;-----------------------------------------------
; input:
; - ix: enemy ptr
; - iyh: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player_bullet:
	ld a, (player_immunity_timer)
	or a
	ret nz  ; player immune
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DEAD
	ret z  ; player already dead
	ld bc, 0
	call update_enemy_player_collision_coarse_1x1
	ret nz
	; ix: ptr to enemy, c, b: left-right of bbox, e, d: width, height of bbox.
	; compute bullet pixel coordinates relative to player:
	ld a, (player_x + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_X)
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, (player_x)
	add a, c
	sub (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	neg  ; a = left-most bullet pixel in player coordinates
	add a, 6
	ld c, a  ; x1
	add a, 4
	ld e, a  ; x2

	ld a, (player_y + 1)
	sub (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	add a, a
	add a, a
	add a, a
	ld b, a
	ld a, (player_y)
	add a, b
	sub (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	neg  ; a = top-most bullet pixel in player coordinates
	add a, 2
	ld b, a  ; y1
	add a, 4
	ld d, a  ; y2
	call update_enemy_player_collision_pixel_level
	ret nz

	; player is hit!
	ld c, iyh
	call player_hit_damage_c
	xor a  ; hit
	ret


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
update_enemy_move_up_if_possible_stairs:
	call update_enemy_can_move_up_stairs
	ret z
	jp update_enemy_move_up



;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: cannot
; - nz: can
update_enemy_move_up_if_possible_tall:
	call update_enemy_can_move_up_tall
	ret z
	jp update_enemy_move_up


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
update_enemy_move_down_if_possible_stairs:
	call update_enemy_can_move_down_stairs
	ret z
	jp update_enemy_move_down


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
	ld a, (current_room__width)
	add a, 2
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ret z  ; cannot
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
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	or a
	ret z  ; cannot
	ld c, a
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
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	or a
	ret z  ; cannot
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
update_enemy_can_move_up_tall:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	ret nz
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	or a
	ret z  ; cannot
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	jr nc, update_enemy_can_move_up_tall_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec b
	call general_check_collision_with_wall
	ret z
update_enemy_can_move_up_tall_continue:
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec b
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
	ld a, (current_room__height)
	add a, 2
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ret z  ; cannot
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
update_enemy_can_move_up_stairs:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	ret nz
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	jr nc, update_enemy_can_move_up_stairs_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	call general_check_collision_with_wall
	ret z
update_enemy_can_move_up_stairs_continue:
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
update_enemy_can_move_down_stairs:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	ret nz
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	cp 4
	jr nc, update_enemy_can_move_down_stairs_continue
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc b
	inc b
	call general_check_collision_with_wall
	ret z
update_enemy_can_move_down_stairs_continue;
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc b
	inc b
	jp general_check_collision_with_wall


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
; 	inc b
	call general_check_collision_with_wall
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
	or a
	ret z  ; screen edge
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	jr nz, update_enemy_bullet_move_left_if_possible_move
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec c
; 	inc b
	call general_check_collision_with_wall
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
	call general_check_collision_with_wall
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
	or a
	ret z  ; screen edge
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	or a
	jr nz, update_enemy_bullet_move_up_if_possible_move
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec b
	call general_check_collision_with_wall
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
	cp ENEMY_SNAKE  ; first enemy that can be hit
	ret c
	cp ENEMY_ROCKMAN
	jr z, enemy_hit_rockman
	cp ENEMY_ROCKMAN2
	jr z, enemy_hit_rockman
	cp ENEMY_MARS_SNAIL1
	jr z, enemy_hit_mars_snail
	cp ENEMY_MARS_SNAIL2
	jr z, enemy_hit_mars_snail
enemy_hit_continue:
	ld a, iyl
	ld (ix + ROOM_OBJECT_STRUCT_LAST_HIT_ID), a
	ld a, (ix + ROOM_OBJECT_STRUCT_HEALTH)
	sub iyh
	jr z, enemy_hit_killed
	jr c, enemy_hit_killed
	ld (ix + ROOM_OBJECT_STRUCT_HEALTH), a
	ld hl, SFX_enemy_hit
	jp play_SFX_with_high_priority

enemy_hit_rockman:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	cp 2
	jr nz, enemy_hit_continue
enemy_hit_rockman_stone:
	; hit rockman when it was in stone shape, shield hit:
	ld a, iyl
	ld (ix + ROOM_OBJECT_STRUCT_LAST_HIT_ID), a
	ld hl, SFX_shield
	jp play_SFX_with_high_priority

enemy_hit_mars_snail:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	sub 2
	jr z, enemy_hit_rockman_stone
	dec a
	jr z, enemy_hit_rockman_stone
	ld a, (player_x + 1)  ; tile x
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	jr z, enemy_hit_rockman_stone
	jr nc, enemy_hit_mars_snail_from_right
enemy_hit_mars_snail_left:
	and #01
	jr nz, enemy_hit_continue
	jr enemy_hit_rockman_stone
enemy_hit_mars_snail_from_right:
	and #01
	jr z, enemy_hit_continue
	jr enemy_hit_rockman_stone

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
	cp ENEMY_ALIEN
	ret z  ; aliens do not have drops
	ld a, (boss__active)
	or a
	ret nz  ; no drops for enemies spawned by bosses
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
; 	cp 8 * 2
; 	ld hl, spawn_tile_object_5_coins
; 	jr c, enemy_maybe_spawn_drop_drop
	cp 16 * 2
	ld hl, spawn_tile_object_1_coin
	jr c, enemy_maybe_spawn_drop_drop
	cp 24 * 2
	ld hl, spawn_tile_object_corn
	jr c, enemy_maybe_spawn_drop_drop
	cp 32 * 2
	ld hl, spawn_tile_object_5_stones
	jr c, enemy_maybe_spawn_drop_drop_stones
	cp 40 * 2
	ld hl, spawn_tile_object_5_darts
	jr c, enemy_maybe_spawn_drop_drop_darts
	cp 48 * 2
	ld hl, spawn_tile_object_5_spears
	jr c, enemy_maybe_spawn_drop_drop_spears
	cp 64 * 2
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
update_enemy_bullet_move_right_if_possible_a_times:
	srl a
	ld b, a
	jr nc, update_enemy_bullet_move_right_if_possible_a_times_continue
	ld a, (game_cycle)
	rrca
	rrca
	jr c, update_enemy_bullet_move_right_if_possible_a_times_continue
	inc b
update_enemy_bullet_move_right_if_possible_a_times_continue:
update_enemy_bullet_move_right_if_possible_a_times_loop:
	push bc
		call update_enemy_bullet_move_right_if_possible
	pop bc
	ret z
	djnz update_enemy_bullet_move_right_if_possible_a_times_loop
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - a: number of frames to move * 2
; output:
; - z: collision
; - nz: no collision
update_enemy_bullet_move_left_if_possible_a_times:
	srl a
	ld b, a
	jr nc, update_enemy_bullet_move_left_if_possible_a_times_continue
	ld a, (game_cycle)
	rrca
	rrca
	jr c, update_enemy_bullet_move_left_if_possible_a_times_continue
	inc b
update_enemy_bullet_move_left_if_possible_a_times_continue:
update_enemy_bullet_move_left_if_possible_a_times_loop:
	push bc
		call update_enemy_bullet_move_left_if_possible
	pop bc
	ret z
	djnz update_enemy_bullet_move_left_if_possible_a_times_loop
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - a: number of frames to move * 2
; output:
; - z: collision
; - nz: no collision
update_enemy_bullet_move_down_if_possible_a_times:
	srl a
	ld b, a
	jr nc, update_enemy_bullet_move_down_if_possible_a_times_continue
	ld a, (game_cycle)
	rrca
	rrca
	jr c, update_enemy_bullet_move_down_if_possible_a_times_continue
	inc b
update_enemy_bullet_move_down_if_possible_a_times_continue:
update_enemy_bullet_move_down_if_possible_a_times_loop:
	push bc
		call update_enemy_bullet_move_down_if_possible
	pop bc
	ret z
	djnz update_enemy_bullet_move_down_if_possible_a_times_loop
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - a: number of frames to move * 2
; output:
; - z: collision
; - nz: no collision
update_enemy_bullet_move_up_if_possible_a_times:
	srl a
	ld b, a
	jr nc, update_enemy_bullet_move_up_if_possible_a_times_continue
	ld a, (game_cycle)
	rrca
	rrca
	jr c, update_enemy_bullet_move_up_if_possible_a_times_continue
	inc b
update_enemy_bullet_move_up_if_possible_a_times_continue:
update_enemy_bullet_move_up_if_possible_a_times_loop:
	push bc
		call update_enemy_bullet_move_up_if_possible
	pop bc
	ret z
	djnz update_enemy_bullet_move_up_if_possible_a_times_loop
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - ix: ptr to bullet object
; - l: number of steps to apply
; output:
; - c: number of times to move in x (..., -2, -1, 0, 1, 2, ...)
; - b: number of times to move in y (..., -2, -1, 0, 1, 2, ...)
update_enemy_bullet_bresenham_l_steps:
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	or a
    jp p, update_enemy_bullet_bresenham_no_yspeed_flip
    neg
update_enemy_bullet_bresenham_no_yspeed_flip:
    ld d, a  ; d = |speed y|
    ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
    or a
    jp p, update_enemy_bullet_bresenham_no_xspeed_flip
    neg
update_enemy_bullet_bresenham_no_xspeed_flip:
    ld e, a  ; e = |speed x|
    cp d
    jp c,update_enemy_bullet_bresenham_y_is_bigger
    ; Bresenham for when the |speed x| > |speed y|
update_enemy_bullet_bresenham_x_is_bigger:
	ld bc, 0
    ld a, (ix + ROOM_OBJECT_STRUCT_BRESENHAM_STATE)
update_enemy_bullet_bresenham_x_is_bigger_loop:
    sub d  ; we subtract y difference from the error term 
    jp p, update_enemy_bullet_bresenham_x_is_bigger_no_error_overflow
    inc b
    add a, e
update_enemy_bullet_bresenham_x_is_bigger_no_error_overflow:
    inc c
    dec l
    jr nz, update_enemy_bullet_bresenham_x_is_bigger_loop
    ld (ix + ROOM_OBJECT_STRUCT_BRESENHAM_STATE), a
    jp update_enemy_bullet_bresenham_choose_quadrant

    ; Bresenham for when the |speed x| < |speed y|
update_enemy_bullet_bresenham_y_is_bigger:
	ld bc, 0
    ld a, (ix + ROOM_OBJECT_STRUCT_BRESENHAM_STATE)
update_enemy_bullet_bresenham_y_is_bigger_loop:
    sub e  ; we subtract x difference from the error term 
    jp p,update_enemy_bullet_bresenham_y_is_bigger_no_error_overflow
    inc c
    add a, d
update_enemy_bullet_bresenham_y_is_bigger_no_error_overflow:
    inc b
    dec l
    jr nz, update_enemy_bullet_bresenham_y_is_bigger_loop
    ld (ix + ROOM_OBJECT_STRUCT_BRESENHAM_STATE), a

update_enemy_bullet_bresenham_choose_quadrant:
	; here:
	; - b: number of steps we need to move in y
	; - c: number of steps we need to move in x
    ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
    or a
    jp p, update_enemy_bullet_bresenham_no_yspeed_flip2
    ld a, b
    neg
    ld b, a
update_enemy_bullet_bresenham_no_yspeed_flip2:
    ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
    or a
    ret p
    ld a, c
    neg
    ld c, a
    ret
