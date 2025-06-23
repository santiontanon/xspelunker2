PCG_PRETTIFY_RANDOM: macro
	; We use the "r" register (rotating if 5 bits, so that some of the bricks code works)
	; since it's faster than "random_a" and for the prettify function it's random enough.
	; For important random stuff, where time is not as critical, we use "random_a".
; 	call random_a  ; 164949
	ld a, r
	rrca
	rrca
	rrca
	rrca
	rrca  ; 112000
	endm

;-----------------------------------------------
pcg_generate_room__prettify:
	ld a, (current_area__id)
	or a
	jp z, pcg_generate_room__prettify_jungle
	; ...
	jp pcg_generate_room__prettify_pyramid


;-----------------------------------------------
pcg_generate_room__prettify_jungle:
	; reconstruct ropes/ladders/faces/dragon:
	ld hl, current_room__tile_map
	ld bc, (current_room__width)
	ld a, (current_room__width)
	ld e, a
	ld d, 0	
pcg_generate_room__prettify_jungle_loop_y:
	push bc
		ld b, c
		; 9*16 + 0: tree left
		; 9*16 + 1: tree center
		; 9*16 + 2: tree right
		; 9*16 + 4: tree branch
        ; 12*16 + 6: floor
        ; 13*16 + 5: wall left
        ; 13*16 + 6: wall center
        ; 13*16 + 8: wall right
        ; 14*16 + 6: wall bottom
        ; 14*16 + 9: foliage
        ; 14*16 + 10: foliage down
        ; 15*16 + 14: rubble
		; 15*16 + 15: rope
		ld c, 9*16 + 0
pcg_generate_room__prettify_jungle_loop_x:
		ld a, (hl)
		sub c
		jr c, pcg_generate_room__prettify_jungle_loop_x_continue
		jr z, pcg_generate_room__prettify_jungle_tree_left
		dec a
		jr z, pcg_generate_room__prettify_jungle_tree_center
		dec a
		jr z, pcg_generate_room__prettify_jungle_tree_right
		sub 2
		jr z, pcg_generate_room__prettify_jungle_tree_branch
		sub (12*16 + 6) - (9*16 + 4)
		jr z, pcg_generate_room__prettify_jungle_floor
		sub (13*16 + 5) - (12*16 + 6)
		jp z, pcg_generate_room__prettify_jungle_wall_left
		dec a
		jp z, pcg_generate_room__prettify_jungle_wall_center
		dec a
		dec a
		jp z, pcg_generate_room__prettify_jungle_wall_right
		sub (14*16 + 6) - (13*16 + 8)
		jp z, pcg_generate_room__prettify_jungle_wall_bottom
		sub 3
		jp z, pcg_generate_room__prettify_jungle_foliage
		dec a
		jp z, pcg_generate_room__prettify_jungle_foliage_down
		sub (15*16 + 14) - (14*16 + 10)
		jp z, pcg_generate_room__prettify_jungle_rubble
		dec a
		jp z, pcg_generate_room__prettify_jungle_rope
pcg_generate_room__prettify_jungle_loop_x_continue:
		inc hl
		djnz pcg_generate_room__prettify_jungle_loop_x
	pop bc
	djnz pcg_generate_room__prettify_jungle_loop_y
	ret

pcg_generate_room__prettify_jungle_tree_left:
	PCG_PRETTIFY_RANDOM
	and #01
	jr z, pcg_generate_room__prettify_jungle_loop_x_continue
	ld (hl), 10*16 + 0
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_tree_center:
	PCG_PRETTIFY_RANDOM
	and #01
	jr z, pcg_generate_room__prettify_jungle_loop_x_continue
	ld (hl), 10*16 + 1
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_tree_right:
	PCG_PRETTIFY_RANDOM
	and #01
	jr z, pcg_generate_room__prettify_jungle_loop_x_continue
	ld (hl), 10*16 + 2
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_tree_branch:
	PCG_PRETTIFY_RANDOM
	and #01
	jr z, pcg_generate_room__prettify_jungle_loop_x_continue
	ld (hl), 9*16 + 5
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_floor:
	PCG_PRETTIFY_RANDOM
	and #03
	jr z, pcg_generate_room__prettify_jungle_loop_x_continue
	dec a
	jr z, pcg_generate_room__prettify_jungle_floor1
	dec a
	jr z, pcg_generate_room__prettify_jungle_floor2
	ld (hl), 13*16 + 9
	jp pcg_generate_room__prettify_jungle_loop_x_continue
pcg_generate_room__prettify_jungle_floor1:
	ld (hl), 12*16 + 7
	jp pcg_generate_room__prettify_jungle_loop_x_continue
pcg_generate_room__prettify_jungle_floor2:
	ld (hl), 12*16 + 9
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_wall_left:
	PCG_PRETTIFY_RANDOM
	and #01
	jr z, pcg_generate_room__prettify_jungle_loop_x_continue
	ld (hl), 15*16 + 6
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_wall_center:
	PCG_PRETTIFY_RANDOM
	and #01
	jp z, pcg_generate_room__prettify_jungle_loop_x_continue
	ld (hl), 13*16 + 7
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_wall_right:
	PCG_PRETTIFY_RANDOM
	and #01
	jp z, pcg_generate_room__prettify_jungle_loop_x_continue
	ld (hl), 15*16 + 5
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_wall_bottom:
	PCG_PRETTIFY_RANDOM
	and #01
	jp z, pcg_generate_room__prettify_jungle_loop_x_continue
	ld (hl), 14*16 + 7
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_foliage:
	PCG_PRETTIFY_RANDOM
	and #03
	jp z, pcg_generate_room__prettify_jungle_loop_x_continue
	dec a
	jp z, pcg_generate_room__prettify_jungle_foliage1
	ld (hl), 14*16 + 10
	jp pcg_generate_room__prettify_jungle_loop_x_continue
pcg_generate_room__prettify_jungle_foliage1:
	ld (hl), 14*16 + 11
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_foliage_down:
	PCG_PRETTIFY_RANDOM
	and #03
	jp z, pcg_generate_room__prettify_jungle_loop_x_continue
	dec a
	jp z, pcg_generate_room__prettify_jungle_foliage_down1
	ld (hl), 13*16 + 12
	jp pcg_generate_room__prettify_jungle_loop_x_continue
pcg_generate_room__prettify_jungle_foliage_down1:
	ld (hl), 13*16 + 11
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_rubble:
	PCG_PRETTIFY_RANDOM
	and #03
	jp z, pcg_generate_room__prettify_jungle_loop_x_continue
	add a, 10*16 + 8
	ld (hl), a
	jp pcg_generate_room__prettify_jungle_loop_x_continue

pcg_generate_room__prettify_jungle_rope:
	push hl
	push bc
		ld bc, current_room__tile_map
pcg_generate_room__prettify_jungle_rope_loop:
		or a
		sbc hl, de  ; go one row up
; 		or a
		sbc hl, bc  ; check if we are out of the map
		jr c, pcg_generate_room__prettify_jungle_rope_done
		add hl, bc
		ld a, (hl)
		cp 8*16 + 7  ; top rope piece
		jr z, pcg_generate_room__prettify_jungle_rope_done
pcg_generate_room__prettify_jungle_rope_keep_going:
		PCG_PRETTIFY_RANDOM
		and #03
		jp nz, pcg_generate_room__prettify_jungle_rope_keep_going2
		ld (hl), 8*16 + 3  ; rope knot
		jr pcg_generate_room__prettify_jungle_rope_loop
pcg_generate_room__prettify_jungle_rope_keep_going2:
		ld (hl), 8*16 + 6  ; rope
		jr pcg_generate_room__prettify_jungle_rope_loop
pcg_generate_room__prettify_jungle_rope_done:
	pop bc
	pop hl
	jp pcg_generate_room__prettify_jungle_loop_x_continue


;-----------------------------------------------
; This method:
; - completes ropes, ladders, dragon/face blocks
; - randomizes brick tiles
pcg_generate_room__prettify_pyramid:
	; reconstruct ropes/ladders/faces/dragon:
	ld hl, current_room__tile_map
	ld bc, (current_room__width)
	ld a, (current_room__width)
	ld e, a
	ld d, 0	
pcg_generate_room__prettify_pyramid_loop_y:
	push bc
		ld b, c
		ld c, 15*16 + 6
pcg_generate_room__prettify_pyramid_loop_x:
		ld a, (hl)
		sub c
		jr c, pcg_generate_room__prettify_pyramid_loop_x_continue
		jr z, pcg_generate_room__prettify_pyramid_bricks_randomize
		dec a
		jr z, pcg_generate_room__prettify_pyramid_rubble_randomize
		dec a
		jp z, pcg_generate_room__prettify_pyramid_ladder
		dec a
		jp z, pcg_generate_room__prettify_pyramid_face1
		dec a
		jp z, pcg_generate_room__prettify_pyramid_face2
		dec a
		jp z, pcg_generate_room__prettify_pyramid_dragon_head
		dec a
		jr z, pcg_generate_room__prettify_pyramid_spike_tip_randomize
		dec a
		jr z, pcg_generate_room__prettify_pyramid_thin_bricks_randomize
		dec a
		jr z, pcg_generate_room__prettify_pyramid_platform_randomize
		jp pcg_generate_room__prettify_pyramid_rope
pcg_generate_room__prettify_pyramid_loop_x_continue:
		inc hl
		djnz pcg_generate_room__prettify_pyramid_loop_x
	pop bc
	djnz pcg_generate_room__prettify_pyramid_loop_y
	ret

pcg_generate_room__prettify_pyramid_spike_tip_randomize:
	PCG_PRETTIFY_RANDOM
	and #01
	jr z, pcg_generate_room__prettify_pyramid_spike_tip_randomize_continue
	ld (hl), 8*16 + 13
pcg_generate_room__prettify_pyramid_spike_tip_randomize_continue:
	PCG_PRETTIFY_RANDOM
	and #01
	add a, 8*16 + 4
	add hl, de
	ld (hl), a
	sbc hl, de
	jp pcg_generate_room__prettify_pyramid_loop_x_continue

pcg_generate_room__prettify_pyramid_platform_randomize:
	PCG_PRETTIFY_RANDOM
	and #01
	jp z, pcg_generate_room__prettify_pyramid_loop_x_continue
	ld (hl), 8*16 + 9
	jp pcg_generate_room__prettify_pyramid_loop_x_continue

pcg_generate_room__prettify_pyramid_thin_bricks_randomize:
	PCG_PRETTIFY_RANDOM
	and #03
	sub 2
	jp c, pcg_generate_room__prettify_pyramid_loop_x_continue
	add a, 8*16 + 14
	ld (hl), a
	jp pcg_generate_room__prettify_pyramid_loop_x_continue

pcg_generate_room__prettify_pyramid_rubble_randomize:
	PCG_PRETTIFY_RANDOM
	and #03
	jp z, pcg_generate_room__prettify_pyramid_loop_x_continue
	add a, 10*16 + 0
	ld (hl), a
	jp pcg_generate_room__prettify_pyramid_loop_x_continue

pcg_generate_room__prettify_pyramid_bricks_randomize:
	PCG_PRETTIFY_RANDOM
	cp 96
	jr nc, pcg_generate_room__prettify_pyramid_bricks_randomize_continue
	; ld (hl), 9*16 + 5
	add hl, de
	ld (hl), 9*16 + 8
	sbc hl, de
	jp pcg_generate_room__prettify_pyramid_loop_x_continue
pcg_generate_room__prettify_pyramid_bricks_randomize_continue:
	cp 160
	jr nc, pcg_generate_room__prettify_pyramid_bricks_randomize_continue2
	ld (hl), 9*16 + 6
	add hl, de
	ld (hl), 9*16 + 8
	sbc hl, de
	jp pcg_generate_room__prettify_pyramid_loop_x_continue
pcg_generate_room__prettify_pyramid_bricks_randomize_continue2:
	ld (hl), 9*16 + 11
	add hl, de
	ld (hl), 9*16 + 7
	sbc hl, de
	jp pcg_generate_room__prettify_pyramid_loop_x_continue


pcg_generate_room__prettify_pyramid_rope:
	push hl
	push bc
		ld bc, current_room__tile_map
pcg_generate_room__prettify_pyramid_rope_loop:
		or a
		sbc hl, de  ; go one row up
; 		or a
		sbc hl, bc  ; check if we are out of the map
		jr c, pcg_generate_room__prettify_pyramid_rope_done
		add hl, bc
		ld a, (hl)
		cp 9*16 + 7  ; brick
		jr z, pcg_generate_room__prettify_pyramid_rope_done
		cp 9*16 + 8  ; brick
		jr z, pcg_generate_room__prettify_pyramid_rope_done
		cp 8*16+15  ; thin brick
		jr z, pcg_generate_room__prettify_pyramid_rope_done
		cp 8*16+14  ; thin brick
		jr z, pcg_generate_room__prettify_pyramid_rope_done
		cp 15*16+13  ; thin brick
		jr z, pcg_generate_room__prettify_pyramid_rope_done
		cp 8*16 + 7  ; top rope piece
		jr z, pcg_generate_room__prettify_pyramid_rope_done
pcg_generate_room__prettify_pyramid_rope_keep_going:
		PCG_PRETTIFY_RANDOM
		and #03
		jp nz, pcg_generate_room__prettify_pyramid_rope_keep_going2
		ld (hl), 8*16 + 3  ; rope knot
		jr pcg_generate_room__prettify_pyramid_rope_loop
pcg_generate_room__prettify_pyramid_rope_keep_going2:
		ld (hl), 8*16 + 6  ; rope
		jr pcg_generate_room__prettify_pyramid_rope_loop
pcg_generate_room__prettify_pyramid_rope_done:
	pop bc
	pop hl
	jp pcg_generate_room__prettify_pyramid_loop_x_continue

pcg_generate_room__prettify_pyramid_ladder:
	push hl
	push bc
		ld bc, current_room__tile_map
pcg_generate_room__prettify_pyramid_ladder_loop:
		or a
		sbc hl, de  ; go one row up
		or a
		sbc hl, bc  ; check if we are out of the map
		jr c, pcg_generate_room__prettify_pyramid_ladder_done
		add hl, bc
		ld a, (hl)
		or a
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 6*16 + 8  ; ladder top-left
		jr z, pcg_generate_room__prettify_pyramid_ladder_done
		cp 6*16 + 9  ; ladder top-right
		jr z, pcg_generate_room__prettify_pyramid_ladder_done
		cp 7*16 + 12  ; ladder top-left
		jr c, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 8*16 + 1  ; torch
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 8*16 + 2  ; background
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 9*16 + 5  ; background
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 10*16 + 0  ; background
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 10*16 + 6  ; background
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 11*16 + 12  ; background
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 12*16 + 0  ; background
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 12*16 + 8  ; background
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		cp 15*16 + 5  ; background
		jr z, pcg_generate_room__prettify_pyramid_ladder_keep_going
		and #f0
		cp #60  ; row 6 contains tiles only present on background tiles
		jr nz, pcg_generate_room__prettify_pyramid_ladder_done
pcg_generate_room__prettify_pyramid_ladder_keep_going:
		ld (hl), 15*16 + 8  ; ladder-left
		inc hl
		ld (hl), 10*16 + 7  ; ladder-right
		dec hl
		jr pcg_generate_room__prettify_pyramid_ladder_loop
pcg_generate_room__prettify_pyramid_ladder_done:
	pop bc
	pop hl
	jp pcg_generate_room__prettify_pyramid_loop_x_continue

pcg_generate_room__prettify_pyramid_face1:
	push hl
		inc hl
		ld (hl), 12*16 + 1
		inc hl
		ld (hl), 12*16 + 2
		add hl, de
		ld (hl), 13*16 + 2
		dec hl
		ld (hl), 13*16 + 1
		dec hl
		ld (hl), 13*16 + 0
		add hl, de
		ld (hl), 14*16 + 0
		inc hl
		ld (hl), 14*16 + 1
		inc hl
		ld (hl), 14*16 + 2
		add hl, de
		ld (hl), 15*16 + 2
		dec hl
		ld (hl), 15*16 + 1
		dec hl
		ld (hl), 15*16 + 0
	pop hl
	jp pcg_generate_room__prettify_pyramid_loop_x_continue

pcg_generate_room__prettify_pyramid_face2:
	push hl
		inc hl
		ld (hl), 12*16 + 9
		inc hl
		ld (hl), 12*16 + 10
		inc hl
		ld (hl), 12*16 + 11
		add hl, de
		ld (hl), 13*16 + 11
		dec hl
		ld (hl), 13*16 + 10
		dec hl
		ld (hl), 13*16 + 9
		dec hl
		ld (hl), 13*16 + 8
		add hl, de
		ld (hl), 14*16 + 8
		inc hl
		ld (hl), 14*16 + 9
		inc hl
		ld (hl), 14*16 + 10
		inc hl
		ld (hl), 14*16 + 11
	pop hl
	jp pcg_generate_room__prettify_pyramid_loop_x_continue

pcg_generate_room__prettify_pyramid_dragon_head:
	push hl
		inc hl
		ld (hl), 11*16 + 13
		inc hl
		ld (hl), 11*16 + 14
		inc hl
		ld (hl), 11*16 + 15
		add hl, de
		ld (hl), 12*16 + 15
		dec hl
		ld (hl), 12*16 + 14
		dec hl
		ld (hl), 12*16 + 13
		dec hl
		ld (hl), 12*16 + 12
		add hl, de
		ld (hl), 13*16 + 12
		inc hl
		ld (hl), 13*16 + 13
		inc hl
		ld (hl), 13*16 + 14
		inc hl
		ld (hl), 13*16 + 15
	pop hl
	jp pcg_generate_room__prettify_pyramid_loop_x_continue
