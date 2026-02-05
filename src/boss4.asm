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

	ld a, (boss__4_first_lord)
	or a
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_ID)
	jr z, boss4_awake_xibalba_lord_event_first
boss4_awake_xibalba_lord_event_second:
	ld (boss__4_second_lord), a
	; two ghosts spawned, awaking boss:
	ld hl, 0
	ld (current_room__trial_fn), hl

	; ...

	ret

boss4_awake_xibalba_lord_event_first:
	ld (boss__4_first_lord), a

	; tomb disappears:
	; ...
	ld b, 25
	call wait_b_halts

	; block stairs:
	ld a, 6*16 + 6  ; wall
	ld (current_room__tile_map + 22*64 + 31), a
	ld (current_room__tile_map + 22*64 + 31 + 64*24), a
	inc a
	ld (current_room__tile_map + 22*64 + 32), a
	ld (current_room__tile_map + 22*64 + 32 + 64*24), a

	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	ld hl, SFX_explosion_low_pitch
	jp play_SFX_with_high_priority
