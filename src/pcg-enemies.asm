	include "pcg-enemies-easy.asm"  ; pcg_enemy_generation_table_easy
	include "pcg-enemies-normal.asm"  ; pcg_enemy_generation_table_normal
	include "pcg-enemies-hard.asm"  ; pcg_enemy_generation_table_hard
	include "pcg-enemies-hardest.asm"  ; pcg_enemy_generation_table_hardest


;-----------------------------------------------
; If you have already killed an enemy in a room, make sure it remains killed if you re-enter if
; shortly after. The logic is:
; - We store which enemies have been killed for the last k (k = ENEMY_RESPAWN_TABLE_SIZE = 4) rooms
;   you visited.
; - After enemy spawn, we check that table to see if we need to remove some enemies
; - Every time you leave a room, that table is updated with the information from the
;   room you are just leaving.
; - Hence, you might have to walk change rooms k times before coming back to a room for enemies to
;   respawn.
pcg_generate_room__enemy_respawn_logic:
	; Store the list of enemy IDs we just spawned:
	ld de, current_room__initial_enemy_ids
	ld hl, current_room__sprite_enemies
	ld bc, ROOM_OBJECT_STRUCT_SIZE
pcg_generate_room__enemy_respawn_logic_loop1:
	ld a, (hl)
	add hl, bc
	cp #ff  ; sentinel
	jr z, pcg_generate_room__enemy_respawn_logic_loop1_done
	ld (de), a
	inc de
	jr pcg_generate_room__enemy_respawn_logic_loop1
pcg_generate_room__enemy_respawn_logic_loop1_done:

	; potential tile enemy:
	ld ix, current_room__tile_objects - ROOM_TILE_OBJECT_STRUCT_SIZE
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
pcg_generate_room__enemy_respawn_logic_loop2:
	add ix, bc
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	cp #ff
	jr z, pcg_generate_room__enemy_respawn_logic_loop2_done
	cp #fe  ; sentinel
	jr z, pcg_generate_room__enemy_respawn_logic_loop2_done
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp FIRST_TILE_ENEMY_TAG
	jr c, pcg_generate_room__enemy_respawn_logic_loop2
	; found the tile enemy (since there can only be one, we are done)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	ld (de), a
	inc de
pcg_generate_room__enemy_respawn_logic_loop2_done:

	; See if we have an entry for this room in the "enemy_respawn_table":
	ld ix, enemy_respawn_table
	ld hl, 0
	ld b, ENEMY_RESPAWN_TABLE_SIZE
pcg_generate_room__enemy_respawn_logic_loop3:
	ld a, (current_area__id)
	cp (ix + 1)
	jr nz, pcg_generate_room__enemy_respawn_logic_loop3_next
	ld a, (current_room__id)
	cp (ix + 2)
	jr nz, pcg_generate_room__enemy_respawn_logic_loop3_next
	; found!
	push ix
	pop hl
	jr pcg_generate_room__enemy_respawn_logic_loop3_done
pcg_generate_room__enemy_respawn_logic_loop3_next:
	ld de, 1 + 1 + 1 + MAX_ROOM_SPRITE_ENEMIES + 1 + 1
	add ix, de
	djnz pcg_generate_room__enemy_respawn_logic_loop3
pcg_generate_room__enemy_respawn_logic_loop3_done:
	ld a, h
	or l
	ret z  ; we did not find an entry, so, nothing to be done

	; delete all the enemies that were already killed:
	inc hl  ; skip time
	inc hl  ; skip area id
	inc hl  ; skip room id
pcg_generate_room__enemy_respawn_logic_loop4:
	ld a, (hl)
	cp #ff
	ret z  ; we are done!
	; delete the enemy with id "a":
	ld c, a
	call pcg_generate_room__enemy_respawn_logic__find_enemy_by_id
	jr nz, pcg_generate_room__enemy_respawn_logic_loop4_not_sprite_enemy
	push hl
		; delete sprite enemy in "ix":
		call sprite_object_remove_object_enemy
	pop hl
	jr pcg_generate_room__enemy_respawn_logic_loop4_next
pcg_generate_room__enemy_respawn_logic_loop4_not_sprite_enemy:
	call pcg_generate_room__enemy_respawn_logic__find_tile_enemy_by_id
	jr nz, pcg_generate_room__enemy_respawn_logic_loop4_next  ; this should never happen, but just in case
	push hl	
		; delete tile enemy in "ix":
		push ix
			ld hl, room_undraw_tile_objects
			ld c, TILES_PAGE
			call call_hl_in_page_c_8000
		pop ix

		ld hl, delete_tile_object_in_ix
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000

		ld hl, room_render_tile_objects
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop hl
pcg_generate_room__enemy_respawn_logic_loop4_next:
	inc hl
	jr pcg_generate_room__enemy_respawn_logic_loop4


;-----------------------------------------------
; This is called when leaving a room, just before calling "pcg_generate_room".
pcg_generate_room__enemy_respawn_logic_on_exit_room:
	; Check if we are exiting the calendar room, and we had killed all the aliens:
	ld a, (current_room__id)
	cp CALENDAR_ROOM_ID
	jr nz, pcg_generate_room__enemy_respawn_logic_on_exit_room_not_calendar
	ld a, (current_room__sprite_enemies)
	cp #ff
	jr nz, pcg_generate_room__enemy_respawn_logic_on_exit_room_not_calendar
	; player killed all the aliens, increment the alien counter:
	ld a, (global_state__n_alien_confrontations)
	cp 2
	jr z, pcg_generate_room__enemy_respawn_logic_on_exit_room_not_calendar
	inc a
	ld (global_state__n_alien_confrontations), a
pcg_generate_room__enemy_respawn_logic_on_exit_room_not_calendar:
	; find a spot in enemy_respawn_table:
	ld ix, enemy_respawn_table
	ld hl, enemy_respawn_table  ; current candidate
	ld c, (ix)  ; time of the oldest candidate
	ld b, ENEMY_RESPAWN_TABLE_SIZE
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1:
	ld a, (current_area__id)
	cp (ix + 1)
	jr nz, pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1_no_match
	ld a, (current_room__id)
	cp (ix + 2)
	jr nz, pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1_no_match
	; we had this room already in the table, use it!
	push ix
	pop hl
	jr pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1_done
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1_no_match:
	ld a, (ix)
	cp c
	jr c, pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1_not_better
	push ix
	pop hl
	ld c, a
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1_not_better:
	ld de, 1 + 1 + 1 + MAX_ROOM_SPRITE_ENEMIES + 1 + 1
	add ix, de
	djnz pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop1_done:

	; here:
	; - hl: ptr to the entry in the enemy_respawn_table to use
	ld (hl), 0  ; reset time
	inc hl
	ld a, (current_area__id)
	ld (hl), a
	inc hl
	ld a, (current_room__id)
	ld (hl), a
	inc hl

	; find which initial enemy IDs are dead, and store them in enemy_respawn_table:
	ld de, current_room__initial_enemy_ids
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop2:
	ld a, (de)
	cp #ff  ; sentinel
	jr z, pcg_generate_room__enemy_respawn_logic_on_exit_room_loop2_done
	; check if there is an enemy with ID 'a', if there isn't, it means it's dead,
	; and we need to add it to 'enemy_respawn_table' (in 'hl'):
	ld c, a
	push de
		call pcg_generate_room__enemy_respawn_logic__find_enemy_by_id
	pop de
	jr z, pcg_generate_room__enemy_respawn_logic_on_exit_room_loop2_next
	push de
		call pcg_generate_room__enemy_respawn_logic__find_tile_enemy_by_id
	pop de
	jr z, pcg_generate_room__enemy_respawn_logic_on_exit_room_loop2_next
	ld (hl), c
	inc hl
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop2_next:
	inc de
	jr pcg_generate_room__enemy_respawn_logic_on_exit_room_loop2
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop2_done:
	ld (hl), #ff  ; mark the end

	; increment the times of all the entries in the table
	ld hl, enemy_respawn_table  ; current candidate
	ld b, ENEMY_RESPAWN_TABLE_SIZE
	ld de, 1 + 1 + 1 + MAX_ROOM_SPRITE_ENEMIES + 1 + 1
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop3:
	ld a, (hl)
	cp #ff
	jr z, pcg_generate_room__enemy_respawn_logic_on_exit_room_loop3_next
	inc (hl)
pcg_generate_room__enemy_respawn_logic_on_exit_room_loop3_next:
	add hl, de
	djnz pcg_generate_room__enemy_respawn_logic_on_exit_room_loop3
	ret


;-----------------------------------------------
; input:
; - c: enemy id to search for
; output:
; - z: found (and "ix" is the pointer)
; - nz: not found
pcg_generate_room__enemy_respawn_logic__find_enemy_by_id:
	ld ix, current_room__sprite_enemies
	ld de, ROOM_OBJECT_STRUCT_SIZE
pcg_generate_room__enemy_respawn_logic__find_enemy_by_id_loop:
	ld a, (ix)
	cp c
	ret z
	cp #ff
	jr z, pcg_generate_room__enemy_respawn_logic__find_enemy_by_id_not_found
	cp #fe
	jr z, pcg_generate_room__enemy_respawn_logic__find_enemy_by_id_not_found
	add ix, de
	jr pcg_generate_room__enemy_respawn_logic__find_enemy_by_id_loop
pcg_generate_room__enemy_respawn_logic__find_enemy_by_id_not_found:
	or 1
	ret


;-----------------------------------------------
; input:
; - c: enemy id to search for
; output:
; - z: found (and "ix" is the pointer)
; - nz: not found
pcg_generate_room__enemy_respawn_logic__find_tile_enemy_by_id:
	ld ix, current_room__tile_objects
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
pcg_generate_room__enemy_respawn_logic__find_tile_enemy_by_id_loop:
	ld a, (ix)
	cp c
	ret z
	cp #ff
	jr z, pcg_generate_room__enemy_respawn_logic__find_tile_enemy_by_id_not_found
	cp #fe
	jr z, pcg_generate_room__enemy_respawn_logic__find_tile_enemy_by_id_not_found
	add ix, de
	jr pcg_generate_room__enemy_respawn_logic__find_tile_enemy_by_id_loop
pcg_generate_room__enemy_respawn_logic__find_tile_enemy_by_id_not_found:
	or 1
	ret


;-----------------------------------------------
pcg_generate_room__spawn_enemies:
	; this is already initialized in 'pcg_generate_room_reset_state'
; 	ld a, (current_area__id)
; 	cp 3
; 	jr nz, pcg_generate_room__spawn_enemies_continue
; 	ld a, (current_area__id)
; 	cp CALENDAR_ROOM_ID
; 	ret z  ; calendar room enemy spawning is handled separately
; pcg_generate_room__spawn_enemies_continue:
; 	xor a
; 	ld (tmp_enemy_pcg_tile_enemy_workmemory_usage), a
; 	ld (tmp_enemy_pcg_tile_enemy_spawned_type), a
; 	ld a, #7f  ; first enemy ID (enemy IDs are only used to track which one was already killed, for respawn)
; 	ld (tmp_enemy_pcg_next_enemy_id), a

	ld a, (current_world__difficulty)
	ld hl, pcg_enemy_generation_table_easy
	or a
	jr z, pcg_generate_room__spawn_enemies_difficulty_set
	ld hl, pcg_enemy_generation_table_normal
	dec a
	jr z, pcg_generate_room__spawn_enemies_difficulty_set
	ld hl, pcg_enemy_generation_table_hard
	dec a
	jr z, pcg_generate_room__spawn_enemies_difficulty_set
	ld hl, pcg_enemy_generation_table_hardest
pcg_generate_room__spawn_enemies_difficulty_set:
	ld a, (current_area__id)
	add a, a
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl  ; hl = ptr to the enemy specs of this area

	; determine the area of the current room:
	ld a, (current_room__width)
	rrca
	rrca
	rrca
	rrca
	rrca
	and #07  ; room width in screens
	ld b, a  ; current number of screens
	ld c, a
	ld a, (current_room__height)
pcg_generate_room__spawn_enemies_loop1:
	sub 24
	jr z, pcg_generate_room__spawn_enemies_loop1_done
	push af
		ld a, b
		add a, c
		ld b, a
	pop af
	jr pcg_generate_room__spawn_enemies_loop1
pcg_generate_room__spawn_enemies_loop1_done:

	; b = number of screen
	push bc
		ld c, (hl)   ; number of enemies per screen
		xor a   ; number of enemies in this room
pcg_generate_room__spawn_enemies_loop2:
		add a, c
		djnz pcg_generate_room__spawn_enemies_loop2

		push hl
		push af
			call pcg__find_enemy_spawn_locations
		pop af
		pop hl

		; here 'a' has the target number of enemies we want to spawn:
		inc hl
		push hl
			ld c, (hl)  ; number of different tile-based enemies
			ld b, 0
			inc hl
			add hl, bc
			add hl, bc  ; we skip the tile-based enemy info, and
						; point to the number of options for sprite enemies.
pcg_generate_room__spawn_enemies_loop3:
			push af
			push hl
				; spawn enemy:
				call pcg_generate_room__spawn_one_enemy
			pop hl
			pop af
			dec a
			jr nz, pcg_generate_room__spawn_enemies_loop3
		pop hl
	pop bc  ; b = number of screens (we will use this as the target number of tile enemies)
pcg_generate_room__spawn_tile_enemies_outer_loop:
	push bc
	push hl
		; chance of spawning a tile-based enemy:
		ld b, (hl)  ; number of different tile-based enemy types to choose from
		ld a, b
		or a
		jr z, pcg_generate_room__spawn_tile_enemies_loop_done
		inc hl
		call random_a
pcg_generate_room__spawn_tile_enemies_loop:
		ld c, (hl)  ; potential enemy type
		inc hl
		cp (hl)  ; chance
		jr nc, pcg_generate_room__spawn_tile_enemies_loop_next
		call pcg_generate_room__spawn_tile_enemies_loop_found
		jr pcg_generate_room__spawn_tile_enemies_loop_done
pcg_generate_room__spawn_tile_enemies_loop_next:
		inc hl
		djnz pcg_generate_room__spawn_tile_enemies_loop
pcg_generate_room__spawn_tile_enemies_loop_done:
	pop hl
	pop bc
	djnz pcg_generate_room__spawn_tile_enemies_outer_loop
	ret

pcg_generate_room__spawn_tile_enemies_loop_found:
	ld a, c
	cp TAG_ENEMY_CARNIVORE_PLANT
	jp z, pcg_generate_room__spawn_carnivore_plant
	cp TAG_ENEMY_BEE_HIVE
	jp z, pcg_generate_room__spawn_bee_hive
	cp TAG_ENEMY_ANT_COLONY
	jp z, pcg_generate_room__spawn_ant_colony
	cp TAG_ENEMY_ANT_COLONY2
	jp z, pcg_generate_room__spawn_ant_colony2
	cp TAG_ENEMY_IMP_GENERATOR
	jp z, pcg_generate_room__spawn_imp_generator
	cp TAG_ENEMY_IMP_GENERATOR2
	jp z, pcg_generate_room__spawn_imp_generator2
	cp TAG_ENEMY_FIREBALL_GENERATOR
	jp z, pcg_generate_room__spawn_fireball_generator
; 	cp TAG_ENEMY_LAVA_GENERATOR  ; these are spawned elsewhere (like pushable-blocks)
; 	jp z, pcg_generate_room__spawn_lava_generator
	cp TAG_ENEMY_STONE_OWL
	jp z, pcg_generate_room__spawn_stone_owl
; 	cp TAG_ENEMY_SENTINEL
; 	jp z, pcg_generate_room__spawn_sentinel  ; these are spawned elsewhere (like pushable-blocks)
; 	cp TAG_ENEMY_MARS_WALKER_LEFT
; 	jp z, pcg_generate_room__spawn_mars_walker_left  ; these are spawned elsewhere (like pushable-blocks)
; 	cp TAG_ENEMY_MARS_WALKER_RIGHT
; 	jp z, pcg_generate_room__spawn_mars_walker_right  ; these are spawned elsewhere (like pushable-blocks)
; 	cp TAG_ENEMY_MOON_LARGE_MUSHROOM
; 	jp z, pcg_generate_room__spawn_moon_large_mushroom  ; these are spawned elsewhere (like pushable-blocks)
	; ...
	ret


;-----------------------------------------------
; - hl: ptr to enemy weights
pcg_generate_room__spawn_one_enemy:
	; choose an enemy type by weight:
	ld b, (hl)  ; number of options
	inc hl
	ld a, b
	or a
	ret z
	call random_a
	and #1f
pcg_generate_room__spawn_one_enemy_loop:
	ld c, (hl)  ; enmy type
	inc hl
	sub (hl)  ; weight
	jr c, pcg_generate_room__spawn_one_enemy_chosen
	inc hl
	djnz pcg_generate_room__spawn_one_enemy_loop
pcg_generate_room__spawn_one_enemy_chosen:
	ld a, c

	; spawn an enemy:
	cp ENEMY_SNAKE
	jp z, pcg_generate_room__spawn_snake
	cp ENEMY_SNAKE_DASHER
	jp z, pcg_generate_room__spawn_snake_dasher
	cp ENEMY_SNAKE_POISON
	jp z, pcg_generate_room__spawn_snake_poison
	cp ENEMY_FISH
	jp z, pcg_generate_room__spawn_fish
	cp ENEMY_FISH_JUMPER
	jp z, pcg_generate_room__spawn_fish_jumper
	cp ENEMY_BAT
	jp z, pcg_generate_room__spawn_bat
	cp ENEMY_BAT_AGGRESSIVE
	jp z, pcg_generate_room__spawn_bat_aggressive
	cp ENEMY_SKELETON
	jp z, pcg_generate_room__spawn_skeleton
	cp ENEMY_SKELETON_THROWER1
	jp z, pcg_generate_room__spawn_skeleton_thrower1
	cp ENEMY_SKELETON_THROWER2
	jp z, pcg_generate_room__spawn_skeleton_thrower2
	cp ENEMY_SKELETON_THROWER3
	jp z, pcg_generate_room__spawn_skeleton_thrower3
	cp ENEMY_SKELETON_THROWER4
	jp z, pcg_generate_room__spawn_skeleton_thrower4
	cp ENEMY_SKELETON_FLAME1
	jp z, pcg_generate_room__spawn_skeleton_flame1
	cp ENEMY_SKELETON_FLAME2
	jp z, pcg_generate_room__spawn_skeleton_flame2
	cp ENEMY_SKELETON_SLEEPER
	jp z, pcg_generate_room__spawn_skeleton_sleeper
	cp ENEMY_FIRE_IMP
	jp z, pcg_generate_room__spawn_fire_imp
	cp ENEMY_FIRE_IMP2
	jp z, pcg_generate_room__spawn_fire_imp2
	cp ENEMY_FROG
	jp z, pcg_generate_room__spawn_frog
	cp ENEMY_FROG_JUMPER
	jp z, pcg_generate_room__spawn_frog_jumper
	cp ENEMY_FROG_TONGUE
	jp z, pcg_generate_room__spawn_frog_tongue
	cp ENEMY_MONKEY
	jp z, pcg_generate_room__spawn_monkey
	cp ENEMY_MONKEY_THROWER
	jp z, pcg_generate_room__spawn_monkey_thrower
	cp ENEMY_ROCKMAN
	jp z, pcg_generate_room__spawn_rockman
	cp ENEMY_ROCKMAN2
	jp z, pcg_generate_room__spawn_rockman2
	cp ENEMY_GHOST
	jp z, pcg_generate_room__spawn_ghost
	cp ENEMY_GHOST2
	jp z, pcg_generate_room__spawn_ghost2
	cp ENEMY_FISHMAN
	jp z, pcg_generate_room__spawn_fishman
	cp ENEMY_FISHMAN2
	jp z, pcg_generate_room__spawn_fishman2
	cp ENEMY_MARS_SNAIL1
	jp z, pcg_generate_room__spawn_mars_snail1
	cp ENEMY_MARS_SNAIL2
	jp z, pcg_generate_room__spawn_mars_snail2
	cp ENEMY_MARS_BLOB1
	jp z, pcg_generate_room__spawn_mars_blob1
	cp ENEMY_MARS_BLOB2
	jp z, pcg_generate_room__spawn_mars_blob2
	cp ENEMY_MARS_DRONE1
	jp z, pcg_generate_room__spawn_mars_drone1
	cp ENEMY_MARS_DRONE2
	jp z, pcg_generate_room__spawn_mars_drone2
	cp ENEMY_MARS_ROBOT1
	jp z, pcg_generate_room__spawn_mars_robot1
	cp ENEMY_MARS_ROBOT2
	jp z, pcg_generate_room__spawn_mars_robot2
	cp ENEMY_MUSHROOM1
	jp z, pcg_generate_room__spawn_mushroom1
	cp ENEMY_MUSHROOM2
	jp z, pcg_generate_room__spawn_mushroom2
	ret


;-----------------------------------------------
; input:
; output:
; - e, d: position
; - hl: ptr
; - z: ptr found
; - nz: no ptr found
pcg_generate_room__spawn_enemy_get_new_ptr:
	call pcg_generate_room__spawn_enemy_get_new_position
	ret nz
	push bc
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ret nz
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	xor a  ; z
	ret


;-----------------------------------------------
; input:
; output:
; - e, d: position
; - hl: ptr
; - z: ptr found
; - nz: no ptr found
pcg_generate_room__spawn_water_enemy_get_new_ptr:
	call pcg_generate_room__spawn_enemy_get_new_water_position
	ret nz
	push bc
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ret nz
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	xor a  ; z
	ret


;-----------------------------------------------
; input:
; output:
; - e, d: position
; - hl: ptr
; - z: ptr found
; - nz: no ptr found
pcg_generate_room__spawn_ceiling_enemy_get_new_ptr:
	call pcg_generate_room__spawn_enemy_get_new_ceiling_position
	ret nz
	push bc
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ret nz
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	xor a  ; z
	ret


;-----------------------------------------------
; input:
; output:
; - e, d: position
; - z: ptr found
; - nz: no ptr found
pcg_generate_room__spawn_enemy_get_new_position:
	ld a, (tmp_enemy_pcg_n_platform_locs)
	ld e, a
	or a
	jr z, pcg_generate_room__spawn_enemy_get_new_position_not_found  ; no positions available
	ld c, a
	call random_modulo
	ld hl, buffer_4096
; 	push bc
		push de
			ld e, a
			ld d, 0
			add hl, de
			add hl, de
			ld e, (hl)
			inc hl
			ld d, (hl)
		pop bc
		; remove the position (shift all the positions left):
		sub c
		neg
		dec a  ; a = number of positions we need to copy to the left
		push de
			ld e, l
			ld d, h
			dec de
			inc hl
			or a
			jr z, pcg_generate_room__spawn_enemy_get_new_position_continue
			ld c, a
			ld b, 0
			sla c
			rl b
			ldir
pcg_generate_room__spawn_enemy_get_new_position_continue:
		pop de
; 	pop bc
; 	dec c
	ld a, (tmp_enemy_pcg_n_platform_locs)
	dec a
	ld (tmp_enemy_pcg_n_platform_locs), a
	xor a
	ret
pcg_generate_room__spawn_enemy_get_new_ceiling_position_not_found:
pcg_generate_room__spawn_enemy_get_new_water_position_not_found:
pcg_generate_room__spawn_enemy_get_new_lava_position_not_found:
pcg_generate_room__spawn_enemy_get_new_position_not_found:
	or 1
	ret


;-----------------------------------------------
; input:
; output:
; - e, d: position
; - z: ptr found
; - nz: no ptr found
pcg_generate_room__spawn_enemy_get_new_water_position:
	ld a, (tmp_enemy_pcg_n_water_locs)
	ld e, a
	or a
	jr z, pcg_generate_room__spawn_enemy_get_new_water_position_not_found  ; no positions available
	ld c, a
	call random_modulo
	ld hl, buffer_4096 + 512
; 	push bc
		push de
			ld e, a
			ld d, 0
			add hl, de
			add hl, de
			ld e, (hl)
			inc hl
			ld d, (hl)
		pop bc
		; remove the position (shift all the positions left):
		sub c
		neg
		dec a  ; a = number of positions we need to copy to the left
		push de
			ld e, l
			ld d, h
			dec de
			inc hl
			or a
			jr z, pcg_generate_room__spawn_enemy_get_new_water_position_continue
			ld c, a
			ld b, 0
			sla c
			rl b
			ldir
pcg_generate_room__spawn_enemy_get_new_water_position_continue:
		pop de
; 	pop bc
; 	dec c
	ld a, (tmp_enemy_pcg_n_water_locs)
	dec a
	ld (tmp_enemy_pcg_n_water_locs), a
	xor a
	ret


;-----------------------------------------------
pcg_generate_room__spawn_enemy_get_new_ceiling_position:
	ld a, (tmp_enemy_pcg_n_ceiling_locs)
	or a
	jr z, pcg_generate_room__spawn_enemy_get_new_ceiling_position_not_found
; 	push bc
		ld c, a
		call random_modulo
		ld hl, buffer_4096 + 1024
		ld e, c
		push de
			ld e, a
			ld d, 0
			add hl, de
			add hl, de
			ld e, (hl)
			inc hl
			ld d, (hl)
		pop bc
		; remove the position (shift all the positions left):
		sub c
		neg
		dec a  ; a = number of positions we need to copy to the left
		push de
			ld e, l
			ld d, h
			dec de
			inc hl
			or a
			jr z, pcg_generate_room__spawn_enemy_get_new_ceiling_position_continue
			ld c, a
			ld b, 0
			sla c
			rl b
			ldir
pcg_generate_room__spawn_enemy_get_new_ceiling_position_continue:
		pop de
; 	pop bc
	ld a, (tmp_enemy_pcg_n_ceiling_locs)
	dec a
	ld (tmp_enemy_pcg_n_ceiling_locs), a
	xor a
	ret


;-----------------------------------------------
; input:
; output:
; - e, d: position
; - z: ptr found
; - nz: no ptr found
pcg_generate_room__spawn_enemy_get_new_lava_position:
	ld a, (tmp_enemy_pcg_n_lava_locs)
	ld e, a
	or a
	jr z, pcg_generate_room__spawn_enemy_get_new_lava_position_not_found  ; no positions available
	ld c, a
	call random_modulo
	ld hl, buffer_4096 + 1536
; 	push bc
		push de
			ld e, a
			ld d, 0
			add hl, de
			add hl, de
			ld e, (hl)
			inc hl
			ld d, (hl)
		pop bc
		; remove the position (shift all the positions left):
		sub c
		neg
		dec a  ; a = number of positions we need to copy to the left
		push de
			ld e, l
			ld d, h
			dec de
			inc hl
			or a
			jr z, pcg_generate_room__spawn_enemy_get_new_lava_position_continue
			ld c, a
			ld b, 0
			sla c
			rl b
			ldir
pcg_generate_room__spawn_enemy_get_new_lava_position_continue:
		pop de
; 	pop bc
; 	dec c
	ld a, (tmp_enemy_pcg_n_lava_locs)
	dec a
	ld (tmp_enemy_pcg_n_lava_locs), a
	xor a
	ret


;-----------------------------------------------
; input:
; pcg_generate_room__spawn_snake_poison:
; 	ld ixl, ENEMY_SNAKE_POISON
; 	ld ixh, 2
; 	jr pcg_generate_room__spawn_snake_continue
; pcg_generate_room__spawn_snake_dasher:
; 	ld ixl, ENEMY_SNAKE_DASHER
; 	ld ixh, 2
; 	jr pcg_generate_room__spawn_snake_continue
; pcg_generate_room__spawn_snake:
; 	ld ixl, ENEMY_SNAKE
; 	ld ixh, 2
; pcg_generate_room__spawn_snake_continue
; 	call pcg_generate_room__spawn_enemy_get_new_ptr
; 	ret nz
; 	ld a, ixl
; 	ld (hl), a
; 	inc hl
; 	ld (hl), 0
; 	inc hl
; 	ld (hl), e  ; tile x
; 	inc hl
; 	ld (hl), 0
; 	inc hl
; 	ld (hl), d  ; tile y
; 	inc hl
; 	call random_a  ; randomly face left or right
; 	and #01
; 	ld (hl), a  ; state
; 	inc hl
; 	ld (hl), 0  ; state timer
; 	inc hl
; 	ld (hl), #ff  ; hit ID
; 	inc hl
; 	ld a, ixh
; 	ld (hl), a  ; health
; 	ret


;-----------------------------------------------
; input:
; - b: number of positions available (in tmp_enemy_pcg_n_water_locs)
pcg_generate_room__spawn_fish_jumper:
	ld ixl, ENEMY_FISH_JUMPER
	jr pcg_generate_room__spawn_fish_continue
pcg_generate_room__spawn_fish:
	ld ixl, ENEMY_FISH
pcg_generate_room__spawn_fish_continue:
	call pcg_generate_room__spawn_water_enemy_get_new_ptr
	ret nz
	ld a, ixl
	ld (hl), a
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), d  ; tile y
	inc hl
	call random_a  ; randomly face left or right
	and #01
	ld (hl), a  ; state
	inc hl
	call random_a  ; random state timer
	and #1f
	ld (hl), a  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld (hl), 1  ; health
	ret


;-----------------------------------------------
; input:
; - b: number of positions available (in tmp_enemy_pcg_n_ceiling_locs)
pcg_generate_room__spawn_mars_drone1:
	ld ixl, ENEMY_MARS_DRONE1
	ld ixh, 2  ; hitpoints
	ld iyl, 0  ; state
	jr pcg_generate_room__spawn_bat_continue
pcg_generate_room__spawn_mars_drone2:
	ld ixl, ENEMY_MARS_DRONE2
	ld ixh, 4  ; hitpoints
	ld iyl, 0  ; state
	jr  pcg_generate_room__spawn_bat_continue
pcg_generate_room__spawn_bat_aggressive:
	ld ixl, ENEMY_BAT_AGGRESSIVE
	ld ixh, 1
	ld iyl, 9  ; state (hanging)
	jr pcg_generate_room__spawn_bat_continue
pcg_generate_room__spawn_bat:
	ld ixl, ENEMY_BAT
	ld ixh, 1
	ld iyl, 9  ; state (hanging)
pcg_generate_room__spawn_bat_continue:
	call pcg_generate_room__spawn_ceiling_enemy_get_new_ptr
	ret nz
	ld a, ixl
	ld (hl), a
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), d  ; tile y
	inc hl
	ld a, iyl
	ld (hl), a  ; state
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld a, ixh
	ld (hl), a  ; health
	ret


;-----------------------------------------------
; input:
; - b: number of positions available (in tmp_enemy_pcg_n_platform_locs)
pcg_generate_room__spawn_snake_poison:
	ld ixl, ENEMY_SNAKE_POISON
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_snake_dasher:
	ld ixl, ENEMY_SNAKE_DASHER
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_snake:
	ld ixl, ENEMY_SNAKE
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_monkey_thrower:
	ld ixl, ENEMY_MONKEY_THROWER
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue		
pcg_generate_room__spawn_monkey:
	ld ixl, ENEMY_MONKEY
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue		
pcg_generate_room__spawn_frog:
	ld ixl, ENEMY_FROG
	ld ixh, 1  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue	
pcg_generate_room__spawn_frog_jumper:
	ld ixl, ENEMY_FROG_JUMPER
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue	
pcg_generate_room__spawn_frog_tongue:
	ld ixl, ENEMY_FROG_TONGUE
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue	
pcg_generate_room__spawn_skeleton_thrower1:
	ld ixl, ENEMY_SKELETON_THROWER1
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton_thrower2:
	ld ixl, ENEMY_SKELETON_THROWER2
	ld ixh, 2  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton_thrower3:
	ld ixl, ENEMY_SKELETON_THROWER3
	ld ixh, 4  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton_thrower4:
	ld ixl, ENEMY_SKELETON_THROWER4
	ld ixh, 4  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton_flame1:
	ld ixl, ENEMY_SKELETON_FLAME1
	ld ixh, 3  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton_flame2:
	ld ixl, ENEMY_SKELETON_FLAME2
	ld ixh, 4  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_ghost:
	ld ixl, ENEMY_GHOST
	ld ixh, 4  ; hitpoints
	jp pcg_generate_room__spawn_ghost_continue
pcg_generate_room__spawn_ghost2:
	ld ixl, ENEMY_GHOST2
	ld ixh, 6  ; hitpoints
	jp pcg_generate_room__spawn_ghost_continue
pcg_generate_room__spawn_fishman:
	ld ixl, ENEMY_FISHMAN
	ld ixh, 4  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_fishman2:
	ld ixl, ENEMY_FISHMAN2
	ld ixh, 8  ; hitpoints
	jp pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_mars_snail1:
	ld ixl, ENEMY_MARS_SNAIL1
	ld ixh, 6  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_mars_snail2:
	ld ixl, ENEMY_MARS_SNAIL2
	ld ixh, 10  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_mars_blob1:
	ld ixl, ENEMY_MARS_BLOB1
	ld ixh, 4  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_mars_blob2:
	ld ixl, ENEMY_MARS_BLOB2
	ld ixh, 8  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_mars_robot1:
	ld ixl, ENEMY_MARS_ROBOT1
	ld ixh, 4  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_mars_robot2:
	ld ixl, ENEMY_MARS_ROBOT2
	ld ixh, 8  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_mushroom1:
	ld ixl, ENEMY_MUSHROOM1
	ld ixh, 4  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_mushroom2:
	ld ixl, ENEMY_MUSHROOM2
	ld ixh, 8  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton_sleeper:
	ld ixl, ENEMY_SKELETON_SLEEPER
	ld ixh, 4  ; hitpoints
	call pcg_generate_room__spawn_skeleton_continue
	dec hl
	dec hl
	dec hl
	ld (hl), 2  ; start sleeping
	ret
pcg_generate_room__spawn_fire_imp2:
	ld ixl, ENEMY_FIRE_IMP2
	ld ixh, 8  ; hitpoints
	jr pcg_generate_room__spawn_fire_imp_continue
pcg_generate_room__spawn_fire_imp:
	ld ixl, ENEMY_FIRE_IMP
	ld ixh, 4  ; hitpoints
pcg_generate_room__spawn_fire_imp_continue:
	call pcg_generate_room__spawn_skeleton_continue
	dec hl
	dec hl
	call random_a
	and #1f
	ld (hl), a  ; random state timer init, to dash at different times
	dec hl
	ld (hl), 0  ; start in fireball state
	ret
pcg_generate_room__spawn_rockman:
	ld ixl, ENEMY_ROCKMAN
	ld ixh, 8  ; hitpoints
	jr pcg_generate_room__spawn_rockman_continue
pcg_generate_room__spawn_rockman2:
	ld ixl, ENEMY_ROCKMAN2
	ld ixh, 16  ; hitpoints
	jr pcg_generate_room__spawn_rockman_continue
pcg_generate_room__spawn_skeleton:
	ld ixl, ENEMY_SKELETON
	ld ixh, 2  ; hitpoints
pcg_generate_room__spawn_skeleton_continue:
	call pcg_generate_room__spawn_enemy_get_new_ptr  ; hl: ptr, e, d: x, y
	ret nz
	ld a, ixl
	ld (hl), a
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), d  ; tile y
	inc hl
	call random_a  ; randomly face left or right
	and #01
	ld (hl), a  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld a, ixh
	ld (hl), a  ; health
	ret

pcg_generate_room__spawn_rockman_continue:
	call pcg_generate_room__spawn_enemy_get_new_ptr  ; hl: ptr, e, d: x, y
	ret nz
	ld a, ixl
	ld (hl), a
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), d  ; tile y
	inc hl
	ld (hl), 2  ; state (rock)
	inc hl
	call random_a
	and #7f
	add a, 32
	ld (hl), a  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld a, ixh
	ld (hl), a  ; health
	ret

pcg_generate_room__spawn_ghost_continue:
	; call pcg_generate_room__spawn_enemy_get_new_ptr  ; hl: ptr, e, d: x, y
	; ret nz
	ld a, (current_room__width)
	sub 4
	ld c, a
	call random_modulo
	add a, 2
	ld e, a
	ld a, (current_room__height)
	sub 4
	ld c, a
	call random_modulo
	add a, 2
	ld d, a
	push de
		call ptr_to_new_sprite_enemy
	pop de
	ret nz
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld a, ixl
	ld (hl), a
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), d  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld a, ixh
	ld (hl), a  ; health
	ret


;-----------------------------------------------
; input:
; output:
; - a, iyl: number of spots found
; - ixl, ixh: x, y of the spot (if iyl > 0)
pcg_generate_room__find_4x4_enemy_spots:
	; Iterate over the positions and find which are candidates for a carnivore plant,
	; which needs a 4x4 space, instead of only 2x2:
	ld iyl, 0  ; number of viable positions so far
	ld hl, buffer_4096
	ld a, (tmp_enemy_pcg_n_platform_locs)
	ld b, a
pcg_generate_room__find_4x4_enemy_spots_loop:
	push bc
		ld c, (hl)
		inc hl
		ld b, (hl)
		inc hl
		push hl
		push bc
			call get_room_tile_ptr
			ld a, (current_room__width)
			ld b, 0
			ld c, a
			or a
			sbc hl, bc
			sbc hl, bc
			dec hl  ; ptr to top-left
			; first row:
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			inc hl
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			inc hl
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			inc hl
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			; second row:
			add hl, bc
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			dec hl
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			dec hl
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			dec hl
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			; third row:
			add hl, bc
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			inc hl
			inc hl
			inc hl
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			; fourth row:
			add hl, bc
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			dec hl
			dec hl
			dec hl
			ld a, (hl)
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
			; viable position!
			ld a, iyl
			or a
			jr z, pcg_generate_room__find_4x4_enemy_spots_loop_replace
			; reservoir sampling:
			ld c, a
			call random_modulo
			or a
			jr nz, pcg_generate_room__find_4x4_enemy_spots_loop_skip
pcg_generate_room__find_4x4_enemy_spots_loop_replace:
		pop bc
		pop hl
		ld ixl, c
		ld ixh, b
		inc iyl
		jr pcg_generate_room__find_4x4_enemy_spots_loop_next
pcg_generate_room__find_4x4_enemy_spots_loop_skip:
		pop bc
		pop hl
pcg_generate_room__find_4x4_enemy_spots_loop_next:
	pop bc
	djnz pcg_generate_room__find_4x4_enemy_spots_loop
	ld a, iyl
	ret


;-----------------------------------------------
; We can only have a single "hittable" tile enemy per room, because of the logic
; for hitting tile enemies (which does not distinguishes which was hit).
; input:
; - c: tile enemy type
; output:
; - z: we can spawn it
; - nz: we cannot spawn it
pcg_spawn_enemies__tile_enemy_type_check_hittable:
	ld a, (tmp_enemy_pcg_tile_enemy_spawned_type)
	or a
	ret nz  ; there is already another "hittable" tile nemy
pcg_spawn_enemies__tile_enemy_type_check_hittable_check_ok:
	ld a, c
	ld (tmp_enemy_pcg_tile_enemy_spawned_type), a  ; mark that we spawned a carnivore plant
	xor a  ; z
	ret 


;-----------------------------------------------
; input:
; - c: tile enemy type
; output:
; - z: we can spawn it
; - nz: we cannot spawn it
pcg_spawn_enemies__tile_enemy_type_check:
	ld a, (tmp_enemy_pcg_tile_enemy_spawned_type)
	or a
	jr z, pcg_spawn_enemies__tile_enemy_type_check_ok
	cp c
	ret nz  ; if we have enemies of a different type, fail
pcg_spawn_enemies__tile_enemy_type_check_ok:
	ld a, c
	ld (tmp_enemy_pcg_tile_enemy_spawned_type), a  ; mark that we spawned a carnivore plant
	xor a  ; z
	ret 


;-----------------------------------------------
pcg_generate_room__spawn_carnivore_plant:
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	add CARNIVORE_PLANT_WORKMEMORY_USAGE
	cp (tile_enemy_work_memory_end - tile_enemy_work_memory) + 1  ; + 1 so that we can use "nc" as the condition
	ret nc  ; if we do not have enough work memory, do not spawn
	call pcg_generate_room__find_4x4_enemy_spots
	or a
	ret z
	; we found at leat one viable position, spawn the plant:
	ld hl, ptr_to_new_tile_object
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ret nz
	ld c, TAG_ENEMY_CARNIVORE_PLANT
	call pcg_spawn_enemies__tile_enemy_type_check_hittable
	ret nz
	ld c, ixl
	dec c
	ld b, ixh
	dec b
	dec b
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld (hl), TAG_ENEMY_CARNIVORE_PLANT  ; type
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), 16  ; hit points
	inc hl

	ld de, tile_enemy_work_memory
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	ADD_DE_A
	ld (hl), e  ; work memory ptr
	inc hl
	ld (hl), d
	xor a
	ld (de), a  ; tongue length = 0
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	add a, CARNIVORE_PLANT_WORKMEMORY_USAGE
	ld (tmp_enemy_pcg_tile_enemy_workmemory_usage), a

	ld hl, enemy_carnivoreplant_tiles_zx0
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld a, ENEMY_TILES_PAGE
	ld (enemy_tiles_to_upload_to_vdp_page), a
	ld hl, enemy_carnivore_plant_hit
	ld (tile_enemy_hit_fn_ptr), hl
	ret


;-----------------------------------------------
; input:
pcg_generate_room__spawn_ant_colony:
	call pcg_generate_room__find_4x4_enemy_spots
	or a
	ret z
	; we found at leat one viable position, spawn the plant:
	ld hl, ptr_to_new_tile_object
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ret nz
	ld c, TAG_ENEMY_ANT_COLONY
	call pcg_spawn_enemies__tile_enemy_type_check_hittable	
	ret nz
	ld c, ixl
	dec c
	ld b, ixh
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld (hl), TAG_ENEMY_ANT_COLONY  ; type
pcg_generate_room__spawn_ant_colony2_continue:	
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), 16  ; hit points

	ld hl, enemy_ant_colony_tiles_zx0
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld a, ENEMY_TILES_PAGE
	ld (enemy_tiles_to_upload_to_vdp_page), a
	ld hl, enemy_ant_colony_hit
	ld (tile_enemy_hit_fn_ptr), hl
	ret


;-----------------------------------------------
; input:
pcg_generate_room__spawn_ant_colony2:
	call pcg_generate_room__find_4x4_enemy_spots
	or a
	ret z
	; we found at leat one viable position, spawn the plant:
	ld hl, ptr_to_new_tile_object
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ret nz
	ld c, TAG_ENEMY_ANT_COLONY  ; since it uses the same tiles as ant colony, we use the same type
	call pcg_spawn_enemies__tile_enemy_type_check_hittable	
	ret nz

	ld c, ixl
	dec c
	ld b, ixh
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld (hl), TAG_ENEMY_ANT_COLONY2  ; type
	jr pcg_generate_room__spawn_ant_colony2_continue


;-----------------------------------------------
pcg_generate_room__spawn_bee_hive:
	call pcg_generate_room__spawn_enemy_get_new_ceiling_position
	ret nz
	; we found at leat one viable position, spawn the hive:
	push de
	push bc
		; undraw the current tile objects:
		ld hl, room_undraw_tile_objects
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000

		ld hl, ptr_to_new_tile_object
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop bc
	pop de
	ret nz	
	ld c, TAG_ENEMY_BEE_HIVE  ; since it uses the same tiles as ant colony, we use the same type
	call pcg_spawn_enemies__tile_enemy_type_check_hittable		
	ret nz
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld (hl), TAG_ENEMY_BEE_HIVE  ; type
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), d  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), 8  ; hit points

	ld hl, enemy_bee_hive_tiles_zx0
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld a, ENEMY_TILES_PAGE
	ld (enemy_tiles_to_upload_to_vdp_page), a
	ld hl, enemy_bee_hive_hit
	ld (tile_enemy_hit_fn_ptr), hl

	; draw the tile objects again, now that we have added a new one:
	push bc
		ld hl, room_render_tile_objects
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop bc
	ret


;-----------------------------------------------
pcg_generate_room__spawn_imp_generator:
	call pcg_generate_room__spawn_enemy_get_new_lava_position
	ret nz
	; we found at leat one viable position, spawn the generator:
	push de
	push bc
		ld hl, ptr_to_new_tile_object
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop bc
	pop de
	ret nz
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld (hl), TAG_ENEMY_IMP_GENERATOR  ; type
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), d  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), 0  ; hit points
	ret

pcg_generate_room__spawn_imp_generator2:
	call pcg_generate_room__spawn_enemy_get_new_lava_position
	ret nz
	; we found at leat one viable position, spawn the generator:
	push de
	push bc
		ld hl, ptr_to_new_tile_object
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop bc
	pop de
	ret nz
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld (hl), TAG_ENEMY_IMP_GENERATOR2  ; type
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), d  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), 0  ; hit points
	ret


;-----------------------------------------------
pcg_generate_room__spawn_fireball_generator:
	call pcg_generate_room__spawn_enemy_get_new_lava_position
	ret nz
	; we found at leat one viable position, spawn the generator:
	push de
	push bc
		ld hl, ptr_to_new_tile_object
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop bc
	pop de
	ret nz
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld (hl), TAG_ENEMY_FIREBALL_GENERATOR  ; type
	inc hl
	ld (hl), e  ; tile x
	inc hl
	ld (hl), d  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), 0  ; hit points
	ret


;-----------------------------------------------
; input:
; - de: ptr to foreground chunk "lava-generator" object
pcg_generate_room__spawn_lava_generator:
  	ex de, hl
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	add LAVA_GENERATOR_WORKMEMORY_USAGE
	cp (tile_enemy_work_memory_end - tile_enemy_work_memory) + 1  ; + 1 so that we can use "nc" as the condition
	ret nc  ; if we do not have enough work memory, do not spawn

	; probability of spawning, depending on the difficulty level:
	call pcg_generate_room__spawn_sentinel_probability_check
	ret nc

	ld de, (tmp_pcg_room__next_tile_object_ptr)
	push de
		xor a  ; lava generators have ID 0
		ld (de), a  ; ID
		inc de
		ld a, TAG_ENEMY_LAVA_GENERATOR
		ld (de), a  ; type
		inc de
		inc hl
		ld a, (tmp_pcg_room__chunk_x)
		add a, (hl)  ; x relative to this chunk
		ld (de), a  ; x
		inc de
		inc hl
		ld a, (tmp_pcg_room__chunk_y)
		add a, (hl)  ; y relative to this chunk
		ld (de), a  ; y
		inc de
		xor a
		ld (de), a  ; state
		inc de
		ld (de), a  ; state timer
		inc de
		inc de
		ex de, hl

		ld de, tile_enemy_work_memory
		ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
		ADD_DE_A
		ld (hl), e  ; work memory ptr
		inc hl
		ld (hl), d
		ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
		add a, LAVA_GENERATOR_WORKMEMORY_USAGE
		ld (tmp_enemy_pcg_tile_enemy_workmemory_usage), a
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	ld (tmp_pcg_room__next_tile_object_ptr), hl	
	ret


;-----------------------------------------------
pcg_generate_room__spawn_stone_owl:
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	add STONE_OWL_WORKMEMORY_USAGE
	cp (tile_enemy_work_memory_end - tile_enemy_work_memory) + 1  ; + 1 so that we can use "nc" as the condition
	ret nc  ; if we do not have enough work memory, do not spawn
	call pcg_generate_room__find_4x4_enemy_spots
	or a
	ret z
	; we found at leat one viable position, spawn the owl:
	ld hl, ptr_to_new_tile_object
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ret nz
	ld c, TAG_ENEMY_STONE_OWL
	call pcg_spawn_enemies__tile_enemy_type_check_hittable
	ret nz
	ld c, ixl
	dec c
	ld b, ixh
	dec b
	dec b  ; we will treat it as a 4x4 enemy (even if it's not)
	ld a, (tmp_enemy_pcg_next_enemy_id)
	ld (hl), a  ; ID
	inc a
	ld (tmp_enemy_pcg_next_enemy_id), a
	inc hl
	ld (hl), TAG_ENEMY_STONE_OWL  ; type
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), 32  ; hit points
	inc hl

	ld de, tile_enemy_work_memory
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	ADD_DE_A
	ld (hl), e  ; work memory ptr
	inc hl
	ld (hl), d
	xor a
	ld (de), a  ; mark that we have not yet saved the background
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	add a, STONE_OWL_WORKMEMORY_USAGE
	ld (tmp_enemy_pcg_tile_enemy_workmemory_usage), a

	ld hl, enemy_stone_owl_tiles_zx0
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld a, ENEMY_TILES_PAGE
	ld (enemy_tiles_to_upload_to_vdp_page), a
	ld hl, enemy_stone_owl_hit
	ld (tile_enemy_hit_fn_ptr), hl
	ret


;-----------------------------------------------
; input:
; - de: ptr to the room chunk object where we will spawn the sentinel
pcg_generate_room__spawn_sentinel:
  	ex de, hl  ; hl: ptr to room chunk object
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	add SENTINEL_WORKMEMORY_USAGE
	cp (tile_enemy_work_memory_end - tile_enemy_work_memory) + 1  ; + 1 so that we can use "nc" as the condition
	ret nc  ; if we do not have enough work memory, do not spawn

	; probability of spawning, depending on the difficulty level:
	call pcg_generate_room__spawn_sentinel_probability_check
	ret nc

	ld c, TAG_ENEMY_SENTINEL
	call pcg_spawn_enemies__tile_enemy_type_check_hittable
	ret nz
	ld de, (tmp_pcg_room__next_tile_object_ptr)
	push de
		ld a, (tmp_enemy_pcg_next_enemy_id)
		ld (de), a  ; ID
		inc a
		ld (tmp_enemy_pcg_next_enemy_id), a
		inc de
		ld a, TAG_ENEMY_SENTINEL
		ld (de), a  ; type
		inc de
		inc hl
		ld a, (tmp_pcg_room__chunk_x)
		add a, (hl)  ; x relative to this chunk
		ld (de), a  ; x
		inc de
		inc hl
		ld a, (tmp_pcg_room__chunk_y)
		add a, (hl)  ; y relative to this chunk
		ld (de), a  ; y
		inc de
		ld a, 5  ; initial state to spawn the sprite object		
		ld (de), a  ; state
		inc de
		xor a
		ld (de), a  ; state timer
		inc de
		ld a, 32
		ld (de), a  ; hit points
		inc de
		ex de, hl

		ld de, tile_enemy_work_memory
		ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
		ADD_DE_A
		xor a
		ld (de), a  ; mark background as not saved
		ld (hl), e  ; work memory ptr
		inc hl
		ld (hl), d
		inc hl
		ld (hl), a  ; extra 1: current frame
		inc hl
		ld (hl), a  ; extra 2: previous frame
		ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
		add a, SENTINEL_WORKMEMORY_USAGE
		ld (tmp_enemy_pcg_tile_enemy_workmemory_usage), a
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	ld (tmp_pcg_room__next_tile_object_ptr), hl	

	ld hl, enemy_sentinel_tiles_zx0
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld a, ENEMY_TILES_PAGE
	ld (enemy_tiles_to_upload_to_vdp_page), a
	ld hl, enemy_sentinel_hit
	ld (tile_enemy_hit_fn_ptr), hl
	ret


;-----------------------------------------------
; input:
; - de: ptr to the room chunk object where we will spawn the sentinel
pcg_generate_room__spawn_mars_walker_right:
	ld iyl, TAG_ENEMY_MARS_WALKER_RIGHT
	ld iyh, 0  ; starting frame
; 	ld iyl, TAG_ENEMY_MARS_WALKER_LEFT
; 	ld iyh, 8  ; starting frame
	jr pcg_generate_room__spawn_mars_walker_left_entry_point
pcg_generate_room__spawn_mars_walker_left:
	ld iyl, TAG_ENEMY_MARS_WALKER_LEFT
	ld iyh, 8  ; starting frame
pcg_generate_room__spawn_mars_walker_left_entry_point:
  	ex de, hl  ; hl: ptr to room chunk object
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	add MARS_WALKER_WORKMEMORY_USAGE
	cp (tile_enemy_work_memory_end - tile_enemy_work_memory) + 1  ; + 1 so that we can use "nc" as the condition
	ret nc  ; if we do not have enough work memory, do not spawn

	; probability of spawning, depending on the difficulty level:
	call pcg_generate_room__spawn_sentinel_probability_check
	ret nc

	; spawn walker:
	ld c, iyl  ; type
	call pcg_spawn_enemies__tile_enemy_type_check_hittable
	ret nz
	ld de, (tmp_pcg_room__next_tile_object_ptr)
	push de
		ld a, (tmp_enemy_pcg_next_enemy_id)
		ld (de), a  ; ID
		inc a
		ld (tmp_enemy_pcg_next_enemy_id), a
		inc de
		ld a, iyl
		ld (de), a  ; type
		inc de
		inc hl
		ld a, (tmp_pcg_room__chunk_x)
		add a, (hl)  ; x relative to this chunk
		ld (de), a  ; x
		inc de
		inc hl
		ld a, (tmp_pcg_room__chunk_y)
		add a, (hl)  ; y relative to this chunk
		ld (de), a  ; y
		inc de
		xor a
		ld (de), a  ; state
		inc de
		ld (de), a  ; state timer
		inc de
		ld a, 32
		ld (de), a  ; hit points
		inc de
		ex de, hl

		ld de, tile_enemy_work_memory
		ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
		ADD_DE_A
		xor a
		ld (de), a  ; mark background as not saved
		ld (hl), e  ; work memory ptr
		inc hl
		ld (hl), d
		inc hl
		ld a, iyh
		ld (hl), a  ; extra 1: current frame
		inc hl
		ld (hl), a  ; extra 2: previous frame
		ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
		add a, MARS_WALKER_WORKMEMORY_USAGE
		ld (tmp_enemy_pcg_tile_enemy_workmemory_usage), a
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	ld (tmp_pcg_room__next_tile_object_ptr), hl	

	ld hl, mars_walker_tiles_right_zx0
	ld a, iyl
	cp TAG_ENEMY_MARS_WALKER_RIGHT
	jr z, pcg_generate_room__spawn_mars_walker_right_ptr_set
	ld hl, mars_walker_tiles_left_zx0
pcg_generate_room__spawn_mars_walker_right_ptr_set:
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld a, ENEMY_TILES_PAGE
	ld (enemy_tiles_to_upload_to_vdp_page), a
	ld hl, enemy_mars_walker_hit
	ld (tile_enemy_hit_fn_ptr), hl
	ret


;-----------------------------------------------
; input:
; - de: ptr to the room chunk object where we will spawn the sentinel (type, x, y, dx, dy)
pcg_generate_room__spawn_moon_large_mushroom:
	ld iyl, TAG_ENEMY_MOON_LARGE_MUSHROOM
  	ex de, hl  ; hl: ptr to room chunk object
	ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
	add LARGE_MUSHROOM_WORKMEMORY_USAGE
	cp (tile_enemy_work_memory_end - tile_enemy_work_memory) + 1  ; + 1 so that we can use "nc" as the condition
	ret nc  ; if we do not have enough work memory, do not spawn

	; probability of spawning, depending on the difficulty level:
	call pcg_generate_room__spawn_sentinel_probability_check
	ret nc

	; spawn mushroom:
	ld c, iyl  ; type
	call pcg_spawn_enemies__tile_enemy_type_check_hittable
	ret nz
	ld de, (tmp_pcg_room__next_tile_object_ptr)
	push de
		ld a, (tmp_enemy_pcg_next_enemy_id)
		ld (de), a  ; ID
		inc a
		ld (tmp_enemy_pcg_next_enemy_id), a
		inc de
		ld a, iyl
		ld (de), a  ; type
		inc de
		inc hl
		ld a, (tmp_pcg_room__chunk_x)
		add a, (hl)  ; x relative to this chunk
		ld (de), a  ; x
		inc de
		inc hl
		ld a, (tmp_pcg_room__chunk_y)
		add a, (hl)  ; y relative to this chunk
		ld (de), a  ; y
		inc de
		xor a
		ld (de), a  ; state
		inc de
		ld (de), a  ; state timer
		inc de
		ld a, 32
		ld (de), a  ; hit points
		inc de
		ex de, hl

		ld de, tile_enemy_work_memory
		ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
		ADD_DE_A
		xor a
		ld (de), a  ; mark background as not saved
		ld (hl), e  ; work memory ptr
		inc hl
		ld (hl), d
		ld a, (tmp_enemy_pcg_tile_enemy_workmemory_usage)
		add a, LARGE_MUSHROOM_WORKMEMORY_USAGE
		ld (tmp_enemy_pcg_tile_enemy_workmemory_usage), a
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	ld (tmp_pcg_room__next_tile_object_ptr), hl	

	ld hl, moon_large_mushroom_tiles_zx0
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld a, ENEMY_TILES_PAGE
	ld (enemy_tiles_to_upload_to_vdp_page), a
	ld hl, enemy_large_mushroom_hit
	ld (tile_enemy_hit_fn_ptr), hl
	ret


;-----------------------------------------------
pcg_generate_room__spawn_sentinel_probability_check:
	ld c, 96  ; easy
	ld a, (current_world__difficulty)
	or a
	jr z, pcg_generate_room__spawn_sentinel_probability_check_continue
	ld c, 160  ; normal
	dec a
	jr z, pcg_generate_room__spawn_sentinel_probability_check_continue
	ld c, 224  ; hard
	dec a
	jr z, pcg_generate_room__spawn_sentinel_probability_check_continue
	ld c, 255  ; very hard
pcg_generate_room__spawn_sentinel_probability_check_continue:
	call random_a
	cp c
	ret


;-----------------------------------------------
; This version iterates over all positions accumulates all that match enemy spawn positions in a list
; output:
; - (tmp_enemy_pcg_n_platform_locs): number of positions found over platforms (stored starting at buffer_4096)
; - (tmp_enemy_pcg_n_water_locs): number of positions found in the water (stored starting at buffer_4096 + 512)
; - (tmp_enemy_pcg_n_ceiling_locs): number of positions found in the ceiling (stored starting at buffer_4096 + 1024)
; - (tmp_enemy_pcg_n_lavalocs): number of positions found in the lava durface (stored starting at buffer_4096 + 1536)
pcg__find_enemy_spawn_locations:
	ld hl, buffer_4096
	ld (tmp_enemy_pcg_platform_loc_ptr), hl
	ld hl, buffer_4096 + 512
	ld (tmp_enemy_pcg_water_loc_ptr), hl
	ld hl, buffer_4096 + 1024
	ld (tmp_enemy_pcg_ceiling_loc_ptr), hl
	ld hl, buffer_4096 + 1536
	ld (tmp_enemy_pcg_lava_loc_ptr), hl
	ld a, (current_room__width)
	ld b, 0
	ld c, a
	ld hl, current_room__tile_map + 4  ; do not spawn enemies on the room edges
	add hl, bc
	add hl, bc
	add hl, bc
	add a, -5
	ld iyl, a
	ld a, (current_room__height)
	add a, -4
	ld iyh, a  
	ld c, 4
	ld b, 3
	; search from c, b  ->  iyl, iyh in increments of 2 by 2 (4 by 4 in the x axis)
	; The maximum number of positions searched is thus:
	; - ((128 - 8) / 4) * ((24 - 8) / 2) = 30 * 8 = 240
	; - and at most half could be matches (as ther emust be platforms underneath).
pcg__find_enemy_spawn_locations_y_loop:
	push bc
	push hl
pcg__find_enemy_spawn_locations_x_loop:
		; see if the position matches a "platform location":
		pcg__find_enemy_spawn_location_empty_p_macro
		jp nz, pcg__find_enemy_spawn_locations_x_loop_skip_post_pop
		inc hl
		pcg__find_enemy_spawn_location_empty_p_macro
		dec hl
		jp nz, pcg__find_enemy_spawn_locations_x_loop_skip_post_pop

		push hl
			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_empty_p_macro
			jp nz, pcg__find_enemy_spawn_locations_x_loop_skip
			inc hl
			pcg__find_enemy_spawn_location_empty_p_macro
			dec hl
			jp nz, pcg__find_enemy_spawn_locations_x_loop_skip

			; this is potentially a gorund position or a ceiling position:
			; check for ground:
			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_platform_p_macro
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip_check_ceiling
			inc hl
			pcg__find_enemy_spawn_location_platform_p_macro
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip_check_ceiling
			ld hl, (tmp_enemy_pcg_platform_loc_ptr)
			ld (hl), c
			inc hl
			ld (hl), b
			inc hl
			ld (tmp_enemy_pcg_platform_loc_ptr), hl
pcg__find_enemy_spawn_locations_x_loop_skip_check_ceiling:
		pop hl
		push hl
			; check if it can also be a ceiling location:
			push bc
				ld a, (current_room__width)
				ld b, 0
				ld c, a
				or a
				sbc hl, bc
			pop bc
			pcg__find_enemy_spawn_location_wall_p_macro
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip
			inc hl
			pcg__find_enemy_spawn_location_wall_p_macro
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip
			ld a, (current_room__width)
			ADD_HL_A
			ld hl, (tmp_enemy_pcg_ceiling_loc_ptr)
			ld (hl), c
			inc hl
			ld (hl), b
			inc hl
			ld (tmp_enemy_pcg_ceiling_loc_ptr), hl
pcg__find_enemy_spawn_locations_x_loop_skip:
		pop hl
pcg__find_enemy_spawn_locations_x_loop_skip_post_pop:

		; See if the position matches a "water location":
		pcg__find_enemy_spawn_location_water_p_macro
		jp nz, pcg__find_enemy_spawn_locations_x_loop_skip_water_post_pop
		inc hl
		pcg__find_enemy_spawn_location_water_p_macro
		dec hl
		jr nz, pcg__find_enemy_spawn_locations_x_loop_skip_water_post_pop
		push hl
			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_water_p_macro
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip_water
			inc hl
			pcg__find_enemy_spawn_location_water_p_macro
			dec hl
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip_water

			; add a water position:
			ld hl, (tmp_enemy_pcg_water_loc_ptr)
			ld (hl), c
			inc hl
			ld (hl), b
			inc hl
			ld (tmp_enemy_pcg_water_loc_ptr), hl
pcg__find_enemy_spawn_locations_x_loop_skip_water:
		pop hl
pcg__find_enemy_spawn_locations_x_loop_skip_water_post_pop:

		; See if the position matches a "lava location":
		ld a, (hl)  ; we want lava with 3 empty tiles above
		or a
		jp nz, pcg__find_enemy_spawn_locations_x_loop_skip_lava_post_pop
		push hl
			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_lava_p_macro
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip_lava
			ld a, (current_room__width)
			ld d, 0
			ld e, a
			or a
			sbc hl, de
			or a
			sbc hl, de
			ld a, (hl)
			or a
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip_lava
			or a
			sbc hl, de
			ld a, (hl)
			or a
			jr nz, pcg__find_enemy_spawn_locations_x_loop_skip_lava

			; add a lava position:
pcg__find_enemy_spawn_locations_x_loop_add_lava_position:
			ld hl, (tmp_enemy_pcg_lava_loc_ptr)
			ld (hl), c
			inc hl
			ld (hl), b
			inc hl
			ld (tmp_enemy_pcg_lava_loc_ptr), hl
pcg__find_enemy_spawn_locations_x_loop_skip_lava:
		pop hl
pcg__find_enemy_spawn_locations_x_loop_skip_lava_post_pop:


		inc hl
		inc hl
		inc hl
		inc hl
		inc c
		inc c
		inc c
		inc c
		ld a, c
		cp iyl
		jp c, pcg__find_enemy_spawn_locations_x_loop
	pop hl
	pop bc
	ld a, (current_room__width)
	ADD_HL_A
	inc b
	ld a, b
	cp iyh
	jp c, pcg__find_enemy_spawn_locations_y_loop

	; number of platform locations:
	ld hl, (tmp_enemy_pcg_platform_loc_ptr)
	ld de, -buffer_4096
	add hl, de
	sra h
	rr l
	ld a, l
	ld (tmp_enemy_pcg_n_platform_locs), a

	; number of water locations:
	ld hl, (tmp_enemy_pcg_water_loc_ptr)
	ld de, -(buffer_4096 + 512)
	add hl, de
	sra h
	rr l
	ld a, l
	ld (tmp_enemy_pcg_n_water_locs), a

	; number of ceiling locations:
	ld hl, (tmp_enemy_pcg_ceiling_loc_ptr)
	ld de, -(buffer_4096 + 1024)
	add hl, de
	sra h
	rr l
	ld a, l
	ld (tmp_enemy_pcg_n_ceiling_locs), a

	; number of lava locations:
	ld hl, (tmp_enemy_pcg_lava_loc_ptr)
	ld de, -(buffer_4096 + 1536)
	add hl, de
	sra h
	rr l
	ld a, l
	ld (tmp_enemy_pcg_n_lava_locs), a

	ret


;-----------------------------------------------
pcg__find_enemy_spawn_location_empty_p_macro: macro
	ld a, (hl)
	or a
	jr z, pcg__find_enemy_spawn_location_empty_p_macro_end
	ex de, hl
		ld hl, current_room__collision_table
		ADD_HL_A
		ld a, (hl)		
	ex de, hl
	or a
pcg__find_enemy_spawn_location_empty_p_macro_end:
	endm


;-----------------------------------------------
pcg__find_enemy_spawn_location_platform_p_macro: macro
	ld a, (hl)
	ex de, hl
		ld hl, current_room__collision_table
		ADD_HL_A
		ld a, (hl)		
	ex de, hl
	dec a  ; cp 1
	jr z, pcg__find_enemy_spawn_location_platform_p_macro_end
	dec a  ; cp 2
	jr z, pcg__find_enemy_spawn_location_platform_p_macro_end
	cp 4  ; cp 6
	jr z, pcg__find_enemy_spawn_location_platform_p_macro_end
	cp 6  ; cp 8
pcg__find_enemy_spawn_location_platform_p_macro_end:
	endm


;-----------------------------------------------
pcg__find_enemy_spawn_location_wall_p_macro: macro
	ld a, (hl)
	ex de, hl
		ld hl, current_room__collision_table
		ADD_HL_A
		ld a, (hl)		
	ex de, hl
	cp 2
	endm


;-----------------------------------------------
pcg__find_enemy_spawn_location_water_p_macro: macro
	ld a, (hl)
	ex de, hl
		ld hl, current_room__collision_table
		ADD_HL_A
		ld a, (hl)		
	ex de, hl
	cp 4
	endm


;-----------------------------------------------
pcg__find_enemy_spawn_location_lava_p_macro: macro
	ld a, (hl)
	ex de, hl
		ld hl, current_room__collision_table
		ADD_HL_A
		ld a, (hl)		
	ex de, hl
	cp 10
	endm
