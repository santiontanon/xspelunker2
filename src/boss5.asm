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

; 	ld a, (boss__behavior)
; 	or a
; 	jp z, update_boss5_behavior_0  ; before boss is spawned
; 	dec a
; 	jp z, update_boss5_behavior_1  ; walking
; 	dec a
; 	jp z, update_boss5_behavior_2  ; stomping
; 	jp update_boss5_behavior_3  ; death
	ret
