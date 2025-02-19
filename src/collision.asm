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
; Check if tile type is 1/2/6/8 (if pixel coordinate is 0 only) (incrementing y by 1 pixel)
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
	cp 2  ; wall
	ret z
	cp 6  ; rope-platform
	jr z, player_check_collision_down_inc_platform
	cp 6  ; ladder-platform
	jr z, player_check_collision_down_inc_platform
	dec a  ; platform
	jr nz, player_check_collision_down_inc_right
player_check_collision_down_inc_platform:
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
	cp 6  ; rope-platform
	jr z, player_check_collision_down_inc_platform2
	cp 8  ; ladder-platform
	jr z, player_check_collision_down_inc_platform2
	dec a  ; platform
	ret nz
player_check_collision_down_inc_platform2:
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
; Check if tile type is 5/6/7/8 (if pixel coordinate is 0 only) (incrementing y by 1 pixel)
; output:
; - z: rope
; - nz: no rope
; - a: 0, if (player_x + 1) tile below is rope
;      1, if (player_x + 1) + 1 tile below is rope
;	   2, if (player_X + 1) tile below is a ladder && (player_X + 1) + 1 as well
check_player_on_rope_or_ladder:  ; this checks for y + 1
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	jp check_player_on_top_of_rope_continue
check_player_on_top_of_rope_or_ladder:  ; this checks for y + 2
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	; collision with the feet-left:
	inc b
check_player_on_top_of_rope_continue:
	inc b
	push bc
		call get_room_tile_type
	pop bc
	cp 5
	jr z, check_player_on_top_of_rope_0
	cp 6
	jr z, check_player_on_top_of_rope_0
	cp 7
	jr z, check_player_maybe_on_top_of_ladder
	cp 8
	jr z, check_player_maybe_on_top_of_ladder	
check_player_on_top_of_rope_right:
	inc c
	call get_room_tile_type
	cp 5
	jr z, check_player_on_top_of_rope_1
	cp 6
	jr z, check_player_on_top_of_rope_1
	ret
check_player_on_top_of_rope_0:
	xor a  ; z, a = 0
	ret
check_player_on_top_of_rope_1:
	ld a, 1
	ret
check_player_maybe_on_top_of_ladder:
	inc c
	call get_room_tile_type
	cp 7
	jr z, check_player_on_top_of_ladder
	cp 8
	ret nz
check_player_on_top_of_ladder:
	ld a, 2
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
; 5: rope
; 6: rope-platform-top
; 7: ladder
; 8: ladder-platform-top
tile_collision_types_pyramid:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3
    db 4, 4, 4, 4, 5, 5, 5, 6, 1, 1, 1, 1, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 7, 7, 8, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 0, 0, 8, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 0, 0, 0, 5, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
    db 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2

