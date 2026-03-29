;-----------------------------------------------
; Elaine shows up and ends the battle
calendar_stone_center_battle_event_fn2__explosion_tile_locations:
	db 192, 193, 194, 208, 209, 210, 224, 225, 226, 240, 241, 242  ; explosion
	db 100, 128, 168  ; rope

elaine_explosion_frame1_gfx:
  db 3, 3
  dw buffer_4096 + 4  ; elaine_explosion_frame1_gfx_tiles
 elaine_explosion_frame1_gfx_tiles:
  db 192, 193, 194
  db 208, 209, 210
  db 224, 225, 226

elaine_explosion_frame2_gfx:
  db 3, 3
  dw buffer_4096 + 4  ; elaine_explosion_frame2_gfx_tiles
 elaine_explosion_frame2_gfx_tiles:
  db 0, 0, 0
  db 240, 241, 242
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
		dec a
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

	; drop rope:
	; ...

	; Elaine goes down the rope:
	; ...

	; Fade to black
	; ...

	; Restore the openings and the ceiling to the room:
	; ...

	; move the player and Elaine to the center:
	; ...

	; Dialogue:
	; ...

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
