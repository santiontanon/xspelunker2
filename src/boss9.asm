;-----------------------------------------------
BOSS_9_HP_OFFSET: equ 0
BOSS_9_EYE_BULLET_ATTACK_PATTERN_OFFSET: equ 1


;-----------------------------------------------
; phase 1:
BOSS9_NAMETABLE_WAIST: equ boss9_name_tables  ; 6*8
BOSS9_NAMETABLE_BODY: equ BOSS9_NAMETABLE_WAIST + 6*8  ; 16*12
BOSS9_NAMETABLE_OPEN_MOUTH: equ BOSS9_NAMETABLE_BODY + 16*12  ; 4*3
BOSS9_NAMETABLE_FIST_LEFT: equ BOSS9_NAMETABLE_OPEN_MOUTH + 4*3  ; 5*4
BOSS9_NAMETABLE_FIST_RIGHT: equ BOSS9_NAMETABLE_FIST_LEFT + 5*4  ; 5*4

boss9_frame_base:
    db 4  ; number of parts
    db 6, 6  ; offset wrt the draw ptr (x offset, y offset)
    dw #0806, BOSS9_NAMETABLE_WAIST  ; dimensions and nametable
    db 1, 0  ; offset wrt the draw ptr (x offset, y offset)
    dw #0c10, BOSS9_NAMETABLE_BODY  ; dimensions and nametable
    db 0, 10  ; offset wrt the draw ptr (x offset, y offset)
    dw #0405, BOSS9_NAMETABLE_FIST_LEFT  ; dimensions and nametable
    db 13, 10  ; offset wrt the draw ptr (x offset, y offset)
    dw #0405, BOSS9_NAMETABLE_FIST_RIGHT  ; dimensions and nametable
    dw 0, #0e12  ; boss__clear_bbos


;-----------------------------------------------
boss9_difficulty_setting__easy:
    dw 192  ; boss hp, and threshold for the other phases
    db BOSS_BULLET_PATTERN_EASY2  ; bullet attack pattern

boss9_difficulty_setting__normal:
    dw 320  ; boss hp, and threshold for the other phases
    db BOSS_BULLET_PATTERN_MEDIUM2  ; bullet attack pattern

boss9_difficulty_setting__hard:
    dw 416  ; boss hp, and threshold for the other phases
    db BOSS_BULLET_PATTERN_HARD2  ; bullet attack pattern

boss9_difficulty_setting__hardest:
    dw 512  ; boss hp, and threshold for the other phases
    db BOSS_BULLET_PATTERN_HARDEST2  ; bullet attack pattern


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
    ; ...
    ret


;-----------------------------------------------
update_boss9_behavior_2:
    ; ...
    ret


;-----------------------------------------------
; input:
update_boss9_draw_boss9_frame:
    call draw_boss9_frame_clear_previous_frame_1
update_boss9_draw_boss9_frame_not_clearing:
    ; compute draw pointer:
    ld bc, (boss__x)
    call get_room_tile_ptr
    ex de, hl  ; hl = ptr where the boss is to be drawn
    ld hl, boss9_frame_base
    call draw_boss9_frame_1_without_clearing

    ; mouth:
    ; ...

    ; fists:
    ; ...
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
    ld e, l
    ld d, h
    push bc
        ld bc, boss__room_bg_buffer - current_room__tile_map
        add hl, bc
    pop bc
draw_boss9_frame_clear_previous_frame_1_continue:
    ; here:
    ; - hl: points to the bg buffer
    ; - de: points to the room part we want to clear
draw_boss9_frame_clear_previous_frame_1_y_loop:
    push bc
        ld b, 0

        ; if "de" < current_room__tile_map, skip row  ->  draw_boss9_frame_clear_previous_frame_1_y_loop_skip
        ex de, hl
        push bc
        push hl
            ld bc, current_room__tile_map
            or a  ; clear carry flag
            sbc hl, bc
        pop hl
        pop bc
        ex de, hl
        jr c, draw_boss9_frame_clear_previous_frame_1_y_loop_skip

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
        jr c, draw_boss9_frame_clear_previous_frame_1_y_loop_continue
        ; outside of the room, we are done restoring background
    pop bc
    ret
draw_boss9_frame_clear_previous_frame_1_y_loop_continue:
        push hl
        push de
            ldir
        pop de
        pop hl
draw_boss9_frame_clear_previous_frame_1_y_loop_skip:
        ld a, (current_room__width)
        ld c, a
        add hl, bc
        ex de, hl
            add hl, bc
        ex de, hl
    pop bc
    djnz draw_boss9_frame_clear_previous_frame_1_y_loop
    ret


;-----------------------------------------------
; input:
; - de: ptr to draw to
; - hl: ptr to frame struct
draw_boss9_frame_1:
    push hl
    push de
        call draw_boss9_frame_clear_previous_frame_1
    pop de
    pop hl
draw_boss9_frame_1_without_clearing:
    push de
        call draw_boss9_frame_internal

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
draw_boss9_frame_internal:
    ld a, (hl)  ; number of frame parts
    inc hl
    or a
    ret z
    ld b, a
draw_boss9_frame_loop:
    push bc
        push de
            ld c, (hl)  ; x offset
            ; check if the part would be totally outside the screen from the right-hand side:
            ld a, e
            sub current_room__tile_map % 256
            and #1f  ; a = x coordinate (as boss 8 room is width 32)
            add a, c
            cp 32
            jr nc, draw_boss9_frame_loop_skip_part  ; part is outside of the screen (to the right)

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
            jr z, draw_boss9_frame_loop_continue
            ex de, hl
draw_boss9_frame_loop_y_offset_loop:
                add hl, bc
                dec a
                jr nz, draw_boss9_frame_loop_y_offset_loop
            ex de, hl
draw_boss9_frame_loop_continue:
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
draw_boss9_frame_loop_skip_part_continue:
        pop de
        inc hl
        inc hl
    pop bc
    djnz draw_boss9_frame_loop
    ret

draw_boss9_frame_loop_skip_part:
            inc hl  ; x offset
            inc hl  ; y offset
            inc hl  ; width
            inc hl  ; height
            jr draw_boss9_frame_loop_skip_part_continue


;-----------------------------------------------
; input:
; - hl: frame ptr
; - de: destination ptr
; - c, b: width, height
draw_boss9_frame_part:
draw_boss9_frame_part_loop_y:
    push bc
        push de
            ; if "de" < current_room__tile_map, skip row  ->  draw_boss_frame_part_loop_y_skip
            ex de, hl
            push bc
            push hl
                ld bc, current_room__tile_map
                or a  ; clear carry flag
                sbc hl, bc
            pop hl
            pop bc
            ex de, hl
            jr c, draw_boss9_frame_part_loop_y_skip

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
draw_boss9_frame_part_loop_y_skip2:
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
draw_boss9_frame_part_loop_y_skip:
            ; advance 'hl':
            ld b, 0
            add hl, bc
            jr draw_boss9_frame_part_loop_y_skip2


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
    ld hl, 1
    ld (boss__hp), hl  ; make sure boss is not dead at the start
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

    ld a, 7
    ld (boss__x), a
    ld a, 8
    ld (boss__y), a
    ld hl, (boss__settings + BOSS_7_HP_OFFSET)
    ld (boss__hp), hl
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

    ; check if we have hit the face or tail:
;     ld a, e
;     cp BOSS7_PHASE2_FIRST_HEAD_TILE
;     jr nc, player_weapon_hitbox_check_boss__boss9_hit_vulnerable_spot

    ; shield:
    ld hl, SFX_shield
    call play_SFX_with_high_priority
    xor a
    ld (player_weapon_hitbox_check_result), a  ; mark a hit
    ld hl, boss__last_collision_id_3
    ld de, boss__last_collision_id_4
    ldd
    ldd
    ldd
    ld a, iyl
    ld (boss__last_collision_id_1), a
    ret
; player_weapon_hitbox_check_boss__boss9_hit_vulnerable_spot:
;     ld hl, player_weapon_hitbox_check_boss__lose_hp
;     ld c, BOSS_PAGE
;     jp call_hl_in_page_c_8000

