;-----------------------------------------------
BOSS_9_HP_OFFSET: equ 0
BOSS_9_EYE_BULLET_ATTACK_PATTERN_OFFSET: equ 2
BOSS_9_WAIT_TIME_OFFSET: equ 3
BOSS_9_FIST_WAIT_TIME_OFFSET: equ 4
BOSS_9_N_FIST_STONES_OFFSET: equ 5
BOSS_9_N_2FISTS_STONES_OFFSET: equ 6


;-----------------------------------------------
; phase 1:
BOSS9_NAMETABLE_WAIST: equ boss9_name_tables  ; 6*8
BOSS9_NAMETABLE_BODY: equ BOSS9_NAMETABLE_WAIST + 6*8  ; 16*12
BOSS9_NAMETABLE_OPEN_MOUTH: equ BOSS9_NAMETABLE_BODY + 16*12  ; 4*3
BOSS9_NAMETABLE_FIST_LEFT: equ BOSS9_NAMETABLE_OPEN_MOUTH + 4*3  ; 5*4
BOSS9_NAMETABLE_FIST_RIGHT: equ BOSS9_NAMETABLE_FIST_LEFT + 5*4  ; 5*4

boss9_frame_base:
    dw #0c10, BOSS9_NAMETABLE_BODY  ; dimensions and nametable
    dw #0c10  ; boss__clear_bbox

boss9_frame_fist_left:
    dw #0405, BOSS9_NAMETABLE_FIST_LEFT  ; dimensions and nametable
    dw #0405  ; boss__clear_bbox

boss9_frame_fist_right:
    dw #0405, BOSS9_NAMETABLE_FIST_RIGHT  ; dimensions and nametable
    dw #0405  ; boss__clear_bbox


;-----------------------------------------------
boss9_difficulty_setting__easy:
    dw 192  ; boss hp, and threshold for the other phases
    db BOSS_BULLET_PATTERN_EASY1, 48, 28, 1, 2  ; bullet attack pattern, wait time, fist wait time, n fist stones, n 2 fist stones

boss9_difficulty_setting__normal:
    dw 32  ; boss hp, and threshold for the other phases  (DEBUG)
;     dw 320  ; boss hp, and threshold for the other phases
    db BOSS_BULLET_PATTERN_MEDIUM1, 40, 24, 2, 3 ; bullet attack pattern, wait time, fist wait time, n fist stones, n 2 fist stones

boss9_difficulty_setting__hard:
    dw 416  ; boss hp, and threshold for the other phases
    db BOSS_BULLET_PATTERN_HARD1, 32, 20, 2, 4  ; bullet attack pattern, wait time, fist wait time, n fist stones, n 2 fist stones

boss9_difficulty_setting__hardest:
    dw 512  ; boss hp, and threshold for the other phases
    db BOSS_BULLET_PATTERN_HARDEST1, 24, 16, 3, 5  ; bullet attack pattern, wait time, n fist stones, n 2 fist stones


;-----------------------------------------------
update_boss9_behavior:
    ld hl, boss__hit_timer
    ld a, (hl)
    or a
    jr z, update_boss9_behavior_continue
    dec (hl)
update_boss9_behavior_continue:
    ld a, (boss__active)
    or a
    ret z

    ld a, (boss__behavior)
    or a
    jp z, update_boss9_behavior_0  ; boss start
    dec a
    jp z, update_boss9_behavior_1  ; boss regular behavior
    jp update_boss9_behavior_2  ; death


;-----------------------------------------------
update_boss9_behavior_0:
    ld a, (boss__state)
    or a
    jr z, update_boss9_behavior_0_state_0
    dec a
    jr z, update_boss9_behavior_0_state_1
    ret


update_boss9_behavior_0_state_0:
    ld a, (current_world__difficulty)
    ld hl, boss9_difficulty_setting__easy
    or a
    jr z, update_boss9_behavior_0_state_0_continue
    ld hl, boss9_difficulty_setting__normal
    dec a
    jr z, update_boss9_behavior_0_state_0_continue
    dec a
    ld hl, boss9_difficulty_setting__hard
    jr z, update_boss9_behavior_0_state_0_continue
    ld hl, boss9_difficulty_setting__hardest
update_boss9_behavior_0_state_0_continue:
    ld de, boss__settings
    ld bc, 14
    ldir

    ld hl, (boss__settings + BOSS_9_HP_OFFSET)
    ld (boss__hp), hl

    ld a, 1
    ld (boss__state), a
    ret


update_boss9_behavior_0_state_1:
    ; close room doors:
    ld hl, current_room__tile_map + 2 + 21*32
    ld b, 8
update_boss9_behavior_0_state_1_loop1:
    push hl
    push bc
        call update_boss9_behavior_0_state_1_random_rubble
        ld (hl), a
        inc hl
        call update_boss9_behavior_0_state_1_random_rubble
        ld (hl), a
        ld de, 25
        add hl, de
        call update_boss9_behavior_0_state_1_random_rubble
        ld (hl), a
        inc hl
        call update_boss9_behavior_0_state_1_random_rubble
        ld (hl), a

        ld hl, draw_room_with_hud
        ld c, TILES_PAGE
        call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
        ld hl, SFX_explosion_low_pitch
        call play_SFX_with_high_priority
        ld b, 10
        call wait_b_halts
    pop bc
    pop hl
    ld de, -32
    add hl, de
    djnz update_boss9_behavior_0_state_1_loop1

    ld hl, current_room__tile_map + 2 + 11*32
    ld b, 10
update_boss9_behavior_0_state_1_loop2:
    push hl
    push bc
        call update_boss9_behavior_0_state_1_random_rubble
        ld (hl), a
        ld de, 27
        add hl, de
        call update_boss9_behavior_0_state_1_random_rubble
        ld (hl), a

        ld hl, draw_room_with_hud
        ld c, TILES_PAGE
        call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
        ld hl, SFX_explosion_low_pitch
        call play_SFX_with_high_priority
        ld b, 10
        call wait_b_halts
    pop bc
    pop hl
    ld de, -32
    add hl, de
    djnz update_boss9_behavior_0_state_1_loop2

    ld hl, current_room__tile_map
    ld b, 32
update_boss9_behavior_0_state_1_loop3:
    ld a, (hl)
    or a
    jr nz,update_boss9_behavior_0_state_1_loop3_skip
    call update_boss9_behavior_0_state_1_random_rubble
    ld (hl), a
update_boss9_behavior_0_state_1_loop3_skip:
    inc hl
    djnz update_boss9_behavior_0_state_1_loop3

    ld hl, draw_room_with_hud
    ld c, TILES_PAGE
    call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
    ld hl, SFX_explosion_low_pitch
    call play_SFX_with_high_priority
    ld b, 10
    call wait_b_halts

    ; combat starts:
    ld ix, boss9_name_initial_sprite_attributes
    ld de, boss9_name_y_table
    ld hl, update_boss_behavior_bring_name_down_ix
    ld c, BOSS_PAGE
    call call_hl_in_page_c_8000

    ld b, 200
    call wait_b_halts_skippable
    ld ix, boss9_name_initial_sprite_attributes
    ld de, boss9_name_y_table + 23
    ld hl, update_boss_behavior_bring_name_up_ix
    ld c, BOSS_PAGE
    call call_hl_in_page_c_8000

    xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ld a, 1
    ld (boss__behavior), a
    ret

update_boss9_behavior_0_state_1_random_rubble:
    call random_a
    and #03
    add a, 160
    ret

;-----------------------------------------------
update_boss9_behavior_1:
    ; states:
    ; 0: wake up (hit with fists 3 times)
    ; 1: behavior switch 
    ; 2: pause 
    ; 3: left-fist attack
    ; 4: right-fist attack
    ; 5: both fists attack
    ; 6: body goes to the very top and bullet barrage
    ld a, (boss__state)
    or a
    jr z, update_boss9_behavior_1_state_0
    dec a
    jp z, update_boss9_behavior_1_state_1
    dec a
    jp z, update_boss9_behavior_1_state_2
    dec a
    jp z, update_boss9_behavior_1_state_3
    dec a
    jp z, update_boss9_behavior_1_state_4
    dec a
    jp z, update_boss9_behavior_1_state_5
    dec a
    jp z, update_boss9_behavior_1_state_6
    ret

update_boss9_behavior_1_state_0:
    ; 0 - 8: raise
    ; 8 - 10: drop
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    cp 8
    jr c, update_boss9_behavior_1_state_0_raise
    cp 10
    jr c, update_boss9_behavior_1_state_0_drop
    jp z, update_boss9_behavior_1_state_0_hit
    cp 18
    ret c
    cp 8 + 18
    jr c, update_boss9_behavior_1_state_0_raise
    cp 10 + 18
    jr c, update_boss9_behavior_1_state_0_drop
    jp z, update_boss9_behavior_1_state_0_hit
    cp 18 + 18
    ret c
    cp 8 + 18*2
    jr c, update_boss9_behavior_1_state_0_raise
    cp 10 + 18*2
    jr c, update_boss9_behavior_1_state_0_drop
    jp z, update_boss9_behavior_1_state_0_hit
    cp 18 + 18*2
    ret c
    ld a, 1
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret


update_boss9_behavior_1_state_0_raise:
    ld hl, boss__y2
    dec (hl)
    ld hl, boss__9_y3
    dec (hl)
    jp update_boss9_draw_boss9_frame

update_boss9_behavior_1_state_0_drop:
    ld hl, boss__y2
    inc (hl)
    inc (hl)
    inc (hl)
    inc (hl)
    ld hl, boss__9_y3
    inc (hl)
    inc (hl)
    inc (hl)
    inc (hl)
    jp update_boss9_draw_boss9_frame

update_boss9_behavior_1_state_0_hit:
    ld a, (boss__settings + BOSS_9_N_2FISTS_STONES_OFFSET)
    call update_boss9_spawn_debris
    ld bc, #1407
    call spawn_4tile_appart_dust    
    ld bc, #1415
    call spawn_4tile_appart_dust    
    ld hl, SFX_explosion
    jp play_SFX_with_high_priority


update_boss9_behavior_1_state_1:
    call update_boss9_maybe_fire_eye_bullet

    ld hl, (boss__hp)
    ld a, h
    or l
    jr nz, update_boss9_behavior_1_state_1_continue
    ; boss defeated, transition to phase 2!
    ld a, 2
    ld (boss__behavior), a
    xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ret
update_boss9_behavior_1_state_1_continue:
    ; behavior switch: 2, 3, 4, 5, 6
    ld c, 5
    call random_modulo
    add a, 2
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a

    ; set a new target for the body:
    call random_a
    and #03
    add a, 5
    ld (boss__9_target_y), a
    ret


update_boss9_behavior_1_state_2:
    ld hl, boss__state_timer
    inc (hl)
    call update_boss9_move_body
    call update_boss9_maybe_fire_eye_bullet

    ld a, (boss__settings + BOSS_9_WAIT_TIME_OFFSET)
    ld c, a
    ld a, (boss__state_timer)
    cp c
    ret nz
    ld a, 1
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret


update_boss9_behavior_1_state_3:
    ; left fist:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    push af
        call update_boss9_move_body
        call update_boss9_maybe_fire_eye_bullet
    pop af
    cp 16
    jr c, update_boss9_behavior_1_state_3_raise
    push af
        ld a, (boss__settings + BOSS_9_FIST_WAIT_TIME_OFFSET)
        add a, 16
        ld c, a
    pop af
    cp c
    ret c
    inc c
    inc c
    inc c
    inc c
    cp c
    jr c, update_boss9_behavior_1_state_3_drop
    ret nz
    ; hit:
    ld a, (boss__settings + BOSS_9_N_FIST_STONES_OFFSET)
    call update_boss9_spawn_debris
    ld a, (boss__x2)
    ld c, a
    ld b, 20
    call spawn_4tile_appart_dust    
    ld hl, SFX_explosion
    call play_SFX_with_high_priority

    ld a, 1
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a    
    ret

update_boss9_behavior_1_state_3_raise:
    and #03
    jr nz, update_boss9_behavior_1_state_3_raise_no_horizontal_movement
    push af
        ld de, #0b06
        ld hl, boss__x2
        call update_boss9_move_fist_horizontally
    pop af
update_boss9_behavior_1_state_3_raise_no_horizontal_movement:
    and #01
    ret nz
    ld hl, boss__y2
    dec (hl)
    jp update_boss9_draw_boss9_frame

update_boss9_behavior_1_state_3_drop:
    ld hl, boss__y2
    inc (hl)
    inc (hl)
    jp update_boss9_draw_boss9_frame


update_boss9_behavior_1_state_4:
    ; right fist:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    push af
        call update_boss9_move_body
        call update_boss9_maybe_fire_eye_bullet
    pop af
    cp 16
    jr c, update_boss9_behavior_1_state_4_raise
    push af
        ld a, (boss__settings + BOSS_9_FIST_WAIT_TIME_OFFSET)
        add a, 16
        ld c, a
    pop af
    cp c
    ret c
    inc c
    inc c
    inc c
    inc c
    cp c
    jr c, update_boss9_behavior_1_state_4_drop
    ret nz
    ; hit:
    ld a, (boss__settings + BOSS_9_N_FIST_STONES_OFFSET)
    call update_boss9_spawn_debris
    ld a, (boss__9_x3)
    ld c, a
    ld b, 20
    call spawn_4tile_appart_dust    
    ld hl, SFX_explosion
    call play_SFX_with_high_priority

    ld a, 1
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a   
    ret

update_boss9_behavior_1_state_4_raise:
    and #03
    jr nz, update_boss9_behavior_1_state_4_raise_no_horizontal_movement
    push af
        ld de, #1510
        ld hl, boss__9_x3
        call update_boss9_move_fist_horizontally
    pop af
update_boss9_behavior_1_state_4_raise_no_horizontal_movement:
    and #01
    ret nz
    ld hl, boss__9_y3
    dec (hl)
    jp update_boss9_draw_boss9_frame

update_boss9_behavior_1_state_4_drop:
    ld hl, boss__9_y3
    inc (hl)
    inc (hl)
    jp update_boss9_draw_boss9_frame


update_boss9_behavior_1_state_5:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    push af
        call update_boss9_move_body
        call update_boss9_maybe_fire_eye_bullet
    pop af
    cp 16
    jr c, update_boss9_behavior_1_state_5_raise
    push af
        ld a, (boss__settings + BOSS_9_FIST_WAIT_TIME_OFFSET)
        add a, 16
        ld c, a
    pop af
    cp c
    ret c
    inc c
    inc c
    inc c
    inc c
    cp c
    jr c, update_boss9_behavior_1_state_5_drop
    ret nz
    ; hit:
    ld a, (boss__settings + BOSS_9_N_2FISTS_STONES_OFFSET)
    call update_boss9_spawn_debris
    ld a, (boss__x2)
    ld c, a
    ld b, 20
    call spawn_4tile_appart_dust    
    ld a, (boss__9_x3)
    ld c, a
    ld b, 20
    call spawn_4tile_appart_dust    
    ld hl, SFX_explosion
    call play_SFX_with_high_priority

    ld a, 1
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a   
    ret


update_boss9_behavior_1_state_5_raise:
    and #03
    jr nz, update_boss9_behavior_1_state_5_raise_no_horizontal_movement
    push af
        ld de, #0b06
        ld hl, boss__x2
        call update_boss9_move_fist_horizontally
        ld de, #1510
        ld hl, boss__9_x3
        call update_boss9_move_fist_horizontally
    pop af
update_boss9_behavior_1_state_5_raise_no_horizontal_movement:
    and #01
    ret nz
    ld hl, boss__y2
    dec (hl)
    ld hl, boss__9_y3
    dec (hl)
    jp update_boss9_draw_boss9_frame

update_boss9_behavior_1_state_5_drop:
    ld hl, boss__y2
    inc (hl)
    inc (hl)
    ld hl, boss__9_y3
    inc (hl)
    inc (hl)
    jp update_boss9_draw_boss9_frame


update_boss9_behavior_1_state_6:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    push af
        call update_boss9_move_body
    pop af
    or a
    jr nz, update_boss9_behavior_1_state_6_continue
    push af
        ld a, 2
        ld (boss__9_target_y), a
    pop af
update_boss9_behavior_1_state_6_continue:
    cp 40
    ret c
    jr nz, update_boss9_behavior_1_state_6_continue2
    ; open mouth:
    push af
        ld a, 1
        ld (boss__9_mouth_state), a
        call update_boss9_draw_boss9_frame
    pop af
update_boss9_behavior_1_state_6_continue2:
    cp 128
    jr z, update_boss9_behavior_1_state_6_done
    and #0f
    ret nz
    ; mouth attack:
    ; - e, b: tile coordinate from where the bullet is fired
    ; - ixl, ixh: pixel offset  
    ld e, 15
    ld b, 9
    ld ix, 0    
    ld hl, boss_fire_directional_bullet_towards_player_with_random_offset_e_b
    ld c, BOSS_PAGE
    call call_hl_in_page_c_8000
    ret nz
    ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BOSS8_BIG_PLASMA_BALL
    ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
    ld (ix + ROOM_OBJECT_STRUCT_EXTRA1), 16  ; time paused
    ret
update_boss9_behavior_1_state_6_done:
    ld a, 1
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ; close mouth:
    ld (boss__9_mouth_state), a
    jp update_boss9_draw_boss9_frame


;-----------------------------------------------
update_boss9_behavior_2:
    ld a, (boss__state)
    or a
    jr z, update_boss9_behavior_2_state_0
    dec a
    jr z, update_boss9_behavior_2_state_1
    ret

update_boss9_behavior_2_state_0:
    xor a
    ld (boss__9_mouth_state), a
    ld a, 8
    ld (boss__9_target_y), a

    ld hl, boss__state_timer
    inc (hl)

    call update_boss9_move_body

    ld a, (boss__y)
    cp 8
    ret nz

    ld a, 1
    ld (boss__state), a
    ret

update_boss9_behavior_2_state_1:
    call stop_music

    ld de, TEXT_BOSS9_DEFEATED
    ld hl, display_in_game_message_textpage4_wait100
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ; reopen doors:
    ld hl, current_room__tile_map
    ld b, 24
update_boss9_behavior_2_state_1_loop:
    push bc
        push hl
            ld bc, #2000
update_boss9_behavior_2_state_1_loop_x:
            ld a, (hl)
            cp 160
            jr c, update_boss9_behavior_2_state_1_loop_x_skip
            cp 164
            jr nc, update_boss9_behavior_2_state_1_loop_x_skip
            ld (hl), 0
            ld c, 1
update_boss9_behavior_2_state_1_loop_x_skip:
            inc hl
            djnz update_boss9_behavior_2_state_1_loop_x
            ld a, c
            or a
            jr z, update_boss9_behavior_2_state_1_loop_no_wall

            ld hl, draw_room_with_hud
            ld c, TILES_PAGE
            call call_hl_in_page_c_8000  ; just so that we do not lose the page we are at
            ld hl, SFX_explosion_low_pitch
            call play_SFX_with_high_priority
            ld b, 10
            call wait_b_halts
update_boss9_behavior_2_state_1_loop_no_wall:
        pop hl
        ld bc, 32
        add hl, bc
    pop bc
    djnz update_boss9_behavior_2_state_1_loop

    ld hl, tile_collision_types_boss9_idle
    ld (current_room__collision_ptr), hl
    ld de, current_room__collision_table
    ld bc, 256
    ldir

    ; mark boss as defeated, and add to game over screen:
    ld a, #07
    ld (global_state__objects + TAG_BOSS_9_ROOM), a

    ; mark for stats:
    ld b, 22  ; balam-tun
    ld c, BOSS_PAGE
    ld hl, add_killed_boss_to_stats
    call call_hl_in_page_c_8000

    ; spawn entrance (we know there are no other tile objects):
    ld iy, current_room__tile_objects
    ld (iy + ROOM_TILE_OBJECT_STRUCT_ID), 3
    ld (iy + ROOM_TILE_OBJECT_STRUCT_TYPE), TAG_BOSS9_ENTRANCE
    ld (iy + ROOM_TILE_OBJECT_STRUCT_X), 15
    ld (iy + ROOM_TILE_OBJECT_STRUCT_Y), 20
    ld (iy + ROOM_TILE_OBJECT_STRUCT_STATE), 0

    ld hl, redraw_flags
    ld (hl), #ff
    ld hl, room_render_tile_objects
    ld c, TILES_PAGE
    call call_hl_in_page_c_8000

    ld a, 2
    ld (boss__state), a
    ret




;-----------------------------------------------
; input:
; - hl: ptr to fist x coordinate
; - d, e: max/min x coordinates
update_boss9_move_fist_horizontally:
    ld a, (player_x + 1)
    dec a
    dec a
    ld c, a
    ld a, (hl)
    cp c
    ret z
    jr c, update_boss9_move_fist_horizontally_right
update_boss9_move_fist_horizontally_right_left:
    cp e
    ret z
    ret c
    dec (hl)
    ret
update_boss9_move_fist_horizontally_right:
    cp d
    ret z
    ret nc
    inc (hl)
    ret


;-----------------------------------------------
update_boss9_move_body:
    ld a, (boss__state_timer)
    and #03
    ret nz
    ld a, (boss__9_target_y)
    ld b, a
    ld a, (boss__y)
    cp b
    ret z
    jr c, update_boss9_move_body_down
update_boss9_move_body_up:
    dec a
    ld (boss__y), a
    jp update_boss9_draw_boss9_frame
update_boss9_move_body_down:
    inc a
    ld (boss__y), a
    jp update_boss9_draw_boss9_frame


;-----------------------------------------------
update_boss9_maybe_fire_eye_bullet:
    ; fire bullets through eyes
    ld a, (boss__settings + BOSS_9_EYE_BULLET_ATTACK_PATTERN_OFFSET)
    call boss_bullet_pattern_cycle
    ret nz
    ld hl, #0405  ; or #0409
    call random_a
    and #01
    jr z, update_boss9_maybe_fire_eye_bullet_continue
    inc l
    inc l
    inc l
update_boss9_maybe_fire_eye_bullet_continue:
    ld bc, (boss__x)
    add hl, bc
    ld e, l
    ld b, h
    ld ix, #0004
    ; - e, b: tile coordinate from where the bullet is fired
    ; - ixl, ixh: pixel offset  
    ld hl, boss_fire_directional_bullet_towards_player_with_random_offset_e_b
    ld c, BOSS_PAGE
    call call_hl_in_page_c_8000
    ret nz
    ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BULLET_IGNORING_WALLS
    ret


;-----------------------------------------------
; input:
; - a: n debris
update_boss9_spawn_debris:
    ld b, a
update_boss9_spawn_debris_loop:
    push bc
        ; spawn debris:
        call ptr_to_new_sprite_enemy
    pop bc
    ret nz
    ld (hl), 0  ; ID
    inc hl
    ld (hl), ENEMY_BULLET_BOSS9_DEBRIS
    inc hl
    ld (hl), 0  ; pixel x
    inc hl
    ld a, b
    cp 1
    jr z, update_boss9_spawn_debris_loop_on_top_of_player
    ld c, 26
    call random_modulo
    add a, 3
    jr update_boss9_spawn_debris_loop_x_set
update_boss9_spawn_debris_loop_on_top_of_player:
    ld a, (player_x + 1)
update_boss9_spawn_debris_loop_x_set:
    ld (hl), a  ; tile x
    inc hl
    ld (hl), 0  ; pixel y
    inc hl
    ld (hl), 0  ; tile y
    inc hl
    call random_a
    ld c, (FIRST_ENEMY_SPRITE_PATTERN + 6) * 4
    and #01
    jr z, update_boss9_spawn_debris_sprite_set
    ld c, (FIRST_ENEMY_SPRITE_PATTERN + 5) * 4
update_boss9_spawn_debris_sprite_set:
    ld (hl), c   ; state == sprite to use
    djnz update_boss9_spawn_debris_loop


;-----------------------------------------------
; input:
update_boss9_draw_boss9_frame:
;     out (#2c),a  ; DEBUG
    call draw_boss9_frame_clear_previous_frame_1
    call draw_boss9_frame_clear_previous_frame_2
    call draw_boss9_frame_clear_previous_frame_3
    ; compute draw pointer:
    ld bc, (boss__x)
    call get_room_tile_ptr
    ex de, hl  ; hl = ptr where the boss is to be drawn
    ld hl, boss9_frame_base
    push de
        call draw_boss9_frame_1_without_clearing
    pop hl

    ; mouth:
    ld a, (boss__9_mouth_state)
    or a
    jr z, update_boss9_draw_boss9_frame_mouth_done
    ld de, 32*7 + 6
    add hl, de
    ex de, hl
    ld hl, BOSS9_NAMETABLE_OPEN_MOUTH
    ld bc, #0304
    call draw_boss9_frame_part
update_boss9_draw_boss9_frame_mouth_done:
    ; fists:
    ld bc, (boss__x2)
    call get_room_tile_ptr
    ex de, hl  ; hl = ptr where the boss is to be drawn
    ld hl, boss9_frame_fist_left
    call draw_boss9_frame_2_without_clearing

    ld bc, (boss__9_x3)
    call get_room_tile_ptr
    ex de, hl  ; hl = ptr where the boss is to be drawn
    ld hl, boss9_frame_fist_right
    call draw_boss9_frame_3_without_clearing

    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
;     out (#2d),a  ; DEBUG  
    ret


;-----------------------------------------------
draw_boss9_frame_clear_previous_frame_1:
    ; clear the previous frame
    ld bc, (boss__clear_bbox_1 + 2)
    ld a, c
    or b
    ret z
    ld hl, (boss__clear_bbox_1)
    ; here:
    ; - hl: ptr
    ; - bc: width, height
draw_boss9_frame_clear_previous_frame_1_continue:
    ld e, l
    ld d, h
    push bc
        ld bc, boss__room_bg_buffer - current_room__tile_map
        add hl, bc
    pop bc
    ; here:
    ; - hl: points to the bg buffer
    ; - de: points to the room part we want to clear
draw_boss9_frame_clear_previous_frame_1_y_loop:
    push bc
        ld b, 0
        push hl
        push de
            ldir
        pop de
        pop hl
        ld a, (current_room__width)
        ld c, a
        add hl, bc
        ex de, hl
            add hl, bc
        ex de, hl
    pop bc
    djnz draw_boss9_frame_clear_previous_frame_1_y_loop
    ret


draw_boss9_frame_clear_previous_frame_2:
    ; clear the previous frame
    ld bc, (boss__clear_bbox_2 + 2)
    ld a, c
    or b
    ret z
    ld hl, (boss__clear_bbox_2)
    jr draw_boss9_frame_clear_previous_frame_1_continue


draw_boss9_frame_clear_previous_frame_3:
    ; clear the previous frame
    ld bc, (boss__9_clear_bbox_3 + 2)
    ld a, c
    or b
    ret z
    ld hl, (boss__9_clear_bbox_3)
    jr draw_boss9_frame_clear_previous_frame_1_continue


;-----------------------------------------------
; input:
; - de: ptr to draw to
; - hl: ptr to frame struct
draw_boss9_frame_1_without_clearing:
    ld (boss__clear_bbox_1), de
    call draw_boss9_frame_internal

    ; set clear bbox:
    ld de, boss__clear_bbox_1 + 2
    push bc
        ldi
        ldi
    pop bc
    ret


;-----------------------------------------------
; input:
; - de: ptr to draw to
; - hl: ptr to frame struct
draw_boss9_frame_2_without_clearing:
    ld (boss__clear_bbox_2), de
    call draw_boss9_frame_internal

    ; set clear bbox:
    ld de, boss__clear_bbox_2 + 2
    push bc
        ldi
        ldi
    pop bc
    ret


;-----------------------------------------------
; input:
; - de: ptr to draw to
; - hl: ptr to frame struct
draw_boss9_frame_3_without_clearing:
    ld (boss__9_clear_bbox_3), de
    call draw_boss9_frame_internal

    ; set clear bbox:
    ld de, boss__9_clear_bbox_3 + 2
    push bc
        ldi
        ldi
    pop bc
    ret


;-----------------------------------------------
; input:
; - de: ptr to draw to
; - hl: ptr to frame struct
; output:
; - hl: ptr to the boss__clear_bbox info
draw_boss9_frame_internal:
    ld c, (hl)  ; width
    inc hl
    ld b, (hl)  ; height
    inc hl
    push hl
        ld a, (hl)
        inc hl
        ld h, (hl)
        ld l, a
        call draw_boss9_frame_part
    pop hl
    inc hl
    inc hl
    ret


;-----------------------------------------------
; input:
; - hl: frame ptr
; - de: destination ptr
; - c, b: width, height
draw_boss9_frame_part:
draw_boss9_frame_part_loop_y:
    push bc
        push de
            ld b, c
draw_boss9_frame_part_loop_x:
            ld a, (hl)
            or a
            jr z, draw_boss9_frame_part_loop_x_skip
            ld (de), a
draw_boss9_frame_part_loop_x_skip:
            inc hl
            inc de
            djnz draw_boss9_frame_part_loop_x
        pop de
        ex de, hl
            ld a, (current_room__width)
            ; ld b, 0
            ld c, a
            add hl, bc
        ex de, hl
    pop bc
    djnz draw_boss9_frame_part_loop_y
    ret


;-----------------------------------------------
start_boss9:
    call clear_all_the_sprites
    call boss9_panel_clear_box

    call stop_music

    ld a, BOSS_9_ROOM_PAGE
    ld (current_room__enemy_sprites_ptr_page), a
    ld hl, boss9_sprites_zx0
    ld (current_room__enemy_sprites_ptr), hl
    ld hl, 0
    ld (large_object_to_upload_to_vdp), hl
    ld (current_room__music_ptr), hl  ; no music in the boss room until the boss appears
    ld hl, (boss__settings + BOSS_9_HP_OFFSET)
    ld (boss__hp), hl
    xor a
    ld (boss__behavior), a
    ld (boss__state), a
    ld (boss__state_timer), a
    ld (boss__hit_timer), a 
    ld (boss__last_collision_id_1), a
    ld (boss__last_collision_id_2), a
    ld (boss__last_collision_id_3), a
    ld (boss__last_collision_id_4), a
    inc a  ; a = 1
    ld (boss__active), a
    ld a, 8
    ld (boss__current_boss_number), a

    ld hl, tile_collision_types_boss9_boss
    ld (current_room__collision_ptr), hl
    ld de, current_room__collision_table
    ld bc, 256
    ldir

    ld hl, (current_room__enemy_sprites_ptr)
    ld de, buffer_4096
    ld a, (current_room__enemy_sprites_ptr_page)
    ld c, a
    call dzx0_from_page_c
    ld hl, buffer_4096      
    ld de, SPRTBL2 + 32 * FIRST_ENEMY_SPRITE_PATTERN
    ld bc, (64 - FIRST_ENEMY_SPRITE_PATTERN) * 32
    call fast_LDIRVM

    ld hl, current_room__tile_objects
    ld bc, MAX_ROOM_TILE_OBJECTS * ROOM_TILE_OBJECT_STRUCT_SIZE - 1
    ld a, #ff
    call clear_memory_a

    xor a
    ld (boss__9_mouth_state), a
    ld bc, #0808
    ld (boss__x), bc  ; body
    ld bc, #1207
    ld (boss__x2), bc  ; left fist
    ld bc, #1214
    ld (boss__9_x3), bc  ; right fist
    ld hl, player_weapon_hitbox_check_boss__boss9_hit
    ld (boss__hit_fn), hl
    ld a, BOSS_9_ROOM_PAGE
    ld (boss__hit_fn_page), a    
    ; clear the bbox:
    ld hl, boss__clear_bbox_1 + 2
    ld (hl), 0
    inc hl
    ld (hl), 0
    ld hl, boss__clear_bbox_2 + 2
    ld (hl), 0
    inc hl
    ld (hl), 0    
    ld hl, boss__9_clear_bbox_3 + 2
    ld (hl), 0
    inc hl
    ld (hl), 0    

    ; clear the statue (7,8 - 24,21) from the background and draw the actual boss:
    ld hl, current_room__tile_map + 7 + 8*32
    ld bc, #0e12 
start_boss9_loop_y:
    push bc
    push hl
        ld b, c
start_boss9_loop_x:
        ld (hl), 0
        inc hl
        djnz start_boss9_loop_x
    pop hl
    pop bc
    ld de, 32
    add hl, de
    djnz start_boss9_loop_y

    ; draw the waist:
    ld hl, BOSS9_NAMETABLE_WAIST
    ld de, current_room__tile_map + 13 + 14*32
    ld bc, #0806
    call draw_boss9_frame_part

    ; make a copy of the boss room so that we can restore the background as the boss moves:
    ld hl, current_room__tile_map
    ld de, current_room__tile_map + 32*24*2
    ld bc, 32*24*2
    ldir

    call update_boss9_draw_boss9_frame    

    ld hl, state_play_update_agenda_boss
    ld (state_play_update_agenda_tbl_ptr), hl
    ret


;-----------------------------------------------
; input:
; - e: tile number that was hit
; - iyh: damage to deal
; - iyl: collision ID
; - ix: ptr of the tile we hit
player_weapon_hitbox_check_boss__boss9_hit:
    ld a, (boss__behavior)
    or a
    ret z

    ld hl, player_weapon_hitbox_check_boss__lose_hp
    ld c, BOSS_PAGE
    jp call_hl_in_page_c_8000

