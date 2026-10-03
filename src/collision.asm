;-----------------------------------------------
; input:
; - c, b: tile x, y
; output:
; - z: collision
; - nz: no collision
general_check_collision:
	call get_room_tile_type
	dec a
	ret z  ; platform
	dec a
	ret z  ; wall
	cp 4
	ret z  ; rope-platform-top
	cp 6
	ret  ; ladder-platform-top


;-----------------------------------------------
; input:
; - c, b: tile x, y
; output:
; - z: collision
; - nz: no collision
general_check_collision_with_wall:
	call get_room_tile_type
	cp 2
	ret


;-----------------------------------------------
; This is what is used to check collisions with walls, and also
; to see if we can get up when the player is crouching.
; - collision range in x is: 6 - 10  [offset by "8 - PLAYER_COLLISION_WIDTH/2"]
; - assuming PLAYER_COLLISION_WIDTH == 4: 0 - 4
; 000000001111111122222222
; xxxx....
;  xxxx...
;   xxxx..
;    xxxx.
;     xxxx
;      xxxx
;       xxxx
;        xxxx
; - if pixel_x = 0  ->  tile_x
; - if pixel_x = 1  ->  tile_x
; - if pixel_x = 2  ->  tile_x
; - if pixel_x = 3  ->  tile_x
; - if pixel_x = 4  ->  tile_x
; - if pixel_x = 5  ->  tile_x, tile_x + 1
; - if pixel_x = 6  ->  tile_x, tile_x + 1
; - if pixel_x = 7  ->  tile_x, tile_x + 1
; output:
; - a: tile type (if there is collision)
; - z: collision
; - nz: no collision
player_check_collision_idle:
	ld a, (player_y + 1)  ; tile y
	ld b, a
	ld a, (player_x + 1)  ; tile x
	ld c, a
; 	cp #ff
; 	jp z, player_exit_room_left
	; collision with the feet:
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_idle_continue
	inc b
player_check_collision_idle_continue:
	push bc
		call get_room_tile_type_player
	pop bc
	cp 2
	ret z
	ld a, (player_x)
	cp 5
	jr c, player_check_collision_idle_head
	inc hl
	ld a, (hl)
	or a
	call nz, get_collision_tile_type_of_a  ; 0 is directly no collision (we exit early, as the tile type table starts at 32)
	cp 2
	ret z
player_check_collision_idle_head:
	; collision with the head:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	jr c, player_check_collision_idle_continue3
	inc b
player_check_collision_idle_continue3:
	call get_room_tile_type_player
	cp 2
	ret z
	ld a, (player_x)
	cp 5
	jr c, player_check_collision_idle_no_collision
	inc hl
	ld a, (hl)
	or a
	call nz, get_collision_tile_type_of_a  ; 0 is directly no collision (we exit early, as the tile type table starts at 32)
	cp 2
	ret
player_check_collision_idle_no_collision:
	or 1
	ret


;-----------------------------------------------
; Same as 'player_check_collision_idle' but checks collision with types: 3, 9, 11, 12
player_check_collision_idle_with_hazard_or_waterfalls:
	ld a, (player_y + 1)  ; tile y
	ld b, a
	ld a, (player_x + 1)  ; tile x
	ld c, a
; 	cp #ff
; 	jp z, player_exit_room_left
	; collision with the feet:
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_idle_with_hazard_or_waterfalls_continue
	inc b
player_check_collision_idle_with_hazard_or_waterfalls_continue:
	push bc
		call get_room_tile_type_player
	pop bc
	cp 3
	ret z
	cp 9
	ret z
	cp 11
	ret z
	cp 12
	ret z
	ld a, (player_x)
	cp 5
	jr c, player_check_collision_idle_with_hazard_or_waterfalls_head
	inc hl
	ld a, (hl)
	or a
	call nz, get_collision_tile_type_of_a  ; 0 is directly no collision (we exit early, as the tile type table starts at 32)
	cp 3
	ret z
	cp 9
	ret z
	cp 11
	ret z
	cp 12
	ret z
player_check_collision_idle_with_hazard_or_waterfalls_head:
	; collision with the head:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	jr c, player_check_collision_idle_with_hazard_or_waterfalls_continue3
	inc b
player_check_collision_idle_with_hazard_or_waterfalls_continue3:
	call get_room_tile_type_player
	cp 3
	ret z
	cp 9
	ret z
	cp 11
	ret z
	cp 12
	ret z
	ld a, (player_x)
	cp 5
	jr c, player_check_collision_idle_no_collision
	inc hl
	ld a, (hl)
	or a
	call nz, get_collision_tile_type_of_a  ; 0 is directly no collision (we exit early, as the tile type table starts at 32)
	cp 3
	ret z
	cp 9
	ret z
	cp 11
	ret z
	cp 12
	ret


;-----------------------------------------------
; - collision range in x is: 5 - 11  [offset by "8 - PLAYER_COLLISION_WIDTH/2"]
; - assuming PLAYER_COLLISION_WIDTH == 4: -1 - 5
; --------000000001111111122222222
;        xxxxxx...
;         xxxxxx..
;          xxxxxx.
;           xxxxxx
;            xxxxxx
;             xxxxxx
;              xxxxxx
;               xxxxxx
; - if pixel_x = 0  ->  tile_x -1, tile_x
; - if pixel_x = 1  ->  tile_x
; - if pixel_x = 2  ->  tile_x
; - if pixel_x = 3  ->  tile_x
; - if pixel_x = 4  ->  tile_x, tile_x + 1
; - if pixel_x = 5  ->  tile_x, tile_x + 1
; - if pixel_x = 6  ->  tile_x, tile_x + 1
; - if pixel_x = 7  ->  tile_x, tile_x + 1
; However, to simplify (and to give the player a small advantage), we use the same
; range as 'player_check_collision_idle'
; - We check collision with hazards, falling water/lava: 3, 9, 11, 12
; output:
; - a: tile type (if there is collision)
; - z: collision
; - nz: no collision
player_check_collision_crouching_with_hazard_or_waterfalls:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_x + 1)
	ld c, a
; 	cp #ff
; 	jp z, player_exit_room_left
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_crouching_with_de_continue
	inc b
player_check_collision_crouching_with_de_continue:
	call get_room_tile_type_player
	cp 3
	ret z
	cp 9
	ret z
	cp 11
	ret z
	cp 12
	ret z
	ld a, (player_x)
	cp 5
	jp c, player_check_collision_idle_no_collision
	inc hl
	ld a, (hl)
	or a
	call nz, get_collision_tile_type_of_a  ; 0 is directly no collision (we exit early, as the tile type table starts at 32)
	cp 3
	ret z
	cp 9
	ret z
	cp 11
	ret z
	cp 12
	ret


;-----------------------------------------------
; output:
; - z: collision
; - nz: no collision
player_check_collision_left:
	ld a, (player_y + 1)
	ld b, a
	ld a, (player_x + 1)
	ld c, a
	; collision with the feet:
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_left_continue
	inc b
player_check_collision_left_continue:
	ld a, c
	cp #ff
	jp z, player_exit_room_left
	push bc
		call get_room_tile_type_player
	pop bc
	cp 2  ; wall
	ret z
	; if we are crawling, do not check head:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CRAWLING
	jr z, player_check_collision_left_no_collision

	; collision up to the head (might have to check 1 or 2 tiles):
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	ld a, (player_y + 1)
	jr c, player_check_collision_left_continue2
	inc a
player_check_collision_left_continue2:
	dec b
	cp b
	jr z, player_check_collision_left_continue3
	; need to do an intermediate check:
	push bc
		call get_room_tile_type_player
	pop bc
	cp 2  ; wall
	ret z
	dec b
player_check_collision_left_continue3:
	call get_room_tile_type_player
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
	inc b
	ld a, (player_y)
	or a
	jr z, player_check_collision_right_continue
	inc b
player_check_collision_right_continue:
	ld a, (current_room__width)
	cp c
	jp z, player_exit_room_right
	push bc
		call get_room_tile_type_player
	pop bc
	cp 2  ; wall
	ret z
	; if we are crawling, do not check head:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_CRAWLING
	jr z, player_check_collision_right_no_collision

	; collision up to the head (might have to check 1 or 2 tiles):
	ld a, (player_y)
	cp PLAYER_COLLISION_UP_LEEWAY
	ld a, (player_y + 1)
	jr c, player_check_collision_right_continue2
	inc a
player_check_collision_right_continue2:
	dec b
	cp b
	jr z, player_check_collision_right_continue3
	; need to do an intermediate check:
	push bc
		call get_room_tile_type_player
	pop bc
	cp 2  ; wall
	ret z
	dec b
player_check_collision_right_continue3:
	call get_room_tile_type_player
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
	ld a, (current_room__height)
	cp b
	jp z, player_exit_room_down
	push bc
		call get_room_tile_type_player
	pop bc
	cp 2  ; wall
	ret z
	cp 6  ; rope-platform
	jr z, player_check_collision_down_inc_platform
	cp 8  ; ladder-platform
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
	cp (8 - PLAYER_COLLISION_WIDTH) + 1
	jr c, player_check_collision_down_inc_continue2
	inc c  ; if < PLAYER_COLLISION_BOX_WIDTH, c+=1
player_check_collision_down_inc_continue2:
	call get_room_tile_type_player
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
	cp #ff
	jp z, player_exit_room_up
	push bc
		call get_room_tile_type_player
	pop bc
	cp 2
	ret z
	; collision with the head-right:
	ld a, (player_x)
	cp (8 - PLAYER_COLLISION_WIDTH) + 1
	jr c, player_check_collision_up_continue2
	inc c  ; if < PLAYER_COLLISION_BOX_WIDTH, c+=1
player_check_collision_up_continue2:
	call get_room_tile_type_player
	cp 2
	ret


;-----------------------------------------------
; Check if tile type is 5/6/7/8 (if pixel coordinate is 0 only) (incrementing y by 1 pixel)
; output:
; - z: rope
; - nz: no rope
; - a: 0, if rope
;	   2, if ladder
; - c: tile coordinate where the rope/ladder was found
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
	ld a, (player_x)
	cp 7
	jr nz, check_player_on_top_of_rope_continue2
	inc c
check_player_on_top_of_rope_continue2:
	inc b
	push bc
		call get_room_tile_type_player
	pop bc
	cp 5
	jr z, check_player_on_top_of_rope
	cp 6
	jr z, check_player_on_top_of_rope
	cp 7
	jr z, check_player_maybe_on_top_of_ladder
	cp 8
	jr z, check_player_maybe_on_top_of_ladder	
	ret
check_player_on_top_of_rope:
	xor a  ; z, a = 0
	ret
check_player_maybe_on_top_of_ladder:
	inc c
	push bc
		call get_room_tile_type_player
	pop bc
	dec c
	cp 7
	jr z, check_player_on_top_of_ladder
	cp 8
	jr nz, check_player_on_top_of_ladder_right
check_player_on_top_of_ladder:
	ld a, 2
	ret
check_player_on_top_of_ladder_right:
	dec c
	xor a  ; set z
	ld a, 2
	ret



;-----------------------------------------------
; Check if tile type is 4 or 10 (water or lava).
; output:
; - z: in water
; - nz: not in water
check_player_in_water:
	ld a, (player_x + 1)
	ld c, a
	ld a, (player_y + 1)
	ld b, a
	inc b
	call get_room_tile_type_player_behind_item
	cp 4  ; water
	ret z
	cp 10  ; lava
	ret 


;-----------------------------------------------
; input:
; - c: tile x
; - b: tile y
; output:
; - a: tile collision type
; - c: tile
; - hl: ptr to the tile
get_room_tile_type:
	ld l, b  ; assume b is positive
	ld h, 0
	call get_room_tile_ptr_hl_set
	ld a, (hl)
	or a
	ret z  ; 0 is directly no collision (we exit early, as the table below starts at 32)

get_collision_tile_type_of_a:
	; get collision type:
	push bc
		ld bc, current_room__collision_table
		ADD_BC_A
		ld a, (bc)
	pop bc
	ret


;-----------------------------------------------
; Same as "get_room_tile_type", but:
; - if we are in a boss room, and player_immunity_timer > 0:
;   - it checks the background copy of the room (without the boss drawn) for collision if collision type is "9"
; - if we are in boss 8, and we are checking bank 3, it uses 'boss__8_bank3_collision_table'.
get_room_tile_type_player:
	ld a, (boss__active)
	or a
	jr z, get_room_tile_type
	ld a, (boss__current_boss_number)
	cp 7
	jr z, get_room_tile_type_player_boss_8
	ld l, b  ; assume b is positive
	ld h, 0
	call get_room_tile_ptr_hl_set
	ld a, (hl)
	or a
	ret z  ; 0 is directly no collision (we exit early, as the table below starts at 32)
	; get collision type:
	push bc
		ld bc, current_room__collision_table
		ADD_BC_A
		ld a, (bc)
	pop bc
	cp 9
	ret nz
	; if we are here it is that we are in a boss room (as those are the only ones with
	; collision type 9).
	ex af, af'
		ld a, (player_immunity_timer)
		or a
		jr z, get_room_tile_type_player_no_immunity
	ex af, af'
	; We are in a boss room, collided with the boss, and are immune:
	; - we will check the background copy of the boss room, to collide with whatever
	;   is behind the boss instead.
	push bc
		ld bc, 64*24
		add hl, bc
	pop bc
	ld a, (hl)
	ld c, a
	or a
	ret z
	jp get_collision_tile_type_of_a
get_room_tile_type_player_no_immunity
	ex af, af'
	ret

get_room_tile_type_player_boss_8:
	ld a, b
	cp 16
	jr c, get_room_tile_type
	ld l, b  ; assume b is positive
	ld h, 0
	call get_room_tile_ptr_hl_set
	ld a, (hl)
	or a
	ret z  ; 0 is directly no collision (we exit early, as the table below starts at 32)
	; get collision type:
	push bc
		ld bc, boss__8_bank3_collision_table
		ADD_BC_A
		ld a, (bc)
	pop bc
	ret


;-----------------------------------------------
; Some times the player walks over an item, but we want to know the tile type
; of the tile that was behind that item. For example, when the player is swimming,
; and we want to know if the player is still in the water.
; input:
; - c: tile x
; - b: tile y
; output:
; - a: tile collision type
get_room_tile_type_player_behind_item:
	push bc
		call get_room_tile_type_player
	pop bc  ; coordinates are in e, d now
	or a
	ret nz  ; items are collision type == 0
	ld a, (hl)  ; recover again the actual tile
	cp FIRST_REGULAR_ITEM_TILE
	jr c, get_room_tile_type_player_behind_item_non_item
	cp LAST_REGULAR_ITEM_TILE
	jr nc, get_room_tile_type_player_behind_item_non_item
	; it's an item, we need to locate it, and get its background:
	ld hl, get_tile_behind_tile_object
	ld e, TILES_PAGE
	call call_hl_in_page_e_8000
	jr z, get_room_tile_type_player_behind_item_non_item
	ld bc, current_room__collision_table
	ADD_BC_A
	ld a, (bc)
	ret	
get_room_tile_type_player_behind_item_non_item:
	xor a
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - c, b: player tile coordinates (limited to room dimensions)
crop_player_tile_coordinates_top_room_limits:
		; make sure c, b, are within the room:
		ld a, c
		cp #ff
		jr nz, crop_player_tile_coordinates_top_room_limits_continue1
		inc c
crop_player_tile_coordinates_top_room_limits_continue1:
		ld a, (current_room__width)
		cp c
		jr nz, crop_player_tile_coordinates_top_room_limits_continue2
		dec c
crop_player_tile_coordinates_top_room_limits_continue2:
		ld a, b
		cp #ff
		jr nz, crop_player_tile_coordinates_top_room_limits_continue3
		inc b
crop_player_tile_coordinates_top_room_limits_continue3:
		ld a, (current_room__height)
		cp b
		ret nz
		dec b
		ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - hl: ptr inside "current_area__chunks_ids" where the player currently is located
; - ixl: player_y % 12
get_chunk_ids_current_room_ptr:
	push bc
		call crop_player_tile_coordinates_top_room_limits

		; convert c, b to coordinates in "chunks" (c/=16, b/=12)
		sra c
		sra c
		sra c
		sra c

		ld a, b
		ld b, 0
get_chunk_ids_current_room_ptr_div24_loop:
		sub 12
		jr c, get_chunk_ids_current_room_ptr_continue5
		inc b
		jr get_chunk_ids_current_room_ptr_div24_loop
get_chunk_ids_current_room_ptr_continue5:
		add a, 12
		ld ixl, a  ; player_y % 12

		ld a, (current_area__width)
		add a, a
		ld hl, 0
		ld d, 0
		ld e, a
		ld a, (current_room__y)
		add a, a
		add a, b
		or a
		jr z, get_chunk_ids_current_room_ptr_continue
get_chunk_ids_current_room_ptr_loop:
		add hl, de
		dec a
		jr nz, get_chunk_ids_current_room_ptr_loop
get_chunk_ids_current_room_ptr_continue:

		ld a, (current_room__x)
		add a, a
		add a, c
		ld e, a
		add hl, de
		ld de, current_area__chunks_ids
		add hl, de
	pop bc
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - hl: ptr inside "current_area__room_ids" where the player currently is located
get_room_ids_current_room_ptr:
	push bc
		call crop_player_tile_coordinates_top_room_limits
		call get_player_room_coordinates

		ld a, (current_area__width)
		ld hl, 0
		ld d, 0
		ld e, a
		ld a, (current_room__y)
		add a, b
		or a
		jr z, get_room_ids_current_room_ptr_continue
get_room_ids_current_room_ptr_loop:
		add hl, de
		dec a
		jr nz, get_room_ids_current_room_ptr_loop
get_room_ids_current_room_ptr_continue:

		ld a, (current_room__x)
		add a, c
		ld e, a
		add hl, de
		ld de, current_area__room_ids
		add hl, de
	pop bc
	ret


;-----------------------------------------------
; returns:
; - z: collision
; - nz: no collision
player_exit_room_left:
	ld a, (boss__in_boss_room)
	or a
	jr nz, player_exit_room_left__in_boss

	; are we exiting yatzil's room?
	ld a, (current_room__id)
	cp YATZIL_ROOM_ID
	ld a, BOSS_9_ROOM_PAGE
	ld hl, exit_yatzil_room
	jp z, jp_to_hl_in_page_a_8000

	; are we entering the astronomy room?
	ld a, (current_room__id)
	cp EIGHT_BRIDGE_ROOM_ID
	ld a, ASTRONOMY_ROOM_PAGE
	ld hl, astronomy_room__enter
	jp z, jp_to_hl_in_page_a_8000

	call check_for_interarea_exit_left
	call check_collision_with_next_chunk_left
	ret z  ; collision	
	call get_room_ids_current_room_ptr
	dec hl
	ld e, (hl)  ; next roomID
	ld a, e
	cp #ff
	ret z
	push de
		call disable_VDP_output
	pop de
	ld a, (current_room__y)
	push af
		push de
			ld hl, pcg_generate_room__enemy_respawn_logic_on_exit_room
			ld c, PCG_PAGE_ENEMIES
			call call_hl_in_page_c_8000
		pop de
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af
	; adjust "y" coordinate, based on the difference of current vs previous y coordinate:
	ld c, a
	ld a, (current_room__y)
	sub c
	neg
	add a, a
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, (player_y + 1)
	add a, c
	ld (player_y + 1), a

	ld a, (current_room__width)
	dec a
	ld (player_x + 1), a
	xor a
	ld (player_x), a
	jp state_play_from_loaded_room

player_exit_room_left__in_boss:
	ld a, (boss__current_boss_number)
	cp 5  ; mars boss
	jp z, player_exit_room_left__in_boss_mars
	xor a  ; no exit
	ret


;-----------------------------------------------
; returns:
; - z: collision
; - nz: no collision
player_exit_room_right:
	ld a, (boss__in_boss_room)
	xor #01  ; we do "xor 1" so that we exit with "z", and indicate collision
	ret z

	; are we leaving the astronomy room?
	ld a, (current_room__id)
	cp ASTRONOMY_ROOM_ID
	ld a, ASTRONOMY_ROOM_PAGE
	ld hl, astronomy_room__leave
	jp z, jp_to_hl_in_page_a_8000

	call check_for_interarea_exit_right
	call check_collision_with_next_chunk_right
	ret z  ; collision
	call get_room_ids_current_room_ptr
	inc hl
	ld e, (hl)  ; next roomID
	ld a, e
	cp #ff
	ret z
	push de
		call disable_VDP_output
	pop de
	ld a, (current_room__y)
	push af	
		push de
			ld hl, pcg_generate_room__enemy_respawn_logic_on_exit_room
			ld c, PCG_PAGE_ENEMIES
			call call_hl_in_page_c_8000
		pop de
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af
	; adjust "y" coordinate, based on the difference of current vs previous y coordinate:
	ld c, a
	ld a, (current_room__y)
	sub c
	neg
	add a, a
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, (player_y + 1)
	add a, c
	ld (player_y + 1), a

	xor a
	ld (player_x + 1), a
	ld (player_x), a
	jp state_play_from_loaded_room


;-----------------------------------------------
; returns:
; - z: collision
; - nz: no collision
player_exit_room_up:
	ld a, (boss__in_boss_room)
	xor #01  ; we do "xor 1" so that we exit with "z", and indicate collision
	ret z
	ld a, (current_room__id)
	cp MARS_ROBOT_PUZZLE_ROOM_ID
	jr z, player_exit_room_up_mars_robot_puzzle_room
	call check_for_interarea_exit_up
	call check_collision_with_next_chunk_up
	ret z  ; collision
	call get_room_ids_current_room_ptr
	ld a, (current_area__width)
	ld d, 0
	ld e, a
	or a
	sbc hl, de
	ld e, (hl)  ; next roomID
	ld a, e
	cp #ff
	ret z
	push de
		call disable_VDP_output
	pop de
	ld a, (current_room__x)
	push af
		push de
			ld hl, pcg_generate_room__enemy_respawn_logic_on_exit_room
			ld c, PCG_PAGE_ENEMIES
			call call_hl_in_page_c_8000
		pop de
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af
	; adjust "x" coordinate, based on the difference of current vs previous x coordinate:
	ld c, a
	ld a, (current_room__x)
	sub c
	neg
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, (player_x + 1)
	add a, c
	ld (player_x + 1), a

	ld a, (current_room__height)
	add a, -2
	ld (player_y + 1), a
	xor a
	ld (player_y), a
	jp state_play_from_loaded_room


player_exit_room_up_mars_robot_puzzle_room:
	ld a, MARS_ROBOT_PUZZLE_PAGE
	ld hl, mars_robot_puzzle_back_to_boss_room
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
; input:
; - c, b: player coordinates
; returns:
; - z: collision
; - nz: no collision
player_exit_room_down:
	ld a, (boss__in_boss_room)
	or a
	jr nz, player_exit_room_down__in_boss
	call check_for_interarea_exit_down
	call check_collision_with_next_chunk_down
	ret z  ; collision		
	call get_room_ids_current_room_ptr
	ld a, (current_area__width)
	ld d, 0
	ld e, a
	add hl, de
	ld e, (hl)  ; next roomID
	ld a, e
	cp #ff
	ret z
	push de
		call disable_VDP_output
	pop de
	ld a, (current_room__x)
	push af
		push de
			ld hl, pcg_generate_room__enemy_respawn_logic_on_exit_room
			ld c, PCG_PAGE_ENEMIES
			call call_hl_in_page_c_8000
		pop de
		ld hl, pcg_generate_room
		ld c, PCG_PAGE
		call call_hl_in_page_c_8000
	pop af
	; adjust "x" coordinate, based on the difference of current vs previous x coordinate:
	ld c, a
	ld a, (current_room__x)
	sub c
	neg
	add a, a
	add a, a
	add a, a
	add a, a
	add a, a
	ld c, a
	ld a, (player_x + 1)
	add a, c
	ld (player_x + 1), a

	xor a
	ld (player_y + 1), a
	ld (player_y), a
	jp state_play_from_loaded_room

player_exit_room_down__in_boss:
	ld a, (boss__current_boss_number)
	cp 3  ; xibalba lords
	jr z, player_exit_room_down__in_boss_xibalba_lords
	cp 5  ; mars boss
	jr z, player_exit_room_down__in_boss_mars
	xor a  ; no exit
	ret

player_exit_room_left__in_boss_mars:
player_exit_room_down__in_boss_xibalba_lords:
	call disable_VDP_output

	; teleport outside (store room/position before entering boss room):
	ld a, (boss_door_exit_to_room)
	ld e, a
	ld hl, pcg_generate_room
	ld c, PCG_PAGE
	call call_hl_in_page_c_8000

	ld a, (boss_door_exit_to_x)
	ld (player_x + 1), a
	ld a, (boss_door_exit_to_y)
	ld (player_y + 1), a

	jp state_play_from_loaded_room

player_exit_room_down__in_boss_mars:
	ld a, MARS_ROBOT_PUZZLE_PAGE
	ld hl, mars_robot_puzzle_spawn_room
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - z: collision
; - nz: no collision
check_collision_with_next_chunk_left:
	push bc
		call get_chunk_ids_current_room_ptr  ; ixl now has player_y % 12
	pop bc
	dec hl
	push hl
		call check_collision_with_next_chunk_check_if_its_special_room_left_right  ; e = collisionmask
		jr z, check_collision_with_next_chunk_left_continue
		ld a, (hl)  ; chunk ID
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		ld de, (current_area__chunk_edgecollisions_ptr)
		inc de
		inc de
		add hl, de
		ld a, CHUNK_EDGECOLLISIONS_PAGE
		call ld_hl_from_page_a  ; e = bitmask with collisions on the up edge of the chunk
check_collision_with_next_chunk_left_continue:
		ld a, ixl
		sra a
		; check if the corresponding bit is on/off:
check_collision_with_next_chunk_left_loop:
		jr z, check_collision_with_next_chunk_left_bit_found
		rr e
		dec a
		jp 	check_collision_with_next_chunk_left_loop
check_collision_with_next_chunk_left_bit_found:
		ld a, e
		and #01
		xor #01  ; reverse the bit to get the flag we want
	pop hl
	ret nz
	; collision, check if a door or breakable wall was open:
	ld de, -current_area__chunks_ids
	add hl, de
	ld e, l  ; e = chunk we are looking at
	ld ixh, 1  ; entering from the right
	push bc  ; preserve player coordinates
		call check_collision_with_next_chunk_check_horizontal_open_wall
	pop bc
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - z: collision
; - nz: no collision
check_collision_with_next_chunk_right:
	push bc
		call get_chunk_ids_current_room_ptr  ; ixl now has player_y % 12
	pop bc
	inc hl
	push hl
		call check_collision_with_next_chunk_check_if_its_special_room_left_right  ; e = collisionmask
		jr z, check_collision_with_next_chunk_right_continue
		ld a, (hl)  ; chunk ID
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		ld de, (current_area__chunk_edgecollisions_ptr)
		add hl, de
		ld a, CHUNK_EDGECOLLISIONS_PAGE
		call ld_hl_from_page_a  ; e = bitmask with collisions on the up edge of the chunk
check_collision_with_next_chunk_right_continue:
		ld a, ixl
		sra a
		; check if the corresponding bit is on/off:
check_collision_with_next_chunk_right_loop:
		jr z, check_collision_with_next_chunk_right_bit_found
		rr e
		dec a
		jp 	check_collision_with_next_chunk_right_loop
check_collision_with_next_chunk_right_bit_found:
		ld a, e
		and #01
		xor #01  ; reverse the bit to get the flag we want
	pop hl
	ret nz
	; collision, check if a door or breakable wall was open:
	ld de, -current_area__chunks_ids
	add hl, de
	ld e, l  ; e = chunk we are looking at
	ld ixh, 0  ; entering from the left
	push bc  ; preserve player coordinates
		call check_collision_with_next_chunk_check_horizontal_open_wall
	pop bc
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - z: collision
; - nz: no collision
check_collision_with_next_chunk_up:
	push bc
		call get_chunk_ids_current_room_ptr  ; ixl now has player_y % 12
	pop bc
	ld a, (current_area__width)
	add a, a
	ld e, a
	ld d, 0
	or a
	sbc hl, de
	push hl
		call check_collision_with_next_chunk_check_if_its_special_room_up_down  ; e = collisionmask
		jr z, check_collision_with_next_chunk_up_continue
		ld a, (hl)  ; chunk ID
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		ld de, (current_area__chunk_edgecollisions_ptr)
		inc de
		inc de
		inc de
		add hl, de
		ld a, CHUNK_EDGECOLLISIONS_PAGE
		call ld_hl_from_page_a  ; e = bitmask with collisions on the up edge of the chunk
check_collision_with_next_chunk_up_continue:
		ld a, c
		and #0f
		sra a
		; check if the corresponding bit is on/off:
check_collision_with_next_chunk_up_loop:
		jr z, check_collision_with_next_chunk_up_bit_found
		rr e
		dec a
		jp 	check_collision_with_next_chunk_up_loop
check_collision_with_next_chunk_up_bit_found:
		ld a, e
		and #01
		xor #01  ; reverse the bit to get the flag we want
	pop hl
	ret nz
	; collision, check if a door or breakable wall was open:
	ld de, -current_area__chunks_ids
	add hl, de
	ld e, l  ; e = chunk we are looking at
	ld ixh, 1  ; entering from the below
	push bc  ; preserve player coordinates
		call check_collision_with_next_chunk_check_vertical_open_wall
	pop bc
	ret


;-----------------------------------------------
; input:
; - a: page
; - hl: ptr
; output:
; - e: (hl) in page a
ld_hl_from_page_a:
	di
	ld (#7000), a
	ld e, (hl)
	ld a, (current_megarom_page_in_8000)
	ld (#7000), a
	ei
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
; output:
; - z: collision
; - nz: no collision
check_collision_with_next_chunk_down:
	push bc
		call get_chunk_ids_current_room_ptr  ; ixl now has player_y % 12
	pop bc
	ld a, (current_area__width)
	add a, a
	ld e, a
	ld d, 0
	add hl, de
	push hl
		call check_collision_with_next_chunk_check_if_its_special_room_up_down  ; e = collisionmask
		jr z, check_collision_with_next_chunk_down_continue
		ld a, (hl)  ; chunk ID
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		ld de, (current_area__chunk_edgecollisions_ptr)
		inc de
		add hl, de
		ld a, CHUNK_EDGECOLLISIONS_PAGE
		call ld_hl_from_page_a  ; e = bitmask with collisions on the up edge of the chunk
check_collision_with_next_chunk_down_continue:
		ld a, c
		and #0f
		sra a
		; check if the corresponding bit is on/off:
check_collision_with_next_chunk_down_loop:
		jr z, check_collision_with_next_chunk_down_bit_found
		rr e
		dec a
		jp 	check_collision_with_next_chunk_down_loop
check_collision_with_next_chunk_down_bit_found:
		ld a, e
		and #01
		xor #01  ; reverse the bit to get the flag we want
	pop hl
	ret nz
	; collision, check if a door or breakable wall was open:
	ld de, -current_area__chunks_ids
	add hl, de
	ld e, l  ; e = chunk we are looking at
	ld ixh, 0  ; entering from the above
	push bc  ; preserve player coordinates
		call check_collision_with_next_chunk_check_vertical_open_wall
	pop bc
	ret


;-----------------------------------------------
; Note: all special rooms have the "contract" that the openings above/below/left/right
;       are all in the same positions
; input:
; - hl: ptr to current_area__chunks_ids
; output:
; - e: collision mask
; - z: it is a special room
; - nz: it is not
check_collision_with_next_chunk_check_if_its_special_room_left_right:
	ld e, #23
	jr check_collision_with_next_chunk_check_if_its_special_room_continue
check_collision_with_next_chunk_check_if_its_special_room_up_down:
	ld e, #c3
check_collision_with_next_chunk_check_if_its_special_room_continue:
	ld a, (current_area__id)
	cp 3  ; confluence
	jr z, check_collision_with_next_chunk_check_if_its_special_room_confluence
	cp 9  ; atlantis
	jr z, check_collision_with_next_chunk_check_if_its_special_room_atlantis
	or 1  ; it is not a special room
	ret

check_collision_with_next_chunk_check_if_its_special_room_confluence:
check_collision_with_next_chunk_check_if_its_special_room_atlantis:
	push hl
	push bc
		ld bc, -current_area__chunks_ids
		add hl, bc
		ld a, (current_area__width)
		add a, a
		ld d, a  ; d = width in chunks
REPT MAX_SPECIAL_ROOMS_PER_AREA, ?index
		ld a, (current_area__special_room_chunk_id_offsets + ?index)
check_collision_with_next_chunk_check_if_its_special_room_atlantis_entry_point:
		cp l
		jr z, check_collision_with_next_chunk_check_if_its_special_room_confluence_done
		inc a
		cp l
		jr z, check_collision_with_next_chunk_check_if_its_special_room_confluence_done
		add a, d
		cp l
		jr z, check_collision_with_next_chunk_check_if_its_special_room_confluence_done
		dec a
		cp l
ENDR
check_collision_with_next_chunk_check_if_its_special_room_confluence_done:
	pop bc
	pop hl
	ret


;-----------------------------------------------
; input:
; - ixl: within chunk tile y coordinate to check
; - ixh: 0 (from left), 1 (from right)
; - e: chunk we are looking at
check_collision_with_next_chunk_check_horizontal_open_wall:
	ld a, (current_area__id)
	inc a
	ld d, a  ; area ID + 1
	ld hl, global_state__open_walls
check_collision_with_next_chunk_check_horizontal_open_wall_loop:
	ld a, (hl)
	or a
	ret z  ; no more open walls to check
	cp d
	jr nz, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next6
	inc hl
	ld a, (hl)
	cp e
	jr nz, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next5
	inc hl
	ld a, ixh
	or a
	jr nz, check_collision_with_next_chunk_check_horizontal_open_wall_right
	ld a, (hl)
	or a  ; if it's not in the left, we are not interested
	jr nz, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next4
	inc hl
	ld a, (hl)
	cp ixl  ; y coordinate within this chunk
	jr nc, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next3
	inc hl  ; skip width
check_collision_with_next_chunk_check_horizontal_open_wall_right_continue:
	inc hl
	add a, (hl)  ; a = y + height
	cp ixl  ; y coordinate within this chunk
	jr z, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next1
	jr c, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next1
	; wall was open! no collision!
	or 1
	ret
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next6:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next5:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next4:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next3:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next2:
	inc hl
check_collision_with_next_chunk_check_horizontal_open_wall_loop_next1:
	inc hl
	jr check_collision_with_next_chunk_check_horizontal_open_wall_loop

check_collision_with_next_chunk_check_horizontal_open_wall_right:
	ld c, (hl)
	inc hl
	ld b, (hl)
	cp ixl  ; y coordinate within this chunk
	jr nc, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next3
	inc hl
	ld a, (hl)
	add a, c
	cp CHUNK_WIDTH - 1
	ld a, b  ; recover 'y' in a
	jr c, check_collision_with_next_chunk_check_horizontal_open_wall_loop_next2
	jr check_collision_with_next_chunk_check_horizontal_open_wall_right_continue


;-----------------------------------------------
; input:
; - ixh: 0 (from above), 1 (from below)
; - e: chunk we are looking at
check_collision_with_next_chunk_check_vertical_open_wall:
	ld a, (player_x + 1)
	and #0f
	ld ixl, a  ; ixl = player tile coordinate within the chunk
	ld a, (current_area__id)
	inc a
	ld d, a  ; area ID + 1
	ld hl, global_state__open_walls
check_collision_with_next_chunk_check_vertical_open_wall_loop:
	ld a, (hl)
	or a
	ret z  ; no more open walls to check
	cp d
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_loop_next6
	inc hl
	ld a, (hl)
	cp e
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_loop_next5
	inc hl
	ld c, (hl)  ; x1
	ld a, c
	cp ixl  ; x coordinate within this chunk
	jr nc, check_collision_with_next_chunk_check_vertical_open_wall_loop_next4
	inc hl
	ld a, ixh
	or a
	ld a, (hl)  ; y1
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_down
	or a  ; if it's not in above, we are not interested
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_loop_next3
	inc hl
	ld a, c
	add a, (hl)
	cp ixl  ; x coordinate within this chunk
	jr z, check_collision_with_next_chunk_check_vertical_open_wall_loop_next2
	jr c, check_collision_with_next_chunk_check_vertical_open_wall_loop_next2
	; wall was open! no collision!
	or 1
	ret
check_collision_with_next_chunk_check_vertical_open_wall_loop_next6:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next5:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next4:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next3:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next2:
	inc hl
check_collision_with_next_chunk_check_vertical_open_wall_loop_next1:
	inc hl
	jr check_collision_with_next_chunk_check_vertical_open_wall_loop

check_collision_with_next_chunk_check_vertical_open_wall_down:
	ld b, a  ; y1
	inc hl
	ld a, c
	add a, (hl)  ; width
	cp ixl  ; x coordinate within this chunk
	jr z, check_collision_with_next_chunk_check_vertical_open_wall_loop_next2
	jr c, check_collision_with_next_chunk_check_vertical_open_wall_loop_next2
	inc hl
	ld a, (hl)  ; height	
	add a, b
	cp CHUNK_HEIGHT
	jr nz, check_collision_with_next_chunk_check_vertical_open_wall_loop_next1
	; wall was open! no collision!
	or 1
	ret


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
get_player_room_coordinates:
	; convert c, b to coordinates in "screens" (c/=32, b/=24)
	sra c
	sra c
	sra c
	sra c
	sra c
	ld a, b
	ld b, 0
get_player_room_coordinates_div24_loop:
	sub 24
	ret c
	inc b
	jr get_player_room_coordinates_div24_loop


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
get_player_chunk_coordinates:
	; convert c, b to coordinates in "screens" (c/=16, b/=12)
	sra c
	sra c
	sra c
	sra c
	ld a, b
	ld b, 0
get_player_chunk_coordinates_div12_loop:
	sub 12
	ret c
	inc b
	jr get_player_chunk_coordinates_div12_loop


;-----------------------------------------------
; input:
; - c, b: player tile coordinates
check_for_interarea_exit_left:
	ld d, PCG_DIRECTION_LEFT
	jp check_for_interarea_exit_d
check_for_interarea_exit_up:
	ld d, PCG_DIRECTION_UP
	jp check_for_interarea_exit_d
check_for_interarea_exit_right:
	ld d, PCG_DIRECTION_RIGHT
	jp check_for_interarea_exit_d
check_for_interarea_exit_down:
	ld d, PCG_DIRECTION_DOWN
check_for_interarea_exit_d:
	push bc
		call crop_player_tile_coordinates_top_room_limits
		call get_player_chunk_coordinates
		ld a, (current_room__x)
		add a, a
		add a, c
		ld c, a
		ld a, (current_room__y)
		add a, a
		add a, b
		ld b, a  ; c, b: room coordinate in the area

		ld a, (current_area__id)
		ld e, a
		; check if coordinates match any inter-area exit:
		ld hl, current_world__interarea_connections  ; id1, id2, x1, y1, direction1, x2, y2, direction2
check_for_interarea_exit_loop:
		ld a, (hl)  ; id1
		inc hl
		cp #ff  ; sentinel
		jr z, check_for_interarea_exit_done
		cp e
		jr nz, check_for_interarea_exit_no_area1
		inc hl
		ld a, (hl)  ; x1
		cp c
		jr nz, check_for_interarea_exit_no_x1
		inc hl
		ld a, (hl)  ; y1
		cp b
		jr nz, check_for_interarea_exit_no_y1
		inc hl
		ld a, (hl)  ; direction1
		cp d  ; compare with direction the player is exiting through
		jr nz, check_for_interarea_exit_no_direction1
		; match 1, we need to teleport to area 2!
; 	    ; only going up to another area up/down via ladders
; 		ld a, d
; 		cp PCG_DIRECTION_LEFT
; 		jr z, check_for_interarea_exit_exit1_ok
; 		cp PCG_DIRECTION_RIGHT
; 		jr z, check_for_interarea_exit_exit1_ok
; 		ld a, (player_state)
; 		and #fe
; 		cp PLAYER_STATE_LADDER
; 		jp nz, check_for_interarea_exit_done
; check_for_interarea_exit_exit1_ok:
		dec hl
		dec hl
		dec hl
		ld e, (hl)  ; id2
		inc hl
		inc hl
		inc hl
		inc hl
		SETMEGAROMPAGE_8000 INTERAREA_PAGE
		jp interarea_exit  ; no need for "pop bc", since interarea_exit will reset the stack

check_for_interarea_exit_no_direction1:
		dec hl
check_for_interarea_exit_no_y1:
		dec hl
check_for_interarea_exit_no_x1:
		dec hl
check_for_interarea_exit_no_area1:
		ld a, (hl)  ; id2
		inc hl
		inc hl
		inc hl
		inc hl
		cp e
		jr nz, check_for_interarea_exit_no_area2
		ld a, (hl)  ; x2
		cp c
		jr nz, check_for_interarea_exit_no_x2
		inc hl
		ld a, (hl)  ; y2
		cp b
		jr nz, check_for_interarea_exit_no_y2
		inc hl
		ld a, (hl)  ; direction2
		cp d  ; compare with direction the player is exiting through
		jr nz, check_for_interarea_exit_no_direction2
		; match 2, we need to teleport to area 1!
	    ; only going up to another area up/down via ladders
; 		ld a, d
; 		cp PCG_DIRECTION_LEFT
; 		jr z, check_for_interarea_exit_exit2_ok
; 		cp PCG_DIRECTION_RIGHT
; 		jr z, check_for_interarea_exit_exit2_ok
; 		ld a, (player_state)
; 		and #fe
; 		cp PLAYER_STATE_LADDER
; 		jp nz, check_for_interarea_exit_done
; check_for_interarea_exit_exit2_ok:		
		ld bc, -7
		add hl, bc
		ld e, (hl)  ; id1
		inc hl
		inc hl
		SETMEGAROMPAGE_8000 INTERAREA_PAGE
		jp interarea_exit  ; no need for "pop bc", since interarea_exit will reset the stack

check_for_interarea_exit_no_area2:
check_for_interarea_exit_no_x2:
		inc hl
check_for_interarea_exit_no_y2:		
		inc hl
check_for_interarea_exit_no_direction2:		
		inc hl
		jp check_for_interarea_exit_loop

check_for_interarea_exit_done:
	pop bc
	ret

