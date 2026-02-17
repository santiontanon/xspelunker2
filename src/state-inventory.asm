;-----------------------------------------------
state_inventory_from_quit:
	ld a, 7
	ld (inventory_cursor_position_x), a
	jr state_inventory_entry_point


;-----------------------------------------------
state_game_over_from_quit:
	ld hl, state_game_over
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
state_inventory_from_options:
	ld a, 4
	ld (inventory_cursor_position_x), a
	jr state_inventory_entry_point


;-----------------------------------------------
state_inventory:
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority

	; reset sprites:
	ld hl, sprite_attribute_table
	ld bc, MAX_SPRITES * 4 + 3 - 1
	call clear_memory

	xor a
	ld (inventory_cursor_position_x), a
state_inventory_entry_point:
	xor a
	ld (inventory_cursor_position_y), a
state_inventory_entry_point_from_item_inspection:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want
	call disable_VDP_output
		call clear_all_the_sprites
		call setup_inventory_gfx
		call draw_inventory_items_weapons
		call draw_inventory_weapon_bullets
		call draw_inventory_player_health
		ld a, (player_inventory_coins)
		ld de, CHRTBL2 + (2*32+19)*8
		ld iy, #8000 + COLOR_WHITE*16
		ld b, 3
		call draw_inventory_number
		call draw_inventory_map
		call draw_inventory_player
		call draw_inventory_cursor
	call enable_VDP_output

state_inventory_loop:
	call state_play__update_time  ; updates how long has the player been playing
	halt
	call draw_inventory_player
	call draw_inventory_cursor
	call draw_inventory_selected_item_highlight
	call update_keyboard_buffers
	call state_inventory_update_cursor
	jr state_inventory_loop


;-----------------------------------------------
state_inventory_update_cursor:
	ld hl, (inventory_cursor_position_x)
	push hl
		ld a, (keyboard_clicks)
		bit KEY_RIGHT_BIT, a  ; right
		push af
			call nz, state_inventory_update_cursor_right
		pop af
		bit KEY_DOWN_BIT, a  ; down
		push af
			call nz, state_inventory_update_cursor_down
		pop af
		bit KEY_UP_BIT, a  ; up
		push af
			call nz, state_inventory_update_cursor_up
		pop af
		bit KEY_LEFT_BIT, a  ; left
		push af
			call nz, state_inventory_update_cursor_left
		pop af
	pop hl
	; see if cursor has moved:
	ld bc, (inventory_cursor_position_x)
	or a
	sbc hl, bc
	ld a, h
	or l
	jr z, state_inventory_update_cursor_continue
	; cursor moved to a new position:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	; see if we need to draw text:
	call state_inventory_update_item_text
state_inventory_update_cursor_continue:

	ld a, (keyboard_clicks)
	bit KEY_WEAPON_BIT, a  ; space
	jp nz, state_inventory_update_cursor_button
	bit KEY_INTERACT_BIT, a  ; interact
	jp nz, state_inventory_update_cursor_interact
	bit KEY_INVENTORY_BIT, a
	jp nz, state_inventory_update_cursor_button_back
	ret

state_inventory_update_cursor_interact:
	; interact with items:
	call state_inventory_item_under_cursor
	ret z
	ld l, (iy + 12)
	ld h, (iy + 13)
	ld a, l
	or h
	ret z  ; no interact function
	jp (hl)


state_inventory_update_cursor_button:
	ld a, (inventory_cursor_position_y)
	or a
	jr z, state_inventory_update_cursor_button_row0

	call state_inventory_item_under_cursor
	ret z

	ld a, (iy + 3)  ; selectable?
	or a
	ret z

	ld a, (iy)
	ld (player_current_item), a
	ld hl, SFX_ui_select
	jp play_SFX_with_high_priority	


state_inventory_update_cursor_button_row0:
	ld a, (inventory_cursor_position_x)
	or a
	jr z, state_inventory_update_cursor_button_back
	cp 4
	jr z, state_inventory_update_cursor_button_options
state_inventory_update_cursor_button_quit:
	ld ix, TEXT_ARE_YOU_SURE
	ld hl, state_game_over_from_quit  ; yes
	ld de, state_inventory_from_quit  ; no
	jp state_yesno_dialog

state_inventory_update_cursor_button_back:
	call disable_VDP_output
	call clear_all_the_sprites
	jp state_play_from_inventory

state_inventory_update_cursor_button_options:
	xor a
	ld (options_called_from), a
	jp state_options


state_inventory_update_cursor_right:
	ld a, (inventory_cursor_position_y)
	or a
	jr z, state_inventory_update_cursor_right_row0
	ld a, (inventory_cursor_position_x)
	cp 9
	ret z
	inc a
	ld (inventory_cursor_position_x), a
	ret

state_inventory_update_cursor_right_row0:
	ld a, (inventory_cursor_position_x)
	or a
	jr z, state_inventory_update_cursor_right_row0_0
	cp 4
	jr z, state_inventory_update_cursor_right_row0_4
	; right-most button:
	ret
state_inventory_update_cursor_right_row0_4:
	ld a, 7
	ld (inventory_cursor_position_x), a
	ret

state_inventory_update_cursor_right_row0_0:
	ld a, 4
	ld (inventory_cursor_position_x), a
	ret


state_inventory_update_cursor_left:
	ld a, (inventory_cursor_position_y)
	or a
	jr z, state_inventory_update_cursor_left_row0
	cp 2
	jr z, state_inventory_update_cursor_left_wide
	cp 3
	jr z, state_inventory_update_cursor_left_wide
	ld a, (inventory_cursor_position_x)
	cp 4
	ret z
	dec a
	ld (inventory_cursor_position_x), a
	ret
state_inventory_update_cursor_left_wide:
	ld a, (inventory_cursor_position_x)
	or a
	ret z
	dec a
	ld (inventory_cursor_position_x), a
	ret


state_inventory_update_cursor_left_row0:
	ld a, (inventory_cursor_position_x)
	or a
	ret z
	cp 4
	jr z, state_inventory_update_cursor_left_row0_4
	; right-most button:
	ld a, 4
	ld (inventory_cursor_position_x), a
	ret
state_inventory_update_cursor_left_row0_4:
	xor a
	ld (inventory_cursor_position_x), a
	ret


state_inventory_update_cursor_down:
	ld a, (inventory_cursor_position_y)
	cp 5
	ret z  ; bottom of the screen
	or a
	jr z, state_inventory_update_cursor_down_row0
	cp 3
	jr z, state_inventory_update_cursor_down_row3
	inc a
	ld (inventory_cursor_position_y), a
	ret
state_inventory_update_cursor_down_row0:
	ld a, (inventory_cursor_position_x)
	cp 4
	jr c, state_inventory_update_cursor_down_row0_left
	ld a, 1
	ld (inventory_cursor_position_y), a
	ret
state_inventory_update_cursor_down_row0_left:
	xor a
	ld (inventory_cursor_position_x), a
	ld a, 2
	ld (inventory_cursor_position_y), a
	ret
state_inventory_update_cursor_down_row3:
	ld a, (inventory_cursor_position_x)
	cp 4
	ret c
	ld a, 4
	ld (inventory_cursor_position_y), a
	ret


state_inventory_update_cursor_up:
	ld a, (inventory_cursor_position_y)
	or a
	ret z
	cp 1
	jr z, state_inventory_update_cursor_up_row1
	cp 2
	jr z, state_inventory_update_cursor_up_row2
	dec a
	ld (inventory_cursor_position_y), a
	ret
state_inventory_update_cursor_up_row1:
	ld a, (inventory_cursor_position_x)
	cp 7
	jr c, state_inventory_update_cursor_up_row1_middle
	ld a, 7
	ld (inventory_cursor_position_x), a
	xor a
	ld (inventory_cursor_position_y), a
	ret
state_inventory_update_cursor_up_row1_middle:
	ld a, 4
	ld (inventory_cursor_position_x), a
	xor a
	ld (inventory_cursor_position_y), a
	ret
state_inventory_update_cursor_up_row2:
	ld a, (inventory_cursor_position_x)
	cp 4
	jr c, state_inventory_update_cursor_up_row2_left
	ld a, (inventory_cursor_position_y)
	dec a
	ld (inventory_cursor_position_y), a
	ret
state_inventory_update_cursor_up_row2_left:
	xor a
	ld (inventory_cursor_position_x), a
	ld (inventory_cursor_position_y), a
	ret


;-----------------------------------------------
; output:
; - z: no item underneath
; - nz: item underneath
; - iy: ptr to item (if nz)
state_inventory_item_under_cursor:
	ld a, (inventory_cursor_position_y)
	ld b, a
	ld a, (inventory_cursor_position_x)
	ld c, a
	; pressed over an item/weapon:
	ld ix, inventory_table
	ld iy, 0
state_inventory_item_under_cursor_loop:
	ld a, (ix)
	cp #ff  ; sentinel
	jr z, state_inventory_item_under_cursor_loop_done
	ld hl, player_inventory_weapons
	ADD_HL_A
	ld a, (hl)
	or a
	jr z, state_inventory_item_under_cursor_loop_next
; 	ld a, (ix + 3)  ; selectable?
; 	or a
; 	jr z, state_inventory_item_under_cursor_loop_next
	ld a, (ix + 1)
	cp c
	jr nz, state_inventory_item_under_cursor_loop_next
	ld a, (ix + 2)
	cp b
	jr nz, state_inventory_item_under_cursor_loop_next
	push ix
	pop iy
state_inventory_item_under_cursor_loop_next:
	ld de, 14
	add ix, de
	jr state_inventory_item_under_cursor_loop
state_inventory_item_under_cursor_loop_done:
	ld a, iyl
	or iyh
	ret


;-----------------------------------------------
state_inventory_update_cursor_interact_power_stone1:
	ld a, (player_inventory_items + INVENTORY_ITEM_POWER_STONE1)
	or a
	ld e, 0
	jr nz, state_inventory_update_cursor_interact_power_stone
	ret
state_inventory_update_cursor_interact_power_stone2:
	ld a, (player_inventory_items + INVENTORY_ITEM_POWER_STONE1 + 1)
	or a
	ld e, 1
	jr nz, state_inventory_update_cursor_interact_power_stone
	ret
state_inventory_update_cursor_interact_power_stone3:
	ld a, (player_inventory_items + INVENTORY_ITEM_POWER_STONE1 + 2)
	or a
	ld e, 2
	jr nz, state_inventory_update_cursor_interact_power_stone
	ret
state_inventory_update_cursor_interact_power_stone4:
	ld a, (player_inventory_items + INVENTORY_ITEM_POWER_STONE1 + 3)
	or a
	ld e, 3
	jr nz, state_inventory_update_cursor_interact_power_stone
	ret
state_inventory_update_cursor_interact_power_stone5:
	ld a, (player_inventory_items + INVENTORY_ITEM_POWER_STONE1 + 4)
	or a
	ld e, 4
	jr nz, state_inventory_update_cursor_interact_power_stone
	ret
state_inventory_update_cursor_interact_power_stone6:
	ld a, (player_inventory_items + INVENTORY_ITEM_POWER_STONE1 + 5)
	or a
	ld e, 5
	ret z
state_inventory_update_cursor_interact_power_stone:
	ld ix, TEXT_INSPECT_POWER_STONE
	call display_power_stone_closeup
	jp state_inventory_entry_point_from_item_inspection


; ;-----------------------------------------------
state_inventory_update_cursor_interact_puzzlebox1:
	ld ix, current_world__maya_puzzle2_combination1
	ld hl, display_puzzlebox_closeup
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	jp state_inventory_entry_point_from_item_inspection

state_inventory_update_cursor_interact_puzzlebox2:
	ld ix, current_world__maya_puzzle2_combination2
	ld hl, display_puzzlebox_closeup
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	jp state_inventory_entry_point_from_item_inspection


;-----------------------------------------------
; input:
; - ix: message to display
; - e: power stone number
display_power_stone_closeup:
	call disable_VDP_output
		push ix
			push de
			    call clear_all_the_sprites
				xor a
				ld hl, NAMTBL2
				ld bc, 768
				call fast_FILVRM

				ld hl, power_stones_tiles_zx0
				ld c, MAP_PAGE
				call decompress_tiles_to_all_banks

				ld hl, power_stones_nametable_zx0
				ld de, buffer_4096
				ld c, MAP_PAGE
				call dzx0_from_page_c
			pop de  ; e = power stone number

			; draw the appropriate number
			ld a, e
			cp 5
			jr nc, display_power_stone_closeup_no_number
			ld d, 0
			ld hl, current_world__power_stone_numbers
			add hl, de
			ld a, (hl)
			add a, 118
			ld (buffer_4096 + 13 + 14*32), a
display_power_stone_closeup_no_number:

			; draw appropriate animal:
			; start tile = 128 + e * 3 (if e < 5), and 176 + (e-5) * 3 otherwise
			ld a, e
			cp 5
			jr c, display_power_stone_closeup_leq5
			sub 5
			ld c, a
			add a, a
			add a, c
			add a, 176
			jr display_power_stone_closeup_continue
display_power_stone_closeup_leq5:
			ld c, a
			add a, a
			add a, c
			add a, 128
display_power_stone_closeup_continue:
			ld hl, buffer_4096 + 15 + 9*32
			ld de, 30
			ld b, 3
display_power_stone_closeup_animal_loop:
			ld (hl), a
			inc a
			inc hl
			ld (hl), a
			inc a
			inc hl
			ld (hl), a
			add a, 14
			add hl, de
			djnz display_power_stone_closeup_animal_loop

			ld hl, buffer_4096
			ld de, NAMTBL2
			ld bc, 768
			call fast_LDIRVM
		pop hl
		ld de, CHRTBL2 + (225 + 256*2)*8
		ld iy, #80f0
		ld b, 30
		call draw_sentence_to_vdp_clearing_text_buffer
    call enable_VDP_output

	call wait_for_click
	xor a
	ld (keyboard_clicks), a

	ld hl, redraw_flags
	ld (hl), #ff
	ret


;-----------------------------------------------
state_inventory_update_cursor_interact_letter1:
	ld hl, display_elaine_letter1
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	jp state_inventory_entry_point_from_item_inspection


;-----------------------------------------------
state_inventory_update_cursor_interact_letter2:
	ld hl, display_elaine_letter2
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	jp state_inventory_entry_point_from_item_inspection


;-----------------------------------------------
state_inventory_update_cursor_interact_map:
	ld hl, display_map_closeup
	ld c, MAP_PAGE
	call call_hl_in_page_c_8000
	jp state_inventory_entry_point_from_item_inspection


;-----------------------------------------------
state_inventory_update_item_text:
	call state_inventory_update_item_text_clear_text
	ld a, (inventory_cursor_position_y)
	or a
	ret z
	ld b, a
	ld a, (inventory_cursor_position_x)
	ld c, a

	ld ix, inventory_table
	ld iy, 0
state_inventory_update_item_text_loop:
	ld a, (ix)
	cp #ff  ; sentinel
	jr z, state_inventory_update_item_text_loop_done
	ld hl, player_inventory_weapons
	ADD_HL_A
	ld a, (hl)
	or a
	jr z, state_inventory_update_item_text_loop_next
	ld a, (ix + 1)
	cp c
	jr nz, state_inventory_update_item_text_loop_next
	ld a, (ix + 2)
	cp b
	jr nz, state_inventory_update_item_text_loop_next
	push ix
	pop iy
state_inventory_update_item_text_loop_next:
	ld de, 14
	add ix, de
	jr state_inventory_update_item_text_loop
state_inventory_update_item_text_loop_done:
	ld a, iyl
	or iyh
	ret z
	; found a match, write:
	ld l, (iy + 10)
	ld h, (iy + 11)

state_inventory_update_item_text_print:
	; hl = text to print, copy it to buffer_4096
	ld de, buffer_4096
	ld a, (hl)
	add a, 2
	ld c, a
	ld b, 0
	ldir
    ld de, CHRTBL2 + 2*8*256 + (3*32+15)*8
state_inventory_update_item_text_print_loop:
    ld hl, buffer_4096
    push de
    push hl
		ld iyl, 17*8  ; 17 = inventory space for text
	    call max_length_of_sentence_in_one_line
    pop hl
	pop de    
    ; limit the sentence to that width and draw it:
    ld c, (hl)   ; we save the old length
    ld (hl), a
    push bc
    push hl
        ; draw the first part of the sentence:
        ld iy, #80f0
        ld b, 17
        push de
			call draw_sentence_to_vdp_clearing_text_buffer
		pop de
    pop hl
    pop bc
    ld a, c
    sub (hl)  ; length left
    ret z  ; if we have drawn the whole sentence, we are done
    push de
	    ld c, (hl)  ; c: length of the segment we just drew, 
	    ld e, a  ; e: remaining length
	    ld (hl), e
	    push bc
	        ld b, 0
	        add hl, bc  ; we advance hl to the remainder of the sentence
	        inc hl  ; skip the space we were splitting on
	        ld c, e  ; move the sentence to the left
	        ld de, buffer_4096 + 1
	        ldir
	    pop bc
	pop hl
	; next line:
	ld de, 32*8
	add hl, de
	ex de, hl
    jr state_inventory_update_item_text_print_loop

state_inventory_update_item_text_clear_text:
	ld b, 5  ; 5 lines
	ld hl, CHRTBL2 + 2*8*256 + (3*32+15)*8
state_inventory_update_item_text_clear_text_loop:
	push bc
	push hl
		ld bc, 17*8
		xor a
		call fast_FILVRM
	pop hl
	pop bc
	ld de, 8*32
	add hl, de
	djnz state_inventory_update_item_text_clear_text_loop
	ret


;-----------------------------------------------
draw_inventory_player:
	ld a, (interrupt_cycle)
	bit 4, a
	jr z, draw_inventory_player_frame2
	ld hl, player_sprites_bin + 64
	jr draw_inventory_player_frame_set
draw_inventory_player_frame2:
	ld hl, player_sprites_bin
draw_inventory_player_frame_set:
	ld de, SPRTBL2
	ld bc, 64
	call fast_LDIRVM_from_sprites_page

	; upload sprite attributes:
	ld hl, buffer_4096
	ld (hl), 23
	inc hl
	ld (hl), 8
	inc hl
	ld (hl), 0  ; sprite number
	inc hl
	ld (hl), COLOR_DARK_YELLOW
	inc hl
	ld (hl), 23
	inc hl
	ld (hl), 8
	inc hl
	ld (hl), 4  ; sprite number
	inc hl
	ld (hl), COLOR_DARK_RED
	inc hl
	ld hl, buffer_4096
	ld de, SPRATR2
	ld b, 8
	jp fast_small_LDIRVM


;-----------------------------------------------
draw_inventory_cursor_offsets:
	db 0, 0, 0, 1, 2, 2, 2, 1
draw_inventory_cursor:
	; base position: x: c, e, y: b
	ld a, (inventory_cursor_position_y)
	or a
	jr z, draw_inventory_cursor_row0
	; other rows:
	; x = 4 + (inventory_cursor_position_x) * 24
	; y = 7 + (inventory_cursor_position_y) * 24
	add a, a
	add a, a
	add a, a
	ld b, a
	add a, a
	add a, b
	add a, 7
	ld b, a  ; y
	ld a, (inventory_cursor_position_x)
	add a, a
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	add a, 4
	ld c, a
	ld a, (inventory_cursor_position_x)
	cp 4
	jr c, draw_inventory_cursor_continue
	ld a, c
	add a, 8
	ld c, a
draw_inventory_cursor_continue:
	ld a, c
	add a, 20
	ld e, a
	jp draw_inventory_cursor_coordinates_set
draw_inventory_cursor_row0:
	ld b, 3
	ld a, (inventory_cursor_position_x)
	or a
	jr z, draw_inventory_cursor_row0_0
	cp 4
	jr z, draw_inventory_cursor_row0_4
	; right most:
	ld c, 171
	ld e, 209
	jr draw_inventory_cursor_coordinates_set
draw_inventory_cursor_row0_0:
	ld c, 43
	ld e, 81
	jr draw_inventory_cursor_coordinates_set
draw_inventory_cursor_row0_4:
	ld c, 107
	ld e, 145

draw_inventory_cursor_coordinates_set:
	ld a, (interrupt_cycle)
	rrca
	and #07
	ld hl, draw_inventory_cursor_offsets
	ADD_HL_A
	ld a, c
	sub (hl)
	ld c, a  ; x1
	ld a, e
	add a, (hl)
	ld e, a  ; x2

	ld hl, buffer_4096
	ld (hl), b
	inc hl
	ld (hl), c
	inc hl
	ld (hl), 8  ; sprite number
	inc hl
	ld (hl), COLOR_WHITE
	inc hl
	ld (hl), b
	inc hl
	ld (hl), e
	inc hl
	ld (hl), 12  ; sprite number
	inc hl
	ld (hl), COLOR_WHITE
	inc hl
	ld hl, buffer_4096
	ld de, SPRATR2 + 2*4
	ld b, 8
	jp fast_small_LDIRVM


;-----------------------------------------------
draw_inventory_player_health:
	ld a, (player_max_health)
	rrca
	rrca
	and #3f
	ld b, a  ; number of hearts to display
	ld a, (player_health)
	ld c, a  ; remaining health to display
	ld hl, NAMTBL2 + 3*32+3
draw_inventory_player_health_loop:
	ld e, 4
	ld a, c
	cp 4
	jr nc, draw_inventory_player_health_loop_continue
	ld e, a
draw_inventory_player_health_loop_continue:
	ld a, c
	sub e
	ld c, a
	push bc
	push de
	push hl
		ld a, e
		add a, 19  ; first heart tile
		call WRTVRM
	pop hl		
	pop de
	pop bc
	inc hl
	djnz draw_inventory_player_health_loop
	ret


;-----------------------------------------------
draw_inventory_small_keys:
	ld a, (player_inventory_n_small_keys)
	or a
	ret z

	ld de, CHRTBL2 + (256 + 171)*8
	ld iy, #0800 + COLOR_GREY*16
	ld b, 1
	jp draw_inventory_number


;-----------------------------------------------
draw_inventory_items_weapons:
	ld ix, inventory_table
draw_inventory_items_weapons_loop:
	ld a, (ix)
	cp #ff  ; sentinel
	ret z
	ld hl, player_inventory_weapons
	ADD_HL_A
	ld a, (hl)
	or a
	jr z, draw_inventory_items_weapons_loop_next
	; draw weapon/item:
	; draw ptr (name table) is: NAMTBL2 + (1 + y*3) * 32 + (1 + x*3) [+1 if x >= 4]
	ld a, (ix + 1)  ; x
	add a, a
	cp 8
	jr c, draw_inventory_items_weapons_loop_continue
	inc a
draw_inventory_items_weapons_loop_continue:
	add a, (ix + 1)
	inc a
	ld e, a
	ld d, 0
	ld a, (ix + 2)  ; y
	add a, a
	add a, (ix + 2)  ; * 3
	inc a
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl
	add hl, hl  ; * 32
	add hl, de
	ld de, NAMTBL2
	add hl, de
	ex hl, de
	push ix
	pop hl
	inc hl
	inc hl
	inc hl
	inc hl
	push hl
		push de
			ld b, 2
			call fast_small_LDIRVM
		pop hl
		ld bc, 32
		add hl, bc
		ex de, hl
	pop hl
	inc hl
	inc hl
	ld b, 2
	call fast_small_LDIRVM

	ld l, (ix + 8)
	ld h, (ix + 9)
	ld a, l
	or h
	call nz, jp_to_hl
draw_inventory_items_weapons_loop_next:
	ld de, 14
	add ix, de
	jr draw_inventory_items_weapons_loop


;-----------------------------------------------
draw_inventory_selected_item_highlight:
	ld a, (interrupt_cycle)
	bit 4, a
	jr z, draw_inventory_selected_item_highlight_erase
	ld a, (player_current_item)
	; a * 14:
	ld c, a
	ld b, 0
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	add hl, hl
	or a
	sbc hl, bc  ; a * 7
	add hl, hl
	ld bc, inventory_table
	add hl, bc
	push hl
	pop ix

	; items: (sprite 28)
	; x = 8 + x*24  (+8 if x >= 4)
	; y = 23 + y*24
	; weapons:
	; y = 71 (sprite 28), or y = 72 (sprite 32)
	ld iy, buffer_4096
	; compute sprite x:
	ld c, 8
	ld a, (ix + 1)  ; x
	cp 4
	jr c, draw_inventory_selected_item_highlight_continue
	ld c, 16
draw_inventory_selected_item_highlight_continue:
	add a, a
	add a, a
	add a, a
	ld d, a
	add a, a
	add a, d
	add a, c
	ld (iy + 1), a  ; x = 8 + x*24  (+8 if x >= 4)

	ld a, (ix + 3)  ; highlight type
	dec a
	jr z, draw_inventory_selected_item_highlight_weapon1
	dec a
	jr z, draw_inventory_selected_item_highlight_weapon2
draw_inventory_selected_item_highlight_item:
	ld (iy + 2), 28
	ld b, 23
	ld a, (ix + 2)  ; y
	add a, a
	add a, a
	add a, a
	ld d, a
	add a, a
	add a, d
	add a, b
	ld (iy + 0), a  ; y = 23 + y*24
	jr draw_inventory_selected_item_highlight_continue2
draw_inventory_selected_item_highlight_weapon1:
	ld (iy + 0), 71
	ld (iy + 2), 28
	jr draw_inventory_selected_item_highlight_continue2
draw_inventory_selected_item_highlight_weapon2:
	ld (iy + 0), 72
	ld (iy + 2), 32
draw_inventory_selected_item_highlight_continue2:
	ld (iy + 3), COLOR_WHITE

	ld hl, buffer_4096
	ld de, SPRATR2 + 7*4
	ld b, 4
	jp fast_small_LDIRVM
draw_inventory_selected_item_highlight_erase:
	ld hl, SPRATR2 + 7*4
	xor a
	ld bc, 4
	jp fast_FILVRM


draw_inventory_weapon_bullets:
	; weapon bullets:
	ld a, (player_inventory_weapon_ammo)
	ld de, CHRTBL2 + (256 + 16)*8
	ld iy, #0800 + COLOR_BLUE*16
	ld b, 2
	call draw_inventory_number

	ld a, (player_inventory_weapon_ammo + 1)
	ld de, CHRTBL2 + (256 + 18)*8
	ld iy, #0800 + COLOR_BLUE*16
	ld b, 2
	call draw_inventory_number

	ld a, (player_inventory_weapon_ammo + 2)
	ld de, CHRTBL2 + (256 + 20)*8
	ld iy, #0800 + COLOR_BLUE*16
	ld b, 2
	call draw_inventory_number

	ld a, (player_inventory_weapon_ammo + 3)
	ld de, CHRTBL2 + (256 + 22)*8
	ld iy, #0800 + COLOR_BLUE*16
	ld b, 2
	jp draw_inventory_number


draw_inventory_weapons_hammer_sprite:
	ld hl, buffer_4096
	ld (hl), 7*8 - 1
	inc hl
	ld (hl), 4*8
	inc hl
	ld (hl), 16  ; sprite number
	inc hl
	ld (hl), COLOR_GREY
	ld hl, buffer_4096
	ld de, SPRATR2 + 4*4
	ld b, 4
	jp fast_small_LDIRVM

draw_inventory_weapons_ice_macuahuitl_sprite:
draw_inventory_weapons_macuahuitl_sprite:
	ld hl, buffer_4096
	ld (hl), 7*8 - 1
	inc hl
	ld (hl), 7*8
	inc hl
	ld (hl), 20  ; sprite number
	inc hl
	ld (hl), COLOR_DARK_BLUE
	ld hl, buffer_4096
	ld de, SPRATR2 + 5*4
	ld b, 4
	jp fast_small_LDIRVM

draw_inventory_weapons_blowgun_sprite:
	ld hl, buffer_4096
	ld (hl), 10*8 - 1
	inc hl
	ld (hl), 4*8
	inc hl
	ld (hl), 24  ; sprite number
	inc hl
	ld (hl), COLOR_LIGHT_RED
	ld hl, buffer_4096
	ld de, SPRATR2 + 6*4
	ld b, 4
	jp fast_small_LDIRVM

draw_inventory_weapons_fire_hammer_sprite:
	ld hl, buffer_4096
	ld (hl), 7*8 - 1
	inc hl
	ld (hl), 4*8
	inc hl
	ld (hl), 16  ; sprite number
	inc hl
	ld (hl), COLOR_RED
	ld hl, buffer_4096
	ld de, SPRATR2 + 4*4
	ld b, 4
	jp fast_small_LDIRVM


;-----------------------------------------------
; input:
; - a: number
; - b: width in tiles to use
; - de: VRAM address to draw to (CHRTBL2)
; - iyl: color (attribute byte)
; - iyh: pixel to start from (128 to start in pixel 0)
draw_inventory_number_ixl:
	ld a, ixl
draw_inventory_number:
	push de
	push bc
		ld de, buffer_4096 + 1
		ld c, 0  ; number of characters

		ld b, 0  ; hundreds digit
draw_inventory_number_hundreds_loop:
		cp 100
		jr c, draw_inventory_number_hundreds_loop_done
		sub 100
		inc b
		jp draw_inventory_number_hundreds_loop
draw_inventory_number_hundreds_loop_done:	
		push af
			ld a, b
			or a
			jr z, draw_inventory_number_hundreds_done
			ld hl, text_numbers
			ADD_HL_A
			ld a, (hl)
			ld (de), a
			inc de
			inc c  ; number of digits
draw_inventory_number_hundreds_done:
		pop af

		ld b, 0  ; tens digit
draw_inventory_number_tens_loop:
		cp 10
		jr c, draw_inventory_number_tens_loop_done
		sub 10
		inc b
		jp draw_inventory_number_tens_loop
draw_inventory_number_tens_loop_done:	
		push af
			ld a, c  ; number of digits
			or a
			jr nz, draw_inventory_number_tens_draw
			ld a, b
			or a
			jr z, draw_inventory_number_tens_done
draw_inventory_number_tens_draw:
			ld a, b
			ld hl, text_numbers
			ADD_HL_A
			ld a, (hl)
			ld (de), a
			inc de
			inc c  ; number of digits
draw_inventory_number_tens_done:
		pop af

		ld hl, text_numbers
		ADD_HL_A
		ld a, (hl)
		ld (de), a
		inc de
		xor a
		ld (de), a
		inc c  ; number of digits

		ld hl, buffer_4096
		ld (hl), c
	pop bc
	pop de
	jp draw_sentence_to_vdp_clearing_text_buffer


;-----------------------------------------------
draw_inventory_map:
	ld hl, draw_inventory_map_to_piece_table
	ld a, (current_area__id)
	ADD_HL_A
	ld a, (hl)
	cp #ff
	jr z, draw_inventory_map_have_map
	ld hl, global_state__objects + TAG_MAP_PIECE1
	ADD_HL_A
	ld a, (hl)
	or a
	jr nz, draw_inventory_map_have_map

	ld hl, TEXT_NO_MAP
	ld de, CHRTBL2 + (256*2+32*2+3)*8
	ld iy, #2000 + COLOR_DARK_YELLOW
	ld b, 5
	jp draw_sentence_to_vdp_clearing_text_buffer

draw_inventory_map_have_map:
	; Loop 1, draw the map:
	ld a, (current_area__height)
	ld b, a
	ld a, (current_area__width)
	ld c, a
	ld hl, draw_inventory_map_row_ptrs
	ld de, current_area__room_ids
draw_inventory_map_have_map_loop_y:
	push bc
	push hl
		ld a, (hl)
		inc hl
		ld h, (hl)
		ld l, a
		ld b, c
		push bc
		push de
			call SETWRT
		pop de
		pop bc
        ld a, (VDP.DW)
        ld c, a
draw_inventory_map_have_map_loop_x:
		ld a, (de)
		cp #ff
		jr z, draw_inventory_map_have_map_loop_x_skip
		; room:
		; check if we need to connect to the right:
		ld l, a
		inc de
		ld a, (de)
		dec de
		cp l
		ld a, 1
		jr nz, draw_inventory_map_have_map_loop_x_room_no_right_connection
		ld a, 0
draw_inventory_map_have_map_loop_x_room_no_right_connection:
REPT 7
	    out (c), a
	    nop
ENDR
		; check if we need to connect down:
		push af
			ld a, (de)
			push af
				ld a, (current_area__width)
				ld l, a
				ld h, 0
				add hl, de
				ld l, (hl)  ; this might overflow outside of the map, but it's ok.
			pop af
			cp l
			jr nz, draw_inventory_map_have_map_loop_x_room_no_down_connection
		pop af
	    out (c), a
	    jr draw_inventory_map_have_map_loop_x_continue
draw_inventory_map_have_map_loop_x_room_no_down_connection:
		pop af
		ld a, #ff
	    out (c), a
		jr draw_inventory_map_have_map_loop_x_continue
draw_inventory_map_have_map_loop_x_skip:
		; no room:
		ld a, #ff
REPT 8
	    out (c), a
	    nop
ENDR

draw_inventory_map_have_map_loop_x_continue:
		inc de
		djnz draw_inventory_map_have_map_loop_x
	pop hl
	pop bc
	inc hl
	inc hl
	djnz draw_inventory_map_have_map_loop_y

	; mark interarea connections:
	; each connection is 8 bytes: ; id1, id2, x1, y1, direction1, x2, y2, direction2 (coordinates are in chunks)
	ld ix, current_world__interarea_connections
draw_inventory_map_have_map_ia_loop:
	ld a, (ix)
	cp #ff
	jp z, draw_inventory_map_have_map_ia_loop_done
	ld a, (current_area__id)
	cp (ix + 0)
	jr z, draw_inventory_map_have_map_ia_loop_found_1
	cp (ix + 1)
	jr z, draw_inventory_map_have_map_ia_loop_found_2
	jr draw_inventory_map_have_map_ia_loop_next
draw_inventory_map_have_map_ia_loop_found_1:
	ld c, (ix + 2)  ; x
	ld b, (ix + 3)  ; y
	ld e, (ix + 4)  ; direction
	jr draw_inventory_map_have_map_ia_loop_found_continue
draw_inventory_map_have_map_ia_loop_found_2:
	ld c, (ix + 5)  ; x
	ld b, (ix + 6)  ; y
	ld e, (ix + 7)  ; direction
draw_inventory_map_have_map_ia_loop_found_continue:
	; draw marker:
	sra c
	sra b
	ld a, b
	add a, a
	ld hl, draw_inventory_map_row_ptrs
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld a, c
	add a, a
	add a, a
	add a, a
	ADD_HL_A  ; hl = ptr to where to draw the marker
	ld a, e
	cp 8
	jr z, draw_inventory_map_have_map_ia_loop_found_left
	cp 4
	jr z, draw_inventory_map_have_map_ia_loop_found_up
	cp 2
	jr z, draw_inventory_map_have_map_ia_loop_found_right
draw_inventory_map_have_map_ia_loop_found_down:
	ld bc, 5
	add hl, bc
	jr draw_inventory_map_have_map_ia_loop_found_up
draw_inventory_map_have_map_ia_loop_found_left:
	inc hl
	inc hl
	inc hl
	call SETWRT
	ld a, (VDP.DW)
	ld c, a
	ld a, #e0
	jr draw_inventory_map_have_map_ia_loop_found_right_continue
draw_inventory_map_have_map_ia_loop_found_up:
	push hl
		call RDVRM
	pop hl
	push af
		call SETWRT
		ld a, (VDP.DW)
		ld c, a
	pop af
	or #10
	out (c), a
	push hl
	pop hl
	out (c), a
	jr draw_inventory_map_have_map_ia_loop_next
draw_inventory_map_have_map_ia_loop_found_right:
	inc hl
	inc hl
	inc hl
	call SETWRT
	ld a, (VDP.DW)
	ld c, a
	ld a, #07
draw_inventory_map_have_map_ia_loop_found_right_continue:
	out (c), a
	jr draw_inventory_map_have_map_ia_loop_next
draw_inventory_map_have_map_ia_loop_next:
	ld bc, 8
	add ix, bc
	jp draw_inventory_map_have_map_ia_loop
draw_inventory_map_have_map_ia_loop_done:


	; Loop 2, change the map colors to indicate where the player is:
	ld a, (current_room__id)
	ld iyl, a
	ld a, (current_area__height)
	ld b, a
	ld a, (current_area__width)
	ld c, a
	ld hl, draw_inventory_map_row_ptrs
	ld de, current_area__room_ids
draw_inventory_map_have_map_loop_y2:
	push bc
	push hl
		ld a, (hl)
		inc hl
		ld h, (hl)
		ld l, a
		ld b, c
		push bc
		push de
			ld bc, CLRTBL2 - CHRTBL2
			add hl, bc
			call SETWRT
		pop de
		pop bc
        ld a, (VDP.DW)
        ld c, a
draw_inventory_map_have_map_loop_x2:
		ld a, (de)
		cp iyl
		jr nz, draw_inventory_map_have_map_loop_x2_no_player
		; player is here:
		ld a, COLOR_DARK_RED + COLOR_DARK_YELLOW*16
REPT 8
	    out (c), a
	    nop
ENDR
	    jr draw_inventory_map_have_map_loop_x2_continue
draw_inventory_map_have_map_loop_x2_no_player:
		; no player:
		ld a, COLOR_DARK_YELLOW*16
REPT 8
	    out (c), a
	    nop
ENDR
draw_inventory_map_have_map_loop_x2_continue:
		inc de
		djnz draw_inventory_map_have_map_loop_x2
	pop hl
	pop bc
	inc hl
	inc hl
	djnz draw_inventory_map_have_map_loop_y2
	ret


draw_inventory_map_row_ptrs:
	dw CHRTBL2 + (256 + 117) * 8
	dw CHRTBL2 + (256*2 + 1) * 8
	dw CHRTBL2 + (256*2 + 1 + 1*32) * 8
	dw CHRTBL2 + (256*2 + 1 + 2*32) * 8
	dw CHRTBL2 + (256*2 + 1 + 3*32) * 8
	dw CHRTBL2 + (256*2 + 1 + 4*32) * 8
	dw CHRTBL2 + (256*2 + 1 + 5*32) * 8
	dw CHRTBL2 + (256*2 + 1 + 6*32) * 8


draw_inventory_map_to_piece_table:
	db #ff, #ff  ; junle, inscriptions
	db 0  ; hidden
	db 1, 1  ; confluence, inverted
	db 2, 2, 2  ; caves, fire shaft, caves
	db 3, 4, 5, 6  ; fire, atlantis, mars, moon


;-----------------------------------------------
setup_inventory_gfx:
	; sprites:
	ld hl, inventory_sprites
	ld de, SPRTBL2 + 32 * 2  ; first two reserved for player
	ld bc, inventory_sprites_end - inventory_sprites
	call fast_LDIRVM

	ld hl, inventory_tiles_nametable_zx0
	ld de, buffer_4096
	ld c, TILES_INVENTORY_AGE
	call dzx0_from_page_c

	; Draw inventory screen:
	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	call fast_LDIRVM

	; tiles
	ld hl, inventory_tiles_bank0_zx0
	ld de, buffer_4096
	ld c, TILES_INVENTORY_AGE
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, CHRTBL2
	ld bc, 256*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 256*8
	ld de, CLRTBL2
	ld bc, 256*8
	call fast_LDIRVM

	ld hl, inventory_tiles_bank1_zx0
	ld de, buffer_4096
	ld c, TILES_INVENTORY_AGE
	call dzx0_from_page_c
	ld hl, buffer_4096
	ld de, CHRTBL2 + 256*8
	ld bc, 256*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 256*8
	ld de, CLRTBL2 + 256*8
	ld bc, 256*8
	call fast_LDIRVM

	ld hl, inventory_tiles_bank2_zx0
	ld de, buffer_4096
	ld c, TILES_INVENTORY_AGE
	call dzx0_from_page_c
	ld hl, buffer_4096
	ld de, CHRTBL2 + 256*8*2
	ld bc, 256*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 256*8
	ld de, CLRTBL2 + 256*8*2
	ld bc, 256*8
	jp fast_LDIRVM	


inventory_sprites:
	incbin "autogenerated/inventory-sprites.bin"
inventory_sprites_end:


; IF (inventory_item_positions_end - inventory_item_positions) != N_INVENTORY_ITEM_TYPES
; 	ERROR "number of entries in inventory_item_positions is not N_INVENTORY_ITEM_TYPES"
; ENDIF

; IF (inventory_item_gfx_end - inventory_item_gfx)/4 != N_INVENTORY_ITEM_TYPES
; 	ERROR "number of entries in inventory_item_gfx is not N_INVENTORY_ITEM_TYPES"
; ENDIF


; equipable: 
; - 0: no
; - 1: weapon first row
; - 2: weapon second row
; - 3: item
INVENTORY_ITEM_FN: macro index, x, y, equipable, gfx1, gfx2, gfx3, gfx4, highlightptr, textptr, fnptr
	db index, x, y, equipable, gfx1, gfx2, gfx3, gfx4
	dw highlightptr, textptr, fnptr
	endm
inventory_table:
	; weapons:
	INVENTORY_ITEM_FN  0,  0, 2,  1,  160, 161, 24, 25,  0, TEXT_WEAPON_MACHETE,  0
	INVENTORY_ITEM_FN  1,  1, 2,  1,  162, 163, 26, 27,  draw_inventory_weapons_hammer_sprite, TEXT_WEAPON_HAMMER,  0
	INVENTORY_ITEM_FN  2,  2, 2,  1,  164, 165, 28, 29,  draw_inventory_weapons_ice_macuahuitl_sprite, TEXT_WEAPON_MACUAHUITL,  0
	INVENTORY_ITEM_FN  3,  3, 2,  1,  166, 167, 30, 31,  0, TEXT_WEAPON_SHIELD,  0
	INVENTORY_ITEM_FN  4,  0, 3,  2,  130, 131, 162, 163,  0, TEXT_WEAPON_SLING,  0
	INVENTORY_ITEM_FN  5,  1, 3,  2,  132, 133, 164, 165,  draw_inventory_weapons_blowgun_sprite, TEXT_WEAPON_BLOWGUN,  0
	INVENTORY_ITEM_FN  6,  2, 3,  2,  134, 135, 166, 167,  0, TEXT_WEAPON_ATLATL,  0
	INVENTORY_ITEM_FN  7,  3, 3,  2,  136, 137, 168, 169,  0, TEXT_WEAPON_RAYGUN,  0
	INVENTORY_ITEM_FN  8,  0, 2,  1,  168, 169, 192, 193,  0, TEXT_WEAPON_OBSIDIAN_KNIVE,  0
	INVENTORY_ITEM_FN  9,  1, 2,  1,  170, 171, 194, 195,  draw_inventory_weapons_fire_hammer_sprite, TEXT_WEAPON_FIRE_HAMMER,  0
	INVENTORY_ITEM_FN 10,  2, 2,  1,  172, 173, 196, 197,  draw_inventory_weapons_ice_macuahuitl_sprite, TEXT_WEAPON_ICE_MACUAHUITL,  0
	; boss keys:
	INVENTORY_ITEM_FN 11,   4, 1,  3,  96, 97, 128, 129,  0, TEXT_ITEM_BOSS_KEY,  0
	INVENTORY_ITEM_FN 12,   5, 1,  3,  98, 99, 130, 131,  0, TEXT_ITEM_BOSS_KEY,  0
	INVENTORY_ITEM_FN 13,   6, 1,  3,  100, 101, 132, 133,  0, TEXT_ITEM_BOSS_KEY,  0
	INVENTORY_ITEM_FN 14,   7, 1,  3,  102, 103, 134, 135,  0, TEXT_ITEM_BOSS_KEY,  0
	INVENTORY_ITEM_FN 15,   8, 1,  3,  104, 105, 136, 137,  0, TEXT_ITEM_BOSS_KEY,  0
	INVENTORY_ITEM_FN 16,   9, 1,  3,  106, 107, 138, 139,  0, TEXT_ITEM_BOSS_KEY,  0
	INVENTORY_ITEM_FN 17,   4, 2,  3,  108, 109, 172, 173,  0, TEXT_ITEM_BOSS_KEY,  0
	; power stones:
	INVENTORY_ITEM_FN 18,   4, 1,  3,  110, 111, 142, 143,  0, TEXT_ITEM_BOSS_POWER_STONE,  state_inventory_update_cursor_interact_power_stone1
	INVENTORY_ITEM_FN 19,   5, 1,  3,  110, 111, 142, 143,  0, TEXT_ITEM_BOSS_POWER_STONE,  state_inventory_update_cursor_interact_power_stone2
	INVENTORY_ITEM_FN 20,   6, 1,  3,  110, 111, 142, 143,  0, TEXT_ITEM_BOSS_POWER_STONE,  state_inventory_update_cursor_interact_power_stone3
	INVENTORY_ITEM_FN 21,   7, 1,  3,  110, 111, 142, 143,  0, TEXT_ITEM_BOSS_POWER_STONE,  state_inventory_update_cursor_interact_power_stone4
	INVENTORY_ITEM_FN 22,   8, 1,  3,  110, 111, 142, 143,  0, TEXT_ITEM_BOSS_POWER_STONE,  state_inventory_update_cursor_interact_power_stone5
	INVENTORY_ITEM_FN 23,   9, 1,  3,  110, 111, 142, 143,  0, TEXT_ITEM_BOSS_POWER_STONE,  state_inventory_update_cursor_interact_power_stone6
	; color keys, small keys, key items:
	INVENTORY_ITEM_FN 24,   6, 2,  3,  112, 113, 80, 81,  0, TEXT_ITEM_RED_KEY,  0
	INVENTORY_ITEM_FN 25,   7, 2,  3,  114, 115, 82, 83,  0, TEXT_ITEM_GREEN_KEY,  0
	INVENTORY_ITEM_FN 26,   8, 2,  3,  116, 117, 84, 85,  0, TEXT_ITEM_BLUE_KEY,  0
	INVENTORY_ITEM_FN 27,   9, 2,  3,  118, 119, 86, 87,  0, TEXT_ITEM_YELLOW_KEY,  0
	INVENTORY_ITEM_FN 28,   4, 3,  3,  56, 57, 88, 89,  0, TEXT_ITEM_WHITE_KEY,  0
	INVENTORY_ITEM_FN 29,   5, 3,  3,  58, 59, 90, 91,  0, TEXT_ITEM_PURPLE_KEY,  0
	INVENTORY_ITEM_FN 30,   6, 3,  3,  138, 139, 170, 171,  draw_inventory_small_keys, TEXT_ITEM_SMALL_KEYS,  0
	INVENTORY_ITEM_FN 31,   7, 3,  3,  36, 37, 68, 69,  0, TEXT_ITEM_BALL,  0
	INVENTORY_ITEM_FN 32,   8, 3,  3,  38, 39, 70, 71,  0, TEXT_ITEM_IDOL,  0
	INVENTORY_ITEM_FN 33,   9, 3,  3,  34, 35, 66, 67,  0, TEXT_ITEM_GEAR,  0
	INVENTORY_ITEM_FN 34,   4, 4,  3,  32, 33, 64, 65,  0, TEXT_ITEM_CLAY_SUIT,  0
	; upgrade items
	INVENTORY_ITEM_FN 35,   5, 4,  0,  40, 41, 72, 73,  0, TEXT_ITEM_SANDALS,  0
	INVENTORY_ITEM_FN 36,   6, 4,  0,  42, 43, 74, 75,  0, TEXT_ITEM_GLOVES,  0
	INVENTORY_ITEM_FN 37,   7, 4,  0,  44, 45, 76, 77,  0, TEXT_ITEM_WARRIOR_HAT,  0
	INVENTORY_ITEM_FN 38,   8, 4,  0,  46, 47, 78, 79,  0, TEXT_ITEM_COTTON_ARMOR,  0
	INVENTORY_ITEM_FN 39,   9, 4,  0,  60, 61, 92, 93,  0, TEXT_ITEM_CHAAC_BLESSING,  0
	INVENTORY_ITEM_FN 40,   4, 5,  0,  18, 19, 50, 51,  0, TEXT_ITEM_SEASHELL,  0
	INVENTORY_ITEM_FN 41,   5, 5,  0,  20, 21, 52, 53,  0, TEXT_ITEM_BELT,  0
	INVENTORY_ITEM_FN 42,   6, 5,  0,  22, 23, 54, 55,  0, TEXT_ITEM_ICE_CAPE,  0
	; special items
	INVENTORY_ITEM_FN 43,   7, 5,  0,  24, 25, 56, 57,  0, TEXT_ITEM_LETTER1,  state_inventory_update_cursor_interact_letter1
	INVENTORY_ITEM_FN 44,   8, 5,  0,  26, 27, 58, 59,  0, TEXT_ITEM_LETTER2,  state_inventory_update_cursor_interact_letter2
	INVENTORY_ITEM_FN 45,   9, 5,  0,  30, 31, 62, 63,  0, TEXT_ITEM_MAP,  state_inventory_update_cursor_interact_map
	INVENTORY_ITEM_FN 46,   9, 1,  0,  0, 0, 142, 143,  0, TEXT_ITEM_HALF_POWER_STONE,  0
	INVENTORY_ITEM_FN 47,   4, 2,  0,  0, 0, 142, 143,  0, TEXT_ITEM_HALF_POWER_STONE,  0
	INVENTORY_ITEM_FN 48,   9, 1,  0,  174, 175, 176, 177,  0, TEXT_ITEM_PUZZLEBOX,  state_inventory_update_cursor_interact_puzzlebox1
	INVENTORY_ITEM_FN 49,   4, 2,  0,  174, 175, 140, 141,  0, TEXT_ITEM_PUZZLEBOX,  state_inventory_update_cursor_interact_puzzlebox2
	db #ff  ; sentinel

