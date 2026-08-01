;-----------------------------------------------
update_boss8_check_turret_respawn:
    ld bc, #020d 
    call update_boss8_check_turret_respawn_internal
    ld bc, #0212 
update_boss8_check_turret_respawn_internal:
    ld iy, current_room__sprite_enemies
    ld de, ROOM_OBJECT_STRUCT_SIZE
update_boss8_check_turret_respawn_internal_loop:
    ld a, (iy)
    cp #ff
    jr z, update_boss8_check_turret_respawn_internal_not_found
    ld a, (iy + ROOM_OBJECT_STRUCT_TYPE)
    cp ENEMY_BOSS8_TURRET
    jr nz, update_boss8_check_turret_respawn_internal_loop_next
    ld a, (iy + ROOM_OBJECT_STRUCT_TILE_X)
    cp c
    jr nz, update_boss8_check_turret_respawn_internal_loop_next
    ; found!
    ret
update_boss8_check_turret_respawn_internal_loop_next:
    add iy, de
    jr update_boss8_check_turret_respawn_internal_loop
update_boss8_check_turret_respawn_internal_not_found:
    ld b, 24  ; spawn it lower, so it cannot be hit
    call update_boss8_behavior_0_intro_scene_4_spawn_turret
    dec hl
    dec hl
    dec hl
    ld (hl), 4  ; state (hidden)
    ret


;-----------------------------------------------
update_boss8_eye_blink:
    ld a, (boss__state_timer)
    and #03
    ret nz
    ld a, (boss__8_eye_frame)
    or a
    jr z, update_boss8_eye_blink_0
    dec a
    jr z, update_boss8_eye_blink_1
    dec a
    jr z, update_boss8_eye_blink_2
    dec a
    jr z, update_boss8_eye_blink_3
    ; ...

update_boss8_eye_blink_0:
    call random_a
    and #0f
    ret nz
    ld a, 1
    ld (boss__8_eye_frame), a
    xor a
    jp update_boss8_draw_boss8_frame

update_boss8_eye_blink_1:
update_boss8_eye_blink_2:
    ld hl, boss__8_eye_frame
    inc (hl)
    xor a
    jp update_boss8_draw_boss8_frame

update_boss8_eye_blink_3:
    xor a
    ld (boss__8_eye_frame), a
    jp update_boss8_draw_boss8_frame


;-----------------------------------------------
; input:
; - b: height of chains
update_boss8_draw_chains:
    ld a, 48  ; chain tile
    ld hl, current_room__tile_map + 23
    ld de, 28
update_boss8_draw_chains_loop:
    ld (hl), a
    inc hl
    inc hl
    inc hl
    inc hl
    ld (hl), a
    add hl, de
    djnz update_boss8_draw_chains_loop
    ret


;-----------------------------------------------
; input:
; - a: frame to draw
update_boss8_draw_boss8_frame:
    push af
        call draw_boss8_frame_clear_previous_frame_1
    pop af
update_boss8_draw_boss8_frame_not_clearing:
    ld hl, boss8_frame_ptrs
    add a, a
    ADD_HL_A
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    push hl
        ld hl, redraw_flags
        set ROOM_REDRAW_FLAG_BIT, (hl)

        ; compute draw pointer:
        ld bc, (boss__x)
        call get_room_tile_ptr
        ex de, hl  ; hl = ptr where the boss is to be drawn
    pop hl
    call draw_boss8_frame_1_without_clearing

update_boss8_draw_boss8_frame_eye:
    ld a, (boss__8_eye_frame)
    or a
    jr z, update_boss8_draw_boss8_frame_eye_drawn
    ; draw eye frame:
    ld hl, boss8_eye_frame_ptrs
    add a, a
    ADD_HL_A
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    push hl
        ld hl, #0803
        ld bc, (boss__x)
        add hl, bc
        ld c, l
        ld b, h
        call get_room_tile_ptr
        ex de, hl  ; hl = ptr where the boss is to be drawn
    pop hl
    call draw_boss8_frame_internal
update_boss8_draw_boss8_frame_eye_drawn:
    ret


;-----------------------------------------------
; input:
; - a: frame to draw
update_boss8_draw_boss8_frame_phase2:
    push af
        call draw_boss8_frame_clear_previous_frame_1
    pop af
update_boss8_draw_boss8_frame_phase2_not_clearing:
    ld hl, boss8_frame_ptrs_phase2
    add a, a
    ADD_HL_A
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    push hl
        ld hl, redraw_flags
        set ROOM_REDRAW_FLAG_BIT, (hl)

        ; compute draw pointer:
        ld bc, (boss__x)
        call get_room_tile_ptr
        ex de, hl  ; hl = ptr where the boss is to be drawn
    pop hl
    call draw_boss8_frame_1_without_clearing

    ; eye:
    ; ...

    ret


;-----------------------------------------------
; input:
; - e: tile number that was hit
; - iyh: damage to deal
; - iyl: collision ID
; - ix: ptr of the tile we hit
player_weapon_hitbox_check_boss__boss8_hit:
    ld a, (boss__behavior)
    or a
    ret z
    dec a  ; behaviors 1, 2 are phase 1:
    jr z, player_weapon_hitbox_check_boss__boss8_hit_phase1
    dec a
    jr z, player_weapon_hitbox_check_boss__boss8_hit_phase1
    ; ...
    jr player_weapon_hitbox_check_boss__boss8_hit_phase2

player_weapon_hitbox_check_boss__boss8_hit_phase1:
    ; - 52-63, 70-73, 80-83, 88-90: hit
    ; - 49-51,106-108,146-159,161-175,177-191,193-: shield
    ld a, e
    cp 49
    ret c
    cp 52
    jp c, player_weapon_hitbox_check_boss__boss8_hit_shield
    cp 64
    jp c, player_weapon_hitbox_check_boss__boss8_hit_body
    cp 70
    ret c
    cp 74
    jp c, player_weapon_hitbox_check_boss__boss8_hit_body
    cp 80
    ret c
    cp 84
    jp c, player_weapon_hitbox_check_boss__boss8_hit_body
    cp 88
    ret c
    cp 91
    jp c, player_weapon_hitbox_check_boss__boss8_hit_body
    cp 106
    ret c
    cp 109
    jp c, player_weapon_hitbox_check_boss__boss8_hit_shield
    cp 146
    ret c
    cp 160
    jp c, player_weapon_hitbox_check_boss__boss8_hit_shield
    cp 161
    ret c
    cp 176
    jp c, player_weapon_hitbox_check_boss__boss8_hit_shield
    cp 177
    ret c
    cp 192
    jp c, player_weapon_hitbox_check_boss__boss8_hit_shield
    cp 193
    ret c
    jr player_weapon_hitbox_check_boss__boss8_hit_shield


player_weapon_hitbox_check_boss__boss8_hit_phase2:
    ; hit the main body:
;     ld a, e
;     cp 222  ; first punch tile
;     jp c, player_weapon_hitbox_check_boss__boss8_hit_body
player_weapon_hitbox_check_boss__boss8_hit_shield:
    ld hl, SFX_shield
    call play_SFX_with_high_priority
    xor a
    ld (player_weapon_hitbox_check_result), a  ; mark a hit
    ld a, (boss__last_collision_id2)
    ld (boss__last_collision_id1), a
    ld a, iyl
    ld (boss__last_collision_id2), a
    ret
player_weapon_hitbox_check_boss__boss8_hit_body:
    ld a, (boss__behavior)
    cp 2
    ld hl, player_weapon_hitbox_check_boss__lose_hp
    jr nz, player_weapon_hitbox_check_boss__boss8_hit_body_continue
    ld hl, player_weapon_hitbox_check_boss__lose_hp_continue2  ; if we are in phase 2, do not lose HP
player_weapon_hitbox_check_boss__boss8_hit_body_continue:
    ld c, BOSS_PAGE
    jp call_hl_in_page_c_8000   


;-----------------------------------------------
calendar_room_full_activation:
    ld a, 1
    ld (global_state__solved_final_riddle), a
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
        ; clear the arrow sprite:
        ld hl, SPRATR2
        ld a, 200
        ld b, 1
        call fast_small_FILVRM

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
    jp call_hl_in_page_c_8000


;-----------------------------------------------
draw_boss8_frame_clear_previous_frame_1:
    ; clear the previous frame
    ld bc, (boss__clear_bbox_1 + 2)
    ld a, c
    or b
    ret z
    ld hl, (boss__clear_bbox_1)
draw_boss8_frame_clear_previous_frame_1_continue:
    ; here:
    ; - hl: ptr
    ; - bc: width, height
    ld e, l
    ld d, h
    push bc
        ld bc, boss__room_bg_buffer - current_room__tile_map
        add hl, bc
    pop bc
    ; here:
    ; - hl: points to the bg buffer
    ; - de: points to the room part we want to clear
draw_boss8_frame_clear_previous_frame_1_y_loop:
    push bc
        ld b, 0

        ; if "de" < current_room__tile_map, skip row  ->  draw_boss8_frame_clear_previous_frame_1_y_loop_skip
        ex de, hl
        push bc
        push hl
            ld bc, current_room__tile_map
            or a  ; clear carry flag
            sbc hl, bc
        pop hl
        pop bc
        ex de, hl
        jr c, draw_boss8_frame_clear_previous_frame_1_y_loop_skip

        ; if "de" >= boss__room_bg_buffer, we are done drawing
        ex de, hl
        push bc
        push hl
            ld bc, boss__room_bg_buffer
            or a  ; clear carry flag
            sbc hl, bc
        pop hl
        pop bc
        ex de, hl
        jr c, draw_boss8_frame_clear_previous_frame_1_y_loop_continue
        ; outside of the room, we are done restoring background
    pop bc
    ret
draw_boss8_frame_clear_previous_frame_1_y_loop_continue:
        push hl
        push de
            ldir
        pop de
        pop hl
draw_boss8_frame_clear_previous_frame_1_y_loop_skip:
        ld a, (current_room__width)
        ld c, a
        add hl, bc
        ex de, hl
            add hl, bc
        ex de, hl
    pop bc
    djnz draw_boss8_frame_clear_previous_frame_1_y_loop
    ret


;-----------------------------------------------
; input:
; - de: ptr to draw to
; - hl: ptr to frame struct
draw_boss8_frame_1:
    push hl
    push de
        call draw_boss8_frame_clear_previous_frame_1
    pop de
    pop hl
draw_boss8_frame_1_without_clearing:
    push de
        call draw_boss8_frame_internal

        ; set clear bbox:
        ld c, (hl)
        inc hl
        ld b, (hl)  ; bc is the offset wrt original draw pointer
        inc hl
        ld de, boss__clear_bbox_1 + 2
        push bc
            ldi
            ldi
        pop bc
    pop hl
    add hl, bc
    ld (boss__clear_bbox_1), hl
    ret


;-----------------------------------------------
; input:
; - de: ptr to draw to
; - hl: ptr to frame struct
; output:
; - hl: ptr to the boss__clear_bbox info
draw_boss8_frame_internal:
    ld a, (hl)  ; number of frame parts
    inc hl
    or a
    ret z
    ld b, a
draw_boss8_frame_loop:
    push bc
        push de
            ld c, (hl)  ; x offset
            ; check if the part would be totally outside the screen from the right-hand side:
            ld a, e
            sub current_room__tile_map % 256
            and #1f  ; a = x coordinate (as boss 8 room is width 32)
            add a, c
            cp 32
            jr nc, draw_boss8_frame_loop_skip_part  ; part is outside of the screen (to the right)

            ld b, 0  ; (we assume offset >= 0)
            inc hl
            ex de, hl
                add hl, bc  ; add x offset
            ex de, hl
            ld a, (current_room__width)
            ld c, a
            ld a, (hl)  ; y offset
            inc hl
            or a
            jr z, draw_boss8_frame_loop_continue
            ex de, hl
draw_boss8_frame_loop_y_offset_loop:
                add hl, bc
                dec a
                jr nz, draw_boss8_frame_loop_y_offset_loop
            ex de, hl
draw_boss8_frame_loop_continue:
            ld c, (hl)  ; width
            inc hl
            ld b, (hl)  ; height
            inc hl
            push hl
                ld a, (hl)
                inc hl
                ld h, (hl)
                ld l, a
                call draw_boss8_frame_part
            pop hl
draw_boss8_frame_loop_skip_part_continue:
        pop de
        inc hl
        inc hl
    pop bc
    djnz draw_boss8_frame_loop
    ret

draw_boss8_frame_loop_skip_part:
            inc hl  ; x offset
            inc hl  ; y offset
            inc hl  ; width
            inc hl  ; height
            jr draw_boss8_frame_loop_skip_part_continue


;-----------------------------------------------
; Compared to 'draw_boss_frame_part', this method uses data in boss 8 page, and also
; prevents tiels being drawn on x coordinates larger or equal to 32 (assuming that the
; left-most x coordinate is < 32).
; input:
; - hl: frame ptr
; - de: destination ptr
; - c, b: width, height
draw_boss8_frame_part:
draw_boss8_frame_part_loop_y:
    push bc
        push de
            push hl
                ; if "de" < current_room__tile_map, skip row  ->  draw_boss8_frame_part_loop_y_skip
                ex de, hl
                push bc
                push hl
                    ld bc, current_room__tile_map
                    or a  ; clear carry flag
                    sbc hl, bc
                pop hl
                pop bc
                ex de, hl
                jr c, draw_boss8_frame_part_loop_y_skip

                ; x loop:
                ; see if we need to do less than "c" byte copies (overlap with right border):
                ; min(width, 32 - x0)
                ld a, e
                sub current_room__tile_map % 256
                and #01f  ; initial x coordinate
                neg
                add 32
                cp c
                jr c, draw_boss8_frame_part_loop_x_clip
                ld b, c
                jr draw_boss8_frame_part_loop_x
draw_boss8_frame_part_loop_x_clip:
                ld b, a
draw_boss8_frame_part_loop_x:
                ld a, (hl)
                or a
                jr z, draw_boss8_frame_part_loop_x_skip
                ld (de), a
draw_boss8_frame_part_loop_x_skip:
                inc hl
                inc de
                djnz draw_boss8_frame_part_loop_x

draw_boss8_frame_part_loop_y_skip2:
            pop hl
            add hl, bc
        pop de
        ex de, hl
        ld a, (current_room__width)
        ; ld b, 0
        ld c, a
        add hl, bc
        ex de, hl
    pop bc
    djnz draw_boss8_frame_part_loop_y
    ret
draw_boss8_frame_part_loop_y_skip:
            ; advance 'hl':
            ld b, 0
            add hl, bc
            jr draw_boss8_frame_part_loop_y_skip2


;-----------------------------------------------
; input:
; - hl: frame ptr
; - de: destination ptr
; - c, b: width, height
draw_boss8_frame_part_no_transparency:
draw_boss8_frame_part_no_transparency_loop_y:
    push bc
        push de
            ; if "de" < current_room__tile_map, skip row  ->  draw_boss8_frame_part_loop_y_skip
            ex de, hl
            push bc
            push hl
                ld bc, current_room__tile_map
                or a  ; clear carry flag
                sbc hl, bc
            pop hl
            pop bc
            ex de, hl
            jr c, draw_boss8_frame_part_no_transparency_loop_y_skip

            ld b, 0
            ldir
draw_boss8_frame_part_no_transparency_loop_y_skip2:
        pop de
        ex de, hl
        ld a, (current_room__width)
;         ld b, 0
        ld c, a
        add hl, bc
        ex de, hl
    pop bc
    djnz draw_boss8_frame_part_no_transparency_loop_y
    ret
draw_boss8_frame_part_no_transparency_loop_y_skip:
            ; advance 'hl':
            ld b, 0
            add hl, bc
            jr draw_boss8_frame_part_no_transparency_loop_y_skip2


;-----------------------------------------------
; boss8_maybe_push_player_up:
;     call player_check_collision_idle
;     ret nz  ; if it's a collision with a wall, push player up
;     ld hl, player_y + 1
;     ld a, (hl)
;     or a
;     jr z, boss8_maybe_push_player_up_hit
;     dec (hl)
;     call player_check_collision_idle
;     ret nz  ; moving the player, resolved the collision
;     ; the player was pushed against a wall! bring the player back to the initial position and take damage!
;     ld hl, player_y + 1
;     inc (hl)
; boss8_maybe_push_player_up_hit:
;     ld hl, player_immunity_timer
;     ld a, (hl)
;     or a
;     ret nz
;     ld c, 4
;     jp player_hit_damage_c