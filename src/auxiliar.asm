;-----------------------------------------------
; From: http://www.z80st.es/downloads/code/ (author: Konamiman)
; GETSLOT: constructs the SLOT value to then call ENSALT
; input:
; a: slot
; output:
; a: value for ENSALT
GETSLOT:    
    and #03             ; Proteccion, nos aseguramos de que el valor esta en 0-3
    ld c, a             ; c = slot de la pagina
    ld b, 0             ; bc = slot de la pagina
    ld hl, #fcc1        ; Tabla de slots expandidos
    add hl, bc          ; hl -> variable que indica si este slot esta expandido
    ld a, (hl)          ; Tomamos el valor
    and #80             ; Si el bit mas alto es cero...
    jr z, GETSLOT_EXIT  ; ...nos vamos a GETSLOT_EXIT
    ; --- El slot esta expandido ---
    or c                ; Slot basico en el lugar adecuado
    ld c, a             ; Guardamos el valor en c
    inc hl              ; Incrementamos hl una...
    inc hl              ; ...dos...
    inc hl              ; ...tres...
    inc hl              ; ...cuatro veces
    ld a, (hl)          ; a = valor del registro de subslot del slot donde estamos
    and #0c             ; Nos quedamos con el valor donde esta nuestro cartucho
GETSLOT_EXIT:     
    or c                ; Slot extendido/basico en su lugar
    ret                 ; Volvemos


;-----------------------------------------------
; From: http://www.z80st.es/downloads/code/
; SETPAGES32K: BIOS-ROM-YY-ZZ   -> BIOS-ROM-ROM-ZZ (SITUA PAGINA 2)
SETPAGES32K:    ; --- Posiciona las paginas de un megarom o un 32K ---
    call RSLREG             ; Leemos el contenido del registro de seleccion de slots
    rrca                    ; Rotamos a la derecha...
    rrca                    ; ...dos veces
    call GETSLOT            ; Obtenemos el slot de la pagina 1 ($4000-$BFFF)
    ld h, #80               ; Seleccionamos pagina 2 ($8000-$BFFF)
    jp ENASLT               ; Posicionamos la pagina 2 y volvemos


;-----------------------------------------------
; source: https://www.msx.org/forum/development/msx-development/how-0?page=0
; returns 1 in a and clears z flag if vdp is 60Hz
; size: 27 bytes
CheckIf60Hz:
    di
    in a, (#99)
    nop
    nop
    nop
CheckIf60Hz_vdpSync:
    in a, (#99)
    and #80
    jr z, CheckIf60Hz_vdpSync
    
    ld hl, #900
CheckIf60Hz_vdpLoop:
    dec hl
    ld a, h
    or l
    jr nz, CheckIf60Hz_vdpLoop
    
    in a,(#99)
    rlca
    and 1
    ei
    ret


;-----------------------------------------------
; waits a given number of "halts"
; input:
; - b: number of halts
wait_b_halts:
    halt
    djnz wait_b_halts
    ret


; -----------------------------------------------
; waits a given number of "halts" (can be skipped pressing space)
; input:
; - b: number of halts
; output:
; - nz: skipped
; - z: not skipped
wait_b_halts_skippable:
    halt
    push bc
        call update_keyboard_buffers
    pop bc
    ld a, (keyboard_clicks)
    bit KEY_WEAPON_BIT, a
    ret nz
    djnz wait_b_halts_skippable
    ret


; -----------------------------------------------
; hl: memory to clear
; bc: bytes to clear - 1
clear_memory:
    xor a
clear_memory_a:
    ld d, h
    ld e, l
    inc de
    ld (hl), a
clear_memory_a_entry_point:
    ldir
    ret


; ;-----------------------------------------------
; ; faster version of the method above if the amount to clear is > 256:
; ; hl: memory to clear
; ; bc: bytes to clear - 1
; clear_memory_fast:
;     xor a
; clear_memory_fast_a:
;     ld d, h
;     ld e, l
;     inc de
;     ld (hl), a
;     ld a, b
;     or a
; clear_memory_fast_loop:
;     jr z, clear_memory_a_entry_point
; REPT 256
;     ldi
; ENDR
;     dec a
;     jp clear_memory_fast_loop


;-----------------------------------------------
; Adapted from the CHGET routine here: https://sourceforge.net/p/cbios/cbios/ci/master/tree/src/main.asm#l289
; It returns 0 if no key is ready to be read
getcharacter_nonwaiting:
    ld hl, (GETPNT)
    ld de, (PUTPNT)
    call DCOMPR
    jr z, getcharacter_nonwaiting_invalidkey
    ; there is a character ready to be read:
    ld a, (hl)
    push af
        inc hl
        ld a, l
        cp #00ff & (KEYBUF + 40)
        jr nz, getcharacter_nonwaiting_nowrap
        ld hl, KEYBUF
getcharacter_nonwaiting_nowrap:
        ld (GETPNT), hl
    pop af
    ret
getcharacter_nonwaiting_invalidkey:
    xor a
    ret

getcharacter_nonwaiting_reset:
    di
    ld hl, (PUTPNT)
    ld (GETPNT), hl
    ei
    ret


;-----------------------------------------------
ldir_from_page_a:
    ex af, af'
    ld a, (current_megarom_page_in_8000)
    push af
        ex af, af'
        SETMEGAROMPAGE_8000_A
        ldir
    pop af
    SETMEGAROMPAGE_8000_A
    ret


;-----------------------------------------------
a_mod_3:
    push bc
        ld c, a
        rrca
        rrca
        rrca
        rrca
        add a, c
        adc a, 0
        ld c, a
        rrca
        rrca
        add a, c
        adc a, 1
    pop bc
    ret z
    and #03
    dec a
    ret


;-----------------------------------------------
; Source: https://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random
; Generates a 16 bit random number
; - rng_seed1: 16-bit seed value
; - rng_seed2: NON-ZERO 16-bit seed value
;Outputs:
; - a: 8bit random number  (this method is capable of generating 16bit random numbers in hl, but I don't need them).
; random:
random_a:
    push hl
    push bc
        ld hl, (rng_seed1)
        ld b, h
        ld c, l
        add hl, hl
        add hl, hl
        inc l
        add hl, bc
        ld (rng_seed1), hl
        ld hl, (rng_seed2)
        add hl, hl
        sbc a, a
        and #2d
        xor l
        ld l, a
        ld (rng_seed2), hl
        add hl, bc
        ld a, l
    pop bc
    pop hl
    ret


;-----------------------------------------------
; input:
; - c: modulo
; output:
; - a: random % c
random_modulo:
    call random_a
random_modulo_loop:
    cp c
    ret c
    sub c
    jp random_modulo_loop
