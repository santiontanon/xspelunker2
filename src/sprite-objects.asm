;-----------------------------------------------
; output:
; - z: we could find a new ptr
; - nz: no ptrs available
; - hl: ptr if one was available
ptr_to_new_sprite_object_player_bullet:
	ld hl, current_room__player_bullets
	ld de, ROOM_OBJECT_STRUCT_SIZE
	jr ptr_to_new_sprite_object_loop


;-----------------------------------------------
; output:
; - z: we could find a new ptr
; - nz: no ptrs available
; - hl: ptr if one was available
ptr_to_new_sprite_enemy:
	ld hl, current_room__sprite_enemies
	ld de, ROOM_OBJECT_STRUCT_SIZE
	jp ptr_to_new_sprite_object_loop


;-----------------------------------------------
; output:
; - z: we could find a new ptr
; - nz: no ptrs available
; - hl: ptr if one was available
ptr_to_new_sprite_object:
	ld hl, current_room__sprite_objects
	ld de, ROOM_OBJECT_STRUCT_SIZE
ptr_to_new_sprite_object_loop:
	ld a, (hl)
	cp #ff  ; empty spot
	ret z
	cp #fe  ; sentinel
	jr z, ptr_to_new_sprite_object_reached_sentinel
	add hl, de
	jp ptr_to_new_sprite_object_loop
ptr_to_new_sprite_object_reached_sentinel:
	or 1
	ret


;-----------------------------------------------
; input:
; - c, b: tile coordinates where to spawn
spawn_water_splash:	
	call ptr_to_new_sprite_object
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_WATER_SPLASH
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 8  ; state (frames left)
	ld hl, SFX_watersplash_soft
	jp play_SFX_with_high_priority


;-----------------------------------------------
; input:
; - c, b: tile coordinates of the block
spawn_pushing_block_dust:
	call ptr_to_new_sprite_object
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_BLOCK_DUST
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 8  ; state (frames left)
	ld hl, SFX_explosion
	jp play_SFX_with_high_priority


;-----------------------------------------------
; input:
; - c, b: tile coordinates of the dust
spawn_4tile_appart_dust:
	call ptr_to_new_sprite_object
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_4TILE_APPART_DUST
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 8  ; state (frames left)
	ld hl, SFX_explosion
	jp play_SFX_with_high_priority


;-----------------------------------------------
; input:
; - c, b: tile coordinates where to spawn
spawn_big_explosion:
	ld e, SPRITE_OBJECT_TYPE_BIG_EXPLOSION
	jr spawn_explosion_continue
spawn_explosion:
	ld e, SPRITE_OBJECT_TYPE_EXPLOSION
spawn_explosion_continue:
	push de
		call ptr_to_new_sprite_object
	pop de
	ret nz
	ld (hl), 0  ; ID
	inc hl
	ld (hl), e  ; type
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 8  ; state (frames left)
	ld hl, SFX_enemy_kill
	jp play_SFX_with_high_priority


;-----------------------------------------------
update_sprite_objects_player_bullets:
	ld a, (n_displayed_object_sprites_without_player_bullets)
	ld (n_displayed_object_sprites), a
	ld ix, current_room__player_bullets
update_sprite_objects_player_bullets_loop:
	ld a, (ix + ROOM_OBJECT_STRUCT_ID)
	cp #ff  ; empty spot
	ret z
	cp #fe  ; sentinel
	ret z
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	sub SPRITE_OBJECT_TYPE_PLAYER_BULLET_STONE
	jp z, update_sprite_objects_player_bullet_stone
	dec a
	jp z, update_sprite_objects_player_bullet_dart
	dec a
	jp z, update_sprite_objects_player_bullet_spear
	dec a
	jp z, update_sprite_objects_player_bullet_ray
update_sprite_objects_player_bullets_loop_next:
	ld de, ROOM_OBJECT_STRUCT_SIZE
	add ix, de
	jp update_sprite_objects_player_bullets_loop
update_sprite_objects_player_bullets_loop_next_after_deletion:
	jp update_sprite_objects_player_bullets_loop_next


;-----------------------------------------------
update_sprite_objects:
	xor a
	ld (n_displayed_object_sprites), a
	ld ix, current_room__sprite_objects
update_sprite_objects_loop:
	ld a, (ix + ROOM_OBJECT_STRUCT_ID)
	cp #ff  ; empty spot
	ret z
	cp #fe  ; sentinel
	ret z
	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp SPRITE_OBJECT_TYPE_WATER_SPLASH
	jr z, update_sprite_objects_water_splash
	cp SPRITE_OBJECT_TYPE_BLOCK_DUST
	jr z, update_sprite_objects_pushing_block_dust
	cp SPRITE_OBJECT_TYPE_4TILE_APPART_DUST
	jr z, update_sprite_objects_4tile_appart_dust
	cp SPRITE_OBJECT_TYPE_EXPLOSION
	jr z, update_sprite_objects_explosion
	cp SPRITE_OBJECT_TYPE_BIG_EXPLOSION
	jp z, update_sprite_objects_big_explosion
	cp SPRITE_OBJECT_TYPE_SHOPKEEPER
	jp z, update_sprite_objects_shopkeeper
	cp SPRITE_OBJECT_TYPE_LOST_VENDOR
	jp z, update_sprite_objects_lost_vendor
	cp SPRITE_OBJECT_TYPE_SHOPKEEPER2
	jp z, update_sprite_objects_shopkeeper2
	cp SPRITE_OBJECT_TYPE_BOSS_EXTRAS
	jp z, update_sprite_objects_boss_extras
update_sprite_objects_loop_next:
	ld de, ROOM_OBJECT_STRUCT_SIZE
	add ix, de
	jp update_sprite_objects_loop
update_sprite_objects_loop_next_after_deletion:
	jp update_sprite_objects_loop_next


; -----------------------------------------------
update_sprite_objects_water_splash:
	ld d, COLOR_WHITE
	ld e, 12
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame

update_sprite_objects_decrease_timer_and_delete_if_necessary:
	dec (ix + ROOM_OBJECT_STRUCT_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jp nz, update_sprite_objects_loop_next
update_sprite_objects_delete:
	call sprite_object_remove_object
	jp update_sprite_objects_loop_next_after_deletion


;-----------------------------------------------
update_sprite_objects_pushing_block_dust:
	ld d, COLOR_WHITE
	ld e, 16
	ld c, -5
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame

	ld d, COLOR_WHITE
	ld e, 20
	ld c, 4
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	jp update_sprite_objects_decrease_timer_and_delete_if_necessary


;-----------------------------------------------
update_sprite_objects_4tile_appart_dust:
	ld d, COLOR_WHITE
	ld e, 16
	ld c, -5
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame

	ld d, COLOR_WHITE
	ld e, 20
	ld c, 22
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	jp update_sprite_objects_decrease_timer_and_delete_if_necessary


;-----------------------------------------------
update_sprite_objects_explosion:
	ld d, COLOR_WHITE
	ld e, 76
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	jp update_sprite_objects_decrease_timer_and_delete_if_necessary


;-----------------------------------------------
update_sprite_objects_big_explosion:
	ld d, COLOR_WHITE
	ld e, 76
	ld c, 0
	inc (ix + ROOM_OBJECT_STRUCT_TILE_X)
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	dec (ix + ROOM_OBJECT_STRUCT_TILE_X)
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	inc (ix + ROOM_OBJECT_STRUCT_TILE_X)
	inc (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	dec (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	dec (ix + ROOM_OBJECT_STRUCT_TILE_X)
	dec (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jp update_sprite_objects_decrease_timer_and_delete_if_necessary


;-----------------------------------------------
update_sprite_objects_shopkeeper:
	inc (ix + ROOM_OBJECT_STRUCT_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #08
	add a, (FIRST_ENEMY_SPRITE_PATTERN + 0) * 4
	ld e, a 
	ld d, COLOR_DARK_YELLOW
	ld c, 0
	push af
		call get_sprite_object_sprite_coordinates
		call z, add_sprite_to_this_frame
	pop af
	add a, 4
	ld e, a
	ld d, COLOR_DARK_BLUE
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame

	ld a, (global_state__story)
	cp STORY_STATE__FOUND_CALENDAR
	jp z, update_sprite_objects_shopkeeper_got_letter
	cp STORY_STATE__FOUND_LOST_VENDOR
	jp nz, update_sprite_objects_loop_next
	ld a, (global_state__n_power_stones_in_calendar)
	cp 2
	jr nc, update_sprite_objects_shopkeeper_got_letter
	jp update_sprite_objects_loop_next
update_sprite_objects_shopkeeper_got_letter:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #04
	jp z, update_sprite_objects_loop_next
	; display an exclamation mark:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 6) * 4 
	ld d, COLOR_DARK_YELLOW
	ld c, 0
	call get_sprite_object_sprite_coordinates
	jp nz, update_sprite_objects_loop_next
	ld a, -16
	add a, b
	ld b, a
	call add_sprite_to_this_frame
	jp update_sprite_objects_loop_next


;-----------------------------------------------
update_sprite_objects_lost_vendor:
	ld a, (global_state__story)
	cp STORY_STATE__FOUND_LOST_VENDOR
	jp z, update_sprite_objects_delete
	inc (ix + ROOM_OBJECT_STRUCT_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #08
	add a, (FIRST_ENEMY_SPRITE_PATTERN + 35) * 4
update_sprite_objects_shopkeeper2_entry_point:
	ld e, a 
	ld d, COLOR_DARK_YELLOW
	ld c, 0
	push af
		call get_sprite_object_sprite_coordinates
		call z, add_sprite_to_this_frame
	pop af
	add a, 4
	ld e, a
	ld d, COLOR_DARK_RED
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	jp update_sprite_objects_loop_next


;-----------------------------------------------
update_sprite_objects_shopkeeper2:
	inc (ix + ROOM_OBJECT_STRUCT_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #08
	add a, (FIRST_ENEMY_SPRITE_PATTERN + 7) * 4
	jr update_sprite_objects_shopkeeper2_entry_point


;-----------------------------------------------
update_sprite_objects_boss_extras:
	ld a, (boss__active)
	or a
	jp z, update_sprite_objects_loop_next  ; boss is not active yet
	ld hl, (boss__hp)
	ld a, h
	or l
	jp z, update_sprite_objects_loop_next  ; boss is dead
	ld a, (current_area__id)
	cp 2  ; inverted pyramid
	jr z, update_sprite_objects_boss_extras_boss_2
	; ...

	jp update_sprite_objects_loop_next

update_sprite_objects_boss_extras_boss_2:
	; boss 2, camazotz
	ld a, (boss__behavior)
	dec a
	jr z, update_sprite_objects_boss_extras_boss_2_walking
	dec a
	jr z, update_sprite_objects_boss_extras_boss_2_flying
	jp update_sprite_objects_loop_next
update_sprite_objects_boss_extras_boss_2_walking:
	; boss 2, camazotz, walking
	ld a, (boss__2_direction)
	or a
	jr z, update_sprite_objects_boss_extras_boss_2_walking_left
	; right:
	ld a, (boss__x)
	ld hl, room_scroll_x
	sub (hl)
	add a, 8
	cp 32
	jp nc, update_sprite_objects_loop_next
	add a, a
	add a, a
	add a, a
	add a, 7
	ld c, a
	jr update_sprite_objects_boss_extras_boss_2_walking_continue
update_sprite_objects_boss_extras_boss_2_walking_left:
	; left:
	ld a, (boss__x)
	ld hl, room_scroll_x
	sub (hl)
	add a, 3
	cp 32
	jp nc, update_sprite_objects_loop_next
	add a, a
	add a, a
	add a, a
	add a, 3
	ld c, a

update_sprite_objects_boss_extras_boss_2_walking_continue:
	ld a, (boss__y)
	ld hl, room_scroll_y
	sub (hl)
	add a, a
	add a, a
	add a, a
	add a, 24 + 4
	ld b, a

update_sprite_objects_boss_extras_boss_2_walking_bc_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 5) * 4
	ld a, (interrupt_cycle)
	and #08
	jr nz, update_sprite_objects_boss_extras_boss_2_walking_continue2
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 6) * 4
update_sprite_objects_boss_extras_boss_2_walking_continue2:
	ld d, COLOR_RED
	call add_sprite_to_this_frame
	jp update_sprite_objects_loop_next

update_sprite_objects_boss_extras_boss_2_flying:
	ld a, (boss__state)
	or a
	jr z, update_sprite_objects_boss_extras_boss_2_walking  ; 0
	dec a
	jr z, update_sprite_objects_boss_extras_boss_2_flying_fakeoff  ; 1
	dec a
	jr z, update_sprite_objects_boss_extras_boss_2_flying_air  ; 2
	dec a
	jr z, update_sprite_objects_boss_extras_boss_2_flying_air  ; 3
	dec a
	jr z, update_sprite_objects_boss_extras_boss_2_flying_air  ; 4
	dec a
	jr z, update_sprite_objects_boss_extras_boss_2_flying_fakeoff  ; 5
update_sprite_objects_boss_extras_boss_2_flying_air:
	; flying:
	ld a, (boss__x)
	ld hl, room_scroll_x
	sub (hl)
	add a, a
	add a, a
	add a, a
	add a, 6*8 + 4
	ld c, a
	ld a, (boss__y)
	ld hl, room_scroll_y
	sub (hl)
	add a, a
	add a, a
	add a, a
	add a, 16 + 7
	; 0: +16, 1,3: +8, 2: +0
	ld b, a
	ld a, (boss__state_timer)
	rrca
	rrca
	and #03
	cp 3
	jr nz, update_sprite_objects_boss_extras_boss_2_flying_continue
	ld a, 1
update_sprite_objects_boss_extras_boss_2_flying_continue:
	add a, a
	add a, a
	add a, a
	neg
	add a, 16
	add a, b
	ld b, a
update_sprite_objects_boss_extras_boss_2_flying_bc_set:
	ld e, (FIRST_ENEMY_SPRITE_PATTERN + 10) * 4
	ld d, COLOR_RED
	call add_sprite_to_this_frame
	jp update_sprite_objects_loop_next
update_sprite_objects_boss_extras_boss_2_flying_fakeoff:
	ld a, (boss__2_direction)
	or a
	jr nz, update_sprite_objects_boss_extras_boss_2_flying_fakeoff_right
	ld a, (boss__x)
	ld hl, room_scroll_x
	sub (hl)
	add a, a
	add a, a
	add a, a
	add a, 4
update_sprite_objects_boss_extras_boss_2_flying_fakeoff_right_continue:
	ld c, a
	ld a, (boss__y)
	ld hl, room_scroll_y
	sub (hl)
	add a, a
	add a, a
	add a, a
	add a, 32 + 7
	ld b, a
	jr update_sprite_objects_boss_extras_boss_2_flying_bc_set
update_sprite_objects_boss_extras_boss_2_flying_fakeoff_right:
	ld a, (boss__x)
	ld hl, room_scroll_x
	sub (hl)
	add a, a
	add a, a
	add a, a
	add a, 7*8 + 4
	jr update_sprite_objects_boss_extras_boss_2_flying_fakeoff_right_continue


;-----------------------------------------------
; input:
; - ix: ptr to the bullet sprite object
; - iyh: bullet damage
; output:
; - z: hit something
; - nz: did not hit anything
update_sprite_objects_player_bullet_small_hitbox:
	ld hl, #0101
update_sprite_objects_player_bullet_hitbox:
	ld e, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld d, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	cp 4
	jr c, update_sprite_objects_player_bullet_hitbox_continue
	inc d
update_sprite_objects_player_bullet_hitbox_continue:
	ld a, l
	add a, e
	ld l, a
	ld a, d
	add a, h
	ld h, a
	ld a, (ix + ROOM_OBJECT_STRUCT_HIT_ID)
	ld iyl, a
	jp player_weapon_hitbox_check


;-----------------------------------------------
update_sprite_objects_player_bullet_stone:
update_sprite_objects_player_bullet_dart:
update_sprite_objects_player_bullet_spear:
update_sprite_objects_player_bullet_ray:
	; movement:
	ld c, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
	ld b, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	call update_sprite_objects_move_object

	; stop if collision (or out of room)
	ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld a, c
	cp #ff
	jp z, update_sprite_objects_player_bullet_delete
	ld a, (current_room__width)
	cp c
	jp z, update_sprite_objects_player_bullet_delete
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld a, b
	cp #ff
	jp z, update_sprite_objects_player_bullet_delete
	ld a, (current_room__height)
	cp b
	jp z, update_sprite_objects_player_bullet_delete
	call get_room_tile_type
	cp 2  ; wall
	jp z, update_sprite_objects_player_bullet_delete

	ld a, (ix + ROOM_OBJECT_STRUCT_TYPE)
	cp SPRITE_OBJECT_TYPE_PLAYER_BULLET_STONE
	jr z, update_sprite_objects_player_bullet_stone_parabolla
	cp SPRITE_OBJECT_TYPE_PLAYER_BULLET_SPEAR
	jp z, update_sprite_objects_player_bullet_spear_parabolla
	cp SPRITE_OBJECT_TYPE_PLAYER_BULLET_DART
	jr z, update_sprite_objects_player_bullet_straight_dart
update_sprite_objects_player_bullet_straight_ray:
	ld iyh, RAYGUN_DAMAGE
	call update_sprite_objects_player_bullet_small_hitbox

	ld d, COLOR_GREEN
	ld c, 0
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	or a
	jr z, update_sprite_objects_player_bullet_straight_ray_fw
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
	or a
	jr z, update_sprite_objects_player_bullet_straight_ray_up
	jp p, update_sprite_objects_player_bullet_straight_ray_up_right
	ld e, 72
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_straight_ray_up_right:
	ld e, 68
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_straight_ray_up:
	ld e, 64
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_straight_ray_fw:
	ld e, 60
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set

update_sprite_objects_player_bullet_straight_dart:
	ld iyh, DART_DAMAGE
	call update_sprite_objects_player_bullet_small_hitbox
	jp z, update_sprite_objects_player_bullet_delete

	ld d, COLOR_YELLOW
	ld c, 0
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	or a
	jr z, update_sprite_objects_player_bullet_straight_dart_fw
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
	or a
	jr z, update_sprite_objects_player_bullet_straight_dart_up
	jp p, update_sprite_objects_player_bullet_straight_dart_up_right
	ld e, 40
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_straight_dart_up_right:
	ld e, 36
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_straight_dart_up:
	ld e, 32
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_straight_dart_fw:
	ld e, 28
update_sprite_objects_player_bullet_straight_dart_sprite_set:
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	jp update_sprite_objects_player_bullet_decrease_timer_and_delete_if_necessary

update_sprite_objects_player_bullet_stone_parabolla:
	ld iyh, STONE_DAMAGE
	call update_sprite_objects_player_bullet_small_hitbox
	jp z, update_sprite_objects_player_bullet_delete

	; parabolic movement:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #03
	jr nz, update_sprite_objects_player_bullet_stone_continue
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	cp 4  ; max vertical speed
	jr z, update_sprite_objects_player_bullet_stone_continue
	inc (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
update_sprite_objects_player_bullet_stone_continue:
	ld d, COLOR_GREY
	ld c, 0
	ld e, 24
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame
	jp update_sprite_objects_player_bullet_decrease_timer_and_delete_if_necessary

update_sprite_objects_player_bullet_spear_parabolla:
	; parabolic movement:
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	and #07
	jr nz, update_sprite_objects_player_bullet_spear_continue
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	cp 4  ; max vertical speed
	jr z, update_sprite_objects_player_bullet_spear_continue
	inc (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
update_sprite_objects_player_bullet_spear_continue:
	ld d, COLOR_LIGHT_RED
	ld c, 0
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_X)
	or a
	jr z, update_sprite_objects_player_bullet_spear_vertical
	ld a, (ix + ROOM_OBJECT_STRUCT_SPEED_Y)
	inc a
	jr z, update_sprite_objects_player_bullet_spear_horizontal
	dec a
	jr z, update_sprite_objects_player_bullet_spear_horizontal
	dec a
	jr z, update_sprite_objects_player_bullet_spear_horizontal
	inc a
	xor (ix + ROOM_OBJECT_STRUCT_SPEED_X)
	jp m, update_sprite_objects_player_bullet_spear_horizontal_upright
	ld hl, #0202
	ld e, 56  ; \
	jr update_sprite_objects_player_bullet_straight_spear_sprite_set
update_sprite_objects_player_bullet_spear_horizontal_upright:
	ld hl, #0202
	ld e, 52  ; /
	jr update_sprite_objects_player_bullet_straight_spear_sprite_set
update_sprite_objects_player_bullet_spear_horizontal:
	ld hl, #0102
	ld e, 44  ; -
	jr update_sprite_objects_player_bullet_straight_spear_sprite_set
update_sprite_objects_player_bullet_spear_vertical:
	ld hl, #0201
	ld e, 48  ; |
update_sprite_objects_player_bullet_straight_spear_sprite_set:
	push hl
		call get_sprite_object_sprite_coordinates
		call z, add_sprite_to_this_frame
	pop hl
	ld iyh, SPEAR_DAMAGE
	call update_sprite_objects_player_bullet_hitbox
	jp z, update_sprite_objects_player_bullet_delete  ; hit something, delete the bullet
	jp update_sprite_objects_player_bullet_decrease_timer_and_delete_if_necessary


update_sprite_objects_player_bullet_decrease_timer_and_delete_if_necessary:
	dec (ix + ROOM_OBJECT_STRUCT_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jp nz, update_sprite_objects_player_bullets_loop_next
update_sprite_objects_player_bullet_delete:
	call sprite_object_remove_object_player_bullet
	jp update_sprite_objects_player_bullets_loop_next_after_deletion


;-----------------------------------------------
; input:
; - ix: object ptr
; - c: amount to move in x
; - y: amount to move in y
update_sprite_objects_move_object:
	ld a, c
	or a
	jp p, update_sprite_objects_move_object_x_positive
	; x negative:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	add a, c
	jp p, update_sprite_objects_move_object_no_overflow_x
	and #07
	dec (ix + ROOM_OBJECT_STRUCT_TILE_X)
	jr update_sprite_objects_move_object_no_overflow_x
update_sprite_objects_move_object_x_positive:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	add a, c
	cp 8
	jr c, update_sprite_objects_move_object_no_overflow_x
	and #07
	inc (ix + ROOM_OBJECT_STRUCT_TILE_X)
update_sprite_objects_move_object_no_overflow_x:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_X), a

	ld a, b
	or a
	jp p, update_sprite_objects_move_object_y_positive
	; y negative:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	add a, b
	jp p, update_sprite_objects_move_object_no_overflow_y
	and #07
	dec (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	jr update_sprite_objects_move_object_no_overflow_y
update_sprite_objects_move_object_y_positive:
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	add a, b
	cp 8
	jr c, update_sprite_objects_move_object_no_overflow_y
	and #07
	inc (ix + ROOM_OBJECT_STRUCT_TILE_Y)
update_sprite_objects_move_object_no_overflow_y:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), a
	ret


;-----------------------------------------------
; input:
; - ix: object ptr
; - c: x offset
; - d: sprite color
; output:
; - c, b: sprite x, y
; - d: updated sprite color with early clock bit
; - z: render
; - nz: out of bounds
get_sprite_object_sprite_coordinates:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld hl, room_scroll_y
	sub (hl)
	cp #ff
	jr z, get_sprite_object_sprite_coordinates_continue
	cp 24
	jr c, get_sprite_object_sprite_coordinates_continue
	; out of bounds:
	or 1
	ret
get_sprite_object_sprite_coordinates_continue:
	add a, a
	add a, a
	add a, a
	add a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	dec a  ; sprites y in the VDP is off by 1 pixel
	ld b, a
	ld a, (config_hud_type)
	cp 2  ; full hud
	jr nz, get_sprite_object_sprite_coordinates_no_full_hud
	ld a, 16  ; move sprites 16 pixels down
	add a, b
	ld b, a
get_sprite_object_sprite_coordinates_no_full_hud:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld hl, room_scroll_x
	sub (hl)
	cp #ff
	jr z, get_sprite_object_sprite_coordinates_continue2_early_clock
	cp 32
	jr c, get_sprite_object_sprite_coordinates_continue2
	; out of bounds:
	or 1
	ret
get_sprite_object_sprite_coordinates_continue2:
	add a, a
	add a, a
	add a, a
	add a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	add a, c
	ld c, a
	xor a  ; z
	ret

get_sprite_object_sprite_coordinates_continue2_early_clock:
	add a, a
	add a, a
	add a, a
	add a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	add a, c
	add a, 32
	ld c, a
	set 7, d
	xor a  ; z
	ret


;-----------------------------------------------
; input:
; - c, b: x, y
; - e: sprite number
; - d: attribute + early clock
add_sprite_to_this_frame:
	ld a, (n_displayed_object_sprites)
	cp 32 - FIRST_OBJECT_SPRITE
	ret z  ; do not add more sprites than we can display
	add a, a
	add a, a
	ld hl, sprite_attribute_table + FIRST_OBJECT_SPRITE * 4
	ADD_HL_A
	ld (hl), b
	inc hl
	ld (hl), c
	inc hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, n_displayed_object_sprites
	inc (hl)
	ret



;-----------------------------------------------
; input:
; - ix: ptr to the object to remove
sprite_object_remove_object:
	; shift all the objects one position left:
	ld (ix + ROOM_OBJECT_STRUCT_ID), #ff  ; clear the current object ID (only needed if this is the last object, but just in case).
	ld d, ixh
	ld e, ixl
	ld h, d
	ld l, e
	ld bc, ROOM_OBJECT_STRUCT_SIZE
	add hl, bc
	push hl
	push de
		ld hl, current_room__sprite_objects_sentinel - ROOM_OBJECT_STRUCT_SIZE
		or a
		sbc hl, de  ; hl = amount to copy
		ld b, h
		ld c, l
	pop de
	pop hl
	ld a, c
	or b
	ret z  ; nothing to copy
	ldir  ; shift all the objects left
	ret


;-----------------------------------------------
; input:
; - ix: ptr to the object to remove
sprite_object_remove_object_player_bullet:
	; shift all the objects one position left:
	ld (ix + ROOM_OBJECT_STRUCT_ID), #ff  ; clear the current object type (only needed if this is the last object, but just in case).
	ld d, ixh
	ld e, ixl
	ld h, d
	ld l, e
	ld bc, ROOM_OBJECT_STRUCT_SIZE
	add hl, bc
	push hl
	push de
		ld hl, current_room__player_bullets_sentinel - ROOM_OBJECT_STRUCT_SIZE
		or a
		sbc hl, de  ; hl = amount to copy
		ld b, h
		ld c, l
	pop de
	pop hl
	ld a, c
	or b
	ret z  ; nothing to copy
	ldir  ; shift all the objects left
	ret


;-----------------------------------------------
; input:
; - ix: ptr to the object to remove
sprite_object_remove_object_enemy:
	; shift all the objects one position left:
	ld (ix + ROOM_OBJECT_STRUCT_ID), #ff  ; clear the current object type (only needed if this is the last object, but just in case).
	ld d, ixh
	ld e, ixl
	ld h, d
	ld l, e
	ld bc, ROOM_OBJECT_STRUCT_SIZE
	add hl, bc
	push hl
	push de
		ld hl, current_room__sprite_enemies_sentinel - ROOM_OBJECT_STRUCT_SIZE
		or a
		sbc hl, de  ; hl = amount to copy
		ld b, h
		ld c, l
	pop de
	pop hl
	ld a, c
	or b
	ret z  ; nothing to copy
	ldir  ; shift all the objects left
	ret
