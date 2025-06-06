


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
	cp ENEMY_SNAKE_DASHER
	jr z, update_enemy_snake_dasher
update_sprite_enemies_loop_next:
	ld de, ROOM_OBJECT_STRUCT_SIZE
	add ix, de
	jp update_sprite_enemies_loop
update_sprite_enemies_loop_next_after_deletion:
	jp update_sprite_enemies_loop_next


;-----------------------------------------------
update_enemy_snake_dasher:
	; ...

	ld d, COLOR_DARK_GREEN
	ld e, FIRST_ENEMY_SPRITE_PATTERN * 4
	ld c, 0
	call get_sprite_object_sprite_coordinates
	call z, add_sprite_to_this_frame	
	jr update_sprite_enemies_loop_next

