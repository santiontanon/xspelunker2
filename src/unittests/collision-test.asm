	org #0000

COLLISION_UNIT_TESTING: equ 1

	include "../constants.asm"
	include "../collision.asm"
	include "../player.asm"


ASSERT_COLLISION: macro
	jr z, assert_z_continue
	ld hl, (player_x)
	ld de, (player_y)
	nop  ; mdl-watch: "expected collision at:", hl, de
	jp test_end
assert_z_continue:
	endm

ASSERT_NO_COLLISION: macro
	jr nz, assert_nz_continue
	ld hl, (player_x)
	ld de, (player_y)
	nop  ; mdl-watch: "expected no collision at:", hl, de
	jp test_end
assert_nz_continue:
	endm


COLLISION_TEST: macro x, y, expected_left, expected_up, expected_right, expected_down
	ld hl, x
	ld (player_x), hl
	ld hl, y
	ld (player_y), hl

	; left:
	call player_update_move_one_pixel_left_considering_collisions
	ld hl, (player_x)
	ld bc, x
	or a
	sbc hl, bc
	ld a, h
	or l
IF expected_left == 1
	jr z, COLLISION_TEST_continue_left
	ld hl, x
	ld de, y
	nop  ; mdl-watch: "expected left collision at", hl, de
ELSE
	jr nz, COLLISION_TEST_continue_left
	ld hl, x
	ld de, y
	nop  ; mdl-watch: "expected no left collision at", hl, de
ENDIF
COLLISION_TEST_continue_left:
	ld hl, x
	ld (player_x), hl

	call player_check_collision_up
IF expected_up == 1
	ASSERT_COLLISION
ELSE
	ASSERT_NO_COLLISION
ENDIF

	; right:
	call player_update_move_one_pixel_right_considering_collisions
	ld hl, (player_x)
	ld bc, x
	or a
	sbc hl, bc
	ld a, h
	or l
IF expected_right == 1
	jr z, COLLISION_TEST_continue_right
	ld hl, x
	ld de, y
	nop  ; mdl-watch: "expected right collision at", hl, de
ELSE
	jr nz, COLLISION_TEST_continue_right
	ld hl, x
	ld de, y
	nop  ; mdl-watch: "expected no right collision at", hl, de
ENDIF
COLLISION_TEST_continue_right:
	ld hl, x
	ld (player_x), hl

	call player_check_collision_down_inc
IF expected_down == 1
	ASSERT_COLLISION
ELSE
	ASSERT_NO_COLLISION
ENDIF
	endm


test_start:
	ld sp, #0000

	; assuming: 
	; PLAYER_COLLISION_BOX_WIDTH: equ 2

	; testing collisions left:
	COLLISION_TEST #0303, #0300, 1, 1, 0, 0
	COLLISION_TEST #0400, #0300, 0, 1, 0, 0
	COLLISION_TEST #0401, #0300, 0, 1, 0, 0
	COLLISION_TEST #0402, #0300, 0, 1, 0, 0
	COLLISION_TEST #0403, #0300, 1, 0, 0, 0
	COLLISION_TEST #0404, #0300, 0, 0, 0, 0
	COLLISION_TEST #0405, #0300, 0, 0, 0, 0
	COLLISION_TEST #0406, #0300, 0, 0, 0, 0
	COLLISION_TEST #0407, #0300, 0, 0, 0, 0
	COLLISION_TEST #0500, #0300, 0, 0, 0, 0
	COLLISION_TEST #0503, #0300, 0, 0, 0, 0
	COLLISION_TEST #0600, #0300, 0, 0, 0, 0
	; left + head:
	COLLISION_TEST #0403, #0400, 1, 0, 0, 0
	COLLISION_TEST #0403, #0401, 1, 0, 0, 0
	COLLISION_TEST #0403, #0402, 1, 0, 0, 0
	COLLISION_TEST #0403, #0403, 1, 0, 0, 0
	COLLISION_TEST #0403, #0404, 1, 0, 0, 0
	COLLISION_TEST #0403, #0405, 0, 0, 0, 0

	; testing collisions up:
	COLLISION_TEST #0100, #0407, 0, 0, 0, 0
	COLLISION_TEST #0101, #0407, 0, 0, 0, 0
	COLLISION_TEST #0102, #0407, 0, 0, 0, 0
	COLLISION_TEST #0103, #0407, 0, 0, 0, 0
	COLLISION_TEST #0104, #0407, 0, 0, 0, 0
	COLLISION_TEST #0105, #0407, 0, 0, 0, 0
	COLLISION_TEST #0106, #0407, 0, 1, 0, 0
	COLLISION_TEST #0107, #0407, 0, 1, 0, 0
	COLLISION_TEST #0200, #0407, 0, 1, 0, 0
	COLLISION_TEST #0300, #0407, 0, 1, 0, 0
	COLLISION_TEST #0300, #0500, 0, 0, 0, 0
	COLLISION_TEST #0400, #0407, 0, 1, 0, 0
	COLLISION_TEST #0401, #0407, 0, 1, 0, 0
	COLLISION_TEST #0402, #0407, 0, 1, 0, 0
	COLLISION_TEST #0403, #0407, 0, 0, 0, 0
	COLLISION_TEST #0404, #0407, 0, 0, 0, 0
	COLLISION_TEST #0405, #0407, 0, 0, 0, 0
	COLLISION_TEST #0406, #0407, 0, 0, 0, 0
	COLLISION_TEST #0407, #0407, 0, 0, 0, 0
	COLLISION_TEST #0500, #0407, 0, 0, 0, 0

	; testing collisions right:
	COLLISION_TEST #0104, #0101, 0, 0, 0, 0
	COLLISION_TEST #0105, #0101, 0, 0, 1, 0
	COLLISION_TEST #0105, #0100, 0, 0, 0, 0
	COLLISION_TEST #0106, #0100, 0, 0, 0, 1

	COLLISION_TEST #0100, #0300, 0, 0, 0, 0
	COLLISION_TEST #0101, #0300, 0, 0, 0, 0
	COLLISION_TEST #0102, #0300, 0, 0, 0, 0
	COLLISION_TEST #0103, #0300, 0, 0, 0, 0
	COLLISION_TEST #0104, #0300, 0, 0, 0, 0
	COLLISION_TEST #0105, #0300, 0, 0, 1, 0
	COLLISION_TEST #0105, #0301, 0, 0, 1, 0
	COLLISION_TEST #0106, #0300, 0, 1, 0, 0
	COLLISION_TEST #0107, #0300, 0, 1, 0, 0
	COLLISION_TEST #0107, #0301, 0, 1, 0, 0
	COLLISION_TEST #0200, #0300, 0, 1, 0, 0
	COLLISION_TEST #0205, #0300, 0, 1, 1, 0
	COLLISION_TEST #0205, #0301, 0, 1, 1, 0
	COLLISION_TEST #0300, #0300, 0, 1, 0, 0
	; right + head:
	COLLISION_TEST #0105, #0400, 0, 0, 1, 0
	COLLISION_TEST #0105, #0401, 0, 0, 1, 0
	COLLISION_TEST #0105, #0402, 0, 0, 1, 0
	COLLISION_TEST #0105, #0403, 0, 0, 1, 0
	COLLISION_TEST #0105, #0404, 0, 0, 1, 0
	COLLISION_TEST #0105, #0405, 0, 0, 0, 0

	; testing collisions down:
	COLLISION_TEST #0100, #0100, 0, 0, 0, 0
	COLLISION_TEST #0101, #0100, 0, 0, 0, 0
	COLLISION_TEST #0102, #0100, 0, 0, 0, 0
	COLLISION_TEST #0103, #0100, 0, 0, 0, 0
	COLLISION_TEST #0104, #0100, 0, 0, 0, 0
	COLLISION_TEST #0105, #0100, 0, 0, 0, 0
	COLLISION_TEST #0106, #0100, 0, 0, 0, 1
	COLLISION_TEST #0107, #0100, 0, 0, 0, 1
	COLLISION_TEST #0200, #0100, 0, 0, 0, 1
	COLLISION_TEST #0300, #0100, 0, 0, 0, 1
	COLLISION_TEST #0300, #0007, 0, 0, 0, 0
	COLLISION_TEST #0400, #0100, 0, 0, 0, 1
	COLLISION_TEST #0401, #0100, 0, 0, 0, 1
	COLLISION_TEST #0402, #0100, 0, 0, 0, 1
	COLLISION_TEST #0403, #0100, 0, 0, 0, 0
	COLLISION_TEST #0404, #0100, 0, 0, 0, 0
	COLLISION_TEST #0405, #0100, 0, 0, 0, 0
	COLLISION_TEST #0406, #0100, 0, 0, 0, 0
	COLLISION_TEST #0407, #0100, 0, 0, 0, 0
	COLLISION_TEST #0500, #0100, 0, 0, 0, 0

	nop  ; mdl-watch: "all tests passed"
test_end:
	jr test_end


current_room__width:
  db 32
current_room__height:
  db 24
current_room__tile_map:
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 150, 155, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 152, 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

current_room__max_scroll_x:
  db 0
current_room__max_scroll_y:
  db 0



	org #c000

player_x: ds virtual 2  ; 1st byte is the tile coordinate, and 2nd the pixel
player_y: ds virtual 2  ; 1st byte is the tile coordinate, and 2nd the pixel
player_state: ds virtual 1

