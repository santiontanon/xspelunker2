;-----------------------------------------------
; each puzzle line consist of:
; - verb: 
;    0: strike
;    1: strike east
;    2: strike west
;    3: sit
;    4: sit east
;    5: sit west
;    6: blowgun
;    7: blowgun east
;    8: blowgun west
;    9: stand up west standup east
;    10: stand up east standup west
;    11: ascend (can only be followed by ladder)
; - location:
;    0: here
;    1: below jaguar
;    2: above jaguar
;    3: below snake
;    4: above snake
;    5: below eagle
;    6: above eagle
;    7: below fish
;    8: above fish
;    9: below ladder
;    10: ladder (can only go with ascend)
; - number of times (2 - 6)

;-----------------------------------------------
pcg_generate_maya_puzzle_riddles:
	; Generate the sentences for Maya puzzle 1:
	ld hl, current_world__maya_puzzle_riddles
	call pcg_generate_maya_puzzle_riddle_sentence
	ld hl, current_world__maya_puzzle_riddles + 3
	call pcg_generate_maya_puzzle_riddle_sentence

	; Generate the combinations for Maya puzzle 2:
	ld b, 8
	ld hl, current_world__maya_puzzle2_combination1
pcg_generate_maya_puzzle_riddles__puzzle2_loop:
	ld c, 5
	call random_modulo
	ld (hl), a
	inc hl
	djnz pcg_generate_maya_puzzle_riddles__puzzle2_loop
	ret


;-----------------------------------------------
pcg_generate_maya_puzzle_riddle_sentence:
	; generate verb:
	ld c, 12
	call random_modulo
	ld (hl), a
	inc hl
	cp 11  ; ascend
	jr z, pcg_generate_maya_puzzle_riddle_sentence_ascend
	ld c, 10
	call random_modulo
	ld (hl), a
	inc hl
pcg_generate_maya_puzzle_riddle_sentence_number:
	ld c, 5
	call random_modulo
	add a, 2
	ld (hl), a
	ret

pcg_generate_maya_puzzle_riddle_sentence_ascend:
	ld (hl), 10  ; ladder
	inc hl
	jr pcg_generate_maya_puzzle_riddle_sentence_number


;-----------------------------------------------
pcg_generate_syllable_riddle:
	ld hl, current_world__maya_puzzle3_nametable
	ld bc, 10*3 - 1
	ld a, 23
	call clear_memory_a

	ld hl, current_world__maya_puzzle3_word
	ld bc, 20 - 1
	call clear_memory

	ld ix, current_world__maya_puzzle3_nametable
	ld iy, current_world__maya_puzzle3_word
	; Sample from the grammar twice, to make for a longer word:
	call syllable_riddle__sample_from_grammar
	jp syllable_riddle__sample_from_grammar


;-----------------------------------------------
; input:
; - ix: ptr to name table
; - iy: ptr to word
syllable_riddle__sample_from_grammar:
	ld e, 0  ; constraint for the first syllable in the rules
	; [1x3 -R->] 
	call random_a
	and #0f
	jr nz, syllable_riddle__sample_from_grammar_continue
	; add a [1x3] piece:
	ld d, #13
	ld e, PCG_DIRECTION_RIGHT  ; constraint
	call syllable_riddle__sample_piece
	call syllable_riddle__add_piece
	ld e, PCG_DIRECTION_LEFT  ; constraint
	inc ix  ; move the ptr to the nametable
syllable_riddle__sample_from_grammar_continue:

	ld c, 4 + 4 + 4 + 2 + 3 + 3  ; grammar rule weights
	call random_modulo
	sub 4
	jp c, syllable_riddle__sample_from_grammar_rule1
	sub 4
	jp c, syllable_riddle__sample_from_grammar_rule2
	sub 4
	jp c, syllable_riddle__sample_from_grammar_rule3
	sub 2
	jp c, syllable_riddle__sample_from_grammar_rule4
	sub 3
	jp c, syllable_riddle__sample_from_grammar_rule5
	jp syllable_riddle__sample_from_grammar_rule6


;-----------------------------------------------
; input:
; - d: piece type
; - e: connection constraint
; output:
; - hl: piece ptr
; - nz: found
; - z: not found
syllable_riddle__sample_piece:
	; We use "reservoir sampling" to prevent having to build a "candidate list"
	push ix
	push iy
		ld iy, 0  ; the current candidate
		ld c, 0  ; number of candidates found so far
		ld ix, maya_syllable_table
		ld b, (maya_syllable_table_end - maya_syllable_table)/2
syllable_riddle__sample_piece_loop:
		ld l, (ix)
		ld h, (ix + 1)
		inc ix
		inc ix
		ld a, (hl)
		cp d  ; piece type
		jr nz, syllable_riddle__sample_piece_loop_next
		inc hl
		ld a, (hl)  ; constraint
		dec hl
		and e
		cp e
		jr nz, syllable_riddle__sample_piece_loop_next
		; candidate found!
		ld a, c
		or a
		jr z, syllable_riddle__sample_piece_first_candidate
		inc c
		call random_modulo
		or a
		jr nz, syllable_riddle__sample_piece_loop_next
		jr syllable_riddle__sample_piece_replace_candidate
syllable_riddle__sample_piece_first_candidate:
		inc c
syllable_riddle__sample_piece_replace_candidate:
		push hl
		pop iy
syllable_riddle__sample_piece_loop_next:
		djnz syllable_riddle__sample_piece_loop
		push iy
		pop hl  ; put the candidate ptr in hl
	pop iy
	pop ix
	ld a, c
	or a
	ret


;-----------------------------------------------
; input:
; - hl: piece ptr
; - ix: ptr to name table
; - iy: ptr to word
; output:
; - iy ptr is updated (ix ptr is NOT updated)
syllable_riddle__add_piece:
	push hl
		; add piece to the name table:
		ld e, (hl)  ; piece size
		ld a, e
		and #0f
		ld b, a  ; height
		ld a, e
		rrca
		rrca
		rrca
		rrca
		and #0f
		ld c, a  ; width
		inc hl
		inc hl
		push ix
syllable_riddle__add_piece_loop_y:
			push bc
				push ix
syllable_riddle__add_piece_loop_x:
					ld a, (hl)
					ld (ix), a
					inc hl
					inc ix
					dec c
					jr nz, syllable_riddle__add_piece_loop_x
				pop ix
				ld bc, 10
				add ix, bc  ; next line 
			pop bc
			djnz syllable_riddle__add_piece_loop_y
		pop ix

		; add text to the word:
syllable_riddle__add_piece_word_loop:
		ld a, (hl)
		or a
		jr z, syllable_riddle__add_piece_word_loop_done
		ld (iy), a
		inc iy
		inc hl
		jr syllable_riddle__add_piece_word_loop
syllable_riddle__add_piece_word_loop_done:
	pop hl
	ret


;-----------------------------------------------
; input:
; - ix: ptr to name table
; - iy: ptr to word
; - e: constraint for the 3x3 piece
syllable_riddle__sample_from_grammar_rule1:
    ; 3x3 [-R-> 3x1]
	ld d, #33
	call syllable_riddle__sample_piece
	call syllable_riddle__add_piece
	inc ix
	inc ix
	inc ix
	inc hl
	ld a, (hl)  ; constraint of last piece sampled
syllable_riddle__sample_from_grammar_rule1_tail_1x3:
	and PCG_DIRECTION_RIGHT
	ret z  ; if we cannot put another piece on the right, we are done
	call random_a
	and #0f
	ret nz
	ld e, PCG_DIRECTION_LEFT
	ld d, #13
	call syllable_riddle__sample_piece
	call syllable_riddle__add_piece
	inc ix
	ret


;-----------------------------------------------
; - ix: ptr to name table
; - iy: ptr to word
; - e: constraint for the 3x2 piece
syllable_riddle__sample_from_grammar_rule2:
    ; 3x2 -D-> 3x1 [-R-> 3x1]
	ld d, #32
	ld a, e
	or PCG_DIRECTION_DOWN
	ld e, a
	call syllable_riddle__sample_piece
	call syllable_riddle__add_piece
	inc hl
	ld a, (hl)  ; constraint of last piece sampled
	push af
		ld bc, 20
		add ix, bc
		ld d, #31
		ld e, PCG_DIRECTION_UP
		call syllable_riddle__sample_piece
		call syllable_riddle__add_piece
		ld bc, 3 - 20
		add ix, bc
	pop af
	jp syllable_riddle__sample_from_grammar_rule1_tail_1x3


;-----------------------------------------------
; - ix: ptr to name table
; - iy: ptr to word
; - e: constraint for the 3x2 piece
syllable_riddle__sample_from_grammar_rule3:
    ; 3x1 -D-> 3x2 [-R-> 1x3]
    push de
		ld d, #31
		ld e, PCG_DIRECTION_DOWN
		call syllable_riddle__sample_piece
		call syllable_riddle__add_piece
		ld bc, 10
		add ix, bc
    pop de
	ld d, #32
	ld a, e
	or PCG_DIRECTION_UP
	ld e, a
	call syllable_riddle__sample_piece
	call syllable_riddle__add_piece
	ld bc, 3 - 10
	add ix, bc
	inc hl
	ld a, (hl)  ; constraint of last piece sampled	
	jp syllable_riddle__sample_from_grammar_rule1_tail_1x3


;-----------------------------------------------
; - ix: ptr to name table
; - iy: ptr to word
; - e: constraint for the 2x3 piece
syllable_riddle__sample_from_grammar_rule4:
    ; 2x3 [-R-> 3x1]
	ld d, #23
	call syllable_riddle__sample_piece
	call syllable_riddle__add_piece
	inc ix
	inc ix
	inc hl
	ld a, (hl)  ; constraint of last piece sampled
	jr syllable_riddle__sample_from_grammar_rule1_tail_1x3


;-----------------------------------------------
; - ix: ptr to name table
; - iy: ptr to word
; - e: constraint for the 2x2 piece
syllable_riddle__sample_from_grammar_rule5:
    ; 2x2 -D-> 2x1 [-R-> 3x1]
	ld d, #22
	ld a, e
	or PCG_DIRECTION_DOWN
	ld e, a
	call syllable_riddle__sample_piece
	call syllable_riddle__add_piece
	inc hl
	ld a, (hl)  ; constraint of last piece sampled
	push af
		ld bc, 20
		add ix, bc
		ld d, #21
		ld e, PCG_DIRECTION_UP
		call syllable_riddle__sample_piece
		call syllable_riddle__add_piece
		ld bc, 2 - 20
		add ix, bc
	pop af
	jp syllable_riddle__sample_from_grammar_rule1_tail_1x3


;-----------------------------------------------
; - ix: ptr to name table
; - iy: ptr to word
; - e: constraint for the 2x2 piece
syllable_riddle__sample_from_grammar_rule6:
    ; 2x1 -D-> 2x2 [-R-> 3x1]
    push de
		ld d, #21
		ld e, PCG_DIRECTION_DOWN
		call syllable_riddle__sample_piece
		call syllable_riddle__add_piece
		ld bc, 10
		add ix, bc
    pop de
	ld d, #22
	ld a, e
	or PCG_DIRECTION_UP
	ld e, a
	call syllable_riddle__sample_piece
	call syllable_riddle__add_piece
	ld bc, 2 - 10
	add ix, bc
	inc hl
	ld a, (hl)  ; constraint of last piece sampled	
	jp syllable_riddle__sample_from_grammar_rule1_tail_1x3


;-----------------------------------------------
maya_syllable_table:
	dw maya_syllable_ke
	dw maya_syllable_ja
	dw maya_syllable_chu
	dw maya_syllable_e
	dw maya_syllable_pe
	dw maya_syllable_lu
	dw maya_syllable_se
	dw maya_syllable_cha
	dw maya_syllable_ka
	dw maya_syllable_ki
	dw maya_syllable_le
	dw maya_syllable_ne
	dw maya_syllable_ya
	dw maya_syllable_na
	dw maya_syllable_ko
	dw maya_syllable_ba
	dw maya_syllable_la
	dw maya_syllable_pu
	dw maya_syllable_ba2
	dw maya_syllable_ma
	dw maya_syllable_wa
	dw maya_syllable_t_a
	dw maya_syllable_a
	dw maya_syllable_mu
	dw maya_syllable_bu
maya_syllable_table_end:

	; size (wwwwhhhh), connections, ...tiles..., ascii, 0
	; connection bits: 0000LURD
maya_syllable_ke:
	db #33, #0c, 38, 39, 40, 54, 55, 56, 70, 71, 72, "ke", 0
maya_syllable_ja:
	db #33, #0d, 83, 84, 85, 99, 100, 101, 115, 116, 117, "ja", 0
maya_syllable_chu:
	db #33, #0f, 86, 87, 88, 102, 103, 104, 118, 119, 120, "chu", 0
maya_syllable_e:
	db #33, #07, 90, 91, 92, 106, 107, 108, 122, 123, 124, "e", 0
maya_syllable_pe:
	db #33, #07, 128, 129, 130, 144, 145, 146, 160, 161, 162, "pe", 0
maya_syllable_lu:
	db #33, #0d, 131, 132, 133, 147, 148, 149, 163, 164, 165, "lu", 0
maya_syllable_se
	db #32, #0d, 57, 58, 59, 73, 74, 75, "se", 0
maya_syllable_cha
	db #32, #0d, 44, 45, 46, 60, 61, 62, "cha", 0
maya_syllable_ka
	db #32, #0d, 96, 97, 98, 112, 113, 114, "ka", 0
maya_syllable_ki
	db #31, #01, 41, 42, 43, "ki", 0
maya_syllable_le
	db #31, #05, 134, 135, 136, "le", 0
maya_syllable_ne
	db #31, #05, 150, 151, 152, "ne", 0
maya_syllable_ya
	db #31, #05, 166, 167, 168, "ya", 0
maya_syllable_na
	db #31, #05, 76, 77, 78, "na", 0
maya_syllable_ko
	db #31, #05, 80, 81, 82, "ko", 0
maya_syllable_ba
	db #23, #0a, 32, 33, 48, 49, 64, 65, "ba", 0
maya_syllable_la
	db #22, #0d, 34, 35, 50, 51, "la", 0
maya_syllable_pu
	db #22, #0d, 36, 37, 52, 53, "pu", 0
maya_syllable_ba2
	db #22, #0f, 110, 111, 126, 127, "ba", 0
maya_syllable_ma
	db #21, #04, 66, 67, "ma", 0
maya_syllable_wa
	db #21, #05, 68, 69, "wa", 0
maya_syllable_t_a
	db #21, #05, 94, 95, "t'a", 0
maya_syllable_a
	db #13, #02, 47, 63, 79, "a", 0
maya_syllable_mu
	db #13, #08, 89, 105, 121, "mu", 0
maya_syllable_bu
	db #13, #08, 93, 109, 125, "bu", 0


;-----------------------------------------------
pcg_generate_atlantis_boss_riddle:
	call random_a
	and #03
	ld (current_world__atlantis_boss_statue), a
	ret
