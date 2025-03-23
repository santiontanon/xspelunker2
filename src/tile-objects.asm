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

	call room_render_tile_objects
	; force redraw:
	ld a, 1
	ld (redraw_whole_room_flag), a
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
		ld a, 1
		ld (redraw_whole_room_flag), a
	pop hl
	pop af  ; we do an extra pop, since we are skipping the one at update_tile_objects_loop_continue
	jp update_tile_objects_loop


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
		add a, (hl)  ; type
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
		add a, (hl)  ; type
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
	TILE_OBJECT_DATA 0, 0, 0, 0
ENDR
	TILE_OBJECT_DATA 0, 2, 2, tile_object_pushable_block_gfx


tile_object_pushable_block_gfx:
	db 185, 187, 182, 184

