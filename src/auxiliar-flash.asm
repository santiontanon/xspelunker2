;-----------------------------------------------
; Routines form this file are adapted from the originals here:
; https://www.msx.org/forum/msx-talk/development/ascii-x-flashrom-cartridge?page=9

SAVE_GAME_SIZE: equ 16 + 4 + (RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start)
FLASH_ROUTINES_RAM_SIZE: equ flash_routines_RAM_end - flash_routines_RAM


;-----------------------------------------------
copy_flash_routines_to_RAM:
	ld hl, flash_routines_ROM
	ld de, flash_routines_RAM
	ld bc, FLASH_ROUTINES_RAM_SIZE
	ldir
	ret


;-----------------------------------------------
flash_save_game_to_slot_0:
	ld de, buffer_4096 + FLASH_ROUTINES_RAM_SIZE
	jr flash_save_game_to_slot

flash_save_game_to_slot_1:
	ld de, buffer_4096 + FLASH_ROUTINES_RAM_SIZE + SAVE_GAME_SIZE
	jr flash_save_game_to_slot

flash_save_game_to_slot_2:
	ld de, buffer_4096 + FLASH_ROUTINES_RAM_SIZE + SAVE_GAME_SIZE * 2
	jr flash_save_game_to_slot

flash_save_game_to_slot:
	; save game consists of (< 1024 bytes):
	; #ff / #00 -> empty / used
	; current_world__name: 16 bytes
	; current_world__seed: 4 bytes
	; RAM_to_zero_on_game_start -> RAM_to_zero_on_game_start_end: 982 bytes

	ld a, (current_megarom_page_in_8000)
	push af
		push de
			; copy the current state of the save games to RAM:
			SETMEGAROMPAGE_8000 SAVEGAME_PAGE
			ld hl, #8000
			ld de, buffer_4096 + FLASH_ROUTINES_RAM_SIZE
			ld bc, 3 * FLASH_ROUTINES_RAM_SIZE
			ldir
		pop de
		call flash_prepare_save_game_data

		ld bc, #8000
		call flash_erase

		ld hl, buffer_4096 + FLASH_ROUTINES_RAM_SIZE
		ld de, #8000
		ld bc, 3 * SAVE_GAME_SIZE
		call flash_program
	pop af
	SETMEGAROMPAGE_8000_A
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
	ld hl, RAM_to_zero_on_game_start
	ld bc, RAM_to_zero_on_game_start_end - RAM_to_zero_on_game_start
	ldir
	ret


;-----------------------------------------------
flash_routines_ROM:
	org buffer_4096

flash_routines_RAM:

;-----------------------------------------------
; input:
; - hl: source data
; - de: destination ptr
; - bc: data length
; output:
; - carry: error
flash_program:
	ld a, #aa  ; unlock flash
	ld (#4aaa), a
	ld a, #55
	ld (#4555), a
	ld a, #a0  ; program command
	ld (#4aaa), a
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
	jr nz, flash_program

	ret


;-----------------------------------------------
; input:
; - bc: address inside the sector we want to erase.
flash_erase:
	ld hl, #4aaa
	ld de, #4555
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
