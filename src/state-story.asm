STATE_STORY_ONE_LINE_PAUSE: equ 80
STATE_STORY_TWO_LINE_PAUSE: equ 160


;-----------------------------------------------
state_story_sprite_attributes:
	db 119, 88, 10*4, COLOR_DARK_YELLOW
	db 119, 88, 11*4, COLOR_DARK_RED

	db 122, 176, 0*4, COLOR_DARK_YELLOW
	db 122, 176, 1*4, COLOR_DARK_RED

;-----------------------------------------------
state_story:
    ld sp, stack
	call clear_screen_left_to_right

	call stop_music
	ld hl, music_intro1_bin
	ld a, 6
	call play_music_adjusting_tempo

	call state_story_setup_gfx

	ld hl, story_nametable
	ld de, NAMTBL2 + 8 + 6*32
	ld bc, #c10
	call state_story_copy_nametable

	ld hl, state_story_sprite_attributes
	ld de, buffer_4096 + 1024
	ld bc, 16
	ldir

	; scene 1: Xavier arrives (half way):
	ld hl, 10*4 + (0*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 12*4 + (2*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld c, 176  ; Xavier x
state_story_scene1_loop:
	halt
	ld a, c
	ld (buffer_4096 + 1024 + 9), a
	ld (buffer_4096 + 1024 + 13), a
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	ld a, (interrupt_cycle)
	and #03
	jr nz, state_story_scene1_loop
	dec c
	ld a, c
	cp 160
	jr nz, state_story_scene1_loop

	; scene 2a: Xavier pauses 
	ld hl, 10*4 + (4*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 12*4 + (6*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld b, 50
state_story_scene2a_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene2a_loop

	; scene 2b: Elaine says "if it isn't Michael S. Xavier in person!?"
	ld hl, TEXT_STORY1
	ld de, TEXT_STORY2
	call state_story_render_text_two_lines
	call state_story_draw_elaine_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene2b_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene2b_loop

	; scene 3: Xavier walks all the way
	ld hl, story_nametable
	ld de, NAMTBL2 + 8 + 6*32
	ld bc, #c10
	call state_story_copy_nametable
	ld hl, 10*4 + (0*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 12*4 + (2*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld c, 160  ; Xavier x
state_story_scene3_loop:
	halt
	ld a, c
	ld (buffer_4096 + 1024 + 9), a
	ld (buffer_4096 + 1024 + 13), a
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	ld a, (interrupt_cycle)
	and #03
	jr nz, state_story_scene3_loop
	dec c
	ld a, c
	cp 110
	jr nz, state_story_scene3_loop

	; scene 4: Xavier says: "Elaine!! Did you receive my letters?"
	call state_story_clear_text_tiles
	ld hl, TEXT_STORY3
	ld de, TEXT_STORY4
	call state_story_render_text_two_lines
	call state_story_draw_xavier_bubble

	ld hl, 10*4 + (4*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 12*4 + (6*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene4_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene4_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 5: Xavier says: "I made a huge discovery!"
	call state_story_clear_text_tiles
	ld hl, TEXT_STORY5
	ld de, TEXT_STORY6
	call state_story_render_text_two_lines
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene5_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene5_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 6: Elaine says "Sigh... what is it this time?"
	ld hl, TEXT_STORY7
	ld de, TEXT_STORY8
	call state_story_render_text_two_lines
	call state_story_draw_elaine_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene6_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene6_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 7: Elaine says "Aliens?"
	ld hl, TEXT_STORY9
	call state_story_render_text_one_line
	call state_story_draw_elaine_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene7_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene7_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 8: Xavier says "..."
	ld hl, TEXT_STORY10
	call state_story_render_text_one_line
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_ONE_LINE_PAUSE
state_story_scene8_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene8_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 8: Xavier says "This time it's real!"
	ld hl, TEXT_STORY11
	call state_story_render_text_one_line
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_ONE_LINE_PAUSE
state_story_scene9_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene9_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 10: Xavier says "Look! Proof!"
	ld hl, TEXT_STORY12
	call state_story_render_text_one_line
	call state_story_draw_xavier_bubble
	ld hl, story_nametable_frame2
	ld de, NAMTBL2 + 11 + 15*32
	ld bc, #0303
	call state_story_copy_nametable
	ld hl, 10*4 + (8*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 10*4 + (8*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene10_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene10_loop

	ld b, 30
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 11: Elaine says "Wait! You Serious? What's this?"
	ld hl, TEXT_STORY13
	ld de, TEXT_STORY14
	call state_story_render_text_two_lines
	call state_story_draw_elaine_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene11_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene11_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip


	; scene 12: Xavier says "Soemthing I found in Palenque!"
	ld hl, TEXT_STORY15
	ld de, TEXT_STORY16
	call state_story_render_text_two_lines
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene12_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene12_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip


	; scene 13: Xavier says "I took it from the corpse of an alien!"
	ld hl, TEXT_STORY17
	ld de, TEXT_STORY18
	call state_story_render_text_two_lines
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene13_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene13_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 14: Elaine says "Wait! You Serious? What's this?"
	ld hl, TEXT_STORY19
	ld de, TEXT_STORY20
	call state_story_render_text_two_lines
	call state_story_draw_elaine_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene14_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene14_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; clear screen:
	call clear_all_the_sprites
	ld hl, NAMTBL2
	xor a
	ld bc, 768
	call fast_FILVRM

	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	; scene 15: artifact zoom:
	ld hl, story_nametable_artifact1
	ld de, NAMTBL2 + 14 + 6*32
	ld bc, #0a03
	call state_story_copy_nametable
	ld b, 60
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY21
	call state_story_draw_text_zoom_in

	ld b, STATE_STORY_ONE_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	; scene 16: Elaine's hand touches the artifact
	call state_story_clear_text_tiles

	ld ixl, 5
state_story_scene16_loop:
	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip
	ld hl, story_nametable_hand
	ld de, NAMTBL2 + 8 + 8*32
	ld bc, #0406
	call state_story_copy_nametable_cropped
	call state_story_check_for_skip
	jp nz, state_story_skip
	ld a, ixl
	dec ixl
	or a
	jr nz, state_story_scene16_loop

	; scene 17: artifact opens
	ld hl, SFX_item_pickup
	call play_SFX_with_high_priority
	ld hl, story_nametable_artifact2a
	ld de, NAMTBL2 + 14 + 6*32
	ld bc, #0503
	call state_story_copy_nametable
	ld hl, story_nametable_artifact2b + 3
	ld de, NAMTBL2 + 14 + 11*32
	ld bc, #0603
	call state_story_copy_nametable

	ld b, 30
	call wait_b_halts_skippable
	jp nz, state_story_skip

	; scene 17: bottom half of the artifact falls
	ld ixl, 7
	ld de, NAMTBL2 + 14 + 11*32
state_story_scene17_loop:
	push de
		ld hl, story_nametable_artifact2b
		ld c, 3
		ld b, ixl
		call state_story_copy_nametable
		ld b, 8
		call wait_b_halts_skippable
		jp nz, state_story_skip
	pop hl
	ld bc, 32
	add hl, bc
	ex de, hl
	dec ixl
	jr nz, state_story_scene17_loop

	ld b, 30
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld hl, SFX_explosion
	call play_SFX_with_high_priority

	ld de, TEXT_STORY22
	call state_story_draw_text_zoom_in

	ld b, STATE_STORY_ONE_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	; clear screen:
	ld hl, NAMTBL2
	xor a
	ld bc, 768
	call fast_FILVRM

	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	; scene 18: zoom out again, with artifact broken
	ld hl, story_nametable
	ld de, NAMTBL2 + 8 + 6*32
	ld bc, #c10
	call state_story_copy_nametable
	ld hl, story_nametable_frame3
	ld de, NAMTBL2 + 11 + 15*32
	ld bc, #0303
	call state_story_copy_nametable
	ld hl, 14*4 + (8*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 14*4 + (8*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld b, 60
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 19: Xaviers complains Elaine broke it
	ld hl, TEXT_STORY23
	ld de, TEXT_STORY24
	call state_story_render_text_two_lines
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene19_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene19_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 20: Xavier realizes there is something inside
	ld hl, TEXT_STORY25
	ld de, TEXT_STORY26
	call state_story_render_text_two_lines
	call state_story_draw_xavier_bubble
	ld hl, story_nametable_frame4
	ld de, NAMTBL2 + 11 + 15*32
	ld bc, #0303
	call state_story_copy_nametable
	ld hl, 10*4 + (4*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 12*4 + (6*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene20_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene20_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 21: Xavier realizes there is something inside part 2
	ld hl, TEXT_STORY27
	ld de, TEXT_STORY28
	call state_story_render_text_two_lines
	call state_story_draw_xavier_bubble
	ld hl, story_nametable_frame5
	ld de, NAMTBL2 + 11 + 15*32
	ld bc, #0303
	call state_story_copy_nametable
	ld hl, 10*4 + (8*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 10*4 + (8*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene21_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene21_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 22: Elaine claims credit
	ld hl, TEXT_STORY29
	ld de, TEXT_STORY30
	call state_story_render_text_two_lines
	call state_story_draw_elaine_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene22_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene22_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; clear screen:
	call clear_all_the_sprites
	ld hl, NAMTBL2
	xor a
	ld bc, 768
	call fast_FILVRM

	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	; scene 23: map zoom:
	; initialize the game state, so that the map is shown with only the first piece:
	ld hl, RAM_to_zero_on_game_start
	ld bc, (RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start) - 1
	call clear_memory
	ld hl, display_map_draw_map_internal
	ld c, MAP_PAGE
	call call_hl_in_page_c_8000

	ld b, 30
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY31
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY32
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	call state_story_clear_text_tiles
	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY33
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY34
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	call state_story_clear_text_tiles
	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY35
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY36
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY37
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY38
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	call state_story_clear_text_tiles
	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY39
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	call state_story_clear_text_tiles
	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY40
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY41
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY42
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY43
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY44
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY45
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	ld de, TEXT_STORY46
	call state_story_draw_text_zoom_in_24
	ld b, STATE_STORY_TWO_LINE_PAUSE
	call wait_b_halts_skippable
	jp nz, state_story_skip

	call state_story_clear_text_tiles
	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	; clear screen:
	ld hl, NAMTBL2
	xor a
	ld bc, 768
	call fast_FILVRM

	ld b, 15
	call wait_b_halts_skippable
	jp nz, state_story_skip

	; scene 24: back to zoom out, Elaine is surprised Xavier does not know Maya
	call state_story_setup_gfx
	ld hl, state_story_sprite_attributes
	ld de, buffer_4096 + 1024
	ld bc, 16
	ldir
	ld a, 110
	ld (buffer_4096 + 1024 + 9), a
	ld (buffer_4096 + 1024 + 13), a

	ld hl, story_nametable
	ld de, NAMTBL2 + 8 + 6*32
	ld bc, #c10
	call state_story_copy_nametable
	ld hl, story_nametable_frame6
	ld de, NAMTBL2 + 11 + 15*32
	ld bc, #0303
	call state_story_copy_nametable
	ld hl, 10*4 + (4*4*256)
	ld (buffer_4096 + 1024 + 16), hl
	ld hl, 12*4 + (6*4*256)
	ld (buffer_4096 + 1024 + 18), hl
	ld b, 60
	call state_story_pause_state_removing_bubble

	ld hl, TEXT_STORY47
	ld de, TEXT_STORY48
	call state_story_render_text_two_lines
	call state_story_draw_elaine_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene24_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene24_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 25: Xavier: ...
	ld hl, TEXT_STORY10
	call state_story_render_text_one_line
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_ONE_LINE_PAUSE
state_story_scene25_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene25_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 26: Elaine says it's too dangerous
	ld hl, TEXT_STORY49
	ld de, TEXT_STORY50
	call state_story_render_text_two_lines
	call state_story_draw_elaine_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene26_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene26_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 27: Xavier says he's ready
	ld hl, TEXT_STORY51
	ld de, TEXT_STORY52
	call state_story_render_text_two_lines
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene27_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene27_loop

	ld b, 15
	call state_story_pause_state_removing_bubble
	jp nz, state_story_skip

	; scene 28: Xavier says he's ready (2)
	ld hl, TEXT_STORY53
	call state_story_render_text_one_line
	call state_story_draw_xavier_bubble
	ld b, STATE_STORY_TWO_LINE_PAUSE
state_story_scene28_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	jp nz, state_story_skip
	djnz state_story_scene28_loop

	ld b, 60
	call state_story_pause_state_removing_bubble
	; jp nz, state_story_skip

state_story_skip:
	ld hl, state_braingames
	ld a, BRAINGAMES_PAGE
	jp jp_to_hl_in_page_a_8000


;-----------------------------------------------
; output:
; - z: no skip
; - nz: skip
state_story_check_for_skip:
    call update_keyboard_buffers
    ld a, (keyboard_clicks)
    bit KEY_WEAPON_BIT, a
    ret


;-----------------------------------------------
; input:
; - de: text ptr
state_story_draw_text_zoom_in_nametable:
	db 128, 129, 130, 131
	db 132, 133, 134, 135
	db 136, 137, 138, 139
	db 140, 141, 142, 143
	db 144, 145, 146, 147
	db 148, 149, 150, 151

state_story_draw_text_zoom_in:
	call state_story_clear_text_tiles

	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096, CHRTBL2 + 256*8*2 + 128*8, COLOR_WHITE*16, 16

	ld hl, state_story_draw_text_zoom_in_nametable
	ld de, NAMTBL2 + 32*20 + 8
	ld bc, 16
	jp fast_LDIRVM


state_story_draw_text_zoom_in_24:
	call state_story_clear_text_tiles

	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096, CHRTBL2 + 256*8*2 + 128*8, COLOR_WHITE*16, 24

	ld hl, state_story_draw_text_zoom_in_nametable
	ld de, NAMTBL2 + 32*20 + 4
	ld bc, 24
	jp fast_LDIRVM


;-----------------------------------------------
; input:
; - b: duration in frames
; output:
; - z: no skip
; - nz: skip
state_story_pause_state_removing_bubble:
	push bc
		ld hl, NAMTBL2 + 11 + 11*32
		xor a
		ld b, 12
		call fast_small_FILVRM
		ld hl, NAMTBL2 + 11 + 12*32
		xor a
		ld b, 12
		call fast_small_FILVRM
		ld hl, NAMTBL2 + 11 + 13*32
		xor a
		ld b, 12
		call fast_small_FILVRM
		ld hl, NAMTBL2 + 11 + 14*32
		xor a
		ld b, 12
		call fast_small_FILVRM
	pop bc
state_story_pause_state_removing_bubble_loop:
	halt
	push bc
		call state_story_draw_sprites
		call state_story_check_for_skip
	pop bc
	ret nz
	djnz state_story_pause_state_removing_bubble_loop
	xor a  ; no skip
	ret


;-----------------------------------------------
; input:
; - hl: text line 1
; - de: text line 2
state_story_render_text_two_lines:
	push de
		push hl
			call state_story_clear_text_tiles
		pop de
		ld hl, copy_text_from_another_page
		ld c, TEXT_PAGE3
		call call_hl_in_page_c_8000
		DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096, CHRTBL2 + 256*8 + 128*8, COLOR_WHITE, 10
	pop de
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096, CHRTBL2 + 256*8 + (128+10)*8, COLOR_WHITE, 10
	ret


;-----------------------------------------------
; input:
; - hl: text line 1
state_story_render_text_one_line:
	push hl
		call state_story_clear_text_tiles
	pop de
	ld hl, copy_text_from_another_page
	ld c, TEXT_PAGE3
	call call_hl_in_page_c_8000
	DRAW_SENTENCE_TO_VDP_REMOTE_MACRO buffer_4096, CHRTBL2 + 256*8 + 128*8, COLOR_WHITE, 10
	ret


;-----------------------------------------------
state_story_draw_xavier_bubble:
	ld hl, story_bubble_nametable
	ld de, NAMTBL2 + 11 + 11*32
	ld bc, #40c
	call state_story_copy_nametable
	ld hl, NAMTBL2 + 13 + 14*32
	ld a, (story_bubble_nametable + 3*12 + 1)
	ld b, 1
	call fast_small_FILVRM
	ld hl, NAMTBL2 + 16 + 14*32
	ld a, (story_bubble_nametable + 3*12 + 2)
	ld b, 1
	jp fast_small_FILVRM


;-----------------------------------------------
state_story_draw_elaine_bubble:
	ld hl, story_bubble_nametable
	ld de, NAMTBL2 + 11 + 11*32
	ld bc, #40c
	jp state_story_copy_nametable


;-----------------------------------------------
state_story_clear_text_tiles:
	ld hl, CLRTBL2 + 256*8 + 128*8
	ld a, COLOR_WHITE
	ld b, 24*8
	call fast_small_FILVRM

	ld hl, CHRTBL2 + 256*8 + 128*8
	xor a
	ld b, 24*8
	call fast_small_FILVRM

	ld hl, CLRTBL2 + 256*2*8 + 128*8
	ld a, COLOR_WHITE*16
	ld b, 24*8
	call fast_small_FILVRM

	ld hl, CHRTBL2 + 256*2*8 + 128*8
	xor a
	ld b, 24*8
	jp fast_small_FILVRM


;-----------------------------------------------
; input:
; - frames to use in (buffer_4096 + 16) and (buffer_4096 + 18)
state_story_draw_sprites:
	ld ix, buffer_4096 + 1024
	ld a, (interrupt_cycle)
	bit 4, a
	jr z, state_story_scene1_loop_frame2
state_story_scene1_loop_frame1:
	ld hl, (buffer_4096 + 1024 + 16)
	jr state_story_scene1_loop_frame_set
state_story_scene1_loop_frame2:
	ld hl, (buffer_4096 + 1024 + 18)
state_story_scene1_loop_frame_set:
	ld (ix + 2), l
	ld (ix + 8 + 2), h
	ld bc, #0404
	add hl, bc
	ld (ix + 4 + 2), l
	ld (ix + 12 + 2), h

	ld hl, buffer_4096 + 1024
	ld de, SPRATR2
	ld b, 16
	jp fast_small_LDIRVM


;-----------------------------------------------
; input:
; - hl: nametable
; - de: ptr to VDP
; - c, b: width, height
state_story_copy_nametable:
state_story_copy_nametable_loop_y:
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
	djnz state_story_copy_nametable_loop_y
	ret


;-----------------------------------------------
; input:
; - hl: nametable
; - de: ptr to VDP
; - c, b: width, height
; - ixl: amount to crop from the left
state_story_copy_nametable_cropped:
state_story_copy_nametable_cropped_loop_y:
	push bc
		push hl
			push de
				ld a, ixl
				ADD_HL_A
				ld a, c
				sub ixl
				ld b, a
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
	djnz state_story_copy_nametable_cropped_loop_y
	ret


;-----------------------------------------------
state_story_setup_gfx:
	ld hl, story_tiles_zx0
	ld c, STORY_PAGE
	call decompress_tiles_to_all_banks

	ld hl, story_sprites_zx0
	ld de, buffer_4096 + 1024
	ld c, STORY_PAGE
	call dzx0_from_page_c
	ld hl, buffer_4096 + 1024
	ld de, SPRTBL2
	ld bc, 16*32
	jp fast_LDIRVM