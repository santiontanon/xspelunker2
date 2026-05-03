;-----------------------------------------------
; Temporary variables (overlapping with the buffer):
tmp_pcg_room__current_target_chunk_bank_id: equ buffer_4096 + 4094
tmp_pcg_room__current_decompressed_chunk_bank_id: equ tmp_pcg_room__current_target_chunk_bank_id - 1
tmp_pcg_room__next_enemy_ptr: equ tmp_pcg_room__current_decompressed_chunk_bank_id - 2
tmp_pcg_room__next_tile_object_ptr: equ tmp_pcg_room__next_enemy_ptr - 2
tmp_pcg_room__chunk_x: equ tmp_pcg_room__next_tile_object_ptr - 1
tmp_pcg_room__chunk_y: equ tmp_pcg_room__chunk_x - 1
tmp_pcg_room__is_midpoint_room: equ tmp_pcg_room__chunk_y - 1
tmp_pcg_room__previous_seed: equ tmp_pcg_room__is_midpoint_room - 4
tmp_pcg_room__current_chunk_bg_bank_ptrs: equ tmp_pcg_room__previous_seed - 2


;-----------------------------------------------
area_default_tileset_ptrs:
	db JUNGLE_TILES_PAGE
	dw tiles_jungle_zx0, update_animations_in_vdp_jungle
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_jungle, jungle_enemy_sprites_zx0  ; jungle
	dw music_jungle_bin
	db 6

	db PYRAMID_TILES_PAGE
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_pyramid, pyramid_enemy_sprites_zx0  ; pyramid 1
	dw music_pyramid_bin
	db 10

	db PYRAMID_TILES_PAGE
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_pyramid, pyramid_enemy_sprites_zx0  ; pyramid 2
	dw music_pyramid_bin
	db 10

	db CAVES_TILES_PAGE
	dw tiles_caves_zx0, update_animations_in_vdp_caves
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_caves, caves_enemy_sprites_zx0  ; confluence
	dw music_caves_bin
	db 12

	db PYRAMID_TILES_PAGE
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_pyramid, pyramid_enemy_sprites_zx0  ; pyramid 3
	dw music_pyramid_bin
	db 10

	db PYRAMID_TILES_PAGE
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_pyramid, pyramid_enemy_sprites_zx0  ; fire shaft
	dw music_pyramid_bin
	db 10

	db CAVES_TILES_PAGE
	dw tiles_caves_zx0, update_animations_in_vdp_caves
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_caves, caves_enemy_sprites_zx0  ; pacific caves
	dw music_caves_bin
	db 12

	db CAVES_TILES_PAGE
	dw tiles_caves_zx0, update_animations_in_vdp_caves
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_caves, caves_enemy_sprites_zx0  ; atlantic caves
	dw music_caves_bin
	db 12

	db XIBALBA_TILES_PAGE
	dw tiles_xibalba_zx0, update_animations_in_vdp_xibalba
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_xibalba, xibalba_enemy_sprites_zx0  ; xibalba
	dw 0
	db 0

	db ATLANTIS_TILES_PAGE
	dw tiles_atlantis_zx0, update_animations_in_vdp_atlantis
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_atlantis, atlantis_enemy_sprites_zx0  ; atlantis
	dw 0
	db 0

	db PYRAMID_TILES_PAGE
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_pyramid, pyramid_enemy_sprites_zx0  ; mars
	dw 0
	db 0

	db PYRAMID_TILES_PAGE
	dw tiles_pyramid_zx0, update_animations_in_vdp_pyramid
	db AREA_COLLISION_TABLES_PAGE
	dw tile_collision_types_pyramid, pyramid_enemy_sprites_zx0  ; moon
	dw 0
	db 0


;-----------------------------------------------
pcg_generate_room_reset_state:
	ld hl, area_default_tileset_ptrs
	ld a, (current_area__id)
	ld b, a
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c  ; a * 12
	add a, b  ; a * 13
	ADD_HL_A
	ld de, current_room__tileset_page
	ldi  ; current_room__tileset_page
	ldi
	ldi  ; current_room__tileset_ptr
	ldi
	ldi  ; current_room__animation_fn_ptr
	ldi  ; current_room__collision_ptr_page
	ldi
	ldi  ; current_room__collision_ptr
	ldi
	ldi  ; current_room__enemy_sprites_ptr
	ldi
	ldi  ; current_room__music_ptr
	ldi  ; current_room__music_tempo
	xor a
	ld (current_room__tileset_overrides_item_tiles), a

	ld hl, state_play_update_agenda_normal_play
	ld (state_play_update_agenda_tbl_ptr), hl

	; Even if this will be copied later (in state-play.asm), we need to copy it early, so that
	; collision table is set when we get to pcg-enemies.asm.
	ld a, (current_room__collision_ptr_page)
	ld hl, (current_room__collision_ptr)
	ld de, current_room__collision_table
	ld bc, 256
	call ldir_from_page_a

	ld hl, player_combination_levers_state
	ld bc, 8 - 1
	ld a, 1
	call clear_memory_a

; 	ld hl, current_room__sprite_objects
; 	ld bc, MAX_ROOM_SPRITE_OBJECTS * ROOM_OBJECT_STRUCT_SIZE - 1
	xor a
	ld (boss__active), a
	ld (player_trial_completion_state), a
	ld (tmp_pcg_room__is_midpoint_room), a
; 	call clear_memory_a
	ld hl, current_room__sprite_enemies
	ld (tmp_pcg_room__next_enemy_ptr), hl
; 	ld bc, MAX_ROOM_SPRITE_ENEMIES * ROOM_OBJECT_STRUCT_SIZE - 1
; 	call clear_memory_a

; 	ld hl, current_room__player_bullets
; 	ld bc, MAX_ROOM_PLAYER_BULLETS * ROOM_OBJECT_STRUCT_SIZE - 1
; 	call clear_memory

	ld hl, current_room__tile_objects
	ld (tmp_pcg_room__next_tile_object_ptr), hl
	ld hl, current_room__player_bullets
	ld bc, current_room__tile_objects_sentinel - current_room__player_bullets
	ld a, #ff
	call clear_memory_a
	dec a  ; the sentinels are set to #fe, since the whole space is initialzied to #ff (to differentiate an "empty spot" from the "final sentinel")
	ld (current_room__sprite_objects_sentinel), a
	ld (current_room__player_bullets_sentinel), a
	ld (current_room__sprite_enemies_sentinel), a
	ld (current_room__tile_objects_sentinel), a

	ld hl, 0
	ld (enemy_tiles_to_upload_to_vdp), hl
	ld (tile_enemy_hit_fn_ptr), hl
	ld a, #ff
	ld (tile_enemy_last_collision_id), a

	ld hl, default_in_game_event_fn
	ld (in_game_event_fn_ptr), hl
	ld a, PCG_PAGE
	ld (in_game_event_fn_page), a

	xor a
	ld (boss__in_boss_room), a
	ld (room_locked_scroll), a
	ld (tmp_enemy_pcg_tile_enemy_workmemory_usage), a
	ld (tmp_enemy_pcg_tile_enemy_spawned_type), a
	ld a, #7f  ; first enemy ID (enemy IDs are only used to track which one was already killed, for respawn)
	ld (tmp_enemy_pcg_next_enemy_id), a

	ld hl, current_room__initial_enemy_ids
	ld bc, (current_room__initial_enemy_ids_end - current_room__initial_enemy_ids) - 1
	ld a, #ff
	jp clear_memory_a


;-----------------------------------------------
; This method fills in the "current_room" data structure by generating a room
; using the information in "current_area". 
; input:
; - e: room ID
pcg_generate_room:
	; preserve the random seed:
	ld hl, (rng_seed1)
	ld (tmp_pcg_room__previous_seed), hl
	ld hl, (rng_seed2)
	ld (tmp_pcg_room__previous_seed + 2), hl

	ld a, e
	ld (current_room__id), a

	ld hl, 0
	ld (item_object_to_upload_to_vdp), hl
	ld (large_object_to_upload_to_vdp), hl
	ld (current_room__trial_fn), hl

	push de
		call pcg_generate_room_reset_state
	pop de	

	; Find x1, y1, x2, y2 of the room in the room IDs map:
	ld ix, #0000  ; x1, y1  (we will store "width - x" and "height - y" since it's easier)
	ld iy, #ffff  ; x2, y2
	ld hl, current_area__room_ids
	ld bc, (current_area__width)  ; c = width, b = height
pcg_generate_room__xy_loop_y:
	push bc
pcg_generate_room__xy_loop_x:
		ld a, e  ; room ID
		cp (hl)
		jr nz, pcg_generate_room__xy_loop_x_skip
		; x1 = max(x1, c)
		ld a, ixl
		cp c
		jr nc, pcg_generate_room__xy_loop_x_skip_x1  ; jump if c <= ixl
		ld ixl, c
pcg_generate_room__xy_loop_x_skip_x1:
		; y1 = max(y1, b)
		ld a, ixh
		cp b
		jr nc, pcg_generate_room__xy_loop_x_skip_y1  ; jump if b <= ixh
		ld ixh, b
pcg_generate_room__xy_loop_x_skip_y1:
		; x2 = min(x2, c)
		ld a, iyl
		cp c
		jr c, pcg_generate_room__xy_loop_x_skip_x2  ; jump if c > iyl
		ld iyl, c
pcg_generate_room__xy_loop_x_skip_x2:
		; y2 = min(y2, b)
		ld a, iyh
		cp b
		jr c, pcg_generate_room__xy_loop_x_skip_y2  ; jump if b > iyh
		ld iyh, b
pcg_generate_room__xy_loop_x_skip_y2:
pcg_generate_room__xy_loop_x_skip:
		inc hl
		dec c
		jr nz, pcg_generate_room__xy_loop_x
	pop bc
	djnz pcg_generate_room__xy_loop_y

	; room coordinates:
	ld a, (current_area__width)
	sub ixl
	ld (current_room__x), a
	ld a, (current_area__height)
	sub ixh
	ld (current_room__y), a

	; Compute the room width/height, and scroll limits:
	; width = ((ixl - iyl) + 1) * 32
	; height = ((ixh - iyh) + 1) * 24
	; max_scroll_x = width - 32
	; max_scroll_y = height - 24
	ld a, ixl
	sub iyl
	inc a
	ld iyl, a  ; iyl now has width in "screens"
	ld (current_room__width_in_screens), a
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a  ; a * 32
	ld (current_room__width), a
	sub 32
	ld (current_room__max_scroll_x), a
	ld a, ixh
	sub iyh
	inc a
	ld iyh, a  ; iyl now has height in "screens"
	ld (current_room__height_in_screens), a
	add a, a
	add a, a
	add a, a
	ld d, a
	add a, a
	add a, d  ; a * 24
	ld (current_room__height), a

	; Get the room seed (from the area seed, generate as many numbers as the room ID):
	ld hl, (current_area__seed)
	ld (rng_seed1), hl
	ld hl, (current_area__seed + 2)
	ld (rng_seed2), hl
	ld b, e  ; roomID
	ld a, b
	or a
	jr z, pcg_generate_room__seed_generated
pcg_generate_room__seed_loop:
	call random_a
	djnz pcg_generate_room__seed_loop
pcg_generate_room__seed_generated:

	; Init the tile map:
	ld hl, current_room__tile_map
	ld bc, MAX_ROOM_SIZE - 1
	call clear_memory

	; check if it's a special room:
	ld a, (current_room__id)
	cp START_ROOM_ID
	jp z, pcg_generate_room__start
	cp CALENDAR_ROOM_ID
	jp z, pcg_generate_room__calendar
	cp TELEPORTER_ROOM_ID
	jp z, pcg_generate_room__teleporter
	cp TEMPLE_OF_POSEIDON_ID
	jp z, pcg_generate_room__temple_of_poseidon
	cp EIGHT_BRIDGE_ROOM_ID
	jp z, pcg_generate_room__8_bridge_room

	; Add background chunks randomly:
	; here:
	; - iyl/iyh have the width/height of the room in "screens"
	; - ixl/ixh have the x1, y1 coordinates of the room
	; hl = current_area__chunks_ids + (width - ixl) * 2 + (height - ixh) * 2 * width * 2
	ld a, (current_area__height)
	sub ixh
	add a, a
	add a, a  ; a = (height - ixh) * 2 * 2
	ld d, 0
	ld e, a
	ld hl, 0
	ld a, (current_area__width)
	; hl *= a
	ld b, a
pcg_generate_room__fb_chunk_ptr_loop:
	add hl, de
	djnz pcg_generate_room__fb_chunk_ptr_loop
	ld a, (current_area__width)
	sub ixl
	add a, a
	ADD_HL_A
	ld de, current_area__chunks_ids
	add hl, de  ; hl = current_area__chunks_ids + (width - ixl) * 2 + (height - ixh) * 2 * width

	push hl
	push ix
	push iy
		call pcg_generate_room_background
	pop iy
	pop ix
	pop hl

	; Iterate over the foreground chunk IDs, and copy the proper chunks to the proper places:
	; here:
	; - iyl/iyh have the width/height of the room in "screens"
	; - ixl/ixh have the x1, y1 coordinates of the room
	ld a, #ff
	ld (tmp_pcg_room__current_decompressed_chunk_bank_id), a
	ld a, (current_area__n_chunk_banks)
	ld b, a
pcg_generate_room__fg_loop_bank_id:
	push bc
	push hl
		ld a, b
		dec a
		add a, a
		add a, a
		add a, a
		add a, a
		ld (tmp_pcg_room__current_target_chunk_bank_id), a  ; we will only consider chunks in this bank in this iteration

		ld b, iyh
		rl b
		ld c, iyl
		rl c
pcg_generate_room__fg_loop_y:
		push bc
		push hl
			ld a, (tmp_pcg_room__current_target_chunk_bank_id)
			ld e, a
pcg_generate_room__fg_loop_x:
			ld a, (hl)
			and #f0
			cp e
			jp nz, pcg_generate_room__fg_loop_x_skip
			ld a, (hl)
			push hl
				push bc
					ld hl, (current_area__chunk_fg_bank_ptrs)
					call pcg_get_chunk_ptr
				pop bc
				push bc
					push hl
						; - hl: ptr to chunk
						; - iyl/iyh: room width/height in screens.
						; - c/b: x, y coordinates where to add this chunk in the current room.			
						call pcg_generate_room_copy_chunk_to_room
					pop hl
					; Instantiate pushable-blocks:
					ld bc, CHUNK_WIDTH * CHUNK_HEIGHT
					add hl, bc
				pop bc  ; we recover the x, y coordinates of the chunk
				push bc
					; Coordinates of the top-left of this chunk are: (iyl*2 - c)*16 + location.x, (iyh*2 - b)*12 + location.y
					ld a, iyl
					add a, a
					sub c
					add a, a
					add a, a
					add a, a
					add a, a  ; * 16
					ld (tmp_pcg_room__chunk_x), a
					ld a, iyh
					add a, a
					sub b
					add a, a
					add a, a
					ld c, a
					add a, a
					add a, c  ; * 12
					ld (tmp_pcg_room__chunk_y), a

					; Here hl = ptr to the "locations" marked in the chunk
					; We iterate over all of them looking for instances of "pushable-block":
					; each location is: type, x, y, dx, dy
pcg_generate_room__fg_chunk_object_loop:
					ld a, (hl)
					or a
					jr z, pcg_generate_room__fg_chunk_object_loop_done
					cp CHUNK_LOCATION_PUSHABLE_BLOCK
					jr z, pcg_generate_room__fg_chunk_object_loop_spawn_pushable_block
					cp CHUNK_LOCATION_LAVA_GENERATOR
					jr z, pcg_generate_room__fg_chunk_object_loop_spawn_lava_generator
					cp CHUNK_LOCATION_SENTINEL
					jr z, pcg_generate_room__fg_chunk_object_loop_spawn_sentinel
					jr pcg_generate_room__fg_chunk_object_loop_next
pcg_generate_room__fg_chunk_object_loop_spawn_pushable_block:
					; it's a pushable block, spawn it:
					push hl
					push de
						ld de, (tmp_pcg_room__next_tile_object_ptr)
						xor a  ; pushable blocks have ID 0
						ld (de), a  ; ID
						inc de
						ld a, TAG_PUSHABLE_BLOCK
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
						ex de, hl
						ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE - 4  ; "- 4", since we already did 4 "inc de"
						add hl, bc
						ld (tmp_pcg_room__next_tile_object_ptr), hl
					pop de
					pop hl
					jr pcg_generate_room__fg_chunk_object_loop_next
pcg_generate_room__fg_chunk_object_loop_spawn_lava_generator:
					; it's a lava generator, spawn it:
					push hl
					push de
						ex de, hl
						ld c, PCG_PAGE_ENEMIES
						ld hl, pcg_generate_room__spawn_lava_generator
						call call_hl_in_page_c_8000
					pop de
					pop hl
					jr pcg_generate_room__fg_chunk_object_loop_next
pcg_generate_room__fg_chunk_object_loop_spawn_sentinel:
					; it's an atlantis sentinel robot, spawn it:
					push hl
					push de
						ex de, hl
						ld c, PCG_PAGE_ENEMIES
						ld hl, pcg_generate_room__spawn_sentinel
						call call_hl_in_page_c_8000
					pop de
					pop hl
; 					jr pcg_generate_room__fg_chunk_object_loop_next
pcg_generate_room__fg_chunk_object_loop_next:
					ld bc, 5
					add hl, bc
					jr pcg_generate_room__fg_chunk_object_loop
pcg_generate_room__fg_chunk_object_loop_done:
				pop bc
			pop hl
			ld a, (tmp_pcg_room__current_target_chunk_bank_id)
			ld e, a			
pcg_generate_room__fg_loop_x_skip:
			inc hl
			dec c
			jp nz, pcg_generate_room__fg_loop_x
		pop hl
		ld a, (current_area__width)
		add a, a  ; next row
		ADD_HL_A
		pop bc
		dec b
		jp nz, pcg_generate_room__fg_loop_y
	pop hl
	pop bc
	dec b
	jp nz, pcg_generate_room__fg_loop_bank_id

	; Auto-fill ladders/ropes/etc. and randomize tiles:
;     out (#2c),a  ; DEBUG
	call pcg_generate_room__prettify
;     out (#2d),a  ; DEBUG

	; Instantiate 'current_area__objects':
	ld ix, current_area__objects
pcg_generate_room__object_loop:
	ld a, (ix)
	cp #ff
	jp z, pcg_generate_room__object_loop_end
	; see if the object is in this room:
	ld a, (ix + AREA_OBJECT_STRUCT_OFFSET)
	call area_object_offset_to_x_y_in_chunks
	; convert coordinates to in-room coordinates:
	ld de, (current_room__x)  ; e = current_room__x, d = current_room__y
	or a
	rl d  ; in chunks
	rl e  ; in chunks
	ld a, c
	sub e
	jp c, pcg_generate_room__object_loop_next  ; out of bounds left 
	ld c, a  ; c = (object chunk x) - (room chunk x)
	ld a, (current_room__width_in_screens)
	add a, a  ; in chunks
	cp c  ; if a <= c, out of bounds
	jp z, pcg_generate_room__object_loop_next  ; out of bounds right 
	jp c, pcg_generate_room__object_loop_next  ; out of bounds right 
	ld a, b
	sub d
	jp c, pcg_generate_room__object_loop_next  ; out of bounds top 
	ld b, a
	ld a, (current_room__height_in_screens)
	add a, a  ; in chunks
	cp b  ; if a <= b, out of bounds
	jp z, pcg_generate_room__object_loop_next  ; out of bounds bottom 
	jp c, pcg_generate_room__object_loop_next  ; out of bounds bottom 

	; object is in this room:
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	cp TAG_BREAKABLE_WALL1
	jp z, pcg_generate_room__object_breakable_wall
	cp TAG_BREAKABLE_WALL2
	jp z, pcg_generate_room__object_breakable_wall
	cp TAG_BREAKABLE_WALL3
	jp z, pcg_generate_room__object_breakable_wall
	cp TAG_BREAKABLE_WALL4
	jp z, pcg_generate_room__object_breakable_wall
	cp TAG_LOST_VENDOR
	jp z, pcg_generate_room__object_lost_vendor	
	push ix
		ld ixl, a
		call pcg_generate_area__choose_chunks_is_chest_tag_p
		ld a, ixl
	pop ix
	jp z, pcg_generate_room__object_chest
	push ix
		ld ixl, a
		call pcg_generate_area__choose_chunks_is_item_tag_p
		ld a, ixl
	pop ix
	jp z, pcg_generate_room__object_regular_item
	push ix
		ld ixl, a
		call pcg_generate_area__choose_chunks_is_small_lock_tag_p
		ld a, ixl
	pop ix
	jp z, pcg_generate_room__object_small_lock
	push ix
		ld ixl, a
		call pcg_generate_area__choose_chunks_is_boss_tag_p
		ld a, ixl
	pop ix
	jp z, pcg_generate_room__object_boss_lock

	cp TAG_IDOL_LOCK
	jp z, pcg_generate_room__object_idol_lock
	cp TAG_GEAR_LOCK
	jp z, pcg_generate_room__object_gear_lock

	cp TAG_BUTTON_DOOR1
	jp z, pcg_generate_room__object_button_door
	cp TAG_BUTTON_DOOR2
	jp z, pcg_generate_room__object_button_door
	cp TAG_BUTTON_DOOR3
	jp z, pcg_generate_room__object_button_door
	cp TAG_BUTTON_DOOR4
	jp z, pcg_generate_room__object_button_door

	cp TAG_COMBINATION1_LOCK
	jp z, pcg_generate_room__object_combination_lock
	cp TAG_COMBINATION2_LOCK
	jp z, pcg_generate_room__object_combination_lock
	cp TAG_COMBINATION3_LOCK
	jp z, pcg_generate_room__object_combination_lock
	cp TAG_COMBINATION4_LOCK
	jp z, pcg_generate_room__object_combination_lock

	cp TAG_TRIAL1_LOCK
	jp z, pcg_generate_room__object_trial_lock
	cp TAG_TRIAL2_LOCK
	jp z, pcg_generate_room__object_trial_lock
	cp TAG_TRIAL3_LOCK
	jp z, pcg_generate_room__object_trial_lock
	cp TAG_TRIAL4_LOCK
	jp z, pcg_generate_room__object_trial_lock

	cp TAG_TELEPORTER1
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER2
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER3
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER4
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER5
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER6
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER7
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER8
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER_MARS
	jp z, pcg_generate_room__object_teleporter
	cp TAG_TELEPORTER_MOON
	jp z, pcg_generate_room__object_teleporter

	cp TAG_MIDPOINT
	jp z, pcg_generate_room__object_midpoint_door

	; ...

pcg_generate_room__object_loop_next:
	ld bc, AREA_OBJECT_STRUCT_SIZE
	add ix, bc
	jp pcg_generate_room__object_loop
pcg_generate_room__object_loop_end:

	; Render the tile objects (and then remove them), to ensure enemies are not spawned on top:
	ld hl, room_render_tile_objects
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
;     out (#2c),a  ; DEBUG
	ld c, PCG_PAGE_ENEMIES
	ld hl, pcg_generate_room__spawn_enemies
	call call_hl_in_page_c_8000
	ld c, PCG_PAGE_ENEMIES
	ld hl, pcg_generate_room__enemy_respawn_logic
	call call_hl_in_page_c_8000
;     out (#2d),a	  ; DEBUG
	ld hl, room_undraw_tile_objects
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000

	ld a, (tmp_pcg_room__is_midpoint_room)
	or a
	call nz, pcg_generate_room__open_midpoint_door

	; preserve the random seed:
	ld hl, (tmp_pcg_room__previous_seed)
	ld (rng_seed1), hl
	ld hl, (tmp_pcg_room__previous_seed + 2)
	ld (rng_seed2), hl
	ret


;-----------------------------------------------
; input:
; - ix: ptr to the area object
; - c, b: x, y of where to spawn the object (in chunks)
pcg_generate_room__object_breakable_wall:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		ld a, (ix + AREA_OBJECT_STRUCT_EXTRA)  ; get the direction of the wall
		cp PCG_DIRECTION_LEFT
		jr z, pcg_generate_room__object_breakable_wall_left
		cp PCG_DIRECTION_UP
		jr z, pcg_generate_room__object_breakable_wall_up
		cp PCG_DIRECTION_RIGHT
		jr z, pcg_generate_room__object_breakable_wall_right
pcg_generate_room__object_breakable_wall_down:
		ld e, CHUNK_LOCATION_BREAKABLE_DOWN
		jr pcg_generate_room__object_breakable_wall_mask_set
pcg_generate_room__object_breakable_wall_right:
		ld e, CHUNK_LOCATION_BREAKABLE_RIGHT
		jr pcg_generate_room__object_breakable_wall_mask_set
pcg_generate_room__object_breakable_wall_up:
		ld e, CHUNK_LOCATION_BREAKABLE_UP
		jr pcg_generate_room__object_breakable_wall_mask_set
pcg_generate_room__object_breakable_wall_left:
		ld e, CHUNK_LOCATION_BREAKABLE_LEFT
pcg_generate_room__object_breakable_wall_mask_set:

		; select one chunk location for a breakable wall that matches the direction constraint:
		call sample_chunk_location  ; de: ptr to the location
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	call pcg_generate_room__compute_object_coordinates
	inc de
	ld a, (de)  ; width
	ld l, a
	inc de
	ld a, (de)  ; height
	ld e, l
	ld d, a  ; here: c, b: x, y coordinates, e, d: width, height

	; check if the wall was already destroyed:
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_breakable_wall_continue
	; wall was already destroyed:
	push bc
	push de
		call room_remove_breakable_wall_restore_background
	pop de
	pop bc

	; check if it's a breakable wall at the bottom of a room:
	ld a, b
	add a, d
	ld d, a
	ld a, (current_room__height)
	cp d
	jp z, pcg_generate_room__maybe_replace_door_by_ladder_continue
	jp pcg_generate_room__object_loop_next


pcg_generate_room__object_breakable_wall_continue:	
	; spawn the breakable wall object:
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld a, (ix + AREA_OBJECT_STRUCT_ID)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; ID
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), a  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 8  ; state (hitpoints)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_WIDTH), e  ; width
	ld (iy + ROOM_TILE_OBJECT_STRUCT_HEIGHT), d  ; height
	ld (iy + ROOM_TILE_OBJECT_STRUCT_LAST_HIT_ID), #ff  ; can be hit by anything
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	ld a, 1
	ld (play_seashell_flag), a

	jp pcg_generate_room__object_loop_next


;-----------------------------------------------
; - ix: ptr to the area object
; - c, b: x, y of where to spawn the object (in chunks)
pcg_generate_room__object_chest:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_ITEM
		call sample_chunk_location  ; de: ptr to the location
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	; compute object coordinates:
	call pcg_generate_room__compute_object_coordinates
	; here: c, b: x, y coordinates

	; check if chest was already open:
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_regular_item_continue
	; chest was already open, see if the item was picked up
	ld d, (ix + AREA_OBJECT_STRUCT_TYPE)
	call get_chest_content  ; e = chest content
	ld hl, global_state__objects
	ld d, 0
	add hl, de
	ld a, (hl)
	or a
	jp nz, pcg_generate_room__object_loop_next  ; chest inside object was already picked up
	ld d, e
	jp pcg_generate_room__object_regular_item_continue_de_set


;-----------------------------------------------
; - ix: ptr to the area object
; - c, b: x, y of where to spawn the object (in chunks)
pcg_generate_room__object_regular_item:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_ITEM
		call sample_chunk_location  ; de: ptr to the location
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	; compute object coordinates:
	call pcg_generate_room__compute_object_coordinates
	; here: c, b: x, y coordinates

	; check if the item was already picked up (except a few special tags):
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	cp TAG_BUTTON1
	jr z, pcg_generate_room__object_regular_item_continue
	cp TAG_BUTTON2
	jr z, pcg_generate_room__object_regular_item_continue
	cp TAG_BUTTON3
	jr z, pcg_generate_room__object_regular_item_continue
	cp TAG_BUTTON4
	jr z, pcg_generate_room__object_regular_item_continue
	cp TAG_LOST_VENDOR
	jr z, pcg_generate_room__object_regular_item_continue
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_regular_item_continue
	; item was already picked up:
	jp pcg_generate_room__object_loop_next

pcg_generate_room__object_regular_item_continue:	
	; spawn the object:
	ld d, (ix + AREA_OBJECT_STRUCT_ID)
	ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
pcg_generate_room__object_regular_item_continue_de_set:
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
	call set_item_object_to_upload_to_vdp

	jp pcg_generate_room__object_loop_next


;-----------------------------------------------
; - ix: ptr to the area object
; - c, b: x, y of where to spawn the object (in chunks)
pcg_generate_room__object_small_lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	push bc
		push hl
			; compute object coordinates:
			call pcg_generate_room__compute_object_coordinates
			; here: c, b: x, y coordinates

			; spawn the lock:
			ld d, (ix + AREA_OBJECT_STRUCT_ID)
			ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld iy, (tmp_pcg_room__next_tile_object_ptr)
			ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
			ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
			ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
			ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
			ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
			ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
			add iy, bc
			ld (tmp_pcg_room__next_tile_object_ptr), iy

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			call set_item_object_to_upload_to_vdp
		pop hl  ; chunk ptr

pcg_generate_room__object_small_lock_spawn_door:
		ld a, (ix + AREA_OBJECT_STRUCT_EXTRA)  ; a = direction
		ld e, CHUNK_LOCATION_DOOR_LEFT
		cp PCG_DIRECTION_LEFT
		jr z, pcg_generate_room__object_small_lock_direction_set
		ld e, CHUNK_LOCATION_DOOR_UP
		cp PCG_DIRECTION_UP
		jr z, pcg_generate_room__object_small_lock_direction_set
		ld e, CHUNK_LOCATION_DOOR_RIGHT
		cp PCG_DIRECTION_RIGHT
		jr z, pcg_generate_room__object_small_lock_direction_set
		ld e, CHUNK_LOCATION_DOOR_DOWN
pcg_generate_room__object_small_lock_direction_set:
		call sample_chunk_location  ; de: ptr to the location

		ASSERT_D_NOT_EQ 0

	pop bc  ; coordinates in chunks

pcg_generate_room__object_small_lock_spawn_door_no_ladder_replacement:
	; Clear the background behind the door:
	call pcg_generate_room__compute_object_coordinates
	inc de
	ex de, hl
	ld e, (hl)  ; width
	inc hl
	ld d, (hl)  ; height
	push bc
		call room_remove_breakable_wall_restore_background  ; this clears the space
	pop bc

	; check if the lock has already been open
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp nz, pcg_generate_room__maybe_replace_door_by_ladder  ; item was already open, do not spawn door

	; spawn the door:
	ld a, (ix + AREA_OBJECT_STRUCT_EXTRA)  ; a = direction
	ld e, TAG_DOOR_VERTICAL
	cp PCG_DIRECTION_LEFT
	jr z, pcg_generate_room__object_small_lock_direction_set2
	ld e, TAG_DOOR_HORIZONTAL
	cp PCG_DIRECTION_UP
	jr z, pcg_generate_room__object_small_lock_direction_set2
	ld e, TAG_DOOR_VERTICAL
	cp PCG_DIRECTION_RIGHT
	jr z, pcg_generate_room__object_small_lock_direction_set2_right

	; down:
	ld e, TAG_DOOR_HORIZONTAL
	ld a, (current_room__height)
	dec a
	ld b, a  ; put the door at the bottom of the room
pcg_generate_room__object_small_lock_direction_set2:

	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 0  ; doors have ID 0
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	jp pcg_generate_room__object_loop_next

pcg_generate_room__object_small_lock_direction_set2_right:
	ld a, (current_room__width)
	dec a
	ld d, c  ; save the current 'x', in case it's not a "right" door
	ld c, a  ; put the door at the right-edge of the room
	jr pcg_generate_room__object_small_lock_direction_set2


;-----------------------------------------------
pcg_generate_room__maybe_replace_door_by_ladder:
	; c, b: x, y of the door object
	; If it's a door down to an inter-area connection, replace by a ladder:
	ld a, (ix + AREA_OBJECT_STRUCT_EXTRA)  ; a = direction
	cp PCG_DIRECTION_DOWN
	jp nz, pcg_generate_room__object_loop_next
pcg_generate_room__maybe_replace_door_by_ladder_continue:
	; is it an inter-area connection? (check if we are at the edge of the map, or there is no chunk below)
	push bc
		ld a, (current_room__y)
		ld c, a
		ld a, (current_room__height_in_screens)
		add a, c
		ld c, a
		ld a, (current_area__height)
		cp c
	pop bc
	jr z, pcg_generate_room__maybe_replace_door_by_ladder_inter_area_connection
	push bc
		; see if there is a chunk below:
		call get_player_chunk_coordinates
		inc b  ; chunk below
		ld e, PCG_PAGE
		ld hl, get_chunk_id_from_coordinates
		call call_hl_in_page_e_8000
		ld a, (hl)
		cp #ff
	pop bc
	jp nz, pcg_generate_room__object_loop_next

pcg_generate_room__maybe_replace_door_by_ladder_inter_area_connection:
	; replace by a ladder:
	ld a, (current_room__height)
	dec a
	ld b, a  ; put the ladder at the bottom of the room
	call get_room_tile_ptr
	ld (hl), 254  ; platform
	inc hl
	ld (hl), 168  ; ladder-left
	inc hl
	ld (hl), 136  ; ladder-right
	inc hl
	ld (hl), 254  ; platform
	ret

;-----------------------------------------------
pcg_generate_room__object_idol_lock:
pcg_generate_room__object_gear_lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_BIG_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	push bc
		push hl
			; compute object coordinates:
			call pcg_generate_room__compute_object_coordinates
			; here: c, b: x, y coordinates

			; spawn the lock:
			ld d, (ix + AREA_OBJECT_STRUCT_ID)
			ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld iy, (tmp_pcg_room__next_tile_object_ptr)
			ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
			ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
			ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
			ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
			ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
			ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
			add iy, bc
			ld (tmp_pcg_room__next_tile_object_ptr), iy

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			call set_large_object_to_upload_to_vdp
		pop hl  ; chunk ptr

		jp pcg_generate_room__object_small_lock_spawn_door


;-----------------------------------------------
pcg_generate_room__object_teleporter:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_BIG_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	; compute object coordinates:
	call pcg_generate_room__compute_object_coordinates
	; here: c, b: x, y coordinates

	; spawn the teleporter:
	ld d, (ix + AREA_OBJECT_STRUCT_ID)
	ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
	call set_large_object_to_upload_to_vdp
	jp pcg_generate_room__object_loop_next


;-----------------------------------------------
pcg_generate_room__object_midpoint_door:
	ld a, 1
	ld (tmp_pcg_room__is_midpoint_room), a
	; jr pcg_generate_room__object_button_door


pcg_generate_room__object_button_door:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		jp pcg_generate_room__object_small_lock_spawn_door


;-----------------------------------------------
pcg_generate_room__object_lost_vendor:
	ld a, (global_state__story)
	cp STORY_STATE__PLACED_FIRST_POWER_STONE
	jp nz, pcg_generate_room__object_loop_next
	; spawn lost vendor:
	jp pcg_generate_room__object_regular_item


;-----------------------------------------------
pcg_generate_room__object_combination_lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
	pop bc
	push hl
		push bc
			; spawn the levers:
			ld iyl, 1  ; first ID 
			ld bc, CHUNK_WIDTH * CHUNK_HEIGHT
			add hl, bc
pcg_generate_room__object_combination_lock_loop:
			ld a, (hl)
			or a
			jr z, pcg_generate_room__object_combination_lock_loop_end
			cp CHUNK_LOCATION_ITEM
			jr nz, pcg_generate_room__object_combination_lock_loop_next
		pop bc  ; recover the chunk coordinates
		push bc
			push hl
				ex de, hl
				call pcg_generate_room__compute_object_coordinates
				; spawn a lever object:
				ld a, iyl
				push iy
					ld iy, (tmp_pcg_room__next_tile_object_ptr)
					ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; ID
					ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
					ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
					ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
					ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
					ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 1  ; state
					ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
					add iy, bc
					ld (tmp_pcg_room__next_tile_object_ptr), iy
				pop iy
				inc iyl
			pop hl
pcg_generate_room__object_combination_lock_loop_next:
			inc hl
			inc hl
			inc hl
			inc hl
			inc hl
			jr pcg_generate_room__object_combination_lock_loop
pcg_generate_room__object_combination_lock_loop_end:

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			ld e, TAG_COMBINATION1_LOCK
			call set_large_object_to_upload_to_vdp

		pop bc
	pop hl
	push bc
		jp pcg_generate_room__object_small_lock_spawn_door


;-----------------------------------------------
pcg_generate_room__object_trial_lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_4X4_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	push bc
		push hl
			; compute object coordinates:
			call pcg_generate_room__compute_object_coordinates
			; here: c, b: x, y coordinates

			; spawn the lock:
			ld d, (ix + AREA_OBJECT_STRUCT_ID)
			ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld iy, (tmp_pcg_room__next_tile_object_ptr)
			ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
			ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
			ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
			ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
			ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
			ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
			add iy, bc
			ld (tmp_pcg_room__next_tile_object_ptr), iy

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			call set_large_object_to_upload_to_vdp

			; check if the lock has already been open
			ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld hl, global_state__objects
			ADD_HL_A
			ld a, (hl)
			or a
			jp nz, pcg_generate_room__object_trial_lock_continue  ; item was already open, no need to set a trial fn

			ld hl, current_world__trial_types
			ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
			sub TAG_TRIAL1_LOCK
			ADD_HL_A
			ld a, (hl)
			add a, a
			ld hl, trial_fn_ptrs
			ADD_HL_A
			ld a, (hl)
			inc hl
			ld h, (hl)
			ld l, a
			ld (current_room__trial_fn), hl

pcg_generate_room__object_trial_lock_continue:

		pop hl  ; chunk ptr

		jp pcg_generate_room__object_small_lock_spawn_door


;-----------------------------------------------
pcg_generate_room__object_boss_lock:
	; spawn the lock:
	; get the chunk type where we are placing the object:
	push bc
		call get_chunk_id_from_coordinates  ; a = chunk ID
		ld hl, (current_area__chunk_fg_bank_ptrs)
		call pcg_get_chunk_ptr
		ld e, CHUNK_LOCATION_ITEM
		push hl
			call sample_chunk_location  ; de: ptr to the location
		pop hl
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	push bc
		push hl
			; compute object coordinates:
			call pcg_generate_room__compute_object_coordinates
			; here: c, b: x, y coordinates

			; spawn the lock:
			ld d, (ix + AREA_OBJECT_STRUCT_ID)
			ld e, (ix + AREA_OBJECT_STRUCT_TYPE)
			ld iy, (tmp_pcg_room__next_tile_object_ptr)
			ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), d  ; ID
			ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), e  ; type
			ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
			ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
			ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
			ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
			add iy, bc
			ld (tmp_pcg_room__next_tile_object_ptr), iy

			; set which object gfx to up load vdp (starting at tile FIRST_ITEM_TILE):
			call set_item_object_to_upload_to_vdp
		pop hl  ; chunk ptr

		; spawn the boss door:
		ld e, CHUNK_LOCATION_4X4_ITEM
		call sample_chunk_location  ; de: ptr to the location
	pop bc  ; chunk coordinates

	ASSERT_D_NOT_EQ 0

	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	cp 2  ; boss killed
	jp z, pcg_generate_room__object_loop_next

	; compute object coordinates:
	call pcg_generate_room__compute_object_coordinates
	; here: c, b: x, y coordinates

	; spawn the lock:
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; ID (boss doors have as ID the type of the corresponding lock)
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_DOOR_BOSS  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), c  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), b  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state (hitpoints)
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, bc
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; set which object gfx to up load vdp:
	ld e, TAG_DOOR_BOSS
	call set_large_object_to_upload_to_vdp

	; check if the lock has already been open
	ld a, (ix + AREA_OBJECT_STRUCT_TYPE)
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	jp z, pcg_generate_room__object_loop_next  ; door was already open

	; change door image to open:
	ld hl, buffer_4096 + (48 + 32) * 16  ; boss door frame 2
	ld (large_object_to_upload_to_vdp), hl

	jp pcg_generate_room__object_loop_next


;-----------------------------------------------
; - a = (random % 8) % l
pcg_generate_room__sample_door_position_chunk_sample:
	call random_a
	and #07
pcg_generate_room__sample_door_position_chunk_sample_loop:
	cp l
	ret c
	sub l
	jr pcg_generate_room__sample_door_position_chunk_sample_loop


;-----------------------------------------------
; input:
; - de: ptr to a chunk location
; - c, b: x, y of where to spawn the object (in chunks)
; output:
; - c, b: x, y coordinates
pcg_generate_room__compute_object_coordinates:
	inc de  ; skip type
	; x = c * CHUNK_WIDTH + (de)
	ld a, c
	add a, a
	add a, a
	add a, a
	add a, a  ; assumes CHUNK_WIDTH = 16
	ld c, a
	ld a, (de)  ; x
	add a, c
	ld c, a
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), a  ; x
	inc de
	; y = b * CHUNK_HEIGHT + (de)
	ld a, b
	add a, a
	add a, a
	ld b, a
	add a, a
	add a, b  ; assumes CHUNK_HEIGHT = 12
	ld b, a
	ld a, (de)  ; y
	add a, b
	ld b, a
	ret


;-----------------------------------------------
; input:
; - hl: ptr to chunk
; - e: location type
; output:
; - de: ptr to the selected location
sample_chunk_location:
	ld a, e
	ld bc, CHUNK_WIDTH * CHUNK_HEIGHT
	add hl, bc
	ld b, MAX_CHUNK_LOCATIONS
	ld de, 0
sample_chunk_location_loop:
	cp (hl)
	jr nz, sample_chunk_location_loop_next
	push af
		ld a, d
		or a
		jr z, sample_chunk_location_select
		call random_a
		and #01
		jr z, sample_chunk_location_skip
sample_chunk_location_select:
		ld d, h
		ld e, l
sample_chunk_location_skip:
	pop af
sample_chunk_location_loop_next:
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	djnz sample_chunk_location_loop
	ret


;-----------------------------------------------
; input:
; - c, b: x, y of where to spawn the object (in chunks)
get_chunk_id_from_coordinates:
	ld a, (current_room__x)
	add a, a
	add a, c
	ld c, a
	ld a, (current_room__y)
	add a, a
	add a, b
	ld b, a

	; chunk id = (current_area__chunks_ids + c + b * (current_area__width) * 2)
	ld a, (current_area__width)
	add a, a
	ld e, a
	ld d, 0
	ld hl, 0
	ld a, b
	or a
	jr z, get_chunk_id_from_coordinates_loop_done
get_chunk_id_from_coordinates_loop:
	add hl, de
	djnz get_chunk_id_from_coordinates_loop
get_chunk_id_from_coordinates_loop_done:
	ld b, 0
	add hl, bc
	ld bc, current_area__chunks_ids
	add hl, bc
	ld a, (hl)
	ret


;-----------------------------------------------
pcg_generate_room_background:
	ld a, (current_area__id)
	or a
	ret z  ; no background for jungle
	cp 3
	jp z, pcg_generate_room_background_caves
	cp 6
	jp z, pcg_generate_room_background_caves
	cp 7
	jp z, pcg_generate_room_background_caves
	cp 8
	jp z, pcg_generate_room_background_xibalba
	cp 9
	jp z, pcg_generate_room_background_atlantis
	jp pcg_generate_room_background_pyramid


;-----------------------------------------------
; input:
; - hl: ptr to the fg chunk types
pcg_generate_room_background_caves:
	ld de, caves_chunk_bg_bank_ptrs
	ld (tmp_pcg_room__current_chunk_bg_bank_ptrs), de
	jr pcg_generate_room_background_pyramid_continue
pcg_generate_room_background_xibalba:
	ld de, xibalba_chunk_bg_bank_ptrs
	ld (tmp_pcg_room__current_chunk_bg_bank_ptrs), de
	jr pcg_generate_room_background_pyramid_continue
pcg_generate_room_background_atlantis:
	ld de, atlantis_chunk_bg_bank_ptrs
	ld (tmp_pcg_room__current_chunk_bg_bank_ptrs), de
	jr pcg_generate_room_background_pyramid_continue
pcg_generate_room_background_pyramid:
	ld de, pyramid_chunk_bg_bank_ptrs
	ld (tmp_pcg_room__current_chunk_bg_bank_ptrs), de
pcg_generate_room_background_pyramid_continue:
	xor a
	ld (tmp_pcg_room__current_target_chunk_bank_id), a	
	ld a, #ff
	ld (tmp_pcg_room__current_decompressed_chunk_bank_id), a	
	ld b, iyh
	sla b  ; width in "chunks"
	ld c, iyl
	sla c  ; height in "chunks"
pcg_generate_room__bg_loop_y:
	push bc
	push hl
pcg_generate_room__bg_loop_x:
		call pcg_generate_room_get_fg_chunk_flags
		and CHUNK_FLAG_BOSS_MASK
		jr nz, pcg_generate_room__bg_loop_empty_chunk
		; pick a background chunk:

; current_area__n_bg_chunks: ds virtual 1
; current_area__p_of_first_bg_chunk: ds virtual 1

		ld a, (current_area__p_of_first_bg_chunk)
		or a
		jr z, pcg_generate_room__bg_loop_empty_chunk
		push bc
			ld c, a
			call random_a
			cp c
		pop bc
		jr c, pcg_generate_room__bg_loop_empty_chunk
		ld a, (current_area__n_bg_chunks)
		dec a
		jr z, pcg_generate_room__bg_loop_empty_chunk
		push bc
			ld c, a
			call random_modulo
		pop bc
		push bc
			ld hl, (tmp_pcg_room__current_chunk_bg_bank_ptrs)
			call pcg_get_chunk_ptr  ; hl = ptr of the chunk to copy
		pop bc
		push bc
			call pcg_generate_room_copy_chunk_to_room_overwrite
		pop bc
pcg_generate_room__bg_loop_empty_chunk:
		inc hl
		dec c
		jr nz, pcg_generate_room__bg_loop_x
	pop hl
	pop bc
	ld a, (current_area__width)
	add a, a
	ld d, 0
	ld e, a
	add hl, de
	djnz pcg_generate_room__bg_loop_y
	ret


;-----------------------------------------------
; input: 
; - hl: ptr to fg chunk type
; output:
; - a: flags
pcg_generate_room_get_fg_chunk_flags:
	push hl
	push bc
		ld a, (hl)
		ld hl, (current_area__chunk_flags_ptr)
		ld c, a
		ld b, 0
		add hl, bc  ; each chunk has 5 bytes
		add hl, bc
		add hl, bc
		add hl, bc
		add hl, bc
		inc hl
		ld a, (hl)
	pop bc
	pop hl
	ret


;-----------------------------------------------
pcg_generate_room_copy_chunk_to_room_set_ptrs:
	; - Coordinates will be: (iyl*2 - c), (iyh*2 - b)
	; - Address to start the copy is thus:
	;     current_room__tile_map + (iyh*2 - b) * iyl * 32 * 12 + (iyl*2 - c) * 16
	push hl
		ld a, iyh
		add a, a
		sub b
		ld e, a
		ld d, 0
		ld l, e
		ld h, d  ; hl, de = (iyh*2 - b)
		ld a, iyl
pcg_generate_room_copy_chunk_to_room_loop1:
		dec a
		jr z, pcg_generate_room_copy_chunk_to_room_continue
		add hl, de
		jp pcg_generate_room_copy_chunk_to_room_loop1
pcg_generate_room_copy_chunk_to_room_continue:
		; hl = ((iyh*2 - b) * iyl

		ld d, l
		ld e, 0
		ld h, l
		ld l, e
		srl d
		rr e
		add hl, de  ; hl *= 32 * 12

		ld a, iyl
		add a, a
		sub c
		add a, a
		add a, a
		add a, a
		add a, a
		ld e, a
		ld d, 0
		add hl, de  ; hl = (iyh*2 - b) * iyl * 32 + (iyl*2 - c) * 16

		ld de, current_room__tile_map
		add hl, de
		ex de, hl  ; de = current_room__tile_map + (iyh*2 - b) * iyl * 32 + (iyl*2 - c) * 16
	pop hl
	ret


;-----------------------------------------------
; This method only copies those tiles that are != 0.
; input:
; - hl: ptr to chunk
; - iyl/iyh: room width/height in screens.
; - c/b: x, y coordinates where to add this chunk in the current room.
pcg_generate_room_copy_chunk_to_room:
	call pcg_generate_room_copy_chunk_to_room_set_ptrs
	ld b, CHUNK_HEIGHT
	ld c, CHUNK_WIDTH
pcg_generate_room_copy_chunk_to_room_loop_y:
	push bc
		xor a
		ld b, a
pcg_generate_room_copy_chunk_to_room_loop_x:
		cp (hl)
		jp z, pcg_generate_room_copy_chunk_to_room_loop_x_skip
		ldi
		jp pe, pcg_generate_room_copy_chunk_to_room_loop_x
		jp pcg_generate_room_copy_chunk_to_room_loop_x_continue
pcg_generate_room_copy_chunk_to_room_loop_x_skip:
		inc hl
		inc de
		dec c
		jp nz, pcg_generate_room_copy_chunk_to_room_loop_x
pcg_generate_room_copy_chunk_to_room_loop_x_continue:
		ld a, (current_room__width)
		sub CHUNK_WIDTH
		ld c, a  ; b is already 0 here
		ex de, hl
			add hl, bc
		ex de, hl
	pop bc
	djnz pcg_generate_room_copy_chunk_to_room_loop_y
	ret


;-----------------------------------------------
; This method only copies all tiles (unlike the above)
; input:
; - hl: ptr to chunk
; - iyl/iyh: room width/height in screens.
; - c/b: x, y coordinates where to add this chunk in the current room.
pcg_generate_room_copy_chunk_to_room_overwrite:
	call pcg_generate_room_copy_chunk_to_room_set_ptrs
	ld b, CHUNK_HEIGHT
pcg_generate_room_copy_chunk_to_room_overwrite_loop_y:
	push bc
REPT CHUNK_WIDTH
		ldi
ENDR
		ld a, (current_room__width)
		sub CHUNK_WIDTH
		ld b, 0
		ld c, a
		ex de, hl
			add hl, bc
		ex de, hl
	pop bc
	djnz pcg_generate_room_copy_chunk_to_room_overwrite_loop_y
	ret


;-----------------------------------------------
; input:
; - a: chunk number
; - hl: pointer to bank pointers
; output:
; - hl: ptr to chunk
pcg_get_chunk_ptr:
	push af
		; 8 chunks per bank:
		rrca
		rrca
		rrca
		and #1e
		ld de, (tmp_pcg_room__current_decompressed_chunk_bank_id)  ; e = tmp_pcg_room__current_decompressed_chunk_bank_id
		cp e
		jr z, pcg_get_chunk_ptr_already_loaded
		ld (tmp_pcg_room__current_decompressed_chunk_bank_id), a  ; store the current chunk bank (*2)
		ADD_HL_A
		ld e, (hl)
		inc hl
		ld h, (hl)
		ld l, e
		ld a, (current_area__chunks_page)
		ld c, a
		ld de, buffer_4096
		call dzx0_from_page_c
pcg_get_chunk_ptr_already_loaded:
	pop af
	; hl = buffer_4096 + a * CHUNK_SIZE
	ld hl, buffer_4096
	and #0f
	ret z
	ld b, a
	ld de, CHUNK_SIZE
pcg_get_chunk_ptr_loop:
	add hl, de
	djnz pcg_get_chunk_ptr_loop
	ret


;-----------------------------------------------
; input:
; - a: offset (x+y*width)
; output:
; - c, b: x, y in chunk coordinates
area_object_offset_to_x_y_in_chunks:
	push af
		ld a, (current_area__width)
		add a, a
		ld e, a  ; width in chunks
	pop af
	ld b, 0
area_object_offset_to_x_y_in_chunks_loop:
	cp e
	jr c, area_object_offset_to_x_y_in_chunks_loop_done
	sub e
	inc b
	jp area_object_offset_to_x_y_in_chunks_loop
area_object_offset_to_x_y_in_chunks_loop_done:
	ld c, a
	ret


;-----------------------------------------------
; input:
; - d: chest object ID
; output:
; - z: not found
; - nz: found
; - e: object ID
get_chest_content:
	ld hl, current_world__chest_content
get_chest_content_loop:
	ld a, (hl)
	cp #ff
	ret z
	cp d
	jr z, get_chest_content_found
	inc hl
	inc hl
	jr get_chest_content_loop

get_chest_content_found:
	inc hl
	ld e, (hl)
	or 1  ; nz
	ret


;-----------------------------------------------
; input:
; - e: item ID
set_item_object_to_upload_to_vdp:
	; check for open locks:
	ld a, e
	cp TAG_BALL_LOCK
	jr z, set_item_object_to_upload_to_vdp_ball_lock
	cp TAG_ASTRONAUT_LOCK
	jr z, set_item_object_to_upload_to_vdp_astronaut_lock
	cp TAG_BUTTON1
	jr z, set_item_object_to_upload_to_vdp_button
	cp TAG_BUTTON2
	jr z, set_item_object_to_upload_to_vdp_button
	cp TAG_BUTTON3
	jr z, set_item_object_to_upload_to_vdp_button
	cp TAG_BUTTON4
	jr z, set_item_object_to_upload_to_vdp_button
	ld hl, object_tiles_start_ptrs
	ld d, 0
	add hl, de
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
set_item_object_to_upload_to_vdp_continue:
	ld (item_object_to_upload_to_vdp), hl
	ret

set_item_object_to_upload_to_vdp_ball_lock:
	ld hl, buffer_4096 + 54 * 64  ; ball lock (locked)
	ld a, (global_state__objects + TAG_BALL_LOCK)
	or a
	jr z, set_item_object_to_upload_to_vdp_continue
	ld hl, buffer_4096 + 55 * 64  ; ball lock (unlocked)
	jr set_item_object_to_upload_to_vdp_continue

set_item_object_to_upload_to_vdp_astronaut_lock:
	ld hl, buffer_4096 + 56 * 64  ; astronaut lock (locked)
	ld a, (global_state__objects + TAG_ASTRONAUT_LOCK)
	or a
	jr z, set_item_object_to_upload_to_vdp_continue
	ld hl, buffer_4096 + 57 * 64  ; astronaut lock (unlocked)
	jr set_item_object_to_upload_to_vdp_continue

set_item_object_to_upload_to_vdp_button:
	ld hl, global_state__objects
	ADD_HL_A
	ld a, (hl)
	or a
	ld hl, buffer_4096 + 58 * 64  ; button (not pressed)
	jr z, set_item_object_to_upload_to_vdp_continue
	ld hl, buffer_4096 + 59 * 64  ; button (pressed)
	jr set_item_object_to_upload_to_vdp_continue


;-----------------------------------------------
; input:
; - e: item ID
set_large_object_to_upload_to_vdp:
	ld a, e
	cp TAG_COMBINATION1_LOCK
	jr z, set_large_object_to_upload_to_vdp_combination_lock
	cp TAG_IDOL_LOCK
	jr z, set_large_object_to_upload_to_vdp_idol_lock
	cp TAG_GEAR_LOCK
	jp z, set_large_object_to_upload_to_vdp_gear_lock
	cp TAG_TRIAL1_LOCK
	jr z, set_large_object_to_upload_to_vdp_trial1_lock
	cp TAG_TRIAL2_LOCK
	jr z, set_large_object_to_upload_to_vdp_trial2_lock
	cp TAG_TRIAL3_LOCK
	jr z, set_large_object_to_upload_to_vdp_trial3_lock
	cp TAG_TRIAL4_LOCK
	jr z, set_large_object_to_upload_to_vdp_trial4_lock
	cp TAG_DOOR_BOSS
	jr z, set_large_object_to_upload_to_vdp_boss_door
	cp TAG_TELEPORTER_MARS
	jr z, set_large_object_to_upload_to_vdp_teleporter_activated_by_player
	cp TAG_TELEPORTER_MOON
	jr z, set_large_object_to_upload_to_vdp_teleporter_activated_by_player
	; teleporters:
	ld a, (global_state__n_power_stones_in_calendar)
	or a
	jr z, set_large_object_to_upload_to_vdp__teleporter_off
	; check if the teleporter was activated by the player:
	ld d, 0
	ld hl, global_state__objects
	add hl, de
	ld a, (hl)
	or a
	jr nz, set_large_object_to_upload_to_vdp_teleporter_activated_by_player
	ld e, 12*8
	ld hl, buffer_4096 + 178 * 16  ; teleporter on
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_teleporter_activated_by_player:
	ld e, 12*8
	ld hl, buffer_4096 + 190 * 16  ; teleporter activated by player
	jr set_large_object_to_upload_to_vdp_ptr_set	
set_large_object_to_upload_to_vdp__teleporter_off:
	ld e, 12*8
	ld hl, buffer_4096 + 166 * 16  ; teleporter off
	jr set_large_object_to_upload_to_vdp_ptr_set	
set_large_object_to_upload_to_vdp_boss_door:
	ld e, 16*8
	ld hl, buffer_4096 + 48 * 16  ; boss door
	ld a, (current_area__id)
	cp 9  ; atlantis
	jr nz, set_large_object_to_upload_to_vdp_ptr_set
	ld hl, buffer_4096 + 202 * 16  ; boss door golden
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_trial1_lock:
	ld e, 16*8
	ld hl, buffer_4096 + 102 * 16  ; god 1 image
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_trial2_lock:
	ld e, 16*8
	ld hl, buffer_4096 + 118 * 16  ; god 2 image
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_trial3_lock:
	ld e, 16*8
	ld hl, buffer_4096 + 134 * 16  ; god 3 image
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_trial4_lock:
	ld e, 16*8
	ld hl, buffer_4096 + 150 * 16  ; god 4 image
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_combination_lock:
	ld e, 6*8
	ld hl, buffer_4096 + 96 * 16  ; lever
	jr set_large_object_to_upload_to_vdp_ptr_set
set_large_object_to_upload_to_vdp_idol_lock:
	ld hl, buffer_4096 + 0 * 16
	ld e, 12*8
	ld a, (global_state__objects + TAG_IDOL_LOCK)
	or a
	jr z, set_large_object_to_upload_to_vdp_ptr_set
	ld hl, buffer_4096 + 12 * 16
	jr set_large_object_to_upload_to_vdp_ptr_set

set_large_object_to_upload_to_vdp_gear_lock:
	ld hl, buffer_4096 + 24 * 16
	ld e, 12*8
	ld a, (global_state__objects + TAG_GEAR_LOCK)
	or a
	jr z, set_large_object_to_upload_to_vdp_ptr_set
	ld hl, buffer_4096 + 36 * 16
set_large_object_to_upload_to_vdp_ptr_set:
	ld (large_object_to_upload_to_vdp), hl
	ld a, e
	ld (large_object_to_upload_to_vdp_size), a
	ret


;-----------------------------------------------
object_tiles_start_ptrs:
REPT TAG_RED_LOCK
	dw buffer_4096
ENDR
	dw buffer_4096 + 48 * 64  ; TAG_RED_LOCK
	dw buffer_4096 + 49 * 64  ; TAG_GREEN_LOCK
	dw buffer_4096 + 50 * 64  ; TAG_BLUE_LOCK
	dw buffer_4096 + 51 * 64  ; TAG_YELLOW_LOCK
	dw buffer_4096 + 52 * 64  ; TAG_WHITE_LOCK
	dw buffer_4096 + 53 * 64  ; TAG_PURPLE_LOCK
REPT TAG_BALL_LOCK - TAG_TRIAL1_LOCK
	dw buffer_4096
ENDR
	dw buffer_4096 + 54 * 64  ; TAG_BALL_LOCK: equ 27
	dw buffer_4096  ; TAG_IDOL_LOCK: equ 28
	dw buffer_4096  ; TAG_GEAR_LOCK: equ 29
	dw buffer_4096 + 56 * 64  ; TAG_ASTRONAUT_LOCK: equ 30
REPT TAG_BUTTON1 - TAG_START
	dw buffer_4096
ENDR
; TAG_START: equ 31
; TAG_ENDING: equ 32
; TAG_MIDPOINT: equ 33
; TAG_TELEPORTER_ATLANTIS: equ 34
; TAG_TELEPORTER_MARS: equ 35
; TAG_TELEPORTER_MOON: equ 36
	dw buffer_4096 + 58 * 64  ; TAG_BUTTON1
	dw buffer_4096 + 58 * 64  ; TAG_BUTTON2
	dw buffer_4096 + 58 * 64  ; TAG_BUTTON3
	dw buffer_4096 + 58 * 64  ; TAG_BUTTON4
	dw buffer_4096 + 8 * 64  ; TAG_RED_KEY
	dw buffer_4096 + 9 * 64  ; TAG_GREEN_KEY
	dw buffer_4096 + 10 * 64  ; TAG_BLUE_KEY
	dw buffer_4096 + 11 * 64  ; TAG_YELLOW_KEY
	dw buffer_4096 + 12 * 64  ; TAG_WHITE_KEY
	dw buffer_4096 + 13 * 64  ; TAG_PURPLE_KEY
	dw buffer_4096 + 41 * 64  ; TAG_RED_CHEST
	dw buffer_4096 + 42 * 64  ; TAG_GREEN_CHEST
	dw buffer_4096 + 43 * 64  ; TAG_BLUE_CHEST
	dw buffer_4096 + 44 * 64  ; TAG_YELLOW_CHEST
	dw buffer_4096 + 45 * 64  ; TAG_WHITE_CHEST
	dw buffer_4096 + 46 * 64  ; TAG_PURPLE_CHEST
	dw buffer_4096 + 60 * 64  ; TAG_TRIAL1_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_TRIAL2_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_TRIAL3_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_TRIAL4_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_COMBINATION1_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_COMBINATION2_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_COMBINATION3_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_COMBINATION4_CLUE
	dw buffer_4096 + 14 * 64  ; TAG_BALL_KEY
	dw buffer_4096 + 15 * 64  ; TAG_IDOL_KEY
	dw buffer_4096 + 16 * 64  ; TAG_GEAR_KEY
	dw buffer_4096 + 17 * 64  ; TAG_ASTRONAUT_KEY
	dw buffer_4096  ; TAG_BOSS1
	dw buffer_4096 + 0 * 64  ; TAG_BOSS1_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS1_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS2
	dw buffer_4096 + 1 * 64  ; TAG_BOSS2_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS2_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS3
	dw buffer_4096 + 2 * 64  ; TAG_BOSS3_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS3_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS4
	dw buffer_4096 + 3 * 64  ; TAG_BOSS4_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS4_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS5
	dw buffer_4096 + 4 * 64  ; TAG_BOSS5_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS5_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS6
	dw buffer_4096 + 5 * 64  ; TAG_BOSS6_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS6_CHESTLOCK
	dw buffer_4096  ; TAG_BOSS7
	dw buffer_4096 + 6 * 64  ; TAG_BOSS7_KEY
	dw buffer_4096 + 7 * 64  ; TAG_BOSS7_CHESTLOCK
	dw buffer_4096 + 27 * 64  ; TAG_WEAPON_HAMMER
	dw buffer_4096 + 28 * 64  ; TAG_WEAPON_MACUAHUITL
	dw buffer_4096 + 29 * 64  ; TAG_WEAPON_SHIELD
	dw buffer_4096 + 30 * 64  ; TAG_WEAPON_SLING
	dw buffer_4096 + 31 * 64  ; TAG_WEAPON_BLOWGUN
	dw buffer_4096 + 32 * 64  ; TAG_WEAPON_ATLATL
	dw buffer_4096 + 33 * 64  ; TAG_WEAPON_RAYGUN
	dw buffer_4096 + 34 * 64  ; TAG_WEAPON_OBSIDIAN_KNIVE
	dw buffer_4096 + 35 * 64  ; TAG_WEAPON_FIRE_HAMMER
	dw buffer_4096 + 36 * 64  ; TAG_WEAPON_ICE_MACUAHUITL
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE1
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE2
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE3
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE4
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE5
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE6
	dw buffer_4096 + 38 * 64  ; TAG_MAP_PIECE7
	dw buffer_4096 + 39 * 64  ; TAG_HEART1
	dw buffer_4096 + 39 * 64  ; TAG_HEART2
	dw buffer_4096 + 39 * 64  ; TAG_HEART3
	dw buffer_4096 + 39 * 64  ; TAG_HEART4
	dw buffer_4096 + 39 * 64  ; TAG_HEART5
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE1
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE2
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE3
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE4
	dw buffer_4096 + 60 * 64  ; TAG_MAYA_RIDDLE_CLUE5
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA1
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA2
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA3
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA4
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA5
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA6
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA7
	dw buffer_4096 + 60 * 64  ; TAG_STORY_TRIVIA8
	dw buffer_4096 + 18 * 64  ; TAG_ITEM_SANDALS
	dw buffer_4096 + 19 * 64  ; TAG_ITEM_GLOVES
	dw buffer_4096 + 20 * 64  ; TAG_ITEM_WARRIOR_HAT
	dw buffer_4096 + 21 * 64  ; TAG_ITEM_ARMOR
	dw buffer_4096 + 22 * 64  ; TAG_ITEM_CHAAC
	dw buffer_4096 + 23 * 64  ; TAG_ITEM_SEASHELL
	dw buffer_4096 + 24 * 64  ; TAG_ITEM_BELT
	dw buffer_4096 + 25 * 64  ; TAG_ITEM_ICE_CAPE
	dw buffer_4096 + 37 * 64  ; TAG_SMALL_KEY1
	dw buffer_4096 + 37 * 64  ; TAG_SMALL_KEY2
	dw buffer_4096 + 37 * 64  ; TAG_SMALL_KEY3
	dw buffer_4096 + 37 * 64  ; TAG_SMALL_KEY4
	dw buffer_4096 + 40 * 64  ; TAG_SMALL_KEY_CHEST1
	dw buffer_4096 + 40 * 64  ; TAG_SMALL_KEY_CHEST2
	dw buffer_4096 + 40 * 64  ; TAG_SMALL_KEY_CHEST3
	dw buffer_4096 + 40 * 64  ; TAG_SMALL_KEY_CHEST4
	dw buffer_4096  ; TAG_TELEPORTER1
	dw buffer_4096  ; TAG_TELEPORTER2
	dw buffer_4096  ; TAG_TELEPORTER3
	dw buffer_4096  ; TAG_TELEPORTER4
	dw buffer_4096  ; TAG_TELEPORTER5
	dw buffer_4096  ; TAG_TELEPORTER6
	dw buffer_4096  ; TAG_TELEPORTER7
	dw buffer_4096  ; TAG_TELEPORTER8
	dw buffer_4096 + 60 * 64  ; TAG_CALENDAR_NAME_CLUE
	dw buffer_4096  ; TAG_LOST_VENDOR
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_STORY1
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_STORY2
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_STORY3
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_STORY4
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_STORY5
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_LORDS1
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_LORDS2
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_LORDS3
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_LORDS4
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_LORDS5
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_LORDS6
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_LORDS7
	dw buffer_4096 + 60 * 64  ; TAG_XIBALBA_CLUE
	dw buffer_4096 + 60 * 64  ; TAG_ATLANTIS_TABLET1
	dw buffer_4096 + 60 * 64  ; TAG_ATLANTIS_TABLET2
	dw buffer_4096 + 60 * 64  ; TAG_ATLANTIS_TABLET3
	dw buffer_4096 + 60 * 64  ; TAG_ATLANTIS_TABLET4
	dw buffer_4096 + 60 * 64  ; TAG_ATLANTIS_TABLET5


;-----------------------------------------------
pcg_generate_room__start:
	; name table:
	ld hl, start_room_zx0
	ld de, current_room__tile_map
	ld c, MAP_PAGE
	call dzx0_from_page_c

	; tile sets, collisions, and animation ptrs:
	ld bc, tiles_jungle_zx0
	ld (current_room__tileset_ptr), bc
	ld a, AREA_COLLISION_TABLES_PAGE
	ld (current_room__collision_ptr_page), a
	ld bc, tile_collision_types_jungle
	ld (current_room__collision_ptr), bc
	ld a, JUNGLE_TILES_PAGE
	ld (current_room__tileset_page), a
	xor a
	ld (current_room__tileset_overrides_item_tiles), a
		ld hl, jungle_start_npc_sprites_zx0
	ld (current_room__enemy_sprites_ptr), hl

	; open/close the appropriate walls:
	ld a, (current_room__y)
	add a, a  ; y in chunks
	ld b, a
	ld a, (current_area__width)
	add a, a  ; width in chunks
	ld c, a
	ld a, b
	or a
	ld a, 0
	jr z, pcg_generate_room__start_ptr_loop_end
pcg_generate_room__start_ptr_loop:
	add a, c
	djnz pcg_generate_room__start_ptr_loop
pcg_generate_room__start_ptr_loop_end:
	ld c, a
	ld a, (current_room__x)
	add a, a
	add a, c
	ld hl, current_area__chunks_ids
	ADD_HL_A
	ld a, (hl)  ; top-left chunk ID
	push hl
		ld b, PCG_DIRECTION_UP
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__start_continue1
		ld bc, #0002
		ld de, #010c
		call room_remove_breakable_wall_restore_background
pcg_generate_room__start_continue1:
	pop hl
	inc hl
	ld a, (hl)  ; top-right chunk ID
	push hl
		ld b, PCG_DIRECTION_UP
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__start_continue2
		ld bc, #0012
		ld de, #010c
		call room_remove_breakable_wall_restore_background
pcg_generate_room__start_continue2:
	pop hl
	ld a, (hl)  ; top-right chunk ID
	push hl
		ld b, PCG_DIRECTION_RIGHT
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__start_continue3
		ld bc, #021e
		ld de, #0802
		call room_remove_breakable_wall_restore_background
		ld hl, current_room__tile_map + 30 + 1*32
		ld (hl), 229
		inc hl
		ld (hl), 230
		ld hl, current_room__tile_map + 30 + 10*32
		ld (hl), 197
		inc hl
		ld (hl), 198
pcg_generate_room__start_continue3:
	pop hl
	ld a, (current_area__width)
	add a, a  ; width in chunks
	ld e, a
	ld d, 0
	add hl, de
	ld a, (hl)  ; bottom-right chunk ID
	push hl
		ld b, PCG_DIRECTION_RIGHT
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__start_continue4
		ld bc, #0e1e
		ld de, #0802
		call room_remove_breakable_wall_restore_background
pcg_generate_room__start_continue4:
	pop hl	
	ld a, (hl)  ; bottom-right chunk ID
	push hl
		ld b, PCG_DIRECTION_DOWN
		call pcg_generate_room__chunk_direction_open
		jr nz, pcg_generate_room__start_continue5
		call pcg_generate_room__start_remove_ropes_bottom_right
pcg_generate_room__start_continue5:
	pop hl
	dec hl
	ld a, (hl)  ; bottom-left chunk ID
	ld b, PCG_DIRECTION_DOWN
	call pcg_generate_room__chunk_direction_open
	jr nz, pcg_generate_room__start_continue6
	call pcg_generate_room__start_remove_ropes_bottom_left
pcg_generate_room__start_continue6:

	; Check if there is an inter-area connection (and we need to spawn a ladder, and remove the ropes):
	; each connection is 8 bytes: ; id1, id2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)
	ld ix, current_world__interarea_connections
	ld a, (ix)
	or a
	jr nz, pcg_generate_room__start_no_interarea_connection
	ld a, (ix + 1)
	cp 1
	jr nz, pcg_generate_room__start_no_interarea_connection
	ld a, (current_room__y)
	add a, a
	inc a  ; *2 + 1 t convert it to chunk coordinates
	cp (ix + 3)
	jr nz, pcg_generate_room__start_no_interarea_connection
	ld a, (current_room__x)
	add a, a
	cp (ix + 2)
	jr z, pcg_generate_room__start_interarea_connection_bottom_left
	inc a
	cp (ix + 2)
	jr nz, pcg_generate_room__start_no_interarea_connection
pcg_generate_room__start_interarea_connection_bottom_right:
	call pcg_generate_room__start_remove_ropes_bottom_right
	ld hl, current_room__tile_map + 23 + 22*32
	ld (hl), 168  ; ladder left
	inc hl
	ld (hl), 136  ; ladder right
	ld hl, current_room__tile_map + 23 + 23*32
	ld (hl), 248  ; ladder left
	inc hl
	ld (hl), 167  ; ladder right
	jr pcg_generate_room__start_no_interarea_connection
pcg_generate_room__start_interarea_connection_bottom_left:
	call pcg_generate_room__start_remove_ropes_bottom_left
	ld hl, current_room__tile_map + 7 + 22*32
	ld (hl), 168  ; ladder left
	inc hl
	ld (hl), 136  ; ladder right
	ld hl, current_room__tile_map + 7 + 23*32
	ld (hl), 248  ; ladder left
	inc hl
	ld (hl), 167  ; ladder right
pcg_generate_room__start_no_interarea_connection:

	; random seed stela left:
	ld de, (current_world__seed)
	bit 7, d
	jr z, pcg_generate_room__start_seed_stela_bit0_done
	ld hl, current_room__tile_map + 4 + 3*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit0_done:
	bit 6, d
	jr z, pcg_generate_room__start_seed_stela_bit1_done
	ld hl, current_room__tile_map + 4 + 2*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit1_done:
	bit 5, d
	jr z, pcg_generate_room__start_seed_stela_bit2_done
	ld hl, current_room__tile_map + 5 + 2*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit2_done:
	bit 4, d
	jr z, pcg_generate_room__start_seed_stela_bit3_done
	ld hl, current_room__tile_map + 6 + 2*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit3_done:
	bit 3, d
	jr z, pcg_generate_room__start_seed_stela_bit4_done
	ld hl, current_room__tile_map + 7 + 2*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit4_done:
	bit 2, d
	jr z, pcg_generate_room__start_seed_stela_bit5_done
	ld hl, current_room__tile_map + 7 + 3*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit5_done:

	; random seed stela center:
	bit 1, d
	jr z, pcg_generate_room__start_seed_stela_bit6_done
	ld hl, current_room__tile_map + 12 + 6*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit6_done:
	bit 0, d
	jr z, pcg_generate_room__start_seed_stela_bit7_done
	ld hl, current_room__tile_map + 13 + 5*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit7_done:
	bit 7, e
	jr z, pcg_generate_room__start_seed_stela_bit8_done
	ld hl, current_room__tile_map + 14 + 5*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit8_done:
	bit 6, e
	jr z, pcg_generate_room__start_seed_stela_bit9_done
	ld hl, current_room__tile_map + 15 + 6*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit9_done:

	; random seed stela right:
	bit 5, e
	jr z, pcg_generate_room__start_seed_stela_bit10_done
	ld hl, current_room__tile_map + 19 + 4*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit10_done:
	bit 4, e
	jr z, pcg_generate_room__start_seed_stela_bit11_done
	ld hl, current_room__tile_map + 19 + 3*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit11_done:
	bit 3, e
	jr z, pcg_generate_room__start_seed_stela_bit12_done
	ld hl, current_room__tile_map + 20 + 3*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit12_done:
	bit 2, e
	jr z, pcg_generate_room__start_seed_stela_bit13_done
	ld hl, current_room__tile_map + 21 + 3*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit13_done:
	bit 1, e
	jr z, pcg_generate_room__start_seed_stela_bit14_done
	ld hl, current_room__tile_map + 22 + 3*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit14_done:
	bit 0, e
	jr z, pcg_generate_room__start_seed_stela_bit15_done
	ld hl, current_room__tile_map + 22 + 4*32
	ld (hl), 223
pcg_generate_room__start_seed_stela_bit15_done:

	; break each of the 3 stelae based on their condition:
	ld a, (current_world__stela_status)
	bit 0, a
	ld hl, current_room__tile_map + 3 + 0*32
	call z, pcg_generate_room__start_destroy_stella
	ld a, (current_world__stela_status)
	bit 1, a
	ld hl, current_room__tile_map + 11 + 3*32
	call z, pcg_generate_room__start_destroy_stella
	ld a, (current_world__stela_status)
	bit 2, a
	ld hl, current_room__tile_map + 18 + 1*32
	call z, pcg_generate_room__start_destroy_stella

	; spawn the NPCs (each NPC has a sprite object to render it, and then an invisible tile object behind, to interact with it):
	ld iy, (tmp_pcg_room__next_tile_object_ptr)

	call ptr_to_new_sprite_object
	jr nz, pcg_generate_room__start_continue7
	ld (hl), 0  ; id
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_SHOPKEEPER
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 7  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 11  ; tile y
pcg_generate_room__start_continue7:

	ld a, (global_state__story)
	cp STORY_STATE__FOUND_LOST_VENDOR
	jr c, pcg_generate_room__start_continue9

	; spawn the second vendor, and open his hut:
	call ptr_to_new_sprite_object
	jr nz, pcg_generate_room__start_continue8
	ld (hl), 0
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_SHOPKEEPER2
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 22  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 13  ; tile y
pcg_generate_room__start_continue8:

	; spawn the invisible tile objects:
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 0  ; id
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_NPC_SHOPKEEPER2  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 22  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 13  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, de

pcg_generate_room__start_continue9:
	; shopkeeper:
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 0  ; id
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_NPC_SHOPKEEPER  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 7  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 11  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, de

	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 0  ; id
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_NPC_SHOP  ; type
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 10  ; x
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 11  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, de
	ld (tmp_pcg_room__next_tile_object_ptr), iy	
	ret 

pcg_generate_room__start_remove_ropes_bottom_right:
	ld hl, current_room__tile_map + 22 + 22*32
	ld a, (hl)
	dec hl
	ld (hl), a
	xor a
	ld hl, current_room__tile_map + 21 + 23*32
	ld (hl), a
	ld hl, current_room__tile_map + 28 + 22*32
	ld a, (hl)
	dec hl
	ld (hl), a
	xor a
	ld hl, current_room__tile_map + 27 + 23*32
	ld (hl), a
	ret

pcg_generate_room__start_remove_ropes_bottom_left:
	ld hl, current_room__tile_map + 5 + 22*32
	ld a, (hl)
	dec hl
	ld (hl), a
	xor a
	ld hl, current_room__tile_map + 4 + 23*32
	ld (hl), a
	ld hl, current_room__tile_map + 11 + 22*32
	ld a, (hl)
	dec hl
	ld (hl), a
	xor a
	ld hl, current_room__tile_map + 10 + 23*32
	ld (hl), a
	ret

pcg_generate_room__start_destroy_stella:
	ld (hl), 0
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0
	ld bc, 32 - 5
	add hl, bc
	ld (hl), 0
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 0
	ld bc, 32 - 5
	add hl, bc
	ld (hl), 247
	inc hl
	ld (hl), 250
	inc hl
	ld (hl), 250
	inc hl
	ld (hl), 250
	inc hl
	ld (hl), 250
	inc hl
	ld (hl), 251
	ret


;-----------------------------------------------
pcg_generate_room__calendar:
	; name table:
	ld hl, calendar_room_zx0
	ld de, current_room__tile_map
	ld c, CHUNKS_PYRAMID_PAGE
	call dzx0_from_page_c

	; tile sets, collisions, and animation ptrs:
	ld bc, tiles_calendar_zx0
	ld (current_room__tileset_ptr), bc
	ld a, AREA_COLLISION_TABLES_PAGE
	ld (current_room__collision_ptr_page), a
	ld bc, tile_collision_types_calendar
	ld (current_room__collision_ptr), bc
	ld a, PYRAMID_TILES_PAGE
	ld (current_room__tileset_page), a
	ld a, 1
	ld (current_room__tileset_overrides_item_tiles), a
	ld hl, calendar_enemy_sprites_zx0
	ld (current_room__enemy_sprites_ptr), hl
	ld hl, update_animations_in_vdp_pyramid
	ld (current_room__animation_fn_ptr), hl

	call pcg_generate_room__calendar_open_walls

	; spawn the tablets:
	ld hl, pcg_generate_room__calendar_objects
	ld b, 9	
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld de, global_state__power_calendar - 2  ; -2, since we only have the state for the sockets (state of tablets does not matter)
	ld a, (global_state__story)
	cp STORY_STATE__DEFEATED_ALIENS
	jr c, pcg_generate_room__calendar_object_loop
	inc b  ; also spawn elaine tile object (so that she is interactable)
pcg_generate_room__calendar_object_loop:
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; id
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), a  ; type
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), a  ; x
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), a  ; y
	ld a, (de)
	inc de
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), a  ; state
	push de
		ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
		add iy, de
	pop de
	djnz pcg_generate_room__calendar_object_loop
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; spawn aliens:
	ld a, (global_state__story)
	cp STORY_STATE__DEFEATED_ALIENS
	jr c, pcg_generate_room__calendar_aliens
pcg_generate_room__calendar_elaine:
	; spawn elaine at 11, 15
	call ptr_to_new_sprite_object
	ld (hl), 0  ; id
	inc hl
	ld (hl), SPRITE_OBJECT_TYPE_ELAINE
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 11  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 15  ; tile y
	inc hl
	ld (hl), 0  ; state (idle)
	inc hl
	ld (hl), 0  ; state timer
	jr pcg_generate_room__calendar_aliens_done
pcg_generate_room__calendar_aliens:
	; - when 2 aliens: 9, 15; 21, 15
	; - when 3 aliens: add one at 15, 20
	; - when 4 aliens: the original two plus 5, 9; 25, 9	
	ld de, 9 + 15*256
	call pcg_generate_room__calendar_alien
	ld de, 21 + 15*256
	call pcg_generate_room__calendar_alien
	ld a, (global_state__n_alien_controntations)
	or a
	jr z, pcg_generate_room__calendar_aliens_done
	dec a
	jr z, pcg_generate_room__calendar_3_aliens
pcg_generate_room__calendar_4_aliens:
	ld de, 5 + 9*256
	call pcg_generate_room__calendar_alien
	ld de, 25 + 9*256
	call pcg_generate_room__calendar_alien
	jr pcg_generate_room__calendar_aliens_done
pcg_generate_room__calendar_3_aliens:
	ld de, 15 + 20*256
	call pcg_generate_room__calendar_alien
pcg_generate_room__calendar_aliens_done:

	; tablet gfx:
	ld hl, buffer_4096 + 60 * 64
	ld (item_object_to_upload_to_vdp), hl

	ld hl, calendar_stone_room_enter_event_fn
	ld (in_game_event_fn_ptr), hl
	ld a, CALENDAR_EVENTS_PAGE
	ld (in_game_event_fn_page), a
	ret

pcg_generate_room__calendar_objects:
	db 0, TAG_CALENDAR_TABLET, 5, 9
	db 0, TAG_CALENDAR_TABLET, 25, 9
	db 0, TAG_CALENDAR_SOCKET, 14, 15  ; has a spent stone
	db 1, TAG_CALENDAR_SOCKET, 16, 15
	db 2, TAG_CALENDAR_SOCKET, 13, 12
	db 3, TAG_CALENDAR_SOCKET, 17, 12
	db 4, TAG_CALENDAR_SOCKET, 14, 9
	db 5, TAG_CALENDAR_SOCKET, 16, 9
	db 0, TAG_CALENDAR_STONE_CENTER, 15, 12
	db 0, TAG_NPC_ELAINE, 11, 15


pcg_generate_room__calendar_alien:
	push de
		call ptr_to_new_sprite_enemy
	pop de
	ret nz
	; add enemy IDs, even if these are ignored for this room, they always respawn
	ld (hl), 0  ; ID
	inc hl
	ld (hl), ENEMY_ALIEN
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
	ld (hl), 4  ; health
	ret


;-----------------------------------------------
pcg_generate_room__calendar_turn_on_phase1:
	ld hl, CLRTBL2 + 72*8
	ld a, #48  ; blue + red
	ld b, 8
	call fast_small_FILVRM
	ld hl, CLRTBL2 + (256 + 72)*8
	ld a, #48  ; blue + red
	ld b, 8
	jp fast_small_FILVRM


;-----------------------------------------------
pcg_generate_room__calendar_open_walls:
	; open the appropriate walls:
	ld a, (current_room__y)
	add a, a  ; y in chunks
	ld b, a
	ld a, (current_area__width)
	add a, a  ; width in chunks
	ld c, a
	ld a, b
	or a
	ld a, 0
	jr z, pcg_generate_room__calendar_ptr_loop_end
pcg_generate_room__calendar_ptr_loop:
	add a, c
	djnz pcg_generate_room__calendar_ptr_loop
pcg_generate_room__calendar_ptr_loop_end:
	ld c, a
	ld a, (current_room__x)
	add a, a
	add a, c
	ld hl, current_area__chunks_ids
	ADD_HL_A
	ld a, (hl)  ; top-left chunk ID
	push hl
		ld b, PCG_DIRECTION_LEFT
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue1
		ld bc, #0400
		ld de, #0602
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue1:
	pop hl
	ld a, (hl)  ; top-left chunk ID
	push hl
		ld b, PCG_DIRECTION_UP
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue2
		ld bc, #0004
		ld de, #0208
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue2:
	pop hl
	inc hl
	ld a, (hl)  ; top-right chunk ID
	push hl
		ld b, PCG_DIRECTION_RIGHT
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue3
		ld bc, #041e
		ld de, #0602
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue3:
	pop hl
	ld a, (hl)  ; top-right chunk ID
	push hl
		ld b, PCG_DIRECTION_UP
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue4
		ld bc, #0014
		ld de, #0208
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue4:
	pop hl
	ld a, (current_area__width)
	add a, a  ; width in chunks
	dec a
	ld e, a
	ld d, 0
	add hl, de
	ld a, (hl)  ; bottom-left chunk ID
	push hl
		ld b, PCG_DIRECTION_LEFT
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue5
		ld bc, #1000
		ld de, #0602
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue5:
	pop hl
	ld a, (hl)  ; bottom-left chunk ID
	push hl
		ld b, PCG_DIRECTION_DOWN
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue6
		ld bc, #1604
		ld de, #0208
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue6:
	pop hl
	inc hl
	ld a, (hl)  ; bottom-right chunk ID
	push hl
		ld b, PCG_DIRECTION_DOWN
		call pcg_generate_room__chunk_direction_open
		jr z, pcg_generate_room__calendar_continue7
		ld bc, #1614
		ld de, #0208
		call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue7:
	pop hl
	ld a, (hl)  ; bottom-right chunk ID
	ld b, PCG_DIRECTION_RIGHT
	call pcg_generate_room__chunk_direction_open
	jr z, pcg_generate_room__calendar_continue8
	ld bc, #101e
	ld de, #0602
	call room_remove_breakable_wall_restore_background
pcg_generate_room__calendar_continue8:
	ret


;-----------------------------------------------
pcg_generate_room__teleporter:
	; name table:
	ld hl, teleporter_room_zx0
	ld de, current_room__tile_map
	ld c, TELEPORTER_ROOM_PAGE
	call dzx0_from_page_c

	; tile sets, collisions, and animation ptrs:
	ld bc, tiles_teleporter_zx0
	ld (current_room__tileset_ptr), bc
	ld a, AREA_COLLISION_TABLES_PAGE
	ld (current_room__collision_ptr_page), a
	ld bc, tile_collision_types_atlantis
	ld (current_room__collision_ptr), bc
	ld a, TILES_PAGE
	ld (current_room__tileset_page), a
	ld a, 1
	ld (current_room__tileset_overrides_item_tiles), a

	call pcg_generate_room__calendar_open_walls

	; spawn the tablet / teleporters:
	ld hl, pcg_generate_room__teleporter_objects
	ld b, 9
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
pcg_generate_room__teleporter_object_loop:
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; id
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), a  ; type
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), a  ; x
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), a  ; y
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0  ; state
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, de
	djnz pcg_generate_room__teleporter_object_loop
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; trial fns & teleporter gfx:
	ld hl, buffer_4096 + 190 * 16  ; teleporter activated by player
	ld a, (global_state__maya_riddle)
	cp 2
	jr z, pcg_generate_room__teleporter_trial_done
	ld hl, maya_puzzle_trial_fn
	ld (current_room__trial_fn), hl
	ld hl, buffer_4096 + 166 * 16  ; teleporter off
pcg_generate_room__teleporter_trial_done:
	ld (large_object_to_upload_to_vdp), hl
	ld a, 12*8
	ld (large_object_to_upload_to_vdp_size), a

	; tablet gfx:	
	ld hl, buffer_4096 + 60 * 64
	ld (item_object_to_upload_to_vdp), hl
	ret

pcg_generate_room__teleporter_objects:
	db 0, TAG_MAYA_PUZZLE_TABLET, 15, 9
	db 0, TAG_TELEPORTER_ATLANTIS, 12, 19
	db 1, TAG_TELEPORTER_ATLANTIS_TO_MOON, 16, 19


;-----------------------------------------------
pcg_generate_room__temple_of_poseidon:
	; name table:
	ld hl, temple_of_poseidon_room_zx0
	ld de, current_room__tile_map
	ld c, TEMPLE_OF_POSEIDON_PAGE
	call dzx0_from_page_c

	; tile sets, collisions, and animation ptrs:
	ld bc, tiles_atlantis_zx0
	ld (current_room__tileset_ptr), bc
	ld a, AREA_COLLISION_TABLES_PAGE
	ld (current_room__collision_ptr_page), a
	ld bc, tile_collision_types_atlantis
	ld (current_room__collision_ptr), bc
	ld a, ATLANTIS_TILES_PAGE
	ld (current_room__tileset_page), a
	ld a, 0
	ld (current_room__tileset_overrides_item_tiles), a

	call pcg_generate_room__calendar_open_walls

	; spawn the objects:
	ld hl, pcg_generate_room__poseidon_objects + 4  ; skip the boss door, if boss already defeated
	ld b, 6
	ld iy, (tmp_pcg_room__next_tile_object_ptr)
	ld a, (global_state__objects + TAG_BOSS5_CHESTLOCK)
	cp 2
	jr z, pcg_generate_room__temple_of_poseidon_object_loop
	ld hl, pcg_generate_room__poseidon_objects
pcg_generate_room__temple_of_poseidon_object_loop:
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), a  ; id
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), a  ; type
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_X), a  ; x
	ld a, (hl)
	inc hl
	ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), a  ; y
	xor a
	ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), a  ; state
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	add iy, de
	djnz pcg_generate_room__temple_of_poseidon_object_loop
	ld (tmp_pcg_room__next_tile_object_ptr), iy

	; set the corresponding face to mouth open:
	ld a, (current_world__atlantis_boss_statue)
	; coordinates = (9 + a * 4, 7)
	ld b, 7
	add a, a
	add a, a
	add a, 9
	ld c, a
	call get_room_tile_ptr
	inc (hl)
	inc (hl)
	inc hl
	inc (hl)
	inc (hl)
	ld bc, 31  ; poseidon room is width 32
	add hl, bc
	inc (hl)
	inc (hl)
	inc hl
	inc (hl)
	inc (hl)

	; tablet gfx:	
	ld hl, buffer_4096 + 60 * 64
	ld (item_object_to_upload_to_vdp), hl
	ld e, TAG_DOOR_BOSS
	call set_large_object_to_upload_to_vdp

	; check if the lock has already been open
	ld a, (global_state__objects + TAG_BOSS5_CHESTLOCK)
	or a
	ret z  ; door was already open

	; change door image to open:
	ld hl, buffer_4096 + (202 + 32) * 16  ; boss door frame 2
	ld (large_object_to_upload_to_vdp), hl
	ret


pcg_generate_room__poseidon_objects:
	db TAG_BOSS5_CHESTLOCK, TAG_DOOR_BOSS, 14, 12
	db 0, TAG_ATLANTIS_TABLET1, 2, 20
	db 0, TAG_BOSS5_CHESTLOCK, 6, 11
	db 1, TAG_BOSS5_CHESTLOCK, 11, 11
	db 2, TAG_BOSS5_CHESTLOCK, 19, 11
	db 3, TAG_BOSS5_CHESTLOCK, 24, 11


;-----------------------------------------------
pcg_generate_room__8_bridge_room:
	; name table:
	ld hl, eight_bridge_room_zx0
	ld de, current_room__tile_map
	ld c, EIGHT_BRIDGE_ROOM_PAGE
	call dzx0_from_page_c

	; tile sets, collisions, and animation ptrs:
	ld bc, tiles_caves_zx0
	ld (current_room__tileset_ptr), bc
	ld a, AREA_COLLISION_TABLES_PAGE
	ld (current_room__collision_ptr_page), a
	ld bc, tile_collision_types_caves
	ld (current_room__collision_ptr), bc
	ld a, CAVES_TILES_PAGE
	ld (current_room__tileset_page), a
	ld a, 0
	ld (current_room__tileset_overrides_item_tiles), a

	call pcg_generate_room__calendar_open_walls

	; stela:
	; ...

	; open bridge:
	; ...

	ret


;-----------------------------------------------
pcg_generate_room__calendar_turn_on_phase2_tile_ids:
	db 80, 81, 83, 85, 89, 92, 93, 94, 146, 153, 171, 172, 175
pcg_generate_room__calendar_turn_on_phase2_tile_ids_end:

pcg_generate_room__calendar_turn_on_phase2_partial_tile_clr:
	db COLOR_DARK_BLUE*16 + COLOR_RED, COLOR_DARK_BLUE*16 + COLOR_RED
	db COLOR_DARK_BLUE*16, COLOR_DARK_BLUE*16
	db COLOR_DARK_BLUE*16 + COLOR_RED, COLOR_DARK_BLUE*16 + COLOR_RED
	db COLOR_DARK_BLUE*16, COLOR_DARK_BLUE*16


pcg_generate_room__calendar_turn_on_phase2:
	ld hl, pcg_generate_room__calendar_turn_on_phase2_tile_ids
	ld b, pcg_generate_room__calendar_turn_on_phase2_tile_ids_end - pcg_generate_room__calendar_turn_on_phase2_tile_ids
pcg_generate_room__calendar_turn_on_phase2_loop:
	ld a, (hl)
	inc hl
	push bc
	push hl
		; bank 1:
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		add hl, hl
		ld de, CLRTBL2 + 256*8
		add hl, de
		ld a, COLOR_DARK_BLUE*16 + COLOR_RED
		ld b, 8
		push hl
			call fast_small_FILVRM
		pop hl
		; bank 2:
		ld de, 256*8
		add hl, de
		ld a, COLOR_DARK_BLUE*16 + COLOR_RED
		ld b, 8
		call fast_small_FILVRM
	pop hl
	pop bc
	djnz pcg_generate_room__calendar_turn_on_phase2_loop

	; tiles that have to be half-changed: 82, 84 (only appear in the middle bank):
	ld hl, pcg_generate_room__calendar_turn_on_phase2_partial_tile_clr
	ld de, CLRTBL2 + (256 + 82)*8
	ld b, 8
	call fast_small_LDIRVM
	ld hl, pcg_generate_room__calendar_turn_on_phase2_partial_tile_clr
	ld de, CLRTBL2 + (256 + 84)*8
	ld b, 8
	jp fast_small_LDIRVM


;-----------------------------------------------
; input:
; - a: chunk ID
; - b: direction to check
; output:
; - z: closed
; - nz: open
pcg_generate_room__chunk_direction_open:
	ld h, 0
	ld l, a
	add hl, hl
	add hl, hl
	ld d, 0
	ld e, a
	add hl, de
	ld de, (current_area__chunk_flags_ptr)
	add hl, de
	ld a, (hl)  ; top-left chunk type
	and b
	ret


;-----------------------------------------------
; This door has to be open with this special function, since the event that 
; opens it is in a different room than the door itself, and hence the 
; 'room_mark_open_door' cannot be called at that point. So, we delay it until
; we load the door where the TAG_MIDPOINT tag is.
pcg_generate_room__open_midpoint_door:
	ld a, (global_state__objects + TAG_MIDPOINT)
	or a
	ret nz  ; already open
	ld a, (global_state__n_power_stones_in_calendar)
	cp 3
	ret c  ; not at the point of opening it yet
	ld e, TAG_DOOR_HORIZONTAL
	ld c, TILES_PAGE
	ld hl, find_tile_object_ptr
	call call_hl_in_page_c_8000
	ld a, 1
	ld (global_state__objects + TAG_MIDPOINT), a  ; mark the door as already open
	push hl
	pop ix
	call room_mark_open_door
	ld c, TILES_PAGE
	ld hl, delete_tile_object_in_ix
	jp call_hl_in_page_c_8000


;-----------------------------------------------
; input:
; - ix: ptr to the door object
room_mark_open_door:
	; Create an entry in "global_state__open_walls":
	ld hl, global_state__open_walls
room_mark_open_door_loop:
	ld a, (hl)
	or a
	jr z, room_mark_open_door_loop_end
	ld bc, 6
	add hl, bc
	jr room_mark_open_door_loop
room_mark_open_door_loop_end:
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
	ld (hl), a  ; chunk where this door is
	inc hl
	; get within-chunk coordinates:
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	and #0f
	ld c, a  ; c = x % CHUNK_WIDTH
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
room_mark_open_door_chunk_y_loop:
	cp CHUNK_HEIGHT
	jr c, room_mark_open_door__continue
	sub CHUNK_HEIGHT
	jr room_mark_open_door_chunk_y_loop
room_mark_open_door__continue:
	ld b, a  ; b = y % CHUNK_HEIGHT
	ld (hl), c
	inc hl
	ld (hl), b
	inc hl

	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_DOOR_VERTICAL
	jr z, room_mark_open_door__vertical
	ld e, 4
	ld d, 1
	jr room_mark_open_door__dimensions_set
room_mark_open_door__vertical:
	ld e, 1
	ld d, 3
room_mark_open_door__dimensions_set:
	ld (hl), e
	inc hl
	ld (hl), d
	ret


;-----------------------------------------------
; this method checks for any events that should happen upon entering a room:
default_in_game_event_fn:
	ld a, (global_state__story)
	cp STORY_STATE__START
	jr z, default_in_game_event_fn_start
	; ...
	ret

default_in_game_event_fn_start:
	ld a, (current_area__id)
	or a
	ret z
	; entered the ruins:
	ld de, TEXT_STORY_ENTER_RUINS
	ld hl, display_in_game_message
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000
	ld a, STORY_STATE__ENTERED_RUINS
	ld (global_state__story), a
	ret
