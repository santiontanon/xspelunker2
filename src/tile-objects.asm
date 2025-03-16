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
		jr z, room_render_tile_objects_render_saving_background
		dec a
		jr z, room_render_tile_objects_render
room_render_tile_objects_loop_continue:
	pop hl
	ld bc, ROOM_TILE_OBJECT_STRUCT_SIZE
	add hl, bc
	jp room_render_tile_objects_loop
	ret

room_render_tile_objects_render_saving_background:
	; - hl: ptr to tile_object_gfx_table
	; - ixl, ixh: x, y of the object
	; save background:
	push hl
		; ...
	pop hl

room_render_tile_objects_render:
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
	; ...
	ret


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

