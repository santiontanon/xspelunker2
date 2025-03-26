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
ptr_to_new_sprite_object:
	ld hl, current_room__objects
	ld de, ROOM_OBJECT_STRUCT_SIZE
ptr_to_new_sprite_object_loop:
	ld a, (hl)
	or a
	ret z
	inc a
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
update_sprite_objects_player_bullets:
	ld a, (n_displayed_object_sprites_without_player_bullets)
	ld (n_displayed_object_sprites), a
	ld ix, current_room__player_bullets
update_sprite_objects_player_bullets_loop:
	ld a, (ix)
	or a
	ret z
	cp #ff  ; sentinel
	ret z
	sub SPRITE_OBJECT_TYPE_PLAYER_BULLET_STONE
	jr z, update_sprite_objects_player_bullet_stone
	dec a
	jr z, update_sprite_objects_player_bullet_dart
	dec a
	jr z, update_sprite_objects_player_bullet_spear
	dec a
	jr z, update_sprite_objects_player_bullet_ray
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
	ld ix, current_room__objects
update_sprite_objects_loop:
	ld a, (ix)
	or a
	ret z
	cp #ff  ; sentinel
	ret z
	dec a
	jr z, update_sprite_objects_water_splash
	dec a
	jr z, update_sprite_objects_pushing_block_dust
; 	dec a
; 	jr z, update_sprite_objects_player_bullet_stone
; 	dec a
; 	jr z, update_sprite_objects_player_bullet_dart
; 	dec a
; 	jr z, update_sprite_objects_player_bullet_spear
; 	dec a
; 	jr z, update_sprite_objects_player_bullet_ray
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
	jr z, update_sprite_objects_player_bullet_spear_parabolla
	cp SPRITE_OBJECT_TYPE_PLAYER_BULLET_DART
	jr z, update_sprite_objects_player_bullet_straight_dart
update_sprite_objects_player_bullet_straight_ray:
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
	ld d, COLOR_GREY
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
	ld e, 56  ; \
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_spear_horizontal_upright:
	ld e, 52  ; /
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_spear_horizontal:
	ld e, 44  ; -
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set
update_sprite_objects_player_bullet_spear_vertical:
	ld e, 48  ; |
	jr update_sprite_objects_player_bullet_straight_dart_sprite_set

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
sprite_object_remove_object:
	; shift all the objects one position left:
	ld (ix), 0  ; clear the current object type (only needed if this is the last object, but just in case).
	ld d, ixh
	ld e, ixl
	ld h, d
	ld l, e
	ld bc, ROOM_OBJECT_STRUCT_SIZE
	add hl, bc
	push hl
	push de
		ld hl, current_room__objects_sentinel - ROOM_OBJECT_STRUCT_SIZE
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


sprite_object_remove_object_player_bullet:
	; shift all the objects one position left:
	ld (ix), 0  ; clear the current object type (only needed if this is the last object, but just in case).
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

