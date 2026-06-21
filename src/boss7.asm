;-----------------------------------------------
BOSS_7_HP_OFFSET: equ 0


;-----------------------------------------------
; boss7_statue_frame_ptrs:
; 	dw boss7_statue_frame_0

; boss7_phase1_frame_ptrs:
; 	; ...


;-----------------------------------------------
boss7_difficulty_setting__easy:
	dw 192, 144, 64  ; boss hp

boss7_difficulty_setting__normal:
	dw 320, 240, 108  ; boss hp

boss7_difficulty_setting__hard:
	dw 416, 312, 140  ; boss hp

boss7_difficulty_setting__hardest:
	dw 512, 384, 176  ; boss hp


;-----------------------------------------------
update_boss7_behavior:
	ld hl, boss__hit_timer
	ld a, (hl)
	or a
	jr z, update_boss7_behavior_continue
	dec (hl)
update_boss7_behavior_continue:
	ld a, (boss__active)
	or a
	ret z

	ld a, (boss__behavior)
	or a
	jp z, update_boss7_behavior_0  ; before boss is spawned
	dec a
	jp z, update_boss7_behavior_1  ; phase 1
	dec a
	jp z, update_boss7_behavior_2  ; phase 2
	dec a
	jp z, update_boss7_behavior_3  ; phase 3
	jp update_boss7_behavior_4  ; death


;-----------------------------------------------
update_boss7_behavior_0:
	ld a, (boss__state)
	or a
	jr nz, update_boss7_behavior_0_wait_for_player
update_boss7_behavior_init:
	ld a, (current_world__difficulty)
	ld hl, boss7_difficulty_setting__easy
	or a
	jr z, update_boss7_behavior_init_continue
	ld hl, boss7_difficulty_setting__normal
	dec a
	jr z, update_boss7_behavior_init_continue
	dec a
	ld hl, boss7_difficulty_setting__hard
	jr z, update_boss7_behavior_init_continue
	ld hl, boss7_difficulty_setting__hardest
update_boss7_behavior_init_continue:
	ld de, boss__settings
	ld bc, 12
	ldir

; 	ld a, 22
; 	ld (boss__x), a
; 	ld a, 7
; 	ld (boss__y), a
; 	xor a
; 	ld (boss__x2), a
; 	ld (boss__y2), a
; 	ld (boss__6_eye_frame), a
; 	ld (boss__6_face_turret_frame), a
; 	ld hl, (boss__settings + BOSS_7_HP_OFFSET)
; 	ld (boss__hp), hl
; 	ld hl, player_weapon_hitbox_check_boss__boss7_hit
; 	ld (boss__hit_fn), hl
; 	ld a, BOSS_7_PAGE
; 	ld (boss__hit_fn_page), a
; 	ld a, 1
; 	ld (boss__state), a
	ret

update_boss7_behavior_0_wait_for_player:
	; condition for the boss to trigger:

	ld a, (player_x + 1)  ; tile x
	cp 48
	ret c

	; appear!
	xor a
	ld (boss__state), a
	inc a
	ld (boss__behavior), a

	; close door:
	; ...

	ld hl, SFX_door_open
	call play_SFX_with_high_priority
	ld b, 50
	call wait_b_halts

	; snake face appears:
	; ...


	ld ix, boss7_name_initial_sprite_attributes
	ld de, boss7_name_y_table
	ld hl, update_boss_behavior_bring_name_down_ix
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	ld b, 200
	call wait_b_halts_skippable
	ld ix, boss7_name_initial_sprite_attributes
	ld de, boss7_name_y_table + 23
	ld hl, update_boss_behavior_bring_name_up_ix
	ld c, BOSS_PAGE
	call call_hl_in_page_c_8000

	; start tile animations:
; 	ld hl, update_animations_in_vdp_boss7
; 	ld (current_room__animation_fn_ptr), hl

	ret



;-----------------------------------------------
; phase 1:
update_boss7_behavior_1:
	; states:
	; ...
; 	ld a, (boss__state)
; 	or a
; 	jr z, update_boss7_behavior_1_state_0
; 	dec a
; 	jp z, update_boss7_behavior_1_state_1
	; ...
	ret


;-----------------------------------------------
; phase 2:
update_boss7_behavior_2:
	; states:
	; ...
; 	ld a, (boss__state)
; 	or a
; 	jr z, update_boss7_behavior_2_state_0
; 	dec a
; 	jp z, update_boss7_behavior_2_state_1
	; ...
	ret


;-----------------------------------------------
; phase 3:
update_boss7_behavior_3:
	; states:
	; ...
; 	ld a, (boss__state)
; 	or a
; 	jr z, update_boss7_behavior_3_state_0
; 	dec a
; 	jp z, update_boss7_behavior_3_state_1
	; ...
	ret


;-----------------------------------------------
; death:
update_boss7_behavior_4:
	; states:
	; ...
; 	ld a, (boss__state)
; 	or a
; 	jr z, update_boss7_behavior_4_state_0
; 	dec a
; 	jp z, update_boss7_behavior_4_state_1
	; ...
	ret


;-----------------------------------------------
; input:
; - e: tile number that was hit
; - iyh: damage to deal
; - iyl: collision ID
; - ix: ptr of the tile we hit
player_weapon_hitbox_check_boss__boss7_hit:
	ld a, (boss__behavior)
	or a
	ret z

	; check if we have hit the face or tail:
	; ...
player_weapon_hitbox_check_boss__boss7_hit_vulnerable_spot:
	ld hl, player_weapon_hitbox_check_boss__lose_hp
	ld c, BOSS_PAGE
	jp call_hl_in_page_c_8000	

