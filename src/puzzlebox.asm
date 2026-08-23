;-----------------------------------------------
; input:
; - ix: puzzlebox combination
display_puzzlebox_closeup:
	call disable_VDP_output
		push ix
		    call clear_all_the_sprites
			xor a
			ld hl, NAMTBL2
			ld bc, 768
			call fast_FILVRM

			ld hl, puzzlebox_tiles_zx0
			ld c, TILES_PUZZLEBOX_PAGE
			call decompress_tiles_to_all_banks

			ld hl, puzzlebox_nametable_zx0
			ld de, buffer_4096
			ld c, TILES_PUZZLEBOX_PAGE
			call dzx0_from_page_c

			; draw the background:
			ld hl, buffer_4096 + 420  ; 420 is the size of the puzzlebox name table (20*21)
			ld bc, 768 - 1
			call clear_memory

			ld b, 14
			ld hl, buffer_4096
			ld de, buffer_4096 + 420 + 6 + 2*32
display_puzzlebox_closeup_loop_y:
			push bc
				ld a, b
				cp 5
				jr nz, display_puzzlebox_closeup_loop_y_continue
				; skip two rows to make the box closed:
				ld bc, 40
				add hl, bc
display_puzzlebox_closeup_loop_y_continue:
				ld bc, 20
				ldir
				ex de, hl
				ld bc, 12
				add hl, bc
				ex de, hl
			pop bc

			djnz display_puzzlebox_closeup_loop_y
		pop ix

		; draw the combination of animals:
		ld de, buffer_4096 + 420 + 8 + 3*32
		ld a, (ix)
		call puzzlebox_display_animal_face
		ld de, buffer_4096 + 420 + 12 + 3*32
		ld a, (ix + 1)
		call puzzlebox_display_animal_face
		ld de, buffer_4096 + 420 + 16 + 3*32
		ld a, (ix + 2)
		call puzzlebox_display_animal_face
		ld de, buffer_4096 + 420 + 20 + 3*32
		ld a, (ix + 3)
		call puzzlebox_display_animal_face

		; draw the current number combination:
		ld hl, tmp_puzzlebox_state
		ld bc, 4 - 1
		call clear_memory
		call puzzlebox_display_number_state

		; copy to VDP:
		ld hl, buffer_4096 + 420
		ld de, NAMTBL2
		ld bc, 768
		call fast_LDIRVM

		call set_bitmap_name_table_bank3
		ld hl, CLRTBL2 + 256*8*2
		ld bc, 256*8
		xor a
		call fast_FILVRM

    call enable_VDP_output
    ; jp puzzlebox_state1


;-----------------------------------------------
puzzlebox_state1:
	ld hl, CLRTBL2 + 256*8*2
	ld bc, 256*8
	xor a
	call fast_FILVRM

    ld a, 4
    ld (tmp_puzzlebox_pointer), a
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_PUZZLEBOX_OPTION1, CHRTBL2 + 256*8*2 + (11 + 2*32)*8, #f0, 16
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_OPTIONS1, CHRTBL2 + 256*8*2 + (11 + 4*32)*8, #f0, 16
puzzlebox_state1_loop:
	halt
	call puzzlebox_draw_sprite
	call update_keyboard_buffers

	ld a, (keyboard_clicks)
	bit KEY_UP_BIT, a  ; up
	push af
		call nz, puzzlebox_state1_up
	pop af
	bit KEY_DOWN_BIT, a  ; down
	push af
		call nz, puzzlebox_state1_down
	pop af
	bit KEY_WEAPON_BIT, a  ; down
	jp nz, puzzlebox_state1_fire
	jr puzzlebox_state1_loop

puzzlebox_state1_up:
puzzlebox_state1_down:
	ld a, (tmp_puzzlebox_pointer)
	xor #01
	ld (tmp_puzzlebox_pointer), a

	ld hl, SFX_ui_move
	jp play_SFX_with_high_priority

puzzlebox_state1_fire:
	ld a, (tmp_puzzlebox_pointer)
	cp 4
	jr z, puzzlebox_state2

puzzlebox_return:
	xor a
	ld (keyboard_clicks), a

	ld hl, redraw_flags
	ld (hl), #ff
	ret


;-----------------------------------------------
puzzlebox_state2:
	ld hl, CLRTBL2 + 256*8*2
	ld bc, 256*8
	xor a
	call fast_FILVRM

    xor a
    ld (tmp_puzzlebox_pointer), a
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_PUZZLEBOX_INSTRUCTIONS, CHRTBL2 + 256*8*2 + (7 + 2*32)*8, #f0, 18
puzzlebox_state2_loop:
	call puzzlebox_draw_sprite
	call update_keyboard_buffers
	bit KEY_LEFT_BIT, a  ; up
	push af
		call nz, puzzlebox_state2_left
	pop af
	bit KEY_RIGHT_BIT, a  ; down
	push af
		call nz, puzzlebox_state2_right
	pop af
	bit KEY_UP_BIT, a  ; up
	push af
		call nz, puzzlebox_state2_up
	pop af
	bit KEY_DOWN_BIT, a  ; down
	push af
		call nz, puzzlebox_state2_down
	pop af
	bit KEY_WEAPON_BIT, a  ; down
	jp nz, puzzlebox_state2_fire
	jr puzzlebox_state2_loop

puzzlebox_state2_left:
	ld a, (tmp_puzzlebox_pointer)
	dec a
	and #03
	ld (tmp_puzzlebox_pointer), a

	ld hl, SFX_ui_move
	jp play_SFX_with_high_priority

puzzlebox_state2_right:
	ld a, (tmp_puzzlebox_pointer)
	inc a
	and #03
	ld (tmp_puzzlebox_pointer), a

	ld hl, SFX_ui_move
	jp play_SFX_with_high_priority

puzzlebox_state2_up:
	ld hl, tmp_puzzlebox_state
	ld a, (tmp_puzzlebox_pointer)
	ADD_HL_A
	ld a, (hl)
	inc a
puzzlebox_state2_up_continue:
	and #07
	ld (hl), a
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	call puzzlebox_display_number_state
	ld hl, buffer_4096 + 420
	ld de, NAMTBL2
	ld bc, 512
	jp fast_LDIRVM

puzzlebox_state2_down:
	ld hl, tmp_puzzlebox_state
	ld a, (tmp_puzzlebox_pointer)
	ADD_HL_A
	ld a, (hl)
	dec a
	jr puzzlebox_state2_up_continue

puzzlebox_state2_fire:
	; check if puzzle is solved:
	call puzzlebox_check_solution
	jr z, puzzlebox_state2_fire_solved
	; not solved!
	ld hl, SFX_ui_wrong
	call play_SFX_with_high_priority

	ld hl, CLRTBL2 + 256*8*2
	ld bc, 256*8
	xor a
	call fast_FILVRM

	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_PUZZLEBOX_FAILURE, CHRTBL2 + 256*8*2 + (11 + 2*32)*8, #f0, 10
	call wait_for_click
	jp puzzlebox_state1

puzzlebox_state2_fire_solved:
	ld hl, SFX_secret
	call play_SFX_with_high_priority

	call clear_all_the_sprites

	ld hl, CLRTBL2 + 256*8*2
	ld bc, 256*8
	xor a
	call fast_FILVRM

	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_PUZZLEBOX_SUCCESS, CHRTBL2 + 256*8*2 + (10 + 2*32)*8, #f0, 14
	call wait_for_click

	; open box:
	ld hl, buffer_4096 + 420 + 32
	ld de, buffer_4096 + 420
	ld bc, 32*10
	ldir
	ld hl, buffer_4096 + 10*20
	ld de, buffer_4096 + 420 + 10*32 + 6
	ld bc, 20
	ldir
	ld hl, buffer_4096 + 420
	ld de, NAMTBL2
	ld bc, 512
	call fast_LDIRVM
	ld hl, SFX_explosion
	call play_SFX_with_high_priority
	ld b, 30
	call wait_b_halts

	ld hl, buffer_4096 + 420 + 32
	ld de, buffer_4096 + 420
	ld bc, 32*10
	ldir
	ld hl, buffer_4096 + 9*20
	ld de, buffer_4096 + 420 + 9*32 + 6
	ld bc, 20
	ldir
	ld hl, buffer_4096 + 420
	ld de, NAMTBL2
	ld bc, 512
	call fast_LDIRVM
	ld hl, SFX_explosion
	call play_SFX_with_high_priority
	call wait_for_click

	; check if it's the first or second half stone:
	ld a, (player_inventory_items + INVENTORY_ITEM_HALF_POWER_STONE1)  ; do we have a half stone?
	or a
	jr nz, puzzlebox_state2_fire_solved_second
	ld a, (player_inventory_items + INVENTORY_ITEM_HALF_POWER_STONE2)  ; do we have a half stone?
	or a
	jr z, puzzlebox_state2_fire_solved_first
puzzlebox_state2_fire_solved_second:
	; second half stone:
	ld de, TEXT_FOUND_SECOND_HALF_POWER_STONE
	ld hl, display_in_game_message_internal
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	; drop puzzlebox, and half-power stones, and gain 6th power stone:
	xor a
	ld (player_inventory_items+INVENTORY_ITEM_HALF_POWER_STONE1), a
	ld (player_inventory_items+INVENTORY_ITEM_HALF_POWER_STONE2), a
	ld (player_inventory_items+INVENTORY_ITEM_PUZZLEBOX_MARS), a
	ld (player_inventory_items+INVENTORY_ITEM_PUZZLEBOX_MOON), a
	inc a
	ld (player_inventory_items + INVENTORY_ITEM_POWER_STONE1 + 5), a  ; sixth stone
	jp puzzlebox_return

puzzlebox_state2_fire_solved_first:
	; first half stone:
	; drop puzzlebox, and gain half-power stone:
	push ix
		ld de, TEXT_FOUND_HALF_POWER_STONE
		ld hl, display_in_game_message_internal
		ld c, TEXT_PAGE
		call call_hl_in_page_c_8000
	pop hl
	ld bc, -current_world__maya_puzzle2_combination1
	add hl, bc
	ld a, l
	or a
	jr z, puzzlebox_state2_fire_solved_first_mars
	; moon:
	xor a
	ld (player_inventory_items+INVENTORY_ITEM_PUZZLEBOX_MOON), a
	inc a
	ld (player_inventory_items+INVENTORY_ITEM_HALF_POWER_STONE2), a	
	jr puzzlebox_state2_fire_solved_first_continue
puzzlebox_state2_fire_solved_first_mars:
	xor a
	ld (player_inventory_items + INVENTORY_ITEM_PUZZLEBOX_MARS), a
	inc a
	ld (player_inventory_items + INVENTORY_ITEM_HALF_POWER_STONE1), a	
puzzlebox_state2_fire_solved_first_continue:
	jp puzzlebox_return



;-----------------------------------------------
puzzlebox_check_solution:
	ld hl, tmp_puzzlebox_state
	push ix
	pop de  ; combination
	ld b, 4
puzzlebox_check_solution_loop:
	push bc
		ld a, (de)  ; animal in this position
		inc de
		push hl
			ld hl, current_world__power_stone_numbers
			ADD_HL_A
			ld a, (hl)
		pop hl
		dec a  ; target for this position
		cp (hl)
		jr nz, puzzlebox_check_solution_fail
		inc hl
	pop bc
	djnz puzzlebox_check_solution_loop
	; success!
	xor a
	ret

puzzlebox_check_solution_fail:
	pop bc
	or 1
	ret


;-----------------------------------------------
; tmp_puzzlebox_pointer:
; - 0, 1, 2, 3: numbers
; - 4: option 1
; - 5: option 2
puzzlebox_draw_sprite:
	ld a, (interrupt_cycle)
	bit 4, a
	jr z, puzzlebox_draw_sprite_clear
	ld hl, buffer_4096 + 420 + 768
	ld a, (tmp_puzzlebox_pointer)
	cp 4
	jr z, puzzlebox_draw_sprite_option1
	cp 5
	jr z, puzzlebox_draw_sprite_option2

	add a, a
	add a, a
	add a, a
	add a, a
	cp 32
	jr c, puzzlebox_draw_sprite_no_correction
	add a, 8
puzzlebox_draw_sprite_no_correction:
	add a, 92
	ld (hl), 74
	inc hl
	ld (hl), a
	inc hl
	ld (hl), 7*4
	inc hl
	ld (hl), COLOR_WHITE
	jr puzzlebox_draw_sprite_continue

puzzlebox_draw_sprite_option1:
	ld (hl), 144
	inc hl
	ld (hl), 72
	inc hl
	ld (hl), 9*4
	inc hl
	ld (hl), COLOR_WHITE
	jr puzzlebox_draw_sprite_continue

puzzlebox_draw_sprite_option2:
	ld (hl), 160
	inc hl
	ld (hl), 72
	inc hl
	ld (hl), 9*4
	inc hl
	ld (hl), COLOR_WHITE
	; jr puzzlebox_draw_sprite_continue

puzzlebox_draw_sprite_continue:
	ld hl, buffer_4096 + 420 + 768
	ld de, SPRATR2
	ld b, 4
	jp fast_small_LDIRVM

puzzlebox_draw_sprite_clear:
	ld hl, SPRATR2
	xor a
	ld b, 4
	jp fast_small_FILVRM


;-----------------------------------------------
; input:
; - de: name table ptr
; - a: face to draw
puzzlebox_display_animal_face:
	ld hl, buffer_4096 + 16*20
	add a, a
	add a, a
	ADD_HL_A
	ld b, 3
puzzlebox_display_animal_face_loop:
	push bc
		ld bc, 4
		ldir
		ld bc, 16
		add hl, bc
		ex de, hl
		ld bc, 28
		add hl, bc
		ex de, hl
	pop bc
	djnz puzzlebox_display_animal_face_loop
	ret


;-----------------------------------------------
puzzlebox_display_number_state:
	ld de, buffer_4096 + 420 + 12 + 7*32
	ld a, (tmp_puzzlebox_state)
	call puzzlebox_display_number_state_one_number
	ld de, buffer_4096 + 420 + 14 + 7*32
	ld a, (tmp_puzzlebox_state + 1)
	call puzzlebox_display_number_state_one_number
	ld de, buffer_4096 + 420 + 17 + 7*32
	ld a, (tmp_puzzlebox_state + 2)
	call puzzlebox_display_number_state_one_number
	ld de, buffer_4096 + 420 + 19 + 7*32
	ld a, (tmp_puzzlebox_state + 3)
	; jp puzzlebox_display_number_state_one_number

puzzlebox_display_number_state_one_number:
	ld hl, buffer_4096 + 19*20
	ADD_HL_A
	ldi
	ld bc, 19
	add hl, bc
	ex de, hl
	ld bc, 31
	add hl, bc
	ex de, hl
	ldi
	ret


