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
    ; ensure tile 0 is all black (we only need to ensure this on bank 3 for XSpelunker 2):
    ld hl, CLRTBL2 + 256*8*2
    ld b, 8
    xor a
    call fast_small_FILVRM
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
fast_small_FILVRM:
    push af
        call SETWRT
        ld a, (VDP.DW)
        ld c, a
    pop af
fast_small_FILVRM_loop:
    out (c), a
    dec b
    jp nz, fast_small_FILVRM_loop
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
    call setup_game_tiles_only_biome

    ; hud tiles (includes generic in-game tiles too, like coins, etc.):
    ld hl, tiles_hud_zx0
    ld de, buffer_4096
    ld c, TILES_HUD_PAGE
    call dzx0_from_page_c

    ld de, CHRTBL2
    ld bc, 48*8
    jp upload_tile_patch_to_all_banks


;-----------------------------------------------
; Uploads a a subset of tiles from buffer_4096 to the VDP
; input:
; - de: destination in the CHRTBL2 table
; - bc: size (number of tiles * 8)
upload_tile_patch_to_all_banks:
    ld a, 3
upload_tile_patch_to_all_banks_loop:
    ld hl, buffer_4096
    push af
        push de
            push bc
                push de
                    push bc
                        call fast_LDIRVM
                    pop bc
                    ; ld hl, buffer_4096 + 48*8
                    ld hl, buffer_4096
                    add hl, bc
                    ex de, hl  ; de = buffer_4096 + bc
                pop hl
                ld bc, CLRTBL2 - CHRTBL2
                add hl, bc
                ex de, hl  ; hl = buffer_4096 + bc, de = start in CLRTBL2
            pop bc
            push bc
                call fast_LDIRVM
            pop bc  ; restore bc for next loop
        pop hl
        ld de, 256*8
        add hl, de
        ex de, hl  ; restore de for next loop
    pop af
    dec a
    jr nz, upload_tile_patch_to_all_banks_loop
    ret

;     ld hl, buffer_4096
;     ld de, CHRTBL2 + 256*8
;     ld bc, 48*8
;     call fast_LDIRVM

;     ld hl, buffer_4096 + 48*8
;     ld de, CLRTBL2 + 256*8
;     ld bc, 48*8
;     call fast_LDIRVM

;     ld hl, buffer_4096
;     ld de, CHRTBL2 + 256*8*2
;     ld bc, 48*8
;     call fast_LDIRVM

;     ld hl, buffer_4096 + 48*8
;     ld de, CLRTBL2 + 256*8*2
;     ld bc, 48*8
;     jp fast_LDIRVM


;-----------------------------------------------
; input:
; - hl: ptr to tiles
; - c: megarom page where the tiles are
setup_game_tiles_only_biome:
    ld de, buffer_4096
    call dzx0_from_page_c

    ld a, (current_room__tileset_overrides_item_tiles)
    ld bc, 192*8
    ld de, CHRTBL2 + 64*8
    or a
    jr z, setup_game_tiles_only_biome_continue
    ld bc, 208*8
    ld de, CHRTBL2 + 48*8
setup_game_tiles_only_biome_continue:

    ; bank 0:
    ld hl, buffer_4096
    push hl
    push bc
        push de
            call fast_LDIRVM
        pop hl
        ld bc, CLRTBL2 - CHRTBL2
        add hl, bc
        ex de, hl  ; de = CLRTBL2 + 64*8
    pop bc
    pop hl
    add hl, bc
    push bc
        push de
            call fast_LDIRVM
        pop hl
        ld bc, CHRTBL2 + 256*8 - CLRTBL2
        add hl, bc
        ex de, hl  ; de = CHRTBL2 + 256*8 + 64*8
    pop bc

    ; bank 1:
    ld hl, buffer_4096
    push hl
    push bc
        push de
            call fast_LDIRVM
        pop hl
        ld bc, CLRTBL2 - CHRTBL2
        add hl, bc
        ex de, hl  ; de = CLRTBL2 + 256*8 + 64*8
    pop bc
    pop hl
    add hl, bc
    push bc
        push de
            call fast_LDIRVM
        pop hl
        ld bc, CHRTBL2 + 256*8 - CLRTBL2
        add hl, bc  ; de = CHRTBL2 + 256*8*2 + 64*8
        ex de, hl
    pop bc

    ; bank 2:
    halt  ; synchronize the last bank so that when we use this method for swapping tile sets
          ; in bosses, we minimize the time with a glitch
    ld hl, buffer_4096
    push hl
    push bc
        push de
            call fast_LDIRVM
        pop hl
        ld bc, CLRTBL2 - CHRTBL2
        add hl, bc
        ex de, hl  ; de = CLRTBL2 + 256*8*2 + 64*8
    pop bc
    pop hl
    add hl, bc
    call fast_LDIRVM

    ; tileset modifications:
    ; in calendar room:
    ld a, (current_area__id)
    cp 3
    jr z, setup_game_tiles_only_biome_area_3
    ld a, (current_area__id)
    cp 9
    jr z, setup_game_tiles_only_biome_area_9
    ; ...
    ret

setup_game_tiles_only_biome_area_3:
    ld a, (current_room__id)
    cp CALENDAR_ROOM_ID
    ret nz

    ; first stone effect:
    ld a, (global_state__n_power_stones_in_calendar)
    or a
    ret z
    ld hl, pcg_generate_room__calendar_turn_on_phase1
    ld c, PCG_PAGE
    call call_hl_in_page_c_8000    

    ; third stone effect:
    ld a, (global_state__n_power_stones_in_calendar)
    cp 3
    ret c
    ld hl, pcg_generate_room__calendar_turn_on_phase2
    ld c, PCG_PAGE
    jp call_hl_in_page_c_8000

setup_game_tiles_only_biome_area_9:
    ld a, (boss__active)
    or a
    ret z

    ; boss 5 room, make bg of boss tiles dark blue (they are in water):
    ld hl, boss5_tile_attributes_patch
    ld c, BOSS_5_PAGE
    jp call_hl_in_page_c_8000


; -----------------------------------------------
; input:
; - hl: ptr to zx0 compressed tiles
; - c: page where the tiles are
decompress_tiles_to_all_banks:
    ld de, buffer_4096
    call dzx0_from_page_c

    ld hl, buffer_4096
    ld de, CHRTBL2
    ld bc, 256*8
    call fast_LDIRVM
    ld hl, buffer_4096 + 256*8
    ld de, CLRTBL2
    ld bc, 256*8
    call fast_LDIRVM

    ld hl, buffer_4096
    ld de, CHRTBL2 + 256*8
    ld bc, 256*8
    call fast_LDIRVM
    ld hl, buffer_4096 + 256*8
    ld de, CLRTBL2 + 256*8
    ld bc, 256*8
    call fast_LDIRVM

    ld hl, buffer_4096
    ld de, CHRTBL2 + 256*8*2
    ld bc, 256*8
    call fast_LDIRVM
    ld hl, buffer_4096 + 256*8
    ld de, CLRTBL2 + 256*8*2
    ld bc, 256*8
    jp fast_LDIRVM
