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
	ld de, player_weapon_sprites_bin
	jp upload_sprites_to_vdp_player_direction_set
upload_sprites_to_vdp_player_left:
	ld bc, player_sprites_left_bin
	ld de, player_weapon_sprites_left_bin
upload_sprites_to_vdp_player_direction_set:
	push de
		add hl, bc
		ld de, SPRTBL2
		ld b, 64
		call fast_small_LDIRVM
	pop bc

	ld a, (player_requested_weapon_sprite)
	cp #ff
	jr z, upload_sprites_to_vdp_no_weapon
	ld l, 0
	rrca
	rr l
	rrca
	rr l
	and #3f  ; hl = a * 64
	ld h, a
	add hl, bc	
	ld de, SPRTBL2 + 32*2
	ld b, 32
	call fast_small_LDIRVM

upload_sprites_to_vdp_no_weapon:
	; upload sprite attributes:
	ld hl, sprite_attribute_table
	ld de, SPRATR2
	ld b, 3 * 4  ; 2 for player, 1 for player weapon
	call fast_small_LDIRVM
	; jp upload_displayed_object_sprites_to_vdp


;-----------------------------------------------
; Upload the rest of the "sprite_attribute_table" attributes to the VDP.
; Also, if we have less sprites this frame than the last frame, we upload additional data
; to clear the extra sprites in the previous frame.
upload_displayed_object_sprites_to_vdp:
	ld a, (interrupt_cycle)
	or #01
	jr nz, upload_displayed_object_sprites_to_vdp_flip
	ld a, (n_displayed_object_sprites)
	ld iyl, a
	add a, a
	jr z, upload_displayed_object_sprites_to_vdp_uploaded
	add a, a
	ld b, a
	ld hl, sprite_attribute_table + FIRST_OBJECT_SPRITE * 4
	ld de, SPRATR2 + FIRST_OBJECT_SPRITE * 4
	call fast_small_LDIRVM

upload_displayed_object_sprites_to_vdp_uploaded:
	ld a, (n_displayed_object_sprites_last_frame)
	sub iyl  ; (n_displayed_object_sprites)
	ret z  ; same this frame than last, we are done
	jr c, upload_displayed_object_sprites_to_vdp_done  ; more sprites this frame than last, we are done

	; We need to clear the extra sprites from last frame:
	add a, a
	add a, a
	ld b, a  ; b = 4 * number of extra sprites last frame
	ld a, iyl  ; (n_displayed_object_sprites)
	add a, a
	add a, a
	ld d, 0
	ld e, a
	ld hl, SPRATR2 + FIRST_OBJECT_SPRITE * 4
	add hl, de
	ld a, #e0
	call fast_FILVRM_small

upload_displayed_object_sprites_to_vdp_done:
	ld a, iyl  ; (n_displayed_object_sprites)
	ld (n_displayed_object_sprites_last_frame), a
	ret

upload_displayed_object_sprites_to_vdp_flip:
	ld a, (n_displayed_object_sprites)
	ld iyl, a
	or a
	jr z, upload_displayed_object_sprites_to_vdp_uploaded
	ld hl, SPRATR2 + FIRST_OBJECT_SPRITE * 4
    call SETWRT
    ld a, iyl  ; (n_displayed_object_sprites)
	ld hl, sprite_attribute_table + FIRST_OBJECT_SPRITE * 4
	dec a
	add a, a
	add a, a
	ld b, 0
	ld c, a
	add hl, bc  ; hl points to the last sprite to upload
    ; the code here is equivalent to "fast_LDIRVM", but uploads sprites in reverse order:
    ld de, -8
    ; get the VDP write register:
    ld a, (VDP.DW)
    ld c, a
	ld a, iyl  ; (n_displayed_object_sprites)
upload_displayed_object_sprites_to_vdp_flip_loop:
	; note: we do not just unroll to 4 "outi", as that would be too fast for the MSX1 VDP.
	ld b, 4
upload_displayed_object_sprites_to_vdp_flip_loop2:
    outi
    jp nz, upload_displayed_object_sprites_to_vdp_flip_loop2
    add hl, de
    dec a
    jr nz, upload_displayed_object_sprites_to_vdp_flip_loop
	jp upload_displayed_object_sprites_to_vdp_uploaded

