;-----------------------------------------------
; output:
; - z: we could find a new ptr
; - nz: no ptrs available
; - hl: ptr if one was available
ptr_to_new_sprite_object:
	ld de, ROOM_OBJECT_STRUCT_SIZE
	ld hl, current_room__objects
ptr_to_new_sprite_object_loop:
	ld a, (hl)
	or a
	ret z
	inc a
	jr z, ptr_to_new_sprite_object_reached_sentinel
	add hl, de
	jp ptr_to_new_sprite_object_loop
ptr_to_new_sprite_object_reached_sentinel:
	or 1
	ret


;-----------------------------------------------
; input:
; - c, b: tile coordinates where to spawn
spawn_water_splash:	
	call ptr_to_new_sprite_object
	ret nz
	ld (hl), SPRITE_OBJECT_TYPE_WATER_SPLASH
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 8  ; state (frames left)
	ld hl, SFX_watersplash_soft
	jp play_SFX_with_high_priority


;-----------------------------------------------
; input:
; - c, b: tile coordinates of the block
spawn_pushing_block_dust:	
	call ptr_to_new_sprite_object
	ret nz
	ld (hl), SPRITE_OBJECT_TYPE_BLOCK_DUST
	inc hl
	ld (hl), c  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), b  ; tile y
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 8  ; state (frames left)
	ld hl, SFX_explosion
	jp play_SFX_with_high_priority


;-----------------------------------------------
update_sprite_objects:
	xor a
	ld (n_displayed_object_sprites), a
	ld de, ROOM_OBJECT_STRUCT_SIZE
	ld ix, current_room__objects
update_sprite_objects_loop:
	ld a, (ix)
	or a
	ret z
	cp #ff  ; sentinel
	ret z
	dec a
	jr z, update_sprite_objects_water_splash
	dec a
	jr z, update_sprite_objects_pushing_block_dust
update_sprite_objects_loop_next:
	add ix, de
	jp update_sprite_objects_loop


; -----------------------------------------------
update_sprite_objects_water_splash:
	ld d, COLOR_WHITE
	ld e, 8
	call get_sprite_object_sprite_coordinates
	call add_sprite_to_this_frame

update_sprite_objects_pushing_block_dust_entry_point:
	dec (ix + ROOM_OBJECT_STRUCT_STATE)
	ld a, (ix + ROOM_OBJECT_STRUCT_STATE)
	or a
	jp nz, update_sprite_objects_loop_next
	call sprite_object_remove_object
	; move the ptr one back, so that the loop can continue:
	ld de, -ROOM_OBJECT_STRUCT_SIZE
	add ix, de
	ld de, ROOM_OBJECT_STRUCT_SIZE
	jp update_sprite_objects_loop_next


;-----------------------------------------------
update_sprite_objects_pushing_block_dust:
	ld d, COLOR_WHITE
	ld e, 12
	call get_sprite_object_sprite_coordinates
	ld a, c
	add a, -16
	ld c, a
	push bc
		call add_sprite_to_this_frame
	pop bc

	ld d, COLOR_WHITE
	ld e, 16
	ld a, c
	add a, 32
	ld c, a
	call add_sprite_to_this_frame
	jp update_sprite_objects_pushing_block_dust_entry_point


;-----------------------------------------------
; input:
; - ix: object ptr
; - d: expected sprite color
; output:
; - c, b: sprite x, y
; - d: updated sprite color with early clock bit
get_sprite_object_sprite_coordinates:
	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
	ld hl, room_scroll_y
	sub (hl)
	add a, a
	add a, a
	add a, a
	add a, (ix + ROOM_OBJECT_STRUCT_PIXEL_Y)
	dec a  ; sprites y in the VDP is off by 1 pixel
	ld b, a

	ld a, (ix + ROOM_OBJECT_STRUCT_TILE_X)
	ld hl, room_scroll_x
	sub (hl)
	add a, a
	add a, a
	add a, a
	add a, (ix + ROOM_OBJECT_STRUCT_PIXEL_X)
	ld c, a

	; set "early clock bit"?
	cp 256 - (8 - PLAYER_COLLISION_WIDTH/2)
	ret c
	set 7, d
	ret


;-----------------------------------------------
; input:
; - c, b: x, y
; - e: sprite number
; - d: attribute + early clock
add_sprite_to_this_frame:
	ld a, (n_displayed_object_sprites)
	cp 32 - FIRST_OBJECT_SPRITE
	ret z  ; do not add more sprites than we can display
	add a, a
	add a, a
	ld hl, sprite_attribute_table + FIRST_OBJECT_SPRITE * 4
	ADD_HL_A
	ld (hl), b
	inc hl
	ld (hl), c
	inc hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, n_displayed_object_sprites
	inc (hl)
	ret



;-----------------------------------------------
sprite_object_remove_object:
	; shift all the objects one position left:
	ld (ix), 0  ; clear the current object type (only needed if this is the last object, but just in case).
	ld d, ixh
	ld e, ixl
	ld h, d
	ld l, e
	ld bc, ROOM_OBJECT_STRUCT_SIZE
	add hl, bc
	push hl
	push de
		ld hl, current_room__objects_sentinel - ROOM_OBJECT_STRUCT_SIZE
		or a
		sbc hl, de  ; hl = amount to copy
		ld b, h
		ld c, l
	pop de
	pop hl
	ld a, c
	or b
	ret z  ; nothing to copy
	ldir  ; shift all the objects left
	ret

