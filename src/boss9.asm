;-----------------------------------------------
BOSS_9_HP_OFFSET: equ 0
BOSS_9_EYE_BULLET_ATTACK_PATTERN_OFFSET: equ 1


;-----------------------------------------------
; boss9_frame_ptrs:
;     dw boss8_frame_0_brain_in_vat


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
    jp update_boss8_behavior_2  ; death


;-----------------------------------------------
update_boss9_behavior_0:
    ld a, (boss__state)
    or a
    jr z, update_boss9_behavior_0_state_0
;     inc a
;     jr z, update_boss9_behavior_0_state_1
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

;     ld a, 55
;     ld (boss__x), a
;     ld a, 4
;     ld (boss__y), a
    ld hl, (boss__settings + BOSS_7_HP_OFFSET)
    ld (boss__hp), hl
    ld hl, player_weapon_hitbox_check_boss__boss9_hit
    ld (boss__hit_fn), hl
    ld a, BOSS_9_ROOM_PAGE
    ld (boss__hit_fn_page), a
    ld a, 1
    ld (boss__state), a
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

    ; load alternate version of the boss room, without the boss already drawn:
    ; ...

    ; make a copy of the boss room so that we can restore the background as the boss moves:
    ld hl, current_room__tile_map
    ld de, current_room__tile_map + 32*24*2
    ld bc, 32*24*2
    ldir

    ld hl, state_play_update_agenda_boss
    ld (state_play_update_agenda_tbl_ptr), hl

    ; clear the bbox:
    ld hl, boss__clear_bbox_1 + 2
    ld (hl), 0
    inc hl
    ld (hl), 0
    ld hl, boss__clear_bbox_2 + 2
    ld (hl), 0
    inc hl
    ld (hl), 0    
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

