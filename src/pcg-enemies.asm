;-----------------------------------------------
pcg_enemy_generation_table:
	dw pcg_enemy_generation_table_jungle
	dw pcg_enemy_generation_table_pyramid1
	dw pcg_enemy_generation_table_pyramid2
	dw pcg_enemy_generation_table_confluence
	dw pcg_enemy_generation_table_pyramid3
	dw pcg_enemy_generation_table_fire_shaft
	dw pcg_enemy_generation_table_caves_west
	dw pcg_enemy_generation_table_caves_east
	dw pcg_enemy_generation_table_xibalba
	dw pcg_enemy_generation_table_atlantis
	dw pcg_enemy_generation_table_mars
	dw pcg_enemy_generation_table_moon

pcg_enemy_generation_table_jungle:
	; weights (all sprite-based) should add up to 32
	db 2  ; 2 enemies per "screen" area
	db 1
	db TAG_ENEMY_BEE_HIVE, 255  ; tile-based enemy type and chance (out of 256)
; 	db 3  ; 2 possible tile enemy types to be spawned
; 	db TAG_ENEMY_CARNIVORE_PLANT, 32  ; tile-based enemy type and chance (out of 256)
; 	db TAG_ENEMY_BEE_HIVE, 96  ; tile-based enemy type and chance (out of 256)
; 	db TAG_ENEMY_ANT_COLONY, 128  ; tile-based enemy type and chance (out of 256)
	db 6  ; 3 possible sprite enemy types to be spawned
	db ENEMY_SNAKE, 8  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 4
	db ENEMY_SNAKE_POISON, 4
	db ENEMY_FROG, 8  ; enemy type and weight
	db ENEMY_FROG_JUMPER, 4
	db ENEMY_FROG_TONGUE, 4

pcg_enemy_generation_table_pyramid1:
pcg_enemy_generation_table_pyramid2:
pcg_enemy_generation_table_confluence:
pcg_enemy_generation_table_pyramid3:
pcg_enemy_generation_table_fire_shaft:
pcg_enemy_generation_table_caves_west:
pcg_enemy_generation_table_caves_east:
pcg_enemy_generation_table_xibalba:
pcg_enemy_generation_table_atlantis:
pcg_enemy_generation_table_mars:
pcg_enemy_generation_table_moon:
	; weights (all sprite-based) should add up to 32
	db 2  ; 2 enemies per "screen" area
	db 1
	db TAG_ENEMY_CARNIVORE_PLANT, 96  ; tile-based enemy type and chance (out of 256)
	db 10  ; 10 possible sprite enemy types to be spawned
	db ENEMY_SNAKE, 5  ; enemy type and weight
	db ENEMY_SNAKE_DASHER, 2
	db ENEMY_SNAKE_POISON, 2
	db ENEMY_POISON_BULLET, 1
	db ENEMY_FISH, 5
	db ENEMY_FISH_JUMPER, 2
	db ENEMY_BAT, 5
	db ENEMY_BAT_AGGRESSIVE, 2
	db ENEMY_SKELETON, 5
	db ENEMY_SKELETON_THROWER1, 2
	db ENEMY_SKELETON_THROWER2, 1


;-----------------------------------------------
pcg_generate_room__spawn_enemies:	
	ld hl, pcg_enemy_generation_table
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
		push bc
			ld c, (hl)  ; number of different tile-based enemies
			ld b, 0
			inc hl
			add hl, bc
			add hl, bc  ; we skip the tile-based enemy info, and
						; point to the number of options for sprite enemies.
		pop bc
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

	; chance of spawning a tile-based enemy:
	push bc
		ld b, (hl)  ; number of different tile-based enemy types to choose from
		inc hl
		call random_a
pcg_generate_room__spawn_tile_enemies_loop:
		ld c, (hl)  ; potential enemy type
		inc hl
		cp (hl)  ; chance
		jr c, pcg_generate_room__spawn_tile_enemies_loop_found
		inc hl
		djnz  pcg_generate_room__spawn_tile_enemies_loop
	pop bc
	; no tile enemy to spawn
	ret

pcg_generate_room__spawn_tile_enemies_loop_found:
		ld a, c
	pop bc
	cp TAG_ENEMY_CARNIVORE_PLANT
	jp z, pcg_generate_room__spawn_carnivore_plant
	cp TAG_ENEMY_BEE_HIVE
	jp z, pcg_generate_room__spawn_bee_hive
	cp TAG_ENEMY_ANT_COLONY
	jp z, pcg_generate_room__spawn_ant_colony
	; ...
	ret


;-----------------------------------------------
; - hl: ptr to enemy weights
; - c, b: number of spots 
pcg_generate_room__spawn_one_enemy:
	; choose an enemy type by weight:
	push bc
		ld b, (hl)  ; number of options
		inc hl
		ld a, b
		or a
		jr z, pcg_generate_room__spawn_one_enemy_done
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
	pop bc

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
	cp ENEMY_FROG
	jp z, pcg_generate_room__spawn_frog
	cp ENEMY_FROG_JUMPER
	jp z, pcg_generate_room__spawn_frog_jumper
	cp ENEMY_FROG_TONGUE
	jp z, pcg_generate_room__spawn_frog_tongue
	ret

pcg_generate_room__spawn_one_enemy_done:
	pop bc
	ret


;-----------------------------------------------
; input:
; - c: number of positions total we have in this buffer of positions
; output:
; - e, d: position
; - hl: ptr
; - z: ptr found
; - nz: no ptr found
; - decrements 'c' if a position is found
pcg_generate_room__spawn_enemy_get_new_ptr:
; 	ld a, c
; 	or a
; 	jr z, pcg_generate_room__spawn_enemy_get_new_ptr_not_found  ; no positions available
; 	call random_modulo
; 	ld hl, buffer_4096
; 	ld e, c
; 	push bc
; 		push de
; 			ld e, a
; 			ld d, 0
; 			add hl, de
; 			add hl, de
; 			ld e, (hl)
; 			inc hl
; 			ld d, (hl)
; 		pop bc
; 		; remove the position (shift all the positions left):
; 		sub c
; 		neg
; 		dec a  ; a = number of positions we need to copy to the left
; 		push de
; 			ld e, l
; 			ld d, h
; 			dec de
; 			inc hl
; 			or a
; 			jr z, pcg_generate_room__spawn_enemy_get_new_ptr_continue
; 			ld c, a
; 			ld b, 0
; 			sla c
; 			rl b
; 			ldir
; pcg_generate_room__spawn_enemy_get_new_ptr_continue:
; 			; find a new enemy ptr:
; 			call ptr_to_new_sprite_enemy
; 		pop de
; 	pop bc
; 	ex af, af'  ; preserve the z flag
; 	dec c
; 	ex af, af'
; 	ret
; pcg_generate_room__spawn_enemy_get_new_ptr_not_found:
; 	or 1
	call pcg_generate_room__spawn_enemy_get_new_position
	ret nz
	push bc
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ret


;-----------------------------------------------
; input:
; - c: number of positions total we have in this buffer of positions
; output:
; - e, d: position
; - z: ptr found
; - nz: no ptr found
; - decrements 'c' if a position is found
pcg_generate_room__spawn_enemy_get_new_position:
	ld a, c
	or a
	jr z, pcg_generate_room__spawn_enemy_get_new_position_not_found  ; no positions available
	call random_modulo
	ld hl, buffer_4096
	ld e, c
	push bc
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
	pop bc
	dec c
	xor a
	ret
pcg_generate_room__spawn_enemy_get_new_ceiling_position_not_found:
pcg_generate_room__spawn_enemy_get_new_position_not_found:
	or 1
	ret


;-----------------------------------------------
pcg_generate_room__spawn_enemy_get_new_ceiling_position:
	ld a, (tmp_enemy_pcg_n_ceiling_locs)
	or a
	jr z, pcg_generate_room__spawn_enemy_get_new_ceiling_position_not_found
	push bc
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
	pop bc
	ld a, (tmp_enemy_pcg_n_ceiling_locs)
	dec a
	ld (tmp_enemy_pcg_n_ceiling_locs), a
	xor a
	ret


;-----------------------------------------------
; input:
; - c: number of positions available (in buffer_4096)
pcg_generate_room__spawn_snake_poison:
	ld ixl, ENEMY_SNAKE_POISON
	jr pcg_generate_room__spawn_snake_continue
pcg_generate_room__spawn_snake_dasher:
	ld ixl, ENEMY_SNAKE_DASHER
	jr pcg_generate_room__spawn_snake_continue
pcg_generate_room__spawn_snake:
	ld ixl, ENEMY_SNAKE
pcg_generate_room__spawn_snake_continue
	call pcg_generate_room__spawn_enemy_get_new_ptr
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
	ld (hl), 2  ; health
	ret


;-----------------------------------------------
; input:
; - b: number of positions available (in buffer_4096 + 512)
pcg_generate_room__spawn_fish_jumper:
	ld ixl, ENEMY_FISH_JUMPER
	jr pcg_generate_room__spawn_fish_continue
pcg_generate_room__spawn_fish:
	ld ixl, ENEMY_FISH
pcg_generate_room__spawn_fish_continue:
	call pcg_generate_room__spawn_enemy_get_new_ptr
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
	call random_a  ; randomly face left or right
	and #1f
	ld (hl), a  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld (hl), 1  ; health
	ret


;-----------------------------------------------
; input:
; - c: number of positions available (in buffer_4096)
pcg_generate_room__spawn_bat_aggressive:
	ld ixl, ENEMY_BAT_AGGRESSIVE
	jr pcg_generate_room__spawn_bat_continue
pcg_generate_room__spawn_bat:
	ld ixl, ENEMY_BAT
pcg_generate_room__spawn_bat_continue:
	call pcg_generate_room__spawn_enemy_get_new_ptr
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
	; call random_a  ; randomly face left or right
	; and #01
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld (hl), 1  ; health
	ret


;-----------------------------------------------
; input:
; - c: number of positions available (in buffer_4096)
pcg_generate_room__spawn_frog:
	ld ixl, ENEMY_FROG
	ld ixh, 1  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue	
pcg_generate_room__spawn_frog_jumper:
	ld ixl, ENEMY_FROG_JUMPER
	ld ixh, 2  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue	
pcg_generate_room__spawn_frog_tongue:
	ld ixl, ENEMY_FROG_TONGUE
	ld ixh, 2  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue	
pcg_generate_room__spawn_skeleton_thrower1:
	ld ixl, ENEMY_SKELETON_THROWER1
	ld ixh, 2  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton_thrower2:
	ld ixl, ENEMY_SKELETON_THROWER2
	ld ixh, 2  ; hitpoints
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton:
	ld ixl, ENEMY_SKELETON
	ld ixh, 2  ; hitpoints
pcg_generate_room__spawn_skeleton_continue:
	call pcg_generate_room__spawn_enemy_get_new_ptr
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
	call random_a
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


;-----------------------------------------------
; input:
; - c: number of 2x2 enemy spots found
; output:
; - iyl: number of spots found
; - ixl, ixh: x, y of the spot (if iyl > 0)
pcg_generate_room__find_4x4_enemy_spots:
	; Iterate over the positions and find which are candidates for a carnivore plant,
	; which needs a 4x4 space, instead of only 2x2:
	ld iyl, 0  ; number of viable positions so far
	ld hl, buffer_4096
	push bc
		ld b, c
pcg_generate_room__spawn_carnivore_plant_loop:
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
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				inc hl
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				inc hl
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				inc hl
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				; second row:
				add hl, bc
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				dec hl
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				dec hl
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				dec hl
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				; third row:
				add hl, bc
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				inc hl
				inc hl
				inc hl
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				; fourth row:
				add hl, bc
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				dec hl
				dec hl
				dec hl
				ld a, (hl)
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
				; viable position!
				ld a, iyl
				or a
				jr z, pcg_generate_room__spawn_carnivore_plant_loop_replace
				; reservoir sampling:
				ld c, a
				call random_modulo
				or a
				jr nz, pcg_generate_room__spawn_carnivore_plant_loop_skip
pcg_generate_room__spawn_carnivore_plant_loop_replace:
			pop bc
			pop hl
			ld ixl, c
			ld ixh, b
			inc iyl
			jr pcg_generate_room__spawn_carnivore_plant_loop_next
pcg_generate_room__spawn_carnivore_plant_loop_skip:
			pop bc
			pop hl
pcg_generate_room__spawn_carnivore_plant_loop_next:
		pop bc
		djnz pcg_generate_room__spawn_carnivore_plant_loop
	pop bc
	ld a, iyl
	ret


;-----------------------------------------------
; input:
; - c: number of positions available (in buffer_4096)
pcg_generate_room__spawn_carnivore_plant:
	call pcg_generate_room__find_4x4_enemy_spots
	or a
	ret z
	; we found at leat one viable position, spawn the plant:
	ld hl, ptr_to_new_tile_object
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ret nz
	ld c, ixl
	dec c
	ld b, ixh
	dec b
	dec b
	ld (tile_enemy_ptr), hl
	ld (hl), 0  ; ID
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

	ld hl, tile_enemy_work_memory
	ld (hl), 0  ; tongue length = 0

	ld hl, enemy_carnivoreplant_tiles_zx0
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld a, ENEMY_TILES_PAGE
	ld (enemy_tiles_to_upload_to_vdp_page), a
	ld hl, enemy_carnivore_plant_hit
	ld (tile_enemy_hit_fn_ptr), hl
	ret


;-----------------------------------------------
; input:
; - c: number of positions available (in buffer_4096)
pcg_generate_room__spawn_ant_colony:
	call pcg_generate_room__find_4x4_enemy_spots
	or a
	ret z
	; we found at leat one viable position, spawn the plant:
	ld hl, ptr_to_new_tile_object
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ret nz
	ld c, ixl
	dec c
	ld b, ixh
	ld (tile_enemy_ptr), hl
	ld (hl), 0  ; ID
	inc hl
	ld (hl), TAG_ENEMY_ANT_COLONY  ; type
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
pcg_generate_room__spawn_bee_hive:
	call pcg_generate_room__spawn_enemy_get_new_ceiling_position
	ret nz
	; we found at leat one viable position, spawn the plant:
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
	ld (tile_enemy_ptr), hl
	ld (hl), 0  ; ID
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
; This version iterates over all positions accumulates all that match enemy spawn positions in a list
; output:
; - c: number of positions found over platforms (stored starting at buffer_4096)
; - b: number of positions found in the water (stored starting at buffer_4096 + 512)
; - (tmp_enemy_pcg_n_ceiling_locs): number of positions found in the ceiling (stored starting at buffer_4096 + 1024)
pcg__find_enemy_spawn_locations:
	ld hl, buffer_4096
	ld (tmp_enemy_pcg_platform_loc_ptr), hl
	ld hl, buffer_4096 + 512
	ld (tmp_enemy_pcg_water_loc_ptr), hl
	ld hl, buffer_4096 + 1024
	ld (tmp_enemy_pcg_ceiling_loc_ptr), hl
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
			push hl
				ld hl, (tmp_enemy_pcg_water_loc_ptr)
				ld (hl), c
				inc hl
				ld (hl), b
				inc hl
				ld (tmp_enemy_pcg_water_loc_ptr), hl
			pop hl
pcg__find_enemy_spawn_locations_x_loop_skip_water:
		pop hl
pcg__find_enemy_spawn_locations_x_loop_skip_water_post_pop:

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
	ld c, l

	; number of water locations:
	ld hl, (tmp_enemy_pcg_water_loc_ptr)
	ld de, -(buffer_4096 + 512)
	add hl, de
	sra h
	rr l
	ld b, l

	; number of ceiling locations:
	ld hl, (tmp_enemy_pcg_ceiling_loc_ptr)
	ld de, -(buffer_4096 + 1024)
	add hl, de
	sra h
	rr l
	ld a, l
	ld (tmp_enemy_pcg_n_ceiling_locs), a
	ret


;-----------------------------------------------
pcg__find_enemy_spawn_location_empty_p_macro: macro
	ld a, (hl)
	or a
	jr z, pcg__find_enemy_spawn_location_empty_p_macro_end
	ex de, hl
		ld hl, (current_room__collision_ptr)
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
		ld hl, (current_room__collision_ptr)
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
		ld hl, (current_room__collision_ptr)
		ADD_HL_A
		ld a, (hl)		
	ex de, hl
	cp 2
	endm


;-----------------------------------------------
pcg__find_enemy_spawn_location_water_p_macro: macro
	ld a, (hl)
	ex de, hl
		ld hl, (current_room__collision_ptr)
		ADD_HL_A
		ld a, (hl)		
	ex de, hl
	cp 4
	endm
