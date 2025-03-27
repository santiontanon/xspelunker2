;-----------------------------------------------
; input:
; - hl: ptr where to draw
draw_hud_player_health:
	ld a, (player_max_health)
	rrca
	rrca
	and #3f
	ld b, a  ; number of hearts to display
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
	ret


;-----------------------------------------------
; input:
; - hl: ptr where to draw
; - de: room width - 32
draw_hud_coins:
	add hl, de
	ld bc, 32
	add hl, bc
	ld (hl), 6  ; coin tile
	ld a, (hud_rerender_coins)
	or a
	jr z, draw_hud_coins_no_rerender
	xor a
	ld (hud_rerender_coins), a
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
draw_hud_current_weapon:
	push hl
	push de
		ld a, (hud_rerender_weapon)
		or a
		jr z, draw_hud_current_weapon_no_rerender

		; update the weapon tiles in the hud:
		; ...

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
		ld a, (hud_rerender_weapon)
		or a
		jr z, draw_hud_current_weapon_ammo_no_rerender
		xor a
		ld (hud_rerender_weapon), a
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

