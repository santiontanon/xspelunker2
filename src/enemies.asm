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
	dec a  ; cp ENEMY_SNAKE
	jr z, update_enemy_snake
	dec a  ; cp ENEMY_SNAKE_DASHER
	jp z, update_enemy_snake_dasher
	dec a  ; cp ENEMY_SNAKE_POISON
	jp z, update_enemy_snake_poison
	dec a  ; cp ENEMY_POISON_BULLET
	jp z, update_enemy_poison_bullet
	dec a  ; cp ENEMY_FISH
	jp z, update_enemy_fish
	dec a  ; cp ENEMY_FISH_JUMPER
	jp z, update_enemy_fish_jumper

update_sprite_enemies_loop_next:
	ld de, ROOM_OBJECT_STRUCT_SIZE
	add ix, de
	jp update_sprite_enemies_loop
update_sprite_enemies_loop_next_after_deletion:
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_snake:
	ld c, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_snake_right
	dec a
	jr z, update_enemy_snake_left
	; we cannever reach here ...

update_enemy_snake_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_snake_right_continue
	call update_enemy_can_move_right
	jr z, update_enemy_snake_switch_to_state_left
	call update_enemy_move_right
	jr update_enemy_snake_right_continue
update_enemy_snake_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
update_enemy_snake_right_continue:
	ld d, COLOR_DARK_YELLOW
update_enemy_snake_right_continue_color_set:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rrca
	and #04
	add a, FIRST_ENEMY_SPRITE_PATTERN * 4 
	ld e, a
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next

update_enemy_snake_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_snake_left_continue
	call update_enemy_can_move_left
	jr z, update_enemy_snake_switch_to_state_right
	call update_enemy_move_left
	jr update_enemy_snake_left_continue
update_enemy_snake_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
update_enemy_snake_left_continue:
	ld d, COLOR_DARK_YELLOW
update_enemy_snake_left_continue_color_set:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rrca
	and #04
	add a, (FIRST_ENEMY_SPRITE_PATTERN + 2) * 4 
	ld e, a
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_snake_dasher:
	ld c, 1  ; damage to deal
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
	call update_enemy_can_move_right
	jr z, update_enemy_snake_dasher_switch_to_state_left
	call update_enemy_move_right
	jr update_enemy_snake_dasher_right_continue
update_enemy_snake_dasher_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
update_enemy_snake_dasher_right_continue:
	ld d, COLOR_DARK_GREEN
	jp update_enemy_snake_right_continue_color_set

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
	call update_enemy_can_move_left
	jr z, update_enemy_snake_dasher_switch_to_state_right
	call update_enemy_move_left
	jr update_enemy_snake_dasher_left_continue
update_enemy_snake_dasher_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
update_enemy_snake_dasher_left_continue:
	ld d, COLOR_DARK_GREEN
	jp update_enemy_snake_left_continue_color_set

update_enemy_snake_dasher_dash_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jr z, update_enemy_snake_dasher_switch_to_state_left
	cp 32
	jr nc, update_enemy_snake_dasher_right_continue
	call update_enemy_can_move_right
	jr z, update_enemy_snake_dasher_right_continue
	call update_enemy_move_right
	call update_enemy_can_move_right
	jr z, update_enemy_snake_dasher_right_continue
	call update_enemy_move_right
	jr update_enemy_snake_dasher_right_continue

update_enemy_snake_dasher_dash_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 64
	jr z, update_enemy_snake_dasher_switch_to_state_right
	cp 32
	jr nc, update_enemy_snake_dasher_left_continue
	call update_enemy_can_move_left
	jr z, update_enemy_snake_dasher_left_continue
	call update_enemy_move_left
	call update_enemy_can_move_left
	jr z, update_enemy_snake_dasher_left_continue
	call update_enemy_move_left
	jr update_enemy_snake_dasher_left_continue


;-----------------------------------------------
update_enemy_snake_poison:
	ld c, 1  ; damage to deal
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

update_enemy_snake_poison_right:
	; spit?
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 16
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
; 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
; 	and #1
; 	jr z, update_enemy_snake_poison_right_continue
	call update_enemy_can_move_right
	jr z, update_enemy_snake_poison_switch_to_state_left
	call update_enemy_move_right
	jr update_enemy_snake_poison_right_continue
update_enemy_snake_poison_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
update_enemy_snake_poison_right_continue:
	ld d, COLOR_GREEN
	jp update_enemy_snake_right_continue_color_set

update_enemy_snake_poison_left:
	; spit?
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 16
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
; 	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
; 	and #1
; 	jr z, update_enemy_snake_poison_left_continue
	call update_enemy_can_move_left
	jr z, update_enemy_snake_poison_switch_to_state_right
	call update_enemy_move_left
	jr update_enemy_snake_poison_left_continue
update_enemy_snake_poison_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
update_enemy_snake_poison_left_continue:
	ld d, COLOR_GREEN
	jp update_enemy_snake_left_continue_color_set

update_enemy_snake_poison_spit_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr nz, update_enemy_snake_poison_spit_right_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
update_enemy_snake_poison_spit_right_continue:
	cp 16
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
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 4) * 4 
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next

update_enemy_snake_poison_spit_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	cp 32
	jr nz, update_enemy_snake_poison_spit_left_continue
	ld (ix + ROOM_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
update_enemy_snake_poison_spit_left_continue:
	cp 16
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
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 5) * 4 
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_poison_bullet:
	ld c, 2  ; damage to deal
	call update_enemy_hurt_player_shieldable
	jp z, update_enemy_delete
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr nz, update_enemy_poison_bullet_left

update_enemy_poison_bullet_right:
	call update_enemy_bullet_can_move_right
	jp z, update_enemy_delete
	call update_enemy_move_right
	call update_enemy_bullet_can_move_right
	jp z, update_enemy_delete
	call update_enemy_move_right
	ld d, COLOR_GREEN
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 6) * 4 
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next

update_enemy_poison_bullet_left:
	call update_enemy_bullet_can_move_left
	jp z, update_enemy_delete
	call update_enemy_move_left
	call update_enemy_bullet_can_move_left
	jp z, update_enemy_delete
	call update_enemy_move_left
	ld d, COLOR_GREEN
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 6) * 4 
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_fish:
	ld c, 1  ; damage to deal
	call update_enemy_hurt_player
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jr z, update_enemy_fish_right
	dec a
	jr z, update_enemy_fish_left
	; we cannever reach here ...

update_enemy_fish_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_fish_right_continue
	call update_enemy_can_move_right_water
	jr z, update_enemy_fish_switch_to_state_left
	call update_enemy_move_right
	jr update_enemy_fish_right_continue
update_enemy_fish_switch_to_state_left:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 1  ; left
update_enemy_fish_right_continue:
	ld d, COLOR_PURPLE
update_enemy_fish_right_continue_color_set:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rrca
	and #04
	add a, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4 
	ld e, a
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next

update_enemy_fish_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	and #1
	jr z, update_enemy_fish_left_continue
	call update_enemy_can_move_left_water
	jr z, update_enemy_fish_switch_to_state_right
	call update_enemy_move_left
	jr update_enemy_fish_left_continue
update_enemy_fish_switch_to_state_right:
	ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
update_enemy_fish_left_continue:
	ld d, COLOR_PURPLE
update_enemy_fish_left_continue_color_set:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)
	rrca
	and #04
	add a, (FIRST_ENEMY_SPRITE_PATTERN + 11) * 4 
	ld e, a
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_fish_jumper:
	inc (ix + ROOM_OBJECT_STRUCT_STATE_TIMER)

	; ...
	jr update_enemy_fish_right_continue


;-----------------------------------------------
update_enemy_delete:
	call sprite_object_remove_object_enemy
	jp update_sprite_enemies_loop_next_after_deletion


;-----------------------------------------------
; input:
; - c: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player_shieldable:
	ld a, (player_current_item)
	cp 3  ; shield
	jp nz, update_enemy_hurt_player
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_DIRECTIONAL_WEAPON
	jp nz, update_enemy_hurt_player
	; check if the player has the shield up and in the correct direction:
	ld a, (player_weapon_swing_type)
	cp PLAYER_WEAPON_SHIELD_UP
	jr z, update_enemy_hurt_player_shieldable_shield_up
	cp PLAYER_WEAPON_SHIELD_FORWARD
	jr nz, update_enemy_hurt_player
update_enemy_hurt_player_shieldable_shield_fw:
	ld a, (player_state)
	and #01
	jr z, update_enemy_hurt_player_shieldable_shield_right

update_enemy_hurt_player_shieldable_shield_left:
	ld a, (player_x + 1)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr z, update_enemy_hurt_player_shieldable_shield_left_y
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nz, update_enemy_hurt_player
update_enemy_hurt_player_shieldable_shield_left_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_shielded
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_shielded
	jp update_enemy_hurt_player

update_enemy_hurt_player_shieldable_shield_right:
	ld a, (player_x + 1)
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
; 	jr z, update_enemy_hurt_player_shieldable_shield_left_y
; 	inc a
; 	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr nz, update_enemy_hurt_player
update_enemy_hurt_player_shieldable_shield_right_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_shielded
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_shielded
	jp update_enemy_hurt_player

update_enemy_hurt_player_shieldable_shield_up:
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr z, update_enemy_hurt_player_shieldable_shield_up_y
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ret nz
update_enemy_hurt_player_shieldable_shield_up_y:
	ld a, (player_y + 1)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_shieldable_shielded
	jp update_enemy_hurt_player

update_enemy_hurt_player_shieldable_shielded:
	ld hl, SFX_shield
	call play_SFX_with_high_priority
	xor a  ; hit
	ret


;-----------------------------------------------
; input:
; - c: amount of damage to deal
; output:
; - z: hit
; - nz: no hit
update_enemy_hurt_player:
	ld a, (player_immunity_timer)
	or a
	ret nz  ; player immune
	ld a, (player_x + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr z, update_enemy_hurt_player_y
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ret nz
update_enemy_hurt_player_y:
	ld a, (player_y + 1)
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_collision
	inc a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr z, update_enemy_hurt_player_collision
	dec a
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ret nz
update_enemy_hurt_player_collision:
	; player is hit!
	call player_hit_damage_c
	xor a  ; hit
	ret


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
	ret


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
; - z: canot
; - nz: can
update_enemy_can_move_right:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	inc b
	call general_check_collision
	ret z
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
; - z: canot
; - nz: can
update_enemy_can_move_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec c
	inc b
	call general_check_collision
	ret z
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec c
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
; - z: canot
; - nz: can
update_enemy_can_move_right_water:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	jp general_check_collision


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: canot
; - nz: can
update_enemy_can_move_left_water:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec c
	jp general_check_collision


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: canot
; - nz: can
update_enemy_bullet_can_move_right:
	ld a, (current_room__width)
	dec a
	cp (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ret z  ; screen edge
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc c
	inc c
	inc b
	jp general_check_collision


;-----------------------------------------------
; input:
; - ix: enemy ptr
; output:
; - z: canot
; - nz: can
update_enemy_bullet_can_move_left:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ret z  ; screen edge
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	or a
	ret nz
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec c
	inc b
	jp general_check_collision


;-----------------------------------------------
; input:
; - ix: enemy ptr
; - iyl: hit ID
; - iyh: damage to deal
enemy_hit:
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
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	push bc
		call sprite_object_remove_object_enemy
	pop bc
	push bc
		call spawn_explosion
	pop bc
	call random_a
	; item drop:
	cp 8 * 2
	ld hl, spawn_tile_object_1_coin
	jr c, enemy_hit_spawn_drop
	cp 16 * 2
	ld hl, spawn_tile_object_corn
	jr c, enemy_hit_spawn_drop
	cp 24 * 2
	ld hl, spawn_tile_object_2_stones
	jr c, enemy_hit_spawn_drop_stones
	cp 32 * 2
	ld hl, spawn_tile_object_2_darts
	jr c, enemy_hit_spawn_drop_darts
	cp 40 * 2
	ld hl, spawn_tile_object_2_spears
	jr c, enemy_hit_spawn_drop_spears
	cp 48 * 2
	ld hl, spawn_tile_object_battery
	jr c, enemy_hit_spawn_drop_battery
enemy_hit_continue:
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ld hl, SFX_enemy_kill
	jp play_SFX_with_high_priority

enemy_hit_spawn_drop:
	ld e, TILES_PAGE
	call call_hl_in_page_e_8000
	jr enemy_hit_continue

enemy_hit_spawn_drop_stones:
	ld a, (player_inventory_weapons+4)  ; do we have the sling?
	or a
	jr z, enemy_hit_continue
	jr enemy_hit_spawn_drop

enemy_hit_spawn_drop_darts:
	ld a, (player_inventory_weapons+5)  ; do we have the blowgun?
	or a
	jr z, enemy_hit_continue
	jr enemy_hit_spawn_drop

enemy_hit_spawn_drop_spears:
	ld a, (player_inventory_weapons+6)  ; do we have the atlatl
	or a
	jr z, enemy_hit_continue
	jr enemy_hit_spawn_drop

enemy_hit_spawn_drop_battery:
	ld a, (player_inventory_weapons+7)  ; do we have the raygun
	or a
	jr z, enemy_hit_continue
	jr enemy_hit_spawn_drop


