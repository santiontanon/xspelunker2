CARNIVORE_PLANT_MAX_TONGUE_LENGTH: equ 16
CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR_OFFSET: equ 1 + CARNIVORE_PLANT_MAX_TONGUE_LENGTH * 3
CARNIVORE_PLANT_WORKMEMORY_USAGE: equ 1 + CARNIVORE_PLANT_MAX_TONGUE_LENGTH * 3 + 2  ; 51 bytes
; workmemory usage:
; - 1 byte for tongue length
; - each tongue segment has 3 bytes: background (to undraw), tile, direction of next
; - 2 bytes at the end for room tile ptr of the current tongue tip

LAVA_GENERATOR_MAX_LAVA_LENGTH: equ 8
LAVA_GENERATOR_WORKMEMORY_USAGE: equ LAVA_GENERATOR_MAX_LAVA_LENGTH * 2  ; 16

STONE_OWL_WORKMEMORY_USAGE: equ 15


;-----------------------------------------------
; input:
; - hl: object ptr + 1
update_tile_objects_enemy_carnivore_plant:
	dec hl
	push hl
	pop ix
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
	push bc
	pop iy  ; iy points to the work memory

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
	ld (iy), 0  ; tongue length = 0
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
	ld (iy), a
	jp update_tile_objects_loop_force_redraw_and_continue

update_tile_objects_enemy_carnivore_plant_tongue:
	; elongate the tongue by one position:
	push iy
	pop hl  ; hl = ptr to work memory
	ld a, (hl)
	or a
	jr nz, update_tile_objects_enemy_carnivore_plant_tongue_not_first
	; first:
	ld (iy), 2  ; we start with tongue length of 2
	ld (iy + 1), 0  ; background
	ld (iy + 2), 68
	ld (iy + 3), PCG_DIRECTION_UP_BIT
	ld (iy + 4), 0  ; background
	ld (iy + 5), 89
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	call get_room_tile_ptr
	inc hl
	ld a, (current_room__width)
	ADD_HL_A
	ld (iy + CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR_OFFSET), l
	ld (iy + CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR_OFFSET + 1), h
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
	ld e, (iy + CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR_OFFSET)
	ld d, (iy + CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR_OFFSET + 1)
	; pick a random direction that is empty and go there:
	ld b, 4  ; max retries
update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop:
	ld a, (iy)
	cp 2
	jr nz, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue
	; the first time, it must go up:
	ld a, PCG_DIRECTION_UP_BIT
	jr update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue2
update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue:
	; chance of going towards player:
	call random_a
	and #03
	jr z, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_continue2
	call random_a
	and #01
	jr z, update_tile_objects_enemy_carnivore_plant_tongue_elongate_loop_to_player_y
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
	ld (iy + CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR_OFFSET), e
	ld (iy + CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR_OFFSET + 1), d
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
	inc (iy)
	jp update_tile_objects_loop_force_redraw_and_continue

update_tile_objects_enemy_carnivore_plant_tongue_retract:
	; we need to undraw first
	ld a, (iy)
	cp 2
	jp z, update_tile_objects_enemy_carnivore_plant_switch_to_idle
	push iy
		call room_undraw_tile_objects
	pop iy
	ld a, (iy)
	or a
	jr z, update_tile_objects_enemy_carnivore_plant_tongue_retract_continue
	dec (iy)
	ld a, (iy)
	push iy
	pop hl
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
; input:
; - hl: object ptr + 1
room_render_tile_objects_render_enemy_carnivore_plant:
	dec hl
	push hl
	pop ix
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)  ; state
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
	ld l, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
	ld h, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
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
	dec hl
	push hl
	pop ix
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	push bc
		; ptr to tongue start:
		inc c
		inc b
		inc b
		call get_room_tile_ptr
		ex de, hl

		ld l, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
		ld h, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
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
	and #1f
	cp #1f
	jp nz, update_tile_objects_loop_continue

	; spawn an ant:
	ld iyl, ENEMY_ANT  
	ld iyh, 2  ; hit points
update_tile_objects_enemy_ant_colony_spawn:
	; how many ants do we already have?
	call update_tile_objects_enemy_ant_colony_count_ants
	ld a, c
	cp 2  ; max ants
	jp nc, update_tile_objects_loop_continue  ; there are already too many

	call ptr_to_new_sprite_enemy
	jp nz, update_tile_objects_loop_continue
	ld (hl), 0
	inc hl
	ld a, iyl
	ld (hl), a  ; type
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	inc a
	ld (hl), a  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)	
	ld (hl), a  ; tile y
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE)  ; alternate between ants walking left/right
	and #01
	ld (hl), a  ; state (walk left/right)
	inc hl
	ld (hl), 0  ; state timer
	inc hl
	ld (hl), #ff  ; hit ID
	inc hl
	ld a, iyh
	ld (hl), a  ; health
	jp update_tile_objects_loop_continue


;-----------------------------------------------
update_tile_objects_enemy_ant_colony2:
	dec hl
	push hl
	pop ix
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH)
	or a
	jp z, update_tile_objects_2x2_enemy_killed	

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #1f
	cp #1f
	jp nz, update_tile_objects_loop_continue

	; spawn an ant:
	ld iyl, ENEMY_ANT2
	ld iyh, 4  ; hit points
	jr update_tile_objects_enemy_ant_colony_spawn


;-----------------------------------------------
; return:
; - c: number of ants currently in the screen
update_tile_objects_enemy_ant_colony_count_ants:
	ld hl, current_room__sprite_enemies
	ld de, ROOM_OBJECT_STRUCT_SIZE
	ld c, 0  ; number of ants
update_tile_objects_enemy_ant_colony_count_ants_loop:
	ld a, (hl)
	cp #ff  ; empty spot
	ret z
	cp #fe  ; sentinel
	ret z
	inc hl
	ld a, (hl)
	dec hl
	cp ENEMY_ANT
	jr z, update_tile_objects_enemy_ant_colony_count_ants_ant
	cp ENEMY_ANT2
	jr z, update_tile_objects_enemy_ant_colony_count_ants_ant
	add hl, de
	jp update_tile_objects_enemy_ant_colony_count_ants_loop
update_tile_objects_enemy_ant_colony_count_ants_ant:
	inc c
	add hl, de
	jp update_tile_objects_enemy_ant_colony_count_ants_loop


;-----------------------------------------------
; input:
; - e: tile idx that was hit
; - iyl: collision ID
; - iyh: weapon damage
enemy_stone_owl_hit:
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
update_tile_objects_enemy_imp_generator:
	dec hl
	push hl
	pop ix

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #7f
	cp #7f
	jp nz, update_tile_objects_loop_continue

	; spawn an imp:
	ld iyl, ENEMY_FIRE_IMP
	ld iyh, 4  ; hit points
update_tile_objects_enemy_imp_generator_spawn:
	; how many ants do we already have?
	call update_tile_objects_enemy_ant_colony_count_ants
	ld a, c
	cp 2  ; max ants
	jp nc, update_tile_objects_loop_continue  ; there are already too many

	call ptr_to_new_sprite_enemy
	jp nz, update_tile_objects_loop_continue
	ld (hl), 0
	inc hl
	ld a, iyl
	ld (hl), a  ; type
	inc hl
	ld (hl), 0
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	inc a
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
	ld a, iyh
	ld (hl), a  ; health
	jp update_tile_objects_loop_continue

update_tile_objects_enemy_imp_generator2:
	dec hl
	push hl
	pop ix

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #7f
	cp #7f
	jp nz, update_tile_objects_loop_continue

	; spawn an imp:
	ld iyl, ENEMY_FIRE_IMP2
	ld iyh, 8  ; hit points
	jr update_tile_objects_enemy_imp_generator_spawn

update_tile_objects_enemy_fireball_generator:
	dec hl
	push hl
	pop ix

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #3f
	cp #3f
	jp nz, update_tile_objects_loop_continue

	; spawn an imp:
	ld iyl, ENEMY_FIREBALL
	ld iyh, 8  ; hit points
	jr update_tile_objects_enemy_imp_generator_spawn


;-----------------------------------------------
; input:
; - hl: object ptr + 1
update_tile_objects_enemy_lava_generator:
	dec hl
	push hl
	pop ix

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)

	; state timer:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #3f
	cp 64 - 25
	jp c, update_tile_objects_loop_continue
	call room_render_tile_objects_render_enemy_lava_generator_internal
	ld hl, SFX_waterfall
	call play_SFX_with_high_priority
	jp update_tile_objects_loop_continue


;-----------------------------------------------
; input:
; - hl: object ptr + 1
room_render_tile_objects_undraw_enemy_lava_generator:
	dec hl
	push hl
	pop ix
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	or a
	call nz, room_render_tile_objects_undraw_enemy_lava_generator_internal
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; mark that we have to regrab the background
	jp room_undraw_tile_objects_loop_continue

room_render_tile_objects_undraw_enemy_lava_generator_internal:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
	inc c
	inc b
	call get_room_tile_ptr
	ld iyl, 8
	ld a, (current_room__width)
	dec a
	ld b, 0
	ld c, a
room_render_tile_objects_undraw_enemy_lava_generator_internal_loop_y:
	ld a, (de)
	ld (hl), a
	inc hl
	inc de
	ld a, (de)
	ld (hl), a
	inc de
	add hl, bc
	dec iyl
	jr nz, room_render_tile_objects_undraw_enemy_lava_generator_internal_loop_y
	ret


;-----------------------------------------------
; input:
; - hl: object ptr + 1
room_render_tile_objects_render_enemy_lava_generator:
	dec hl
	push hl
	pop ix

	call room_render_tile_objects_render_enemy_lava_generator_internal
	jp room_render_tile_objects_loop_continue



tile_object_lava_generator_gfx:
	db 176, 177, 177, 178
	db 179, 177, 177, 180

tile_object_lava_gfx:
	db 0, 0
	db 0, 0
	db 0, 0
	db 0, 0
	db 0, 0
	db 0, 0
	db 0, 0
	db 0, 0
	db 183, 183

	db 192, 192
	db 186, 192
	db 192, 192
	db 192, 192
	db 192, 186
	db 192, 192
	db 192, 192
	db 186, 186

	db 192, 192
	db 186, 192
	db 192, 192
	db 192, 192
	db 192, 186
	db 186, 192
	db 192, 192
	db 186, 186

	db #ff


room_render_tile_objects_render_enemy_lava_generator_internal:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	or a
	jr nz, room_render_tile_objects_render_enemy_lava_generator_continue
	; the first time, draw the mouth and store the background in the work memory:
	call room_render_tile_objects_render_enemy_lava_generator_draw_mouth
	call room_render_tile_objects_render_enemy_lava_generator_save_bg
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 1  ; mark that we have already saved the background
room_render_tile_objects_render_enemy_lava_generator_continue:
	; start by restoring the background:
	call room_render_tile_objects_undraw_enemy_lava_generator_internal
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	; 0 - 128-25: nothing
	; 128-25 - 128: lava starts falling
	and #3f
	cp 64 - 25
	ret c  ; nothing to draw:

	; compute the start of the lava gfx table to use:
	sub 63
	neg
	add a, a
	ld de, tile_object_lava_gfx
	ADD_DE_A

	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	exx
		ld l, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
		ld h, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
	exx
	inc c
	inc b
	call get_room_tile_ptr
	ld iyl, 8
	ld a, (current_room__width)
	dec a
	ld b, 0
	ld c, a
room_render_tile_objects_render_enemy_lava_generator_loop_y:
	ld a, (de)
	cp #ff
	jr z, room_render_tile_objects_render_enemy_lava_generator_loop_y_done
	or a
	jr nz, room_render_tile_objects_render_enemy_lava_generator_loop_y_continue
	; get from background:
	exx
		ld a, (hl)
		inc hl
	exx
	ld (hl), a
	inc hl
	inc de
	exx
		ld a, (hl)
		inc hl
	exx
	ld (hl), a
	jr room_render_tile_objects_render_enemy_lava_generator_loop_y_continue2

room_render_tile_objects_render_enemy_lava_generator_loop_y_continue:
	ld (hl), a
	inc de
	inc hl
	ld a, (de)
	ld (hl), a
	exx
		inc hl
		inc hl
	exx
room_render_tile_objects_render_enemy_lava_generator_loop_y_continue2:
	inc de
	add hl, bc
	dec iyl
	jr nz, room_render_tile_objects_render_enemy_lava_generator_loop_y
room_render_tile_objects_render_enemy_lava_generator_loop_y_done:
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret

room_render_tile_objects_render_enemy_lava_generator_draw_mouth:
	ld de, tile_object_lava_generator_gfx
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	call get_room_tile_ptr
	ld bc, #0204
room_render_tile_objects_render_enemy_lava_generator_draw_mouth_loop_y:
	push bc
	push hl
room_render_tile_objects_render_enemy_lava_generator_draw_mouth_loop_x:
		ld a, (de)
		ld (hl), a
		inc de
		inc hl
		dec c
		jr nz, room_render_tile_objects_render_enemy_lava_generator_draw_mouth_loop_x
	pop hl
	pop bc
	ld a, (current_room__width)
	ADD_HL_A
	djnz room_render_tile_objects_render_enemy_lava_generator_draw_mouth_loop_y
	ret	

room_render_tile_objects_render_enemy_lava_generator_save_bg:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
	inc c
	inc b
	call get_room_tile_ptr
	ld iyl, 8
	ld a, (current_room__width)
	dec a
	ld b, 0
	ld c, a
room_render_tile_objects_render_enemy_lava_generator_save_bg_loop_y:
	ld a, (hl)
	ld (de), a
	inc hl
	inc de
	ld a, (hl)
	ld (de), a
	inc de
	add hl, bc
	dec iyl
	jr nz, room_render_tile_objects_render_enemy_lava_generator_save_bg_loop_y
	ret


;-----------------------------------------------
; input:
; - hl: object ptr + 1
update_tile_objects_enemy_stone_owl:
	dec hl
	push hl
	pop ix

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH)
	or a
	jp z, update_tile_objects_4x4_enemy_killed	
	; behavior is:
	; state 0: still -> chance to go to "turn head left/right" (state 1/3), or fly (state 7)
	; state 1: left 45 degrees -> go to 2
	; state 2: left 90 degrees -> fire a bullet if player is in this direction and go to 3
	; state 3: left 45 degrees -> go to 0
	; state 4: right 45 degrees -> go to 5
	; state 5: right 90 degrees -> fire a bullet if player is in this direction and go to 6
	; state 6: right 45 degrees -> go to 0
	; state 7: flying wings open -> go to 8
	; state 8: flying wings closed -> move in a random direction that is available (if we end up landing, go to 0)
	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	or a
	jr z, update_tile_objects_enemy_stone_owl_state_0
	dec a
	jr z, update_tile_objects_enemy_stone_owl_state_1
	dec a
	jr z, update_tile_objects_enemy_stone_owl_state_2
	dec a
	jr z, update_tile_objects_enemy_stone_owl_state_3
	dec a
	jp z, update_tile_objects_enemy_stone_owl_state_4
	dec a
	jp z, update_tile_objects_enemy_stone_owl_state_5
	dec a
	jp z, update_tile_objects_enemy_stone_owl_state_6
	dec a
	jr z, update_tile_objects_enemy_stone_owl_state_7
	dec a
update_tile_objects_enemy_stone_owl_state_8:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 4
	jp nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 0
	jp update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_7:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 4
	jp nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 8
	jr update_tile_objects_enemy_stone_owl_continue

update_tile_objects_enemy_stone_owl_state_0:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 8
	jr nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	; switch state:
	call random_a
	cp 192
	jr nc, update_tile_objects_enemy_stone_owl_state_0_to_7
	and #01
	jr z, update_tile_objects_enemy_stone_owl_state_0_to_1
update_tile_objects_enemy_stone_owl_state_0_to_4:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 4
	jr update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_0_to_1:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 1
	jr update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_0_to_7:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 7
	jr update_tile_objects_enemy_stone_owl_continue

update_tile_objects_enemy_stone_owl_state_1:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 2
	jr nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 2
	jr update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_2:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 8
	jr nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 3
	jr update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_3:
update_tile_objects_enemy_stone_owl_state_6:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 2
	jr nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 0
	jr update_tile_objects_enemy_stone_owl_continue

update_tile_objects_enemy_stone_owl_state_4:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 2
	jr nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 5
	jr update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_5:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 8
	jr nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 6
	; jr update_tile_objects_enemy_stone_owl_continue

update_tile_objects_enemy_stone_owl_continue:
	; redraw tile objects:
	jp update_tile_objects_loop_force_redraw_and_continue
update_tile_objects_enemy_stone_owl_continue2:
	jp update_tile_objects_loop_continue


;-----------------------------------------------
; input:
; - hl: object ptr + 1
room_render_tile_objects_render_enemy_stone_owl:
	dec hl
	push hl
	pop ix

	; get frame to draw:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	ld hl, tile_object_stone_owl_frames
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a

	; draw saving bg to work memory:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	dec c  ; owl is 5x3, but we are treating it as 4x4
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc b  ; owl is 5x3, but we are treating it as 4x4
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
	ld ixl, e
	ld ixh, d
	ld iyl, c
	ld iyh, b
; 	ld hl, tile_object_stone_owl_frame1_gfx - 1
	call room_render_tile_objects_render_saving_background
	jp room_render_tile_objects_loop_continue

tile_object_stone_owl_frames:
	dw tile_object_stone_owl_frame1_gfx - 1  ; idle
	dw tile_object_stone_owl_frame2_gfx - 1  ; 45 degrees left
	dw tile_object_stone_owl_frame3_gfx - 1  ; 90 degrees left
	dw tile_object_stone_owl_frame2_gfx - 1  ; 45 degrees left
	dw tile_object_stone_owl_frame4_gfx - 1  ; 45 degrees right
	dw tile_object_stone_owl_frame5_gfx - 1  ; 90 degrees right
	dw tile_object_stone_owl_frame4_gfx - 1  ; 45 degrees right
	dw tile_object_stone_owl_frame6_gfx - 1  ; wings open (flying)
	dw tile_object_stone_owl_frame1_gfx - 1  ; wings closed (flying)

tile_object_stone_owl_frame1_gfx:
	db 5, 3
	dw tile_object_stone_owl_frame1_gfx_tiles
tile_object_stone_owl_frame1_gfx_tiles:
	db 0, 64, 65, 66, 0
	db 0, 67, 175, 68, 0
	db 0, 69, 70, 71, 0

tile_object_stone_owl_frame2_gfx:
	db 5, 3
	dw tile_object_stone_owl_frame2_gfx_tiles
tile_object_stone_owl_frame2_gfx_tiles:
	db 0, 80, 81, 82, 0
	db 0, 83, 84, 85, 0
	db 0, 69, 70, 71, 0

tile_object_stone_owl_frame3_gfx:
	db 5, 3
	dw tile_object_stone_owl_frame3_gfx_tiles
tile_object_stone_owl_frame3_gfx_tiles:
	db 0, 86, 87, 82, 0
	db 0, 88, 89, 85, 0
	db 0, 69, 70, 71, 0

tile_object_stone_owl_frame4_gfx:
	db 5, 3
	dw tile_object_stone_owl_frame4_gfx_tiles
tile_object_stone_owl_frame4_gfx_tiles:
	db 0, 76, 77, 78, 0
	db 0, 92, 93, 94, 0
	db 0, 69, 70, 71, 0

tile_object_stone_owl_frame5_gfx:
	db 5, 3
	dw tile_object_stone_owl_frame5_gfx_tiles
tile_object_stone_owl_frame5_gfx_tiles:
	db 0, 76, 87, 79, 0
	db 0, 92, 89, 95, 0
	db 0, 69, 70, 71, 0

tile_object_stone_owl_frame6_gfx:
	db 5, 3
	dw tile_object_stone_owl_frame6_gfx_tiles
tile_object_stone_owl_frame6_gfx_tiles:
	db 0, 64, 65, 66, 0
	db 72, 73, 175, 74, 75
	db 0, 90, 70, 91, 0


;-----------------------------------------------
; input:
; - hl: object ptr + 1
room_render_tile_objects_undraw_enemy_stone_owl:
	dec hl
	push hl
	pop ix
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	dec c  ; owl is 5x3, but we are treating it as 4x4
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc b  ; owl is 5x3, but we are treating it as 4x4
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
	ld iyl, e
	ld iyh, d
	ld ixl, c
	ld ixh, b
	ld hl, tile_object_stone_owl_frame1_gfx - 1
	call room_undraw_tile_objects_restore_background
	jp room_undraw_tile_objects_loop_continue


;-----------------------------------------------
; Used for when the player hits a tile enemy, sssumes there is a single tile enemy
; that can be hit in the whole screen.
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
	cp TAG_ENEMY_ANT_COLONY2
	ret z
	; these cannot be hit:
; 	cp TAG_ENEMY_IMP_GENERATOR
; 	ret z
; 	cp TAG_ENEMY_IMP_GENERATOR2
; 	ret z
; 	cp TAG_ENEMY_FIREBALL_GENERATOR
; 	ret z
;   cp TAG_ENEMY_LAVA_GENERATOR
;   ret z
	cp TAG_ENEMY_STONE_OWL
	ret z
	add ix, bc
	jr find_tile_enemy_ptr_loop
find_tile_enemy_ptr_not_found:
	or 1
	ret
