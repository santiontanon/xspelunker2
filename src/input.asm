; KEY_WEAPON_BIT: equ 0
; KEY_JUMP_BIT: equ 1
; KEY_INVENTORY_BIT: equ 2
; KEY_INTERACT_BIT: equ 3
; KEY_LEFT_BIT: equ 4
; KEY_UP_BIT: equ 5
; KEY_DOWN_BIT: equ 6
; KEY_RIGHT_BIT: equ 7

;-----------------------------------------------
; updates the 'keyboard_state', 'keyboard_state_prev', and 'keyboard_clicks'
update_keyboard_buffers:
    ld b, 8
    ld hl, config_keyboard
    xor a
update_keyboard_buffers_loop:
    push af
    push bc
        ld a, (hl)  ; keyboard martrix line
        inc hl
        push hl
            call SNSMAT
        pop hl
        ld c, (hl)  ; mask
        inc hl
        and c
        jr z, update_keyboard_buffers_loop_pressed
    pop bc
    pop af
    rlca
    or #1
    djnz update_keyboard_buffers_loop
    jr update_keyboard_buffers_loop_done
update_keyboard_buffers_loop_pressed:
    pop bc
    pop af
    rlca
    djnz update_keyboard_buffers_loop
update_keyboard_buffers_loop_done:
    ld (keyboard_state), a
    call read_joystick

    ld hl, keyboard_state_prev
    ld a, (keyboard_state)
    ld b, (hl)
    ld (hl), a
    xor b
    and b
    ld (keyboard_clicks), a
    ret


;-----------------------------------------------
; updates the 'keyboard_line_state' and 'keyboard_line_state_prev' buffers
; update_keyboard_buffers:
;     ld a, #08
;     call SNSMAT
;     ld (keyboard_line_state), a  ; RIGHT, DOWN, UP, LEFT, DEL, INS, HOME, SPACE

;     ld a, #04
;     call SNSMAT
;     ld (keyboard_line_state + 2), a  ; R, Q, P, O, N, M, L, K

;     call read_joystick

;     ld de, keyboard_line_state
;     ld hl, keyboard_line_state_prev
;     ld bc, #0204  ; c just > b so that "ldi" will not interferer with b.
; update_keyboard_buffers_loop:
;         ld a, (de)
;         xor (hl)
;         and (hl)  ; a now has the value to save in "keyboard_line_clicks" (which is "keyboard_line_state", offset by 1)
;         ex de, hl
;             ldi
;         ex de, hl
;         ld (de), a  ; save the click in "keyboard_line_clicks"
;         inc de
;     djnz update_keyboard_buffers_loop
;     ret


;-----------------------------------------------
; Reads the joystick status, and updates the corresponding keyboard_line_state to treat it as if it was the keyboard
read_joystick:
    ld a, 15 ; read the joystick 1 status:
    di
    call RDPSG
    and #bf
    ld e, a
    ld a, 15
    call WRTPSG
    dec a
    call RDPSG  ; a = -, -, B, A, right, left, down, up
    ei

    ; convert the joystick input to keyboard input
    ld c, a
    ; arrows/space:
    ld hl, keyboard_state
    ld a, (hl)
    
    rr c
    jr c, read_joystick_noUp
    and #df
read_joystick_noUp:

    rr c
    jr c, read_joystick_noDown
    and #bf
read_joystick_noDown:

    rr c
    jr c, read_joystick_noLeft
    and #ef
read_joystick_noLeft:

    rr c
    jr c, read_joystick_noRight
    and #7f
read_joystick_noRight:

    rr c
    jr c, read_joystick_noA
    and #fe
read_joystick_noA:

    rr c
    jr c, read_joystick_noB
    and #fb
read_joystick_noB:

    ld (hl), a   ; we add the joystick input to the keyboard input
    ret


;-----------------------------------------------
; Waits until the player presses button 1, button 2, or interaction key
wait_for_click:
    call update_keyboard_buffers
    ld a, (keyboard_clicks)
    bit KEY_WEAPON_BIT, a
    ret nz
    bit KEY_JUMP_BIT, a
    ret nz
    bit KEY_INTERACT_BIT, a
    ret nz
    halt
    jr wait_for_click

