;-----------------------------------------------
object_interaction_function_shop_internal:
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority

	xor a
	ld (tmp_shop_cursor_position), a

	call display_shop_base_ui

	; synthesize the list of items/prices:
	call synthesize_shop_list

	; draw extra items:
	ld a, (buffer_4096 + 256 + 6*2)
	or a
	jr z, object_interaction_function_shop_internal_extra_items_drawn
	ld de, NAMTBL2 + 256*2 + 32 + 21
	call shop_draw_extra_item

	ld a, (buffer_4096 + 256 + 7*2)
	or a
	jr z, object_interaction_function_shop_internal_extra_items_drawn
	ld de, NAMTBL2 + 256*2 + 32 + 24
	call shop_draw_extra_item
object_interaction_function_shop_internal_extra_items_drawn:

	; draw prices:
	ld de, CHRTBL2 + (256*2 + 104) * 8
	ld hl, buffer_4096 + 256
	ld b, 8
object_interaction_function_shop_internal_price_loop:
	push bc
		ld a, (hl)
		inc hl
		push hl
			push de
				or a
				jr z, object_interaction_function_shop_internal_price_loop_next
				ld a, (hl)  ; price
				or a
				jr z, object_interaction_function_shop_internal_price_loop_n_a
				; price:
				ld ixl, a
				ld b, 2
				ld iy, #80f0
				ld hl, draw_inventory_number_ixl
				ld c, TEXT_PAGE
				call call_hl_in_page_c_8000
				jr object_interaction_function_shop_internal_price_loop_next
object_interaction_function_shop_internal_price_loop_n_a:
				; n/a:
				ld hl, TEXT_SHOP_OUT
				ld iy, #08f0
				ld b, 2
				call draw_sentence_to_vdp_from_another_page
object_interaction_function_shop_internal_price_loop_next:
			pop hl
			ld bc, 8*2
			add hl, bc
			ex de, hl
		pop hl
	pop bc
	inc hl
	djnz object_interaction_function_shop_internal_price_loop

	; draw player coins:
	ld hl, TEXT_SHOP_MONEY
	ld iy, #08f0
	ld de, CHRTBL2 + (256*2 + 123)*8
	ld b, 4
	call draw_sentence_to_vdp_from_another_page

	ld a, (player_inventory_coins)
	ld ixl, a
	ld b, 3
	ld iy, #80f0
	ld de, CHRTBL2 + (256*2 + 120)*8
	ld hl, draw_inventory_number_ixl
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000

	; interaction loop:
object_interaction_function_shop_internal_loop:
	halt
	call shop_draw_cursor
	call update_keyboard_buffers
	call shop_update_cursor
	jr nz, object_interaction_function_shop_internal_loop
object_interaction_function_shop_internal_loop_end:

	xor a
	ld (keyboard_clicks), a

	; restore tiles in bottom bank (first clear the shop):
	ld hl, CLRTBL2 + 256*2*8
	ld bc, 256*8
	; xor a
	call fast_FILVRM

	ld hl, SPRATR2 + 30*4
	ld bc, 8
	; xor a
	call fast_FILVRM

	; restore content below:
	ld hl, buffer_4096
	ld de, NAMTBL2 + 256*2
	ld bc, 256
	call fast_LDIRVM

	ld hl, redraw_flags
	ld (hl), #ff	

	ld a, (current_room__tileset_page)
	ld c, a
	ld hl, (current_room__tileset_ptr)
	jp setup_game_tiles_only_biome


synthesize_shop_list:
	ld hl, buffer_4096 + 256
	ld (hl), TAG_CORN
	inc hl
	ld (hl), 10
	inc hl
	ld (hl), TAG_STONES
	inc hl
	ld c, 5
	ld a, (player_inventory_weapons + 4)
	or a
	jr nz, synthesize_shop_list_has_sling
	ld c, 0
synthesize_shop_list_has_sling:
	ld (hl), c
	inc hl
	ld (hl), TAG_DARTS
	inc hl
	ld c, 8
	ld a, (player_inventory_weapons + 5)
	or a
	jr nz, synthesize_shop_list_has_blowgun
	ld c, 0
synthesize_shop_list_has_blowgun:
	ld (hl), c
	inc hl
	ld (hl), TAG_SPEARS
	inc hl
	ld c, 8
	ld a, (player_inventory_weapons + 6)
	or a
	jr nz, synthesize_shop_list_has_atlatl
	ld c, 0
synthesize_shop_list_has_atlatl:
	ld (hl), c
	inc hl
	ld (hl), TAG_BATTERY
	inc hl
	ld c, 8
	ld a, (player_inventory_weapons + 7)
	or a
	jr nz, synthesize_shop_list_has_battery
	ld c, 0
synthesize_shop_list_has_battery:
	ld (hl), c
	inc hl
	ld (hl), TAG_DYNAMITE
	inc hl
	ld (hl), 0
	inc hl
	ld a, (current_world__shop_extra_items)
	ld (hl), a
	inc hl
	ld c, a
	or a
	jr z, synthesize_shop_list_continue1
	ld c, 50
synthesize_shop_list_continue1:
	ld (hl), c
	inc hl
	ld a, (current_world__shop_extra_items + 1)
	ld (hl), a
	inc hl
	ld c, a
	or a
	jr z, synthesize_shop_list_continue2
	ld c, 50
synthesize_shop_list_continue2:
	ld (hl), c
	ret


;-----------------------------------------------
shop_draw_cursor_offsets:
	db 0, 0, 0, 1, 2, 2, 2, 1
shop_draw_cursor:
	ld a, (tmp_shop_cursor_position)
	; x = 20 + (inventory_cursor_position_x) * 24
	; y = 135
	add a, a
	add a, a
	add a, a  ; * 8
	ld c, a
	add a, a  ; * 16
	add a, c  ; * 24
	add a, 20  ; 20 + (inventory_cursor_position_x) * 24
	ld c, a
	add a, 20
	ld e, a
	ld a, (tmp_shop_cursor_position)
	cp 8
	jr nz, shop_draw_cursor_continue
	ld a, e
	add a, 16
	ld e, a
shop_draw_cursor_continue:
	ld b, 135
	ld a, (interrupt_cycle)
	rrca
	and #07
	ld hl, shop_draw_cursor_offsets
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
	ld (hl), (FIRST_ENEMY_SPRITE_PATTERN + 4) * 4  ; sprite number
	inc hl
	ld (hl), COLOR_WHITE
	inc hl
	ld (hl), b
	inc hl
	ld (hl), e
	inc hl
	ld (hl), (FIRST_ENEMY_SPRITE_PATTERN + 5) * 4  ; sprite number
	inc hl
	ld (hl), COLOR_WHITE
	inc hl
	ld hl, buffer_4096
	ld de, SPRATR2 + 30*4
	ld b, 8
	jp fast_small_LDIRVM


;-----------------------------------------------
shop_update_cursor:
	ld a, (keyboard_clicks)
	bit KEY_RIGHT_BIT, a
	push af
		call nz, shop_update_cursor_right
	pop af
	bit KEY_LEFT_BIT, a
	push af
		call nz, shop_update_cursor_left
	pop af
	bit KEY_WEAPON_BIT, a  ; space
	jp nz, shop_update_cursor_select
	bit KEY_INTERACT_BIT, a  ; interact
	jp nz, shop_update_cursor_select
	or 1  ; do not end the shop yet
	ret

shop_update_cursor_select:
	ld a, (tmp_shop_cursor_position)
	cp 8  ; "back"
	jr z, shop_update_cursor_select_back
	; ...
	ret
shop_update_cursor_select_back:
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority
	xor a  ; end the shop
	ret


shop_update_cursor_right:
	ld a, (tmp_shop_cursor_position)
	cp 8
	ret z
shop_update_cursor_right_loop:
	ld a, (tmp_shop_cursor_position)
	inc a
	ld (tmp_shop_cursor_position), a
	cp 8
	jr z, shop_update_cursor_right_done
	; skip empty items:
	ld hl, buffer_4096 + 256
	add a, a
	ADD_HL_A
	ld a, (hl)
	or a
	jr z, shop_update_cursor_right_loop
shop_update_cursor_right_done:
	ld hl, SFX_ui_move
	jp play_SFX_with_high_priority	

shop_update_cursor_left:
	ld a, (tmp_shop_cursor_position)
	or a
	ret z
shop_update_cursor_left_loop:
	ld a, (tmp_shop_cursor_position)
	dec a
	ld (tmp_shop_cursor_position), a
	; skip empty items:
	ld hl, buffer_4096 + 256
	add a, a
	ADD_HL_A
	ld a, (hl)
	or a
	jr z, shop_update_cursor_left_loop
	ld hl, SFX_ui_move
	jp play_SFX_with_high_priority	


;-----------------------------------------------
display_shop_base_ui:
	; clear sprites that are in the message area (y > 112)
	ld hl, sprite_attribute_table
	ld a, (n_displayed_object_sprites)
	add a, FIRST_OBJECT_SPRITE
	ld b, a
display_shop_base_ui__clear_sprites_loop:
	ld a, (hl)  ; y
	cp 112
	jr c, display_shop_base_ui__clear_sprites_loop_next
	ld (hl), 200  ; move out of the screen
display_shop_base_ui__clear_sprites_loop_next:
	inc hl
	inc hl
	inc hl
	inc hl
	djnz display_shop_base_ui__clear_sprites_loop
	ld hl, sprite_attribute_table
	ld de, SPRATR2
	ld a, (n_displayed_object_sprites)
	add a, FIRST_OBJECT_SPRITE
	add a, a
	add a, a
	ld b, a
	call fast_small_LDIRVM		

	; clear all biome tiles:
	; - we first clear the color table
	; - then decompress the tileset, and copy only the CHRTBL2 part (so that we can then reuse the bottom part of the buffer_4096)
	; - we use that bottom part to temporaryly save the nametable
	; - and then we clear the name table in the VDP, and copy over the CLRTBL2 part
	ld hl, CLRTBL2 + 256*2*8
	ld bc, 256*8
	xor a
	call fast_FILVRM

	ld hl, shop_tiles_zx0
	ld de, buffer_4096
	ld C, NPCS_PAGE
	call dzx0_from_page_c

	ld hl, buffer_4096
	ld de, CHRTBL2 + 256*2*8
	ld bc, 256*8
	call fast_LDIRVM

	; save the content below:
	ld hl, NAMTBL2 + 256*2
	ld de, buffer_4096
	ld bc, 256
	call LDIRMV

	ld hl, shop_nametable
	ld de, NAMTBL2 + 256*2
	ld bc, 256
	call fast_LDIRVM

	ld hl, buffer_4096 + 256*8
	ld de, CLRTBL2 + 256*2*8
	ld bc, 256*8
	jp fast_LDIRVM


;-----------------------------------------------
; input:
; - a: item
; - de: name table to draw to
shop_draw_extra_item:
	ld c, a
	ld hl, shop_extra_item_gfx
shop_draw_extra_item_loop:
	ld a, (hl)
	inc hl
	or a
	ret z  ; not found
	cp c
	jr nz, shop_draw_extra_item_loop_next
	; found:
	ld b, 2
	push hl
		push de
			call fast_small_LDIRVM
		pop hl
		ld bc, 32
		add hl, bc
		ex de, hl
	pop hl
	inc hl
	inc hl
	ld b, 2
	jp fast_small_LDIRVM

shop_draw_extra_item_loop_next:
	inc hl
	inc hl
	inc hl
	inc hl
	jr shop_draw_extra_item_loop


;-----------------------------------------------
shop_nametable:
	db 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1
	db 0,   0,   0,   3,   4,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   7,   0,   0,   8,   9,   0,   0,   0,   0,   0,   0,   0,  96,  97,  98,  99,   0
	db 0,   0,   0,  19,  20,   0,   5,   6,   0,  17,  18,   0,  21,  22,   0,  23,   0,   0,  24,  25,   0,   0,   0,   0,   0,   0,   0, 100, 101, 102, 103,   0
	db 0,   0,   0, 104, 105,   0, 106, 107,   0, 108, 109,   0, 110, 111,   0, 112, 113,   0, 114, 115,   0, 116, 117,   0, 118, 119,   0,   0,   0,   0,   0,   0
	db 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
	db 0, 123, 124, 125, 126,   0, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153
	db 0,   2,   0, 120, 121, 122, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179
	db 0,   0,   0,   0,   0,   0, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205

shop_extra_item_gfx:
	db TAG_WEAPON_HAMMER, 10, 11, 26, 27
	db TAG_WEAPON_MACUAHUITL, 12, 13, 28, 29
	db TAG_WEAPON_SHIELD, 14, 15, 30, 31
	db TAG_WEAPON_SLING, 32, 33, 48, 49
	db TAG_WEAPON_BLOWGUN, 34, 35, 50, 51
	db TAG_WEAPON_ATLATL, 36, 37, 52, 53
	db TAG_WEAPON_RAYGUN, 38, 39, 54, 55
	db TAG_WEAPON_OBSIDIAN_KNIVE, 40, 41, 56, 57
	db TAG_WEAPON_FIRE_HAMMER, 42, 43, 58, 59
	db TAG_WEAPON_ICE_MACUAHUITL, 44, 45, 60, 61
	db TAG_ITEM_SANDALS, 46, 47, 62, 63
	db TAG_ITEM_GLOVES, 64, 65, 80, 81
	db TAG_ITEM_WARRIOR_HAT, 66, 67, 82, 83
	db TAG_ITEM_ARMOR, 68, 69, 84, 85
	db TAG_ITEM_CHAAC, 70, 71, 86, 87
	db TAG_ITEM_SEASHELL, 72, 73, 88, 89
	db TAG_ITEM_BELT, 74, 75, 90, 91
	db TAG_ITEM_ICE_CAPE, 76, 77, 92, 93
	db 0  ; sentinel

