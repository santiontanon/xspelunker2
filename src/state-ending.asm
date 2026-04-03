;-----------------------------------------------
; Ending C data:
ending_C_UFO_captain_looking:
	db 78, 158, 0, COLOR_GREEN
	db 78 + 5, 158, 4, COLOR_WHITE

ending_C_UFO_captain_idle:
	db 78, 158, 8, COLOR_GREEN
	db 78 + 5, 158, 12, COLOR_WHITE

ending_C_UFO_captain_talking:
	db 78, 158, 16, COLOR_GREEN
	db 78 + 5, 158, 20, COLOR_WHITE

ending_C_UFO_captain_agitated:
	db 78, 158, 24, COLOR_GREEN
	db 78 + 5, 158, 28, COLOR_WHITE

ending_C_UFO_captain_agitated_talking:
	db 78, 158, 32, COLOR_GREEN
	db 78 + 5, 158, 36, COLOR_WHITE

ending_C_UFO_minion_idle:
	db 77, 88, 40, COLOR_GREEN
	db 77 + 5, 88, 44, COLOR_PURPLE

ending_C_UFO_minion_talking:
	db 77, 88, 56, COLOR_GREEN
	db 77 + 5, 88, 60, COLOR_PURPLE


ending_C_beach_unbrealla_sprites:
	db 63, 57, 0, COLOR_RED
	db 63, 57, 4, COLOR_BLACK
ending_C_beach_elaine_michael_sprites:
	db 79, 140, 8, COLOR_LIGHT_RED
	db 79, 143, 12, COLOR_DARK_YELLOW
	db 79, 170, 16, COLOR_DARK_YELLOW
	db 79, 173, 20, COLOR_DARK_RED


;-----------------------------------------------
ending_C:
    ld sp, stack
	ld hl, TEXT_ENDING_C
	ld (stats__ending), hl

	call clear_screen_left_to_right

	call ending_UFO_scene_approach_earth  ; aliens approach Earth, and captain calls for the invasion
	call ending_UFO_scene_minion_interrupts  ; alien minion approaches and tells the captain something is wrong

	ld hl, TEXT_ENDING_C_UFO_8
	ld b, 32
	call ending_UFO_scene_minion_talks
        
	ld hl, TEXT_ENDING_C_UFO_9
	ld b, 32
	call ending_UFO_scene_captain_talks_agitated

	ld hl, TEXT_ENDING_C_UFO_10
	ld b, 32
	call ending_UFO_scene_captain_talks

	ld hl, TEXT_ENDING_C_UFO_11
	ld b, 32
	call ending_UFO_scene_minion_talks
        
	ld hl, TEXT_ENDING_C_UFO_12
	ld b, 64
	call ending_UFO_scene_captain_talks_agitated

	ld b, 100
	call wait_b_halts_skippable

	call clear_screen_left_to_right

	call ending_beach_scene  ; elaine and michael relax in the beach

	ld hl, state_game_over	
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_B:
    ld sp, stack
	ld hl, TEXT_ENDING_B
	ld (stats__ending), hl
	
	; ...

	ld hl, state_game_over	
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_A:
    ld sp, stack
	ld hl, TEXT_ENDING_A
	ld (stats__ending), hl
	
	; ...

	ld hl, state_game_over	
	ld a, GAME_OVER_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
ending_UFO_scene_approach_earth:
	call disable_VDP_output
		ld hl, ending_ufo_tiles_zx0
		ld c, ENDING_PAGE
		call decompress_tiles_to_all_banks

		ld hl, ending_ufo_nametables
		ld de, NAMTBL2 + 4*32+6
		ld bc, #0914
		call state_ending_copy_nametable

		ld hl, ending_ufo_sprites_zx0
		ld de, buffer_4096
		call dzx0

		ld hl, buffer_4096
		ld de, SPRTBL2
		ld bc, 512
		call fast_LDIRVM

		ld hl, ending_C_UFO_captain_looking
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 
	call enable_VDP_output

	ld b, 50
	call wait_b_halts

	; make earth appear:
	ld b, 5
	ld de, NAMTBL2 + 9*32 + 11
ending_UFO_scene_approach_earth_loop:
	push bc
		; earth:
		ld c, 10
		ld a, 6
		sub b
		ld b, a
		ld hl, ending_ufo_nametables + 20*9
		push bc
			push de
				call state_ending_copy_nametable
			pop hl
			ld bc, 12 + 32
			add hl, bc
			ex de, hl
		pop bc
		; moon:
		dec b
		jr z, ending_UFO_scene_approach_earth_loop_continue2
		ld c, 2
		ld a, b
		cp 3
		jr c, ending_UFO_scene_approach_earth_loop_continue
		ld b, 3
ending_UFO_scene_approach_earth_loop_continue:
		ld hl, ending_ufo_nametables + 20*9 + 10*6
		push bc
		push de
			call state_ending_copy_nametable
		pop de
		pop bc
ending_UFO_scene_approach_earth_loop_continue2:
		ex de, hl
		ld bc, -(12 + 32 + 32)
		add hl, bc
		ex de, hl

		ld b, 25
		call wait_b_halts
	pop bc
	djnz ending_UFO_scene_approach_earth_loop

	; captain asks for the invasion:
	ld hl, TEXT_ENDING_C_UFO_1
	ld b, 32
	jp ending_UFO_scene_captain_talks_agitated


;-----------------------------------------------
ending_UFO_scene_minion_interrupts:
	ld hl, ending_C_UFO_minion_idle
	ld de, buffer_4096
	ld bc, 8
	ldir

	ld b, 40
ending_UFO_scene_minion_interrupts_walk_loop:
	push bc
		ld a, 88
		sub b
		ld (buffer_4096 + 1), a
		ld (buffer_4096 + 1 + 4), a
		ld c, 40  ; idle
		bit 2, a
		jr nz, ending_UFO_scene_minion_interrupts_walk_loop_continue
		ld c, 48  ; walking
ending_UFO_scene_minion_interrupts_walk_loop_continue:
		ld a, c
		ld (buffer_4096 + 2), a
		add a, 4
		ld (buffer_4096 + 2 + 4), a
		ld hl, buffer_4096
		ld de, SPRATR2 + 4 * 2
		ld b, 8
		call fast_small_LDIRVM
		halt
		halt
	pop bc
	djnz ending_UFO_scene_minion_interrupts_walk_loop


	ld hl, TEXT_ENDING_C_UFO_2
	ld b, 32
	call ending_UFO_scene_minion_talks

	ld hl, TEXT_ENDING_C_UFO_3
	ld b, 32
	call ending_UFO_scene_captain_talks_agitated

	ld hl, TEXT_ENDING_C_UFO_4
	ld b, 32
	call ending_UFO_scene_minion_talks

	ld iy, TEXT_STORY10
	ld b, 1  ; first tile to use
	ld de, NAMTBL2 + 32*16 + 5
	ld ix, CHRTBL2 + 2*256*8
	ld a, COLOR_WHITE * 16
	ld (tmp_letter_line_color), a
	ld hl, display_paragraph_text_page3
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	ld b, 100
	call wait_b_halts_skippable
	call fast_small_LDIRVM 	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	call fast_FILVRM

	ld hl, TEXT_ENDING_C_UFO_5
	ld b, 32
	call ending_UFO_scene_captain_talks

	ld hl, TEXT_ENDING_C_UFO_6
	ld b, 32
	call ending_UFO_scene_minion_talks

	ld hl, TEXT_ENDING_C_UFO_7
	ld b, 32
	jp ending_UFO_scene_captain_talks_agitated


;-----------------------------------------------
; input:
; - hl: text
; - b: speech cycles to wait
ending_UFO_scene_captain_talks:
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_WHITE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page3
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
ending_UFO_scene_captain_talks_loop:
	push bc
		ld hl, ending_C_UFO_captain_idle
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 

		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_captain_talks_loop_skip
	push bc

		ld hl, ending_C_UFO_captain_talking
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 
		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_captain_talks_loop_skip
	djnz ending_UFO_scene_captain_talks_loop
ending_UFO_scene_captain_talks_loop_skip:
	ld hl, ending_C_UFO_captain_idle
	ld de, SPRATR2
	ld b, 8
	call fast_small_LDIRVM 	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	jp fast_FILVRM


;-----------------------------------------------
; input:
; - hl: text
; - b: speech cycles to wait
ending_UFO_scene_captain_talks_agitated:
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_WHITE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page3
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
ending_UFO_scene_captain_talks_agitated_loop:
	push bc
		ld hl, ending_C_UFO_captain_agitated
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 

		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_captain_talks_agitated_loop_skip
	push bc

		ld hl, ending_C_UFO_captain_agitated_talking
		ld de, SPRATR2
		ld b, 8
		call fast_small_LDIRVM 
		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_captain_talks_agitated_loop_skip
	djnz ending_UFO_scene_captain_talks_agitated_loop
ending_UFO_scene_captain_talks_agitated_loop_skip:
	ld hl, ending_C_UFO_captain_idle
	ld de, SPRATR2
	ld b, 8
	call fast_small_LDIRVM 	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	jp fast_FILVRM


;-----------------------------------------------
; input:
; - hl: text
; - b: speech cycles to wait
ending_UFO_scene_minion_talks
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld a, COLOR_PURPLE * 16
		ld (tmp_letter_line_color), a
		ld hl, display_paragraph_text_page3
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
ending_UFO_scene_minion_talks_loop:
	push bc
		ld hl, ending_C_UFO_minion_idle
		ld de, SPRATR2 + 4 * 2
		ld b, 8
		call fast_small_LDIRVM 

		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_minion_talks_loop_skip
	push bc

		ld hl, ending_C_UFO_minion_talking
		ld de, SPRATR2 + 4 * 2
		ld b, 8
		call fast_small_LDIRVM 
		ld b, 8
		call wait_b_halts_skippable
	pop bc
	jr nz, ending_UFO_scene_minion_talks_loop_skip
	djnz ending_UFO_scene_minion_talks_loop
ending_UFO_scene_minion_talks_loop_skip:
	ld hl, ending_C_UFO_minion_idle
	ld de, SPRATR2 + 4 * 2
	ld b, 8
	call fast_small_LDIRVM 	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	jp fast_FILVRM


;-----------------------------------------------
ending_beach_scene:
	call disable_VDP_output
		ld hl, ending_beach_tiles_zx0
		ld c, ENDING_PAGE
		call decompress_tiles_to_all_banks

		ld hl, ending_beach_nametables
		ld de, NAMTBL2 + 4*32+6
		ld bc, #0814
		call state_ending_copy_nametable

		ld hl, ending_beach_sprites_zx0
		ld de, buffer_4096
		call dzx0

		ld hl, buffer_4096
		ld de, SPRTBL2
		ld bc, 192
		call fast_LDIRVM

		ld hl, ending_C_beach_unbrealla_sprites
		ld de, SPRATR2
		ld b, 6*4
		call fast_small_LDIRVM 
	call enable_VDP_output

	call wait_for_click

	ret	


;-----------------------------------------------
; input:
; - hl: nametable
; - de: ptr to VDP
; - c, b: width, height
state_ending_copy_nametable:
state_ending_copy_nametable_loop_y:
	push bc
		push hl
			push de
				ld b, c
				call fast_small_LDIRVM
			pop hl
			ld bc, 32
			add hl, bc
			ex de, hl
		pop hl
	pop bc
	push bc
		ld b, 0
		add hl, bc
	pop bc
	djnz state_ending_copy_nametable_loop_y
	ret
