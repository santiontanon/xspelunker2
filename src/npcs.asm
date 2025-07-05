;-----------------------------------------------
object_interaction_function_shop_internal:
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority

	call display_shop_base_ui

	; synthesize the list of items/prices:
	call synthesize_shop_list

	; draw extra items:
	; ...

	; draw prices:
	; ...

	; draw player / player coins:
	; ...

	; interaction loop:
	; ...

	call wait_for_click
	xor a
	ld (keyboard_clicks), a

	; restore tiles in bottom bank (first clear the shop):
	ld hl, CLRTBL2 + 256*2*8
	ld bc, 256*8
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
	ret


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


shop_nametable:
	db 1, 1, 1,   1,   1, 1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1,   1
	db 0, 0, 0,   3,   4, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   7,   0,   0,   8,   9,   0,   0,   0,   0,   0,   0,   0,  96,  97,  98,  99,   0
	db 0, 0, 0,  19,  20, 0,   5,   6,   0,  17,  18,   0,  21,  22,   0,  23,   0,   0,  24,  25,   0,   0,   0,   0,   0,   0,   0, 100, 101, 102, 103,   0
	db 0, 0, 0, 104, 106, 0, 107, 108,   0, 109, 110,   0, 111, 112,   0, 113, 114,   0, 115, 116,   0, 117, 118,   0, 119, 120,   0,   0,   0,   0,   0,   0
	db 0, 0, 0,   0,   0, 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
	db 0, 0, 0,   0,   0, 0, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153
	db 0, 0, 2, 121, 122, 0, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179
	db 0, 0, 0,   0,   0, 0, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205

