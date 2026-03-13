;-----------------------------------------------
update_boss5_behavior:
	ld hl, boss__hit_timer
	ld a, (hl)
	or a
	jr z, update_boss5_behavior_continue
	dec (hl)
update_boss5_behavior_continue:
	ld a, (boss__active)
	or a
	ret z

	; ...

	ld a, (boss__behavior)
	or a
	jp z, update_boss5_behavior_0  ; before boss is spawned (we don't even know if it's charybdis or scylla here)
; 	dec a
; 	jp z, update_boss5_behavior_1  ; walking
; 	dec a
; 	jp z, update_boss5_behavior_2  ; stomping
; 	jp update_boss5_behavior_3  ; death
	ret


;-----------------------------------------------
object_interaction_function_poseidon_boss_display_internal:
	ld hl, SFX_ui_move
	call play_SFX_with_high_priority
	ld hl, redraw_flags
	set ROOM_REDRAW_FLAG_BIT, (hl)

	inc (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	ld a, (ix + ROOM_TILE_OBJECT_STRUCT_STATE_TIMER)
	and #1f
	jr z, object_interaction_function_poseidon_boss_display_internal_both
	and #07
	jr z, object_interaction_function_poseidon_boss_display_internal_skull
	and #01
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), a
object_interaction_function_poseidon_boss_display_internal_continue:
	ld c, TILES_PAGE
	ld hl, room_undraw_tile_objects
	call call_hl_in_page_c_8000
	ld c, TILES_PAGE
	ld hl, room_render_tile_objects
	jp call_hl_in_page_c_8000

object_interaction_function_poseidon_boss_display_internal_skull:
	ld hl, SFX_secret
	call play_SFX_with_high_priority
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 2
	jr object_interaction_function_poseidon_boss_display_internal_continue

object_interaction_function_poseidon_boss_display_internal_both:
	ld hl, SFX_secret
	call play_SFX_with_high_priority
	ld (ix + ROOM_TILE_OBJECT_STRUCT_STATE), 3
	jr object_interaction_function_poseidon_boss_display_internal_continue



;-----------------------------------------------
update_boss5_behavior_0:
	ld a, (boss__state)
	or a
	jr z, update_boss5_behavior_0_state_0
	; ...	
	ret

update_boss5_behavior_0_state_0:
	; draw island:
	ld de, current_room__tile_map + 18*32 + 12
	ld ix, boss5_frame_island_0
	ld c, BOSS_PAGE
	ld hl, draw_boss_frame_1_without_clearing_ix
	call call_hl_in_page_c_8000

	ld a, 1
	ld (boss__state), a
	ret

