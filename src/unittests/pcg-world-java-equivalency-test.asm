; Unit tests run on MDL, and not on an MSX machine, so, we can use the whole 64k space.
	org #0000
	ld sp, #ffff

	include "../constants.asm"
	include "../auxiliar.asm"
	include "../input.asm"
hardcoded_world_data:
IF PCG_WORLD_SEED1 = 0
	include "hardcoded-world-seed0.asm"
ENDIF
IF PCG_WORLD_SEED1 = 1
	include "hardcoded-world-seed1.asm"
ENDIF
IF PCG_WORLD_SEED1 = 2
	include "hardcoded-world-seed2.asm"
ENDIF
IF PCG_WORLD_SEED1 = 3
	include "hardcoded-world-seed3.asm"
ENDIF
IF PCG_WORLD_SEED1 = 4
	include "hardcoded-world-seed4.asm"
ENDIF
IF PCG_WORLD_SEED1 = 5
	include "hardcoded-world-seed5.asm"
ENDIF
IF PCG_WORLD_SEED1 = 6
	include "hardcoded-world-seed6.asm"
ENDIF
IF PCG_WORLD_SEED1 = 7
	include "hardcoded-world-seed7.asm"
ENDIF
IF PCG_WORLD_SEED1 = 8
	include "hardcoded-world-seed8.asm"
ENDIF
IF PCG_WORLD_SEED1 = 9
	include "hardcoded-world-seed9.asm"
ENDIF
IF PCG_WORLD_SEED1 = 10
	include "hardcoded-world-seed10.asm"
ENDIF
IF PCG_WORLD_SEED1 = 11
	include "hardcoded-world-seed11.asm"
ENDIF
IF PCG_WORLD_SEED1 = 12
	include "hardcoded-world-seed12.asm"
ENDIF
IF PCG_WORLD_SEED1 = 13
	include "hardcoded-world-seed13.asm"
ENDIF
IF PCG_WORLD_SEED1 = 14
	include "hardcoded-world-seed14.asm"
ENDIF
IF PCG_WORLD_SEED1 = 15
	include "hardcoded-world-seed15.asm"
ENDIF
IF PCG_WORLD_SEED1 = 16
	include "hardcoded-world-seed16.asm"
ENDIF
IF PCG_WORLD_SEED1 = 17
	include "hardcoded-world-seed17.asm"
ENDIF
IF PCG_WORLD_SEED1 = 18
	include "hardcoded-world-seed18.asm"
ENDIF
IF PCG_WORLD_SEED1 = 19
	include "hardcoded-world-seed19.asm"
ENDIF
IF PCG_WORLD_SEED1 = 20
	include "hardcoded-world-seed20.asm"
ENDIF
IF PCG_WORLD_SEED1 = 21
	include "hardcoded-world-seed21.asm"
ENDIF
IF PCG_WORLD_SEED1 = 22
	include "hardcoded-world-seed22.asm"
ENDIF
IF PCG_WORLD_SEED1 = 23
	include "hardcoded-world-seed23.asm"
ENDIF
hardcoded_world_data_end:
	include "../pcg-world.asm"
	include "../pcg-riddles.asm"
	include "empty-callbacks.asm"


;-----------------------------------------------
test_start:
	; set random seed:
	ld hl, PCG_WORLD_SEED1
	ld (current_world__seed), hl
	ld hl, PCG_WORLD_SEED2
	ld (current_world__seed + 2), hl

	ld a, 2
	ld (current_world__difficulty), a

	; generate world:
	call pcg_generate_world
	jr z, pcg_generate_world_call_succeeded
	nop  ; mdl-watch: "test__pcg_generate_world call failed!"
pcg_generate_world_call_succeeded:

	ld hl, hardcoded_world_data
	ld de, current_world__area_data
	ld bc, hardcoded_world_data_end - hardcoded_world_data
	call test__arrays_equal

test_end:
	jr test_end


;-----------------------------------------------
; input:
; - hl, de: arrays to compare
; - bc: length
test__arrays_equal:
	push bc  ; we save BC in IX, so that we can print a debug statement with the offset.
	pop ix  ; mdl-watch2: "test__arrays_equal: hl,de,bc", hl, de, bc
test__arrays_equal_loop:
	ld a, (de)
	cp (hl)
	jr nz, test__arrays_equal_fail
	inc de
	inc hl
	dec bc
	ld a, c
	or b
	ret z
	jr test__arrays_equal_loop


;-----------------------------------------------
test__arrays_equal_fail:
	ld a, (hl)  ; mdl-watch: "test__arrays_equal_fail: (hl)", hl, a
	inc hl
	ld a, (hl)  ; mdl-watch: "test__arrays_equal_fail: (hl+1)", a
	inc hl
	ld a, (hl)  ; mdl-watch: "test__arrays_equal_fail: (hl+2)", a
	ld a, (de)  ; mdl-watch: "test__arrays_equal_fail: (de)", de, a
	inc de
	ld a, (de)  ; mdl-watch: "test__arrays_equal_fail: (de+1)", a
	inc de
	ld a, (de)  ; mdl-watch: "test__arrays_equal_fail: (de+2)", a
	push ix
	pop hl
	or a
	sbc hl, bc
	nop  ; mdl-watch: "test__arrays_equal_fail: offset", hl
	or 1
	ret


;-----------------------------------------------
	include "../ram.asm"
