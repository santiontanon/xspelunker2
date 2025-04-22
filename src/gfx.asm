; -----------------------------------------------
disable_VDP_output:
    ld a,(VDP_REGISTER_1)
    and #bf ; reset the BL bit
    di
    out (#99),a
    ld  a,1+128 ; write to register 1
    ei
    out (#99),a
    ret


; -----------------------------------------------
enable_VDP_output:
    ld a,(VDP_REGISTER_1)
    or #40  ; set the BL bit
    di
    out (#99),a
    ld  a,1+128 ; write to register 1
    ei
    out (#99),a
    ret


;-----------------------------------------------
; clear sprites:
clear_all_the_sprites:
    ld hl,SPRATR2
    ld a,224
    ld bc,32*4
    jp fast_FILVRM


;-----------------------------------------------
clear_screen_left_to_right:
    call clear_all_the_sprites
    ld b, 32
    ld hl, NAMTBL2
clear_screen_left_to_right_loop:
    push hl
    push bc
        ld b, 24
clear_screen_left_to_right_loop2:
        push bc
            push hl
                call SETWRT
                ld a, (VDP.DW)
                ld c, a
                xor a
                out (c), a
            pop hl
            ld bc, 32
            add hl, bc
        pop bc
        djnz clear_screen_left_to_right_loop2
    pop bc
    pop hl
    inc hl
    halt
    djnz clear_screen_left_to_right_loop
    ret


;-----------------------------------------------
; sets the name table of the banks to: 0, 1, 2, 3, ..., 255
; and clears all patterns and attributes to 0
set_bitmap_mode:
    xor a
set_bitmap_mode_a_color:
    ld bc, 8 * 256 * 3
    push bc
        ld hl, CLRTBL2
        call fast_FILVRM
        xor a
    pop bc
    ld hl, CHRTBL2
    call fast_FILVRM
    ; jp set_bitmap_name_table_all_banks


;-----------------------------------------------
; sets the name table of the banks to: 0, 1, 2, 3, ..., 255
set_bitmap_name_table_all_banks:
    ld hl, NAMTBL2
    call set_bitmap_name_table
    ld hl, NAMTBL2 + 256
    call set_bitmap_name_table
set_bitmap_name_table_bank3:
    ld hl, NAMTBL2 + 512

set_bitmap_name_table:
    call SETWRT
    ld a, (VDP.DW)
    ld c, a
    xor a
    ld b, a
set_bitmap_name_table_bank3_loop:
    out (c), a
    inc a
    djnz set_bitmap_name_table_bank3_loop
    ret


;-----------------------------------------------
; a: byte
; bc: amount to write
; hl: target address in the VDP
fast_FILVRM:
    push af
        push bc
            call SETWRT
            ld a, (VDP.DW)
            ld c, a
        pop de
        ld a, e
        or a
        jr z, fast_FILVRM_no_inc
        inc d
fast_FILVRM_no_inc:
    pop af
fast_FILVRM_loop2:
fast_FILVRM_loop:
    out (c), a
    dec e
    jp nz, fast_FILVRM_loop
    ; ld e, 256  ; unnecessary, as e == 0 here already
    dec d
    jp nz, fast_FILVRM_loop2
    ret


;-----------------------------------------------
; a: byte
; b: amount to write
; hl: target address in the VDP
fast_FILVRM_small:
    push af
        call SETWRT
        ld a, (VDP.DW)
        ld c, a
    pop af
fast_FILVRM_small_loop:
    out (c), a
    dec b
    jp nz, fast_FILVRM_small_loop
    ret



;-----------------------------------------------
fast_LDIRVM_from_sprites_page:
    ld a, (current_megarom_page_in_8000)
    push af
        SETMEGAROMPAGE_8000 SPRITES_PAGE
        call fast_LDIRVM
    pop af
    SETMEGAROMPAGE_8000_A
    ret


;-----------------------------------------------
; hl: source data
; de: target address in the VDP
; bc: amount to copy
fast_LDIRVM:
    ex de, hl    ; this is wasteful, but it's to maintain the order of parameters of the original LDIRVM...
                ; For things that require real speed, this function should not be used anyway, but use specialized loops
    push de
        call SETWRT
    pop hl
    ; jp copy_to_VDP

;-----------------------------------------------
; This is like LDIRVM, but faster, and assumes, we have already called "SETWRT" with the right address
; input: 
; - hl: address to copy from
; - bc: amount fo copy
copy_to_VDP:
    ld e, b
    ld a, c
    or a
    jr z, copy_to_VDP_lsb_0
    inc e
copy_to_VDP_lsb_0:
    ld b, c
    ; get the VDP write register:
    ld a, (VDP.DW)
    ld c, a
    ld a, e
copy_to_VDP_loop2:
copy_to_VDP_loop:
    outi
    jp nz, copy_to_VDP_loop
    dec a
    jp nz, copy_to_VDP_loop2
    ret


;-----------------------------------------------
; hl: source data
; de: target address in the VDP
; b: amount to copy
fast_small_LDIRVM:
    ex de,hl    ; this is wasteful, but it's to maintain the order of parameters of the original LDIRVM...
                ; For things that require real speed, this function should not be used anyway,
                ; but use specialized loops.
    push de
        call SETWRT
    pop hl
    ; get the VDP write register:
    ld a, (VDP.DW)
    ld c, a
fast_small_LDIRVM_loop:
    outi
    jp nz, fast_small_LDIRVM_loop
    ret


;-----------------------------------------------
; input:
; - hl: ptr to tiles
; - c: megarom page where the tiles are
setup_game_tiles:
    ld a, (current_megarom_page_in_8000)
    push af
        call setup_game_tiles_biome_internal

        ; hud tiles (includes generic in-game tiles too, like coins, etc.):
        ld hl, tiles_hud_zx0
        ld de, buffer_4096
        call dzx0

        ld hl, buffer_4096
        ld de, CHRTBL2
        ld bc, 64*8
        call fast_LDIRVM

        ld hl, buffer_4096 + 64*8
        ld de, CLRTBL2
        ld bc, 64*8
        call fast_LDIRVM

        ld hl, buffer_4096
        ld de, CHRTBL2 + 256*8
        ld bc, 64*8
        call fast_LDIRVM

        ld hl, buffer_4096 + 64*8
        ld de, CLRTBL2 + 256*8
        ld bc, 64*8
        call fast_LDIRVM

        ld hl, buffer_4096
        ld de, CHRTBL2 + 256*8*2
        ld bc, 64*8
        call fast_LDIRVM

        ld hl, buffer_4096 + 64*8
        ld de, CLRTBL2 + 256*8*2
        ld bc, 64*8
        call fast_LDIRVM
    pop af
    SETMEGAROMPAGE_8000_A
    ret


;-----------------------------------------------
; input:
; - hl: ptr to tiles
; - c: megarom page where the tiles are
setup_game_tiles_only_biome:
    ld a, (current_megarom_page_in_8000)
    push af
        call setup_game_tiles_biome_internal
    pop af
    SETMEGAROMPAGE_8000_A
    ret


;-----------------------------------------------
; input:
; - hl: ptr to tiles
; - c: megarom page where the tiles are
setup_game_tiles_biome_internal:
    ld a, c
    SETMEGAROMPAGE_8000_A
    ld de, buffer_4096
    call dzx0

    ; bank 0:
    ld hl, buffer_4096
    ld de, CHRTBL2 + 64*8
    ld bc, 192*8
    call fast_LDIRVM

    ld hl, buffer_4096 + 192*8
    ld de, CLRTBL2 + 64*8
    ld bc, 192*8
    call fast_LDIRVM

    ; bank 1:
    ld hl, buffer_4096
    ld de, CHRTBL2 + 256*8 + 64*8
    ld bc, 192*8
    call fast_LDIRVM

    ld hl, buffer_4096 + 192*8
    ld de, CLRTBL2 + 256*8 + 64*8
    ld bc, 192*8
    call fast_LDIRVM

    ; bank 2:
    ld hl, buffer_4096
    ld de, CHRTBL2 + 256*8*2 + 64*8
    ld bc, 192*8
    call fast_LDIRVM

    ld hl, buffer_4096 + 192*8
    ld de, CLRTBL2 + 256*8*2 + 64*8
    ld bc, 192*8
    jp fast_LDIRVM
