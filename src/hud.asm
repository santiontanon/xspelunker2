;-----------------------------------------------
draw_hud_minimal:
	ld hl, (tmp_hud_drawing_hl)
	call draw_hud_player_health

	ld hl, (tmp_hud_drawing_hl)
	ld de, (tmp_hud_drawing_de)
	call draw_hud_coins

	ld hl, (tmp_hud_drawing_hl)
	call draw_hud_oxygen

	ld hl, (tmp_hud_drawing_hl)
	ld de, (tmp_hud_drawing_de)
	call draw_hud_current_weapon

	ld hl, (tmp_hud_drawing_hl)
	ld de, (tmp_hud_drawing_de)
	jp draw_hud_current_weapon_ammo


;-----------------------------------------------
hud_full_nametable:
	db 19, 20, 21, 22, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 28, 29, 30, 31, 0, 0, 0, 0, 24, 25, 26, 27, 0, 0
	db 6,   0,  0,  0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0,  0,  0,  0, 0, 0, 0, 0,  0,  0,  0,  0, 0, 0

draw_hud_full:
	ld hl, hud_full_nametable
	ld de, buffer_4096 + 32  ; we render the hud in "buffer_4096 + 32" to leave some leeway to render the coins/ammo
	ld bc, 64
	ldir

	ld hl, buffer_4096 + 32 + 4
	call draw_hud_player_health

	ld hl, buffer_4096 + 32
	ld de, 0
	call draw_hud_coins

	ld hl, buffer_4096 + 64 + 4
	call draw_hud_oxygen_always

	ld hl, buffer_4096 + 32
	ld de, 0
	call draw_hud_current_weapon

	ld hl, buffer_4096 + 64
	call draw_hud_current_weapon_ammo

	ld hl, buffer_4096 + 32
	ld de, NAMTBL2
	ld b, 64
	jp fast_small_LDIRVM


;-----------------------------------------------
; input:
; - hl: ptr where to draw
draw_hud_player_health:
	ld a, (player_max_health)
	rrca
	rrca
	and #3f
	ld b, a  ; number of hearts to display
	push af
		ld a, (player_health)
		ld c, a  ; remaining health to display
draw_hud_player_health_loop:
		ld e, 4
		ld a, c
		cp 4
		jr nc, draw_hud_player_health_loop_continue
		ld e, a
draw_hud_player_health_loop_continue:
		ld a, c
		sub e
		ld c, a
		ld a, e
		inc a  ; first heart tile is tile 1
		ld (hl), a
		inc hl
		djnz draw_hud_player_health_loop
	pop af
	; make sure we use at least 5 positions (otherwise, coins look weird):
draw_hud_player_health_loop2:
	cp 5
	ret nc
	ld (hl), 0
	inc hl
	inc a
	jr draw_hud_player_health_loop2


;-----------------------------------------------
; input:
; - hl: ptr where to draw
; - de: room width - 32
draw_hud_coins:
	add hl, de
	ld bc, 32
	add hl, bc
	ld (hl), 6  ; coin tile
	ld a, (redraw_flags)
	bit COINS_REDRAW_FLAG_BIT, a
	jr z, draw_hud_coins_no_rerender
	ld a, (player_inventory_coins)
	ld de, CHRTBL2 + 10*8
	ld iy, #8000 + COLOR_WHITE*16
	ld b, 3
	push hl
		call draw_inventory_number
	pop hl
draw_hud_coins_no_rerender:
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 10
	inc hl
	ld (hl), 11
	inc hl
	ld (hl), 12
	ret


;-----------------------------------------------
draw_hud_oxygen:
	ld a, (player_state)
	and #fe
	cp PLAYER_STATE_SWIMMING
	ret nz
draw_hud_oxygen_always:
	ld a, (player_oxygen)
	or a
	jr z, draw_hud_oxygen_zero
draw_hud_oxygen_continue:
	ld de, 16 - (PLAYER_MAX_OXYGEN / 4)
	add hl, de
	ld b, PLAYER_MAX_OXYGEN / 2
draw_hud_oxygen_loop:
	or a
	jr z, draw_hud_oxygen_loop_0
	dec a
	jr z, draw_hud_oxygen_loop_1
	dec a
	ld (hl), 7
	jr draw_hud_oxygen_loop_continue
draw_hud_oxygen_loop_0:
	ld (hl), 0
	jr draw_hud_oxygen_loop_continue
draw_hud_oxygen_loop_1:
	ld (hl), 8
draw_hud_oxygen_loop_continue:
	inc hl
	djnz draw_hud_oxygen_loop
	ret

draw_hud_oxygen_zero:
	ld a, (interrupt_cycle)
	bit 4, a
	ld a, (player_oxygen)
	jr z, draw_hud_oxygen_continue
	xor a
	ld de, 16 - (PLAYER_MAX_OXYGEN / 4)
	add hl, de
	ld b, PLAYER_MAX_OXYGEN / 2 - 1
	ld (hl), 9
	inc hl
	jr draw_hud_oxygen_loop


;-----------------------------------------------
draw_hud_current_weapon:
	push hl
	push de
		ld a, (redraw_flags)
		bit WEAPON_REDRAW_FLAG_BIT, a
		jr z, draw_hud_current_weapon_no_rerender

		SETMEGAROMPAGE_8000 TILES_PAGE

		; update the weapon tiles in the hud:
		; from: hud_weapon_tiles_bin + a*64
		; to: CHRTBL2 + 15*8  /  CLRTBL2 + 15*8
		ld a, (player_current_weapon)
		add a, a  ; * 2
		add a, a  ; * 4
		add a, a  ; * 8
		add a, a  ; * 16
		ld l, a
		ld h, 0
		add hl, hl  ; * 32
		add hl, hl  ; * 64
		ld bc, hud_weapon_tiles_bin
		add hl, bc
		ld de, CHRTBL2 + 15*8
		ld b, 32
		call fast_small_LDIRVM
		ld de, CLRTBL2 + 15*8
		ld b, 32
		call fast_small_LDIRVM
draw_hud_current_weapon_no_rerender:
	pop de
	pop hl
	ld bc, 30
	add hl, bc
	ld (hl), 15
	inc hl
	ld (hl), 16
	add hl, de
	ld bc, 31
	add hl, bc
	ld (hl), 17
	inc hl
	ld (hl), 18
	ret


;-----------------------------------------------
draw_hud_current_weapon_ammo:
	ld a, (player_current_weapon)
	sub 4
	ret c
	cp 4
	ret nc
	push hl
		ld hl, player_inventory_weapon_ammo
		ADD_HL_A
		ld e, (hl)  ; e = number of bullets left
		ld a, (redraw_flags)
		bit COINS_REDRAW_FLAG_BIT, a
		jr z, draw_hud_current_weapon_ammo_no_rerender
		ld a, e
		ld de, CHRTBL2 + 13*8
		ld iy, #0800 + COLOR_WHITE*16
		ld b, 2
		push hl
			call draw_inventory_number
		pop hl
draw_hud_current_weapon_ammo_no_rerender:
	pop hl
	ld bc, 28
	add hl, bc
	ld (hl), 13
	inc hl
	ld (hl), 14
	ret

