;-----------------------------------------------
; Routines form this file are adapted from the originals here:
; https://www.msx.org/forum/msx-talk/development/ascii-x-flashrom-cartridge?page=9

SAVE_GAME_SIZE: equ 1 + 16 + 4 + 2 + (RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start)
FLASH_ROUTINES_RAM_SIZE: equ flash_routines_RAM_end - flash_routines_RAM

SAVEGAME_CURRENT_AREA_ID_OFFSET: equ 1 + 16 + 4
SAVEGAME_CURRENT_ROOM_ID_OFFSET: equ 1 + 16 + 4 + 1

SAVEGAME_TIME_OFFSET: equ 1 + 16 + 4 + 2 + (stats__time - RAM_to_zero_on_game_start)
SAVEGAME_PLAYER_HEALTH_OFFSET: equ 1 + 16 + 4 + 2 + (player_health - RAM_to_zero_on_game_start)
SAVEGAME_PLAYER_MAX_HEALTH_OFFSET: equ 1 + 16 + 4 + 2 + (player_max_health - RAM_to_zero_on_game_start)
SAVEGAME_PLAYER_COINS_OFFSET: equ 1 + 16 + 4 + 2 + (player_inventory_coins - RAM_to_zero_on_game_start)


;-----------------------------------------------
copy_flash_routines_to_RAM:
	ld hl, flash_routines_ROM
	ld de, flash_routines_RAM
	ld bc, FLASH_ROUTINES_RAM_SIZE
	ldir
	ret


;-----------------------------------------------
copy_savegames_to_RAM:
	push hl
	push de
	push bc
		ld hl, copy_savegames_to_RAM_internal
		ld c, SAVEGAME_PAGE
		call call_hl_in_page_c_8000
	pop bc
	pop de
	pop hl
	ret

copy_savegames_to_RAM_internal:
	ld hl, #8000
	ld de, buffer_4096 + FLASH_ROUTINES_RAM_SIZE
	ld bc, 3 * SAVE_GAME_SIZE
	ldir
	ret


;-----------------------------------------------
; save game consists of (< 1024 bytes):
; - #ff / #00 -> empty / used: 1 byte
; - current_world__name: 16 bytes
; - current_world__seed: 4 bytes
; - current_area__id / current_room__id: 2 bytes
; - RAM_to_zero_on_game_start -> RAM_to_zero_on_game_start_end: 982 bytes
flash_save_game_to_slot:
	call copy_savegames_to_RAM
	call flash_prepare_save_game_data
	halt  ; so that no interrup arrives in metween PauseMusic and "di"
	call PauseMusic
	di  ; PauseMusic re-enables them, so, we need to put this after

		ld hl, #8000
		call flash_erase

		ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE
		ld de, #8000
		ld bc, 3 * SAVE_GAME_SIZE
		call flash_program
		push af  ; keep whether the call succeeded (no carry) or failed (carry)
			call ResumeMusic
		pop af
	ei
	ret


;-----------------------------------------------
; input:
; - de: pointer where to save the savegame data
flash_prepare_save_game_data:
	xor a
	ld (de), a
	inc de
	ld hl, current_world__name
	ld bc, 16
	ldir
	ld hl, current_world__seed
	ld bc, 4
	ldir
	ld hl, current_area__id
	ldi
	ld hl, current_room__id
	ldi
	ld hl, RAM_to_zero_on_game_start
	ld bc, RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start
	ldir
	ret


;-----------------------------------------------
flash_routines_ROM:
	org buffer_4096

flash_routines_RAM:


;-----------------------------------------------
flash_call_hl_in_savegamepage_8000_interrupts_off:
    ld a, (current_megarom_page_in_8000)  ; 3 bytes
    push af  ; 1 byte
        ld a, SAVEGAME_PAGE  ; 1 byte
        ld (#7000), a  ; 3 bytes
        ld (current_megarom_page_in_8000), a  ; 3 bytes
        call jp_to_hl
    ex af, af'  ; preserve the return af of the function we called
        pop af  ; 1 byte
        ld (#7000), a  ; 3 bytes
        ld (current_megarom_page_in_8000), a  ; 3 bytes
    ex af, af'
    ret  ; 1 byte


;-----------------------------------------------
; input:
; - hl: source data
; - de: destination ptr
; - bc: data length
; output:
; - carry: error
flash_program:
	push hl
	pop ix
	ld hl, flash_program_internal
	jp flash_call_hl_in_savegamepage_8000_interrupts_off


;-----------------------------------------------
; input:
; - ix: source data
; - de: destination ptr
; - bc: data length
; output:
; - carry: error
flash_program_internal:
	push ix
	pop hl
flash_program_internal_loop:
	ld a, #aa  ; unlock flash
	ld (#8aaa), a
	ld a, #55
	ld (#8555), a
	ld a, #a0  ; program command
	ld (#8aaa), a
	ld a, (hl)
	ld (de), a
	push bc
		call check_flash_status
	pop bc
	ret c  ; carry = 1 if error (return)

	inc hl
	inc de
	dec bc
	ld a, b
	or c
	jr nz, flash_program_internal_loop
	ret


;-----------------------------------------------
; input:
; - hl: address inside the sector we want to erase.
flash_erase:
	ex de, hl
	ld hl, flash_erase_internal
	jp flash_call_hl_in_savegamepage_8000_interrupts_off


;-----------------------------------------------
; input:
; - de: address inside the sector we want to erase.
flash_erase_internal:
	ld c, e
	ld b, d
	ld hl, #8aaa
	ld de, #8555
	ld (hl), l  ; #aa
	ld a, e  ; #55
	ld (de), a
	ld (hl), #80  ; erase prepare
	ld (hl), l  ; #aa
	ld (de), a
	ld a, #30  ; erase confirm
	ld (bc), a
	ld a, #ff
	ld d, b
	ld e, c
	; jr check_flash_status


;-----------------------------------------------
; input:
; - de: address where it we are expecting the value to be in
; - a: value we expect to be written
check_flash_status:
	ld c, a

check_flash_status_loop:
	ld a, (de)  ; pull byte
	xor c
	jp p, check_flash_status_exit  ; if bit7 matches,  finished
	xor c
	and #20  ; dq5 timeout?
	jr z, check_flash_status_loop

	ld a, (de)
	xor c
	jp p, check_flash_status_exit

	scf  ; set carry to indicate error
	ld a, #f0  ; if error occurs (do not leave flash rom waiting in programming mode)
	ld (de), a

check_flash_status_exit:
	ret


flash_routines_RAM_end:
	org flash_routines_ROM + FLASH_ROUTINES_RAM_SIZE
flash_routines_ROM_end:
