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
; - number:
;    0: 2 times
;    1: 3 times
;    2: 4 times
;    3: 5 times
;    4: 6 times

;-----------------------------------------------
pcg_generate_maya_puzzle_riddles:
	ld hl, current_world__maya_puzzle_riddles
	call pcg_generate_maya_puzzle_riddle_sentence
	ld hl, current_world__maya_puzzle_riddles + 3
	jp pcg_generate_maya_puzzle_riddle_sentence


;-----------------------------------------------
pcg_generate_maya_puzzle_riddle_sentence:
	; generate verb:
	ld c, 12
	call pcg_random_modulo
	ld (hl), a
	inc hl
	cp 11  ; ascend
	jr z, pcg_generate_maya_puzzle_riddle_sentence_ascend
	ld c, 10
	call pcg_random_modulo
	ld (hl), a
	inc hl
pcg_generate_maya_puzzle_riddle_sentence_number:
	ld c, 5
	call pcg_random_modulo
	ld (hl), a
	ret

pcg_generate_maya_puzzle_riddle_sentence_ascend:
	ld (hl), 10  ; ladder
	inc hl
	jr pcg_generate_maya_puzzle_riddle_sentence_number

