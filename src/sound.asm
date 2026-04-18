;-----------------------------------------------
; Note: this code assumes music is in page 1 of the cartridge.
; input:
; - hl: ptr to compressed song
; - a: MUSIC_tempo. This is assumed to be the tempo for 50Hz machines. IF we are in a 60Hz machine,
;      this method will try to adjust it.
play_music_adjusting_tempo:
    ld (MUSIC_original_tempo), a
    ld e, a
    ld a, (isComputer50HzOr60Hz)
    or a
    ld a, e
    jr z, play_music_adjusting_tempo_continue
    cp 12
    jr z, play_music_adjusting_tempo_12
    cp 10
    jr z, play_music_adjusting_tempo_10
    cp 6
    jr z, play_music_adjusting_tempo_6
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_12:
    ld e, 14
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_10:
    ld e, 12
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_6:
    ld e, 7
play_music_adjusting_tempo_continue:
    ld a, e
    ld (MUSIC_tempo), a
    push hl
        call stop_music
    pop hl
    ld a, 1
    di
        ld (MUSIC_currently_playing_music_ptr), hl
        ld (MUSIC_play), a
        ld (MUSIC_pointer), hl
        ld (MUSIC_start_pointer), hl
        ld hl, MUSIC_repeat_stack
        ld (MUSIC_repeat_stack_ptr), hl
    ei
    ret


;-----------------------------------------------
stop_music:
    ld hl, beginning_of_sound_variables_except_tempo
    ld bc, (end_of_sound_variables - beginning_of_sound_variables_except_tempo) - 1
    di
    call clear_memory
    call clear_PSG_volume
    ei
    ret


;-----------------------------------------------
ResumeMusic:
    ld a, (MUSIC_currently_playing_music_ptr)
    or a
    ret z  ; there was no music playing anyway
    ld a, 1
    ld (MUSIC_play), a
    ret


;-----------------------------------------------
PauseMusic:
    xor a
    ld (MUSIC_play), a
    ; jp clear_PSG_volume


;-----------------------------------------------
; silences all 3 channels of the PSG
clear_PSG_volume:
    ld a, 8
    ld e, 0
    fast_WRTPSG_macro
    ld a, 9
    fast_WRTPSG_macro
    ld a, 10
    fast_WRTPSG_macro
    ret


;-----------------------------------------------
; Starts playing an SFX
; arguments: 
; - a: SFX priority
; - hl: pointer to the SFX to play
play_SFX_with_high_priority:
    ld a, SFX_PRIORITY_HIGH
play_SFX_with_priority:
    push hl
        ld hl, SFX_priority
        cp (hl)
    pop hl
    ret m
    di
        ld (SFX_pointer), hl
        ld (SFX_priority), a
        xor a
        ld (MUSIC_instruments + 2), a  ; reset the instrument in channel 3 to Square wave, so it does not interfere with the SFX
    ei
    ret


;-----------------------------------------------
; Music player update routine
; We do not need to push many registers, since this is called from within the custom_interrupt, which already pushed af, bc, de and hl
update_music_skip:
    dec a
    ld (MUSIC_tempo_counter), a
update_sound_no_music:
    ld a, (SFX_priority)
    or a
    ret z
    xor a
    ld (MUSIC_time_step_required), a
    ld hl, (SFX_pointer)
    call update_sound_internal
    ld (SFX_pointer), hl
    ret


update_sound:     ; This routine sould be called 50 or 60 times / sec 
    ld a, (MUSIC_play)
    or a
    jr z, update_sound_no_music
    update_sound_handle_instruments_macro
    ld a, (MUSIC_tempo_counter)
    or a
    jp nz, update_music_skip
    ld (MUSIC_time_step_required), a  ; a == 0 here
    ld hl, (MUSIC_pointer)
    call update_sound_internal
    ld (MUSIC_pointer), hl
    ld a, (MUSIC_tempo)
    ld (MUSIC_tempo_counter), a
    ld a, (SFX_priority)
    or a
    ret z
    xor a
    ld (MUSIC_time_step_required), a
    ld hl, (SFX_pointer)
    call update_sound_internal
    ld (SFX_pointer), hl
    ret


;-----------------------------------------------
; handle the volume curves of the music instruments, and the arpeggiator
update_sound_handle_instruments_macro: macro
    ld a, (MUSIC_instruments)
    or a  ; MUSIC_INSTRUMENT_SQUARE_WAVE
    jr z, update_sound_handle_instruments_CH2
IF MUSIC_USE_ARPEGGIOS = 1
    ; handle arpeggios, channel 1:
    ld a, (MUSIC_intrument_arpeggio)
    inc a  ; cp #ff
    jr z, update_sound_handle_instruments_not_arpeggio_CH1
    push hl
        ld hl, MUSIC_intrument_arpeggio
        ld a, (interrupt_cycle)
        and #03
        ADD_HL_A
        ld a, (MUSIC_instrument_base_note)
        add a, (hl)

        ld hl, note_period_table
        ADD_HL_A
        ld e, (hl)  ; MSB of the period    
        inc l  ; note_period_table is 2-aligned
        ld a, 1
        fast_WRTPSG_macro
        ld e, (hl)  ; LSB of the period    
        xor a
        fast_WRTPSG_macro
    pop hl
update_sound_handle_instruments_not_arpeggio_CH1:        
ENDIF
    ld de, (MUSIC_instrument_envelope_ptr)
    ld a, (de)
    cp #ff
    jr z, update_sound_handle_instruments_CH2
    inc de
    ld (MUSIC_instrument_envelope_ptr), de
IF MUSIC_USE_SET_VOLUME = 1
    ; a -= (MUSIC_volumes)
    ex de, hl
        ld hl, MUSIC_volumes
        sub (hl)
    ex de, hl
    jr nc, sound_update_handle_instruments_CH1_continue2
    xor a
sound_update_handle_instruments_CH1_continue2:
ENDIF
    ld e, a
    ld a, 8
    fast_WRTPSG_macro
update_sound_handle_instruments_CH2:
    ld a, (MUSIC_instruments + 1)
    or a  ; MUSIC_INSTRUMENT_SQUARE_WAVE
    jr z, update_sound_handle_instruments_CH3
IF MUSIC_USE_ARPEGGIOS = 1
    ; handle arpeggios, channel 2:
    ld a, (MUSIC_intrument_arpeggio + 4)
    inc a  ; cp #ff
    jr z, update_sound_handle_instruments_not_arpeggio_CH2
    push hl
        ld a, (interrupt_cycle)
        and #03
        ld hl, MUSIC_intrument_arpeggio + 4
        ADD_HL_A
        ld a, (MUSIC_instrument_base_note + 1)
        add a, (hl)

        ld hl, note_period_table
        ADD_HL_A
        ld e, (hl)  ; MSB of the period    
        inc l  ; note_period_table is 2-aligned
        ld a, 3
        fast_WRTPSG_macro
        ld e, (hl)  ; LSB of the period    
        ld a, 2
        fast_WRTPSG_macro
    pop hl
update_sound_handle_instruments_not_arpeggio_CH2
ENDIF
    ld de, (MUSIC_instrument_envelope_ptr + 2)
    ld a, (de)
    cp #ff
    jr z, update_sound_handle_instruments_CH3
    inc de
    ld (MUSIC_instrument_envelope_ptr + 2), de
IF MUSIC_USE_SET_VOLUME = 1
    ; a -= (MUSIC_volumes + 1)
    ex de, hl
        ld hl, MUSIC_volumes + 1
        sub (hl)
    ex de, hl
    jr nc, sound_update_handle_instruments_CH2_continue2
    xor a
sound_update_handle_instruments_CH2_continue2:
ENDIF    
    ld e, a
    ld a, 9
    fast_WRTPSG_macro
update_sound_handle_instruments_CH3:
    ld a, (SFX_priority)
    or a
    jr nz, update_sound_handle_instruments_macro_end  ; if there is an SFX playing, then do not update the instruments in channel 3!
    ld a, (MUSIC_instruments + 2)
    or a  ; MUSIC_INSTRUMENT_SQUARE_WAVE 
    jr z, update_sound_handle_instruments_macro_end
IF MUSIC_USE_ARPEGGIOS = 1
    ; handle arpeggios, channel 3:
    ld a, (MUSIC_intrument_arpeggio + 8)
    inc a  ; cp #ff
    jr z, update_sound_handle_instruments_not_arpeggio_CH3
    push hl
        ld a, (interrupt_cycle)
        and #03
        ld hl, MUSIC_intrument_arpeggio + 8
        ADD_HL_A
        ld a, (MUSIC_instrument_base_note + 2)
        add a, (hl)

        ld hl, note_period_table
        ADD_HL_A
        ld e, (hl)  ; MSB of the period    
        inc l  ; note_period_table is 2-aligned
        ld a, 5
        fast_WRTPSG_macro
        ld e, (hl)  ; LSB of the period    
        ld a, 4
        fast_WRTPSG_macro
    pop hl
update_sound_handle_instruments_not_arpeggio_CH3:
ENDIF
    ld de, (MUSIC_instrument_envelope_ptr + 4)
    ld a, (de)
    cp #ff
    jr z, update_sound_handle_instruments_macro_end
    inc de
    ld (MUSIC_instrument_envelope_ptr + 4), de
IF MUSIC_USE_SET_VOLUME = 1
    ; a -= (MUSIC_volumes + 2)
    ex de, hl
        ld hl, MUSIC_volumes + 2
        sub (hl)
    ex de, hl
    jr nc, sound_update_handle_instruments_CH3_continue2
    xor a
sound_update_handle_instruments_CH3_continue2:
ENDIF    
    ld e, a
    ld a, 10
    fast_WRTPSG_macro
update_sound_handle_instruments_macro_end:
    endm


update_sound_SET_INSTRUMENT:
    ld d, (hl)   ; instrument
    inc hl
    ld a, (hl)   ; channel
    inc hl
    push hl
        cp 2
        jr nz, update_sound_SET_INSTRUMENT_not_third_channel
        ld hl, MUSIC_channel3_instrument_buffer
        ld (hl), d
update_sound_SET_INSTRUMENT_not_third_channel:
        ld hl, MUSIC_instruments
IF MUSIC_USE_ARPEGGIOS = 1
        push af
        ADD_HL_A
        ld (hl), d
        pop af
        ld hl, MUSIC_intrument_arpeggio
        add a, a
        add a, a
        ADD_HL_A  ; hl: ptr to the corresponding 'MUSIC_intrument_arpeggio'
        ld a, d
        ex de, hl
        cp MUSIC_INSTRUMENT_ARPEGGIO_MAJOR
        jr c, update_sound_SET_INSTRUMENT_not_an_arpeggio
        ld hl, diminished_arpeggio_pattern
        cp MUSIC_INSTRUMENT_ARPEGGIO_DIMINISHED_FADEIN
        jr z, update_sound_SET_INSTRUMENT_arpeggio
        ld hl, major_arpeggio_pattern
        jr z, update_sound_SET_INSTRUMENT_arpeggio
        cp MUSIC_INSTRUMENT_ARPEGGIO_MAJOR_FADEIN
        jr z, update_sound_SET_INSTRUMENT_arpeggio
        ld hl, major_arpeggio_2ndinv_pattern
        cp MUSIC_INSTRUMENT_ARPEGGIO_MAJOR_2NDINV
        jr z, update_sound_SET_INSTRUMENT_arpeggio
        ld hl, minor_arpeggio_pattern
        cp MUSIC_INSTRUMENT_ARPEGGIO_MINOR
        jr z, update_sound_SET_INSTRUMENT_arpeggio
        cp MUSIC_INSTRUMENT_ARPEGGIO_MINOR_FADEIN
        jr z, update_sound_SET_INSTRUMENT_arpeggio
        ld hl, minor_arpeggio_2ndinv_pattern
update_sound_SET_INSTRUMENT_arpeggio:
        ldi
        ldi
        ldi
        ldi
    pop hl
    jp update_sound_internal_loop
update_sound_SET_INSTRUMENT_not_an_arpeggio:
        ld a, #ff
        ld (de), a  ; mark that it's not an arpeggio
    pop hl
    jp update_sound_internal_loop
ELSE
        ADD_HL_A
        ld (hl), d
    pop hl
    jp update_sound_internal_loop
ENDIF

update_sound_GOTO:
    ld e, (hl)
    inc hl
    ld d, (hl)
    ld hl, (MUSIC_start_pointer)
    add hl, de
    ; we also need to silence channels 1 and 2, just in case
    ld a, 8
    ld e, 0
    fast_WRTPSG_macro
    ld a, 9
    fast_WRTPSG_macro
    ; xor a  ; not needed, as it's 0 after 'fast_WRTPSG_macro' with e = 0.
    ld (MUSIC_instruments), a
    ld (MUSIC_instruments + 1), a
    jp update_sound_internal_loop


update_sound_REPEAT:
    ld a, (hl)
    inc hl
    push de
        ex de, hl
        ld hl, (MUSIC_repeat_stack_ptr)
        ld (hl), a
        inc hl
        ld (hl), e
        inc hl
        ld (hl), d
        inc hl
        ld (MUSIC_repeat_stack_ptr), hl
        ex de, hl
    pop de
    jp update_sound_internal_loop


update_sound_END_REPEAT:
    ; decrease the top value of the repeat stack
    ; if it is 0, pop
    ; if it is not 0, goto the repeat point
    push ix
        ld ix, (MUSIC_repeat_stack_ptr)
        ld a, (ix - 3)
        dec a
        jr z, update_sound_END_REPEAT_POP
        ld (ix - 3), a
        ld l, (ix - 2)
        ld h, (ix - 1)
    pop ix
    jp update_sound_internal_loop
update_sound_END_REPEAT_POP:
        dec ix
        dec ix
        dec ix
        ld (MUSIC_repeat_stack_ptr), ix
    pop ix
    jp update_sound_internal_loop


update_sound_WRTPSG:
    and #0f ; clear all the flags that the command might have
    ld e, (hl)
    inc hl
    fast_WRTPSG_macro  ; send command to PSG
;     jp update_sound_internal_loop     


update_sound_internal_loop:
    ; check if there is a time step required on the last command
    ld a, (MUSIC_time_step_required)
    or a
    ret nz
update_sound_internal:
    ld a, (hl)
    inc hl 
    ; check if it's a special command:
    bit 6, a
    jp z, update_sound_internal_no_time_step
    ex de, hl  ; 5
        ld hl, MUSIC_time_step_required  ; 11
        ld (hl), 1  ; 11
    ex de, hl  ; 5
update_sound_internal_no_time_step:    
    bit 7, a
    jp z, update_sound_WRTPSG
    and #3f ; clear all the flags the command might have
    ret z   ; MUSIC_CMD_SKIP command
    dec a   ; MUSIC_CMD_SET_INSTRUMENT
    jp z, update_sound_SET_INSTRUMENT
    dec a   ; MUSIC_CMD_PLAY_INSTRUMENT_CH1
    jr z, update_sound_PLAY_INSTRUMENT_CH1
    dec a   ; MUSIC_CMD_PLAY_INSTRUMENT_CH2
    jr z, update_sound_PLAY_INSTRUMENT_CH2
    dec a   ; MUSIC_CMD_PLAY_INSTRUMENT_CH3
    jp z, update_sound_PLAY_INSTRUMENT_CH3
    dec a   ; MUSIC_CMD_PLAY_SFX_OPEN_HIHAT
    jr z, update_sound_PLAY_SFX_OPEN_HIHAT
    dec a   ; MUSIC_CMD_PLAY_SFX_SHORT_HIHAT
    jr z, update_sound_PLAY_SFX_SHORT_HIHAT
;     dec a   ; MUSIC_CMD_PLAY_SFX_DRUM_SHORT_RE
;     jr z, update_sound_PLAY_SFX_DRUM_SHORT_RE
    dec a   ; MUSIC_CMD_PLAY_SFX_DRUM_SHORTER_RE
    jr z, update_sound_PLAY_SFX_DRUM_SHORTER_RE
    dec a   ; MUSIC_CMD_PLAY_SFX_DRUM_SHORTER_C
    jr z, update_sound_PLAY_SFX_DRUM_SHORTER_C
    dec a   ; MUSIC_CMD_PLAY_SFX_SHORT_HIHAT_LOUDER
    jr z, update_sound_PLAY_SFX_SHORT_HIHAT_LOUDER
    dec a   ; MUSIC_CMD_GOTO
    jp z, update_sound_GOTO
    dec a   ; MUSIC_CMD_REPEAT
    jp z, update_sound_REPEAT
    dec a   ; MUSIC_CMD_END_REPEAT
    jr z, update_sound_END_REPEAT
IF MUSIC_USE_SET_VOLUME = 1
    dec a  ; MUSIC_CMD_SET_VOLUME1
    jr z, sound_update_set_volume1
    dec a  ; MUSIC_CMD_SET_VOLUME2
    jr z, sound_update_set_volume2
    dec a  ; MUSIC_CMD_SET_VOLUME3
    jr z, sound_update_set_volume3
ENDIF

;    dec a   ; MUSIC_CMD_TRANSPOSE_UP
;    jr z, update_sound_TRANSPOSE_UP
;    dec a   ; MUSIC_CMD_CLEAR_TRANSPOSE
;    jr z, update_sound_CLEAR_TRANSPOSE
    ; SFX_CMD_END
;    jp update_sound_SFX_END  ; if the SFX sound is over, we are done


update_sound_SFX_END:
    xor a
    ld (SFX_priority), a
    ld a, 7
    ld e, #b8  ; SFX should reset all channels to tone
    fast_WRTPSG_macro
    ret


update_sound_PLAY_SFX_OPEN_HIHAT:
    push hl
        ld hl, SFX_open_hi_hat
update_sound_PLAY_SFX_OPEN_HIHAT_entry:
        ld a, SFX_PRIORITY_MUSIC
        call play_SFX_with_priority
    pop hl
    jp update_sound_internal_loop

update_sound_PLAY_SFX_SHORT_HIHAT:
    push hl
        ld hl, SFX_short_hi_hat
        jp update_sound_PLAY_SFX_OPEN_HIHAT_entry

; update_sound_PLAY_SFX_PEDAL_HIHAT:
;     push hl
;     ld hl, SFX_pedal_hi_hat
;     jp update_sound_PLAY_SFX_OPEN_HIHAT_entry

; update_sound_PLAY_SFX_DRUM_SHORT_RE:
;     push hl
;         ld hl, SFX_drum_short_re
;         jp update_sound_PLAY_SFX_OPEN_HIHAT_entry

update_sound_PLAY_SFX_DRUM_SHORTER_C:
    push hl
        ld hl, SFX_drum_shorter_c
        jp update_sound_PLAY_SFX_OPEN_HIHAT_entry

update_sound_PLAY_SFX_DRUM_SHORTER_RE:
    push hl
        ld hl, SFX_drum_shorter_re
        jp update_sound_PLAY_SFX_OPEN_HIHAT_entry

update_sound_PLAY_SFX_SHORT_HIHAT_LOUDER:
    push hl
        ld hl, SFX_short_hi_hat_louder
        jp update_sound_PLAY_SFX_OPEN_HIHAT_entry


IF MUSIC_USE_SET_VOLUME = 1
sound_update_set_volume1:
    ld a, (hl)  ; new volume
    ld (MUSIC_volumes), a
    inc hl
    jp update_sound_internal_loop
sound_update_set_volume2:
    ld a, (hl)  ; new volume
    ld (MUSIC_volumes + 1), a
    inc hl
    jp update_sound_internal_loop
sound_update_set_volume3:
    ld a, (hl)  ; new volume
    ld (MUSIC_volumes + 2), a
    inc hl
    jp update_sound_internal_loop
ENDIF


;update_sound_TRANSPOSE_UP:
;    ld a, (MUSIC_transpose)
;    inc a
;update_sound_TRANSPOSE_UP_entry:
;    ld (MUSIC_transpose), a
;    jp update_sound_internal_loop


;update_sound_CLEAR_TRANSPOSE:
;    xor a
;    jp update_sound_TRANSPOSE_UP_entry


update_sound_PLAY_INSTRUMENT_CH1:
    inc a  ; a = 1
IF MUSIC_USE_ARPEGGIOS = 1
    ld de, MUSIC_instrument_base_note
ENDIF
    jp update_sound_PLAY_INSTRUMENT
update_sound_PLAY_INSTRUMENT_CH2:
    ld a, 3
IF MUSIC_USE_ARPEGGIOS = 1
    ld de, MUSIC_instrument_base_note + 1
ENDIF
    jp update_sound_PLAY_INSTRUMENT
update_sound_PLAY_INSTRUMENT_CH3:
    ld a, (SFX_priority)
    cp SFX_PRIORITY_LOW
    jp p, update_sound_PLAY_INSTRUMENT_IGNORE
    ld a, (MUSIC_channel3_instrument_buffer)
    ld (MUSIC_instruments + 2), a
    ld a, 5
IF MUSIC_USE_ARPEGGIOS = 1
    ld de, MUSIC_instrument_base_note + 2
ENDIF
update_sound_PLAY_INSTRUMENT:
    push hl
        ld b, 0  ; for later use
        ld c, (hl)  ; note to play
        sla c
IF MUSIC_USE_ARPEGGIOS = 1
        ex hl, de
            ld (hl), c  ; store the base note * 2
        ex hl, de
ENDIF
        ld hl, note_period_table
        add hl, bc
        ld e, (hl)  ; MSB of the period    
        inc l  ; note_period_table is 2-aligned
        ld d, a
        fast_WRTPSG_macro
        ld a, d
        ld e, (hl)  ; LSB of the period    
        dec a
        ld d, a
        fast_WRTPSG_macro
        ld a, d
        ld hl, MUSIC_instruments
        ld c, a  ; here  a == 0, 2 or 4 depending on which channel we are playing
        srl a  ; divide by 2
        ADD_HL_A  ; HL = MUSIC_instruments + channel
        ld a, (hl)  ; we get the instrument
        ; we calculate pointer to the instrument envelope
        ld hl, instrument_profile_table
        add a, a
        ADD_HL_A
        ld e, (hl)
        inc hl
        ld d, (hl)
        ld hl, MUSIC_instrument_envelope_ptr
        add hl, bc  ; b should still be 0 here, so, we are just adding c
        ld (hl), e
        inc l
        ld (hl), d

        sra c  ; calculate the volume port: (c/2)+8
        ld a, c
IF MUSIC_USE_SET_VOLUME = 1
        ld hl, MUSIC_volumes
        add hl, bc
        ld b, (hl)  ; b = current channel volume
ENDIF
    pop hl
    add a, 8
    ld c, a
    ld a, (de)
IF MUSIC_USE_SET_VOLUME = 1
    sub a, b
    jr nc, sound_update_PLAY_INSTRUMENT_continue
    xor a
sound_update_PLAY_INSTRUMENT_continue:
ENDIF
    ld e, a
    ld a, c
    fast_WRTPSG_macro
update_sound_PLAY_INSTRUMENT_IGNORE:
    inc hl
    jp update_sound_internal_loop


;-----------------------------------------------
; I don't like redefining a BIOS function, but this is called many times, and 
; a lot of interrupt time is wasted in call/ret/jps and unnecessary push/pops
; so, this saves a lot of time.
; input:
; - a: PSG register number
; - e: data to write
; Values obtained from cbios source code: https://cbios.sourceforge.net/
PSG_REGS: equ #A0  ; PSG register write port
PSG_DATA: equ #A1  ; PSG value write port
fast_WRTPSG_macro: macro
    di
    out (PSG_REGS), a
    ld a, e
    out (PSG_DATA), a
    ei
endm
