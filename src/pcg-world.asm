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
	ret
