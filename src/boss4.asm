;-----------------------------------------------
update_boss4_behavior:
	; check if we need to draw an overlay of the "damage face" when the boss is hit:
	ld hl, boss__hit_timer
	ld a, (hl)
	or a
	jr z, update_boss4_behavior_continue
	dec (hl)
update_boss4_behavior_continue:
	ld a, (boss__active)
	or a
	ret z

	; ...

	ret

