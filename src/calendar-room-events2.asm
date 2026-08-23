;-----------------------------------------------
; Elaine shows up and ends the battle
calendar_stone_center_battle_event_fn2__explosion_tile_locations:
	db 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59  ; explosion
	db 60, 61, 62  ; rope

elaine_explosion_frame1_gfx:
  db 3, 3
  dw buffer_4096 + 4  ; elaine_explosion_frame1_gfx_tiles
 elaine_explosion_frame1_gfx_tiles:
  db 48, 49, 50
  db 51, 52, 53
  db 54, 55, 56

elaine_explosion_frame2_gfx:
  db 3, 3
  dw buffer_4096 + 4  ; elaine_explosion_frame2_gfx_tiles
 elaine_explosion_frame2_gfx_tiles:
  db 0, 0, 0
  db 57, 58, 59
  db 0, 0, 0

elaine_explosion_frame3_gfx:
  db 3, 3
  dw buffer_4096 + 4  ; elaine_explosion_frame3_gfx_tiles
 elaine_explosion_frame3_gfx_tiles:
  db 0, 0, 0
  db 0, 0, 0
  db 0, 0, 0


calendar_stone_center_battle_event_fn2:
	; Replace UFO tiles by explosion/rope tiles
	ld hl, calendar_explosion_tiles_zx0
	ld de, buffer_4096
	ld c, TILES_CALENDAR_EXPLOSION_PAGE
	call dzx0_from_page_c

	; tiles go to: 
	ld hl, buffer_4096  ; ptr to patterns
	ld ix, calendar_stone_center_battle_event_fn2__explosion_tile_locations
	ld b, 15
calendar_stone_center_battle_event_fn2__patch_explosion_tiles_loop:
	push bc
		push hl
			ld a, (ix)
			call calendar_stone_center_battle_event_fn2__patch_explosion_tile
		pop hl
		ld bc, 8
		add hl, bc
		inc ix
	pop bc
	djnz calendar_stone_center_battle_event_fn2__patch_explosion_tiles_loop

	; Explosions:
	; copy the gfx data to buffer_4096 so that the tiles page can see it:
	ld b, 8
calendar_stone_center_battle_event_fn2__explosions_loop:
	push bc
		ld c, 3
		call random_modulo
		ld c, 4
		or a
		jr z, calendar_stone_center_battle_event_fn2__explosions_loop_continue
		ld c, 14
		dec a
		jr z, calendar_stone_center_battle_event_fn2__explosions_loop_continue
		ld c, 24
calendar_stone_center_battle_event_fn2__explosions_loop_continue:
		call random_a
		and #01
		add a, c
		ld iyl, a  ; explosion x coordinate
		call random_a
		and #01
		ld iyh, a  ; explosion y coordinate

		; draw explosion frame 1:
		ld hl, elaine_explosion_frame1_gfx
		ld de, buffer_4096
		ld bc, 13
		ldir

		ld de, buffer_4096 - 1  ; elaine_explosion_frame1_gfx - 1
		ld c, TILES_PAGE
		push iy
			ld hl, room_render_tile_objects_render_de
			call call_hl_in_page_c_8000
			ld hl, draw_room_with_hud
			ld c, TILES_PAGE
			call call_hl_in_page_c_8000
		pop iy

		; sfx + pause:
		ld hl, SFX_explosion
		call play_SFX_with_high_priority
		ld b, 10
		call wait_b_halts

		; draw explosion frame 2:
		ld hl, elaine_explosion_frame2_gfx
		ld de, buffer_4096
		ld bc, 13
		ldir

		ld de, buffer_4096 - 1  ; elaine_explosion_frame2_gfx - 1
		ld c, TILES_PAGE
		push iy
			ld hl, room_render_tile_objects_render_de
			call call_hl_in_page_c_8000
			ld hl, draw_room_with_hud
			ld c, TILES_PAGE
			call call_hl_in_page_c_8000
		pop iy

		; pause:
		ld b, 15
		call wait_b_halts

		; clear explosion:
		ld hl, elaine_explosion_frame3_gfx
		ld de, buffer_4096
		ld bc, 13
		ldir

		ld de, buffer_4096 - 1  ; elaine_explosion_frame3_gfx - 1
		ld c, TILES_PAGE
		ld hl, room_render_tile_objects_render_de
		call call_hl_in_page_c_8000
		ld hl, draw_room_with_hud
		ld c, TILES_PAGE
		call call_hl_in_page_c_8000
	pop bc
	dec b
	jp nz, calendar_stone_center_battle_event_fn2__explosions_loop

	ld b, 50
	call wait_b_halts

	; drop rope:
	ld hl, current_room__tile_map + 6
	ld bc, 32
	ld (hl), 60
	add hl, bc
	ld (hl), 60
	add hl, bc
	ld (hl), 61
	add hl, bc
	ld (hl), 60
	add hl, bc
	ld (hl), 60
	add hl, bc
	ld (hl), 62
	add hl, bc
	ld hl, draw_room_with_hud
	ld c, TILES_PAGE
	call call_hl_in_page_c_8000
	ld hl, SFX_enemy_bullet
	call play_SFX_with_high_priority

	; Elaine goes down the rope:
	; spawn Elaine:
	call ptr_to_new_sprite_object
	push hl
		ld (hl), 0  ; id
		inc hl
		ld (hl), SPRITE_OBJECT_TYPE_ELAINE
		inc hl
		ld (hl), 0
		inc hl
		ld (hl), 5  ; tile x
		inc hl
		ld (hl), 0
		inc hl
		ld (hl), -1  ; tile y
		inc hl
		ld (hl), 1  ; state (rope)
		inc hl
		ld (hl), 0  ; state timer
	pop ix

	ld b, 32
calendar_stone_center_battle_event_fn2__elaine_rope_loop:
	push bc
		; Elaine goes down the rope
		push ix
			call update_sprite_objects
			ld hl, upload_sprites_to_vdp
			ld c, SPRITES_PAGE
			call call_hl_in_page_c_8000
		pop ix

		ld bc, #0100
		ld hl, update_enemy_move_cb
		ld e, ENEMIES_PAGE
		call call_hl_in_page_e_8000
	pop bc
	ld a, b
	and #03
	jr nz, calendar_stone_center_battle_event_fn2__elaine_rope_loop_continue
	; alternate between states 2 and 1:
	ld a, 3
	sub (ix + ROOM_OBJECT_STRUCT_STATE)
	ld (ix + ROOM_OBJECT_STRUCT_STATE), a
calendar_stone_center_battle_event_fn2__elaine_rope_loop_continue:
	halt
	halt
	djnz calendar_stone_center_battle_event_fn2__elaine_rope_loop
	ld b, 100
	call wait_b_halts_skippable

	; Restore the room to its original state
	call disable_VDP_output

	ld e, CALENDAR_ROOM_ID
	ld hl, pcg_generate_room
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000
	ld hl, #1300
	ld (player_x), hl
	ld hl, #0f00
	ld (player_y), hl
	xor a
	ld (player_state_timer), a
	inc a
	ld (player_state), a

	; set event for when room is loaded:
	ld hl, calendar_stone_center_battle_event_fn3_a
	ld (in_game_event_fn_ptr), hl
	ld a, CALENDAR_EVENTS_PAGE2
	ld (in_game_event_fn_page), a

	jp state_play_from_loaded_room


;-----------------------------------------------
calendar_stone_center_battle_event_fn3_a:
	; we have this "fn3_a/b" so that at least one whole cycle is executed before 
	; 'calendar_stone_center_battle_event_fn3', and the sprites are rendered to see Elaine.
	ld hl, calendar_stone_center_battle_event_fn3_b
	ld (in_game_event_fn_ptr), hl
	ret

calendar_stone_center_battle_event_fn3_b:
	ld hl, calendar_stone_center_battle_event_fn3
	ld (in_game_event_fn_ptr), hl
	ret

calendar_stone_center_battle_event_fn3_tbl:
	dw TEXT_AMBUSH_ELAINE_1
	dw TEXT_AMBUSH_ELAINE_2
	dw TEXT_AMBUSH_ELAINE_3
	dw TEXT_AMBUSH_ELAINE_4
	dw TEXT_AMBUSH_ELAINE_4B
	dw TEXT_AMBUSH_ELAINE_5
	dw TEXT_AMBUSH_ELAINE_6
	dw TEXT_AMBUSH_ELAINE_7
	dw TEXT_AMBUSH_ELAINE_8
	dw TEXT_AMBUSH_ELAINE_3
	dw TEXT_AMBUSH_ELAINE_10
	dw TEXT_ELAINE_CALENDAR_5

calendar_stone_center_battle_event_fn3:
	ld b, 12
	ld hl, calendar_stone_center_battle_event_fn3_tbl
calendar_stone_center_battle_event_fn3_loop:
	push bc
	push hl
		ld e, (hl)
		inc hl
		ld d, (hl)
		ld hl, display_in_game_message_textpage3
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
; 		ld b, 25
; 		call wait_b_halts_skippable
	pop hl
	pop bc
	inc hl
	inc hl
	djnz calendar_stone_center_battle_event_fn3_loop
	ret


;-----------------------------------------------
; input:
; - a: destination tile
; - hl: ptr to patterns (8 bytes), attributes are 15*8 bytes away
calendar_stone_center_battle_event_fn2__patch_explosion_tile:
	; de = CHRTBL2 + a * 8
	push hl
		ld l, a
		ld h, 0
		add hl, hl
		add hl, hl
		add hl, hl
		ld de, CHRTBL2
		add hl, de
		ex de, hl
	pop hl
	; bank 1:
	call calendar_stone_center_battle_event_fn2__patch_explosion_tile_one_bank
	; bank 2:
	ex de, hl
		ld bc, 256*8
		add hl, bc
	ex de, hl
	call calendar_stone_center_battle_event_fn2__patch_explosion_tile_one_bank
	; bank 3:
	ex de, hl
		ld bc, 256*8
		add hl, bc
	ex de, hl
calendar_stone_center_battle_event_fn2__patch_explosion_tile_one_bank:
	push hl
	push de
		push hl
			push de
				; patterns:
				ld bc, 8
				call fast_LDIRVM
			pop hl
			ld bc, CLRTBL2 - CHRTBL2
			add hl, bc
			ex de, hl
		pop hl
		ld bc, 15*8
		add hl, bc
		; attributes
		ld bc, 8
		call fast_LDIRVM
	pop de
	pop hl
	ret
