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

	; clear all the tile objects:
	ld hl, current_room__tile_map + 32*24*2
	ld de, current_room__tile_map
	ld bc, 32*24*2
	ldir
	ld hl, current_room__tile_objects
	ld bc, MAX_ROOM_TILE_OBJECTS * ROOM_TILE_OBJECT_STRUCT_SIZE - 1
	ld a, #ff
	call clear_memory_a

	ld b, 25
	call wait_b_halts

	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at

	ld hl, SFX_explosion_low_pitch
	call play_SFX_with_high_priority

	; ...

	ret

boss4_awake_xibalba_lord_event_first:
	ld (boss__4_first_lord), a

	ld b, 25
	call wait_b_halts

	; block stairs:
	ld a, 6*16 + 6  ; wall
	ld (current_room__tile_map + 22*64 + 31), a
	ld (current_room__tile_map + 22*64 + 31 + 64*24), a
	inc a
	ld (current_room__tile_map + 22*64 + 32), a
	ld (current_room__tile_map + 22*64 + 32 + 64*24), a

	ld hl, SFX_explosion_low_pitch
	jp play_SFX_with_high_priority


boss4_awake_xibalba_lord_event_lower_tomb:
	; - ix: ptr to object
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
	ld b, 25
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
	ld b, 25
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
