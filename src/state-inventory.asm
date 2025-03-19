;-----------------------------------------------
state_inventory:
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority

	call disable_VDP_output
		call clear_all_the_sprites
		call setup_inventory_gfx
		call draw_inventory_items
		call draw_inventory_weapons
		call draw_inventory_cursor
	call enable_VDP_output

	xor a
	ld (inventory_cursor_position), a

state_inventory_loop:
	halt
	call draw_inventory_cursor
	call update_keyboard_buffers
	ld a, (keyboard_line_clicks + 2)
	bit 2, a
	jr nz, state_inventory_exit
	jr state_inventory_loop

state_inventory_exit:
	call disable_VDP_output
	call clear_all_the_sprites
	jp state_play_from_inventory


;-----------------------------------------------
draw_inventory_cursor_offsets:
	db 0, 0, 0, 1, 2, 2, 2, 1
draw_inventory_cursor:
	ld a, (interrupt_cycle)
	rrca
	rrca
	and #07
	ld hl, draw_inventory_cursor_offsets
	ADD_HL_A
	ld a, 30
	sub (hl)
	ld c, a  ; x1
	ld a, 82
	add a, (hl)
	ld e, a  ; x2
	ld b, 3  ; y

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
	ret


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
setup_inventory_gfx:
	; sprites:
	ld hl, inventory_sprites
	ld de, SPRTBL2 + 32 * 2  ; first two reserved for player
	ld bc, inventory_sprites_end - inventory_sprites
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
	call fast_LDIRVM

	ld hl, inventory_tiles_nametable_zx0
	ld de, buffer_4096
	ld c, TILES_PAGE
	call dzx0_from_page_c

	; Draw inventory screen:
	ld hl, buffer_4096
	ld de, NAMTBL2
	ld bc, 768
	jp fast_LDIRVM


;-----------------------------------------------
inventory_item_positions:
	db 0, 1, 2  ; first 3 boss keys
	db 0, 1, 2, 3  ; last 4 boss keys
	db 4, 5, 6  ; first 3 idols
	db 4, 5, 6, 7  ; last 4 boss idols
	db 8, 9, 10, 11, 12, 13  ; color keys
	db 14, 15, 16, 17  ; key items
	db 18, 19, 20, 21, 22, 23  ; maya upgrade items
	db 24, 25  ; alien upgrade items
	db 26, 27, 28  ; elaine letters
	db 29  ; map
inventory_item_positions_end:

inventory_item_gfx:
	db 96, 97, 128, 129  ; boss key 1
	db 98, 99, 130, 131  ; boss key 2
	db 100, 101, 132, 133  ; boss key 3
	db 102, 103, 134, 135  ; boss key 4
	db 104, 105, 136, 137  ; boss key 5
	db 106, 107, 138, 139  ; boss key 6
	db 108, 109, 140, 141  ; boss key 7
	db 110, 111, 142, 143  ; boss idol 1
	db 110, 111, 142, 143  ; boss idol 2
	db 110, 111, 160, 161  ; boss idol 3
	db 110, 111, 142, 143  ; boss idol 4
	db 110, 111, 142, 143  ; boss idol 5
	db 110, 111, 160, 161  ; boss idol 6
	db 110, 111, 160, 161  ; boss idol 7
	db 112, 113, 80, 81  ; red key
	db 114, 115, 82, 83  ; green key
	db 116, 117, 84, 85  ; blue key
	db 118, 119, 86, 87  ; yellow key
	db 56, 57, 88, 89  ; purple key
	db 58, 59, 90, 91  ; white key
	db 32, 33, 64, 65  ; clay suit
	db 34, 35, 66, 67  ; gear
	db 36, 37, 68, 69  ; ball
	db 38, 39, 70, 71  ; idol
	db 40, 41, 72, 73  ; sandals
	db 42, 43, 74, 75  ; gloves
	db 44, 45, 76, 77  ; hurakán blessing
	db 46, 47, 78, 79  ; cotton armor
	db 60, 61, 92, 93  ; chaac blessing
	db 62, 63, 94, 95  ; seashell
	db 20, 21, 52, 53  ; antigrav-belt
	db 22, 23, 54, 55  ; heat-shield
	db 24, 25, 56, 57  ; letter 1
	db 26, 27, 58, 59  ; letter 2
	db 28, 29, 60, 61  ; letter 3
	db 30, 31, 62, 63  ; map
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


IF (inventory_item_positions_end - inventory_item_positions) != N_INVENTORY_ITEM_TYPES
	ERROR "number of entries in inventory_item_positions is not N_INVENTORY_ITEM_TYPES"
ENDIF

IF (inventory_item_gfx_end - inventory_item_gfx)/4 != N_INVENTORY_ITEM_TYPES
	ERROR "number of entries in inventory_item_gfx is not N_INVENTORY_ITEM_TYPES"
ENDIF

