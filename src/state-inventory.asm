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
		call draw_inventory_items
		call draw_inventory_weapons
		call draw_inventory_player_health
		call draw_inventory_small_keys
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
	; interact with power stones:
	ld a, (inventory_cursor_position_y)
	dec a
	jr z, state_inventory_update_cursor_interact_row1
	dec a
	jr z, state_inventory_update_cursor_interact_row2
	cp 3
	jr z, state_inventory_update_cursor_interact_row5
	ret
state_inventory_update_cursor_interact_row1:
	ld a, (inventory_cursor_position_x)
	cp 6
	jp z, state_inventory_update_cursor_interact_maybe_puzzlebox1
	cp 7
	jp z, state_inventory_update_cursor_interact_maybe_puzzlebox2
	cp 8
	jp z, state_inventory_update_cursor_interact_power_stone1
	cp 9
	jp z, state_inventory_update_cursor_interact_power_stone2
	ret
state_inventory_update_cursor_interact_row2:
	ld a, (inventory_cursor_position_x)
	cp 4
	jp z, state_inventory_update_cursor_interact_power_stone3
	cp 5
	jp z, state_inventory_update_cursor_interact_power_stone4
	ret
state_inventory_update_cursor_interact_row5:
	ld a, (inventory_cursor_position_x)
	cp 7
	jp z, state_inventory_update_cursor_interact_letter1
	cp 8
	jp z, state_inventory_update_cursor_interact_letter2
	cp 9
	jp z, state_inventory_update_cursor_interact_map
	ret


state_inventory_update_cursor_button:
	ld a, (inventory_cursor_position_y)
	or a
	jr z, state_inventory_update_cursor_button_row0
	; pressed over an item/weapon:
	ld b, a
	ld a, (inventory_cursor_position_x)
	ld c, a
	ld hl, inventory_weapon_item_fns
state_inventory_update_cursor_button_loop:
	ld a, (hl)
	cp #ff  ; sentinel
	ret z
	cp c
	jr nz, state_inventory_update_cursor_button_loop_next
	inc hl
	ld a, (hl)
	cp b
	jr nz, state_inventory_update_cursor_button_loop_next1
	; found!
	inc hl
	ld e, (hl)
	inc hl
	ld h, (hl)
	ld l, e
	jp (hl)
state_inventory_update_cursor_button_loop_next:
	inc hl
state_inventory_update_cursor_button_loop_next1:
	inc hl
	inc hl
	inc hl
	jr state_inventory_update_cursor_button_loop

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
state_inventory_update_cursor_interact_power_stone1:
	ld a, (player_inventory_items + 7)
	or a
	ld e, 0
	jr nz, state_inventory_update_cursor_interact_power_stone
	ld a, (player_inventory_items + 7 + 3)
	or a
	ld e, 3
	jr nz, state_inventory_update_cursor_interact_power_stone
	ret
state_inventory_update_cursor_interact_power_stone2:
	ld a, (player_inventory_items + 7 + 1)
	or a
	ld e, 1
	jr nz, state_inventory_update_cursor_interact_power_stone
	ld a, (player_inventory_items + 7 + 4)
	or a
	ld e, 4
	jr nz, state_inventory_update_cursor_interact_power_stone
	ret
state_inventory_update_cursor_interact_power_stone3:
	ld a, (player_inventory_items + 7 + 2)
	or a
	ld e, 2
	jr nz, state_inventory_update_cursor_interact_power_stone
	ld a, (player_inventory_items + 7 + 5)
	or a
	ld e, 5
	jr nz, state_inventory_update_cursor_interact_power_stone
	ret
state_inventory_update_cursor_interact_power_stone4:
	ld a, (player_inventory_items + 7 + 6)
	or a
	ld e, 6
	ret z
state_inventory_update_cursor_interact_power_stone:
	ld ix, TEXT_INSPECT_POWER_STONE
	call display_power_stone_closeup
	jp state_inventory_entry_point_from_item_inspection


;-----------------------------------------------
state_inventory_update_cursor_interact_maybe_puzzlebox1:
	ld a, (player_inventory_items + INVENTORY_ITEM_PUZZLEBOX_MARS)
	or a
	ret z
	ld ix, current_world__maya_puzzle2_combination1
	ld hl, display_puzzlebox_closeup
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	jp state_inventory_entry_point_from_item_inspection

state_inventory_update_cursor_interact_maybe_puzzlebox2:
	ld a, (player_inventory_items + INVENTORY_ITEM_PUZZLEBOX_MOON)
	or a
	ret z
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
			cp 6
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

	ld a, (inventory_cursor_position_x)
	cp 4
	jr c, state_inventory_update_item_text_weapon
state_inventory_update_item_text_item:
	sub 4
	ld c, a
	ld a, (inventory_cursor_position_y)
	dec a
	add a, a
	ld b, a
	add a, a
	add a, b
	add a, c
	ld c, a  ; c = position the cursor is over now
	ld hl, inventory_item_positions
	ld de, player_inventory_items
	ld b, 0  ; index in the item inventory
state_inventory_update_item_text_item_loop:
	ld a, (hl)
	cp c
	jr nz, state_inventory_update_item_text_item_loop_next
	; position matches, does the player have this weapon?
	ld a, (de)
	or a
	jr z, state_inventory_update_item_text_item_loop_next
	; found it! We need to print the text for this weapon:
	ld hl, inventory_item_texts
	ld a, b
	add a, a
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	jr state_inventory_update_item_text_print
state_inventory_update_item_text_item_loop_next:
	inc b
	inc hl
	inc de
	ld a, b
	cp N_INVENTORY_ITEM_TYPES
	ret z
	jp state_inventory_update_item_text_item_loop

state_inventory_update_item_text_weapon:
	ld c, a
	ld a, (inventory_cursor_position_y)
	sub 2
	add a, a
	add a, a
	add a, c
	ld c, a  ; c = position the cursor is over now
	ld hl, inventory_weapon_positions
	ld de, player_inventory_weapons
	ld b, 0  ; index in the weapon inventory
state_inventory_update_item_text_weapon_loop:
	ld a, (hl)
	cp c
	jr nz, state_inventory_update_item_text_weapon_loop_next
	; position matches, does the player have this weapon?
	ld a, (de)
	or a
	jr z, state_inventory_update_item_text_weapon_loop_next
	; found it! We need to print the text for this weapon:
	ld hl, inventory_weapon_texts
	ld a, b
	add a, a
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	jr state_inventory_update_item_text_print
state_inventory_update_item_text_weapon_loop_next:
	inc b
	inc hl
	inc de
	ld a, b
	cp N_INVENTORY_WEAPON_TYPES
	ret z
	jp state_inventory_update_item_text_weapon_loop

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

; 	ld hl, NAMTBL2 + 4*32+7
; 	ld b, 0
; 	ld c, a
; 	ld a, 24  ; small key tile
; 	jp fast_FILVRM


;-----------------------------------------------
draw_inventory_items:
	ld hl, player_inventory_items
	ld de, inventory_item_gfx
	ld b, N_INVENTORY_ITEM_TYPES
draw_inventory_items_loop:
	push bc
		ld a, (hl)
		or a
		jr z, draw_inventory_items_loop_next
		; draw item
		ld bc, inventory_item_positions - player_inventory_items
		add hl, bc
		ld a, (hl)  ; position of this item in the inventory screen
		or a
		sbc hl, bc
		; position to draw is:
		; NAMTBL2 + (14 + (a%6) * 3) + 32 * (4 + (a/6) * 3)
		push hl
		push de
			ld hl, NAMTBL2 + 14 + 32*4
draw_inventory_items_position_loop:
			cp 6
			jr c, draw_inventory_items_position_loop_done
			sub 6
			ld bc, 3 * 32
			add hl, bc
			jr draw_inventory_items_position_loop
draw_inventory_items_position_loop_done:
			ld c, a
			add a, a
			add a, c  ; a *= 3
			ADD_HL_A
			; hl = ptr to draw!
			ex de, hl
			push hl
			push de
				ld b, 2
				call fast_small_LDIRVM
			pop de
			pop hl
			ex de, hl
			inc de
			inc de
			ld bc, 32
			add hl, bc
			ex de, hl
			ld b, 2
			call fast_small_LDIRVM
		pop de
		pop hl
draw_inventory_items_loop_next:
		ex de, hl
			ld bc, 4
			add hl, bc
		ex de, hl
		inc hl
	pop bc
	djnz draw_inventory_items_loop
	ret


;-----------------------------------------------
draw_inventory_selected_item_highlight:
	ld a, (interrupt_cycle)
	bit 4, a
	jr z, draw_inventory_selected_item_highlight_erase
	ld a, (player_current_item)
	ld hl, inventory_selected_weapon_sprites
	add a, a
	add a, a
	ADD_HL_A
	ld de, SPRATR2 + 7*4
	ld b, 4
	jp fast_small_LDIRVM
draw_inventory_selected_item_highlight_erase:
	ld hl, SPRATR2 + 7*4
	xor a
	ld bc, 4
	jp fast_FILVRM


;-----------------------------------------------
draw_inventory_weapons:
	ld hl, player_inventory_weapons
	ld de, inventory_weapon_gfx
	ld b, 4 + 4 + 3  ; 4 base weapons, 4 ranged and 3 upgraded base
draw_inventory_weapons_loop:
	push bc
		ld a, (hl)
		or a
		jr z, draw_inventory_weapons_loop_next
		; draw weapon
		ld bc, inventory_weapon_positions - player_inventory_weapons
		add hl, bc
		ld a, (hl)  ; position of this weapon in the inventory screen
		or a
		sbc hl, bc
		; position to draw is:
		; NAMTBL2 + (1 + (a%4) * 3) + 32 * (7 + (a/4) * 3)
		push hl
		push de
			ld hl, NAMTBL2 + 1 + 32*7
draw_inventory_weapons_position_loop:
			cp 4
			jr c, draw_inventory_weapons_position_loop_done
			sub 4
			ld bc, 3 * 32
			add hl, bc
			jr draw_inventory_weapons_position_loop
draw_inventory_weapons_position_loop_done:
			ld c, a
			add a, a
			add a, c  ; a *= 3
			ADD_HL_A
			; hl = ptr to draw!
			ex de, hl
			push hl
			push de
				ld b, 2
				call fast_small_LDIRVM
			pop de
			pop hl
			ex de, hl
			inc de
			inc de
			ld bc, 32
			add hl, bc
			ex de, hl
			ld b, 2
			call fast_small_LDIRVM
		pop de
		pop hl
draw_inventory_weapons_loop_next:
		ex de, hl
			ld bc, 4
			add hl, bc
		ex de, hl
		inc hl
	pop bc
	djnz draw_inventory_weapons_loop

	; add sprite highlights:
	ld a, (player_inventory_weapons + 1)  ; hammer
	or a
	call nz, draw_inventory_weapons_hammer_sprite
	ld a, (player_inventory_weapons + 2)  ; macuahuitl
	or a
	call nz, draw_inventory_weapons_macuahuitl_sprite
	ld a, (player_inventory_weapons + 5)  ; blowgun
	or a
	call nz, draw_inventory_weapons_blowgun_sprite
	ld a, (player_inventory_weapons + 9)  ; fire hammer
	or a
	call nz, draw_inventory_weapons_fire_hammer_sprite
	ld a, (player_inventory_weapons + 10)  ; ice macuahuitl
	or a
	call nz, draw_inventory_weapons_ice_macuahuitl_sprite

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
	ld c, TILES_PAGE
	call dzx0_from_page_c

	; Draw inventory screen:
	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	call fast_LDIRVM

	; tiles
	ld hl, inventory_tiles_bank0_zx0
	ld de, buffer_4096
	ld c, TILES_PAGE
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
	ld c, TILES_PAGE
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
	ld c, TILES_PAGE
	call dzx0_from_page_c
	ld hl, buffer_4096
	ld de, CHRTBL2 + 256*8*2
	ld bc, 256*8
	call fast_LDIRVM
	ld hl, buffer_4096 + 256*8
	ld de, CLRTBL2 + 256*8*2
	ld bc, 256*8
	jp fast_LDIRVM	


;-----------------------------------------------
WEAPON_ITEM_FN: macro x, y, fn
	db x, y
	dw fn
	endm
inventory_weapon_item_fns:
	; weapons:
	WEAPON_ITEM_FN 0, 2, select_weapon0
	WEAPON_ITEM_FN 1, 2, select_weapon1
	WEAPON_ITEM_FN 2, 2, select_weapon2
	WEAPON_ITEM_FN 3, 2, select_weapon3
	WEAPON_ITEM_FN 0, 3, select_weapon4
	WEAPON_ITEM_FN 1, 3, select_weapon5
	WEAPON_ITEM_FN 2, 3, select_weapon6
	WEAPON_ITEM_FN 3, 3, select_weapon7
	; boss keys
	WEAPON_ITEM_FN 4, 1, select_boss_key1
	WEAPON_ITEM_FN 5, 1, select_boss_key2
	WEAPON_ITEM_FN 6, 1, select_boss_key3
	WEAPON_ITEM_FN 7, 1, select_boss_key4
	; idols
	WEAPON_ITEM_FN 8, 1, select_power_stone1
	WEAPON_ITEM_FN 9, 1, select_power_stone2
	WEAPON_ITEM_FN 4, 2, select_power_stone3
	WEAPON_ITEM_FN 5, 2, select_power_stone4
	; color keys
	WEAPON_ITEM_FN 6, 2, select_color_key1
	WEAPON_ITEM_FN 7, 2, select_color_key2
	WEAPON_ITEM_FN 8, 2, select_color_key3
	WEAPON_ITEM_FN 9, 2, select_color_key4
	WEAPON_ITEM_FN 4, 3, select_color_key5
	WEAPON_ITEM_FN 5, 3, select_color_key6
	; small keys
	WEAPON_ITEM_FN 6, 3, select_key_small_key
	; key items
	WEAPON_ITEM_FN 7, 3, select_key_item1
	WEAPON_ITEM_FN 8, 3, select_key_item2
	WEAPON_ITEM_FN 9, 3, select_key_item3
	WEAPON_ITEM_FN 4, 4, select_key_item4
	db #ff

select_weapon0:
	ld a, (player_inventory_weapons + 8)
	or a
	jr nz, select_weapon0_upgraded
	ld c, 0
select_weapon_generic:  ; c = weapon to select
	ld a, c
	ld hl, player_inventory_weapons
	ADD_HL_A
	ld a, (hl)
	or a
	ret z
	ld a, c
	ld (player_current_item), a
	ld hl, SFX_ui_select
	jp play_SFX_with_high_priority	
select_weapon0_upgraded:
	ld c, 8
	jr select_weapon_generic

select_weapon1:
	ld a, (player_inventory_weapons + 9)
	or a
	jr nz, select_weapon1_upgraded
	ld c, 1
	jr select_weapon_generic
select_weapon1_upgraded:
	ld c, 9
	jr select_weapon_generic

select_weapon2:
	ld a, (player_inventory_weapons + 10)
	or a
	jr nz, select_weapon2_upgraded
	ld c, 2
	jr select_weapon_generic
select_weapon2_upgraded:
	ld c, 10
	jr select_weapon_generic

select_weapon3:
	ld c, 3
	jr select_weapon_generic
select_weapon4:
	ld c, 4
	jr select_weapon_generic
select_weapon5:
	ld c, 5
	jr select_weapon_generic
select_weapon6:
	ld c, 6
	jr select_weapon_generic
select_weapon7:
	ld c, 7
	jr select_weapon_generic

select_boss_key1:
	ld hl, player_inventory_items  ; boss key 1
	ld de, player_inventory_items + 3
	ld bc, #0e0b  ; 11 and 14 (boss key 1 and 4)
select_power_stone_generic:
select_boss_key_generic:
	ld a, (hl)
	or a
	ld a, c
	jr nz, select_boss_key_generic_continue2
select_boss_key_generic_continue1:
	ld a, (de)
	or a
	ret z
	ld a, b
select_boss_key_generic_continue2:
	ld (player_current_item), a
	ld hl, SFX_ui_select
	jp play_SFX_with_high_priority	

select_boss_key2:
	ld hl, player_inventory_items + 1
	ld de, player_inventory_items + 4
	ld bc, #0f0c  ; 12 and 15 (boss key 2 and 5)
	jr select_boss_key_generic

select_boss_key3:
	ld hl, player_inventory_items + 2
	ld de, player_inventory_items + 5
	ld bc, #100d  ; 13 and 16 (boss key 3 and 6)
	jr select_boss_key_generic

select_boss_key4:
	ld de, player_inventory_items + 6
	ld b, 17  ; boss key 7
	jr select_boss_key_generic_continue1

select_power_stone1:
	ld hl, player_inventory_items + 7 ; power stone 1
	ld de, player_inventory_items + 10
	ld bc, #1512  ; 18 and 21 (power stone 1 and 4)
	jr select_power_stone_generic

select_power_stone2:
	ld hl, player_inventory_items + 8
	ld de, player_inventory_items + 11
	ld bc, #1613  ; 19 and 22 (power stone 2 and 5)
	jr select_power_stone_generic

select_power_stone3:
	ld hl, player_inventory_items + 9
	ld de, player_inventory_items + 12
	ld bc, #1714  ; 20 and 23 (power stone 3 and 6)
	jr select_power_stone_generic

select_power_stone4:
	ld de, player_inventory_items + 13
	ld b, 24  ; power stone 7 (prism)
	jr select_boss_key_generic_continue1

select_color_key1:
	ld de, player_inventory_items + 14
	ld b, 25
	jr select_boss_key_generic_continue1

select_color_key2:
	ld de, player_inventory_items + 15
	ld b, 26
	jr select_boss_key_generic_continue1

select_color_key3:
	ld de, player_inventory_items + 16
	ld b, 27
	jr select_boss_key_generic_continue1

select_color_key4:
	ld de, player_inventory_items + 17
	ld b, 28
	jr select_boss_key_generic_continue1

select_color_key5:
	ld de, player_inventory_items + 18
	ld b, 29
	jr select_boss_key_generic_continue1

select_color_key6:
	ld de, player_inventory_items + 19
	ld b, 30
	jr select_boss_key_generic_continue1

select_key_small_key:
	ld de, player_inventory_items + 20
	ld b, 31
	jp select_boss_key_generic_continue1

select_key_item1:
	ld de, player_inventory_items + 21
	ld b, 32
	jp select_boss_key_generic_continue1

select_key_item2:
	ld de, player_inventory_items + 22
	ld b, 33
	jp select_boss_key_generic_continue1

select_key_item3:
	ld de, player_inventory_items + 23
	ld b, 34
	jp select_boss_key_generic_continue1

select_key_item4:
	ld de, player_inventory_items + 24
	ld b, 35
	jp select_boss_key_generic_continue1


;-----------------------------------------------
inventory_item_positions:
	db 0, 1, 2  ; first 3 boss keys
	db 0, 1, 2, 3  ; last 4 boss keys
	db 4, 5, 6  ; first 3 power stones
	db 4, 5, 6, 7  ; last 3 boss power stones + place holder for something
	db 8, 9, 10, 11, 12, 13  ; color keys
	db 14  ; small keys
	db 15, 16, 17, 18  ; key items (21 - 24)
	db 19, 20, 21, 22, 23, 24  ; maya upgrade items (25 - 30)
	db 25, 26  ; alien upgrade items (31, 32)
	db 27, 28  ; elaine letters (33, 34, 35)
	db 29  ; map (36)
	db 6  ; half stone (turns into 6th power stone when picking up the second half)
	db 2, 3  ; puzzle boxes
inventory_item_positions_end:

inventory_item_gfx:
	db 96, 97, 128, 129  ; boss key 1
	db 98, 99, 130, 131  ; boss key 2
	db 100, 101, 132, 133  ; boss key 3
	db 102, 103, 134, 135  ; boss key 4
	db 104, 105, 136, 137  ; boss key 5
	db 106, 107, 138, 139  ; boss key 6
	db 108, 109, 140, 141  ; boss key 7
	db 110, 111, 142, 143  ; boss power stone 1
	db 110, 111, 142, 143  ; boss power stone 2
	db 110, 111, 160, 161  ; boss power stone 3
	db 110, 111, 142, 143  ; boss power stone 4
	db 110, 111, 142, 143  ; boss power stone 5
	db 110, 111, 160, 161  ; boss power stone 6
	db 110, 111, 160, 161  ; boss power stone 7
	db 112, 113, 80, 81  ; red key
	db 114, 115, 82, 83  ; green key
	db 116, 117, 84, 85  ; blue key
	db 118, 119, 86, 87  ; yellow key
	db 56, 57, 88, 89  ; purple key
	db 58, 59, 90, 91  ; white key
	db 138, 139, 170, 171  ; small keys
	db 36, 37, 68, 69  ; ball
	db 38, 39, 70, 71  ; idol
	db 34, 35, 66, 67  ; gear	
	db 32, 33, 64, 65  ; clay suit
	db 40, 41, 72, 73  ; sandals
	db 42, 43, 74, 75  ; gloves
	db 44, 45, 76, 77  ; hurakán blessing
	db 46, 47, 78, 79  ; cotton armor
	db 60, 61, 92, 93  ; chaac blessing
	db 18, 19, 50, 51  ; seashell
	db 20, 21, 52, 53  ; antigrav-belt
	db 22, 23, 54, 55  ; ice cape
	db 24, 25, 56, 57  ; letter 1
	db 26, 27, 58, 59  ; letter 2
	; db 28, 29, 60, 61  ; letter 3
	db 30, 31, 62, 63  ; map
	db 0, 0, 160, 161  ; half power stone
	db 174, 175, 176, 177  ; puzzlebox
	db 174, 175, 176, 177  ; puzzlebox
inventory_item_gfx_end:

inventory_weapon_positions:
	db 0, 1, 2, 3  ; base weapons
	db 4, 5, 6, 7  ; ranged
	db 0, 1, 2, 3  ; base upgraded

inventory_weapon_gfx:
	db 160, 161, 24, 25  ; machete
	db 162, 163, 26, 27  ; hammer
	db 164, 165, 28, 29  ; macuahuitl
	db 166, 167, 30, 31  ; shield
	db 130, 131, 162, 163  ; sling
	db 132, 133, 164, 165  ; blowgun
	db 134, 135, 166, 167  ; atlatl
	db 136, 137, 168, 169  ; raygun
	db 168, 169, 192, 193  ; obsidian machete
	db 170, 171, 194, 195  ; fire hammer
	db 172, 173, 196, 197  ; ice macuahuitl

inventory_sprites:
	incbin "autogenerated/inventory-sprites.bin"
inventory_sprites_end:


inventory_selected_weapon_sprites:
	; weapons:
	db 71, 8, 28, COLOR_WHITE
	db 71, 32, 28, COLOR_WHITE
	db 71, 56, 28, COLOR_WHITE
	db 71, 80, 28, COLOR_WHITE
	db 72, 8, 32, COLOR_WHITE
	db 72, 32, 32, COLOR_WHITE
	db 72, 56, 32, COLOR_WHITE
	db 72, 80, 32, COLOR_WHITE
	db 71, 8, 28, COLOR_WHITE
	db 71, 32, 28, COLOR_WHITE
	db 71, 56, 28, COLOR_WHITE
	; boss keys:
	db 47, 112, 28, COLOR_WHITE
	db 47, 136, 28, COLOR_WHITE
	db 47, 160, 28, COLOR_WHITE
	db 47, 112, 28, COLOR_WHITE
	db 47, 136, 28, COLOR_WHITE
	db 47, 160, 28, COLOR_WHITE
	db 47, 184, 28, COLOR_WHITE
	; power stones:
	db 47, 208, 28, COLOR_WHITE
	db 47, 232, 28, COLOR_WHITE
	db 71, 112, 28, COLOR_WHITE
	db 47, 208, 28, COLOR_WHITE
	db 48, 232, 28, COLOR_WHITE
	db 71, 112, 28, COLOR_WHITE
	db 71, 136, 28, COLOR_WHITE
	; color keys:
	db 71, 160, 28, COLOR_WHITE
	db 71, 184, 28, COLOR_WHITE
	db 71, 208, 28, COLOR_WHITE
	db 71, 232, 28, COLOR_WHITE
	db 95, 112, 28, COLOR_WHITE
	db 95, 136, 28, COLOR_WHITE
	; small keys:
	db 95, 160, 28, COLOR_WHITE
	; key items:
	db 95, 184, 28, COLOR_WHITE
	db 95, 208, 28, COLOR_WHITE
	db 95, 232, 28, COLOR_WHITE
	db 119, 112, 28, COLOR_WHITE


inventory_weapon_texts:
	dw TEXT_WEAPON_MACHETE, TEXT_WEAPON_HAMMER, TEXT_WEAPON_MACUAHUITL, TEXT_WEAPON_SHIELD
	dw TEXT_WEAPON_SLING, TEXT_WEAPON_BLOWGUN, TEXT_WEAPON_ATLATL, TEXT_WEAPON_RAYGUN
	dw TEXT_WEAPON_OBSIDIAN_KNIVE, TEXT_WEAPON_FIRE_HAMMER, TEXT_WEAPON_ICE_MACUAHUITL

inventory_item_texts:
	dw TEXT_ITEM_BOSS_KEY, TEXT_ITEM_BOSS_KEY, TEXT_ITEM_BOSS_KEY, TEXT_ITEM_BOSS_KEY
	dw TEXT_ITEM_BOSS_KEY, TEXT_ITEM_BOSS_KEY, TEXT_ITEM_BOSS_KEY
	dw TEXT_ITEM_BOSS_POWER_STONE, TEXT_ITEM_BOSS_POWER_STONE, TEXT_ITEM_BOSS_POWER_STONE, TEXT_ITEM_BOSS_POWER_STONE
	dw TEXT_ITEM_BOSS_POWER_STONE, TEXT_ITEM_BOSS_POWER_STONE, TEXT_ITEM_BOSS_POWER_STONE
	dw TEXT_ITEM_RED_KEY, TEXT_ITEM_GREEN_KEY, TEXT_ITEM_BLUE_KEY, TEXT_ITEM_YELLOW_KEY
	dw TEXT_ITEM_WHITE_KEY, TEXT_ITEM_PURPLE_KEY, TEXT_ITEM_SMALL_KEYS
	dw TEXT_ITEM_BALL, TEXT_ITEM_IDOL, TEXT_ITEM_GEAR, TEXT_ITEM_CLAY_SUIT
	dw TEXT_ITEM_SANDALS, TEXT_ITEM_GLOVES, TEXT_ITEM_WARRIOR_HAT, TEXT_ITEM_COTTON_ARMOR
	dw TEXT_ITEM_CHAAC_BLESSING, TEXT_ITEM_SEASHELL, TEXT_ITEM_BELT, TEXT_ITEM_ICE_CAPE
	dw TEXT_ITEM_LETTER1, TEXT_ITEM_LETTER2
	dw TEXT_ITEM_MAP
	dw TEXT_ITEM_HALF_POWER_STONE
	dw TEXT_ITEM_PUZZLEBOX, TEXT_ITEM_PUZZLEBOX


IF (inventory_item_positions_end - inventory_item_positions) != N_INVENTORY_ITEM_TYPES
	ERROR "number of entries in inventory_item_positions is not N_INVENTORY_ITEM_TYPES"
ENDIF

IF (inventory_item_gfx_end - inventory_item_gfx)/4 != N_INVENTORY_ITEM_TYPES
	ERROR "number of entries in inventory_item_gfx is not N_INVENTORY_ITEM_TYPES"
ENDIF

