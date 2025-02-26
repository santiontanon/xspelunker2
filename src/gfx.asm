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
; - a: megarom page where the tiles are
setup_game_tiles:
    SETMEGAROMPAGE_8000_A
    ld de, buffer_4096
    call dzx0

    ; bank 0:
    ld hl, buffer_4096
    ld de, CHRTBL2
    ld bc, 256*8
    call fast_LDIRVM

    ld hl, buffer_4096 + 2048
    ld de, CLRTBL2
    ld bc, 256*8
    call fast_LDIRVM

    ; bank 1:
    ld hl, buffer_4096
    ld de, CHRTBL2 + 256*8
    ld bc, 256*8
    call fast_LDIRVM

    ld hl, buffer_4096 + 2048
    ld de, CLRTBL2 + 256*8
    ld bc, 256*8
    call fast_LDIRVM

    ; bank 2:
    ld hl, buffer_4096
    ld de, CHRTBL2 + 256*8*2
    ld bc, 256*8
    call fast_LDIRVM

    ld hl, buffer_4096 + 2048
    ld de, CLRTBL2 + 256*8*2
    ld bc, 256*8
    jp fast_LDIRVM
