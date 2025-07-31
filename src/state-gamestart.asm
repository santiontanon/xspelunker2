;-----------------------------------------------
state_gamestart:
    ld sp, stack
	call clear_screen_left_to_right

	; ...

	jp state_play
