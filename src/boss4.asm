;-----------------------------------------------
update_boss4_behavior:
	; check if we need to draw an overlay of the "damage face" when the boss is hit:
	ld hl, boss__hit_timer
	ld a, (hl)
	or a
	jr z, update_boss4_behavior_continue
	dec (hl)
update_boss4_behavior_continue:
	ld a, (boss__active)
	or a
	ret z

	; check if it is dead:
	ld hl, (boss__hp)
	ld a, h
	or l
	jr nz, update_boss4_behavior_continue2
	; boss is dead!
	ld a, 2
	ld (boss__behavior), a
update_boss4_behavior_continue2:
	ld a, (boss__behavior)
	or a
	jp z, update_boss4_behavior_0  ; boss has not yet appeared, waiting for player to wake two ghosts
	dec a
	jp z, update_boss4_behavior_1  ; boss is active
; 	dec a
	jp update_boss4_behavior_2  ; death


;-----------------------------------------------
update_boss4_behavior_0:
	ld a, (boss__4_second_lord)
	or a
	ret z

	; two lords awakened, boss appears!

	; ghosts go down:
	ld ix, current_room__sprite_objects
	ld a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	inc a
	cp 8
	jr nz, update_boss4_behavior_0_continue
	xor a
	inc b
update_boss4_behavior_0_continue:
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), a
	ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), b
	ld ix, current_room__sprite_objects + ROOM_OBJECT_STRUCT_SIZE
	ld (ix + ROOM_OBJECT_STRUCT_PIXEL_Y), a
	ld (ix + ROOM_OBJECT_STRUCT_TILE_Y), b
	ld a, b
	cp 24
	ret nz
	; remove the ghosts:
	ld a, #ff
	ld (current_room__sprite_objects), a
	ld (current_room__sprite_objects + ROOM_OBJECT_STRUCT_SIZE), a

	; Bring boss name (using sprites)
	ld hl, boss4_name_initial_sprite_attributes
	ld de, boss4_name_y_table
	call update_boss_behavior_bring_name_down
	ld b, 100
	call wait_b_halts_skippable
	; Remove boss name (using sprites)
	ld hl, boss4_name_initial_sprite_attributes
	ld de, boss4_name_y_table + 23
	call update_boss_behavior_bring_name_up

	; boss starts attacking!
	ld a, 1
	ld (boss__behavior), a
	ret


;-----------------------------------------------
update_boss4_behavior_1:
	; ...
	ret


;-----------------------------------------------
update_boss4_behavior_2:
	; ...
	ret


;-----------------------------------------------
boss4_awake_xibalba_lord_event:
	ld hl, SFX_secret
	call play_SFX_with_high_priority
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	sub 4
	ld b, a
	call spawn_xibalba_lord_ghost	

	push ix
		call update_sprite_objects
		ld hl, upload_sprites_to_vdp
		ld c, SPRITES_PAGE
		call call_hl_in_page_c_8000
	pop ix

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	; tomb disappears:
	ld b, 25
	call wait_b_halts
	call boss4_awake_xibalba_lord_event_lower_tomb

	ld a, (boss__4_first_lord)
	or a
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	jr z, boss4_awake_xibalba_lord_event_first
boss4_awake_xibalba_lord_event_second:
	ld (boss__4_second_lord), a
	; two ghosts spawned, awaking boss:
	ld hl, 0
	ld (current_room__trial_fn), hl

	; lower all the tombs:
boss4_awake_xibalba_lord_event_second_loop:
	ld ix, current_room__tile_objects
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)
	cp TAG_XIBALBA_BOSS_GRAVE
	jr nz, boss4_awake_xibalba_lord_event_second_loop_done
	call boss4_awake_xibalba_lord_event_lower_tomb_quick
	jr boss4_awake_xibalba_lord_event_second_loop
boss4_awake_xibalba_lord_event_second_loop_done:

	; ...

	ret

boss4_awake_xibalba_lord_event_first:
	ld (boss__4_first_lord), a

	ld b, 25
	call wait_b_halts

	; block stairs:
	ld a, 6*16 + 6  ; wall
	ld (current_room__tile_map + 23*64 + 31), a
	ld (current_room__tile_map + 23*64 + 31 + 64*24), a
	inc a
	ld (current_room__tile_map + 23*64 + 32), a
	ld (current_room__tile_map + 23*64 + 32 + 64*24), a

	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at

	ld hl, SFX_explosion_low_pitch
	jp play_SFX_with_high_priority


boss4_awake_xibalba_lord_event_lower_tomb_quick:
	ld b, 5
	jr boss4_awake_xibalba_lord_event_lower_tomb_continue
boss4_awake_xibalba_lord_event_lower_tomb:
	ld b, 25
boss4_awake_xibalba_lord_event_lower_tomb_continue:
	; - ix: ptr to object
	push bc
		; lower first step:
		ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
		ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
		inc b
		inc b
		call get_room_tile_ptr
		ld d, h
		ld e, l
		ld bc, -64
		add hl, bc
		ldi
		ldi
		ld bc, -66
		add hl, bc
		ex de, hl
			add hl, bc
		ex de, hl
		ldi
		ldi
		ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
		ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
		call get_room_tile_ptr
		ld d, h
		ld e, l
		ld bc, 64*24
		add hl, bc
		ldi
		ldi
		push ix
			ld hl, draw_room_with_hud
			ld c, TILES_PAGE
			call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
		pop ix
		ld hl, SFX_explosion_low_pitch
		call play_SFX_with_high_priority
	pop bc
	push bc
		call wait_b_halts

		; lower second step:
		ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
		ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
		inc b
		inc b
		call get_room_tile_ptr
		ld d, h
		ld e, l
		ld bc, -64
		add hl, bc
		ldi
		ldi
		ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
		ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
		inc b
		call get_room_tile_ptr
		ld d, h
		ld e, l
		ld bc, 64*24
		add hl, bc
		ldi
		ldi
		push ix
			ld hl, draw_room_with_hud
			ld c, TILES_PAGE
			call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
		pop ix	
		ld hl, SFX_explosion_low_pitch
		call play_SFX_with_high_priority	
	pop bc
	call wait_b_halts

	; lower third step:
	ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
	ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	inc b
	inc b
	call get_room_tile_ptr
	ld d, h
	ld e, l
	ld bc, 64*24
	add hl, bc
	ldi
	ldi
	push ix
		ld hl, draw_room_with_hud
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
	pop ix	
	ld hl, SFX_explosion_low_pitch
	call play_SFX_with_high_priority	

	ld hl, delete_tile_object_in_ix
	ld c, TILES_PAGE
	jp call_hl_in_page_c_8000
