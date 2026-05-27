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

	call disable_VDP_output	
	jp state_play_from_inventory


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
