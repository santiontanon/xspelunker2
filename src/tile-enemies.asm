CARNIVORE_PLANT_MAX_TONGUE_LENGTH: equ 16
CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR: equ tile_enemy_work_memory + 1 + CARNIVORE_PLANT_MAX_TONGUE_LENGTH * 3
; workmemory usage:
; - 1 byte for tongue length
; - each tongue segment has 3 bytes: background (to undraw), tile, direction of next
; - 2 bytes at the end for room tile ptr of the current tongue tip


;-----------------------------------------------
; input:
; - hl: object ptr + 1
update_tile_objects_enemy_carnivore_plant:
	dec hl
	push hl
	pop ix

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH)
	or a
	jp z, update_tile_objects_4x4_enemy_killed

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	dec a
	jr z, update_tile_objects_enemy_carnivore_plant_fire_spores
	dec a
	jr z, update_tile_objects_enemy_carnivore_plant_tongue
	dec a
	jp z, update_tile_objects_enemy_carnivore_plant_tongue_retract

update_tile_objects_enemy_carnivore_plant_idle
	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 12
	jp nz, update_tile_objects_loop_continue
	; change state:
	call random_a
	and #01
	inc a
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), a  ; fire spores or tongue
; 	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 2  ; tongue
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld hl, tile_enemy_work_memory
	ld (hl), 0  ; tongue length = 0
	jp update_tile_objects_loop_force_redraw_and_continue

update_tile_objects_enemy_carnivore_plant_fire_spores
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #01
	jr nz, update_tile_objects_enemy_carnivore_plant_fire_spores_continue
	; fire a bullet:
	call ptr_to_new_sprite_enemy
	jr nz, update_tile_objects_enemy_carnivore_plant_fire_spores_continue
	ld (hl), 0
	inc hl
	ld (hl), ENEMY_PARABOLA_BULLET
	inc hl
	ld (hl), 0  ; pixel x
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	inc a
	ld (hl), a
	inc hl
	ld (hl), 0  ; pixel y
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc a
	inc a
	ld (hl), a
	inc hl
	ld c, 5
	call random_modulo
	add a, -2
	ld (hl), a
	inc hl
	ld (hl), 0  ; state timer

	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
update_tile_objects_enemy_carnivore_plant_fire_spores_continue:
	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 16
	jp nz, update_tile_objects_loop_continue
update_tile_objects_enemy_carnivore_plant_switch_to_idle:
	; change state:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; idle
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	xor a
	ld (tile_enemy_work_memory), a
	jp update_tile_objects_loop_force_redraw_and_continue

update_tile_objects_enemy_carnivore_plant_tongue:
	; elongate the tongue by one position:
	ld hl, tile_enemy_work_memory
	ld a, (hl)
	or a
	jr nz, update_tile_objects_enemy_carnivore_plant_tongue_not_first
	; first:
	ld (hl), 2  ; we start with tongue length of 2
	inc hl
	ld (hl), 0  ; background
	inc hl
	ld (hl), 68
	inc hl
	ld (hl), PCG_DIRECTION_UP_BIT
	inc hl
	ld (hl), 0  ; background
	inc hl
	ld (hl), 89
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	call get_room_tile_ptr
	inc hl
	ld a, (current_room__width)
	ADD_HL_A
	ld (CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR), hl
	jp update_tile_objects_loop_force_redraw_and_continue
update_tile_objects_enemy_carnivore_plant_tongue_not_first:
	cp CARNIVORE_PLANT_MAX_TONGUE_LENGTH
	jr nz, update_tile_objects_enemy_carnivore_plant_tongue_elongate
update_tile_objects_enemy_carnivore_plant_tongue_stop_elongating:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 3  ; retract tongue
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	jp update_tile_objects_loop_continue
update_tile_objects_enemy_carnivore_plant_tongue_elongate:
; 	inc a
; 	ld (hl), a
; 	dec a
	ld c, a
	add a, a
	add a, c
	dec a
	ADD_HL_A  ; hl now has the pointer to the last tile we wrote to the tongue
	ld de, (CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR)
	; pick a random direction that is empty and go there:
	ld b, 4  ; max retries
update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop:
	ld a, (tile_enemy_work_memory)
	cp 3
	jr nz, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue
	; the first time, it must go up:
	ld a, PCG_DIRECTION_UP_BIT
	jr update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue2
update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue:
	; chance of going towards player:
	call random_a
	and #03
	jr z, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_to_player_x
	dec a
	jr z, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_to_player_y
	jr update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue2
update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_to_player_x:
	; try to go towards the player in x:
	ld a, (player_x + 1)
	sub (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld a, PCG_DIRECTION_LEFT_BIT
	jr c, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue3
	ld a, PCG_DIRECTION_RIGHT_BIT
	jr update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue3
update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_to_player_y:
	; try to go towards the player in y:
	ld a, (player_y + 1)
	sub (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	ld a, PCG_DIRECTION_UP_BIT
	jr c, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue3
	ld a, PCG_DIRECTION_DOWN_BIT
	jr update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue3

update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue2:
	call random_a
	and #03
update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue3:
	ld c, a
	push de
		call room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr
		ld a, (de)  ; a = background tile where we want to move
		or a  ; is it background?
		jr z, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_end
		; check if it's background/rope
		push de
			ld de, current_room__collision_table
			ADD_DE_A
			ld a, (de)
		pop de
		or a  ; background
		jr z, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_end
		cp 5  ; rope
		jr z, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_end
	pop de
	djnz update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop
	; we could not elongate, we are done:
	jr update_tile_objects_enemy_carnivore_plant_tongue_stop_elongating
update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_end:
	pop af  ; just undo the "pop de"
	; Here: 
	; - hl: ptr to the tongue list pointing a the last tile we wrote
	; - c: direction we want to go
	; - de: next ptr to the tip
	ld (CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR), de
	dec hl
	dec hl
	ld b, (hl)  ; previous direction
	inc hl
	inc hl
	call update_tile_objects_enemy_carnivore_plant_tongue_midpiece
	ld (hl), a  ; update the last tile to twist in the correct new direction
	inc hl
	ld (hl), c  ; new direction
	inc hl
	ld a, (de)
	ld (hl), a  ; background
	inc hl
	call update_tile_objects_enemy_carnivore_plant_tongue_tip
	ld (hl), a  ; new last tile
	ld hl, tile_enemy_work_memory
	inc (hl)
	jp update_tile_objects_loop_force_redraw_and_continue

update_tile_objects_enemy_carnivore_plant_tongue_retract:
	; we need to undraw first
	ld a, (tile_enemy_work_memory)
	cp 2
	jp z, update_tile_objects_enemy_carnivore_plant_switch_to_idle
	call room_undraw_tile_objects
	ld hl, tile_enemy_work_memory
	ld a, (hl)
	or a
	jr z, update_tile_objects_enemy_carnivore_plant_tongue_retract_continue
	dec (hl)
	ld a, (hl)
	dec a
	ld c, a
	add a, a
	add a, c
	ADD_HL_A  ; hl now has the pointer to the last tile we wrote to the tongue
	ld c, (hl)  ; direction
	inc hl
	inc hl
	call update_tile_objects_enemy_carnivore_plant_tongue_tip
	ld (hl), a
update_tile_objects_enemy_carnivore_plant_tongue_retract_continue:
	call room_render_tile_objects
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	jp update_tile_objects_loop_continue


update_tile_objects_enemy_carnivore_plant_tongue_midpiece:
	; carnivore_plants_tongue_midpieces + previous * 4 + current
	ld a, b
	add a, a
	add a, a
	add a, c
	push hl
		ld hl, carnivore_plants_tongue_midpieces
		ADD_HL_A
		ld a, (hl)
	pop hl
	ret


update_tile_objects_enemy_carnivore_plant_tongue_tip:
	push hl
		ld hl, carnivore_plants_tongue_tips
		ld b, 0
		add hl, bc
		ld a, (hl)
	pop hl
	ret

carnivore_plants_tongue_midpieces:
	db 70, 87, 0, 88  ; down -> *
	db 72, 69, 88, 0  ; right -> *
	db 0, 71, 70, 72  ; up -> *
	db 71, 0, 87, 69  ; left -> *


carnivore_plants_tongue_tips:
	db 68, 90, 89, 79


;-----------------------------------------------
update_tile_objects_2x2_enemy_killed:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	push bc
		push ix
			call spawn_explosion
			call room_undraw_tile_objects
		pop hl
		push hl
			call delete_tile_object_in_hl
			call room_render_tile_objects
			; force redraw:
			ld hl, redraw_flags
			set ROOM_REDRAW_FLAG_BIT, (hl)
		pop hl
	pop bc
	push hl
		ld hl, enemy_maybe_spawn_drop
		ld e, ENEMIES_PAGE
		call call_hl_in_page_e_8000
	pop hl
	pop af  ; we do an extra pop, since we are skipping the one at update_tile_objects_loop_continue
	jp update_tile_objects_loop


;-----------------------------------------------
update_tile_objects_4x4_enemy_killed:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	push bc
		push ix
			call spawn_big_explosion
			call room_undraw_tile_objects
		pop hl
		push hl
			call delete_tile_object_in_hl
			call room_render_tile_objects
			; force redraw:
			ld hl, redraw_flags
			set ROOM_REDRAW_FLAG_BIT, (hl)
		pop hl
	pop bc
	push hl
		; chance of 3 drops:
		inc c
		push bc
			ld hl, enemy_maybe_spawn_drop
			ld e, ENEMIES_PAGE
			call call_hl_in_page_e_8000
		pop bc
		dec c
		inc b
		inc b
		push bc
			ld hl, enemy_maybe_spawn_drop
			ld e, ENEMIES_PAGE
			call call_hl_in_page_e_8000
		pop bc
		inc c
		inc c
		ld hl, enemy_maybe_spawn_drop
		ld e, ENEMIES_PAGE
		call call_hl_in_page_e_8000
	pop hl
	pop af  ; we do an extra pop, since we are skipping the one at update_tile_objects_loop_continue
	jp update_tile_objects_loop


;-----------------------------------------------
room_render_tile_objects_render_enemy_carnivore_plant:
	inc hl
	ld c, (hl)  ; x
	ld ixl, c
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld a, (hl)  ; state
	push af
		call get_room_tile_ptr
		ld bc, #0404
		ld de, tile_object_carnivore_plant
	pop af
	or a
	jp z, room_render_tile_objects_render_loop_y
	ld de, tile_object_carnivore_plant_open
room_render_tile_objects_render_enemy_carnivore_plant_loop_y:
	push bc
	push hl
room_render_tile_objects_render_enemy_carnivore_plant_loop_x:
		ld a, (de)
		ld (hl), a
		inc de
		inc hl
		dec c
		jr nz, room_render_tile_objects_render_enemy_carnivore_plant_loop_x
	pop hl
	pop bc
	ld a, (current_room__width)
	ADD_HL_A
	djnz room_render_tile_objects_render_enemy_carnivore_plant_loop_y

	; ptr to tongue start:
	ld a, (current_room__width)
	ld c, a
	ld b, 0
	or a
	sbc hl, bc
	or a
	sbc hl, bc
	inc hl
	ex de, hl

	; draw tongue:
	ld hl, tile_enemy_work_memory
	ld a, (hl)
	or a
	jp z, room_render_tile_objects_loop_continue
	ld b, a
	inc hl
room_render_tile_objects_render_enemy_carnivore_plant_loop_tongue:
	ld a, (de)
	ld (hl), a  ; save background
	inc hl
	ld a, (hl)
	ld (de), a  ; draw
	inc hl
	ld a, (hl)  ; direction
	inc hl
	call room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr
	djnz room_render_tile_objects_render_enemy_carnivore_plant_loop_tongue

	jp room_render_tile_objects_loop_continue


;-----------------------------------------------
; input:
; - de: ptr
; - a: direction
; output:
; - de: updated pter moved one step in direction a
room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr:
	cp PCG_DIRECTION_LEFT_BIT
	jr z, room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr_left
	cp PCG_DIRECTION_UP_BIT
	jr z, room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr_up
	cp PCG_DIRECTION_RIGHT_BIT
	jr z, room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr_right
	; down:
	ld a, (current_room__width)
	ADD_DE_A
	ret

room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr_left:
	dec de
	ret

room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr_up:
	push bc
		ld a, (current_room__width)
		ld b, 0
		ld c, a
		or a
		ex de, hl
			sbc hl, bc
		ex de, hl
	pop bc
	ret

room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr_right:
	inc de
	ret


;-----------------------------------------------
tile_object_carnivore_plant:
	db 0, 0, 0, 0
	db 0, 64, 65, 0
	db 80, 81, 82, 92  ; We use a "92", which is an empty tile, so that the player can hit that spot
	db 73, 74, 75, 76

tile_object_carnivore_plant_open:
	db 0, 0, 0, 0
	db 66, 0, 0, 67
	db 83, 84, 85, 86
	db 77, 78, 75, 76


;-----------------------------------------------
room_render_tile_objects_undraw_enemy_carnivore_plant:
	; undraw tongue:
	inc hl
	ld c, (hl)  ; x
	inc hl
	ld b, (hl)  ; y
	push bc
		; ptr to tongue start:
		inc c
		inc b
		inc b
		call get_room_tile_ptr
		ex de, hl

		ld hl, tile_enemy_work_memory
		ld a, (hl)
		or a
		jp z, room_render_tile_objects_undraw_enemy_carnivore_plant_continue
		ld b, a
		inc hl
	room_render_tile_objects_undraw_enemy_carnivore_plant_loop_tongue:
		ld a, (hl)
		ld (de), a  ; restore background
		inc hl
		inc hl
		ld a, (hl)  ; direction
		inc hl
		call room_render_tile_objects_render_enemy_carnivore_plant_next_tongue_piece_ptr
		djnz room_render_tile_objects_undraw_enemy_carnivore_plant_loop_tongue

room_render_tile_objects_undraw_enemy_carnivore_plant_continue:
	pop bc
	; undraw the main body:
	call get_room_tile_ptr
	ld bc, #0404
	jp room_undraw_tile_objects_delete_object_loop_y



;-----------------------------------------------
; input:
; - e: tile idx that was hit
; - iyl: collision ID
; - iyh: weapon damage
enemy_carnivore_plant_hit:
	call find_tile_enemy_ptr
	ret nz
	ld a, e
	; these are tongue tiles, just retract the tongue: 68, 69, 70, 71, 72, 79, 87, 88, 89, 90
	cp 68
	jr c, enemy_carnivore_plant_hit_body
	cp 73
	jr c, enemy_carnivore_plant_hit_tongue
	cp 79
	jr z, enemy_carnivore_plant_hit_tongue
	cp 92
	jr z, enemy_carnivore_plant_hit_body
	cp 87
	jr nc, enemy_carnivore_plant_hit_tongue
enemy_carnivore_plant_hit_body:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH)
	sub iyh
	ld (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH), a
	jr z, enemy_carnivore_plant_hit_body_dead
	jr nc, enemy_carnivore_plant_hit_continue
enemy_carnivore_plant_hit_body_dead:
	; tile enemy killed!
	ld (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH), 0
	jr enemy_carnivore_plant_hit_continue
enemy_carnivore_plant_hit_tongue:
	; retract!
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	cp 3
	jr z, enemy_carnivore_plant_hit_continue  ; already retracting!
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 3  ; retract tongue
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
enemy_carnivore_plant_hit_continue:
	ld a, iyl
	ld (tile_enemy_last_collision_id), a

	ld hl, SFX_enemy_hit
	jp play_SFX_with_high_priority


;-----------------------------------------------
update_tile_objects_enemy_bee_hive:
	dec hl
	push hl
	pop ix
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH)
	or a
	jp z, update_tile_objects_2x2_enemy_killed	

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #3f
	cp #3f
	jp nz, update_tile_objects_loop_continue
	; check if player is closeby:
	ld a, (player_x + 1)
	sub (ix + ROOM_TILE_OBJECT_STRUCT_X)
	cp 20
	jp p, update_tile_objects_loop_continue
	cp -20
	jp m, update_tile_objects_loop_continue
	ld a, (player_y + 1)
	sub (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	cp 16
	jp p, update_tile_objects_loop_continue
	cp -16
	jp m, update_tile_objects_loop_continue

	; spawn a bee:
	call ptr_to_new_sprite_enemy
	jp nz, update_tile_objects_loop_continue
	ld (hl), 0
	inc hl
	ld (hl), ENEMY_BEE
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld (hl), a  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)	
	ld (hl), a  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld (hl), 0  ; health	
	jp update_tile_objects_loop_continue


;-----------------------------------------------
update_tile_objects_enemy_ant_colony:
	dec hl
	push hl
	pop ix
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH)
	or a
	jp z, update_tile_objects_2x2_enemy_killed	

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #3f
	cp #3f
	jp nz, update_tile_objects_loop_continue

	; spawn an ant:
	call ptr_to_new_sprite_enemy
	jp nz, update_tile_objects_loop_continue
	ld (hl), 0
	inc hl
	ld (hl), ENEMY_ANT
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld (hl), a  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)	
	ld (hl), a  ; tile y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld (hl), 0  ; health	
	jp update_tile_objects_loop_continue


;-----------------------------------------------
; input:
; - e: tile idx that was hit
; - iyl: collision ID
; - iyh: weapon damage
enemy_ant_colony_hit:
enemy_bee_hive_hit:
	call find_tile_enemy_ptr
	ret nz
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH)
	sub iyh
	ld (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH), a
	jr z, enemy_ant_colony_hit_dead
	jr nc, enemy_ant_colony_hit_continue
enemy_ant_colony_hit_dead:
	; tile enemy killed!
	ld (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH), 0
enemy_ant_colony_hit_continue:
	ld a, iyl
	ld (tile_enemy_last_collision_id), a

	ld hl, SFX_enemy_hit
	jp play_SFX_with_high_priority


;-----------------------------------------------
; output:
; - ix: ptr
; - z: found
; - nz: not found
find_tile_enemy_ptr:
	ld ix, current_room__tile_objects
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
find_tile_enemy_ptr_loop:
	ld a, (ix)
	cp #ff
	jr z, find_tile_enemy_ptr_not_found
	cp #fe
	jr z, find_tile_enemy_ptr_not_found
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_ENEMY_CARNIVORE_PLANT
	ret z
	cp TAG_ENEMY_BEE_HIVE
	ret z
	cp TAG_ENEMY_ANT_COLONY
	ret z
	add ix, bc
	jr find_tile_enemy_ptr_loop
find_tile_enemy_ptr_not_found:
	or 1
	ret
