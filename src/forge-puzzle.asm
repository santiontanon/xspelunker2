;-----------------------------------------------
forge_puzzle_closeup:
    ld sp, stack
	call clear_screen_left_to_right
	call disable_VDP_output

		ld hl, firestone_forge_puzzle_tiles12_zx0
		ld c, FORGE_PUZZLE_PAGE
		call decompress_tiles_to_all_banks
		
		ld hl, firestone_forge_puzzle_tiles3_zx0
		ld c, FORGE_PUZZLE_PAGE
	    ld de, buffer_4096
	    call dzx0_from_page_c
		call copy_tiles_to_bank3

		ld hl, firestone_forge_puzzle_nametables
		ld de, NAMTBL2 + 5
		ld bc, #1515  ; 21x21
		call forge_puzzle_copy_nametable

		call forge_puzzle_set_bitmap_mode_bottom_rows
	call enable_VDP_output

	ld a, (global_state__first_time_flags)
	bit 4, a
	jr nz, forge_puzzle_closeup_not_first_time
	set 4, a
	ld (global_state__first_time_flags), a
	ld hl, TEXT_FIRESTONE_PUZZLE_1_1
	ld de, CHRTBL2 + 256*8*2 + 130*8
	call forge_puzzle_text
	ld hl, TEXT_FIRESTONE_PUZZLE_1_2
	ld de, CHRTBL2 + 256*8*2 + (130+32)*8
	call forge_puzzle_text
	call wait_for_click
	call forge_puzzle_clear_text
forge_puzzle_closeup_not_first_time:

	ld hl, TEXT_FIRESTONE_PUZZLE_2_1
	ld de, CHRTBL2 + 256*8*2 + 130*8
	call forge_puzzle_text
	ld hl, TEXT_FIRESTONE_PUZZLE_2_2
	ld de, CHRTBL2 + 256*8*2 + (130+32)*8
	call forge_puzzle_text
	call wait_for_click
	call forge_puzzle_clear_text

	; which item does the player have selected? 54, 55, 56: codex
	ld a, (player_current_item)
	cp 54
	jr z, forge_puzzle_closeup_1_codex
	cp 55
	jr z, forge_puzzle_closeup_2_codex
	cp 56
	jr z, forge_puzzle_closeup_3_codex

	; it's not the codex:
	call disable_VDP_output	
	jp state_play_from_inventory


forge_puzzle_closeup_2_codex:
	call forge_puzzle_draw_codex2
forge_puzzle_closeup_1_codex:
	call forge_puzzle_draw_codex1

	ld hl, TEXT_FIRESTONE_PUZZLE_3_1
	ld de, CHRTBL2 + 256*8*2 + 130*8
	call forge_puzzle_text
	ld hl, TEXT_FIRESTONE_PUZZLE_3_2
	ld de, CHRTBL2 + 256*8*2 + (130+32)*8
	call forge_puzzle_text
	call wait_for_click
	call forge_puzzle_clear_text

	call disable_VDP_output	
	jp state_play_from_inventory


forge_puzzle_closeup_3_codex:
	call forge_puzzle_draw_codex1
	call forge_puzzle_draw_codex2
	call forge_puzzle_draw_codex3

	ld hl, TEXT_FIRESTONE_PUZZLE_3_1
	ld de, CHRTBL2 + 256*8*2 + 130*8
	call forge_puzzle_text
	call wait_for_click
	call forge_puzzle_clear_text

	; open the puzzle:
	ld hl, firestone_forge_puzzle_nametables + 21*21
	ld de, buffer_4096
	ld bc, 11*17
	ldir
	call forge_puzzle_closeup_update_control_nametable

	ld hl, buffer_4096 + 17*10
	ld de, NAMTBL2 + 7 + 32 * 11
	ld b, 11
forge_puzzle_closeup_3_codex_loop:
	push bc
		; scroll up the lid:
		push de
		push hl
			call forge_puzzle_close_up_scroll_lid_one_up
		pop hl
		pop de

		; draw the control panel below:
		push hl
			push de
				ld bc, #0111
				call forge_puzzle_copy_nametable

				ld hl, SFX_explosion_low_pitch
				call play_SFX_with_high_priority
				ld b, 20
				call wait_b_halts
			pop hl
			ld bc, -32
			add hl, bc
			ex de, hl
		pop hl
		ld bc, -17
		add hl, bc

	pop bc
	djnz forge_puzzle_closeup_3_codex_loop

; 	ld hl, buffer_4096
; 	ld de, NAMTBL2 + 7 + 32 * 1
; 	ld bc, #0b11
; 	call forge_puzzle_copy_nametable

	call wait_for_click

	call disable_VDP_output	
	jp state_play_from_inventory


;-----------------------------------------------
; input:
; - b: how many rows to move up
forge_puzzle_close_up_scroll_lid_one_up:
	push bc
		ld hl, NAMTBL2
		ld de, buffer_4096 + 256
		ld bc, 12*32
		call LDIRMV
	pop bc
	ld hl, buffer_4096 + 256 + 7 + 32
	ld de, NAMTBL2 + 7
forge_puzzle_close_up_scroll_lid_one_up_loop:
	push bc
		push hl
			push de
				ld b, 17
				call fast_small_LDIRVM 
			pop hl
			ld bc, 32
			add hl, bc
			ex de, hl
		pop hl
		ld bc, 32
		add hl, bc
	pop bc
	djnz forge_puzzle_close_up_scroll_lid_one_up_loop
	ret


;-----------------------------------------------
forge_puzzle_closeup_update_control_nametable:
	ld ix, buffer_4096 + 1 + 1*17
	ld de, (current_world__firestone_forge_state)
	ld b, 8
forge_puzzle_closeup_update_control_nametable_loop1:
	rl d
	push de
		push af
			call c, forge_puzzle_closeup_update_control_nametable_switch_up
		pop af
		call nc, forge_puzzle_closeup_update_control_nametable_switch_down
	pop de
	inc ix
	inc ix
	djnz forge_puzzle_closeup_update_control_nametable_loop1

	ld ix, buffer_4096 + 1 + 6*17
	ld d, e
	ld b, 8
forge_puzzle_closeup_update_control_nametable_loop2:
	rl d
	push de
		push af
			call c, forge_puzzle_closeup_update_control_nametable_switch_up
		pop af
		call nc, forge_puzzle_closeup_update_control_nametable_switch_down
	pop de
	inc ix
	inc ix
	djnz forge_puzzle_closeup_update_control_nametable_loop2
	ret

forge_puzzle_closeup_update_control_nametable_switch_up:
	ld a, (firestone_forge_puzzle_nametables + 21*21 + 1 + 17)
	ld (ix + 0), a
	ld a, (firestone_forge_puzzle_nametables + 21*21 + 1 + 34)
	ld (ix + 17), a
	ld (ix + 34), 0
	ld (ix + 51), 0 
	ret

forge_puzzle_closeup_update_control_nametable_switch_down:
	ld (ix + 0), 0
	ld (ix + 17), 0
	ld a, (firestone_forge_puzzle_nametables + 21*21 + 1 + 17)
	ld (ix + 34), a
	ld a, (firestone_forge_puzzle_nametables + 21*21 + 1 + 34)
	ld (ix + 51), a 
	ret


;-----------------------------------------------
forge_puzzle_draw_codex1:
	ld hl, firestone_forge_puzzle_nametables + 21*21 + 11*17
	ld de, NAMTBL2 + 9 + 32 * 13
	ld bc, #0603
	jp forge_puzzle_copy_nametable


;-----------------------------------------------
forge_puzzle_draw_codex2:
	ld hl, firestone_forge_puzzle_nametables + 21*21 + 11*17 + 6*3
	ld de, NAMTBL2 + 14 + 32 * 13
	ld bc, #0603
	jp forge_puzzle_copy_nametable


;-----------------------------------------------
forge_puzzle_draw_codex3:
	ld hl, firestone_forge_puzzle_nametables + 21*21 + 11*17 + 6*3*2
	ld de, NAMTBL2 + 19 + 32 * 13
	ld bc, #0603
	jp forge_puzzle_copy_nametable


;-----------------------------------------------
; input:
; - hl: text
; - de: CHRTBL2 ptr
forge_puzzle_text:
	push de
		ex de, hl
		ld hl, copy_text_from_another_page
		ld c, TEXT_PAGE3
		call call_hl_in_page_c_8000
	pop de
	ld hl, buffer_4096
	ld iy, #80f0
	ld b, 28
	jp draw_sentence_to_vdp_from_another_page


;-----------------------------------------------
forge_puzzle_clear_text:
	ld hl, CHRTBL2 + 256*8*2 + 128*8
	ld bc, 64*8
	xor a
	jp fast_FILVRM


;-----------------------------------------------
; input:
; - hl: nametable
; - de: ptr to VDP
; - c, b: width, height
forge_puzzle_copy_nametable:
forge_puzzle_copy_nametable_loop_y:
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
	djnz forge_puzzle_copy_nametable_loop_y
	ret


;-----------------------------------------------
forge_puzzle_set_bitmap_mode_bottom_rows:
	ld hl, NAMTBL2 + 32*22
    call SETWRT
    ld a, (VDP.DW)
    ld c, a
    ld a, 128
    ld b, 64
forge_puzzle_set_bitmap_mode_bottom_rows_loop:
    out (c), a
    inc a
    djnz forge_puzzle_set_bitmap_mode_bottom_rows_loop
