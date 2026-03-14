;-----------------------------------------------
update_boss5_behavior:
	ld hl, boss__hit_timer
	ld a, (hl)
	or a
	jr z, update_boss5_behavior_continue
	dec (hl)
update_boss5_behavior_continue:
	ld a, (boss__active)
	or a
	ret z

	; ...

	ld a, (boss__behavior)
	or a
	jp z, update_boss5_behavior_0  ; before boss is spawned (we don't even know if it's charybdis or scylla here)
; 	dec a
; 	jp z, update_boss5_behavior_1  ; walking
; 	dec a
; 	jp z, update_boss5_behavior_2  ; stomping
; 	jp update_boss5_behavior_3  ; death
	ret


;-----------------------------------------------
object_interaction_function_poseidon_boss_display_internal:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #1f
	jr z, object_interaction_function_poseidon_boss_display_internal_both
	and #07
	jr z, object_interaction_function_poseidon_boss_display_internal_skull
	and #01
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), a
object_interaction_function_poseidon_boss_display_internal_continue:
	ld c, TILES_PAGE
	ld hl, room_undraw_tile_objects
	call call_hl_in_page_c_8000
	ld c, TILES_PAGE
	ld hl, room_render_tile_objects
	jp call_hl_in_page_c_8000

object_interaction_function_poseidon_boss_display_internal_skull:
	ld hl, SFX_secret
	call play_SFX_with_high_priority
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 2
	jr object_interaction_function_poseidon_boss_display_internal_continue

object_interaction_function_poseidon_boss_display_internal_both:
	ld hl, SFX_secret
	call play_SFX_with_high_priority
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 3
	jr object_interaction_function_poseidon_boss_display_internal_continue



;-----------------------------------------------
update_boss5_behavior_0:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_0_state_0
	dec a
	; nothing to do on state 1
	dec a
	jr z, update_boss5_behavior_0_state_2  ; player activated the lever
	dec a
	jr z, update_boss5_behavior_0_state_3  ; water starts pouring in
	dec a
	jp z, update_boss5_behavior_0_state_4  ; water level / island rises
	dec a
	jp z, update_boss5_behavior_0_state_5  ; boss name comes down and combat starts
	dec a
	jp z, update_boss5_behavior_0_state_6  ; water stops pouring, and behavior 0 ends
	ret

update_boss5_behavior_0_state_0:
	; draw island:
	ld de, current_room__tile_map + 18*32 + 12
	ld ix, boss5_frame_island_0
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_1_without_clearing_ix
	call call_hl_in_page_c_8000

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	ld a, 1
	ld (boss__state), a
	ret

update_boss5_behavior_0_state_2:
	; the player just pressed the lever, remove the boss display and lever:
	ld hl, current_room__tile_map + 4*32 + (64*24)
	ld de, current_room__tile_map + 4*32
	ld bc, 6 * 32
	ldir

	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE * 2
	ld hl, current_room__tile_objects
	ld a, #ff
	call clear_memory_a

	ld hl, SFX_secret
	call play_SFX_with_high_priority

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	ld a, 3
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret

update_boss5_behavior_0_state_3:
	; start pouring water:
	ld hl, boss__state_timer
	ld a, (hl)
	cp 17
	jr nz, update_boss5_behavior_0_state_3_continue
	ld a, 4
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_0_state_3_continue:
	inc (hl)
	; hl = current_room__tile_map + (5 + a) * 32 + 6
	add a, 5
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, current_room__tile_map + 6
	add hl, bc
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	ld bc, 22 - 9
	add hl, bc
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	inc hl
	ld (hl), 97  ; water falling tile
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret

update_boss5_behavior_0_state_4:
	; water level + island rises:
	ld hl, boss__state_timer
	ld a, (hl)
	cp 16 * 7
	jr nz, update_boss5_behavior_0_state_4_continue
	ld a, 5
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_0_state_4_continue:
	inc (hl)
	rrca
	rrca
	rrca
	rrca
	and #0f
	; hl = current_room__tile_map + (21 - a) * 32 + 2 + 64*24  ; we overwrite the second copy
	sub 21
	neg
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, current_room__tile_map + 2 + 64*24
	add hl, bc
	push hl
		ld d, h
		ld e, l
		inc de
		ld (hl), 98  ; water top
		ld bc, 27
		ldir
	REPT 5
		inc hl
		inc de
	ENDR
		ld (hl), 129  ; water
		ld bc, 27
		ldir

		ld bc, - (64*24 + 32 + 27)
		add hl, bc
		ld d, h
		ld e, l
		ld bc, 64*24
		add hl, bc
		ld bc, 32 + 28
		ldir
	pop hl

	; compute pointer where to draw the island:
	ld bc, 10 - (4*32 + 64*24)
	add hl, bc
	ex de, hl
	ld ix, boss5_frame_island_0
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_1_without_clearing_ix
	call call_hl_in_page_c_8000

	; draw the boss below:
	; ...

	; push the player up if on the island:
	call player_check_collision_idle
	jr nz, update_boss5_behavior_0_state_4_continue2
	cp 2  ; if it's with a wall, push player up
	ld hl, player_y + 1
	dec (hl)
update_boss5_behavior_0_state_4_continue2:

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret

update_boss5_behavior_0_state_5:
	; boss name:
	; ...
	ld a, 6
	ld (boss__state), a
	xor a
	ld (boss__state_timer), a
	ret	

update_boss5_behavior_0_state_6:
	; water stops pouring:
	ld hl, boss__state_timer
	ld a, (hl)
	cp 10
	jr nz, update_boss5_behavior_0_state_6_continue
	ld a, 1
	ld (boss__behavior), a
	xor a
	ld (boss__state), a
	ld (boss__state_timer), a
	ret
update_boss5_behavior_0_state_6_continue:
	inc (hl)
	; hl = current_room__tile_map + (5 + a) * 32 + 6
	add a, 5
	ld l, a
	ld h, 0
	cp 5
	ld a, 154  ; bottom piece of the water sources
	jr z, update_boss5_behavior_0_state_6_continue2
	xor a
update_boss5_behavior_0_state_6_continue2:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	ld bc, current_room__tile_map + 6
	add hl, bc
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	ld bc, 22 - 9
	add hl, bc
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	inc hl
	ld (hl), a
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	ret
