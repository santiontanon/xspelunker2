;-----------------------------------------------
; Check if tile type is 2
; output:
; - z: collision
; - nz: no collision
player_check_collision_horizontal:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet:
	inc c
	inc b
	call get_room_tile_type
	cp 2
	ret


;-----------------------------------------------
; Check if tile type is 1 or 2 (incrementing y by 1 pixel)
; output:
; - z: collision
; - nz: no collision
player_check_collision_down_inc:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet:
	inc c
	inc b
	inc b
	call get_room_tile_type
	cp 2
	ret z
	dec a
	ret
	

;-----------------------------------------------
player_check_collision_up:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the head:
	inc c
	call get_room_tile_type
	cp 2
	ret


;-----------------------------------------------
; input:
; - c: tile x
; - b: tile y
; output:
; - a: tile collision type
get_room_tile_type:
	; get room ID and within room coordinates:
	call global_position_to_layout_and_room_coordinates

	; e = layout coordinates: e + d * 4:
	ld a, d
	add a, a
	add a, a
	add a, e
	ld e, a
	ld d, 0
	ld hl, current_room__layout
	add hl, de
	ld a, (hl)  ; a = room ID (must be > 0)
	dec a

	; get tile from the proper room:
	ld l, 0
	ld h, a
	add hl, hl
	ld d, a
	ld e, 0
	add hl, de
	ld de, current_room__tile_map
	add hl, de  ; hl = current_room__tile_map + a * 32 * 24
	ex de, hl

	; add room coordinates:
	; hl += b * 32 + c
	ld a, b
	add a, a
	add a, a
	add a, a
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	ld b, 0
	add hl, bc
	add hl, de
	ld a, (hl)

	; get collision type:
	ld hl, tile_collision_types_pyramid
	ADD_HL_A
	SETMEGAROMPAGE_8000 TILES_PAGE
	ld a, (hl)
	ret
