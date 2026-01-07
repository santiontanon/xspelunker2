braingames_logo_nametable:
	db 0, 0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0, 0, 0
	db 0, 0,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 0, 0
	db 0, 0, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 0, 0
	db 0, 0, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 0, 0
	db 0, 0, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 0, 0

braingames_logo_with_dust_nametable:
	db  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	db  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18
	db 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36
	db 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54
	db 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72


;-----------------------------------------------
state_braingames:
    ld sp, stack
	call clear_screen_left_to_right

	; upload the tile data to vdp:
	ld hl, braingames_tiles_zx0
	ld c, BRAINGAMES_TILES_PAGE
	call decompress_tiles_to_all_banks

	; drop brain games logo:
	ld c, -5
state_braingames_drop_loop:
	ld hl, braingames_logo_nametable
	push bc
		call state_braingames_draw_logo
	pop bc
	inc c
	ld a, c
	halt
	cp 10
	jr nz, state_braingames_drop_loop

	; dust:
	ld c, 10
	ld hl, braingames_logo_with_dust_nametable
	call state_braingames_draw_logo
	ld hl, SFX_explosion
	call play_SFX_with_high_priority
	ld b, 50
	call wait_b_halts_skippable
	jp nz, state_braingames_done

	; delete dust:
	ld c, 10
	ld hl, braingames_logo_nametable
	call state_braingames_draw_logo

	; wait:
	ld b, 250
	call wait_b_halts_skippable

state_braingames_done:
	jp state_title


;-----------------------------------------------
; input:
; - c: y coordinate (in tiles)
; - hl: logo version
state_braingames_draw_logo:
	; compute the start ptr, and the number of rows to draw:
	ld a, c
	or a
	jp p, state_braingames_draw_logo_positive
	; negative coordinate:
	add a, 5
	ret z  ; nothing to draw
	ret m  ; nothing to draw
	ld b, a
	ld de, NAMTBL2 + 7
	ld a, c
	neg
	ld c, a
	add a, a  ; * 2
	add a, a  ; * 4
	add a, a  ; * 8
	add a, c  ; * 9
	add a, a  ; * 18
	ADD_HL_A
	jr state_braingames_draw_logo_y_loop
state_braingames_draw_logo_positive:
	ex de, hl
		ld h, 0
		ld l, a
		add hl, hl
		add hl, hl
		add hl, hl
		add hl, hl
		add hl, hl
		ld bc, NAMTBL2 + 7
		add hl, bc
	ex de, hl
	ld b, 5
state_braingames_draw_logo_y_loop:
	push bc
		push hl
			push de
				ld b, 18
				call fast_small_LDIRVM
			pop hl
			ld bc, 32
			add hl, bc
			ex de, hl
		pop hl
		ld bc, 18
		add hl, bc
	pop bc
	djnz state_braingames_draw_logo_y_loop
	ret
