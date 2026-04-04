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

ending_C_beach_elaine_michael_sprites2:
	db 80, 140, 8, COLOR_LIGHT_RED
	db 80, 143, 12, COLOR_DARK_YELLOW
	db 80, 170, 16, COLOR_DARK_YELLOW
	db 80, 173, 20, COLOR_DARK_RED


;-----------------------------------------------
ending_C:
    ld sp, stack
	ld hl, TEXT_ENDING_C
	ld (stats__ending), hl

; 	ld de, TEXT_CALENDAR_ACTIVATED_C_2
; 	ld hl, display_in_game_message_textpage3
; 	ld c, TEXT_PAGE
; 	call call_hl_in_page_c_8000	

; 	ld de, TEXT_CALENDAR_ACTIVATED_C_3
; 	ld hl, display_in_game_message_textpage3
; 	ld c, TEXT_PAGE
; 	call call_hl_in_page_c_8000	

; 	ld de, TEXT_CALENDAR_ACTIVATED_C_4
; 	ld hl, display_in_game_message_textpage3
; 	ld c, TEXT_PAGE
; 	call call_hl_in_page_c_8000	

; 	ld de, TEXT_CALENDAR_ACTIVATED_C_5
; 	ld hl, display_in_game_message_textpage3
; 	ld c, TEXT_PAGE
; 	call call_hl_in_page_c_8000	

; 	call clear_screen_left_to_right

; 	call ending_UFO_scene_approach_earth  ; aliens approach Earth, and captain calls for the invasion

; 	; Custom Ending C part of the UFO scene:	
; 	call ending_UFO_scene_minion_interrupts  ; alien minion approaches and tells the captain something is wrong
; 	ld hl, TEXT_ENDING_C_UFO_8
; 	ld b, 32
; 	call ending_UFO_scene_minion_talks
        
; 	ld hl, TEXT_ENDING_C_UFO_9
; 	ld b, 32
; 	call ending_UFO_scene_captain_talks_agitated

; 	ld hl, TEXT_ENDING_C_UFO_10
; 	ld b, 32
; 	call ending_UFO_scene_captain_talks

; 	ld hl, TEXT_ENDING_C_UFO_11
; 	ld b, 32
; 	call ending_UFO_scene_minion_talks
        
; 	ld hl, TEXT_ENDING_C_UFO_12
; 	ld b, 64
; 	call ending_UFO_scene_captain_talks_agitated

; 	ld b, 100
; 	call wait_b_halts_skippable
; 	call clear_screen_left_to_right

; 	call ending_beach_scene_C  ; elaine and michael relax in the beach

	call clear_screen_left_to_right

	ld ix, ending_C_text_page_ptrs
	ld b, 1  ; # number of pages
	call ending_final_text_scene

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

	ld iy, TEXT_ENDING_C_UFO_0
	ld b, 1  ; first tile to use
	ld de, NAMTBL2 + 12*32 + 8
	ld ix, CHRTBL2 + 1*256*8
	ld a, 16
	ld (tmp_letter_line_width), a
	ld a, COLOR_WHITE * 16
	ld (tmp_letter_line_color), a
	ld hl, display_paragraph_text_page3
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	ld b, 200
	call wait_b_halts_skippable
	call clear_screen_left_to_right

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
ending_UFO_scene_minion_talks:
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
ending_beach_scene_C:
	ld iy, TEXT_ENDING_C_BEACH_0
	ld b, 1  ; first tile to use
	ld de, NAMTBL2 + 12*32 + 10
	ld ix, CHRTBL2 + 1*256*8
	ld a, 16
	ld (tmp_letter_line_width), a
	ld a, COLOR_WHITE * 16
	ld (tmp_letter_line_color), a
	ld hl, display_paragraph_text_page3
	ld c, TABLET_LETTER_PAGE
	call call_hl_in_page_c_8000
	ld b, 200
	call wait_b_halts_skippable
	call clear_screen_left_to_right

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

	ld b, 2
	call ending_beach_scene_C_wait_skippable

	ld hl, TEXT_ENDING_C_BEACH_1
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_2
	ld a, COLOR_WHITE * 16
	ld b, 4
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_3
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_4
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_5
	ld a, COLOR_WHITE * 16
	ld b, 7
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_AMBUSH_ELAINE_3
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_7
	ld a, COLOR_WHITE * 16
	ld b, 8
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_8
	ld a, COLOR_WHITE * 16
	ld b, 3
	call ending_beach_scene_C_dialogue_line

	ld hl, TEXT_ENDING_C_BEACH_9
	ld a, COLOR_WHITE * 16
	ld b, 10
	jp ending_beach_scene_C_dialogue_line


;-----------------------------------------------
; input:
; - b: wait animation cycles
ending_beach_scene_C_dialogue_line:
	ld (tmp_letter_line_color), a
	push bc
		push hl
		pop iy
		ld b, 1  ; first tile to use
		ld de, NAMTBL2 + 32*16 + 5
		ld ix, CHRTBL2 + 2*256*8
		ld a, 24
		ld (tmp_letter_line_width), a
		ld hl, display_paragraph_text_page3
		ld c, TABLET_LETTER_PAGE
		call call_hl_in_page_c_8000
	pop bc
	call ending_beach_scene_C_wait_skippable	
	ld hl, CLRTBL2 + 2*256*8
	ld bc, 256*8
	xor a
	call fast_FILVRM
	ld b, 25
	jp wait_b_halts_skippable


;-----------------------------------------------
; input:
; - b: number of animation cycles
ending_beach_scene_C_wait_skippable:
	push bc
		call ending_beach_scene_C_frame2
		ld b, 50
		call wait_b_halts_skippable
		jr nz, ending_beach_scene_C_wait_skippable_skip
		call ending_beach_scene_C_frame1
		ld b, 50
		call wait_b_halts_skippable
		jr nz, ending_beach_scene_C_wait_skippable_skip
	pop bc
	djnz ending_beach_scene_C_wait_skippable
	ret
ending_beach_scene_C_wait_skippable_skip:
	pop bc
	jp ending_beach_scene_C_frame1  ; always end in frame 1


;-----------------------------------------------
ending_beach_scene_C_frame1:
	ld hl, ending_beach_nametables + 4*20+14
	ld de, NAMTBL2 + (4+4)*32 + (6+14)
	ld bc, #0103
	call state_ending_copy_nametable

	ld hl, ending_beach_nametables + 5*20+14
	ld de, NAMTBL2 + (4+5)*32 + (6+14)
	ld bc, #0103
	call state_ending_copy_nametable

	ld hl, ending_beach_nametables + 6*20+11
	ld de, NAMTBL2 + (4+6)*32 + (6+11)
	ld bc, #0107
	call state_ending_copy_nametable

	ld hl, ending_beach_nametables + 7*20+11
	ld de, NAMTBL2 + (4+7)*32 + (6+11)
	ld bc, #0107
	call state_ending_copy_nametable

	ld hl, ending_C_beach_elaine_michael_sprites
	ld de, SPRATR2 + 4*2
	ld b, 4*4
	jp fast_small_LDIRVM 


;-----------------------------------------------
ending_beach_scene_C_frame2:
	ld hl, ending_beach_nametables + 20*8
	ld de, NAMTBL2 + (4+4)*32 + (6+14)
	ld bc, #0203
	call state_ending_copy_nametable

	ld hl, ending_beach_nametables + 20*8 + 2*3
	ld de, NAMTBL2 + (4+6)*32 + (6+11)
	ld bc, #0207
	call state_ending_copy_nametable

	ld hl, ending_C_beach_elaine_michael_sprites2
	ld de, SPRATR2 + 4*2
	ld b, 4*4
	jp fast_small_LDIRVM 


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


;-----------------------------------------------
ending_C_text_page_ptrs:
	dw ending_C_text_page_1
	; dw ending_C_text_page_2
	; dw ending_C_text_page_3


ending_C_text_page_1:
	db 16
	dw TEXT_ENDING_C_PAGE_1_1
	dw TEXT_ENDING_C_PAGE_1_2
	dw TEXT_ENDING_C_PAGE_1_3
	dw TEXT_ENDING_C_PAGE_1_4
	dw TEXT_ENDING_C_PAGE_1_5
	dw TEXT_ENDING_C_PAGE_1_6
	dw TEXT_ENDING_C_PAGE_1_7
	dw TEXT_ENDING_C_PAGE_1_8
	dw TEXT_ENDING_C_PAGE_1_9
	dw TEXT_ENDING_C_PAGE_1_10
	dw TEXT_ENDING_C_PAGE_1_11
	dw TEXT_ENDING_C_PAGE_1_12
	dw TEXT_ENDING_C_PAGE_1_13
	dw TEXT_ENDING_C_PAGE_1_14
	dw TEXT_ENDING_C_PAGE_1_15
	dw TEXT_ENDING_C_PAGE_1_16


;-----------------------------------------------
; input:
; - ix: ptr to page ptrs
; - b: number of pages
ending_final_text_scene:
	push bc
		call set_bitmap_mode
	pop bc
ending_final_text_scene_loop:
	push ix
	push bc
ending_final_text_scene_pages_loop:
		push bc
		push ix
			; clear the text area:
			ld b, 16
			ld hl, CHRTBL2 + 8 * (4*32 + 12)
ending_final_text_scene_clear_text_area_loop1:
			push bc
				push hl
					ld bc, 20*8
					xor a
					call fast_FILVRM
				pop hl
				ld bc, 32*8
				add hl, bc
			pop bc
			djnz ending_final_text_scene_clear_text_area_loop1
			ld b, 16
			ld hl, CLRTBL2 + 8 * (4*32 + 12)
ending_final_text_scene_clear_text_area_loop2:
			push bc
				push hl
					ld bc, 20*8
					xor a
					call fast_FILVRM
				pop hl
				ld bc, 32*8
				add hl, bc
			pop bc
			djnz ending_final_text_scene_clear_text_area_loop2

			; Draw the text:
			ld a, (ix)
			ld b, (ix + 1)
			ld ixl, a
			ld ixh, b
			ld b, (ix)  ; number of sentences
			inc ix
			ld de, CHRTBL2 + 8 * (4*32 + 12)
ending_final_text_scene_sentences_loop:
			push bc
			push ix
				push de
					push de
						ld e, (ix)
						ld d, (ix + 1)
						ld hl, copy_text_from_another_page
						ld c, TEXT_PAGE3
						call call_hl_in_page_c_8000

						ld hl, clear_text_rendering_buffer
						ld c, TEXT_PAGE
						call call_hl_in_page_c_8000

						ld iyh, #80
						ld hl, draw_sentence_to_vdp_internal_from_buffer_4096
						ld c, TEXT_PAGE
						call call_hl_in_page_c_8000
					pop de  ; target VRAM address

					; Render character by character:
					ld b, 20
					ld hl, text_draw_buffer
ending_final_text_scene_character_loop:
					push bc
						push hl
							push de
								push de
									ld b, 8
									call fast_small_LDIRVM
								pop hl
								ld bc, CLRTBL2 - CHRTBL2
								add hl, bc

								; fade in:
								push hl
									ld a, COLOR_DARK_BLUE*16
									ld b, 8
									call fast_small_FILVRM
								pop hl
								halt
								halt
								push hl
									ld a, COLOR_BLUE*16
									ld b, 8
									call fast_small_FILVRM
								pop hl
								halt
								halt
								push hl
									ld a, COLOR_LIGHT_BLUE*16
									ld b, 8
									call fast_small_FILVRM
								pop hl
								halt
								halt
								push hl
									ld a, COLOR_WHITE*16
									ld b, 8
									call fast_small_FILVRM
								pop hl
								halt
								halt
							pop hl
							ld c, 8  ; b == 0 here
							add hl, bc
							ex de, hl
						pop hl
						ld c, 8  ; b == 0 here already
						add hl, bc
					pop bc
					djnz ending_final_text_scene_character_loop
				pop hl
				ld bc, 32*8
				add hl, bc
				ex hl, de
			pop ix
			pop bc
			inc ix  ; next line
			inc ix
			dec b
			jp nz, ending_final_text_scene_sentences_loop
		pop ix
		pop bc
		inc ix  ; next page
		inc ix
		dec b
		jp nz, ending_final_text_scene_pages_loop
		ld b, 200
		call wait_b_halts_skippable
	pop bc
	pop ix
	jp ending_final_text_scene_loop


