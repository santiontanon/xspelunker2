;-----------------------------------------------
pcg_generate_room__spawn_enemies:
	; ...

	; DEBUG: spawn one snake
	call ptr_to_new_sprite_enemy
	ret nz
	ld (hl), ENEMY_SNAKE_DASHER
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 8  ; tile x
	inc hl
	ld (hl), 0
	inc hl
	ld (hl), 8  ; tile y
	inc hl
	ld (hl), 0
	inc hl
	inc hl
	inc hl
	ld (hl), 1  ; health
	ret

