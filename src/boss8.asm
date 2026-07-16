;-----------------------------------------------
tile_collision_types_boss8:
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 1, 2, 1, 1, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0


;-----------------------------------------------
calendar_room_full_activation:
    ld a, 1
    ld (global_state__solved_final_riddle), a
    ld a, (current_room__tileset_page)
    ld c, a
    ld hl, (current_room__tileset_ptr)
    call setup_game_tiles_only_biome

    ld de, TEXT_TALK_CALENDAR_SUCCESS1
    ld hl, display_in_game_message
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS2
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS3
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS4
    call calendar_room_full_activation_yes_no_dialogue
    ld a, (tmp_dialog_pointer_position)

    or a
    jr nz, calendar_room_full_activation_do_not_destroy
    ld hl, ending_B_UFO_scene
    ld c, ENDING_PAGE
    call call_hl_in_page_c_8000

    ; ...

    jp state_play_from_inventory

calendar_room_full_activation_do_not_destroy:

    ; ...

    jp state_play_from_inventory


calendar_room_full_activation_yes_no_dialogue:
    ld hl, copy_text_from_another_page
    ld c, TEXT_PAGE4
    call call_hl_in_page_c_8000
    ld de, buffer_4096
    ld hl, display_in_game_message_draw_message
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_YES, CHRTBL2 + (14*32+14)*8, #f0, 4
    DRAW_SENTENCE_TO_VDP_REMOTE_MACRO TEXT_NO, CHRTBL2 + (15*32+14)*8, #f0, 4

    ; destroy threat yes/no:
    ld a, 13 * 8 - 1  ; y coordinate of the first option
    ld (tmp_dialog_options_position), a
    ld hl, dialog_sprites_bin
    ld de, SPRTBL2
    ld bc, dialog_sprites_bin_end - dialog_sprites_bin
    call fast_LDIRVM_from_sprites_page
    ld hl, state_yesno_dialog_mainloop
    ld c, YES_NO_DIALOG_PAGE
    call call_hl_in_page_c_8000

    ; restore tiles in middle bank:
    ld hl, CLRTBL2 + (256 + 16*6)*8
    ld bc, (256-16*6)*8
    xor a
    call fast_FILVRM

    ; restore content below:
    ld hl, buffer_4096 + 1024
    ld de, NAMTBL2 + 256
    ld bc, 256
    call fast_LDIRVM

    ld hl, redraw_flags
    ld (hl), #ff

    ld a, (current_room__tileset_page)
    ld c, a
    ld hl, (current_room__tileset_ptr)
    jp setup_game_tiles_only_biome


