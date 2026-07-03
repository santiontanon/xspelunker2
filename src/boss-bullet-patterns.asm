;-----------------------------------------------
BOSS_BULLET_PATTERN_EASY1: equ 0
BOSS_BULLET_PATTERN_EASY2: equ 1
BOSS_BULLET_PATTERN_MEDIUM1: equ 2
BOSS_BULLET_PATTERN_MEDIUM2: equ 3
BOSS_BULLET_PATTERN_HARD1: equ 4
BOSS_BULLET_PATTERN_HARD2: equ 5
BOSS_BULLET_PATTERN_HARDEST1: equ 5
BOSS_BULLET_PATTERN_HARDEST2: equ 6


;-----------------------------------------------
boss_bullet_patterns_table:
	dw boss_bullet_pattern_easy1
	dw boss_bullet_pattern_easy2
	dw boss_bullet_pattern_normal1
	dw boss_bullet_pattern_normal2
	dw boss_bullet_pattern_hard1
	dw boss_bullet_pattern_hard2
	dw boss_bullet_pattern_hardest1
	dw boss_bullet_pattern_hardest2

; n=number of bullets, time_1, ..., time_n, reset time
boss_bullet_pattern_easy1:
	db 3, 0, 16, 32, 76
boss_bullet_pattern_easy2:
	db 6, 0, 14, 28,  56, 70, 84, 112

boss_bullet_pattern_normal1:
	db 3, 0, 10, 20, 30, 60
boss_bullet_pattern_normal2:
	db 8, 0, 8, 16, 24,  48, 56, 64, 72, 104

boss_bullet_pattern_hard1:
	db 4, 0, 8, 16, 24, 56
boss_bullet_pattern_hard2:
	db 8, 0, 6, 12, 18,  36, 42, 48, 54, 80

boss_bullet_pattern_hardest1:
	db 5, 0, 6, 12, 18, 24,  48
boss_bullet_pattern_hardest2:
	db 10, 0, 4, 8, 12, 16,  28, 32, 36, 40, 44, 64


;-----------------------------------------------
; input:
; - a: pattern type
; output:
; - z: fire bullet
; - nz: do not fire
boss_bullet_pattern_cycle:
	ld hl, boss_bullet_patterns_table
	add a, a
	ADD_HL_A
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld b, (hl)  ; number of times
	inc hl
	ld a, (boss__bullet_pattern_state)
	inc a
	ld (boss__bullet_pattern_state), a
	dec a
boss_bullet_pattern_cycle_loop:
	cp (hl)
	ret z
	inc hl
	djnz boss_bullet_pattern_cycle_loop
	cp (hl)
	ret c
	xor a
	ld (boss__bullet_pattern_state), a
	or 1  ; do not fire
	ret

