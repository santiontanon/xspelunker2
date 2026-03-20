CARNIVORE_PLANT_MAX_TONGUE_LENGTH: equ 16
CARNIVORE_PLANT_MAX_TONGUE_TIP_PTR_OFFSET: equ 1 + CARNIVORE_PLANT_MAX_TONGUE_LENGTH * 3
CARNIVORE_PLANT_WORKMEMORY_USAGE: equ 1 + CARNIVORE_PLANT_MAX_TONGUE_LENGTH * 3 + 2  ; 51 bytes
; workmemory usage:
; - 1 byte for tongue length
; - each tongue segment has 3 bytes: background (to undraw), tile, direction of next
; - 2 bytes at the end for room tile ptr of the current tongue tip

LAVA_GENERATOR_MAX_LAVA_LENGTH: equ 8
LAVA_GENERATOR_WORKMEMORY_USAGE: equ LAVA_GENERATOR_MAX_LAVA_LENGTH * 2  ; 16

STONE_OWL_WORKMEMORY_USAGE: equ 16

SENTINEL_WORKMEMORY_USAGE: equ 17
; - 1 byte: background saved?
; - 1 byte: original x when rendered
; - 15 bytes: background buffer


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
	jr nz, room_render_tile_objects_render_enemy_carnivore_plant_continue
	call room_render_tile_objects_render_loop_y
	jp room_render_tile_objects_loop_continue
room_render_tile_objects_render_enemy_carnivore_plant_continue:
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
; output:
; - z: hit
; - nz: no hit
enemy_carnivore_plant_hit:
	call find_tile_enemy_ptr
	ret nz
	ld a, e
	; only if hit was for tiles 64 - 96
	cp 64
	ret c
	cp 96
	jr nc, enemy_carnivore_plant_hit_no_hit
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
	call play_SFX_with_high_priority
	xor a
	ret
enemy_carnivore_plant_hit_no_hit:
	or 1
	ret


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
; output:
; - z: hit
; - nz: no hit
enemy_stone_owl_hit:
enemy_ant_colony_hit:
enemy_bee_hive_hit:
	call find_tile_enemy_ptr
	ret nz
	; only if hit was for tiles 64 - 96
	ld a, e
	cp 64
	ret c
	cp 96
	jr nc, enemy_stone_owl_hit_no_hit
enemy_sentinel_hit_entry_point:
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
	call play_SFX_with_high_priority
	xor a  ; z
	ret
enemy_stone_owl_hit_no_hit:
	or 1
	ret



;-----------------------------------------------
; input:
; - e: tile idx that was hit
; - iyl: collision ID
; - iyh: weapon damage
enemy_sentinel_hit:
	; hits can happen in many different tiles, it's easier
	; to get the tile type, check it was a "hazzard", and discard if it
	; was tile 130 or 252 (spike tips)
	ld a, e
	cp 130
	jr z, enemy_stone_owl_hit_no_hit
	cp 252
	jr z, enemy_stone_owl_hit_no_hit
	call get_collision_tile_type_of_a
	cp 3
	ret nz
	call find_tile_enemy_ptr
	ret nz	
	jr enemy_sentinel_hit_entry_point


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
	jp room_undraw_tile_objects_loop_continue


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
	jp z, update_tile_objects_enemy_stone_owl_state_0
	dec a
	jp z, update_tile_objects_enemy_stone_owl_state_1
	dec a
	jp z, update_tile_objects_enemy_stone_owl_state_2
	dec a
	jp z, update_tile_objects_enemy_stone_owl_state_3
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
	cp 2
	jp nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 7
	jp update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_7:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 2
	jp nz, update_tile_objects_enemy_stone_owl_continue2
	; move to an adjacent tile if possible:
	; - determine available directions
	; - choose a random available direction (or down)
	; - if moving down but it's not available, go to state 0 (landing)
	ld iyl, 0  ; will store the available directions
	call update_tile_objects_enemy_stone_owl_can_move_left
	jr z, update_tile_objects_enemy_stone_owl_state_7_continue1
	ld a, iyl
	OR PCG_DIRECTION_LEFT
	ld iyl, a
update_tile_objects_enemy_stone_owl_state_7_continue1:
	call update_tile_objects_enemy_stone_owl_can_move_up
	jr z, update_tile_objects_enemy_stone_owl_state_7_continue2
	ld a, iyl
	OR PCG_DIRECTION_UP
	ld iyl, a
update_tile_objects_enemy_stone_owl_state_7_continue2:
	call update_tile_objects_enemy_stone_owl_can_move_right
	jr z, update_tile_objects_enemy_stone_owl_state_7_continue3
	ld a, iyl
	OR PCG_DIRECTION_RIGHT
	ld iyl, a
update_tile_objects_enemy_stone_owl_state_7_continue3:
	call update_tile_objects_enemy_stone_owl_can_move_down
	jr z, update_tile_objects_enemy_stone_owl_state_7_continue4
	ld a, iyl
	OR PCG_DIRECTION_DOWN
	ld iyl, a
update_tile_objects_enemy_stone_owl_state_7_continue4:
	ld a, iyl
	or a
	ld c, PCG_DIRECTION_DOWN_BIT
	jr z, update_tile_objects_enemy_stone_owl_state_7_loop_done
update_tile_objects_enemy_stone_owl_state_7_loop:
	call random_a
	and #03
	ld c, 1
	or a
	jr z, update_tile_objects_enemy_stone_owl_state_7_inner_loop_done
update_tile_objects_enemy_stone_owl_state_7_inner_loop:
	sla c
	dec a
	jr nz, update_tile_objects_enemy_stone_owl_state_7_inner_loop
update_tile_objects_enemy_stone_owl_state_7_inner_loop_done:
	ld a, c  ; chosen direction
	cp PCG_DIRECTION_DOWN
	jr z, update_tile_objects_enemy_stone_owl_state_7_loop_done  ; we can always go down
	and iyl
	jr nz, update_tile_objects_enemy_stone_owl_state_7_loop_done  ; direction available

	jr update_tile_objects_enemy_stone_owl_state_7_loop
update_tile_objects_enemy_stone_owl_state_7_loop_done:
	ld a, c  ; chosen direction
	and iyl
	jr z, update_tile_objects_enemy_stone_owl_state_7_to_state_0  ; not available, which means it's 'down', so, we need to land
	; undraw the tile objects:
	push bc
	push ix
		call room_undraw_tile_objects
	pop ix
	pop bc	
	ld a, c
	cp PCG_DIRECTION_LEFT
	jr z, update_tile_objects_enemy_stone_owl_state_7_left
	cp PCG_DIRECTION_UP
	jr z, update_tile_objects_enemy_stone_owl_state_7_up
	cp PCG_DIRECTION_RIGHT
	jr z, update_tile_objects_enemy_stone_owl_state_7_right
update_tile_objects_enemy_stone_owl_state_7_down:
	inc (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jr update_tile_objects_enemy_stone_owl_state_7_movement_done
update_tile_objects_enemy_stone_owl_state_7_left:
	dec (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr update_tile_objects_enemy_stone_owl_state_7_movement_done
update_tile_objects_enemy_stone_owl_state_7_up:
	dec (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jr update_tile_objects_enemy_stone_owl_state_7_movement_done
update_tile_objects_enemy_stone_owl_state_7_right:
	inc (ix + ROOM_TILE_OBJECT_STRUCT_X)
update_tile_objects_enemy_stone_owl_state_7_movement_done:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 8
	call room_render_tile_objects
	jp update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_7_to_state_0:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 0
	jp update_tile_objects_enemy_stone_owl_continue

update_tile_objects_enemy_stone_owl_state_0:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 8
	jp nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	; switch state:
	call random_a
	cp 192
	jr nc, update_tile_objects_enemy_stone_owl_state_0_to_7
	and #01
	jr z, update_tile_objects_enemy_stone_owl_state_0_to_1
update_tile_objects_enemy_stone_owl_state_0_to_4:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 4
	jp update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_0_to_1:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 1
	jp update_tile_objects_enemy_stone_owl_continue
update_tile_objects_enemy_stone_owl_state_0_to_7:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 7
	jp update_tile_objects_enemy_stone_owl_continue

update_tile_objects_enemy_stone_owl_state_1:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 2
	jp nz, update_tile_objects_enemy_stone_owl_continue2
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), #ff
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 2
	jp update_tile_objects_enemy_stone_owl_continue

update_tile_objects_enemy_stone_owl_state_2:
	; fire bullets:
	ld a, (player_x + 1)
	cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr nc, update_tile_objects_enemy_stone_owl_state_2_skip_bullets
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #03
	jr nz, update_tile_objects_enemy_stone_owl_state_2_skip_bullets
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	inc e
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc d
	ld hl, update_enemy_fire_directional_bullet_towards_player_at_e_d
	ld c, ENEMIES_PAGE
	call call_hl_in_page_c_8000
update_tile_objects_enemy_stone_owl_state_2_skip_bullets:
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
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), #ff
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 5
	jr update_tile_objects_enemy_stone_owl_continue

update_tile_objects_enemy_stone_owl_state_5:
	; fire bullets:
	ld a, (player_x + 1)
	cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr c, update_tile_objects_enemy_stone_owl_state_5_skip_bullets
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #03
	jr nz, update_tile_objects_enemy_stone_owl_state_5_skip_bullets
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	inc e
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc d
	ld hl, update_enemy_fire_directional_bullet_towards_player_at_e_d
	ld c, ENEMIES_PAGE
	call call_hl_in_page_c_8000
update_tile_objects_enemy_stone_owl_state_5_skip_bullets:

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


update_tile_objects_enemy_stone_owl_can_move_left:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	or a
	ret z  ; no moving left of the room
	ld c, a
	dec c
update_tile_objects_enemy_stone_owl_can_move_right_entry_point:
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc b
	push bc
		call general_check_collision_with_wall
	pop bc
	ret z
	inc b
	push bc
		call general_check_collision_with_wall
	pop bc
	ret z
	inc b
	call general_check_collision_with_wall
	ret

update_tile_objects_enemy_stone_owl_can_move_up:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	or a
	ret z  ; no moving up of the room
	ld b, a	
update_tile_objects_enemy_stone_owl_can_move_down_entry_point:
	push bc
		call general_check_collision_with_wall
	pop bc
	ret z
	inc c
	push bc
		call general_check_collision_with_wall
	pop bc
	ret z
	inc c
	call general_check_collision_with_wall
	ret

update_tile_objects_enemy_stone_owl_can_move_right:
	ld a, (current_room__width)
	sub 4
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	cp c
	ret z  ; not exiting the room to the right
	inc c
	inc c
	inc c
	jr update_tile_objects_enemy_stone_owl_can_move_right_entry_point

update_tile_objects_enemy_stone_owl_can_move_down:
	ld a, (current_room__height)
	sub 4	
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	cp b
	ret z  ; not exiting the room down
	inc b
	inc b
	inc b
	inc b
	jr update_tile_objects_enemy_stone_owl_can_move_down_entry_point


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
	ld a, 1
	ld (de), a  ; mark that we have saved background
	inc de
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
	ld a, (de)
	or a
	jp z, room_undraw_tile_objects_loop_continue  ; if we have not yet saved background, do not undraw
	inc de
	ld iyl, e
	ld iyh, d
	ld ixl, c
	ld ixh, b
	ld hl, tile_object_stone_owl_frame1_gfx - 1
	call room_undraw_tile_objects_restore_background
	jp room_undraw_tile_objects_loop_continue


;-----------------------------------------------
; input:
; - hl: object ptr + 1
update_tile_objects_enemy_sentinel:
	dec hl
	push hl
	pop ix

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEALTH)
	or a
	jp z, update_tile_objects_enemy_sentinel_killed	

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	; state switch:
	; - 0: state switch
	; - 1: idle (might fire a laser)
	; - 2: walk right (might fire a laser)
	; - 3: walk left (might fire a laser)
	; - 4: throw stone
	; - 5: initial state (spawn the sprite object)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	or a
	jr z, update_tile_objects_enemy_sentinel_state_0
	dec a
	jr z, update_tile_objects_enemy_sentinel_state_1
	dec a
	jp z, update_tile_objects_enemy_sentinel_state_2
	dec a
	jp z, update_tile_objects_enemy_sentinel_state_3
	dec a
	jp z, update_tile_objects_enemy_sentinel_state_4
	dec a
	jp z, update_tile_objects_enemy_sentinel_state_5
	; we should never get here
update_tile_objects_enemy_sentinel_state_0:
	ld c, 4
	call random_modulo
	inc a
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), a
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER), 0
	jp update_tile_objects_enemy_sentinel_state_1_continue  ; so that it switches direction

update_tile_objects_enemy_sentinel_state_1:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 4
	jr z, update_tile_objects_enemy_sentinel_state_0  ; change state!
update_tile_objects_enemy_sentinel_state_1_continue:
	; chance of firing
	call random_a
	and #03
	call z, update_tile_objects_enemy_sentinel_fire_laser
	; idle, just turn towards player:
	ld a, (player_x + 1)
	cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr c, update_tile_objects_enemy_sentinel_state_0_left
	; right:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 0
	jp update_tile_objects_enemy_sentinel_continue
update_tile_objects_enemy_sentinel_state_0_left:
	; left:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 7
	jp update_tile_objects_enemy_sentinel_continue

update_tile_objects_enemy_sentinel_state_2:
	; walk right:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	cp 7
	jr c, update_tile_objects_enemy_sentinel_state_2_rfw
update_tile_objects_enemy_sentinel_state_2_rbw:
	ld hl, update_tile_objects_enemy_sentinel_walk_table_right_bw
	jr update_tile_objects_enemy_sentinel_state_2_continue
update_tile_objects_enemy_sentinel_state_2_rfw:
	ld hl, update_tile_objects_enemy_sentinel_walk_table_right_fw
update_tile_objects_enemy_sentinel_state_2_continue:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #03
	jp nz, update_tile_objects_enemy_sentinel_continue
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	rrca
	rrca
	and #0f
	ld c, a
	add a, a
	add a, c
	ADD_HL_A  ; hl = pointer to the walk frame we want: collision check, target frame, x movement
	ld a, (hl)
	or a
	jr z, update_tile_objects_enemy_sentinel_state_2_continue2
	; collision check:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	add a, c
	ld c, a
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc b
	inc b
	inc b
	; - there should be no wall at (x + offset, y + 3)
	; - there should be wall/platform/laddertop/ropetop (x + offset, y + 4)
	push hl
	push bc
		call get_room_tile_type
	pop bc
	pop hl
	cp 2  ; wall
	jp z, update_tile_objects_enemy_sentinel_state_2_wall
	push hl
		inc b
		call general_check_collision
	pop hl
	jp nz, update_tile_objects_enemy_sentinel_state_2_wall
update_tile_objects_enemy_sentinel_state_2_continue2:
	inc hl
	ld a, (hl)
	ld (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), a
	ld c, a
	inc hl
	ld a, (hl)
	add a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld (ix + ROOM_TILE_OBJECT_STRUCT_X), a
	; if we went back to frame 0 or 7, is that we are done with the step:
	ld a, c
	or a
	jp z, update_tile_objects_enemy_sentinel_state_0
	cp 7
	jp z, update_tile_objects_enemy_sentinel_state_0
	jp update_tile_objects_enemy_sentinel_continue
update_tile_objects_enemy_sentinel_state_2_wall:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	cp 7
	jr c, update_tile_objects_enemy_sentinel_state_2_wall_right
update_tile_objects_enemy_sentinel_state_2_wall_left:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 7
	jp update_tile_objects_enemy_sentinel_state_0
update_tile_objects_enemy_sentinel_state_2_wall_right:
	ld (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 0
	jp update_tile_objects_enemy_sentinel_state_0

update_tile_objects_enemy_sentinel_state_3:
	; walk left:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	cp 7
	jr c, update_tile_objects_enemy_sentinel_state_3_lbw
update_tile_objects_enemy_sentinel_state_3_lfw:
	ld hl, update_tile_objects_enemy_sentinel_walk_table_left_fw
	jr update_tile_objects_enemy_sentinel_state_2_continue
update_tile_objects_enemy_sentinel_state_3_lbw:
	ld hl, update_tile_objects_enemy_sentinel_walk_table_left_bw
	jr update_tile_objects_enemy_sentinel_state_2_continue

update_tile_objects_enemy_sentinel_state_4:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	cp 16
	jp z, update_tile_objects_enemy_sentinel_state_4_done
	cp 8
	jp c, update_tile_objects_enemy_sentinel_state_4_prepare
	jp z, update_tile_objects_enemy_sentinel_state_4_shoot
	jr update_tile_objects_enemy_sentinel_continue
update_tile_objects_enemy_sentinel_state_4_done:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	cp 7
	jp c, update_tile_objects_enemy_sentinel_state_4_done_right
	ld  (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 7
	inc (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jp update_tile_objects_enemy_sentinel_state_0
update_tile_objects_enemy_sentinel_state_4_done_right:
	ld  (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 0
	jp update_tile_objects_enemy_sentinel_state_0
update_tile_objects_enemy_sentinel_state_4_shoot:
	; frame 6 (right) or 13 (left):
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	cp 7
	jr c, update_tile_objects_enemy_sentinel_state_4_shoot_right
update_tile_objects_enemy_sentinel_state_4_shoot_left:
	ld  (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 13
	dec (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr update_tile_objects_enemy_sentinel_state_4_shoot_spawn_projectyle
update_tile_objects_enemy_sentinel_state_4_shoot_right:
	ld  (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 6
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	inc e
	inc e
update_tile_objects_enemy_sentinel_state_4_shoot_spawn_projectyle:
	; spawn projectile:
	ld a, (player_x + 1)
	sub e
	ld c, a
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc d
	ld a, (player_y + 1)
	sub d
	ld b, a
	push bc
	push de
		call ptr_to_new_sprite_enemy
	pop de
	pop bc
	jr nz, update_tile_objects_enemy_sentinel_continue
	ld (hl), 0  ; ID
	inc hl
	ld (hl), ENEMY_SENTINEL_ROCK
	inc hl
	ld (hl), 0  ; pixel X
	inc hl
	ld (hl), e  ; tile X
	inc hl
	ld (hl), 4  ; pixel Y
	inc hl
	ld (hl), d  ; tile Y
	inc hl
	ld (hl), 0  ; state
	inc hl
	ld (hl), c  ; speed x
	inc hl
	ld (hl), b  ; speed y
	inc hl
	ld (hl), 1  ; health  ; must be 1, as otherwiise, the hitting logic would mess up speed y
	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority
	jr update_tile_objects_enemy_sentinel_continue

update_tile_objects_enemy_sentinel_state_4_prepare:
	; frame 5 (right) or 12 (left):
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	cp 7
	jr c, update_tile_objects_enemy_sentinel_state_4_prepare_right
update_tile_objects_enemy_sentinel_state_4_prepare_left:
	ld  (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 12
	jr update_tile_objects_enemy_sentinel_continue
update_tile_objects_enemy_sentinel_state_4_prepare_right:
	ld  (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1), 5
	; jr update_tile_objects_enemy_sentinel_continue

update_tile_objects_enemy_sentinel_continue:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	cp (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA2)
	jp z, update_tile_objects_loop_continue
	; we need to redraw as the frame has changed:
	call room_undraw_tile_objects
	call room_render_tile_objects
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	jp update_tile_objects_loop_continue

update_tile_objects_enemy_sentinel_state_5:
	; spawn the extras object:
	; spawn object for sprite decorations
	call ptr_to_new_sprite_object
	jp nz, update_tile_objects_enemy_sentinel_state_0
	ld (hl), 0  ; ID
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_ATLANTIS_SENTINEL_EXTRAS
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	ld (hl), #ff  ; we use 'state' to store the sprite we currently have uploaded
; 	; store the work enemy ptr
; 	ld bc, ROOM_OBJECT_STRUCT_EXTRA1 - 1
; 	add hl, bc
; 	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
; 	ld (hl), c
; 	inc hl
; 	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR+ 1)
; 	ld (hl), b 
	jp update_tile_objects_enemy_sentinel_state_0

update_tile_objects_enemy_sentinel_fire_laser:
	call ptr_to_new_sprite_enemy
	ret nz
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	cp 7
	jr c, update_tile_objects_enemy_sentinel_fire_laser_right
update_tile_objects_enemy_sentinel_fire_laser_left:
	ld c, 0  ; x offset
	ld b, 0  ; direction
	jr update_tile_objects_enemy_sentinel_fire_laser_continue
update_tile_objects_enemy_sentinel_fire_laser_right:
	ld c, 2  ; x offset
	ld b, 4  ; direction
update_tile_objects_enemy_sentinel_fire_laser_continue:
	ld (hl), 0  ; ID
	inc hl
	ld (hl), ENEMY_BULLET_LASER  ; enemy type
	inc hl
	ld (hl), 0  ; pixel x
	inc hl
	ld a, e
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)  ; sentinel x
	add a, c  ; x offset
	ld (hl), a  ; tile x
	inc hl
	ld (hl), 0  ; pixel y
	inc hl
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)  ; boss y
	ld (hl), a  ; tile y
	inc hl
	; although only 0 and 4 are implemented:
	; 1: left-up, 0: left, 2: left-down
	; 5: right-up, 4: right, 6: left-down
	ld (hl), b  ; state / direction
	ld hl, SFX_raygun
	jp play_SFX_with_high_priority

update_tile_objects_enemy_sentinel_killed:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	dec c
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
		inc c
		inc b
		inc b
		ld hl, enemy_maybe_spawn_drop
		ld e, ENEMIES_PAGE
		call call_hl_in_page_e_8000
	pop hl
	pop af  ; we do an extra pop, since we are skipping the one at update_tile_objects_loop_continue
	jp update_tile_objects_loop


update_tile_objects_enemy_sentinel_walk_table_right_fw:
	; - if looking right: 1, 2, 3[x++], 4[x++], 0[done]
	db   0, 1, 0  ; go to frame 1, no need for collision check
	db   2, 2, 0  ; go to frame 2 if collision check at [x+2] succeeds
	db   0, 3, 1  ; go to frame 3, no need for collision check (x++)
	db   2, 4, 1  ; go to frame 4 if collision check at [x+2] succeeds (x++)
	db   0, 0, 0  ; go to frame 0, no need for collision check

update_tile_objects_enemy_sentinel_walk_table_right_bw:
	; - if looking left: 10, 9, 8[x++], 11, 0[x++, done]
	db   0, 10, 0  ; go to frame 10, no need for collision check
	db   2,  9, 0  ; go to frame 9 if collision check at [x+2] succeeds
	db   0,  8, 1  ; go to frame 8, no need for collision check (x++)
	db   0, 11, 0  ; go to frame 11, no need for collision check
	db   2,  7, 1  ; go to frame 7 if collision check at [x+2] succeeds (x++)

update_tile_objects_enemy_sentinel_walk_table_left_fw:
	; - if looking left: 8, 9[x--], 10, 11[x--], 7[done]
	db   0,  8,  0  ; go to frame 10, no need for collision check
	db  -2,  9, -1  ; go to frame 9 if collision check at [x+2] succeeds
	db   0, 10,  0  ; go to frame 8, no need for collision check (x++)
	db  -2, 11, -1  ; go to frame 11, no need for collision check
	db   0,  7,  0  ; go to frame 7 if collision check at [x+2] succeeds (x++)

update_tile_objects_enemy_sentinel_walk_table_left_bw:
	; - if looking right: 3, 2[x--], 1, 4, 0[x--, done]
	db   0, 3,  0  ; go to frame 1, no need for collision check
	db  -2, 2, -1  ; go to frame 2 if collision check at [x+2] succeeds
	db   0, 1,  0  ; go to frame 3, no need for collision check (x++)
	db  -2, 4,  0  ; go to frame 4 if collision check at [x+2] succeeds (x++)
	db   0, 0, -1  ; go to frame 0, no need for collision check


;-----------------------------------------------
; input:
; - hl: object ptr + 1
room_render_tile_objects_render_enemy_sentinel:
	dec hl
	push hl
	pop ix

	; get frame to draw:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA1)
	ld (ix + ROOM_TILE_OBJECT_STRUCT_EXTRA2), a  ; store that this is the frame we just drew
	ld hl, tile_object_sentinel_frames
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a

	; draw saving bg to work memory:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	dec b  ; sentinel is 3x5, but we are treating it as 2x4
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
	ld a, 1
	ld (de), a  ; mark that we have saved background
	inc de
	ld a, c
	ld (de), a  ; x when rendering
	inc de
	ld ixl, e
	ld ixh, d
	ld iyl, c
	ld iyh, b
	call room_render_tile_objects_render_saving_background
	jp room_render_tile_objects_loop_continue


tile_object_sentinel_frames:
	; 0
	dw tile_object_sentinel_frame_right0_gfx - 1  ; right 0
	dw tile_object_sentinel_frame_right1_gfx - 1  ; right 1
	dw tile_object_sentinel_frame_right2_gfx - 1  ; right 2
	dw tile_object_sentinel_frame_right3_gfx - 1  ; right 3
	dw tile_object_sentinel_frame_right4_gfx - 1  ; right 4
	dw tile_object_sentinel_frame_attack_right0_gfx - 1  ; attack right 0
	dw tile_object_sentinel_frame_attack_right1_gfx - 1  ; attack right 1
	; 7
	dw tile_object_sentinel_frame_left0_gfx - 1  ; left 0
	dw tile_object_sentinel_frame_left1_gfx - 1  ; left 1
	dw tile_object_sentinel_frame_left2_gfx - 1  ; left 2
	dw tile_object_sentinel_frame_left3_gfx - 1  ; left 3
	dw tile_object_sentinel_frame_left4_gfx - 1  ; left 4
	dw tile_object_sentinel_frame_attack_left0_gfx - 1  ; attack left 0
	dw tile_object_sentinel_frame_attack_left1_gfx - 1  ; attack left 1

tile_object_sentinel_frame_right0_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_right0_gfx_tiles
tile_object_sentinel_frame_right0_gfx_tiles:
  db 0, 0, 0
  db 0, 64, 0
  db 65, 66, 0
  db 67, 68, 0
  db 69, 70, 0
tile_object_sentinel_frame_right1_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_right1_gfx_tiles
tile_object_sentinel_frame_right1_gfx_tiles:
  db 0, 0, 0
  db 0, 64, 0
  db 65, 66, 0
  db 67, 71, 0
  db 69, 72, 0
tile_object_sentinel_frame_right2_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_right2_gfx_tiles
tile_object_sentinel_frame_right2_gfx_tiles:
  db 0, 0, 0
  db 0, 0, 64
  db 0, 65, 66
  db 0, 73, 68
  db 74, 75, 70
tile_object_sentinel_frame_right3_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_right3_gfx_tiles
tile_object_sentinel_frame_right3_gfx_tiles:
  db 0, 0, 0
  db 0, 64, 0
  db 65, 66, 0
  db 67, 76, 0
  db 77, 78, 0
tile_object_sentinel_frame_right4_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_right4_gfx_tiles
tile_object_sentinel_frame_right4_gfx_tiles:
  db 0, 0, 0
  db 0, 64, 0
  db 65, 66, 0
  db 79, 80, 0
  db 81, 0, 0
tile_object_sentinel_frame_attack_right0_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_attack_right0_gfx_tiles
tile_object_sentinel_frame_attack_right0_gfx_tiles:
  db 82, 0, 0
  db 83, 64, 0
  db 84, 66, 0
  db 85, 68, 0
  db 69, 70, 0
tile_object_sentinel_frame_attack_right1_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_attack_right1_gfx_tiles
tile_object_sentinel_frame_attack_right1_gfx_tiles:
  db 0, 0, 0
  db 0, 64, 0
  db 86, 87, 88
  db 85, 68, 0
  db 69, 70, 0
tile_object_sentinel_frame_left0_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_left0_gfx_tiles
tile_object_sentinel_frame_left0_gfx_tiles:
  db 0, 0, 0
  db 190, 0, 0
  db 169, 189, 0
  db 176, 177, 0
  db 145, 160, 0
tile_object_sentinel_frame_left1_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_left1_gfx_tiles
tile_object_sentinel_frame_left1_gfx_tiles:
  db 0, 0, 0
  db 190, 0, 0
  db 169, 189, 0
  db 144, 177, 0
  db 128, 160, 0
tile_object_sentinel_frame_left2_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_left2_gfx_tiles
tile_object_sentinel_frame_left2_gfx_tiles:
  db 0, 0, 0
  db 190, 0, 0
  db 169, 189, 0
  db 176, 95, 0
  db 145, 93, 94
tile_object_sentinel_frame_left3_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_left3_gfx_tiles
tile_object_sentinel_frame_left3_gfx_tiles:
  db 0, 0, 0
  db 190, 0, 0
  db 169, 189, 0
  db 92, 177, 0
  db 90, 91, 0
tile_object_sentinel_frame_left4_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_left4_gfx_tiles
tile_object_sentinel_frame_left4_gfx_tiles:
  db 0, 0, 0
  db 190, 0, 0
  db 169, 189, 0
  db 223, 177, 0
  db 0, 222, 0
tile_object_sentinel_frame_attack_left0_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_attack_left0_gfx_tiles
tile_object_sentinel_frame_attack_left0_gfx_tiles:
  db 0, 221, 0
  db 190, 220, 0
  db 169, 207, 0
  db 176, 206, 0
  db 145, 160, 0
tile_object_sentinel_frame_attack_left1_gfx:
  db 3, 5
  dw tile_object_sentinel_frame_attack_left1_gfx_tiles
tile_object_sentinel_frame_attack_left1_gfx_tiles:
  db 0, 0, 0
  db 0, 190, 0
  db 191, 204, 205
  db 0, 176, 206
  db 0, 145, 160


;-----------------------------------------------
; input:
; - hl: object ptr + 1
room_render_tile_objects_undraw_enemy_sentinel:
	dec hl
	push hl
	pop ix
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
    dec b  ; sentinel is 3x5, but we are treating it as 2x4
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR)
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_WORKMEMORY_PTR + 1)
	ld a, (de)
	or a
	jp z, room_undraw_tile_objects_loop_continue  ; if we have not yet saved background, do not undraw
	inc de
	ld a, (de)  ; x when we rendered
	ld c, a
	inc de
	ld iyl, e
	ld iyh, d
	ld ixl, c
	ld ixh, b
	ld hl, tile_object_sentinel_frame_right0_gfx - 1
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
	cp TAG_ENEMY_SENTINEL
	ret z
	add ix, bc
	jr find_tile_enemy_ptr_loop
find_tile_enemy_ptr_not_found:
	or 1
	ret
