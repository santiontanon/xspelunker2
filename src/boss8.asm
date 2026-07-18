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
    or a
    jp nz, calendar_room_full_activation_do_not_destroy
    ld hl, ending_B_UFO_scene
    ld c, ENDING_PAGE
    call call_hl_in_page_c_8000

    call calendar_room_full_activation_restore_gfx

    ld de, TEXT_TALK_CALENDAR_SUCCESS5
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS6
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS7
    call calendar_room_full_activation_yes_no_dialogue
    or a
    jp nz, calendar_room_full_activation_do_not_open_gate

    ; make teleporter appear:
    ld a, BOSS_8_PAGE
    ld (current_room__tileset_page), a
    ld hl, tiles_calendar_teleporter_zx0
    ld (current_room__tileset_ptr), hl
    call setup_game_tiles_only_biome

    ld c, TILES_PAGE
    ld hl, room_undraw_tile_objects
    call call_hl_in_page_c_8000

    ld hl, ptr_to_new_tile_object
    ld c, TILES_PAGE
    call call_hl_in_page_c_8000

    ld (hl), 0  ; ID
    inc hl
    ld (hl), TAG_TELEPORTER_MARS  ; type (any teleporter would do)
    inc hl
    ld (hl), 14  ; tile x
    inc hl
    ld (hl), 19  ; tile y
    inc hl
    ld (hl), 0  ; state

    ld c, TILES_PAGE
    ld hl, room_render_tile_objects
    call call_hl_in_page_c_8000

    ld hl, draw_room_with_hud
    ld c, TILES_PAGE
    call call_hl_in_page_c_8000

    ld hl, SFX_secret
    call play_SFX_with_high_priority

    ld b, 50
    call wait_b_halts

    ld de, TEXT_TALK_CALENDAR_SUCCESS8
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS9
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS10
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS11
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS12
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS13
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

calendar_room_full_activation_boss8_intro_scene:
    ; intro scene of 8th boss:
    call clear_screen_left_to_right
    ld hl, music_ending_aliens_bin
    ld a, 5
    call play_music_adjusting_tempo
    ld iy, TEXT_BOSS8_INTRO_0
    ld b, 1  ; first tile to use
    ld de, NAMTBL2 + 12*32 + 7
    ld ix, CHRTBL2 + 1*256*8
    ld a, 18
    ld (tmp_letter_line_width), a
    ld a, COLOR_WHITE * 16
    ld (tmp_letter_line_color), a
    ld hl, display_paragraph_text_page4
    ld c, TABLET_LETTER_PAGE
    call call_hl_in_page_c_8000
    ld b, 200
    call wait_b_halts_skippable
    call clear_screen_left_to_right

    ld a, 7
    ld (boss__current_boss_number), a
    ld c, a
    ld a, BOSS_PAGE
    ld hl, enter_boss_door_load_room
    jp jp_to_hl_in_page_a_8000


calendar_room_full_activation_do_not_destroy:
    ld hl, ending_UFO_scene_conquer
    ld c, ENDING_PAGE
    call call_hl_in_page_c_8000
    ld hl, state_game_over
    ld a, GAME_OVER_PAGE
    jp z, jp_to_hl_in_page_a_8000

calendar_room_full_activation_do_not_open_gate:
    ld de, TEXT_TALK_CALENDAR_SUCCESS8
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS9
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_TALK_CALENDAR_SUCCESS10B
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld hl, ending_B_prime
    ld a, (global_state__objects + TAG_FIRESTONE_FORGE)
    or a
    ld a, ENDING_PAGE
    jp z, jp_to_hl_in_page_a_8000
    ld hl, ending_B_plus_prime
    jp jp_to_hl_in_page_a_8000


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

    ld a, (tmp_dialog_pointer_position)
    push af
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
        call setup_game_tiles_only_biome
    pop af
    ret


;-----------------------------------------------
calendar_room_full_activation_restore_gfx:
    ; setup sprites:
    ld a, SPRITES_PAGE
    ld hl, pyramid_object_sprites_bin
    ld de, SPRTBL2 + 32 * FIRST_OBJECT_SPRITE_PATTERN  ; first three reserved for player / weapon
    ld bc, pyramid_object_sprites_bin_end - pyramid_object_sprites_bin
    call fast_LDIRVM_from_sprites_page

    ld hl, (current_room__enemy_sprites_ptr)
    ld de, buffer_4096
    ld a, (current_room__enemy_sprites_ptr_page)
    ld c, a
    call dzx0_from_page_c
    ld hl, buffer_4096      
    ld de, SPRTBL2 + 32 * FIRST_ENEMY_SPRITE_PATTERN
    ld bc, (64 - FIRST_ENEMY_SPRITE_PATTERN) * 32
    call fast_LDIRVM

    ; setup tiles:
    ld a, (current_room__tileset_page)
    ld c, a
    ld hl, (current_room__tileset_ptr)
    call setup_game_tiles
    call state_play_upload_object_tiles_to_vdp_if_necessary    

    ; init sprite attribute table:
    ld hl, sprite_attribute_table + 2
    ld (hl), 0
    inc hl
    ld (hl), COLOR_DARK_YELLOW
    ld hl, sprite_attribute_table + 2 + 4
    ld (hl), 4
    inc hl
    ld (hl), COLOR_DARK_RED
    ld hl, sprite_attribute_table + 2 + 8
    ld (hl), 8

    ld a, HUD_MAX_TIME
    ld (hud_redraw_timer), a
    ld a, #ff  ; redraw everything the first time
    ld (redraw_flags), a

    call maybe_recenter_scroll_and_set_actual
    call update_scroll      
    call draw_room_with_hud
    call player_update_update_sprite_position
    xor a
    ld (n_displayed_object_sprites), a
    ld (n_displayed_object_sprites_without_player_bullets), a
    ld (n_displayed_object_sprites_last_frame), a
    call update_sprite_objects  ; to show Elaine
    ld hl, upload_sprites_to_vdp
    ld c, SPRITES_PAGE
    call call_hl_in_page_c_8000

    jp play_current_room_music_if_needed
