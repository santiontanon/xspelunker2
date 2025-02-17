;-----------------------------------------------
; Check if tile type is 2
; output:
; - z: collision
; - nz: no collision
player_check_collision_left:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet:
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_left_continue
	inc b
player_check_collision_left_continue:
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret z
	; if we are crawling, do not check head:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CRAWLING
	jr z, player_check_collision_left_no_collision	
	; collision with the head:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_y)
	cp 8 - PLAYER_COLLISION_UP_LEEWAY  ; 5
	jr c, player_check_collision_left_continue2
	inc b
player_check_collision_left_continue2:
	call get_room_tile_type
	cp 2
	ret
player_check_collision_left_no_collision:
	or 1
	ret


;-----------------------------------------------
; Check if tile type is 2
; output:
; - z: collision
; - nz: no collision
player_check_collision_right:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet:
	inc c
	inc c
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_right_continue
	inc b
player_check_collision_right_continue:
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret z
	; if we are crawling, do not check head:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CRAWLING
	jr z, player_check_collision_right_no_collision
	; collision with the head:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_y)
	cp 8 - PLAYER_COLLISION_UP_LEEWAY  ; 5
	jr c, player_check_collision_right_continue2
	inc b
player_check_collision_right_continue2:
	call get_room_tile_type
	cp 2
	ret
player_check_collision_right_no_collision:
	or 1
	ret


;-----------------------------------------------
; Check if tile type is 2 or 1 (if pixel coordinate is 0 only) (incrementing y by 1 pixel)
; output:
; - z: collision
; - nz: no collision
player_check_collision_down_inc:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet-left:
	inc b
	inc b
	ld a, (player_x)
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	jr c, player_check_collision_down_inc_continue
	inc c  ; if >= PLAYER_COLLISION_BOX_WIDTH, c+=1
player_check_collision_down_inc_continue:
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret z
	dec a
	jr nz, player_check_collision_down_inc_right
	; tile type is 1 (platform), check if pixel coordinate is 0, and in that case, it's a collision:
	ld a, (player_y)
	or a
	ret z
player_check_collision_down_inc_right:
	; collision with the feet-right:
	ld a, (player_x)
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	jr nc, player_check_collision_down_inc_continue2
	inc c  ; if < PLAYER_COLLISION_BOX_WIDTH, c+=1
	jp player_check_collision_down_inc_continue3
player_check_collision_down_inc_continue2:
	cp (8 - PLAYER_COLLISION_BOX_WIDTH)
	jr c, player_check_collision_down_inc_continue3
	inc c  ; if >= (8 - PLAYER_COLLISION_BOX_WIDTH), c+=1
player_check_collision_down_inc_continue3:
	call get_room_tile_type
	cp 2
	ret z
	dec a
	ret nz
	; tile type is 1 (platform), check if pixel coordinate is 0, and in that case, it's a collision:
	ld a, (player_y)
	or a
	ret


;-----------------------------------------------
player_check_collision_up:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the head-left:
; 	inc c
	ld a, (player_x)
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	jr c, player_check_collision_up_continue
	inc c  ; if >= PLAYER_COLLISION_BOX_WIDTH, c+=1
player_check_collision_up_continue:
	push bc
		call get_room_tile_type
	pop bc
	cp 2
	ret z
	; collision with the head-right:
	ld a, (player_x)
	cp PLAYER_COLLISION_BOX_WIDTH + 1
	jr nc, player_check_collision_up_continue2
	inc c  ; if < PLAYER_COLLISION_BOX_WIDTH, c+=1
	jp player_check_collision_up_continue3
player_check_collision_up_continue2:
	cp (8 - PLAYER_COLLISION_BOX_WIDTH)
	jr c, player_check_collision_down_inc_continue3
	inc c  ; if >= (8 - PLAYER_COLLISION_BOX_WIDTH), c+=1
player_check_collision_up_continue3:
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
	ld a, (current_room__width)
	cp 64
	jr z, get_room_tile_type_width64
get_room_tile_type_width32:
	; in this case, we know room_scroll_x == 0
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 32
	jp get_room_tile_type_continue
get_room_tile_type_width64:
	ld l, b
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; hl = y * 64
get_room_tile_type_continue:
	ld b, 0
	add hl, bc
	ld bc, current_room__tile_map
	add hl, bc
	ld a, (hl)

	; get room ID and within room coordinates:
; 	call global_position_to_layout_and_room_coordinates

; 	; e = layout coordinates: e + d * 4:
; 	ld a, d
; 	add a, a
; 	add a, a
; 	add a, e
; 	ld e, a
; 	ld d, 0
; 	ld hl, current_room__layout
; 	add hl, de
; 	ld a, (hl)  ; a = room ID (must be > 0)
; 	dec a

; 	; get tile from the proper room:
; 	ld l, 0
; 	ld h, a
; 	add hl, hl
; 	ld d, a
; 	ld e, 0
; 	add hl, de
; 	ld de, current_room__tile_map
; 	add hl, de  ; hl = current_room__tile_map + a * 32 * 24
; 	ex de, hl

; 	; add room coordinates:
; 	; hl += b * 32 + c
; 	ld a, b
; 	add a, a
; 	add a, a
; 	add a, a
; 	ld l, a
; 	ld h, 0
; 	add hl, hl
; 	add hl, hl
; 	ld b, 0
; 	add hl, bc
; 	add hl, de
; 	ld a, (hl)

	; get collision type:
	ld hl, tile_collision_types_pyramid
	ADD_HL_A
	ld a, (hl)
	ret


;-----------------------------------------------
; 0: no collision
; 1: platform (you can jump through)
; 2: wall
; 3: hazard
; 4: water
tile_collision_types_pyramid:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3
    db 4, 4, 4, 4, 0, 0, 0, 1, 1, 1, 1, 1, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2

