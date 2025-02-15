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
; b - number of halts
; wait_b_halts:
;     halt
;     djnz wait_b_halts
;     ret


;-----------------------------------------------
; wait_b_halts_skippable:
;     halt
;     CHECK_KEY_CLICK_WITH_ALTERNATE KEY_BUTTON_1, KEY_JUMP
;     ret nz
;     djnz wait_b_halts_skippable
;     ret


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
; Source: http://wikiti.brandonw.net/index.php?title=Z80_Routines:Math:Random
; Generate a random number
; ouput:
; - a: 8bit random number
random:
    push hl
    push de
        ld hl, (randData)
        ld a, r
        ld d, a
        ld e, (hl)
        add hl, de
        add a, l
        xor h
        ld (randData), hl
    pop de
    pop hl
    ret


; randomSeedUpdate:
;     ld a, (randSeedIndex)
;     inc a
;     ld (randSeedIndex), a
;     and #01
;     jp z, randomSeedUpdate2
;     ld a, r
;     ld (randData), a
;     ret
; randomSeedUpdate2:
;     ld a, r
;     ld (randData + 1), a
;     ret

