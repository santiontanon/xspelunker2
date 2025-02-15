;-----------------------------------------------
state_play:
	ld sp, stack  ; reset the stack, so we can jump here from wherever we want

	; setup tiles:
	ld a, TILES_PAGE
	ld hl, tiles_pyramid_zx0
	call setup_game_tiles

	; get room data:
	SETMEGAROMPAGE_8000 MAP_DATA_PAGE
	ld hl, hardcoded_room_data
	ld de, current_room__layout
	ld bc, hardcoded_room_data_end - hardcoded_room_data
	ldir

	xor a
state_play_loop:
	halt
	push af
		rrca
		rrca
; 		and #3f
; 		ld b, 0
; 		ld c, a
		and #0f
		ld b, a
		ld c, #40
		call draw_room
	pop af
	inc a
	jr state_play_loop


