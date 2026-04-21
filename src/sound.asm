;-----------------------------------------------
; sound.asm will go to page 0 (so that it can be called from anywhere)
; sound-internal.asm will go to the music page (to save space in page 0)


;-----------------------------------------------
; input:
; - hl: ptr to compressed song
; - a: MUSIC_tempo. This is assumed to be the tempo for 50Hz machines. IF we are in a 60Hz machine,
;      this method will try to adjust it.
play_music_adjusting_tempo:
    ld (MUSIC_original_tempo), a
    ld e, a
    ld a, (isComputer50HzOr60Hz)
    or a
    jr z, play_music_adjusting_tempo_continue
    ld a, e
    cp 14
    jr z, play_music_adjusting_tempo_14
    cp 12
    jr z, play_music_adjusting_tempo_12
    cp 10
    jr z, play_music_adjusting_tempo_10
    cp 8
    jr z, play_music_adjusting_tempo_8
    cp 6
    jr z, play_music_adjusting_tempo_6
    cp 5
    jr z, play_music_adjusting_tempo_5
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_14:
    ld e, 17
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_12:
    ld e, 14
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_10:
    ld e, 12
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_8:
    ld e, 10
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_6:
    ld e, 7
    jr play_music_adjusting_tempo_continue
play_music_adjusting_tempo_5:
    ld e, 6
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

