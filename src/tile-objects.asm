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
		call room_remove_tile_objects
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
	ld hl, SFX_enemy_kill
	call play_SFX_with_high_priority

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
room_remove_tile_objects:
	ld hl, current_room__tile_objects_sentinel - ROOM_TILE_OBJECT_STRUCT_SIZE  ; ptr to the last object
	ld b, (current_room__tile_objects_sentinel - current_room__tile_objects)/ROOM_TILE_OBJECT_STRUCT_SIZE
room_remove_tile_objects_loop:
	ld a, (hl)  ; ID
	cp #ff
	jr z, room_remove_tile_objects_loop_continue_no_pop
	; render the object:
	push bc
	push hl
		inc hl
		ld a, (hl)  ; type
		cp TAG_BREAKABLE_WALL1
		jr z, room_remove_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL2
		jr z, room_remove_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL3
		jr z, room_remove_tile_objects_loop_continue		
		cp TAG_BREAKABLE_WALL4
		jr z, room_remove_tile_objects_loop_continue		
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
		jr z, room_remove_tile_objects_restore_background  ; type 0: we had saved the background
		dec a
		jr z, room_remove_tile_objects_delete_object  ; type 1: we just replace with 0s
room_remove_tile_objects_loop_continue:
	pop hl
	pop bc
room_remove_tile_objects_loop_continue_no_pop:
	ld de, -ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, de
	djnz room_remove_tile_objects_loop
	ret


room_remove_tile_objects_restore_background:
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
room_remove_tile_objects_restore_background_loop_y:
			push ix
			push bc
			push hl
room_remove_tile_objects_restore_background_loop_x:
				; check that:
				; - ixl < current_room__width
				; - ixl >= 0
				; - ixh < current_room__height
				ld a, (current_room__width)
				cp ixl
				jr z, room_remove_tile_objects_restore_background_loop_x_continue
				jr c, room_remove_tile_objects_restore_background_loop_x_continue
				ld a, ixl
				or a
				jp m, room_remove_tile_objects_restore_background_loop_x_continue
				ld a, (current_room__height)
				cp ixh
				jr z, room_remove_tile_objects_restore_background_loop_x_continue
				jr c, room_remove_tile_objects_restore_background_loop_x_continue

				; restore background:
				ld a, (iy + ROOM_TILE_OBJECT_STRUCT_BACKGROUND)
				ld (hl), a
room_remove_tile_objects_restore_background_loop_x_continue
				inc hl
				inc iy
				inc ixl
				ld a, ixl
				or a
				jr nz, room_remove_tile_objects_restore_background_loop_x_continue2
				; if ixl turned 0, it means the previous pointer was probably bad, so, we need to recompute it:
				push bc
					ld c, ixl
					ld b, ixh
					call get_room_tile_ptr					
				pop bc
room_remove_tile_objects_restore_background_loop_x_continue2:

				dec c
				jr nz, room_remove_tile_objects_restore_background_loop_x
			pop hl
			pop bc
			pop ix
			inc ixh
			ld a, (current_room__width)
			ADD_HL_A
			djnz room_remove_tile_objects_restore_background_loop_y
		pop ix
		jp room_remove_tile_objects_loop_continue


room_remove_tile_objects_delete_object:
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
room_remove_tile_objects_delete_object_loop_y:

		push bc
		push hl
room_remove_tile_objects_delete_object_loop_x:
			; restore background:
			ld (hl), 0
			inc hl
			dec c
			jr nz, room_remove_tile_objects_delete_object_loop_x
		pop hl
		pop bc
		ld a, (current_room__width)
		ADD_HL_A
		djnz room_remove_tile_objects_delete_object_loop_y
		jp room_remove_tile_objects_loop_continue


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

	push de
		ld c, (ix + ROOM_TILE_OBJECT_STRUCT_X)
		ld b, (ix + ROOM_TILE_OBJECT_STRUCT_Y)
		call get_room_tile_ptr
	pop bc
room_remove_breakable_wall_loop_y:
	push bc
	push hl
room_remove_breakable_wall_loop_x:
		ld (hl), 0
		inc hl
		dec c
		jr nz, room_remove_breakable_wall_loop_x
	pop hl
	pop bc
	ld a, (current_room__width)
	ADD_HL_A
	djnz room_remove_breakable_wall_loop_y
	push ix
	pop hl
	jp delete_tile_object_in_hl


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
REPT TAG_PUSHABLE_BLOCK  ; add filler
	TILE_OBJECT_DATA 2, 0, 0, 0
ENDR
	TILE_OBJECT_DATA 0, 2, 2, tile_object_pushable_block_gfx


tile_object_pushable_block_gfx:
	db 185, 187, 182, 184

