; ------------------------------------------------
clear_text_rendering_buffer:
    ld bc, 32*8-1
clear_text_rendering_buffer_bc_set:
    ld hl, text_draw_buffer
    jp clear_memory


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


; ------------------------------------------------
; input:
; - ix: sentence to draw (first byte is the length)
; - de: target NAMTBL2 address
; - iyl: color (attribute byte)
draw_sentence20_simple_white:
	ld iyl, COLOR_WHITE * 16
draw_sentence20_simple:
	push de
		push de
			call clear_text_rendering_buffer
		pop de
		; determine if we are writing to bank 1, 2 or 3:
		ld h, d
		ld l, e
		ld bc, NAMTBL2 + 256
		or a
		sbc hl, bc
		jr c, draw_sentence20_simple_bank1
		ld bc, 256
		sbc hl, bc
		jr c, draw_sentence20_simple_bank2
draw_sentence20_simple_bank3:
		ld de, CHRTBL2 + (12 + 256*2)*8
		jp draw_sentence20_simple_continue
draw_sentence20_simple_bank1:
		ld de, CHRTBL2 + 12*8
		jp draw_sentence20_simple_continue
draw_sentence20_simple_bank2:
		ld de, CHRTBL2 + (12 + 256)*8
draw_sentence20_simple_continue:
		push ix
		pop hl
		ld iyh, 128
		ld b, 20
		call draw_sentence_to_vdp
	pop hl  ; NAMTBL2 address
    call SETWRT
    ld a, (VDP.DW)
    ld c, a

    ; write 12, 13, 14, ... to the proper position in the name table
    ld a, 12
    ld b, 20
draw_sentence20_simple_loop:
    out (c), a
    inc a
    djnz draw_sentence20_simple_loop
	ret



; ------------------------------------------------
; Draws a sentence to video memory
; input:
; - hl: sentence to draw (first byte is the length)
; - de: target VRAM address (ptr to CHRTBL2)
; - iyl: color (attribute byte)
; - iyh: pixel to start from (128 to start in pixel 0)
; - b: expected width in tiles
draw_sentence_to_vdp:
	push de
	push bc
		ld de, text_draw_buffer
	    ld b, (hl)   ; get the sentence length
	    inc hl
	    ld c, iyh
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
	pop bc
	pop de
	ld a, iyl
; 	jp render_text_draw_buffer


; ------------------------------------------------
; input:
; - de: VRAM address where to start drawing (ptr to CHRTBL2)
; - a: attribute (color)
; - b: expected length in characters
; - (slow_text_rendering_on): whether we 'halt' and check for keyboard each tile
; output:
; - (slow_text_rendering_on): reset to 0 in case a key was pressed
render_text_draw_buffer:
	ld hl, text_draw_buffer
render_text_draw_buffer_loop:
	push bc
		push hl
			push de
				push af
					push de
						ld b, 8
						call fast_small_LDIRVM
					pop hl
					ld bc, CLRTBL2 - CHRTBL2
					add hl, bc
				pop af
				ld b, 8
				call fast_FILVRM_small
			pop hl
			ld c, 8  ; b == 0 here
			add hl, bc
			ex de, hl
		pop hl
		ld c, 8  ; b == 0 here already
		add hl, bc
	pop bc

; 	push af
; 	push hl
; 		; if we need to wait for a key press, do it:
; 		ld a, (slow_text_rendering_on)
; 		or a
; 		jr z, render_text_draw_buffer_loop_continue
; 		halt
; 		halt
; 		CHECK_KEY_CLICK_WITH_ALTERNATE KEY_BUTTON_1, KEY_JUMP
; 		jr nz, render_text_draw_buffer_loop_key_pressed
; 		halt
; 		halt
; 		CHECK_KEY_CLICK_WITH_ALTERNATE KEY_BUTTON_1, KEY_JUMP
; 		jr z, render_text_draw_buffer_loop_continue
; render_text_draw_buffer_loop_key_pressed:
; 		xor a
; 		ld (slow_text_rendering_on), a  ; skip the rest of the text
; render_text_draw_buffer_loop_continue:
; 	pop hl
; 	pop af
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

