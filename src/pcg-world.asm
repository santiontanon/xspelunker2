;-----------------------------------------------
; input:
; - de: seed 1
pcg_generate_world:
	ld (rng_seed1), de

	; ...

	; for now just copy over the hardcoded data:
	ld hl, hardcoded_world_data
	ld de, current_world__area_data
	ld bc, hardcoded_world_data_end - hardcoded_world_data
	ldir

	call pcg_generate_maya_puzzle_riddles
	jp pcg_generate_syllable_riddle


;-----------------------------------------------
; input:
; - c: modulo
; output:
; - a: random % c
pcg_random_modulo:
	call random_a
pcg_random_modulo_loop:
	cp c
	ret c
	sub c
	jr pcg_random_modulo_loop
