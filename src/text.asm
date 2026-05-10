; ------------------------------------------------
clear_text_rendering_buffer:
    ld bc, 32*8-1
clear_text_rendering_buffer_bc_set:
    ld hl, text_draw_buffer
    jp clear_memory


; ------------------------------------------------
copy_ix_text_to_buffer_4096:
	ld de, buffer_4096
copy_ix_text_to_de:
	push ix
	pop hl
	ld c, (hl)
	ld b, 0
	inc c
	ldir
	ret


; ------------------------------------------------
; concatenates two strings into buffer_4096
; input:
; - ix: string1
; - de: string2
text_concatenate_strings:
	ld hl, buffer_4096
	ld a, (de)
	add a, (ix)
	inc a  ; add a space in between
	ld (hl), a
	inc hl
	push de
		ex de, hl
		push ix
		pop hl
		ld b, 0
		ld c, (hl)
		inc hl
		ldir
		xor a  ; a space
		ld (de), a
		inc de
	pop hl
	ld c, (hl)
	inc hl
	ldir
	ret


DRAW_SENTENCE_TO_VDP_MACRO: MACRO TEXT, VRAM, ATTRIBUTE, LENGTH
	ld hl, TEXT
	ld de, VRAM
	ld iy, #8000 + ATTRIBUTE
	ld b, LENGTH
	call draw_sentence_to_vdp_clearing_text_buffer
	ENDM

DRAW_SENTENCE_TO_VDP_REMOTE_MACRO: MACRO TEXT, VRAM, ATTRIBUTE, LENGTH
	ld hl, TEXT
	ld de, VRAM
	ld iy, #8000 + ATTRIBUTE
	ld b, LENGTH
	call draw_sentence_to_vdp_from_another_page
	ENDM

DRAW_SENTENCE_TO_VDP_REMOTE_MACRO_DE_SET: MACRO TEXT, ATTRIBUTE, LENGTH
	ld hl, TEXT
	ld iy, #8000 + ATTRIBUTE
	ld b, LENGTH
	call draw_sentence_to_vdp_from_another_page
	ENDM


DRAW_SENTENCE_TO_VDP_REMOTE_MACRO_OFFSET: MACRO TEXT, VRAM, ATTRIBUTE_OFFSET, LENGTH
	ld hl, TEXT
	ld de, VRAM
	ld iy, ATTRIBUTE_OFFSET
	ld b, LENGTH
	call draw_sentence_to_vdp_from_another_page
	ENDM


; ------------------------------------------------
; Draws a sentence to video memory
; input:
; - hl: sentence to draw (first byte is the length)
; - iyh: pixel to start from (128 to start in pixel 0)
draw_sentence_to_vdp_internal_from_buffer_4096:
	ld hl, buffer_4096
draw_sentence_to_vdp_internal:
	push de
	push bc
		ld de, text_draw_buffer
	    ld b, (hl)   ; get the sentence length
	    inc hl
	    ld c, iyh
	    ld a, b
	    or a
	    jr z, draw_sentence_to_vdp_loop_end
draw_sentence_to_vdp_loop:
	    push bc
	    push hl
	        ld a, (hl)
	        call draw_font_character
	        ld a, c	; we save the pixel mask
	    pop hl
	    pop bc
	    ld c, a

	    ; next character
	    inc hl  
	    djnz draw_sentence_to_vdp_loop
draw_sentence_to_vdp_loop_end:
	pop bc
	pop de
	ret


; ------------------------------------------------
; Draws a sentence to video memory
; input:
; - hl: sentence to draw (first byte is the length)
; - de: target VRAM address (ptr to CHRTBL2)
; - iyl: color (attribute byte)
; - iyh: pixel to start from (128 to start in pixel 0)
; - b: expected width in tiles
draw_sentence_to_vdp_clearing_text_buffer:
	push hl
	push de
	push bc
		call clear_text_rendering_buffer
	pop bc
	pop de
	pop hl
	call draw_sentence_to_vdp_internal
; 	jp render_text_draw_buffer


; ------------------------------------------------
; input:
; - de: VRAM address where to start drawing (ptr to CHRTBL2)
; - iyl: attribute (color)
; - b: expected length in characters
render_text_draw_buffer:
	ld hl, text_draw_buffer
render_text_draw_buffer_loop:
	push bc
		push hl
			push de
				push de
					ld b, 8
					call fast_small_LDIRVM
				pop hl
				ld bc, CLRTBL2 - CHRTBL2
				add hl, bc
				ld a, iyl
				ld b, 8
				call fast_small_FILVRM
			pop hl
			ld c, 8  ; b == 0 here
			add hl, bc
			ex de, hl
		pop hl
		ld c, 8  ; b == 0 here already
		add hl, bc
	pop bc
	djnz render_text_draw_buffer_loop
	ret


; ------------------------------------------------
; Draws a character to a buffer
; input:
; - a: character to draw
; - de: memory address to draw
; - c: pixel offset (to determine whether we start in pixel 0, 1, 2, 3, 4, 5, 6, or 7 in the current tile)
;	- This is a "mask": 1, 2, 4, 8, 16, 32, ...
draw_font_character:
    ; get the pointer to the character:
    push de
        ; for variable size fonts:
        ld d, 0
        ld e, a
        ld hl, font_bin
        add hl, de
        add hl, de
        add hl, de	; index of the letter is a*3
    pop de

    ld b, (hl)	; character size
    inc hl
draw_font_character_loop:
    push de
		push bc
		    ld b, (hl)	; column bitmap
		    inc hl

		    ; render one column of the character:
REPT 7
		    sra b
		    jp nc, draw_font_character_loop_no_pixel
		    ld a, (de)
		    or c
		    ld (de), a
draw_font_character_loop_no_pixel:
			inc e
ENDR
			; last iteration is special, as it does not need the "inc e"
		    sra b
		    jp nc, draw_font_character_loop_no_pixel_iteration8
		    ld a, (de)
		    or c
		    ld (de), a
draw_font_character_loop_no_pixel_iteration8:
	    pop bc
	    rrc c
	    jr nc, draw_font_character_loop_no_next_tile
	    inc e
    pop af  ; we want to keep the current value of de, so, we just pop "de" into af
    djnz draw_font_character_loop
    ret
draw_font_character_loop_no_next_tile:
	pop de  ; we recover the previous value of "de" (beginnig of this same tile)
    djnz draw_font_character_loop
    ret


; ------------------------------------------------
; Calculates the maximum length that can be rendered without overflowing iyl pixels.
; Only "spaces" are considered as possible splits
; input:
; - hl: sentence
; - iyl: max pixels in the line
; output:
; - a/ixl: number of characters that can be drawn
max_length_of_sentence_in_one_line_ix:
	push ix
	pop hl
max_length_of_sentence_in_one_line:
    ld ixl, 0  ; best found so far
    ld ixh, 0  ; current character
    ld b, (hl)  ; get the sentence length
    inc hl
    xor a  ; pixels drawn
    ld d, 0
max_length_of_sentence_in_one_line_loop:
    ld e, (hl)
    ex af, af'
        ld a, e
        or a  ; is it a space?
        jr nz, max_length_of_sentence_in_one_line_no_space
        ld a, ixh
        inc a  ; we increase it in one to skip the space
        ld ixl, a
max_length_of_sentence_in_one_line_no_space:
    ex af, af'
    inc ixh
    push hl
        ld hl, font_bin
        add hl, de
        add hl, de
        add hl, de   ; index of the letter is a*3
        add a, (hl)   ; letter width in pixels
    pop hl
    inc hl  ; does not modify the flags
    cp iyl
    jr nc, max_length_of_sentence_in_one_line_limit_reached
    djnz max_length_of_sentence_in_one_line_loop
    ld a, ixh
    ld ixl, a
    ret
max_length_of_sentence_in_one_line_limit_reached:
    ld a, ixl
    ret


; ------------------------------------------------
; Calculates the width of a text string
; Only "spaces" are considered as possible splits
; input:
; - hl: sentence
; output:
; - a: sentence width (assuming it's < 256)
text_string_width:
    ld d, 0
    ld b, (hl)  ; get the sentence length
    inc hl
    xor a  ; pixels drawn
text_string_width_loop:
    ld e, (hl)
    push hl
        ld hl, font_bin
        add hl, de
        add hl, de
        add hl, de   ; index of the letter is a*3
        add a, (hl)   ; letter width in pixels
    pop hl
    inc hl  ; does not modify the flags
    djnz text_string_width_loop
    ret
