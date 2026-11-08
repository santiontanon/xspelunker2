;-----------------------------------------------
; this method checks for any events that should happen upon entering a room:
default_in_game_event_fn:
	ld a, (global_state__story)
	cp STORY_STATE__START
	jr z, default_in_game_event_fn_start
	ld a, (current_area__id)
	cp 10  ; mars
	jr z, default_in_game_event_fn_mars
	cp 11  ; moon
	jr z, default_in_game_event_fn_moon
	; ...
	ret

default_in_game_event_fn_start:
	ld a, (current_area__id)
	or a
	ret z
	; entered the ruins:
	ld de, TEXT_STORY_ENTER_RUINS
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000
	ld a, STORY_STATE__ENTERED_RUINS
	ld (global_state__story), a
	ret

default_in_game_event_fn_mars:
	ld a, (global_state__first_time_flags)
	bit 2, a  ; have we enterd mars before?
	ret nz
	; entered mars for the first time:
	ld de, TEXT_MARS_FIRST_TIME
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000
	ld hl, global_state__first_time_flags
	set 2, (hl)
	ret	

default_in_game_event_fn_moon:
	ld a, (global_state__first_time_flags)
	bit 3, a  ; have we enterd moon before?
	ret nz
	; entered moon for the first time:
	ld de, TEXT_MOON_FIRST_TIME
	ld hl, display_in_game_message_textpage3
	ld c, TEXT_PAGE
	call call_hl_in_page_c_8000
	ld hl, global_state__first_time_flags
	set 3, (hl)
	ret	

