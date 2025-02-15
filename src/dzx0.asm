; -----------------------------------------------------------------------------
; ZX0 decoder by Einar Saukas
; "Standard" version (69 bytes only)
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

; dzx0:
; dzx0_standard:
;         ld      bc, #ffff               ; preserve default offset 1
;         push    bc
;         inc     bc
;         ld      a, #80
; dzx0s_literals:
;         call    dzx0s_elias             ; obtain length
;         ldir                            ; copy literals
;         add     a, a                    ; copy from last offset or new offset?
;         jr      c, dzx0s_new_offset
;         call    dzx0s_elias             ; obtain length
; dzx0s_copy:
;         ex      (sp), hl                ; preserve source, restore offset
;         push    hl                      ; preserve offset
;         add     hl, de                  ; calculate destination - offset
;         ldir                            ; copy from offset
;         pop     hl                      ; restore offset
;         ex      (sp), hl                ; preserve offset, restore source
;         add     a, a                    ; copy from literals or new offset?
;         jr      nc, dzx0s_literals
; dzx0s_new_offset:
;         call    dzx0s_elias             ; obtain offset MSB
;         ex      af, af'
;         pop     af                      ; discard last offset
;         xor     a                       ; adjust for negative offset
;         sub     c
;         ret     z                       ; check end marker
;         ld      b, a
;         ex      af, af'
;         ld      c, (hl)                 ; obtain offset LSB
;         inc     hl
;         rr      b                       ; last offset bit becomes first length bit
;         rr      c
;         push    bc                      ; preserve new offset
;         ld      bc, 1                   ; obtain length
;         call    nc, dzx0s_elias_backtrack
;         inc     bc
;         jr      dzx0s_copy
; dzx0s_elias:
;         inc     c                       ; interlaced Elias gamma coding
; dzx0s_elias_loop:
;         add     a, a
;         jr      nz, dzx0s_elias_skip
;         ld      a, (hl)                 ; load another group of 8 bits
;         inc     hl
;         rla
; dzx0s_elias_skip:
;         ret     c
; dzx0s_elias_backtrack:
;         add     a, a
;         rl      c
;         rl      b
;         jr      dzx0s_elias_loop
; -----------------------------------------------------------------------------


; -----------------------------------------------------------------------------
; ZX0 decoder by Einar Saukas & introspec
; "Turbo" version (128 bytes, 21% faster) - OLD FILE FORMAT v1
; - Modified by Santiago Ontañón to remove the self-modifying bits (and work from ROM).
;   it is a tiny bit slower, but still faster than the standard version above
; -----------------------------------------------------------------------------
; Parameters:
;   HL: source address (compressed data)
;   DE: destination address (decompressing)
; -----------------------------------------------------------------------------

dzx0:
; dzx0_turbo:
        ld      bc, $ffff               ; preserve default offset 1
        ld      (dzx0t_last_offset_tmp), bc
        inc     bc
        ld      a, $80
        jp      dzx0t_literals
dzx0t_new_offset:
        inc     c                       ; obtain offset MSB
        add     a, a
        jp      nz, dzx0t_new_offset_skip
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
dzx0t_new_offset_skip:
        call    nc, dzx0t_elias
        ex      af, af'                 ; adjust for negative offset
        xor     a
        sub     c
        ret     z                       ; check end marker
        ld      b, a
        ex      af, af'
        ld      c, (hl)                 ; obtain offset LSB
        inc     hl
        rr      b                       ; last offset bit becomes first length bit
        rr      c
        ld      (dzx0t_last_offset_tmp), bc  ; preserve new offset
        ld      bc, 1                   ; obtain length
        call    nc, dzx0t_elias
        inc     bc
dzx0t_copy:
        push    hl                      ; preserve source
        ld      hl, (dzx0t_last_offset_tmp)  ; restore offset
        add     hl, de                  ; calculate destination - offset
        ldir                            ; copy from offset
        pop     hl                      ; restore source
        add     a, a                    ; copy from literals or new offset?
        jr      c, dzx0t_new_offset
dzx0t_literals:
        inc     c                       ; obtain length
        add     a, a
        jp      nz, dzx0t_literals_skip
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
dzx0t_literals_skip:
        call    nc, dzx0t_elias
        ldir                            ; copy literals
        add     a, a                    ; copy from last offset or new offset?
        jr      c, dzx0t_new_offset
        inc     c                       ; obtain length
        add     a, a
        jp      nz, dzx0t_last_offset_skip
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
dzx0t_last_offset_skip:
        call    nc, dzx0t_elias
        jp      dzx0t_copy
dzx0t_elias:
        add     a, a                    ; interlaced Elias gamma coding
        rl      c
        add     a, a
        jr      nc, dzx0t_elias
        ret     nz
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
        ret     c
        add     a, a
        rl      c
        add     a, a
        ret     c
        add     a, a
        rl      c
        add     a, a
        ret     c
        add     a, a
        rl      c
        add     a, a
        ret     c
dzx0t_elias_loop:
        add     a, a
        rl      c
        rl      b
        add     a, a
        jr      nc, dzx0t_elias_loop
        ret     nz
        ld      a, (hl)                 ; load another group of 8 bits
        inc     hl
        rla
        jr      nc, dzx0t_elias_loop
        ret
; -----------------------------------------------------------------------------


;-----------------------------------------------
dzx0_from_page_c:
    ld a, (current_megarom_page_in_8000)
    push af
        ld a, c
        SETMEGAROMPAGE_8000_A
        call dzx0
    pop af
    SETMEGAROMPAGE_8000_A
    ret    
