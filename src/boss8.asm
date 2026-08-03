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


boss8_frame_ptrs_phase2:
    dw boss8_suit_base_frame
    dw boss8_suit_walk_frame1
    dw boss8_suit_walk_frame2
    dw boss8_suit_walk_frame3
    dw boss8_suit_walk_frame4
    dw boss8_suit_walk_frame5
    dw boss8_suit_base_frame  ; just for when we overflow
    ; left-arm attack:
    dw boss8_suit_larm_frame1  ; 7
    dw boss8_suit_larm_frame2  ; 8
    ; right-arm attack:
    dw boss8_suit_rarm_frame1  ; 9
    dw boss8_suit_rarm_frame2  ; 10
    dw boss8_suit_rarm_frame3  ; 11

boss8_eye_frame_ptrs_phase2:
    dw boss8_eye_phase2_frame_0_open
    dw boss8_eye_phase2_frame_1_closing
    dw boss8_eye_phase2_frame_2_closed
    dw boss8_eye_phase2_frame_1_closing
    dw boss8_eye_phase2_frame_3_down
    dw boss8_eye_phase2_frame_4_up


;-----------------------------------------------
; Boss phases:
; - phase 1: brain in a vat (until ~75% health)
; - phase 2: combat suit (until boss reaches ~25% health)
; - phase 3: flying core (until boss reaches 0% health)
; final boss only has one difficulty level
boss8_difficulty_setting__normal:
    dw 560, 480, 160  ; boss hp, and thresholds for phase 2 and 3
    db BOSS_BULLET_PATTERN_HARD1  ; bullet pattern


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
    jp z, update_boss8_behavior_1  ; phase 1 (brain in a vat)
    dec a
    jp z, update_boss8_behavior_2  ; transition to phase 2
    dec a
    jp z, update_boss8_behavior_3  ; phase 2 (mechanical armor)
    dec a
    jp z, update_boss8_behavior_4  ; transition to phase 3
    dec a
    jp z, update_boss8_behavior_5  ; phase 3 (flying core)
    jp update_boss8_behavior_6  ; death


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
    dec a
    jp z, update_boss8_behavior_0_intro_scene_6
    dec a
    jp z, update_boss8_behavior_0_intro_scene_7
    dec a
    jp z, update_boss8_behavior_0_intro_scene_8
    ret
update_boss8_behavior_init:
    ld hl, boss8_difficulty_setting__normal
    ld de, boss__settings
    ld bc, 12
    ldir

    ; collision table for bank 3:
    ld hl, tile_collision_types_boss8_phase1
    ld de, boss__8_bank3_collision_table
    ld bc, 256
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
    call update_boss8_draw_boss8_frame
    ld b, 10
    jp update_boss8_draw_chains  ; draws the chains that hold the supporting machine up to height 10

update_boss8_behavior_0_intro_scene_1:
    ; boss intro scene (start, and door opens):
    call update_boss8_eye_blink_phase1

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
    call update_boss8_eye_blink_phase1
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
    call update_boss8_eye_blink_phase1
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
    call update_boss8_eye_blink_phase1

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
    call update_boss8_eye_blink_phase1
    ld hl, boss__state_timer
    inc (hl)
    ld a, (hl)
    cp 72
    ret nz
    ; fire bullets:
    ld bc, #030d
    ld de, #12ff
    call update_boss8_behavior_0_intro_scene_5_spawn_bullet

    ld bc, #0312
    ld de, #12fd
    call update_boss8_behavior_0_intro_scene_5_spawn_bullet

    xor a
    ld (boss__state_timer), a
    ld a, 6
    ld (boss__state), a
    ret

update_boss8_behavior_0_intro_scene_5_spawn_bullet:
    push bc
    push de
        call ptr_to_new_sprite_enemy
    pop de
    pop bc
    ; ret nz  ; should never happen
    ld (hl), 0  ; ID
    inc hl
    ld (hl), ENEMY_BOSS8_PLASMA_BALL
    inc hl
    ld (hl), 0  ; pixel X
    inc hl
    ld (hl), c  ; tile X
    inc hl
    ld (hl), 0  ; pixel Y
    inc hl
    ld (hl), b  ; tile Y
    inc hl
    ld (hl), 0  ; state
    inc hl
    ld (hl), e  ; ROOM_OBJECT_STRUCT_SPEED_X
    inc hl
    ld (hl), d  ; ROOM_OBJECT_STRUCT_SPEED_Y
    inc hl
    ld (hl), 0  ; -
    inc hl
    ld (hl), 0  ; ROOM_OBJECT_STRUCT_BRESENHAM_STATE

    ld hl, SFX_raygun
    jp play_SFX_with_high_priority

update_boss8_behavior_0_intro_scene_6:
    call update_boss8_eye_blink_phase1
    ld hl, boss__state_timer
    inc (hl)
    ld a, (hl)
    cp 46
    ret nz
    ; replace aliens by explosions:
    ld ix, current_room__sprite_enemies
    ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
    ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
    push bc
        call sprite_object_remove_object_enemy
    pop bc
    call spawn_explosion

    ld ix, current_room__sprite_enemies
    ld c, (ix + ROOM_OBJECT_STRUCT_TILE_X)
    ld b, (ix + ROOM_OBJECT_STRUCT_TILE_Y)
    push bc
        call sprite_object_remove_object_enemy
    pop bc
    call spawn_explosion

    xor a
    ld (boss__state_timer), a
    ld a, 7
    ld (boss__state), a
    ret

update_boss8_behavior_0_intro_scene_7:
    call update_boss8_eye_blink_phase1
    ld hl, boss__state_timer
    inc (hl)
    ld a, (hl)
    cp 50
    ret nz

    ld de, TEXT_BOSS8_INTRO_11
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ; teleporter appears:
    ld hl, BOSS8_NAMETABLE_TELEPORTER
    ld c, 4
    ld b, 3
    ld de, current_room__tile_map + 4 + 4*32
    call draw_boss8_frame_part
    ld hl, draw_room_with_hud
    ld c, TILES_PAGE
    call call_hl_in_page_c_8000
    ld hl, SFX_secret
    call play_SFX_with_high_priority
    ld b, 20
    call wait_b_halts

    ld a, PLAYER_STATE_TELEPORT_IN
    ld (player_state), a
    ld a, 4
    ld (player_x), a
    ld a, 31  ; immune while teleporting
    ld (player_immunity_timer), a

    xor a
    ld (boss__state_timer), a
    ld a, 8
    ld (boss__state), a
    ret


update_boss8_behavior_0_intro_scene_8:
    call update_boss8_eye_blink_phase1
    ld hl, boss__state_timer
    inc (hl)
    ld a, (hl)
    cp 32
    ret nz

    ld de, TEXT_BOSS8_INTRO_12
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_13
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_14
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ld de, TEXT_BOSS8_INTRO_15
    ld hl, display_in_game_message_textpage4
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000

    ; combat starts:
    ld ix, boss8_name_initial_sprite_attributes
    ld de, boss8_name_y_table
    ld hl, update_boss_behavior_bring_name_down_ix
    ld c, BOSS_PAGE
    call call_hl_in_page_c_8000

    ld b, 200
    call wait_b_halts_skippable
    ld ix, boss8_name_initial_sprite_attributes
    ld de, boss8_name_y_table + 23
    ld hl, update_boss_behavior_bring_name_up_ix
    ld c, BOSS_PAGE
    call call_hl_in_page_c_8000

    ; make turrets follow player:
    ld ix, current_room__sprite_enemies
    ld (ix + ROOM_OBJECT_STRUCT_STATE), 1
    ld ix, current_room__sprite_enemies + ROOM_OBJECT_STRUCT_SIZE
    ld (ix + ROOM_OBJECT_STRUCT_STATE), 1

    xor a
    ld (boss__state_timer), a
    ld (boss__state), a    
    inc a
    ld (boss__behavior), a
    ret


;-----------------------------------------------
; brain in a vat
update_boss8_behavior_1:
    call update_boss8_eye_blink_phase1
    call update_boss8_check_turret_respawn
    ld bc, (boss__settings + BOSS_8_HP_PHASE2_OFFSET)
    ld hl, (boss__hp)
    or a
    sbc hl, bc
    ret nc
    ld a, 2
    ld (boss__behavior), a
    xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ret


;-----------------------------------------------
; transition to phase 2
update_boss8_behavior_2:
    call update_boss8_check_turret_respawn

    ; states:
    ;  0: Boss asks for the suit
    ;  1: right door opens
    ;  2: brain is lifted
    ;  3: vat is lowered
    ;  4: giant suit walks in
    ;  5: brain is deposited inside
    ;  6: support mechanism goes away
    ;  7: phase 3 start (reset HP, etc.)
    ld a, (boss__state)
    or a
    jp z, update_boss8_behavior_2_state_0
    dec a
    jp z, update_boss8_behavior_2_state_1
    dec a
    jp z, update_boss8_behavior_2_state_2
    dec a
    jp z, update_boss8_behavior_2_state_3
    dec a
    jp z, update_boss8_behavior_2_state_4
    dec a
    jp z, update_boss8_behavior_2_state_5
    dec a
    jp z, update_boss8_behavior_2_state_6
    ret

update_boss8_behavior_2_state_0:
    ld de, TEXT_BOSS8_PHASE2_START
    ld hl, display_in_game_message_textpage4_wait100
    ld c, TEXT_PAGE
    call call_hl_in_page_c_8000
    ld a, 1
    ld (boss__state), a
    ret

update_boss8_behavior_2_state_1:
    call update_boss8_eye_blink_phase1
    ; right door opens:
    ld hl, boss__state_timer
    ld a, (Hl)
    inc (hl)
    ld c, a
    and #03
    ret nz
    ld a, c
    and #fc
    cp 16*4
    jr z, update_boss8_behavior_2_state_1_done
    ld h, 0
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    ex de, hl
    ld hl, current_room__tile_map + 21*32 + 30
    or a
    sbc hl, de
    ld (hl), 144
    inc hl
    ld (hl), 145
    ld bc, 31
    add hl, bc
    ld (hl), 0
    inc hl
    ld (hl), 0
    ; also affect the back copy:
    ld bc, 64*24 - (1 + 32)
    add hl, bc
    ld (hl), 144
    inc hl
    ld (hl), 145
    ld bc, 31
    add hl, bc
    ld (hl), 0
    inc hl
    ld (hl), 0

    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ld hl, SFX_door_open
    jp play_SFX_with_high_priority

update_boss8_behavior_2_state_1_done:
    ld a, 2
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret

update_boss8_behavior_2_state_2_table:
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED1, current_room__tile_map + 22 + 9*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED2, current_room__tile_map + 22 + 8*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED3, current_room__tile_map + 22 + 7*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED4, current_room__tile_map + 22 + 6*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED5, current_room__tile_map + 22 + 5*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED6, current_room__tile_map + 22 + 4*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED7, current_room__tile_map + 22 + 3*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED8, current_room__tile_map + 22 + 2*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED8, current_room__tile_map + 22 + 1*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED8, current_room__tile_map + 22 + 0*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED8, current_room__tile_map + 22 - 1*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED8, current_room__tile_map + 22 - 2*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED8, current_room__tile_map + 22 - 3*32
    dw BOSS8_NAMETABLE_BRAIN_IN_VAT_LIFTED8, current_room__tile_map + 22 - 4*32

update_boss8_behavior_2_state_2:
    ; raise the brain:
    ld hl, boss__state_timer
    ld a, (Hl)
    inc (hl)
    ld c, a
    and #03
    ret nz
    ld a, c
    and #7c
    cp 14*4
    jr z, update_boss8_behavior_2_state_2_continue
    ld hl, update_boss8_behavior_2_state_2_table
    ADD_HL_A
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    ex de, hl
    ld bc, #0c06
    call draw_boss8_frame_part_no_transparency
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ret

update_boss8_behavior_2_state_2_continue:
    ld a, 3
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret

update_boss8_behavior_2_state_3:
    ; lower the vat:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    ld c, a
    and #03
    ret nz
    ld a, c
    and #fc
    cp 10 * 4
    jr z, update_boss8_behavior_2_state_3_continue
    ld h, 0
    ld l, a
    add hl, hl
    add hl, hl
    add hl, hl
    ld de, current_room__tile_map + 20 + 14*32
    add hl, de
    ex de, hl
    ld hl, BOSS8_NAMETABLE_VAT
    ld bc, #0a0a
    call draw_boss8_frame_part_no_transparency
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ret

update_boss8_behavior_2_state_3_continue:
    ld hl, current_room__tile_map + 23*32 + 64*24
    ld de, current_room__tile_map + 23*32
    ld bc, 32
    ldir
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)

    ; switch tilesets:
    ld hl, update_animations_in_vdp_none
    ld (current_room__animation_fn_ptr), hl
    ld hl, boss_8_phase1b_12_tiles_zx0
    ld (current_room__tileset_ptr), hl
    ld hl, boss_8_phase2_3_tiles_zx0
    ld (current_room__tileset_bank3_ptr), hl
    call setup_game_tiles_only_biome

    ; update collision type table:
    ld hl, tile_collision_types_boss8_phase1b_12
    ld (current_room__collision_ptr), hl
    ld de, current_room__collision_table
    ld bc, 256
    ldir

    ; collision table for bank 3:
    ld hl, tile_collision_types_boss8_phase2_3
    ld de, boss__8_bank3_collision_table
    ld bc, 256
    ldir    

    ld bc, 0
    ld (boss__clear_bbox_1), bc
    ld bc, #071f  ; 31, 7
    ld (boss__x), bc
    ld a, #ff
    ld (boss__8_eye_frame), a

    ld a, 4
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret

update_boss8_behavior_2_state_4:
    ; suit walks in:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    ld c, a
    and #07
    ret nz
    ld a, c

    rrca
    rrca
    rrca
    and #1f
    cp 6  ; last frame
    jr nz, update_boss8_behavior_2_state_4_continue
    xor a
    ld (boss__state_timer), a
update_boss8_behavior_2_state_4_continue:
    ld hl, boss__x
    dec (hl)
    call update_boss8_draw_boss8_frame_phase2
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)

    ld a, (boss__x)
    cp 17
    ret nz
    ld a, 5
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret


update_boss8_behavior_2_state_5_table:
    dw BOSS8_NAMETABLE_LOWERING_BRAIN0, #0c06, current_room__tile_map + 22 - 3*32
    dw BOSS8_NAMETABLE_LOWERING_BRAIN1, #0b06, current_room__tile_map + 22 - 2*32
    dw BOSS8_NAMETABLE_LOWERING_BRAIN2, #0a06, current_room__tile_map + 22 - 1*32
    dw BOSS8_NAMETABLE_LOWERING_BRAIN3, #0906, current_room__tile_map + 22 + 0*32
    dw BOSS8_NAMETABLE_LOWERING_BRAIN4, #0806, current_room__tile_map + 22 + 1*32
    dw BOSS8_NAMETABLE_LOWERING_BRAIN5, #0706, current_room__tile_map + 22 + 2*32
    dw BOSS8_NAMETABLE_LOWERING_BRAIN6, #0706, current_room__tile_map + 22 + 2*32
    dw BOSS8_NAMETABLE_LOWERING_BRAIN7, #0806, current_room__tile_map + 22 + 1*32

update_boss8_behavior_2_state_5:
    ; brain is deposited inside:
    ld hl, boss__state_timer
    ld a, (Hl)
    inc (hl)
    ld c, a
    and #03
    ret nz
    ld a, c
    and #7c
    ld c, a
    sra a
    add a, c
    cp 8*6
    jr z, update_boss8_behavior_2_state_5_continue
    ld hl, update_boss8_behavior_2_state_5_table
    ADD_HL_A
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl
    ld c, (hl)
    inc hl
    ld b, (hl)
    inc hl
    ld a, (hl)
    inc hl
    ld h, (hl)
    ld l, a
    ex de, hl
    call draw_boss8_frame_part_no_transparency
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ret
update_boss8_behavior_2_state_5_continue:
    ld a, 6
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ld (boss__8_eye_frame), a
    ; xor a
    jp update_boss8_draw_boss8_frame_phase2


update_boss8_behavior_2_state_6_table:
    dw current_room__tile_map + 22
    dw current_room__tile_map + 22 - 1*32
    dw current_room__tile_map + 22 - 2*32
    dw current_room__tile_map + 22 - 3*32
    dw current_room__tile_map + 22 - 4*32
    dw current_room__tile_map + 22 - 5*32
    dw current_room__tile_map + 22 - 6*32


update_boss8_behavior_2_state_6:
    ; suport mechanism goes away:
    ld hl, boss__state_timer
    ld a, (Hl)
    inc (hl)
    ld c, a
    and #03
    ret nz
    ld a, c
    and #7c
    sra a
    cp 7*2
    jr z, update_boss8_behavior_2_state_6_continue
    ld hl, update_boss8_behavior_2_state_6_table
    ADD_HL_A
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld hl, BOSS8_NAMETABLE_LOWERING_BRAIN_MECHANISM
    ld bc, #0706
    call draw_boss8_frame_part_no_transparency
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ret
update_boss8_behavior_2_state_6_continue:
    ld a, 3
    ld (boss__behavior), a
    xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ld (boss__8_eye_frame), a

    ; switch tileset:
    ld hl, boss_8_phase2_12_tiles_zx0
    ld (current_room__tileset_ptr), hl
    call boss8_setup_game_tiles_only_biome_banks12

    ; update collision type table:
    ld hl, tile_collision_types_boss8_phase2_12
    ld (current_room__collision_ptr), hl
    ld de, current_room__collision_table
    ld bc, 256
    ldir

    ; reset HP just in case:
    ld hl, (boss__settings + BOSS_8_HP_PHASE2_OFFSET)
    ld (boss__hp), hl
    ret


;-----------------------------------------------
; combat suit
update_boss8_behavior_3:
    call update_boss8_eye_blink_phase2
    call update_boss8_check_turret_respawn
    call update_boss8_maybe_fire_eye_bullet

    ; states:
    ; 0: idle
    ; 1: walk left
    ; 2: walk right
    ; 3: left arm attack (fist)
    ; 4: right arm attack 1 (plasma bullets)
    ; 5: right arm attack 2
    ; 6: left arm attack (fist flying left)
    ; 7: left arm attack (fist flying vertically)
    ; 8: left arm attack (fist flying right)
    ; 9: left arm attack (fist flying vertically)
    ; 10: left arm attack (fist flying back)
    ld a, (boss__state)
    or a
    jr z, update_boss8_behavior_3_state_0
    dec a
    jr z, update_boss8_behavior_3_state_1
    dec a
    jr z, update_boss8_behavior_3_state_2
    dec a
    jp z, update_boss8_behavior_3_state_3
    dec a
    jp z, update_boss8_behavior_3_state_4
    dec a
    jp z, update_boss8_behavior_3_state_5
    dec a
    jp z, update_boss8_behavior_3_state_6
    dec a
    jp z, update_boss8_behavior_3_state_7
    dec a
    jp z, update_boss8_behavior_3_state_8
    dec a
    jp z, update_boss8_behavior_3_state_9
    dec a
    jp z, update_boss8_behavior_3_state_10
    ret

update_boss8_behavior_3_state_0:
    ; idle:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    cp 8
    ret nz
    ; state switch:
    ld c, 6
    call random_modulo
    ; ld a, 4  ; DEBUG!
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret


update_boss8_behavior_3_state_1:
    ; walk left:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    or a
    jr z, update_boss8_behavior_3_state_1_start
update_boss8_behavior_3_state_1_continue:
    ld c, a
    and #03
    ret nz
    ld a, c
    rrca
    rrca
    and #3f
    push af
        ld hl, boss__x
        dec (hl)
        call update_boss8_draw_boss8_frame_phase2
        ld hl, redraw_flags
        set ROOM_REDRAW_FLAG_BIT, (hl)
    pop af
    cp 6
    ret nz
    xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ret
update_boss8_behavior_3_state_1_start:
    ld a, (boss__x)
    cp 5
    jr nz, update_boss8_behavior_3_state_1_continue
    ld a, 2
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ; jr update_boss8_behavior_3_state_2


update_boss8_behavior_3_state_2:
    ; walk right:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    or a
    jr z, update_boss8_behavior_3_state_2_start
update_boss8_behavior_3_state_2_continue:
    ld c, a
    and #03
    ret nz
    ld a, c
    rrca
    rrca
    and #3f
    neg
    add a, 6
    push af
        ld hl, boss__x
        inc (hl)
        call update_boss8_draw_boss8_frame_phase2
        ld hl, redraw_flags
        set ROOM_REDRAW_FLAG_BIT, (hl)
    pop af
    ; or a
    ret nz
    ; xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ret
update_boss8_behavior_3_state_2_start:
    ld a, (boss__x)
    cp 23
    jr nz, update_boss8_behavior_3_state_2_continue
    ld a, 1
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    jr update_boss8_behavior_3_state_1


;-----------------------------------------------
update_boss8_maybe_fire_eye_bullet
    ; fire bullets through eyes
    ld a, (boss__settings + BOSS_8_EYE_BULLET_ATTACK_PATTERN_OFFSET)
    call boss_bullet_pattern_cycle
    ret nz
    ld hl, #0406
    ld bc, (boss__x)
    add hl, bc
    ld e, l
    ld b, h
    ld ix, #0000
    ; - e, b: tile coordinate from where the bullet is fired
    ; - ixl, ixh: pixel offset  
    ld hl, boss_fire_directional_bullet_towards_player_with_random_offset_e_b
    ld c, BOSS_PAGE
    call call_hl_in_page_c_8000
    ret nz
    ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BULLET_IGNORING_WALLS
    ret


update_boss8_behavior_3_state_3:
    ; left-arm attack (fist):
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    or a
    jr nz, update_boss8_behavior_3_state_3_continue
    ; first frame, switch tilesets:
    ld hl, update_animations_in_vdp_none
    ld (current_room__animation_fn_ptr), hl
    ld hl, boss_8_phase2_12_tiles_zx0
    ld (current_room__tileset_ptr), hl
    call boss8_setup_game_tiles_only_biome_banks12
    ld hl, tile_collision_types_boss8_phase2_12
    ld (current_room__collision_ptr), hl
    ld de, current_room__collision_table
    ld bc, 256
    ldir

    ; draw the flying fist:
    ld a, (boss__x)
    dec a
    ld (boss__x2), a
    ld a, 12
    ld (boss__y2), a

    ld a, 7
    call update_boss8_draw_boss8_frame_phase2
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ret
update_boss8_behavior_3_state_3_continue:
    push af
        call update_boss8_draw_boss8_frame_phase2_fist    
        ld hl, redraw_flags
        set ROOM_REDRAW_FLAG_BIT, (hl)
    pop af
    cp 24
    ret nz

    ld bc, (boss__x2)
    ld a, -3
    add a, c
    ld (boss__x2), a
    ld a, -4
    add a, b
    ld (boss__y2), a

    ld a, 8
    call update_boss8_draw_boss8_frame_phase2
    ld a, 6
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret


; where to spawn the plasma balls relative to the boss
update_boss8_behavior_3_state_4_offset_table:
    db 9, 7
    db 7, 5
    db 9, 3

update_boss8_behavior_3_state_4:
    ; right-arm attack 1 (barrage):
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    or a
    jr nz, update_boss8_behavior_3_state_4_continue
    ; first frame, switch tilesets:
    ld hl, update_animations_in_vdp_none
    ld (current_room__animation_fn_ptr), hl
    ld hl, boss_8_phase2_12b_tiles_zx0
    ld (current_room__tileset_ptr), hl
    call boss8_setup_game_tiles_only_biome_banks12
    ld hl, tile_collision_types_boss8_phase2_12b
    ld (current_room__collision_ptr), hl
    ld de, current_room__collision_table
    ld bc, 256
    ldir
    xor a
update_boss8_behavior_3_state_4_continue:
    cp 32
    jr z, update_boss8_behavior_3_state_4_done
    cp 9
    jr z, update_boss8_behavior_3_state_4_fire
    cp 17
    jr z, update_boss8_behavior_3_state_4_fire
    cp 25
    jr z, update_boss8_behavior_3_state_4_fire
update_boss8_behavior_3_state_4_continue2:
    and #07
    ret nz
    ; point arm to player (horizontally, arm is at y == 13):
    ld a, (player_y + 1)
    cp 9
    jr c, update_boss8_behavior_3_state_4_up
    cp 17
    jr c, update_boss8_behavior_3_state_4_front
update_boss8_behavior_3_state_4_down:
    ld a, 9
    jr update_boss8_behavior_3_state_4_continue3
update_boss8_behavior_3_state_4_up:
    ld a, 11
    jr update_boss8_behavior_3_state_4_continue3
update_boss8_behavior_3_state_4_front:
    ld a, 10
update_boss8_behavior_3_state_4_continue3:
    call update_boss8_draw_boss8_frame_phase2
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ret

update_boss8_behavior_3_state_4_fire:
    push af
        ld b, 2
update_boss8_behavior_3_state_4_fire_loop:
        push bc
            ; spawn bullets:
            ld a, (boss__8_last_suit_frame)
            sub 9
            add a, a
            ld hl, update_boss8_behavior_3_state_4_offset_table
            ADD_HL_A
            ld a, (hl)
            inc hl
            ld h, (hl)
            ld l, a
            ld bc, (boss__x)
            add hl, bc
            ld e, l
            ld b, h
            ld ix, #0000
            ; - e, b: tile coordinate from where the bullet is fired
            ; - ixl, ixh: pixel offset  
            ld hl, boss_fire_directional_bullet_towards_player_with_random_offset_e_b
            ld c, BOSS_PAGE
            call call_hl_in_page_c_8000
            jr nz, update_boss8_behavior_3_state_4_no_sprite_available
            ld (ix + ROOM_OBJECT_STRUCT_TYPE), ENEMY_BOSS8_BIG_PLASMA_BALL
            ld (ix + ROOM_OBJECT_STRUCT_STATE), 0
            ld (ix + ROOM_OBJECT_STRUCT_EXTRA1), 16  ; time paused
update_boss8_behavior_3_state_4_no_sprite_available:
        pop bc
        djnz update_boss8_behavior_3_state_4_fire_loop
    pop af
    jr update_boss8_behavior_3_state_4_continue2

update_boss8_behavior_3_state_4_done:
    xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ; xor a
    call update_boss8_draw_boss8_frame_phase2
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)
    ret

update_boss8_behavior_3_state_5:
    ; right-arm attack 2:
    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    or a
    jr nz, update_boss8_behavior_3_state_5_continue
    ; first frame, switch tilesets:
    ld hl, update_animations_in_vdp_none
    ld (current_room__animation_fn_ptr), hl
    ld hl, boss_8_phase2_12b_tiles_zx0
    ld (current_room__tileset_ptr), hl
    call boss8_setup_game_tiles_only_biome_banks12
    ld hl, tile_collision_types_boss8_phase2_12b
    ld (current_room__collision_ptr), hl
    ld de, current_room__collision_table
    ld bc, 256
    ldir

update_boss8_behavior_3_state_5_continue:
    ; ...

    xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ret


update_boss8_behavior_3_state_6:
    ; fist flying left:
    call update_boss8_draw_boss8_frame_phase2_fist    
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)

    ld a, (boss__x2)
    cp 2
    jr z, update_boss8_behavior_3_state_6_continue
    dec a
    ld (boss__x2), a
    ret
update_boss8_behavior_3_state_6_continue:
    ld a, 7
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret

update_boss8_behavior_3_state_7:
    ; fist flying vertically:
    call update_boss8_draw_boss8_frame_phase2_fist    
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)

    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    and #01
    ret nz

    ld a, (boss__y2)
    ld hl, player_y + 1
    cp (hl)
    jr z, update_boss8_behavior_3_state_7_continue
    jr c, update_boss8_behavior_3_state_7_down
update_boss8_behavior_3_state_7_up:
    ld hl, boss__y2
    dec (hl)
    ret
update_boss8_behavior_3_state_7_down:
    ld hl, boss__y2
    inc (hl)
    ret
update_boss8_behavior_3_state_7_continue:
    ld a, 8
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret

update_boss8_behavior_3_state_8:
    ; fist flying right:
    call update_boss8_draw_boss8_frame_phase2_fist    
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)

    ld a, (boss__x2)
    cp 26
    jr z, update_boss8_behavior_3_state_8_continue
    inc a
    ld (boss__x2), a
    ret
update_boss8_behavior_3_state_8_continue:
    ld a, 9
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret

update_boss8_behavior_3_state_9:
    ; fist flying vertically again:
    call update_boss8_draw_boss8_frame_phase2_fist    
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)

    ld hl, boss__state_timer
    ld a, (hl)
    inc (hl)
    and #01
    ret nz

    ld a, (boss__y2)
    cp 12
    jr z, update_boss8_behavior_3_state_9_continue
    jr c, update_boss8_behavior_3_state_9_down
update_boss8_behavior_3_state_9_up:
    ld hl, boss__y2
    dec (hl)
    ret
update_boss8_behavior_3_state_9_down:
    ld hl, boss__y2
    inc (hl)
    ret
update_boss8_behavior_3_state_9_continue:
    ld a, 10
    ld (boss__state), a
    xor a
    ld (boss__state_timer), a
    ret

update_boss8_behavior_3_state_10:
    ; fist flying back:
    call update_boss8_draw_boss8_frame_phase2_fist    
    ld hl, redraw_flags
    set ROOM_REDRAW_FLAG_BIT, (hl)

    ld a, (boss__x)
    dec a
    ld c, a

    ld a, (boss__x2)
    cp c
    jr z, update_boss8_behavior_3_state_10_continue
    dec a
    ld (boss__x2), a
    ret
update_boss8_behavior_3_state_10_continue:
    call draw_boss8_frame_clear_previous_frame_2
    ld bc, 0
    ld (boss__x2), a
    xor a
    ld (boss__state), a
    ld (boss__state_timer), a
    ret


;-----------------------------------------------
; transition to phase 3
update_boss8_behavior_4:
;     ld a, (boss__state)
;     or a
    ret


;-----------------------------------------------
; flying core
update_boss8_behavior_5:
;     ld a, (boss__state)
;     or a
    ret


;-----------------------------------------------
; death
update_boss8_behavior_6:
;     ld a, (boss__state)
;     or a
    ret


