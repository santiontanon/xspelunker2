;-----------------------------------------------
pcg_generate_room__spawn_enemies:
	; ...
	call pcg__find_enemy_spawn_locations
; 	call pcg_generate_room__spawn_snake
; 	call pcg_generate_room__spawn_snake
; 	call pcg_generate_room__spawn_snake
; 	call pcg_generate_room__spawn_snake
; 	call pcg_generate_room__spawn_fish
; 	call pcg_generate_room__spawn_fish
; 	call pcg_generate_room__spawn_bat
; 	call pcg_generate_room__spawn_bat
; 	call pcg_generate_room__spawn_bat_aggressive
; 	call pcg_generate_room__spawn_bat_aggressive
; 	call pcg_generate_room__spawn_skeleton
; 	call pcg_generate_room__spawn_skeleton
; 	call pcg_generate_room__spawn_skeleton_thrower1
; 	call pcg_generate_room__spawn_skeleton_thrower2
	call pcg_generate_room__spawn_carnivore_plant
	ret


;-----------------------------------------------
; input:
; - hl: ptr to positions
; - a: position index
; - e: number of positions total we have in this buffer of positions
; output:
; - hl: ptr
; - z: ptr found
; - nz: no ptr found
pcg_generate_room__spawn_enemy_get_new_ptr:
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
			jr z, pcg_generate_room__spawn_enemy_get_new_ptr_continue
			ld c, a
			ld b, 0
			sla c
			rl b
			ldir
pcg_generate_room__spawn_enemy_get_new_ptr_continue:
			; find a new enemy ptr:
			call ptr_to_new_sprite_enemy
		pop de
	pop bc
	ret


;-----------------------------------------------
; input:
; - c: number of positions available (in buffer_4096)
pcg_generate_room__spawn_snake:
	ld a, c
	or a
	ret z  ; no positions available
	call random_modulo
	ld hl, buffer_4096
	ld e, c
	call pcg_generate_room__spawn_enemy_get_new_ptr
	ex af, af'  ; preserve the z flag
	dec c
	ex af, af'
	ret nz
; 	ld (hl), ENEMY_SNAKE
; 	ld (hl), ENEMY_SNAKE_DASHER
	ld (hl), ENEMY_SNAKE_POISON
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
pcg_generate_room__spawn_fish:
	ld a, b
	or a
	ret z  ; no positions available
	push bc
		ld c, b
		call random_modulo
	pop bc
	ld hl, buffer_4096 + 512
	ld e, b
	call pcg_generate_room__spawn_enemy_get_new_ptr
	ex af, af'  ; preserve the z flag
	dec b
	ex af, af'
	ret nz
; 	ld (hl), ENEMY_FISH
	ld (hl), ENEMY_FISH_JUMPER
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
	ld a, c
	or a
	ret z  ; no positions available
	call random_modulo
	ld hl, buffer_4096
	ld e, c
	call pcg_generate_room__spawn_enemy_get_new_ptr
	ex af, af'  ; preserve the z flag
	dec c
	ex af, af'
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
pcg_generate_room__spawn_skeleton_thrower1:
	ld ixl, ENEMY_SKELETON_THROWER1
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton_thrower2:
	ld ixl, ENEMY_SKELETON_THROWER2
	jr pcg_generate_room__spawn_skeleton_continue
pcg_generate_room__spawn_skeleton:
	ld ixl, ENEMY_SKELETON
pcg_generate_room__spawn_skeleton_continue:
	ld a, c
	or a
	ret z  ; no positions available
	call random_modulo
	ld hl, buffer_4096
	ld e, c
	call pcg_generate_room__spawn_enemy_get_new_ptr
	ex af, af'  ; preserve the z flag
	dec c
	ex af, af'
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
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld (hl), 2  ; health
	ret


;-----------------------------------------------
; input:
; - c: number of positions available (in buffer_4096)
pcg_generate_room__spawn_carnivore_plant:
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
; This version iterates over all positions accumulates all that match enemy spawn positions in a list
; output:
; - c: number of positions found over platforms (stored starting at buffer_4096)
; - b: number of positions found in the water (stored starting at buffer_4096 + 512)
pcg__find_enemy_spawn_locations:
	ld hl, buffer_4096
	ld (tmp_enemy_pcg_platform_loc_ptr), hl
	ld hl, buffer_4096 + 512
	ld (tmp_enemy_pcg_water_loc_ptr), hl
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
	; search from c, b  ->  iyl, iyh in increments of 2 by 2
	; The maximum number of positions searched is thus:
	; - ((128 - 8) / 2) * ((24 - 8) / 2) = 60 * 8 = 480
	; - and at most half could be matches (as ther emust be platforms underneath).
pcg__find_enemy_spawn_locations_y_loop:
	push bc
	push hl
pcg__find_enemy_spawn_locations_x_loop:
		; see if the position matches a "platform location":
		pcg__find_enemy_spawn_location_empty_p_macro
		jp nz,  pcg__find_enemy_spawn_locations_x_loop_skip_post_pop
		inc hl
		pcg__find_enemy_spawn_location_empty_p_macro
		dec hl
		jp nz,  pcg__find_enemy_spawn_locations_x_loop_skip_post_pop

		push hl
			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_empty_p_macro
			jr nz,  pcg__find_enemy_spawn_locations_x_loop_skip
			inc hl
			pcg__find_enemy_spawn_location_empty_p_macro
			dec hl
			jr nz,  pcg__find_enemy_spawn_locations_x_loop_skip

			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_platform_p_macro
			jr nz,  pcg__find_enemy_spawn_locations_x_loop_skip
			inc hl
			pcg__find_enemy_spawn_location_platform_p_macro
			dec hl
			jr nz,  pcg__find_enemy_spawn_locations_x_loop_skip
			push hl
				ld hl, (tmp_enemy_pcg_platform_loc_ptr)
				ld (hl), c
				inc hl
				ld (hl), b
				inc hl
				ld (tmp_enemy_pcg_platform_loc_ptr), hl
			pop hl
pcg__find_enemy_spawn_locations_x_loop_skip:
		pop hl
pcg__find_enemy_spawn_locations_x_loop_skip_post_pop:

		; See if the position matches a "water location":
		pcg__find_enemy_spawn_location_water_p_macro
		jp nz,  pcg__find_enemy_spawn_locations_x_loop_skip_water_post_pop
		inc hl
		pcg__find_enemy_spawn_location_water_p_macro
		dec hl
		jr nz,  pcg__find_enemy_spawn_locations_x_loop_skip_water_post_pop
		push hl
			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_water_p_macro
			jr nz,  pcg__find_enemy_spawn_locations_x_loop_skip_water
			inc hl
			pcg__find_enemy_spawn_location_water_p_macro
			dec hl
			jr nz,  pcg__find_enemy_spawn_locations_x_loop_skip_water

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
pcg__find_enemy_spawn_location_water_p_macro: macro
	ld a, (hl)
	ex de, hl
		ld hl, (current_room__collision_ptr)
		ADD_HL_A
		ld a, (hl)		
	ex de, hl
	cp 4
	endm
