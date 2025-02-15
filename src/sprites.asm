;-----------------------------------------------
upload_sprites_to_vdp:
	; upload requested player frame to the VDP player sprite slots (0, and 1):
	ld a, (player_requested_frame)
	ld l, 0
	rrca
	rr l
	rrca
	rr l
	and #3f  ; hl = a * 64
	ld h, a

	ld a, (player_state)
	and #01
	jr nz, upload_sprites_to_vdp_player_left
	ld bc, player_sprites_bin
	jp upload_sprites_to_vdp_player_direction_set
upload_sprites_to_vdp_player_left:
	ld bc, player_sprites_left_bin
upload_sprites_to_vdp_player_direction_set:
	add hl, bc
	ld de, SPRTBL2
	ld bc, 64
	call fast_LDIRVM

	; upload sprite attributes:
	ld hl, sprite_attribute_table
	ld de, SPRATR2
	ld bc, 8
	call fast_LDIRVM


	ret
