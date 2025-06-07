;-----------------------------------------------
pcg_generate_room__spawn_enemies:
	; ...
	call pcg__find_enemy_spawn_locations_over_platform
	call pcg_generate_room__spawn_snake
	call pcg_generate_room__spawn_snake
	call pcg_generate_room__spawn_snake
	call pcg_generate_room__spawn_snake
	ret


;-----------------------------------------------
; input:
; - c: number of positions available (in buffer_4096)
pcg_generate_room__spawn_snake:
	ld a, c
	or a
	ret z  ; no positions available
	call pcg_random_modulo
	ld e, a
	ld d, 0
	ld hl, buffer_4096
	add hl, de
	add hl, de
	ld e, (hl)
	inc hl
	ld d, (hl)
	; remove the position (shift all the positions left):
	push bc
	push de
		ld e, l
		ld d, h
		dec de
		inc hl
		ld b, 0
		sla c
		rl b
		ldir

		; find a new enemy ptr:
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	ex af, af'  ; preserve the z flag
	dec c
	ex af, af'
	ret nz
	ld (hl), ENEMY_SNAKE_DASHER
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
	ld (hl), 1  ; health
	ret


;-----------------------------------------------
; This version iterates over all positions accumulates all that match enemy spawn positions in a list
; output:
; - c: number of positions found
pcg__find_enemy_spawn_locations_over_platform:
	ld ix, buffer_4096  ; ptr to the next position to store
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
pcg__find_enemy_spawn_locations_over_platform_y_loop:
	push bc
	push hl
pcg__find_enemy_spawn_locations_over_platform_x_loop:
		; see if the position matches:
		pcg__find_enemy_spawn_location_empty_p_macro
		jp nz,  pcg__find_enemy_spawn_locations_over_platform_x_loop_skip_post_pop
		inc hl
		pcg__find_enemy_spawn_location_empty_p_macro
		dec hl
		jr nz,  pcg__find_enemy_spawn_locations_over_platform_x_loop_skip_post_pop

		push hl
			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_empty_p_macro
			jr nz,  pcg__find_enemy_spawn_locations_over_platform_x_loop_skip
			inc hl
			pcg__find_enemy_spawn_location_empty_p_macro
			dec hl
			jr nz,  pcg__find_enemy_spawn_locations_over_platform_x_loop_skip

			ld a, (current_room__width)
			ADD_HL_A
			pcg__find_enemy_spawn_location_platform_p_macro
			jr nz,  pcg__find_enemy_spawn_locations_over_platform_x_loop_skip
			inc hl
			pcg__find_enemy_spawn_location_platform_p_macro
			dec hl
			jr nz,  pcg__find_enemy_spawn_locations_over_platform_x_loop_skip
			ld (ix), c
			inc ix
			ld (ix), b
			inc ix
pcg__find_enemy_spawn_locations_over_platform_x_loop_skip:
		pop hl
pcg__find_enemy_spawn_locations_over_platform_x_loop_skip_post_pop:

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
		jp c, pcg__find_enemy_spawn_locations_over_platform_x_loop
	pop hl
	pop bc
	ld a, (current_room__width)
	ADD_HL_A
	inc b
	ld a, b
	cp iyh
	jp c, pcg__find_enemy_spawn_locations_over_platform_y_loop

	push ix
	pop hl
	ld bc, -buffer_4096
	add hl, bc
	sra h
	rr l
	ld c, l
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
