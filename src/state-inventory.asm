;-----------------------------------------------
state_inventory:
	ld hl, SFX_ui_select
	call play_SFX_with_high_priority

	call disable_VDP_output
		; Draw inventory screen:
		ld hl, NAMTBL2
		ld bc, 768
		xor a
		call fast_FILVRM
		call clear_all_the_sprites
	call enable_VDP_output

state_inventory_loop:
	halt
	call update_keyboard_buffers
	ld a, (keyboard_line_clicks + 2)
	bit 2, a
	jr nz, state_inventory_exit
	jr state_inventory_loop

state_inventory_exit:
	call disable_VDP_output
	jp state_play_from_inventory
