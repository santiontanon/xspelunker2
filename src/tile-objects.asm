;-----------------------------------------------
update_tile_objects:
	ld hl, current_room__tile_objects
update_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff
	ret z
	; render the object:
	push hl
		inc hl
		add a, (hl)  ; type
		cp TAG_PUSHABLE_BLOCK
		jr z, update_tile_objects_pushable_block
update_tile_objects_loop_continue:
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp update_tile_objects_loop


;-----------------------------------------------
; input:
; - hl: ptr to object + 1
update_tile_objects_pushable_block:
	inc hl
	ld c, (hl)  ; x
	inc hl
	ld b, (hl)  ; y
	push hl
		inc b
		inc b
		push bc
			call get_room_tile_type
		pop bc
		; blocks collide with:
		;   1: platform (you can jump through)
		;   2: wall
		;   6: rope-platform-top
		;   8: ladder-platform-top
		dec a  ; 1
		jr z, update_tile_objects_pushable_block_collision
		dec a  ; 2
		jr z, update_tile_objects_pushable_block_collision
		cp 6 - 2  ; 6
		jr z, update_tile_objects_pushable_block_collision
		cp 8 - 2  ; 8
		jr z, update_tile_objects_pushable_block_collision

		inc c
		call get_room_tile_type
		dec a  ; 1
		jr z, update_tile_objects_pushable_block_collision
		dec a  ; 2
		jr z, update_tile_objects_pushable_block_collision
		cp 6 - 2  ; 6
		jr z, update_tile_objects_pushable_block_collision
		cp 8 - 2  ; 8
		jr z, update_tile_objects_pushable_block_collision

		; block should fall!
		call room_undraw_tile_objects
	pop hl
	ld a, (hl)  ; block y
	inc a
	ld (hl), a
	inc hl
	ld (hl), 1  ; state: falling

	; see if we are out of screen bounds:
	ld b, a
	ld a, (current_room__height)	
	cp b
	jr z, update_tile_objects_pushable_block_remove

	; See if we hit the player:
	dec hl
	ld b, (hl)
	dec hl
	ld c, (hl)  ; c, b: block coordinates
	ld a, (player_x + 1)
	cp c
	jr c, update_tile_objects_pushable_block_no_player_hit
	inc c
	inc c
	cp c
	jr nc, update_tile_objects_pushable_block_no_player_hit
	ld a, (player_y + 1)
	inc b
	cp b
	jr nz, update_tile_objects_pushable_block_no_player_hit

	; move the player on top of the block, to prevent getting trapped:
	sub 2
	ld (player_y + 1), a
	call player_hit_hazard

update_tile_objects_pushable_block_no_player_hit:
	call room_render_tile_objects

	; force redraw:
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)
	jp update_tile_objects_loop_continue

update_tile_objects_pushable_block_collision:
	pop hl
	dec hl
	ld c, (hl)  ; x
	inc hl
	ld b, (hl)  ; y
	inc hl
	ld a, (hl)
	or a
	jp z, update_tile_objects_loop_continue
	; block just fell on top of something:
	ld (hl), 0  ; state: still
	call spawn_pushing_block_dust
	jp update_tile_objects_loop_continue


update_tile_objects_pushable_block_remove:
	dec hl
	dec hl
	dec hl
	dec hl
	push hl
		call delete_tile_object_in_hl

		call room_render_tile_objects
		; force redraw:
		ld hl, redraw_flags
		set ROOM_REDRAW_FLAG_BIT, (hl)
	pop hl
	pop af  ; we do an extra pop, since we are skipping the one at update_tile_objects_loop_continue
	jp update_tile_objects_loop


;-----------------------------------------------
; input:
; - ix: ptr to breakable wall
; - a: collision ID
; - iyh: damage to deal
breakable_wall_hit_by_player:
	ld a, iyl
	ld (ix + ROOM_TILE_OBJECT_STRUCT_LAST_HIT_ID), a

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE)
	sub iyh
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), a
	jr z, breakable_wall_hit_by_player_destroyed
	jr nc, breakable_wall_hit_by_player_continue

breakable_wall_hit_by_player_destroyed:
	; wall destroyed!
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_WIDTH)
	sub 2
	sra a
	add a, c
	ld c, a
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_HEIGHT)
	sub 2
	sra a
	add a, b
	ld b, a
	call spawn_explosion
	jp room_remove_breakable_wall

breakable_wall_hit_by_player_continue:
	ld hl, SFX_enemy_hit
	jp play_SFX_with_high_priority


;-----------------------------------------------
; input:
; - hl: ptr of the tile object to delete
delete_tile_object_in_hl:
	; copy:
	; - from: hl + ROOM_TILE_OBJECT_STRUCT_SIZE
	; - to: hl
	; - amount: (current_room__tile_objects_sentinel - (hl + ROOM_TILE_OBJECT_STRUCT_SIZE) + 1
	; to:
	ld e, l
	ld d, h
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	push hl
		ld c, l
		ld b, h
		ld hl, current_room__tile_objects_sentinel
		or a
		sbc hl, bc
		inc hl
		ld c, l
		ld b, h
	pop hl
	ldir
	ret


;-----------------------------------------------
; Replaces background tiles by those corresponding to the current object, and stores the previous background
; in the tile object baclground buffer
room_render_tile_objects:
	ld hl, current_room__tile_objects
room_render_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff
	ret z
	; render the object:
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_BREAKABLE_WALL1
		jr z, room_render_tile_objects_loop_continue
		cp TAG_BREAKABLE_WALL2
		jr z, room_render_tile_objects_loop_continue
		cp TAG_BREAKABLE_WALL3
		jr z, room_render_tile_objects_loop_continue
		cp TAG_BREAKABLE_WALL4
		jr z, room_render_tile_objects_loop_continue		
		inc hl
		ld c, (hl)  ; x
		ld ixl, c
		inc hl
		ld b, (hl)  ; y
		ld ixh, b

		ld l, a
		ld h, 0
		add hl, hl
		add hl, hl
		ADD_HL_A  ; hl = a * 5
		ld bc, tile_object_gfx_table
		add hl, bc
		ld a, (hl)
		or a
		jr z, room_render_tile_objects_render_saving_background  ; type 0: saving background
		dec a
		jr z, room_render_tile_objects_render  ; type 1: rendering directly
room_render_tile_objects_loop_continue:
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp room_render_tile_objects_loop


room_render_tile_objects_render_saving_background:
		; - hl: ptr to tile_object_gfx_table
		; - ixl, ixh: x, y of the object
		inc hl
		ld c, (hl)  ; width
		inc hl
		ld b, (hl)  ; height
		inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)  ; de = ptr to the graphics
		; compute ptr where to draw:
	pop iy  ; recover the ptr to the object in iy
	push iy
		push bc
			ld c, ixl
			ld b, ixh
			call get_room_tile_ptr
		pop bc
		push ix
room_render_tile_objects_render_saving_background_loop_y:
			push ix
			push bc
			push hl
room_render_tile_objects_render_saving_background_loop_x:
				; check that:
				; - ixl < current_room__width
				; - ixl >= 0
				; - ixh < current_room__height
				ld a, (current_room__width)
				cp ixl
				jr z, room_render_tile_objects_render_saving_background_loop_x_continue
				jr c, room_render_tile_objects_render_saving_background_loop_x_continue
				ld a, ixl
				or a
				jp m, room_render_tile_objects_render_saving_background_loop_x_continue
				ld a, (current_room__height)
				cp ixh
				jr z, room_render_tile_objects_render_saving_background_loop_x_continue
				jr c, room_render_tile_objects_render_saving_background_loop_x_continue

				; save background:
				ld a, (hl)
				ld (iy + ROOM_TILE_OBJECT_STRUCT_BACKGROUND), a
				ld a, (de)
				ld (hl), a

room_render_tile_objects_render_saving_background_loop_x_continue:
				inc de
				inc hl
				inc iy
				inc ixl
				ld a, ixl
				or a
				jr nz, room_render_tile_objects_render_saving_background_loop_x_continue2
				; if ixl turned 0, it means the previous pointer was probably bad, so, we need to recompute it:
				push bc
					ld c, ixl
					ld b, ixh
					call get_room_tile_ptr					
				pop bc
room_render_tile_objects_render_saving_background_loop_x_continue2:
				dec c
				jr nz, room_render_tile_objects_render_saving_background_loop_x
			pop hl
			pop bc
			pop ix
			inc ixh
			ld a, (current_room__width)
			ADD_HL_A
			djnz room_render_tile_objects_render_saving_background_loop_y
		pop ix
		jp room_render_tile_objects_loop_continue


room_render_tile_objects_render:
		; Note, we do not need to take into account room bounds here, since this method
		; is for objects that are static, and hence will always be within screen bounds.
		; - hl: ptr to tile_object_gfx_table
		; - ixl, ixh: x, y of the object
		inc hl
		ld c, (hl)  ; width
		inc hl
		ld b, (hl)  ; height
		inc hl
		ld e, (hl)
		inc hl
		ld d, (hl)  ; de = ptr to the graphics
		; compute ptr where to draw:
		push bc
			ld c, ixl
			ld b, ixh
			call get_room_tile_ptr
		pop bc
room_render_tile_objects_render_loop_y:

		push bc
		push hl
room_render_tile_objects_render_loop_x:
			ld a, (de)
			ld (hl), a
			inc de
			inc hl
			dec c
			jr nz, room_render_tile_objects_render_loop_x
		pop hl
		pop bc
		ld a, (current_room__width)
		ADD_HL_A
		djnz room_render_tile_objects_render_loop_y
		jp room_render_tile_objects_loop_continue


;-----------------------------------------------
; restores the background that was removed by tile objects
room_undraw_tile_objects:
	ld hl, current_room__tile_objects_sentinel - ROOM_TILE_OBJECT_STRUCT_SIZE  ; ptr to the last object
	ld b, (current_room__tile_objects_sentinel - current_room__tile_objects)/ROOM_TILE_OBJECT_STRUCT_SIZE
room_undraw_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff
	jr z, room_undraw_tile_objects_loop_continue_no_pop
	; render the object:
	push bc
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_BREAKABLE_WALL1
		jr z, room_undraw_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL2
		jr z, room_undraw_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL3
		jr z, room_undraw_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL4
		jr z, room_undraw_tile_objects_loop_continue		
		inc hl
		ld c, (hl)  ; x
		ld ixl, c
		inc hl
		ld b, (hl)  ; y
		ld ixh, b

		ld l, a
		ld h, 0
		add hl, hl
		add hl, hl
		ADD_HL_A  ; hl = a * 5
		ld bc, tile_object_gfx_table
		add hl, bc
		ld a, (hl)
		or a
		jr z, room_undraw_tile_objects_restore_background  ; type 0: we had saved the background
		dec a
		jr z, room_undraw_tile_objects_delete_object  ; type 1: we just replace with 0s
room_undraw_tile_objects_loop_continue:
	pop hl
	pop bc
room_undraw_tile_objects_loop_continue_no_pop:
	ld de, -ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, de
	djnz room_undraw_tile_objects_loop
	ret


room_undraw_tile_objects_restore_background:
		; - hl: ptr to tile_object_gfx_table
		; - ixl, ixh: x, y of the object
		inc hl
		ld c, (hl)  ; width
		inc hl
		ld b, (hl)  ; height
		; compute ptr where to draw:
	pop iy  ; recover the ptr to the object in iy
	push iy
		push bc
			ld c, ixl
			ld b, ixh
			call get_room_tile_ptr
		pop bc
		push ix
room_undraw_tile_objects_restore_background_loop_y:
			push ix
			push bc
			push hl
room_undraw_tile_objects_restore_background_loop_x:
				; check that:
				; - ixl < current_room__width
				; - ixl >= 0
				; - ixh < current_room__height
				ld a, (current_room__width)
				cp ixl
				jr z, room_undraw_tile_objects_restore_background_loop_x_continue
				jr c, room_undraw_tile_objects_restore_background_loop_x_continue
				ld a, ixl
				or a
				jp m, room_undraw_tile_objects_restore_background_loop_x_continue
				ld a, (current_room__height)
				cp ixh
				jr z, room_undraw_tile_objects_restore_background_loop_x_continue
				jr c, room_undraw_tile_objects_restore_background_loop_x_continue

				; restore background:
				ld a, (iy + ROOM_TILE_OBJECT_STRUCT_BACKGROUND)
				ld (hl), a
room_undraw_tile_objects_restore_background_loop_x_continue
				inc hl
				inc iy
				inc ixl
				ld a, ixl
				or a
				jr nz, room_undraw_tile_objects_restore_background_loop_x_continue2
				; if ixl turned 0, it means the previous pointer was probably bad, so, we need to recompute it:
				push bc
					ld c, ixl
					ld b, ixh
					call get_room_tile_ptr					
				pop bc
room_undraw_tile_objects_restore_background_loop_x_continue2:

				dec c
				jr nz, room_undraw_tile_objects_restore_background_loop_x
			pop hl
			pop bc
			pop ix
			inc ixh
			ld a, (current_room__width)
			ADD_HL_A
			djnz room_undraw_tile_objects_restore_background_loop_y
		pop ix
		jp room_undraw_tile_objects_loop_continue


room_undraw_tile_objects_delete_object:
		; Note, we do not need to take into account room bounds here, since this method
		; is for objects that are static, and hence will always be within screen bounds.
		; - hl: ptr to tile_object_gfx_table
		; - ixl, ixh: x, y of the object
		inc hl
		ld c, (hl)  ; width
		inc hl
		ld b, (hl)  ; height
		; compute ptr where to delete:
		push bc
			ld c, ixl
			ld b, ixh
			call get_room_tile_ptr
		pop bc
room_undraw_tile_objects_delete_object_loop_y:

		push bc
		push hl
room_undraw_tile_objects_delete_object_loop_x:
			; restore background:
			ld (hl), 0
			inc hl
			dec c
			jr nz, room_undraw_tile_objects_delete_object_loop_x
		pop hl
		pop bc
		ld a, (current_room__width)
		ADD_HL_A
		djnz room_undraw_tile_objects_delete_object_loop_y
		jp room_undraw_tile_objects_loop_continue


;-----------------------------------------------
; input:
; - ix: ptr to the object
room_remove_breakable_wall:
	; mark its deletion in the global state:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld (hl), 1  ; mark the object as deleted

	; Create an entry in "global_state__open_walls":
	ld hl, global_state__open_walls
room_remove_breakable_wall_open_wall_loop:
	ld a, (hl)
	or a
	jr z, room_remove_breakable_wall_open_wall_loop_end
	ld bc, 6
	add hl, bc
	jr room_remove_breakable_wall_open_wall_loop
room_remove_breakable_wall_open_wall_loop_end:
	ld a, (current_area__id)
	inc a  ; so that we don't have a 0
	ld (hl), a
	inc hl
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	push hl
	push ix
		call get_chunk_ids_current_room_ptr
		ld bc, -current_area__chunks_ids
		add hl, bc
		ld a, l
	pop ix
	pop hl
	ld (hl), a  ; chunk where this wall is
	inc hl

	; get within-chunk coordinates:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	and #0f
	ld c, a  ; c = x % CHUNK_WIDTH
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
room_remove_breakable_wall_continue_within_chunk_y_loop:
	cp CHUNK_HEIGHT
	jr c, room_remove_breakable_wall_continue
	sub CHUNK_HEIGHT
	jr room_remove_breakable_wall_continue_within_chunk_y_loop
room_remove_breakable_wall_continue:
	ld b, a  ; b = y % CHUNK_HEIGHT
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl
	ld e, (ix + ROOM_TILE_OBJECT_STRUCT_WIDTH)
	ld d, (ix + ROOM_TILE_OBJECT_STRUCT_HEIGHT)
	ld (hl), e
	inc hl
	ld (hl), d
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	call room_remove_breakable_wall_restore_background
	push ix
	pop hl
	jp delete_tile_object_in_hl


;-----------------------------------------------
room_remove_breakable_wall_restore_background:
	push de
		call get_room_tile_ptr
	pop bc
room_remove_breakable_wall_restore_background_loop_y:
	push bc
	push hl
room_remove_breakable_wall_restore_background_loop_x:
		ld (hl), 0
		inc hl
		dec c
		jr nz, room_remove_breakable_wall_restore_background_loop_x
	pop hl
	pop bc
	ld a, (current_room__width)
	ADD_HL_A
	djnz room_remove_breakable_wall_restore_background_loop_y
	ret


;-----------------------------------------------
; output:
; - z: no object behind
; - nz: object behind
; - ix: ptr to object if one found
get_tile_object_behind_player:
	ld a, (player_x+1)
	ld c, a
	ld a, (player_y+1)
	ld b, a
	ld ix, current_room__tile_objects
get_tile_object_behind_player_loop:
	ld a, (ix)  ; ID
	cp #ff
	ret z
	; for now, assume all objects are 16x16:
	ld a, b
	cp (ix+ROOM_TILE_OBJECT_STRUCT_Y)
	jr nz, get_tile_object_behind_player_loop_next
	ld a, c
    cp (ix+ROOM_TILE_OBJECT_STRUCT_X)
    jr z, get_tile_object_behind_player_found
    dec a
    cp (ix+ROOM_TILE_OBJECT_STRUCT_X)
	jr z, get_tile_object_behind_player_found
get_tile_object_behind_player_loop_next:
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	add ix, de
	jp get_tile_object_behind_player_loop
get_tile_object_behind_player_found:
	or 1
	ret


;-----------------------------------------------
; input:
; - ix: ptr to object
interact_with_tile_object:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ld hl, object_interaction_function_ptrs
	ld b, 0
	ld c, a
	add hl, bc
	add hl, bc
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	jp (hl)

object_interaction_function_ptrs:
REPT TAG_BOSS1_KEY
	dw object_interaction_function_empty
ENDR
	; TAG_RED_LOCK: equ 13
	; TAG_GREEN_LOCK: equ 14
	; TAG_BLUE_LOCK: equ 15
	; TAG_YELLOW_LOCK: equ 16
	; TAG_WHITE_LOCK: equ 17
	; TAG_PURPLE_LOCK: equ 18
	; TAG_TRIAL1_LOCK: equ 19
	; TAG_TRIAL2_LOCK: equ 20
	; TAG_TRIAL3_LOCK: equ 21
	; TAG_TRIAL4_LOCK: equ 22
	; TAG_COMBINATION1_LOCK: equ 23
	; TAG_COMBINATION2_LOCK: equ 24
	; TAG_COMBINATION3_LOCK: equ 25
	; TAG_COMBINATION4_LOCK: equ 26
	; TAG_BALL_LOCK: equ 27
	; TAG_IDOL_LOCK: equ 28
	; TAG_GEAR_LOCK: equ 29
	; TAG_ASTRONAUT_LOCK: equ 30
	; TAG_TELEPORTER_ATLANTIS: equ 34
	; TAG_TELEPORTER_MARS: equ 35
	; TAG_TELEPORTER_MOON: equ 36
	; TAG_RED_KEY: equ 41
	; TAG_GREEN_KEY: equ 42
	; TAG_BLUE_KEY: equ 43
	; TAG_YELLOW_KEY: equ 44
	; TAG_WHITE_KEY: equ 45
	; TAG_PURPLE_KEY: equ 46
	; TAG_RED_CHEST: equ 47
	; TAG_GREEN_CHEST: equ 48
	; TAG_BLUE_CHEST: equ 49
	; TAG_YELLOW_CHEST: equ 50
	; TAG_WHITE_CHEST: equ 51
	; TAG_PURPLE_CHEST: equ 52
	; TAG_TRIAL1_CLUE: equ 53
	; TAG_TRIAL2_CLUE: equ 54
	; TAG_TRIAL3_CLUE: equ 55
	; TAG_TRIAL4_CLUE: equ 56
	; TAG_COMBINATION1_CLUE: equ 57
	; TAG_COMBINATION2_CLUE: equ 58
	; TAG_COMBINATION3_CLUE: equ 59
	; TAG_COMBINATION4_CLUE: equ 60
	; TAG_BALL_KEY: equ 61
	; TAG_IDOL_KEY: equ 62
	; TAG_GEAR_KEY: equ 63
	; TAG_ASTRONAUT_KEY: equ 64
	dw object_interaction_function_pickup_item  ; TAG_BOSS1_KEY:
	; TAG_BOSS1_CHESTLOCK: equ 67
	; TAG_BOSS2_KEY: equ 69
	; TAG_BOSS2_CHESTLOCK: equ 70
	; TAG_BOSS3_KEY: equ 72
	; TAG_BOSS3_CHESTLOCK: equ 73
	; TAG_BOSS4_KEY: equ 75
	; TAG_BOSS4_CHESTLOCK: equ 76
	; TAG_BOSS5_KEY: equ 78
	; TAG_BOSS5_CHESTLOCK: equ 79
	; TAG_BOSS6_KEY: equ 81
	; TAG_BOSS6_CHESTLOCK: equ 82
	; TAG_BOSS7_KEY: equ 84
	; TAG_BOSS7_CHESTLOCK: equ 85
	; TAG_WEAPON_HAMMER: equ 86
	; TAG_WEAPON_MACUAHUITL: equ 87
	; TAG_WEAPON_SHIELD: equ 88
	; TAG_WEAPON_SLING: equ 89
	; TAG_WEAPON_BLOWGUN: equ 90
	; TAG_WEAPON_ATLATL: equ 91
	; TAG_WEAPON_RAYGUN: equ 92
	; TAG_WEAPON_OBSIDIAN_KNIVE: equ 93
	; TAG_WEAPON_FIRE_HAMMER: equ 94
	; TAG_WEAPON_ICE_MACUAHUITL: equ 95
	; TAG_MAP_PIECE1: equ 96
	; TAG_MAP_PIECE2: equ 97
	; TAG_MAP_PIECE3: equ 98
	; TAG_MAP_PIECE4: equ 99
	; TAG_MAP_PIECE5: equ 100
	; TAG_MAP_PIECE6: equ 101
	; TAG_MAP_PIECE7: equ 102
	; TAG_MAP_PIECE8: equ 103
	; TAG_HEART1: equ 104
	; TAG_HEART2: equ 105
	; TAG_HEART3: equ 106
	; TAG_HEART4: equ 107
	; TAG_HEART5: equ 108
	; TAG_MAYA_RIDDLE_CLUE1: equ 109
	; TAG_MAYA_RIDDLE_CLUE2: equ 110
	; TAG_MAYA_RIDDLE_CLUE3: equ 111
	; TAG_MAYA_RIDDLE_CLUE4: equ 112
	; TAG_STORY_TRIVIA1: equ 113
	; TAG_STORY_TRIVIA2: equ 114
	; TAG_STORY_TRIVIA3: equ 115
	; TAG_STORY_TRIVIA4: equ 116
	; TAG_STORY_TRIVIA5: equ 117
	; TAG_STORY_TRIVIA6: equ 118
	; TAG_STORY_TRIVIA7: equ 119
	; TAG_STORY_TRIVIA8: equ 120
	; TAG_ITEM_SANDALS: equ 121
	; TAG_ITEM_GLOVES: equ 122
	; TAG_ITEM_HURAKAN: equ 123
	; TAG_ITEM_ARMOR: equ 124
	; TAG_ITEM_CHAAC: equ 125
	; TAG_ITEM_SEASHELL: equ 126
	; TAG_ITEM_BELT: equ 127
	; TAG_ITEM_ICE_CAPE: equ 128
	; TAG_SMALL_KEY1: equ 129
	; TAG_SMALL_KEY2: equ 130
	; TAG_SMALL_KEY3: equ 131
	; TAG_SMALL_KEY4: equ 132
	; TAG_SMALL_KEY_CHEST1: equ 133
	; TAG_SMALL_KEY_CHEST2: equ 134
	; TAG_SMALL_KEY_CHEST3: equ 135
	; TAG_SMALL_KEY_CHEST4: equ 136
	ret

object_interaction_inventory_slot:
	db #ff, #ff, #ff, #ff, #ff  ; none, block puzzles
	db #ff, #ff, #ff, #ff  ; button doors
	db #ff, #ff, #ff, #ff  ; breakable walls
	db #ff, #ff, #ff, #ff, #ff, #ff  ; color locks
	db #ff, #ff, #ff, #ff  ; trial locks
	db #ff, #ff, #ff, #ff  ; combination locks
	db #ff, #ff, #ff, #ff  ; special locks
	db #ff, #ff, #ff, #ff, #ff, #ff  ; start, ending, midpoint, teleporters
	db #ff, #ff, #ff, #ff  ; buttons
	db 15, 16, 17, 18, 19, 20  ; color keys
	db #ff, #ff, #ff, #ff, #ff, #ff  ; color chests
	db #ff, #ff, #ff, #ff  ; trial clues
	db #ff, #ff, #ff, #ff  ; combination clues
	db 21, 22, 23, 24  ; key items
	db #ff, 0, #ff  ; boss1
	db #ff, 1, #ff  ; boss2
	db #ff, 2, #ff  ; boss3
	db #ff, 3, #ff  ; boss4
	db #ff, 4, #ff  ; boss5
	db #ff, 5, #ff  ; boss6
	db #ff, 6, #ff  ; boss7
	db 1 + 128, 2 + 128, 3 + 128  ; weapons
	db 4 + 128, 5 + 128, 6 + 128, 7 + 128  ; ranged weapons
	db 8 + 128, 9 + 128, 10 + 128  ; upgraded weapons
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; map pieces
	db #ff, #ff, #ff, #ff, #ff  ; hearts
	db #ff, #ff, #ff, #ff  ; riddle clues
	db #ff, #ff, #ff, #ff, #ff, #ff, #ff, #ff  ; story trivia
	db 25, 26, 27, 28, 29, 30  ; maya upgrade items
	db 31, 32  ; alien upgrade items
	db #ff, #ff, #ff, #ff  ; small keys
	db #ff, #ff, #ff, #ff  ; small key chests


;-----------------------------------------------
object_interaction_function_empty:
	ret


;-----------------------------------------------
object_interaction_function_pickup_item:
	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority

	; add to inventory:
	ld hl, object_interaction_inventory_slot
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld a, (hl)
	cp N_INVENTORY_ITEM_TYPES
	ret nc  ; should never happen

	; add to inventory:
	ld hl, player_inventory_items
	ADD_HL_A	
	ld (hl), 1

	; mark as taken:
	ld hl, global_state__objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	ADD_HL_A
	ld (hl), 1

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	push ix
		call room_undraw_tile_objects
	pop hl
	call delete_tile_object_in_hl
	jp room_render_tile_objects


;-----------------------------------------------
; types:
; - 0: save background, then render
; - 1: render directly
; - 2: do not render
TILE_OBJECT_DATA: macro type, dx, dy, gfx_ptr
	db type, dx, dy
	dw gfx_ptr
endm


tile_object_gfx_table:
REPT TAG_BOSS1_KEY  ; add filler
	TILE_OBJECT_DATA 2, 0, 0, 0
ENDR
	TILE_OBJECT_DATA 0, 2, 2, tile_object_regular_object_gfx
REPT TAG_PUSHABLE_BLOCK - (TAG_BOSS1_KEY + 1)  ; add filler
	TILE_OBJECT_DATA 2, 0, 0, 0
ENDR
	TILE_OBJECT_DATA 0, 2, 2, tile_object_pushable_block_gfx

tile_object_regular_object_gfx:
	db FIRST_ITEM_TILE, FIRST_ITEM_TILE+1, FIRST_ITEM_TILE+2, FIRST_ITEM_TILE+3
tile_object_pushable_block_gfx:
	db 185, 187, 182, 184

