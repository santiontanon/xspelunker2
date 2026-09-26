; ------------------------------------------------
; Custom interrupt handler (this will be copied to RAM,
; so that it's not affected when we change pages in #4000 and #8000):
; In order to make things easier to relocate, DO NOT USE "jp" instructions in this code.
start_of_interrupt_code_rom:
interrupt_callback:
    push af
    push bc
    push de
    push hl
        ld hl, interrupt_cycle
        inc (hl)

        ; handle SFX and music:
        ld a, (current_room__music_page)
        SETMEGAROMPAGE_8000_A_WITHOUT_TRACKING  ; we do it this way to save CPU cycles
        call update_sound
        ld a, (current_megarom_page_in_8000)
        SETMEGAROMPAGE_8000_A_WITHOUT_TRACKING  ; restore the page we had in 8000
    pop hl
    pop de
    pop bc
    pop af
    ei
    ret

end_of_interrupt_code_rom:
