;-----------------------------------------------
player_update:
	ld a, (player_state)
	ld hl, player_update_state_fn_table
	and #fe  ; lowest bit is direction (0: right, 1: left)
	ADD_HL_A
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex hl, de
	jp hl


;-----------------------------------------------
player_update_update_sprite_position:
	ld de, sprite_attribute_table
	ld bc, sprite_attribute_table + 4

	ld a, (player_y + 1)
	ld hl, room_scroll_y
	sub (hl)
	add a, a
	add a, a
	add a, a
	ld hl, player_y
	add a, (hl)
	dec a  ; sprites y in the VDP is off by 1 pixel

	ld (de), a
	ld (bc), a
	inc de
	inc bc

	ld a, (player_x + 1)
	ld hl, room_scroll_x
	sub (hl)
	add a, a
	add a, a
	add a, a
	ld hl, player_x
	add a, (hl)

	ld (de), a
	ld (bc), a
	ret


player_update_state_fn_table:
	dw player_update_state_idle
	dw player_update_state_walking


;-----------------------------------------------
player_update_switch_to_idle:
	ld a, (player_state)
	and #01
	ld (player_state), a

player_update_state_idle:
	; check for walk:
	ld a, (keyboard_line_state)
	bit 7, a
	jr z, player_update_switch_to_walking_right
	bit 4, a
	jr z, player_update_switch_to_walking_left


	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	rrca
	and #01
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


;-----------------------------------------------
player_update_switch_to_walking_left:
	ld a, PLAYER_STATE_WALKING + 1
	ld (player_state), a
	jp player_update_state_walking

player_update_switch_to_walking_right:
	ld a, PLAYER_STATE_WALKING
	ld (player_state), a

player_update_state_walking:
	; check for idle:
	ld a, (keyboard_line_state)
	bit 7, a
	jr z, player_update_state_walking_right
	bit 4, a
	jr z, player_update_state_walking_left
	jp player_update_switch_to_idle

player_update_state_walking_right:
	ld a, PLAYER_STATE_WALKING
	ld (player_state), a
	ld hl, player_x
	ld a, (hl)
	inc a
	ld (hl), a
	cp 8
	jr c, player_update_state_walking_continue
	and #07
	ld (hl), a
	inc hl
	inc (hl)
	jr player_update_state_walking_continue

player_update_state_walking_left:
	ld a, PLAYER_STATE_WALKING + 1
	ld (player_state), a
	ld hl, player_x
	ld a, (hl)
	dec a
	ld (hl), a
	inc a
	jp nz, player_update_state_walking_continue
	ld (hl), 7
	inc hl
	dec (hl)

player_update_state_walking_continue:
	ld a, (interrupt_cycle)
	rrca
	rrca
	rrca
	and #01
	add a, a
	ld (player_requested_frame), a
	jp player_update_update_sprite_position


