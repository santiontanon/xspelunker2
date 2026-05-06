;-----------------------------------------------
draw_room_only_hud
	call draw_room_compute_ptrs
	ld b, 2
	jr draw_room_with_hud_entry_point


;-----------------------------------------------
; When the hud is not "full" (it only has small parts), we draw it on top of the room itself,
; and then transfer those tiles to the VDP to make things faster.
draw_room_with_hud:
	call draw_room_compute_ptrs

	ld b, 24
draw_room_with_hud_entry_point:
	push bc
		; hl = ptr from where to draw
		; de = room width - 32
		; copy the room content underneath the hud:
		ld (tmp_hud_drawing_hl), hl
		ld (tmp_hud_drawing_de), de
		ld b, d
		ld c, e
		ld de, hud_draw_buffer
		push bc
			ld bc, 32
			ldir
		pop bc
		add hl, bc
		ld bc, 32
		ldir

		; Draw the hud:
		ld a, (config_hud_type)
		cp 2
		jr nz, draw_room_with_hud_minimal
		call draw_hud_full

		ld hl, NAMTBL2 + 32*2  ; when the hud is full, we draw the room 2 rows lower
		call SETWRT
	pop bc
	dec b  ; with full hud, we draw 2 less rows of map
	dec b
	ret z  ; if we are only drawing the hud, we are done
	push bc
		jr draw_room_with_hud_drawn
draw_room_with_hud_minimal:
		call draw_hud_minimal

		ld hl, NAMTBL2
		call SETWRT
draw_room_with_hud_drawn:

		ld hl, (tmp_hud_drawing_hl)
		ld de, (tmp_hud_drawing_de)
	pop bc  ; number of rows to draw
	; Draw the room:
    ld a, (VDP.DW)
    ld c, a
draw_room_with_hud_row_loop:
	push bc
		ld b, 32
draw_room_with_hud_column_loop:
		outi
		jp nz, draw_room_with_hud_column_loop
		add hl, de
	pop bc
	djnz draw_room_with_hud_row_loop

	; Restore the content below the hud:
	ld bc, (tmp_hud_drawing_de)
	ld de, (tmp_hud_drawing_hl)
	ld hl, hud_draw_buffer
	push bc
		ld bc, 32
		ldir
	pop bc
	ex de, hl
		add hl, bc
	ex de, hl
	ld bc, 32
	ldir

	xor a
	ld a, (redraw_flags)
	and AFTER_ROOOMREDRAW_CLEAR_MASK
	ld (redraw_flags), a
	ret


;-----------------------------------------------
draw_room:
	ld hl, NAMTBL2
	call SETWRT

	call draw_room_compute_ptrs

	; hl = ptr from where to draw
	; de = room width - 32
    ld a, (VDP.DW)
    ld c, a
    ld b, 24
draw_room_row_loop:
	push bc
		ld b, 32
draw_room_column_loop:
		outi
		jp nz, draw_room_column_loop
		add hl, de
	pop bc
	djnz draw_room_row_loop

	xor a
	ld (redraw_flags), a	
	ret


;-----------------------------------------------
; output:
; - hl = ptr from where to draw
; - de = room width - 32
draw_room_compute_ptrs:
	; start drawing from: current_room__tile_map + (room_scroll_x) + (room_scroll_y) * width
	; if the width is not 32 or 64, we know that room_scroll_y == 0 anyway
	ld bc, (room_scroll_x)  ; c = x offset, b = y offset
	ld a, (current_room__width)
	ld h, 0
	ld l, a
	ld de, -32
	add hl, de
	ex de, hl  ; de = offset we need to add to copy the next row
	cp 64
	jr z, draw_room_width64
	cp 96
	jr z, draw_room_width96
	cp 128
	jr z, draw_room_width128
draw_room_width32:
	; in this case, we know room_scroll_x == 0
	ld a, (room_scroll_y)
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 32
	jp draw_room_continue
draw_room_width96:
	ld bc, (room_scroll_x)  ; b: room_scroll_y, c: room_scroll_x
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	push de
		ld e, l
		ld d, h
		add hl, hl
		add hl, de  ; hl = y * 96
	pop de
	ld b, 0
	add hl, bc  ; add room_scroll_x
	jp draw_room_continue
draw_room_width64:
	ld bc, (room_scroll_x)
	ld l, b
	ld h, 0
	jp draw_room_width64_entrypoint
draw_room_width128:
	ld bc, (room_scroll_x)  ; b: room_scroll_y, c: room_scroll_x
	ld l, b
	ld h, 0
	add hl, hl
draw_room_width64_entrypoint:
	add hl, hl
draw_room_width32_entrypoint:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 128
	ld b, 0
	add hl, bc
draw_room_continue:
	ld bc, current_room__tile_map
	add hl, bc
	ret


;-----------------------------------------------
; input:
; - c: tile x
; - b: tile y
; output:
; - hl: ptr to the tile
get_room_tile_ptr:
	; sign extend b to hl:
	ld l, b
	ld a, b
    rlca
    sbc a
    ld  h, a	
get_room_tile_ptr_hl_set:
	ld a, (current_room__width)
	cp 32*2
	jr z, get_room_tile_ptr_width64
	cp 32*3
	jr z, get_room_tile_ptr_width96
	cp 32*4
	jr z, get_room_tile_ptr_width128
get_room_tile_ptr_width32:
	jp get_room_tile_ptr_width32_entry_point
get_room_tile_ptr_width96:
	ld a, c  ; preserve c
	ld c, l
	ld b, h
	add hl, hl
	add hl, bc  ; hl = y * 3
	ld c, a
	jp get_room_tile_ptr_width96_entry_point
get_room_tile_ptr_width128:
	add hl, hl
get_room_tile_ptr_width64:
	add hl, hl
get_room_tile_ptr_width32_entry_point:
get_room_tile_ptr_width96_entry_point:
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 128
get_room_tile_ptr_continue:
	; sign extend b to bc:
	ld a, c
    rlca
    sbc a
    ld  b, a
	add hl, bc
	ld bc, current_room__tile_map
	add hl, bc
	ret


;-----------------------------------------------
; Should return the last object that matches (since that's the one that is rendered on top).
; output:
; - z: no object behind
; - nz: object behind
; - ix: ptr to object if one found
get_tile_object_behind_player:
	ld hl, 0
	ld (tmp_get_tile_object_behind_player_ptr), hl
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	ld ix, current_room__tile_objects
get_tile_object_behind_player_loop:
	ld a, (ix)  ; ID
	cp #ff
	jp z, get_tile_object_behind_player_done
	cp #fe  ; sentinel in tile objects is #fe
	jp z, get_tile_object_behind_player_done
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_TYPE)  ; type
	cp TAG_GEAR_LOCK
	jp z, get_tile_object_behind_player_32x24_object
	cp TAG_IDOL_LOCK
	jp z, get_tile_object_behind_player_32x24_object
	cp TAG_TRIAL1_LOCK
	jp z, get_tile_object_behind_player_32x32_object
	cp TAG_TRIAL2_LOCK
	jp z, get_tile_object_behind_player_32x32_object
	cp TAG_TRIAL3_LOCK
	jp z, get_tile_object_behind_player_32x32_object
	cp TAG_TRIAL4_LOCK
	jp z, get_tile_object_behind_player_32x32_object
	cp TAG_DOOR_BOSS
	jp z, get_tile_object_behind_player_32x32_object
	cp TAG_TELEPORTER1
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER2
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER3
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER4
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER5
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER6
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER7
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER8
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER9
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER_ATLANTIS
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER_ATLANTIS_TO_MOON
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER_MARS
	jr z, get_tile_object_behind_player_32x24_object
	cp TAG_TELEPORTER_MOON
	jr z, get_tile_object_behind_player_32x24_object

	; 16x16 objects:
	ld a, b
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jr z, get_tile_object_behind_player_check_x
	dec a
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jr z, get_tile_object_behind_player_check_x
	inc a
	inc a
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jr nz, get_tile_object_behind_player_loop_next
get_tile_object_behind_player_check_x:
	ld a, c
    cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
    jr z, get_tile_object_behind_player_found
    dec a
    cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr z, get_tile_object_behind_player_found
get_tile_object_behind_player_loop_next:
	ld de, ROOM_TILE_OBJECT_STRUCT_SIZE
	add ix, de
	jp get_tile_object_behind_player_loop
get_tile_object_behind_player_found:
	ld (tmp_get_tile_object_behind_player_ptr), ix
	jr get_tile_object_behind_player_loop_next

get_tile_object_behind_player_done:
	ld ix, (tmp_get_tile_object_behind_player_ptr)
	ld a, ixl
	or ixh
	ret

get_tile_object_behind_player_32x24_object:
	ld a, b
	dec a
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jr nz, get_tile_object_behind_player_loop_next
get_tile_object_behind_player_32x24_object_x:
	ld a, c
    cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
    jr z, get_tile_object_behind_player_found
    dec a
    cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr z, get_tile_object_behind_player_found
    dec a
    cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr z, get_tile_object_behind_player_found
    dec a
    cp (ix + ROOM_TILE_OBJECT_STRUCT_X)
	jr z, get_tile_object_behind_player_found
	jr get_tile_object_behind_player_loop_next

get_tile_object_behind_player_32x32_object:
	ld a, b
	dec a
	dec a
	cp (ix + ROOM_TILE_OBJECT_STRUCT_Y)
	jr nz, get_tile_object_behind_player_loop_next
	jr get_tile_object_behind_player_32x24_object_x


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
; - c, b: x, y
; - e, d: width, height
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
