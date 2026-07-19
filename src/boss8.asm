;-----------------------------------------------
BOSS_8_HP_OFFSET: equ 0
BOSS_8_HP_PHASE2_OFFSET: equ 2
BOSS_8_HP_PHASE3_OFFSET: equ 4
BOSS_8_EYE_BULLET_ATTACK_PATTERN_OFFSET: equ 6


;-----------------------------------------------
boss8_frame_ptrs:
    dw boss8_frame_0_brain_in_vat

boss8_eye_frame_ptrs:
    dw boss8_eye_frame_0_open
    dw boss8_eye_frame_1_closing
    dw boss8_eye_frame_2_closed
    dw boss8_eye_frame_1_closing
    dw boss8_eye_frame_3_down
    dw boss8_eye_frame_4_up


;-----------------------------------------------
; Boss phases:
; - phase 1: brain in a vat (until ~75% health)
; - phase 2: combat suit (until boss reaches ~25% health)
; - phase 3: flying core (until boss reaches 0% health)
boss8_difficulty_setting__easy:
    dw 256, 192, 64  ; boss hp, and thresholds for phase 2 and 3
    db BOSS_BULLET_PATTERN_EASY2  ; bullet pattern

boss8_difficulty_setting__normal:
    dw 320, 240, 80  ; boss hp, and thresholds for phase 2 and 3
    db BOSS_BULLET_PATTERN_MEDIUM2  ; bullet pattern

boss8_difficulty_setting__hard:
    dw 416, 312, 104  ; boss hp, and thresholds for phase 2 and 3
    db BOSS_BULLET_PATTERN_HARD2  ; bullet pattern

boss8_difficulty_setting__hardest:
    dw 512, 384, 128  ; boss hp, and thresholds for phase 2 and 3
    db BOSS_BULLET_PATTERN_HARDEST2  ; bullet pattern


;-----------------------------------------------
update_boss8_behavior:
    ld hl, boss__hit_timer
    ld a, (hl)
    or a
    jr z, update_boss8_behavior_continue
    dec (hl)
update_boss8_behavior_continue:
    ld a, (boss__active)
    or a
    ret z

    ld a, (boss__behavior)
    or a
    jp z, update_boss8_behavior_0  ; before boss is spawned
    dec a
    jp z, update_boss8_behavior_1  ; phase 1
    dec a
    jp z, update_boss8_behavior_2  ; phase 2
    dec a
    jp z, update_boss8_behavior_3  ; phase 3
    jp update_boss8_behavior_4  ; death


;-----------------------------------------------
update_boss8_behavior_0:
    ld a, (boss__state)
    or a
    jr z, update_boss8_behavior_init
    dec a
    jr z, update_boss8_behavior_0_intro_scene_1
    dec a
    jp z, update_boss8_behavior_0_intro_scene_2
    dec a
    jp z, update_boss8_behavior_0_intro_scene_3
    dec a
    jp z, update_boss8_behavior_0_intro_scene_4
    dec a
    jp z, update_boss8_behavior_0_intro_scene_5
    ; ...
    ret
update_boss8_behavior_init:
    ld a, (current_world__difficulty)
    ld hl, boss8_difficulty_setting__easy
    or a
    jr z, update_boss8_behavior_init_continue
    ld hl, boss8_difficulty_setting__normal
    dec a
    jr z, update_boss8_behavior_init_continue
    dec a
    ld hl, boss8_difficulty_setting__hard
    jr z, update_boss8_behavior_init_continue
    ld hl, boss8_difficulty_setting__hardest
update_boss8_behavior_init_continue:
    ld de, boss__settings
    ld bc, 12
    ldir

    ld a, 20
    ld (boss__x), a
    ld a, 10
    ld (boss__y), a
    xor a
    ld (boss__x2), a
    ld (boss__y2), a
    ld (boss__8_eye_frame), a
    ld hl, (boss__settings + BOSS_8_HP_OFFSET)
    ld (boss__hp), hl
    ld hl, player_weapon_hitbox_check_boss__boss8_hit
    ld (boss__hit_fn), hl
    ld a, BOSS_8_PAGE
    ld (boss__hit_fn_page), a
    ld a, 1
    ld (boss__state), a

    xor a
    call update_boss8_draw_boss_frame
    ld b, 10
    call update_boss8_draw_chains  ; draws the chains that hold the supporting machine up to height 10

    ; ...

    ret

update_boss8_behavior_0_intro_scene_1:
    ; boss intro scene (start, and door opens):
    call update_boss8_eye_blink

    ld hl, boss__state_timer
    inc (hl)
    ld a, (hl)
    cp 64
    ret nz
    xor a
    ld (boss__state_timer), a
    ld a, 2
    ld (boss__state), a
    ; door opens:
    ld hl, current_room__tile_map + 18*32
    ld b, 5
    ld de, 31
update_boss8_behavior_0_intro_scene_1_loop:
    ld (hl), 0
    inc hl
    ld (hl), 0
    add hl, de
    djnz update_boss8_behavior_0_intro_scene_1_loop
    ld hl, SFX_door_open
    call play_SFX_with_high_priority
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ret

update_boss8_behavior_0_intro_scene_2:
    ; boss intro scene (aliens walk in): 1st alien spawner at 24, second at 48
    call update_boss8_eye_blink
    ld hl, boss__state_timer
    inc (hl)
    ld a, (hl)
    cp 24
    jr z, update_boss8_behavior_0_intro_scene_2_spawn_alien
    cp 46
    ret nz
    call update_boss8_behavior_0_intro_scene_2_spawn_alien
    xor a
    ld (boss__state_timer), a
    ld a, 3
    ld (boss__state), a
    ret

update_boss8_behavior_0_intro_scene_2_spawn_alien:
    call ptr_to_new_sprite_enemy
    ; ret nz  ; should never happen
    push hl
    pop ix
    ld (hl), 0  ; ID
    inc hl
    ld (hl), ENEMY_BOSS8_ALIEN
    inc hl
    ld (hl), 0  ; pixel X
    inc hl
    ld (hl), 0  ; tile X
    inc hl
    ld (hl), 0  ; pixel Y
    inc hl
    ld (hl), 21  ; tile Y
    inc hl
    ld (hl), 1  ; state (walking)
    inc hl
    ld (hl), 0  ; state timer
    inc hl
    ld (hl), #ff  ; hit ID
    inc hl
    ld (hl), 1  ; health
    ret

update_boss8_behavior_0_intro_scene_3:
    call update_boss8_eye_blink
    ld hl, boss__state_timer
    inc (hl)
    ld a, (hl)
    cp 96
    ret nz
    ld ix, current_room__sprite_enemies  ; first alien
    ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
    ld ix, current_room__sprite_enemies + ROOM_OBJECT_STRUCT_SIZE  ; second alien
    ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
    ; left door closes:
    ld de, current_room__tile_map + 18*32
    ld hl, current_room__tile_map + 18*32 + 64*24
    ld a, 5
    ld bc, 30
update_boss8_behavior_0_intro_scene_3_loop:
    push bc
        ldi
        ldi
    pop bc
    add hl, bc
    ex de, hl
        add hl, bc
    ex de, hl
    dec a
    jr nz, update_boss8_behavior_0_intro_scene_3_loop
    ld hl, SFX_door_open
    call play_SFX_with_high_priority
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    xor a
    ld (boss__state_timer), a
    ld a, 4
    ld (boss__state), a
    ret    

update_boss8_behavior_0_intro_scene_4:
    call update_boss8_eye_blink

    ld de, TEXT_BOSS8_INTRO_1
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_2
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_3
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_4
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_5
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_6
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_7
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_8
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_9
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_10
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld bc, #020d
    call update_boss8_behavior_0_intro_scene_4_spawn_turret

    ld bc, #0212
    call update_boss8_behavior_0_intro_scene_4_spawn_turret

    xor a
    ld (boss__state_timer), a
    ld a, 5
    ld (boss__state), a
    ret

update_boss8_behavior_0_intro_scene_4_spawn_turret:
    push bc
        call ptr_to_new_sprite_enemy
    pop bc
    ; ret nz  ; should never happen
    push hl
    pop ix
    ld (hl), 0  ; ID
    inc hl
    ld (hl), ENEMY_BOSS8_TURRET
    inc hl
    ld (hl), 0  ; pixel X
    inc hl
    ld (hl), c  ; tile X
    inc hl
    ld (hl), 0  ; pixel Y
    inc hl
    ld (hl), b  ; tile Y
    inc hl
    ld (hl), 0  ; state (appearing)
    inc hl
    ld (hl), 0  ; state timer
    inc hl
    ld (hl), #ff  ; hit ID
    inc hl
    ld (hl), 16  ; health
    ret    

update_boss8_behavior_0_intro_scene_5:
    call update_boss8_eye_blink
    ; ...
    ret


;-----------------------------------------------
; brain in a vat
update_boss8_behavior_1:
;     ld a, (boss__state)
;     or a
    ret


;-----------------------------------------------
; combat suit
update_boss8_behavior_2:
;     ld a, (boss__state)
;     or a
    ret


;-----------------------------------------------
; flying core
update_boss8_behavior_3:
;     ld a, (boss__state)
;     or a
    ret


;-----------------------------------------------
; death
update_boss8_behavior_4:
;     ld a, (boss__state)
;     or a
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
    jp update_boss8_draw_boss_frame

update_boss8_eye_blink_1:
update_boss8_eye_blink_2:
    ld hl, boss__8_eye_frame
    inc (hl)
    xor a
    jp update_boss8_draw_boss_frame

update_boss8_eye_blink_3:
    xor a
    ld (boss__8_eye_frame), a
    jp update_boss8_draw_boss_frame


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
update_boss8_draw_boss_frame:
    push af
        ld hl, draw_boss_frame_clear_previous_frame_1
        ld c, BOSS_PAGE
        call call_hl_in_page_c_8000
    pop af
update_boss8_draw_boss_frame_not_clearing:
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
    pop ix
    ld c, BOSS_PAGE
    ld hl, draw_boss_frame_1_without_clearing_ix
    call call_hl_in_page_c_8000

update_boss8_draw_boss_frame_eye:
    ld a, (boss__8_eye_frame)
    or a
    jr z, update_boss8_draw_boss_frame_eye_drawn
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
    pop ix
    ld c, BOSS_PAGE
    ld hl, draw_boss_frame_internal_ix
    call call_hl_in_page_c_8000
update_boss8_draw_boss_frame_eye_drawn:
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

    ; hit the main body:
;     ld a, e
;     cp 222  ; first punch tile
;     jp c, player_weapon_hitbox_check_boss__boss6_hit_body
    ld hl, SFX_shield
    jp play_SFX_with_high_priority
; player_weapon_hitbox_check_boss__boss6_hit_body:
;     ld hl, player_weapon_hitbox_check_boss__lose_hp
;     ld c, BOSS_PAGE
;     jp call_hl_in_page_c_8000   


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
    jp call_hl_in_page_c_8000
